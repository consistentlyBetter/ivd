##' Helper to check for suggested package
##' @param pkg requested package
##' @param feature requested feature
##' @author philippe
.require_suggest <- function(pkg, feature) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(
            sprintf(
                "Package '%s' is required %s. Please install it.",
                pkg, if (nzchar(feature)) paste("to use", feature) else ""
            ),
            call. = FALSE
        )
    }
}

##' @title Plot method for ivd objects
##' @param x An object of type `ivd`.
##' @param type Defaults to 'pip', other options are 'funnel' and 'outcome'.
##' @param pip_level Defines a value for the posterior inclusion probability. Defaults to 0.75.
##' @param variable Name of a specific variable. Defaults to `NULL`
##' @param label_points Should points above the pip threshold be labelled? Defaults to `TRUE`.
##' @param ... Controls ggrepel aruments.
#' @return
#' Invisibly returns a \code{ggplot} object corresponding to the selected plot
#' type. The primary purpose of this method is the side effect of displaying the
#' plot.
#'
#' The exact plot depends on the value of \code{type}:
#' \itemize{
#'   \item \code{"pip"} — Posterior inclusion probability plot for random scale
#'         effects.
#'   \item \code{"funnel"} — Funnel plot showing the relation between within-cluster
#'         standard deviation (\code{tau}) and posterior inclusion probabilities.
#'   \item \code{"outcome"} — Outcome plot relating cluster means (\code{mu}),
#'         posterior inclusion probability, and within-cluster SD.
#' }
#'
#' When \code{label_points = TRUE}, labels for clusters exceeding the
#' \code{pip_level} threshold are added using \pkg{ggrepel} (if available).
##' @author Philippe Rast
##' @import ggplot2
##' @importFrom patchwork plot_layout
##' @importFrom stats aggregate median
##' @importFrom utils menu
##' @export
plot.ivd <- function(x, type = "pip", pip_level = .75, variable = NULL, label_points = TRUE, ...) {
    obj <- x
    ## Get scale variable names
    ranef_scale_names <- colnames(obj$Z_scale)
    fixef_scale_names <- colnames(obj$X_scale)

    col_names <- dimnames(.summary_table(obj$samples[[1]]$samples))[[2]]
    Kr <- obj$nimble_constants$Kr

    cols_to_keep <- c()
    ## Find spike and slab variables
    col_ss <- col_names[grepl("^ss\\[", col_names)]
    for (col_name in col_ss) {
        col_number <- as.numeric(unlist(regmatches(col_name, gregexpr("[0-9]+", col_name)))[1])
        if (col_number > Kr) {
            cols_to_keep <- c(cols_to_keep, col_name)
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
    for (i in 1:Sr) {
        index <- paste0("\\[", i + Kr)
        position_ss_value <- grepl(index, names(means_list[[1]]))
        ss_means[[i]] <- final_means[position_ss_value]
    }

    ## Get number of random scale effects:
    no_ranef_s <- obj$nimble_constants$Sr

    ## With multiple random effects, ask user which one to be plotted:
    if (no_ranef_s == 1) {
        ## Define ordered dataset
        df_pip <- data.frame(
            id = seq_len(length(ss_means[[1]])),
            pip = ss_means[[1]]
        )
        df_pip <- df_pip[order(df_pip$pip), ]
        df_pip$ordered <- 1:nrow(df_pip)
    } else if (no_ranef_s > 1) {
        if (is.null(variable)) {

            if (interactive()) {
                ## Allow menu selection ONLY in interactive sessions
                choice <- menu(
                    choices = ranef_scale_names,
                    title = "Multiple random scale effects detected. Choose one to plot:"
                )
                
                if (choice == 0) {
                    stop("No variable selected. Halting plot generation.", call. = FALSE)
                }
                
                variable <- ranef_scale_names[choice]
                
            } else {
                ## Non-interactive → fail with clear message (CRAN requirement)
                stop(
                    paste0(
                        "Multiple random scale effects detected. Please specify the 'variable' argument.\n",
                        "Available options: ", paste(ranef_scale_names, collapse = ", ")
                    ),
                    call. = FALSE
                )
            }
        }

        ## Find position of user requested random effect
        scale_ranef_position_user <- which(ranef_scale_names == variable)

        ## Define ordered dataset
        df_pip <- data.frame(
            id = seq_len(length(ss_means[[scale_ranef_position_user]])),
            pip = ss_means[[scale_ranef_position_user]]
        )
        df_pip <- df_pip[order(df_pip$pip), ]
        df_pip$ordered <- 1:nrow(df_pip)
    }

    ## find scale random effects
    ## Extract numbers and find locations
    column_indices <- sapply(col_names, function(x) {
        if (grepl("^u\\[", x)) { # Check if the name starts with 'u['
            ## Extracting numbers
            nums <- as.numeric(unlist(strsplit(gsub("[^0-9,]", "", x), ",")))
            ## Check if second number (column index) is greater than Kr
            return(nums[2] > Kr)
        } else {
            return(FALSE)
        }
    })

    ## Indices of columns where column index is greater than Kr
    scale_ranef_pos <- which(column_indices)

    ## Create tau locally
    if (no_ranef_s == 1) {
        ## Extract the posterior mean of the fixed effect:
        zeta <- mean(unlist(lapply(.extract_to_mcmc(obj), FUN = function(x) mean(x[, "zeta[1]"]))))
        ## Extract the posterior mean of each random effect:
        u <- colMeans(do.call(rbind, lapply(.extract_to_mcmc(obj), FUN = function(x) colMeans(x[, scale_ranef_pos]))))
        tau <- exp(zeta + u)
    } else if (no_ranef_s > 1) {

        ## Find position of user requested random effect
        scale_ranef_position_user <-
            which(ranef_scale_names == variable)

        ## Find position of user requested fixed effect
        ## TODO: When interactions are present plot will change according to moderator...
        ## Currently only main effect is selected
        scale_fixef_position_user <-
            which(fixef_scale_names == variable)

        ## Use ranef_position_user to select corresponding fixed effect
        zeta <- mean(unlist(lapply(.extract_to_mcmc(obj), FUN = function(x) mean(x[, paste0("zeta[", scale_fixef_position_user, "]")]))))

        ## Extract the posterior mean of each random effect:
        pos <- scale_ranef_pos[grepl(paste0(Kr + scale_ranef_position_user, "\\]"), names(scale_ranef_pos))]

        u <-
            colMeans(do.call(rbind, lapply(.extract_to_mcmc(obj), FUN = function(x) colMeans(x[, pos]))))
        tau <- exp(zeta + u)
    } else {
        stop("Invalid action specified. Exiting.", call. = FALSE)
    }

    ## Get mu's across chains
    mu_combined <- lapply(obj$samples, function(chain) {
        mu_indices <- grep("mu", colnames(chain$samples))
        mu_samples <- chain$samples[, mu_indices, drop = FALSE]
        return(mu_samples)
    })

    # Combine chains into one large matrix

    # Compute the posterior means
    # posterior_tau_means <- colMeans(do.call(rbind, tau_combined))
    posterior_mu_means <- colMeans(do.call(rbind, mu_combined))

    # tau <- tapply(posterior_tau_means, obj$Y$group_id, mean)
    mu <- tapply(posterior_mu_means, obj$Y$group_id, mean)

    ## Add tau and mu to data frame -- ensure correct order
    df_pip <-
        cbind(df_pip[order(df_pip$id), ], tau)
    df_pip <-
        cbind(df_pip[order(df_pip$id), ], mu)


    if (type == "pip") {
        ## 1. Create the base plot *without* the labels
        plt <- ggplot(df_pip, aes(x = ordered, y = pip)) +
            geom_point(
                data = subset(df_pip, pip < pip_level),
                alpha = .3, size = 5, shape = 21,
                fill = "grey40", color = "black"
            ) +
            geom_jitter(
                data = subset(df_pip, pip >= pip_level),
                fill = "#0265a5", size = 5, shape = 21,
                color = "white"
            ) +
            geom_abline(intercept = pip_level, slope = 0, lty = 3) +
            labs(
                x = "Ordered index",
                y = "Posterior Inclusion Probability",
                title = "Intercept"
            ) +
            theme(
                axis.title.x = element_text(hjust = 0.5),
                axis.title.y = element_text(hjust = 0.5)
            )

        ## 2. Conditionally add the label layer to the existing plot object
        if (label_points) {
            .require_suggest("ggrepel", "`geom_label_repel()`")
            plt <- plt + ggrepel::geom_label_repel(
                data = subset(df_pip, pip >= pip_level),
                aes(label = id),
                force = 100,
                box.padding = 0.35,
                point.padding = 0.5,
                segment.color = "grey50",
                direction = "x",
                ...
            )
        }

        return(plt)
    } else if (type == "funnel") {
        plt <- ggplot(df_pip, aes(x = tau, y = pip)) +
            geom_point(
                data = subset(df_pip, pip < pip_level),
                alpha = .3,
                size = 5,
                shape = 21,
                fill = "grey40",
                color = "white"
            ) +
            geom_jitter(
                data = subset(df_pip, pip >= pip_level),
                fill = "#0265a5",
                size = 5,
                shape = 21,
                position = "jitter",
                color = "white"
            ) +
            labs(x = "Within-Cluster SD") +
            geom_abline(intercept = pip_level, slope = 0, lty = 3) +
            ggtitle(variable) +
            guides(fill = "none")

        if (label_points) {
            .require_suggest("ggrepel", "`geom_text_repel()`")
            plt <- plt + ggrepel::geom_text_repel(
                data = subset(df_pip, pip >= pip_level),
                aes(label = id),
                point.padding = 0.5,
                ...
            )
        }

        return(plt)
    } else if (type == "outcome") {
        ## Declare global variable to avoid R CMD check NOTE

        plt <- ggplot(df_pip, aes(x = mu, y = pip, fill = tau)) +
            geom_point(
                data = subset(df_pip, pip < pip_level),
                alpha = .3, stroke = 1,
                shape = 21, color = "grey40", size = 5
            ) +
            geom_point(
                data = subset(df_pip, pip >= pip_level),
                shape = 21,
                size = 5
            ) +
            geom_abline(intercept = pip_level, slope = 0, lty = 3) +
            scale_fill_gradient2(
                midpoint = median(df_pip$tau, na.rm = TRUE), ,
                low = "#2166ACFF", high = "#B2182BFF",
                mid = "#F7F7F7FF",
                name = "Within-cluster SD"
            ) +
            scale_color_gradient2(
                midpoint = median(df_pip$tau, na.rm = TRUE), ,
                low = "#2166ACFF", high = "#B2182BFF",
                mid = "#F7F7F7FF", guide = "none"
            ) +
            labs(
                x = "Cluster mean",
                y = "Posterior Inclusion Probability",
                title = variable
            ) +
            guides(
                fill = guide_colorbar(
                    direction = "vertical",
                    title.position = "left",
                    barwidth = unit(0.8, "lines"),
                    barheight = unit(10, "lines")
                )
            ) +
            theme(
                axis.title.x = element_text(hjust = 0.5),
                axis.title.y = element_text(hjust = 0.5),
                legend.position = "right",
                legend.title = element_text(
                    angle = 90,
                    hjust = 0.5
                )
            )

        if (label_points) {
            .require_suggest("ggrepel", "`geom_text_repel()`")
            plt <- plt + ggrepel::geom_text_repel(
                data = subset(df_pip, pip >= pip_level),
                aes(label = id),
                point.padding = 0.5,
                ...
            )
        }

        return(plt)
    } else {
        stop("Invalid plot type. Please choose between 'pip', 'funnel' or 'outcome'.")
    }
    invisible(plt)
}


##' For more plots see coda
##' @title Traceplot from the coda package
##' @param obj ivd object
##' @param parameters Provide parameters of interest using names from the summary() output (e.g., "Intc", "scl_Intc", "sd_Intc", "R\\[scl_Intc, Intc\\]", "pip\\[Intc, 5\\]"). Defaults to NULL (plots all parameters).
##' @param type Coda plot. Defaults to 'traceplot'. See coda for more options such as 'acfplot', 'densplot' etc.
##' @param askNewPage Should user be prompted for next plot. Defaults to `TRUE`
##' @return Specified coda plot
##' @author Philippe Rast
##' @import coda
##' @importFrom grDevices devAskNewPage
##' @export
codaplot <- function(obj, parameters = NULL, type = 'traceplot', askNewPage = TRUE) {
  ## TODO: Inherit variable names from summary object

  ## Prepare reduced options of parameters to be plotted (i.e., only those
  ## in the summary table)

  ## Extract to mcmc object
  extract_samples <- .extract_to_mcmc(obj)
  Kr <- obj$nimble_constants$Kr
  ## Extract relevant names with summary_table function
  mat_transposed <- .summary_table(t(extract_samples[[1]]), Kr)

  ## Exclude mu and tau indexes
  mu_index <- grep('mu',  rownames(mat_transposed) )
  tau_index <- grep('tau',  rownames(mat_transposed))

  raw_internal_names <- rownames(mat_transposed[-c(mu_index, tau_index), ])
  internal_names <- raw_internal_names

  ## Location fixed effects
  beta_index <- grep('^beta\\[', internal_names)
  if(length(beta_index) > 0 && length(beta_index) == length(obj$X_location_names)) {
    internal_names[beta_index] <- obj$X_location_names
  }
  ## Scale fixed effects
  zeta_index <- grep('^zeta\\[', internal_names)
  if(length(zeta_index) > 0 && length(zeta_index) == length(colnames(obj$X_scale))) {
    internal_names[zeta_index] <- paste0("scl_", colnames(obj$X_scale))
  }
  ## Random effects SD (diagonal of sigma_rand)
  sigma_rand_index <- grep('^sigma_rand\\[(\\d+)]', internal_names) # Only diagonal
  sd_names <- c(obj$Z_location_names, paste0("scl_", colnames(obj$Z_scale)))
  if(length(sigma_rand_index) > 0 && length(sigma_rand_index) == length(sd_names)) {
    internal_names[sigma_rand_index] <- paste0("sd_", sd_names)
  }

  ## Rewrite correlation variable
  ## number of random effects:
  cols <- length(sigma_rand_index)
  ## Place holder variable: R is indexed as vech
  M <- matrix(1:cols^2, ncol = cols )
  ## record positions
  vech <- M[lower.tri(M)]
  ## match variable names to position
  corrvar <- expand.grid(sd_names, sd_names)[vech,]
  R_index <-  grep('R\\[', internal_names)
  if( nrow(corrvar) != length(R_index) )stop("Check R_index in summary.R" )
  internal_names[R_index] <- paste0("R[",paste(corrvar[, 1], corrvar[, 2], sep = ", "), "]")


  ## Link PIP to actual clustering units
  ## find the positions of the scale random effects in the model
  scale_ranef <- colnames(obj$Z_scale)
  scale_indexes <- seq_len(length(scale_ranef)) + length(colnames(obj$Z_scale))
  ## build patterns and replacements
  patterns <- paste0("\\[", scale_indexes, ",")
  replacements <- paste0("[", scale_ranef, ",")
  ## create a vector with the new rownames
  new_rownames <- Reduce(function(x, pattern_replacement) {
    gsub(pattern_replacement[1], pattern_replacement[2], x)
  },
  mapply(c, patterns, replacements, SIMPLIFY = FALSE),
  init = internal_names)
  ## assign back
  internal_names <- new_rownames

  pip_pos <- grep("ss", internal_names)
  internal_names[pip_pos] <- sub("^ss", "pip", internal_names[pip_pos])

  ## (Intercept) is annoying long. Change to Int.
  Int_index <- grep("\\(Intercept\\)", internal_names)
  internal_names[Int_index] <- gsub("\\(Intercept\\)",  "Intc", internal_names[Int_index])

  ## Filter each chain in the list for the relevant parameters
  extract_samples_filtered <- lapply(extract_samples, function(chain) {
    chain_names <- colnames(chain)
    matching_cols <- chain_names %in% raw_internal_names
    filtered_chain <- chain[, matching_cols, drop = FALSE]
    colnames(filtered_chain) <- internal_names
    return(filtered_chain)
  })

  ## Check if 'type' corresponds to a valid coda plotting function
  ## Typically, these would be 'plot', 'acfplot', etc.
  ## The user needs to ensure the correct function name is provided.

  ## Attempt to get the plotting function based on 'type'
  plot_func <- match.fun(type)
  
  if (is.null(parameters)) {

    ## If no parameters specified, apply the chosen function to all samples
    #params <- dimnames(.summary_table(obj$samples[[1]]$samples ))[[2]]
    params = internal_names
    
    ## Apply the chosen function to the specified parameters    
    for (param in params) {
      plot_func(mcmc.list(extract_samples_filtered)[, param, drop = FALSE])
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
    if (!all( params %in% colnames(extract_samples_filtered[[1]]))) {
      stop("Some specified parameters do not exist in the samples.")
    }

    ## Apply the chosen function to the specified parameters
    for (param in params) {
      plot_func(mcmc.list(extract_samples_filtered)[, param, drop = FALSE])
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
