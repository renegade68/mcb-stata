*! version 0.1.1 17nov2026
* Copyright 2026 Choonjoo Lee. Licensed under AFL-3.0; see LICENSE.
program define mcbhsumargin, rclass
    version 16.1
    if strtrim(lower(`"`0'"'))=="version" {
        _mcbhsumargin_load
        display as text "mcbhsumargin 0.1.1; mcbhsu engine 0.9.2"
        return local version "0.1.1"
        return local engine_version "0.9.2"
        exit
    }
    syntax [using/], EPSilon(string) [SAVing(string asis) GRAPH NAME(name)]
    * Copy the prior r() results before any command can replace them.
    tempname T C V B M O resultsframe grouplabel decisionlabel
    if `"`using'"'=="" {
        local previous "`r(cmd)'"
        if !inlist("`previous'","mcbhsu","mcbhsus","mcbhsumargin") {
            display as error "Run immediately after mcbhsu/mcbhsus, or specify using saved_results"
            exit 301
        }
        local method "`r(method)'"
        local best "`r(best)'"
        local target "`r(target)'"
        local source_cmd "`previous'"
        local source_version "`r(version)'"
        local engine_version "`r(engine_version)'"
        local input "`r(input)'"
        if "`previous'"=="mcbhsu" {
            local engine_version "`r(version)'"
            local input raw
        }
        if "`previous'"=="mcbhsumargin" {
            local source_cmd "`r(source_cmd)'"
            local source_version "`r(source_version)'"
        }
        if "`previous'"=="mcbhsumargin" matrix `T'=r(base_results)
        else matrix `T'=r(results)
        matrix `C'=r(control_candidates)
        matrix `V'=r(group_values)
        matrix `B'=r(near_boundary)
        matrix `M'=(r(N),r(K),r(df),r(level))
        local K=rowsof(`T')
        forvalues i=1/`K' {
            mata: st_local("mcb_group`i'",st_global("r(group`i')"))
            mata: st_local("mcb_key`i'",st_global("r(key`i')"))
        }
    }
    capture confirm number `epsilon'
    if _rc {
        display as error "epsilon() must be finite and nonnegative"
        exit 459
    }
    if `epsilon'<0 | `epsilon'>=. {
        display as error "epsilon() must be finite and nonnegative"
        exit 459
    }
    if "`name'"!="" & "`graph'"=="" {
        display as error "name() requires graph"
        exit 198
    }
    if "`name'"=="" local name mcbhsumargin
    if `"`saving'"'!="" {
        _mcbhsumargin_saving using `saving'
        local savefile `"`s(filename)'"'
        local replace "`s(replace)'"
        if "`replace'"=="" confirm new file `"`savefile'"'
    }
    _mcbhsumargin_load
    frame create `resultsframe'
    capture noisily {
        if `"`using'"'!="" {
            frame `resultsframe': use `"`using'"', clear
            foreach var in group_id group_value n mean se_mean estimate lower upper p_exclude candidate critical control_candidate near_boundary {
                frame `resultsframe': confirm numeric variable `var'
            }
            frame `resultsframe': confirm string variable group_string group_label
            frame `resultsframe': mata: _mcbhsumargin_p011_read("`T'","`C'","`V'","`B'","`M'")
        }
        if !inlist("`method'","edwardshsu","tukeygap") | "`target'"!="nonnegative_best_distance" {
            display as error "Margin decisions require method(edwardshsu) or method(tukeygap) distance intervals"
            error 498
        }
        if "`engine_version'"!="0.9.2" | !inlist("`best'","max","min") {
            display as error "Unsupported source version or direction; recompute older results with the current suite"
            error 459
        }
        if !inlist("`source_cmd'","mcbhsu","mcbhsus") | ///
            !inlist("`input'","raw","summary_sd","summary_mse") {
            display as error "Unsupported source command or input mode"
            error 459
        }
        if ("`source_cmd'"=="mcbhsu" & ("`source_version'"!="0.9.2" | "`input'"!="raw")) | ///
            ("`source_cmd'"=="mcbhsus" & ("`source_version'"!="0.1.1" | "`input'"=="raw")) {
            display as error "Inconsistent source version or input metadata"
            error 459
        }
        mata: _mcbhsumargin_p011_validate("`T'","`C'","`V'","`B'","`M'")
        mata: _mcbhsumargin_p011_make("`T'","`O'",`epsilon')
        local K=rowsof(`T')
        local level=`M'[1,4]
        if `"`using'"'!="" frame `resultsframe': clear
        frame `resultsframe': quietly set obs `K'
        foreach var in group_id group_value n mean se_mean estimate lower upper p_exclude candidate critical control_candidate near_boundary epsilon decision at_boundary {
            frame `resultsframe': quietly generate double `var'=.
        }
        frame `resultsframe': quietly generate strL group_string=""
        frame `resultsframe': quietly generate strL group_label=""
        frame `resultsframe': mata: _mcbhsu_p092_export("`T'","`V'","`C'","`B'","`grouplabel'")
        frame `resultsframe': mata: st_store(.,tokens("epsilon decision at_boundary"),st_matrix("`O'")[,10..12])
        frame `resultsframe': label define `decisionlabel' 0 "Uncertain" 1 "Within epsilon" 2 "Beyond epsilon"
        frame `resultsframe': label values decision `decisionlabel'
        frame `resultsframe': label variable decision "Classification of nonnegative distance against epsilon"
        frame `resultsframe': label variable at_boundary "1 = epsilon exactly equals a stored interval endpoint"
        frame `resultsframe': char _dta[mcbhsu_version] "0.9.2"
        frame `resultsframe': char _dta[mcbhsu_method] "`method'"
        frame `resultsframe': char _dta[mcbhsu_target] "nonnegative_best_distance"
        frame `resultsframe': char _dta[mcbhsu_best] "`best'"
        frame `resultsframe': char _dta[mcbhsu_level] "`level'"
        frame `resultsframe': char _dta[mcbhsu_N] "`=el(`M',1,1)'"
        frame `resultsframe': char _dta[mcbhsu_df] "`=el(`M',1,3)'"
        frame `resultsframe': char _dta[mcbhsu_input] "`input'"
        frame `resultsframe': char _dta[mcbhsumargin_version] "0.1.1"
        frame `resultsframe': char _dta[mcbhsumargin_source_cmd] "`source_cmd'"
        frame `resultsframe': char _dta[mcbhsumargin_source_version] "`source_version'"
        frame `resultsframe': char _dta[mcbhsumargin_rule] "within: U<=epsilon; beyond: L>epsilon; otherwise uncertain"
        if "`graph'"!="" {
            frame `resultsframe': twoway ///
                (rcap lower upper group_id, horizontal lcolor(gs8)) ///
                (scatter group_id estimate if decision==1, msymbol(O) mcolor(navy)) ///
                (scatter group_id estimate if decision==2, msymbol(X) mcolor(maroon)) ///
                (scatter group_id estimate if decision==0, msymbol(D) mcolor(dkorange)), ///
                ylabel(1(1)`K', valuelabel angle(horizontal) labsize(small)) ///
                yscale(reverse) ytitle("") xtitle("Distance from best mean (all groups)") ///
                xline(0, lpattern(dash) lcolor(gs10)) xline(`epsilon', lpattern(dash) lcolor(navy)) ///
                title("`level'% simultaneous confidence intervals") ///
                subtitle("`method'; best = `best'; epsilon = `epsilon'") ///
                legend(order(2 "Within epsilon" 3 "Beyond epsilon" 4 "Uncertain") rows(1)) name(`name', replace)
        }
        if `"`saving'"'!="" frame `resultsframe': save `"`savefile'"', `replace'
    }
    local rc=_rc
    capture frame drop `resultsframe'
    if `rc' {
        if `"`mcb_error'"'!="" display as error `"`mcb_error'"'
        exit `rc'
    }
    matrix colnames `O'=n mean SE_mean difference lower upper p_exclude candidate critical epsilon decision at_boundary
    local rn
    forvalues i=1/`K' {
        local rn `rn' g`i'
    }
    matrix rownames `O'=`rn'
    matrix colnames `T'=n mean SE_mean difference lower upper p_exclude candidate critical
    matrix colnames `C'=control_candidate
    matrix colnames `V'=group_value
    matrix colnames `B'=near_boundary
    foreach mat in T C V B {
        matrix rownames ``mat''=`rn'
    }
    display as text _newline "Practical distance margin: epsilon = " as result %12.6g `epsilon'
    display as text "Within: upper <= epsilon; beyond: lower > epsilon; otherwise uncertain."
    mata: _mcbhsumargin_p011_display("`O'")
    display as text "Original intervals and best-candidate flags are unchanged."
    mata: st_local("n_within",strofreal(sum(st_matrix("`O'")[,11]:==1)))
    mata: st_local("n_beyond",strofreal(sum(st_matrix("`O'")[,11]:==2)))
    return scalar within=`n_within'
    return scalar beyond=`n_beyond'
    return scalar uncertain=`K'-`n_within'-`n_beyond'
    return scalar epsilon=`epsilon'
    return scalar N=`M'[1,1]
    return scalar K=`K'
    return scalar df=`M'[1,3]
    return scalar level=`level'
    return matrix results=`O'
    return matrix base_results=`T'
    return matrix control_candidates=`C'
    return matrix group_values=`V'
    return matrix near_boundary=`B'
    return local cmd "mcbhsumargin"
    return local version "0.1.1"
    return local engine_version "0.9.2"
    return local source_cmd "`source_cmd'"
    return local source_version "`source_version'"
    return local method "`method'"
    return local best "`best'"
    return local target "nonnegative_best_distance"
    return local input "`input'"
    forvalues i=1/`K' {
        return local group`i' `"`macval(mcb_group`i')'"'
        return local key`i' `"`macval(mcb_key`i')'"'
    }
end

program define _mcbhsumargin_load
    version 16.1
    capture quietly mcbhsu version
    if _rc {
        display as error "Install the complete mcbhsu 0.9.2 package first"
        exit 499
    }
    if "`r(version)'"!="0.9.2" {
        display as error "This add-on requires mcbhsu engine 0.9.2"
        exit 499
    }
    capture mata: st_local("margin_loaded",_mcbhsumargin_p011_version())
    if "`margin_loaded'"!="0.1.1" {
        quietly findfile mcbhsumargin.mata
        quietly run `"`r(fn)'"'
    }
end

program define _mcbhsumargin_saving, sclass
    version 16.1
    syntax using/ [, REPLACE]
    if substr(lower(`"`using'"'),-4,4)!=".dta" local using `"`using'.dta"'
    sreturn local filename `"`using'"'
    sreturn local replace "`replace'"
end
