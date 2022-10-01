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

#SMA crossover signal
price2<-Cl(AMZN)
View(price2)

r<-price2/Lag(price2)-1 #Daily return
View(r)

signal2<-c(0)

#SMA fast
fast<-as.integer(readline(prompt='Enter fast window: '))
#Example:
#Enter fast window: 5
SMA_fast<-round(SMA(price2,fast),3)
View(SMA_fast)

#SMA slow 
slow<-as.integer(readline(prompt='Enter slow window: '))
#Example:
#Enter slow window: 8
SMA_slow<-round(SMA(price2,slow),3)
View(SMA_slow)

for (i in slow:length(price2)){
  if (SMA_fast[i]>SMA_slow[i]){
    signal2[i]<-1}
  else
    signal2[i]<-0
}
signal2

signal2<-reclass(signal2,SMA_fast,SMA_slow)
View(signal2)

SMA<-cbind(price2,SMA_fast,SMA_slow,signal2)
colnames(SMA)<-c('price2','SMA fast','SMA slow','signal2')
View(SMA)

#Plot SMA crossover strategy
candleChart(AMZN,from=start,to=Sys.Date())
addSMA(n=fast,col='red')
addSMA(n=slow,col='blue')
addTA(signal2,type='S',col='yellow')

#Backtesting
trade2<-Lag(signal2,1)
r2<-r*trade2
View(r2)

names(r2)<-'SMA Crossover'
charts.PerformanceSummary(r2)
table.Stats(r2)

#Filter Rule Vs SMA crossover
r3<-cbind(r1,r2) #Run the previous week code (backtesting_technical_analysis_filter_rule_strategy.R)
charts.PerformanceSummary(r3,main='Filter Rule Vs SMA Crossover')
table.Stats(r3)