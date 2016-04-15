* Find PO/AB and change all

clear all
set more off

cd C:\Dissertation\csv\PO // For PO estimation results
! dir *.csv /a-d /b >C:\Dissertation\csv\test\filelist.txt

file open myfile using C:\Dissertation\csv\test\filelist.txt, read
use C:\Dissertation\csv\master_PO, clear

file read myfile line
while r(eof)==0 {

	append using `line'.dta, force

	file read myfile line
}
save saved_master_PO, replace
