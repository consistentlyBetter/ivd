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

test_that("plot.ivd pip plot reflects the chosen variable in title and data", {
  ## Regression: the pip plot title was hard-coded to "Intercept", so with
  ## several random scale effects every choice of `variable` *looked* like
  ## the intercept plot (the underlying data were correct).
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  ref <- pip(ivd_fixture)

  for (v in colnames(ivd_fixture$Z_scale)) {
    p <- plot(ivd_fixture, type = "pip", variable = v, label_points = FALSE)
    expect_identical(p$labels$title, v)
    expect_equal(p$data$pip[order(p$data$id)],
                 ref$pip[ref$scale_var == v])
  }
})

test_that("plot.ivd rejects a variable that is not a random scale effect", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  expect_error(
    plot(ivd_fixture, type = "pip", variable = "not_a_variable"),
    "must be one of the random scale effects"
  )
})

test_that("plot.ivd handles a random scale effect with no matching fixed effect", {
  ## e.g. scale_formula = ~ 1 + (1 + x | id): valid model, fixed part of x
  ## is 0. Used to fail with "subscript out of bounds" on zeta[integer(0)].
  ## Mimic it by dropping x from the fixed scale design.
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  fit <- ivd_fixture
  fit$X_scale <- fit$X_scale[, "(Intercept)", drop = FALSE]

  ## pip plot never displays tau -> no error, no warning
  expect_silent(p <- plot(fit, type = "pip", variable = "x", label_points = FALSE))
  expect_s3_class(p, "ggplot")

  ## funnel/outcome display tau -> drawn with zeta = 0 plus a warning
  expect_warning(
    pf <- plot(fit, type = "funnel", variable = "x", label_points = FALSE),
    "no fixed effect 'x'"
  )
  expect_s3_class(pf, "ggplot")
  ref <- suppressWarnings(plot(ivd_fixture, type = "funnel", variable = "x",
                               label_points = FALSE))
  ## tau = exp(0 + u) here vs exp(zeta + u) on the intact fixture
  zeta_x <- fixef(ivd_fixture)[["scl_x"]]
  expect_equal(pf$data$tau, ref$data$tau / exp(zeta_x), tolerance = 1e-8)
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

test_that("codaplot resolves coda plot functions without coda attached", {
  ## Regression: match.fun() searches the caller's environment, so
  ## codaplot(type = "traceplot") failed from any script without
  ## library(coda). Tests inherit the ivd namespace (which imports coda),
  ## masking the bug — so call from an environment rooted at baseenv().
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")
  tmp <- tempfile(fileext = ".pdf"); pdf(tmp); on.exit({ dev.off(); unlink(tmp) }, add = TRUE)
  e <- new.env(parent = baseenv())
  e$fit <- ivd_fixture
  expect_error(
    eval(quote(ivd::codaplot(fit, parameters = "Intc")), envir = e),
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
