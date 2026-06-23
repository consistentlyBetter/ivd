library(testthat)
library(ivd)

test_that(".summary_table drops redundant correlation, ss, sigma_rand and u rows", {
  ## Hand-built summary matrix with the row-name shapes .summary_table filters.
  ## With Kr = 2 (two random *location* effects):
  ##   - R[i, j] keeps only the strict lower triangle (i > j)
  ##   - ss[i, j] drops location effects (i <= Kr); keeps scale effects (i > Kr)
  ##   - sigma_rand[i, j] (matrix form) keeps only the diagonal (i == j)
  ##   - u[...] is always dropped
  rn <- c(
    "beta[1]", "zeta[1]",
    "R[1, 1]", "R[2, 1]", "R[1, 2]",
    "ss[1, 3]", "ss[3, 3]",
    "sigma_rand[1, 1]", "sigma_rand[2, 1]",
    "u[1, 1]"
  )
  ## Two columns so the subset stays a matrix (drop = TRUE would lose rownames).
  stats <- matrix(seq_len(2 * length(rn)) * 1.0, ncol = 2,
                  dimnames = list(rn, c("Mean", "SD")))

  filtered <- .summary_table(stats, Kr = 2)

  expect_setequal(
    rownames(filtered),
    c("beta[1]", "zeta[1]", "R[2, 1]", "ss[3, 3]", "sigma_rand[1, 1]")
  )
})

test_that(".summary_table keeps vector-form sigma_rand entries", {
  rn <- c("sigma_rand[1]", "sigma_rand[2]", "beta[1]")
  stats <- matrix(seq_len(2 * length(rn)) * 1.0, ncol = 2,
                  dimnames = list(rn, c("Mean", "SD")))

  filtered <- .summary_table(stats, Kr = 1)
  expect_setequal(rownames(filtered), rn)
})

test_that(".require_suggest errors for a missing package and is silent otherwise", {
  expect_error(
    .require_suggest("a.package.that.does.not.exist.12345", "this feature"),
    "is required"
  )
  expect_silent(.require_suggest("stats", ""))
})

test_that(".newline prints the requested number of blank lines", {
  expect_output(.newline(3))
})
