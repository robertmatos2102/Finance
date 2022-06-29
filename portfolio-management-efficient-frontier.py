#Libraries
import numpy as np
import pandas as pd
import datetime as dt
import pandas_datareader.data as pdr
import matplotlib.pyplot as plt

#Set style
plt.style.use('dark_background')

#Set data frame
ticker_1=str(input('Enter ticker 1: '))
ticker_2=str(input('Enter ticker 2: '))
ticker_3=str(input('Enter ticker 3: '))
ticker_4=str(input('Enter ticker 4: '))
print(ticker_1,ticker_2,ticker_3,ticker_4)
#Example:
#Enter ticker 1: 005930.KS
#Enter ticker 2: 051910.KS
#Enter ticker 3: 005380.KS
#Enter ticker 4: 035720.KS

start_year=int(input('Enter start year: '))
start_month=int(input('Enter start month: '))
start_day=int(input('Enter start day: '))
#Example:
#Enter start year: 2019
#Enter start month: 1
#Enter start day: 1

start=dt.datetime(start_year,start_month,start_day)
now=dt.datetime.now()

df1=pdr.get_data_yahoo(ticker_1,start,now)
print(df1)
df2=pdr.get_data_yahoo(ticker_2,start,now)
print(df2)
df3=pdr.get_data_yahoo(ticker_3,start,now)
print(df3)
df4=pdr.get_data_yahoo(ticker_4,start,now)
print(df4)

#Plot data
plt.figure(figsize=(12.5,4.5))
plt.plot(df1['Close'],label=ticker_1,color='red')
plt.plot(df2['Close'],label=ticker_2,color='blue')
plt.plot(df3['Close'],label=ticker_3,color='green')
plt.plot(df4['Close'],label=ticker_4,color='yellow')
plt.title('Price History')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend(loc='upper left')
plt.show()

#Set new data frame
df5=pd.DataFrame()
df5[ticker_1]=df1['Close']
df5[ticker_2]=df2['Close']
df5[ticker_3]=df3['Close']
df5[ticker_4]=df4['Close']
print(df5)

#Get returns
returns=np.log(df5/df5.shift(1)) #Logarithmic returns
returns=returns.dropna(axis=0)
print(returns)

#Portfolio
n_portfolios=int(1e4) #Number of portfolios
print(n_portfolios)
n_securities=int(len(returns.columns)) #Number of securities
print(n_securities)
weight=np.zeros((n_portfolios,n_securities)) #Weight
print(weight)

portfolio_return=np.zeros(n_portfolios) #Portfolio return
portfolio_std=np.zeros(n_portfolios) #Portfolio standard deviation
portfolio_sharpe=np.zeros(n_portfolios) #Portfolio Sharpe ratio
rf=.025 #Risk free rate

for i in range(n_portfolios):
    w=np.array(np.random.random(n_securities)) #Random weights in the half-open interval [0.0, 1.0)
    w=w/np.sum(w) #Sum up to 1
    weight[i,:]=w
    portfolio_return[i]=np.sum((returns.mean()*w*252)) #Expected return
    portfolio_std[i]=np.sqrt(np.dot(w.T,np.dot(returns.cov()*252,w))) #Expected volatility
    portfolio_sharpe[i]=(portfolio_return[i]-rf)/portfolio_std[i] #Sharpe ratio

print(portfolio_return)
print(portfolio_std)
print(portfolio_sharpe)

#Sharpe ratio
max_sharpe=portfolio_sharpe.max() #Max Sharpe ratio
max_sharpe_loc=portfolio_sharpe.argmax() #Sharpe ratio location
max_sharpe_return=portfolio_return[max_sharpe_loc]
max_sharpe_std=portfolio_std[max_sharpe_loc]

#Plot efficient frontier
plt.figure(figsize=(12.5,4.5))
plt.scatter(portfolio_std,portfolio_return,c=portfolio_sharpe,cmap='viridis')
plt.scatter(max_sharpe_std,max_sharpe_return,c='red')
plt.colorbar(label='Sharpe Ratio')
plt.title('Efficient Frontier')
plt.xlabel('Expected Volatility')
plt.ylabel('Expected Return')
plt.show()
