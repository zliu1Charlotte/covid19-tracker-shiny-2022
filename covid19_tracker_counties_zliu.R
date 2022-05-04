df <- read.csv("us-counties-2022.csv")
library(shiny)
library(ggplot2)

ui <- navbarPage("Covid-19 Cases Tracker",
        tabPanel("About",
             headerPanel(strong("Covid-19 Cases Tracker",style = "color:orange")),
             fluidRow(
             column(10,
             h1(p(
             "Tracking Region:",style = "color:blue")),
             h2(p(
             "United States Counties")),
             
             h1(p(
               "Tracking Time Period:",style = "color:blue")),
             h2(p(
               "Jan 1st 2022 - April 11st 2022")),
             
             h1(p(
               "Tracking Details:",style = "color:blue")),
             h2(p(
               "Positive and Death Cases")),
             
             h1(p(
               "About:",style = "color:blue")),
             h2(p(
               "This R Shiny Application is use to track Covid-19 positive and death cases 
               throughout the United States Counties from Jan to April 2022.")),
             
             h1(p(
               "Author:",style = "color:blue")),
             h2(p(
               "Zhenyuan Liu", tags$br(),
               "Electrical and Computer Engr",tags$br(),
               "PhD Candidate", tags$br(),
               "Worcester Polytechnic Institute")),
             
             ),
             )
             ),
    
        tabPanel("Data Frame in Table",DT::dataTableOutput("table")),
       
        tabPanel("Cases Results on Number",
            headerPanel("Accumulated Day Cases over Date, State and County"),
            sidebarPanel(
            dateInput("dt1","Select Date: ",
            value = "2022-01-01",
            min = "2022-01-01",
            max = "2022-04-11"),
            selectInput("statein", "Select State:",choices = unique(df$state)),
            selectInput("countyin", "Select County", choices = NULL)
            ),
            
            mainPanel(
            h1("Accumulated Confirmed Case:",textOutput("oconf"),style="color:orange"),
            h1("Accumulated Death Case:",textOutput("odet"),style="color:red"),
            )
        ),
        
        tabPanel("Cases Results on Plots",
                 headerPanel("County Cases over Date and States"),
                 sidebarPanel(
                   dateInput("dt2","Select Date: ",
                             value = "2022-01-01",
                             min = "2022-01-01",
                             max = "2022-04-11"),
                   selectInput("statein2", "Select State:",choices = unique(df$state))
                 ),
                 
                 mainPanel(
                   plotOutput("plot"),
                   plotOutput("plot2")
                 )
        ),
        
        tabPanel("Cluster Cases over Date and State",
                 headerPanel("K-Mean Clustering on Confirmed and Death Cases"),
                 sidebarPanel(
                   dateInput("dt3","Select Date: ",
                             value = "2022-01-01",
                             min = "2022-01-01",
                             max = "2022-04-11"),
                   selectInput("statein3", "Select State:",choices = unique(df$state)),
                   #selectInput("countyin3", "Select County", choices = NULL),
                   numericInput('clusters', 'Cluster count', 3, min = 1, max = 9)
                 ),
          mainPanel(
            plotOutput('plot3')
          )
        )
            
        )
             
            


server <- function(input, output, session) {
  
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
  

shinyApp(ui = ui, server = server)
  
  