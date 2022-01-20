## replication of Dorn lookup file for PUMA 1990 to CZ 1990 ##

# packages
library(tidyverse)
library(haven)

####### read data ---------------------------------------------------------------------

# USCB tracts-PUMA lookup table
# download from https://usa.ipums.org/usa/resources/volii/1990_PUMAs_5pct.xls
puma_lkup <- readxl::read_excel("../../../Data/Boundaries/United States/ipums_puma_1990_5pct/1990_PUMAs_5pct.xls")

# Fowler-Jensen county-CZ lookup table
# description at https://sites.psu.edu/psucz/data/
cty_cz_lkup <- read_csv("https://sites.psu.edu/psucz/files/2018/09/counties90-29c6g4u.csv")


####### reformat county codes and link to county-CZ file ---------------------------------

# fix county FIPS code in PUMA lookup so same format as county-CZ lookup
puma_lkup <- puma_lkup %>% 
  mutate(FIPS = State * 1000 + `County FIPS code`)

# check format of FIPS is the same in both datasets
puma_lkup %>% pull(FIPS) %>% unique() %>% summary()
cty_cz_lkup %>% pull(FIPS) %>% unique() %>% summary()

# link CZs to counties in PUMA lookup
# CZ code is in field ERS90
puma_lkup <- puma_lkup %>% 
  left_join(cty_cz_lkup %>% select(FIPS, ERS90), 
            by = "FIPS") %>% 
  rename(czone = ERS90)


####### calculate proportion of PUMA population in each CZ (variable 'afactor') ------------

# produce table of fractional weights (stored in afactor)
puma1990_cz1990 <- puma_lkup %>% 
  group_by(czone, State, PUMA, `PUMA population`) %>% 
  summarise(PUMApopnincz = sum(`Area population`) ) %>% 
  ungroup() %>% 
  mutate(afactor = round(PUMApopnincz/`PUMA population`, 3), 
         puma1990 = State * 10000 + PUMA) %>% 
  select(afactor, puma1990, czone)


####### check against Dorn's original table ------------------------------------------------

# download from http://ddorn.net/data.htm#Local%20Labor%20Market%20Geography
dorn_puma1990_cz1990 <- 
  read_dta("../../../Data/Boundaries/United States Dorn lookups/cw_puma1990_czone/cw_puma1990_czone.dta")

# values identical within +/- 0.002
left_join(puma1990_cz1990, dorn_puma1990_cz1990, by = c("puma1990", "czone") ) %>% 
  mutate(diff = afactor.x - afactor.y) %>% 
  pull(diff) %>% 
  summary()

## R environment ----------------------------------------------------

writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
