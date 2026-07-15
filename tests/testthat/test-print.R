## print.ivd() runs against the committed fixture (no MCMC, covr-safe).

test_that("print.ivd shows data, sampling and convergence overview", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  J <- ivd_fixture$nimble_constants$J
  N <- nrow(ivd_fixture$Y)
  chains <- length(ivd_fixture$samples)

  expect_output(print(ivd_fixture), "Individual variance detection")
  expect_output(print(ivd_fixture),
                sprintf("%d observations in %d clusters", N, J))
  expect_output(print(ivd_fixture), sprintf("%d chains", chains))
  expect_output(print(ivd_fixture), "max split-Rhat")
})

test_that("print.ivd shows formulas when stored and skips them on legacy objects", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  ## legacy object (fixture predates stored formulas): no formula lines
  fit <- ivd_fixture
  fit$location_formula <- NULL
  fit$scale_formula <- NULL
  out_legacy <- capture.output(print(fit))
  expect_false(any(grepl("Location:", out_legacy)))

  ## with formulas stored, both lines appear
  fit$location_formula <- y ~ x + (1 + x | school)
  fit$scale_formula <- ~ x + (1 + x | school)
  out <- capture.output(print(fit))
  expect_true(any(grepl("Location: y ~ x \\+ \\(1 \\+ x \\| school\\)", out)))
  expect_true(any(grepl("Scale:", out)))
})

test_that("print.ivd returns its input invisibly", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  capture.output(vis <- withVisible(print(ivd_fixture)))
  expect_false(vis$visible)
  expect_identical(vis$value, ivd_fixture)
})
