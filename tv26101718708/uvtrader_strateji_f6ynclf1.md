# UVTrader Strateji

- url: https://www.tradingview.com/script/F6yNCLf1/
- type: strategy
- pine_id: PUB;UKEvUTzEltV6ow7aabhPquKh2UnMI5Tg
- version: 1.0

## Description

If you see "AL", you can buy.

If you see "SAT", you can sell.

You can use all charts, but 4H and 1D charts are very well.

## Source Code

````pine
//@version=3
strategy("UVTrader Strateji", overlay=true)

longCondition = crossover(close, highest(high[1],3))
if (longCondition)
    strategy.entry("AL", strategy.long)

shortCondition = crossunder(close, lowest(low[1],3))
if (shortCondition)
    strategy.entry("SAT", strategy.short)
````
