#' posterior_summary
#'
#' Summarizes the posterior distribution contained in `ss_ranef` objects
#'
#' @param obj An object of type `ss_ranef`
#' @param ci The width of the credible interval that should be used. Defaults to 0.9.
#' @param as_df Whether a `data.frame` should instead be returned. Defaults to FALSE.
#' @param digits The number of digits to which the output should be rounded. Defaults to 2.
#' @importFrom stats quantile
#'
#' @export

posterior_summary <- function(obj, ci = 0.9, as_df = FALSE, digits = 2) {

  type <- obj$call[1]
  if (grepl("beta", type)) {
    cnames <- c("alpha", "beta", "sigma", "tau1", "tau2", "rho")
  } else if (grepl("alpha", type)) {
    cnames <- c("alpha", "sigma", "tau")
  } else if (grepl("mv", type)) {
    cnames <- c("B_1_1", "B_1_2", "B_2_1", "B_2_2",
                "rb_1_2", "rb_1_3", "rb_1_4", "rb_2_3", "rb_2_4", "rb_3_4",
                "rw",
                "sigma_1", "sigma_2",
                "Tau_1_1", "Tau_2_2", "Tau_3_3", "Tau_4_4")
  } else {
    stop("obj must be an ss_ranef object.")
  }

  post_samps <- obj$posterior_samples[, cnames]

  lwr <- (1 - ci)/2
  upr <- 1 - lwr
  post_lwr <- apply(post_samps, 2, function(x) quantile(x, lwr))
  post_means <- colMeans(post_samps)
  post_upr <- apply(post_samps, 2, function(x) quantile(x, upr))

  bounds_chr <- as.character(c(lwr, upr))
  # splits e.g., "0.05" and returns "05"
  bounds_digits <- sapply(bounds_chr, function(x) strsplit(x, split = "[.]")[[1]][2])
  bounds_labs <- paste0("q", bounds_digits)

  summ_df <- data.frame(post_means, post_lwr, post_upr)
  summ_df <- round(summ_df, digits)
  colnames(summ_df) <- c("Post_mean", bounds_labs)

  if (as_df) return(summ_df)

  attr(summ_df, "call") <- obj$call
  class(summ_df) <- c("posterior_summary", "data.frame")

  return(summ_df)
}

#' print.posterior_summary
#'
#' Print method for `posterior_summary()`
#'
#'
#' @param x An object of type `ss_ranef`
#' @param ... Currently not in use
#'
#'
#' @export
print.posterior_summary <- function(x, ...) {
  cat("Linear mixed model fit with SSranef\n")
  cat("Call: ")
  print(attr(x, "call"))
  cat("\n")
  print(as.data.frame(x), right = FALSE)
}


#' ranef_summary
#'
#' Summarizes the posterior distribution of the random effects contained in `ss_ranef` objects
#'
#' @param obj An object of type `ss_ranef`
#' @param ci The width of the credible interval that should be used. Defaults to 0.9.
#' @param as_df Whether a `data.frame` should instead be returned. Defaults to FALSE.
#' @param digits The number of digits to which the output should be rounded. Defaults to 2.
#'
#' @export
#'

ranef_summary <- function(obj, ci = 0.9, as_df = FALSE, digits = 2) {
  all_cnames <- colnames(obj$posterior_samples)
  post_samps <- obj$posterior_samples

  type <- obj$call[1]
  if (grepl("beta", type)) {
    theta_names <- c(grep("theta1", all_cnames, value = TRUE),
                    grep("theta2", all_cnames, value = TRUE))
  } else if (grepl("alpha", type)) {
    theta_names <- c(grep("theta", all_cnames, value = TRUE))
  } else if (grepl("mv", type)) {
    theta_names <- c(grep("theta", all_cnames, value = TRUE))
     # stop("Multivariate models not yet supported.")
  } else {
    stop("obj must be an ss_ranef object.")
  }

  if (grepl("mv", type)) {
    gamma1_names <- grep("gamma1", all_cnames, value = TRUE)
    gamma2_names <- grep("gamma2", all_cnames, value = TRUE)

    gamma1s <- post_samps[, gamma1_names]
    gamma2s <- post_samps[, gamma2_names]
  } else {
    gamma_names <- grep("gamma", all_cnames, value = TRUE)
    gammas <- post_samps[, gamma_names]
    }

  thetas <- post_samps[, theta_names]

  lwr <- (1 - ci)/2
  upr <- 1 - lwr

  post_lwr <- apply(thetas, 2, function(x) quantile(x, lwr))
  post_means <- colMeans(thetas)
  post_upr <- apply(thetas, 2, function(x) quantile(x, upr))
  if (grepl("beta", type)) {
    pips <- c(rep(NA, ncol(thetas)/2), colMeans(gammas))
    } else if (grepl("alpha", type)) {
      pips <- colMeans(gammas)
    } else if (grepl("mv", type)) {
      J <- obj$data_list$J

      pips <- c(rep(NA, J),
                colMeans(gamma1s),
                rep(NA, J),
                colMeans(gamma2s))
    }

  BF_10 <- pips / (1 - pips)
  BF_01 <- 1/BF_10


  bounds_chr <- as.character(c(lwr, upr))
  # splits e.g., "0.05" and returns "05"
  bounds_digits <- sapply(bounds_chr, function(x) strsplit(x, split = "[.]")[[1]][2])
  bounds_labs <- paste0("q", bounds_digits)

  summ_df <- data.frame(post_means, post_lwr, post_upr, pips, BF_10, BF_01)
  summ_df <- round(summ_df, digits)
  colnames(summ_df) <- c("Post_mean", bounds_labs, "PIP", "BF_10", "BF_01")

  if (as_df) return(summ_df)

  attr(summ_df, "call") <- obj$call
  class(summ_df) <- c("ranef_summary", "data.frame")

  return(summ_df)

}

#' print.ranef_summary
#'
#' Print method for `ranef_summary()`
#'
#' @param x ...
#' @param ... Currently not in use
#'
#'
#' @export
print.ranef_summary <- function(x, ...) {
  cat("Linear mixed model fit with SSranef\n")
  cat("Call: ")
  print(attr(x, "call"))
  cat("\n")
  print(as.data.frame(x), right = FALSE, ...)
}
