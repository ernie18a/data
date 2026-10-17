# Kozlod - Simple BB Strategy - XBTUSD - 1 minute

- url: https://www.tradingview.com/script/D3PkU5ho-Kozlod-Simple-BB-Strategy-XBTUSD-1-minute/
- type: strategy
- pine_id: PUB;VPkAquBCDPT2nMD6NBh1Pt4TCs1ShGpo
- version: 2.0

## Description

Really nice performance for simple BB on XBTUSD Bitmex 1 minute chart. 
BB length = 55, BB mult = 4.
No SL or PT used. 

Amazingly performance for the last week, 92% profitable. Tested on entire May percent profitable become 80%, still not bad. 

And remember: 
Past performance does not guarantee future results.

## Source Code

````pine
//@version=3
strategy("Kozlod - BB Strategy - 1 minute", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

source = close
length = input(55, minval=1)
mult = input(4, minval=0.001, maxval=50)

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
