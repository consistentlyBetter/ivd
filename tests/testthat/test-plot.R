library(testthat)
library(ivd)

## All tests use the committed fixture (ivd_fixture, loaded in setup.R), which
## is fit with multiple random scale effects (Sr > 1). plot.ivd() therefore
## requires an explicit `variable` in the non-interactive test session.

test_that("plot.ivd builds a pip plot", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  p <- plot(ivd_fixture, type = "pip", variable = "(Intercept)", label_points = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("plot.ivd builds a funnel plot", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  p <- plot(ivd_fixture, type = "funnel", variable = "(Intercept)", label_points = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("plot.ivd builds an outcome plot", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  p <- plot(ivd_fixture, type = "outcome", variable = "x", label_points = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("plot.ivd labels points when ggrepel is available", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  skip_if_not_installed("ggrepel")
  p <- plot(ivd_fixture, type = "pip", variable = "(Intercept)", label_points = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot.ivd requires `variable` when there are several random scale effects", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  expect_error(plot(ivd_fixture, type = "pip"), "specify the 'variable'")
})

test_that("plot.ivd rejects an unknown plot type", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  expect_error(
    plot(ivd_fixture, type = "nope", variable = "(Intercept)"),
    "Invalid plot type"
  )
})

## --- codaplot ---------------------------------------------------------------
## codaplot draws to the active graphics device, so route output to a temp pdf.

test_that("codaplot draws a traceplot for a named parameter", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  tmp <- tempfile(fileext = ".pdf"); pdf(tmp); on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  expect_error(codaplot(ivd_fixture, parameters = "Intc"), NA)
})

test_that("codaplot supports other coda plot types", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  tmp <- tempfile(fileext = ".pdf"); pdf(tmp); on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  expect_error(codaplot(ivd_fixture, type = "densplot", parameters = "Intc"), NA)
})

test_that("codaplot handles multiple parameters with askNewPage = FALSE", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  tmp <- tempfile(fileext = ".pdf"); pdf(tmp); on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  expect_error(
    codaplot(ivd_fixture, parameters = c("Intc", "x"), askNewPage = FALSE),
    NA
  )
})

test_that("codaplot errors for a parameter that does not exist", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  tmp <- tempfile(fileext = ".pdf"); pdf(tmp); on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  expect_error(
    codaplot(ivd_fixture, parameters = "does_not_exist"),
    "do not exist"
  )
})
