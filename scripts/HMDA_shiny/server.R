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
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "other", input$lei))
        }
        else if (input$lei == "All" & input$county != "All") {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "other", input$lei),
                       county_code = if_else(county_code != input$county, "other", input$county)) %>% 
                filter(county_code == input$county)
        }
        else if (input$lei != "All" & input$county == "All") {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "other", input$lei))
        }
        else if (input$lei != "All" & input$county != "All") {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "other", input$lei),
                       county_code = if_else(county_code != input$county, "other", input$county)) %>% 
                filter(county_code == input$county)
            
        }
        
    })
    group_filter <- reactive({
        if(input$category == "Race") {
            lei_county_filter() %>% 
                count(lei, derived_race) %>% 
                pivot_wider(names_from = derived_race, values_from = n) %>% 
                replace(is.na(.), 0) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:10])) * 100) %>% 
                pivot_longer(cols = "2 or more minority races":"Race Not Available") %>% 
                filter(name != "Free Form Text Only")
             
        }
        else if(input$category == "Age") {
            lei_county_filter() %>% 
                filter(!applicant_age %in% c("8888", "9999")) %>% 
                count(lei, applicant_age) %>% 
                pivot_wider(names_from = applicant_age, values_from = n) %>% 
                replace(is.na(.), 0) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:8]))*100) %>% 
                pivot_longer(cols = "<25":"65-74") %>% 
                mutate(name = fct_relevel(name,"<25", "25-34", "35-44", "45-54", "55-64", "65-74", ">74"))
                
        }
        else if(input$category == "Sex") {
            lei_county_filter() %>% 
                filter(derived_sex != "Sex Not Available") %>% 
                count(lei, derived_sex) %>% 
                pivot_wider(names_from = derived_sex, values_from = n) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:4]))*100)%>% 
                pivot_longer(cols = "Female":"Male") %>% 
                mutate(name = fct_relevel(name, "Female", "Male", "Joint"))
        }
    })
    
    cat_title_perc <- reactive({
        if(input$category == "Age") {
            labs(title = "Percent Applicant by Age: Lei Vs. Competitors")
        }
        else if(input$category == "Race") {
            labs(title = "Percent Applicant by Race: Lei Vs. Competitors")
        }
        else if(input$category == "Sex") {
            labs(title = "Percent Applicant by Sex: Lei Vs. Competitors")
        }
    })
   
    cat_ylab_perc <- reactive({
        if(input$category == "Age") {
            ylab("Age")
        }
        else if(input$category == "Race") {
            ylab("Race")
        }
        else if(input$category == "Sex") {
            ylab("Sex")
        }
    })

    output$barPlot <- renderPlot({
      
        group_filter() %>%  
            arrange(desc(name)) %>% 
            ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
            geom_col(position = "dodge") +
            theme(axis.text.y = element_text(face = "bold"),
                  plot.title = element_text(hjust = 0.5)) +
            scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) +
            cat_title_perc() + 
            cat_ylab_perc() +
            xlab("Percent (%)")
      

        # generate bins based on input$bins from ui.R
        #x    <- HMDA_WA[, 22]
        #bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        #hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
