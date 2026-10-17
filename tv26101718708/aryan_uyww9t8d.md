# AryaN

- url: https://www.tradingview.com/script/uYWw9T8d-AryaN/
- type: strategy
- pine_id: PUB;1cce48269ba44cd482c1a6106105b774
- version: 1.0

## Description

very well good performing i satisfy and testing very good

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sandipkindo

//@version=5
strategy("My strategyP", overlay=true, margin_long=100, margin_short=100)

longCondition = ta.crossover(ta.ema(close, 5), ta.ema(close, 10))
if (longCondition)
    strategy.entry("Buy", strategy.long)

shortCondition = ta.crossunder(ta.ema(close, 6), ta.ema(close, 11))
if (shortCondition)
    strategy.entry("Sell" , strategy.short)
````
