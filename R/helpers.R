#' @importFrom methods is
#' @importFrom stats quantile sd coef
#' @importFrom utils packageVersion

# helpers for alpha model
#----

make_default_priors_alpha <- function() {
  priors_list <- list(
    gamma = "gamma[j] ~ dbern(0.5)",
    alpha = "alpha ~ dnorm(0, 0.01)",
    tau = "tau ~ dt(0, 1, 3)T(0, )",
    sigma = "sigma ~ dt(0, 1, 3)T(0, )"
  )
  return(priors_list)
}


make_custom_priors_alpha <- function(custom_priors) {
  custom_priors_names <- names(custom_priors)
  priors_list <- make_default_priors_alpha()

  priors_list[custom_priors_names] <- custom_priors

  return(priors_list)
}


alpha_model_text1 <-
  "model{
  for (i in 1:N) {
    # likelihood
    y[i] ~ dnorm(alpha_j[unit[i]], precision)
  }
  for (j in 1:J) {"


alpha_model_text2 <-
   "
    # non-centered parameterization
    alpha_raw[j] ~ dnorm(0, 1)
    theta[j] <- tau * alpha_raw[j] * gamma[j]
    alpha_j[j] <- alpha + theta[j]
    lambda[j] <- (tau^2 / (tau^2 + sigma^2/n_j[j])) * gamma[j]
  }
"


make_model_text_alpha <- function(priors_list) {
  model_text <- paste0(
    alpha_model_text1, "\n    ",
    priors_list$gamma,
    alpha_model_text2, "  ",
    priors_list$alpha, "\n  ",
    priors_list$tau, "\n  ",
    "precision <- pow(sigma, -2)", "\n  ",
    priors_list$sigma, "\n",
    "}"

  )
  return(model_text)
}



# --- helpers for beta model ---

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


beta_model_text1 <-
  "model {
    for (i in 1:N) {
      # likelihood
      y[i] ~ dnorm(mu[i], precision)
      mu[i] <- inprod(X[i, ], B[unit[i],  ])
    }
    for (j in 1:J) {
      # prior for inclusion variable"


beta_model_text2 <-
  "
      # random intercept
      z1[j] ~ dnorm(0, 1)
      theta1[j] <- tau1 * z1[j]

      # random slope
      z2[j] ~ dnorm(0, 1)
      theta2raw[j] <- rho * z1[j] + sqrt(1 - rho^2) * z2[j]
      theta2star[j] <- theta2raw[j] * gamma[j]
      theta2[j] <- tau2 * theta2star[j]
      B[j, 1] <- alpha + theta1[j]
      B[j, 2] <- beta + theta2[j]
    }
  # priors"


make_model_text_beta <- function(priors_list) {
  model_text <- paste0(
    beta_model_text1, "\n      ",
    priors_list$gamma,
    beta_model_text2, "\n  ",
    priors_list$alpha, "\n  ",
    priors_list$beta, "\n  ",
    priors_list$tau1, "\n  ",
    priors_list$tau2, "\n  ",
    "precision <- pow(sigma, -2)", "\n  ",
    priors_list$sigma, "\n  ",
    priors_list$rho, "\n",
    "}"

  )
  return(model_text)
}

#----

# helpers for multivariate model
#----

make_default_priors_mv <- function() {
  priors_list <- list(
    # fixed effects
    B1_1 = "B[1, 1] ~ dnorm(0, 0.1)",
    B1_2 = "B[1, 2] ~ dnorm(0, 0.1)",
    B2_1 = "B[2, 1] ~ dnorm(0, 0.1)",
    B2_2 = "B[2, 2] ~ dnorm(0, 0.1)",
    # random effects
    theta = "theta[j, 1:4] ~ dmnorm(c(0, 0, 0, 0), Omega[1:4, 1:4])",
    Omega = "Omega[1:4,1:4] ~ dwish(O[1:4,1:4], 5)",
    gamma1 = "gamma1[j] ~ dbern(0.5)",
    gamma2 = "gamma2[j] ~ dbern(0.5)",
    # residual standard deviations
    s1 = "s[1, 1] ~ dt(0, 1, 3)T(0, )",
    s2 = "s[2, 2] ~ dt(0, 1, 3)T(0, )",
    rw = "rw ~ dunif(-1, 1)"
  )
  return(priors_list)
}


make_custom_priors_mv <- function(custom_priors) {
  custom_priors_names <- names(custom_priors)
  priors_list <- make_default_priors_mv()

  priors_list[custom_priors_names] <- custom_priors

  return(priors_list)
}


mv_model_text1 <- "
model{
  for (i in 1:N) {
    Y[i, 1:2] ~ dmnorm(M[i, 1:2], Pw[1:2, 1:2])
    M[i, 1] <- inprod(X[i, 1:2], Bj[unit[i], 1, 1:2])
    M[i, 2] <- inprod(X[i, 1:2], Bj[unit[i], 2, 1:2])
  }
  for (j in 1:J) {
"

mv_model_text2 <-
  " Bj[j, 1, 1:2] <- B[1, 1:2] + theta[j, 1:2] * c(0, gamma1[j])
    Bj[j, 2, 1:2] <- B[2, 1:2] + theta[j, 3:4] * c(0, gamma2[j])
  }"


mv_model_text3 <- "
  # ==== Covariance matrix for residuals ====

  # Precision matrix for within-unit errors
  Pw <- inverse(Sigma)

  # standard deviations for residuals
  sigma[1:2] <- c(sqrt(Sigma[1, 1]),
                  sqrt(Sigma[2, 2]))

  # Covariance matrix for residuals
  Sigma <- s %*% Rw %*% s

  # within-unit correlation
  Rw[1, 1] <- 1
  Rw[2, 2] <- 1
  Rw[1, 2] <- rw
  Rw[2, 1] <- rw

  s[1, 2] <- 0
  s[2, 1] <- 0

  # priors for residual SDs
"


mv_model_text4 <-
  "
  # ==== Covariance matrix for random effects ====
  "


mv_model_text5 <- "
  Tau <- inverse(Omega)

  for (k in 1:K){
    for (k.prime in 1:K){
      rb[k,k.prime] <- Tau[k,k.prime]/
        sqrt(Tau[k,k]*Tau[k.prime,k.prime])
    }
  }
 }
 "

make_model_text_mv <- function(priors_list) {
  model_text <-
    paste0(
    mv_model_text1, "    ",
    priors_list$theta, "",
    priors_list$gamma1, "\n    ",
    priors_list$gamma2, "\n   ",
    mv_model_text2, "\n  ",
    priors_list$B1_1, "\n  ",
    priors_list$B1_2, "\n  ",
    priors_list$B2_1, "\n  ",
    priors_list$B2_2, "\n  ",
    mv_model_text3, "  ",
    priors_list$s1, "\n  ",
    priors_list$s2, "\n  ",
    priors_list$rw, "\n  ",
    mv_model_text4,
    priors_list$Omega, "\n  ",

    mv_model_text5
  )
  return(model_text)
}





# new models
#----
ICC_lsm <- "model{

  for(j in 1:J){

    # latent betas
    beta_raw_l[j] ~  dnorm(0, 1)

    # random effect
    beta_l[j] <- fe_mu + tau_mu * beta_raw_l[j]

    # cholesky
    z2[j] ~ dnorm(0, 1)
    beta_raw_s[j] = rho12 * beta_raw_l[j] + sqrt(1 - rho12^2) * z2[j]

    beta_s[j] <- fe_sd + tau_sd * beta_raw_s[j]

  }

  for(i in 1:N){

    # likelihood
    y[i] ~ dnorm(beta_l[ID[i]], 1/exp(beta_s[ID[i]])^2)

  }


  # fixed effects priors
  fe_mu ~ dnorm(mean_start, 0.0001)
  fe_sd ~ dnorm(0, 0.0001)

  # random effects priors
  tau_mu ~ dt(0, pow(prior_scale,-2), 10)T(0,)
  tau_sd ~ dt(0, pow(prior_scale,-2), 10)T(0,)



  # prior for RE correlation
  fz ~ dnorm(0, 1)
  rho12 = tanh(fz)

}"


ICC_customary <- "model{

for(j in 1:J){
  # latent betas
  beta_raw[j] ~  dnorm(0, 1)

  # random effect
  beta[j] <- fe_mu + tau_mu * beta_raw[j]
 }

for(i in 1:N){

  # likelihood
  y[i] ~ dnorm(beta[ID[i]], prec)}


# fixed effects priors
fe_mu ~ dnorm(mean_start, 0.001)

# random effects priors
tau_mu ~ dt(0, pow(prior_scale,-2), 10)T(0,)
prec ~ dgamma(1.0E-4,1.0E-4)

sigma <- 1/sqrt(prec)

}"

ICC_pick_tau <- "model{

    for(j in 1:J){

      # latent betas
      beta_raw_l[j] ~  dnorm(0, 1)

      # random effect
      beta_l[j] <- fe_mu + tau_mu * beta_raw_l[j]

      # cholesky
      z2[j] ~ dnorm(0, 1)
      beta_raw_s[j] = rho12 * beta_raw_l[j] + sqrt(1 - rho12^2) * z2[j]

      beta_s[j] <- fe_sd + tau_new * beta_raw_s[j]

    }

    for(i in 1:N){

      # likelihood
      y[i] ~ dnorm(beta_l[ID[i]], 1/exp(beta_s[ID[i]])^2)

    }


    # fixed effects priors
    fe_mu ~ dnorm(mean_start, 0.0001)
    fe_sd ~ dnorm(0, 0.0001)

    # random effects priors
    tau_mu ~ dgamma(1.0E-4,1.0E-4)

    tau_sd ~ dt(0, pow(prior_scale,-2), 10)T(0,)

    pick_tau ~ dbern(inc_prob)

    tau_new <- tau_sd * pick_tau


    # prior for RE correlation
    fz ~ dnorm(0, 1)
    rho12 = tanh(fz)

}"



ICC_pick_id <- "model{

for(j in 1:J){

      pick_id[j] ~ dbern(inc_prob)

      # latent betas
      beta_raw_l[j] ~  dnorm(0, 1)

      # random effect
      beta_l[j] <- fe_mu + tau_mu * beta_raw_l[j]

      # cholesky
      z2[j] ~ dnorm(0, 1)

      beta_raw_s[j] = rho12 * beta_raw_l[j] + sqrt(1 - rho12^2) * z2[j]

      beta_new[j] <- beta_raw_s[j] * pick_id[j]
      beta_s[j] <- fe_sd + (tau_sd * beta_new[j])

}

for(i in 1:N){
# likelihood
y[i] ~ dnorm(beta_l[ID[i]], 1/exp(beta_s[ID[i]])^2)
}


# fixed effects priors
fe_mu ~ dnorm(mean_start, 0.0001)
fe_sd ~ dnorm(0, 0.0001)

# random effects priors
tau_mu ~   dt(0, pow(prior_scale,-2), 10)T(0,)
tau_sd ~   dt(0, pow(prior_scale,-2), 10)T(0,)



# prior for RE correlation
fz ~ dnorm(0, 1)
rho12 = tanh(fz)

}"