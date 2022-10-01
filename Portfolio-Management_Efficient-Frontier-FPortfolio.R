#Libraries
library(quantmod)
library(timeSeries) 
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

#Efficient frontier
efficient_frontier<-portfolioFrontier(as.timeSeries(portfolio_returns),
                               spec=portfolioSpec(),
                               constraints='LongOnly')
efficient_frontier

plot.new()
par(mfrow=c(1,1))
plot(efficient_frontier,
     c(1,2,3,4,5,8)) #1
  #1 Plot efficient frontier (black points)
  #2 Plot minimum variance portfolio (red point)
  #3 Plot tangency portfolio (blue triangle)
  #4 Plot risk returns for each asset (diamonds)
  #5 Plot equal weights portfolio (blue square)
  #6 Plot two asset frontier (gray lines)
  #7 Plot Monte Carlo portfolio (black salt)
  #8 Plot Sharpe ratio (hollow circle)

plot.new()
par(mfrow=c(1,1))
tailoredFrontierPlot(efficient_frontier) #2

target_risk_return<-frontierPoints(efficient_frontier)
target_risk_return

plot.new()
par(mfrow=c(1,1))
frontierPlot(efficient_frontier) #3

plot.new()
par(mfrow=c(1,1))
chart.RiskReturnScatter(portfolio_returns) #4

#Portfolios
#Efficient frontier
  optimal_portfolio<-efficientPortfolio(as.timeSeries(portfolio_returns),
                                      spec=portfolioSpec(),
                                      constraints='LongOnly')
  optimal_portfolio #Returns the properties of the efficient portfolio
  
#Max ratio portfolio
  maxratio_portfolio<-maxratioPortfolio(as.timeSeries(portfolio_returns),
                                    spec=portfolioSpec(),
                                    constraints='LongOnly')
  maxratio_portfolio #Returns the portfolio with the highest return/risk ratio

#Tangency portfolio
  tan_portfolio<-tangencyPortfolio(as.timeSeries(portfolio_returns),
                               spec=portfolioSpec(),
                               constraints='LongOnly')
  tan_portfolio #Synonym of maxratioPortfolio

#Minimum risk portfolio
  minrisk_portfolio<-minriskPortfolio(as.timeSeries(portfolio_returns),
                                  spec=portfolioSpec(),
                                  constraints='LongOnly')
  minrisk_portfolio #Returns the portfolio with the lowest risk at all

#Minimum variance portfolio
  minvar_portfolio<-minvariancePortfolio(as.timeSeries(portfolio_returns),
                                     spec=portfolioSpec(),
                                     constraints='LongOnly')
  minvar_portfolio #Synonym of minriskPortfolio

#Optimal weights
optimal_weights<-getWeights(maxratio_portfolio)
optimal_weights

plot.new()
par(mfrow=c(1,1))
weightsPlot(efficient_frontier,
            label=FALSE)

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
                 benchmark_returns)
  colnames(overall)<-c('Optimal Portfolio',
                       'Benchmark')
  overall<-na.omit(overall)
  overall
  
  plot.new()
  par(mfrow=c(1,1))
  charts.PerformanceSummary(overall,
                            main='Optimal Portfolio Vs Benchmark',
                            plot.engine='plotly')
  
  table.Stats(overall) #Statistics for optimal portfolio and benchmark returns