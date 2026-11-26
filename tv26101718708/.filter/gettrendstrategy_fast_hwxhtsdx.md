# GetTrendStrategy Fast

- url: https://www.tradingview.com/script/HwxhtSdX-GetTrendStrategy-Fast/
- type: strategy
- pine_id: PUB;lmeHuhobRgfIKnHz6AbLe3LNMu3T3MPt
- version: 1.0

## Description

GetTrendStrategy but much much much faster, and much more productive.
Works perfect on 1m charts
(YaroslavG)

## Source Code

````pine
//@version=2
strategy("GetTrendStrategy Fast", overlay=true)
tim=input('6')
out1 = security(tickerid, tim, open)
out2 = security(tickerid, tim, close)
plot(out1,color=red)
plot(out2,color=green)
longCondition = crossover(security(tickerid, tim, close),security(tickerid, tim, open))
if (longCondition)
    strategy.entry("long", strategy.long)
shortCondition = crossunder(security(tickerid, tim, close),security(tickerid, tim, open))
if (shortCondition)
    strategy.entry("short", strategy.short)
//YaroslavG
````
