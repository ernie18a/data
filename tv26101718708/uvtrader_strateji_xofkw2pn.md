# UVTrader Strateji

- url: https://www.tradingview.com/script/xoFkw2PN/
- type: strategy
- pine_id: PUB;1M0lIJG4hPohUTURNRh2NaqhzXCzR5AC
- version: 1.0

## Description

If you see "AL" you can buy, If you see "SAT" you can sell. You can use all charts, but 4 H and 1 D charts are very well..

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

longCondition = crossover(close, highest(high[1],3))
if (longCondition)
    strategy.entry("AL", strategy.long)

shortCondition = crossunder(close, lowest(low[1],3))
if (shortCondition)
    strategy.entry("SAT", strategy.short)
````
