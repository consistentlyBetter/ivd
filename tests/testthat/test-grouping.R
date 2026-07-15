## Arbitrary grouping IDs: prepare_data_for_nimble() recodes any ID type to
## the internal 1..J index and keeps the original labels; summary()/plot()
## can report those labels via labels = "original".

test_that("prepare_data_for_nimble accepts character grouping IDs", {
  data <- data.frame(
    Y = rnorm(30), X1 = rnorm(30),
    group = rep(c("school_C", "school_A", "school_B"), each = 10)
  )
  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))

  expect_equal(sort(unique(result$group_id)), 1:3)
  expect_equal(result$groups, 3)
  ## factor() level order: alphabetical for character IDs
  expect_equal(result$group_labels, c("school_A", "school_B", "school_C"))
  ## round-trip: labels indexed by the internal index recover the input
  expect_equal(result$group_labels[result$group_id], data$group)
})

test_that("prepare_data_for_nimble accepts factor grouping IDs and keeps level order", {
  data <- data.frame(
    Y = rnorm(20), X1 = rnorm(20),
    group = factor(rep(c("b", "a"), each = 10), levels = c("b", "a"))
  )
  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))

  expect_equal(result$group_labels, c("b", "a"))
  expect_equal(result$group_labels[result$group_id], as.character(data$group))
})

test_that("prepare_data_for_nimble recodes large unsorted numeric IDs without reordering rows", {
  ## Realistic school codes, rows not sorted by group.
  ids <- c(35012976, 11000023, 35012976, 53001087, 11000023, 35012976)
  data <- data.frame(Y = rnorm(6), X1 = rnorm(6), group = ids)
  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))

  ## numeric IDs get numeric (not alphabetical) level order
  expect_equal(result$group_labels, c("11000023", "35012976", "53001087"))
  expect_equal(result$group_id, c(2, 1, 2, 3, 1, 2))
  ## row order untouched: Y still aligned with the input
  expect_equal(result$data$Y, data$Y)
})

test_that("prepare_data_for_nimble leaves a conforming 1..J index unchanged", {
  data <- data.frame(
    Y = rnorm(40), X1 = rnorm(40),
    group = rep(1:4, each = 10)
  )
  result <- prepare_data_for_nimble(data, Y ~ X1 + (1 | group), ~ X1 + (1 | group))

  expect_equal(result$group_id, data$group)
  expect_equal(result$group_labels, as.character(1:4))
})

test_that("summary(labels = 'original') maps PIP rows to original IDs", {
  fit <- ivd_fixture
  J <- fit$nimble_constants$J
  fit$group_labels <- sprintf("school_%03d", seq_len(J))

  res_orig <- suppressWarnings(summary(fit, pip = "pip", labels = "original"))$table
  res_idx <- suppressWarnings(summary(fit, pip = "pip"))$table # default: index

  expect_equal(nrow(res_orig), nrow(res_idx))
  expect_true(all(grepl("school_\\d{3}\\]$", rownames(res_orig))))
  ## row j must carry label j: rebuild the expected names from the index rows
  expected <- sub(",\\s*(\\d+)\\]$", "", rownames(res_idx))
  j <- as.integer(sub(".*,\\s*(\\d+)\\]$", "\\1", rownames(res_idx)))
  expect_equal(rownames(res_orig), paste0(expected, ", ", fit$group_labels[j], "]"))
})

test_that("summary(labels = 'original') warns and keeps the index on legacy objects", {
  fit <- ivd_fixture
  fit$group_labels <- NULL

  expect_warning(res <- summary(fit, pip = "pip", labels = "original"),
                 "predates 'group_labels'")
  expect_true(all(grepl(",\\s*\\d+\\]$", rownames(res$table))))
})

test_that("plot(labels = 'original') labels points with original IDs", {
  skip_if_not_installed("ggrepel")
  fit <- ivd_fixture
  J <- fit$nimble_constants$J
  fit$group_labels <- sprintf("school_%03d", seq_len(J))

  p <- plot(fit, type = "pip", variable = "(Intercept)",
            label_points = TRUE, labels = "original")
  expect_s3_class(p, "ggplot")
  expect_true("label" %in% names(p$data))
  expect_equal(p$data$label, fit$group_labels[p$data$id])

  ## default stays on the compact internal index
  p_idx <- plot(fit, type = "pip", variable = "(Intercept)", label_points = TRUE)
  expect_equal(p_idx$data$label, p_idx$data$id)
})

test_that("plot(labels = 'original') warns and falls back on legacy objects", {
  fit <- ivd_fixture
  fit$group_labels <- NULL

  expect_warning(
    p <- plot(fit, type = "pip", variable = "(Intercept)",
              label_points = FALSE, labels = "original"),
    "predates 'group_labels'"
  )
  expect_s3_class(p, "ggplot")
  expect_equal(p$data$label, p$data$id)
})
