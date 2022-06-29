#Libraries
library(quantmod)
library(PerformanceAnalytics)

#Set data
start<-readline(prompt='Enter start date: ')
#Example:
#Enter start date: 2021-01-01
ticker<-readline(prompt='Enter ticker: ')
#Example:
#Enter ticker:AMZN
ticker<-getSymbols(ticker,from=start,to=Sys.Date(),do.cache=FALSE)

#Plot data
candleChart(AMZN,from=start,to=Sys.Date())
addSMA(n=50,col='blue')
addSMA(n=200,col='red')
addMACD(fast=12,slow=26,signal=9,type='EMA')
addRSI(n=14,maType='EMA')
addMomentum(n=14)
addBBands(n=20,sd=2)

#Filter rule signal
price1<-Cl(AMZN)
View(price1)

r<-price1/Lag(price1)-1 #Daily return
View(r)

signal1<-c(0) 

#Threshold
delta<-as.integer(readline(prompt='Enter threshold: '))
#Example:
#Enter threshold: 0.006

for (i in 2:length(price1)){
  if (r[i]>delta){
    signal1[i]<-1
  }else
    signal1[i]<-0
}
signal1

signal1<-reclass(signal1,price1) 
View(signal1)

#Plot filter rule strategy
candleChart(AMZN,from=start,to=Sys.Date())
addTA(signal1,type='S',col='yellow')

#Backtesting
trade1<-Lag(signal1,1)
r1<-r*trade1
View(r1)

names(r1)<-'Filter Rule'
charts.PerformanceSummary(r1)
table.Stats(r1)