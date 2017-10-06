#load packages (install if you dont have)
library('httr')
library('jsonlite')
library('lubridate')
library('anytime')
library('ggplot2')
library('dplyr')
options(stringsAsFactors = FALSE)

##get data

getdata <- function(url, path, parameters){
  raw.result <- GET(url = url, path = paste(path,'?',parameters, sep = ''))
  text.content <- rawToChar(raw.result$content)
  content <-fromJSON(text.content)
  content
}

##set parameters
url <- 'https://min-api.cryptocompare.com'
path <- '/data/histohour'
fsym <- 'fsym=ETH'
tsym <- 'tsym=CAD'
tsyms <- 'tsyms=CAD,USD'
limit <- 'limit=2000'
##put in all the parameters here that you want to add to the path
parameters <- paste(fsym, tsym,limit, sep = '&')



content <- getdata(url, path, parameters)
str(content$Data)
#convert unix time
content$Data$time <- anytime(content$Data$time)

dailyprice <- content$Data
#remove days with no price data(pre ethereum)
dailypriceeth <- subset(dailyprice, dailyprice$high > 0)

head(dailypriceeth$time)


###lets also get the price for some other coins
fsym <- 'fsym=BTC'
tsym <- 'tsym=CAD'
limit <- 'limit=2000'
parameters2 <- paste(fsym, tsym, limit, sep = '&')
content <- getdata(url, path, parameters2)
#convert unix time
content$Data$time <- anytime(content$Data$time)
dailypricebtc <- subset(content$Data, content$Data$high > 0)

symbols <- c('BTC','ETH','XMR', 'ETC', 'ZEC', 'DASH', 'LTC', 'DOGE', 'NXT')

alldata <- list()
for(i in 1:length(symbols)){
  fsym <- paste('fsym=', symbols[i], sep = '')
  parameters <- paste(fsym, tsym, limit, sep = '&')
  content <- getdata(url, path, parameters)
  content$Data$time <- anytime(content$Data$time)
  alldata[[i]] <-content$Data
}

str(alldata[[2]])
prices <- matrix(0, nrow = length(alldata[[1]]$close), ncol = 14)
prices[,1] <- alldata[[1]]$time  
for(i in 1:length(symbols)){
  prices[,i+1] <- alldata[[i]]$close
}
prices[,11] <- alldata[[1]]$volumefrom
prices[,12] <- alldata[[1]]$volumeto
prices[,13] <- alldata[[2]]$volumeto
prices[,14] <- alldata[[2]]$volumefrom


pricesdfhour <- as.data.frame(prices)
names(pricesdfhour) <- c('time', 'BTC','ETH','XMR', 'ETC', 'ZEC', 'DASH', 'LTC', 'DOGE', 'NXT', 'BTCVOLFROM',
                         'BTCVOLTO', 'ETHVOLTO', 'ETHVOLFROM')
pricesdfhour$time <- anytime(pricesdfhour$time)

path2 = "C://i love yein/pricesdfhour.csv"
write.csv(pricesdfhour, file = path2)
head(pricesdfhour)
