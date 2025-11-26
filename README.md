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
    devtools::install_github("consistentlybetter/ivd")

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
               niter = 2000, nburnin = 6000, WAIC = TRUE, workers = 6)
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
    #> warning: logProb of data node Y[5427]: logProb less than -1e12.
    #> warning: logProb of data node Y[5428]: logProb less than -1e12.
    #> warning: logProb of data node Y[5429]: logProb less than -1e12.
    #> warning: logProb of data node Y[5430]: logProb less than -1e12.
    #> warning: logProb of data node Y[5431]: logProb less than -1e12.
    #> warning: logProb of data node Y[5432]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5445]: logProb less than -1e12.
    #> warning: logProb of data node Y[5446]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5448]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5450]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5457]: logProb less than -1e12.
    #> warning: logProb of data node Y[5459]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5464]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5468]: logProb less than -1e12.
    #> warning: logProb of data node Y[5469]: logProb less than -1e12.
    #> warning: logProb of data node Y[7017]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10829]: logProb less than -1e12.
    #> warning: logProb of data node Y[10830]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
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
    #> warning: logProb of data node Y[2345]: logProb less than -1e12.
    #> warning: logProb of data node Y[2367]: logProb less than -1e12.
    #> warning: logProb of data node Y[2385]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5469]: logProb less than -1e12.
    #> warning: logProb of data node Y[6956]: logProb less than -1e12.
    #> warning: logProb of data node Y[6980]: logProb less than -1e12.
    #> warning: logProb of data node Y[10004]: logProb less than -1e12.
    #> warning: logProb of data node Y[10321]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
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
    #> warning: logProb of data node Y[1588]: logProb less than -1e12.
    #> warning: logProb of data node Y[1594]: logProb less than -1e12.
    #> warning: logProb of data node Y[1603]: logProb less than -1e12.
    #> warning: logProb of data node Y[1612]: logProb less than -1e12.
    #> warning: logProb of data node Y[2367]: logProb less than -1e12.
    #> warning: logProb of data node Y[2385]: logProb less than -1e12.
    #> warning: logProb of data node Y[5427]: logProb less than -1e12.
    #> warning: logProb of data node Y[5428]: logProb less than -1e12.
    #> warning: logProb of data node Y[5429]: logProb less than -1e12.
    #> warning: logProb of data node Y[5430]: logProb less than -1e12.
    #> warning: logProb of data node Y[5431]: logProb less than -1e12.
    #> warning: logProb of data node Y[5432]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5445]: logProb less than -1e12.
    #> warning: logProb of data node Y[5446]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5448]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5450]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5464]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5468]: logProb less than -1e12.
    #> warning: logProb of data node Y[7017]: logProb less than -1e12.
    #> warning: logProb of data node Y[8099]: logProb less than -1e12.
    #> warning: logProb of data node Y[8100]: logProb less than -1e12.
    #> warning: logProb of data node Y[8104]: logProb less than -1e12.
    #> warning: logProb of data node Y[8105]: logProb less than -1e12.
    #> warning: logProb of data node Y[8112]: logProb less than -1e12.
    #> warning: logProb of data node Y[8114]: logProb less than -1e12.
    #> warning: logProb of data node Y[8116]: logProb less than -1e12.
    #> warning: logProb of data node Y[8119]: logProb less than -1e12.
    #> warning: logProb of data node Y[8121]: logProb less than -1e12.
    #> warning: logProb of data node Y[8123]: logProb less than -1e12.
    #> warning: logProb of data node Y[8125]: logProb less than -1e12.
    #> warning: logProb of data node Y[8127]: logProb less than -1e12.
    #> warning: logProb of data node Y[8130]: logProb less than -1e12.
    #> warning: logProb of data node Y[8133]: logProb less than -1e12.
    #> warning: logProb of data node Y[8135]: logProb less than -1e12.
    #> warning: logProb of data node Y[8136]: logProb less than -1e12.
    #> warning: logProb of data node Y[8137]: logProb less than -1e12.
    #> warning: logProb of data node Y[8138]: logProb less than -1e12.
    #> warning: logProb of data node Y[8139]: logProb less than -1e12.
    #> warning: logProb of data node Y[8141]: logProb less than -1e12.
    #> warning: logProb of data node Y[8144]: logProb less than -1e12.
    #> warning: logProb of data node Y[8146]: logProb less than -1e12.
    #> warning: logProb of data node Y[8147]: logProb less than -1e12.
    #> warning: logProb of data node Y[8148]: logProb less than -1e12.
    #> warning: logProb of data node Y[8149]: logProb less than -1e12.
    #> warning: logProb of data node Y[8150]: logProb less than -1e12.
    #> warning: logProb of data node Y[8151]: logProb less than -1e12.
    #> warning: logProb of data node Y[8154]: logProb less than -1e12.
    #> warning: logProb of data node Y[8155]: logProb less than -1e12.
    #> warning: logProb of data node Y[8162]: logProb less than -1e12.
    #> warning: logProb of data node Y[8167]: logProb less than -1e12.
    #> warning: logProb of data node Y[8169]: logProb less than -1e12.
    #> warning: logProb of data node Y[8173]: logProb less than -1e12.
    #> warning: logProb of data node Y[8174]: logProb less than -1e12.
    #> warning: logProb of data node Y[8175]: logProb less than -1e12.
    #> warning: logProb of data node Y[8179]: logProb less than -1e12.
    #> warning: logProb of data node Y[8181]: logProb less than -1e12.
    #> warning: logProb of data node Y[8192]: logProb less than -1e12.
    #> warning: logProb of data node Y[8194]: logProb less than -1e12.
    #> warning: logProb of data node Y[8199]: logProb less than -1e12.
    #> warning: logProb of data node Y[8200]: logProb less than -1e12.
    #> warning: logProb of data node Y[8201]: logProb less than -1e12.
    #> warning: logProb of data node Y[8203]: logProb less than -1e12.
    #> warning: logProb of data node Y[8204]: logProb less than -1e12.
    #> warning: logProb of data node Y[8205]: logProb less than -1e12.
    #> warning: logProb of data node Y[8206]: logProb less than -1e12.
    #> warning: logProb of data node Y[8208]: logProb less than -1e12.
    #> warning: logProb of data node Y[8209]: logProb less than -1e12.
    #> warning: logProb of data node Y[8211]: logProb less than -1e12.
    #> warning: logProb of data node Y[8212]: logProb less than -1e12.
    #> warning: logProb of data node Y[8216]: logProb less than -1e12.
    #> warning: logProb of data node Y[8219]: logProb less than -1e12.
    #> warning: logProb of data node Y[8220]: logProb less than -1e12.
    #> warning: logProb of data node Y[8222]: logProb less than -1e12.
    #> warning: logProb of data node Y[8223]: logProb less than -1e12.
    #> warning: logProb of data node Y[8227]: logProb less than -1e12.
    #> warning: logProb of data node Y[8230]: logProb less than -1e12.
    #> warning: logProb of data node Y[8231]: logProb less than -1e12.
    #> warning: logProb of data node Y[8235]: logProb less than -1e12.
    #> warning: logProb of data node Y[8238]: logProb less than -1e12.
    #> warning: logProb of data node Y[8239]: logProb less than -1e12.
    #> warning: logProb of data node Y[8242]: logProb less than -1e12.
    #> warning: logProb of data node Y[8246]: logProb less than -1e12.
    #> warning: logProb of data node Y[8248]: logProb less than -1e12.
    #> warning: logProb of data node Y[8253]: logProb less than -1e12.
    #> warning: logProb of data node Y[8257]: logProb less than -1e12.
    #> warning: logProb of data node Y[8258]: logProb less than -1e12.
    #> warning: logProb of data node Y[8259]: logProb less than -1e12.
    #> warning: logProb of data node Y[8260]: logProb less than -1e12.
    #> warning: logProb of data node Y[8265]: logProb less than -1e12.
    #> warning: logProb of data node Y[8266]: logProb less than -1e12.
    #> warning: logProb of data node Y[8269]: logProb less than -1e12.
    #> warning: logProb of data node Y[8272]: logProb less than -1e12.
    #> warning: logProb of data node Y[8273]: logProb less than -1e12.
    #> warning: logProb of data node Y[8274]: logProb less than -1e12.
    #> warning: logProb of data node Y[8279]: logProb less than -1e12.
    #> warning: logProb of data node Y[8280]: logProb less than -1e12.
    #> warning: logProb of data node Y[8282]: logProb less than -1e12.
    #> warning: logProb of data node Y[8284]: logProb less than -1e12.
    #> warning: logProb of data node Y[8286]: logProb less than -1e12.
    #> warning: logProb of data node Y[8289]: logProb less than -1e12.
    #> warning: logProb of data node Y[8290]: logProb less than -1e12.
    #> warning: logProb of data node Y[8291]: logProb less than -1e12.
    #> warning: logProb of data node Y[8298]: logProb less than -1e12.
    #> warning: logProb of data node Y[8300]: logProb less than -1e12.
    #> warning: logProb of data node Y[8301]: logProb less than -1e12.
    #> warning: logProb of data node Y[8302]: logProb less than -1e12.
    #> warning: logProb of data node Y[8304]: logProb less than -1e12.
    #> warning: logProb of data node Y[8310]: logProb less than -1e12.
    #> warning: logProb of data node Y[8314]: logProb less than -1e12.
    #> warning: logProb of data node Y[8317]: logProb less than -1e12.
    #> warning: logProb of data node Y[8319]: logProb less than -1e12.
    #> warning: logProb of data node Y[8321]: logProb less than -1e12.
    #> warning: logProb of data node Y[8322]: logProb less than -1e12.
    #> warning: logProb of data node Y[8325]: logProb less than -1e12.
    #> warning: logProb of data node Y[10095]: logProb less than -1e12.
    #> warning: logProb of data node Y[10499]: logProb less than -1e12.
    #> warning: logProb of data node Y[10502]: logProb less than -1e12.
    #> warning: logProb of data node Y[10503]: logProb less than -1e12.
    #> warning: logProb of data node Y[10507]: logProb less than -1e12.
    #> warning: logProb of data node Y[10508]: logProb less than -1e12.
    #> warning: logProb of data node Y[10511]: logProb less than -1e12.
    #> warning: logProb of data node Y[10516]: logProb less than -1e12.
    #> warning: logProb of data node Y[10519]: logProb less than -1e12.
    #> warning: logProb of data node Y[10520]: logProb less than -1e12.
    #> warning: logProb of data node Y[10522]: logProb less than -1e12.
    #> warning: logProb of data node Y[10525]: logProb less than -1e12.
    #> warning: logProb of data node Y[10527]: logProb less than -1e12.
    #> warning: logProb of data node Y[10533]: logProb less than -1e12.
    #> warning: logProb of data node Y[10537]: logProb less than -1e12.
    #> warning: logProb of data node Y[10539]: logProb less than -1e12.
    #> warning: logProb of data node Y[10542]: logProb less than -1e12.
    #> warning: logProb of data node Y[10545]: logProb less than -1e12.
    #> warning: logProb of data node Y[10547]: logProb less than -1e12.
    #> warning: logProb of data node Y[10553]: logProb less than -1e12.
    #> warning: logProb of data node Y[10559]: logProb less than -1e12.
    #> warning: logProb of data node Y[10562]: logProb less than -1e12.
    #> warning: logProb of data node Y[10563]: logProb less than -1e12.
    #> warning: logProb of data node Y[10565]: logProb less than -1e12.
    #> warning: logProb of data node Y[10569]: logProb less than -1e12.
    #> warning: logProb of data node Y[10574]: logProb less than -1e12.
    #> warning: logProb of data node Y[10577]: logProb less than -1e12.
    #> warning: logProb of data node Y[10579]: logProb less than -1e12.
    #> warning: logProb of data node Y[10580]: logProb less than -1e12.
    #> warning: logProb of data node Y[10581]: logProb less than -1e12.
    #> warning: logProb of data node Y[10585]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10811]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10815]: logProb less than -1e12.
    #> warning: logProb of data node Y[10817]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10823]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10828]: logProb less than -1e12.
    #> warning: logProb of data node Y[10829]: logProb less than -1e12.
    #> warning: logProb of data node Y[10830]: logProb less than -1e12.
    #> warning: logProb of data node Y[10831]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
    #> |-------------|-------------|-------------|-------------|
    #> |-------------------------------------------------------|
    #>   [Warning] There are 46 individual pWAIC values that are greater than 0.4. This may indicate that the WAIC estimate is unstable (Vehtari et al., 2017), at least in cases without grouping of data nodes or multivariate data nodes.
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
    #> warning: logProb of data node Y[2345]: logProb less than -1e12.
    #> warning: logProb of data node Y[2385]: logProb less than -1e12.
    #> warning: logProb of data node Y[5427]: logProb less than -1e12.
    #> warning: logProb of data node Y[5428]: logProb less than -1e12.
    #> warning: logProb of data node Y[5429]: logProb less than -1e12.
    #> warning: logProb of data node Y[5430]: logProb less than -1e12.
    #> warning: logProb of data node Y[5431]: logProb less than -1e12.
    #> warning: logProb of data node Y[5432]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5445]: logProb less than -1e12.
    #> warning: logProb of data node Y[5446]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5448]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5450]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5464]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5468]: logProb less than -1e12.
    #> warning: logProb of data node Y[5469]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10811]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10817]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10823]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10828]: logProb less than -1e12.
    #> warning: logProb of data node Y[10829]: logProb less than -1e12.
    #> warning: logProb of data node Y[10830]: logProb less than -1e12.
    #> warning: logProb of data node Y[10831]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
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
    #> warning: logProb of data node Y[5427]: logProb less than -1e12.
    #> warning: logProb of data node Y[5428]: logProb less than -1e12.
    #> warning: logProb of data node Y[5429]: logProb less than -1e12.
    #> warning: logProb of data node Y[5430]: logProb less than -1e12.
    #> warning: logProb of data node Y[5431]: logProb less than -1e12.
    #> warning: logProb of data node Y[5432]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5445]: logProb less than -1e12.
    #> warning: logProb of data node Y[5446]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5448]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5450]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5464]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5468]: logProb less than -1e12.
    #> warning: logProb of data node Y[5469]: logProb less than -1e12.
    #> warning: logProb of data node Y[9951]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10817]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10823]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10828]: logProb less than -1e12.
    #> warning: logProb of data node Y[10829]: logProb less than -1e12.
    #> warning: logProb of data node Y[10830]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
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
    #> warning: logProb of data node Y[2385]: logProb less than -1e12.
    #> warning: logProb of data node Y[3363]: logProb less than -1e12.
    #> warning: logProb of data node Y[3754]: logProb less than -1e12.
    #> warning: logProb of data node Y[3764]: logProb less than -1e12.
    #> warning: logProb of data node Y[3765]: logProb less than -1e12.
    #> warning: logProb of data node Y[3807]: logProb less than -1e12.
    #> warning: logProb of data node Y[3812]: logProb less than -1e12.
    #> warning: logProb of data node Y[3816]: logProb less than -1e12.
    #> warning: logProb of data node Y[3817]: logProb less than -1e12.
    #> warning: logProb of data node Y[3848]: logProb less than -1e12.
    #> warning: logProb of data node Y[3870]: logProb less than -1e12.
    #> warning: logProb of data node Y[3871]: logProb less than -1e12.
    #> warning: logProb of data node Y[3874]: logProb less than -1e12.
    #> warning: logProb of data node Y[3875]: logProb less than -1e12.
    #> warning: logProb of data node Y[3888]: logProb less than -1e12.
    #> warning: logProb of data node Y[3894]: logProb less than -1e12.
    #> warning: logProb of data node Y[3899]: logProb less than -1e12.
    #> warning: logProb of data node Y[3911]: logProb less than -1e12.
    #> warning: logProb of data node Y[5134]: logProb less than -1e12.
    #> warning: logProb of data node Y[5135]: logProb less than -1e12.
    #> warning: logProb of data node Y[5136]: logProb less than -1e12.
    #> warning: logProb of data node Y[5137]: logProb less than -1e12.
    #> warning: logProb of data node Y[5138]: logProb less than -1e12.
    #> warning: logProb of data node Y[5140]: logProb less than -1e12.
    #> warning: logProb of data node Y[5141]: logProb less than -1e12.
    #> warning: logProb of data node Y[5146]: logProb less than -1e12.
    #> warning: logProb of data node Y[5147]: logProb less than -1e12.
    #> warning: logProb of data node Y[5148]: logProb less than -1e12.
    #> warning: logProb of data node Y[5150]: logProb less than -1e12.
    #> warning: logProb of data node Y[5152]: logProb less than -1e12.
    #> warning: logProb of data node Y[5153]: logProb less than -1e12.
    #> warning: logProb of data node Y[5154]: logProb less than -1e12.
    #> warning: logProb of data node Y[5155]: logProb less than -1e12.
    #> warning: logProb of data node Y[5156]: logProb less than -1e12.
    #> warning: logProb of data node Y[5158]: logProb less than -1e12.
    #> warning: logProb of data node Y[5160]: logProb less than -1e12.
    #> warning: logProb of data node Y[5163]: logProb less than -1e12.
    #> warning: logProb of data node Y[5168]: logProb less than -1e12.
    #> warning: logProb of data node Y[5172]: logProb less than -1e12.
    #> warning: logProb of data node Y[5174]: logProb less than -1e12.
    #> warning: logProb of data node Y[5175]: logProb less than -1e12.
    #> warning: logProb of data node Y[5176]: logProb less than -1e12.
    #> warning: logProb of data node Y[5178]: logProb less than -1e12.
    #> warning: logProb of data node Y[5180]: logProb less than -1e12.
    #> warning: logProb of data node Y[5182]: logProb less than -1e12.
    #> warning: logProb of data node Y[5183]: logProb less than -1e12.
    #> warning: logProb of data node Y[5186]: logProb less than -1e12.
    #> warning: logProb of data node Y[5187]: logProb less than -1e12.
    #> warning: logProb of data node Y[5188]: logProb less than -1e12.
    #> warning: logProb of data node Y[5189]: logProb less than -1e12.
    #> warning: logProb of data node Y[5427]: logProb less than -1e12.
    #> warning: logProb of data node Y[5428]: logProb less than -1e12.
    #> warning: logProb of data node Y[5429]: logProb less than -1e12.
    #> warning: logProb of data node Y[5430]: logProb less than -1e12.
    #> warning: logProb of data node Y[5431]: logProb less than -1e12.
    #> warning: logProb of data node Y[5432]: logProb less than -1e12.
    #> warning: logProb of data node Y[5442]: logProb less than -1e12.
    #> warning: logProb of data node Y[5445]: logProb less than -1e12.
    #> warning: logProb of data node Y[5446]: logProb less than -1e12.
    #> warning: logProb of data node Y[5447]: logProb less than -1e12.
    #> warning: logProb of data node Y[5448]: logProb less than -1e12.
    #> warning: logProb of data node Y[5449]: logProb less than -1e12.
    #> warning: logProb of data node Y[5450]: logProb less than -1e12.
    #> warning: logProb of data node Y[5454]: logProb less than -1e12.
    #> warning: logProb of data node Y[5462]: logProb less than -1e12.
    #> warning: logProb of data node Y[5464]: logProb less than -1e12.
    #> warning: logProb of data node Y[5467]: logProb less than -1e12.
    #> warning: logProb of data node Y[5468]: logProb less than -1e12.
    #> warning: logProb of data node Y[5946]: logProb less than -1e12.
    #> warning: logProb of data node Y[5948]: logProb less than -1e12.
    #> warning: logProb of data node Y[5949]: logProb less than -1e12.
    #> warning: logProb of data node Y[5950]: logProb less than -1e12.
    #> warning: logProb of data node Y[5954]: logProb less than -1e12.
    #> warning: logProb of data node Y[5957]: logProb less than -1e12.
    #> warning: logProb of data node Y[5958]: logProb less than -1e12.
    #> warning: logProb of data node Y[5962]: logProb less than -1e12.
    #> warning: logProb of data node Y[5963]: logProb less than -1e12.
    #> warning: logProb of data node Y[5964]: logProb less than -1e12.
    #> warning: logProb of data node Y[5966]: logProb less than -1e12.
    #> warning: logProb of data node Y[5969]: logProb less than -1e12.
    #> warning: logProb of data node Y[5970]: logProb less than -1e12.
    #> warning: logProb of data node Y[5975]: logProb less than -1e12.
    #> warning: logProb of data node Y[5976]: logProb less than -1e12.
    #> warning: logProb of data node Y[5977]: logProb less than -1e12.
    #> warning: logProb of data node Y[5980]: logProb less than -1e12.
    #> warning: logProb of data node Y[5981]: logProb less than -1e12.
    #> warning: logProb of data node Y[5984]: logProb less than -1e12.
    #> warning: logProb of data node Y[5985]: logProb less than -1e12.
    #> warning: logProb of data node Y[5986]: logProb less than -1e12.
    #> warning: logProb of data node Y[5988]: logProb less than -1e12.
    #> warning: logProb of data node Y[5989]: logProb less than -1e12.
    #> warning: logProb of data node Y[5990]: logProb less than -1e12.
    #> warning: logProb of data node Y[5991]: logProb less than -1e12.
    #> warning: logProb of data node Y[5993]: logProb less than -1e12.
    #> warning: logProb of data node Y[5994]: logProb less than -1e12.
    #> warning: logProb of data node Y[6310]: logProb less than -1e12.
    #> warning: logProb of data node Y[6313]: logProb less than -1e12.
    #> warning: logProb of data node Y[9531]: logProb less than -1e12.
    #> warning: logProb of data node Y[10004]: logProb less than -1e12.
    #> warning: logProb of data node Y[10805]: logProb less than -1e12.
    #> warning: logProb of data node Y[10806]: logProb less than -1e12.
    #> warning: logProb of data node Y[10808]: logProb less than -1e12.
    #> warning: logProb of data node Y[10810]: logProb less than -1e12.
    #> warning: logProb of data node Y[10814]: logProb less than -1e12.
    #> warning: logProb of data node Y[10817]: logProb less than -1e12.
    #> warning: logProb of data node Y[10818]: logProb less than -1e12.
    #> warning: logProb of data node Y[10820]: logProb less than -1e12.
    #> warning: logProb of data node Y[10821]: logProb less than -1e12.
    #> warning: logProb of data node Y[10823]: logProb less than -1e12.
    #> warning: logProb of data node Y[10824]: logProb less than -1e12.
    #> warning: logProb of data node Y[10826]: logProb less than -1e12.
    #> warning: logProb of data node Y[10827]: logProb less than -1e12.
    #> warning: logProb of data node Y[10828]: logProb less than -1e12.
    #> warning: logProb of data node Y[10829]: logProb less than -1e12.
    #> warning: logProb of data node Y[10830]: logProb less than -1e12.
    #> warning: logProb of data node Y[10832]: logProb less than -1e12.
    #> warning: logProb of data node Y[10834]: logProb less than -1e12.
    #> warning: logProb of data node Y[10835]: logProb less than -1e12.
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
    #> Chains (workers): 6 
    #> 
    #>                              Mean    SD Time-series SE   2.5%    50%  97.5% n_eff  R-hat
    #> R[scl_Intc, Intc]          -0.651 0.174          0.010 -0.948 -0.643 -0.254   142  1.045
    #> Intc                        0.107 0.043          0.008  0.015  0.117  0.168    42  1.869
    #> student_ses                 0.082 0.010          0.000  0.063  0.082  0.100  3484  1.000
    #> school_ses                  0.807 0.101          0.009  0.601  0.816  0.987    59  1.354
    #> student_ses:school_ses     -0.042 0.035          0.001 -0.110 -0.041  0.025   458  1.016
    #> sd_Intc                     0.275 0.023          0.002  0.235  0.273  0.322    50  1.316
    #> sd_scl_Intc                 0.890 1.824          0.944  0.049  0.081  5.521    25 18.084
    #> pip[Intc, 1]                0.558 0.497          0.033  0.000  1.000  1.000  3578  1.098
    #> pip[Intc, 2]                0.567 0.495          0.031  0.000  1.000  1.000  2288  1.094
    #> pip[Intc, 3]                0.548 0.498          0.032  0.000  1.000  1.000  1430  1.103
    #> pip[Intc, 4]                0.567 0.496          0.031  0.000  1.000  1.000  2041  1.094
    #> pip[Intc, 5]                0.621 0.485          0.023  0.000  1.000  1.000  1707  1.073
    #> pip[Intc, 6]                0.534 0.499          0.035  0.000  1.000  1.000  1973  1.109
    #> pip[Intc, 7]                0.498 0.500          0.038  0.000  0.000  1.000  1077  1.131
    #> pip[Intc, 8]                0.555 0.497          0.036  0.000  1.000  1.000  2884  1.100
    #> pip[Intc, 9]                0.987 0.114          0.002  1.000  1.000  1.000  3506  1.002
    #> pip[Intc, 10]               0.546 0.498          0.034  0.000  1.000  1.000  1531  1.103
    #> pip[Intc, 11]               0.657 0.475          0.021  0.000  1.000  1.000  1275  1.062
    #> pip[Intc, 12]               0.473 0.499          0.043  0.000  0.000  1.000  1567  1.146
    #> pip[Intc, 13]               0.551 0.497          0.030  0.000  1.000  1.000  1305  1.101
    #> pip[Intc, 14]               0.674 0.469          0.019  0.000  1.000  1.000  1331  1.058
    #> pip[Intc, 15]               0.583 0.493          0.032  0.000  1.000  1.000  3497  1.088
    #> pip[Intc, 16]               0.564 0.496          0.034  0.000  1.000  1.000  4548  1.095
    #> pip[Intc, 17]               0.519 0.500          0.038  0.000  1.000  1.000  2076  1.117
    #> pip[Intc, 18]               0.609 0.488          0.027  0.000  1.000  1.000  3507  1.078
    #> pip[Intc, 19]               0.370 0.483          0.059  0.000  0.000  1.000   511  1.251
    #> pip[Intc, 20]               0.601 0.490          0.028  0.000  1.000  1.000  2229  1.080
    #> pip[Intc, 21]               0.468 0.499          0.040  0.000  0.000  1.000   898  1.150
    #> pip[Intc, 22]               0.642 0.479          0.022  0.000  1.000  1.000  1483  1.067
    #> pip[Intc, 23]               0.581 0.493          0.028  0.000  1.000  1.000  2181  1.088
    #> pip[Intc, 24]               0.570 0.495          0.032  0.000  1.000  1.000  4739  1.092
    #> pip[Intc, 25]               0.551 0.497          0.036  0.000  1.000  1.000  2835  1.101
    #> pip[Intc, 26]               0.593 0.491          0.028  0.000  1.000  1.000  4145  1.083
    #> pip[Intc, 27]               0.540 0.498          0.036  0.000  1.000  1.000  2500  1.106
    #> pip[Intc, 28]               0.496 0.500          0.041  0.000  0.000  1.000  1953  1.131
    #> pip[Intc, 29]               0.577 0.494          0.028  0.000  1.000  1.000  1953  1.089
    #> pip[Intc, 30]               0.528 0.499          0.034  0.000  1.000  1.000  1609  1.112
    #> pip[Intc, 31]               0.552 0.497          0.033  0.000  1.000  1.000  2020  1.100
    #> pip[Intc, 32]               0.569 0.495          0.028  0.000  1.000  1.000  1431  1.093
    #> pip[Intc, 33]               0.569 0.495          0.031  0.000  1.000  1.000  2009  1.093
    #> pip[Intc, 34]               0.680 0.467          0.020  0.000  1.000  1.000  2826  1.055
    #> pip[Intc, 35]               0.712 0.453          0.016  0.000  1.000  1.000  1434  1.047
    #> pip[Intc, 36]               0.479 0.500          0.036  0.000  0.000  1.000   850  1.142
    #> pip[Intc, 37]               0.549 0.498          0.035  0.000  1.000  1.000  3805  1.102
    #> pip[Intc, 38]               0.539 0.499          0.034  0.000  1.000  1.000  1807  1.108
    #> pip[Intc, 39]               0.785 0.410          0.014  0.000  1.000  1.000   565  1.041
    #> pip[Intc, 40]               0.552 0.497          0.035  0.000  1.000  1.000  4335  1.101
    #> pip[Intc, 41]               0.688 0.463          0.018  0.000  1.000  1.000   532  1.057
    #> pip[Intc, 42]               0.538 0.499          0.036  0.000  1.000  1.000  1515  1.107
    #> pip[Intc, 43]               0.502 0.500          0.036  0.000  1.000  1.000  1647  1.127
    #> pip[Intc, 44]               0.531 0.499          0.038  0.000  1.000  1.000  2429  1.111
    #> pip[Intc, 45]               0.517 0.500          0.038  0.000  1.000  1.000  1684  1.118
    #> pip[Intc, 46]               0.997 0.051          0.001  1.000  1.000  1.000  1661  1.001
    #> pip[Intc, 47]               0.544 0.498          0.037  0.000  1.000  1.000  2852  1.105
    #> pip[Intc, 48]               0.673 0.469          0.020  0.000  1.000  1.000  2041  1.057
    #> pip[Intc, 49]               0.583 0.493          0.026  0.000  1.000  1.000  1409  1.088
    #> pip[Intc, 50]               0.604 0.489          0.028  0.000  1.000  1.000  5091  1.079
    #> pip[Intc, 51]               0.560 0.496          0.033  0.000  1.000  1.000  4031  1.097
    #> pip[Intc, 52]               0.617 0.486          0.026  0.000  1.000  1.000  2840  1.074
    #> pip[Intc, 53]               0.842 0.364          0.008  0.000  1.000  1.000  1811  1.023
    #> pip[Intc, 54]               0.656 0.475          0.020  0.000  1.000  1.000  1675  1.062
    #> pip[Intc, 55]               0.491 0.500          0.043  0.000  0.000  1.000  1241  1.134
    #> pip[Intc, 56]               0.564 0.496          0.031  0.000  1.000  1.000  1954  1.095
    #> pip[Intc, 57]               0.673 0.469          0.021  0.000  1.000  1.000  1609  1.057
    #> pip[Intc, 58]               0.500 0.500          0.042  0.000  1.000  1.000  1486  1.128
    #> pip[Intc, 59]               0.522 0.500          0.038  0.000  1.000  1.000  2597  1.117
    #> pip[Intc, 60]               0.594 0.491          0.026  0.000  1.000  1.000  3170  1.083
    #> pip[Intc, 61]               0.407 0.491          0.052  0.000  0.000  1.000   324  1.204
    #> pip[Intc, 62]               0.514 0.500          0.037  0.000  1.000  1.000  1783  1.120
    #> pip[Intc, 63]               0.585 0.493          0.032  0.000  1.000  1.000  1871  1.086
    #> pip[Intc, 64]               0.729 0.444          0.015  0.000  1.000  1.000  2839  1.044
    #> pip[Intc, 65]               0.565 0.496          0.032  0.000  1.000  1.000  1729  1.095
    #> pip[Intc, 66]               0.682 0.466          0.018  0.000  1.000  1.000  2547  1.055
    #> pip[Intc, 67]               0.446 0.497          0.046  0.000  0.000  1.000  1336  1.166
    #> pip[Intc, 68]               0.474 0.499          0.040  0.000  0.000  1.000  1132  1.146
    #> pip[Intc, 69]               0.542 0.498          0.037  0.000  1.000  1.000  3060  1.105
    #> pip[Intc, 70]               0.506 0.500          0.035  0.000  1.000  1.000  1206  1.125
    #> pip[Intc, 71]               0.499 0.500          0.040  0.000  0.000  1.000  1487  1.130
    #> pip[Intc, 72]               0.482 0.500          0.040  0.000  0.000  1.000  1001  1.140
    #> pip[Intc, 73]               0.491 0.500          0.030  0.000  0.000  1.000   514  1.135
    #> pip[Intc, 74]               0.449 0.497          0.031  0.000  0.000  1.000    69  1.051
    #> pip[Intc, 75]               0.557 0.497          0.032  0.000  1.000  1.000  2233  1.098
    #> pip[Intc, 76]               0.547 0.498          0.033  0.000  1.000  1.000  3069  1.104
    #> pip[Intc, 77]               0.553 0.497          0.034  0.000  1.000  1.000  1551  1.100
    #> pip[Intc, 78]               0.535 0.499          0.037  0.000  1.000  1.000  1733  1.110
    #> pip[Intc, 79]               0.493 0.500          0.042  0.000  0.000  1.000  2123  1.132
    #> pip[Intc, 80]               0.584 0.493          0.024  0.000  1.000  1.000  1060  1.063
    #> pip[Intc, 81]               0.598 0.490          0.026  0.000  1.000  1.000  2403  1.081
    #> pip[Intc, 82]               0.601 0.490          0.027  0.000  1.000  1.000  1931  1.080
    #> pip[Intc, 83]               0.573 0.495          0.032  0.000  1.000  1.000  3725  1.092
    #> pip[Intc, 84]               0.590 0.492          0.029  0.000  1.000  1.000  3807  1.084
    #> pip[Intc, 85]               0.547 0.498          0.035  0.000  1.000  1.000  2835  1.103
    #> pip[Intc, 86]               0.566 0.496          0.030  0.000  1.000  1.000  2048  1.095
    #> pip[Intc, 87]               0.760 0.427          0.012  0.000  1.000  1.000  1201  1.038
    #> pip[Intc, 88]               0.559 0.497          0.030  0.000  1.000  1.000  2011  1.097
    #> pip[Intc, 89]               0.613 0.487          0.027  0.000  1.000  1.000  3118  1.076
    #> pip[Intc, 90]               0.530 0.499          0.020  0.000  1.000  1.000   324  1.042
    #> pip[Intc, 91]               0.535 0.499          0.036  0.000  1.000  1.000  1709  1.109
    #> pip[Intc, 92]               0.738 0.440          0.014  0.000  1.000  1.000  2279  1.041
    #> pip[Intc, 93]               0.535 0.499          0.034  0.000  1.000  1.000  1729  1.109
    #> pip[Intc, 94]               0.571 0.495          0.031  0.000  1.000  1.000  1942  1.093
    #> pip[Intc, 95]               0.753 0.431          0.014  0.000  1.000  1.000  1482  1.038
    #> pip[Intc, 96]               0.537 0.499          0.034  0.000  1.000  1.000  1434  1.107
    #> pip[Intc, 97]               0.464 0.499          0.039  0.000  0.000  1.000  1242  1.153
    #> pip[Intc, 98]               0.559 0.497          0.031  0.000  1.000  1.000  1802  1.098
    #> pip[Intc, 99]               0.631 0.483          0.024  0.000  1.000  1.000  3180  1.070
    #> pip[Intc, 100]              0.540 0.498          0.036  0.000  1.000  1.000  4314  1.106
    #> pip[Intc, 101]              0.520 0.500          0.037  0.000  1.000  1.000  1518  1.117
    #> pip[Intc, 102]              0.597 0.490          0.024  0.000  1.000  1.000  1380  1.082
    #> pip[Intc, 103]              0.488 0.500          0.042  0.000  0.000  1.000  1462  1.136
    #> pip[Intc, 104]              0.543 0.498          0.037  0.000  1.000  1.000  2469  1.105
    #> pip[Intc, 105]              0.570 0.495          0.032  0.000  1.000  1.000  2646  1.093
    #> pip[Intc, 106]              0.519 0.500          0.033  0.000  1.000  1.000   666  1.117
    #> pip[Intc, 107]              0.611 0.487          0.026  0.000  1.000  1.000  2386  1.077
    #> pip[Intc, 108]              0.613 0.487          0.022  0.000  1.000  1.000   251  1.077
    #> pip[Intc, 109]              0.604 0.489          0.028  0.000  1.000  1.000  2863  1.079
    #> pip[Intc, 110]              0.487 0.500          0.040  0.000  0.000  1.000  1167  1.136
    #> pip[Intc, 111]              0.542 0.498          0.031  0.000  1.000  1.000   737  1.107
    #> pip[Intc, 112]              0.571 0.495          0.028  0.000  1.000  1.000  1401  1.093
    #> pip[Intc, 113]              0.683 0.465          0.018  0.000  1.000  1.000  2164  1.054
    #> pip[Intc, 114]              0.895 0.307          0.006  0.000  1.000  1.000   815  1.015
    #> pip[Intc, 115]              0.859 0.348          0.008  0.000  1.000  1.000  1845  1.019
    #> pip[Intc, 116]              0.562 0.496          0.029  0.000  1.000  1.000  1202  1.097
    #> pip[Intc, 117]              0.535 0.499          0.038  0.000  1.000  1.000  4992  1.109
    #> pip[Intc, 118]              0.495 0.500          0.039  0.000  0.000  1.000  1494  1.131
    #> pip[Intc, 119]              0.581 0.493          0.029  0.000  1.000  1.000  2445  1.088
    #> pip[Intc, 120]              0.626 0.484          0.026  0.000  1.000  1.000  3420  1.072
    #> pip[Intc, 121]              0.439 0.496          0.047  0.000  0.000  1.000   740  1.172
    #> pip[Intc, 122]              0.620 0.485          0.022  0.000  1.000  1.000   715  1.075
    #> pip[Intc, 123]              0.639 0.480          0.025  0.000  1.000  1.000  2399  1.067
    #> pip[Intc, 124]              0.782 0.413          0.012  0.000  1.000  1.000  1889  1.032
    #> pip[Intc, 125]              0.558 0.497          0.031  0.000  1.000  1.000  1745  1.098
    #> pip[Intc, 126]              0.581 0.493          0.030  0.000  1.000  1.000  2249  1.089
    #> pip[Intc, 127]              0.631 0.483          0.023  0.000  1.000  1.000  1960  1.070
    #> pip[Intc, 128]              0.581 0.493          0.030  0.000  1.000  1.000  2174  1.088
    #> pip[Intc, 129]              0.516 0.500          0.038  0.000  1.000  1.000  2337  1.119
    #> pip[Intc, 130]              0.556 0.497          0.035  0.000  1.000  1.000  2648  1.099
    #> pip[Intc, 131]              0.646 0.478          0.023  0.000  1.000  1.000  3951  1.065
    #> pip[Intc, 132]              0.500 0.500          0.041  0.000  0.000  1.000  2405  1.128
    #> pip[Intc, 133]              0.466 0.499          0.045  0.000  0.000  1.000  1784  1.152
    #> pip[Intc, 134]              0.598 0.490          0.027  0.000  1.000  1.000  1353  1.081
    #> pip[Intc, 135]              0.523 0.499          0.038  0.000  1.000  1.000  2869  1.115
    #> pip[Intc, 136]              0.499 0.500          0.037  0.000  0.000  1.000  1937  1.129
    #> pip[Intc, 137]              0.529 0.499          0.034  0.000  1.000  1.000  1860  1.112
    #> pip[Intc, 138]              0.526 0.499          0.038  0.000  1.000  1.000  3153  1.113
    #> pip[Intc, 139]              0.511 0.500          0.039  0.000  1.000  1.000  1942  1.122
    #> pip[Intc, 140]              0.645 0.478          0.023  0.000  1.000  1.000  2840  1.066
    #> pip[Intc, 141]              0.625 0.484          0.025  0.000  1.000  1.000  3430  1.072
    #> pip[Intc, 142]              0.560 0.496          0.035  0.000  1.000  1.000  3983  1.097
    #> pip[Intc, 143]              0.518 0.500          0.038  0.000  1.000  1.000  1642  1.118
    #> pip[Intc, 144]              0.561 0.496          0.032  0.000  1.000  1.000  3269  1.096
    #> pip[Intc, 145]              0.541 0.498          0.028  0.000  1.000  1.000    82  1.056
    #> pip[Intc, 146]              0.548 0.498          0.035  0.000  1.000  1.000  1762  1.102
    #> pip[Intc, 147]              0.581 0.493          0.032  0.000  1.000  1.000  4314  1.089
    #> pip[Intc, 148]              0.688 0.463          0.019  0.000  1.000  1.000  5345  1.053
    #> pip[Intc, 149]              0.758 0.428          0.014  0.000  1.000  1.000  2149  1.037
    #> pip[Intc, 150]              0.490 0.500          0.038  0.000  0.000  1.000  1832  1.135
    #> pip[Intc, 151]              0.556 0.497          0.035  0.000  1.000  1.000  2195  1.098
    #> pip[Intc, 152]              0.558 0.497          0.033  0.000  1.000  1.000  3481  1.098
    #> pip[Intc, 153]              0.811 0.392          0.010  0.000  1.000  1.000  2501  1.027
    #> pip[Intc, 154]              0.464 0.499          0.039  0.000  0.000  1.000   826  1.153
    #> pip[Intc, 155]              0.530 0.499          0.036  0.000  1.000  1.000  2534  1.112
    #> pip[Intc, 156]              0.608 0.488          0.025  0.000  1.000  1.000  2480  1.078
    #> pip[Intc, 157]              0.609 0.488          0.028  0.000  1.000  1.000  4638  1.077
    #> pip[Intc, 158]              0.571 0.495          0.033  0.000  1.000  1.000  4059  1.092
    #> pip[Intc, 159]              0.559 0.497          0.032  0.000  1.000  1.000  2446  1.098
    #> pip[Intc, 160]              0.595 0.491          0.030  0.000  1.000  1.000  4944  1.082
    #> scl_Intc                    0.337 1.267          0.642 -0.245 -0.227  3.408    21 30.150
    #> scl_student_ses             0.031 0.009          0.000  0.014  0.031  0.049   962  1.004
    #> scl_school_ses              0.786 1.383          0.688  0.104  0.186  4.437    36 11.364
    #> scl_student_ses:school_ses  0.054 0.032          0.002 -0.002  0.051  0.127   100  1.166
    #> 
    #> WAIC: 27056.61 
    #> elppd: -13356.84 
    #> pWAIC: 171.4655

## Plots

### Posterior inclusion probability plot (PIP)

    plot(out, type = "pip")
    #> Warning: ggrepel: 1 unlabeled data points (too many overlaps). Consider increasing max.overlaps

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
