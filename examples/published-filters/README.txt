Reproduce the independent-group mcbhsu manuscript example
Suite 0.1.4 companion; 17 November 2026
Copyright 2026 Choonjoo Lee. AFL-3.0; see LICENSE.

Requirements
Stata 16.1 or later and the complete installed suite 0.1.4:
mcbhsu 0.9.2, mcbhsus 0.1.1, mcbhsumargin 0.1.1.
No R, Python, external statistical package, or data download is needed.
This companion does not contain or replace the suite installation package.

Run
Save your data and open a fresh Stata session. From the extracted suite folder:
    do install_mcbhsu_suite.do
Then change to this companion folder and run:
    do reproduce_mcbhsu.do
Success ends with MCBHSU_PAPER_EXAMPLE_PASSED. The script replaces working data.
It creates mcbhsu_paper_results and refuses to reuse an existing folder.
For another run, supply a new name:
    do reproduce_mcbhsu.do "second_results"

Example
The 21 numeric observations are transcribed from Edwards and Hsu (1983),
Multiple Comparisons With the Best Treatment, JASA 78:965-971, p. 970.
DOI: https://doi.org/10.2307/2288211
The script reproduces the seven-filter analysis and the six-filter analysis
that omits filter 7. It also runs the signed default, aggregates the raw data,
checks both summary input forms and best(min), and compares practical-margin
results obtained from raw and summary saved results.

Read the outputs
In the seven-filter example, compatible controls S={5,7}, whereas distance
candidates C={1,3,5,7}. With the illustrative epsilon=25, filter 5 is within,
filters 4 and 6 are beyond, and filters 1,2,3,7 are uncertain. The threshold is
an illustration here, not a substantive standard supplied by the original paper.
A distance candidate is not demonstrated equivalent or within the margin.
The six-filter example changes the comparison family and pooled variance; it
is not advice to omit groups after inspecting results.

Outputs
CSV and Stata datasets record raw, summary, signed-default and margin results.
filter_comparison.png compares the two published families on common axes.
practical_margin.png shows the seven-filter intervals against epsilon=25.
checks.csv records versions and the maximum raw/summary matrix difference.
example.txt is the execution log. expected/ contains the checked CSV and PNG
outputs from macOS Stata/MP 16.1. Figures may render differently across platforms.

Scope
Assumes independent normal observations and common within-group variance.
Not a panel, unequal-variance, DEA, or general estimated-means procedure.
Current Windows suite results are pending. This example does not replace the
suite's separate installation check: do validate_installation.do.
