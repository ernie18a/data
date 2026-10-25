# OBV Strategy

- url: https://www.tradingview.com/script/P9fxjChQ-OBV-Strategy/
- type: strategy
- pine_id: PUB;ukWQmydfcU1ufiGPl6BxR2GFMAX3CX2X
- version: 1.0

## Description

A simple strategy to give buy/sell signals based on OBV and EMA crossover/crossunder.
When OBV crossunder the EMA it gives a sell signal. When OBV crossover EMA it gives a buy signal.

You can adjust the length of the EMA . By default it is set to 9

## Source Code

````pine
//author: Reda
//@version=3
strategy("OBV Strategy", overlay=true)

src = close
len = input(9, minval=1, title="Length")
obv = cum(change(src) > 0 ? volume : change(src) < 0 ? -volume : 0*volume)
ema = ema(obv, len)


longCondition = crossover(obv, ema)
if (longCondition)
    strategy.entry("Long", strategy.long)

shortCondition = crossunder(obv, ema)
if (shortCondition)
    strategy.entry("Short", strategy.short)
````
