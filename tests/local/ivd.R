devtools::load_all( )

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
