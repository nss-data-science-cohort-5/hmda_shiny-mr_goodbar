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
  
  observeEvent(input$debug, {
    browser()
  })
  
    
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
              filter(county_code == input$county) %>%
                mutate(lei = if_else(lei != input$lei, "other", input$lei))
        }
        
    })
    
    
    
    #This section handles the race filters
    group_filter_race <- reactive({
      lei_county_filter() %>% 
                filter(derived_race != "Race Not Available") %>% 
                count(lei, derived_race)
    })
    
    race_count <- reactive({
      length(unique(group_filter_race()[["derived_race"]])) + 1
    })
    
    race_graph_info <- reactive({
      group_filter_race() %>%
        pivot_wider(names_from = derived_race, values_from = n) %>% 
        replace(is.na(.), 0) %>% 
        mutate_if(is.numeric, function(x)(x/rowSums(.[2:race_count()])) * 100) %>%
        pivot_longer(cols = -c("lei")) %>% 
        filter(name != "Free Form Text Only")
    })
    
    
    
    #This section handles the sex filters
    group_filter_sex <- reactive({
      lei_county_filter() %>% 
        filter(derived_sex != "Sex Not Available") %>% 
        count(lei, derived_sex)
    })
    
    sex_count <- reactive({
      length(unique(group_filter_sex()[["derived_sex"]])) + 1
    })
    
    sex_graph_info <- reactive({
      group_filter_sex() %>%
        pivot_wider(names_from = derived_sex, values_from = n) %>% 
        replace(is.na(.), 0) %>% 
        mutate_if(is.numeric, function(x)(x/rowSums(.[2:sex_count()])) * 100) %>%
        pivot_longer(cols = -c("lei")) %>% 
        filter(name != "Free Form Text Only")
    })
    
    
    
    #This section handles the age filters
    group_filter_age <- reactive({
      lei_county_filter() %>% 
        filter(!applicant_age %in% c("8888", "9999")) %>% 
        count(lei, applicant_age)
    })
    
    age_count <- reactive({
      length(unique(group_filter_age()[["applicant_age"]])) + 1
    })
    
    age_graph_info <- reactive({
      group_filter_age() %>%
        pivot_wider(names_from = applicant_age, values_from = n) %>% 
        replace(is.na(.), 0) %>% 
        mutate_if(is.numeric, function(x)(x/rowSums(.[2:age_count()])) * 100) %>%
        pivot_longer(cols = -c("lei")) %>% 
        filter(name != "Free Form Text Only")
    })
    
    
    
    #This section handles the plots
    output$racePlot <- renderPlot({
      race_graph_info() %>%  
            arrange(desc(name)) %>% 
            ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
            geom_col(position = "dodge") +
            theme(axis.text.x = element_text(face = "bold", size=rel(1.25)),
                  axis.text.y = element_text(face = "bold", size=rel(1.25)),
                  axis.title = element_text(size=rel(1.50)),
                  legend.text = element_text(size=rel(1.50)),
                  legend.title = element_text(size=rel(1.50)),
                  plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) +
        labs(title = "Percent Applicant by Race: Lei Vs. Competitors") +
        ylab("Race\n") +
        xlab("Percent (%)")

    })
    
    output$agePlot <- renderPlot({
      
      age_graph_info() %>%  
        arrange(desc(name)) %>% 
        ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
        geom_col(position = "dodge") +
        theme(axis.text.x = element_text(face = "bold", size=rel(1.25)),
              axis.text.y = element_text(face = "bold", size=rel(1.25)),
              axis.title = element_text(size=rel(1.50)),
              legend.text = element_text(size=rel(1.50)),
              legend.title = element_text(size=rel(1.50)),
              plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 20)) +
        labs(title = "Percent Applicant by Age: Lei Vs. Competitors") + 
        ylab("Age\n") +
        xlab("Percent (%)")
      
    })
    
    output$sexPlot <- renderPlot({
      
      sex_graph_info() %>%  
        arrange(desc(name)) %>% 
        ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
        geom_col(position = "dodge") +
        theme(axis.text.x = element_text(face = "bold", size=rel(1.25)),
              axis.text.y = element_text(face = "bold", size=rel(1.25)),
              axis.title = element_text(size=rel(1.50)),
              legend.text = element_text(size=rel(1.50)),
              legend.title = element_text(size=rel(1.50)),
              plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) +
        labs(title = "Percent Applicant by Sex: Lei Vs. Competitors") + 
        ylab("Sex\n") +
        xlab("Percent (%)")
      
    })
    
    output$raceTable <- renderTable({
      group_filter_race() %>%
        pivot_wider(names_from = derived_race, values_from = n) %>% 
        replace(is.na(.), 0)
    })

})
