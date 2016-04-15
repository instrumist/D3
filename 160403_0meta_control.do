ssc install xtabond2, replace

* 0. Make sure the mat2txt2 is installed in your STATA!
* 1. Check window version and choose appropriate compressor(7zip or native winzip)
* 2. Sample run시 최소 ARG까지 포함시킬것!

clear all

local cpath D:\Dissertation\Codes\
local mpath D:\Dissertation\Codes\
local rpath D:\Dissertation\Outputs\tdb_160404_H2\
local prj tbd_160315_H2_mf_mp

cd "`cpath'" // directory which includes cfz.do

*do 160403_part1_cfz `rpath' `prj' `mpath'

* Arg1: Raw data path, Arg2: Filename, Arg3: Masterfile path

cd "`cpath'"
do 160403_part2_generating_dtas `rpath' `prj'

cd "`cpath'"
do 160403_part3_xtreg_xtabond `rpath' `prj'
