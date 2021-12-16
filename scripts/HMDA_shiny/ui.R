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
shinyUI(fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("lei",
                        "Lei:",
                        lei_list
                        ),
            selectInput("county",
                         "County Code:",
                         county_list
                        ),
            selectInput("race",
                        "Race:",
                        c("White",
                          "Native Hawaiian or Other Pacific Islander", 
                          "Asian", 
                          'American Indian or Alaska Native',
                          "Black or African American",
                          "2 or more minority races",
                          "Joint")
                        ),
            checkboxGroupInput("sex",
                        h3("Sex:"),
                        c("Male",
                          "Female",
                          "Joint"),
                        selected = c("Male", "Female", "Joint")
                        ),
            selectInput("category",
                        "Category:",
                        c("Age" = "applicant_age",
                          "Sex" = "derived_sex",
                          "Race" = "derived_race")),
                  width = 3
              ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("barPlot"),
            plotOutput("countPlot")
        )
    )
))
