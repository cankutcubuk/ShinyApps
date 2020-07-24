############################################################ 
#    Example for the network visualization on shiny app    #
#                                                          #
#         cankutcubuk [at] {gmail} [dot] {com}             #
#                         2020                             #
#             @ QMUL and ICR, London, UK                   #
############################################################ 

rm(list=ls())
library(shiny)
library(visNetwork)
library(dplyr)

load(url("https://raw.githubusercontent.com/cankutcubuk/ShinyApps/master/mynetwork.RData"))

########################################
server <- shinyServer(function(input, output) {
  
  output$network <- renderVisNetwork({
      visNetwork(nodes, edges) %>%
        visIgraphLayout() %>%
        visNodes(
                 shape = "dot",
                 color = list(
                   background = "#0085AF",
                   border = "#013848",
                   highlight = "#FF8000"
                 ),
                 shadow = list(enabled = TRUE, size = 10)
        ) %>%
        visEdges(
          shadow = FALSE,
          color = list(color = "#0085AF", highlight = "#C62F4B")
        ) %>%
        visLayout(randomSeed = 11)  
  })
})

ui <- shinyUI(
    fluidPage(visNetworkOutput("network", height = "700px"))
  )

browseURL("http://localhost:3838")
runApp(list(ui = ui, server = server), launch.browser = TRUE, port = 3838)

