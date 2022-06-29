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

#SMA signal
price4<-Cl(AMZN)
View(price4)

r<-price4/Lag(price4)-1 #Daily return
View(r)

signal4<-c(0)

#SMA
window<-as.integer(readline(prompt='Enter window: '))
#Example:
#Enter window: 15
SMA2<-round(SMA(price4,window),3)
View(SMA2)

for (i in window:length(price4)){
  if (price4[i]>SMA2[i]){
    signal4[i]<-1}
  else
    signal4[i]<-0
}
signal4

signal4<-reclass(signal4,SMA2)
View(signal4)

SMA2<-cbind(price4,SMA2,signal4)
colnames(SMA2)<-c('price4','SMA2','signal4')
View(SMA2)

#Plot SMA support and resistance strategy
candleChart(AMZN,from=start,to=Sys.Date())
addSMA(n=window,col='red')
addTA(signal4,type='S',col='yellow')

#Backtesting
trade4<-Lag(signal4,1)
r4<-r*trade4
View(r4)

names(r4)<-'SMA Support and Resistance'
charts.PerformanceSummary(r4)
table.Stats(r4)

#Filter Rule Vs SMA crossover Vs SMA support and resistance
r5<-cbind(r3,r4) #Run the previous week code
charts.PerformanceSummary(r5,main='Filter Rule Vs SMA Crossover Vs SMA Support and Resistance')
table.Stats(r5)