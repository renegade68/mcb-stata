* Published filter example and raw-summary-margin workflow.
* Save your data and start a fresh Stata session. Requires suite 0.1.4 installed.
* Data: Edwards and Hsu (1983), JASA 78:970, Tables 1 and 2.
* epsilon=25 is an illustrative choice here, not a threshold from the article.
version 16.1
clear all
set more off
set linesize 120
args outdir
if `"`outdir'"'=="" local outdir mcbhsu_paper_results
quietly mcbhsu version
assert "`r(version)'"=="0.9.2"
quietly mcbhsus version
assert "`r(version)'"=="0.1.1" & "`r(engine_version)'"=="0.9.2"
quietly mcbhsumargin version
assert "`r(version)'"=="0.1.1" & "`r(engine_version)'"=="0.9.2"
capture mkdir "`outdir'"
if _rc {
 display as error "Choose a new output folder; existing results are not overwritten."
 exit 602
}
log using "`outdir'/example.txt", text replace
input byte filter double y
1 97
1 117
1 70
2 87
2 72
2 108
3 95
3 112
3 87
4 53
4 68
4 54
5 139
5 133
5 124
6 65
6 61
6 66
7 127
7 125
7 114
end
save "`outdir'/filter_observations.dta"

* 1. Distances from the best of all groups; explicit method avoids the signed default.
mcbhsu y, over(filter) method(edwardshsu) level(95) saving("`outdir'/raw_results.dta")
matrix raw=r(results)
matrix controls=r(control_candidates)
scalar pooled=r(mse)
scalar residual_df=r(df)
assert r(N)==21 & r(K)==7 & r(df)==14 & r(candidates)==4
mata: assert(all(st_matrix("controls"):==(0\0\0\0\1\0\1)))
assert raw[1,8]==1 & controls[1,1]==0
assert raw[3,8]==1 & controls[3,1]==0

* 2. Reproduce the article's second table. This is a different comparison family.
preserve
drop if filter==7
mcbhsu y, over(filter) method(edwardshsu) saving("`outdir'/six_filter_results.dta")
assert r(K)==6 & r(df)==12 & r(candidates)==1
matrix six=r(results)
assert six[5,5]==0 & six[5,6]==0
restore

* 3. The default method has a different signed target and candidate rule.
mcbhsu y, over(filter) saving("`outdir'/constrained_results.dta")
assert "`r(method)'"=="constrained"
assert "`r(target)'"=="best_other_difference"

* 4. Summaries are sufficient under the same independent normal common-variance model.
collapse (count) count=y (mean) avg=y (sd) sd=y, by(filter)
save "`outdir'/filter_summaries.dta"
export delimited using "`outdir'/filter_summaries.csv"
mcbhsus avg, over(filter) n(count) sd(sd) method(edwardshsu) saving("`outdir'/summary_results.dta")
matrix summary=r(results)
mata: st_numscalar("raw_summary_error",max(abs(st_matrix("raw")-st_matrix("summary"))))
assert scalar(raw_summary_error)<1e-10
mcbhsus avg, over(filter) n(count) mse(`=scalar(pooled)') df(`=scalar(residual_df)') method(edwardshsu)
matrix common_mse=r(results)
mata: assert(max(abs(st_matrix("raw")-st_matrix("common_mse")))<1e-10)
* Direction check: negating y and requesting best(min) preserves distance intervals.
generate double negavg=-avg
mcbhsus negavg, over(filter) n(count) sd(sd) best(min) method(edwardshsu)
matrix min_results=r(results)
mata: assert(max(abs(st_matrix("raw")[,4..6]-st_matrix("min_results")[,4..6]))<1e-10)

* 5. The substantive threshold is distinct from the confidence level.
mcbhsumargin using "`outdir'/raw_results.dta", epsilon(25) saving("`outdir'/margin_results.dta")
assert r(within)==1 & r(beyond)==2 & r(uncertain)==4
matrix raw_margin=r(results)
mcbhsumargin using "`outdir'/summary_results.dta", epsilon(25)
matrix summary_margin=r(results)
mata: assert(max(abs(st_matrix("raw_margin")-st_matrix("summary_margin")))<1e-10)

* Export measured results for the manuscript, without hand-entered endpoints.
foreach pair in raw_results six_filter_results constrained_results summary_results margin_results {
 use "`outdir'/`pair'.dta", clear
 export delimited using "`outdir'/`pair'.csv"
}

* Compare the two published families using identical axes.
foreach pair in raw_results six_filter_results {
 use "`outdir'/`pair'.dta", clear
 local heading "Seven filters"
 if "`pair'"=="six_filter_results" local heading "Six filters (7 omitted)"
 twoway (rcap lower upper group_id, horizontal lcolor(navy)) ///
        (scatter group_id estimate, msymbol(O) mcolor(navy)), ///
        ylabel(1(1)7, angle(0)) yscale(reverse) ytitle("Filter") ///
        xlabel(0(25)100) xscale(range(0 110)) xtitle("Distance below best mean") ///
        title("`heading'", size(medsmall)) legend(off) ///
        graphregion(color(white)) name(`pair', replace)
}
graph combine raw_results six_filter_results, cols(2) xcommon ycommon iscale(1) ///
 graphregion(color(white)) xsize(8) ysize(4.8) ///
 title("95% simultaneous distance intervals", size(medium))
graph export "`outdir'/filter_comparison.png", width(2400) replace

use "`outdir'/margin_results.dta", clear
assert candidate[1]==1 & control_candidate[1]==0 & decision[1]==0
assert candidate[2]==0 & decision[2]==0
assert decision[4]==2 & decision[5]==1 & decision[6]==2
twoway (rcap lower upper group_id if decision==0, horizontal lcolor(navy)) ///
       (scatter group_id estimate if decision==0, msymbol(O) mcolor(navy)) ///
       (rcap lower upper group_id if decision==1, horizontal lcolor(forest_green)) ///
       (scatter group_id estimate if decision==1, msymbol(D) mcolor(forest_green)) ///
       (rcap lower upper group_id if decision==2, horizontal lcolor(orange_red)) ///
       (scatter group_id estimate if decision==2, msymbol(T) mcolor(orange_red)), ///
       ylabel(1(1)7, angle(0)) yscale(reverse) ytitle("Filter") ///
       xlabel(0(25)100) xtitle("Distance below best mean") ///
       xline(25, lpattern(dash) lcolor(gs7)) ///
       legend(order(2 "Uncertain" 4 "Within 25" 6 "Beyond 25") rows(1) size(small)) ///
       graphregion(color(white)) xsize(8) ysize(4.8) ///
       note("95% simultaneous intervals; illustrative threshold epsilon = 25.", size(small))
graph export "`outdir'/practical_margin.png", width(2400) replace
clear
set obs 1
generate double raw_summary_max_error=scalar(raw_summary_error)
generate double mse=scalar(pooled)
generate double df=scalar(residual_df)
generate str8 core_version="0.9.2"
generate str8 summary_version="0.1.1"
generate str8 margin_version="0.1.1"
export delimited using "`outdir'/checks.csv"
display "MCBHSU_PAPER_EXAMPLE_PASSED"
log close
