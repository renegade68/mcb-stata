* Save your data first. Run from the source distribution's root.
version 16.1
clear
set more off
adopath ++ "."
adopath ++ "summary"
input str8 treatment double(count avg sd)
"First" 5 11 1
"Second" 5 12 1.5
"Third" 5 13 2
end
mcbhsus avg, over(treatment) n(count) sd(sd)
scalar pooled=r(mse)
scalar residual_df=r(df)
matrix from_sd=r(results)
mcbhsus avg, over(treatment) n(count) mse(`=scalar(pooled)') df(`=scalar(residual_df)')
matrix from_mse=r(results)
mata: assert(max(abs(st_matrix("from_sd")-st_matrix("from_mse")))<1e-10)
mcbhsus avg, over(treatment) n(count) sd(sd) method(edwardshsu) best(min) graph name(summary_costs)
assert _N==3 & r(N)==15 & r(df)==12
display "MCBHSUS_DEMO_PASSED"
