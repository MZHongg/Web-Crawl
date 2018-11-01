
######################################################################
### quantmod 101
######################################################################

# install.packages("quantmod")
library(quantmod)

# quantmod::getSymbols 
getSymbols("DIS")
DisneystockData <-getSymbols("DIS")
DisneystockData <- get(DisneystockData)
head(DisneystockData,10) 
DisneystockData <- data.frame(DisneystockData)
DisneystockData$date <- as.Date(row.names(DisneystockData)) 
DisneystockData
View(DisneystockData)
write.csv(DisneystockData, "Disney.csv")

# view data
head(DIS)
tail(DIS)
View(DIS)
summary(DIS)

# quantmod::chartSeries
chartSeries(DIS,theme='white',TA=NULL)
write.csv(DIS, "DIS.csv")
