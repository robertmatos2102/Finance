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
#Enter ticker: PEAK
print(ticker)

start_year=int(input('Enter start year: '))
start_month=int(input('Enter start month: '))
start_day=int(input('Enter start day: '))
#Example:
#Enter start year: 2021
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

#MACD
short_ema_period=int(input('Enter short EMA period: '))
#Example:
#Enter short EMA period: 12
short_ema=df2[ticker].ewm(span=short_ema_period,adjust=False).mean() #Short EMA

long_ema_period=int(input('Enter long EMA period: '))
#Example:
#Enter long EMA period: 26
long_ema=df2[ticker].ewm(span=long_ema_period,adjust=False).mean() #Long EMA
macd=short_ema-long_ema #MACD
df2['MACD']=macd
print(df2['MACD'])
print(df2)

signal_period=int(input('Enter signal period: '))
#Example:
#Enter signal period: 9
signal=macd.ewm(span=signal_period,adjust=False).mean() #Signal
df2['Signal']=signal
print(df2['Signal'])
print(df2)

#Plot MACD
plt.figure(figsize=(12.5,4.5))
plt.plot(df2['MACD'],label='MACD',color='blue')
plt.plot(df2['Signal'],label='Signal',color='red')
plt.axhline(0,linestyle='--',alpha=.6,color='yellow')
plt.title('MACD & Signal')
plt.legend(loc='upper left')
plt.show()

#Plot MACD strategy (without signal)
plt.figure(figsize=(12.5,4.5))
plt.subplot(2,1,1)
plt.plot(df2[str(ticker)],label=ticker,color='gray',alpha=.6)
plt.title(ticker+' Price History')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')

plt.subplot(2,1,2)
plt.plot(df2['MACD'],label='MACD',color='blue')
plt.plot(df2['Signal'],label='Signal',color='red')
plt.axhline(0,linestyle='--',alpha=.6,color='yellow')
plt.title('MACD & Signal')
plt.legend(loc='upper left')
plt.show()

#Buy sell signal
def buy_sell(df2):
    sig_price_buy=[]
    sig_price_sell=[]
    signal=-1

    for i in range(len(df2)):
        if df2['MACD'][i]>df2['Signal'][i]:
            if signal!=1:
                sig_price_buy.append(df2[ticker][i])
                sig_price_sell.append(np.nan)
                signal=1
            else:
                sig_price_buy.append(np.nan)
                sig_price_sell.append(np.nan)
        elif df2['MACD'][i]<df2['Signal'][i]:
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

#Plot MACD strategy (with signal)
plt.figure(figsize=(12.5,4.5))
plt.subplot(2,1,1)
plt.plot(df2[str(ticker)],label=ticker,color='gray',alpha=.6)
plt.scatter(df2.index,df2['Buy Signal Price'],label='Buy',marker='^',color='green')
plt.scatter(df2.index,df2['Sell Signal Price'],label='Sell',marker='v',color='red')
plt.title(ticker+' Price History')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')

plt.subplot(2,1,2)
plt.plot(df2['MACD'],label='MACD',color='blue')
plt.plot(df2['Signal'],label='Signal',color='red')
plt.axhline(0,linestyle='--',alpha=.6,color='yellow')
plt.title('MACD & Signal')
plt.legend(loc='upper left')
plt.show()