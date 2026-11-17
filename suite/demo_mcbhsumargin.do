* Save your data first. Run from the full source distribution root.
version 16.1
clear
set more off
adopath ++ "."
adopath ++ "margin"
set obs 30
generate byte group=ceil(_n/10)
generate double y=5*group+sin(_n)
label define treatments 1 "First" 2 "Second" 3 "Third"
label values group treatments
mcbhsu y, over(group) method(edwardshsu)
mcbhsumargin, epsilon(5) graph name(practical)
assert r(within)==1 & r(beyond)==1 & r(uncertain)==1
matrix base=r(base_results)
mcbhsumargin, epsilon(0)
assert r(within)==1 & r(beyond)==2 & r(uncertain)==0
mata: assert(all((st_matrix("base"):<.):==(st_matrix("r(base_results)"):<.)))
mata: assert(max(abs(st_matrix("base")-st_matrix("r(base_results)")))==0)
assert _N==30
display "MCBHSUMARGIN_DEMO_PASSED"
