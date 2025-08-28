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

test_that("prepare_data_for_nimble errors when random-effects term is missing", {
  data <- data.frame(
    Y = rnorm(5),
    X = runif(5),
    group = 1:5
  )
  loc_no_re <- Y ~ X
  scale_re <-  ~ X + (1 | group)
  expect_error(
    prepare_data_for_nimble(data, loc_no_re, scale_re),
    "Random effects missing"
  )

  loc_re <- Y ~ X + (1 | group)
  scale_no_re <-  ~ X
  expect_error(
    prepare_data_for_nimble(data, loc_re, scale_no_re),
    "Random effects missing"
  )
})

test_that("prepare_data_for_nimble errors with different grouping variables", {
  data <- data.frame(
    Y = rnorm(5),
    X = runif(5),
    group = 1:5,
    grp2 = 1:5
  )
  location_formula <- Y ~ X + (1 | group)
  scale_formula <-  ~ X + (1 | grp2)

  expect_error(
    prepare_data_for_nimble(data, location_formula, scale_formula),
    "Location and scale grouping variable needs to be the same."
  )
})

test_that("prepare_data_for_nimble requires continuous sorted group index", {
  data <- data.frame(
    Y = rnorm(5),
    X = runif(5),
    group = c(1, 2, 1, 3, 5)
  )
  location_formula <- Y ~ X + (1 | group)
  scale_formula <-  ~ X + (1 | group)

  expect_error(
    prepare_data_for_nimble(data, location_formula, scale_formula),
    "Grouping variable is not a sorted and continuous index."
  )
})


### Sample Tests for `._extract_to_mcmc`

test_that("._extract_to_mcmc extracts MCMC samples correctly", {
  mock_samples <- list(samples = list(matrix(rnorm(200), ncol = 2)))
  obj <- list(samples = list(mock_samples))
  
  result <- .extract_to_mcmc(obj)
  expect_type(result, "list")
  expect_s3_class(result[[1]], "mcmc")
})
