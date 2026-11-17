* Extract the suite ZIP, make its folder the working directory, then run:
* do install_mcbhsu_suite.do
* An optional argument supplies a different extracted-suite folder.
version 16.1
args suite_source
if `"`suite_source'"'=="" local suite_source `"`c(pwd)'"'
tempname installer
program define `installer', rclass
    version 16.1
    args suite_source
    tempname inventory
    frame create `inventory'
    capture noisily {
        frame `inventory': import delimited using `"`suite_source'/bundle_files.csv"', varnames(1) asdouble clear
        frame `inventory': assert _N==36
        frame `inventory': isid file
        frame `inventory': assert regexm(file,"^[A-Za-z0-9_.-]+$") & strpos(file,"..")==0
        frame `inventory': assert bytes>0 & bytes<. & crc>=0 & crc<.
        frame `inventory': assert bytes_crlf>0 & bytes_crlf<. & crc_crlf>=0 & crc_crlf<.
        foreach required in mcbhsu.ado mcbhsu.mata mcbhsu.sthlp mcbhsus.ado mcbhsus.mata mcbhsus.sthlp mcbhsumargin.ado mcbhsumargin.mata mcbhsumargin.sthlp mcbhsu.pkg mcbhsus.pkg mcbhsumargin.pkg mcbhsu_suite.pkg {
            frame `inventory': quietly count if file=="`required'"
            assert r(N)==1
        }
        * Check every supplied file before the first installation.
        forvalues i=1/36 {
            frame `inventory': local filename=file[`i']
            frame `inventory': local wanted_bytes=bytes[`i']
            frame `inventory': local wanted_crc=crc[`i']
            quietly checksum `"`suite_source'/`filename'"'
            if r(filelen)!=`wanted_bytes' | r(checksum)!=`wanted_crc' {
                display as error "MCBHSU_SUITE_SOURCE_MISMATCH"
                display as error "The extracted `filename' differs from this suite. Extract a complete matching ZIP."
                error 459
            }
        }
        foreach package in mcbhsu mcbhsus mcbhsumargin mcbhsu_suite {
            net install `package', from(`"`suite_source'"') replace
        }
        * Keep the existing package registrations; do not give the runtimes
        * a second owner in a new aggregate package.
        foreach runtime in mcbhsu.ado mcbhsu.mata mcbhsu.sthlp mcbhsus.ado mcbhsus.mata mcbhsus.sthlp mcbhsumargin.ado mcbhsumargin.mata mcbhsumargin.sthlp mcbhsu_suite.sthlp {
            quietly findfile `runtime'
            local located `"`r(fn)'"'
            quietly checksum `"`located'"'
            local found_bytes=r(filelen)
            local found_crc=r(checksum)
            * net install on Windows converts text LF to CRLF. Accept only the
            * exact distributed bytes or their complete LF-to-CRLF conversion.
            * The source-folder check above remains byte-for-byte strict.
            frame `inventory': quietly count if file=="`runtime'" & ///
                ((bytes==`found_bytes' & crc==`found_crc') | ///
                 (bytes_crlf==`found_bytes' & crc_crlf==`found_crc'))
            if r(N)!=1 {
                display as error "MCBHSU_SUITE_SEARCH_PATH_MISMATCH"
                display as error `"Located: `located'"'
                display as error "The located file matches neither the source nor its Windows line-ending form. Check for stale or edited copies."
                error 459
            }
        }
        which mcbhsu
        which mcbhsus
        which mcbhsumargin
        quietly mcbhsu version
        assert "`r(version)'"=="0.9.2"
        quietly mcbhsus version
        assert "`r(version)'"=="0.1.1" & "`r(engine_version)'"=="0.9.2"
        quietly mcbhsumargin version
        assert "`r(version)'"=="0.1.1" & "`r(engine_version)'"=="0.9.2"
    }
    local rc=_rc
    capture frame drop `inventory'
    if `rc' exit `rc'
    display as text "Installed mcbhsu 0.9.2, mcbhsus 0.1.1, mcbhsumargin 0.1.1 and suite help."
    display as text "Use help mcbhsu_suite for a complete workflow."
    return scalar packages=4
    return local suite_version "0.1.5"
end
capture noisily `installer' `"`suite_source'"'
local rc=_rc
capture program drop `installer'
if `rc' exit `rc'
display "MCBHSU_SUITE_INSTALL_PASSED"
