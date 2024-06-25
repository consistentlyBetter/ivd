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
    #>   [Warning] There are 60 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
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
    #>   [Warning] There are 9 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
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
    #>   [Warning] There are 47 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
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

    summary(out)
    #> Summary statistics for ivd model:
    #>                     Mean     SD Time-series SE    2.5%    50%  97.5% Point est. Upper C.I.
    #> R[2, 1]           -0.141  0.417          0.236  -0.977 -0.038  0.244      6.749     18.187
    #> beta[1]          -10.696 42.549         31.284 -79.750 -0.352 38.818    197.066    509.426
    #> beta[2]            0.083  0.012          0.002   0.061  0.083  0.105      1.612      2.456
    #> sigma_rand[1, 1]  10.526 10.911          6.503   0.226  8.174 26.982    537.026   1025.229
    #> sigma_rand[2, 2]   0.535  0.592          0.340   0.059  0.207  1.979      1.684      4.536
    #> ss[2, 1]           0.685  0.465          0.066   0.000  1.000  1.000      1.101      1.276
    #> ss[2, 2]           0.681  0.466          0.068   0.000  1.000  1.000      1.143      1.380
    #> ss[2, 3]           0.655  0.475          0.075   0.000  1.000  1.000      1.110      1.299
    #> ss[2, 4]           0.671  0.470          0.068   0.000  1.000  1.000      1.092      1.253
    #> ss[2, 5]           0.748  0.434          0.045   0.000  1.000  1.000      1.301      1.886
    #> ss[2, 6]           0.647  0.478          0.079   0.000  1.000  1.000      1.111      1.300
    #> ss[2, 7]           0.652  0.476          0.072   0.000  1.000  1.000      1.034      1.100
    #> ss[2, 8]           0.682  0.466          0.073   0.000  1.000  1.000      1.097      1.265
    #> ss[2, 9]           0.966  0.181          0.012   0.000  1.000  1.000      1.210      1.606
    #> ss[2, 10]          0.671  0.470          0.082   0.000  1.000  1.000      1.142      1.377
    #> ss[2, 11]          0.655  0.475          0.059   0.000  1.000  1.000      1.016      1.050
    #> ss[2, 12]          0.647  0.478          0.084   0.000  1.000  1.000      1.114      1.308
    #> ss[2, 13]          0.638  0.480          0.079   0.000  1.000  1.000      1.016      1.048
    #> ss[2, 14]          0.751  0.433          0.039   0.000  1.000  1.000      1.014      1.041
    #> ss[2, 15]          0.705  0.456          0.063   0.000  1.000  1.000      1.104      1.282
    #> ss[2, 16]          0.680  0.466          0.079   0.000  1.000  1.000      1.127      1.340
    #> ss[2, 17]          0.659  0.474          0.075   0.000  1.000  1.000      1.162      1.429
    #> ss[2, 18]          0.733  0.442          0.050   0.000  1.000  1.000      1.128      1.350
    #> ss[2, 19]          0.612  0.487          0.090   0.000  1.000  1.000      1.115      1.313
    #> ss[2, 20]          0.729  0.444          0.053   0.000  1.000  1.000      1.188      1.510
    #> ss[2, 21]          0.668  0.471          0.067   0.000  1.000  1.000      1.113      1.307
    #> ss[2, 22]          0.747  0.435          0.044   0.000  1.000  1.000      1.183      1.511
    #> ss[2, 23]          0.734  0.442          0.051   0.000  1.000  1.000      1.318      1.941
    #> ss[2, 24]          0.694  0.461          0.073   0.000  1.000  1.000      1.163      1.435
    #> ss[2, 25]          0.677  0.468          0.075   0.000  1.000  1.000      1.160      1.424
    #> ss[2, 26]          0.704  0.457          0.059   0.000  1.000  1.000      1.111      1.300
    #> ss[2, 27]          0.665  0.472          0.080   0.000  1.000  1.000      1.106      1.290
    #> ss[2, 28]          0.668  0.471          0.059   0.000  1.000  1.000      1.058      1.166
    #> ss[2, 29]          0.679  0.467          0.067   0.000  1.000  1.000      1.088      1.244
    #> ss[2, 30]          0.645  0.479          0.074   0.000  1.000  1.000      1.098      1.269
    #> ss[2, 31]          0.693  0.461          0.059   0.000  1.000  1.000      1.167      1.445
    #> ss[2, 32]          0.738  0.440          0.054   0.000  1.000  1.000      1.282      1.809
    #> ss[2, 33]          0.669  0.471          0.066   0.000  1.000  1.000      1.055      1.158
    #> ss[2, 34]          0.681  0.466          0.057   0.000  1.000  1.000      1.025      1.074
    #> ss[2, 35]          0.769  0.421          0.039   0.000  1.000  1.000      1.015      1.045
    #> ss[2, 36]          0.678  0.467          0.060   0.000  1.000  1.000      1.034      1.099
    #> ss[2, 37]          0.672  0.470          0.067   0.000  1.000  1.000      1.113      1.307
    #> ss[2, 38]          0.700  0.458          0.072   0.000  1.000  1.000      1.245      1.649
    #> ss[2, 39]          0.824  0.381          0.053   0.000  1.000  1.000      1.107      1.272
    #> ss[2, 40]          0.665  0.472          0.071   0.000  1.000  1.000      1.119      1.321
    #> ss[2, 41]          0.826  0.379          0.061   0.000  1.000  1.000      1.085      1.234
    #> ss[2, 42]          0.649  0.477          0.076   0.000  1.000  1.000      1.079      1.220
    #> ss[2, 43]          0.621  0.485          0.086   0.000  1.000  1.000      1.175      1.453
    #> ss[2, 44]          0.667  0.471          0.076   0.000  1.000  1.000      1.145      1.385
    #> ss[2, 45]          0.640  0.480          0.076   0.000  1.000  1.000      1.133      1.355
    #> ss[2, 46]          0.984  0.125          0.006   1.000  1.000  1.000      1.309      2.348
    #> ss[2, 47]          0.673  0.469          0.069   0.000  1.000  1.000      1.104      1.284
    #> ss[2, 48]          0.698  0.459          0.059   0.000  1.000  1.000      1.041      1.118
    #> ss[2, 49]          0.728  0.445          0.058   0.000  1.000  1.000      1.286      1.830
    #> ss[2, 50]          0.701  0.458          0.062   0.000  1.000  1.000      1.121      1.327
    #> ss[2, 51]          0.666  0.472          0.073   0.000  1.000  1.000      1.103      1.281
    #> ss[2, 52]          0.715  0.452          0.053   0.000  1.000  1.000      1.150      1.410
    #> ss[2, 53]          0.801  0.399          0.058   0.000  1.000  1.000      1.044      1.122
    #> ss[2, 54]          0.716  0.451          0.047   0.000  1.000  1.000      1.031      1.088
    #> ss[2, 55]          0.677  0.468          0.068   0.000  1.000  1.000      1.155      1.411
    #> ss[2, 56]          0.690  0.463          0.065   0.000  1.000  1.000      1.238      1.631
    #> ss[2, 57]          0.745  0.436          0.046   0.000  1.000  1.000      1.161      1.444
    #> ss[2, 58]          0.714  0.452          0.067   0.000  1.000  1.000      1.274      1.738
    #> ss[2, 59]          0.697  0.460          0.066   0.000  1.000  1.000      1.161      1.428
    #> ss[2, 60]          0.678  0.467          0.062   0.000  1.000  1.000      1.051      1.147
    #> ss[2, 61]          0.560  0.496          0.120   0.000  1.000  1.000      1.122      1.327
    #> ss[2, 62]          0.623  0.485          0.097   0.000  1.000  1.000      1.086      1.238
    #> ss[2, 63]          0.691  0.462          0.071   0.000  1.000  1.000      1.138      1.376
    #> ss[2, 64]          0.770  0.421          0.040   0.000  1.000  1.000      1.168      1.459
    #> ss[2, 65]          0.667  0.471          0.056   0.000  1.000  1.000      1.049      1.141
    #> ss[2, 66]          0.776  0.417          0.042   0.000  1.000  1.000      1.118      1.322
    #> ss[2, 67]          0.653  0.476          0.077   0.000  1.000  1.000      1.220      1.565
    #> ss[2, 68]          0.661  0.473          0.071   0.000  1.000  1.000      1.082      1.229
    #> ss[2, 69]          0.672  0.470          0.076   0.000  1.000  1.000      1.119      1.320
    #> ss[2, 70]          0.659  0.474          0.072   0.000  1.000  1.000      1.024      1.072
    #> ss[2, 71]          0.696  0.460          0.068   0.000  1.000  1.000      1.197      1.523
    #> ss[2, 72]          0.649  0.477          0.078   0.000  1.000  1.000      1.144      1.383
    #> ss[2, 73]          0.685  0.464          0.073   0.000  1.000  1.000      1.059      1.168
    #> ss[2, 74]          0.688  0.463          0.073   0.000  1.000  1.000      1.252      1.688
    #> ss[2, 75]          0.680  0.467          0.070   0.000  1.000  1.000      1.181      1.477
    #> ss[2, 76]          0.670  0.470          0.073   0.000  1.000  1.000      1.145      1.388
    #> ss[2, 77]          0.657  0.475          0.081   0.000  1.000  1.000      1.160      1.421
    #> ss[2, 78]          0.660  0.474          0.077   0.000  1.000  1.000      1.155      1.411
    #> ss[2, 79]          0.661  0.473          0.079   0.000  1.000  1.000      1.195      1.509
    #> ss[2, 80]          0.552  0.497          0.016   0.000  1.000  1.000      1.000      1.002
    #> ss[2, 81]          0.689  0.463          0.072   0.000  1.000  1.000      1.254      1.680
    #> ss[2, 82]          0.727  0.446          0.057   0.000  1.000  1.000      1.237      1.647
    #> ss[2, 83]          0.682  0.466          0.069   0.000  1.000  1.000      1.145      1.387
    #> ss[2, 84]          0.688  0.463          0.061   0.000  1.000  1.000      1.059      1.166
    #> ss[2, 85]          0.682  0.466          0.071   0.000  1.000  1.000      1.119      1.323
    #> ss[2, 86]          0.621  0.485          0.090   0.000  1.000  1.000      1.158      1.418
    #> ss[2, 87]          0.880  0.325          0.022   0.000  1.000  1.000      1.210      1.678
    #> ss[2, 88]          0.733  0.442          0.056   0.000  1.000  1.000      1.265      1.736
    #> ss[2, 89]          0.686  0.464          0.066   0.000  1.000  1.000      1.068      1.189
    #> ss[2, 90]          0.647  0.478          0.048   0.000  1.000  1.000      1.026      1.079
    #> ss[2, 91]          0.692  0.462          0.066   0.000  1.000  1.000      1.152      1.405
    #> ss[2, 92]          0.762  0.426          0.051   0.000  1.000  1.000      1.006      1.019
    #> ss[2, 93]          0.689  0.463          0.065   0.000  1.000  1.000      1.163      1.435
    #> ss[2, 94]          0.667  0.471          0.075   0.000  1.000  1.000      1.082      1.228
    #> ss[2, 95]          0.861  0.346          0.023   0.000  1.000  1.000      1.221      1.709
    #> ss[2, 96]          0.672  0.470          0.085   0.000  1.000  1.000      1.298      1.778
    #> ss[2, 97]          0.673  0.469          0.066   0.000  1.000  1.000      1.313      1.801
    #> ss[2, 98]          0.701  0.458          0.066   0.000  1.000  1.000      1.329      1.901
    #> ss[2, 99]          0.734  0.442          0.050   0.000  1.000  1.000      1.189      1.519
    #> ss[2, 100]         0.677  0.468          0.071   0.000  1.000  1.000      1.220      1.572
    #> ss[2, 101]         0.659  0.474          0.077   0.000  1.000  1.000      1.121      1.325
    #> ss[2, 102]         0.765  0.424          0.045   0.000  1.000  1.000      1.394      2.323
    #> ss[2, 103]         0.662  0.473          0.083   0.000  1.000  1.000      1.328      1.880
    #> ss[2, 104]         0.651  0.477          0.079   0.000  1.000  1.000      1.092      1.257
    #> ss[2, 105]         0.673  0.469          0.061   0.000  1.000  1.000      1.055      1.158
    #> ss[2, 106]         0.641  0.480          0.076   0.000  1.000  1.000      1.032      1.095
    #> ss[2, 107]         0.698  0.459          0.067   0.000  1.000  1.000      1.209      1.557
    #> ss[2, 108]         0.852  0.356          0.029   0.000  1.000  1.000      1.236      1.799
    #> ss[2, 109]         0.655  0.475          0.076   0.000  1.000  1.000      1.006      1.019
    #> ss[2, 110]         0.640  0.480          0.086   0.000  1.000  1.000      1.294      1.745
    #> ss[2, 111]         0.712  0.453          0.063   0.000  1.000  1.000      1.397      2.166
    #> ss[2, 112]         0.683  0.465          0.063   0.000  1.000  1.000      1.057      1.161
    #> ss[2, 113]         0.737  0.440          0.052   0.000  1.000  1.000      1.163      1.439
    #> ss[2, 114]         0.887  0.317          0.044   0.000  1.000  1.000      1.078      1.198
    #> ss[2, 115]         0.826  0.379          0.038   0.000  1.000  1.000      1.266      1.925
    #> ss[2, 116]         0.693  0.461          0.064   0.000  1.000  1.000      1.443      2.201
    #> ss[2, 117]         0.680  0.466          0.067   0.000  1.000  1.000      1.074      1.205
    #> ss[2, 118]         0.632  0.482          0.084   0.000  1.000  1.000      1.104      1.285
    #> ss[2, 119]         0.686  0.464          0.068   0.000  1.000  1.000      1.115      1.310
    #> ss[2, 120]         0.685  0.464          0.062   0.000  1.000  1.000      1.029      1.085
    #>  [ reached getOption("max.print") -- omitted 42 rows ]

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip" )

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />
\### PIP vs. Within-cluster SD

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-16-1.png" width="100%" />

### Diagnostic plots based on coda plots:

    codaplot(out, parameter =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-17-1.png" width="100%" />

    #> NULL

    codaplot(out, parameter =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-17-2.png" width="100%" />

    #> NULL

# References
