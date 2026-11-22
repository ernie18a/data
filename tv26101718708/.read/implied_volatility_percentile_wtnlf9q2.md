# Implied Volatility Percentile

- url: https://www.tradingview.com/script/wtNlF9q2-Implied-Volatility-Percentile/
- type: indicator
- pine_id: PUB;d7lXTQysvrmyrIY7CFNOBinOgkCHPZqy
- version: 1.0

## Description

This script calculates the Implied Volatility (IV) based on the daily returns of price using a standard deviation.  It then annualizes the 30 day average to create the historical Implied Volatility.  This indicator is intended to measure the IV for options traders but could also provide information for equities traders to show how price is extended in the expected price range based on the historical volatility. 

The IV Rank (Green line) is then calculated by looking at the high and low volatility over the number of days back specified in the input parameter, default is 252 (trading days in 1 year) and then calculating the rank of the current IV compared to the High and Low.  This is not as reliable as the IV Percentile as the and extreme high or low could have a side effect on the ranking but it is included for those that want to use.

The IV Percentile is calculated by counting the number of days below the current IV, then returns this as a % of the days back in the input

You can adjust the number of days back to check the IV Rank & IV Percentile if you are not wanting to look back a whole year.  

This will only work on Daily or higher timeframe charts.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © karimka

//@version=4
study(title="Implied Volatility Percentile", shorttitle="IVP", precision=0)

var length = input(title="Days Back", defval=252, minval=20, maxval=505)
var userDeviation = input (title="Std Dev", defval=1, minval=1, maxval=3)

// Calculate Historical IV
priceReturns = (close-close[1])/close[1]
deviation = stdev(priceReturns, 30)
annualizedVolatility = deviation * 16
// DEBUG/Validate the IV: plot(annualizedVolatility*100, color=color.purple)

// Get the High and Low over the past # of days input
low_over_timespan = lowest(annualizedVolatility, length)
high_over_timespan = highest(annualizedVolatility, length)

//Calculate IV Rank
ivRank = round((annualizedVolatility-low_over_timespan)/(high_over_timespan-low_over_timespan)*100)


//Calculate IV Percentile
count = 0.0
for i = 1 to length
    if annualizedVolatility > annualizedVolatility[i] 
        count:=count+1
    
ivPercentile = round(count/length*100)

plot(series=iff(timeframe.isdwm, ivRank,na), color=color.green, title="IV Rank Comp to High Low")
plot (series=iff(timeframe.isdwm,ivPercentile,na), color=color.yellow, title="% of days below the IV")
````
