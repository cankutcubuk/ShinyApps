rm(list=ls())
library(shiny)
library(visNetwork)

############################################################ 
#                  Visualize the networks                  #
#                        2020                              #
#                    @ EMR, QMUL, London                   #
############################################################ 

setwd("/Desktop/EMR/ElisabettaSciacca/nets/")
load("netlist2.RData")
names(netlist) <- gsub("[.]"," ",names(netlist))
netnames <- names(netlist)

########################################
server <- shinyServer(function(input, output) {
  output$title_panel = renderText({
        input$networkSel
  })
  output$network <- renderVisNetwork({
         netlist[[input$networkSel]]$mynetwork
  })
})

ui <- shinyUI(
    fluidPage(
      titlePanel("Sciacca's Network"),
      sidebarLayout(position = "left",
                 sidebarPanel(# h2("Parameters"
                                 width=2,
                                  selectInput(inputId = "networkSel",label = "Select network:",choices = netnames, selected = netnames[1]),
                        fluidRow(align="center",  tags$div(img(src = "legend.png", class="img-responsive", width = "150px", height = "150px")),p(" "))
                        ),
      mainPanel(#h2("Network Plots"),t
                width=10,
                tabsetPanel(
                  tabPanel(title =  uiOutput("title_panel"), visNetworkOutput("network", height = "500px"), style = "background-color: #eeeeee;")
                ))
      )
    )
  )

shinyApp(ui, server)
