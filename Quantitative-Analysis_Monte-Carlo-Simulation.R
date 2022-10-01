#Libraries
library(quantmod)

#Set data
start<-readline(prompt='Enter start date: ')
#Example:
#Enter start date: 2019-01-01
ticker<-readline(prompt='Enter ticker: ')
#Example:
#Enter ticker:ARNA
ticker<-getSymbols(ticker,from=start,to=Sys.Date(),do.cache=FALSE)

#Plot data
candleChart(ARNA,from=start,to=Sys.Date())
addSMA(n=50,col='blue')
addSMA(n=200,col='red')
addMACD(fast=12,slow=26,signal=9,type='EMA')
addRSI(n=14,maType='EMA')
addMomentum(n=14)
addBBands(n=20,sd=2)

#Drift
price<-Cl(ARNA)
price

r<-price/Lag(price)-1 #Daily return
r<-na.omit(r)
r

average_return<-mean(r) #Average return
average_return

variance<-var(r) #Variance
variance

drift<-average_return-.5*variance #Drift
drift

#Random variable
stdev<-sd(r) #Standard deviation
stdev

#Simulation
T<-365   #Periods                                  
s<-1000 #Number of simulations    

walks<-matrix(nrow=T,ncol=s)
walks
walks[1,]<-last(price)
walks[1,]

for (s in 1:s){
  for (t in 2:T){
    walks[t,s]<-walks[t-1,s]*exp(drift+rnorm(1,0,1)*stdev)
  }
}
walks

#Plot simulation
color<-rainbow(t)
ts.plot(price,col=color)
ts.plot(walks,col=color)

#Plot histogram
walks_last<-walks[T,]
walks_last
hist(walks_last)

#Some statistics
mean_walks_last<-mean(walks_last)
mean_walks_last

sd_walks_last<-sd(walks_last)
sd_walks_last

ci_walks_last<-mean(walks_last)+c(-1,1)*qnorm(.975)*sd(walks_last) #Confidence interval
ci_walks_last

ordered_walks_last<-walks_last[order(walks_last,decreasing=T)] #Order
ordered_walks_last

walks_last[0.95*s] #5% lower percentile
sum(walks_last<walks_last[0.95*s])/s