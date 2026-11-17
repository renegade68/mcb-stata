version 16.1
* DEMONSTRATION: replaces data in memory. Save your current data first.
clear all
set more off
set linesize 160
capture mkdir output
which mcbhsu
input byte filter double colonies
1 69
1 122
1 95
2 118
2 154
2 102
3 171
3 132
3 182
4 122
4 119
5 204
5 225
5 190
6 140
6 130
6 127
7 170
7 165
end
label define filters 1 "Filter A" 2 "Filter B" 3 "Filter C" ///
    4 "Filter D" 5 "Filter E" 6 "Filter F" 7 "Filter G"
label values filter filters

* Default: signed difference from the best OTHER group mean.
mcbhsu colonies, over(filter) saving("output/constrained", replace) graph name(mcb_signed)
assert r(N)==19 & r(df)==12 & r(candidates)==2
matrix signed_results=r(results)
assert signed_results[5,8]==1 & signed_results[7,8]==1
graph export "output/constrained.png", width(1800) replace

* Different target: nonnegative distance from the best of ALL group means.
mcbhsu colonies, over(filter) method(edwardshsu) ///
    saving("output/edwardshsu", replace) graph name(mcb_distance)
matrix distance_results=r(results)
matrix construction_set=r(control_candidates)
assert r(candidates)==6
graph export "output/edwardshsu.png", width(1800) replace

* Lower values can instead be defined as better.
mcbhsu colonies, over(filter) best(min)

* Benchmark estimating the same nonnegative distance as Edwards-Hsu.
mcbhsu colonies, over(filter) method(tukeygap) saving("output/tukeygap", replace)
matrix list r(results)
return list
display "MCBHSU_DEMO_PASSED"
