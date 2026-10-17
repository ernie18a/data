# MA Cross System

- url: https://www.tradingview.com/script/cxNNI673-MA-Cross-System/
- type: strategy
- pine_id: PUB;qsKiB44X6UH2nNLXr5aikXSgPA0ijZvP
- version: 1.0

## Description

A MA Cross System.

## Source Code

````pine
//@version=3
strategy(title="MA Cross WT System", shorttitle="MA_Cross", overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_value = 0.25)
fastLength = input(20)
slowLength = input(100)
slowerLength = input(400)
src = input(close, title="Source")

emaFast = sma(src, fastLength)
emaSlow = sma(src, slowLength)
emaSlower = sma(src, slowerLength)

plot(emaSlow, title="Slow", color=blue)
plot(emaSlower, title='Slower', color=yellow)
plot(emaFast, title='Fast', color=purple)

longCond = ((emaSlow > emaSlower) and (emaFast > emaSlower) and crossover(emaFast, emaSlow))
sellCond = (crossunder(emaFast, emaSlower))

if longCond
    strategy.entry('long', strategy.long)

strategy.close_all(when=sellCond)
````
