## pip()/fixef()/ranef()/coef() run against the committed fixture
## (no MCMC, covr-safe). Fixture dims: J = 12, Kr = 2, Sr = 2.

test_that("pip returns one row per cluster x scale random effect", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  J <- ivd_fixture$nimble_constants$J
  Sr <- ivd_fixture$nimble_constants$Sr
  res <- pip(ivd_fixture)

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), J * Sr)
  expect_named(res, c("scale_var", "cluster_index", "cluster_id",
                      "pip", "u_mean", "u_sd"))
  expect_setequal(unique(res$scale_var), colnames(ivd_fixture$Z_scale))
  expect_true(all(res$pip >= 0 & res$pip <= 1))
  expect_true(all(res$u_sd > 0))
  ## the fixture's IDs are 1..J, so cluster_id parses back to the numeric
  ## index; same fallback applies to legacy objects without group_labels
  expect_equal(res$cluster_id, res$cluster_index)
})

test_that("pip parses cluster_id back to numeric only when lossless", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  fit <- ivd_fixture
  J <- fit$nimble_constants$J

  ## numeric-born labels (e.g. gapped school codes) come back numeric
  fit$group_labels <- as.character(seq_len(J) * 1000 + 23)
  expect_type(pip(fit)$cluster_id, "double")
  expect_equal(unique(pip(fit)$cluster_id), seq_len(J) * 1000 + 23)

  ## zero-padded IDs would not round-trip -> stay character
  fit$group_labels <- sprintf("%03d", seq_len(J))
  expect_type(pip(fit)$cluster_id, "character")

  ## true character IDs stay character
  fit$group_labels <- paste0("school_", seq_len(J))
  expect_type(pip(fit)$cluster_id, "character")
})

test_that("pip uses original grouping IDs when available", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  fit <- ivd_fixture
  J <- fit$nimble_constants$J
  fit$group_labels <- sprintf("school_%03d", seq_len(J))

  res <- pip(fit)
  expect_equal(res$cluster_id, fit$group_labels[res$cluster_index])
})

test_that("pip matches the PIP rows of the summary table", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  res <- pip(ivd_fixture)
  tab <- suppressWarnings(summary(ivd_fixture, pip = "pip", digits = 8))$table

  ## summary rows are named pip[<scale_var>, <j>]; align and compare values
  j <- as.integer(sub(".*,\\s*(\\d+)\\]$", "\\1", rownames(tab)))
  svar <- sub("^pip\\[(.*),\\s*\\d+\\]$", "\\1", rownames(tab))
  svar <- sub("^Intc$", "(Intercept)", svar)
  key_tab <- paste(svar, j)
  key_res <- paste(res$scale_var, res$cluster_index)
  expect_setequal(key_tab, key_res)
  expect_equal(res$pip[match(key_tab, key_res)], unname(tab[, "Mean"]),
               tolerance = 1e-6)
})

test_that("fixef returns named posterior means for location and scale", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  fe <- fixef(ivd_fixture)
  expect_named(fe, c(ivd_fixture$X_location_names,
                     paste0("scl_", colnames(ivd_fixture$X_scale))))

  ## spot-check beta[1] against the pooled draws
  pooled <- do.call(rbind, lapply(ivd_fixture$samples, function(ch) ch$samples))
  expect_equal(unname(fe[1]), mean(pooled[, "beta[1]"]))
})

test_that("coef is an alias for fixef", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_identical(coef(ivd_fixture), fixef(ivd_fixture))
})

test_that("ranef returns a J x (Kr + Sr) matrix consistent with pip()", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  J <- ivd_fixture$nimble_constants$J
  Kr <- ivd_fixture$nimble_constants$Kr
  Sr <- ivd_fixture$nimble_constants$Sr

  re <- ranef(ivd_fixture)
  expect_true(is.matrix(re))
  expect_equal(dim(re), c(J, Kr + Sr))
  expect_equal(colnames(re), c(ivd_fixture$Z_location_names,
                               paste0("scl_", colnames(ivd_fixture$Z_scale))))

  ## the scale columns must agree with pip()'s u_mean
  res <- pip(ivd_fixture)
  for (s in seq_len(Sr)) {
    svar <- colnames(ivd_fixture$Z_scale)[s]
    expect_equal(unname(re[, Kr + s]),
                 res$u_mean[res$scale_var == svar])
  }
})

test_that("ranef labels rows with original IDs on request", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  fit <- ivd_fixture
  J <- fit$nimble_constants$J
  fit$group_labels <- sprintf("school_%03d", seq_len(J))

  expect_equal(rownames(ranef(fit)), as.character(seq_len(J)))
  expect_equal(rownames(ranef(fit, labels = "original")), fit$group_labels)
})
