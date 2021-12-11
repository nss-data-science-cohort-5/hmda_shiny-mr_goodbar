#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

data=read.csv('../county_53031.csv')

head(data)

sapply(data, class)

glimpse(data)

data %>% 
  select(derived_race) %>% 
  mutate(derived_race=na_if(derived_race, 'Race Not Available')) %>% 
  drop_na(derived_race)

data %>% 
  select(derived_sex) %>% 
  mutate(derived_sex=na_if(derived_sex, 'Sex Not Available')) %>% 
  drop_na(derived_sex)

data %>% 
  select(applicant_age) %>% 
  mutate(applicant_age=na_if(applicant_age, 8888)) %>% 
  drop_na(applicant_age)


library(httr)

url = 'https://ffiec.cfpb.gov/v2/data-browser-api/view/csv?states=WA&years=2020'

query = list(
  'type' = 'lei'
) 

response = GET(url, query=query)


response$status_code

hmda <- content(response, as = "text") %>% 
    read_csv()
hmda %>% write_csv('hdma.csv')

data= read_csv('hdma.csv') %>% 
  select('lei', 'county_code', 'census_tract', 'derived_race', 'derived_sex', "applicant_age", 'denial_reason-1')

data %>% 
  filter(derived_race!='Race Not Available', derived_sex!= "Sex Not Available",applicant_age!= '8888') %>% view()
  
