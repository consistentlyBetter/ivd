<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- knit with rmarkdown::render("README.Rmd", output_format = "md_document") -->

Individual Variance Detection
=============================

<!-- badges: start -->

[![R-CMD-check](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/consistentlyBetter/ivd/graph/badge.svg?token=SD0PM5BVIL)](https://codecov.io/gh/consistentlyBetter/ivd)
<!-- badges: end -->

*ivd* is an R package for random effects selection in the scale part of
Mixed Effects Location Scale Modlels (MELSM). `ivd()` fits a random
intercepts model with a spike-and-slab prior on the random effects of
the scale.

Installation
------------

This package can be installed with

    # install.packages("devtools")
    devtools::install_github("consistentlybetter/ivd")

Example
-------

    library(ivd)

    d <- mlmRev::Hsb82

    ## Ensure that school id is a continuous vector
    school_dat$schoolid <- NA
    k <- 0
    for( i in unique(school_dat$school) ) {
      k <- k+1
      school_dat[school_dat$school == i, "schoolid"] <- k
    }

Estimate Model
--------------

    out <- ivd(location_formula = mAch ~ ses + sector + (ses | schoolid),
               scale_formula =  ~ ses + (1 | schoolid),
               data = school_dat,
               niter = 1000, nburnin = 1000)
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_block_lkj_corr_cholesky sampler (1)
    #>   - L[1:3, 1:3] 
    #> RW sampler (485)
    #>   - z[]  (480 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (3 elements)
    #> conjugate sampler (3)
    #>   - beta[]  (3 elements)
    #> binary sampler (480)
    #>   - ss[]  (480 elements)
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] To calculate WAIC, set 'WAIC = TRUE', in addition to having enabled WAIC in building the MCMC.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_block_lkj_corr_cholesky sampler (1)
    #>   - L[1:3, 1:3] 
    #> RW sampler (485)
    #>   - z[]  (480 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (3 elements)
    #> conjugate sampler (3)
    #>   - beta[]  (3 elements)
    #> binary sampler (480)
    #>   - ss[]  (480 elements)
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] To calculate WAIC, set 'WAIC = TRUE', in addition to having enabled WAIC in building the MCMC.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_block_lkj_corr_cholesky sampler (1)
    #>   - L[1:3, 1:3] 
    #> RW sampler (485)
    #>   - z[]  (480 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (3 elements)
    #> conjugate sampler (3)
    #>   - beta[]  (3 elements)
    #> binary sampler (480)
    #>   - ss[]  (480 elements)
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] To calculate WAIC, set 'WAIC = TRUE', in addition to having enabled WAIC in building the MCMC.
    #> running chain 1...
    #> ===== Monitors =====
    #> thin = 1: beta, L, sigma_rand, ss, z, zeta
    #> ===== Samplers =====
    #> RW_block_lkj_corr_cholesky sampler (1)
    #>   - L[1:3, 1:3] 
    #> RW sampler (485)
    #>   - z[]  (480 elements)
    #>   - zeta[]  (2 elements)
    #>   - sigma_rand[]  (3 elements)
    #> conjugate sampler (3)
    #>   - beta[]  (3 elements)
    #> binary sampler (480)
    #>   - ss[]  (480 elements)
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] To calculate WAIC, set 'WAIC = TRUE', in addition to having enabled WAIC in building the MCMC.
    #> running chain 1...

    summary(out)
    #> Summary statistics for ivd model:
    #>                    Mean    SD Time-series SE   2.5%    50%  97.5% Point est. Upper C.I.
    #> R[2, 1]           0.377 0.334          0.055 -0.257  0.415  0.857      2.711      5.027
    #> R[3, 1]          -0.732 0.275          0.030 -0.980 -0.848 -0.047      2.627      5.056
    #> R[3, 2]          -0.145 0.355          0.050 -0.814 -0.147  0.471      1.539      2.276
    #> beta[1]          11.788 0.245          0.018 11.279 11.799 12.238      1.065      1.186
    #> beta[2]           2.358 0.121          0.004  2.128  2.356  2.602      1.009      1.030
    #> beta[3]           1.941 0.429          0.032  1.158  1.912  2.847      1.258      1.649
    #> sigma_rand[1, 1]  1.452 0.142          0.012  1.207  1.435  1.767      1.128      1.341
    #> sigma_rand[2, 2]  0.650 0.283          0.031  0.119  0.648  1.213      1.121      1.351
    #> sigma_rand[3, 3]  0.370 0.247          0.040  0.113  0.289  0.992      1.853      4.234
    #> ss[3, 1]          0.696 0.460          0.014  0.000  1.000  1.000      1.002      1.007
    #> ss[3, 2]          0.464 0.499          0.009  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 3]          0.370 0.483          0.012  0.000  0.000  1.000      1.013      1.039
    #> ss[3, 4]          0.459 0.498          0.008  0.000  0.000  1.000      0.999      1.000
    #> ss[3, 5]          0.465 0.499          0.010  0.000  0.000  1.000      1.004      1.014
    #> ss[3, 6]          0.481 0.500          0.011  0.000  0.000  1.000      1.000      1.004
    #> ss[3, 7]          0.752 0.432          0.011  0.000  1.000  1.000      1.000      1.001
    #> ss[3, 8]          0.920 0.271          0.008  0.000  1.000  1.000      1.011      1.020
    #> ss[3, 9]          0.850 0.358          0.009  0.000  1.000  1.000      1.008      1.019
    #> ss[3, 10]         0.430 0.495          0.008  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 11]         0.467 0.499          0.008  0.000  0.000  1.000      0.999      1.000
    #> ss[3, 12]         0.547 0.498          0.018  0.000  1.000  1.000      1.014      1.043
    #> ss[3, 13]         0.342 0.475          0.010  0.000  0.000  1.000      1.004      1.012
    #> ss[3, 14]         0.510 0.500          0.008  0.000  1.000  1.000      1.000      1.002
    #> ss[3, 15]         0.408 0.492          0.011  0.000  0.000  1.000      1.003      1.012
    #> ss[3, 16]         0.477 0.500          0.008  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 17]         0.456 0.498          0.008  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 18]         0.440 0.496          0.009  0.000  0.000  1.000      0.999      1.000
    #> ss[3, 19]         0.432 0.495          0.008  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 20]         0.435 0.496          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 21]         0.403 0.491          0.009  0.000  0.000  1.000      1.013      1.040
    #> ss[3, 22]         0.547 0.498          0.018  0.000  1.000  1.000      1.070      1.198
    #> ss[3, 23]         0.458 0.498          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 24]         0.452 0.498          0.010  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 25]         0.501 0.500          0.008  0.000  1.000  1.000      0.999      1.000
    #> ss[3, 26]         0.793 0.405          0.010  0.000  1.000  1.000      1.013      1.032
    #> ss[3, 27]         0.456 0.498          0.008  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 28]         0.625 0.484          0.009  0.000  1.000  1.000      1.000      1.003
    #> ss[3, 29]         0.419 0.493          0.008  0.000  0.000  1.000      1.004      1.015
    #> ss[3, 30]         0.473 0.499          0.009  0.000  0.000  1.000      1.006      1.020
    #> ss[3, 31]         0.486 0.500          0.010  0.000  0.000  1.000      1.006      1.020
    #> ss[3, 32]         0.424 0.494          0.010  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 33]         0.420 0.494          0.009  0.000  0.000  1.000      1.002      1.009
    #> ss[3, 34]         0.486 0.500          0.008  0.000  0.000  1.000      1.008      1.028
    #> ss[3, 35]         0.457 0.498          0.009  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 36]         0.579 0.494          0.010  0.000  1.000  1.000      1.002      1.009
    #> ss[3, 37]         0.618 0.486          0.010  0.000  1.000  1.000      1.005      1.017
    #> ss[3, 38]         0.920 0.271          0.007  0.000  1.000  1.000      1.004      1.007
    #> ss[3, 39]         0.658 0.475          0.011  0.000  1.000  1.000      1.007      1.022
    #> ss[3, 40]         0.469 0.499          0.012  0.000  0.000  1.000      1.002      1.008
    #> ss[3, 41]         0.422 0.494          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 42]         0.560 0.496          0.009  0.000  1.000  1.000      1.002      1.008
    #> ss[3, 43]         0.421 0.494          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 44]         0.488 0.500          0.017  0.000  0.000  1.000      1.009      1.029
    #> ss[3, 45]         0.438 0.496          0.009  0.000  0.000  1.000      1.002      1.008
    #> ss[3, 46]         0.498 0.500          0.010  0.000  0.000  1.000      0.999      1.000
    #> ss[3, 47]         0.581 0.493          0.013  0.000  1.000  1.000      1.019      1.058
    #> ss[3, 48]         0.990 0.100          0.002  1.000  1.000  1.000      1.137      1.174
    #> ss[3, 49]         0.645 0.478          0.010  0.000  1.000  1.000      1.001      1.004
    #> ss[3, 50]         0.435 0.496          0.009  0.000  0.000  1.000      1.009      1.028
    #> ss[3, 51]         0.754 0.431          0.009  0.000  1.000  1.000      1.006      1.017
    #> ss[3, 52]         0.508 0.500          0.011  0.000  1.000  1.000      1.003      1.011
    #> ss[3, 53]         0.657 0.475          0.013  0.000  1.000  1.000      1.008      1.025
    #> ss[3, 54]         0.506 0.500          0.009  0.000  1.000  1.000      1.002      1.007
    #> ss[3, 55]         0.407 0.491          0.009  0.000  0.000  1.000      0.999      0.999
    #> ss[3, 56]         0.667 0.471          0.013  0.000  1.000  1.000      1.027      1.078
    #> ss[3, 57]         0.647 0.478          0.009  0.000  1.000  1.000      1.009      1.029
    #> ss[3, 58]         0.472 0.499          0.009  0.000  0.000  1.000      1.003      1.012
    #> ss[3, 59]         0.468 0.499          0.010  0.000  0.000  1.000      1.001      1.006
    #> ss[3, 60]         0.480 0.500          0.008  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 61]         0.632 0.482          0.011  0.000  1.000  1.000      1.007      1.023
    #> ss[3, 62]         0.436 0.496          0.009  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 63]         0.518 0.500          0.010  0.000  1.000  1.000      1.011      1.036
    #> ss[3, 64]         0.416 0.493          0.008  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 65]         0.370 0.483          0.009  0.000  0.000  1.000      1.009      1.029
    #> ss[3, 66]         0.380 0.486          0.010  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 67]         0.506 0.500          0.009  0.000  1.000  1.000      1.003      1.010
    #> ss[3, 68]         0.490 0.500          0.009  0.000  0.000  1.000      1.004      1.016
    #> ss[3, 69]         0.483 0.500          0.009  0.000  0.000  1.000      1.002      1.008
    #> ss[3, 70]         0.447 0.497          0.008  0.000  0.000  1.000      1.002      1.008
    #> ss[3, 71]         0.406 0.491          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 72]         0.370 0.483          0.018  0.000  0.000  1.000      1.076      1.210
    #> ss[3, 73]         0.429 0.495          0.008  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 74]         0.238 0.426          0.011  0.000  0.000  1.000      1.006      1.019
    #> ss[3, 75]         0.328 0.470          0.012  0.000  0.000  1.000      1.008      1.024
    #> ss[3, 76]         0.475 0.499          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 77]         0.430 0.495          0.011  0.000  0.000  1.000      1.005      1.016
    #> ss[3, 78]         0.519 0.500          0.012  0.000  1.000  1.000      1.002      1.008
    #> ss[3, 79]         0.561 0.496          0.010  0.000  1.000  1.000      1.000      1.001
    #> ss[3, 80]         0.428 0.495          0.008  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 81]         0.508 0.500          0.013  0.000  1.000  1.000      1.001      1.004
    #> ss[3, 82]         0.433 0.496          0.015  0.000  0.000  1.000      1.001      1.007
    #> ss[3, 83]         0.418 0.493          0.010  0.000  0.000  1.000      1.010      1.032
    #> ss[3, 84]         0.422 0.494          0.008  0.000  0.000  1.000      1.005      1.017
    #> ss[3, 85]         0.528 0.499          0.010  0.000  1.000  1.000      0.999      0.999
    #> ss[3, 86]         0.427 0.495          0.008  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 87]         0.290 0.454          0.012  0.000  0.000  1.000      1.004      1.012
    #> ss[3, 88]         0.453 0.498          0.008  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 89]         0.391 0.488          0.010  0.000  0.000  1.000      1.001      1.006
    #> ss[3, 90]         0.517 0.500          0.012  0.000  1.000  1.000      1.002      1.008
    #> ss[3, 91]         0.506 0.500          0.008  0.000  1.000  1.000      1.000      1.002
    #> ss[3, 92]         0.609 0.488          0.008  0.000  1.000  1.000      1.000      1.002
    #> ss[3, 93]         0.432 0.495          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 94]         0.376 0.485          0.009  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 95]         0.438 0.496          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 96]         0.446 0.497          0.012  0.000  0.000  1.000      1.009      1.031
    #> ss[3, 97]         0.441 0.497          0.008  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 98]         0.388 0.487          0.010  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 99]         0.412 0.492          0.012  0.000  0.000  1.000      1.005      1.016
    #> ss[3, 100]        0.431 0.495          0.010  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 101]        0.454 0.498          0.008  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 102]        0.369 0.483          0.010  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 103]        0.856 0.351          0.009  0.000  1.000  1.000      1.005      1.013
    #> ss[3, 104]        0.498 0.500          0.016  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 105]        0.421 0.494          0.009  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 106]        0.410 0.492          0.009  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 107]        0.556 0.497          0.010  0.000  1.000  1.000      1.001      1.004
    #> ss[3, 108]        0.731 0.444          0.019  0.000  1.000  1.000      1.037      1.100
    #> ss[3, 109]        0.408 0.492          0.009  0.000  0.000  1.000      1.003      1.010
    #> ss[3, 110]        0.257 0.437          0.013  0.000  0.000  1.000      1.070      1.188
    #> ss[3, 111]        0.456 0.498          0.008  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 112]        0.448 0.497          0.008  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 113]        0.293 0.455          0.010  0.000  0.000  1.000      1.013      1.039
    #> ss[3, 114]        0.419 0.493          0.009  0.000  0.000  1.000      1.001      1.007
    #> ss[3, 115]        0.428 0.495          0.008  0.000  0.000  1.000      1.003      1.010
    #> ss[3, 116]        0.509 0.500          0.011  0.000  1.000  1.000      1.008      1.026
    #> ss[3, 117]        0.448 0.497          0.011  0.000  0.000  1.000      1.008      1.026
    #> ss[3, 118]        0.470 0.499          0.009  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 119]        0.450 0.498          0.009  0.000  0.000  1.000      1.003      1.011
    #> ss[3, 120]        0.460 0.498          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 121]        0.452 0.498          0.008  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 122]        0.892 0.310          0.006  0.000  1.000  1.000      1.006      1.013
    #> ss[3, 123]        0.402 0.490          0.009  0.000  0.000  1.000      1.009      1.031
    #> ss[3, 124]        0.515 0.500          0.009  0.000  1.000  1.000      1.000      1.003
    #> ss[3, 125]        0.446 0.497          0.010  0.000  0.000  1.000      0.999      1.000
    #> ss[3, 126]        0.424 0.494          0.009  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 127]        0.439 0.496          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 128]        0.592 0.492          0.010  0.000  1.000  1.000      1.003      1.011
    #> ss[3, 129]        0.600 0.490          0.011  0.000  1.000  1.000      1.005      1.016
    #> ss[3, 130]        0.447 0.497          0.008  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 131]        0.448 0.497          0.008  0.000  0.000  1.000      1.003      1.011
    #> ss[3, 132]        0.907 0.290          0.008  0.000  1.000  1.000      1.031      1.060
    #> ss[3, 133]        0.579 0.494          0.011  0.000  1.000  1.000      1.003      1.010
    #> ss[3, 134]        0.436 0.496          0.009  0.000  0.000  1.000      1.001      1.006
    #> ss[3, 135]        0.402 0.490          0.009  0.000  0.000  1.000      1.009      1.028
    #> ss[3, 136]        0.438 0.496          0.008  0.000  0.000  1.000      1.000      1.001
    #> ss[3, 137]        0.516 0.500          0.012  0.000  1.000  1.000      1.011      1.036
    #> ss[3, 138]        0.430 0.495          0.008  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 139]        0.428 0.495          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 140]        0.421 0.494          0.008  0.000  0.000  1.000      1.004      1.013
    #> ss[3, 141]        0.424 0.494          0.010  0.000  0.000  1.000      1.005      1.017
    #> ss[3, 142]        0.407 0.491          0.009  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 143]        0.253 0.435          0.011  0.000  0.000  1.000      1.004      1.012
    #> ss[3, 144]        0.524 0.499          0.012  0.000  1.000  1.000      1.000      1.003
    #> ss[3, 145]        0.436 0.496          0.008  0.000  0.000  1.000      1.001      1.004
    #> ss[3, 146]        0.430 0.495          0.009  0.000  0.000  1.000      1.003      1.012
    #> ss[3, 147]        0.443 0.497          0.009  0.000  0.000  1.000      1.000      1.002
    #> ss[3, 148]        0.552 0.497          0.016  0.000  1.000  1.000      1.016      1.049
    #> ss[3, 149]        0.518 0.500          0.008  0.000  1.000  1.000      1.000      1.002
    #> ss[3, 150]        0.329 0.470          0.011  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 151]        0.531 0.499          0.008  0.000  1.000  1.000      1.003      1.013
    #> ss[3, 152]        0.391 0.488          0.011  0.000  0.000  1.000      1.002      1.007
    #> ss[3, 153]        0.523 0.500          0.010  0.000  1.000  1.000      1.003      1.010
    #> ss[3, 154]        0.459 0.498          0.009  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 155]        0.450 0.498          0.012  0.000  0.000  1.000      1.001      1.005
    #> ss[3, 156]        0.525 0.499          0.019  0.000  1.000  1.000      1.006      1.020
    #> ss[3, 157]        0.468 0.499          0.009  0.000  0.000  1.000      1.002      1.008
    #> ss[3, 158]        0.445 0.497          0.008  0.000  0.000  1.000      1.000      1.003
    #> ss[3, 159]        0.589 0.492          0.011  0.000  1.000  1.000      1.000      1.002
    #> ss[3, 160]        0.438 0.496          0.009  0.000  0.000  1.000      1.001      1.006
    #> zeta[1]           1.805 0.010          0.000  1.786  1.804  1.824      1.015      1.043
    #> zeta[2]          -0.007 0.012          0.000 -0.029 -0.007  0.014      1.003      1.010

    plot(out, type = "pip" )

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Diagnostic plots based on coda plots:

    codaplot(out, parameter =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

    #> NULL

References
==========
