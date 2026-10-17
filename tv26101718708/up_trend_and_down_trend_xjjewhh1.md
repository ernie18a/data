# UP TREND AND DOWN TREND

- url: https://www.tradingview.com/script/xJjEWHh1-UP-TREND-AND-DOWN-TREND/
- type: strategy
- pine_id: PUB;310a719442584d62abe2f97e1c48618b
- version: 1.0

## Description

It's help you to find the market trend up or down side

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © natrajgcl

//@version=5
strategy("UP TREND AND DOWN TREND", overlay=true, margin_long=100, margin_short=100)

longCondition = ta.crossover(ta.sma(close, 20), ta.sma(close, 200))
if (longCondition)
    strategy.entry("UP TREND", strategy.long)

shortCondition = ta.crossunder(ta.sma(close, 20), ta.sma(close, 200))
if (shortCondition)
    strategy.entry("DOWN TREND", strategy.short)
````
