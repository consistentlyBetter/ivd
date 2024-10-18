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

    # install.packages("devtools")
    devtools::install_github("consistentlybetter/ivd")

## Example

    library(ivd)
    library(data.table)

## Data

The illustration uses openly accessible data from The Basic Education
Evaluation System (Saeb) conducted by Brazil’s National Institute for
Educational Studies and Research (Inep), available at
<https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/saeb/resultados>.
It is also available as the `saeb` dataset in the `ivd` package.

Separate within- from between-school effects. That is, besides
`student_ses`, compute `school_ses`.

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

Illustration of school level variability:

    library(ggplot2)
    plot0 <- ggplot( data = saeb, aes( x = school_id, y = math_proficiency) )
    plot0 + geom_point(aes(color =  school_id), show.legend =  FALSE)

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

## Estimate Model

We will predict `math_proficiency` which is a standardized variable
capturing math proficiency at the end of grade 12.

Both, location (means) and scale (residual variances) are modeled as a
function of student and school SES. Note that the formula objects for
both location and scale follow `lme4` notation.

    out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1|school_id),
               scale_formula =  ~ student_ses * school_ses + (1|school_id),
               data = saeb,
               niter = 2000, nburnin = 8000, WAIC = TRUE, workers = 6)
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 5 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 5 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 4 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (326)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (4 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (4)
    #>   - beta[]  (4 elements)
    #> binary sampler (320)
    #>   - ss[]  (320 elements)
    #> thin = 1: beta, mu, R, sigma_rand, ss, tau, u, zeta
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 3 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
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

    s_out <- summary(out)
    #> Summary statistics for ivd model:
    #> Chains (workers): 6 
    #> 
    #>                              Mean    SD Time-series SE   2.5%    50%  97.5% n_eff R-hat
    #> R[scl_Intc, Intc]          -0.801 0.170          0.028 -0.992 -0.848 -0.359    37 1.288
    #> Intc                        0.127 0.023          0.001  0.082  0.127  0.173   221 1.009
    #> student_ses                 0.082 0.010          0.000  0.063  0.082  0.101  8308 1.000
    #> school_ses                  0.763 0.084          0.004  0.599  0.764  0.927   302 1.012
    #> student_ses:school_ses     -0.037 0.038          0.001 -0.112 -0.037  0.037  5091 1.001
    #> sd_Intc                     0.209 0.023          0.003  0.174  0.206  0.260    42 1.160
    #> sd_scl_Intc                 0.186 0.136          0.018  0.067  0.147  0.550    53 1.204
    #> ss[2, 1]                    0.474 0.499          0.005  0.000  0.000  1.000 14019 1.000
    #> ss[2, 2]                    0.482 0.500          0.005  0.000  0.000  1.000  8497 1.000
    #> ss[2, 3]                    0.444 0.497          0.006  0.000  0.000  1.000  8769 1.000
    #> ss[2, 4]                    0.481 0.500          0.007  0.000  0.000  1.000  4739 1.002
    #> ss[2, 5]                    0.539 0.498          0.007  0.000  1.000  1.000  3674 1.001
    #> ss[2, 6]                    0.425 0.494          0.005  0.000  0.000  1.000  5755 1.000
    #> ss[2, 7]                    0.412 0.492          0.008  0.000  0.000  1.000  2924 1.001
    #> ss[2, 8]                    0.464 0.499          0.005  0.000  0.000  1.000 10200 1.000
    #> ss[2, 9]                    0.985 0.124          0.003  1.000  1.000  1.000  1977 1.000
    #> ss[2, 10]                   0.443 0.497          0.005  0.000  0.000  1.000  8515 1.001
    #> ss[2, 11]                   0.578 0.494          0.006  0.000  1.000  1.000  6371 1.000
    #> ss[2, 12]                   0.389 0.487          0.006  0.000  0.000  1.000  6488 1.001
    #> ss[2, 13]                   0.459 0.498          0.010  0.000  0.000  1.000  1525 1.004
    #> ss[2, 14]                   0.630 0.483          0.009  0.000  1.000  1.000  2463 1.001
    #> ss[2, 15]                   0.504 0.500          0.005  0.000  1.000  1.000 12585 1.000
    #> ss[2, 16]                   0.476 0.499          0.005  0.000  0.000  1.000 10942 1.001
    #> ss[2, 17]                   0.443 0.497          0.006  0.000  0.000  1.000  7774 1.000
    #> ss[2, 18]                   0.523 0.500          0.005  0.000  1.000  1.000  7049 1.000
    #> ss[2, 19]                   0.276 0.447          0.006  0.000  0.000  1.000  3938 1.002
    #> ss[2, 20]                   0.532 0.499          0.005  0.000  1.000  1.000  8432 1.000
    #> ss[2, 21]                   0.379 0.485          0.008  0.000  0.000  1.000  3902 1.001
    #> ss[2, 22]                   0.566 0.496          0.007  0.000  1.000  1.000  3808 1.001
    #> ss[2, 23]                   0.463 0.499          0.008  0.000  0.000  1.000  3628 1.000
    #> ss[2, 24]                   0.488 0.500          0.005  0.000  0.000  1.000 10989 1.000
    #> ss[2, 25]                   0.467 0.499          0.005  0.000  0.000  1.000  9608 1.000
    #> ss[2, 26]                   0.514 0.500          0.005  0.000  1.000  1.000 10591 1.000
    #> ss[2, 27]                   0.437 0.496          0.005  0.000  0.000  1.000 11929 1.000
    #> ss[2, 28]                   0.406 0.491          0.006  0.000  0.000  1.000  7670 1.001
    #> ss[2, 29]                   0.490 0.500          0.005  0.000  0.000  1.000  8736 1.000
    #> ss[2, 30]                   0.442 0.497          0.009  0.000  0.000  1.000   945 1.003
    #> ss[2, 31]                   0.467 0.499          0.005  0.000  0.000  1.000  9788 1.000
    #> ss[2, 32]                   0.483 0.500          0.008  0.000  0.000  1.000  3140 1.000
    #> ss[2, 33]                   0.476 0.499          0.006  0.000  0.000  1.000  5711 1.001
    #> ss[2, 34]                   0.583 0.493          0.005  0.000  1.000  1.000  8404 1.000
    #> ss[2, 35]                   0.673 0.469          0.011  0.000  1.000  1.000   997 1.003
    #> ss[2, 36]                   0.393 0.488          0.009  0.000  0.000  1.000  2298 1.005
    #> ss[2, 37]                   0.454 0.498          0.005  0.000  0.000  1.000  9883 1.001
    #> ss[2, 38]                   0.454 0.498          0.005  0.000  0.000  1.000  9842 1.000
    #> ss[2, 39]                   0.753 0.432          0.022  0.000  1.000  1.000   236 1.013
    #> ss[2, 40]                   0.454 0.498          0.005  0.000  0.000  1.000 10805 1.000
    #> ss[2, 41]                   0.692 0.462          0.017  0.000  1.000  1.000   463 1.007
    #> ss[2, 42]                   0.455 0.498          0.006  0.000  0.000  1.000  6507 1.000
    #> ss[2, 43]                   0.384 0.486          0.007  0.000  0.000  1.000  4278 1.001
    #> ss[2, 44]                   0.438 0.496          0.005  0.000  0.000  1.000  7160 1.000
    #> ss[2, 45]                   0.435 0.496          0.005  0.000  0.000  1.000 10041 1.000
    #> ss[2, 46]                   0.999 0.033          0.000  1.000  1.000  1.000 12148 1.000
    #> ss[2, 47]                   0.457 0.498          0.005  0.000  0.000  1.000 11625 1.000
    #> ss[2, 48]                   0.597 0.490          0.008  0.000  1.000  1.000  3221 1.002
    #> ss[2, 49]                   0.499 0.500          0.014  0.000  0.000  1.000   683 1.002
    #> ss[2, 50]                   0.526 0.499          0.005  0.000  1.000  1.000  9574 1.000
    #> ss[2, 51]                   0.463 0.499          0.005  0.000  0.000  1.000  6007 1.000
    #> ss[2, 52]                   0.532 0.499          0.005  0.000  1.000  1.000  8140 1.000
    #> ss[2, 53]                   0.803 0.398          0.015  0.000  1.000  1.000   532 1.007
    #> ss[2, 54]                   0.574 0.494          0.008  0.000  1.000  1.000  2486 1.000
    #> ss[2, 55]                   0.417 0.493          0.005  0.000  0.000  1.000 10708 1.000
    #> ss[2, 56]                   0.477 0.499          0.006  0.000  0.000  1.000  7461 1.001
    #> ss[2, 57]                   0.606 0.489          0.005  0.000  1.000  1.000  7566 1.000
    #> ss[2, 58]                   0.419 0.493          0.006  0.000  0.000  1.000  6618 1.001
    #> ss[2, 59]                   0.437 0.496          0.005  0.000  0.000  1.000  9339 1.000
    #> ss[2, 60]                   0.515 0.500          0.005  0.000  1.000  1.000  7373 1.000
    #> ss[2, 61]                   0.301 0.459          0.014  0.000  0.000  1.000   610 1.005
    #> ss[2, 62]                   0.419 0.493          0.006  0.000  0.000  1.000  4513 1.001
    #> ss[2, 63]                   0.506 0.500          0.005  0.000  1.000  1.000  7839 1.001
    #> ss[2, 64]                   0.686 0.464          0.006  0.000  1.000  1.000  5666 1.000
    #> ss[2, 65]                   0.485 0.500          0.004  0.000  0.000  1.000 14035 1.000
    #> ss[2, 66]                   0.623 0.485          0.006  0.000  1.000  1.000  5329 1.002
    #> ss[2, 67]                   0.368 0.482          0.006  0.000  0.000  1.000  5360 1.000
    #> ss[2, 68]                   0.389 0.488          0.007  0.000  0.000  1.000  1517 1.000
    #> ss[2, 69]                   0.457 0.498          0.005  0.000  0.000  1.000 12427 1.000
    #> ss[2, 70]                   0.418 0.493          0.008  0.000  0.000  1.000  1708 1.001
    #> ss[2, 71]                   0.404 0.491          0.005  0.000  0.000  1.000  7418 1.001
    #> ss[2, 72]                   0.388 0.487          0.006  0.000  0.000  1.000  4495 1.001
    #> ss[2, 73]                   0.439 0.496          0.013  0.000  0.000  1.000   621 1.002
    #> ss[2, 74]                   0.484 0.500          0.005  0.000  0.000  1.000  9127 1.000
    #> ss[2, 75]                   0.459 0.498          0.005  0.000  0.000  1.000 12067 1.000
    #> ss[2, 76]                   0.456 0.498          0.005  0.000  0.000  1.000  8593 1.001
    #> ss[2, 77]                   0.476 0.499          0.005  0.000  0.000  1.000  8518 1.000
    #> ss[2, 78]                   0.438 0.496          0.005  0.000  0.000  1.000  9035 1.000
    #> ss[2, 79]                   0.400 0.490          0.006  0.000  0.000  1.000  6285 1.001
    #> ss[2, 80]                   0.499 0.500          0.005  0.000  0.000  1.000 12164 1.000
    #> ss[2, 81]                   0.510 0.500          0.007  0.000  1.000  1.000  4335 1.002
    #> ss[2, 82]                   0.510 0.500          0.007  0.000  1.000  1.000  3596 1.000
    #> ss[2, 83]                   0.482 0.500          0.005  0.000  0.000  1.000 11942 1.000
    #> ss[2, 84]                   0.509 0.500          0.005  0.000  1.000  1.000 11475 1.000
    #> ss[2, 85]                   0.466 0.499          0.005  0.000  0.000  1.000 11948 1.000
    #> ss[2, 86]                   0.470 0.499          0.006  0.000  0.000  1.000  6061 1.000
    #> ss[2, 87]                   0.718 0.450          0.011  0.000  1.000  1.000   789 1.005
    #> ss[2, 88]                   0.490 0.500          0.006  0.000  0.000  1.000  6455 1.000
    #> ss[2, 89]                   0.525 0.499          0.005  0.000  1.000  1.000  9649 1.000
    #> ss[2, 90]                   0.491 0.500          0.005  0.000  0.000  1.000 11145 1.000
    #> ss[2, 91]                   0.445 0.497          0.005  0.000  0.000  1.000 10665 1.000
    #> ss[2, 92]                   0.684 0.465          0.011  0.000  1.000  1.000  1415 1.004
    #> ss[2, 93]                   0.446 0.497          0.005  0.000  0.000  1.000  8819 1.000
    #> ss[2, 94]                   0.479 0.500          0.005  0.000  0.000  1.000 11069 1.000
    #> ss[2, 95]                   0.700 0.458          0.009  0.000  1.000  1.000  1635 1.001
    #> ss[2, 96]                   0.429 0.495          0.005  0.000  0.000  1.000  7492 1.001
    #> ss[2, 97]                   0.364 0.481          0.007  0.000  0.000  1.000  3716 1.001
    #> ss[2, 98]                   0.459 0.498          0.007  0.000  0.000  1.000  4198 1.001
    #> ss[2, 99]                   0.548 0.498          0.006  0.000  1.000  1.000 10057 1.000
    #> ss[2, 100]                  0.447 0.497          0.005  0.000  0.000  1.000 11139 1.000
    #> ss[2, 101]                  0.414 0.492          0.007  0.000  0.000  1.000  3968 1.002
    #> ss[2, 102]                  0.479 0.500          0.015  0.000  0.000  1.000   467 1.006
    #> ss[2, 103]                  0.378 0.485          0.007  0.000  0.000  1.000  3349 1.002
    #> ss[2, 104]                  0.444 0.497          0.005  0.000  0.000  1.000  7836 1.001
    #> ss[2, 105]                  0.483 0.500          0.005  0.000  0.000  1.000  9972 1.000
    #> ss[2, 106]                  0.444 0.497          0.011  0.000  0.000  1.000   839 1.001
    #> ss[2, 107]                  0.523 0.499          0.005  0.000  1.000  1.000  7323 1.001
    #> ss[2, 108]                  0.560 0.496          0.017  0.000  1.000  1.000   413 1.007
    #> ss[2, 109]                  0.523 0.499          0.005  0.000  1.000  1.000  8861 1.000
    #> ss[2, 110]                  0.386 0.487          0.007  0.000  0.000  1.000  3375 1.001
    #> ss[2, 111]                  0.444 0.497          0.010  0.000  0.000  1.000  1637 1.001
    #> ss[2, 112]                  0.478 0.500          0.008  0.000  0.000  1.000  3649 1.001
    #> ss[2, 113]                  0.618 0.486          0.005  0.000  1.000  1.000  9339 1.000
    #> ss[2, 114]                  0.896 0.305          0.007  0.000  1.000  1.000  1356 1.002
    #> ss[2, 115]                  0.828 0.377          0.015  0.000  1.000  1.000   250 1.011
    #> ss[2, 116]                  0.441 0.497          0.009  0.000  0.000  1.000  1826 1.001
    #> ss[2, 117]                  0.439 0.496          0.005  0.000  0.000  1.000 11170 1.000
    #> ss[2, 118]                  0.393 0.488          0.007  0.000  0.000  1.000  5873 1.001
    #> ss[2, 119]                  0.492 0.500          0.005  0.000  0.000  1.000 10134 1.000
    #> ss[2, 120]                  0.553 0.497          0.005  0.000  1.000  1.000  7918 1.000
    #> ss[2, 121]                  0.358 0.480          0.006  0.000  0.000  1.000  4878 1.001
    #> ss[2, 122]                  0.565 0.496          0.013  0.000  1.000  1.000   788 1.005
    #> ss[2, 123]                  0.562 0.496          0.005  0.000  1.000  1.000  9603 1.000
    #> ss[2, 124]                  0.737 0.441          0.007  0.000  1.000  1.000  3355 1.000
    #> ss[2, 125]                  0.470 0.499          0.006  0.000  0.000  1.000  7970 1.001
    #> ss[2, 126]                  0.494 0.500          0.006  0.000  0.000  1.000  6605 1.001
    #> ss[2, 127]                  0.557 0.497          0.005  0.000  1.000  1.000  9536 1.000
    #> ss[2, 128]                  0.503 0.500          0.006  0.000  1.000  1.000  8109 1.000
    #> ss[2, 129]                  0.416 0.493          0.005  0.000  0.000  1.000 10169 1.000
    #> ss[2, 130]                  0.459 0.498          0.005  0.000  0.000  1.000  9281 1.000
    #> ss[2, 131]                  0.556 0.497          0.005  0.000  1.000  1.000  9847 1.000
    #> ss[2, 132]                  0.424 0.494          0.005  0.000  0.000  1.000  9238 1.000
    #> ss[2, 133]                  0.374 0.484          0.005  0.000  0.000  1.000  8540 1.001
    #> ss[2, 134]                  0.509 0.500          0.005  0.000  1.000  1.000  8925 1.000
    #> ss[2, 135]                  0.429 0.495          0.006  0.000  0.000  1.000  6175 1.000
    #> ss[2, 136]                  0.407 0.491          0.006  0.000  0.000  1.000  7264 1.000
    #> ss[2, 137]                  0.451 0.498          0.006  0.000  0.000  1.000  6020 1.000
    #> ss[2, 138]                  0.436 0.496          0.006  0.000  0.000  1.000  6687 1.000
    #> ss[2, 139]                  0.434 0.496          0.005  0.000  0.000  1.000  8304 1.000
    #> ss[2, 140]                  0.566 0.496          0.005  0.000  1.000  1.000  8665 1.000
    #> ss[2, 141]                  0.536 0.499          0.005  0.000  1.000  1.000 10058 1.000
    #> ss[2, 142]                  0.471 0.499          0.005  0.000  0.000  1.000  9645 1.000
    #> ss[2, 143]                  0.418 0.493          0.007  0.000  0.000  1.000  5771 1.000
    #> ss[2, 144]                  0.474 0.499          0.005  0.000  0.000  1.000 12102 1.000
    #> ss[2, 145]                  0.490 0.500          0.007  0.000  0.000  1.000  4071 1.000
    #> ss[2, 146]                  0.457 0.498          0.005  0.000  0.000  1.000  7473 1.000
    #> ss[2, 147]                  0.497 0.500          0.004  0.000  0.000  1.000 11042 1.000
    #> ss[2, 148]                  0.630 0.483          0.005  0.000  1.000  1.000 10496 1.000
    #> ss[2, 149]                  0.695 0.461          0.006  0.000  1.000  1.000  6201 1.001
    #> ss[2, 150]                  0.394 0.489          0.009  0.000  0.000  1.000  2457 1.003
    #> ss[2, 151]                  0.477 0.499          0.005  0.000  0.000  1.000 10732 1.000
    #> ss[2, 152]                  0.465 0.499          0.005  0.000  0.000  1.000  4219 1.001
    #> ss[2, 153]                  0.762 0.426          0.007  0.000  1.000  1.000  3044 1.001
    #> ss[2, 154]                  0.372 0.483          0.007  0.000  0.000  1.000  4885 1.000
    #> ss[2, 155]                  0.439 0.496          0.006  0.000  0.000  1.000  6373 1.000
    #> ss[2, 156]                  0.530 0.499          0.005  0.000  1.000  1.000  7914 1.001
    #> ss[2, 157]                  0.523 0.499          0.005  0.000  1.000  1.000  9595 1.000
    #> ss[2, 158]                  0.484 0.500          0.005  0.000  0.000  1.000 11658 1.000
    #> ss[2, 159]                  0.471 0.499          0.006  0.000  0.000  1.000  6096 1.001
    #> ss[2, 160]                  0.517 0.500          0.005  0.000  1.000  1.000  8241 1.001
    #> scl_Intc                   -0.231 0.009          0.000 -0.248 -0.231 -0.214   464 1.002
    #> scl_student_ses             0.031 0.009          0.000  0.014  0.031  0.048  2052 1.001
    #> scl_school_ses              0.145 0.036          0.001  0.075  0.143  0.216   205 1.008
    #> scl_student_ses:school_ses  0.065 0.033          0.001 -0.001  0.065  0.129  1407 1.002
    #> 
    #> WAIC: 27042.5 
    #> elppd: -13362.96 
    #> pWAIC: 158.2911

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip")

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

### PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### PIP vs. math achievement

Note that point size represents the within-cluster standard deviation of
each cluster.

    plot(out, type =  "outcome")

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameters =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

    codaplot(out, parameters =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

## Acknowledgment

This work was supported by the Tools Competition catalyst award for the
project
[consistentlyBetter](https://tools-competition.org/winner/consistentlybetter/)
to PR. The content is solely the responsibility of the authors and does
not necessarily represent the official views of the funding agency.

## References

Rodriguez, J. E., Williams, D. R., & Rast, P. (2024). Who is and is not"
average’"? Random effects selection with spike-and-slab priors.
*Psychological Methods*. <https://doi.org/10.1037/met0000535>

Williams, D. R., Martin, S. R., & Rast, P. (2022). Putting the
individual into reliability: Bayesian testing of homogeneous
within-person variance in hierarchical models. *Behavior Research
Methods*, *54*(3), 1272–1290.
<https://doi.org/10.3758/s13428-021-01646-x>
