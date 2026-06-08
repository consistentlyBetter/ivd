
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

``` r
# install.packages("devtools")
# devtools::install_github("consistentlybetter/ivd")
```

## Example

``` r
library(ivd)
library(data.table)
#> 
#> Attaching package: 'data.table'
#> The following object is masked from 'package:base':
#> 
#>     %notin%
```

## Data

The illustration uses openly accessible data from The Basic Education
Evaluation System (Saeb) conducted by Brazil’s National Institute for
Educational Studies and Research (Inep), available at
<https://web.archive.org/web/20250202015037/https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/saeb/resultados>.
It is also available as the `saeb` dataset in the `ivd` package.

Separate within- from between-school effects. That is, besides
`student_ses`, compute `school_ses`.

``` r
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

<img src="man/figures/README-unnamed-chunk-2-1.png" alt="" width="100%" />

## Estimate Model

We will predict `math_proficiency` which is a standardized variable
capturing math proficiency at the end of grade 12.

Both, location (means) and scale (residual variances) are modeled as a
function of student and school SES. Note that the formula objects for
both location and scale follow `lme4` notation.

``` r
out <- ivd(location_formula = math_proficiency ~ student_ses * school_ses + (1 | school_id),
           scale_formula =  ~ student_ses * school_ses + (1 | school_id),
           data = saeb,
           niter = 5000, nburnin = 6000,
           progress = TRUE,
           seed = 800056)
#> ivd: compiling and sampling 4 chains in parallel ...
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
#> Chains (workers): 4 
#> 
#>                              Mean    SD Time-series SE   2.5%    50%  97.5%
#> R[scl_Intc, Intc]          -0.684 0.175          0.006 -0.957 -0.706 -0.287
#> Intc                        0.129 0.025          0.001  0.082  0.129  0.180
#> student_ses                 0.082 0.010          0.000  0.063  0.082  0.100
#> school_ses                  0.676 0.085          0.004  0.509  0.676  0.847
#> student_ses:school_ses     -0.023 0.040          0.000 -0.100 -0.023  0.055
#> sd_Intc                     0.268 0.019          0.001  0.232  0.267  0.308
#> sd_scl_Intc                 0.080 0.015          0.000  0.051  0.079  0.112
#> pip[Intc, 1]                0.462 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 2]                0.488 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 3]                0.457 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 4]                0.481 0.500          0.005  0.000  0.000  1.000
#> pip[Intc, 5]                0.525 0.499          0.005  0.000  1.000  1.000
#> pip[Intc, 6]                0.423 0.494          0.004  0.000  0.000  1.000
#> pip[Intc, 7]                0.408 0.492          0.005  0.000  0.000  1.000
#> pip[Intc, 8]                0.464 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 9]                0.987 0.114          0.001  1.000  1.000  1.000
#> pip[Intc, 10]               0.442 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 11]               0.561 0.496          0.004  0.000  1.000  1.000
#> pip[Intc, 12]               0.360 0.480          0.004  0.000  0.000  1.000
#> pip[Intc, 13]               0.476 0.499          0.005  0.000  0.000  1.000
#> pip[Intc, 14]               0.600 0.490          0.006  0.000  1.000  1.000
#> pip[Intc, 15]               0.509 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 16]               0.480 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 17]               0.423 0.494          0.004  0.000  0.000  1.000
#> pip[Intc, 18]               0.531 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 19]               0.236 0.425          0.005  0.000  0.000  1.000
#> pip[Intc, 20]               0.519 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 21]               0.351 0.477          0.004  0.000  0.000  1.000
#> pip[Intc, 22]               0.565 0.496          0.005  0.000  1.000  1.000
#> pip[Intc, 23]               0.504 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 24]               0.484 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 25]               0.458 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 26]               0.516 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 27]               0.441 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 28]               0.395 0.489          0.004  0.000  0.000  1.000
#> pip[Intc, 29]               0.484 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 30]               0.449 0.497          0.005  0.000  0.000  1.000
#> pip[Intc, 31]               0.466 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 32]               0.477 0.499          0.005  0.000  0.000  1.000
#> pip[Intc, 33]               0.490 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 34]               0.543 0.498          0.004  0.000  1.000  1.000
#> pip[Intc, 35]               0.663 0.473          0.005  0.000  1.000  1.000
#> pip[Intc, 36]               0.360 0.480          0.006  0.000  0.000  1.000
#> pip[Intc, 37]               0.463 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 38]               0.452 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 39]               0.696 0.460          0.009  0.000  1.000  1.000
#> pip[Intc, 40]               0.456 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 41]               0.646 0.478          0.009  0.000  1.000  1.000
#> pip[Intc, 42]               0.465 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 43]               0.413 0.492          0.004  0.000  0.000  1.000
#> pip[Intc, 44]               0.447 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 45]               0.442 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 46]               0.999 0.026          0.000  1.000  1.000  1.000
#> pip[Intc, 47]               0.464 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 48]               0.612 0.487          0.004  0.000  1.000  1.000
#> pip[Intc, 49]               0.494 0.500          0.005  0.000  0.000  1.000
#> pip[Intc, 50]               0.519 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 51]               0.462 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 52]               0.543 0.498          0.004  0.000  1.000  1.000
#> pip[Intc, 53]               0.825 0.380          0.005  0.000  1.000  1.000
#> pip[Intc, 54]               0.607 0.488          0.004  0.000  1.000  1.000
#> pip[Intc, 55]               0.395 0.489          0.004  0.000  0.000  1.000
#> pip[Intc, 56]               0.470 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 57]               0.621 0.485          0.004  0.000  1.000  1.000
#> pip[Intc, 58]               0.406 0.491          0.004  0.000  0.000  1.000
#> pip[Intc, 59]               0.429 0.495          0.004  0.000  0.000  1.000
#> pip[Intc, 60]               0.523 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 61]               0.287 0.452          0.005  0.000  0.000  1.000
#> pip[Intc, 62]               0.417 0.493          0.004  0.000  0.000  1.000
#> pip[Intc, 63]               0.496 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 64]               0.732 0.443          0.004  0.000  1.000  1.000
#> pip[Intc, 65]               0.487 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 66]               0.631 0.483          0.004  0.000  1.000  1.000
#> pip[Intc, 67]               0.349 0.477          0.004  0.000  0.000  1.000
#> pip[Intc, 68]               0.374 0.484          0.005  0.000  0.000  1.000
#> pip[Intc, 69]               0.454 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 70]               0.394 0.489          0.005  0.000  0.000  1.000
#> pip[Intc, 71]               0.383 0.486          0.004  0.000  0.000  1.000
#> pip[Intc, 72]               0.379 0.485          0.004  0.000  0.000  1.000
#> pip[Intc, 73]               0.389 0.488          0.006  0.000  0.000  1.000
#> pip[Intc, 74]               0.500 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 75]               0.467 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 76]               0.466 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 77]               0.459 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 78]               0.437 0.496          0.004  0.000  0.000  1.000
#> pip[Intc, 79]               0.385 0.487          0.004  0.000  0.000  1.000
#> pip[Intc, 80]               0.507 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 81]               0.503 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 82]               0.521 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 83]               0.484 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 84]               0.512 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 85]               0.464 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 86]               0.533 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 87]               0.725 0.447          0.006  0.000  1.000  1.000
#> pip[Intc, 88]               0.480 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 89]               0.531 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 90]               0.495 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 91]               0.438 0.496          0.004  0.000  0.000  1.000
#> pip[Intc, 92]               0.719 0.450          0.005  0.000  1.000  1.000
#> pip[Intc, 93]               0.443 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 94]               0.476 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 95]               0.751 0.433          0.004  0.000  1.000  1.000
#> pip[Intc, 96]               0.449 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 97]               0.347 0.476          0.004  0.000  0.000  1.000
#> pip[Intc, 98]               0.464 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 99]               0.560 0.496          0.004  0.000  1.000  1.000
#> pip[Intc, 100]              0.451 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 101]              0.422 0.494          0.004  0.000  0.000  1.000
#> pip[Intc, 102]              0.503 0.500          0.005  0.000  1.000  1.000
#> pip[Intc, 103]              0.383 0.486          0.004  0.000  0.000  1.000
#> pip[Intc, 104]              0.456 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 105]              0.487 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 106]              0.457 0.498          0.005  0.000  0.000  1.000
#> pip[Intc, 107]              0.519 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 108]              0.540 0.498          0.006  0.000  1.000  1.000
#> pip[Intc, 109]              0.531 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 110]              0.396 0.489          0.004  0.000  0.000  1.000
#> pip[Intc, 111]              0.447 0.497          0.005  0.000  0.000  1.000
#> pip[Intc, 112]              0.462 0.499          0.005  0.000  0.000  1.000
#> pip[Intc, 113]              0.628 0.483          0.004  0.000  1.000  1.000
#> pip[Intc, 114]              0.892 0.310          0.003  0.000  1.000  1.000
#> pip[Intc, 115]              0.811 0.392          0.005  0.000  1.000  1.000
#> pip[Intc, 116]              0.464 0.499          0.005  0.000  0.000  1.000
#> pip[Intc, 117]              0.430 0.495          0.004  0.000  0.000  1.000
#> pip[Intc, 118]              0.386 0.487          0.004  0.000  0.000  1.000
#> pip[Intc, 119]              0.489 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 120]              0.561 0.496          0.004  0.000  1.000  1.000
#> pip[Intc, 121]              0.327 0.469          0.004  0.000  0.000  1.000
#> pip[Intc, 122]              0.540 0.498          0.008  0.000  1.000  1.000
#> pip[Intc, 123]              0.575 0.494          0.004  0.000  1.000  1.000
#> pip[Intc, 124]              0.752 0.432          0.004  0.000  1.000  1.000
#> pip[Intc, 125]              0.473 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 126]              0.504 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 127]              0.562 0.496          0.004  0.000  1.000  1.000
#> pip[Intc, 128]              0.514 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 129]              0.410 0.492          0.004  0.000  0.000  1.000
#> pip[Intc, 130]              0.461 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 131]              0.559 0.496          0.004  0.000  1.000  1.000
#> pip[Intc, 132]              0.400 0.490          0.004  0.000  0.000  1.000
#> pip[Intc, 133]              0.355 0.478          0.004  0.000  0.000  1.000
#> pip[Intc, 134]              0.510 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 135]              0.430 0.495          0.004  0.000  0.000  1.000
#> pip[Intc, 136]              0.390 0.488          0.004  0.000  0.000  1.000
#> pip[Intc, 137]              0.448 0.497          0.004  0.000  0.000  1.000
#> pip[Intc, 138]              0.439 0.496          0.004  0.000  0.000  1.000
#> pip[Intc, 139]              0.413 0.492          0.004  0.000  0.000  1.000
#> pip[Intc, 140]              0.568 0.495          0.004  0.000  1.000  1.000
#> pip[Intc, 141]              0.522 0.500          0.004  0.000  1.000  1.000
#> pip[Intc, 142]              0.473 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 143]              0.416 0.493          0.004  0.000  0.000  1.000
#> pip[Intc, 144]              0.481 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 145]              0.456 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 146]              0.454 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 147]              0.486 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 148]              0.635 0.481          0.004  0.000  1.000  1.000
#> pip[Intc, 149]              0.712 0.453          0.004  0.000  1.000  1.000
#> pip[Intc, 150]              0.381 0.486          0.005  0.000  0.000  1.000
#> pip[Intc, 151]              0.464 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 152]              0.461 0.498          0.004  0.000  0.000  1.000
#> pip[Intc, 153]              0.762 0.426          0.004  0.000  1.000  1.000
#> pip[Intc, 154]              0.341 0.474          0.005  0.000  0.000  1.000
#> pip[Intc, 155]              0.417 0.493          0.004  0.000  0.000  1.000
#> pip[Intc, 156]              0.581 0.493          0.004  0.000  1.000  1.000
#> pip[Intc, 157]              0.534 0.499          0.004  0.000  1.000  1.000
#> pip[Intc, 158]              0.462 0.499          0.004  0.000  0.000  1.000
#> pip[Intc, 159]              0.477 0.500          0.004  0.000  0.000  1.000
#> pip[Intc, 160]              0.516 0.500          0.004  0.000  1.000  1.000
#> scl_Intc                   -0.234 0.008          0.000 -0.251 -0.234 -0.217
#> scl_student_ses             0.031 0.009          0.000  0.014  0.031  0.048
#> scl_school_ses              0.119 0.035          0.001  0.051  0.119  0.187
#> scl_student_ses:school_ses  0.074 0.038          0.001  0.000  0.074  0.148
#>                            n_eff R-hat
#> R[scl_Intc, Intc]            405 1.007
#> Intc                         129 1.008
#> student_ses                14324 1.000
#> school_ses                    72 1.010
#> student_ses:school_ses     18480 1.000
#> sd_Intc                      242 1.013
#> sd_scl_Intc                  917 1.004
#> pip[Intc, 1]               20726 1.000
#> pip[Intc, 2]               18477 1.000
#> pip[Intc, 3]               15246 1.000
#> pip[Intc, 4]               12258 1.000
#> pip[Intc, 5]               10796 1.000
#> pip[Intc, 6]               17046 1.000
#> pip[Intc, 7]               10728 1.000
#> pip[Intc, 8]               19366 1.000
#> pip[Intc, 9]                6346 1.000
#> pip[Intc, 10]              17660 1.000
#> pip[Intc, 11]               7908 1.000
#> pip[Intc, 12]              12689 1.000
#> pip[Intc, 13]              11410 1.000
#> pip[Intc, 14]               6478 1.000
#> pip[Intc, 15]              19687 1.000
#> pip[Intc, 16]              18788 1.000
#> pip[Intc, 17]              16529 1.000
#> pip[Intc, 18]              15732 1.000
#> pip[Intc, 19]               8304 1.000
#> pip[Intc, 20]              16587 1.000
#> pip[Intc, 21]              11073 1.000
#> pip[Intc, 22]              11819 1.000
#> pip[Intc, 23]              13638 1.000
#> pip[Intc, 24]              19423 1.000
#> pip[Intc, 25]              20500 1.000
#> pip[Intc, 26]              18134 1.000
#> pip[Intc, 27]              18313 1.000
#> pip[Intc, 28]              14102 1.001
#> pip[Intc, 29]               9943 1.000
#> pip[Intc, 30]              10625 1.001
#> pip[Intc, 31]              15667 1.000
#> pip[Intc, 32]              10922 1.000
#> pip[Intc, 33]              14833 1.000
#> pip[Intc, 34]              15842 1.000
#> pip[Intc, 35]               4992 1.000
#> pip[Intc, 36]               2955 1.000
#> pip[Intc, 37]              19031 1.000
#> pip[Intc, 38]              18823 1.000
#> pip[Intc, 39]               1327 1.002
#> pip[Intc, 40]              19548 1.000
#> pip[Intc, 41]               1786 1.002
#> pip[Intc, 42]              13667 1.000
#> pip[Intc, 43]              13668 1.001
#> pip[Intc, 44]              16180 1.000
#> pip[Intc, 45]              17760 1.000
#> pip[Intc, 46]              20084 1.000
#> pip[Intc, 47]              16222 1.000
#> pip[Intc, 48]              10906 1.000
#> pip[Intc, 49]               6466 1.000
#> pip[Intc, 50]              20319 1.000
#> pip[Intc, 51]              18810 1.000
#> pip[Intc, 52]              14048 1.000
#> pip[Intc, 53]               5593 1.000
#> pip[Intc, 54]              13816 1.000
#> pip[Intc, 55]              16605 1.000
#> pip[Intc, 56]              15386 1.000
#> pip[Intc, 57]              14664 1.000
#> pip[Intc, 58]              12166 1.000
#> pip[Intc, 59]              14090 1.000
#> pip[Intc, 60]              11601 1.000
#> pip[Intc, 61]               6286 1.001
#> pip[Intc, 62]              13980 1.000
#> pip[Intc, 63]              16493 1.000
#> pip[Intc, 64]               9000 1.000
#> pip[Intc, 65]              16421 1.000
#> pip[Intc, 66]              12980 1.000
#> pip[Intc, 67]              11863 1.000
#> pip[Intc, 68]              10534 1.000
#> pip[Intc, 69]              18431 1.000
#> pip[Intc, 70]               6540 1.000
#> pip[Intc, 71]              13959 1.000
#> pip[Intc, 72]              12343 1.000
#> pip[Intc, 73]               1772 1.001
#> pip[Intc, 74]              17534 1.000
#> pip[Intc, 75]              18279 1.000
#> pip[Intc, 76]              19399 1.000
#> pip[Intc, 77]              16143 1.000
#> pip[Intc, 78]              17627 1.000
#> pip[Intc, 79]              14312 1.000
#> pip[Intc, 80]              17049 1.000
#> pip[Intc, 81]              13754 1.001
#> pip[Intc, 82]              11806 1.000
#> pip[Intc, 83]              18251 1.000
#> pip[Intc, 84]              19138 1.000
#> pip[Intc, 85]              17486 1.000
#> pip[Intc, 86]              11734 1.000
#> pip[Intc, 87]               4925 1.001
#> pip[Intc, 88]              13670 1.000
#> pip[Intc, 89]              17181 1.000
#> pip[Intc, 90]              21665 1.000
#> pip[Intc, 91]              18356 1.000
#> pip[Intc, 92]               8137 1.001
#> pip[Intc, 93]              18855 1.000
#> pip[Intc, 94]              18566 1.000
#> pip[Intc, 95]               8860 1.000
#> pip[Intc, 96]              16977 1.000
#> pip[Intc, 97]              13208 1.000
#> pip[Intc, 98]              15638 1.000
#> pip[Intc, 99]              13601 1.000
#> pip[Intc, 100]             15126 1.000
#> pip[Intc, 101]             14071 1.000
#> pip[Intc, 102]              8176 1.000
#> pip[Intc, 103]             12872 1.000
#> pip[Intc, 104]             18225 1.000
#> pip[Intc, 105]             18838 1.000
#> pip[Intc, 106]              7719 1.000
#> pip[Intc, 107]             16312 1.000
#> pip[Intc, 108]              4808 1.001
#> pip[Intc, 109]             19020 1.000
#> pip[Intc, 110]             13389 1.000
#> pip[Intc, 111]             11703 1.001
#> pip[Intc, 112]             10321 1.000
#> pip[Intc, 113]             12215 1.000
#> pip[Intc, 114]              6585 1.000
#> pip[Intc, 115]              4716 1.001
#> pip[Intc, 116]              9987 1.000
#> pip[Intc, 117]             15926 1.000
#> pip[Intc, 118]             14069 1.000
#> pip[Intc, 119]             17761 1.000
#> pip[Intc, 120]             18687 1.000
#> pip[Intc, 121]             10142 1.000
#> pip[Intc, 122]              2289 1.001
#> pip[Intc, 123]             18724 1.000
#> pip[Intc, 124]              8818 1.000
#> pip[Intc, 125]             13910 1.000
#> pip[Intc, 126]             15478 1.000
#> pip[Intc, 127]             16230 1.000
#> pip[Intc, 128]             15792 1.000
#> pip[Intc, 129]             14126 1.000
#> pip[Intc, 130]             18795 1.000
#> pip[Intc, 131]             17513 1.000
#> pip[Intc, 132]             16559 1.000
#> pip[Intc, 133]             13829 1.000
#> pip[Intc, 134]             14967 1.000
#> pip[Intc, 135]             13444 1.000
#> pip[Intc, 136]             13688 1.000
#> pip[Intc, 137]             13705 1.000
#> pip[Intc, 138]             15181 1.000
#> pip[Intc, 139]             15871 1.000
#> pip[Intc, 140]             17385 1.000
#> pip[Intc, 141]             18153 1.000
#> pip[Intc, 142]             16721 1.000
#> pip[Intc, 143]             13389 1.000
#> pip[Intc, 144]             19665 1.000
#> pip[Intc, 145]              7403 1.000
#> pip[Intc, 146]             19377 1.000
#> pip[Intc, 147]             19033 1.000
#> pip[Intc, 148]             12896 1.000
#> pip[Intc, 149]             14608 1.000
#> pip[Intc, 150]             11125 1.000
#> pip[Intc, 151]             20088 1.000
#> pip[Intc, 152]             17908 1.000
#> pip[Intc, 153]              9079 1.001
#> pip[Intc, 154]              9977 1.000
#> pip[Intc, 155]             13534 1.000
#> pip[Intc, 156]             14079 1.000
#> pip[Intc, 157]             16986 1.000
#> pip[Intc, 158]             16024 1.000
#> pip[Intc, 159]             14499 1.000
#> pip[Intc, 160]             18293 1.000
#> scl_Intc                    1046 1.003
#> scl_student_ses             3523 1.001
#> scl_school_ses               294 1.003
#> scl_student_ses:school_ses  3036 1.000
#> 
#> WAIC: 27045.06 
#> elppd: -13364.85 
#> pWAIC: 157.6844
```

## Plots

### Posterior inclusion probability plot (PIP)

``` r
plot(out, type = "pip")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />

### PIP vs. Within-cluster SD

``` r
plot(out, type =  "funnel")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" alt="" width="100%" />

### PIP vs. math achievement

``` r
plot(out, type =  "outcome")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" alt="" width="100%" />

### Diagnostic plots based on coda plots:

``` r
codaplot(out, parameters =  "Intc")
```

<img src="man/figures/README-unnamed-chunk-9-1.png" alt="" width="100%" />

``` r
codaplot(out, parameters =  "R[scl_Intc, Intc]")
```

<img src="man/figures/README-unnamed-chunk-9-2.png" alt="" width="100%" />

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
