library(latticeExtra)

# compute on SoilWeb via:
# soilweb-acreage-by-pmkind.sh

x <- read.table('raw-stats/pmkind-stats.txt.gz', header = FALSE, stringsAsFactors = FALSE, sep='|')
names(x) <- c('pmkind', 'area_ac', 'n_polygons')

idx <- order(x$area_ac, decreasing = TRUE)
x$pmkind <- factor(x$pmkind, levels=x$pmkind[rev(idx)])
x <- x[idx,]
x$area_cumulative_proportion <- cumsum(x$area_ac) / sum(x$area_ac)

head(x)


write.csv(x, file='summaries/fy2019-ssurgo-pmkind-area.csv', row.names = FALSE)


png(file='summaries/pmkind-top-30-area.png', width=900, height=700, res=120, type='cairo', antialias = 'subpixel')

dotplot(pmkind ~ area_ac, data=x[1:30, ], cex=1,
        par.settings=list(dot.symbol=list(pch=16, col='royalblue')),
        xlab='Approximate Area (ac)', main='Top 30 Parent Material Kind\nFY2019 SSURGO',
        sub=list('major components / RV pmkind / no misc. area components', cex=0.85, font=3),
        scales=list(cex=0.85, x=list(log=10)), xscale.components=xscale.components.logpower
)

dev.off()


png(file='summaries/pmkind-top-30-proportion.png', width=900, height=700, res=120, type='cairo', antialias = 'subpixel')

dotplot(pmkind ~ area_cumulative_proportion, data=x[1:30, ], cex=1,
        par.settings=list(dot.symbol=list(pch=16, col='royalblue')),
        xlab='Cumulative Proportion of Area', main='Top 30 Parent Material Kind\nFY2019 SSURGO',
        sub=list('major components / RV pmkind / no misc. area components', cex=0.85, font=3),
        scales=list(cex=0.85)
)

dev.off()


## pmorigin

x <- read.table('raw-stats/pmorigin-stats.txt.gz', header = FALSE, stringsAsFactors = FALSE, sep='|')
names(x) <- c('pmorigin', 'area_ac', 'n_polygons')


idx <- order(x$area_ac, decreasing = TRUE)
x$pmorigin <- factor(x$pmorigin, levels=x$pmorigin[rev(idx)])
x <- x[idx,]
x$area_cumulative_proportion <- cumsum(x$area_ac) / sum(x$area_ac)

head(x)


write.csv(x, file='summaries/fy2019-ssurgo-pmorigin-area.csv', row.names = FALSE)


png(file='summaries/pmorigin-top-30-area.png', width=900, height=700, res=120, type='cairo', antialias = 'subpixel')

dotplot(pmorigin ~ area_ac, data=x[1:30, ], cex=1,
        par.settings=list(dot.symbol=list(pch=16, col='royalblue')),
        xlab='Approximate Area (ac)', main='Top 30 Parent Material Origin\nFY2019 SSURGO',
        sub=list('major components / RV pmkind / no misc. area components', cex=0.85, font=3),
        scales=list(cex=0.85, x=list(log=10)), xscale.components=xscale.components.logpower
)

dev.off()


png(file='summaries/pmorigin-top-30-proportion.png', width=900, height=700, res=120, type='cairo', antialias = 'subpixel')

dotplot(pmorigin ~ area_cumulative_proportion, data=x[1:30, ], cex=1,
        par.settings=list(dot.symbol=list(pch=16, col='royalblue')),
        xlab='Cumulative Proportion of Area', main='Top 30 Parent Origin\nFY2019 SSURGO',
        sub=list('major components / RV pmkind / no misc. area components', cex=0.85, font=3),
        scales=list(cex=0.85)
)

dev.off()

