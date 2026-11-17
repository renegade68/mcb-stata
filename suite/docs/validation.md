## Suite 0.1.5: Windows installer correction

Core 0.9.2 and summary/margin 0.1.1 calculations are unchanged. On Windows/MP
16.1, all 14 source-directory numerical quickchecks passed for suite 0.1.4.
Its installation check stopped with r(459): net install changed LF line endings
to CRLF, and the post-install checksum rejected otherwise identical content.
Suite 0.1.5 accepts either the exact source bytes or their complete CRLF form
for installed files. The extracted source files still require exact checksums.
The full Windows installation/help workflow must be rerun on this candidate;
the successful numerical checks alone do not establish that workflow passed.

# Validation and known limitations

The current sources are core 0.9.2, summary 0.1.1 and margin 0.1.1 in suite 0.1.5.
The Edwards–Hsu upper-bound domain now follows the original theorem.

## A check you can run

Save your data, then run `do verify.do` from the extracted folder after installation.
It creates its own data and compares two-group results against analytic t
calculations and native Stata regression. Fourteen cases cover the three methods,
both directions, separated/tied means, missing observations and string keys.
It also checks saved labels and preservation of data and regression coefficients.
Success is reported as `MCBHSU_INDEPENDENT_QUICKCHECK_PASSED`; outputs are written
into `mcbhsu_replication/`. This small check is not validation of every multi-group design.

`do demo_mcbhsu_suite.do` also checks agreement between raw-data and summary-data
results and three practical-margin decisions. `do first_steps.do` reproduces
the user-facing example and graph.

## Current distribution checks

The suite 0.1.5 check uses the complete ZIP in isolated PLUS/PERSONAL
directories on macOS/MP 16.1. The distributed `validate_installation.do` installs
and reinstalls the packages, runs 14 commands extracted from installed help,
the integrated workflow, first steps and all 14 quickcheck cases.
See [how to reproduce the check](external-validation.md). Windows core 0.9.2 numerical checks passed, but the suite 0.1.4 installation
check stopped on CRLF conversion. The corrected suite 0.1.5 Windows workflow
requires a rerun. Linux remains unverified.

## Existing numerical evidence

Development validation included independent R integration, tail and boundary
checks, transformations and candidate rules, and selected raw-data Monte Carlo
experiments. The expanded numerical set covered 16 designs and 32 critical values;
raw-data experiments comprised nine designs with 20,000 replicates each plus
200,000 independent confirmation replicates. These finite checks do not establish
performance for every supported design. They are prior component evidence, not
new experiments rerun for core 0.9.2.

A published 1986 example had an endpoint discrepancy of approximately 0.00068;
independent R integration supported the implemented critical value, but the
historical cause of the printed discrepancy remains unresolved. Actual SAS,
Minitab and JMP executable results have not been obtained.

## Environment and attribution limits

Component tests ran in Stata/MP 16.1 on macOS. A separate Intel Mac/MP 16.1 core
result was received and checked; suite success on that machine was reported by
the user without a separate full suite log.

On 15 November 2026, results from a separate Windows computer running Stata/MP
16.1 were received. All 40 distribution files matched the earlier 0.1.1 candidate by
SHA-256. All 14 quickcheck cases passed, with the success marker present and
numerical results matching the macOS run (maximum scaled error about 3.36e-9).
The received suite and first-steps datasets agreed within 1e-10, and the three
margin decisions and exported graph were checked. The Windows quickcheck loaded
mcbhsu from the working folder. No Windows installer or full suite execution log
was received, so these results do not verify installation into PLUS or every
step of that workflow. Linux and other Stata versions remain unverified.
That 15 November evidence concerns core 0.9.1. The separate 17 November return
contains suite 0.1.4: all 44 distribution files match, core 0.9.2 passed all 14
quickchecks, and the installer failed after text conversion to CRLF. The installed
help tests were not reached. The new manuscript example was not in this return.

## Original-paper alignment in core 0.9.2

The supplied 1983 JASA article and 1984 JASA corrigendum were reviewed for the
supported normal common-variance symmetric case. The corrected sqrt(2) calibration
was already present. The upper bound now follows Theorem 1 and Example 2 by
maximizing over all other groups. The lower bound and compatible control set S
are unchanged. Asymmetric and nonparametric cases in the article are not implemented.

The two published filter tables (13 intervals) agree with a separate calculation
of the original formula to about 1e-13. High-precision endpoints differ from the
printed endpoints by up to 0.064. Using the printed two-decimal means and critical
values reproduces all 13 printed intervals at one decimal place. That is consistent
with printed precision, not a verified account of the authors' calculation workflow.
Independent evaluation of the corrected calibration gives approximately 0.95 at
the two computed critical values. This does not assert exact 95% final MCB coverage.

Regression checks include an explicit control-wise critical-value fixture that
distinguishes the all-other-group upper bound from the former S-only bound,
unequal sample sizes, tied means, singleton S, boundary inclusion, group relabeling,
affine transformations, best(min), raw/summary agreement and saved-result provenance.
The distinguishing fixture tests the interval construction with supplied conservative
critical values; it is not a claim that the current calibration generated those values.
An earlier finite search of 40,000 unequal-size mean arrays found no upper-bound
difference. Neither that search nor these checks prove general old/new equivalence
or coverage across all supported designs. No vendor executable comparison is claimed.

Support requests should include the command, versions, a small reproducible
example and the error message. Do not send confidential data or full Stata
startup logs containing license details.
