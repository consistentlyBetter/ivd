##' Create a function to be loaded on each worker.
##' This function needs to be exported for `future` to be able to load it.
##' @param seed Inherits from ivd  
##' @param data Inherits from ivd
##' @param constants Inherits from ivd
##' @param code Inherits from ivd
##' @param niter Inherits from ivd
##' @param nburnin Inherits from ivd
##' @param useWAIC Inherits from ivd
##' @param inits Inherits from ivd
##' @param additional_monitors Inherits from ivd
##' @import nimble
##' @export
run_MCMC_allcode <- function(seed, data, constants, code, niter, nburnin, useWAIC = WAIC, inits, additional_monitors = "NULL") {
  myModel <- nimble::nimbleModel(code = code,
                          data = data,
                          constants = constants,
                          inits = inits)
  cmpModel <- nimble::compileNimble(myModel)

  config <- nimble::configureMCMC(myModel)
  config$enableWAIC <- useWAIC
  config$monitors <- c("beta", "zeta", "R", "ss", "sigma_rand", "u")
  
  myMCMC <- nimble::buildMCMC(config)
  compMCMC <- nimble::compileNimble(myMCMC, project = cmpModel)
  
  results <- nimble::runMCMC(compMCMC, niter = niter, setSeed = seed, nburnin = nburnin, WAIC = useWAIC)
  
  return(results)
}


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
#' @param ... Currently not used
#' @import future
#' @importFrom future.apply future_lapply
#' @importFrom coda as.mcmc mcmc.list
#' @importFrom nimble nimbleCode nimbleModel compileNimble buildMCMC runMCMC
#' @importFrom rstan monitor
#' @importFrom stats as.formula model.matrix rlnorm rnorm update.formula
#' @importFrom utils head str
#' @export 
ivd <- function(location_formula, scale_formula, data, niter, nburnin = NULL, WAIC = TRUE, workers = 4,...) {
  if(is.null(nburnin)) {
    nburnin <- niter
  }
  niter <- niter + nburnin
  
  dat <- prepare_data_for_nimble(data = data, location_formula = location_formula, scale_formula = scale_formula)
  data <- dat[[1]]
  groups <- dat$groups
  group_id <- dat$group_id

  ## Nimble part:
  ## Nimble constants
  constants <- list(N = length(data$Y),
                    J = groups,
                    K = ncol(data$X),  ## number of fixed location effects
                    Kr = ncol(data$Z), ## number of random location effects
                    S = ncol(data$X_scale),  ## number of fixed scale effects
                    Sr = ncol(data$Z_scale),  ## number of random scale effects                    
                    P = ncol(data$Z) + ncol(data$Z_scale),  ## number of random effects
                    groupid = group_id,
                    bval = matrix(c(rep(1,  ncol(data$Z)), rep(0.5, ncol(data$Z_scale)) ), ncol = 1)) ## Prior probability for dbern 
  ## Nimble inits
  inits <- list(beta = rnorm(constants$K, 5, 10),
                zeta =  rnorm(constants$S, 1, 3),
                sigma_rand = diag(rlnorm(constants$P, 0, 1)),
                L = diag(1,constants$P) )


  
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
          mu[i] <- sum(beta[1:K] * X[i, 1:K]) + sum( u[groupid[i], 1:Kr] * Z[i, 1:Kr] )
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
          tau[i] <- exp( sum(zeta[1:S] * X_scale[i, 1:S]) + sum(u[groupid[i], (Kr+1):(Kr+Sr)] * Z_scale[i, 1:Sr]) )  
        } else {
          tau[i] <- exp( sum(zeta[1:S] * X_scale[i, 1:S]) + u[groupid[i], (Kr+1)] ) 
        }
      } else {
        ## This assumes that if there is only one fixed intercept in scale, there is also exactly one random intercept in scale,
        ## and no other effects
        tau[i] <- exp( zeta[1] + u[groupid[i], (Kr+1)] )
      }
    }
    ## Obtain correlated random effects
    for(j in 1:J) {
      ## Bernoulli for Spike and Slab
      for(p in 1:P){
        ss[p,j] ~ dbern(bval[p,1]) ## bval is a constant
      }    
      ## normal scaling for random effects
      for( k in 1:P ){
        z[k,j] ~ dnorm(0,1)
      }
      ## Transpose L to get lower cholesky
      ## then compute the hadamard (element-wise) product with the ss vector
      u[j,1:P] <- t( sigma_rand[1:P, 1:P] %*% L[1:P, 1:P]  %*% z[1:P,j] * ss[1:P,j] )
    }
    ## Priors:
    ## Fixed effects: Location
    for (k in 1:K) {
      beta[k] ~ dnorm(0, 0.0001)
    }
    ## Fixed effects: Scale
    for (s in 1:S) {
      zeta[s] ~ dnorm(0, 0.0001)
    }  
    ## Random effects SD
    for(p in 1:P){
      sigma_rand[p,p] ~ T(dt(0, 1, 3), 0, )
    }
    ## Lower cholesky of random effects correlation 
    L[1:P, 1:P] ~ dlkj_corr_cholesky(eta = 1, p = P)
    ##
    R[1:P, 1:P] <- t(L[1:P, 1:P] ) %*% L[1:P, 1:P]
  })

 
  future::plan(multisession, workers = workers)

  results <- future_lapply(1:workers, function(x) run_MCMC_allcode(x, data, constants, modelCode, niter, nburnin, TRUE, inits, WAIC),
                           future.seed = TRUE, future.packages = c("nimble"))
  

  ## Prepare object to be returned
  out <- list()
  mcmc_chains <- lapply(results, as.mcmc)
  combined_chains <- mcmc.list(mcmc_chains)

  ## Compute R hats:
  x <- mcmc.list( lapply(combined_chains, FUN = function(x) mcmc(x$samples)) )
  ## Extract dimensions
  iterations <- nrow(x[[1]])
  parameters <- ncol(x[[1]])
  chains <- length(x)
  ## Initialize a 3D array
  samples_array <- array(NA, dim = c(iterations, chains, parameters))

  ## Fill the 3D array with the data from the list
  for (i in seq_along(x)) {
    samples_array[, i, ] <- x[[i]]
  }
  ## Use the monitor function from rstan to obtain Rhat (coda's gelman.rhat does not work reliably)
  monitor_results <- rstan::monitor(samples_array, print = FALSE)
  ## Extract and print R-hat values
  out$rhat_values <- monitor_results[, "Rhat"]
  if( any(out$rhat_values > 1.1) ) warning("Some R-hat values are greater than 1.10 -- increase warmup and/or sampling iterations." )
  
  out$samples <- combined_chains
  out$nimble_constants <- constants
  out$X_scale <- data$X_scale
  out$Z_scale <- data$Z_scale
  out$workers <- workers
  
  class(out) <- c("ivd", "list")
  return(out)
  }
