#Libraries
import yfinance as yf
import pandas as pd
import numpy as np

#Stocks to compare
n=int(input('Enter number of tickers: '))
tickers=list(map(str,input('Enter tickers: ').strip().split()))[:n]
print(tickers)
#Example:
#Enter number of tickers: 3
#Enter tickers: AVB MAA EQR

#Get info
infos=[]
for i in tickers:
  infos.append(yf.Ticker(i).info)

#Define fundamentals
fundamentals=['previousClose','targetMeanPrice']

#Set data frame
df1=pd.DataFrame(infos)
df1=df1.set_index('symbol')
df1=df1[df1.columns[df1.columns.isin(fundamentals)]]
print(df1)

#Upside/ downside percentage
df1['Upside/ downside percentage']=(df1['targetMeanPrice']/df1['previousClose']-1)*100
df1['Upside/ downside percentage']
print(df1)

#Upside/ downside label
df1['Upside/ downside']=np.where(df1['Upside/ downside percentage']>1.0,'upside','downside')
print(df1)