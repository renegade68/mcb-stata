*! version 0.9.2 17nov2026
* Copyright 2026 Choonjoo Lee. Licensed under AFL-3.0; see LICENSE.
program define mcbhsu, rclass
    version 16.1
    if inlist(strtrim(lower(`"`0'"')), "clearcache", "version") {
        local action = strtrim(lower(`"`0'"'))
        _mcbhsu_load
        if "`action'" == "clearcache" {
            mata: _mcbhsu_p092_clearcache()
            display as text "mcbhsu critical-value cache cleared"
        }
        else display as text "mcbhsu 0.9.2 (release candidate), 17 November 2026"
        return local version "0.9.2"
        exit
    }
    syntax varname(numeric) [if] [in], OVER(varname) ///
        [BEST(string) Level(cilevel) METHOD(string) MISSING NOCACHE ///
        SAVing(string asis) GRAPH NAME(name)]
    if "`best'" == "" local best max
    local best = lower("`best'")
    if !inlist("`best'", "max", "min") {
        display as error "best() must be max or min"
        exit 198
    }
    if "`method'" == "" local method constrained
    local method = lower("`method'")
    if !inlist("`method'", "constrained", "edwardshsu", "tukeygap") {
        display as error "method() must be constrained, edwardshsu, or tukeygap"
        exit 198
    }
    if `level' < 80 | `level' > 99.9 {
        display as error "Supported confidence levels are 80 through 99.9"
        exit 198
    }
    if "`name'" != "" & "`graph'" == "" {
        display as error "name() requires graph"
        exit 198
    }
    if "`name'" == "" local name mcbhsu
    if `"`saving'"' != "" {
        _mcbhsu_saving using `saving'
        local savefile `"`s(filename)'"'
        local replace "`s(replace)'"
        if "`replace'" == "" confirm new file `"`savefile'"'
    }
    marksample touse, novarlist
    quietly count if `touse'
    local N_selected = r(N)
    markout `touse' `varlist'
    if "`missing'" == "" markout `touse' `over', strok
    quietly count if `touse'
    if r(N) == 0 error 2000
    local N_excluded = `N_selected' - r(N)
    _mcbhsu_load
    tempname T S C V B resultsframe grouplabel
    local usecache = ("`nocache'" == "")
    capture noisily mata: _mcbhsu_p092_analyze("`varlist'", "`over'", ///
        "`touse'", "`best'", "`method'", `level', `usecache', ///
        "`T'", "`S'", "`C'", "`V'", "`B'")
    if _rc {
        local rc = _rc
        if `"`mcb_error'"' != "" display as error `"`mcb_error'"'
        exit `rc'
    }
    matrix colnames `T' = n mean SE_mean difference lower upper p_exclude candidate critical
    local K = el(`S',1,2)
    local rn
    forvalues i=1/`K' {
        local rn `rn' g`i'
    }
    foreach M in T C V B {
        matrix rownames ``M'' = `rn'
    }
    matrix colnames `C' = control_candidate
    matrix colnames `V' = group_value
    matrix colnames `B' = near_boundary
    local target best_other_difference
    local xtitle "Group mean minus best other mean"
    if "`method'" != "constrained" {
        local target nonnegative_best_distance
        local xtitle "Distance from best mean (all groups)"
    }
    if `"`saving'"' != "" | "`graph'" != "" {
        frame create `resultsframe'
        capture noisily {
            frame `resultsframe': quietly set obs `K'
            foreach v in group_id group_value n mean se_mean estimate lower upper p_exclude candidate critical control_candidate near_boundary {
                frame `resultsframe': quietly generate double `v' = .
            }
            frame `resultsframe': quietly generate strL group_string = ""
            frame `resultsframe': quietly generate strL group_label = ""
            frame `resultsframe': mata: _mcbhsu_p092_export("`T'", "`V'", "`C'", "`B'", "`grouplabel'")
            frame `resultsframe': order group_id group_value group_string group_label
            frame `resultsframe': label variable estimate "Estimate of the stated target"
            frame `resultsframe': label variable se_mean "Standard error of this group mean"
            frame `resultsframe': label variable candidate "1 = retained as possibly best"
            frame `resultsframe': label variable control_candidate "EH construction set; constrained screening set; missing for Tukey"
            frame `resultsframe': label variable near_boundary "1 = classification close to numerical tolerance; inspect"
            frame `resultsframe': char _dta[mcbhsu_version] "0.9.2"
            frame `resultsframe': char _dta[mcbhsu_method] "`method'"
            frame `resultsframe': char _dta[mcbhsu_best] "`best'"
            frame `resultsframe': char _dta[mcbhsu_target] "`target'"
            frame `resultsframe': char _dta[mcbhsu_level] "`level'"
            frame `resultsframe': char _dta[mcbhsu_outcome] "`varlist'"
            frame `resultsframe': char _dta[mcbhsu_over] "`over'"
            frame `resultsframe': char _dta[mcbhsu_df] "`=el(`S',1,3)'"
            frame `resultsframe': char _dta[mcbhsu_N] "`=el(`S',1,1)'"
            if "`graph'" != "" {
                frame `resultsframe': twoway ///
                    (rcap lower upper group_id, horizontal lcolor(gs8)) ///
                    (scatter group_id estimate if candidate==1, msymbol(O) mcolor(navy)) ///
                    (scatter group_id estimate if candidate==0, msymbol(X) mcolor(maroon)), ///
                    ylabel(1(1)`K', valuelabel angle(horizontal) labsize(small)) ///
                    yscale(reverse) ytitle("") xtitle("`xtitle'") xline(0, lpattern(dash) lcolor(gs10)) ///
                    title("`level'% simultaneous confidence intervals") ///
                    subtitle("`method'; best = `best'") ///
                    legend(order(2 "Retained" 3 "Excluded") rows(1)) name(`name', replace)
            }
            if `"`saving'"' != "" frame `resultsframe': save `"`savefile'"', `replace'
        }
        local rc = _rc
        capture frame drop `resultsframe'
        if `rc' exit `rc'
    }
    display as text _newline "Hsu MCB: independent one-way normal model, common variance"
    display as text "`level'% simultaneous confidence intervals; `method'; best = `best'"
    display as text "N = " as result el(`S',1,1) as text "   Groups = " as result `K' ///
        as text "   Residual df = " as result el(`S',1,3)
    mata: _mcbhsu_p092_display("`T'")
    if "`method'" == "constrained" {
        display as text "Estimate: group mean minus the best OTHER group mean."
        display as text "Intervals contain zero by construction; screening is a separate one-sided test."
    }
    else {
        display as text "Estimate: nonnegative distance from the best of ALL group means."
        display as text "Retained means the lower distance bound is zero; p-values are not reported."
        if "`method'" == "tukeygap" display as text "Tukey-Kramer projection is a benchmark, not Hsu MCB."
    }
    display as text "Retained does not establish equivalence. See help mcbhsu for assumptions."
    if `N_excluded' display as text "Excluded for missing outcome/group: " as result `N_excluded'
    mata: st_local("nboundary", strofreal(sum(st_matrix("`B'"))))
    if `nboundary' display as text "Classification near a numerical boundary: inspect r(near_boundary)."
    if el(`S',1,4)>=. display as text "MSE exceeds physical variance storage range; see r(log_mse)."
    return matrix table = `T', copy
    return matrix results = `T'
    return matrix control_candidates = `C'
    return matrix group_values = `V'
    return matrix near_boundary = `B'
    return scalar N = el(`S',1,1)
    return scalar N_excluded = `N_excluded'
    return scalar K = el(`S',1,2)
    return scalar df = el(`S',1,3)
    return scalar mse = el(`S',1,4)
    return scalar candidates = el(`S',1,5)
    return scalar log_mse = el(`S',1,6)
    return scalar cache_hits = el(`S',1,9)
    return scalar cache_misses = el(`S',1,10)
    return scalar level = `level'
    return local target "`target'"
    return local method "`method'"
    return local best "`best'"
    return local depvar "`varlist'"
    return local over "`over'"
    return local version "0.9.2"
    return local cmd "mcbhsu"
    forvalues i=1/`K' {
        return local group`i' `"`macval(mcb_group`i')'"'
        return local key`i' `"`macval(mcb_key`i')'"'
    }
end

program define _mcbhsu_load
    version 16.1
    capture mata: st_local("mcb_loaded", _mcbhsu_p092_version())
    if "`mcb_loaded'" != "0.9.2" {
        capture findfile mcbhsu.mata
        if _rc {
            display as error "mcbhsu.mata not found; reinstall the complete mcbhsu package"
            exit 601
        }
        quietly run `"`r(fn)'"'
    }
end

program define _mcbhsu_saving, sclass
    version 16.1
    syntax using/ [, REPLACE]
    local extension = substr(lower(`"`using'"'), -4, 4)
    if "`extension'" != ".dta" local using `"`using'.dta"'
    sreturn local filename `"`using'"'
    sreturn local replace "`replace'"
end
