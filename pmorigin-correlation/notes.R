
# ## read-in from clipboard via xlsx ... better options exist
# x <- readClipboard()
# x <- read.table(textConnection(x), sep = '\t', header = TRUE, stringsAsFactors = FALSE)
# write.csv(x, file='LUT.csv', row.names = FALSE)


library(aqp)
library(sharpshootR)
library(igraph)
library(data.tree)

# network representation of coarse -> original mapping
tab <- table(x$winnowed.2, x$pmorigin)
m <- genhzTableToAdjMat(tab)

# PNG is handy for a quick example, SVG is better for zooming
png(file='coarse-groupings.svg', width=1000, height=1000, antialias = 'cleartype')
svg(file='coarse-groupings.svg', width=10, height=10, pointsize = 10, family = 'sans', antialias = 'subpixel')
par(mar=c(0,0,2,0))
plotSoilRelationGraph(m, graph.mode = 'directed', edge.arrow.size=0.2, vertex.label.family='sans', vertex.label.cex=0.65)
dev.off()



# data.tree representation
z <- x
z$path <- sprintf("pmorigin/%s/%s/%s", z$winnowed.2, z$winnowed, z$pmorigin)
z <- as.Node(z, pathName='path')

# full tree
print(z, pruneMethod = NULL)

# prune specific branches
print(z$`igneous extrusive rock`, pruneMethod = NULL)
print(z$`igneous intrusive rock`, pruneMethod = NULL)

# close-up views
plot(z$`igneous extrusive rock`, output='visNetwork')
plot(z$`igneous extrusive rock`, output='graph')

# full correlation: takes a while, result is ~ 1.5Mb HTML
plot(z, output='visNetwork')


