# Kozlod - Simple BB Strategy - XRPBTC - 1 minute

- url: https://www.tradingview.com/script/hZiWYCbj-Kozlod-Simple-BB-Strategy-XRPBTC-1-minute/
- type: strategy
- pine_id: PUB;eaCqdfuBoGeAxZ4AuZDt04xELzr9Cdbd
- version: 2.0

## Description

Pretty good performance of simple BB on XRPBTC 1minute chart.
No SL or PT used. 

And remember: 
Past performance does not guarantee future results.

## Source Code

````pine
//@version=3
strategy("Kozlod - BB Strategy - 1 minute", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 5)

source = close
length = input(45, minval=1)
mult = input(2.5, minval=0.001, maxval=50)

basis = sma(source, length)
dev = mult * stdev(source, length)

upper = basis + dev
lower = basis - dev

plot(upper)
plot(lower)

buyEntry  = crossover(source, lower)
sellEntry = crossunder(source, upper)

if (crossover(source, lower))
    strategy.entry("BBandLE", strategy.long, stop=lower, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandLE")
else
    strategy.cancel(id="BBandLE")

if (crossunder(source, upper))
    strategy.entry("BBandSE", strategy.short, stop=upper, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandSE")
else
    strategy.cancel(id="BBandSE")
````
