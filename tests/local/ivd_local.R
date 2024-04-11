devtools::load_all( )

library(mlmRev)



school_dat = mlmRev::Hsb82

school_dat$y <- c(scale(school_dat$mAch))
school_dat$intercept <- 1


school_dat$schoolid <- NA
k <- 0
for( i in unique(school_dat$school) ) {
  k <- k+1
  school_dat[school_dat$school == i, "schoolid"] <- k
}



dat <- ivd:::prepare_data_for_nimble(data = school_dat,
                                location_formula = mAch ~ ses * sector +(ses | schoolid),
                                scale_formula =  ~ ses + (1 | schoolid) )

str(dat )
## head(dat[[1]]$X_scale)

## data$X
## data$Z
## dat$data$X
dat$data$X_scale
## dat$data$Z
dat$data$Z_scale

## str(dat)

## ## Maybe change this up to location_formula = , and scale_formula = "

## str(dat )

devtools::load_all( )
head(school_dat )

out <- ivd(location_formula = mAch ~ ses * sector + (ses | schoolid),
           scale_formula =  ~ ses + (1 | schoolid),
           data = school_dat,
           niter = 1500, nburnin = 1500)

str(out)
class(out)

summary(out)
print(out )







## Plot without burnin
plot(out$samples[, c( "zeta[1]", "zeta[2]", "beta[1]", "beta[2]")] )
plot(out$samples[, c( "beta[3]", "beta[4]", "R[2, 1]" ,"R[3, 1]")] )
plot(out$samples[, c( "sigma_rand[1, 1]", "sigma_rand[2, 2]", "sigma_rand[3, 3]")] )




colMeans(out[[1]][,1:10])

colMeans(out[[1]][,35:42] )
str(out )



d <- mlmRev::Hsb82

head(d)
d$y <- c(scale(d$mAch))
system.time( {
  alpha <- ivd_alpha(y = d$y, unit = d$school)
})
## 34 second, down to 9 sec

names(alpha$posterior_samples)

alpha$model_text



posterior_summary(alpha, ci = 0.90, digits = 2)

print(alpha$call)
caterpillar_plot( alpha, legend = FALSE)

pip_plot( alpha ,  legend = FALSE)


beta <- ivd_beta(y = d$y, X = d$ses, unit = d$school)
ranef_summary(beta)



caterpillar_plot(beta, legend =  FALSE)

##
jags_data <- list(y = d$y,
                  unit =  d$school,
                  N = length(d$y)
                  J = length(unique(d$school)),
                  n_j = )


jags_data <- alpha$data_list
jags_data

parameters <- c("s_alpha_0", "s_alpha_0_j", "gamma")

#setwd("./tests/local/" )
library(R2jags)
fit <- jags.parallel(jags_data, parameters.to.save = parameters, model.file = "model.bug",
                     n.iter = 1000)

fit

textConnection( alpha$model_text )

model_text <- ivd:::make_model_text_alpha(priors_list = ivd:::make_default_priors_alpha( ))

write(moda,
      file = "model.bug")

vars2monitor = c("alpha", "gamma", "sigma", "tau", "theta")

fit <- jags.parallel(jags_data,
                     parameters.to.save = vars2monitor,
                     model.file = jags_tempfile,
                     n.iter = 2000)
data_list <- alpha$data_list

floor(11/2)

tempdir()

coda.samples(fit,  variable.names = vars2monitor )

fit$BUGSoutput

mcmc_list <- as.mcmc(fit )
str(mcmc_list )

do.call(rbind.data.frame, mcmc_list)
