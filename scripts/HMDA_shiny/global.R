library(shiny)
library(tidyverse)
library(plotly)
library(dplyr)

#C:\Users\cmerr\Documents\Nashville Software School\Projects\hmda_shiny-mr_goodbar\scripts\HMDA_shiny\data
HMDA_WA_all <- read_csv("data/state_WA.csv")

HMDA_WA <- HMDA_WA_all %>% 
  subset(select = c(activity_year, lei, `derived_msa-md`, state_code, county_code,
         census_tract, derived_loan_product_type, derived_dwelling_category,
         derived_race, derived_sex, action_taken, loan_type, loan_amount, 
         loan_to_value_ratio, property_value, income, tract_population,tract_minority_population_percent, applicant_age)
         ) %>% 
  transform(property_value = as.numeric(property_value), county_code = as.character(county_code))

lei_list <- unique(HMDA_WA$lei)
lei_list <- append(lei_list, "All")
lei_list <- sort(lei_list)
county_list <- unique(HMDA_WA$county_code)
county_list <- append(county_list, "All")