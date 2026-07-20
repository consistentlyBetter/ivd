library(testthat)
library(ivd)

## These tests run against the committed fixture loaded in setup.R
## (ivd_fixture). They contain no MCMC, so they execute during coverage.

test_that("summary.ivd prints the expected header, chain count and WAIC", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  ## summary() assembles silently; print.summary.ivd() renders.
  expect_output(print(suppressWarnings(summary(ivd_fixture))), "Summary statistics for ivd model:")
  expect_output(print(suppressWarnings(summary(ivd_fixture))), "Chains \\(workers\\):")
  ## fixture is fit with WAIC = TRUE
  expect_output(print(suppressWarnings(summary(ivd_fixture))), "WAIC:")
})

test_that("summary.ivd returns a structured summary.ivd object and honours `pip`", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  res_all   <- suppressWarnings(summary(ivd_fixture, pip = "all"))
  res_model <- suppressWarnings(summary(ivd_fixture, pip = "model"))
  res_pip   <- suppressWarnings(summary(ivd_fixture, pip = "pip"))

  expect_s3_class(res_all, "summary.ivd")
  expect_true(is.matrix(res_all$table))
  expect_equal(res_all$chains, ivd_fixture$workers)
  expect_true(res_all$has_waic)
  expect_true(is.finite(res_all$waic))

  ## "model" drops the pip rows, "pip" keeps only them
  expect_lt(nrow(res_model$table), nrow(res_all$table))
  expect_lt(nrow(res_pip$table), nrow(res_all$table))
  expect_equal(nrow(res_model$table) + nrow(res_pip$table), nrow(res_all$table))
})

test_that("summary.ivd rejects an invalid `pip` argument", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_error(
    suppressWarnings(summary(ivd_fixture, pip = "nonsense")),
    "needs one of"
  )
})
