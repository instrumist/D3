/*--------------------------------------------------------------
 Code by Bawoo Kim
 For TDB(Trade Database) construction
 Last update : 2015.06.02
 Description :
   1. WITS bulkdownload zip file의 압축을 1회 풀고,
   2. zip상태로 들어있는 세부 파일들이 있는 경로를 path로 지정
   3. master.dta 파일이 있는 경로를 mpath로 지정
   4. 최종 output filename을 fn으로 지정(1행)
   주의! path에는 최종 output file과 log(txt)file만이 남게 됨.
---------------------------------------------------------------*/

clear all

local fn="`2'" // Filename
local path="`1'" // Path which includes the zip files
local mpath="`3'" // Path including master.dta

set more off
cd "`path'"

! 7z e *.zip -aoa // 7 zip version
*! unzip -qq -o *.zip // native windows version
! dir *.csv /a-d /b > "`fn'"_zip_list.txt

file open `fn'_csv_list using `fn'_zip_list.txt, read

file read `fn'_csv_list line
while r(eof)==0 {
	insheet using `line', names
	tostring productcode, replace force
	save `line'.dta, replace
	drop _all
	file read `fn'_csv_list line
}
! dir *.dta /a-d /b > "`fn'"_dta_list.txt

file open `fn'_dta_list using `fn'_dta_list.txt, read

file read `fn'_dta_list line
use `mpath'master, clear

while r(eof)==0 {
	append using `line', force
	file read `fn'_dta_list line
}
! del *.csv *.zip *.dta

saveold "`fn'", replace version(13)
