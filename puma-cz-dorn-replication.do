** replication of Dorn lookup file for PUMA 1990 to CZ 1990 **


** read data, reformat -----------------------------------------------------------

* Fowler-Jensen county-CZ lookup table
* description at https://sites.psu.edu/psucz/data/
* read it in as csv, write out as dta, so it can be used in merge later
* is there a way to use merge in Stata with file formats other than .dta?
import delimited "https://sites.psu.edu/psucz/files/2018/09/counties90-29c6g4u.csv"
summ fips ers90, detail
save counties90-29c6g4u
clear

* USCB tracts-PUMA lookup table
* download from https://usa.ipums.org/usa/resources/volii/1990_PUMAs_5pct.xls
import excel "../../../Data/Boundaries/United States/ipums_puma_1990_5pct/1990_PUMAs_5pct.xls", firstrow

* fix county FIPS code in PUMA lookup so same format as county-CZ lookup
gen fips = State * 1000 + CountyFIPScode

* check format of FIPS is as expected
summ fips, detail


** merge data --------------------------------------------------------------------

* merge CZ identifier ERS90 into the dataset - has to be a .dta file
merge m:1 fips using counties90-29c6g4u, keepusing(ers90)

* delete .dta version of file 
erase counties90-29c6g4u.dta


** calculate proportion of PUMA population in each CZ (variable 'afactor') -------

* total PUMA population in each CZ
collapse (sum) PUMApopnincz = Areapopulation, by(ers90 State PUMA PUMApopulation)

* proportion PUMA population in each CZ 
replace afactor = round(PUMApopnincz / PUMApopulation, 0.001)

* check the variable 
summ afactor, detail


** put into same format as Dorn's original table, save as .dta --------------------

* create PUMA code combining State and original PUMA code
gen puma1990 = State * 10000 + PUMA

* keep variables we want, rename ers90 as czone, rearrange variables
keep afactor puma1990 ers90 
rename ers90 czone
order afactor puma1990 czone 

* save file as dta
save puma-cz-dorn-replication
