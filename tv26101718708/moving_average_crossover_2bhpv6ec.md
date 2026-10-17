# Moving Average Crossover 

- url: https://www.tradingview.com/script/2BHPV6EC/
- type: strategy
- pine_id: PUB;tY07Cco4yvBY3ae6I2QAxS0owzqh9dzn
- version: 1.0

## Description

This indicator is based on ema 5 and ema 20, when ema 5 crosses over ema 20, the line will be green, when ema 5 crosses down it will be red

This indicator has been accompanied by a strategy so we can see the results through the strategy tester, this strategy there is only a long, I recommend using a weekly timeframe because the volatility is lower and minimal with false signals

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © muh4mm4dm4hr

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © muh4mm4dm4hr

//@version=4
strategy("Moving Average Crossover 1", overlay= true)


ema5 = ema(close, 5)
ema20 = ema(close, 20)

long = ema5 > ema20
short = ema5 < ema20



colorBasis = ema5 >= ema20 ? color.green : color.red

pBasis = plot(ema20, linewidth=4, color=colorBasis)

strategy.entry("long", strategy.long, 1000.0, when=long)


strategy.close("long", when = short)
````
