# Regenerate the committed test fixture: tests/testthat/fixtures/ivd_fit.rds
#
# This script is NOT run by the test suite (testthat only sources test-*.R in
# tests/testthat/). It exists so the fixture can be reproduced deterministically.
#
# The fixture is a small but structurally rich fitted `ivd` object: it has more
# than an intercept in both the location and scale sub-models, AND a random
# slope in each, so that Kr > 1 and Sr > 1. That exercises the parts of
# summary.ivd() / plot.ivd() / codaplot() that only fire with multiple random
# effects (correlation renaming, multiple sigma_rand, the multi-random-scale
# plotting branch and its variable-selection error path).
#
# Run from the package root with a library that matches your current R version:
#   Rscript tests/testthat/fixtures/make-ivd-fixture.R
# then commit the resulting tests/testthat/fixtures/ivd_fit.rds.

library(ivd)

set.seed(2025)

n_per  <- 8L
n_grp  <- 12L
group  <- rep(seq_len(n_grp), each = n_per)
N      <- length(group)
x      <- rnorm(N)

## Random intercept + slope per group, plus a small fixed slope.
ranef_intercept <- rep(rnorm(n_grp, 0, 0.5), each = n_per)
y <- 0.3 * x + ranef_intercept + rnorm(N)

dat <- data.frame(y = y, x = x, group = group)

## Small number of iterations: the fixture only needs to be *structurally*
## valid, not converged. Warnings about R-hat are expected and suppressed.
fit <- suppressWarnings(
  ivd(
    location_formula = y ~ 1 + x + (1 + x | group),
    scale_formula    =     ~ 1 + x + (1 + x | group),
    data    = dat,
    niter   = 400,
    nburnin = 200,
    WAIC    = TRUE,
    workers = 2,
    ## "stan" (rstan::monitor) avoids a crash in the "local" n_eff path on
    ## short chains, where an autocorrelation that never crosses zero makes
    ## min() return Inf and `1:position` overflow. See ivd.R n_eff block.
    n_eff   = "stan"
  )
)

out_path <- file.path("tests", "testthat", "fixtures", "ivd_fit.rds")
if (!dir.exists(dirname(out_path))) {
  stop("Run this script from the package root: ", normalizePath("."), call. = FALSE)
}
saveRDS(fit, out_path, compress = "xz")

message("Wrote ", out_path, " (", round(file.size(out_path) / 1024), " KB)")
