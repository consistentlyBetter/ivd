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

## test_that("run_MCMC_allcode processes valid inputs correctly", {
##   result <- run_MCMC_allcode(seed = 123,
##                              data = mock_data,
##                              constants = mock_constants,
##                              code = mock_code,
##                              niter = 10, nburnin = 5,
##                              useWAIC = TRUE, inits = mock_inits)
##   expect_type(result, "list")
## })

## test_that("run_MCMC_allcode handles incorrect data types", {
##   expect_error(run_MCMC_allcode(seed = 123, data = "wrong_type",
##                                 constants = mock_constants,
##                                 code = mock_code, niter = 10,
##                                 nburnin = 5, useWAIC = TRUE, inits = mock_inits))
## })

# Test that uses the NEW functions: run_MCMC_allcode was replaced by run_MCMC_compiled_model
test_that("Build and run MCMC processes valid inputs correctly", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping build/run test during coverage")

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
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping WAIC=FALSE test during coverage")

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

## Testing ivd
test_that("ivd sets up and runs with correct defaults and inputs", {
  ## Skip the test if the R_COVR environment variable is set to true
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  
  ## testoutput <- ivd(location_formula = Y ~ 1 + (1|grouping),
  ##               scale_formula = ~ 1 + (1|grouping),
  ##               data = data.frame(Y = rnorm(100), grouping = rep(1:10, each = 10)),
  ##               niter = 100, nburnin = 50, WAIC = TRUE, workers = 2)
  expect_s3_class(testoutput, "ivd")
  expect_equal(length(testoutput$samples), 2) # Assuming workers = 2
  expect_equal(testoutput$workers, 2)
})


test_that("ivd handles missing formulas", {
  expect_error(ivd(data = data.frame(Y = rnorm(100), X = 1:100),
                   niter = 100, nburnin = 50, workers = 2))
})

test_that("ivd manages zero workers", {
  expect_error(ivd(location_formula = ~1, scale_formula = ~1,
                   data = data.frame(Y = rnorm(100), X = 1:100),
                    niter = 100, nburnin = 50, WAIC = TRUE, workers = 0))
})
