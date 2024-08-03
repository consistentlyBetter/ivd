##' @title Plot method for ivd objects
##' @param x An object of type `ivd`.
##' @param type Defaults to 'pip', other options are 'funnel' and 'outcome'.
##' @param pip_level Defines a value for the posterior inclusion probability. Defaults to 0.75.
##' @param variable Name of a specific variable. Defaults to `NULL`
##' @param col_id Whether the plot should color in points by their unique identifier.
##' @param legend Should legend be included? Defaults to `TRUE`.
##' @param ... Currently not in use.
##' @author Philippe Rast
##' @import ggplot2 
##' @importFrom patchwork plot_layout
##' @importFrom stats aggregate
##' @export
plot.ivd <- function(x, type = "pip", pip_level = .75, variable = NULL, col_id = TRUE, legend = TRUE, ...) {
  obj <- x
  ## Get scale variable names
  ranef_scale_names <- colnames(obj$Z_scale)
  fixef_scale_names <- colnames(obj$X_scale)
  
  col_names <- dimnames(.summary_table(obj$samples[[1]]$samples ))[[2]]
  Kr <- obj$nimble_constants$Kr

  cols_to_keep <- c( )
  ## Find spike and slab variables
  col_ss <- col_names[ grepl( "^ss\\[", col_names ) ]
  for(col_name in col_ss) {
    col_number <- as.numeric(unlist(regmatches(col_name, gregexpr("[0-9]+", col_name)))[1])
    if(col_number >  Kr ) {
      cols_to_keep <- c(cols_to_keep,  col_name )
    }
  }

  ## Subset each MCMC matrix to keep only the relevant columns
  subsamples <- lapply(.extract_to_mcmc(obj), function(x) x[, cols_to_keep])
  
  ## Calculate column means for each subsetted MCMC matrix
  means_list <- lapply(subsamples, colMeans)

  ## Average across the lists and chains
  final_means <- Reduce("+", means_list) / length(means_list)

  ## assign the means to the specific random effects
  ss_means <- list()
  ## Select the ss effect(s)
  Sr <- obj$nimble_constants$Sr
  for(i in 1:Sr ) {
    index <- paste0("\\[",  i+Kr)
    position_ss_value <- grepl(index, names(means_list[[1]]) )
    ss_means[[i]] <- final_means[position_ss_value]
  }

  ## Get number of random scale effects:
  no_ranef_s <- obj$nimble_constants$Sr

  ## With multiple random effects, ask user which one to be plotted:
  if(no_ranef_s == 1) {  
    ## Define ordered dataset
    df_pip <- data.frame(id = seq_len(length(ss_means[[1]])),
                         pip = ss_means[[1]])
    df_pip <- df_pip[order(df_pip$pip), ]
    df_pip$ordered <- 1:nrow(df_pip)
  } else if (no_ranef_s > 1 ) {
       if(is.null(variable)) {
         ## Prompt user for action when there are multiple random effects
         variable <- readline(prompt="There are multiple random effects. Please provide the variable name to be plotted or type 'list' \n(or specify as plot(fitted, type = 'funnel', variable = 'variable_name'): ")
         if (tolower(variable) == "list") {
           variable <- readline(prompt = cat(ranef_scale_names, ": "))
         }
       }

       ## Find position of user requested random effect
       scale_ranef_position_user <- which(ranef_scale_names == variable)
       
       ## Define ordered dataset
       df_pip <- data.frame(id = seq_len(length(ss_means[[scale_ranef_position_user]])),
                            pip = ss_means[[scale_ranef_position_user]])
       df_pip <- df_pip[order(df_pip$pip), ]
       df_pip$ordered <- 1:nrow(df_pip)
  }

  
  ## find scale random effects
  ## Extract numbers and find locations
  column_indices <- sapply(col_names, function(x) {
    if (grepl("^u\\[", x)) {  # Check if the name starts with 'u['
      ## Extracting numbers
      nums <- as.numeric(unlist(strsplit(gsub("[^0-9,]", "", x), ",")))
      ## Check if second number (column index) is greater than Kr
      return(nums[2] > Kr)
    } else {
      return(FALSE )
    }
  })
  
  ## Indices of columns where column index is greater than Kr
  scale_ranef_pos <- which(column_indices)
  
  ## Create tau locally
  if(no_ranef_s == 1) {
    ## Extract the posterior mean of the fixed effect:
    zeta <- mean( unlist( lapply(.extract_to_mcmc( obj ), FUN = function(x) mean(x[, "zeta[1]"])) ) )
    ## Extract the posterior mean of each random effect:
    u <- colMeans(do.call(rbind, lapply(.extract_to_mcmc( obj ), FUN = function(x) colMeans(x[, scale_ranef_pos]))))
    tau <- exp(zeta + u )
  } else if (no_ranef_s > 1 ) {
    ## if(is.null(variable)) {
    ##   ## Prompt user for action when there are multiple random effects
    ##   variable <- readline(prompt="There are multiple random effects. Please provide the variable name to be plotted or type 'list' \n(or specify as plot(fitted, type = 'funnel', variable = 'variable_name'): ")
    ##   if (tolower(variable) == "list") {
    ##     variable <- readline(prompt = cat(ranef_scale_names, ": "))
    ##   }
    ## }
    
    ## Find position of user requested random effect
    scale_ranef_position_user <-
      which(ranef_scale_names == variable)
    
    ## Find position of user requested fixed effect
    ## TODO: When interactions are present plot will change according to moderator...
    ## Currently only main effect is selected
    scale_fixef_position_user <-
      which(fixef_scale_names == variable)
    
    ## Use ranef_position_user to select corresponding fixed effect
    zeta <- mean( unlist( lapply(.extract_to_mcmc(obj), FUN = function(x) mean(x[, paste0("zeta[", scale_fixef_position_user, "]")])) ) )
    
    ## Extract the posterior mean of each random effect:        
    pos <- scale_ranef_pos[ grepl( paste0(Kr + scale_ranef_position_user, "\\]"),  names(scale_ranef_pos ) ) ]
    
    u <-
      colMeans(do.call(rbind, lapply(.extract_to_mcmc(obj ), FUN = function(x) colMeans(x[, pos]))))
    tau <- exp(zeta + u )
    
  } else {
    print("Invalid action specified. Exiting.")
  }
  
  if( type == "pip") {
    ## 
    plt <- ggplot(df_pip, aes(x = ordered, y = pip)) +
      geom_point(data = subset(df_pip, pip < pip_level), alpha = .4 , size = 3) +
      geom_point(data = subset(df_pip, pip >= pip_level),
                 aes(color = as.factor(id)), size = 3) +
      # geom_text(data = subset(df_pip, pip >= pip_level),
      #           aes(label = id),
      #           nudge_x = -10,
      #           size = 3) +
      geom_abline(intercept = pip_level, slope = 0, lty =  3)+
      geom_abline(intercept = pip_level - .5, slope = 0, lty =  3)+
      ylim(c(0, 1 ) ) + ggtitle(variable )+
      scale_color_discrete(name = "Cluster ID")
    print(plt )
  } else if ( type == "funnel" ) {

    ## Add tau to data frame -- ensure correct order
    df_funnel <-
      cbind(df_pip[order(df_pip$id), ], tau )

    ## Make nudge scale dependent:
    ## (not used)
    # nx <- (max(df_funnel$tau ) - min(df_funnel$tau ))/50

    plt <- ggplot(df_funnel, aes(x = tau, y = pip)) +
      geom_point(data = subset(df_funnel, pip < pip_level), alpha = .4 ) +
      geom_point(data = subset(df_funnel, pip >= pip_level),
                 aes(color = as.factor(id))) +
      labs(x = "Within-Cluster SD") +
      # geom_text(data = subset(df_funnel, pip >= pip_level),
      #           aes(label = id),
      #           nudge_x = -nx,
      #           size = 3)+
      geom_abline(intercept = pip_level, slope = 0, lty =  3)+
      geom_abline(intercept = pip_level - .5, slope = 0, lty =  3)+
      ylim(c(0, 1 ) )+ggtitle(variable) +
      scale_color_discrete(name = "Cluster ID")
    print( plt )
  } else if ( type == "outcome") {
    ## Declare global variable to avoid R CMD check NOTE
    Y <- NA
    
    df_y <- merge(df_pip,
                  aggregate(Y ~ group_id, data = obj$Y, FUN = mean),
                  by.x = "id", by.y = "group_id")
    df_y$tau <- tau
    ## 
    plt <- ggplot(df_y, aes(x = Y, y = pip)) +
      geom_point(data = subset(df_y, pip < pip_level), aes(size=tau), alpha = .4) +
      geom_point(data = subset(df_y, pip >= pip_level),
                 aes(color = as.factor(id), size = tau)) +
      geom_abline(intercept = pip_level, slope = 0, lty =  3)+
      geom_abline(intercept = pip_level - .5, slope = 0, lty =  3)+
      ylim(c(0, 1 ) ) + 
      ggtitle(variable ) +
      scale_color_discrete(name = "Cluster ID") +
      guides(size = "none")
    print(plt )
  } else {
    stop("Invalid plot type. Please choose between 'pip', 'funnel' or 'outcome'.")
  }
  return(invisible(plt))  
}





##' For more plots see coda
##' @title Traceplot from the coda package
##' @param obj ivd object
##' @param parameters Provide parameters of interest as c("parameter1", "paramter2") etc.
##' @param type Coda plot. Defaults to 'traceplot'. See coda for more options such as 'acfplot', 'densplot' etc.
##' @param askNewPage Should user be prompted for next plot. Defaults to `TRUE`
##' @return Specified coda plot
##' @author Philippe Rast
##' @import coda
##' @importFrom grDevices devAskNewPage
##' @export
codaplot <- function(obj, parameters = NULL, type = 'traceplot', askNewPage = TRUE) {
  ## TODO: Inherit variable names from summary object

  ## Extract to mcmc object
  extract_samples <- .extract_to_mcmc(obj)
  
  ## Check if 'type' corresponds to a valid coda plotting function
  ## Typically, these would be 'plot', 'acfplot', etc.
  ## The user needs to ensure the correct function name is provided.

  ## Attempt to get the plotting function based on 'type'
  plot_func <- match.fun(type)
  
  if(is.null(parameters)) {
    ## If no parameters specified, apply the chosen function to all samples
    params <- dimnames(.summary_table(obj$samples[[1]]$samples ))[[2]]
    
    ## Apply the chosen function to the specified parameters    
    for (param in params) {
      plot_func(mcmc.list(extract_samples)[, param, drop = FALSE])
      if (length(params) > 1) {
        ## Prompt user to move between plots when multiple parameters are involved
        devAskNewPage(askNewPage)
      }
    }
    
    ## Restore default behavior (no prompt) after finishing the plots
    if (length(params) > 1) {
      devAskNewPage(FALSE)
    }
    
  } else {
    ## If parameters are specified, subset the samples first
    params <- c(parameters)
    ## Ensure that subsetting does not reduce the data incorrectly
    if (!all( params %in% colnames(extract_samples[[1]]))) {
      stop("Some specified parameters do not exist in the samples.")
    }

    ## Apply the chosen function to the specified parameters
    for (param in params) {
      plot_func(mcmc.list(extract_samples)[, param, drop = FALSE])
      if (length(params) > 1) {
        ## Prompt user to move between plots when multiple parameters are involved
        devAskNewPage(askNewPage)
      }
    }
    
    ## Restore default behavior (no prompt) after finishing the plots
    if (length(params) > 1) {
      devAskNewPage(FALSE)
    }
  }
}
