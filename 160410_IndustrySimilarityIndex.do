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

* Generate dataset (Manufacturing only, D on ISIC rev.3)
use H0_simplified, clear
keep if rep=="KOR"|rep=="CHN"|rep=="JPN"|rep=="DEU"|rep=="USA"|rep=="ITA"|rep=="FRA"|rep=="GBR"|rep=="NLD"
joinby prod using hs_isic_codeonly
keep if real(substr(isic,1,2))>14 & real(substr(isic,1,2))<38
replace isic=substr(isic,1,2)
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
egen vt=total(v), by(year repn isic)
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
forvalues x = 1/`=n'{
	replace v`x'=0 if v`x'==.
}
save temp_w, replace

* ESI(simultaneous time)

use temp_w, clear
forvalues x = 1/`=n'{
local z=`x'+1
	forvalues y = 1/`=n'{
		capture gen esi`x'_`y'=min(v`x',v`y')
		}
}
collapse (sum) esi* , by(year isic)
reshape long esi, i(year isic) j(id) string

match
save esi_simultaneous, replace

separate esi, by(repo)
twoway (line esi1 esi2 esi6 esi9 year , sort) if rep=="KOR", by(isic)




drop if esi==0 | esi>99
foreach x in CHN KOR JPN{
twoway (line esi year, sort) if rep=="`x'", by(reporteriso3)
graph export esi_simultaneous_`x'.png, replace
}
* ESI(One is time-fixed, the other is time varying)

use temp_w, clear
keep year prod v*
save temp, replace

	use temp_w, clear
	drop isic
	reshape wide v*, i(prod) j(year)

	joinby prod using temp, unmatched(both)

forvalues x = 1/`=n'{
	forvalues i = 1/`=n'{
		forvalues t = 1992/2014{
			capture gen esi`x'_`i'_`t'=min(v`x',v`i'`t')
		}
	}
}
collapse (sum) esi* , by(year)
reshape long esi, i(year) j(id) string
drop if esi==0 | esi>99
reshape wide esi, i(year) j(id) string

forvalues x = 1/`=n'{
	forvalues i = 1/`=n'{
		capture gen BestYr`x'_`i'=0
		capture gen BestEsi`x'_`i'=0
			forvalues t = 1992/2014{
				capture replace BestYr`x'_`i'=`t' if esi`x'_`i'_`t'>BestEsi`x'_`i'
				capture replace BestEsi`x'_`i'=esi`x'_`i'_`t' if esi`x'_`i'_`t'>BestEsi`x'_`i'
		}
	}
	drop BestEsi`x'_`x' BestYr`x'_`x'
}
keep year Best*
