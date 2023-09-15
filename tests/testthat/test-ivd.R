## Define global variables
result_alpha <- result_beta <- result_mv <- NULL

## Generate some example data
set.seed(123)
y <- rnorm(100)
unit <- rep(1:10, each = 10)
result_alpha <- ss_ranef_alpha(y, unit)

set.seed(456)
y <- rnorm(100)
X <- rnorm(100)
unit <- rep(1:10, each = 10)
result_beta <- ss_ranef_beta(y, X, unit)

set.seed(789)
Y <- matrix(rnorm(200), ncol = 2)
X <- rnorm(100)
unit <- rep(1:10, each = 10)
result_mv <- ss_ranef_mv(Y, X, unit)


## Test for ss_ranef_alpha
test_that("ss_ranef_alpha correctly fits the model", {
  ## Check if the result is of class 'ss_ranef'
  expect_s3_class(result_alpha, "ss_ranef")
  return(result_alpha)
})

## Test for ss_ranef_beta
test_that("ss_ranef_beta correctly fits the model", {
  ## Check if the result is of class 'ss_ranef'
  expect_s3_class(result_beta, "ss_ranef")
})

## Test for ss_ranef_mv
test_that("ss_ranef_mv correctly fits the model", {
  expect_s3_class(result_mv, "ss_ranef")
})


## Plots: Caterpillar
test_that("Caterpillar alpha plots", {
  p <- caterpillar_plot( result_alpha )
  expect_s3_class(p, "ggplot")
})

test_that("Caterpillar beta plots", {
  p <- caterpillar_plot( result_beta)
  expect_s3_class(p, "ggplot")
})

test_that("Caterpillar mv plots", {
  p <- caterpillar_plot( result_mv )
  expect_s3_class(p, "ggplot")
})

## Plots: PIP
test_that("PIP alpha plots", {
  p <- pip_plot( result_alpha )
  expect_s3_class(p, "ggplot")
})

test_that("PIP beta plots", {
  p <- pip_plot( result_beta)
  expect_s3_class(p, "ggplot")
})

test_that("PIP mv plots", {
  p <- pip_plot( result_mv )
  expect_s3_class(p, "ggplot")
})

## Plots: Funnel
test_that("Funnel mv plot", {
  p <- funnel_plot( result_mv )
  expect_s3_class(p, "ggplot")
})


## Testing posterior_summary"

test_that("posterior_summary correctly summarizes the alpha posterior distribution", {
  summary <- posterior_summary(result_alpha)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})

test_that("posterior_summary correctly summarizes the beta posterior distribution", {
  summary <- posterior_summary(result_beta)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})

test_that("posterior_summary correctly summarizes the mv posterior distribution", {
  summary <- posterior_summary(result_mv)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})

## Testing ranef_summary

test_that("ranef_summary correctly summarizes the alpha random effects posterior distribution", {
  # Call ranef_summary function
  summary <- ranef_summary(result_alpha)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})

test_that("ranef_summary correctly summarizes the beta random effects posterior distribution", {
  # Call ranef_summary function
  summary <- ranef_summary(result_beta)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})

test_that("ranef_summary correctly summarizes the mv random effects posterior distribution", {
  # Call ranef_summary function
  summary <- ranef_summary(result_mv)
  # Check if the summary is a data frame
  expect_s3_class(summary, "data.frame")
})
