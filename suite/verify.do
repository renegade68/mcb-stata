* Self-contained independent-user check. Save your data before running this file.
version 16.1
clear all
set more off
set linesize 160
args outdir
if `"`outdir'"'=="" local outdir mcbhsu_replication
capture mkdir "`outdir'"
log using "`outdir'/quickcheck.txt", text replace
adopath ++ "."
which mcbhsu
mcbhsu version
local command_version "`r(version)'"
local edition IC
if c(SE) local edition SE
if c(MP) local edition MP
tempname report sources
file open `report' using "`outdir'/summary.csv", write replace
file write `report' "case,method,best,command_version,stata_version,edition,os,N,K,df,max_scaled_error,status" _n
file open `sources' using "`outdir'/files.csv", write replace
file write `sources' "file,bytes,crc" _n
foreach name in mcbhsu.ado mcbhsu.mata mcbhsu.sthlp {
    findfile `name'
    local path `"`r(fn)'"'
    checksum `"`path'"'
    file write `sources' "`name'," %16.0f (r(filelen)) "," %16.0f (r(checksum)) _n
}
file close `sources'
foreach scenario in separated tied {
    clear
    set obs 12
    generate byte group_code=cond(_n<=4,10,20)
    generate double y=cond(_n<=4,_n-1,_n-3)
    quietly replace group_code=10 in 11
    quietly replace group_code=. in 12
    quietly replace y=. in 11
    quietly replace y=1000 in 12
    if "`scenario'"=="tied" quietly replace y=y-3 if group_code==20
    label define groups 10 "Treatment" 20 "Treatment", replace
    label values group_code groups
    quietly regress y ib10.group_code
    scalar ref_N=e(N)
    scalar ref_df=e(df_r)
    scalar ref_mse=e(rmse)^2
    scalar ref_m1=_b[_cons]
    scalar ref_m2=_b[_cons]+_b[20.group_code]
    scalar ref_h=_se[20.group_code]
    matrix original_b=e(b)
    matrix ref_n=(4\6)
    quietly datasignature
    local signature "`r(datasignature)'"
    foreach best in max min {
        scalar sign=cond("`best'"=="max",1,-1)
        foreach method in constrained edwardshsu tukeygap {
            local saveopt
            if "`scenario'"=="separated" & "`best'"=="max" & "`method'"=="edwardshsu" ///
                local saveopt `"saving("`outdir'/example_results", replace)"'
            quietly mcbhsu y, over(group_code) method(`method') best(`best') `saveopt'
            matrix got=r(results)
            matrix keys=r(group_values)
            assert r(N)==10 & r(K)==2 & r(df)==8 & r(N_excluded)==2
            assert abs(r(mse)-ref_mse)<1e-10
            assert keys[1,1]==10 & keys[2,1]==20
            matrix expected=J(2,9,.)
            scalar q=invttail(ref_df,cond("`method'"=="constrained",.05,.025))
            forvalues i=1/2 {
                local j=3-`i'
                scalar mi=ref_m`i'
                scalar mj=ref_m`j'
                scalar difference=mi-mj
                if "`method'"=="constrained" {
                    scalar lower=min(0,difference-q*ref_h)
                    scalar upper=max(0,difference+q*ref_h)
                    scalar candidate=(sign*difference+q*ref_h>0)
                    scalar p=ttail(ref_df,-sign*difference/ref_h)
                }
                else {
                    scalar lower=max(0,-sign*difference-q*ref_h)
                    scalar upper=max(0,-sign*difference+q*ref_h)
                    scalar difference=max(0,-sign*difference)
                    scalar candidate=(lower==0)
                    scalar p=.
                }
                matrix expected[`i',1]=(ref_n[`i',1],mi,sqrt(ref_mse/ref_n[`i',1]),difference,lower,upper,p,candidate,q)
            }
            mata: assert(all((st_matrix("got")[,7]:>=.):==(st_matrix("expected")[,7]:>=.)))
            if "`method'"=="constrained" {
                mata: assert(max(abs(st_matrix("got")[,7]-st_matrix("expected")[,7]))<1e-10)
            }
            mata: st_numscalar("error",max(abs(st_matrix("got")[,(1..6,8..9)]-st_matrix("expected")[,(1..6,8..9)]):/(1:+abs(st_matrix("expected")[,(1..6,8..9)]))))
            assert error<1e-6
            mata: assert(st_matrix("original_b")==st_matrix("e(b)"))
            quietly datasignature
            assert "`signature'"=="`r(datasignature)'"
            file write `report' "`scenario',`method',`best',`command_version',`c(stata_version)',`edition',`c(os)',10,2,8," ///
                %24.17g (error) ",passed" _n
        }
    }
    * Repeating a string-key call must reproduce the numeric-key answer.
    generate str8 group_string=cond(group_code==10,"control",cond(group_code==20,"other",""))
    quietly mcbhsu y, over(group_string) method(tukeygap) best(min)
    matrix strings=r(results)
    mata: st_numscalar("error",max(abs(st_matrix("strings")[,(1..6,8..9)]-st_matrix("got")[,(1..6,8..9)])))
    assert error<1e-10
    file write `report' "`scenario'_string,tukeygap,min,`command_version',`c(stata_version)',`edition',`c(os)',10,2,8," ///
        %24.17g (error) ",passed" _n
}
file close `report'
preserve
use "`outdir'/example_results.dta", clear
assert _N==2 & group_value[1]==10 & group_value[2]==20
assert group_label=="Treatment"
restore
display "MCBHSU_INDEPENDENT_QUICKCHECK_PASSED"
log close
