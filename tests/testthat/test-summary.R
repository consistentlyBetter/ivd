library(testthat)
library(ivd) 
library(nimble)

## Create simple data example
test_that("summary.ivd() prints the expected header", {
  
  # For CRAN or continuous integration, skip
  # MCMC run is likely too time-consuming:
  skip_on_cran()
  
  # 1) Create a simple simulated dataset
  set.seed(123)
  group <- rep(1:5, each = 5)        # 5 groups, 25 obs total
  y <- rnorm(25, mean = 2, sd = 1.5) # Just some random data
  simdata <- data.frame(y = y, group = factor(group))
  
  # 2) Fit a small ivd model (reduce niter for speed)
  fit1 <- suppressWarnings(ivd(location_formula = ~1 + (1 | group),
              scale_formula    = ~1 + (1 | group),
              data    = simdata,
              niter   = 100,
              nburnin = 50,
              WAIC    = TRUE,
              workers = 1, n_eff = "stan")) ## use of stan avoids issues with the 'local' function
  expect_output(summary(fit1), "Summary statistics for ivd model:")
})
