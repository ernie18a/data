# Power Zonessssss

- url: https://www.tradingview.com/script/SCAYsFn7-Power-Zonessssss/
- type: strategy
- pine_id: PUB;a63d4441a23f48a6839fe48cccfb7d3c
- version: 1.0

## Description

Powerfull buy  snd asell strategy for the good buying sn f[rofi

## Source Code

````pine
  // This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © liuen

//@version=5
strategy("Power", overlay=false)
a=ta.vwap(close)
b=ta.ema(close,9)
c= close
d= ta.rsi(close, 14)
plot(a, title="VVWAP", color=color.blue)
plot(b, title="EMA", color=color.green)
plot(c, title="Close", color=color.black)

longCondition = ta.crossover(c, a) and d<50 and c>b
if (longCondition)
    strategy.entry("BUY", strategy.long)

shortCondition = ta.crossunder(c, a) and d>50 and c<b
if (shortCondition)
    strategy.entry("SELL", strategy.short)
````
