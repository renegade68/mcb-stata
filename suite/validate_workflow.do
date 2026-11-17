* Internal worker for validate_installation.do; run the wrapper.
version 16.1
clear all
set more off
args bundle plus personal work mode outdir
log using `"`outdir'/check.txt"', text replace
sysdir set PLUS `"`plus'"'
sysdir set PERSONAL `"`personal'"'
cd `"`work'"'
if "`mode'"=="upgrade" {
    foreach package in mcbhsu mcbhsus mcbhsumargin {
        net install `package', from(`"`bundle'"') replace
    }
}
if "`mode'"=="source_tree" do `"`bundle'/suite/install_from_source.do"' `"`bundle'"'
else do `"`bundle'/install_mcbhsu_suite.do"' `"`bundle'"'
if "`mode'"=="source_tree" local bundle `"`bundle'/dist/mcbhsu-suite-0.1.0"'
foreach runtime in mcbhsu.ado mcbhsu.mata mcbhsu.sthlp mcbhsus.ado mcbhsus.mata mcbhsus.sthlp mcbhsumargin.ado mcbhsumargin.mata mcbhsumargin.sthlp mcbhsu_suite.sthlp {
    findfile `runtime'
    assert strpos(`"`r(fn)'"',`"`plus'"')>0
}
if "`mode'"=="reinstall" do `"`bundle'/install_mcbhsu_suite.do"' `"`bundle'"'

* Extract the actual installed combined help, not a copied example list.
findfile mcbhsu_suite.sthlp
local helpfile `"`r(fn)'"'
translate `"`helpfile'"' `"`outdir'/help_rendered.txt"', translator(smcl2txt) replace
tempfile commands
mata:
void _suite_extract_examples()
{
    real scalar f,out,active,count
    string matrix line
    f=fopen(st_local("helpfile"),"r");out=fopen(st_local("commands"),"w")
    active=count=0
    while (1) {
        line=fget(f)
        if (!rows(line)) break
        if (line=="{title:Examples}") { active=1;continue; }
        if (!active) continue
        if (substr(line,1,7)=="{title:") break
        if (substr(line,1,13)!="{phang2}{cmd:") continue
        if (substr(line,-7,7)=="{p_end}") line=substr(line,1,strlen(line)-7)
        assert(substr(line,-1,1)=="}")
        fput(out,substr(line,14,strlen(line)-14));count++
    }
    fclose(f);fclose(out)
    assert(count==14)
    st_local("help_commands",strofreal(count))
}
_suite_extract_examples()
end
do `"`commands'"'
assert _N==3 & r(N)==30 & r(K)==3 & r(df)==27
assert r(within)==1 & r(beyond)==2 & r(uncertain)==0
mata: assert(max(abs(st_matrix("raw")-st_matrix("summary")))<1e-10)
copy suite_practical.png `"`outdir'/example.png"', replace
preserve
use suite_decisions, clear
assert _N==3 & epsilon==5
assert decision==cond(group_value==1,2,cond(group_value==2,0,1))
export delimited using `"`outdir'/help_results.csv"', replace
restore

* Ancillary examples belong to their original packages; the guide owns only
* its own demonstration, installer, guide and readme/license files.
net set other `"`work'"'
net get mcbhsu_suite, from(`"`bundle'"') replace
do demo_mcbhsu_suite.do
assert _N==3 & r(N)==30 & r(df)==27
assert r(within)==1 & r(beyond)==2
clear
set obs 1
generate str12 install_mode="`mode'"
generate byte help_commands=`help_commands'
generate str8 stata_version="`c(stata_version)'"
generate str8 edition=cond(c(MP),"MP",cond(c(SE),"SE","IC"))
generate str24 os="`c(os)'"
generate str8 core_version="0.9.2"
generate str8 summary_version="0.1.1"
generate str8 margin_version="0.1.1"
export delimited using `"`outdir'/install.csv"', replace
display "MCBHSU_SUITE_WORKFLOW_PASSED"
log close
* Run the distributed examples from the analysis directory, using PLUS code.
do `"`bundle'/first_steps.do"'
do `"`bundle'/verify.do"'
preserve
import delimited using "mcbhsu_replication/summary.csv", clear varnames(1) asdouble
assert _N==14
assert status=="passed"
restore
copy "mcbhsu_replication/summary.csv" `"`outdir'/quickcheck_summary.csv"'
copy "mcbhsu_replication/files.csv" `"`outdir'/runtime_checksums.csv"'
copy "mcbhsu_replication/quickcheck.txt" `"`outdir'/quickcheck.txt"'
copy "onboarding_example/decisions.csv" `"`outdir'/first_steps_decisions.csv"'
copy "onboarding_example/decisions.png" `"`outdir'/first_steps_decisions.png"'
file open receipt using `"`outdir'/status.txt"', write
file write receipt "MCBHSU_INSTALLATION_CHECK_PASSED" _n
file write receipt "Suite 0.1.6; installation and reinstallation; installed help; examples; 14 quickchecks." _n
file close receipt
