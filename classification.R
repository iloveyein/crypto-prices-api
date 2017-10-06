
summary(pricesdfhour)

#want to lag everything except ETH prices by one day so we can use the 
#lag 1 data for each of the other coins to predict the prices of eth

eth <- pricesdfhour$ETH

ethforward1 <- c(eth[2:length(eth)], 0)

pricesdfhour$ethlag <- ethforward1

pricesdfhour <- subset(pricesdfhour, select = -eth)

pricesdfhour1 <- pricesdfhour[1:2000,]


summary(pricesdfhour1)
#now ethlag is lagged FORWARD by one, ie the value of eth column i  is actually equal to the time value of 
#of time column i + 1

#create a "direction column which indiccates if ETH went up or down for the previous day

n <- length(pricesdfhour1$ETH) 
direction <- rep(0, n)
for (i in 1:n){
  if (pricesdfhour1$ethlag[i] < pricesdfhour$ETH[i]) {
    direction[i] <- 0
  }
  else { 
    direction[i] <- 1
  }
}

