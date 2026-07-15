##' Re-weight a posterior inclusion probability to a new prior
##'
##' Converts a PIP estimated under prior inclusion probability `p0` into the
##' PIP implied by a different prior `p1`, without refitting: the Bayes factor
##' `BF = [pip/(1-pip)] / [p0/(1-p0)]` does not depend on the prior, so the
##' re-weighted PIP is `BF*q / (1 + BF*q)` with `q = p1/(1-p1)`. PIPs of
##' exactly 0 or 1 are returned unchanged (they are invariant under any
##' `p1` in (0, 1)); see [pip_sensitivity()] for the finite-sample clamp.
##' @title Analytic PIP re-weighting
##' @param pip Numeric vector of PIPs estimated under `p0`.
##' @param p0 Prior inclusion probability used in the fit.
##' @param p1 New prior inclusion probability (scalar).
##' @return Numeric vector of re-weighted PIPs.
##' @keywords internal
.pip_reweight <- function(pip, p0, p1) {
  stopifnot(p0 > 0, p0 < 1, p1 > 0, p1 < 1,
            all(pip >= 0), all(pip <= 1))
  bf <- (pip / (1 - pip)) / (p0 / (1 - p0))
  q <- p1 / (1 - p1)
  out <- bf * q / (1 + bf * q)
  ## pip = 1 gives bf = Inf and Inf/Inf = NaN above; it stays 1 analytically.
  out[pip == 1] <- 1
  out
}

##' Prior-sensitivity of the posterior inclusion probabilities
##'
##' Shows how each cluster's PIP would change under different prior inclusion
##' probabilities `ss_prior_p`, computed analytically from the fitted model --
##' no refitting. The posterior odds are converted to a prior-independent
##' Bayes factor and re-weighted to each value of `prior_p`
##' (see [.pip_reweight()]).
##'
##' PIPs estimated as exactly 0 or 1 are a finite-sample artifact (with `S`
##' post-warmup draws a PIP of 1 is only known to be at least `(S-0.5)/S`), so
##' they are clamped to `0.5/S` and `(S-0.5)/S` before re-weighting; the
##' `at_boundary` column flags those rows. All other PIPs are used as
##' estimated.
##' @title Analytic prior-sensitivity for PIPs
##' @param fit A fitted `ivd` object.
##' @param prior_p Numeric vector of prior inclusion probabilities to
##'   evaluate, all in (0, 1). Defaults to `seq(0.05, 0.95, by = 0.05)`.
##' @return A data frame of class `pip_sensitivity` with one row per cluster
##'   x scale random effect x `prior_p` value: `scale_var`, `cluster_index`,
##'   `cluster_id`, `prior_p`, `pip`, and `at_boundary`. The prior used in the
##'   fit is stored in `attr(, "p0")`. Plot with [plot.pip_sensitivity()].
##' @author Philippe Rast
##' @examples
##' \dontrun{
##' out <- ivd(y ~ 1 + (1 | school), ~ 1 + (1 | school), data, niter = 2000)
##' sens <- pip_sensitivity(out)
##' plot(sens)
##' }
##' @export
pip_sensitivity <- function(fit, prior_p = seq(0.05, 0.95, by = 0.05)) {
  if (!inherits(fit, "ivd")) stop("'fit' must be an ivd object.")
  if (length(prior_p) < 1 || any(prior_p <= 0) || any(prior_p >= 1)) {
    stop("'prior_p' values must lie strictly between 0 and 1.")
  }

  ## Prior used in the fit: stored since ivd 1.0.0.9000; recoverable from the
  ## NIMBLE constants (bval rows Kr+1..Kr+Sr) for older objects.
  p0 <- fit$ss_prior_p
  if (is.null(p0)) {
    p0 <- fit$nimble_constants$bval[fit$nimble_constants$Kr + 1, 1]
  }

  est <- pip(fit)

  ## Finite-sample clamp for degenerate PIPs (see roxygen details).
  S <- length(fit$samples) * nrow(fit$samples[[1]]$samples)
  at_boundary <- est$pip == 0 | est$pip == 1
  pip0 <- pmin(pmax(est$pip, 0.5 / S), (S - 0.5) / S)

  out <- do.call(rbind, lapply(sort(prior_p), function(p1) {
    data.frame(
      scale_var = est$scale_var,
      cluster_index = est$cluster_index,
      cluster_id = est$cluster_id,
      prior_p = p1,
      pip = .pip_reweight(pip0, p0 = p0, p1 = p1),
      at_boundary = at_boundary,
      row.names = NULL
    )
  }))

  attr(out, "p0") <- p0
  attr(out, "n_draws") <- S
  class(out) <- c("pip_sensitivity", "data.frame")
  out
}

##' Plot PIP trajectories across prior inclusion probabilities
##'
##' One line per cluster (faceted by scale random effect when there is more
##' than one). Clusters whose classification at `pip_level` changes across
##' the evaluated priors are drawn in color and labelled; robust clusters are
##' grey. The dashed vertical line marks the prior used in the fit.
##' @title Plot method for pip_sensitivity objects
##' @param x A `pip_sensitivity` object from [pip_sensitivity()].
##' @param pip_level PIP threshold used to judge whether a cluster's
##'   classification is prior-sensitive. Defaults to 0.75.
##' @param ... Not used.
##' @return A `ggplot` object.
##' @author Philippe Rast
##' @export
plot.pip_sensitivity <- function(x, pip_level = 0.75, ...) {
  df <- as.data.frame(x)
  df$group <- interaction(df$scale_var, df$cluster_index, drop = TRUE)

  ## A cluster is prior-sensitive when it is above the threshold for some
  ## priors and below it for others.
  crosses <- tapply(df$pip >= pip_level, df$group, function(z) any(z) && !all(z))
  df$sensitive <- crosses[as.character(df$group)]

  p0 <- attr(x, "p0")

  plt <- ggplot(df, aes(x = prior_p, y = pip, group = group)) +
    geom_line(data = df[!df$sensitive, ], color = "grey70", linewidth = 0.3) +
    geom_line(data = df[df$sensitive, ],
              aes(color = factor(cluster_id)), linewidth = 0.5,
              show.legend = FALSE) +
    geom_hline(yintercept = pip_level, linetype = "dotted") +
    geom_vline(xintercept = p0, linetype = "dashed", color = "grey40") +
    labs(x = "Prior inclusion probability",
         y = "Posterior inclusion probability (PIP)") +
    ylim(0, 1) +
    theme_minimal()

  ## Label the sensitive clusters at the right edge of their trajectory.
  sens_right <- df[df$sensitive & df$prior_p == max(df$prior_p), ]
  if (nrow(sens_right) > 0) {
    .require_suggest("ggrepel", "`geom_text_repel()`")
    plt <- plt + ggrepel::geom_text_repel(
      data = sens_right,
      aes(label = cluster_id, color = factor(cluster_id)),
      size = 3, show.legend = FALSE
    )
  }

  if (length(unique(df$scale_var)) > 1) {
    plt <- plt + facet_wrap(~scale_var)
  }
  plt
}
