#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  observeEvent(input$debug, {
    browser()
  })
  
    
    lei_county_filter <- reactive({
        if ("All" %in% input$lei & "All" %in% input$county) {
            HMDA_WA
        }
        else if ("All" %in% input$lei & !("All" %in% input$county)) {
            HMDA_WA %>% 
              mutate(county_code = if_else(county_code != input$county, "other", input$county))
        }
        else if (!("All" %in% input$lei) & "All" %in% input$county) {
            HMDA_WA %>%
              mutate(lei = if_else(lei != input$lei, "other", input$lei))
        }
        else {
            HMDA_WA %>%
              filter(county_code %in% input$county) %>%
                mutate(lei = if_else(lei %in% input$lei, lei, "other"))
        }
        
    })
    
    output$textSummary <- renderText({
      summaryText
    })
    
    
    url <- "https://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_050_00_5m.json"
    
    counties <- read_sf(url)
    
    WA_counties <- counties %>% 
      filter(STATE == "53")
    
    county_code_list <- read_csv("../../data/us_county_codes.csv")
    
    county_code_list <- county_code_list %>% 
      rename("NAME" = "County or equivalent", "county_code" = "FIPS") %>% 
      mutate(across(county_code, as.character)) %>% 
      filter(`State or equivalent` == "Washington") 
    
    WA_counties <- left_join(WA_counties, county_code_list)
    
    WA_counties <- WA_counties %>% 
      select(-c(STATE, COUNTY, ...1,))
    
    value_filter1 <- reactive({
      HMDA_WA %>%
        filter(lei == input$leiMap) %>%
        count(county_code, derived_race) %>%
        filter(!is.na(county_code)) %>%
        pivot_wider(names_from = derived_race, values_from = n) %>%
        replace(is.na(.), 0) %>%
        mutate_if(is.numeric, function(x)(x/rowSums(.[2:9])) * 100) %>%
        pivot_longer(!county_code) %>%
        filter(name == input$mapRace)
    })
    
    value_filter2 <- reactive({
      left_join(WA_counties, value_filter1())
    })
    
    
    value_filter3 <- reactive({
      value_filter2() %>% 
        replace_na(list(name = input$mapRace, value = 0))
      })
    
    
    mytext <- reactive({
      paste(
        "County: ", value_filter3()$NAME," ",
        "Percent: ", round(value_filter3()$value, 2), sep = "") %>% 
        sapply(htmltools::HTML)
    })
    
    mybins <- reactive({
      c(0, 1, 2, 4, 8, 16, 25, 50, 75, 100)
    })
    
    
    mypalette <- reactive({
      colorBin(palette="YlOrBr", domain = value_filter3()$value, na.color="transparent", bins=mybins())
    })
    
    
    
    
    #This section handles the race filters
    group_filter_race <- reactive({
      lei_county_filter() %>%
        filter(derived_race != "Race Not Available") %>%
        filter(derived_race != "Free Form Text Only") %>%
        count(lei, derived_race) %>%
        arrange(derived_race)
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
        count(lei, derived_sex) %>%
        arrange(derived_sex)
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
    
    group_filter_age_sort <- reactive({
      group_filter_age() %>%
        arrange(parse_number(applicant_age))
    })
    
    #This orders the age for the graph.
    unique_group_filter_age_sort <- reactive({
      c(unique(group_filter_age_sort()[["applicant_age"]]))
    })
    
    age_count <- reactive({
      length(unique(group_filter_age_sort()[["applicant_age"]])) + 1
    })
    
    age_graph_info <- reactive({
      group_filter_age_sort() %>%
        pivot_wider(names_from = applicant_age, values_from = n) %>% 
        replace(is.na(.), 0) %>% 
        mutate_if(is.numeric, function(x)(x/rowSums(.[2:age_count()])) * 100) %>%
        pivot_longer(cols = -c("lei")) %>%
        mutate(name = fct_relevel(name,unique_group_filter_age_sort()))
    })
    
    
    
    #This section handles the plots
    output$racePlot <- renderPlotly({
      race_graph_info() %>%  
            arrange(desc(name)) %>% 
            ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
            geom_col(position = "dodge") +
            theme(axis.text.x = element_text(face = "bold", size=rel(1.0)),
                  axis.text.y = element_text(face = "bold", size=rel(1.0)),
                  axis.title = element_text(size=rel(1.2)),
                  legend.text = element_text(size=rel(.9)),
                  legend.title = element_text(size=rel(.9)),
                  plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) +
        labs(title = "Percent Applicant by Race: Lei Vs. Competitors") +
        ylab("Race\n") +
        xlab("Percent (%)\n")

    })
    
    output$agePlot <- renderPlotly({
      
      age_graph_info() %>%  
        arrange(desc(name)) %>% 
        ggplot(aes(y = fct_rev(name), x = value, fill = lei)) +
        geom_col(position = "dodge") +
        theme(axis.text.x = element_text(face = "bold", size=rel(1.0)),
              axis.text.y = element_text(face = "bold", size=rel(1.0)),
              axis.title = element_text(size=rel(1.2)),
              legend.text = element_text(size=rel(1.0)),
              legend.title = element_text(size=rel(1.0)),
              plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 20)) +
        labs(title = "Percent Applicant by Age: Lei Vs. Competitors") + 
        ylab("Age\n") +
        xlab("Percent (%)\n")
    })
    
    output$sexPlot <- renderPlotly({
      
      sex_graph_info() %>%  
        arrange(desc(name)) %>% 
        ggplot(aes(y = fct_inorder(name), x = value, fill = lei))+
        geom_col(position = "dodge") +
        theme(axis.text.x = element_text(face = "bold", size=rel(1.0)),
              axis.text.y = element_text(face = "bold", size=rel(1.0)),
              axis.title = element_text(size=rel(1.2)),
              legend.text = element_text(size=rel(1.0)),
              legend.title = element_text(size=rel(1.0)),
              plot.title = element_text(hjust = 0.5, size=rel(1.5))) +
        scale_y_discrete(labels = function(x) str_wrap(x, width = 15)) +
        labs(title = "Percent Applicant by Sex: Lei Vs. Competitors") + 
        ylab("Sex\n") +
        xlab("Percent (%)\n")
      
    })
    
    output$raceTable <- renderTable({
      group_filter_race() %>%
        pivot_wider(names_from = derived_race, values_from = n) %>% 
        replace(is.na(.), 0)
    })
    
    output$ageTable <- renderTable({
      group_filter_age() %>%
        pivot_wider(names_from = applicant_age, values_from = n) %>% 
        replace(is.na(.), 0)
    })
    
    output$sexTable <- renderTable({
      group_filter_sex() %>%
        pivot_wider(names_from = derived_sex, values_from = n) %>% 
        replace(is.na(.), 0)
    })
    
    output$gMap <- renderLeaflet({
      leaflet(value_filter3()) %>% 
        addTiles() %>% 
        addPolygons(fillColor = ~mypalette()(value), 
                    stroke = FALSE, 
                    fillOpacity = 0.8, 
                    smoothFactor = 0.5,
                    color = "white", 
                    weight = 0.3,
                    label = mytext(),
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", 
                                   padding = "3px 8px"),
                      textsize = "13.px",
                      direction = "auto"
                    )
        ) %>% 
        addLegend(pal = mypalette(), values = ~value, opacity = 0.9, title = "Applicants (%)",
                  position = "bottomleft")
    })

})
