# Suite 0.1.5 release candidate

This candidate provides multiple comparisons with the best for independent normal
groups with a common variance, using individual observations or group summaries.
Practical-margin decisions classify distance intervals as within, beyond or
uncertain. Ordinary use requires Stata 16.1 or later and no external software.

## Included versions

- `mcbhsu` 0.9.2
- `mcbhsus` 0.1.1
- `mcbhsumargin` 0.1.1

Suite 0.1.5 corrects installed-file verification for Windows line endings.
The six statistical ado/Mata files are unchanged from suite 0.1.4. The core uses
the Edwards–Hsu upper-bound domain in the original theorem; summary and margin
commands use the same engine and saved-result provenance.

## Verified workflow

Installation, reinstallation, 14 installed-help commands and 14 analytic
quickchecks passed on macOS and Windows with Stata/MP 16.1. The Windows
quickchecks and two example CSVs agree with the macOS records. See
[validation](docs/validation.md) for the exact scope and remaining limits.

## Downloads and examples

For a repository download, start in `suite/`. For the versioned suite ZIP,
start at the extracted top level. Run `do install_mcbhsu_suite.do`, then
`help mcbhsu_suite` and `do first_steps.do`.

The separate [published-filter companion](examples/published-filters/README.txt)
reproduces the article example and its tables and graphs. Its original archive
has a suite-0.1.4 filename; it uses the component versions that remain unchanged
in suite 0.1.5. Its Windows run remains separate from the installation checks.

The tested suite and original companion archives are preserved byte for byte.
This repository adds current user guidance and the received Windows-validation
summary around those fixed files. [Earlier packaged changes](suite/CHANGELOG.md)
remain available for provenance.

## Limits

This remains a candidate for user feedback. It is not an SSC release or a journal
publication. Linux and other Stata versions are unverified. The independent-group
model does not cover covariate-adjusted means, unequal variances, clustered or
repeated observations, or panel/frontier models.
