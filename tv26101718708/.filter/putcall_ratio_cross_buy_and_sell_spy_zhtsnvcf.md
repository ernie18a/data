# Put/call ratio cross - buy and sell SPY

- url: https://www.tradingview.com/script/ZhTSnvCF-Put-call-ratio-cross-buy-and-sell-SPY/
- type: strategy
- pine_id: PUB;2535
- version: -1.0

## Description

When 50DMA and 200DMA cross on PC, algo trades SPY accordingly

## Source Code

````pine
//@version=2
strategy("My Strategy", overlay=true)

longCondition = crossover(sma(close, 50), sma(close, 200))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 50), sma(close, 200))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
