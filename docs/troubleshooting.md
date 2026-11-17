# Check installation and resolve common errors

Save your current data and open a fresh Stata session. Change to the repository's
`suite/` directory (or the top level of the versioned suite ZIP), then run:

```stata
do validate_installation.do "my_installation_check"
```

The checker creates synthetic data, installs and reinstalls the suite into
isolated PLUS/PERSONAL directories, executes installed-help examples and runs
14 analytic checks. A successful run creates
`my_installation_check/results/status.txt` containing
`MCBHSU_INSTALLATION_CHECK_PASSED`.

It restores the caller's installation paths and working directory when it
returns, including after an ordinary Stata error. Forced termination may prevent
restoration; open a new session afterward.

## The output directory already exists

The checker deliberately preserves earlier results. Use a different name:

```stata
do validate_installation.do "my_installation_check_second"
```

This differs from a checksum error. You do not need to delete a successful run.
The demonstration `first_steps.do` has different behavior: it may overwrite its
own example files in `onboarding_example/`.

## The installer or another file cannot be found

Extract the entire ZIP. Do not run from a ZIP preview or download one ado file.
Repository downloads contain the installer in `suite/`; the versioned suite ZIP
contains it at the top level. Use Stata's working-directory command to select
the folder containing `install_mcbhsu_suite.do`.

## Checksum error r(459)

Use the complete matching suite 0.1.5. Do not mix components from different
versions or edit files inside `suite/`. A stale copy in the current working
directory can take precedence over the installed command. Inspect:

```stata
which mcbhsu
which mcbhsus
which mcbhsumargin
```

The LF-to-CRLF installation-check defect observed in suite 0.1.4 is corrected in
0.1.5 and was followed by a successful native Windows rerun. If a mismatch remains,
keep the error message and its indicated file path for diagnosis.

## Older saved results are rejected

The current margin command expects results from engine 0.9.2. Recompute the
original analysis with the complete current suite; do not relabel old results.
Use a fresh Stata session when updating commands already loaded in memory.

## What to include in a support report

Use the agreed support channel and include the command, error message, Stata
version, operating system and a small reproducible example. For installation
checks, include `results/status.txt`, `install.csv`, `quickcheck_summary.csv`,
`help_results.csv`, `runtime_checksums.csv`, and the available `check.txt` and
`quickcheck.txt` logs. An absent final receipt means the check has not established
completion. Review local paths before sharing logs; no files are uploaded by the
checker. Share only data you are authorized to distribute.

[Current validation results](validation.md) · [Return to the installation guide](../README.md)
