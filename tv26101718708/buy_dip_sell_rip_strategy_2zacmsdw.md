# Buy Dip Sell Rip Strategy

- url: https://www.tradingview.com/script/2zacmSDw-Buy-Dip-Sell-Rip-Strategy/
- type: strategy
- pine_id: PUB;dgPUaUPHdUG60ThH2KriEKoh16Gx5Bhh
- version: 1.0

## Description

This simple system buys the dip and sells the rip, depending on the trend of a long-term moving average.  This strategy shows several interesting features.  Applied to the S&P500, it still is a loser in a bear market, even though it achieves a 59% win rate.  Overall, this shows the power of buying dips as an investment strategy, and shows promise as a base for other more short-term trading strategies.

Feel free to donate : )

## Source Code

````pine
//@version=3
strategy("Buy Dip Sell Rip Strategy", overlay=true)
source = close
length = input(15, minval=1)
mult = input(1.25, minval=0.001, maxval=50)
longMAPeriod = input(300, minval=5)
shortMAPeriod = input(20, minval=5)

basis = sma(source, length)
longMA = sma(source, longMAPeriod)
prevLongMA = sma(close[1],longMAPeriod)
shortMA = sma(source, shortMAPeriod)
dev = mult * stdev(source, length)

upper = basis + dev
lower = basis - dev

buyEntry = crossover(source, lower)
sellEntry = crossunder(source, upper)

if (source > lower and source[1] < lower)
    if (longMA < source  and shortMA>source)
        strategy.entry("BBandLE", strategy.long, stop=lower, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandLE")
    else
        strategy.close("BBandSE")
else
    strategy.cancel(id="BBandLE")

if (source > upper and source[1] < upper)
    if (longMA > source  and shortMA < source)
        strategy.entry("BBandSE", strategy.short, stop=upper, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandSE")
    else 
        strategy.close("BBandLE")
else
    strategy.cancel(id="BBandSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
