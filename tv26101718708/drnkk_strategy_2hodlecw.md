# drnkk Strategy

- url: https://www.tradingview.com/script/2hODlecW-drnkk-Strategy/
- type: strategy
- pine_id: PUB;vXNryRouVlERdE7f5ZbM9xZH44vxN7Kv
- version: 5.0

## Description

Strategy based upon combination with, ROC of Vortex, modified RSI, modified Price ROC,

Bu da mı gol değil?

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

longCondition = crossover(sma(close, 14), sma(close, 28))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 14), sma(close, 28))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
