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

    # Calculate school-level SES
    school_ses <- saeb[, .(school_ses = mean(student_ses, na.rm = TRUE)), by = school_id]

    # Join the school_ses back to the original dataset
    saeb <- saeb[school_ses, on = "school_id"]

    # Grand mean center school ses
    saeb$school_ses <- c(scale(saeb$school_ses, scale = FALSE))

    head(saeb )
    #>    school_id public student_ses math_proficiency location school_ses i.school_ses i.school_ses.1
    #>        <num>  <int>       <num>            <num>    <int>      <num>        <num>          <num>
    #> 1:         1      1        3.81         0.094789        1 -0.3717212     4.557222       4.557222
    #> 2:         1      1        4.59         1.518185        1 -0.3717212     4.557222       4.557222
    #> 3:         1      1        5.21        -0.474808        1 -0.3717212     4.557222       4.557222
    #> 4:         1      1        6.10         0.187490        1 -0.3717212     4.557222       4.557222
    #> 5:         1      1        5.37         0.730355        1 -0.3717212     4.557222       4.557222
    #> 6:         1      1        4.51         0.585839        1 -0.3717212     4.557222       4.557222

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
    #> R[2, 1]          -0.818 0.171          0.038 -0.989 -0.878 -0.349 1.423
    #> beta[1]          -0.269 0.053          0.006 -0.377 -0.267 -0.171 1.172
    #> beta[2]           0.081 0.010          0.001  0.063  0.081  0.101 1.134
    #> beta[3]           0.647 0.211          0.023  0.241  0.643  1.061 1.049
    #> beta[4]          -0.011 0.039          0.004 -0.086 -0.009  0.066 1.041
    #> sigma_rand[1, 1]  0.205 0.022          0.003  0.170  0.202  0.258 1.267
    #> sigma_rand[2, 2]  0.199 0.116          0.019  0.072  0.167  0.551 1.243
    #> ss[2, 1]          0.472 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 2]          0.482 0.500          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 3]          0.463 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 4]          0.495 0.500          0.009  0.000  0.000  1.000 1.003
    #> ss[2, 5]          0.539 0.498          0.011  0.000  1.000  1.000 1.005
    #> ss[2, 6]          0.428 0.495          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 7]          0.406 0.491          0.010  0.000  0.000  1.000 1.001
    #> ss[2, 8]          0.454 0.498          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 9]          0.990 0.100          0.004  1.000  1.000  1.000 1.001
    #> ss[2, 10]         0.440 0.496          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 11]         0.552 0.497          0.007  0.000  1.000  1.000 1.002
    #> ss[2, 12]         0.373 0.484          0.008  0.000  0.000  1.000 1.000
    #> ss[2, 13]         0.478 0.500          0.015  0.000  0.000  1.000 1.011
    #> ss[2, 14]         0.615 0.487          0.012  0.000  1.000  1.000 1.001
    #> ss[2, 15]         0.506 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 16]         0.472 0.499          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 17]         0.441 0.497          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 18]         0.524 0.499          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 19]         0.269 0.444          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 20]         0.513 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 21]         0.380 0.485          0.010  0.000  0.000  1.000 1.003
    #> ss[2, 22]         0.560 0.496          0.009  0.000  1.000  1.000 1.000
    #> ss[2, 23]         0.491 0.500          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 24]         0.472 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 25]         0.460 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 26]         0.520 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 27]         0.445 0.497          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 28]         0.405 0.491          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 29]         0.483 0.500          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 30]         0.446 0.497          0.012  0.000  0.000  1.000 1.002
    #> ss[2, 31]         0.470 0.499          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 32]         0.482 0.500          0.011  0.000  0.000  1.000 1.007
    #> ss[2, 33]         0.494 0.500          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 34]         0.514 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 35]         0.680 0.467          0.011  0.000  1.000  1.000 1.006
    #> ss[2, 36]         0.379 0.485          0.011  0.000  0.000  1.000 1.007
    #> ss[2, 37]         0.452 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 38]         0.452 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 39]         0.739 0.439          0.022  0.000  1.000  1.000 1.051
    #> ss[2, 40]         0.455 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 41]         0.689 0.463          0.021  0.000  1.000  1.000 1.024
    #> ss[2, 42]         0.456 0.498          0.008  0.000  0.000  1.000 1.000
    #> ss[2, 43]         0.403 0.491          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 44]         0.432 0.495          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 45]         0.446 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 46]         0.999 0.025          0.000  1.000  1.000  1.000 1.001
    #> ss[2, 47]         0.476 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 48]         0.600 0.490          0.008  0.000  1.000  1.000 1.010
    #> ss[2, 49]         0.497 0.500          0.012  0.000  0.000  1.000 1.002
    #> ss[2, 50]         0.508 0.500          0.006  0.000  1.000  1.000 0.999
    #> ss[2, 51]         0.461 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 52]         0.537 0.499          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 53]         0.837 0.369          0.018  0.000  1.000  1.000 1.006
    #> ss[2, 54]         0.620 0.485          0.010  0.000  1.000  1.000 1.002
    #> ss[2, 55]         0.407 0.491          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 56]         0.454 0.498          0.007  0.000  0.000  1.000 1.003
    #> ss[2, 57]         0.629 0.483          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 58]         0.418 0.493          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 59]         0.437 0.496          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 60]         0.523 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 61]         0.267 0.443          0.017  0.000  0.000  1.000 1.016
    #> ss[2, 62]         0.426 0.495          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 63]         0.502 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 64]         0.738 0.440          0.008  0.000  1.000  1.000 1.001
    #> ss[2, 65]         0.492 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 66]         0.647 0.478          0.008  0.000  1.000  1.000 1.000
    #> ss[2, 67]         0.370 0.483          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 68]         0.378 0.485          0.011  0.000  0.000  1.000 1.003
    #> ss[2, 69]         0.460 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 70]         0.426 0.495          0.011  0.000  0.000  1.000 1.004
    #> ss[2, 71]         0.392 0.488          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 72]         0.396 0.489          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 73]         0.446 0.497          0.017  0.000  0.000  1.000 1.012
    #> ss[2, 74]         0.516 0.500          0.007  0.000  1.000  1.000 1.004
    #> ss[2, 75]         0.465 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 76]         0.453 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 77]         0.454 0.498          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 78]         0.445 0.497          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 79]         0.398 0.489          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 80]         0.500 0.500          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 81]         0.470 0.499          0.009  0.000  0.000  1.000 1.004
    #> ss[2, 82]         0.524 0.499          0.008  0.000  1.000  1.000 1.000
    #> ss[2, 83]         0.492 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 84]         0.516 0.500          0.006  0.000  1.000  1.000 0.999
    #> ss[2, 85]         0.466 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 86]         0.528 0.499          0.008  0.000  1.000  1.000 1.000
    #> ss[2, 87]         0.730 0.444          0.014  0.000  1.000  1.000 1.012
    #> ss[2, 88]         0.491 0.500          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 89]         0.522 0.500          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 90]         0.481 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 91]         0.442 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 92]         0.700 0.458          0.017  0.000  1.000  1.000 1.010
    #> ss[2, 93]         0.454 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 94]         0.481 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 95]         0.750 0.433          0.010  0.000  1.000  1.000 1.004
    #> ss[2, 96]         0.442 0.497          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 97]         0.353 0.478          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 98]         0.460 0.498          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 99]         0.554 0.497          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 100]        0.443 0.497          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 101]        0.430 0.495          0.009  0.000  0.000  1.000 1.000
    #> ss[2, 102]        0.444 0.497          0.019  0.000  0.000  1.000 1.010
    #> ss[2, 103]        0.391 0.488          0.009  0.000  0.000  1.000 1.004
    #> ss[2, 104]        0.448 0.497          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 105]        0.477 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 106]        0.456 0.498          0.017  0.000  0.000  1.000 1.010
    #> ss[2, 107]        0.501 0.500          0.007  0.000  1.000  1.000 1.003
    #> ss[2, 108]        0.598 0.490          0.020  0.000  1.000  1.000 1.003
    #> ss[2, 109]        0.524 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 110]        0.359 0.480          0.010  0.000  0.000  1.000 1.004
    #> ss[2, 111]        0.425 0.494          0.012  0.000  0.000  1.000 1.002
    #> ss[2, 112]        0.457 0.498          0.009  0.000  0.000  1.000 1.005
    #> ss[2, 113]        0.613 0.487          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 114]        0.894 0.307          0.011  0.000  1.000  1.000 1.008
    #> ss[2, 115]        0.803 0.397          0.012  0.000  1.000  1.000 1.005
    #> ss[2, 116]        0.412 0.492          0.012  0.000  0.000  1.000 1.003
    #> ss[2, 117]        0.442 0.497          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 118]        0.397 0.489          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 119]        0.497 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 120]        0.572 0.495          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 121]        0.345 0.475          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 122]        0.602 0.490          0.019  0.000  1.000  1.000 1.012
    #> ss[2, 123]        0.564 0.496          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 124]        0.751 0.433          0.008  0.000  1.000  1.000 1.001
    #> ss[2, 125]        0.465 0.499          0.008  0.000  0.000  1.000 1.001
    #> ss[2, 126]        0.514 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 127]        0.558 0.497          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 128]        0.519 0.500          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 129]        0.415 0.493          0.006  0.000  0.000  1.000 0.999
    #> ss[2, 130]        0.455 0.498          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 131]        0.550 0.498          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 132]        0.414 0.493          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 133]        0.355 0.478          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 134]        0.517 0.500          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 135]        0.426 0.494          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 136]        0.415 0.493          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 137]        0.438 0.496          0.009  0.000  0.000  1.000 1.006
    #> ss[2, 138]        0.434 0.496          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 139]        0.425 0.494          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 140]        0.571 0.495          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 141]        0.498 0.500          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 142]        0.478 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 143]        0.401 0.490          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 144]        0.468 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 145]        0.457 0.498          0.007  0.000  0.000  1.000 1.002
    #> ss[2, 146]        0.460 0.498          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 147]        0.481 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 148]        0.635 0.481          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 149]        0.714 0.452          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 150]        0.392 0.488          0.010  0.000  0.000  1.000 1.003
    #> ss[2, 151]        0.478 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 152]        0.466 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 153]        0.783 0.412          0.008  0.000  1.000  1.000 1.003
    #> ss[2, 154]        0.376 0.484          0.009  0.000  0.000  1.000 1.001
    #> ss[2, 155]        0.418 0.493          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 156]        0.613 0.487          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 157]        0.524 0.499          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 158]        0.464 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 159]        0.480 0.500          0.007  0.000  0.000  1.000 0.999
    #> ss[2, 160]        0.510 0.500          0.006  0.000  1.000  1.000 1.000
    #> zeta[1]          -0.390 0.046          0.010 -0.479 -0.386 -0.310 1.423
    #> zeta[2]           0.031 0.009          0.002  0.015  0.030  0.048 1.409
    #> zeta[3]          -0.187 0.160          0.029 -0.518 -0.197  0.150 1.583
    #> zeta[4]           0.056 0.032          0.006 -0.013  0.058  0.121 1.541
    #> 
    #> WAIC: 27043.62 
    #> elppd: -13363.19 
    #> pWAIC: 158.6218

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip")

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" /> \###
PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### PIP vs. math achievement

    avg_df <- aggregate(math_proficiency ~ school_id, data = saeb, FUN = mean)
    avg_df$pip <- s_out[grep("^ss", rownames(s_out)), 1]

    ggplot(avg_df, aes(x = math_proficiency, y = pip)) +
      geom_point( aes(color = as.factor(school_id)), size = 3) +
      geom_text(data = subset(avg_df, pip >= 0.75),
                aes(label = school_id),
                nudge_x = -.1,
                size = 3) +
      geom_abline(intercept = 0.75, slope = 0, lty =  3)+
      geom_abline(intercept = 0.25, slope = 0, lty =  3)+
      ylim(c(0, 1 ) ) + 
      guides(color ="none") +
      labs(x = "Math achievement (z-standardized)",
           y = "pip")

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameters =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

    #> NULL

    codaplot(out, parameters =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

    #> NULL

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
