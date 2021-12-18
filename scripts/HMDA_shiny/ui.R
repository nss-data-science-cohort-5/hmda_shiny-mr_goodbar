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
        
        selectizeInput("lei",
                    "Lei:",
                    choices = lei_list,
                    selected = c("01KWVG908KE7RKPTNP46"),
                    multiple = T),
        
        selectizeInput("county",
                    "County Code:",
                    choices = county_list,
                    selected = c("53001"),
                    multiple = T),
        
        actionButton('debug', "Debug"),
        
        width = 2
        ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          
          tabPanel("Race",
                   plotOutput("racePlot"),
                   tableOutput("raceTable")
          ),
          tabPanel("Age",
                   plotOutput("agePlot"),
                   tableOutput("ageTable")
          ),
          tabPanel("Sex",
                   plotOutput("sexPlot"),
                   tableOutput("sexTable")
          )
        )
      )
    )
  )
)
