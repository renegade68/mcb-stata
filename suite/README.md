## Suite 0.1.5: Windows installer correction

Core 0.9.2 and summary/margin 0.1.1 calculations are unchanged. On Windows/MP
16.1, all 14 source-directory numerical quickchecks passed for suite 0.1.4.
Its installation check stopped with r(459): net install changed LF line endings
to CRLF, and the post-install checksum rejected otherwise identical content.
Suite 0.1.5 accepts either the exact source bytes or their complete CRLF form
for installed files. The extracted source files still require exact checksums.
The full Windows installation/help workflow must be rerun on this candidate;
the successful numerical checks alone do not establish that workflow passed.

# Multiple comparisons with the best for Stata

Compare independent treatment means with the unknown best population mean,
using a one-way normal model with a common unknown variance.
[한국어 안내](README_ko.md).

**Suite 0.1.5 — release candidate.** Includes `mcbhsu` 0.9.2 (raw observations),
`mcbhsus` 0.1.1 (group summaries), and `mcbhsumargin` 0.1.1 (practical margins).
Stata 16.1 or later is required. Ordinary use needs no R, Python or SSC packages.
Installation and workflow checks cover Stata/MP 16.1 on macOS. Separate Windows/MP 16.1 numerical results are also available; see the [validation scope](docs/validation.md).

## Install

Obtain the complete suite ZIP and extract it completely. If downloading from
GitHub, use **Code > Download ZIP** for a snapshot or the designated versioned
release archive when available. Open a fresh
Stata session. Use **File > Change working directory** (or `cd "path/to/extracted-folder"`)
to select the folder containing `install_mcbhsu_suite.do`, then run:

```stata
do install_mcbhsu_suite.do
which mcbhsu
which mcbhsus
which mcbhsumargin
help mcbhsu_suite
```

Use a fresh Stata session when updating loaded commands. The installer verifies
supplied files, then installs four packages sequentially; it is not a rollback
transaction. After installation you can work in another directory. Older copies
in your working directory can take precedence: inspect `which` if results differ.
Keep the complete extracted folder when rerunning the installer. Installation
uses these local files. The instructions here do not require a remote Stata
net-install URL. See [release status and method scope](docs/release-status.md).

## Run a complete example

Save your current data first: these examples replace data in memory and write
results into `onboarding_example/` and `suite_example/`.

```stata
do first_steps.do
* Optional: raw data -> group summaries -> practical margins
do demo_mcbhsu_suite.do
```

The first example constructs its own data and finishes with
`MCBHSU_FIRST_STEPS_PASSED`. [Read its results](docs/quickstart.md).

## Check a new installation

In a fresh Stata session, from the complete extracted folder:

```stata
do validate_installation.do
```

This creates an isolated installation and runs the installed help and examples.
The destination must be new. See [external validation](docs/external-validation.md)
for the steps and files to share; nothing is uploaded automatically.

## Use your data

Replace `y` and `treatment` with your outcome and group variables.

```stata
* Which groups remain possibly best?
mcbhsu y, over(treatment) graph

* Distance from the best population mean
mcbhsu y, over(treatment) method(edwardshsu) graph

* Immediately afterward: is the distance within five outcome units?
mcbhsumargin, epsilon(5) graph
```

Larger means are better by default. Add `best(min)` to the analysis command
when smaller means are better. Choose epsilon in your outcome's units before
interpreting the decisions; five is only an illustration. For summary data,
see `help mcbhsus` and `do demo_mcbhsus.do`.

`Retained` means not excluded as possibly best. It does **not** establish equality,
equivalence, or being within epsilon. Default constrained intervals include zero
by construction: use the candidate flag for screening. Distance methods answer
a different question. See [methods and assumptions](docs/methods.md).

## Scope and verification

Supports 2–50 groups, unequal group sizes, numeric/string group keys and
confidence levels 80–99.9. Requires independent normal observations, common
variance and positive residual variation. Unequal variances, covariates, repeated measurements and clustered data are
outside this one-way implementation. Panel/frontier research is not a supported
command in this distribution. Some unbalanced
settings and small tail probabilities can require lengthy numerical integration.

A small self-contained check is available with `do verify.do` (save your data
first). [Validation and known limitations](docs/validation.md) distinguish
executed checks from unverified environments and source-attribution limitations.
The supported normal Edwards–Hsu case has been compared with the 1983 article
and its 1984 JASA corrigendum. Core 0.9.2 uses every other group in the upper
bound, matching the original theorem. Published examples and regression checks
are documented in [validation](docs/validation.md). No vendor executable
validation is claimed. Recompute older saved results with this complete suite
before using the new margin command.

Copyright 2026 Choonjoo Lee. [AFL-3.0](LICENSE).
See [citation information](CITATION.cff) and [changes](CHANGELOG.md).
