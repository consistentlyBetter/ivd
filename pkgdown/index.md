# Individual Variance Detection <img src="man/figures/logo.png" align="right" height="139" />

[![R-CMD-check](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ph-rast/ivd/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/consistentlyBetter/ivd/graph/badge.svg?token=SD0PM5BVIL)](https://codecov.io/gh/consistentlyBetter/ivd)

`ivd` implements the **Spike-and-Slab Mixed-Effects Location Scale Model** (SS-MELSM, [Carmo et al. 2024](https://doi.org/10.31234/osf.io/sh6ne)) 
to detect heterogeneous residual variances in hierarchical data.

While standard mixed-effects models assume constant within-group variability, mixed-effects location scale models
explicitly models the residual variance as a function of covariates and random effects. 
In the MELSM approach the covariance matrix (and thus the correlation matrix) of all random effects 
across location and scale is estimated jointly within the likelihood.
SS-MELSM uses a spike-and-slab prior to probabilistically identify specific units (e.g., schools, individuals) 
that exhibit unusually high or low consistency, distinguishing them from the population average.

## Installation

You can install the development version of `ivd` from GitHub:

```r
# install.packages("devtools")
devtools::install_github("consistentlybetter/ivd")
```

## Acknowledgment

This work was supported by the Tools Competition catalyst award for the
project
[consistentlyBetter](https://tools-competition.org/winner/consistentlybetter/)
to PR. The content is solely the responsibility of the authors and does
not necessarily represent the official views of the funding agency.

## References


<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-carmo2025" class="csl-entry">

Carmo, M., Williams, D. R., & Rast, P. (2024, November 24). 
Beyond Average Scores: Identification of Consistent and Inconsistent Academic 
Achievement in Grouping Units. <https://doi.org/10.31234/osf.io/sh6ne>

</div>

<div id="ref-rodriguez2021" class="csl-entry">

Rodriguez, J. E., Williams, D. R., & Rast, P. (2024). Who is and is not
"average"? Random effects selection with spike-and-slab priors.
*Psychological Methods*. <https://doi.org/10.1037/met0000535>

</div>

<div id="ref-williams2022" class="csl-entry">

Williams, D. R., Martin, S. R., & Rast, P. (2022). Putting the
individual into reliability: Bayesian testing of homogeneous
within-person variance in hierarchical models. *Behavior Research
Methods*, *54*(3), 1272–1290.
<https://doi.org/10.3758/s13428-021-01646-x>