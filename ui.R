library(shiny)
library(rCharts)
shinyUI(
    
    navbarPage("Storm Database Explorer",
              tabPanel("Plot",
                       sidebarPanel(
                           sliderInput("range", 
                                       "Year Range:", 
                                       min = 1950, 
                                       max = 2011, 
                                       value = c(1950, 2011),
                                       format="####"),
                           radioButtons(
                               "eventType",
                               "Select Type of Incident for Plot",
                               c("Injuries" = "injuries", "Fatalities" = "fatalities","Property Damage" = "property_damage","Crops Damage" = "crops_damage")
                            )
                       
                       ),
                       
                       mainPanel(
                           tabsetPanel(
                               tabPanel("Map",
                                   plotOutput("state_map_plot")),
                                tabPanel("Graph", 
                                         h4('Damange by year', align = "center"),
                                        showOutput("year_event_plot", "nvd3"))
                               
                               )
                       )
                       
                       ),
              tabPanel("About",
                       mainPanel(includeMarkdown("About.md")))
    )
    
)