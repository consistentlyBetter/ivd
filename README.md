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

    d <- mlmRev::Hsb82

    ## Ensure that school id is a continuous vector
    school_dat$schoolid <- NA
    k <- 0
    for( i in unique(school_dat$school) ) {
      k <- k+1
      school_dat[school_dat$school == i, "schoolid"] <- k
    }

## Estimate Model

    out <- ivd(location_formula = mAch ~ ses + sector + (ses | schoolid),
               scale_formula =  ~ ses + (1 | schoolid),
               data = school_dat,
               niter = 1000, nburnin = 2000)
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
    #>   [Warning] There are 49 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] There are 52 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] There are 41 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>   [Warning] There are 56 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
    #> Defining model
    #> Building model
    #> Setting data and initial values
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
    #>                    Mean    SD Time-series SE   2.5%    50%  97.5% Point est. Upper C.I.
    #> R[2, 1]           0.275 0.252          0.126 -0.178  0.333  0.691      4.492      9.093
    #> R[3, 1]          -0.443 0.284          0.163 -0.939 -0.353 -0.027      4.877     10.584
    #> R[3, 2]           0.341 0.220          0.088 -0.081  0.348  0.703      2.654      5.241
    #> beta[1]          11.015 0.526          0.122 10.156 10.963 12.189      1.493      2.600
    #> beta[2]           2.556 0.184          0.019  2.217  2.554  2.927      1.314      1.820
    #> beta[3]           2.252 0.506          0.099  1.124  2.301  3.110      2.248      3.619
    #> sigma_rand[1, 1]  1.865 0.207          0.031  1.330  1.890  2.196      1.557      2.650
    #> sigma_rand[2, 2]  0.708 0.223          0.029  0.195  0.711  1.146      1.275      1.709
    #> sigma_rand[3, 3]  2.721 0.957          0.353  0.847  2.962  4.683      1.936      3.535
    #> ss[3, 1]          0.938 0.241          0.037  0.000  1.000  1.000      1.294      2.017
    #> ss[3, 2]          0.917 0.275          0.060  0.000  1.000  1.000      1.396      2.433
    #> ss[3, 3]          0.930 0.255          0.064  0.000  1.000  1.000      1.556      3.512
    #> ss[3, 4]          0.922 0.268          0.073  0.000  1.000  1.000      1.444      2.663
    #> ss[3, 5]          0.920 0.271          0.057  0.000  1.000  1.000      1.439      2.688
    #> ss[3, 6]          0.938 0.241          0.048  0.000  1.000  1.000      1.355      2.375
    #> ss[3, 7]          0.943 0.231          0.031  0.000  1.000  1.000      1.185      1.544
    #> ss[3, 8]          0.995 0.074          0.005  1.000  1.000  1.000      1.292      1.956
    #> ss[3, 9]          0.992 0.090          0.004  1.000  1.000  1.000      1.203      1.413
    #> ss[3, 10]         0.919 0.272          0.058  0.000  1.000  1.000      1.433      2.653
    #> ss[3, 11]         0.926 0.262          0.041  0.000  1.000  1.000      1.442      2.719
    #> ss[3, 12]         0.929 0.257          0.042  0.000  1.000  1.000      1.373      2.395
    #> ss[3, 13]         0.900 0.299          0.077  0.000  1.000  1.000      1.657      3.424
    #> ss[3, 14]         0.925 0.263          0.043  0.000  1.000  1.000      1.345      2.204
    #> ss[3, 15]         0.922 0.269          0.057  0.000  1.000  1.000      1.421      2.612
    #> ss[3, 16]         0.925 0.263          0.050  0.000  1.000  1.000      1.397      2.488
    #> ss[3, 17]         0.925 0.263          0.061  0.000  1.000  1.000      1.424      2.618
    #> ss[3, 18]         0.914 0.280          0.060  0.000  1.000  1.000      1.439      2.580
    #> ss[3, 19]         0.914 0.280          0.063  0.000  1.000  1.000      1.394      2.449
    #> ss[3, 20]         0.927 0.260          0.050  0.000  1.000  1.000      1.440      2.749
    #> ss[3, 21]         0.922 0.268          0.068  0.000  1.000  1.000      1.538      3.184
    #> ss[3, 22]         0.950 0.217          0.041  0.000  1.000  1.000      1.400      2.809
    #> ss[3, 23]         0.933 0.250          0.059  0.000  1.000  1.000      1.422      2.695
    #> ss[3, 24]         0.943 0.231          0.051  0.000  1.000  1.000      1.361      2.442
    #> ss[3, 25]         0.932 0.252          0.042  0.000  1.000  1.000      1.402      2.576
    #> ss[3, 26]         0.982 0.133          0.008  1.000  1.000  1.000      1.287      2.110
    #> ss[3, 27]         0.927 0.260          0.054  0.000  1.000  1.000      1.418      2.622
    #> ss[3, 28]         0.952 0.214          0.045  0.000  1.000  1.000      1.452      3.362
    #> ss[3, 29]         0.927 0.261          0.051  0.000  1.000  1.000      1.379      2.445
    #> ss[3, 30]         0.913 0.282          0.062  0.000  1.000  1.000      1.407      2.498
    #> ss[3, 31]         0.933 0.250          0.044  0.000  1.000  1.000      1.360      2.381
    #> ss[3, 32]         0.935 0.247          0.054  0.000  1.000  1.000      1.355      2.362
    #> ss[3, 33]         0.921 0.270          0.055  0.000  1.000  1.000      1.472      2.821
    #> ss[3, 34]         0.912 0.283          0.059  0.000  1.000  1.000      1.436      2.514
    #> ss[3, 35]         0.923 0.267          0.054  0.000  1.000  1.000      1.367      2.313
    #> ss[3, 36]         0.948 0.223          0.031  0.000  1.000  1.000      1.240      1.814
    #> ss[3, 37]         0.931 0.253          0.040  0.000  1.000  1.000      1.365      2.327
    #> ss[3, 38]         0.991 0.096          0.007  1.000  1.000  1.000      1.304      2.245
    #> ss[3, 39]         0.943 0.232          0.032  0.000  1.000  1.000      1.292      2.006
    #> ss[3, 40]         0.904 0.294          0.078  0.000  1.000  1.000      1.641      3.367
    #> ss[3, 41]         0.924 0.265          0.059  0.000  1.000  1.000      1.421      2.605
    #> ss[3, 42]         0.950 0.217          0.039  0.000  1.000  1.000      1.295      2.096
    #> ss[3, 43]         0.920 0.272          0.058  0.000  1.000  1.000      1.485      2.897
    #> ss[3, 44]         0.935 0.246          0.034  0.000  1.000  1.000      1.307      2.106
    #> ss[3, 45]         0.909 0.288          0.076  0.000  1.000  1.000      1.395      2.470
    #> ss[3, 46]         0.921 0.269          0.051  0.000  1.000  1.000      1.408      2.498
    #> ss[3, 47]         0.941 0.235          0.030  0.000  1.000  1.000      1.248      1.809
    #> ss[3, 48]         1.000 0.022          0.000  1.000  1.000  1.000      1.292      1.410
    #> ss[3, 49]         0.970 0.171          0.023  0.000  1.000  1.000      1.290      2.122
    #> ss[3, 50]         0.942 0.234          0.046  0.000  1.000  1.000      1.354      2.393
    #> ss[3, 51]         0.952 0.215          0.028  0.000  1.000  1.000      1.198      1.600
    #> ss[3, 52]         0.939 0.240          0.050  0.000  1.000  1.000      1.294      2.075
    #> ss[3, 53]         0.934 0.248          0.044  0.000  1.000  1.000      1.211      1.670
    #> ss[3, 54]         0.917 0.276          0.067  0.000  1.000  1.000      1.401      2.461
    #> ss[3, 55]         0.925 0.263          0.058  0.000  1.000  1.000      1.449      2.762
    #> ss[3, 56]         0.932 0.251          0.034  0.000  1.000  1.000      1.263      1.874
    #> ss[3, 57]         0.969 0.175          0.019  0.000  1.000  1.000      1.307      2.251
    #> ss[3, 58]         0.928 0.259          0.054  0.000  1.000  1.000      1.369      2.370
    #> ss[3, 59]         0.924 0.265          0.059  0.000  1.000  1.000      1.396      2.511
    #> ss[3, 60]         0.932 0.251          0.047  0.000  1.000  1.000      1.395      2.554
    #> ss[3, 61]         0.927 0.260          0.048  0.000  1.000  1.000      1.291      2.036
    #> ss[3, 62]         0.923 0.266          0.062  0.000  1.000  1.000      1.477      2.886
    #> ss[3, 63]         0.918 0.274          0.044  0.000  1.000  1.000      1.373      2.335
    #> ss[3, 64]         0.905 0.293          0.060  0.000  1.000  1.000      1.474      2.763
    #> ss[3, 65]         0.929 0.257          0.051  0.000  1.000  1.000      1.432      2.724
    #> ss[3, 66]         0.923 0.266          0.068  0.000  1.000  1.000      1.375      2.414
    #> ss[3, 67]         0.935 0.247          0.053  0.000  1.000  1.000      1.511      3.332
    #> ss[3, 68]         0.916 0.278          0.059  0.000  1.000  1.000      1.425      2.534
    #> ss[3, 69]         0.915 0.279          0.055  0.000  1.000  1.000      1.381      2.307
    #> ss[3, 70]         0.919 0.273          0.054  0.000  1.000  1.000      1.395      2.466
    #> ss[3, 71]         0.906 0.292          0.079  0.000  1.000  1.000      1.484      2.786
    #> ss[3, 72]         0.961 0.193          0.031  0.000  1.000  1.000      1.519      5.181
    #> ss[3, 73]         0.923 0.266          0.053  0.000  1.000  1.000      1.446      2.730
    #> ss[3, 74]         0.924 0.265          0.057  0.000  1.000  1.000      1.530      3.192
    #> ss[3, 75]         0.921 0.269          0.063  0.000  1.000  1.000      1.481      2.895
    #> ss[3, 76]         0.941 0.237          0.052  0.000  1.000  1.000      1.420      2.792
    #> ss[3, 77]         0.930 0.254          0.051  0.000  1.000  1.000      1.384      2.486
    #> ss[3, 78]         0.949 0.221          0.039  0.000  1.000  1.000      1.370      2.556
    #> ss[3, 79]         0.921 0.270          0.052  0.000  1.000  1.000      1.350      2.195
    #> ss[3, 80]         0.924 0.265          0.047  0.000  1.000  1.000      1.385      2.463
    #> ss[3, 81]         0.918 0.274          0.053  0.000  1.000  1.000      1.455      2.719
    #> ss[3, 82]         0.927 0.260          0.042  0.000  1.000  1.000      1.316      2.110
    #> ss[3, 83]         0.915 0.279          0.060  0.000  1.000  1.000      1.471      2.742
    #> ss[3, 84]         0.928 0.259          0.051  0.000  1.000  1.000      1.433      2.718
    #> ss[3, 85]         0.949 0.221          0.037  0.000  1.000  1.000      1.447      3.185
    #> ss[3, 86]         0.927 0.260          0.059  0.000  1.000  1.000      1.438      2.726
    #> ss[3, 87]         0.906 0.292          0.079  0.000  1.000  1.000      1.642      3.434
    #> ss[3, 88]         0.927 0.260          0.047  0.000  1.000  1.000      1.380      2.427
    #> ss[3, 89]         0.920 0.272          0.067  0.000  1.000  1.000      1.732      4.362
    #> ss[3, 90]         0.932 0.252          0.046  0.000  1.000  1.000      1.323      2.167
    #> ss[3, 91]         0.937 0.243          0.044  0.000  1.000  1.000      1.369      2.448
    #> ss[3, 92]         0.956 0.205          0.027  0.000  1.000  1.000      1.311      2.214
    #> ss[3, 93]         0.915 0.279          0.060  0.000  1.000  1.000      1.398      2.466
    #> ss[3, 94]         0.909 0.288          0.054  0.000  1.000  1.000      1.426      2.356
    #> ss[3, 95]         0.918 0.274          0.074  0.000  1.000  1.000      1.471      2.802
    #> ss[3, 96]         0.884 0.321          0.062  0.000  1.000  1.000      1.379      2.133
    #> ss[3, 97]         0.925 0.264          0.057  0.000  1.000  1.000      1.410      2.568
    #> ss[3, 98]         0.918 0.275          0.055  0.000  1.000  1.000      1.433      2.633
    #> ss[3, 99]         0.912 0.283          0.057  0.000  1.000  1.000      1.543      3.059
    #> ss[3, 100]        0.929 0.256          0.049  0.000  1.000  1.000      1.395      2.534
    #> ss[3, 101]        0.930 0.255          0.051  0.000  1.000  1.000      1.423      2.673
    #> ss[3, 102]        0.917 0.276          0.064  0.000  1.000  1.000      1.386      2.445
    #> ss[3, 103]        0.997 0.055          0.002  1.000  1.000  1.000      1.223      1.363
    #> ss[3, 104]        0.895 0.307          0.068  0.000  1.000  1.000      1.374      2.236
    #> ss[3, 105]        0.929 0.257          0.070  0.000  1.000  1.000      1.464      2.897
    #> ss[3, 106]        0.924 0.265          0.056  0.000  1.000  1.000      1.457      2.803
    #> ss[3, 107]        0.937 0.243          0.051  0.000  1.000  1.000      1.353      2.324
    #> ss[3, 108]        0.985 0.121          0.011  1.000  1.000  1.000      1.321      2.528
    #> ss[3, 109]        0.927 0.259          0.060  0.000  1.000  1.000      1.416      2.625
    #> ss[3, 110]        0.909 0.288          0.077  0.000  1.000  1.000      1.714      3.823
    #> ss[3, 111]        0.937 0.243          0.043  0.000  1.000  1.000      1.329      2.230
    #> ss[3, 112]        0.921 0.269          0.055  0.000  1.000  1.000      1.470      2.811
    #> ss[3, 113]        0.896 0.305          0.086  0.000  1.000  1.000      1.792      3.876
    #> ss[3, 114]        0.917 0.276          0.067  0.000  1.000  1.000      1.508      2.977
    #> ss[3, 115]        0.930 0.255          0.049  0.000  1.000  1.000      1.397      2.546
    #> ss[3, 116]        0.948 0.222          0.040  0.000  1.000  1.000      1.313      2.188
    #> ss[3, 117]        0.943 0.233          0.048  0.000  1.000  1.000      1.536      3.860
    #> ss[3, 118]        0.924 0.265          0.054  0.000  1.000  1.000      1.436      2.689
    #> ss[3, 119]        0.922 0.268          0.053  0.000  1.000  1.000      1.337      2.242
    #> ss[3, 120]        0.934 0.248          0.054  0.000  1.000  1.000      1.344      2.296
    #> ss[3, 121]        0.933 0.250          0.054  0.000  1.000  1.000      1.439      2.810
    #> ss[3, 122]        0.992 0.088          0.005  1.000  1.000  1.000      1.183      1.332
    #> ss[3, 123]        0.904 0.295          0.066  0.000  1.000  1.000      1.485      2.671
    #> ss[3, 124]        0.920 0.271          0.053  0.000  1.000  1.000      1.305      2.031
    #> ss[3, 125]        0.924 0.265          0.058  0.000  1.000  1.000      1.435      2.690
    #> ss[3, 126]        0.923 0.267          0.059  0.000  1.000  1.000      1.354      2.235
    #> ss[3, 127]        0.928 0.258          0.050  0.000  1.000  1.000      1.370      2.407
    #> ss[3, 128]        0.952 0.214          0.042  0.000  1.000  1.000      1.439      3.218
    #> ss[3, 129]        0.961 0.193          0.025  0.000  1.000  1.000      1.316      2.273
    #> ss[3, 130]        0.922 0.268          0.050  0.000  1.000  1.000      1.432      2.642
    #> ss[3, 131]        0.936 0.245          0.045  0.000  1.000  1.000      1.362      2.381
    #> ss[3, 132]        0.982 0.133          0.015  1.000  1.000  1.000      1.377      3.551
    #> ss[3, 133]        0.923 0.266          0.049  0.000  1.000  1.000      1.269      1.898
    #> ss[3, 134]        0.923 0.267          0.061  0.000  1.000  1.000      1.414      2.554
    #> ss[3, 135]        0.901 0.298          0.070  0.000  1.000  1.000      1.554      2.964
    #> ss[3, 136]        0.925 0.264          0.055  0.000  1.000  1.000      1.359      2.308
    #> ss[3, 137]        0.930 0.255          0.045  0.000  1.000  1.000      1.358      2.295
    #> ss[3, 138]        0.924 0.265          0.046  0.000  1.000  1.000      1.502      3.043
    #> ss[3, 139]        0.934 0.248          0.060  0.000  1.000  1.000      1.414      2.678
    #> ss[3, 140]        0.926 0.261          0.058  0.000  1.000  1.000      1.430      2.687
    #> ss[3, 141]        0.928 0.259          0.054  0.000  1.000  1.000      1.508      3.135
    #> ss[3, 142]        0.920 0.272          0.064  0.000  1.000  1.000      1.435      2.642
    #> ss[3, 143]        0.891 0.311          0.091  0.000  1.000  1.000      1.561      3.016
    #> ss[3, 144]        0.955 0.207          0.027  0.000  1.000  1.000      1.301      2.145
    #> ss[3, 145]        0.924 0.264          0.063  0.000  1.000  1.000      1.441      2.701
    #> ss[3, 146]        0.924 0.264          0.060  0.000  1.000  1.000      1.423      2.640
    #> ss[3, 147]        0.925 0.263          0.066  0.000  1.000  1.000      1.420      2.618
    #> ss[3, 148]        0.976 0.154          0.015  1.000  1.000  1.000      1.391      3.546
    #> ss[3, 149]        0.945 0.229          0.045  0.000  1.000  1.000      1.378      2.561
    #> ss[3, 150]        0.914 0.280          0.055  0.000  1.000  1.000      1.477      2.816
    #> ss[3, 151]        0.943 0.231          0.042  0.000  1.000  1.000      1.320      2.210
    #> ss[3, 152]        0.913 0.282          0.060  0.000  1.000  1.000      1.435      2.562
    #> ss[3, 153]        0.904 0.295          0.057  0.000  1.000  1.000      1.474      2.604
    #> ss[3, 154]        0.917 0.275          0.053  0.000  1.000  1.000      1.372      2.356
    #> ss[3, 155]        0.935 0.246          0.056  0.000  1.000  1.000      1.442      2.863
    #> ss[3, 156]        0.905 0.293          0.067  0.000  1.000  1.000      1.425      2.496
    #> ss[3, 157]        0.917 0.275          0.066  0.000  1.000  1.000      1.447      2.669
    #> ss[3, 158]        0.924 0.265          0.058  0.000  1.000  1.000      1.381      2.431
    #> ss[3, 159]        0.931 0.253          0.039  0.000  1.000  1.000      1.304      2.049
    #> ss[3, 160]        0.926 0.262          0.054  0.000  1.000  1.000      1.439      2.717
    #> zeta[1]           3.621 1.128          0.505  1.803  3.619  5.593      4.605      9.668
    #> zeta[2]          -0.001 0.013          0.001 -0.027 -0.001  0.024      1.002      1.007

    plot(out, type = "pip" )

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

    plot(out, type =  "funnel")

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Diagnostic plots based on coda plots:

    codaplot(out, parameter =  "beta[1]")

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

    #> NULL
    codaplot(out, parameter =  "R[2, 1]")

<img src="man/figures/README-unnamed-chunk-6-2.png" width="100%" />

    #> NULL

# References
