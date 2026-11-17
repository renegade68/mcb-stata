* Save your data first. This example replaces them.
* Run in the extracted suite folder, or after installing all three commands.
version 16.1
clear
set more off
adopath ++ "."
set obs 30
generate byte group=ceil(_n/10)
generate double y=5*group+sin(_n)
label define treatments 1 "First" 2 "Second" 3 "Third"
label values group treatments
capture mkdir suite_example
mcbhsu y, over(group) method(edwardshsu) saving(suite_example/raw_results.dta, replace)
matrix suite_raw=r(results)
collapse (count) count=y (mean) avg=y (sd) sd=y, by(group)
mcbhsus avg, over(group) n(count) sd(sd) method(edwardshsu) saving(suite_example/summary_results.dta, replace)
matrix suite_summary=r(results)
mata: assert(max(abs(st_matrix("suite_raw")-st_matrix("suite_summary")))<1e-10)
mcbhsumargin, epsilon(5) graph name(suite_practical) saving(suite_example/decisions.dta, replace)
assert r(within)==1 & r(beyond)==1 & r(uncertain)==1
matrix suite_margin=r(results)
mcbhsumargin using suite_example/raw_results.dta, epsilon(5)
matrix suite_raw_margin=r(results)
mata: assert(max(abs(st_matrix("suite_margin")-st_matrix("suite_raw_margin")))<1e-10)
mcbhsumargin using suite_example/summary_results.dta, epsilon(5)
assert r(within)==1 & r(beyond)==1 & r(uncertain)==1
mcbhsumargin using suite_example/decisions.dta, epsilon(0)
assert r(within)==1 & r(beyond)==2 & r(uncertain)==0
assert _N==3 & r(N)==30 & r(df)==27
display "MCBHSU_SUITE_DEMO_PASSED"
