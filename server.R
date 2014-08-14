library(shiny)
library(ggplot2)
library(data.table)
library(maps)
library(rCharts)
library(reshape2)
library(markdown)
library(mapproj)
require(rCharts)

states <- map_data("state")
storm <- fread("./data.csv")

shinyServer(
    function(input, output) {
        
        agg_state <- reactive({
            temp <- storm[YEAR >= input$range[1] & YEAR <= input$range[2],]
            
            temp$FATALITIES <- as.numeric(temp$FATALITIES)
            temp$INJURIES <- as.numeric(temp$INJURIES)
            
            melted <- melt(temp, id.vars="STATE", measure.var = c("FATALITIES","INJURIES","PROPDMG","CROPDMG") )
            totalLoss <- dcast(melted, STATE ~ variable, sum)
            totalLoss
        })
        
        agg_year <- reactive({
            temp_year <- storm[YEAR >= input$range[1] & YEAR <= input$range[2],]
            
            temp_year$FATALITIES <- as.numeric(temp_year$FATALITIES)
            temp_year$INJURIES <- as.numeric(temp_year$INJURIES)
            
            melted <- melt(temp_year, id.vars="YEAR", measure.var = c("FATALITIES","INJURIES","PROPDMG","CROPDMG") )
            totalLossYear <- dcast(melted, YEAR ~ variable, sum)
            totalLossYear
        })
        
        output$state_map_plot <- renderPlot({
            data <- agg_state()
            
            if(input$eventType == 'injuries') {
                data$Affected <- data$INJURIES
            } else if(input$eventType == 'fatalities') {
                data$Affected <- data$FATALITIES
            } else if(input$eventType == 'property_damage'){
                data$Affected <-data$PROPDMG
            } else {
                data$Affected <-data$CROPDMG
            }
            
            title <- paste("Impact", input$range[1], "-", input$range[2], "(number of affected)")
            p <- ggplot(data, aes(map_id = STATE))
            p <- p + geom_map(aes(fill = Affected), map = states, colour='black') + expand_limits(x = states$long, y = states$lat)
            p <- p + coord_map() + theme_bw()
            p <- p + labs(x = "Long", y = "Lat", title = title)
            print(p)
        })
        
         output$year_event_plot <- renderChart({
#         output$year_event_plot <- renderPlot({
            data_year <- agg_year()
            
            if(input$eventType == 'injuries') {
                data_year$Affected <- data_year$INJURIES
            } else if(input$eventType == 'fatalities') {
                data_year$Affected <- data_year$FATALITIES
            } else if(input$eventType == 'property_damage'){
                data_year$Affected <-data_year$PROPDMG
            } else {
                data_year$Affected <-data_year$CROPDMG
            }
            
            eventsByYear <- nPlot(
                Affected ~ YEAR,
                data = data_year,#[order(data_year$YEAR),]
                type = "stackedAreaChart", dom = 'year_event_plot', width = 600
            )
            
            eventsByYear$chart(margin = list(left = 100))
            eventsByYear$yAxis( axisLabel = "Affected", width = 80)
            eventsByYear$xAxis( axisLabel = "Year", width = 70)
#              eventsByYear$chart(stacked = TRUE)
             return(eventsByYear)
           
        })
        
    }
)