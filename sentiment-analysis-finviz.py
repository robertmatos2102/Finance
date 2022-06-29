#Libraries
import pandas as pd
import matplotlib.pyplot as plt
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from nltk.sentiment.vader import SentimentIntensityAnalyzer

#Set style
plt.style.use('dark_background')

#Get URL
finviz_url='https://finviz.com/quote.ashx?t='

#Stocks to compare
n=int(input('Enter number of tickers: '))
tickers=list(map(str,input('Enter tickers: ').strip().split()))[:n]
print(tickers)
#Example:
#Enter number of tickers: 3
#Enter tickers: NVDA AMD QCOM

#Get table rows
news_tables={}
for ticker in tickers:
    url=finviz_url+ticker
    request=Request(url=url,headers={'user-agent':'my-app'})
    response=urlopen(request)
    html=BeautifulSoup(response,'html')
    news_table=html.find(id='news-table')
    news_tables[ticker]=news_table
print(news_tables)

#Get headlines
parsed_data=[]
for ticker, news_table in news_tables.items():
    for row in news_table.findAll('tr'):
        title=row.a.text
        date_data=row.td.text.split(' ')
        if len(date_data)==1:
            time=date_data[0]
        else:
            date=date_data[0]
            time=date_data[1]
        parsed_data.append([ticker,date,time,title])
print(parsed_data)

#Set data frame
df1=pd.DataFrame(parsed_data,columns=['ticker','date','time','title'])
print(df1)

#Sentiment analysis
vader=SentimentIntensityAnalyzer()
f=lambda title: vader.polarity_scores(title)['compound']
df1['compound']=df1['title'].apply(f)
df1['date']=pd.to_datetime(df1.date).dt.date
print(df1)

#Group data
df2=df1.groupby(['ticker','date']).mean()
print(df2)
df2=df2.unstack()
print(df2)
df2=df2.xs('compound',axis='columns').transpose()
print(df2)

#Plot
df2.plot(kind='bar')
plt.title('Sentiment Analysis')
plt.xlabel('Date')
plt.ylabel('Sentiment')
plt.legend(loc='upper left')
plt.show()