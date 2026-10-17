# Bollinger Bands Trend Strategy

- url: https://www.tradingview.com/script/o8bKRN8s-Bollinger-Bands-Trend-Strategy/
- type: strategy
- pine_id: PUB;Uu15tbMJePs8w7Q2A0NE98WOzOaTmktB
- version: 1.0

## Description

This is a trading strategy for trend traders. 
Buy signals are generated when price closes above upper band.
Sell signals are generated when price closes below lower band.
Good luck.

## Source Code

````pine
//@version=4
strategy("Bollinger Bands Trend Strategy", shorttitle="BB Trend", overlay=true)
source = close
length = input(8, minval=1)
mult = input(1.00, minval=0.001, maxval=50)

basis = sma(source, length)
dev = mult * stdev(source, length)

upper = basis + dev
lower = basis - dev

buyEntry = crossover(source, upper)
sellEntry = crossunder(source, lower)

if (crossover(source, upper))
    strategy.entry("BBandLE", strategy.long, stop=upper, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandLE")
else
    strategy.cancel(id="BBandLE")

if (crossunder(source, lower))
    strategy.entry("BBandSE", strategy.short, stop=lower, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="BBandSE")
else
    strategy.cancel(id="BBandSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
