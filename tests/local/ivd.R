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


# Define constants and data for the model
data <- list(Y = school_dat$mAch,
             X = cbind(1, school_dat$ses), ## Location design matrix
             Z = cbind(1, school_dat$ses)) ## Scale design matrix

groups <- length(unique(school_dat$schoolid))
group_id <- school_dat$schoolid  # Full N length id ordered ID vector



prepare_data_for_nimble <- function(data, location_formula, scale_formula) {
  ## Helper function to prepare model parts
  prepare_model_part <- function(data, formula, is_scale_model = FALSE) {
    ## Parse the formula to get response and predictors
    response_var <- if(is_scale_model) NA else all.vars(formula)[1]

    fixed_effects <- strsplit(deparse(formula ), split = "\\+ \\(", perl = TRUE)[[1]][1]
    ## slplit out random effects, first split contains grouping variable
    random_effects_F <- strsplit(deparse(formula ), split = "\\+ \\(", perl = TRUE)[[1]][2]
    ## split at | 
    random_effects <- strsplit(random_effects_F, split = "\\|", perl = TRUE)[[1]][1]
    
    predictors <- all.vars(formula)[-length(formula)]
    if (!is_scale_model) {
      predictors <- predictors[-1]  # Exclude the response variable for location model
    }

    ## Creating X matrix
    X_formula <- update.formula(formula, paste("~", paste(predictors, collapse = "+")))
    X_matrix <-  model.matrix(X_formula, data)
    
    ## For Z, random effects predictors
    Z_matrix <- if(length(predictors) > 0 ) {
                  model.matrix( formula( paste("~", paste(random_effects, collapse = "+")) ), data)
                } else {
                  stop("Empty model?")
                }
    Z_matrix
    list(X = X_matrix, Z = Z_matrix) # Adjusting for intercept
  }
  
  ## Extracting the grouping variable from the location formula
  location_formula_string <- deparse(location_formula)
  grouping_variable_match <- regmatches(location_formula_string, regexec("\\|\\s*(\\w+)", location_formula_string))
  if (length(grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the location formula.")
  }
  grouping_variable <- grouping_variable_match[[1]][2]
  ## Extracting the grouping variable from the scale formula
  ## Only support models where grouping variable is the same for location and scale
  scale_formula_string <- deparse(scale_formula)
  scl_grouping_variable_match <- regmatches(scale_formula_string, regexec("\\|\\s*(\\w+)", scale_formula_string))
  if (length(scl_grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the scale formula.")
  }
  ## Check that both location and scale have same grouping variable
  if(grouping_variable != scl_grouping_variable_match[[1]][2]) {
    stop("Location and scale grouping variable needs to be the same.")
  }
    
  ## Ensure the grouping variable is numeric
  if(!is.numeric(data[[grouping_variable]])) {
    data[[grouping_variable]] <- as.numeric(as.factor(data[[grouping_variable]]))
  }
  ## Ensure that grouping variable is a continuous sequence without any missing values
  if( !identical(  seq_len( max(unique(data[[grouping_variable]])) ),
                 as.integer( sort(unique(data[[grouping_variable]])))) ) {
    stop("Grouping variable is not a sorted and continuous index.")
  }
  
  ## Processing location and scale models
  location_data <- prepare_model_part(data, location_formula)
  scale_formula_cleaned <- gsub("sigma = ", "", deparse(scale_formula))  # Remove "sigma = " if present
  scale_data <- if(!is.null(scale_formula_cleaned) && nzchar(scale_formula_cleaned)) {
                  prepare_model_part(data, as.formula(paste(scale_formula_cleaned)), TRUE)
  } else {
    list(X = NULL, Z = NULL)
  }
  
  # Assemble the data structure for NIMBLE
  list(data = list(
         Y = data[[all.vars(location_formula)[1]]],  # Assuming the first variable is the response
         X = location_data$X, 
         Z = location_data$Z, 
         X_scale = scale_data$X, 
         Z_scale = scale_data$Z
       ), 
       groups = length(unique(data[[grouping_variable]])), 
       group_id = data[[grouping_variable]]
  )
}


dat <- ivd:::prepare_data_for_nimble(data = school_dat,
                               location_formula = mAch ~ ses * sector +(ses | schoolid),
                               scale_formula =  ~ ses*sector + (ses | schoolid) )

head(dat[[1]]$X_scale)

data$X
data$Z
dat$data$X
dat$data$X_scale
dat$data$Z
dat$data$Z_scale

str(dat)

## Maybe change this up to location_formula = , and scale_formula = "

str(dat )

devtools::load_all( )
head(school_dat )

out <- ivd(location_formula = mAch ~ ses * sector + (ses | schoolid),
           scale_formula =  ~ ses *sector + (ses | schoolid),
           data = school_dat,
           niter = 2000)


class( out )

str(out[[2]])
out[[2]]$data$X

colMeans(out[[1]][[1]][,1:10])
samplesSummary(out[[1]][[1]])


colMeans(out[[1]][,1:10] )

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
