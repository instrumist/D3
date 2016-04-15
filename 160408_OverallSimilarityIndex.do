clear all
set maxvar 28000
set more off
cd D:\Dissertation

program match
	gen code=substr(id,1,strpos(id, "_")-1)
	gen pcode=substr(id,strpos(id, "_")+1,length(id)-length(code)-1)
	
	joinby code using country_matching
	ren reporter rep
	ren code rcode
	ren pcode code
	joinby code using country_matching
	ren code par
end

* Generate dataset
use H0_simplified, clear
keep if rep=="KOR"|rep=="CHN"|rep=="JPN"|rep=="DEU"|rep=="USA"|rep=="ITA"|rep=="FRA"|rep=="GBR"|rep=="CAN"|rep=="NLD"|rep=="HKG"
joinby prod using hs_isic_codeonly
*keep if substr(prod,1,2)=="87"
*replace isic=substr(isic,1,2)
replace isic="0"
ren tradev v
encode rep, gen(repn)

preserve
	keep reporter repn
	duplicates drop
	gen str2 code=string(repn+0)
	drop repn
	export excel using "Code_matching", sheet("country") sheetreplace
	save country_matching, replace
restore

* Convert to ratio
egen vt=total(v), by(year repn)
gen r=v*100/vt
drop v
ren r v
save temp, replace
*/

* Calculate pairwise similarity (for a nested country set)
use temp, clear
keep repn prod year isic v
su repn
scalar n=r(max)
scalar n_m1=r(max)-1
reshape wide v, i(year prod isic) j(repn)
save temp_w, replace

* ESI

use temp_w, clear
forvalues x = 1/`=n'{
	replace v`x'=0 if v`x'==.
}
forvalues x = 1/`=n'{
local z=`x'+1
	forvalues y = 1/`=n'{
		capture gen esi`x'_`y'=min(v`x',v`y')
		}
}
collapse (sum) esi* , by(year isic)
reshape long esi, i(year isic) j(id) string

match
save esi, replace

* FK

use temp_w, clear
forvalues x = 1/`=n'{
	replace v`x'=0 if v`x'==.
}
forvalues x = 1/`=n_m1'{
local z=`x'+1
	forvalues y = `z'/`=n'{
		gen FKsim`x'_`y'=abs(v`x'-v`y')
		}
}
collapse (sum) FKsim* , by(year isic)

forvalues x = 1/`=n_m1'{
local z=`x'+1
	forvalues y = `z'/`=n'{
		replace FKsim`x'_`y'=1-(.5*FKsim`x'_`y')
		}
}
reshape long FKsim, i(year isic) j(id) string
match
save FKsim, replace
