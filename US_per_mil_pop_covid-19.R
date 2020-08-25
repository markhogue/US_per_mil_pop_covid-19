# libraries
library(RCurl)
library(dplyr)
library(ggplot2)
library(tibble)
library(readxl)
library(tidyr)


# obtain aggregated data from NY Times
covid_by_state <- read.csv(text = getURL("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"))

# obtain population data - *** NOTE *** This will look for a file on your computer - change name and location as needed. 
# See the Readme on how to get this data. Thanks to the US Census Bureau for this data.
colNames <- c("state", "census2010", "est_base", paste0("est_",2010:2019))
usPopEst <- read_excel("c:/R_files/nst-est2019-01.xlsx",
                       range="A10:M60",
                       col_names = colNames)[c(1,13)]
usPopEst$state <- gsub("\\.","",usPopEst$state)

covid_by_state <- left_join(covid_by_state, usPopEst)
rm(usPopEst)
rm(colNames)

covid_by_state <- covid_by_state %>% 
  mutate(case_per_mil = cases / est_2019) %>% 
  mutate(death_per_mil = deaths / est_2019) 

(latest_date <- max(unique(covid_by_state$date)))

# new cases = differential from previous ~~~~~~~~~~~~~~~~~~
# occasionally, this will go negative due to corrections - 
# see https://github.com/nytimes/covid-19-data#geographic-exceptions

covid_by_state <- covid_by_state %>% 
  group_by(state) %>% 
  arrange(date) %>% 
  mutate(new_cases = cases - lag(cases)) %>% 
  mutate(new_deaths = deaths - lag(deaths)) %>% 
  mutate(new_cases_mil = new_cases / (est_2019 / 1e6)) %>% 
  mutate(new_deaths_mil = new_deaths / (est_2019 / 1e6))


# most recent day  --------------------------------------------------------

# latest cases per mil pop
covid_by_state %>% filter(date == latest_date) %>% 
  arrange(-new_cases_mil) %>% 
  select(c(state, new_cases_mil))

# latest deaths per mil pop
covid_by_state %>% filter(date == latest_date) %>% 
  arrange(-new_deaths_mil) %>% 
  select(c(state, new_deaths_mil))


# sum past seven days -----------------------------------------------------
# last seven days cases per mil pop
covid_by_state %>% filter(date > (as.Date(latest_date) - 6)) %>% 
  summarise(case_sum = sum(new_cases_mil)) %>% 
  arrange(-case_sum)

# last seven days deaths per mil pop
covid_by_state %>% filter(date > (as.Date(latest_date) - 6)) %>% 
  summarise(death_sum = sum(new_deaths_mil)) %>% 
  arrange(-death_sum)

