# EMA12/26 buy spot only

- url: https://www.tradingview.com/script/fOkd27us-EMA12-26-buy-spot-only/
- type: strategy
- pine_id: PUB;2e4a33c1dca5452da555c08c26f0d97d
- version: 1.0

## Description

Inspire by CDC action zone, all thanks should be given to AJ piranya33

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sasinp

//@version=5
strategy("EMA12/26 buy spot only", overlay=true)

longCondition = ta.crossover(ta.ema(close, 12), ta.ema(close, 26))
if (longCondition)
    strategy.entry("buy", strategy.long)

if ta.crossunder(ta.ema(close, 12), ta.ema(close, 26))
    strategy.close("buy")
````
