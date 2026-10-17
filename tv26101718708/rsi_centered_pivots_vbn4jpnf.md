# RSI Centered Pivots

- url: https://www.tradingview.com/script/vbn4jPnf-RSI-Centered-Pivots/
- type: strategy
- pine_id: PUB;dab2ec366f6444acb6d4248137b6ce67
- version: 3.0

## Description

Just a simple RSI central pivot strategy I made for a friend.
Backtested on BYBIT:BTCUSD, 155m.

[b]DISCLAIMER[/b]: Please do your own research into anything you use before using it to trade.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OztheWoz

//@version=4
strategy("RSI Fractals", initial_capital=10000, commission_type=strategy.commission.percent, commission_value=0.1, slippage=3)
// study("RSI Fractals")

len = input(19, "Length")
rsi = rsi(close, len)
fractup = pivotlow(rsi, 2, 2)
fractdn = pivothigh(rsi, 2, 2)

plot(rsi)
hline(80, color=color.gray)
hline(20, color=color.gray)
plotshape(fractup, style=shape.triangleup, location=location.bottom, color=color.green, offset=-2)


strategy.entry("Long", true, 1, when=fractup)
strategy.close("Long", when=(rsi >= 80))
stoploss = close[1] - (close[1] * 0.5/100)
strategy.exit("Long", "Exit Long", stop=stoploss)

// alertcondition(fractup, "RSI Fractal Up",   "RSI Fractal V \nExpect Reversal Bearish")
// alertcondition(fractdn, "RSI Fractal Down", "RSI Fractal ^ \nExpect Reversal Bullish")
// alertcondition((rsi >= 80), "RSI Overbought",  "RSI Overbought \nSell Before Bearish Reversal")
// alertcondition((rsi <= 20), "RSI Underbought", "RSI Underbought \nSell Before Bullish Reversal")
````
