# Release status and method scope

Suite 0.1.6 is a local release candidate: `mcbhsu` 0.9.2, `mcbhsus` 0.1.1 and
`mcbhsumargin` 0.1.1. Install the complete suite in a fresh Stata session.
The version label does not claim journal acceptance, SSC availability or
validation on every operating system.

| Feature | Target or role | Evidence and remaining limit |
|---|---|---|
| Default constrained MCB | Signed difference from the best other group; candidate screening | Calculation unchanged; candidate flags must not be replaced by zero-in-interval screening |
| Edwards–Hsu construction | Nonnegative distance from the best of all groups | Supported normal symmetric case aligned with the 1983 theorem and corrected 1984 calibration; published tables reproduced; no asymmetric/nonparametric implementation |
| Tukey gap benchmark | Same nonnegative distance from all-pair bounds | Calculation unchanged; benchmark, not another name for Hsu MCB |
| Summary input | Same model and engine with group summaries | Raw/summary agreement checked; not an unequal-variance model |
| Practical margins | Within, beyond or uncertain relative to epsilon | Inherits source intervals; requires results from engine 0.9.2 |

All options require the documented independent normal common-variance model.
A candidate is not evidence of equivalence. The suite does not implement panel,
DEA or general stochastic-frontier estimation. See [methods](methods.md) and
[validation](validation.md) for assumptions and the limits of the checks.

The new engine uses all other groups in the Edwards–Hsu upper bound, directly
following the original theorem. The former upper bound used only compatible
controls S. No numerical discrepancy was found in the documented finite search,
but general equality is not a premise of the current implementation.

The candidate is intended for reproducible use and feedback. See
[version-specific validation](validation.md) and [complete references](methods.md#references-and-attribution).
