##' Print a concise overview of a fitted ivd model
##'
##' Shows the model formulas, data dimensions, sampling setup and a one-line
##' convergence note. Use [summary.ivd()] for the full posterior table and
##' [pip()] for a tidy data frame of the posterior inclusion probabilities.
##' @title Print method for ivd objects
##' @param x An object of class `ivd`.
##' @param ... Not used.
##' @return `x`, invisibly.
##' @author Philippe Rast
##' @export
print.ivd <- function(x, ...) {
  .fmt_formula <- function(f) paste(deparse(f), collapse = " ")

  cat("Individual variance detection (ivd) model\n\n")
  ## Formulas are stored on objects fitted with ivd >= 1.0.0.9000; older
  ## objects simply omit these lines.
  if (!is.null(x$location_formula)) {
    cat(" Location:", .fmt_formula(x$location_formula), "\n")
  }
  if (!is.null(x$scale_formula)) {
    cat(" Scale:   ", .fmt_formula(x$scale_formula), "\n")
  }

  N <- nrow(x$Y)
  J <- x$nimble_constants$J
  chains <- length(x$samples)
  draws <- nrow(x$samples[[1]]$samples)
  cat(sprintf(" Data:     %d observations in %d clusters\n", N, J))
  cat(sprintf(" Sampling: %d chains, %d post-warmup draws each\n", chains, draws))

  ## One-line convergence note over all monitored parameters (NA entries are
  ## placeholders for unmonitored positions and constant indicators).
  max_rhat <- suppressWarnings(max(x$rhat_values, na.rm = TRUE))
  min_neff <- suppressWarnings(min(x$n_eff, na.rm = TRUE))
  if (is.finite(max_rhat) && is.finite(min_neff)) {
    cat(sprintf(" Diagnostics: max split-Rhat = %.3f, min n_eff = %d\n",
                max_rhat, as.integer(round(min_neff))))
  }

  invisible(x)
}
