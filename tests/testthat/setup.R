# Load the committed fixture instead of fitting a live model during tests.
#
# Fitting a real model here is slow (NIMBLE C++ compilation) and, under covr,
# the MCMC runs inside `future` worker processes that coverage cannot even
# instrument. Tests therefore operate on a pre-fitted object committed at
# tests/testthat/fixtures/ivd_fit.rds. Regenerate it with
# tests/testthat/fixtures/make-ivd-fixture.R.
#
# Reading the fixture only requires base R, so this stays MCMC-free.

library(ivd)

.ivd_fixture_path <- testthat::test_path("fixtures", "ivd_fit.rds")
ivd_fixture <- if (file.exists(.ivd_fixture_path)) readRDS(.ivd_fixture_path) else NULL

## Backwards-compatible alias for the old setup.R variable name.
testoutput <- ivd_fixture
