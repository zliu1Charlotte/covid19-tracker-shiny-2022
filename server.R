df <- read.csv("us-counties-2022.csv")
library(shiny)
library(ggplot2)

function(input, output, session) {
  
  output$table <- DT::renderDataTable(
    df
  )
  
  observe({
    updateSelectInput(session, "countyin", "Select County", 
                      choices = df[df$state == input$statein,]$county)
  })
  
  output$oconf <- renderText({
    d<-df[df$date==input$dt1 & df$county==input$countyin & df$state==input$statein,]
    paste(d$cases) })
  
  output$odet <- renderText({
    d<-df[df$date==input$dt1 & df$county==input$countyin & df$state==input$statein,]
    paste(d$deaths) })
  
  
  output$plot <- renderPlot({
    d<-df[ df$date==input$dt2 & df$state==input$statein2,]
    barplot(d$cases,
            main = "Accumulated Confirmed Cases",
            xlab = "Counties",
            ylab = "Confirmed Cases",
            names = d$county,
            col = "orange",
            border = "orange")
    
    grid(nx = NULL, ny = NULL,
         lty = 2,      # Grid line type
         col = "gray", # Grid line color
         lwd = 2)     # Grid line width
  })
  
  output$plot2 <- renderPlot({
    d<-df[ df$date==input$dt2 & df$state==input$statein2,]
    barplot(d$deaths,
            main = "Accumulated Death Cases",
            xlab = "Counties",
            ylab = "Death Cases",
            names = d$county,
            col = "red",
            border = "red")
    
    grid(nx = NULL, ny = NULL,
         lty = 2,      # Grid line type
         col = "gray", # Grid line color
         lwd = 2)     # Grid line width
  })
  
  
  selectedData <- reactive({
    d<-df[ df$date==input$dt3 & df$state==input$statein3, ]
    a <- c(d$cases,d$deaths)
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  output$plot3 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3, xlab= "Confirmed Cases", ylab= "Death Cases")
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  }) }