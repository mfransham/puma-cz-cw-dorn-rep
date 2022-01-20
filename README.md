# Replication of David Dorn's PUMA-CZ crosswalk files 

This code replicates (some of) the PUMA to Commuting Zone crosswalk files developed by David Dorn and [published on his website](http://ddorn.net/data.htm#Local%20Labor%20Market%20Geography).  Dorn's approach, outlined in the [appendix to his PhD thesis](http://ddorn.net/data/Dorn_Thesis_Appendix.pdf) and subsequently used in [published papers](https://www.aeaweb.org/articles?id=10.1257/aer.103.6.2121), allows users of IPUMS to analyse data that is published for Public Use Microdata Areas (PUMAs) instead for [Commuting Zones](https://www.ers.usda.gov/data-products/commuting-zones-and-labor-market-areas/) (CZs).  

## The problem: analysing CZs using IPUMS data

There is no straightforward one-to-one relationship between PUMAs and CZs.  To maintain the confidentiality of microdata, PUMAs are designed to have a minimum of 100,000 residents.  CZs are highly variable in population size - in 1990 the smallest CZ had a population of 1300 residents, the largest 14.5 million.  In 1990 there were 1,726 PUMAs and 741 CZs, so whilst on average CZs are larger than PUMAs, this is not the case for all CZs and the boundaries of CZs and PUMAs are not contiguous.  PUMAs are built using Census tracts as their building block, whereas CZs are built using counties.  

## The Dorn approach

For many observations in IPUMS, the PUMA of residence will uniquely identify the CZ of residence.  However where the PUMA contains two or more CZs there is uncertainty about which CZ to allocate this observation to.  The Dorn approach is to allocate fractions of the observation (using a fractional weight) to each CZ which overlaps with the PUMA, with weights determined by the proportion of the PUMA population in each CZ.

This approach requires a set of smaller geographical units for which population counts are available that nests (exactly or approximately) within the two larger sets of geographical units.  To construct a lookup (or crosswalk) between 1990 PUMAs and 1990 CZs the appropriate geography is Census tracts.  Spatial analysis can identify which PUMA and CZ each Census tract falls within; this is unnecessary in this case as [the US Census Bureau has published files for 1990](https://usa.ipums.org/usa/volii/puma.shtml) onwards that provide a lookup from Census tracts to PUMAs and counties (the county allows us to identify the CZ).  It is this file that Dorn uses to calculate his crosswalk file for 1990.  

## The replication files

`puma-cz-dorn-replication.R`

- reads in the data: 
  - tract-PUMA lookup file with tract population totals
  - county-CZ lookup file
- reformats county codes in a consistent way, then links CZs to counties
- calculates the proportion of PUMA population in each CZ (variable 'afactor')
- checks the same results are obtained as David Dorn's published table

`puma-cz-dorn-replication.do`

- as above, but with Stata 17

This may later be supplemented with code that constructs lookups to 2010 commuting zones produced by [Fowler and Jensen](https://sites.psu.edu/psucz/data/).  
