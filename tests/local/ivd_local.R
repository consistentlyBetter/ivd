devtools::load_all( )

library(mlmRev)


school_dat = mlmRev::Hsb82

## Ensure that school id is a continuous vector
school_dat$schoolid <- NA
k <- 0
for( i in unique(school_dat$school) ) {
  k <- k+1
  school_dat[school_dat$school == i, "schoolid"] <- k
}


## head(school_dat )


## dat <- ivd:::prepare_data_for_nimble(location_formula = mAch ~  meanses+ (1 | schoolid),
##                                      scale_formula =  ~ meanses + (1  | schoolid),
##                                      data = school_dat)


## str(dat )
## ## head(dat[[1]]$X_scale)
## colnames(dat$data$X)
## colnames(dat$data$X_scale)
## data <- dat[[1]]
## colnames(data$X_scale)

## attributes(dat$data$Y)
## dat$data$X_scale
## dat$data$Z
## dat$data$Z_scale

## ## str(dat)

## ## ## Maybe change this up to location_formula = , and scale_formula = "

## ## str(dat )

## devtools::load_all( )
## head(school_dat )


## head(school_dat )
school_dat$mAch_s <- scale(school_dat$mAch,  center = TRUE,  scale = TRUE )
## str(school_dat$mAch_s)
## str(unclass(school_dat$mAch_s))
## str(c(school_dat$mAch_s))
## str(school_dat$mAch)

school_dat$ses_s <- scale(school_dat$ses)
# nrow(school_dat )


## location_formula = mAch_s ~  meanses + ( 1 | schoolid)
## scale_formula =  ~ meanses  + (1 | schoolid)
## data = school_dat
## thin = 1
## niter = 1000
## nburnin = 1000
## WAIC = TRUE
## workers = 4
## seed <- 123

system.time({
    out <- ivd(
        location_formula = mAch_s ~ 1 + (1 | schoolid),
        scale_formula = ~ 1 + (1 | schoolid),
        data = school_dat,
        niter = 1000, nburnin = 500, WAIC = FALSE, workers = 4, n_eff = "local"
    )
})
summary(out )
codaplot(out, parameters = "Intc")


out$Z_location_names
summary(out, pip = 'model')

summary(out )

## ## Investigate if ss biases correlations (it does not)
## ## To do this, add "L" to monitor in the config$addMonitors in nimble
## str(out$samples)
## grep( "L", colnames(out$samples[[1]]$samples))
## colnames(out$samples[[1]]$samples)[1:4]
## out$samples[[1]]$samples[,3]

## ss2pos <- grep( "ss\\[2,", colnames(out$samples[[1]]$samples))
## colnames(out$samples[[1]]$samples)[7200:7210]
## ss2 <- out$samples[[1]]$samples[,ss2pos]

## unweightedR <- apply(out$samples[[1]]$samples[,1:4], 1, function(x ) {
##   L <- matrix(x, ncol = 2)
##   R <- t(L)%*%L
##   R[1,2]
##   })

## mean(unweightedR)
## weighted <- mean(unlist(lapply(1:160, function(i) sum(unweightedR*ss2[,i])/sum(ss2[,i]) )))
## weighted
## ## Practically now difference among estimates if we only use ss==1 samples or all of them

r_eff <- loo::relative_eff( exp( out$logLik_array ) )
m1 <- loo::loo(out$logLik_array, r_eff = r_eff)



out2 <- ivd(location_formula = mAch_s ~  meanses + ses_s + ( 1 | schoolid),
           scale_formula =  ~ meanses  + ses_s + (1 | schoolid),
           data = school_dat,
           niter = 2000, nburnin = 8000, WAIC = TRUE, workers = 6)

r_eff <- loo::relative_eff( exp( out2$logLik_array ) )
m2 <- loo::loo(out2$logLik_array, r_eff = r_eff)

loo::loo_compare(m1,  m2 )


str(out)

codaplot(out, parameters =  "zeta[1]")

plot(out, type = "pip")

plot(out, type = "funnel", variable = "(Intercept)")
plot(out, type = "funnel", variable = "ses_s")


dev.off( )

stats <-
  out$samples[[1]]



library(plotly )
df_funnel

# Assuming 'df_funnel' is your data frame and it is already loaded
# Create a 3D scatter plot
plot <- plot_ly(data = df_funnel, x = ~log(tau2), y = ~log(tau), z = ~pip, type = 'scatter3d', mode = 'markers',
                marker = list(size = 5, color = df_funnel$pip, colorscale = 'Viridis', opacity = 0.8)) %>%
        layout(title = "3D Plot of pip, tau2, and tau",
               scene = list(xaxis = list(title = 'tau2'),
                            yaxis = list(title = 'tau'),
                            zaxis = list(title = 'pip')))

# If running in an interactive R environment, this will display the plot.
plot



## Plot without burnin
plot(out$samples[, c( "zeta[1]", "zeta[2]", "beta[1]", "beta[2]")] )
plot(out$samples[, c( "beta[3]", "beta[4]", "R[2, 1]" ,"R[3, 1]")] )
plot(out$samples[, c( "sigma_rand[1, 1]", "sigma_rand[2, 2]", "sigma_rand[3, 3]")] )

devtools::load_all( )


coda::
codaplot(out, parameters = "beta[1]")

colnames(out$samples[[1]] )



## Plot DEVEL








## Random efct standard dev:
## Init:
cols_to_keep <- c( )
## Find spike and slab variables
col_sigma_rand <- col_names[ grepl( "^tau\\[", col_names ) ]

for(col_name in col_sigma_rand) {
  elements <- as.numeric(unlist(regmatches(col_name, gregexpr("[0-9]+", col_name))))
  if(elements[1] == elements[2]) {
    cols_to_keep <- c(cols_to_keep,  col_name )
  }
}

cols_to_keep

## Subset each MCMC matrix to keep only the relevant columns
subsamples <- lapply(out$samples, function(x) x[, cols_to_keep])

## Calculate column means for each subsetted MCMC matrix
quantile_list <- lapply(subsamples, function(x) quantile(x, c(0.025, 0.5, .975)) )
quantile_list

##  Aggregate these means across all chains
# This computes the mean of means for each column across all chains
final_quantile <- Reduce("+", quantile_list) / length(quantile_list)












library(ggplot2)
library(data.table )

## Convert the mcmc.list object to a data.table
mcmc_list <- out$samples


dt_mcmc <- data.table(iter = seq_len(nrow(mcmc_list[[1]])),
                      chain = rep(1:length(mcmc_list), each = nrow(mcmc_list[[1]])),
                      parameter = rep(colnames(mcmc_list[[1]]), times = length(mcmc_list)),
                      value = as.vector(as.matrix(mcmc_list)))

keep_columns <- colnames(mcmc_list[[1]]) %in% ss_param

dt_mcmc <- data.table(
  iter = rep(seq_len(nrow(mcmc_list[[1]])), times = length(mcmc_list) * sum(keep_columns)),
  chain = rep(1:length(mcmc_list), each = nrow(mcmc_list[[1]])) %>% rep(times = sum(keep_columns)),
  parameter = rep(colnames(mcmc_list[[1]])[keep_columns], times = length(mcmc_list)),
  value = as.vector(sapply(mcmc_list, function(x) as.matrix(x[, keep_columns, drop = FALSE])))
)

setorder(dt_mcmc, chain, iter)

dt_mcmc

# Plotting using ggplot2
ggplot(data = dt_mcmc[parameter == "ss[1, 124]" & chain == 1], aes(x = iter, y = value, group = chain, colour = as.factor(chain))) +
  geom_line() +
  theme_minimal() +
  labs(title = "Trace Plot for zeta[1]",
       x = "Iteration",
       y = "Value",
       colour = "Chain") +
  scale_color_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3")) # Example colors


dt_mcmc
xtmp <- dt_mcmc[parameter == "zeta[1]", c("iter", "chain", "value", "parameter")]
setorder(xtmp, chain, iter)

plot(xtmp$iter, xtmp$value, type = 'l')


## gelman.diag function from coda package
x <- mcmc.list(extract_samples)[, rownames(sm)]
function (x, confidence = 0.95, transform = FALSE, autoburnin = TRUE, 
    multivariate = TRUE) 
{
  x <- as.mcmc.list(x)
  str(x)
  rstan::monitor(x )
  
    if (nchain(x) < 2) 
      stop("You need at least two chains")

    start(x )
    autoburnin(FALSE )
    
    if (autoburnin && start(x) < end(x)/2) 
        x <- window(x, start = end(x)/2 + 1)
    Niter <-  niter(x)
    Nchain <-  nchain(x)
    Nvar <- nvar(x)
    xnames <-
      varnames(x)
    #if (transform) 
    #    x <- gelman.transform(x)
    x <- lapply(x, as.matrix)
    str(x )

    S2 <- array(sapply(x, var, simplify = TRUE), dim = c(Nvar, 
                                                         Nvar, Nchain))
    str(S2 )
    W <- apply(S2, c(1, 2), mean)
    str(W )
    round(W, 32)
    xbar <- matrix(sapply(x, apply, 2, mean, simplify = TRUE), 
                   nrow = Nvar, ncol = Nchain)
    str(xbar )

    B <- Niter * var(t(xbar))

    if (Nvar > 1 && multivariate) {
        if (is.R()) {
          CW <-
            chol(W)
            emax <- eigen(backsolve(CW, t(backsolve(CW, B, transpose = TRUE)), 
                transpose = TRUE), symmetric = TRUE, only.values = TRUE)$values[1]
        }
        else {
            emax <- eigen(qr.solve(W, B), symmetric = FALSE, 
                only.values = TRUE)$values
        }
        mpsrf <- sqrt((1 - 1/Niter) + (1 + 1/Nvar) * emax/Niter)
    }
    else mpsrf <- NULL
    w <- diag(W)
    b <- diag(B)
    s2 <- matrix(apply(S2, 3, diag), nrow = Nvar, ncol = Nchain)
    muhat <- apply(xbar, 1, mean)
    var.w <- apply(s2, 1, var)/Nchain
    var.b <- (2 * b^2)/(Nchain - 1)
    cov.wb <- (Niter/Nchain) * diag(var(t(s2), t(xbar^2)) - 2 * 
        muhat * var(t(s2), t(xbar)))
    V <- (Niter - 1) * w/Niter + (1 + 1/Nchain) * b/Niter
    var.V <- ((Niter - 1)^2 * var.w + (1 + 1/Nchain)^2 * var.b + 
        2 * (Niter - 1) * (1 + 1/Nchain) * cov.wb)/Niter^2
    df.V <- (2 * V^2)/var.V
    df.adj <- (df.V + 3)/(df.V + 1)
    B.df <- Nchain - 1
    W.df <- (2 * w^2)/var.w
    R2.fixed <- (Niter - 1)/Niter
    R2.random <- (1 + 1/Nchain) * (1/Niter) * (b/w)
    R2.estimate <- R2.fixed + R2.random
    R2.upper <- R2.fixed + qf((1 + confidence)/2, B.df, W.df) * 
        R2.random
    psrf <- cbind(sqrt(df.adj * R2.estimate), sqrt(df.adj * R2.upper))
    dimnames(psrf) <- list(xnames, c("Point est.", "Upper C.I."))
    out <- list(psrf = psrf, mpsrf = mpsrf)
    class(out) <- "gelman.diag"
    out


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

# Now you can use the monitor function from rstan
library(rstan)
monitor_results <- rstan::monitor(samples_array, print = FALSE)

# Extract and print R-hat values
rhat_values <- monitor_results[, "Rhat"]
print(rhat_values)


  library(covr )

  coverage  <- covr::package_coverage( )
  print(coverage )



## Run README examle:
devtools::load_all( )
library(data.table)
 ## Grand mean center student SES
#saeb$student_ses <- c(scale(saeb$student_ses, scale = FALSE))

## Calculate school-level SES
school_ses <- saeb[, .(school_ses = mean(student_ses, na.rm = TRUE)), by = school_id]

## Join the school_ses back to the original dataset
saeb <- saeb[school_ses, on = "school_id"]

## Define student level SES as deviation from the school SES
saeb$student_ses <- saeb$student_ses - saeb$school_ses

## Grand mean center school ses
saeb$school_ses <- c(scale(saeb$school_ses, scale = FALSE))
  
out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1|school_id),
           scale_formula =  ~ student_ses * school_ses + (1 |school_id),
           data = saeb,
           niter = 3000, nburnin = 5000, WAIC = TRUE, workers = 6)

summary(out)

### Simulated data --------------------------------------------------------
devtools::load_all()

## Sample size
n_students = 80
n_schools = 160

## School data
N <- n_students * n_schools
school_id <- rep(1:n_schools, each = n_students)

# Random effects' diagonal SD matrix
tau <- matrix(
  c(0.3, 0,
    0, 0.1), 2, 2)

## Random effects' correlation matrix
R <- matrix(c(
  1, 0.5,
  0.5, 1), 2, 2)

## Random effects' covariance matrix
Sigma <- tau %*% R %*% t(tau)

## Random effects
u <- MASS::mvrnorm(
             n = n_schools,
             mu = c(0, 0), Sigma
           )


## Location model components
loc_rand_intc <- u[, 1][school_id]
linpred <- 0 + loc_rand_intc

 ## Scale model components
scl_rand_intc <- u[, 2][school_id]
school_sd  <- exp(0 + scl_rand_intc)

y_residuals <- rnorm(N, 0, school_sd)

y <- linpred + y_residuals

school_dat <- data.frame(
  y = y,
  school_id = school_id
)

  ## A correlation of 0.5 between the random effects is expected

out <- ivd(
        location_formula = y ~ 1 + (1 | school_id),
        scale_formula = ~ 1 + (1 | school_id),
        data = school_dat,
        niter = 5000, nburnin = 2500, WAIC = FALSE, workers = 4, n_eff = "local"
)

summary(out, pip = "model")
