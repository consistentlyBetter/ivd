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


head(school_dat )


dat <- ivd:::prepare_data_for_nimble(data = school_dat,
                                location_formula = mAch ~ ses * sector +(ses | schoolid),
                                scale_formula =  ~ ses + (1 | schoolid) )



str(dat )
## head(dat[[1]]$X_scale)

dat$data$X_scale
## dat$data$Z
dat$data$Z_scale

## str(dat)

## ## Maybe change this up to location_formula = , and scale_formula = "

## str(dat )

devtools::load_all( )
head(school_dat )


out <- ivd(location_formula = mAch ~  meanses+ses + (ses | schoolid),
           scale_formula =  ~ meanses+ses + (1 + ses | schoolid),
           data = school_dat,
           niter = 1000, nburnin = 2500)


summary(out)
print(out )

codaplot(out, parameter =  "zeta[1]")

plot(out, type = "pip")

plot(out, type = "funnel", variable = "(Intercept)")
plot(out, type = "funnel", variable = "ses")


plot(1:5)
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
