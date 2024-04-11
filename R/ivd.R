##'` Create a function with all the needed code
##' @import nimble

run_MCMC_allcode <- function(seed, data, constants, code, niter, nburnin, useWAIC = TRUE, inits) {
  myModel <- nimbleModel(code = code,
                          data = data,
                          constants = constants,
                          inits = inits)
  CmyModel <- compileNimble(myModel)
  if(useWAIC) 
    monitors <- myModel$getParents(myModel$getNodeNames(dataOnly = TRUE), stochOnly = TRUE)
  ## Note on reversible jump: Does not work here, as only univariate nodes can be used with RJ
  ## Build original model
  myMCMC <- buildMCMC(CmyModel, monitors = c("beta", "zeta", "R", "ss", "sigma_rand")) #monitors)
  CmyMCMC <- compileNimble(myMCMC ) #cmod <- compileNimble(myMCMC )
  ## compile conf containg additinal monitor  with original model
#  CmyMCMC <- compileNimble(compiledMCMC, project = cmod) 
  results <- runMCMC(CmyMCMC, niter = niter, setSeed = seed, nburnin = nburnin)
  return(results)
}

##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title ivd
##' @param location_formula lme4 type formula type 
##' @param scale_formula lme4 type formula type
##' @param data Data in long format
##' @param niter Number of iterations after burnin
##' @param nburnin Number of burnin. Defaults to the same amount as niter (i.e,. with niter = 5000, nburnin is also 5000). 
##' @param ... not defined
##' @return An object of type \code{ivd}.
##' @author Philippe Rast
##' @importFrom  nimble nimbleCode nimbleModel compileNimble buildMCMC runMCMC
##' @import parallel
##' @importFrom coda as.mcmc mcmc.list
##' @importFrom stats update
##' @export

ivd <- function(location_formula, scale_formula, data, niter, nburnin = NULL, ...) {
  if(is.null(nburnin)) {
    nburnin <- niter
  }
  ## In nimble, niter is total amount of iterations, including burnin.
  ## Here, niter is iterations after burnin. 
  niter <- niter + nburnin
  
  dat <- prepare_data_for_nimble(data = data,
                                 location_formula = location_formula,
                                 scale_formula = scale_formula )
  data <- dat[[1]]
  groups <- dat$groups
  group_id <- dat$group_id
  
  modelCode <- nimbleCode({
    ## Likelihood components:
    for(i in 1:N) {
      Y[i] ~ dnorm(mu[i], sd = tau[i]) ## explicitly ask for SD not precision
      ## Check if K (number of fixed location effects) an S (number of fixed scale effecs)
      ## are greater than 1, if not, use simplified computation to avoid indexing issues in nimble
      ## Location
      if(K>1) {
        mu[i] <- sum(beta[1:K] * X[i, 1:K]) + sum( u[groupid[i], 1:Kr] * Z[i, 1:Kr] )
      } else {
        mu[i] <- beta[1] + u[groupid[i], 1]        
      }
      ## Scale
      if(S>1) {
        if(Sr>1) {
          tau[i] <- exp( sum(zeta[1:S] * X_scale[i, 1:S]) + sum(u[groupid[i], (Kr+1):(Kr+Sr)] * Z_scale[i, 1:Sr]) )  
        } else {
         tau[i] <- exp( sum(zeta[1:S] * X_scale[i, 1:S]) + u[groupid[i], (Kr+1)] ) 
        }
      } else {
        ## This assumes that if there is only one fixed interceptin scale, there is also exactly one random intercept in scale,
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
      sigma_rand[p,p] ~ dgamma(1,3)
    }
    ## Lower cholesky of random effects correlation 
    L[1:P, 1:P] ~ dlkj_corr_cholesky(eta = 1, p = P)
    ##
    R[1:P, 1:P] <- t(L[1:P, 1:P] ) %*% L[1:P, 1:P]
  })

  ## Nimble constants
  constants <- list(N = length(data$Y),
                    J = groups,
                    K = ncol(data$X),  ## number of fixed location effects
                    Kr = ncol(data$Z), ## number of fixed random effects
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

  ## parallelization
  nc <- parallel::detectCores( )
  this_cluster <- makeCluster(nc)
  useWAIC <- TRUE
 ##  ## THIS SHOULD NOT BE NECESSARY WITHIN A PACKAGE
## # Assuming 'this_cluster' is already defined as your cluster object
##                                         # Load 'nimble' on each worker
   clusterEvalQ(cl = this_cluster, {
     library(nimble)
   })
##   ## END

  chain_output <- parLapply(cl = this_cluster, X = 1:4, 
                            fun = run_MCMC_allcode, 
                            data = data, constant = constants, inits = inits, code = modelCode, niter = niter, nburnin = nburnin,
                            useWAIC = useWAIC)

  ## It's good practice to close the cluster when you're done with it.
  stopCluster(this_cluster)

  out <- list()

  mcmc_chains <- lapply(chain_output, as.mcmc)
  combined_chains <- mcmc.list(mcmc_chains)
  
  out$samples <- combined_chains
  out$nimble_constants <- constants

  #out <- chain_output
  class(out) <- c("ivd", "list")
  return( out )
}
