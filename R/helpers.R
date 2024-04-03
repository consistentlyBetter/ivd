# --- helpers for alpha model ---

make_default_priors_beta <- function() {
  priors_list <- list(
    gamma = "gamma[j] ~ dbern(0.5)",
    alpha = "alpha ~ dnorm(0, 0.01)",
    beta = "beta ~ dnorm(0, 0.01)",
    tau1 = "tau1 ~ dt(0, 1, 3)T(0, )",
    tau2 = "tau2 ~ dt(0, 1, 3)T(0, )",
    sigma = "sigma ~ dt(0, 1, 3)T(0, )",
    rho = "rho ~ dunif(-1, 1)"
  )
  return(priors_list)
}

make_custom_priors_beta <- function(custom_priors) {
  custom_priors_names <- names(custom_priors)
  priors_list <- make_default_priors_beta()

  priors_list[custom_priors_names] <- custom_priors

  return(priors_list)
}
