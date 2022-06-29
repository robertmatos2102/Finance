#Libraries
import quandl
import numpy as np
import pandas as pd
import datetime as dt
from mpl_toolkits.mplot3d import axes3d
import matplotlib.dates as dates
import matplotlib.ticker as ticker
import matplotlib.pyplot as plt

#Set format date
def format_date(x,pos=None):
    return dates.num2date(x).strftime('%Y-%m-%d')

#Set style
plt.style.use('dark_background')

#Set data frame
bond=str(input('Enter bond name: '))
#Example:
#Enter bond name: USTREASURY/YIELD

start=str(input('Enter start: '))
#Example:
#Enter start: 2017-01-31
now=dt.datetime.now()

df=quandl.get(bond,returns='numpy',trim_start=start,trim_end=now)
print(df)

#Get headers
print(df.dtype.names)

#Convert headers
header=[]
for name in df.dtype.names[1:]:
    maturity=float(name.split(" ")[0])
    if name.split(" ")[1]=='Mo':
        maturity=maturity/12
    header.append(maturity)
print(header)

#Convert dates to numeric
x_df=[]
for dt in df.Date:
    dt_num=dates.date2num(dt)
    x_df.append([dt_num for i in range(len(df.dtype.names)-1)])
print(x_df)

#Extract yields
y_df=[]
z_df=[]
for row in df:
    y_df.append(header)
    z_df.append(list(row.tolist()[1:]))
print(y_df)
print(z_df)

#Build arrays
x=np.array(x_df,dtype='f')
print(x)
y=np.array(y_df,dtype='f')
print(y)
z=np.array(z_df,dtype='f')
print(z)

#Plot 3D yield curve
fig=plt.figure(figsize=(12.5,4.5))
ax=fig.add_subplot(111,projection='3d')
ax.plot_surface(x,y,z,rstride=10,cstride=1,cmap='Blues',vmin=np.nanmin(z),vmax=np.nanmax(z))
ax.set_title(bond)
ax.set_ylabel('Maturity')
ax.set_zlabel('Yield')

def format_date(x,pos=None):
     return dates.num2date(x).strftime('%Y-%m-%d')

ax.w_xaxis.set_major_formatter(ticker.FuncFormatter(format_date))
for tl in ax.w_xaxis.get_ticklabels():
    tl.set_ha('right')
    tl.set_rotation(15)
plt.show()
