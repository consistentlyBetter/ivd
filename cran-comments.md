## Resubmission of initial package:

This resubmission addresses all issues raised by the CRAN team (Benjamin Altmann).

- Title: Quotation marks have been removed
- Executable examples added to all exported functions, where possible. Some functions are exported for only for `future` parallelization: These examples are wrapped in dontrun{}
- Remove all information messages to the console that cannot be easily suppressed.


## Resubmission of initial package:

This resubmission addresses all issues raised by the CRAN team (Konstanze Lauseker).

### DESCRIPTION references
- Added method references in the DESCRIPTION file using the required
  format: authors (year) <doi:...>.

### Missing \value{} tags
- Added complete, CRAN-compliant `\value{}` sections for all exported
  functions:
  - `ivd()`
  - `build_ivd_model()`
  - `run_MCMC_compiled_model()`
  - `plot.ivd()`

### Examples and \dontrun
- All `\dontrun{}` blocks have been replaced with `\donttest{}`.
- Functions and examples are tested in the testthat environment.

### Console output
- The user-generated `print()` statement has been replaced with
  `message()`, making it fully suppressible.
- The remaining console output observed during model fitting originates
  from the NIMBLE backend (model building, configuration, and C++
  compilation). These messages are produced by the external library and
  cannot be controlled or suppressed by this package.

### R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

* This is a new release.
