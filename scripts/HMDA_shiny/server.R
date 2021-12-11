#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    lei_county_filter <- reactive({
        if (input$lei == "All" & input$county == "All") {
            HMDA_WA
        }
        else if (input$lei == "All" & input$county != "All") {
            HMDA_WA %>% 
                mutate(county_code = if_else(county_code != input$county, "other", input$county))
        }
        else if (input$lei != "All" & input$county == "All") {
            HMDA_WA %>% 
            mutate(lei = if_else(lei != input$lei, "other", input$lei))
        }
        else {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "other", input$lei), 
                       county_code =if_else(county_code != input$county, "other", input$county))
        }
        
    })

    output$distPlot <- renderPlot({
      if (input$race == "All") {
          lei_county_filter() %>% 
          filter(derived_sex == input$sex) %>% 
          ggplot(aes(y = loan_amount, x = income)) +
          geom_point()
      }
      else {
          lei_county_filter() %>% 
        filter(derived_race == input$race,
               derived_sex == input$sex) %>%
        ggplot(aes(y = loan_amount, x = income)) +
        geom_point()
        
      }

        # generate bins based on input$bins from ui.R
        #x    <- HMDA_WA[, 22]
        #bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        #hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
