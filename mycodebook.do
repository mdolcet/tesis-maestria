

*****************************************************************
*Programa para guardar el num de observaciones unicas en un panel 
*****************************************************************

* (1) You can stick this into a file called mycodebook.ado in
* /ado/personal (use adopath to see exact location)

capture program drop mycodebook
program mycodebook, rclass

syntax [varlist] [if] [in][, *]

codebook `varlist' `if' `in', `options'

capture ssc install distinct

foreach var of varlist `varlist' {
    qui distinct `var' `if' `in'
    return scalar n_`var' = r(ndist)
}


end