clear all
set more off
cd D:\Dissertation

forvalues i=15/36{
local num=`i'

use H0_simplified, clear
drop if rep=="EUN"
joinby prod using hs_isic_mf_only
keep if category2=="`num'"
ren tradev v
save temp_dataset, replace

egen tv=total(v), by(year rep)
keep year rep tv
duplicates drop
by year, sort : egen float rnk = rank(tv), field
keep if rnk==1
keep year rep
save temp_top_ctry, replace

use H0_simplified, clear
joinby year rep using temp_top_ctry
ren tradev v_base
drop rep
save temp_top_value, replace

use temp_dataset, clear
joinby year prod using temp_top_value, unmatched(master)
drop _merge

replace v_base=0 if v_base==.

egen tv=total(v), by(rep year)
egen tv_b=total(v_base), by(rep year)

gen esi=min(v/tv, v_base/tv_b)
collapse (sum) v v_base esi, by(rep year)
drop if v/v_base<0.05
drop if v==.
drop if v/v_base!=1 & esi>.99
save esi_result_`i', replace

keep if mod(year,5)==4
la var v "Export volume"
la var esi "ESI w.r.t. the top exporter"
twoway (scatter v esi, sort mlabel(reporteriso3)), by(year)
graph export pic_`i'.png, replace
}
*twoway (scatter v esi, sort mlabel(reporteriso3)), by(year)
