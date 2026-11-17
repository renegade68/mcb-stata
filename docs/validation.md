# Validation and remaining limits

## Current candidate: suite 0.1.5

The suite contains `mcbhsu` 0.9.2, `mcbhsus` 0.1.1 and `mcbhsumargin` 0.1.1.
The installation workflow completed on **macOS and a separate Windows computer,
both running Stata/MP 16.1**. The Windows evidence was received on 17 November 2026.

| Check | Recorded result |
| --- | --- |
| Install and reinstall into isolated PLUS/PERSONAL directories | Passed on both systems |
| Commands actually loaded from the isolated installation | Confirmed |
| Commands extracted from the installed combined help | 14 executed successfully on each system |
| Independent analytic quickchecks | All 14 passed on each system |
| Raw observations, group summaries and practical-margin workflow | Passed |
| Windows quickcheck errors and two example CSVs versus macOS | Matched |
| Windows installed runtime/help files | All 10 matched the suite after accounting for CRLF |
| Final installation receipt | `MCBHSU_INSTALLATION_CHECK_PASSED` |

The largest scaled error in the 14 analytic quickchecks was approximately
3.36e-9, below their 1e-6 acceptance threshold. These small two-group checks
compare against analytic t calculations and native Stata regression; they are
not a test of every multi-group design or a proof of coverage.

The Windows result identifies the installed PLUS code, not copies in the current
working folder. The two returned example graphs were checked against their CSVs.
Local execution paths and raw diagnostic logs are retained in the development
archive rather than included in this user distribution.

## Line endings and repeated checks

An earlier suite 0.1.4 Windows installation stopped because the installed files
had CRLF line endings and its byte-level check expected LF. Suite 0.1.5 accepts
the original bytes or their complete CRLF form. Source-folder verification stays
strict. The subsequent native Windows installation and reinstallation passed.

Using an existing check directory is a different matter: the checker refuses to
overwrite it. Use a new directory name for another run. See
[troubleshooting](troubleshooting.md).

## Mathematical and numerical evidence

For the supported independent normal common-variance symmetric construction,
the Edwards–Hsu 1983 article and 1984 corrigendum were reviewed. Core 0.9.2 uses
all other groups in the upper bound and the compatible-control set in the lower
bound. The corrected normal-calibration factor is included.

The two published filter tables contain 13 intervals. Their high-precision
calculations agree with an independent evaluation of the original formula to
approximately 1e-13. Reconstructing with the printed two-decimal means and
critical values reproduces all 13 printed intervals at one decimal. This is
consistent with limited printed precision, not a verified account of the
historical calculation workflow. Calibration probabilities near 0.95 describe
the fixed-control calculation, not exact 95% coverage of every final MCB interval.

Further recorded checks include boundary rules, group permutations, affine
transformations, raw/summary agreement, saved-result provenance and finite
unequal-size comparisons. [Methods](methods.md) distinguishes the signed
constrained target, Edwards–Hsu distances and the all-pairs Tukey benchmark.
The unequal-size constrained implementation should not be presented as a
verbatim consequence of the balanced theorem alone.

## Separate manuscript example

[The published-filter companion](../examples/published-filters/README.txt)
checks both published comparison families, raw/summary agreement, reversal of
the preferred direction and practical-margin decisions. It was executed on
macOS/MP 16.1. Its Windows execution is not included in the installation evidence.
The original companion used suite 0.1.4; the six statistical ado/Mata files and
component versions are identical in suite 0.1.5.

## Limits and version-specific notes

Linux and other Stata versions have not been verified. These results cover the
recorded workflows on the tested systems, not every supported design. Actual
SAS, JMP and Minitab executable equivalence is not claimed. Asymmetric,
nonparametric, heteroskedastic and panel constructions are outside this suite.

The `suite/` directory is the unchanged tested 0.1.5 distribution. Its embedded
validation text records the earlier, pending state; this page records the
subsequently completed Windows check. The mathematical references and historical
component evidence remain available in [the packaged notes](../suite/docs/validation.md).
Candidate status is retained. No journal acceptance or SSC registration is claimed.
