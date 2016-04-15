clear all

set more off
cd C:\Dissertation\csv\PO // For xtreg estimation results
! dir *.csv /a-d /b >C:\Dissertation\csv\PO\filelist.txt

file open myfile using C:\Dissertation\csv\PO\filelist.txt, read

file read myfile line
while r(eof)==0 {
	insheet using `line', names
	
	keep v1 c1 v3
	ren v3 c2
	capture replace v1="ExpL1" if v1=="L.rEXP"
	capture replace v1="ImpL3" if substr(v1,1,4)=="L3.r"
	capture replace v1="ImpL2" if substr(v1,1,4)=="L2.r"
	capture replace v1="ImpL1" if substr(v1,1,3)=="L.r"
	
	capture replace v1="oExpL1" if v1=="oL.rEXP"
	capture replace v1="oImpL3" if substr(v1,1,5)=="oL3.r"
	capture replace v1="oImpL2" if substr(v1,1,5)=="oL2.r"
	capture replace v1="oImpL1" if substr(v1,1,4)=="oL.r"
	
	capture replace v1="Const" if v1=="_cons"
	reshape long c, i(v1) j(k)
	gen i="C"
	replace i="Z" if k==2
	replace v1=v1+i
	drop k i
	ren v _varname
	drop if substr(_v,1,2)=="o."|_v=="r1Z"
	xpose, clear
	ren r1C df_m
	
	local tname="`line'"
	gen text="`tname'"
	gen rep=substr(text,4,3)
	gen par=substr(text,8,3)
	
	save `tname'.dta, replace
	drop _all
	file read myfile line
}
