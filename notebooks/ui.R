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
        textInput("LEI",
                  label = ("Legal Entity Identifier"),
                  value = "Enter LEI code..."),
        
        textInput("county_code",
                  label = ("County Code"),
                  value = "Enter Zipcode..."),
        
        selectizeInput("Applicant Race",
                       label = ("Applicant Race"),
                       choices = derivedrace,
                       multiple = T),
        
        selectizeInput("Applicant Sex", 
                       label = ("Applicant Sex"),
                       choices = derivedsex,
                       multiple = T),
        
        sliderInput("Age Range",
                    label = ("Age"),
                    min = 18, 
                    max = 100,
                    value = c(18, 100),
                    step = 1)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          
          tabPanel(
            title = "Overview",
            fluidRow(
              column(width=6,
                     plotOutput("barPlot")
              ),
              
              column(width=6)
            )
          ),
          
          tabPanel(
            title = "Graphs",
            fluidRow(
              column(width=6,
                     plotOutput("barPlot")
              ),
              column(width=6)
            )
          ),
          tabPanel(
            title = "Comparison",
            fluidRow(
              column(width=6,
                     plotOutput("barPlot")
              ),
              column(width=6)
            )
          )
        )
      )
    )
  )
)
