#Libraries
import numpy as np
import pandas as pd
import datetime as dt
import pandas_datareader.data as pdr
import matplotlib.pyplot as plt
import scipy.stats as sci

#Set style
plt.style.use('dark_background')

#Set data frame
ticker=str(input('Enter ticker: '))
#Example:
#Enter ticker: MELI
print(ticker)

start_year=int(input('Enter start year: '))
start_month=int(input('Enter start month: '))
start_day=int(input('Enter start day: '))
#Example:
#Enter start year: 2019
#Enter start month: 1
#Enter start day: 1

start=dt.datetime(start_year,start_month,start_day)
now=dt.datetime.now()

df1=pdr.get_data_yahoo(ticker,start,now)
print(df1)

#Plot data
plt.figure(figsize=(12.5,4.5))
plt.plot(df1['Close'],label=ticker,color='gray')
plt.title(ticker+' Price History')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()

#Set new data frame
df2=pd.DataFrame()
df2[ticker]=df1['Close']
print(df2)

#Logarithmic returns
returns=np.log(1+df2.pct_change())
print(returns)

#Plot logarithmic returns
plt.figure(figsize=(12.5,4.5))
plt.plot(returns,label=ticker,color='gray')
plt.title(ticker+' Logarithmic Returns')
plt.xlabel('Date')
plt.ylabel('Logarithmic Returns')
plt.legend(loc='upper left')
plt.show()

#Drift
u=returns.mean() #Average return
var=returns.var() #Variance
drift=u-(.5*var)
print(drift)

#Daily returns
days=int(input('Enter days to forecast: '))
trials=int(input('Enter trials: '))
#Example:
#Enter days to forecast: 30
#Enter trials: 1000

std=returns.std() #Standard deviation
Z=sci.norm.ppf(np.random.rand(days,trials)) #Volatility
daily_returns=np.exp(drift.values+std.values*Z)
print(daily_returns)

#Price for every trial
df3=pd.DataFrame()
df3=np.zeros_like(daily_returns)
df3[0]=df2.iloc[-1]
for i in range(1,days):
    df3[i]=df3[i-1]*daily_returns[i]
print(df3)

#Plot simulations
plt.figure(figsize=(12.5,4.5))
plt.plot(df3,label=ticker)
plt.title(ticker+' Monte Carlo Simulation')
plt.xlabel('Date')
plt.ylabel('Price')
plt.show()