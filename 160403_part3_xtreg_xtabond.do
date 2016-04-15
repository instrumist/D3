clear all
set more off
mata: mata set matafavor speed, perm

local path="`1'"
local fn="`2'" // Filename
cd "`path'"

*predefined processes
program ascii, rclass
    syntax anything
    mata: printf("Ascii code for `anything':");ascii("`anything'")
    tempname char
    mata: st_numscalar("char",ascii("`anything'"))
    return scalar char=char 
end

use "`fn'_modified", clear

drop if par=="WLD"
keep rep year
ren rep rep1
duplicates drop
by rep1, sort : egen float NumYear = count(year)
drop if NumYear<8
keep rep1
duplicates drop

/*Inserted clause for dropping reporter countries before "X(arbitrary character)"
local NumOfRep=_N
gen rep1_head=substr(rep1,1,1)
gen dum=.

forvalues i=1/`NumOfRep'{
  local temp=rep1_head[`i']
  ascii `temp'
  local result=`r(char)'
  replace dum=`result' in `i' 
  }
drop if dum<72
*/

putmata *
local NumOfRep=_N

* Slicing modified dataset by reporting countries

use "`fn'_po_ARG", clear // set arbitrary dataset to paste MATA vector

forvalues i=1/`NumOfRep'{

getmata(rep1)=rep1, force
local rname=rep1[`i']

use "`fn'_po_`rname'", clear
	drop if flow==2
	by par, sort : egen float NumObs = count(v)
	drop if NumObs<8
	keep par year
	duplicates drop
	by par, sort : egen float NumObs = count(year)
	drop if NumObs<8
	keep par
	duplicates drop
	local NumOfPar=_N
	putmata par1=par, replace // Note that "WLD" is included as a partner

use "`fn'_pp_`rname'", clear
	getmata(par1)=par1, force
	qui encode prod, gen(hs)
	xtset hs year
	qui tab year, gen(year_dum)
	forvalues j=1/`NumOfPar'{
		local row=`row'+1
		local pname=par1[`j']
		
		* Pooled OLS
		capture qui xtreg rEXP L.rEXP L(1/3).r`pname' year_dum*, fe
		
		mat m=e(df_m)
		mat m = m,m
		qui mat2txt2 m\(e(b)',vecdiag(e(V))') using PO_`rname'_`pname'.csv, replace
		
		* AB
		capture qui xtabond2 rEXP L.rEXP L(1/3).r`pname' year_dum*, gmm(rEXP r`pname', lag(1 3))
		
		mat m=(e(ar1p),e(ar2p))\(e(sarganp),e(chi2p))
		qui mat2txt2 m\(e(b)',vecdiag(e(V))') using AB_`rname'_`pname'.csv, replace

		di 100*(((`i'-1)/`NumOfRep')+(`j'-1)/(`NumOfRep'*`NumOfPar')) " percent competed"
		}
		}
