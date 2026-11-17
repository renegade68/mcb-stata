* Run from the complete extracted suite in a fresh Stata session.
* Save your data first. This check creates synthetic data and new output files.
* Optional argument: a NEW directory under the current working directory.
version 16.1
args destination
if `"`destination'"'=="" local destination "mcbhsu_installation_check"
local bundle `"`c(pwd)'"'
local oldplus `"`c(sysdir_plus)'"'
local oldpersonal `"`c(sysdir_personal)'"'
local oldmore "`c(more)'"
local oldlinesize=c(linesize)
local oldadopath `"`c(adopath)'"'
confirm file "validate_workflow.do"
* mkdir must succeed: an existing folder is never reused or overwritten.
mkdir `"`destination'"'
cd `"`destination'"'
local root `"`c(pwd)'"'
cd `"`bundle'"'
foreach part in plus personal analysis results {
    mkdir `"`root'/`part'"'
}
capture noisily do `"`bundle'/validate_workflow.do"' `"`bundle'"' ///
    `"`root'/plus"' `"`root'/personal"' `"`root'/analysis"' ///
    "reinstall" `"`root'/results"'
local rc=_rc
capture log close
sysdir set PLUS `"`oldplus'"'
sysdir set PERSONAL `"`oldpersonal'"'
cd `"`bundle'"'
set more `oldmore'
set linesize `oldlinesize'
mata: st_global("S_ADO", st_local("oldadopath"))
* Clear code loaded from the isolated installation, without deleting test files.
capture program drop mcbhsu _mcbhsu_load _mcbhsu_saving
capture program drop mcbhsus _mcbhsus_load _mcbhsus_saving
capture program drop mcbhsumargin _mcbhsumargin_load _mcbhsumargin_saving
if `rc' {
    display as error "MCBHSU_INSTALLATION_CHECK_FAILED: r(`rc')"
    display as text `"Keep the results folder for diagnosis: `root'/results"'
    exit `rc'
}
display "MCBHSU_INSTALLATION_CHECK_PASSED"
display as text `"Results: `root'/results"'
display as text "Read docs/external-validation.md for the files to share."
