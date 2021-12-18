library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)

HMDA_WA_all <- read_csv("../../data/state_WA.csv")

HMDA_WA <- HMDA_WA_all %>% 
    subset(select = c(activity_year, lei, `derived_msa-md`, state_code, county_code,
                      census_tract, derived_loan_product_type, derived_dwelling_category,
                      derived_race, derived_sex, action_taken, loan_type, loan_amount, 
                      loan_to_value_ratio, property_value, income, tract_population,tract_minority_population_percent, applicant_age)
    ) %>% 
    transform(property_value = as.numeric(property_value), county_code = as.character(county_code))

lei_list <- unique(HMDA_WA$lei)
lei_list <- append(lei_list, "All")
#lei_list <- str_order()
county_list <- unique(HMDA_WA$county_code)
county_list <- append(county_list, "All")

loan_type_numb <- c(1:4)

loan_type_text <- c("Conventional",
                    "FHA",
                    "VA",
                    "RHS or FSA")
loan_type <-setNames(as.list(loan_type_text), loan_type_numb)

url <- "https://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_050_00_5m.json"

counties <- read_sf(url)

WA_counties <- counties %>% 
    filter(STATE == "53")

county_code_list <- read_csv("../../data/us_county_codes.csv")

county_code_list <- county_code_list %>% 
    rename("NAME" = "County or equivalent", "county_code" = "FIPS") %>% 
    mutate(across(county_code, as.character)) %>% 
    filter(`State or equivalent` == "Washington") 

WA_counties <- left_join(WA_counties, county_code_list)

WA_counties <- WA_counties %>% 
    select(-c(STATE, COUNTY, ...1,))

value_filter <- HMDA_WA %>% 
    count(county_code, derived_race) %>% 
    filter(!is.na(county_code))%>% 
    pivot_wider(names_from = derived_race, values_from = n) %>% 
    replace(is.na(.), 0) %>% 
    mutate_if(is.numeric, function(x)(x/rowSums(.[2:10])) * 100) %>% 
    pivot_longer(!county_code) %>%
    filter(name == "Asian")

value_filter <- left_join(WA_counties, value_filter)
value_filter

library(viridis)
g <-value_filter %>% 
    ggplot(aes(fill = value)) +
    geom_sf() +
    theme_void() +
    scale_fill_viridis(option = "cividis")

ggplotly(g)

value_filter %>% 
    ggplot(aes(x = county_code, y = value)) +
    geom_col()

value_filter %>% 
    plot_ly(type = "choropleth", color = ~value, name=~value)

mytext <- paste(
    "County: ", value_filter$NAME,"<br/>",
    "Percent: ", round(value_filter$value, 2), sep = "") %>% 
    lapply(htmltools::HTML)


mypalette <- colorQuantile(palette="YlOrBr", domain = value_filter$value, na.color="transparent")

leaflet(value_filter) %>% 
    addTiles() %>% 
    addPolygons(fillColor = ~mypalette(value), stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5,
                color = "white", weight = 0.3,
                label = mytext,
                labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "13.px",
                    direction = "auto"
                ))

HMDA_WA %>% 
    count(county_code, derived_race) %>% 
    filter(!is.na(county_code))%>% 
    pivot_wider(names_from = derived_race, values_from = n) %>% 
    replace(is.na(.), 0) %>% 
    mutate_if(is.numeric, function(x)(x/rowSums(.[2:10])) * 100) %>% 
    pivot_longer(!county_code) %>%
    filter(name == "Asian") 

