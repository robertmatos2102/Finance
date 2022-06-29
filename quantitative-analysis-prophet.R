#Libraries
library(quantmod)
library(prophet)
library(dplyr)

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

#Model
df<-Cl(ARNA)
df<-as_data_frame(df,rownames='ds')
colnames(df)<-c('ds','y')
m<-prophet(df)

#Forecast
future<-make_future_dataframe(m,periods=30)
forecast<-predict(m,future)
tail(forecast[c('ds','yhat','yhat_upper','yhat_lower')])

#Plot forecast
plot(m,forecast)
dyplot.prophet(m,forecast)

#Plot trend and seasonality
prophet_plot_components(m,forecast)

#Plot change points
plot(m,forecast)+add_changepoints_to_plot(m)

#Plot uncertain seasonality
m<-prophet(df,mcmc.samples=100)
forecast<-predict(m,future)
prophet_plot_components(m,forecast)