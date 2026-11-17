{smcl}
{* *! suite version 0.1.5 17nov2026}{...}
{title:Title}

{p 4 8 2}{cmd:mcbhsu suite} {hline 2} Raw data, group summaries and practical distance decisions{p_end}

{title:Installation}

{pstd}Extract the complete suite ZIP, make that folder the Stata working
directory, and type {cmd:do install_mcbhsu_suite.do}. It checks the supplied
files and installs the three existing packages plus this guide. It keeps their
original package registrations. No separate Python or R installation is needed.
Use a fresh Stata session when updating already loaded development versions.{p_end}

{pstd}Then move to your analysis working directory and check {cmd:which mcbhsu},
{cmd:which mcbhsus} and {cmd:which mcbhsumargin}. Older copies in a working
directory may take precedence. The installer checks located runtime files;
it does not remove older user files automatically.{p_end}

{title:Choose the next command}

{pstd}Use {help mcbhsu} for individual observations; {help mcbhsus} for one row
per group with n, mean and sample SD, or common MSE and matching df.
Use {help mcbhsumargin} after a distance analysis, or with complete saved results,
to compare its intervals with epsilon. With raw data, ensure the same analysis
sample is used before collapsing to summaries.{p_end}

{pstd}All commands use the independent normal, common-variance one-way model.
The default constrained MCB estimates a signed difference from the best OTHER
group; its candidate flag is not the zero-in-interval rule. For practical
distance decisions, choose {cmd:method(edwardshsu)} or {cmd:method(tukeygap)}.
Their target is the nonnegative distance from the best of ALL groups.
Tukey is a benchmark, not another name for Hsu MCB.{p_end}

{pstd}For distance bounds [L,U], U<=epsilon means within the margin, L>epsilon
means beyond, and the rest is uncertain. Existing candidates and intervals are
unchanged. Possibly best does not establish equivalence or certify a practical
margin. These decisions rely on the source intervals' simultaneous coverage,
model assumptions and numerical accuracy.{p_end}

{title:Examples}

{pstd}Save your data first: this complete workflow creates data and replaces
them with summaries. No external data file is needed.{p_end}

{phang2}{cmd:clear}{p_end}
{phang2}{cmd:set obs 30}{p_end}
{phang2}{cmd:generate byte group = ceil(_n/10)}{p_end}
{phang2}{cmd:generate double y = 5*group + sin(_n)}{p_end}
{phang2}{cmd:mcbhsu y, over(group) method(edwardshsu) saving(suite_raw, replace)}{p_end}
{phang2}{cmd:matrix raw = r(results)}{p_end}
{phang2}{cmd:collapse (count) count=y (mean) avg=y (sd) sd=y, by(group)}{p_end}
{phang2}{cmd:mcbhsus avg, over(group) n(count) sd(sd) method(edwardshsu) saving(suite_summary, replace)}{p_end}
{phang2}{cmd:matrix summary = r(results)}{p_end}
{phang2}{cmd:mcbhsumargin, epsilon(5) graph name(suite_practical) saving(suite_decisions, replace)}{p_end}
{phang2}{cmd:graph export suite_practical.png, name(suite_practical) width(1800) replace}{p_end}
{phang2}{cmd:mcbhsumargin using suite_raw, epsilon(5)}{p_end}
{phang2}{cmd:mcbhsumargin using suite_summary, epsilon(5)}{p_end}
{phang2}{cmd:mcbhsumargin using suite_decisions, epsilon(0)}{p_end}

{title:Versions and scope}

{pstd}Suite 0.1.5 packages {cmd:mcbhsu} 0.9.2, {cmd:mcbhsus} 0.1.1 and
{cmd:mcbhsumargin} 0.1.1. The suite version describes the distribution, not a new
estimator. Source verification, installation and numerical evidence are recorded
separately. Installation and workflow checks use Stata/MP 16.1 on macOS. Separate
Windows/MP 16.1 passed 14 source-directory numerical quickchecks for core 0.9.2.
Suite 0.1.4 installation checking rejected Windows line-ending conversion;
suite 0.1.5 fixes that check. The full Windows installed-help workflow still
requires a rerun. See docs/validation.md in the downloaded folder. The supported normal case has been checked against the
1983 article and 1984 JASA corrigendum. Version 0.9.2 uses all other groups in
the Edwards-Hsu upper bound, as in the original theorem.{p_end}

{title:Author and license}

{pstd}Choonjoo Lee. Copyright 2026. AFL-3.0. Release candidate.{p_end}
