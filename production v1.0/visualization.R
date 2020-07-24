# rm(list=ls())
library(shiny)
library(visNetwork)
library(dplyr)


########################################
server <- shinyServer(function(input, output) {
  
  output$title_panel = renderText({
    switch(input$networkSel, "Network1"="Network1", "Network2"="Network2") 
  })

  output$network <- renderVisNetwork({
    if(input$networkSel=="Network1"){
    }else{}        
  })
})

ui <- shinyUI(
  
  fluidPage(
    titlePanel("Sciacca's Network"),
    sidebarLayout(position = "left",
                  sidebarPanel( h2("Parameters"),
                                selectInput(inputId = "networkSel",label = "Select network:",choices = c("Network1","Network2"),selected = "Network1"),
                                selectInput("mode","Layout:",c("Random","Circle","Tree","Grid"),"Random"),
                                numericInput("sizeedges","Edge size:",min = 1,max = 10,value = 2,step = 1),
                                sliderInput("sizenodes","Edge Factor:",0,40,15,step=5),
                                actionButton("gennet","Generate"),
                                textOutput("networkstat")
                  ),
              
                  mainPanel(#h2("Network Plots"),
                    tabsetPanel(
                      tabPanel(title =  uiOutput("title_panel"), visNetworkOutput("network", height = "500px"), style = "background-color: #eeeeee;")
                    ))
    )
  )
)

runApp(list(ui = ui, server = server), launch.browser = TRUE, port = 3333)

