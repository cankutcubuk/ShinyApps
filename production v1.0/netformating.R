rm(list=ls())
library(visNetwork)
library(igraph)
library(dplyr)

############################################################ 
#        Prepare the networks for visualization            #
#                        2020                              #
#                    @ EMR, QMUL, London                   #
############################################################ 

# Questions
# Do we want a color gradient per network or across all networks

setwd("/Desktop/EMR/ElisabettaSciacca/nets/")
myedgepattern <- ".edges.tsv"
mynodepattern <- ".nodes.csv"

myfiles <- gsub(mynodepattern,"",list.files("./",pattern = mynodepattern))
netlist <- list()
pal <- colorRampPalette(c("white", "blue"))
prefixNA <- "(Exp value is NA)"

for(f in myfiles){

nodes  <- read.delim(paste0("./",f,".nodes.csv"), sep = "\t", stringsAsFactors = F) 
nodes$label[is.na(nodes$mean.expression)] <- paste0(nodes$label[is.na(nodes$mean.expression)], " \n ", prefixNA)

nodes$mean.expression[is.na(nodes$mean.expression)] <- 0
nodes$mean.expression <-(nodes$mean.expression-min(nodes$mean.expression,na.rm = T))/max(nodes$mean.expression,na.rm = T)
nodes$mean.expression <- round(nodes$mean.expression * 100)

edges  <- read.delim(paste0("./",f,".edges.tsv"), sep = "\t", stringsAsFactors = F)

nodes$order = findInterval(nodes$mean.expression, sort(nodes$mean.expression))
nodes$color <- pal(nrow(nodes))[nodes$order]
nodes$font.size <- 40
nodes$color[grep(prefixNA,nodes$label)] <- "#808080"

edges$arrows <- ifelse(edges$direction=="directed","to",NA)
edges$color <- ifelse(edges$colour==1,"green","red")
edges$width <- 5

if(1==0){
# prune to remove unshared nodes between node and edge files
# "some vertex names in edge list are not listed in vertex data frame"
todisc1 <- intersect(which(edges$from %in% nodes$id), which(edges$to %in% nodes$id))
if(length(todisc1)>0){
  edges <- edges[todisc1,]
}

todisc2 <- which(nodes$id %in% unique(c(edges$from, edges$to)))
if(length(todisc2)>0){
  nodes <- nodes[todisc2,]
}

setdiff(nodes$id, unique(c(edges$from, edges$to)))
setdiff(unique(c(edges$from, edges$to)),nodes$id)
intersect(nodes$id, unique(c(edges$from, edges$to)))
}

if(1==1){
# plot every single node in edges.tsv and use available node attributes from nodes.csv
diffs1 <- setdiff(unique(c(edges$from, edges$to)),nodes$id)
if(length(diffs1)>0){
  message(paste0(f,"... calibrated"))
  addnodes <- data.frame("id"=diffs1,
             "label"=paste0(diffs1, " \n ", prefixNA),
             "mean.expression"=NA,
             "order"=0,
             "color"="#808080",
             "font.size"=40
             )
 nodes <- rbind(nodes, addnodes)
}

# create consistent nodes and edges files. for example R4RA.responders.TOC(VsRTX) has 220 edges and 26468 nodes
diffs2 <- setdiff(nodes$id, unique(c(edges$from, edges$to)))
if(length(diffs2)>0){
  message(paste0(f,"... calibrated"))
  nodes <- nodes[which(!nodes$id %in% diffs2),]
}
}

###### create visNetwork obj ######
mynetwork <- visNetwork(nodes, edges, width = "100%", height = "100%") %>%
  visIgraphLayout(layout =  "layout_nicely") %>%
  visNodes(size=30,
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
  visOptions(highlightNearest = list(enabled = T, degree = 1, hover = F)) %>%
  visLayout(randomSeed = 11)  %>%
  visInteraction(navigationButtons = TRUE, dragNodes = T, dragView = T, zoomView = T, keyboard = TRUE, tooltipDelay = 0)
####################################

netlist[[f]] <- list("nodes"=nodes[,c("id","label","color","font.size")],
                     "edges"=edges[,c("from","to","arrows","color","width")],
                     "mynetwork"=mynetwork)
 

print(paste0(f,"...", nrow(nodes),"...",nrow(edges)))
}


save(netlist, file = "/Desktop/EMR/ElisabettaSciacca/nets/netlist2.RData")

##### create dummy color legend
# library(ggplot2)
# 
# mdf <- data.frame(X=c(0:10))
# mdf$Y <- mdf$X * 3
# mdf$Z <- seq(from = 0, to = 1, by = 0.1)
# 
# ggplot(data = mdf, aes(x = X, y = Y, col = Z)) +
#   geom_point() +
#   scale_colour_gradientn(colours = pal(10)) +
#   theme_bw() +
#   theme(legend.position = "top") +
#   ggtitle("Y vs. X with Z-Color")

