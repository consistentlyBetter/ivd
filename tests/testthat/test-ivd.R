## Testing run_MCMC_allcode

library(testthat)
library(ivd)
library(nimble)

# Mock inputs
mock_code <- nimbleCode({
  for(i in 1:N) {
    Y[i] ~ dnorm(mu[i], tau[i])
    mu[i] <- beta[i]
    tau[i] <- 1
    beta[i] ~ dnorm(0, 1)
  }
  zeta ~ dnorm(0,1)
  R ~ dnorm(0,1)
  ss ~ dnorm(0,1)
  sigma_rand ~ dnorm(0,1)
  u ~ dnorm(0,1)
})

mock_data <- list(Y = rnorm(10))  # Y should have N=10 if N is used like this
mock_constants <- list(N = 10)  # Make sure N is correctly defined
mock_inits <- list(beta = rnorm(10))  # mu should have the same length as Y if indexed

# Test that uses the NEW functions: run_MCMC_allcode was replaced by run_MCMC_compiled_model
test_that("Build and run MCMC processes valid inputs correctly", {
  # Step 1: Build and compile the model
  compiled_model <- build_ivd_model(
      code = mock_code,
      constants = mock_constants,
      dummy_data = mock_data,
      dummy_inits = mock_inits,
      useWAIC = TRUE
  )

  # Step 2: Run the compiled MCMC
  result <- run_MCMC_compiled_model(
      compiled = compiled_model,
      seed = 123,
      new_data = mock_data,
      new_inits = mock_inits,
      niter = 10,
      nburnin = 5,
      useWAIC = TRUE # Match the useWAIC in build step if needed
  )

  # Check the result structure (it will be a list if WAIC=T, matrix if WAIC=F)
  if (TRUE) { # Replace TRUE with the actual value of useWAIC used above
      expect_type(result, "list")
      expect_true("samples" %in% names(result))
      expect_true("WAIC" %in% names(result))
      expect_true(is.matrix(result$samples))
  } else {
      expect_true(is.matrix(result))
  }
})

# Test with WAIC = FALSE
test_that("Build and run MCMC with WAIC=FALSE", {
  # Build/compile (useWAIC in build doesn't affect the run structure, but keep consistent)
  compiled_model_no_waic <- build_ivd_model(
      code = mock_code,
      constants = mock_constants,
      dummy_data = mock_data,
      dummy_inits = mock_inits,
      useWAIC = FALSE
  )

  # Run MCMC
  result_no_waic <- run_MCMC_compiled_model(
      compiled = compiled_model_no_waic,
      seed = 456,
      new_data = mock_data,
      new_inits = mock_inits,
      niter = 10,
      nburnin = 5,
      useWAIC = FALSE
  )

  # Check expected structure (matrix only)
  expect_true(is.matrix(result_no_waic))
})


test_that("run_MCMC_compiled_model errors when given an invalid compiled object", {
    ## `run_MCMC_allcode` no longer exists (renamed to run_MCMC_compiled_model);
    ## the old test passed only because the function was not found. This calls
    ## the real function with an empty `compiled` so it fails on setData().
    expect_error(run_MCMC_compiled_model(
        compiled = list(), seed = 123,
        new_data = mock_data, new_inits = mock_inits,
        niter = 10, nburnin = 5, useWAIC = TRUE
    ))
})

## Testing ivd
test_that("ivd sets up and runs with correct defaults and inputs", {
    ## Cannot run under covr: covr's trace injection rewrites the nimbleCode
    ## model's if() branches, and NIMBLE rejects them (checkReservedVarNames).
    ## `# nocov` does not help -- it only filters the tally, not the injection.
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    ## n_eff = "local" (the default) on short chains is a regression test for
    ## the Geyer-truncation crash (min() over an empty set -> Inf -> `1:Inf`);
    ## .geyer_truncate() now falls back to the last available lag instead.
    testoutput <- suppressWarnings({
        ivd(
            location_formula = Y ~ 1 + (1 | grouping),
            scale_formula = ~ 1 + (1 | grouping),
            data = data.frame(Y = rnorm(100), grouping = rep(1:10, each = 10)),
            niter = 100, nburnin = 50, WAIC = TRUE, workers = 2, n_eff = "local"
        )
    })
    expect_s3_class(testoutput, "ivd")
    expect_equal(length(testoutput$samples), 2) # Assuming workers = 2
    expect_equal(testoutput$workers, 2)
    expect_true(any(is.finite(testoutput$n_eff)))
})

test_that("ivd monitors neither mu nor tau, and omits logLik, by default (memory)", {
    ## A+B+D: the per-observation O(N x iterations) nodes mu and tau are not
    ## monitored and logLik_array is opt-in, so none of that storage is kept.
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    out <- suppressWarnings(ivd(
        location_formula = Y ~ 1 + (1 | grouping),
        scale_formula = ~ 1 + (1 | grouping),
        data = data.frame(Y = rnorm(100), grouping = rep(1:10, each = 10)),
        niter = 100, nburnin = 50, WAIC = TRUE, workers = 2, n_eff = "stan"
    ))
    cn <- colnames(out$samples[[1]]$samples)
    expect_false(any(grepl("^tau\\[", cn)))   # tau no longer stored
    expect_false(any(grepl("^mu\\[", cn)))    # mu no longer stored (reconstructed)
    expect_null(out$logLik_array)             # opt-in, off by default

    ## Location design matrices are retained for mu reconstruction.
    expect_false(is.null(out$X))
    expect_false(is.null(out$Z))

    ## Diagnostics are full-length and aligned with the stored columns.
    expect_equal(length(out$rhat_values), length(cn))
    expect_equal(length(out$n_eff), length(cn))

    ## summary() and the outcome plot must work without monitored mu/tau.
    expect_no_error(suppressWarnings(summary(out)))
    expect_s3_class(suppressWarnings(plot(out, type = "outcome", label_points = FALSE)), "ggplot")
})

test_that("ivd returns logLik and monitors tau when return_logLik = TRUE", {
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    out <- suppressWarnings(ivd(
        location_formula = Y ~ 1 + (1 | grouping),
        scale_formula = ~ 1 + (1 | grouping),
        data = data.frame(Y = rnorm(100), grouping = rep(1:10, each = 10)),
        niter = 100, nburnin = 50, WAIC = TRUE, workers = 2, n_eff = "stan",
        return_logLik = TRUE
    ))
    cn <- colnames(out$samples[[1]]$samples)
    expect_true(any(grepl("^tau\\[", cn)))
    expect_false(is.null(out$logLik_array))
    expect_equal(dim(out$logLik_array)[3], 100) # N observations
})

test_that("ivd thins stored iterations", {
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    out <- suppressWarnings(ivd(
        location_formula = Y ~ 1 + (1 | grouping),
        scale_formula = ~ 1 + (1 | grouping),
        data = data.frame(Y = rnorm(100), grouping = rep(1:10, each = 10)),
        niter = 100, nburnin = 50, WAIC = TRUE, workers = 2, n_eff = "stan",
        thin = 5
    ))
    ## 100 post-burnin iterations / thin 5 = 20 stored draws
    expect_equal(nrow(out$samples[[1]]$samples), 20)
})

test_that("ivd(seed = ...) is reproducible without an external set.seed()", {
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    ## Same data, no set.seed() around the calls: the internal `seed` must make
    ## the inits and per-chain MCMC seeds reproducible on its own.
    d <- data.frame(Y = rnorm(80), grouping = rep(1:8, each = 10))
    fit <- function() suppressWarnings(ivd(
        location_formula = Y ~ 1 + (1 | grouping),
        scale_formula = ~ 1 + (1 | grouping),
        data = d, niter = 60, nburnin = 30, workers = 2,
        n_eff = "stan", seed = 99, progress = FALSE
    ))
    a <- fit()
    b <- fit()
    sa <- do.call(rbind, lapply(a$samples, function(ch) ch$samples))
    sb <- do.call(rbind, lapply(b$samples, function(ch) ch$samples))
    expect_identical(sa, sb)
})

test_that("ivd(progress = TRUE) shows a progress line and quiets NIMBLE chatter", {
    skip_if(Sys.getenv("R_COVR") == "true", "covr instrumentation breaks nimbleCode model building")

    out <- NULL
    stdout_lines <- capture.output(
        out <- suppressWarnings(ivd(
            location_formula = Y ~ 1 + (1 | grouping),
            scale_formula = ~ 1 + (1 | grouping),
            data = data.frame(Y = rnorm(80), grouping = rep(1:8, each = 10)),
            niter = 60, nburnin = 30, WAIC = TRUE, workers = 2,
            n_eff = "stan", progress = TRUE
        )),
        type = "output"
    )
    expect_s3_class(out, "ivd")

    joined <- paste(stdout_lines, collapse = "\n")
    expect_true(grepl("chains", joined))               # live progress line rendered
    ## NIMBLE's buffered per-worker output is suppressed under progress = TRUE
    expect_false(grepl("Defining model", joined))
    expect_false(grepl("Compiling", joined))
})

test_that("ivd handles missing formulas", {
    expect_error(ivd(
        data = data.frame(Y = rnorm(100), X = 1:100),
        niter = 100, nburnin = 50, workers = 2
    ))
})

test_that("ivd manages zero workers", {
    expect_error(ivd(
        location_formula = ~1, scale_formula = ~1,
        data = data.frame(Y = rnorm(100), X = 1:100),
        niter = 100, nburnin = 50, WAIC = TRUE, workers = 0
    ))
})
