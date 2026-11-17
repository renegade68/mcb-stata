## Suite 0.1.5: Windows installer correction

Core 0.9.2 and summary/margin 0.1.1 calculations are unchanged. On Windows/MP
16.1, all 14 source-directory numerical quickchecks passed for suite 0.1.4.
Its installation check stopped with r(459): net install changed LF line endings
to CRLF, and the post-install checksum rejected otherwise identical content.
Suite 0.1.5 accepts either the exact source bytes or their complete CRLF form
for installed files. The extracted source files still require exact checksums.
The full Windows installation/help workflow must be rerun on this candidate;
the successful numerical checks alone do not establish that workflow passed.

# Check installation on your computer

This check needs Stata 16.1 or later, the complete extracted suite, and no R,
Python or other user-installed package. It uses synthetic data only. The script
is intended for macOS, Windows and Linux; successful execution on one system
does not certify the others. See [tested environments](validation.md).

1. Save your current data and open a fresh Stata session.
2. Change the working directory to the extracted folder containing
   `validate_installation.do`.
3. Run:

```stata
do validate_installation.do
```

The destination `mcbhsu_installation_check` must not already exist. To keep a
previous run, use a different new folder, for example:

```stata
do validate_installation.do "mcb_check_second"
```

The check creates isolated PLUS and PERSONAL directories, installs and reinstalls
the four packages, and checks that commands and help resolve to that installation.
It extracts and runs the 14 example commands from the installed suite help, then
runs the combined demonstration, first example and 14 analytic quickchecks from
an analysis directory separate from the source files. The caller's PLUS/PERSONAL
paths and working directory are restored when the worker returns, including on
an ordinary Stata error. Forced termination may prevent restoration; open a new
Stata session afterward. The test replaces data and clears loaded programs;
use a fresh session for subsequent work.

Success ends with `MCBHSU_INSTALLATION_CHECK_PASSED` and produces
`mcbhsu_installation_check/results/status.txt`. An incomplete folder or a single
successful numerical table is not evidence that the full test completed.

## Results to share

Share the following files from `results/` through the agreed support channel:

- `status.txt` and `install.csv`: completion and Stata/OS versions;
- `help_results.csv` and `quickcheck_summary.csv`: installed-help and analytic results;
- `runtime_checksums.csv`: the checked calculation file identities;
- `first_steps_decisions.csv`, `example.png` and `first_steps_decisions.png`;
- `check.txt` and `quickcheck.txt` if diagnosing a failure.

Logs can contain local paths. Review those before sharing; do not send licensed
Stata files, license information, confidential data, or a full startup log.
There is no automatic upload. On failure, share the last error and the available
files rather than reporting the whole workflow as passed.

These checks assess installation and selected numerical behavior. They do not
prove coverage for every design or complete the historical source audit.

## Repeating the check

An existing results directory is deliberately never overwritten. Use a fresh
Stata session and a new output name, for example:

```stata
do validate_installation.do "windows_check_015_second"
```

An existing-directory error is different from r(459) caused by a checksum mismatch.
Keep both logs if the first and second attempts differ.
