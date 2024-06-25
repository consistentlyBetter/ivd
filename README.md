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

## Estimate Model

    out <- ivd(location_formula = math_proficiency ~ student_ses + (1|school_id),
               scale_formula =  ~ student_ses + (1|school_id),
               data = saeb,
               niter = 2000, nburnin = 5000, WAIC = TRUE, workers = 4)
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_lkj_corr_cholesky sampler (1)
    #>   - L[1:2, 1:2] 
    #> RW sampler (324)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (2)
    #>   - beta[]  (2 elements)
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
    #> RW sampler (324)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (2)
    #>   - beta[]  (2 elements)
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
    #> RW sampler (324)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (2)
    #>   - beta[]  (2 elements)
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
    #> RW sampler (324)
    #>   - z[]  (320 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (2 elements)
    #> conjugate sampler (2)
    #>   - beta[]  (2 elements)
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

    summary(out)
    #> Summary statistics for ivd model:
    #> Chains/workers: 4 
    #> 
    #>                    Mean    SD Time-series SE   2.5%    50%  97.5% R-hat R-hat 95% C.I.
    #> R[2, 1]          -0.476 0.272          0.092 -0.972 -0.439 -0.060 2.747          4.628
    #> beta[1]          -0.321 0.057          0.007 -0.438 -0.319 -0.214 1.152          1.393
    #> beta[2]           0.089 0.010          0.001  0.070  0.089  0.110 1.193          1.489
    #> sigma_rand[1, 1]  0.291 0.035          0.006  0.223  0.295  0.352 1.919          3.027
    #> sigma_rand[2, 2]  0.116 0.074          0.018  0.058  0.093  0.365 1.885          7.556
    #> ss[2, 1]          0.475 0.499          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 2]          0.463 0.499          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 3]          0.448 0.497          0.007  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 4]          0.472 0.499          0.007  0.000  0.000  1.000 1.000          1.003
    #> ss[2, 5]          0.539 0.498          0.011  0.000  1.000  1.000 1.010          1.033
    #> ss[2, 6]          0.424 0.494          0.007  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 7]          0.461 0.498          0.008  0.000  0.000  1.000 1.001          1.006
    #> ss[2, 8]          0.463 0.499          0.006  0.000  0.000  1.000 1.001          1.005
    #> ss[2, 9]          0.969 0.175          0.004  0.000  1.000  1.000 1.006          1.008
    #> ss[2, 10]         0.427 0.495          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 11]         0.537 0.499          0.009  0.000  1.000  1.000 1.002          1.006
    #> ss[2, 12]         0.427 0.495          0.006  0.000  0.000  1.000 1.001          1.004
    #> ss[2, 13]         0.470 0.499          0.013  0.000  0.000  1.000 1.003          1.010
    #> ss[2, 14]         0.614 0.487          0.011  0.000  1.000  1.000 1.003          1.011
    #> ss[2, 15]         0.489 0.500          0.006  0.000  0.000  1.000 1.001          1.004
    #> ss[2, 16]         0.455 0.498          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 17]         0.412 0.492          0.006  0.000  0.000  1.000 1.002          1.008
    #> ss[2, 18]         0.529 0.499          0.007  0.000  1.000  1.000 1.000          1.002
    #> ss[2, 19]         0.327 0.469          0.013  0.000  0.000  1.000 1.019          1.057
    #> ss[2, 20]         0.516 0.500          0.006  0.000  1.000  1.000 1.000          1.002
    #> ss[2, 21]         0.442 0.497          0.008  0.000  0.000  1.000 1.003          1.009
    #> ss[2, 22]         0.556 0.497          0.009  0.000  1.000  1.000 1.001          1.003
    #> ss[2, 23]         0.502 0.500          0.011  0.000  1.000  1.000 1.000          1.001
    #> ss[2, 24]         0.451 0.498          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 25]         0.462 0.499          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 26]         0.515 0.500          0.006  0.000  1.000  1.000 1.000          1.002
    #> ss[2, 27]         0.440 0.496          0.006  0.000  0.000  1.000 1.003          1.010
    #> ss[2, 28]         0.493 0.500          0.006  0.000  0.000  1.000 1.001          1.005
    #> ss[2, 29]         0.488 0.500          0.008  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 30]         0.437 0.496          0.009  0.000  0.000  1.000 1.006          1.020
    #> ss[2, 31]         0.469 0.499          0.006  0.000  0.000  1.000 1.001          1.004
    #> ss[2, 32]         0.527 0.499          0.010  0.000  1.000  1.000 1.005          1.016
    #> ss[2, 33]         0.467 0.499          0.008  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 34]         0.547 0.498          0.008  0.000  1.000  1.000 1.001          1.005
    #> ss[2, 35]         0.698 0.459          0.016  0.000  1.000  1.000 1.001          1.005
    #> ss[2, 36]         0.480 0.500          0.010  0.000  0.000  1.000 1.003          1.011
    #> ss[2, 37]         0.458 0.498          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 38]         0.432 0.495          0.007  0.000  0.000  1.000 1.004          1.014
    #> ss[2, 39]         0.829 0.376          0.033  0.000  1.000  1.000 1.086          1.207
    #> ss[2, 40]         0.445 0.497          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 41]         0.818 0.386          0.020  0.000  1.000  1.000 1.005          1.011
    #> ss[2, 42]         0.437 0.496          0.007  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 43]         0.388 0.487          0.009  0.000  0.000  1.000 1.003          1.009
    #> ss[2, 44]         0.440 0.496          0.006  0.000  0.000  1.000 1.002          1.007
    #> ss[2, 45]         0.393 0.488          0.008  0.000  0.000  1.000 1.006          1.018
    #> ss[2, 46]         0.992 0.088          0.002  1.000  1.000  1.000 1.079          1.093
    #> ss[2, 47]         0.454 0.498          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 48]         0.536 0.499          0.007  0.000  1.000  1.000 1.002          1.006
    #> ss[2, 49]         0.466 0.499          0.013  0.000  0.000  1.000 1.002          1.007
    #> ss[2, 50]         0.505 0.500          0.006  0.000  1.000  1.000 1.000          1.001
    #> ss[2, 51]         0.436 0.496          0.007  0.000  0.000  1.000 1.001          1.003
    #> ss[2, 52]         0.502 0.500          0.007  0.000  1.000  1.000 1.001          1.003
    #> ss[2, 53]         0.782 0.413          0.019  0.000  1.000  1.000 1.032          1.083
    #> ss[2, 54]         0.581 0.493          0.012  0.000  1.000  1.000 1.000          1.001
    #> ss[2, 55]         0.443 0.497          0.006  0.000  0.000  1.000 1.002          1.008
    #> ss[2, 56]         0.460 0.498          0.007  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 57]         0.561 0.496          0.006  0.000  1.000  1.000 1.000          1.000
    #> ss[2, 58]         0.454 0.498          0.007  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 59]         0.455 0.498          0.006  0.000  0.000  1.000 1.002          1.007
    #> ss[2, 60]         0.499 0.500          0.007  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 61]         0.290 0.454          0.021  0.000  0.000  1.000 1.010          1.030
    #> ss[2, 62]         0.384 0.486          0.008  0.000  0.000  1.000 1.004          1.013
    #> ss[2, 63]         0.490 0.500          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 64]         0.642 0.479          0.008  0.000  1.000  1.000 1.009          1.029
    #> ss[2, 65]         0.484 0.500          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 66]         0.620 0.485          0.008  0.000  1.000  1.000 1.001          1.004
    #> ss[2, 67]         0.411 0.492          0.007  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 68]         0.437 0.496          0.007  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 69]         0.463 0.499          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 70]         0.484 0.500          0.011  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 71]         0.444 0.497          0.006  0.000  0.000  1.000 1.001          1.006
    #> ss[2, 72]         0.408 0.492          0.008  0.000  0.000  1.000 1.003          1.009
    #> ss[2, 73]         0.482 0.500          0.019  0.000  0.000  1.000 1.013          1.040
    #> ss[2, 74]         0.418 0.493          0.010  0.000  0.000  1.000 1.009          1.028
    #> ss[2, 75]         0.456 0.498          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 76]         0.422 0.494          0.007  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 77]         0.431 0.495          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 78]         0.431 0.495          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 79]         0.399 0.490          0.007  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 80]         0.508 0.500          0.006  0.000  1.000  1.000 1.002          1.006
    #> ss[2, 81]         0.454 0.498          0.008  0.000  0.000  1.000 1.004          1.013
    #> ss[2, 82]         0.519 0.500          0.007  0.000  1.000  1.000 1.000          1.002
    #> ss[2, 83]         0.465 0.499          0.006  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 84]         0.489 0.500          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 85]         0.464 0.499          0.006  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 86]         0.389 0.487          0.008  0.000  0.000  1.000 1.004          1.014
    #> ss[2, 87]         0.789 0.408          0.010  0.000  1.000  1.000 1.001          1.003
    #> ss[2, 88]         0.517 0.500          0.008  0.000  1.000  1.000 1.000          1.001
    #> ss[2, 89]         0.499 0.500          0.006  0.000  0.000  1.000 1.001          1.003
    #> ss[2, 90]         0.487 0.500          0.006  0.000  0.000  1.000 1.001          1.003
    #> ss[2, 91]         0.463 0.499          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 92]         0.711 0.453          0.017  0.000  1.000  1.000 1.020          1.056
    #> ss[2, 93]         0.458 0.498          0.006  0.000  0.000  1.000 1.002          1.008
    #> ss[2, 94]         0.470 0.499          0.006  0.000  0.000  1.000 1.002          1.008
    #> ss[2, 95]         0.712 0.453          0.015  0.000  1.000  1.000 1.003          1.008
    #> ss[2, 96]         0.416 0.493          0.008  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 97]         0.412 0.492          0.008  0.000  0.000  1.000 1.002          1.008
    #> ss[2, 98]         0.455 0.498          0.008  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 99]         0.522 0.500          0.007  0.000  1.000  1.000 1.000          1.000
    #> ss[2, 100]        0.416 0.493          0.007  0.000  0.000  1.000 1.001          1.005
    #> ss[2, 101]        0.422 0.494          0.007  0.000  0.000  1.000 1.001          1.004
    #> ss[2, 102]        0.543 0.498          0.017  0.000  1.000  1.000 1.005          1.018
    #> ss[2, 103]        0.372 0.483          0.011  0.000  0.000  1.000 1.008          1.025
    #> ss[2, 104]        0.430 0.495          0.007  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 105]        0.480 0.500          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 106]        0.447 0.497          0.013  0.000  0.000  1.000 1.003          1.011
    #> ss[2, 107]        0.486 0.500          0.007  0.000  0.000  1.000 1.000          1.000
    #> ss[2, 108]        0.697 0.460          0.026  0.000  1.000  1.000 1.001          1.002
    #> ss[2, 109]        0.504 0.500          0.006  0.000  1.000  1.000 1.000          1.003
    #> ss[2, 110]        0.355 0.479          0.010  0.000  0.000  1.000 1.008          1.025
    #> ss[2, 111]        0.454 0.498          0.016  0.000  0.000  1.000 1.003          1.010
    #> ss[2, 112]        0.498 0.500          0.008  0.000  0.000  1.000 1.000          1.001
    #> ss[2, 113]        0.547 0.498          0.006  0.000  1.000  1.000 1.000          1.000
    #> ss[2, 114]        0.914 0.280          0.010  0.000  1.000  1.000 1.011          1.020
    #> ss[2, 115]        0.730 0.444          0.018  0.000  1.000  1.000 1.026          1.072
    #> ss[2, 116]        0.396 0.489          0.011  0.000  0.000  1.000 1.008          1.024
    #> ss[2, 117]        0.488 0.500          0.006  0.000  0.000  1.000 1.000          1.002
    #> ss[2, 118]        0.386 0.487          0.011  0.000  0.000  1.000 1.005          1.015
    #> ss[2, 119]        0.491 0.500          0.006  0.000  0.000  1.000 1.002          1.007
    #> ss[2, 120]        0.526 0.499          0.007  0.000  1.000  1.000 1.000          1.002
    #>  [ reached getOption("max.print") -- omitted 42 rows ]
    #> 
    #> WAIC: 27049.55 
    #> elppd: -13358.98 
    #> lpWAIC: 165.7976

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip" )

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />
\### PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameter =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />

    #> NULL

    codaplot(out, parameter =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-15-2.png" width="100%" />

    #> NULL

# References
