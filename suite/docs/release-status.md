## Suite 0.1.5: Windows installer correction

Core 0.9.2 and summary/margin 0.1.1 calculations are unchanged. On Windows/MP
16.1, all 14 source-directory numerical quickchecks passed for suite 0.1.4.
Its installation check stopped with r(459): net install changed LF line endings
to CRLF, and the post-install checksum rejected otherwise identical content.
Suite 0.1.5 accepts either the exact source bytes or their complete CRLF form
for installed files. The extracted source files still require exact checksums.
The full Windows installation/help workflow must be rerun on this candidate;
the successful numerical checks alone do not establish that workflow passed.

# Release status and method scope

Suite 0.1.5 is a local release candidate: `mcbhsu` 0.9.2, `mcbhsus` 0.1.1 and
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

The initial public phase remains intended for reproducible use and feedback.
Current installation checks cover macOS/MP 16.1. Windows core 0.9.2 numerical checks passed; the corrected Windows installation
workflow, Linux checks and the actual public distribution destination remain outstanding. No vendor executable
validation is claimed. Panel development follows a separate release path.
