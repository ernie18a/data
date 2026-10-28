# GetTrendStrategy 370 30 min

- url: https://www.tradingview.com/script/pVPE2jc5/
- type: strategy
- pine_id: PUB;i85Yrgdff8PN8xf300Ue70Io486ffy7j
- version: 1.0

## Description

Modificación de la estrategia “GetTrendStrategy” optimizada para Bitcoin.

## Source Code

````pine
//@version=2
strategy("GetTrendStrategy 370 30 min", overlay=true)
tim=input('370')


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
````
