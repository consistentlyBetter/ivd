## Guard against a stale fixture: the committed ivd_fit.rds must carry the
## object schema the current code produces. If any of these fail, reinstall
## the package and rerun tests/testthat/fixtures/make-ivd-fixture.R.

test_that("the committed fixture carries the current object schema", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_s3_class(ivd_fixture, "ivd")

  ## structural richness the suite depends on (multi-random-effect branches)
  expect_gt(ivd_fixture$nimble_constants$Kr, 1)
  expect_gt(ivd_fixture$nimble_constants$Sr, 1)
  expect_false(is.null(ivd_fixture$samples[[1]]$WAIC))

  ## schema fields added in 1.0.0.9000 (group labels, formulas, prior)
  expect_equal(ivd_fixture$group_labels,
               as.character(seq_len(ivd_fixture$nimble_constants$J)))
  expect_s3_class(ivd_fixture$location_formula, "formula")
  expect_s3_class(ivd_fixture$scale_formula, "formula")
  expect_equal(ivd_fixture$ss_prior_p, 0.5)
})
