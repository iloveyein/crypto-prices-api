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
path <- '/data/histoday'
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

str(alldata[[1]])
prices <- matrix(0, nrow = length(alldata[[1]]$close), ncol = 10)
prices[,1] <- alldata[[1]]$time        
for(i in 1:length(symbols)){
  prices[,i+1] <- alldata[[i]]$close
}

pricesdf <- as.data.frame(prices)
names(pricesdf) <- c('time', 'BTC','ETH','XMR', 'ETC', 'ZEC', 'DASH', 'LTC', 'DOGE', 'NXT')
pricesdf$time <- anytime(pricesdf$time)
