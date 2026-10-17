# Sma crossover

- url: https://www.tradingview.com/script/8txgTt2X-Sma-crossover/
- type: strategy
- pine_id: PUB;dH2bOBLRK27Wy1sUaqqTyUYHdctFdajm
- version: 1.0

## Description

Sma of 5 cross over sma of 21 periods. Testing stratgy writer

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

longCondition = crossover(sma(close, 5), sma(close, 21))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 14), sma(close, 28))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
