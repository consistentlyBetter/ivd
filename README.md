
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- knit with rmarkdown::render("README.Rmd", output_format = "md_document") -->

# Individual Variance Detection

<!-- badges: start -->

[![R-CMD-check](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/consistentlyBetter/ivd/graph/badge.svg?token=SD0PM5BVIL)](https://codecov.io/gh/consistentlyBetter/ivd)
<!-- badges: end -->

*ivd* is an R package for random effects selection in the scale part of
Mixed Effects Location Scale Modlels (MELSM). `ivd()` fits a random
intercepts model with a spike-and-slab prior on the random effects of
the scale.

## Installation

This package can be installed with

``` r
# install.packages("devtools")
devtools::install_github("consistentlybetter/ivd")
```

## Example

``` r
library(ivd)
library(data.table)
```

## Data

The illustration uses openly accessible data from The Basic Education
Evaluation System (Saeb) conducted by Brazil’s National Institute for
Educational Studies and Research (Inep), available at
<https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/saeb/resultados>.
It is also available as the `saeb` dataset in the `ivd` package.

Separate within- from between-school effects. That is, besides
`student_ses`, compute `school_ses`.

``` r
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
```

Illustration of school level variability:

``` r
library(ggplot2)
plot0 <- ggplot( data = saeb, aes( x = school_id, y = math_proficiency) )
plot0 + geom_point(aes(color =  school_id), show.legend =  FALSE)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

## Estimate Model

We will predict `math_proficiency` which is a standardized variable
capturing math proficiency at the end of grade 12.

Both, location (means) and scale (residual variances) are modeled as a
function of student and school SES. Note that the formula objects for
both location and scale follow `lme4` notation.

``` r
out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1|school_id),
           scale_formula =  ~ student_ses * school_ses + (1|school_id),
           data = saeb,
           niter = 3000, nburnin = 5000, WAIC = TRUE, workers = 6)
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 4 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> ===== Monitors =====
#> thin = 1: beta, sigma_rand, ss, z, zeta, zscore
#> ===== Samplers =====
#> RW sampler (327)
#>   - z[]  (320 elements)
#>   - zeta[]  (4 elements)
#>   - sigma_rand[]  (2 elements)
#>   - zscore
#> conjugate sampler (4)
#>   - beta[]  (4 elements)
#> binary sampler (320)
#>   - ss[]  (320 elements)
#> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
#> |-------------|-------------|-------------|-------------|
#> |-------------------------------------------------------|
#>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
#> Defining model
#>   [Warning] Multiple definitions for the same node.
#>             Did you forget indexing with 'p' on the left-hand side of
#>             `zscore ~ dnorm(mean = 0, sd = 1, lower_ = -Inf, upper_ = Inf, .tau = 1, .var = 1)`?
#> Building model
#> Setting data and initial values
#>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
#>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
#> Running calculate on model
#>   [Note] Any error reports that follow may simply reflect missing values in model variables.
#> Checking model sizes and dimensions
#>   [Note] This model is not fully initialized. This is not an error.
#>          To see which variables are not initialized, use model$initializeInfo().
#>          For more information on model initialization, see help(modelInitialization).
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> Compiling
#>   [Note] This may take a minute.
#>   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
#> running chain 1...
#> [1] "Compiling results..."
```

The summary shows the fixed and random effects and it returns all
posterior inclusion probabilities (PIP) for each one of the 160 schools’
residual variance random effects. The PIP returns the probability of a
school belonging to the slab, that is, the probability of the model
having to include the random scale effect.

In other words, large PIP’s indicate schools that are substantially
deviating from the fixed scale effects either because they are much
*more* or much *less* variable compared to other schools in math
proficiency.

One can readily convert those PIP’s to odds, indicating that a school
with a PIP = .75 is three times as likely to belonging to the slab than
belonging to the spike. With an .50 inclusion prior, these odds can be
readily interpreted as Bayes Factors.

``` r
s_out <- summary(out)
#> Summary statistics for ivd model:
#> Chains (workers): 6 
#> 
#>                              Mean    SD Time-series SE   2.5%    50%  97.5%
#> R[scl_Intc, Intc]          -0.709 0.172          0.006 -0.968 -0.735 -0.311
#> Intc                        0.127 0.023          0.001  0.080  0.128  0.172
#> student_ses                 0.082 0.010          0.000  0.063  0.082  0.100
#> school_ses                  0.678 0.086          0.004  0.506  0.680  0.842
#> student_ses:school_ses     -0.022 0.039          0.000 -0.100 -0.022  0.054
#> sd_Intc                     0.267 0.020          0.001  0.229  0.267  0.306
#> sd_scl_Intc                 0.079 0.015          0.000  0.051  0.078  0.112
#> pip[2, 1]                   0.464 0.499          0.004  0.000  0.000  1.000
#> pip[2, 2]                   0.476 0.499          0.004  0.000  0.000  1.000
#> pip[2, 3]                   0.457 0.498          0.004  0.000  0.000  1.000
#> pip[2, 4]                   0.480 0.500          0.005  0.000  0.000  1.000
#> pip[2, 5]                   0.525 0.499          0.005  0.000  1.000  1.000
#> pip[2, 6]                   0.423 0.494          0.004  0.000  0.000  1.000
#> pip[2, 7]                   0.398 0.490          0.005  0.000  0.000  1.000
#> pip[2, 8]                   0.464 0.499          0.004  0.000  0.000  1.000
#> pip[2, 9]                   0.987 0.114          0.001  1.000  1.000  1.000
#> pip[2, 10]                  0.451 0.498          0.004  0.000  0.000  1.000
#> pip[2, 11]                  0.560 0.496          0.004  0.000  1.000  1.000
#> pip[2, 12]                  0.354 0.478          0.004  0.000  0.000  1.000
#> pip[2, 13]                  0.476 0.499          0.005  0.000  0.000  1.000
#> pip[2, 14]                  0.596 0.491          0.006  0.000  1.000  1.000
#> pip[2, 15]                  0.510 0.500          0.004  0.000  1.000  1.000
#> pip[2, 16]                  0.482 0.500          0.004  0.000  0.000  1.000
#> pip[2, 17]                  0.416 0.493          0.004  0.000  0.000  1.000
#> pip[2, 18]                  0.536 0.499          0.004  0.000  1.000  1.000
#> pip[2, 19]                  0.224 0.417          0.005  0.000  0.000  1.000
#> pip[2, 20]                  0.525 0.499          0.004  0.000  1.000  1.000
#> pip[2, 21]                  0.343 0.475          0.005  0.000  0.000  1.000
#> pip[2, 22]                  0.567 0.496          0.005  0.000  1.000  1.000
#> pip[2, 23]                  0.499 0.500          0.005  0.000  0.000  1.000
#> pip[2, 24]                  0.481 0.500          0.004  0.000  0.000  1.000
#> pip[2, 25]                  0.469 0.499          0.004  0.000  0.000  1.000
#> pip[2, 26]                  0.515 0.500          0.004  0.000  1.000  1.000
#> pip[2, 27]                  0.445 0.497          0.004  0.000  0.000  1.000
#> pip[2, 28]                  0.382 0.486          0.004  0.000  0.000  1.000
#> pip[2, 29]                  0.495 0.500          0.004  0.000  0.000  1.000
#> pip[2, 30]                  0.457 0.498          0.005  0.000  0.000  1.000
#> pip[2, 31]                  0.461 0.499          0.004  0.000  0.000  1.000
#> pip[2, 32]                  0.477 0.499          0.005  0.000  0.000  1.000
#> pip[2, 33]                  0.498 0.500          0.004  0.000  0.000  1.000
#> pip[2, 34]                  0.539 0.499          0.004  0.000  1.000  1.000
#> pip[2, 35]                  0.660 0.474          0.005  0.000  1.000  1.000
#> pip[2, 36]                  0.347 0.476          0.006  0.000  0.000  1.000
#> pip[2, 37]                  0.461 0.498          0.004  0.000  0.000  1.000
#> pip[2, 38]                  0.444 0.497          0.004  0.000  0.000  1.000
#> pip[2, 39]                  0.679 0.467          0.008  0.000  1.000  1.000
#> pip[2, 40]                  0.461 0.498          0.004  0.000  0.000  1.000
#> pip[2, 41]                  0.628 0.483          0.009  0.000  1.000  1.000
#> pip[2, 42]                  0.470 0.499          0.004  0.000  0.000  1.000
#> pip[2, 43]                  0.411 0.492          0.004  0.000  0.000  1.000
#> pip[2, 44]                  0.433 0.495          0.004  0.000  0.000  1.000
#> pip[2, 45]                  0.437 0.496          0.004  0.000  0.000  1.000
#> pip[2, 46]                  0.999 0.032          0.000  1.000  1.000  1.000
#> pip[2, 47]                  0.464 0.499          0.004  0.000  0.000  1.000
#> pip[2, 48]                  0.613 0.487          0.004  0.000  1.000  1.000
#> pip[2, 49]                  0.495 0.500          0.006  0.000  0.000  1.000
#> pip[2, 50]                  0.522 0.500          0.004  0.000  1.000  1.000
#> pip[2, 51]                  0.466 0.499          0.004  0.000  0.000  1.000
#> pip[2, 52]                  0.551 0.497          0.004  0.000  1.000  1.000
#> pip[2, 53]                  0.829 0.376          0.005  0.000  1.000  1.000
#> pip[2, 54]                  0.619 0.486          0.004  0.000  1.000  1.000
#> pip[2, 55]                  0.400 0.490          0.004  0.000  0.000  1.000
#> pip[2, 56]                  0.473 0.499          0.004  0.000  0.000  1.000
#> pip[2, 57]                  0.621 0.485          0.004  0.000  1.000  1.000
#> pip[2, 58]                  0.397 0.489          0.004  0.000  0.000  1.000
#> pip[2, 59]                  0.425 0.494          0.004  0.000  0.000  1.000
#> pip[2, 60]                  0.524 0.499          0.004  0.000  1.000  1.000
#> pip[2, 61]                  0.291 0.454          0.005  0.000  0.000  1.000
#> pip[2, 62]                  0.415 0.493          0.004  0.000  0.000  1.000
#> pip[2, 63]                  0.504 0.500          0.004  0.000  1.000  1.000
#> pip[2, 64]                  0.732 0.443          0.004  0.000  1.000  1.000
#> pip[2, 65]                  0.495 0.500          0.004  0.000  0.000  1.000
#> pip[2, 66]                  0.631 0.483          0.005  0.000  1.000  1.000
#> pip[2, 67]                  0.342 0.474          0.004  0.000  0.000  1.000
#> pip[2, 68]                  0.365 0.482          0.005  0.000  0.000  1.000
#> pip[2, 69]                  0.454 0.498          0.004  0.000  0.000  1.000
#> pip[2, 70]                  0.383 0.486          0.005  0.000  0.000  1.000
#> pip[2, 71]                  0.378 0.485          0.004  0.000  0.000  1.000
#> pip[2, 72]                  0.379 0.485          0.004  0.000  0.000  1.000
#> pip[2, 73]                  0.370 0.483          0.007  0.000  0.000  1.000
#> pip[2, 74]                  0.493 0.500          0.004  0.000  0.000  1.000
#> pip[2, 75]                  0.465 0.499          0.004  0.000  0.000  1.000
#> pip[2, 76]                  0.462 0.499          0.004  0.000  0.000  1.000
#> pip[2, 77]                  0.464 0.499          0.004  0.000  0.000  1.000
#> pip[2, 78]                  0.445 0.497          0.004  0.000  0.000  1.000
#> pip[2, 79]                  0.390 0.488          0.004  0.000  0.000  1.000
#> pip[2, 80]                  0.507 0.500          0.004  0.000  1.000  1.000
#> pip[2, 81]                  0.510 0.500          0.004  0.000  1.000  1.000
#> pip[2, 82]                  0.523 0.499          0.005  0.000  1.000  1.000
#> pip[2, 83]                  0.484 0.500          0.004  0.000  0.000  1.000
#> pip[2, 84]                  0.518 0.500          0.004  0.000  1.000  1.000
#> pip[2, 85]                  0.470 0.499          0.004  0.000  0.000  1.000
#> pip[2, 86]                  0.529 0.499          0.005  0.000  1.000  1.000
#> pip[2, 87]                  0.706 0.455          0.006  0.000  1.000  1.000
#> pip[2, 88]                  0.473 0.499          0.004  0.000  0.000  1.000
#> pip[2, 89]                  0.526 0.499          0.004  0.000  1.000  1.000
#> pip[2, 90]                  0.487 0.500          0.004  0.000  0.000  1.000
#> pip[2, 91]                  0.438 0.496          0.004  0.000  0.000  1.000
#> pip[2, 92]                  0.733 0.442          0.005  0.000  1.000  1.000
#> pip[2, 93]                  0.442 0.497          0.004  0.000  0.000  1.000
#> pip[2, 94]                  0.479 0.500          0.004  0.000  0.000  1.000
#> pip[2, 95]                  0.745 0.436          0.005  0.000  1.000  1.000
#> pip[2, 96]                  0.438 0.496          0.004  0.000  0.000  1.000
#> pip[2, 97]                  0.342 0.474          0.004  0.000  0.000  1.000
#> pip[2, 98]                  0.460 0.498          0.004  0.000  0.000  1.000
#> pip[2, 99]                  0.560 0.496          0.004  0.000  1.000  1.000
#> pip[2, 100]                 0.453 0.498          0.004  0.000  0.000  1.000
#> pip[2, 101]                 0.439 0.496          0.004  0.000  0.000  1.000
#> pip[2, 102]                 0.493 0.500          0.006  0.000  0.000  1.000
#> pip[2, 103]                 0.384 0.486          0.004  0.000  0.000  1.000
#> pip[2, 104]                 0.464 0.499          0.004  0.000  0.000  1.000
#> pip[2, 105]                 0.478 0.500          0.004  0.000  0.000  1.000
#> pip[2, 106]                 0.440 0.496          0.005  0.000  0.000  1.000
#> pip[2, 107]                 0.512 0.500          0.004  0.000  1.000  1.000
#> pip[2, 108]                 0.540 0.498          0.007  0.000  1.000  1.000
#> pip[2, 109]                 0.537 0.499          0.004  0.000  1.000  1.000
#> pip[2, 110]                 0.401 0.490          0.004  0.000  0.000  1.000
#> pip[2, 111]                 0.446 0.497          0.005  0.000  0.000  1.000
#> pip[2, 112]                 0.456 0.498          0.005  0.000  0.000  1.000
#> pip[2, 113]                 0.627 0.484          0.004  0.000  1.000  1.000
#> pip[2, 114]                 0.900 0.299          0.004  0.000  1.000  1.000
#> pip[2, 115]                 0.814 0.389          0.005  0.000  1.000  1.000
#> pip[2, 116]                 0.466 0.499          0.005  0.000  0.000  1.000
#> pip[2, 117]                 0.434 0.496          0.004  0.000  0.000  1.000
#> pip[2, 118]                 0.391 0.488          0.004  0.000  0.000  1.000
#> pip[2, 119]                 0.496 0.500          0.004  0.000  0.000  1.000
#> pip[2, 120]                 0.568 0.495          0.004  0.000  1.000  1.000
#> pip[2, 121]                 0.319 0.466          0.004  0.000  0.000  1.000
#> pip[2, 122]                 0.529 0.499          0.008  0.000  1.000  1.000
#> pip[2, 123]                 0.577 0.494          0.004  0.000  1.000  1.000
#> pip[2, 124]                 0.751 0.433          0.004  0.000  1.000  1.000
#> pip[2, 125]                 0.465 0.499          0.004  0.000  0.000  1.000
#> pip[2, 126]                 0.508 0.500          0.004  0.000  1.000  1.000
#> pip[2, 127]                 0.569 0.495          0.004  0.000  1.000  1.000
#> pip[2, 128]                 0.517 0.500          0.004  0.000  1.000  1.000
#> pip[2, 129]                 0.399 0.490          0.004  0.000  0.000  1.000
#> pip[2, 130]                 0.470 0.499          0.004  0.000  0.000  1.000
#> pip[2, 131]                 0.559 0.496          0.004  0.000  1.000  1.000
#> pip[2, 132]                 0.401 0.490          0.004  0.000  0.000  1.000
#> pip[2, 133]                 0.355 0.478          0.005  0.000  0.000  1.000
#> pip[2, 134]                 0.511 0.500          0.004  0.000  1.000  1.000
#> pip[2, 135]                 0.428 0.495          0.004  0.000  0.000  1.000
#> pip[2, 136]                 0.388 0.487          0.004  0.000  0.000  1.000
#> pip[2, 137]                 0.446 0.497          0.005  0.000  0.000  1.000
#> pip[2, 138]                 0.433 0.496          0.004  0.000  0.000  1.000
#> pip[2, 139]                 0.416 0.493          0.004  0.000  0.000  1.000
#> pip[2, 140]                 0.570 0.495          0.004  0.000  1.000  1.000
#> pip[2, 141]                 0.511 0.500          0.004  0.000  1.000  1.000
#> pip[2, 142]                 0.470 0.499          0.004  0.000  0.000  1.000
#> pip[2, 143]                 0.415 0.493          0.004  0.000  0.000  1.000
#> pip[2, 144]                 0.472 0.499          0.004  0.000  0.000  1.000
#> pip[2, 145]                 0.446 0.497          0.004  0.000  0.000  1.000
#> pip[2, 146]                 0.457 0.498          0.004  0.000  0.000  1.000
#> pip[2, 147]                 0.486 0.500          0.004  0.000  0.000  1.000
#> pip[2, 148]                 0.638 0.480          0.004  0.000  1.000  1.000
#> pip[2, 149]                 0.716 0.451          0.004  0.000  1.000  1.000
#> pip[2, 150]                 0.378 0.485          0.005  0.000  0.000  1.000
#> pip[2, 151]                 0.466 0.499          0.004  0.000  0.000  1.000
#> pip[2, 152]                 0.473 0.499          0.004  0.000  0.000  1.000
#> pip[2, 153]                 0.770 0.421          0.004  0.000  1.000  1.000
#> pip[2, 154]                 0.336 0.472          0.005  0.000  0.000  1.000
#> pip[2, 155]                 0.417 0.493          0.004  0.000  0.000  1.000
#> pip[2, 156]                 0.583 0.493          0.004  0.000  1.000  1.000
#> pip[2, 157]                 0.529 0.499          0.004  0.000  1.000  1.000
#> pip[2, 158]                 0.460 0.498          0.004  0.000  0.000  1.000
#> pip[2, 159]                 0.476 0.499          0.004  0.000  0.000  1.000
#> pip[2, 160]                 0.517 0.500          0.004  0.000  1.000  1.000
#> scl_Intc                   -0.234 0.008          0.000 -0.251 -0.234 -0.218
#> scl_student_ses             0.031 0.009          0.000  0.014  0.031  0.048
#> scl_school_ses              0.120 0.034          0.001  0.053  0.120  0.188
#> scl_student_ses:school_ses  0.076 0.037          0.001  0.002  0.076  0.146
#>                            n_eff R-hat
#> R[scl_Intc, Intc]            741 1.005
#> Intc                         309 1.015
#> student_ses                16787 1.000
#> school_ses                   188 1.019
#> student_ses:school_ses     18732 1.000
#> sd_Intc                      153 1.010
#> sd_scl_Intc                  873 1.004
#> pip[2, 1]                  17602 1.000
#> pip[2, 2]                  16980 1.000
#> pip[2, 3]                  14235 1.000
#> pip[2, 4]                   9184 1.000
#> pip[2, 5]                   9801 1.000
#> pip[2, 6]                  14577 1.000
#> pip[2, 7]                   9652 1.000
#> pip[2, 8]                  17982 1.000
#> pip[2, 9]                   7713 1.001
#> pip[2, 10]                 15953 1.000
#> pip[2, 11]                 11758 1.000
#> pip[2, 12]                 11993 1.000
#> pip[2, 13]                 10686 1.000
#> pip[2, 14]                  6891 1.000
#> pip[2, 15]                 17926 1.000
#> pip[2, 16]                 14946 1.000
#> pip[2, 17]                 10693 1.000
#> pip[2, 18]                 12618 1.000
#> pip[2, 19]                  5642 1.000
#> pip[2, 20]                 15328 1.000
#> pip[2, 21]                  9889 1.000
#> pip[2, 22]                  8538 1.000
#> pip[2, 23]                 10013 1.000
#> pip[2, 24]                 16643 1.000
#> pip[2, 25]                 17328 1.000
#> pip[2, 26]                 18011 1.000
#> pip[2, 27]                 15816 1.000
#> pip[2, 28]                 11102 1.000
#> pip[2, 29]                 12492 1.000
#> pip[2, 30]                  9142 1.000
#> pip[2, 31]                 14164 1.000
#> pip[2, 32]                  9626 1.000
#> pip[2, 33]                 13871 1.000
#> pip[2, 34]                 18092 1.000
#> pip[2, 35]                  7150 1.000
#> pip[2, 36]                  5424 1.001
#> pip[2, 37]                 18064 1.000
#> pip[2, 38]                 13505 1.000
#> pip[2, 39]                  2271 1.003
#> pip[2, 40]                 13388 1.001
#> pip[2, 41]                  2204 1.001
#> pip[2, 42]                 12813 1.000
#> pip[2, 43]                 13512 1.000
#> pip[2, 44]                 15754 1.000
#> pip[2, 45]                 15278 1.000
#> pip[2, 46]                 14037 1.000
#> pip[2, 47]                 18127 1.000
#> pip[2, 48]                 11074 1.000
#> pip[2, 49]                  6908 1.000
#> pip[2, 50]                 16681 1.000
#> pip[2, 51]                 16071 1.000
#> pip[2, 52]                 15676 1.000
#> pip[2, 53]                  3628 1.001
#> pip[2, 54]                 10254 1.000
#> pip[2, 55]                 14233 1.000
#> pip[2, 56]                 13966 1.000
#> pip[2, 57]                 11345 1.000
#> pip[2, 58]                 11313 1.000
#> pip[2, 59]                 11494 1.000
#> pip[2, 60]                 14846 1.000
#> pip[2, 61]                  8360 1.001
#> pip[2, 62]                 14451 1.000
#> pip[2, 63]                 15885 1.000
#> pip[2, 64]                 10258 1.000
#> pip[2, 65]                 17691 1.000
#> pip[2, 66]                 10540 1.000
#> pip[2, 67]                 11010 1.000
#> pip[2, 68]                 10458 1.000
#> pip[2, 69]                 16552 1.000
#> pip[2, 70]                  6707 1.001
#> pip[2, 71]                 13483 1.000
#> pip[2, 72]                 10319 1.000
#> pip[2, 73]                  3310 1.001
#> pip[2, 74]                 12959 1.000
#> pip[2, 75]                 15277 1.000
#> pip[2, 76]                 16138 1.000
#> pip[2, 77]                 15728 1.000
#> pip[2, 78]                 16296 1.000
#> pip[2, 79]                 13809 1.000
#> pip[2, 80]                 18265 1.000
#> pip[2, 81]                 12360 1.000
#> pip[2, 82]                 11160 1.001
#> pip[2, 83]                 15449 1.000
#> pip[2, 84]                 15015 1.000
#> pip[2, 85]                 15124 1.000
#> pip[2, 86]                 11002 1.000
#> pip[2, 87]                  3919 1.000
#> pip[2, 88]                 11940 1.000
#> pip[2, 89]                 14465 1.000
#> pip[2, 90]                 18017 1.000
#> pip[2, 91]                 12365 1.000
#> pip[2, 92]                  9349 1.000
#> pip[2, 93]                 15348 1.000
#> pip[2, 94]                 17674 1.000
#> pip[2, 95]                  7766 1.001
#> pip[2, 96]                 14881 1.000
#> pip[2, 97]                 10089 1.000
#> pip[2, 98]                 13859 1.000
#> pip[2, 99]                 10875 1.000
#> pip[2, 100]                15927 1.001
#> pip[2, 101]                12590 1.000
#> pip[2, 102]                 7196 1.001
#> pip[2, 103]                10476 1.000
#> pip[2, 104]                17497 1.000
#> pip[2, 105]                19916 1.000
#> pip[2, 106]                 8168 1.000
#> pip[2, 107]                12097 1.000
#> pip[2, 108]                 3738 1.001
#> pip[2, 109]                17332 1.000
#> pip[2, 110]                12776 1.000
#> pip[2, 111]                 9216 1.000
#> pip[2, 112]                 9711 1.001
#> pip[2, 113]                10923 1.000
#> pip[2, 114]                 6840 1.001
#> pip[2, 115]                 3993 1.000
#> pip[2, 116]                 5715 1.000
#> pip[2, 117]                17447 1.000
#> pip[2, 118]                12199 1.000
#> pip[2, 119]                18888 1.000
#> pip[2, 120]                14146 1.000
#> pip[2, 121]                10527 1.001
#> pip[2, 122]                 3333 1.000
#> pip[2, 123]                14902 1.000
#> pip[2, 124]                 8232 1.000
#> pip[2, 125]                14370 1.000
#> pip[2, 126]                13653 1.000
#> pip[2, 127]                14731 1.000
#> pip[2, 128]                12021 1.000
#> pip[2, 129]                15129 1.000
#> pip[2, 130]                17230 1.000
#> pip[2, 131]                13643 1.001
#> pip[2, 132]                12801 1.000
#> pip[2, 133]                10795 1.000
#> pip[2, 134]                15325 1.000
#> pip[2, 135]                14946 1.000
#> pip[2, 136]                12157 1.000
#> pip[2, 137]                 9925 1.000
#> pip[2, 138]                16609 1.000
#> pip[2, 139]                15117 1.000
#> pip[2, 140]                15116 1.000
#> pip[2, 141]                13120 1.000
#> pip[2, 142]                18302 1.000
#> pip[2, 143]                14879 1.000
#> pip[2, 144]                17864 1.000
#> pip[2, 145]                11499 1.000
#> pip[2, 146]                16256 1.000
#> pip[2, 147]                18288 1.000
#> pip[2, 148]                16994 1.000
#> pip[2, 149]                13634 1.000
#> pip[2, 150]                11643 1.000
#> pip[2, 151]                19951 1.000
#> pip[2, 152]                18685 1.000
#> pip[2, 153]                 6373 1.000
#> pip[2, 154]                 7563 1.000
#> pip[2, 155]                12623 1.000
#> pip[2, 156]                12034 1.001
#> pip[2, 157]                16346 1.000
#> pip[2, 158]                17213 1.000
#> pip[2, 159]                10666 1.000
#> pip[2, 160]                16370 1.000
#> scl_Intc                    1151 1.002
#> scl_student_ses             3267 1.000
#> scl_school_ses               520 1.005
#> scl_student_ses:school_ses  2447 1.001
#> 
#> WAIC: 27043.65 
#> elppd: -13365.51 
#> pWAIC: 156.3145
```

## Plots

### Posterior inclusion probability plot (PIP)

``` r
plot(out, type = "pip")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

### PIP vs. Within-cluster SD

``` r
plot(out, type =  "funnel")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### PIP vs. math achievement

Note that point size represents the within-cluster standard deviation of
each cluster.

``` r
plot(out, type =  "outcome")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Diagnostic plots based on coda plots:

``` r
codaplot(out, parameters =  "beta[1]")
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

``` r
codaplot(out, parameters =  "R[2, 1]")
```

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

## Acknowledgment

This work was supported by the Tools Competition catalyst award for the
project
[consistentlyBetter](https://tools-competition.org/winner/consistentlybetter/)
to PR. The content is solely the responsibility of the authors and does
not necessarily represent the official views of the funding agency.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-rodriguez2021" class="csl-entry">

Rodriguez, J. E., Williams, D. R., & Rast, P. (2024). Who is and is not"
average’"? Random effects selection with spike-and-slab priors.
*Psychological Methods*. <https://doi.org/10.1037/met0000535>

</div>

<div id="ref-williams2022" class="csl-entry">

Williams, D. R., Martin, S. R., & Rast, P. (2022). Putting the
individual into reliability: Bayesian testing of homogeneous
within-person variance in hierarchical models. *Behavior Research
Methods*, *54*(3), 1272–1290.
<https://doi.org/10.3758/s13428-021-01646-x>

</div>

</div>
