clear all
set more off

local path="`1'" // Path
local fn="`2'" // Filename

cd "`path'"

* Clearing dataset
use "`fn'", clear

capture drop hs q*
drop if tradef==2 & part!="WLD"
drop if tradef==3 | tradef==4 | prod=="999999" | prod==""
drop if year<=2001 // For dynamics
gen str6 prod=string(real(prod),"%06.0f")

keep if real(substr(prod,1,2))>=25 // For industry specification

drop produ
ren prod productcode
ren tradev v
ren tradef flow
collapse (sum) v, by(rep par year flow prod)

save "`fn'_modified", replace

/* Deleting 
keep rep par
duplicates drop
egen ct=count(par), by(rep)
keep if ct==1
*/

* Loading reporter country list to MATA
use "`fn'_modified", clear
keep rep
ren rep rep1
duplicates drop
putmata *
local NumOfRep=_N

* Slicing modified dataset by reporting countries

forvalues i=1/`NumOfRep'{
use "`fn'_modified", clear
	replace par="EXP" if flow==2
	
	getmata(rep1)=rep1, force
	local rname=rep1[`i']
	keep if reporter==rep1[`i']
	
	di "`rname'"
	drop rep1
	save "`fn'_po_`rname'", replace
	
	keep par
	duplicates drop
	local NumOfPar=_N
	putmata par1=par, replace
	
	use "`fn'_po_`rname'", clear
	egen vt=total(v), by(par year flow)
	gen r=v/vt
	
	keep par year r prod
	reshape wide r, i(prod year) j(par) string
	getmata(par1)=par1, force
	
	forvalues j=1/`NumOfPar'{
	local pname=par1[`j']
	replace r`pname'=0 if r`pname'==.
	}
	drop par1
	save "`fn'_pp_`rname'", replace
}
