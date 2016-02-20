#cytoscape and r

library(igraph)
library(RJSONIO)
library(httr)

port.number = 1234
base.url = paste("http://localhost:", toString(port.number), "/v1", sep="")
print(base.url)

# Load list of edges as Data Frame
network.df <- read.table("./eco_EM+TCA.txt")

# Convert it into igraph object
network <- graph.data.frame(network.df,directed=T)

# Remove duplicate edges & loops
g.tca <- simplify(network, remove.multiple=T, remove.loops=T)

# Name it
g.tca$name = "Ecoli TCA Cycle"



# This function will be published as a part of utility package, but not ready yet.
source('toCytoscape.R')

# Convert it into Cytosccape.js JSON
cygraph <- toCytoscape(g.tca)

send2cy <- function(cygraph) {
  network.url = paste(base.url, "networks", sep="/")
  res <- POST(url=network.url, body=cygraph, encode="json")
  network.suid = unname(fromJSON(rawToChar(res$content)))
  print(network.suid)
  
  # Apply Visual Style and Circular Layout
  apply.layout.url = paste(base.url, "apply/layouts/circular", toString(network.suid), sep="/")
  apply.style.url = paste(base.url, "apply/styles/default%20black", toString(network.suid), sep="/")
  
  res <- GET(apply.layout.url)
  res <- GET(apply.style.url)
}

send2cy(cygraph)


plot(g.tca,vertex.label=V(g.tca)$name)







