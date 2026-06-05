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

test_that("prepare_data_for_nimble handles formulas that deparse to multiple lines", {
  ## Many fixed effects make deparse() wrap onto several lines. The parser must
  ## still locate the grouping variable and retain every predictor.
  set.seed(1)
  d <- as.data.frame(matrix(rnorm(40 * 26), 40, 26))
  names(d) <- letters
  d$Y <- rnorm(40)
  d$group <- rep(1:4, each = 10)
  f <- as.formula(paste("Y ~", paste(letters, collapse = " + "), "+ (1 | group)"))

  result <- prepare_data_for_nimble(d, f, ~ 1 + (1 | group))
  expect_equal(ncol(result$data$X), 27) # intercept + 26 predictors
  expect_equal(result$groups, 4)
})

test_that("prepare_data_for_nimble keeps Y, X and Z aligned when predictors have NAs", {
  ## model.matrix() drops NA rows; Y / group_id must be dropped consistently so
  ## NIMBLE never receives mismatched lengths.
  data <- data.frame(
    Y = rnorm(20),
    X1 = c(NA, rnorm(19)),
    group = rep(1:4, each = 5)
  )
  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))

  n <- length(result$data$Y)
  expect_equal(n, 19) # the single incomplete row is dropped
  expect_equal(nrow(result$data$X), n)
  expect_equal(nrow(result$data$Z), n)
  expect_equal(nrow(result$data$X_scale), n)
  expect_equal(nrow(result$data$Z_scale), n)
  expect_equal(length(result$group_id), n)
})


### Sample Tests for `._extract_to_mcmc`

test_that("._extract_to_mcmc extracts MCMC samples correctly", {
  mock_samples <- list(samples = list(matrix(rnorm(200), ncol = 2)))
  obj <- list(samples = list(mock_samples))

  result <- .extract_to_mcmc(obj)
  expect_type(result, "list")
  expect_s3_class(result[[1]], "mcmc")
})


test_that(".reconstruct_mu_means equals the linear predictor from beta and u", {
  ## mu is linear in beta and u, so the posterior-mean reconstruction must equal
  ## X %*% mean(beta) + rowSums(Z * mean(u_group)). Use constant draws so the
  ## posterior means equal the set values, and check against a hand computation.
  N <- 6; J <- 2; Kr <- 2
  group_id <- c(1, 1, 1, 2, 2, 2)
  X <- cbind(`(Intercept)` = 1, x = c(0.5, -0.5, 1, 0, 2, -1)) # K = 2
  Z <- X                                                        # Kr = 2
  beta <- c(1, 0.3)                                             # beta[1], beta[2]
  u <- matrix(c(0.2, -0.1,    # group 1: u[1,1], u[1,2]
                -0.4, 0.5),   # group 2: u[2,1], u[2,2]
              nrow = 2, byrow = TRUE)

  ## One chain, 3 identical iterations; note scale ranef columns (p > Kr) and an
  ## out-of-order group to exercise index parsing rather than column position.
  draw <- c(`beta[1]` = beta[1], `beta[2]` = beta[2],
            `u[2, 1]` = u[2, 1], `u[1, 1]` = u[1, 1],
            `u[1, 2]` = u[1, 2], `u[2, 2]` = u[2, 2],
            `u[1, 3]` = 99, `u[2, 3]` = -99) # scale ranef -> must be ignored
  mat <- matrix(rep(draw, each = 3), nrow = 3,
                dimnames = list(NULL, names(draw)))
  obj <- list(
    samples = list(list(samples = mat)),
    X = X, Z = Z,
    Y = data.frame(group_id = group_id),
    nimble_constants = list(Kr = Kr, J = J)
  )

  got <- .reconstruct_mu_means(obj)
  expected <- as.numeric(X %*% beta) + rowSums(Z * u[group_id, ])
  expect_equal(unname(got), expected)
})

test_that(".progress_line renders a single overwriting status line", {
  t0 <- Sys.time()
  line <- .progress_line(2, 4, t0, spinner = "@")
  expect_true(startsWith(line, "\r@ ivd "))           # CR + spinner: overwrites line
  expect_match(line, "2/4 chains")
  expect_match(line, "elapsed")
  expect_match(.progress_line(4, 4, t0), "\\[={24}\\]") # full bar at completion
  expect_match(.progress_line(0, 4, t0), "\\[ {24}\\]") # empty bar at start
})

test_that(".reconstruct_mu_means errors when design matrices are absent", {
  obj <- list(samples = list(list(samples = matrix(0, 1, 1))),
              nimble_constants = list(Kr = 1, J = 1))
  expect_error(.reconstruct_mu_means(obj), "design matrices")
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
