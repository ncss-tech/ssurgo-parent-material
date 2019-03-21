library(plyr)
library(stringr)

x <- read.csv('fy2018-pmkind-by-series.csv.gz', stringsAsFactors = FALSE)

head(x)

x$series <- str_to_title(x$series)

pmkind <- ddply(x, 'series', .progress='text', .fun=function(i) {
  
  # get most common if there are any
  return(i$q_param[1])
})

sort(table(pmkind$V1), decreasing = TRUE)[1:10]


x <- read.csv('fy2018-pmorigin-by-series.csv.gz', stringsAsFactors = FALSE)

head(x)

x$series <- str_to_title(x$series)

pmorigin <- ddply(x, 'series', .progress='text', .fun=function(i) {
  
  # get most common if there are any
  return(i$q_param[1])
})


head(pmkind)
head(pmorigin)

names(pmkind) <- c('COMPNAME', 'pmkind')
names(pmorigin) <- c('COMPNAME', 'pmorigin')

sort(table(pmkind$pmkind), decreasing = TRUE)[1:20]
sort(table(pmorigin$pmorigin), decreasing = TRUE)[1:20]


## REGEX normalization?
sort(table(pmorigin$pmorigin[grep('grani', pmorigin$pmorigin, ignore.case = TRUE)]), decreasing = TRUE)



write.csv(pmkind, file='pmkind.csv', row.names = FALSE)
write.csv(pmorigin, file='pmorigin.csv', row.names = FALSE)


