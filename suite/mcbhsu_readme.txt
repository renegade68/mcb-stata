mcbhsu 0.9.2 release candidate. Copyright 2026 Choonjoo Lee. AFL-3.0.
Requires Stata 16.1 or later; core 0.9.2 numerical checks in Stata/MP 16.1 on macOS and Windows; native Windows installation evidence is for suite 0.1.5; suite 0.1.6 is a documentation revision; see docs/validation.md.
From the complete suite folder: do install_mcbhsu_suite.do
Then: help mcbhsu
Save your data before running: do demo_mcbhsu.do
The demo replaces data and writes output/.
Independent normal observations with common variance; 2-50 groups.
Retained is not equivalence. Default constrained intervals contain zero;
read the candidate flag. See the supplied README.md and docs/methods.md.
Supported normal Edwards-Hsu case checked against the 1983 article and 1984 corrigendum.
Upper bound uses all other groups, as in Theorem 1. No nonparametric option is implemented.
No vendor executable equivalence is claimed.
