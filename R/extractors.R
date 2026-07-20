##' Pool the post-warmup draws of all chains into one matrix.
##' @param object ivd object
##' @return Matrix of pooled draws (iterations x parameters).
##' @keywords internal
.pooled_draws <- function(object) {
  do.call(rbind, lapply(object$samples, function(chain) chain$samples))
}

##' Posterior means of a set of indexed columns (e.g. `beta[1]`, `beta[2]`),
##' ordered by their numeric index.
##' @param draws pooled draws matrix
##' @param stem parameter name, e.g. "beta"
##' @return Named numeric vector of posterior means in index order.
##' @keywords internal
.indexed_means <- function(draws, stem) {
  cols <- grep(paste0("^", stem, "\\["), colnames(draws), value = TRUE)
  means <- colMeans(draws[, cols, drop = FALSE])
  means[order(as.integer(gsub("\\D", "", names(means))))]
}

##' Parse cluster labels back to numeric when (and only when) they came from
##' a numeric grouping variable: a label is numeric-born iff converting and
##' re-formatting reproduces it exactly, so IDs like "007" or "A12" stay
##' character.
##' @param labels character vector of cluster labels
##' @return Numeric vector when all labels round-trip, otherwise `labels`.
##' @keywords internal
.maybe_numeric <- function(labels) {
  num <- suppressWarnings(as.numeric(labels))
  if (!anyNA(num) && all(as.character(num) == labels)) num else labels
}

##' Extract posterior inclusion probabilities
##'
##' Returns the package's headline output -- the posterior inclusion
##' probability (PIP) of every cluster's scale random effect(s) -- as a tidy
##' data frame, one row per cluster and scale random effect.
##' @title Extract PIPs from a fitted ivd model
##' @param object An object of class `ivd`.
##' @param ... Not used.
##' @return A `data.frame` with one row per cluster x scale random effect:
##' \itemize{
##'   \item \code{scale_var}: Name of the scale random effect.
##'   \item \code{cluster_index}: Internal cluster index \code{1..J} (matches
##'         the default labels in [summary.ivd()] and [plot.ivd()]).
##'   \item \code{cluster_id}: The user's original grouping ID, parsed back to
##'         numeric when the original IDs were numeric (equals
##'         \code{cluster_index} for objects fitted before labels were stored).
##'   \item \code{pip}: Posterior inclusion probability of the cluster's
##'         scale random effect.
##'   \item \code{u_mean}, \code{u_sd}: Posterior mean and SD of the scale
##'         random effect \code{u}.
##' }
##' @author Philippe Rast
##' @export
pip <- function(object, ...) UseMethod("pip")

##' @rdname pip
##' @importFrom stats sd
##' @export
pip.ivd <- function(object, ...) {
  Kr <- object$nimble_constants$Kr
  Sr <- object$nimble_constants$Sr
  J <- object$nimble_constants$J
  scale_vars <- colnames(object$Z_scale)
  labels <- if (!is.null(object$group_labels)) {
    object$group_labels
  } else {
    as.character(seq_len(J))
  }
  labels <- .maybe_numeric(labels)

  draws <- .pooled_draws(object)
  cn <- colnames(draws)

  do.call(rbind, lapply(seq_len(Sr), function(s) {
    ## Scale random effects occupy rows (Kr+1):(Kr+Sr); NIMBLE names the
    ## indicators ss[p, j] and the random effects u[j, p].
    p <- Kr + s
    ss_cols <- paste0("ss[", p, ", ", seq_len(J), "]")
    u_cols <- paste0("u[", seq_len(J), ", ", p, "]")
    if (!all(c(ss_cols, u_cols) %in% cn)) {
      stop("Could not find the ss/u columns for scale random effect ",
           scale_vars[s], " in the stored samples.")
    }
    data.frame(
      scale_var = scale_vars[s],
      cluster_index = seq_len(J),
      cluster_id = labels,
      pip = unname(colMeans(draws[, ss_cols, drop = FALSE])),
      u_mean = unname(colMeans(draws[, u_cols, drop = FALSE])),
      u_sd = unname(apply(draws[, u_cols, drop = FALSE], 2, sd)),
      row.names = NULL
    )
  }))
}

##' Extract fixed effects
##'
##' Posterior means of the fixed effects, named after the model variables.
##' Location effects keep their variable names; scale effects are prefixed
##' with `scl_`, matching [summary.ivd()].
##'
##' The generic is defined here so that `ivd` does not depend on `nlme`/`lme4`;
##' if either package is attached, its same-named generic dispatches to this
##' method just the same.
##' @title Extract fixed effects from a fitted ivd model
##' @param object An object of class `ivd`.
##' @param ... Not used.
##' @return Named numeric vector of posterior means.
##' @author Philippe Rast
##' @export
fixef <- function(object, ...) UseMethod("fixef")

##' @rdname fixef
##' @export
fixef.ivd <- function(object, ...) {
  draws <- .pooled_draws(object)
  beta <- .indexed_means(draws, "beta")
  zeta <- .indexed_means(draws, "zeta")
  names(beta) <- object$X_location_names
  names(zeta) <- paste0("scl_", colnames(object$X_scale))
  c(beta, zeta)
}

##' Extract random effects
##'
##' Posterior means of the random effects `u`, one row per cluster and one
##' column per random effect. Location random effects come first, then the
##' scale random effects (prefixed with `scl_`). Note that the scale columns
##' report the unconditional `u`; multiply by the inclusion indicators (see
##' [pip()]) to reproduce the model-implied, spike-and-slab-selected effect.
##'
##' The generic is defined here so that `ivd` does not depend on `nlme`/`lme4`;
##' if either package is attached, its same-named generic dispatches to this
##' method just the same.
##' @title Extract random effects from a fitted ivd model
##' @param object An object of class `ivd`.
##' @param labels Row names: `"index"` (default) uses the internal 1..J
##'   cluster index; `"original"` uses the user's original grouping IDs.
##' @param ... Not used.
##' @return Numeric matrix (J x (Kr + Sr)) of posterior means.
##' @author Philippe Rast
##' @export
ranef <- function(object, ...) UseMethod("ranef")

##' @rdname ranef
##' @export
ranef.ivd <- function(object, labels = c("index", "original"), ...) {
  labels <- match.arg(labels)
  Kr <- object$nimble_constants$Kr
  Sr <- object$nimble_constants$Sr
  J <- object$nimble_constants$J

  draws <- .pooled_draws(object)
  u <- vapply(seq_len(Kr + Sr), function(p) {
    unname(colMeans(draws[, paste0("u[", seq_len(J), ", ", p, "]"),
                          drop = FALSE]))
  }, numeric(J))
  colnames(u) <- c(object$Z_location_names,
                   paste0("scl_", colnames(object$Z_scale)))
  rownames(u) <- if (identical(labels, "original") &&
                     !is.null(object$group_labels)) {
    object$group_labels
  } else {
    seq_len(J)
  }
  u
}

##' Extract coefficients
##'
##' Convenience alias for [fixef()]: posterior means of the fixed location
##' and scale effects.
##' @title Extract coefficients from a fitted ivd model
##' @param object An object of class `ivd`.
##' @param ... Not used.
##' @return Named numeric vector of posterior means.
##' @author Philippe Rast
##' @export
coef.ivd <- function(object, ...) {
  fixef.ivd(object, ...)
}
