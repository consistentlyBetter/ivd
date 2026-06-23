library(testthat)
library(ivd)

## These tests run against the committed fixture loaded in setup.R
## (ivd_fixture). They contain no MCMC, so they execute during coverage.

test_that("summary.ivd prints the expected header, chain count and WAIC", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_output(suppressWarnings(summary(ivd_fixture)), "Summary statistics for ivd model:")
  expect_output(suppressWarnings(summary(ivd_fixture)), "Chains \\(workers\\):")
  ## fixture is fit with WAIC = TRUE
  expect_output(suppressWarnings(summary(ivd_fixture)), "WAIC:")
})

test_that("summary.ivd returns a summary.ivd object and honours `pip`", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  capture.output(res_all   <- suppressWarnings(summary(ivd_fixture, pip = "all")))
  capture.output(res_model <- suppressWarnings(summary(ivd_fixture, pip = "model")))
  capture.output(res_pip   <- suppressWarnings(summary(ivd_fixture, pip = "pip")))

  expect_s3_class(res_all, "summary.ivd")
  ## "model" drops the pip rows, "pip" keeps only them
  expect_lt(nrow(res_model), nrow(res_all))
  expect_lt(nrow(res_pip), nrow(res_all))
  expect_equal(nrow(res_model) + nrow(res_pip), nrow(res_all))
})

test_that("summary.ivd rejects an invalid `pip` argument", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_error(
    suppressWarnings(summary(ivd_fixture, pip = "nonsense")),
    "needs one of"
  )
})
