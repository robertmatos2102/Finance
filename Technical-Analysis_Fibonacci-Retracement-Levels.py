#Libraries
import numpy as np
import pandas as pd
import datetime as dt
import pandas_datareader.data as pdr
import matplotlib.pyplot as plt

#Set style
plt.style.use('dark_background')

#set data
ticker=str(input('Enter ticker: '))
#Example:
#Enter ticker: BTC-USD
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

#Fibonacci retracement levels

#Fibonacci ratios: .236, .382, .618
#Non Fibonacci ratio: .5

max_level=df1['Close'].max()
print(max_level)
min_level=df1['Close'].min()
print(min_level)
difference=max_level-min_level
print(difference)
first_level=max_level-difference*.236
print(first_level)
second_level=max_level-difference*.382
print(second_level)
third_level=max_level-difference*.5
print(third_level)
fourth_level=max_level-difference*.618
print(fourth_level)

#Plot Fibonacci retracement levels
plt.figure(figsize=(12.5,4.5))
plt.plot(df1['Close'],label=ticker,color='gray')
plt.axhline(max_level,linestyle='--',alpha=.6,color='red')
plt.axhline(first_level,linestyle='--',alpha=.6,color='orange')
plt.axhline(second_level,linestyle='--',alpha=.6,color='yellow')
plt.axhline(third_level,linestyle='--',alpha=.6,color='skyblue')
plt.axhline(fourth_level,linestyle='--',alpha=.6,color='blue')
plt.axhline(min_level,linestyle='--',alpha=.6,color='green')
plt.title('Fibonacci Retracement Levels')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()