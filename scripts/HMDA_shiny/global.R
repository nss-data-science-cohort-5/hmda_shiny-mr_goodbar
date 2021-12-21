library(tidyverse)
library(shiny)
library(plotly)
library(viridis)
library(sf)
library(leaflet)

HMDA_WA_all <- read_csv("../../data/state_WA.csv")
leiData <- read_csv("../../data/leiT.csv")

HMDA_WA <- HMDA_WA_all %>% 
  subset(select = c(activity_year, lei, `derived_msa-md`, state_code, county_code,
         census_tract, derived_loan_product_type, derived_dwelling_category,
         derived_race, derived_sex, action_taken, loan_type, loan_amount, 
         loan_to_value_ratio, property_value, income, tract_population,tract_minority_population_percent, applicant_age)
         ) %>% 
  transform(property_value = as.numeric(property_value), county_code = as.character(county_code))

lei_list <- unique(HMDA_WA$lei)
lei_list <- c("All",lei_list)
lei_list <- sort(lei_list)
county_list <- unique(HMDA_WA$county_code)
county_list <- c("All",county_list)
race_list <- unique(HMDA_WA$derived_race)
age_list <- unique(HMDA_WA$applicant_age)

summaryText = "\nWe developed this app for the purpose of helping Hauser Jones & Sas more easily aid their clients in their compliance with the Home Mortgage Disclosure Act. With this app you are able to use data gathered from the
HMDA website (https://ffiec.cfpb.gov) and https://www.lei-lookup.com to assess institutions lending practices on  the basis of race, gender, and age in various counties in Washington state between the years 2018-2020.
This app allows you to filter data by loan type, purchaser type, dwelling type, loan amounts, and reasons for denial as well as visualize with graphs and maps.  We hope this will become an invaluable tool for helping
your clients achieve equitability in their loan process. \n
For the purposes of this app, the following definitions are for race, age, and sex. \n
Age = age_applicant: The age of the applicant \n
Race = dericed_race: Single aggregated race categorization derived from applicant/borrower and co-applicant/co-borrower race fields \n
Sex = derived_sex: Single aggregated sex categorization derived from applicant/borrower and co-applicant/co-borrower sex fields"


# url = 'https://ffiec.cfpb.gov/v2/data-browser-api/view/csv?states=WA&years=2020'
# 
# query = list(
#   'type' = 'lei'
# ) 
# 
# response = GET(url, query=query)
# 
# 
# response$status_code
# 
# hmda <- content(response, as = "text") %>% 
#   read_csv()
# hmda %>% write_csv('hdma.csv')
# 
# data= read_csv('hdma.csv') %>% 
#   select('lei', 'county_code', 'census_tract', 'derived_race', 'derived_sex', "applicant_age", 'denial_reason-1')
# 
# data %>% 
#   filter(derived_race!='Race Not Available', derived_sex!= "Sex Not Available",applicant_age!= '8888') %>% view()