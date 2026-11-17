{smcl}
{* *! version 0.1.1 17nov2026}{...}
{title:Title}

{p 4 8 2}{cmd:mcbhsus} {hline 2} Hsu MCB from group summary statistics{p_end}

{title:Syntax}

{p 8 12 2}{cmd:mcbhsus} {it:meanvar} {ifin}{cmd:,} {opt over(groupvar)}
{opt n(countvar)} {opt sd(sdvar)}
[{opt best(max|min)} {opt method(constrained|edwardshsu|tukeygap)}
{opt level(#)} {opt missing} {opt saving(filename [, replace])}
{opt graph} {opt name(graphname)} {opt nocache}]{p_end}

{p 8 12 2}{cmd:mcbhsus} {it:meanvar} {ifin}{cmd:,} {opt over(groupvar)}
{opt n(countvar)} {opt mse(#)} {opt df(#)} [{it:same options}]{p_end}

{p 8 12 2}{cmd:mcbhsus version}{p_end}

{title:Description}

{pstd}Enter one row per independent group. Provide the count, arithmetic mean
and sample standard deviation (not its standard error), or provide the count,
mean, common within-group MSE and residual degrees of freedom. This 0.1.1 add-on
requires the complete {cmd:mcbhsu} 0.9.2 package and Stata 16.1 or later.
The add-on calls its numerical kernels without expanding the supplied counts
into artificial individual observations.{p_end}

{pstd}The model is independent normal observations with a common unknown
variance. In SD mode, df=sum(n)-K and MSE=sum((n-1)*sd^2)/df. In MSE mode,
{cmd:df()} must also equal sum(n)-K. An arbitrary fitted model's residual MSE
and adjusted means are not supported. Rounded published means/SDs can give
different answers from unrounded raw data.{p_end}

{pstd}{cmd:best(max)} is the default. {cmd:best(min)} makes smaller means better.
The default {cmd:method(constrained)} targets the signed difference from the
best OTHER group; zero inclusion is not its screening rule. The distance
methods {cmd:edwardshsu} and {cmd:tukeygap} target the nonnegative distance from
the best of ALL groups. Read {cmd:candidate}=1 as retained as possibly best,
not equality or practical equivalence. See {help mcbhsu} for interpretation
and the distinction between construction controls and final candidates.{p_end}

{title:Input checks}

{pstd}Selected group keys must be unique. Counts must be positive integers,
with sum(n) no greater than 2^53-1. Every included mean must be finite.
For n>1, SD must be finite and nonnegative. For n=1, SD must be missing or zero;
that group contributes zero to within-group SSE. Total residual df and pooled
variance must be positive. {cmd:sd()} and {cmd:mse() df()} are mutually exclusive.
Incomplete summaries raise errors rather than silently dropping groups.{p_end}

{pstd}Missing group keys are excluded unless {cmd:missing} is specified.
Numeric ., .a, ..., .z remain distinct. Numeric codes with duplicate value
labels remain distinct groups; string and strL keys match exactly. The supported
group count is 2-50 and confidence level 80-99.9. {cmd:tukeygap} requires df
from 2 through 1,000,000. Use common outcome units for means and SDs, and squared
units for MSE. Extreme mixed scales may need rescaling.{p_end}

{pstd}The command preserves data, row order, labels, estimation results and
the random-number state. {cmd:saving()} writes one row per group with full keys
and labels; {cmd:replace} is required to overwrite. {cmd:graph} creates the
interval graph and {cmd:name()} assigns its name. {cmd:nocache} disables the
engine's critical-value cache for this call.{p_end}

{pstd}For long labels, resize a named graph before export, for example:
{cmd:graph display mygraph, xsize(12) ysize(6) scale(.65)}. Full labels remain
in returned and saved results even when graph labels are shortened.{p_end}

{title:Examples}

{pstd}These examples create their own summaries and replace the data in memory.
Save your current data first. Both input modes run without extra data files.{p_end}

{phang2}{cmd:clear}{p_end}
{phang2}{cmd:set obs 3}{p_end}
{phang2}{cmd:generate byte group = _n}{p_end}
{phang2}{cmd:generate double count = 5}{p_end}
{phang2}{cmd:generate double avg = 10 + _n}{p_end}
{phang2}{cmd:generate double sd = 0.5 + 0.5*_n}{p_end}
{phang2}{cmd:label define treatments 1 "First" 2 "Second" 3 "Third"}{p_end}
{phang2}{cmd:label values group treatments}{p_end}
{phang2}{cmd:mcbhsus avg, over(group) n(count) sd(sd)}{p_end}
{phang2}{cmd:matrix list r(results)}{p_end}
{phang2}{cmd:mcbhsus avg, over(group) n(count) sd(sd) best(min) method(edwardshsu) graph name(summary_costs) saving(summary_example, replace)}{p_end}
{phang2}{cmd:scalar pooled = r(mse)}{p_end}
{phang2}{cmd:scalar residual_df = r(df)}{p_end}
{phang2}{cmd:graph export summary_example.png, name(summary_costs) width(1600) replace}{p_end}
{phang2}{cmd:mcbhsus avg, over(group) n(count) mse(`=scalar(pooled)') df(`=scalar(residual_df)') best(min) method(edwardshsu)}{p_end}

{title:Stored results}

{pstd}{cmd:r(results)} and {cmd:r(table)} have columns n, mean, SE_mean,
difference, lower, upper, p_exclude, candidate and critical. SE_mean is the
standard error of the group mean. {cmd:r(control_candidates)},
{cmd:r(group_values)} and {cmd:r(near_boundary)} have one row per group.
The numeric values, full labels and keys follow {cmd:mcbhsu}'s conventions.{p_end}

{pstd}Scalars include {cmd:r(N)} (sum of counts, not the number of summary rows),
{cmd:r(K)}, {cmd:r(df)}, {cmd:r(mse)}, {cmd:r(log_mse)}, {cmd:r(candidates)},
{cmd:r(level)}, {cmd:r(groups_excluded)}, {cmd:r(cache_hits)} and
{cmd:r(cache_misses)}. Locals include {cmd:r(input)} (summary_sd or summary_mse),
{cmd:r(cmd)} (mcbhsus), {cmd:r(version)} (0.1.1), {cmd:r(engine_version)} (0.9.2),
{cmd:r(method)}, {cmd:r(best)}, {cmd:r(target)}, {cmd:r(group1)}, ... and
{cmd:r(key1)}, ... . Saved data record both versions and the input mode.{p_end}

{title:References}

{pstd}See {help mcbhsu##references:the full methodological references in mcbhsu}.
The chosen source method determines which papers to cite. For Edwards-Hsu
distances, cite Edwards and Hsu (1983) and their 1984 JASA corrigendum together.
Hsu's 1984 Annals paper is a separate constrained-MCB reference. The downloaded
folder includes docs/methods.md, docs/references.bib and CITATION.cff.{p_end}

{title:Author and license}

{pstd}Choonjoo Lee. Copyright 2026. AFL-3.0. Release candidate.
See docs/validation.md for version-specific macOS and Windows evidence.{p_end}
