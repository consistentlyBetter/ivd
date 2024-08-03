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

    head(saeb )
    #>    school_id public student_ses math_proficiency location school_ses i.school_ses i.school_ses.1
    #>        <num>  <int>       <num>            <num>    <int>      <num>        <num>          <num>
    #> 1:         1      1   -0.375501         0.094789        1 -0.3717212     4.557222  -9.868649e-16
    #> 2:         1      1    0.404499         1.518185        1 -0.3717212     4.557222  -9.868649e-16
    #> 3:         1      1    1.024499        -0.474808        1 -0.3717212     4.557222  -9.868649e-16
    #> 4:         1      1    1.914499         0.187490        1 -0.3717212     4.557222  -9.868649e-16
    #> 5:         1      1    1.184499         0.730355        1 -0.3717212     4.557222  -9.868649e-16
    #> 6:         1      1    0.324499         0.585839        1 -0.3717212     4.557222  -9.868649e-16

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
               niter = 2000, nburnin = 8000, WAIC = TRUE, workers = 4)
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
    #> Chains/workers: 4 
    #> 
    #>                    Mean    SD Time-series SE   2.5%    50%  97.5% R-hat
    #> R[2, 1]          -0.744 0.245          0.073 -0.996 -0.825 -0.167 2.284
    #> beta[1]           0.127 0.024          0.002  0.081  0.127  0.172 1.053
    #> beta[2]           0.081 0.010          0.000  0.063  0.081  0.100 1.001
    #> beta[3]           0.753 0.083          0.005  0.592  0.752  0.917 1.028
    #> beta[4]          -0.035 0.038          0.001 -0.111 -0.035  0.038 1.002
    #> sigma_rand[1, 1]  0.213 0.028          0.003  0.170  0.208  0.276 1.584
    #> sigma_rand[2, 2]  0.236 0.225          0.067  0.063  0.136  0.888 1.736
    #> ss[2, 1]          0.458 0.498          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 2]          0.464 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 3]          0.444 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 4]          0.478 0.500          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 5]          0.546 0.498          0.010  0.000  1.000  1.000 1.002
    #> ss[2, 6]          0.421 0.494          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 7]          0.421 0.494          0.010  0.000  0.000  1.000 1.000
    #> ss[2, 8]          0.478 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 9]          0.987 0.115          0.002  1.000  1.000  1.000 1.005
    #> ss[2, 10]         0.436 0.496          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 11]         0.580 0.494          0.008  0.000  1.000  1.000 1.000
    #> ss[2, 12]         0.374 0.484          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 13]         0.429 0.495          0.013  0.000  0.000  1.000 1.003
    #> ss[2, 14]         0.609 0.488          0.012  0.000  1.000  1.000 1.010
    #> ss[2, 15]         0.505 0.500          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 16]         0.471 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 17]         0.439 0.496          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 18]         0.529 0.499          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 19]         0.271 0.445          0.010  0.000  0.000  1.000 1.016
    #> ss[2, 20]         0.531 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 21]         0.391 0.488          0.010  0.000  0.000  1.000 1.002
    #> ss[2, 22]         0.561 0.496          0.008  0.000  1.000  1.000 1.002
    #> ss[2, 23]         0.486 0.500          0.008  0.000  0.000  1.000 1.005
    #> ss[2, 24]         0.492 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 25]         0.459 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 26]         0.503 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 27]         0.440 0.496          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 28]         0.430 0.495          0.007  0.000  0.000  1.000 1.006
    #> ss[2, 29]         0.479 0.500          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 30]         0.444 0.497          0.010  0.000  0.000  1.000 1.003
    #> ss[2, 31]         0.476 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 32]         0.506 0.500          0.011  0.000  1.000  1.000 1.002
    #> ss[2, 33]         0.480 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 34]         0.575 0.494          0.006  0.000  1.000  1.000 1.003
    #> ss[2, 35]         0.671 0.470          0.013  0.000  1.000  1.000 1.007
    #> ss[2, 36]         0.379 0.485          0.011  0.000  0.000  1.000 1.012
    #> ss[2, 37]         0.464 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 38]         0.442 0.497          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 39]         0.754 0.431          0.021  0.000  1.000  1.000 1.023
    #> ss[2, 40]         0.453 0.498          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 41]         0.689 0.463          0.020  0.000  1.000  1.000 1.091
    #> ss[2, 42]         0.445 0.497          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 43]         0.388 0.487          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 44]         0.444 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 45]         0.438 0.496          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 46]         0.998 0.040          0.001  1.000  1.000  1.000 1.001
    #> ss[2, 47]         0.466 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 48]         0.574 0.495          0.009  0.000  1.000  1.000 1.002
    #> ss[2, 49]         0.515 0.500          0.013  0.000  1.000  1.000 1.010
    #> ss[2, 50]         0.510 0.500          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 51]         0.461 0.498          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 52]         0.537 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 53]         0.804 0.397          0.014  0.000  1.000  1.000 1.012
    #> ss[2, 54]         0.575 0.494          0.009  0.000  1.000  1.000 1.002
    #> ss[2, 55]         0.411 0.492          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 56]         0.477 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 57]         0.608 0.488          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 58]         0.425 0.494          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 59]         0.441 0.497          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 60]         0.505 0.500          0.007  0.000  1.000  1.000 1.003
    #> ss[2, 61]         0.301 0.459          0.015  0.000  0.000  1.000 1.007
    #> ss[2, 62]         0.400 0.490          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 63]         0.485 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 64]         0.671 0.470          0.008  0.000  1.000  1.000 1.001
    #> ss[2, 65]         0.481 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 66]         0.620 0.485          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 67]         0.366 0.482          0.008  0.000  0.000  1.000 1.000
    #> ss[2, 68]         0.393 0.488          0.009  0.000  0.000  1.000 1.001
    #> ss[2, 69]         0.448 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 70]         0.424 0.494          0.009  0.000  0.000  1.000 1.005
    #> ss[2, 71]         0.413 0.492          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 72]         0.388 0.487          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 73]         0.461 0.498          0.016  0.000  0.000  1.000 1.014
    #> ss[2, 74]         0.476 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 75]         0.469 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 76]         0.465 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 77]         0.461 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 78]         0.452 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 79]         0.398 0.489          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 80]         0.509 0.500          0.005  0.000  1.000  1.000 1.000
    #> ss[2, 81]         0.504 0.500          0.008  0.000  1.000  1.000 1.005
    #> ss[2, 82]         0.526 0.499          0.008  0.000  1.000  1.000 1.001
    #> ss[2, 83]         0.483 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 84]         0.505 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 85]         0.461 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 86]         0.482 0.500          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 87]         0.741 0.438          0.012  0.000  1.000  1.000 1.009
    #> ss[2, 88]         0.494 0.500          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 89]         0.528 0.499          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 90]         0.498 0.500          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 91]         0.446 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 92]         0.696 0.460          0.012  0.000  1.000  1.000 1.008
    #> ss[2, 93]         0.453 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 94]         0.487 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 95]         0.724 0.447          0.010  0.000  1.000  1.000 1.002
    #> ss[2, 96]         0.424 0.494          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 97]         0.369 0.483          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 98]         0.460 0.498          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 99]         0.535 0.499          0.006  0.000  1.000  1.000 0.999
    #> ss[2, 100]        0.458 0.498          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 101]        0.426 0.495          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 102]        0.522 0.500          0.016  0.000  1.000  1.000 1.007
    #> ss[2, 103]        0.400 0.490          0.009  0.000  0.000  1.000 1.001
    #> ss[2, 104]        0.446 0.497          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 105]        0.484 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 106]        0.417 0.493          0.014  0.000  0.000  1.000 1.002
    #> ss[2, 107]        0.528 0.499          0.007  0.000  1.000  1.000 1.002
    #> ss[2, 108]        0.566 0.496          0.021  0.000  1.000  1.000 1.006
    #> ss[2, 109]        0.529 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 110]        0.369 0.482          0.009  0.000  0.000  1.000 1.000
    #> ss[2, 111]        0.451 0.498          0.011  0.000  0.000  1.000 1.002
    #> ss[2, 112]        0.468 0.499          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 113]        0.613 0.487          0.007  0.000  1.000  1.000 1.003
    #> ss[2, 114]        0.887 0.316          0.008  0.000  1.000  1.000 1.004
    #> ss[2, 115]        0.844 0.363          0.013  0.000  1.000  1.000 1.020
    #> ss[2, 116]        0.446 0.497          0.012  0.000  0.000  1.000 1.001
    #> ss[2, 117]        0.454 0.498          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 118]        0.396 0.489          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 119]        0.486 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 120]        0.546 0.498          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 121]        0.371 0.483          0.008  0.000  0.000  1.000 1.007
    #> ss[2, 122]        0.573 0.495          0.017  0.000  1.000  1.000 1.015
    #> ss[2, 123]        0.559 0.497          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 124]        0.728 0.445          0.009  0.000  1.000  1.000 1.000
    #> ss[2, 125]        0.487 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 126]        0.512 0.500          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 127]        0.559 0.496          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 128]        0.497 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 129]        0.427 0.495          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 130]        0.455 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 131]        0.560 0.496          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 132]        0.414 0.493          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 133]        0.385 0.487          0.007  0.000  0.000  1.000 1.003
    #> ss[2, 134]        0.508 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 135]        0.433 0.495          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 136]        0.420 0.494          0.007  0.000  0.000  1.000 1.003
    #> ss[2, 137]        0.434 0.496          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 138]        0.444 0.497          0.007  0.000  0.000  1.000 1.004
    #> ss[2, 139]        0.429 0.495          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 140]        0.562 0.496          0.006  0.000  1.000  1.000 1.002
    #> ss[2, 141]        0.549 0.498          0.006  0.000  1.000  1.000 0.999
    #> ss[2, 142]        0.483 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 143]        0.414 0.492          0.007  0.000  0.000  1.000 1.003
    #> ss[2, 144]        0.477 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 145]        0.484 0.500          0.009  0.000  0.000  1.000 1.005
    #> ss[2, 146]        0.443 0.497          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 147]        0.501 0.500          0.006  0.000  1.000  1.000 0.999
    #> ss[2, 148]        0.617 0.486          0.006  0.000  1.000  1.000 1.002
    #> ss[2, 149]        0.696 0.460          0.007  0.000  1.000  1.000 1.003
    #> ss[2, 150]        0.415 0.493          0.008  0.000  0.000  1.000 1.000
    #> ss[2, 151]        0.479 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 152]        0.460 0.498          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 153]        0.756 0.429          0.010  0.000  1.000  1.000 1.004
    #> ss[2, 154]        0.385 0.487          0.008  0.000  0.000  1.000 1.005
    #> ss[2, 155]        0.446 0.497          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 156]        0.538 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 157]        0.528 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 158]        0.478 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 159]        0.482 0.500          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 160]        0.518 0.500          0.006  0.000  1.000  1.000 0.999
    #> zeta[1]          -0.230 0.009          0.000 -0.248 -0.230 -0.214 1.010
    #> zeta[2]           0.031 0.009          0.000  0.013  0.031  0.048 1.003
    #> zeta[3]           0.141 0.035          0.001  0.073  0.141  0.208 1.015
    #> zeta[4]           0.068 0.032          0.001  0.004  0.069  0.129 1.007
    #> 
    #> WAIC: 27043.97 
    #> elppd: -13362.98 
    #> pWAIC: 159.0092

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
