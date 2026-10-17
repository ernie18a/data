# ema strategy

- url: https://www.tradingview.com/script/L4o5RzWV-ema-strategy/
- type: strategy
- pine_id: PUB;9c4169d2b9ef4924b2819221143b6c3d
- version: 1.0

## Description

EMA STRATEGY Scalping with staggered buy and profit Booking 

try and like if you get profitable

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sijj

//@version=5
strategy("ema strategy", overlay = true)

ema = ta.ema(close, 5)
e = ta.ema(close, 200)
rsi = ta.rsi(close, 2)
cond1 = close[1] < open[1] * 0.9999 and close[1] < ema and rsi < 10
cond2 = close[1] > open[1] * 1.0001 and close[1] > ema and rsi > 90
plot(ema)

plotshape(cond1, style = shape.triangleup, location = location.belowbar, color = color.lime, text = "Buy" )
plotshape(cond2, style = shape.triangledown, location = location.abovebar, color = color.red, text = "Sell" )

pos = strategy.position_size


strategy.entry("Buy", strategy.long,qty = strategy.opentrades > 0 ? pos*2 : 1000, when = cond1 )

strategy.close("Buy",comment = "Exit", when = strategy.openprofit > 1 or strategy.opentrades > 5)
````
