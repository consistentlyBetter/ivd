---
title: 'ivd: An R Package for Individual Variance Detection using Spike-and-Slab Priors'
tags:
  - R
  - Bayesian statistics
  - mixed-effects location-scale models
  - variable selection
  - spike-and-slab
authors:
  - name: Philippe Rast
    orcid: 0000-0003-3630-6629
    affiliation: 1
  - name: Marwin Carmo
	orcid: 0000-0002-1052-6300 
    affiliation: 1
affiliations:
 - name: University of California, Davis, USA
   index: 1
date: 19 November 2025
bibliography: paper.bib
---


# Summary

Research in fields such as psychology and education typically focus on average performance of unit (e.g., a student or a school), but the *consistency* or variability of that performance can also carry important information about the units of study [@raudenbush1987jes, @leckie_mixed-effects_2023, rast_modeling_2012]. Standard statistical approaches often treat within-cluster variability as a nuisance parameter or assume it is constant across groups. The `ivd` package implements the Spike-and-Slab Mixed-Effects Location Scale Model (SS-MELSM) as a Bayesian framework to explicitly model and detect heterogeneous residual variances.

`ivd` allows users to simultaneously estimate a model for the means (location) and a model for the within-cluster variability (scale). It employs a spike-and-slab prior on the random effects of the scale component as a probabilistic selection mechanism, distinguishing between clusters that have "usual" variability (shrunk to the population mean, or the spike component) and those with "unusual" variability (belonging to the slab) [@mitchell_bayesian_1988]. This allows the identification of individual units that deviate significantly from the norm; for example, schools with students unusually consistent or inconsistent test scores or patients with unstable (or very stable) symptoms [@leckie_modeling_2014].

# Statement of Need

Standard mixed-effects models partition variance into between-group and within-group components, typically assuming the within-group residual variance ($\sigma^2$) is homogeneous across all groups [@raudenbush_hierarchical_2002]. While Mixed-Effects Location Scale Models (MELSM) relax this assumption by allowing $\sigma^2$ to vary as a function of covariates and random effects [@hedeker_application_2008], they do not inherently provide a decision rule for identifying *which* specific units deviate significantly from the average consistency.

In the `ivd` package MELSMs are expanded with the implementation of the SS-MELSM. This method computes a Posterior Inclusion Probability (PIP) for each cluster's scale random effect. A high PIP indicates strong evidence that a specific cluster belongs to the "slab" distribution, as it translates into a larger Bayes factor for including the $k$th random effect for the $j$th school, meaning it exhibits unusually high or low variability compared to other clustering units [@rodriguez_who_2022, williams_putting_2021].

# `ivd`

The package serves as a user-friendly frontend for **nimble** [@de_valpine_programming_2017], allowing SS-MELSMs to be fitted using standard R formula syntax without needing to write custom BUGS or NIMBLE code. The core function, `ivd()`, accepts two formulas: a `location_formula` for the mean structure and a `scale_formula` for the within-cluster variance structure.

The statistical model simultaneously estimates fixed and random effects for both the location and the scale. For the scale model, the residual standard deviation $\sigma_{ij}$ is modeled as a log-linear function of covariates. The random effects associated with the scale intercept are subject to the spike-and-slab prior, where a binary indicator $\delta_j$ determines inclusion. A high PIP for $\delta_j$ indicates strong evidence that the unit belongs to the "slab" distribution. `ivd` leverages the **future** package, enabling parallel processing of Markov Chain Monte Carlo (MCMC) chains.

## Analysis and Visualization

The `summary()` method returns the fixed effects for both location and scale, along with the PIPs for the random scale effects. To facilitate the detection of atypical units, the package includes several visualization methods via the `plot()` function.

Users can generate different plots by specifying the `type` argument in the `plot()` function: `pip` is the default argument and is used to show units exceeding a certain probability threshold (e.g., 0.75 as default). `funnel` visualizes the relationship between the PIP and the estimated within-cluster standard deviation. Additionally, `outcome` displays the interaction between average performance and consistency. For MCMC convergence diagnostics, the `codaplot()` function offers access to trace and density plots for specific parameters.

## Model Comparison

Comparison of competing models is supported through the Widely Applicable Information Criterion (WAIC), which can be computed during estimation (`WAIC = TRUE` is set by default). Furthermore, `ivd` stores the pointwise log-likelihood matrix, making it compatible with the **loo** package for computing the Leave-One-Out Information Criterion (LOO-IC).

# Usage Example

The following example illustrates the workflow using the `saeb` dataset included in the package. We model mathematics proficiency for students nested within schools, predicting both the mean achievement and the residual variability as a function of student and school socioeconomic status (SES).

``` r
library(ivd)
library(data.table)

## Prepare data: separate within- and between-school SES effects
data(saeb)
school_ses <- saeb[, .(school_ses = mean(student_ses, na.rm = TRUE)), by = school_id]
saeb <- saeb[school_ses, on = "school_id"]
saeb$student_ses <- saeb$student_ses - saeb$school_ses
saeb$school_ses <- c(scale(saeb$school_ses, scale = FALSE))

## Fit the Spike-and-Slab MELSM
model <- ivd(
  location_formula = math_proficiency ~ student_ses * school_ses + (1|school_id),
  scale_formula    = ~ student_ses * school_ses + (1|school_id),
  data             = saeb,
  niter            = 2000,
  nburnin          = 1000,
  WAIC             = TRUE,
  workers          = 2
)

## Summarize results
summary(model)

## Visualizations
## Identify schools with unusual variability (PIP > 0.75)
plot(model, type = "pip")

## Inspect the relationship between PIP and within-cluster SD
plot(model, type = "funnel")

## Check convergence for the intercept
codaplot(model, parameters = "Intc")
```
