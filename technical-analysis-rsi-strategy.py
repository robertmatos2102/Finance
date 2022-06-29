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
#Enter ticker: VTR
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

#RSI
delta=df2[ticker].diff(1) #First difference
print(delta)
delta=delta.dropna() #Drop nan
print(delta)

up=delta.copy()
up[up<0]=0 #Get positive gains
print(up)
down=delta.copy()
down[down>0]=0 #Get negative gains
print(down)

rsi_period=int(input('Enter RSI period: '))
#Example:
#Enter RSI period: 14

average_gain=abs(up.rolling(window=rsi_period).mean()) #Absolute average gain
average_loss=abs(down.rolling(window=rsi_period).mean()) #Absolute average loss

relative_strength=average_gain/average_loss #Relative strength
rsi=100-(100/(1+relative_strength)) #RSI
df2['RSI']=rsi
print(df2['RSI'])
print(df2)

#Plot RSI
plt.figure(figsize=(12.5,4.5))
plt.plot(df2['RSI'],color='yellow')
plt.title('RSI')
plt.show()

#Plot RSI strategy (without signal)
plt.figure(figsize=(12.5,4.5))
plt.subplot(2,1,1)
plt.plot(df2[str(ticker)],label=ticker,color='gray',alpha=.6)
plt.title(ticker+' Price History')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')

plt.subplot(2,1,2)
plt.plot(df2['RSI'],color='yellow')
plt.axhline(20,linestyle='--',alpha=.6,color='green')
plt.axhline(80,linestyle='--',alpha=.6,color='red')
plt.title('RSI')
plt.show()

#Buy sell signal
def buy_sell(df2):
    sig_price_buy=[]
    sig_price_sell=[]
    signal=-1

    for i in range(len(df2)):
        if df2['RSI'][i]<20:
            if signal!=1:
                sig_price_buy.append(df2[ticker][i])
                sig_price_sell.append(np.nan)
                signal=1
            else:
                sig_price_buy.append(np.nan)
                sig_price_sell.append(np.nan)
        elif df2['RSI'][i]>80:
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

#Plot RSI strategy (with signal)
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
plt.plot(df2['RSI'],color='yellow')
plt.axhline(20,linestyle='--',alpha=.6,color='green')
plt.axhline(80,linestyle='--',alpha=.6,color='red')
plt.title('RSI')
plt.show()