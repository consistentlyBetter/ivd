## .pip_reweight() is pure math (covr-safe, no fixture); pip_sensitivity()
## and its plot method run against the committed fixture.

test_that(".pip_reweight matches hand-computed values", {
  ## pip = 0.6 under p0 = 0.5: BF = 1.5. Under p1 = 0.25 (q = 1/3):
  ## 1.5/3 / (1 + 1.5/3) = 0.5/1.5 = 1/3.
  expect_equal(.pip_reweight(0.6, p0 = 0.5, p1 = 0.25), 1 / 3)
  ## Same BF under p1 = 0.75 (q = 3): 4.5/5.5 = 9/11.
  expect_equal(.pip_reweight(0.6, p0 = 0.5, p1 = 0.75), 9 / 11)
  ## Vectorized over pip
  expect_equal(.pip_reweight(c(0.6, 0.6), 0.5, 0.25), rep(1 / 3, 2))
})

test_that(".pip_reweight is the identity when p1 equals p0", {
  pips <- c(0, 0.01, 0.3425, 0.56, 0.9, 1)
  expect_equal(.pip_reweight(pips, p0 = 0.5, p1 = 0.5), pips)
  expect_equal(.pip_reweight(pips, p0 = 0.25, p1 = 0.25), pips)
})

test_that(".pip_reweight keeps boundary PIPs at 0 and 1", {
  expect_equal(.pip_reweight(c(0, 1), p0 = 0.5, p1 = 0.1), c(0, 1))
  expect_equal(.pip_reweight(c(0, 1), p0 = 0.5, p1 = 0.9), c(0, 1))
})

test_that(".pip_reweight is monotone in p1 and rejects invalid priors", {
  grid <- seq(0.05, 0.95, by = 0.05)
  out <- vapply(grid, function(p1) .pip_reweight(0.4, 0.5, p1), numeric(1))
  expect_true(all(diff(out) > 0))

  expect_error(.pip_reweight(0.5, p0 = 0, p1 = 0.5))
  expect_error(.pip_reweight(0.5, p0 = 0.5, p1 = 1))
  expect_error(.pip_reweight(1.2, p0 = 0.5, p1 = 0.5))
})

test_that("pip_sensitivity returns a tidy grid anchored at the fitted prior", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  J <- ivd_fixture$nimble_constants$J
  Sr <- ivd_fixture$nimble_constants$Sr
  grid <- c(0.1, 0.25, 0.5, 0.75, 0.9)

  sens <- pip_sensitivity(ivd_fixture, prior_p = grid)

  expect_s3_class(sens, "pip_sensitivity")
  expect_equal(nrow(sens), J * Sr * length(grid))
  expect_named(sens, c("scale_var", "cluster_index", "cluster_id",
                       "prior_p", "pip", "at_boundary"))
  expect_true(all(sens$pip >= 0 & sens$pip <= 1))

  ## p0 comes from the stored ss_prior_p (fit at the 0.5 default)
  expect_equal(attr(sens, "p0"), 0.5)

  ## legacy objects without ss_prior_p recover p0 from nimble_constants$bval
  legacy <- ivd_fixture
  legacy$ss_prior_p <- NULL
  expect_equal(attr(pip_sensitivity(legacy, prior_p = 0.5), "p0"), 0.5)

  ## at prior_p = p0 the (clamped) estimated PIPs are recovered
  est <- pip(ivd_fixture)
  S <- attr(sens, "n_draws")
  pip0 <- pmin(pmax(est$pip, 0.5 / S), (S - 0.5) / S)
  anchor <- sens[sens$prior_p == 0.5, ]
  key_a <- paste(anchor$scale_var, anchor$cluster_index)
  key_e <- paste(est$scale_var, est$cluster_index)
  expect_equal(anchor$pip, pip0[match(key_a, key_e)])

  ## trajectories are monotone in prior_p for every cluster
  by_cluster <- split(sens[order(sens$prior_p), ],
                      paste(sens$scale_var, sens$cluster_index)[order(sens$prior_p)])
  expect_true(all(vapply(by_cluster,
                         function(d) all(diff(d$pip) >= 0), logical(1))))
})

test_that("pip_sensitivity respects a stored ss_prior_p", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  fit <- ivd_fixture
  fit$ss_prior_p <- 0.2
  sens <- pip_sensitivity(fit, prior_p = 0.2)
  expect_equal(attr(sens, "p0"), 0.2)

  ## anchored at its own p0, the estimate is returned unchanged (up to clamp)
  est <- pip(fit)
  S <- attr(sens, "n_draws")
  expect_equal(sens$pip, pmin(pmax(est$pip, 0.5 / S), (S - 0.5) / S))
})

test_that("pip_sensitivity validates its inputs", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  expect_error(pip_sensitivity(list()), "must be an ivd object")
  expect_error(pip_sensitivity(ivd_fixture, prior_p = c(0.5, 1)),
               "strictly between 0 and 1")
  expect_error(pip_sensitivity(ivd_fixture, prior_p = numeric(0)),
               "strictly between 0 and 1")
})

test_that("plot.pip_sensitivity(clusters =) draws only the requested clusters", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  sens <- pip_sensitivity(ivd_fixture)

  ## by cluster index/ID (numeric on the legacy fixture)
  p <- plot(sens, clusters = c(3, 7))
  expect_s3_class(p, "ggplot")
  expect_setequal(unique(p$data$cluster_index), c(3, 7))
  ## explicitly requested clusters are all marked for coloring + labels
  expect_true(all(p$data$sensitive))

  ## by original ID when labels are stored
  fit <- ivd_fixture
  fit$group_labels <- paste0("school_", seq_len(fit$nimble_constants$J))
  sens_lab <- pip_sensitivity(fit)
  p_lab <- plot(sens_lab, clusters = c("school_3", "school_7"))
  expect_setequal(unique(p_lab$data$cluster_id), c("school_3", "school_7"))

  ## unknown clusters error informatively
  expect_error(plot(sens, clusters = c("nope")), "None of 'clusters' match")
})

test_that("plot.pip_sensitivity judges sensitivity within the odds window", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  sens <- pip_sensitivity(ivd_fixture)

  ## odds_factor = 1 collapses the window to the fitted prior: nothing flips
  p1 <- plot(sens, odds_factor = 1)
  expect_false(any(p1$data$sensitive))

  ## widening the window can only add sensitive clusters
  p2 <- plot(sens, odds_factor = 2)
  p10 <- plot(sens, odds_factor = 10)
  expect_lte(sum(p2$data$sensitive), sum(p10$data$sensitive))

  ## the default flag reproduces the analytic rule: classification at the
  ## window ends (odds halved/doubled around p0 = 0.5 -> priors 1/3 and 2/3)
  anchor <- sens[sens$prior_p == min(sens$prior_p), ]
  low <- .pip_reweight(anchor$pip, p0 = min(sens$prior_p), p1 = 1 / 3)
  high <- .pip_reweight(anchor$pip, p0 = min(sens$prior_p), p1 = 2 / 3)
  expected <- (low >= 0.75) != (high >= 0.75)
  got <- p2$data[!duplicated(paste(p2$data$scale_var, p2$data$cluster_index)), ]
  key_g <- paste(got$scale_var, got$cluster_index)
  key_e <- paste(anchor$scale_var, anchor$cluster_index)
  expect_equal(got$sensitive, expected[match(key_g, key_e)])
})

test_that("plot.pip_sensitivity returns a ggplot with facets per scale effect", {
  skip_if(is.null(ivd_fixture), "fixture missing; run tests/testthat/fixtures/make-ivd-fixture.R")

  sens <- pip_sensitivity(ivd_fixture)
  p <- plot(sens)
  expect_s3_class(p, "ggplot")
  ## fixture has Sr = 2 scale random effects -> faceted
  expect_s3_class(p$facet, "FacetWrap")
})
