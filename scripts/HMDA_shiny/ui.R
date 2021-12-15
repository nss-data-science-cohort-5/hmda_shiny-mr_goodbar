#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Mr. Goodbar HMDA"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
        
        selectInput("lei",
                    "Lei:",
                    lei_list),
        
        selectInput("county",
                    "County Code:",
                    county_list)
        ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          
          tabPanel("Race",
                   plotOutput("racePlot")
          ),
          tabPanel("Age",
                   plotOutput("agePlot")
          ),
          tabPanel("Sex",
                   plotOutput("sexPlot")
          )
        )
      )
    )
  )
)
