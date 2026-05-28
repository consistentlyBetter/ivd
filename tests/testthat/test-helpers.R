## Testing prepare_data_for_nimble

library(testthat)
library(ivd) 
library(nimble)

test_that("prepare_data_for_nimble processes correct inputs", {
  data <- data.frame(
    Y = rnorm(100), 
    X1 = runif(100), 
    X2 = rnorm(100), 
    group = sample(1:10, 100, replace = TRUE)
  )
  location_formula <- Y ~ X1 + (1 | group)
  scale_formula <- Y ~ X2 + (1 | group)

  result <- prepare_data_for_nimble(data, location_formula, scale_formula)
  expect_type(result, "list")
  expect_true("X" %in% names(result$data))
  expect_true("Z" %in% names(result$data))
  expect_equal(result$groups, length(unique(data$group)))
  expect_true(all(result$group_id == data$group))
})

test_that("prepare_data_for_nimble handles incorrect formulas -- missing grouping var", {
  data <- data.frame(
    Y = rnorm(100), 
    X1 = runif(100), 
    group = sample(1:10, 100, replace = TRUE)
  )
  location_formula <- Y ~ X1 + (1 | group)
  scale_formula <-  ~ X1 + (1 )

  expect_error(prepare_data_for_nimble(data, location_formula, scale_formula),
               "Grouping variable not found in the scale formula.")
})

test_that("prepare_data_for_nimble handles non-numeric grouping variable", {
  data <- data.frame(
    Y = rnorm(100), 
    X1 = runif(100), 
    group = as.character(sample(1:10, 100, replace = TRUE))
  )
  location_formula <- Y ~ X1 + (1 | group)
  scale_formula <-  ~ X1 + (1 | group)

  result <- prepare_data_for_nimble(data, location_formula, scale_formula)
  expect_true(is.numeric(result$group_id))
})


test_that("prepare_data_for_nimble errors when grouping variables differ", {
  data <- data.frame(
    Y = rnorm(40), X1 = rnorm(40),
    group = rep(1:4, each = 10),
    other = rep(1:4, each = 10)
  )
  expect_error(
    prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | other)),
    "Location and scale grouping variable needs to be the same."
  )
})

test_that("prepare_data_for_nimble errors on a non-continuous grouping index", {
  ## Numeric grouping with a gap (1, 3) is left untouched and must be rejected.
  data <- data.frame(
    Y = rnorm(20), X1 = rnorm(20),
    group = rep(c(1, 3), each = 10)
  )
  expect_error(
    prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group)),
    "not a sorted and continuous index"
  )
})

test_that("prepare_data_for_nimble strips attributes from a scaled response", {
  data <- data.frame(X1 = rnorm(50), group = rep(1:5, each = 10))
  data$Y <- scale(rnorm(50)) # adds 'scaled:center'/'scaled:scale' attributes

  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))
  expect_null(attributes(result$data$Y))
  expect_length(result$data$Y, 50)
})

test_that("prepare_data_for_nimble keeps multiple fixed location predictors", {
  data <- data.frame(
    Y = rnorm(60), X1 = rnorm(60), X2 = rnorm(60),
    group = rep(1:6, each = 10)
  )
  result <- prepare_data_for_nimble(data, Y ~ X1 + X2 + (1 | group), ~ 1 + (1 | group))
  ## Intercept + X1 + X2
  expect_equal(ncol(result$data$X), 3)
})


### Sample Tests for `._extract_to_mcmc`

test_that("._extract_to_mcmc extracts MCMC samples correctly", {
  mock_samples <- list(samples = list(matrix(rnorm(200), ncol = 2)))
  obj <- list(samples = list(mock_samples))

  result <- .extract_to_mcmc(obj)
  expect_type(result, "list")
  expect_s3_class(result[[1]], "mcmc")
})


test_that(".autocorrelation_fft returns a normalised autocorrelation sequence", {
  set.seed(1)
  x <- as.numeric(stats::arima.sim(list(ar = 0.6), n = 200))

  fft_acf <- .autocorrelation_fft(x)

  expect_length(fft_acf, length(x))
  expect_equal(fft_acf[1], 1)                  # lag 0 is always 1
  expect_true(all(abs(fft_acf) <= 1 + 1e-8))   # normalised, so bounded by 1

  ## Tracks stats::acf only approximately: the implementation transforms the
  ## series without the zero-padding its comments intend (fft()'s 2nd argument
  ## is `inverse`, not a length), so it computes a circular autocorrelation.
  ref <- as.numeric(stats::acf(x, lag.max = 3, plot = FALSE)$acf)
  expect_equal(fft_acf[1:4], ref, tolerance = 0.05)
})
