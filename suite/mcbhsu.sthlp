{smcl}
{* *! version 0.9.2 17nov2026}{...}
{title:Title}

{p 4 8 2}{cmd:mcbhsu} {hline 2} Multiple comparisons with the best in an independent one-way normal model{p_end}

{title:Syntax}

{p 8 12 2}{cmd:mcbhsu} {it:y} {ifin}{cmd:,} {opt over(groupvar)}
[{opt best(max|min)} {opt method(constrained|edwardshsu|tukeygap)}
{opt level(#)} {opt missing} {opt saving(filename [, replace])}
{opt graph} {opt name(graphname)} {opt nocache}]{p_end}

{p 8 12 2}{cmd:mcbhsu version}{p_end}
{p 8 12 2}{cmd:mcbhsu clearcache}{p_end}

{title:Description}

{pstd}{cmd:mcbhsu} compares each population mean with the best mean. Specify
{cmd:best(max)} (default) when larger is better; use {cmd:best(min)} when smaller
is better. Numeric and string grouping variables, including strL, are accepted.
Different numeric codes remain different groups even if their value labels match.
The command leaves the original data, observation order, labels, estimation
results, and random-number state unchanged. It is an r-class command.{p_end}

{pstd}This is version 0.9.2, a release candidate. Stata 16.1 or later is required;
runtime checks used Stata/MP 16.1 on macOS and Windows; see docs/validation.md for scope. No community-contributed dependencies,
R, Python, or vendor software are needed for ordinary use.{p_end}

{title:Choose the population quantity first}

{pstd}{cmd:method(constrained)} is the default Hsu constrained MCB procedure.
For {cmd:best(max)} the target is mu_i - max(other mu); for {cmd:best(min)} it is
mu_i - min(other mu). The best OTHER group excludes i. Intervals contain zero
by construction. Therefore zero in the interval is NOT the screening rule.
Read {cmd:candidate}: 1 means retained as possibly best. Screening controls
exclusion of a fixed true best mean; it does not guarantee retaining every
tied best group simultaneously. {cmd:p_exclude} is the one-sided correlated-t
maximum-test tail probability for this screening rule.{p_end}

{pstd}Version 0.9.2 uses the direct t tail for two groups. With three groups
and a positive statistic, and for tiny tails with more groups, it uses a
maximum-coordinate decomposition with conditional t probabilities,
avoiding subtraction from a near-unit CDF. Very small tails may take longer.
A returned zero can still reflect the native univariate tail's numeric range;
it should not be interpreted as a mathematically exact zero.{p_end}

{pstd}{cmd:method(edwardshsu)} reports a NONNEGATIVE distance from the best of
ALL groups: max(mu)-mu_i or mu_i-min(mu), according to {cmd:best()}.
It applies Edwards and Hsu (1983), Theorem 1 and the normal-model Example 2,
using the calibration corrected in the 1984 JASA corrigendum. The lower bound
uses the compatible control set S; the upper bound maximizes over ALL other
groups and is truncated at zero. The current implementation uses symmetric
two-sided critical values under the stated normal common-variance model.
These are simultaneous distance intervals with at least nominal coverage,
subject to numerical accuracy. Retained means lower=0 and need not equal S.
The 1983 article and 1984 corrigendum have been reviewed for this supported
case; the two published tables were reproduced. This option is not the active
final output of SAS's UMCB macro. See docs/methods.md in the downloaded folder.{p_end}

{pstd}{cmd:method(tukeygap)} projects Tukey-Kramer all-pairs intervals to the
SAME nonnegative distance. It is a benchmark, not Hsu MCB. Neither interval
width nor the retained set has a universal ordering against Edwards-Hsu.
For both distance methods {cmd:p_exclude} is missing. Retention establishes
neither equality nor practical equivalence with the best.{p_end}

{title:Options and model scope}

{phang}{opt over(groupvar)} identifies independent groups. Missing outcomes
are always excluded. Missing group values are normally excluded; {opt missing}
includes them as groups. Numeric ., .a, ..., .z are distinct; an empty string
forms a single group. String matching is exact and case-sensitive; Unicode
normalization is not performed. Group order is numeric or Stata string order.{p_end}

{phang}{opt level(#)} sets simultaneous confidence, default {cmd:c(level)}.
Supported levels are 80 through 99.9. This candidate supports 2-50 observed
groups and positive pooled within-group SSE, with N greater than group count.
Singleton groups are allowed when other groups supply residual variation.
{cmd:tukeygap} additionally requires residual df>=2 and <=1,000,000, following
Stata's native Tukey quantile domain. Other methods require df>=1.{p_end}

{pstd}Assumptions: independent normal observations and a common unknown
population variance. Unequal group sizes are supported. The command does not
adjust for covariates, weights, unequal variances, repeated measurements,
clustering, or mixed models. Selecting an option does not test these assumptions.{p_end}

{phang}{opt saving(filename [, replace])} saves one observation per group in a
Stata dataset without replacing the data in memory. Append .dta automatically
if absent. Use quotes around paths with spaces or commas. Metadata record
method, target, direction, confidence level, and version. Full original string
keys and labels are saved (up to 32,000 bytes each). Numeric codes are retained
in {cmd:group_value}; strings in {cmd:group_string}. Display labels may repeat.{p_end}

{phang}{opt graph} plots estimates and simultaneous intervals. The graph is
named {cmd:mcbhsu} unless {opt name()} is supplied; a graph with that name is
replaced. Graph labels use the first 50 Unicode characters, adding g-indices
when those labels coincide. To export, use
{cmd:graph export}. For many groups, enlarge the graph or use the saved results.{p_end}

{phang}{opt nocache} disables reuse/storage of critical values between calls.
Otherwise up to 200 distinct critical-value settings are cached in Mata.
Only counts, degrees of freedom, level, tail type, and computed quantiles are
stored. No observations or labels are cached. Repeated counts reuse a quantile
within a call, even with {cmd:nocache}. {cmd:clear all}, {cmd:mata: mata clear},
or {cmd:mcbhsu clearcache} clears the cache. The backend reloads after Mata clear.{p_end}

{pstd}Internal scaling protects calculations for very small/large outcome units.
{cmd:r(mse)} is missing if the physical variance cannot be stored; use
{cmd:r(log_mse)}. Rescale outcomes if means or interval endpoints overflow.
{cmd:near_boundary} flags some decisions close to numerical precision; it is
a diagnostic, not a different test or a guarantee to detect every borderline case.{p_end}

{title:Examples}

{pstd}The following artificial data make the examples self-contained.
These commands replace the data in memory: save your current data first.
Run the data setup before the analysis commands. They also write or replace
{cmd:mcb_ex.dta} in your working directory.{p_end}

{phang2}{cmd:clear}{p_end}
{phang2}{cmd:set obs 18}{p_end}
{phang2}{cmd:generate byte group = ceil(_n/6)}{p_end}
{phang2}{cmd:generate double y = 10 + 2*group + sin(_n)}{p_end}
{phang2}{cmd:label define mcb_ex 1 "Method A" 2 "Method B" 3 "Method C"}{p_end}
{phang2}{cmd:label values group mcb_ex}{p_end}

{pstd}Check the version and cache commands, then compare the three groups.
The artificial data illustrate syntax; they do not validate model assumptions.{p_end}

{phang2}{cmd:mcbhsu version}{p_end}
{phang2}{cmd:mcbhsu clearcache}{p_end}
{phang2}{cmd:which mcbhsu}{p_end}
{phang2}{cmd:mcbhsu y, over(group)}{p_end}
{phang2}{cmd:mcbhsu y, over(group) best(min) graph name(costs)}{p_end}
{phang2}{cmd:mcbhsu y, over(group) method(tukeygap)}{p_end}
{phang2}{cmd:mcbhsu y, over(group) method(edwardshsu) saving(mcb_ex, replace)}{p_end}
{phang2}{cmd:matrix list r(results)}{p_end}
{phang2}{cmd:return list}{p_end}

{pstd}Full demonstration: if you extracted the ZIP, make the folder containing
{cmd:demo_mcbhsu.do} your working directory and run the command below.
After a standard {cmd:net install}, obtain the ancillary do-file with
{help net:net get} from the same package source, or use the ZIP download first.
The demonstration replaces the data again and writes or replaces its tables
and graphs in {cmd:output/} under your working directory.{p_end}

{phang2}{cmd:do demo_mcbhsu.do}{p_end}

{title:Stored results}

{pstd}{cmd:r(results)} and {cmd:r(table)} are identical K by 9 matrices:
{cmd:n mean SE_mean difference lower upper p_exclude candidate critical}.
{cmd:SE_mean} refers to this group mean, not to the nonlinear target.
{cmd:difference} is the point estimate of {cmd:r(target)}; the saved dataset
calls it {cmd:estimate}. Rows g1,...,gK index this run, not stable group identities.{p_end}

{pstd}{cmd:r(control_candidates)} is the Edwards-Hsu construction set S;
it can differ from the final retained set. For constrained MCB it duplicates
the screening set; for Tukey it is missing. {cmd:r(group_values)} stores numeric
keys (missing for string groups). {cmd:r(near_boundary)} stores diagnostic flags.{p_end}

{pstd}Scalars: {cmd:N}, {cmd:N_excluded} (selected observations dropped for
missingness), {cmd:K}, {cmd:df}, {cmd:mse}, {cmd:log_mse}, {cmd:level},
{cmd:candidates}, {cmd:cache_hits}, {cmd:cache_misses}. Cache counts refer to
distinct control-size settings, not groups; both are zero for Tukey.
Macros: {cmd:cmd}, {cmd:version}, {cmd:method}, {cmd:best}, {cmd:target},
{cmd:depvar}, {cmd:over}, {cmd:group1}... (labels), {cmd:key1}... (raw string keys).{p_end}

{marker references}{...}
{title:References}

{pstd}Edwards, Donald G., and Hsu, Jason C. (1983). Multiple Comparisons with the Best Treatment. Journal of the American Statistical Association, 78(384), 965-971. 
{browse "https://doi.org/10.2307/2288211":10.2307/2288211}.{p_end}

{pstd}Edwards, Donald G., and Hsu, Jason C. (1984). Corrigenda: Multiple Comparisons with the Best Treatment. Journal of the American Statistical Association, 79(388), 965. 
{browse "https://doi.org/10.2307/2288771":10.2307/2288771}.{p_end}

{pstd}Hsu, Jason C. (1981). Simultaneous Confidence Intervals for all Distances from the "Best". The Annals of Statistics, 9(5), 1026-1034. 
{browse "https://doi.org/10.1214/aos/1176345582":10.1214/aos/1176345582}.{p_end}

{pstd}Hsu, Jason C. (1984). Constrained Simultaneous Confidence Intervals for Multiple Comparisons with the Best. The Annals of Statistics, 12(3), 1136-1144. 
{browse "https://doi.org/10.1214/aos/1176346732":10.1214/aos/1176346732}.{p_end}

{pstd}Hsu, Jason C. (1996). Multiple Comparisons: Theory and Methods. London: Chapman & Hall. ISBN 0-412-98281-1. 
{browse "https://www.asc.ohio-state.edu/hsu.1/book.html":Source}.{p_end}

{pstd}Tukey, John W. (1949). Comparing Individual Means in the Analysis of Variance. Biometrics, 5(2), 99-114. 
{browse "https://doi.org/10.2307/3001913":10.2307/3001913}.{p_end}

{pstd}Kramer, Clyde Young (1956). Extension of Multiple Range Tests to Group Means with Unequal Numbers of Replications. Biometrics, 12(3), 307-310. 
{browse "https://doi.org/10.2307/3001469":10.2307/3001469}.{p_end}

{pstd}SAS Institute Inc. (1996). MCB: Multiple Comparisons with the Best. SAS Sample Library; support: Randy Tobias; updated 16 January 1996. 
{browse "https://support.sas.com/documentation/onlinedoc/stat/ex_code/132/mcb.html":Source}.{p_end}

{pstd}Cite Edwards and Hsu (1983) together with their 1984 JASA corrigendum
for {cmd:method(edwardshsu)}. Hsu (1984) in The Annals of Statistics is a
different paper, concerning constrained MCB; its balanced theorem alone does
not prove the unequal-size implementation. For the default constrained method,
cite Hsu (1984) and Hsu (1996); for {cmd:method(tukeygap)}, cite Tukey (1949),
Kramer (1956) and Hsu (1996). Cite the software separately using CITATION.cff
in the downloaded folder. Summary input and practical margins retain the
references of the chosen source method. See docs/methods.md for the mapping
and docs/references.bib for BibTeX entries.{p_end}

{pstd}The SAS sample is a mathematical algorithm reference. This is a new
Stata/Mata implementation; no SAS macro source is distributed. SAS, Minitab
and JMP executables have not been run for validation.{p_end}

{title:Author and license}

{pstd}Choonjoo Lee. Copyright 2026. AFL-3.0; see mcbhsu_license.txt.{p_end}
