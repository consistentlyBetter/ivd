##' Build and compile NIMBLE model and MCMC once
##' This function is exported for use in 'future' and is not meant to be called by user.
##' @import nimble
##' @export
##' @param code Nimble code
##' @param constants Constants
##' @param dummy_data Data
##' @param dummy_inits inits
##' @param useWAIC Defaults to TRUE. Nimble argument
##' @param monitor_pointwise Also monitor the per-observation `mu` and `tau`.
##'   Defaults to FALSE; only needed to reconstruct the pointwise
##'   log-likelihood. Monitoring them costs O(N x iterations) RAM per chain, so
##'   they are off unless requested.
##' @return
#' A named \code{list} with two elements:
#' \itemize{
#'   \item \code{cmodel}: The compiled NIMBLE model object produced by
#'         \code{compileNimble()}.
#'   \item \code{cmcmc}: The compiled NIMBLE MCMC object, created using
#'         \code{buildMCMC()} and \code{compileNimble()}, configured to
#'         monitor the model parameters (including WAIC monitors if
#'         \code{useWAIC = TRUE}).
#' }
#'
#' The function is intended for internal use (e.g., within parallel workers)
#' and is not meant to be called directly by end users.
#' @examples
#' \dontrun{
#' library(nimble)
#' # Generic nimble example
#' code <- nimbleCode({
#'   mu ~ dnorm(0, 1)
#'   x  ~ dnorm(mu, 1)
#' })
#'
#' constants   <- list()
#' dummy_data  <- list(x = 0)
#' dummy_inits <- list(mu = 0)
#'
#' out <- build_ivd_model(
#'   code        = code,
#'   constants   = constants,
#'   dummy_data  = dummy_data,
#'   dummy_inits = dummy_inits,
#'   useWAIC     = FALSE
#' )
#'
#' str(out)
#' }
build_ivd_model <- function(code, constants, dummy_data, dummy_inits, useWAIC = TRUE, monitor_pointwise = FALSE) {
    model <- nimbleModel(code = code, data = dummy_data, constants = constants, inits = dummy_inits)
    cmodel <- compileNimble(model)

    config <- configureMCMC(model)
    if (useWAIC) config$enableWAIC <- useWAIC
    config$monitors <- c("beta", "zeta", "R", "ss", "sigma_rand", "u")
    ## The per-observation nodes `mu` and `tau` are NOT monitored: each stores
    ## O(N x iterations) values per chain (the dominant memory term). The cluster
    ## outcome plot reconstructs the posterior-mean `mu` from `beta` + `u`, and
    ## the pointwise log-likelihood (which also needs `tau`) is opt-in. Monitor
    ## both only when the caller requests the pointwise quantities.
    if (monitor_pointwise) config$addMonitors(c("mu", "tau"))

    mcmc <- buildMCMC(config)
    cmcmc <- compileNimble(mcmc, project = cmodel)

    list(cmodel = cmodel, cmcmc = cmcmc)
}

##' Run MCMC on an already compiled model
##' Exposed but internal function for future()
##' @import nimble
##' @param compiled Compiled nimble model
##' @param seed Seed, set by future
##' @param new_data Data
##' @param new_inits inits
##' @param niter Sampling iteratons
##' @param nburnin Number of burnin iterations
##' @param useWAIC Defaults to TRUE
##' @param thin Thinning interval passed to `runMCMC()`. Defaults to 1.
##' @param ... Placeholder for nimble arguments
#' @return
#' The output produced by \code{nimble::runMCMC()} when applied to a compiled
#' NIMBLE MCMC object.  The returned value depends on the \code{useWAIC}
#' argument:
#'
#' \itemize{
#'   \item If \code{useWAIC = TRUE}, a named \code{list} containing:
#'     \itemize{
#'       \item \code{samples}: A matrix of posterior draws
#'             (iterations × parameters).
#'       \item \code{WAIC}: The WAIC value computed by NIMBLE.
#'       \item \code{...}: Additional elements returned by
#'             \code{runMCMC()} when WAIC is enabled.
#'     }
#'
#'   \item If \code{useWAIC = FALSE}, a numeric matrix containing the posterior
#'         samples (iterations × parameters) with no additional elements.
#' }
#'
#' This function is intended for internal use (e.g., within \code{future}
#' workers) and is not meant to be called directly by end users.
##' @export
##' @examples
#' \dontrun{
#' library(nimble)
#' # Generic nimble example
#' code <- nimbleCode({
#'   mu ~ dnorm(0, 1)
#'   x  ~ dnorm(mu, 1)
#' })
#'
#' constants   <- list()
#' dummy_data  <- list(x = 0)
#' dummy_inits <- list(mu = 0)
#'
#' out <- build_ivd_model(
#'   code        = code,
#'   constants   = constants,
#'   dummy_data  = dummy_data,
#'   dummy_inits = dummy_inits,
#'   useWAIC     = FALSE
#' )
#'
#' str(out)
#' }
run_MCMC_compiled_model <- function(compiled, seed, new_data, new_inits, niter, nburnin, useWAIC = TRUE, thin = 1, ...) {
  compiled$cmodel$setData(new_data)
  compiled$cmodel$setInits(new_inits)

  samples <- runMCMC(compiled$cmcmc, niter = niter, nburnin = nburnin, thin = thin, setSeed = seed, WAIC = useWAIC, ...)
  return(samples)
}

## Leave outside of main ivd function for future to find it
## nocov start: a nimbleFunction body is compiled to C++ by NIMBLE, not run as
## R, so covr cannot instrument it -- and injecting counters breaks compilation.
uppertri_mult_diag <- nimbleFunction(
    run = function(mat = double(2), vec = double(1)) {
        returnType(double(2))
        p <- length(vec)
        out <- matrix(nrow = p, ncol = p, init = FALSE)
        for (i in 1:p) {
            out[, i] <- mat[, i] * vec[i]
        }
        return(out)
    }
)
## nocov end

#' Main function to set up and run parallel MCMC using nimble and future.
#' `ivd` computes a mixed effects location and scale model with Spike and Slab regularization
#' on the scale random effects.
#' @param location_formula A formula for the location model
#' @param scale_formula A formula for the scale model
#' @param data Data frame in long format for analysis
#' @param niter Total number of MCMC iterations after burnin
#' @param nburnin Number of burnin iterations, defaults to the same as niter
#' @param WAIC Compute WAIC, defaults to 'TRUE'
#' @param workers Number of parallel R processes -- doubles as 'chains' argument
#' @param n_eff Use stan::monitor function or built local: 'stan' vs. 'local'
#' @param ss_prior_p Prior inclusion probability. Defaults to '.5'.
#' @param thin Thinning interval for stored posterior draws. Defaults to 1
#'   (keep every iteration). Larger values cut stored-sample RAM linearly.
#' @param return_logLik Store the pointwise log-likelihood array
#'   (`iterations x chains x N`) for use with e.g. `loo`. Defaults to FALSE.
#'   When TRUE, `tau` is also monitored. The array scales with N and is the
#'   single largest element of the returned object, so it is opt-in.
#' @param seed Optional integer for full reproducibility. When supplied, it
#'   seeds both the random initial values and a distinct per-chain MCMC seed, so
#'   repeated calls return identical draws without needing an external
#'   `set.seed()`. Defaults to `NULL` (inits drawn from the ambient RNG; chains
#'   seeded `1:workers` -- the previous behaviour).
#' @param progress Show a live, per-chain progress line while the chains compile
#'   and sample, and suppress NIMBLE's (buffered) per-worker console output.
#'   Defaults to `interactive()`. Set to FALSE to restore NIMBLE's verbose
#'   model-building output and disable the progress line. Progress granularity
#'   is per chain: each tick marks a chain finishing (compile + sample), since
#'   `multisession` workers cannot stream sub-chain progress.
#' @param ... Currently not used
#' @return
#' An object of class \code{"ivd"} (and \code{"list"}), which contains the
#' results from fitting a mixed-effects location-scale model with Spike-and-Slab
#' regularization using NIMBLE and parallel MCMC sampling.  
#'
#' The returned object is a named list with the following components:
#' \itemize{
#'   \item \code{samples}: An \code{mcmc.list} object containing posterior
#'         samples for all monitored parameters across all chains.
#'
#'   \item \code{logLik_array}: Only present when \code{return_logLik = TRUE}.
#'         A 3D array of pointwise log-likelihood values with dimensions
#'         \code{iterations × chains × N}.
#'
#'   \item \code{rhat_values}: Vector of split-\eqn{\hat{R}} convergence
#'         diagnostics (Vehtari et al., 2021).
#'
#'   \item \code{n_eff}: Vector of effective sample sizes, either computed
#'         internally ("local") or via \code{rstan::monitor()} ("stan").
#'
#'   \item \code{nimble_constants}: List of model constants used by the
#'         underlying NIMBLE model (e.g., number of groups, number of parameters).
#'
#'   \item \code{X_location_names}, \code{Z_location_names}:
#'         Names of fixed and random effects in the location submodel.
#'
#'   \item \code{X_scale}, \code{Z_scale}:
#'         Matrices used for the scale submodel’s fixed and random effects.
#'
#'   \item \code{X}, \code{Z}:
#'         Location-submodel fixed/random design matrices, retained so the
#'         outcome plot can reconstruct the posterior mean of \code{mu}.
#'
#'   \item \code{Y}: Data frame with the response vector and group identifiers.
#'
#'   \item \code{workers}: Number of parallel chains used.
#'
#'   \item \code{...}: Additional elements created internally and used for
#'         downstream S3 methods (\code{print()}, \code{summary()}, etc.).
#' }
#'
#' The object is designed to support S3 methods for printing, summarizing,
#' and extracting results from the \code{ivd} model.
#' 
#' @import future
#' @importFrom coda as.mcmc mcmc.list
#' @importFrom nimble nimbleCode nimbleModel compileNimble buildMCMC runMCMC
#' @importFrom rstan monitor
#' @importFrom stats as.formula model.matrix rlnorm rnorm update.formula dnorm sd
#' @importFrom utils head str
#' @export
#' @examples
##' \donttest{
##' out <- ivd(location_formula = math_proficiency ~ 1 + (1 | school_id),
##'    scale_formula =  ~ 1 + (1 | school_id),
##'    data = saeb,
##'    niter = 1000,
##'    nburnin = 2000,
##'    WAIC = TRUE,
##'    workers = 1) ## Workers = 1 for CRAN server - not ideal for individual use
##' ## Posterior inclusion probability plot (PIP)
##' plot(out, type = "pip")
##' ## PIP vs. Within-cluster SD
##' plot(out, type =  "funnel")
##' ## Diagnostic plots based on coda plots:
##' library(coda)
##' codaplot(out, parameters =  "Intc")
##' codaplot(out, parameters =  "R[scl_Intc, Intc]")
##' }
ivd <- function(location_formula, scale_formula, data, niter, nburnin = NULL, WAIC = TRUE, workers = 4, n_eff = "local", ss_prior_p = 0.5, thin = 1, return_logLik = FALSE, seed = NULL, progress = interactive(), ...) {
  if(is.null(nburnin)) {
    nburnin <- niter
  }
  niter <- niter + nburnin
  dat <- prepare_data_for_nimble(data = data, location_formula = location_formula, scale_formula = scale_formula)
  data <- dat[[1]]
  groups <- dat$groups
  group_id <- dat$group_id

  ## Obtain estimates for empirical intercept prior:
  mean_pred <- mean(data$Y, na.rm = TRUE)
  sd_pred <- sd(data$Y, na.rm = TRUE)
  
  ## Nimble part:
  ## Nimble constants
  constants <- list(
      N = length(data$Y),
      J = groups,
      K = ncol(data$X), ## number of fixed location effects
      Kr = ncol(data$Z), ## number of random location effects
      S = ncol(data$X_scale), ## number of fixed scale effects
      Sr = ncol(data$Z_scale), ## number of random scale effects
      P = ncol(data$Z) + ncol(data$Z_scale), ## number of random effects
      groupid = group_id,
      mean_pred =  mean_pred, ## empirical estimate from sample for location
      sd_pred = sd_pred, ## empirical estimate from sample for location
      bval = matrix(c(rep(1, ncol(data$Z)), rep(ss_prior_p, ncol(data$Z_scale))), ncol = 1)## Prior probability for dbern
  )
  ## Optional reproducibility: seed the random inits and derive a distinct,
  ## reproducible RNG seed per chain. With seed = NULL the behaviour is
  ## unchanged -- inits drawn from the ambient RNG, chains seeded 1:workers.
  if (!is.null(seed)) set.seed(seed)
  ## Nimble inits
  inits <- list(beta = rnorm(constants$K, 5, 10), ## TODO: Check inits
                zeta =  rnorm(constants$S, 1, 3))
  chain_seeds <- if (is.null(seed)) seq_len(workers) else sample.int(.Machine$integer.max, workers)

  ## nocov start: the model is NIMBLE's BUGS-style DSL, parsed by nimbleModel()
  ## rather than executed as R. covr's line-counting injection corrupts it
  ## (e.g. the if() branches trip checkReservedVarNames), so exclude it.
  modelCode <- nimbleCode({
      ## Likelihood components:
      for(i in 1:N) {
          Y[i] ~ dnorm(mu[i], sd = tau[i]) ## explicitly ask for SD not precision
          ## Check if K (number of fixed location effects) an S (number of fixed scale effecs)
          ## are greater than 1, if not, use simplified computation to avoid indexing issues in nimble
          ## Location
          ## Check if we have more than just an intercept:
          if(K>1) {
              if(Kr>1) {
                  mu[i] <- sum(beta[1:K] * X[i, 1:K]) + sum(u[groupid[i], 1:Kr] * Z[i, 1:Kr])
              } else {
                  mu[i] <- sum(beta[1:K] * X[i, 1:K]) + u[groupid[i], 1]
              }
          } else {
              mu[i] <- beta[1] + u[groupid[i], 1] * Z[i, 1]
          }
          ## Scale
          ## Check if we have more than just an fixed intercept:
          if(S>1) {
              if(Sr>1) {
                  tau[i] <- exp(sum(zeta[1:S] * X_scale[i, 1:S]) + sum(u[groupid[i], (Kr+1):(Kr+Sr)] * Z_scale[i, 1:Sr]))
              } else {
                  tau[i] <- exp(sum(zeta[1:S] * X_scale[i, 1:S]) + u[groupid[i], (Kr+1)])
              }
          } else {
              ## This assumes that if there is only one fixed intercept in scale, there is also exactly one random intercept in scale,
              ## and no other effects
              tau[i] <- exp(zeta[1] + u[groupid[i], (Kr+1)])
          }
      }
      ## Obtain correlated random effects
      for(j in 1:J) {
          ## Bernoulli for Spike and Slab
          for(p in 1:P){
              ss[p, j] ~ dbern(bval[p, 1]) ## bval is a constant
          } 
          ## normal scaling for random effects
          for(k in 1:P){
              z[k, j] ~ dnorm(0, sd = 1)
          }
          ## Transpose L to get lower cholesky
          ## then compute the hadamard (element-wise) product with the ss vector
          ##u[j,1:P] <- t( sigma_rand[1:P, 1:P] %*% L[1:P, 1:P]  %*% z[1:P,j] * ss[1:P,j] )
          u[j, 1:P] <- t( t(U[1:P, 1:P]) %*% z[1:P, j] ) * ss[1:P, j]
      }
      ## Priors:
      ## Fixed effects: Location
      beta[1] ~ dnorm(mean_pred, sd = 3 * sd_pred)
      if (K > 1) {
          for (k in 2:K) {
              beta[k] ~ dnorm(0, sd = 1000) ## TODO might want to add empirical sd
          }
      }
      ## Fixed effects: Scale
      for (s in 1:S) {
          zeta[s] ~ dnorm(0, sd = 3) ## TODO might want to add empirical sd
      }
      ## Random effects SD
      for(p in 1:P){
          ## reconstruct sigma_rand as vector
          sigma_rand[p] ~ T(dt(0, 1, 3), 0, )
      }
      ## Correlations between random effects
      ## Lower cholesky of random effects correlation
      Ustar[1:P, 1:P] ~ dlkj_corr_cholesky(eta = 1, p = P)
      U[1:P, 1:P] <- uppertri_mult_diag(Ustar[1:P, 1:P], sigma_rand[1:P])
      ##
      ##R[1:P, 1:P] <- L[1:P, 1:P]  %*% t(L[1:P, 1:P])
      R[1:P, 1:P] <- t(Ustar[1:P, 1:P]) %*% Ustar[1:P, 1:P]
  })
  ## nocov end

  ## IMPORTANT: future loads the installed library on its workers - changes in the package that are not in the library(ivd)
  ## are not loaded onto the workers! Edits to build_ivd_model / run_MCMC_compiled_model only take effect after reinstalling.
  future::plan(multisession, workers = workers)

  ## One future per chain (workers == chains). Manual futures (rather than
  ## future_lapply) let the main process poll resolved() and render a live
  ## progress line while the workers compile and sample. With `multisession`
  ## the workers are separate processes whose NIMBLE output is buffered and only
  ## relayed on collection; when `progress = TRUE` it is suppressed in-worker so
  ## the live line is the only console output. Results stay deterministic: each
  ## chain's draws are fixed by `runMCMC(setSeed = chain_seeds[x])` plus the
  ## inits, so the future's own `seed = TRUE` (a valid RNG stream) never affects
  ## the draws -- it only silences future's RNG warning.
  quiet <- isTRUE(progress)
  dots <- list(...)
  chain_globals <- list(
      modelCode = modelCode, constants = constants, data = data, inits = inits,
      niter = niter, nburnin = nburnin, WAIC = WAIC, thin = thin,
      return_logLik = return_logLik, quiet = quiet, dots = dots,
      build_ivd_model = build_ivd_model,
      run_MCMC_compiled_model = run_MCMC_compiled_model,
      uppertri_mult_diag = uppertri_mult_diag
  )
  fits <- lapply(seq_len(workers), function(x) {
      future::future(
          {
              run_one <- function() {
                  compiled_model <- build_ivd_model(
                      code = modelCode, constants = constants,
                      dummy_data = data, dummy_inits = inits,
                      useWAIC = WAIC, monitor_pointwise = return_logLik)
                  do.call(run_MCMC_compiled_model,
                          c(list(compiled = compiled_model, seed = chain_seed,
                                 new_data = data, new_inits = inits,
                                 niter = niter, nburnin = nburnin,
                                 useWAIC = WAIC, thin = thin), dots))
              }
              if (quiet) {
                  res <- NULL
                  utils::capture.output(
                      suppressMessages(suppressWarnings(res <- run_one())))
                  res
              } else {
                  run_one()
              }
          },
          seed = TRUE, packages = "nimble",
          globals = c(chain_globals, list(chain_seed = chain_seeds[x]))
      )
  })

  ## Poll the workers in the main process and render a live spinner + elapsed
  ## timer. There is deliberately no "k/workers" bar: chains run in parallel and
  ## finish together, so a fraction bar would sit at 0 then jump to full -- the
  ## spinner/timer honestly signal "working" without implying smooth progress.
  if (isTRUE(progress)) {
      t0 <- Sys.time()
      message("ivd: compiling and sampling ", workers,
              if (workers == 1) " chain" else " chains", " in parallel ...")
      spin <- c("|", "/", "-", "\\")
      tick <- 0L
      repeat {
          done <- sum(vapply(fits, future::resolved, logical(1)))
          tick <- tick + 1L
          cat(.progress_line(workers, t0, spin[(tick - 1L) %% 4L + 1L]))
          utils::flush.console()
          if (done == workers) break
          Sys.sleep(0.4)
      }
      cat("\n")
  }

  ## Collect results: re-throws any worker error, and relays the buffered
  ## NIMBLE output when it was not suppressed (progress = FALSE).
  results <- lapply(fits, future::value)
  
  ## Prepare object to be returned
  out <- list()

  if (!WAIC) {
    ## If WAIC is FALSE, results is a list of matrices.
    ## Transform it into a list of lists, each containing a 'samples' element.
  results <- lapply(results, function(sample_matrix) {
    list(samples = sample_matrix)
  })
}
  mcmc_chains <- lapply(results, as.mcmc)
  combined_chains <- mcmc.list(mcmc_chains)

  ## Number of observations / chains / stored iterations
  N <- length(data$Y)
  chains <- length(combined_chains)
  iterations <- nrow(combined_chains[[1]]$samples)

  ## Pointwise log-likelihood (opt-in): iterations x chains x N. It is the single
  ## largest element of the returned object and is used only for downstream
  ## loo()/by-hand WAIC workflows, so it is built only on request. It needs
  ## `tau`, which is monitored solely under return_logLik = TRUE (build_ivd_model()).
  if (return_logLik) {
    ## Check that mu and tau are of same length, in case grep picks up other variables
    n_mu  <- length(grep("^mu\\[",  colnames(combined_chains[[1]]$samples)))
    n_tau <- length(grep("^tau\\[", colnames(combined_chains[[1]]$samples)))
    if (n_mu != n_tau & n_mu != N) {
        stop("mu and tau are not of same lenght -- check ivd.R")
    }
    ## Collect mu and tau across chains
    mu_combined <- lapply(combined_chains, function(chain) {
      chain$samples[, grep("^mu\\[", colnames(chain$samples)), drop = FALSE]
    })
    tau_combined <- lapply(combined_chains, function(chain) {
      chain$samples[, grep("^tau\\[", colnames(chain$samples)), drop = FALSE]
    })
    ## Initialize the array for log-likelihoods: iterations x chains x N
    logLik_array <- array(NA, dim = c(iterations, chains, N))
    for (chain_idx in 1:chains) {
      for (iter in 1:iterations) {
        ## mu and tau for this iteration/chain, vectors of length N
        mu_values <- mu_combined[[chain_idx]][iter, ]
        tau_values <- tau_combined[[chain_idx]][iter, ]
        logLik_array[iter, chain_idx, ] <- dnorm(data$Y, mean = mu_values, sd = tau_values, log = TRUE)
      }
    }
    out$logLik_array <- logLik_array
  }

  ## Compute Rhats and n_eff:
  ## Exclude the per-observation mu/tau columns from the diagnostics arrays.
  ## summary.ivd() drops them anyway, and copying 2N columns into
  ## samples_array/split_samples (twice) is the bulk of post-processing RAM --
  ## and running the FFT autocorrelation over near-constant mu/tau feeds the
  ## n_eff = "local" crash. Diagnostics are scattered back to full length (with
  ## NA at mu/tau positions) below, so summary.ivd()'s indexing still aligns.
  all_param_names <- colnames(combined_chains[[1]]$samples)
  keep_cols <- grep("^(mu|tau)\\[", all_param_names, invert = TRUE)
  x <- mcmc.list(lapply(combined_chains, FUN = function(x) mcmc(x$samples[, keep_cols, drop = FALSE])))
  ## Extract dimensions
  parameters <- ncol(x[[1]])
  ## Initialize a 3D array
  samples_array <- array(NA, dim = c(iterations, chains, parameters))

  ## Fill the 3D array with the data from the list
  for (i in seq_along(x)) {
    samples_array[, i, ] <- x[[i]]
  }

  if (isTRUE(getOption("ivd.verbose", FALSE)))
      message("Compiling results...")

  ## Split Rhat and split n_eff:
  ## Vehtari et al doi:10.1214/20-BA1221 available at
  ## http://www.stat.columbia.edu/~gelman/research/published/rhat.pdf
  
  ## Initialize a new array with double the chains, half the iterations
  split_samples <- array(NA, dim = c(iterations / 2, chains * 2, parameters))
  
  ## Split each chain into two halves
  for (c in 1:chains) {
    ## First half of the iterations for the first split chain
    split_samples[, (c * 2) - 1, ] <- samples_array[1:(iterations / 2), c, ]
    ## Second half of the iterations for the second split chain
    split_samples[, c * 2, ] <- samples_array[(iterations / 2 + 1):iterations, c, ]
  }

  ## m - number of chains after splitting
  m <- dim(split_samples )[2]
  ## n be the length of th chain
  n <- dim(split_samples )[1]
  s <- m*n

  ## B ingredients
  tdm <- apply(split_samples, 3, function(slice) {
    apply(slice, 2, mean)
    })
  tdd <- colMeans(tdm)  
  
  ## Eq. 3.1
  result <- tdm - matrix(tdd, nrow = nrow(tdm), ncol = ncol(tdm), byrow = TRUE)
  B <- apply(result, 2, function(x) sum(x^2)*n/(m-1))

  ## Eq. 3.2
  W <- apply(split_samples, 3, function(param_samples) {
    chain_variances <- apply(param_samples, 2, function(chain) {
      chain_mean <- mean(chain)
      sum((chain - chain_mean)^2) / (n - 1)  # s2m: Variance for each chain
    })
    mean(chain_variances)  # Average variance across all split chains
  })

  ## Eq. 3.3
  vtp <- (n-1)*W/n + B/n

  ## Compute R-hat
  Rhat <- sqrt(vtp / W)

  if (n_eff == "local") {
      ## Compute split-chain n_eff
      ## ACF is computed using FFT as per Vehtari et al. 
      ## Compute for multiple chains, following eq 10:

      mn_s2m_ptm <- apply(split_samples, 3, function(param_samples) {
          chain_variances <- apply(param_samples, 2, function(chain) {
              chain_mean <- mean(chain)
              sum((chain - chain_mean)^2) / (n - 1)  # s2m: Variance for each chain
          })

          chain_rho <- apply(param_samples, 2, function(samp_per_chain) {
              acf_values <- .autocorrelation_fft(samp_per_chain)
              ## Truncate according to Geyer (1992)
              position <-  min(seq(2:length(acf_values))[acf_values[-length(acf_values)] + acf_values[-1] < 0])
              ## position contains NA for constants, needs to be addressed here:

              if (!is.na(position)) {
                  ## Pad with NA's so that all vectors are of same length. Saves me storing the position object
                  ## pad with NA so that mean() can be calculated over differing rho's per chains
                  rho <- append(acf_values[1:position + 1], rep(NA, length(acf_values) - position), after = position)
              } else {
                  rho <- rep(NA, n)
              }
          })
          
          s2m_rtm <- lapply(seq_along(chain_variances), function(i) {
              chain_variances[i] * chain_rho[,i]
          })
          ## average across chains
          ## Convert list to a matrix
          matrix_form <- do.call(cbind, s2m_rtm)
          avg_s2m_rtm <- rowMeans(matrix_form, na.rm = TRUE)
      })
      
      ## Eq 10: W - mn_s2m_ptm
      numerator <- matrix(W, nrow = nrow(mn_s2m_ptm), ncol = length(W), byrow = TRUE) - mn_s2m_ptm
      rho_t <- 1 - numerator / matrix(vtp, nrow = nrow(numerator), ncol = length(vtp), byrow = TRUE)
      
      n_eff <- round(n * m / (1 + 2 * colSums(rho_t, na.rm = TRUE)))
      
  } else if (n_eff == "stan") {
      ## Based on rstan, takes forever...
      monitor_results <- rstan::monitor(samples_array, print = FALSE)
      n_eff <- monitor_results$n_eff
  }
  
  ## Scatter diagnostics back to full parameter length (NA at the excluded
  ## mu/tau positions) so downstream index-based subsetting stays aligned.
  rhat_full <- stats::setNames(rep(NA_real_, length(all_param_names)), all_param_names)
  neff_full <- stats::setNames(rep(NA_real_, length(all_param_names)), all_param_names)
  rhat_full[keep_cols] <- Rhat
  neff_full[keep_cols] <- n_eff

  ## Extract and print R-hat values
  out$rhat_values <- rhat_full
  if(any(out$rhat_values[!is.na(out$rhat_values)] > 1.1)) warning("Some R-hat values are greater than 1.10 -- increase warmup and/or sampling iterations.")

  ## Effective sample size
  out$n_eff <- neff_full
  
  ## Save the rest to the out object
  out$samples <- combined_chains
  out$nimble_constants <- constants
  out$X_location_names <- colnames(data$X) # save fixed effects names for summary table renaming
  out$X_scale <- data$X_scale
  out$Z_location_names <- colnames(data$Z) # save random effects names for summary table renaming
  out$Z_scale <- data$Z_scale
  ## Location design matrices kept so plot.ivd() can reconstruct the posterior
  ## mean of `mu` from beta + u (mu is no longer monitored). These are O(N x K)
  ## / O(N x Kr) and do not grow with iterations, unlike the dropped mu samples.
  out$X <- data$X
  out$Z <- data$Z
  out$Y <- data.frame("group_id" = group_id, "Y" = data$Y)
  out$workers <- workers
  
  class(out) <- c("ivd", "list")
  return(out)
}
