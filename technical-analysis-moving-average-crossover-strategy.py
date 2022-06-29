#Libraries
import numpy as np
import pandas as pd
import datetime as dt
import pandas_datareader.data as pdr
import matplotlib.pyplot as plt

#Set style
plt.style.use('dark_background')

#Set data frame
ticker=str(input('Enter ticker: '))
#Example:
#Enter ticker: WELL
print(ticker)

start_year=int(input('Enter start year: '))
start_month=int(input('Enter start month: '))
start_day=int(input('Enter start day: '))
#Example:
#Enter start year: 2015
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

#SMA fast
window_fast=int(input('Enter fast window: '))
#Example:
#Enter fast window: 50
sma_fast_index='SMA '+str(window_fast)
df2[sma_fast_index]=df2[ticker].rolling(window=window_fast).mean()
print(df2[sma_fast_index])
print(df2)

#SMA slow
window_slow=int(input('Enter slow window: '))
#Example:
#Enter slow window: 200
sma_slow_index='SMA '+str(window_slow)
df2[sma_slow_index]=df2[str(ticker)].rolling(window=window_slow).mean()
print(df2[sma_slow_index])
print(df2)

#Plot SMA
plt.figure(figsize=(12.5,4.5))
plt.plot(df2[sma_fast_index],label=sma_fast_index,color='yellow',linestyle='--')
plt.plot(df2[sma_slow_index],label=sma_slow_index,color='purple',linestyle='--')
plt.title('Moving Average')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()

#Plot moving average crossover strategy (without signal)
plt.figure(figsize=(12.5,4.5))
plt.plot(df2[ticker],label=ticker,color='gray',alpha=.6)
plt.plot(df2[sma_fast_index],label=sma_fast_index,color='yellow',linestyle='--')
plt.plot(df2[sma_slow_index],label=sma_slow_index,color='purple',linestyle='--')
plt.title('Moving Average Crossover')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()

#Buy sell signal
def buy_sell(df2):
    sig_price_buy=[]
    sig_price_sell=[]
    signal=-1

    for i in range(len(df2)):
        if df2[sma_fast_index][i]>df2[sma_slow_index][i]:
            if signal!=1:
                sig_price_buy.append(df2[ticker][i])
                sig_price_sell.append(np.nan)
                signal=1
            else:
                sig_price_buy.append(np.nan)
                sig_price_sell.append(np.nan)
        elif df2[sma_fast_index][i]<df2[sma_slow_index][i]:
            if signal!=0:
                sig_price_buy.append(np.nan)
                sig_price_sell.append(df2[ticker][i])
                signal=0
            else:
                sig_price_buy.append(np.nan)
                sig_price_sell.append(np.nan)
        else:
            sig_price_buy.append(np.nan)
            sig_price_sell.append(np.nan)
    return(sig_price_buy,sig_price_sell)
buy_sell=buy_sell(df2)
df2['Buy Signal Price']=buy_sell[0]
df2['Sell Signal Price']=buy_sell[1]
print(df2)

#Plot moving average crossover strategy (with signal)
plt.figure(figsize=(12.5,4.5))
plt.plot(df2[str(ticker)],label=ticker,color='gray',alpha=.6)
plt.plot(df2[sma_fast_index],label=sma_fast_index,color='yellow',linestyle='--')
plt.plot(df2[sma_slow_index],label=sma_slow_index,color='purple',linestyle='--')
plt.scatter(df2.index,df2['Buy Signal Price'],label='Buy',marker='^',color='green')
plt.scatter(df2.index,df2['Sell Signal Price'],label='Sell',marker='v',color='red')
plt.title('Moving Average Crossover')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()