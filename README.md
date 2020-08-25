# US_per_mil_pop_covid-19
R script for computing US state covid-19 rates per million population.

To use, you first need the population data. For example:

`popData <- "https://www2.census.gov/programs-surveys/popest/tables/2010-2019/state/totals/nst-est2019-01.xlsx"

download.file(popData, "nst-est2019-01.xlsx",mode="wb")`
