#Libraries
library(quantmod)
library(timeSeries) 
library(PortfolioAnalytics)
library(fPortfolio)
library(PerformanceAnalytics)

#Set asset data
start<-'2019-01-01'  

tickers<-c('AMZN','EBAY',
           'BABA','PYPL',
           'MGLU3.SA','EVTC',
           'TTEC','CIEL3.SA',
           'RKUNY','AMER3.SA',
           'MELI','GPN') #Industry: internet retail, credit services, software infrastructure and information technology

portfolio_prices<-NULL
for(i in tickers){
  portfolio_prices<-cbind(portfolio_prices,
                          getSymbols(i,
                                     from=start,
                                     to=Sys.Date(),
                                     do.cache=FALSE,
                                     auto.assign=FALSE)[,4])
}

colnames(portfolio_prices)<-tickers
portfolio_prices<-na.omit(portfolio_prices)
portfolio_prices

portfolio_returns<-na.omit(ROC(portfolio_prices))
portfolio_returns

#Set benchmark data
benchmark_prices<-getSymbols('^GSPC',
                             from=start,
                             to=Sys.Date(),
                             do.cache=FALSE,
                             auto.assign=FALSE)[,4]

colnames(benchmark_prices)<-'Benchmark'
benchmark_prices<-na.omit(benchmark_prices)
benchmark_prices

benchmark_returns<-na.omit(ROC(benchmark_prices))
benchmark_returns

#Statistics
summary(portfolio_returns) #Basic statistics for asset returns

summary(benchmark_returns) #Basic statistics for benchmark returns

basicStats(portfolio_returns) #More statistical measures for asset returns
basicStats(portfolio_returns)[c('Mean',
                                'Stdev',
                                'Variance'),] 

basicStats(benchmark_returns) #More statistical measures for benchmark returns
basicStats(benchmark_returns)[c('Mean',
                                'Stdev',
                                'Variance'),] 

#Plot prices
plot.new()
par(mfrow=c(3,4))
par(mar=c(3,3,3,3))
for(i in tickers){
  seriesPlot(as.timeSeries(portfolio_prices),
             grid=FALSE)[i]
}

#Plot returns
plot.new()
par(mfrow=c(3,4))
par(mar=c(3,3,3,3))
for(i in tickers){
  seriesPlot(as.timeSeries(portfolio_returns),
             grid=FALSE)[i]
}

#Portfolios
#Minstdv portfolio
  minstdv_portfolio<-portfolio.spec(tickers)
  minstdv_portfolio<-add.constraint(minstdv_portfolio,type='weight_sum',
                        min_sum=1,
                        max_sum=1)
  minstdv_portfolio<-add.constraint(minstdv_portfolio,type='transaction cost',
                                        ptc=.01)
  minstdv_portfolio<-add.constraint(minstdv_portfolio,type='box',
                        min=0,
                        max=1.)      
  minstdv_portfolio<-add.objective(minstdv_portfolio,type='risk',
                       name='StdDev')
  minstdv_portfolio

#Maxmean portfolio
  maxmean_portfolio<-portfolio.spec(tickers)
  maxmean_portfolio<-add.constraint(maxmean_portfolio,type='weight_sum',
                              min_sum=1,
                              max_sum=1)   
  maxmean_portfolio<-add.constraint(maxmean_portfolio,type='transaction cost',
                                        ptc=.01)
  maxmean_portfolio<-add.constraint(maxmean_portfolio,type='box',
                              min=0,
                              max=1.)      
  maxmean_portfolio<-add.objective(maxmean_portfolio,type='return',
                             name='mean')
  maxmean_portfolio
  
#Maxmeanstdv portfolio
  maxmeanstdv_portfolio<-portfolio.spec(tickers)
  maxmeanstdv_portfolio<-add.constraint(maxmeanstdv_portfolio,type='weight_sum',
                          min_sum=1,
                          max_sum=1)  
  maxmeanstdv_portfolio<-add.constraint(maxmeanstdv_portfolio,type='transaction cost',
                                        ptc=.01)
  maxmeanstdv_portfolio<-add.constraint(maxmeanstdv_portfolio,type='box',
                          min=0,
                          max=1.)     
  maxmeanstdv_portfolio<-add.objective(maxmeanstdv_portfolio,type='return',
                       name='mean')
  maxmeanstdv_portfolio<-add.objective(maxmeanstdv_portfolio,type='risk',
                       name='StdDev')
  maxmeanstdv_portfolio
  
#Efficient frontier
optimal_portfolio<-optimize.portfolio(portfolio_returns,
                            maxmeanstdv_portfolio,
                            optimize_method='ROI', #Mean variance optimization
                            trace='TRUE')
optimal_portfolio

efficient_frontier<-extractEfficientFrontier(optimal_portfolio,
                             match.col='StdDev',
                             n.portfolios=1000,
                             risk_aversion=NULL)
efficient_frontier

plot.new()
par(mfrow=c(1,1))
chart.EfficientFrontier(efficient_frontier,
                        match.col='StdDev') #1

chart.RiskReward(optimal_portfolio,
                 chart.assets=TRUE) #2

#Optimal weights
optimal_weights<-extractWeights(optimal_portfolio)
optimal_weights

chart.Weights(optimal_portfolio)
chart.EF.Weights(optimal_portfolio)

#Optimal returns
optimal_portfolio_returns<-na.omit(Return.portfolio(portfolio_returns,
                                                    optimal_weights))
optimal_portfolio_returns

#Analyzing returns
table.CAPM(portfolio_returns,
           benchmark_returns) #CAPM for asset returns

table.CAPM(optimal_portfolio_returns,
           benchmark_returns) #CAPM for optimal portfolio returns

plot.new()
par(mfrow=c(1,1))
chart.Boxplot(portfolio_returns,
              main='Portfolio Returns',
              plot.engine='plotly') #Box and whiskers plot to compare distributions

plot.new()
par(mfrow=c(1,1))
charts.PerformanceSummary(portfolio_returns,
                          main='Portfolio Returns',
                          plot.engine='plotly')

table.AnnualizedReturns(portfolio_returns,
                        scale=252) #Annualized data for asset returns

table.AnnualizedReturns(optimal_portfolio_returns,
                        scale=252) #Annualized data for optimal portfolio returns

#Analyzing risk
cor_matrix<-cor(portfolio_returns)
cor_matrix #Correlation matrix
write.csv(cor_matrix,
          file='cor_matrix.csv')

dev.off()
plot.new()
par(mfrow=c(1,1))
cor_plot<-assetsCorImagePlot(portfolio_returns)
cor_plot #Correlation plot

plot.new()
par(mfrow=c(1,1))
cor_test_plot<-assetsCorTestPlot(portfolio_returns)
cor_test_plot #Pairwise correlation test plot

var_matrix<-var(portfolio_returns)
var_matrix #Variance matrix
write.csv(var_matrix,
          file='var_matrix.csv')

cov_matrix<-cov(portfolio_returns)
cov_matrix #Covariance matrix
write.csv(cov_matrix,
          file='cov_matrix.csv')

varRisk(portfolio_returns,
        optimal_weights,
        alpha=.05) #Value at Risk

cvarRisk(portfolio_returns,
         optimal_weights,
         alpha=.05) #Conditional Value at Risk

table.DownsideRisk(portfolio_returns) #Downside risk for asset returns

table.DownsideRisk(optimal_portfolio_returns) #Downside risk for optimal portfolio returns

SystematicRisk(portfolio_returns,
               benchmark_returns) #Systematic risk for asset returns

SystematicRisk(optimal_portfolio_returns,
               benchmark_returns) #Systematic risk for optimal portfolio returns

TrackingError(portfolio_returns,
              benchmark_returns) #Tracking error for asset returns

TrackingError(optimal_portfolio_returns,
              benchmark_returns) #Tracking error for optimal portfolio returns

#Backtesting
#Optimal portfolio
  plot.new()
  par(mfrow=c(1,1))
  charts.PerformanceSummary(optimal_portfolio_returns,
                            main='Optimal Portfolio',
                            plot.engine='plotly')
  
  table.Stats(optimal_portfolio_returns) #Statistics for optimal portfolio returns
  
  table.CalendarReturns(optimal_portfolio_returns) #Monthly return for optimal portfolio returns
  
  dev.off()
  plot.new()
  par(mfrow=c(2,2))
  par(mar=c(4,4,4,4))
  chart.Histogram(optimal_portfolio_returns,
                  main='Plain',
                  methods=NULL)
  chart.Histogram(optimal_portfolio_returns,
                  main='Density',
                  methods=c('add.density','add.normal'),
                  breaks=50)
  chart.Histogram(optimal_portfolio_returns,
                  main='Skew and Kurt',
                  methods=c('add.centered','add.rug'))
  chart.Histogram(optimal_portfolio_returns,
                  main='Risk Measures',
                  methods='add.risk') #Distribution plots for optimal portfolio returns

#Rebalanced portfolio
  rebalanced_portfolio<-optimize.portfolio.rebalancing(portfolio_returns,
                                                       maxmeanstdv_portfolio,
                                                       search_size=1000,
                                                       optimize_method='random',
                                                       rp=random_portfolios(maxmeanstdv_portfolio,1000,'sample'),
                                                       rebalance_on='months',
                                                       training_period=2,
                                                       rolling_window=1)
  rebalanced_portfolio
  
  rebalanced_weights<-extractWeights(rebalanced_portfolio)
  rebalanced_weights

  chart.Weights(rebalanced_portfolio)

  rebalanced_portfolio_returns<-na.omit(Return.portfolio(portfolio_returns,rebalanced_weights))
  rebalanced_portfolio_returns
  
  plot.new()
  par(mfrow=c(1,1))
  charts.PerformanceSummary(rebalanced_portfolio_returns,
                            main='Rebalanced Portfolio',
                            plot.engine='plotly')
  
  table.Stats(rebalanced_portfolio_returns) #Statistics for rebalanced portfolio returns
  
  table.CalendarReturns(rebalanced_portfolio_returns) #Monthly return for rebalanced portfolio returns
  
  dev.off()
  plot.new()
  par(mfrow=c(2,2))
  par(mar=c(4,4,4,4))
  chart.Histogram(rebalanced_portfolio_returns,
                  main='Plain',
                  methods=NULL)
  chart.Histogram(rebalanced_portfolio_returns,
                  main='Density',
                  methods=c('add.density','add.normal'),
                  breaks=50)
  chart.Histogram(rebalanced_portfolio_returns,
                  main='Skew and Kurt',
                  methods=c('add.centered','add.rug'))
  chart.Histogram(rebalanced_portfolio_returns,
                  main='Risk Measures',
                  methods='add.risk') #Distribution plots for rebalanced portfolio returns
  
#Benchmark
  plot.new()
  par(mfrow=c(1,1))
  charts.PerformanceSummary(benchmark_returns,
                            main='Benchmark',
                            plot.engine='plotly') 
  
  table.Stats(benchmark_returns) #Statistics for benchmark returns
  
  table.CalendarReturns(benchmark_returns) #Monthly return for benchmark returns
  
  dev.off()
  plot.new()
  par(mfrow=c(2,2))
  par(mar=c(4,4,4,4))
  chart.Histogram(benchmark_returns,
                  main='Plain',
                  methods=NULL)
  chart.Histogram(benchmark_returns,
                  main='Density',
                  methods=c('add.density','add.normal'),
                  breaks=50)
  chart.Histogram(benchmark_returns,
                  main='Skew and Kurt',
                  methods=c('add.centered','add.rug'))
  chart.Histogram(benchmark_returns,
                  main='Risk Measures',
                  methods='add.risk') #Distribution plots for benchmark returns
  
#Overall
  overall<-cbind(optimal_portfolio_returns,
                 rebalanced_portfolio_returns,
                 benchmark_returns)
  colnames(overall)<-c('Optimal Portfolio','Rebalanced Portfolio','Benchmark')
  overall<-na.omit(overall)
  overall
  
  plot.new()
  par(mfrow=c(1,1))
  charts.PerformanceSummary(overall,
                            main='Optimal Portfolio Vs Rebalanced Portfolio Vs Benchmark Vs Benchmark',
                            plot.engine='plotly')
  
  table.Stats(overall) #Statistics for optimal portfolio, rebalanced portfolio and benchmark returns