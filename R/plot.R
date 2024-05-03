##' @title Plot method for ivd objects
##' @param obj An object of type `ivd`.
##' @param type Defaults to 'pip', other options are 'caterpillar' and 'funnel'
##' @param ci The width of the credible interval that should be used. Defaults to 0.9.
##' @param col_id Whether the plot should color in points by their unique identifier.
##' @param legend Should legend be included? Defaults to TRUE
##' @param ... Currently not in use.
##' @author Philippe Rast
##' @import ggplot2 patchwork
##' @export


plot.ivd <- function(obj, type = "pip", variable = NULL, col_id = TRUE, legend = TRUE, ...) {
  ## Get scale variable names
  ranef_scale_names <- colnames(obj$Z_scale)
  fixef_scale_names <- colnames(obj$X_scale)
  
  col_names <- colnames(obj$samples[[1]])
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
  subsamples <- lapply(obj$samples, function(x) x[, cols_to_keep])

  ## Calculate column means for each subsetted MCMC matrix
  means_list <- lapply(subsamples, colMeans)

  ## Aggregate these means across all chains
  ## This computes the mean of means for each column across all chains
  ## TODO: This is combining intercep and slope pips -- FIX
  final_means <- Reduce("+", means_list) / length(means_list)

  ## Define ordered dataset
  df_pip <- data.frame(id = seq_len(length(final_means)),
                       pip = final_means)
  df_pip <- df_pip[order(df_pip$pip), ]
  df_pip$ordered <- 1:nrow(df_pip)

  ## Get number of random scale effects:
  no_ranef_s <- obj$nimble_constants$Sr

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

  
  if( type == "pip") {
    ## 
    plt <- ggplot(df_pip, aes(x = ordered, y = pip)) +
      geom_point( aes(color = as.factor(id)), size = 3) +
      geom_text(data = subset(df_pip, pip >= 0.75),
                aes(label = id),
                nudge_x = -10,
                size = 3) +
      geom_abline(intercept = 0.75, slope = 0, lty =  3)+
      geom_abline(intercept = 0.25, slope = 0, lty =  3)+
      ylim(c(0, 1 ) ) + 
      guides(color ="none")
    print(plt )
  } else {
    if( type == "funnel" ) {
      ## Create tau locally
      if(no_ranef_s == 1) {
        ## Extract the posterior mean of the fixed effect:
        zeta <- mean( unlist( lapply(obj$samples, FUN = function(x) mean(x[, "zeta[1]"])) ) )
        ## Extract the posterior mean of each random effect:
        u <- colMeans(do.call(rbind, lapply(obj$samples, FUN = function(x) colMeans(x[, scale_ranef_pos]))))
        tau <- exp(zeta + u )
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
       
       ## Find position of user requested fixed effect
       ## TODO: When interactions are present plot will change according to moderator...
       ## Currently only main effect is selected
       scale_fixef_position_user <- which(fixef_scale_names == variable)

       ## Use ranef_position_user to select corresponding fixed effect
       zeta <- mean( unlist( lapply(obj$samples, FUN = function(x) mean(x[, paste0("zeta[", scale_fixef_position_user, "]")])) ) )

       ## Extract the posterior mean of each random effect:        
       pos <- scale_ranef_pos[ grepl( paste0(Kr + scale_ranef_position_user, "\\]"),  names(scale_ranef_pos ) ) ]

       u <- colMeans(do.call(rbind, lapply(obj$samples, FUN = function(x) colMeans(x[, pos]))))
       tau <- exp(zeta + u )

      } else {
        print("Invalid action specified. Exiting.")
      }
    }

    ## Add tau to data frame -- ensure correct order
    df_funnel <- cbind(df_pip[order(df_pip$id), ], tau )

    ## Make nudge scale dependent:
    nx <- (max(df_funnel$tau ) - min(df_funnel$tau ))/50

    plt <- ggplot(df_funnel, aes(x = tau, y = pip, color = as.factor(id))) +
      geom_point( ) +
      guides(color = FALSE) + labs(x = "Within-Cluster SD") +
      geom_text(data = subset(df_funnel, pip >= 0.75),
                aes(label = id),
                nudge_x = -nx,
                size = 3)+
      geom_abline(intercept = 0.75, slope = 0, lty =  3)+
      geom_abline(intercept = 0.25, slope = 0, lty =  3)+
      ylim(c(0, 1 ) )
    print( plt )
  }
  return(invisible(plt))  
}





##' For more plots see coda
##' @title Traceplot from the coda package
##' @param obj ivd object
##' @param parameters Provide parameters of interest as c("parameter1", "paramter2") etc.
##' @param type Coda plot. Defaults to 'traceplot'
##' @return Specified coda plot
##' @author Philippe Rast
##' @import coda
##' @export
codaplot <- function(obj, parameters = NULL, type = 'traceplot') {
  ## TODO: Inherit variable names from summary object
  
  ## Check if 'type' corresponds to a valid coda plotting function
  ## Typically, these would be 'plot', 'acfplot', etc.
  ## The user needs to ensure the correct function name is provided.

  ## Attempt to get the plotting function based on 'type'
  plot_func <- match.fun(type)
  
  if(is.null(parameters)) {
    ## If no parameters specified, apply the chosen function to all samples
    params <- dimnames(.summary_table(obj$samples[[1]] ))[[2]]

    ## Apply the chosen function to the specified parameters
    if (length(params) > 1) {
      ## Prompt user to move between plots when multiple parameters are involved
      devAskNewPage(TRUE)
    }
    
    for (param in params) {
      print(plot_func(obj$samples[, param, drop = FALSE]))
    }
    
    ## Restore default behavior (no prompt) after finishing the plots
    if (length(params) > 1) {
      devAskNewPage(FALSE)
    }
    
  } else {
    ## If parameters are specified, subset the samples first
    params <- c(parameters)
    ## Ensure that subsetting does not reduce the data incorrectly
    if (!all(params %in% colnames(obj$samples[[1]]))) {
      stop("Some specified parameters do not exist in the samples.")
    }
    
    ## Apply the chosen function to the specified parameters
    if (length(params) > 1) {
      ## Prompt user to move between plots when multiple parameters are involved
      devAskNewPage(TRUE)
    }
    
    for (param in params) {
      print(plot_func(obj$samples[, param, drop = FALSE]))
    }
    
    ## Restore default behavior (no prompt) after finishing the plots
    if (length(params) > 1) {
      devAskNewPage(FALSE)
    }
  }
}
