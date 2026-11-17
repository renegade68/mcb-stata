{smcl}
{* *! version 0.1.1 17nov2026}{...}
{title:Title}

{p 4 8 2}{cmd:mcbhsumargin} {hline 2} Classify distance confidence intervals against a practical margin{p_end}

{title:Syntax}

{p 8 12 2}{cmd:mcbhsumargin}{cmd:,} {opt epsilon(#)}
[{opt saving(filename [, replace])} {opt graph} {opt name(graphname)}]{p_end}

{p 8 12 2}{cmd:mcbhsumargin using} {it:saved_results}{cmd:,} {opt epsilon(#)}
[{it:same options}]{p_end}

{p 8 12 2}{cmd:mcbhsumargin version}{p_end}

{title:Description}

{pstd}Apply a finite nonnegative distance margin, epsilon, to existing
{cmd:method(edwardshsu)} or {cmd:method(tukeygap)} results. The population quantity
is distance from the best of ALL groups: max(mu)-mu_i for {cmd:best(max)}, or
mu_i-min(mu) for {cmd:best(min)}. Use epsilon in the outcome's units.{p_end}

{pstd}With an interval [L,U], decision=1 (Within epsilon) means U<=epsilon;
decision=2 (Beyond epsilon) means L>epsilon; otherwise decision=0 (Uncertain).
L=epsilon<U is uncertain. U=epsilon is within, including L=U=epsilon.
The command compares stored doubles without rounding or a decision tolerance.
{cmd:at_boundary}=1 records exact equality with an endpoint; it does not resolve
numerical uncertainty near a boundary. Use full precision when supplying an
endpoint as epsilon.{p_end}

{pstd}All declarations are correct on the original simultaneous interval
coverage event, under its model and numerical accuracy. The command does not
recompute or narrow intervals, change their level, or calculate new p-values.
Uncertain does not mean beyond the margin. Retained as possibly best does not
mean within epsilon; at epsilon=0, an interval [0,U] with U>0 is uncertain.
These are distance declarations, not an all-pairs equivalence procedure.{p_end}

{pstd}The signed OTHER-best intervals from {cmd:method(constrained)} are rejected.
Rerun the analysis with one of the two distance methods; there is no silent
conversion of estimands. This add-on requires {cmd:mcbhsu} 0.9.2 and Stata 16.1+.
It also accepts results from {cmd:mcbhsus} 0.1.1. Saved results must identify
engine 0.9.2; recompute older saved results with the current suite. The independent normal,
common-variance model and all restrictions of the source analysis still apply.{p_end}

{title:Results in memory or in a file}

{pstd}Without {cmd:using}, run immediately after the distance analysis, before
another r-class command replaces its r() results. Repeated {cmd:mcbhsumargin}
calls can change epsilon without repeating inference. Alternatively, use an
unchanged {cmd:saving()} results dataset from {cmd:mcbhsu}, {cmd:mcbhsus}, or
{cmd:mcbhsumargin}. Saved results need their complete group rows and metadata;
filtered, edited or arbitrary interval tables are not a supported input.{p_end}

{pstd}{cmd:saving()} retains the base columns and adds epsilon, decision and
at_boundary, with a value label for decision and source metadata. Original
candidate flags remain unchanged. {cmd:replace} is required to overwrite.
The user's data, row order, labels, estimation results and RNG are preserved.
{cmd:graph} colors the three decisions and marks epsilon; {cmd:name()} requires
{cmd:graph}. For long labels, resize a named graph with
{cmd:graph display mygraph, xsize(12) ysize(6) scale(.65)} before export.{p_end}

{title:Examples}

{pstd}These examples create their own data and replace data in memory.
Save your current data first. Install the core and add-on before running.{p_end}

{phang2}{cmd:clear}{p_end}
{phang2}{cmd:set obs 30}{p_end}
{phang2}{cmd:generate byte group = ceil(_n/10)}{p_end}
{phang2}{cmd:generate double y = 5*group + sin(_n)}{p_end}
{phang2}{cmd:label define treatments 1 "First" 2 "Second" 3 "Third"}{p_end}
{phang2}{cmd:label values group treatments}{p_end}
{phang2}{cmd:mcbhsu y, over(group) method(edwardshsu) saving(margin_source, replace)}{p_end}
{phang2}{cmd:mcbhsumargin, epsilon(5) graph name(practical) saving(margin_example, replace)}{p_end}
{phang2}{cmd:matrix list r(results)}{p_end}
{phang2}{cmd:graph export margin_example.png, name(practical) width(1800) replace}{p_end}
{phang2}{cmd:mcbhsumargin using margin_source, epsilon(0)}{p_end}
{phang2}{cmd:mcbhsumargin, epsilon(5)}{p_end}

{title:Stored results}

{pstd}{cmd:r(results)} has the original nine columns n, mean, SE_mean,
difference, lower, upper, p_exclude, candidate and critical, followed by
epsilon, decision and at_boundary. {cmd:r(base_results)} retains the nine-column
source result. {cmd:r(control_candidates)}, {cmd:r(group_values)} and
{cmd:r(near_boundary)} preserve source indicators and values.{p_end}

{pstd}Scalars are {cmd:r(epsilon)}, {cmd:r(within)}, {cmd:r(beyond)},
{cmd:r(uncertain)}, {cmd:r(N)}, {cmd:r(K)}, {cmd:r(df)} and {cmd:r(level)}.
Locals include {cmd:r(method)}, {cmd:r(best)}, {cmd:r(target)}, {cmd:r(input)},
{cmd:r(source_cmd)}, {cmd:r(source_version)}, {cmd:r(cmd)}, {cmd:r(version)}
(0.1.1), {cmd:r(engine_version)} (0.9.2), {cmd:r(group1)}, ... and {cmd:r(key1)}, ... .
No input rows or original candidate flags are replaced by margin decisions.{p_end}

{title:Author and license}

{pstd}Choonjoo Lee. Copyright 2026. AFL-3.0. Private development add-on;
installation testing uses Stata/MP 16.1 on macOS. Received Windows/MP 16.1 margin outputs were compared; see docs/validation.md for the limits of that evidence.{p_end}
