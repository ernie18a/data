# ROoT

- url: https://www.tradingview.com/script/jubSkjKS-ROoT/
- type: strategy
- pine_id: PUB;7a1afc7b7f244bc39a7088a53934b9db
- version: 1.0

## Description

it is a simple crossover technic and with small stop loss

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realisticDove62527

//@version=5
strategy("ROoT", overlay=true, margin_long=1, margin_short=1)

longCondition = ta.crossover(ta.sma(close, 5), ta.vwap(hlc3))
if (longCondition)
    strategy.entry("BUY", strategy.long)

shortCondition = ta.crossunder(ta.sma(close, 5), ta.vwap(hlc3))
if (shortCondition)
    strategy.entry("SELL", strategy.short)
    

stoploss = ta.ema(close, 9)
````
