library(testthat)
library(ivd) 

test_that("plot.ivd creates a PIP plot correctly", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  plot <- plot.ivd(testoutput, type = "pip")
  expect_s3_class(plot, "ggplot")
})

test_that("plot.ivd creates a funnel plot correctly", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  plot <- plot.ivd(testoutput, type = "funnel")
  expect_s3_class(plot, "ggplot")
})

## Codaplots
test_that("codaplot works correctly with specified parameters", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  expect_error(codaplot(testoutput, parameters = c("R[scl_Intc, Intc]")), NA) # Expect no error
})

test_that("codaplot works correctly with specified parameters", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  expect_error(codaplot(testoutput, type = "densplot",  parameters = c("R[scl_Intc, Intc]")), NA) # Expect no error
})

test_that("codaplot works correctly with ask next page", {
  skip_if(Sys.getenv("R_COVR") == "true", "Skipping ivd test during coverage")
  
  expect_error(codaplot(testoutput, type = "densplot",  parameters = c("R[scl_Intc, Intc]", "Intc"),
                        askNewPage = FALSE), NA) # Expect no error
})
