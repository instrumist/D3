clear all
set maxvar 28000
set more off
cd D:\Dissertation

* Showing major countries

use H0_simplified, clear
drop if rep=="EUN"
joinby using "D:\Dissertation\hs_isic_codeonly.dta", unmatched(none)
keep if real(substr(isic,1,2))>14 & real(substr(isic,1,2))<38
ren tradev v
collapse (sum) v, by(rep year)
reshape wide v, i(rep) j(year)
gen r1992=200
forvalues i=1993/2014{
local m = `i'-1
gsort -v`i'
gen r`i'=min(_n, r`m')
}
* Structure analysis

use H0_simplified, clear
keep if rep=="KOR"|rep=="CHN"|rep=="JPN"|rep=="DEU"|rep=="USA"
ren tradev v

joinby prod using hs_isic_codeonly
gen category2=substr(isic,1,2)
collapse (sum) v, by(rep year category2)
joinby using isic_description_rev1, unmatched(none)
keep if category1=="D"

egen vt=total(v), by(year rep)
gen r=v*100/vt

*keep if mod(year,10)==2

forvalues t=1992(2)2012{
graph bar (asis) v if year==`t', over(reporteriso3, sort(category2) descending) by(desc2)
graph export v_`t'.png, replace
graph bar (asis) r if year==`t', over(reporteriso3, sort(category2) descending) by(desc2)
graph export r_`t'.png, replace
}
/*graph bar (asis) tradevalue, over(reporteriso3) by(year desc2, colfirst)
graph bar (asis) tradevalue, over(reporteriso3, sort(year desc) descending) by(desc2 year)
