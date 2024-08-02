library(ivd)

if(Sys.getenv("R_COVR") == "true") {
  print("Skipping ivd model fitting")
} else {
  testoutput <- ivd(location_formula = Y ~ x + (1|grouping),
                    scale_formula = ~ 1 + (1|grouping),
                    data = data.frame(Y = rnorm(100), x = rnorm(100),
                                      grouping = rep(1:10, each = 10)),
                    niter = 100, nburnin = 50, WAIC = TRUE, workers = 2)
}

