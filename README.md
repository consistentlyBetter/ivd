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
    #>    i.school_ses.2
    #>             <num>
    #> 1:       4.557222
    #> 2:       4.557222
    #> 3:       4.557222
    #> 4:       4.557222
    #> 5:       4.557222
    #> 6:       4.557222

Illustration of school level variability:

    plot0 <- ggplot( data = saeb, aes( x = school_id, y = math_proficiency) )
    plot0 + geom_point(aes(color =  school_id), show.legend =  FALSE)

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

## Estimate Model

We will predict `math_proficiency` which is a standardized variable
capturing math proficiency at the end of grade 12.

Both, location (means) and scale (residual variances) are modeled as a
function of student and school SES. Note that the formula objects for
both location and scale follow `lme4` notation.

    out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1|school_id),
               scale_formula =  ~ student_ses * school_ses + (1|school_id),
               data = saeb,
               niter = 5000, nburnin = 5000, WAIC = TRUE, workers = 4)
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
    #> List of 6
    #>  $ statistics: num [1:656, 1:4] 1 -0.712 -0.712 1 -0.297 ...
    #>   ..- attr(*, "dimnames")=List of 2
    #>   .. ..$ : chr [1:656] "R[1, 1]" "R[2, 1]" "R[1, 2]" "R[2, 2]" ...
    #>   .. ..$ : chr [1:4] "Mean" "SD" "Naive SE" "Time-series SE"
    #>  $ quantiles : num [1:656, 1:5] 1 -0.99 -0.99 1 -0.473 ...
    #>   ..- attr(*, "dimnames")=List of 2
    #>   .. ..$ : chr [1:656] "R[1, 1]" "R[2, 1]" "R[1, 2]" "R[2, 2]" ...
    #>   .. ..$ : chr [1:5] "2.5%" "25%" "50%" "75%" ...
    #>  $ start     : num 1
    #>  $ end       : num 20000
    #>  $ thin      : num 1
    #>  $ nchain    : num 1
    #>  - attr(*, "class")= chr "summary.mcmc"
    #> Summary statistics for ivd model:
    #> Chains/workers: 4 
    #> 
    #>                    Mean    SD Time-series SE   2.5%    50%  97.5% R-hat
    #> R[2, 1]          -0.712 0.258          0.059 -0.990 -0.784 -0.082 1.234
    #> beta[1]          -0.297 0.184          0.032 -0.473 -0.272 -0.155 1.040
    #> beta[2]           0.081 0.011          0.001  0.060  0.081  0.103 1.039
    #> beta[3]           0.624 0.311          0.030  0.059  0.654  1.050 1.045
    #> beta[4]          -0.012 0.039          0.002 -0.087 -0.013  0.067 1.037
    #> sigma_rand[1, 1]  0.240 0.164          0.032  0.173  0.211  0.476 1.097
    #> sigma_rand[2, 2]  0.187 0.144          0.022  0.064  0.131  0.608 1.249
    #> ss[2, 1]          0.470 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 2]          0.474 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 3]          0.443 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 4]          0.466 0.499          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 5]          0.527 0.499          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 6]          0.415 0.493          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 7]          0.428 0.495          0.006  0.000  0.000  1.000 1.002
    #> ss[2, 8]          0.461 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 9]          0.987 0.113          0.003  1.000  1.000  1.000 1.001
    #> ss[2, 10]         0.440 0.496          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 11]         0.548 0.498          0.005  0.000  1.000  1.000 1.001
    #> ss[2, 12]         0.381 0.486          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 13]         0.471 0.499          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 14]         0.609 0.488          0.008  0.000  1.000  1.000 1.001
    #> ss[2, 15]         0.499 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 16]         0.481 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 17]         0.439 0.496          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 18]         0.527 0.499          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 19]         0.296 0.456          0.007  0.000  0.000  1.000 1.003
    #> ss[2, 20]         0.528 0.499          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 21]         0.373 0.484          0.006  0.000  0.000  1.000 1.003
    #> ss[2, 22]         0.562 0.496          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 23]         0.486 0.500          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 24]         0.474 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 25]         0.450 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 26]         0.513 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 27]         0.446 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 28]         0.416 0.493          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 29]         0.481 0.500          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 30]         0.465 0.499          0.007  0.000  0.000  1.000 1.001
    #> ss[2, 31]         0.470 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 32]         0.509 0.500          0.007  0.000  1.000  1.000 1.000
    #> ss[2, 33]         0.481 0.500          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 34]         0.512 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 35]         0.675 0.468          0.008  0.000  1.000  1.000 1.003
    #> ss[2, 36]         0.415 0.493          0.008  0.000  0.000  1.000 1.003
    #> ss[2, 37]         0.457 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 38]         0.460 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 39]         0.734 0.442          0.015  0.000  1.000  1.000 1.005
    #> ss[2, 40]         0.444 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 41]         0.724 0.447          0.012  0.000  1.000  1.000 1.008
    #> ss[2, 42]         0.452 0.498          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 43]         0.397 0.489          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 44]         0.436 0.496          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 45]         0.447 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 46]         0.999 0.035          0.000  1.000  1.000  1.000 1.000
    #> ss[2, 47]         0.464 0.499          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 48]         0.585 0.493          0.006  0.000  1.000  1.000 1.000
    #> ss[2, 49]         0.478 0.500          0.009  0.000  0.000  1.000 1.002
    #> ss[2, 50]         0.519 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 51]         0.461 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 52]         0.533 0.499          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 53]         0.849 0.358          0.008  0.000  1.000  1.000 1.002
    #> ss[2, 54]         0.606 0.489          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 55]         0.412 0.492          0.004  0.000  0.000  1.000 1.002
    #> ss[2, 56]         0.458 0.498          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 57]         0.617 0.486          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 58]         0.426 0.495          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 59]         0.445 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 60]         0.509 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 61]         0.290 0.454          0.009  0.000  0.000  1.000 1.002
    #> ss[2, 62]         0.422 0.494          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 63]         0.485 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 64]         0.720 0.449          0.005  0.000  1.000  1.000 1.002
    #> ss[2, 65]         0.477 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 66]         0.631 0.483          0.005  0.000  1.000  1.000 1.000
    #> ss[2, 67]         0.365 0.481          0.005  0.000  0.000  1.000 1.002
    #> ss[2, 68]         0.395 0.489          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 69]         0.453 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 70]         0.442 0.497          0.007  0.000  0.000  1.000 1.000
    #> ss[2, 71]         0.416 0.493          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 72]         0.391 0.488          0.005  0.000  0.000  1.000 1.002
    #> ss[2, 73]         0.463 0.499          0.010  0.000  0.000  1.000 1.004
    #> ss[2, 74]         0.509 0.500          0.005  0.000  1.000  1.000 1.001
    #> ss[2, 75]         0.467 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 76]         0.459 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 77]         0.449 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 78]         0.441 0.496          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 79]         0.399 0.490          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 80]         0.504 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 81]         0.463 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 82]         0.516 0.500          0.006  0.000  1.000  1.000 1.001
    #> ss[2, 83]         0.481 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 84]         0.503 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 85]         0.464 0.499          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 86]         0.521 0.500          0.005  0.000  1.000  1.000 1.001
    #> ss[2, 87]         0.747 0.435          0.009  0.000  1.000  1.000 1.003
    #> ss[2, 88]         0.482 0.500          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 89]         0.510 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 90]         0.489 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 91]         0.448 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 92]         0.720 0.449          0.010  0.000  1.000  1.000 1.006
    #> ss[2, 93]         0.453 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 94]         0.484 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 95]         0.758 0.428          0.007  0.000  1.000  1.000 1.001
    #> ss[2, 96]         0.428 0.495          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 97]         0.373 0.484          0.005  0.000  0.000  1.000 1.002
    #> ss[2, 98]         0.457 0.498          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 99]         0.560 0.496          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 100]        0.448 0.497          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 101]        0.430 0.495          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 102]        0.498 0.500          0.010  0.000  0.000  1.000 1.004
    #> ss[2, 103]        0.389 0.488          0.005  0.000  0.000  1.000 1.002
    #> ss[2, 104]        0.436 0.496          0.004  0.000  0.000  1.000 1.002
    #> ss[2, 105]        0.485 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 106]        0.444 0.497          0.011  0.000  0.000  1.000 1.003
    #> ss[2, 107]        0.501 0.500          0.005  0.000  1.000  1.000 1.000
    #> ss[2, 108]        0.580 0.494          0.014  0.000  1.000  1.000 1.007
    #> ss[2, 109]        0.532 0.499          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 110]        0.370 0.483          0.006  0.000  0.000  1.000 1.000
    #> ss[2, 111]        0.424 0.494          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 112]        0.469 0.499          0.006  0.000  0.000  1.000 1.001
    #> ss[2, 113]        0.599 0.490          0.004  0.000  1.000  1.000 1.001
    #> ss[2, 114]        0.907 0.291          0.006  0.000  1.000  1.000 1.002
    #> ss[2, 115]        0.769 0.421          0.011  0.000  1.000  1.000 1.011
    #> ss[2, 116]        0.400 0.490          0.008  0.000  0.000  1.000 1.002
    #> ss[2, 117]        0.439 0.496          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 118]        0.393 0.489          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 119]        0.495 0.500          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 120]        0.550 0.498          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 121]        0.366 0.482          0.005  0.000  0.000  1.000 1.000
    #> ss[2, 122]        0.597 0.490          0.011  0.000  1.000  1.000 1.007
    #> ss[2, 123]        0.554 0.497          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 124]        0.746 0.435          0.005  0.000  1.000  1.000 1.002
    #> ss[2, 125]        0.478 0.500          0.005  0.000  0.000  1.000 1.001
    #> ss[2, 126]        0.498 0.500          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 127]        0.566 0.496          0.004  0.000  1.000  1.000 1.001
    #> ss[2, 128]        0.511 0.500          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 129]        0.421 0.494          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 130]        0.458 0.498          0.004  0.000  0.000  1.000 1.000
    #> ss[2, 131]        0.541 0.498          0.004  0.000  1.000  1.000 1.000
    #> ss[2, 132]        0.414 0.493          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 133]        0.384 0.486          0.004  0.000  0.000  1.000 1.001
    #> ss[2, 134]        0.518 0.500          0.005  0.000  1.000  1.000 1.000
    #> ss[2, 135]        0.427 0.495          0.004  0.000  0.000  1.000 1.000
    #>  [ reached getOption("max.print") -- omitted 29 rows ]
    #> 
    #> WAIC: 27045.53 
    #> elppd: -13360.63 
    #> pWAIC: 162.1385

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip" )

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" /> \###
PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### PIP vs. math achievement

    plot(out, type =  "outcome")

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameter =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

    #> NULL

    codaplot(out, parameter =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

    #> NULL

# References

Rodriguez, J. E., Williams, D. R., & Rast, P. (2024). Who is and is not"
average’"? Random effects selection with spike-and-slab priors.
*Psychological Methods*. <https://doi.org/10.1037/met0000535>

Williams, D. R., Martin, S. R., & Rast, P. (2022). Putting the
individual into reliability: Bayesian testing of homogeneous
within-person variance in hierarchical models. *Behavior Research
Methods*, *54*(3), 1272–1290.
<https://doi.org/10.3758/s13428-021-01646-x>
