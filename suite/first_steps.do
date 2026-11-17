* Save your data first. This complete example replaces the data in memory.
version 16.1
clear
set more off
capture mkdir onboarding_example
set obs 30
generate byte group=ceil(_n/10)
generate double y=5*group+sin(_n)
label define treatments 1 "First" 2 "Second" 3 "Third", replace
label values group treatments

* Question 1: Which groups remain possible best groups? Larger is better.
mcbhsu y, over(group) graph name(first_candidates) ///
    saving(onboarding_example/candidates.dta, replace)

* Question 2: How far might each group be from the best population mean?
mcbhsu y, over(group) method(edwardshsu) graph name(first_distances) ///
    saving(onboarding_example/distances.dta, replace)

* Question 3: Is the distance no more than five outcome units?
* Run immediately after the distance command, before another r-class command.
mcbhsumargin, epsilon(5) graph name(first_margin) ///
    saving(onboarding_example/decisions.dta, replace)
assert r(within)==1 & r(beyond)==1 & r(uncertain)==1
graph export onboarding_example/decisions.png, name(first_margin) width(1800) replace

* Saved output can be inspected without losing the example's raw observations.
preserve
use onboarding_example/decisions.dta, clear
assert _N==3 & n==10 & epsilon==5
assert decision==cond(group_value==1,2,cond(group_value==2,0,1))
format mean lower upper %9.3f
list group_label mean lower upper candidate decision, noobs abbreviate(20)
export delimited group_value group_label n mean lower upper candidate epsilon decision ///
    using onboarding_example/decisions.csv, replace nolabel
restore
assert _N==30
display "MCBHSU_FIRST_STEPS_PASSED"
