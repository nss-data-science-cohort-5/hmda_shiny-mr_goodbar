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
        if ((input$lei == "All" & input$county == "All") | (input$lei != "All" & input$county == "All")) {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "Competitors", input$lei))
        }
        else if ((input$lei == "All" & input$county != "All") | (input$lei != "All" & input$county != "All")) {
            HMDA_WA %>% 
                mutate(lei = if_else(lei != input$lei, "Competitors", input$lei)) %>% 
                filter(county_code == input$county)
        }
    })
    
    lei_count_filter_other <- reactive({
        if (input$lei == "All" & input$county == "All") {
            HMDA_WA 
        }
        else if(input$lei != "All" & input$county == "All") {
            HMDA_WA %>% 
                filter(lei != input$lei)
        }
        else if (input$lei == "All" & input$county != "All") {
            HMDA_WA %>% 
                filter(county_code == input$county)
        }
        else if(input$lei != "All" & input$county != "All"){
            HMDA_WA %>% 
                filter(lei != input$lei, county_code == input$county)
        }
    })
    
    lei_count_filter_target <- reactive({
        if (input$lei == "All" & input$county == "All") {
            HMDA_WA 
        }
        else if(input$lei != "All" & input$county == "All") {
            HMDA_WA %>% 
                filter(lei == input$lei)
        }
        else if (input$lei == "All" & input$county != "All") {
            HMDA_WA %>% 
                filter(county_code == input$county)
        }
        else if(input$lei != "All" & input$county != "All"){
            HMDA_WA %>% 
                filter(lei == input$lei, county_code == input$county)
        }
    })
    
    
    group_filter <- reactive({
        if(input$category == "derived_race") {
            lei_county_filter() %>% 
                count(lei, derived_race) %>% 
                pivot_wider(names_from = derived_race, values_from = n) %>% 
                replace(is.na(.), 0) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:10])) * 100) %>% 
                pivot_longer(cols = "2 or more minority races":"Race Not Available") %>% 
                filter(name != "Free Form Text Only")
            
        }
        else if(input$category == "applicant_age") {
            lei_county_filter() %>%
                count(lei, applicant_age) %>% 
                pivot_wider(names_from = applicant_age, values_from = n) %>% 
                replace(is.na(.), 0) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:9]))*100) %>% 
                pivot_longer(cols = "<25":"8888") %>% 
                mutate(name = fct_relevel(name,"<25", "25-34", "35-44", "45-54", "55-64", "65-74", ">74", "8888"))
            
        }
        else if(input$category == "derived_sex") {
            lei_county_filter() %>% 
                count(lei, derived_sex) %>% 
                pivot_wider(names_from = derived_sex, values_from = n) %>% 
                mutate_if(is.numeric, function(x)(x/rowSums(.[2:4]))*100)%>% 
                pivot_longer(cols = "Female":"Male") %>% 
                mutate(name = fct_relevel(name, "Female", "Male", "Joint"))
        }
    })
    
    cat_title_perc <- reactive({
        if(input$category == "applicant_age") {
            labs(title = "Percent Applicant by Age: Lei Vs. Competitors")
        }
        else if(input$category == "derived_race") {
            labs(title = "Percent Applicant by Race: Lei Vs. Competitors")
        }
        else if(input$category == "derived_sex") {
            labs(title = "Percent Applicant by Sex: Lei Vs. Competitors")
        }
    })
    
    cat_ylab_perc <- reactive({
        if(input$category == "applicant_age") {
            ylab("Age")
        }
        else if(input$category == "derived_race") {
            ylab("Race")
        }
        else if(input$category == "derived_sex") {
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
        
        
    })
    
    output$countPlot <- renderPlot({
        
        column_reorder <- function(data, x){
            if(x == "applicant_age") {
                mutate(data, applicant_age = fct_relevel(applicant_age,"<25", "25-34", "35-44", "45-54", "55-64", "65-74", ">74", "8888"))
            }
            else if(x == "derived_sex") {
                mutate(data, derived_sex = fct_relevel(derived_sex, "Female", "Male", "Joint"))
            }
            else if(x == "derived_race") {
                mutate(data, derived_race = fct_relevel(derived_race, "Asian", "American Indian or Alaska Native", 
                                                        "Black or African American", "Native Hawaiian or Other Pacific Islander",
                                                        "White", "2 or more minority races", "Joint", "Race Not Available"))
            }
        }
        
        other_lei_numb <- lei_count_filter_other() %>% 
            replace(is.na(.), 0) %>%
            count(lei, !!as.name(input$category))%>% 
            group_by(!!as.name(input$category)) %>% 
            summarize(avg_numb_for_cat = mean(n)) %>% 
            mutate(lei = "Competitors")
        
        target_lei_numb <- lei_count_filter_target() %>% 
            replace(is.na(.), 0) %>%
            count(lei, !!as.name(input$category))%>% 
            group_by(!!as.name(input$category)) %>% 
            summarize(avg_numb_for_cat = mean(n)) %>% 
            mutate(lei = input$lei)
        
        count_comp <- full_join(target_lei_numb, other_lei_numb)  
        
        count_comp %>% 
            column_reorder(input$category) %>% 
            ggplot(aes(y=!!as.name(input$category), x = avg_numb_for_cat, fill = lei)) +
            geom_col(position = "dodge") +
            scale_y_discrete(limits = rev) +
            cat_ylab_perc() +
            xlab("Count") +
            scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) 
    })
    
})
