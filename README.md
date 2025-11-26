<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- knit with rmarkdown::render("README.Rmd", output_format = "md_document") -->

<img src="man/figures/logo.png" align="right" height="120" alt="" /> \#
Individual Variance Detection

<!-- badges: start -->

[![R-CMD-check](https://github.com/consistentlyBetter/ivd/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/consistentlyBetter/ivd/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/consistentlyBetter/ivd/graph/badge.svg?token=SD0PM5BVIL)](https://app.codecov.io/gh/consistentlyBetter/ivd)
<!-- badges: end -->

*ivd* is an R package for random effects selection in the scale part of
Mixed Effects Location Scale Modlels (MELSM). `ivd()` fits a random
intercepts model with a spike-and-slab prior on the random effects of
the scale.

## Installation

This package can be installed with

    # install.packages("devtools")
    # devtools::install_github("consistentlybetter/ivd")

## Example

    library(ivd)
    library(data.table)

## Data

The illustration uses openly accessible data from The Basic Education
Evaluation System (Saeb) conducted by Brazil’s National Institute for
Educational Studies and Research (Inep), available at
<https://web.archive.org/web/20250202015037/https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/saeb/resultados>.
It is also available as the `saeb` dataset in the `ivd` package.

Separate within- from between-school effects. That is, besides
`student_ses`, compute `school_ses`.

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

    out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1 | school_id),
               scale_formula =  ~ student_ses * school_ses + (1 | school_id),
               data = saeb,
               niter = 1000, nburnin = 6000)
    #> ===== Monitors =====
    #> thin = 1: beta, sigma_rand, ss, Ustar, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - Ustar[1:2, 1:2] 
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
    #>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
    #>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, sigma_rand, ss, Ustar, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - Ustar[1:2, 1:2] 
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
    #>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
    #>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, sigma_rand, ss, Ustar, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - Ustar[1:2, 1:2] 
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
    #>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
    #>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, sigma_rand, ss, Ustar, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - Ustar[1:2, 1:2] 
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
    #>   [Note] 'Z' is provided in 'data' but is not a variable in the model and is being ignored.
    #>   [Note] 'Z_scale' is provided in 'data' but is not a variable in the model and is being ignored.
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
    #> Chains (workers): 4 
    #> 
    #>                              Mean    SD Time-series SE   2.5%    50%  97.5% n_eff R-hat
    #> R[scl_Intc, Intc]          -0.659 0.172          0.012 -0.946 -0.677 -0.264   135 1.017
    #> Intc                        0.129 0.024          0.003  0.082  0.130  0.176    49 1.038
    #> student_ses                 0.082 0.010          0.000  0.063  0.082  0.101  2466 1.001
    #> school_ses                  0.753 0.089          0.009  0.580  0.751  0.928    65 1.096
    #> student_ses:school_ses     -0.036 0.038          0.001 -0.112 -0.036  0.038  1193 1.002
    #> sd_Intc                     0.269 0.020          0.002  0.236  0.268  0.312    82 1.056
    #> sd_scl_Intc                 0.077 0.014          0.001  0.049  0.076  0.106   143 1.012
    #> pip[Intc, 1]                0.468 0.499          0.008  0.000  0.000  1.000  2864 1.000
    #> pip[Intc, 2]                0.482 0.500          0.008  0.000  0.000  1.000  4304 0.999
    #> pip[Intc, 3]                0.459 0.498          0.009  0.000  0.000  1.000  3505 1.000
    #> pip[Intc, 4]                0.495 0.500          0.009  0.000  0.000  1.000  2441 1.001
    #> pip[Intc, 5]                0.519 0.500          0.009  0.000  1.000  1.000  2177 1.000
    #> pip[Intc, 6]                0.443 0.497          0.008  0.000  0.000  1.000  3639 1.000
    #> pip[Intc, 7]                0.402 0.490          0.010  0.000  0.000  1.000  1394 1.000
    #> pip[Intc, 8]                0.483 0.500          0.008  0.000  0.000  1.000  3410 1.000
    #> pip[Intc, 9]                0.980 0.140          0.005  1.000  1.000  1.000   612 1.006
    #> pip[Intc, 10]               0.444 0.497          0.008  0.000  0.000  1.000  3977 0.999
    #> pip[Intc, 11]               0.576 0.494          0.010  0.000  1.000  1.000  2601 1.000
    #> pip[Intc, 12]               0.370 0.483          0.008  0.000  0.000  1.000  2616 1.000
    #> pip[Intc, 13]               0.470 0.499          0.010  0.000  0.000  1.000  2436 1.000
    #> pip[Intc, 14]               0.615 0.487          0.013  0.000  1.000  1.000  1298 1.003
    #> pip[Intc, 15]               0.509 0.500          0.008  0.000  1.000  1.000  4422 1.001
    #> pip[Intc, 16]               0.478 0.500          0.008  0.000  0.000  1.000  5244 1.000
    #> pip[Intc, 17]               0.429 0.495          0.009  0.000  0.000  1.000  2220 1.000
    #> pip[Intc, 18]               0.541 0.498          0.008  0.000  1.000  1.000  2661 1.000
    #> pip[Intc, 19]               0.260 0.439          0.010  0.000  0.000  1.000  1760 1.001
    #> pip[Intc, 20]               0.531 0.499          0.008  0.000  1.000  1.000  3615 1.001
    #> pip[Intc, 21]               0.371 0.483          0.010  0.000  0.000  1.000  1313 1.000
    #> pip[Intc, 22]               0.565 0.496          0.010  0.000  1.000  1.000  2713 1.002
    #> pip[Intc, 23]               0.495 0.500          0.009  0.000  0.000  1.000  2919 1.000
    #> pip[Intc, 24]               0.489 0.500          0.008  0.000  0.000  1.000  3719 0.999
    #> pip[Intc, 25]               0.462 0.499          0.008  0.000  0.000  1.000  4512 1.000
    #> pip[Intc, 26]               0.506 0.500          0.008  0.000  1.000  1.000  3151 1.000
    #> pip[Intc, 27]               0.460 0.498          0.009  0.000  0.000  1.000  3611 1.000
    #> pip[Intc, 28]               0.398 0.490          0.009  0.000  0.000  1.000  3267 1.001
    #> pip[Intc, 29]               0.487 0.500          0.009  0.000  0.000  1.000  3601 1.000
    #> pip[Intc, 30]               0.440 0.496          0.010  0.000  0.000  1.000  2689 1.000
    #> pip[Intc, 31]               0.476 0.499          0.008  0.000  0.000  1.000  3012 1.000
    #> pip[Intc, 32]               0.488 0.500          0.010  0.000  0.000  1.000  2311 1.000
    #> pip[Intc, 33]               0.491 0.500          0.009  0.000  0.000  1.000  1722 1.000
    #> pip[Intc, 34]               0.587 0.492          0.008  0.000  1.000  1.000  3476 0.999
    #> pip[Intc, 35]               0.644 0.479          0.012  0.000  1.000  1.000   643 1.003
    #> pip[Intc, 36]               0.364 0.481          0.012  0.000  0.000  1.000  1428 1.001
    #> pip[Intc, 37]               0.476 0.499          0.008  0.000  0.000  1.000  3883 1.001
    #> pip[Intc, 38]               0.432 0.495          0.008  0.000  0.000  1.000  3967 1.000
    #> pip[Intc, 39]               0.739 0.439          0.017  0.000  1.000  1.000   231 1.008
    #> pip[Intc, 40]               0.466 0.499          0.008  0.000  0.000  1.000  2991 1.000
    #> pip[Intc, 41]               0.662 0.473          0.018  0.000  1.000  1.000   628 1.006
    #> pip[Intc, 42]               0.467 0.499          0.009  0.000  0.000  1.000  3458 1.000
    #> pip[Intc, 43]               0.410 0.492          0.009  0.000  0.000  1.000  3101 0.999
    #> pip[Intc, 44]               0.440 0.496          0.008  0.000  0.000  1.000  3499 1.000
    #> pip[Intc, 45]               0.426 0.494          0.008  0.000  0.000  1.000  3502 1.001
    #> pip[Intc, 46]               0.998 0.042          0.001  1.000  1.000  1.000  2620 1.000
    #> pip[Intc, 47]               0.479 0.500          0.008  0.000  0.000  1.000  3566 1.000
    #> pip[Intc, 48]               0.623 0.485          0.009  0.000  1.000  1.000  3266 1.000
    #> pip[Intc, 49]               0.524 0.499          0.013  0.000  1.000  1.000  1210 1.005
    #> pip[Intc, 50]               0.519 0.500          0.008  0.000  1.000  1.000  3912 1.000
    #> pip[Intc, 51]               0.461 0.499          0.008  0.000  0.000  1.000  3811 1.000
    #> pip[Intc, 52]               0.543 0.498          0.008  0.000  1.000  1.000  3180 0.999
    #> pip[Intc, 53]               0.829 0.376          0.010  0.000  1.000  1.000  1567 1.001
    #> pip[Intc, 54]               0.597 0.491          0.009  0.000  1.000  1.000  2746 1.001
    #> pip[Intc, 55]               0.408 0.492          0.008  0.000  0.000  1.000  2827 1.000
    #> pip[Intc, 56]               0.477 0.500          0.009  0.000  0.000  1.000  3273 1.000
    #> pip[Intc, 57]               0.611 0.488          0.008  0.000  1.000  1.000  3604 1.000
    #> pip[Intc, 58]               0.416 0.493          0.009  0.000  0.000  1.000  1093 1.001
    #> pip[Intc, 59]               0.432 0.495          0.008  0.000  0.000  1.000  4394 1.001
    #> pip[Intc, 60]               0.512 0.500          0.009  0.000  1.000  1.000  3043 1.000
    #> pip[Intc, 61]               0.301 0.459          0.010  0.000  0.000  1.000  1613 1.000
    #> pip[Intc, 62]               0.428 0.495          0.009  0.000  0.000  1.000  3201 1.000
    #> pip[Intc, 63]               0.501 0.500          0.008  0.000  1.000  1.000  3662 0.999
    #> pip[Intc, 64]               0.673 0.469          0.009  0.000  1.000  1.000  2949 1.001
    #> pip[Intc, 65]               0.510 0.500          0.008  0.000  1.000  1.000  4009 1.000
    #> pip[Intc, 66]               0.628 0.483          0.010  0.000  1.000  1.000  1622 1.000
    #> pip[Intc, 67]               0.369 0.483          0.009  0.000  0.000  1.000  2463 1.000
    #> pip[Intc, 68]               0.368 0.482          0.009  0.000  0.000  1.000  2315 1.001
    #> pip[Intc, 69]               0.447 0.497          0.008  0.000  0.000  1.000  3411 1.000
    #> pip[Intc, 70]               0.388 0.487          0.011  0.000  0.000  1.000  1515 1.002
    #> pip[Intc, 71]               0.377 0.485          0.009  0.000  0.000  1.000  3173 0.999
    #> pip[Intc, 72]               0.403 0.491          0.009  0.000  0.000  1.000  2217 1.001
    #> pip[Intc, 73]               0.389 0.488          0.014  0.000  0.000  1.000  1081 1.000
    #> pip[Intc, 74]               0.477 0.500          0.008  0.000  0.000  1.000  3920 1.000
    #> pip[Intc, 75]               0.469 0.499          0.008  0.000  0.000  1.000  4021 1.001
    #> pip[Intc, 76]               0.464 0.499          0.008  0.000  0.000  1.000  3986 1.000
    #> pip[Intc, 77]               0.456 0.498          0.011  0.000  0.000  1.000  1825 1.000
    #> pip[Intc, 78]               0.448 0.497          0.008  0.000  0.000  1.000  3851 1.001
    #> pip[Intc, 79]               0.402 0.490          0.008  0.000  0.000  1.000  3029 1.000
    #> pip[Intc, 80]               0.499 0.500          0.008  0.000  0.000  1.000  5631 1.000
    #> pip[Intc, 81]               0.522 0.500          0.009  0.000  1.000  1.000  3309 1.000
    #> pip[Intc, 82]               0.528 0.499          0.010  0.000  1.000  1.000  2846 1.001
    #> pip[Intc, 83]               0.482 0.500          0.008  0.000  0.000  1.000  4271 1.000
    #> pip[Intc, 84]               0.497 0.500          0.008  0.000  0.000  1.000  3408 1.000
    #> pip[Intc, 85]               0.466 0.499          0.008  0.000  0.000  1.000  3625 1.000
    #> pip[Intc, 86]               0.487 0.500          0.010  0.000  0.000  1.000  2085 0.999
    #> pip[Intc, 87]               0.713 0.452          0.012  0.000  1.000  1.000  1309 1.004
    #> pip[Intc, 88]               0.476 0.499          0.009  0.000  0.000  1.000  2538 1.000
    #> pip[Intc, 89]               0.535 0.499          0.008  0.000  1.000  1.000  4741 1.001
    #> pip[Intc, 90]               0.500 0.500          0.008  0.000  0.000  1.000  3440 1.000
    #> pip[Intc, 91]               0.430 0.495          0.008  0.000  0.000  1.000  2614 1.001
    #> pip[Intc, 92]               0.703 0.457          0.011  0.000  1.000  1.000  1493 1.000
    #> pip[Intc, 93]               0.439 0.496          0.008  0.000  0.000  1.000  3724 1.001
    #> pip[Intc, 94]               0.485 0.500          0.008  0.000  0.000  1.000  3591 1.000
    #> pip[Intc, 95]               0.729 0.445          0.009  0.000  1.000  1.000  1997 1.001
    #> pip[Intc, 96]               0.453 0.498          0.008  0.000  0.000  1.000  3484 1.000
    #> pip[Intc, 97]               0.360 0.480          0.009  0.000  0.000  1.000  3129 1.002
    #> pip[Intc, 98]               0.467 0.499          0.010  0.000  0.000  1.000  2464 1.001
    #> pip[Intc, 99]               0.550 0.498          0.008  0.000  1.000  1.000  3663 1.002
    #> pip[Intc, 100]              0.448 0.497          0.008  0.000  0.000  1.000  3470 0.999
    #> pip[Intc, 101]              0.442 0.497          0.009  0.000  0.000  1.000  2902 1.001
    #> pip[Intc, 102]              0.515 0.500          0.012  0.000  1.000  1.000  1405 1.001
    #> pip[Intc, 103]              0.368 0.482          0.009  0.000  0.000  1.000  2961 1.001
    #> pip[Intc, 104]              0.450 0.498          0.008  0.000  0.000  1.000  4608 1.000
    #> pip[Intc, 105]              0.488 0.500          0.008  0.000  0.000  1.000  4520 1.000
    #> pip[Intc, 106]              0.420 0.494          0.010  0.000  0.000  1.000  2130 1.000
    #> pip[Intc, 107]              0.544 0.498          0.008  0.000  1.000  1.000  3017 1.000
    #> pip[Intc, 108]              0.548 0.498          0.015  0.000  1.000  1.000  1039 1.002
    #> pip[Intc, 109]              0.552 0.497          0.008  0.000  1.000  1.000  4418 1.001
    #> pip[Intc, 110]              0.388 0.487          0.009  0.000  0.000  1.000  2888 1.000
    #> pip[Intc, 111]              0.452 0.498          0.010  0.000  0.000  1.000  2069 1.003
    #> pip[Intc, 112]              0.464 0.499          0.011  0.000  0.000  1.000  1876 1.000
    #> pip[Intc, 113]              0.629 0.483          0.009  0.000  1.000  1.000  2737 1.000
    #> pip[Intc, 114]              0.896 0.306          0.007  0.000  1.000  1.000  1783 1.000
    #> pip[Intc, 115]              0.832 0.374          0.010  0.000  1.000  1.000  1129 1.002
    #> pip[Intc, 116]              0.472 0.499          0.010  0.000  0.000  1.000  2389 1.000
    #> pip[Intc, 117]              0.437 0.496          0.008  0.000  0.000  1.000  4329 1.000
    #> pip[Intc, 118]              0.391 0.488          0.009  0.000  0.000  1.000  2556 1.001
    #> pip[Intc, 119]              0.495 0.500          0.009  0.000  0.000  1.000  2635 1.000
    #> pip[Intc, 120]              0.553 0.497          0.008  0.000  1.000  1.000  3419 1.000
    #> pip[Intc, 121]              0.336 0.472          0.009  0.000  0.000  1.000  2606 1.000
    #> pip[Intc, 122]              0.561 0.496          0.015  0.000  1.000  1.000   962 1.004
    #> pip[Intc, 123]              0.558 0.497          0.008  0.000  1.000  1.000  4447 1.000
    #> pip[Intc, 124]              0.747 0.435          0.010  0.000  1.000  1.000  1999 1.004
    #> pip[Intc, 125]              0.461 0.499          0.008  0.000  0.000  1.000  3404 1.001
    #> pip[Intc, 126]              0.507 0.500          0.009  0.000  1.000  1.000  3278 1.001
    #> pip[Intc, 127]              0.566 0.496          0.009  0.000  1.000  1.000  2377 1.001
    #> pip[Intc, 128]              0.507 0.500          0.009  0.000  1.000  1.000  2997 0.999
    #> pip[Intc, 129]              0.421 0.494          0.008  0.000  0.000  1.000  3656 1.001
    #> pip[Intc, 130]              0.468 0.499          0.008  0.000  0.000  1.000  2749 1.001
    #> pip[Intc, 131]              0.553 0.497          0.008  0.000  1.000  1.000  3658 1.000
    #> pip[Intc, 132]              0.403 0.491          0.008  0.000  0.000  1.000  4398 1.000
    #> pip[Intc, 133]              0.360 0.480          0.009  0.000  0.000  1.000  2017 1.000
    #> pip[Intc, 134]              0.525 0.499          0.009  0.000  1.000  1.000  2387 1.000
    #> pip[Intc, 135]              0.426 0.495          0.008  0.000  0.000  1.000  2417 1.001
    #> pip[Intc, 136]              0.393 0.488          0.008  0.000  0.000  1.000  3930 0.999
    #> pip[Intc, 137]              0.424 0.494          0.009  0.000  0.000  1.000  3196 1.001
    #> pip[Intc, 138]              0.467 0.499          0.008  0.000  0.000  1.000  3386 1.000
    #> pip[Intc, 139]              0.422 0.494          0.008  0.000  0.000  1.000  3666 1.001
    #> pip[Intc, 140]              0.559 0.497          0.008  0.000  1.000  1.000  3592 1.001
    #> pip[Intc, 141]              0.533 0.499          0.008  0.000  1.000  1.000  4050 1.000
    #> pip[Intc, 142]              0.470 0.499          0.008  0.000  0.000  1.000  3139 1.000
    #> pip[Intc, 143]              0.422 0.494          0.008  0.000  0.000  1.000  3135 1.000
    #> pip[Intc, 144]              0.462 0.499          0.008  0.000  0.000  1.000  4450 1.000
    #> pip[Intc, 145]              0.493 0.500          0.011  0.000  0.000  1.000  1338 1.001
    #> pip[Intc, 146]              0.466 0.499          0.008  0.000  0.000  1.000  4173 1.000
    #> pip[Intc, 147]              0.492 0.500          0.008  0.000  0.000  1.000  4603 1.000
    #> pip[Intc, 148]              0.629 0.483          0.008  0.000  1.000  1.000  2250 1.000
    #> pip[Intc, 149]              0.723 0.448          0.008  0.000  1.000  1.000  3194 1.002
    #> pip[Intc, 150]              0.387 0.487          0.011  0.000  0.000  1.000  1886 1.001
    #> pip[Intc, 151]              0.464 0.499          0.008  0.000  0.000  1.000  3980 1.000
    #> pip[Intc, 152]              0.472 0.499          0.008  0.000  0.000  1.000  4126 1.000
    #> pip[Intc, 153]              0.756 0.429          0.009  0.000  1.000  1.000  2225 1.000
    #> pip[Intc, 154]              0.371 0.483          0.010  0.000  0.000  1.000  1394 1.001
    #> pip[Intc, 155]              0.423 0.494          0.009  0.000  0.000  1.000  2756 0.999
    #> pip[Intc, 156]              0.529 0.499          0.008  0.000  1.000  1.000  3433 1.002
    #> pip[Intc, 157]              0.544 0.498          0.008  0.000  1.000  1.000  3874 1.000
    #> pip[Intc, 158]              0.494 0.500          0.008  0.000  0.000  1.000  4450 0.999
    #> pip[Intc, 159]              0.480 0.500          0.008  0.000  0.000  1.000  3816 1.000
    #> pip[Intc, 160]              0.526 0.499          0.008  0.000  1.000  1.000  3942 1.000
    #> scl_Intc                   -0.231 0.008          0.000 -0.248 -0.231 -0.215   202 1.007
    #> scl_student_ses             0.032 0.009          0.000  0.015  0.032  0.049   452 1.005
    #> scl_school_ses              0.144 0.034          0.001  0.076  0.144  0.208   301 1.008
    #> scl_student_ses:school_ses  0.065 0.032          0.001  0.003  0.066  0.129   453 1.003
    #> 
    #> WAIC: 27043.51 
    #> elppd: -13365 
    #> pWAIC: 156.7514

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip")

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

### PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### PIP vs. math achievement

    plot(out, type =  "outcome")

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameters =  "Intc")

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

    codaplot(out, parameters =  "R[scl_Intc, Intc]")

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
