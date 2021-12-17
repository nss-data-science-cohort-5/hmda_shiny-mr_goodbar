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


library(httr)

hmda_function= function(year){
  
  
  url=paste0('https://ffiec.cfpb.gov/v2/data-browser-api/view/csv?states=WA&years=20', year)
  response = GET(url)
  hmda <- content(response, as = "text") %>% 
    read_csv()
  hmda %>% write_csv(paste0('hdma',year, '.csv'))
  
  data= hmda %>% 
    select('activity_year','lei', 'county_code', 'census_tract', 'derived_race', 'derived_sex', "applicant_age", 'denial_reason-1', 'derived_loan_product_type', 'derived_dwelling_category', 'purchaser_type', 'action_taken', 'applicant_credit_score_type', 'loan_amount')
  return(data)
}


data_all_years<-rbind(hmda_function(18),
                      hmda_function(19),
                      hmda_function(20))
