library(rasterVis)
library(maps)
library(maptools)
library(rgdal)

r.a <- raster('grid/alluvium.tif')
r.r <- raster('grid/residuum.tif')
r.l <- raster('grid/loess.tif')
r.t <- raster('grid/till.tif')


# crud, extents are different
# get best extent and adjust raster layers
# https://stackoverflow.com/questions/20733555/how-to-create-a-raster-brick-with-rasters-of-different-extents

l <- list(extent(r.a),
     extent(r.r),
     extent(r.l),
     extent(r.t)
)

# make a matrix out of it, each column represents a raster, rows the values
extent_list <- lapply(l, as.matrix)

matrix_extent <- matrix(unlist(extent_list), ncol=length(extent_list))
rownames(matrix_extent)<-c("xmin", "ymin", "xmax", "ymax")
                      
# create an extent with the extrem values of your extent
best_extent <- extent(min(matrix_extent[1,]), max(matrix_extent[3,]), min(matrix_extent[2,]), max(matrix_extent[4,]))


r.a <- extend(r.a, best_extent)
r.r <- extend(r.r, best_extent)
r.l <- extend(r.l, best_extent)
r.t <- extend(r.t, best_extent)

s <- stack(r.a, r.r, r.l, r.t)

# experiment in thresholding, not super-useful
# s.thresh <- stack(r.a > 15, r.r > 15, r.l > 15, r.t > 15)

# generate a simple map of the CONUS states
usa <- map('state', plot=FALSE)
# convert to SPL
usa <- map2SpatialLines(usa)
proj4string(usa) <- '+proj=longlat +datum=NAD83'
usa <- spTransform(usa, CRS(projection(s)))


p.1 <- levelplot(s, scales=list(draw=FALSE), par.settings=viridisTheme(), maxpixels=1e6) + layer(sp.lines(usa, col='black'))

# p.2 <- levelplot(s.thresh, scales=list(draw=FALSE), par.settings=viridisTheme(), maxpixels=1e6) + layer(sp.lines(usa, col='black'))

# most likely layer, by pixel
# return index to ML layer
most.likely.layer <- function(i, ...) {
  
  # this will return an empty vector when all NA
  i.max <- which.max(i)
  
  # pad with NA
  if(length(i.max) < 1)
    i.max <- NA
  
  return(i.max)
}


m <- stackApply(s, indices = rep(1, times=nlayers(s)), fun = most.likely.layer)


m <- ratify(m)
rat <- levels(m)[[1]]
rat$pmkind <- names(s)
levels(m) <- rat

p.2 <- levelplot(m, att='pmkind', scales=list(draw=FALSE), par.settings=viridisTheme(), maxpixels=1e6)


png(file='pmkind-pct-of-grid-cell.png', width=1200, height=1000, type='cairo', antialias = 'subpixel', res=100)
print(p.1)
dev.off()

png(file='pmkind-most-likely.png', width=1200, height=1000, type='cairo', antialias = 'subpixel', res=100)
print(p.2)
dev.off()


