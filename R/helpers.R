##' Define data from formula
##' @param data Data object in long format
##' @param location_formula Formula for location
##' @param scale_formula Formula for scale
##' @keywords internal
prepare_data_for_nimble <- function(data, location_formula, scale_formula) {
  
  ## Collapse a possibly multi-line deparse() into one string. deparse() wraps
  ## long formulas across lines; the parsing below assumed a single line, which
  ## silently dropped predictors / the grouping term on models with many terms.
  .flatten_formula <- function(f) paste(deparse(f), collapse = " ")

  ## Helper function to prepare model parts
  prepare_model_part <- function(data, formula, is_scale_model = FALSE) {
    ## Parse the formula to get response and predictors
    response_var <- if(is_scale_model) NA else all.vars(formula)[1]
    
    fixed_effects <- strsplit(.flatten_formula(formula), split = "\\+ \\(", perl = TRUE)[[1]][1]
    ## slplit out random effects, first split contains grouping variable
    random_effects_F <- strsplit(.flatten_formula(formula), split = "\\+ \\(", perl = TRUE)[[1]][2]
    ## split at | 
    random_effects <- strsplit(random_effects_F, split = "\\|", perl = TRUE)[[1]][1]

    predictors <- all.vars(formula)[-length(all.vars(formula) )]
    if (!is_scale_model) {
      predictors <- predictors[-1]  # Exclude the response variable for location model
    }    
    
    ## Creating X matrix
    X_formula <- update.formula(formula,   fixed_effects )
      #update.formula(formula, paste("~", paste(predictors, collapse = "*")))
    X_matrix <-  model.matrix(X_formula, data)
    
    ## For Z, random effects predictors
    Z_matrix <- if( !is.na(random_effects) ) {
                  model.matrix( formula( paste("~", random_effects) ), data)
                } else {
                  stop("Random effects missing")
                }
    list(X = X_matrix, Z = Z_matrix) # Adjusting for intercept
  }
  
  ## Extracting the grouping variable from the location formula
  location_formula_string <- .flatten_formula(location_formula)
  grouping_variable_match <- regmatches(location_formula_string, regexec("\\|\\s*(\\w+)", location_formula_string))
  if (length(grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the location formula.")
  }
  grouping_variable <- grouping_variable_match[[1]][2]
  ## Extracting the grouping variable from the scale formula
  ## Only support models where grouping variable is the same for location and scale
  scale_formula_string <- .flatten_formula(scale_formula)
  scl_grouping_variable_match <- regmatches(scale_formula_string, regexec("\\|\\s*(\\w+)", scale_formula_string))
  if (length(scl_grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the scale formula.")
  }
  ## Check that both location and scale have same grouping variable
  if(grouping_variable != scl_grouping_variable_match[[1]][2]) {
    stop("Location and scale grouping variable needs to be the same.")
  }
    
  ## Drop rows with missing values in any model variable so that the response,
  ## design matrices and grouping index stay aligned. Otherwise model.matrix()
  ## silently drops NA rows from X/Z while Y and group_id keep their full length.
  model_vars <- intersect(unique(c(all.vars(location_formula),
                                   all.vars(scale_formula))), names(data))
  keep <- stats::complete.cases(data[, model_vars, drop = FALSE])
  if (!all(keep)) {
    message("ivd: dropping ", sum(!keep),
            " row(s) with missing values in model variables.")
    data <- data[keep, , drop = FALSE]
  }

  ## Ensure the grouping variable is numeric
  if(!is.numeric(data[[grouping_variable]])) {
    data[[grouping_variable]] <- as.numeric(as.factor(data[[grouping_variable]]))
  }
  ## Ensure that grouping variable is a continuous sequence without any missing values
  if( !identical(  seq_len( max(unique(data[[grouping_variable]])) ),
                 as.integer( sort(unique(data[[grouping_variable]])))) ) {
    stop("Grouping variable is not a sorted and continuous index.")
  }
  
  ## Processing location and scale models
  location_data <- prepare_model_part(data, formula = location_formula)
  scale_formula_cleaned <- gsub("sigma = ", "", .flatten_formula(scale_formula))  # Remove "sigma = " if present
  scale_data <- if(!is.null(scale_formula_cleaned) && nzchar(scale_formula_cleaned)) {
                  prepare_model_part(data, formula = as.formula(paste(scale_formula_cleaned)), TRUE)
  } else {
    list(X = NULL, Z = NULL)
  }

  ## Check if repsonse_var has attributes, due to scaling with scale()
  ## Remove attributes, if present
  if( is.null(attributes( data[[all.vars(location_formula)[1]]] ) ) ) {
    Y <- data[[all.vars(location_formula)[1]]] # Assuming the first variable is the response
  } else if ( !is.null(attributes( data[[all.vars(location_formula)[1]]] ) )) {
    Y <- c(data[[all.vars(location_formula)[1]]]) # Assuming the first variable is the response
  }
  
  
  # Assemble the data structure for NIMBLE
  list(data = list(
         Y = Y,  
         X = location_data$X, 
         Z = location_data$Z, 
         X_scale = scale_data$X, 
         Z_scale = scale_data$Z
       ), 
       groups = length(unique(data[[grouping_variable]])), 
       group_id = data[[grouping_variable]],
       response_var = all.vars(location_formula)[1]
  )
}
##' Render a single-line, carriage-return progress string for parallel chains
##'
##' Builds the live status line shown by `ivd(progress = TRUE)`: a spinner, the
##' number of chains being fit, and elapsed time. Deliberately has no completion
##' bar -- chains run in parallel and finish together, so a fraction bar would
##' sit at 0 then jump to full. Leads with "\\r" so repeated prints overwrite
##' the same terminal line.
##' @param total Integer number of chains (workers) being fit.
##' @param t0 Start time (`Sys.time()`), used to compute elapsed time.
##' @param spinner Optional single-character spinner frame.
##' @return A length-1 character string.
##' @keywords internal
.progress_line <- function(total, t0, spinner = "") {
  el <- as.integer(as.numeric(difftime(Sys.time(), t0, units = "secs")))
  elapsed <- sprintf("%02d:%02d", el %/% 60L, el %% 60L)
  sprintf("\r%s ivd: fitting %d %s | %s elapsed ",
          spinner, total, if (total == 1) "chain" else "chains", elapsed)
}

##' Extract samples to mcmc object
##' @param obj
##' @return mcmc object
##' @author Philippe Rast
##' @keywords internal
.extract_to_mcmc <- function(obj) {
  e_to_mcmc <- lapply(obj$samples, FUN = function(x) mcmc(x$samples))
  return(e_to_mcmc)
}

##' Reconstruct the posterior mean of the location predictor `mu`
##'
##' `mu` is no longer monitored (it stores O(N x iterations) values per chain).
##' Because `mu[i] = X[i, ] %*% beta + Z[i, ] %*% u[group_i, 1:Kr]` is *linear*
##' in the monitored `beta` and `u`, the posterior mean of `mu` equals the
##' linear predictor evaluated at the posterior means of `beta` and `u` -- no
##' per-iteration `mu` storage required. Used by `plot.ivd()` for the cluster
##' outcome plot.
##' @param obj An `ivd` object (must carry the location design matrices `X`/`Z`).
##' @return Numeric vector of length N: the posterior mean of `mu` per observation.
##' @keywords internal
.reconstruct_mu_means <- function(obj) {
  if (is.null(obj$X) || is.null(obj$Z)) {
    stop("Cannot reconstruct cluster means: location design matrices (X, Z) ",
         "are missing from the ivd object. Refit with the current version of ivd().",
         call. = FALSE)
  }
  Kr <- obj$nimble_constants$Kr
  J  <- obj$nimble_constants$J

  ## Pool draws across chains; only beta and u columns are needed.
  all_draws <- do.call(rbind, .extract_to_mcmc(obj))
  cn <- colnames(all_draws)

  ## Fixed location effects beta[1..K], ordered by their numeric index so they
  ## line up with the columns of X.
  beta_means <- colMeans(all_draws[, grep("^beta\\[", cn), drop = FALSE])
  beta_means <- beta_means[order(as.integer(gsub("\\D", "", names(beta_means))))]

  ## Random location effects u[j, p], p <= Kr, as a J x Kr matrix of means.
  u_means <- colMeans(all_draws[, grep("^u\\[", cn), drop = FALSE])
  idx <- regmatches(names(u_means), gregexpr("[0-9]+", names(u_means)))
  jj <- as.integer(vapply(idx, `[`, character(1), 1)) # group index
  pp <- as.integer(vapply(idx, `[`, character(1), 2)) # random-effect index
  u_loc <- matrix(0, nrow = J, ncol = Kr)
  loc <- pp <= Kr
  u_loc[cbind(jj[loc], pp[loc])] <- u_means[loc]

  group_id <- obj$Y$group_id
  as.numeric(obj$X %*% beta_means) +
    rowSums(obj$Z * u_loc[group_id, , drop = FALSE])
}


##' Fast Fourier transform algorithm to compute the ACF across the whole chain lengt.
##' As noted by Vehtari et al. (2021), Section 3.2
##' @title Use fast Fourier transform to compute ACF
##' @param chain 
##' @return acf
##' @author Philippe Rast
##' @keywords internal
##' @importFrom stats fft
.autocorrelation_fft <- function(chain) {
  ## Ensure the input is a numeric vector
  ts <- as.numeric(chain)
  
  ## Center the time series (subtract the mean)
  ts_centered <- ts - mean(ts)
  
  ## Length of the chain
  n <- length(ts_centered)
  
  ## Zero-padding the series to avoid circular convolution
  padded_length <- 2 * n
  
  ## Compute the FFT of the centered series with zero-padding
  fft_ts <- fft(ts_centered, padded_length)
  
  ## Compute the inverse FFT of the product of FFT and its conjugate
  acf_raw <- Re(fft(fft_ts * Conj(fft_ts), inverse = TRUE))
  
  ## Extract the relevant part and normalize
  acf_raw <- acf_raw[1:n] / padded_length
  
  ## Normalize the result to match the acf() function output
  acf <- acf_raw / acf_raw[1]
  
  return(acf)
}
