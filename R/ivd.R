##'` Create a function with all the needed code
##' @import nimble

run_MCMC_allcode <- function(seed, data, constants, code, niter = 5000, useWAIC = TRUE, inits) {
  myModel <- nimbleModel(code = code,
                          data = data,
                          constants = constants,
                          inits = inits)
  CmyModel <- compileNimble(myModel)
  if(useWAIC) 
    monitors <- myModel$getParents(myModel$getNodeNames(dataOnly = TRUE), stochOnly = TRUE)
  ## Note on reversible jump: Does not work here, as only univariate nodes can be used with RJ
  ## Build original model
  myMCMC <- buildMCMC(CmyModel, monitors = c("beta", "zeta", "R", "ss")) #monitors)
  CmyMCMC <- compileNimble(myMCMC ) #cmod <- compileNimble(myMCMC )
  ## compile conf containg additinal monitor  with original model
#  CmyMCMC <- compileNimble(compiledMCMC, project = cmod) 
  results <- runMCMC(CmyMCMC, niter = niter, setSeed = seed, nburnin = 1000)
  return(results)
}

##' ivd
##'
##' @param data list of data objects
##' @param groups Number of groups (clusters)
##' @param group_id Vector of length N with sequentially ordered group id's

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
#' @return An object of type \code{ivd}.
#'
#' @importFrom  nimble nimbleCode nimbleModel compileNimble buildMCMC runMCMC
#' @import parallel
#' @importFrom coda as.mcmc
#' @importFrom stats update
#' @export

ivd <- function(data,  groups,  group_id, niter) {
  modelCode <- nimbleCode({
    ## Likelihood components:
    for(i in 1:N) {
      Y[i] ~ dnorm(mu[i], sd = tau[i]) ## explicitly ask for SD not precision
      ## Check if K an S are greater than 1, if not, use simplified computation to avoid indexing issues in nimble
      if(K>1) {
        mu[i] <- sum(beta[1:K] * X[i, 1:K]) + sum(u[groupid[i], 1:K] * X[i, 1:K])
      } else {
        mu[i] <- beta[1] + u[groupid[i], 1]        
      }
      if(S>1) {
        tau[i] <- exp( sum(zeta[1:S] * Z[i, 1:S]) + sum(u[groupid[i], (K+1):(K+S)] * Z[i, 1:S]) )
      } else {
        tau[i] <- exp( zeta[1] + u[groupid[i], (K+1)]  )        
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
                    S = ncol(data$Z),  ## number of fixed scale effects
                    P = ncol(data$X) + ncol(data$Z),  ## number of random effects
                    groupid = group_id,
                    bval = matrix(c(rep(1,  ncol(data$X)), rep(0.5, ncol(data$Z)) ), ncol = 1)) ## Prior probability for dbern 
  ## Nimble inits
  inits <- list(beta = rnorm(constants$K, 5, 10),
                zeta =  rnorm(constants$S, 1, 3),
                sigma_rand = diag(rlnorm(constants$P, 0, 1)),
                L = diag(1,constants$P) )

  ## parallelization
  nc <- parallel::detectCores( )
  this_cluster <- makeCluster(nc)
  useWAIC <- TRUE
  ## THIS SHOULD NOT BE NECESSARY WITHIN A PACKAGE
# Assuming 'this_cluster' is already defined as your cluster object
                                        # Load 'nimble' on each worker
  clusterEvalQ(cl = this_cluster, {
    library(nimble)
  })
  ## END

  chain_output <- parLapply(cl = this_cluster, X = 1:4, 
                            fun = run_MCMC_allcode, 
                            data = data, constant = constants, inits = inits, code = modelCode, niter = niter,
                            useWAIC = useWAIC)

  ## It's good practice to close the cluster when you're done with it.
  stopCluster(this_cluster)
  class(chain_output) <- c("ivd", "list")
  return(chain_output)
}
