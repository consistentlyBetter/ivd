# ivd (development version)

## New features

* `ivd()` accepts arbitrary grouping IDs (character, factor, or numeric with
  gaps, e.g. real school codes). IDs are recoded internally to the 1..J index
  NIMBLE needs -- without reordering the data -- and the original labels are
  stored on the fitted object as `group_labels`.
* `summary()` and `plot()` gained a shared `labels = c("index", "original")`
  argument: the default keeps the compact internal cluster index in both
  displays; `"original"` switches both to the user's own grouping IDs.
* New `print()` method for fitted objects: formulas, data dimensions,
  sampling setup, and a one-line convergence note (max split-Rhat, min
  n_eff).
* New `pip()` extractor returning the posterior inclusion probabilities as a
  tidy data frame (one row per cluster x scale random effect, with the
  original cluster IDs).
* New `fixef()`, `ranef()`, and `coef()` extractors following the lme4/nlme
  conventions (without adding a dependency on either).
* New `pip_sensitivity()`: analytic prior-sensitivity for the PIPs. The
  posterior odds are converted to a prior-independent Bayes factor and
  re-weighted across a grid of prior inclusion probabilities -- no refit
  needed. Comes with a `plot()` method showing per-cluster PIP trajectories
  (prior-sensitive clusters highlighted; subset with `clusters =`).
* `summary()` now returns a structured `summary.ivd` object (`$table`,
  `$waic`, `$lppd`, `$pwaic`, `$chains`) rendered by a separate `print()`
  method; console output is unchanged.

## Bug fixes

* Fixed a crash in the default `n_eff = "local"` diagnostics on short or
  strongly autocorrelated chains (Geyer truncation over an empty set
  produced `1:Inf`).
* `.autocorrelation_fft()` now actually zero-pads, computing a linear rather
  than circular autocorrelation; results match `stats::acf()`.
* Fixed the row offset linking PIPs to clusters in `summary()` and
  `codaplot()` for models where the number of location and scale random
  effects differ.
* `DESCRIPTION` now correctly states that the spike-and-slab prior is on the
  *scale* random effects, and cites the published paper:
  Carmo, Williams & Rast (2026) <doi:10.3102/10769986261426004>.

## ivd 1.0.0

Initial CRAN release
