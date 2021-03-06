#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


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
        
        width = 2
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          
          tabPanel("Race",
                   plotlyOutput("racePlot"),
                   tableOutput("raceTable")
          ),
          
          tabPanel("Age",
                   plotlyOutput("agePlot"),
                   tableOutput("ageTable")
          ),
          tabPanel("Sex",
                   plotlyOutput("sexPlot"),
                   tableOutput("sexTable")
          ),
          tabPanel("Map",
                   leafletOutput("gMap"),
                   selectInput("mapRace",
                               "Map Race",
                               choices = race_list,
                               selected = "Asian"),
                   selectInput("leiMap",
                               "LEI for Map",
                               choices = lei_list,
                               selected = "01KWVG908KE7RKPTNP46")
          ),
          # tabPanel("Mean Loan",
          #          plotOutput("avg_loan_race_plot"),
          #          plotOutput("avg_loan_age_plot"),
          #          selectInput("avgRace",
          #                      "Race",
          #                      choices = race_list,
          #                      selected = "Asian"),
          #          selectInput("avgAge",
          #                      "Age",
          #                      choices = age_list,
          #                      selected = ">25")
          #          
          # ),
          tabPanel("LEI Codes",
                   tableOutput("leiTable")
          ),
          tabPanel("Summary",
                   verbatimTextOutput("textSummary")
          )
        )
      )
    )
  )
)
