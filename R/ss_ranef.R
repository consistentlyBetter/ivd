#' ss_ranef_alpha
#'
#' `ss_ranef_alpha()` fits a random intercepts model with a spike-and-slab prior on the random effects
#'
#' @param y A vector containing the outcome
#' @param unit A vector of the same length as `y` containing a unique identifier
#' @param burnin The number of iterations to use as burnin. Defaults to 1000.
#' @param iter The number of iterations to use for estimating the parameters. Defaults to 1000.
#' @param chains The number of MCMC chains to use. Defaults to 4.
#' @param priors A named list to specify priors.  Defaults to NULL. See README for details.
#' @param vars2monitor A vector containing the names of which parameters to monitor. See details below.
#'
#' @details The parameters that can be tracked are:
#' \itemize{
#'   \item alpha: The fixed effect for the intercept
#'   \item gamma: The inclusion indicators for the random effects
#'   \item sigma: The residual standard deviation
#'   \item tau: The standard deviation of the random effects
#'   \item theta: The random effects
#' }
#'
#' @return An object of type \code{ssranef}.
#'
#'
#' @importFrom rjags jags.model coda.samples
#' @importFrom stats update
#' @export


ss_ranef_alpha <- function(y, unit, burnin = 1000, iter = 1000, chains = 4, priors = NULL,
                           vars2monitor = c("alpha", "gamma", "sigma", "tau", "theta")) {
  args <- match.call()

  if (is.null(priors)) {
    priors_list <- make_default_priors_alpha()
  } else {
      priors_list <- make_custom_priors_alpha(priors)
    }

  model_text <- make_model_text_alpha(priors_list = priors_list)
  og_units <- unique(unit)
  data_list <- list(y = y,
                    N = length(y),
                    unit = as.numeric(as.factor(unit)),
                    J = length(unique(unit)),
                    n_j = as.numeric(table(unit)))

  jags_fit <- jags.model(textConnection(model_text),
                         data = data_list,
                         n.chains = chains)

  if (!is.null(burnin)) update(jags_fit, burnin)

  mcmc_list <- coda.samples(jags_fit,
                            variable.names = vars2monitor,
                            n.iter = iter)

  post_samps <- do.call(rbind.data.frame, mcmc_list)
  post_samps$chain <- rep(1:chains, each = iter)

  # clean up column names
  cnames <- colnames(post_samps)
  gamma_mask <- grepl("gamma\\[[0-9]+\\]", cnames)
  lambda_mask <- grepl("lambda\\[[0-9]+\\]", cnames)
  theta_mask <- grepl("theta\\[[0-9]+\\]", cnames)

  cnames[gamma_mask] <- paste("gamma", og_units, sep = "_")
  cnames[lambda_mask] <- paste("lambda", og_units, sep = "_")
  cnames[theta_mask] <- paste("theta", og_units, sep = "_")


  colnames(post_samps) <- cnames

  ret <- list(
    posterior_samples = post_samps,
    data_list = data_list,
    model_text = model_text,
    call = args
  )

  class(ret) <- c("ss_ranef", "list")
  return(ret)
}




#' ss_ranef_beta
#'
#' `ss_ranef_beta()` fits a mixed-effects model with
#' random intercepts and random slopes, with a spike-and-slab prior on the random slopes.
#'
#' @param y A vector containing the outcome
#' @param X A vector containing the predictor
#' @param unit A vector of the same length as `y` containing a unique identifier
#' @param burnin The number of iterations to use as burnin. Defaults to 1000.
#' @param iter The number of iterations to use for estimating the parameters. Defaults to 1000.
#' @param chains The number of MCMC chains to use. Defaults to 4.
#' @param priors A named list to specify priors.  Defaults to NULL. See README for details.
#' @param vars2monitor A vector containing the names of which parameters to monitor. See details below.
#'
#'
#' @details The parameters that can be tracked are:
#' \itemize{
#'   \item alpha: The fixed effect for the intercept
#'   \item beta: The fixed effect for the slope
#'   \item gamma: The inclusion indicators for the slope random effects
#'   \item rho: The correlation between theta1 and theta2
#'   \item sigma: The residual standard deviation
#'   \item tau1: The standard deviation for alpha
#'   \item tau2: The standard deviation for beta
#'   \item theta1: The random effects for alpha
#'   \item theta2: The random effects for beta
#' }
#'
#' @return An object of type \code{ssranef}.
#'
#' @importFrom rjags jags.model coda.samples
#' @importFrom stats update
#' @export


ss_ranef_beta <- function(y, X, unit, burnin = 1000, iter = 1000, chains = 4, priors = NULL,
                          vars2monitor = c("alpha", "beta", "gamma", "rho", "sigma", "tau1", "tau2", "theta1", "theta2")) {
  args <- match.call()

  if (is.null(priors)) {
    priors_list <- make_default_priors_beta()
  } else {
    priors_list <- make_custom_priors_beta(priors)
  }

  model_text <- make_model_text_beta(priors_list = priors_list)
  og_units <- unique(unit)
  X <- cbind(1, X)
  data_list <- list(y = y,
                    X = X,
                    N = length(y),
                    unit = as.numeric(as.factor(unit)),
                    J = length(unique(unit)))

  jags_fit <- jags.model(textConnection(model_text),
                         data = data_list,
                         n.chains = chains)

  if (!is.null(burnin)) update(jags_fit, burnin)

  mcmc_list <- coda.samples(jags_fit,
                            variable.names = vars2monitor,
                            n.iter = iter)

  post_samps <- do.call(rbind.data.frame, mcmc_list)
  post_samps$chain <- rep(1:chains, each = iter)

  # clean up column names
  cnames <- colnames(post_samps)
  gamma_mask <- grepl("gamma\\[[0-9]+\\]", cnames)
  theta1_mask <- grepl("theta1\\[[0-9]+\\]", cnames)
  theta2_mask <- grepl("theta2\\[[0-9]+\\]", cnames)

  cnames[gamma_mask] <- paste("gamma", og_units, sep = "_")
  cnames[theta1_mask] <- paste("theta1", og_units, sep = "_")
  cnames[theta2_mask] <- paste("theta2", og_units, sep = "_")


  colnames(post_samps) <- cnames
  ret <- list(
    posterior_samples = post_samps,
    data_list = data_list,
    model_text = model_text,
    call = args
  )
  class(ret) <- c("ss_ranef", "list")
  return(ret)
}



#' ss_ranef_mv
#'
#' `ss_ranef_mv()` fits a multivariate mixed-effects model with
#' random intercepts and random slopes for two outcomes. A spike-and-slab prior is placed on the random slopes of both outcomes.
#'
#'
#' @param Y A two column matrix containing the outcomes of interest.
#' @param X A vector containing the predictor variable.
#' @param unit A vector of containing a unique identifier for each row in `Y`.
#' @param burnin The number of iterations to use as burnin. Defaults to 1000.
#' @param iter The number of iterations to use for estimating the parameters. Defaults to 1000.
#' @param chains The number of MCMC chains to use. Defaults to 4.
#' @param priors A named list to specify priors.  Defaults to NULL. See README for details.
#' @param vars2monitor A vector containing the names of which parameters to monitor. See details below.
#'
#'
#' @details The parameters that can be tracked are:
#' \itemize{
#'   \item B: The fixed effects.
#'   \itemize{
#'     \item B_1_1 and B_1_2 corresponds to the fixed effect intercept and slope for the first outcome, respectively.
#'     \item B_2_1 and B_2_2 corresponds to the fixed effect intercept and slope for the second outcome, respectively.
#'   }
#'   \item gamma1: The inclusion indicators for the slope random effects of the first outcome.
#'   \item gamma2: The inclusion indicators for the slope random effects of the second outcome.
#'   \item rb: The between-unit correlations, or the correlations between the random effects.
#'   \itemize{
#'     \item rb_1_2: Correlation between random intercept and random slope for the first outcome
#'     \item rb_1_3: Correlation between random intercept for the first outcome and random intercept for the second outcome
#'     \item rb_1_4: Correlation between random intercept for the first outcome and random slope for the second outcome
#'     \item rb_2_3: Correlation between random slope for the first outcome and random intercept for the second outcome
#'     \item rb_2_4: Correlation between random slope for the first outcome and random slope for the second outcome
#'     \item rb_3_4: Correlation between random intercept and random slope for the second outcome
#'   }
#'   \item rw: The correlation between the residual standard deviations, sigma_1 and sigma_2
#'   \item sigma: The residual standard deviations sigma_1 (first outcome) and sigma_2 (second outcome)
#'   \item Tau: The (co-)variances for the random effects
#'   \itemize{
#'     \item Tau_1_1: Variance for the random intercept of the first outcome
#'     \item Tau_2_2: Variance for the random slope of the first outcome
#'     \item Tau_3_3: Variance for the random intercept of the second outcome
#'     \item Tau_4_4: Variance for the random slope of the second outcome
#'   }
#'   \item theta: The random effects each outcome. The names are formatted as `theta_unitID_randomEffect`. E.g., theta_3_2 would correspond
#'   to the random intercept of the 2nd outcome for the 3rd unit.
#' }
#'
#' @importFrom rjags jags.model coda.samples
#' @importFrom stats update
#' @export


ss_ranef_mv <- function(Y, X, unit, burnin = 1000, iter = 1000, chains = 4, priors = NULL,
                          vars2monitor = c("B", "theta", "gamma1", "gamma2", "sigma", "Tau", "rb", "rw")) {
  args <- match.call()

  if (is.null(priors)) {
    priors_list <- make_default_priors_mv()
  } else {
    priors_list <- make_custom_priors_mv(priors)
  }

  model_text <- make_model_text_mv(priors_list = priors_list)
  og_units <- unique(unit)
  X <- cbind(1, X)
  K <- 4
  data_list <- list(Y = Y,
                    X = X,
                    N = nrow(Y),
                    unit = as.numeric(as.factor(unit)),
                    J = length(unique(unit)),
                    O = diag(K),
                    K = K)

  jags_fit <- jags.model(textConnection(model_text),
                         data = data_list,
                         n.chains = chains)

  if (!is.null(burnin)) update(jags_fit, burnin)

  mcmc_list <- coda.samples(jags_fit,
                            variable.names = vars2monitor,
                            n.iter = iter)

  post_samps <- do.call(rbind.data.frame, mcmc_list)
  post_samps$chain <- rep(1:chains, each = iter)

  # clean up column names
  cnames <- colnames(post_samps)
  # -- comma to underscore
  cnames <- gsub(",", "_", cnames)
  # -- open brackets to underscores
  cnames <- gsub("\\[", "_", cnames)
  # -- remove closing brackets
  cnames <- gsub("\\]", "", cnames)

  colnames(post_samps) <- cnames

  ret <- list(
    posterior_samples = post_samps,
    data_list = data_list,
    model_text = model_text,
    call = args
  )
  class(ret) <- c("ss_ranef", "list")
  return(ret)
}




# jcov2cor <- function(x) {
#   x %>%
#     select(matches("Tau\\[")) %>%
#     colMeans() -> x
#   m <- diag(4)
#   diag(m) <- c(x["Tau[1,1]"], x["Tau[2,2]"], x["Tau[3,3]"],x["Tau[4,4]"])
#   m[lower.tri(m)] <- c(
#     x["Tau[1,2]"],
#     x["Tau[1,3]"],
#     x["Tau[1,4]"],
#     x["Tau[2,3]"],
#     x["Tau[2,4]"],
#     x["Tau[3,4]"]
#   )
#
#   m[upper.tri(m)] <- t(m)[upper.tri(m)]
#
#   return(m)
# }
#
# diag(sqrt(jcov2cor(post_df)))
# post_df %>%
#   select(matches("rho\\[")) %>%
#   colMeans()
