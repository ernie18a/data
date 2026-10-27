# dEMA w/ VWAP filter

- url: https://www.tradingview.com/script/d5I7yUXY-dEMA-w-VWAP-filter/
- type: strategy
- pine_id: PUB;b2LbWi2ZRTVMCwKwTjURV8okVtcLRWFC
- version: 1.0

## Description

Buy when EMA is below VWAP and starts sloping up
Sell when EMA is above VWAP and starts sloping down

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shiner_trading

//@version=4
strategy("dEMA w/ VWAP filter", overlay=true, default_qty_type=strategy.cash, initial_capital=500)

len = input(34, "EMA Length")
ma = ema(close, len)

longCondition = change(ma) > 0 and ma < vwap
if (longCondition)
    strategy.entry("Buy", true, 1)

shortCondition = (change(ma) < 0 and close > vwap) or (crossunder(ma, vwap) and change(ma) > 0)
if (shortCondition)
    strategy.close("Buy")

plot (vwap, color=color.fuchsia)
plot (ma)
````
