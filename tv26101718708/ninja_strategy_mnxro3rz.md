# ninja strategy

- url: https://www.tradingview.com/script/MnxRo3rZ-ninja-strategy/
- type: strategy
- pine_id: PUB;330b27444bc040fb949f1d3d121156e9
- version: 1.0

## Description

The ninja strategy is 3-minute scalping.

It takes profits from very short term ups and downs.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kuroisirokisi

//@version=5

strategy("ninja strategy")

if (low[1] > low[2] and low[2] > low[3] and close <= low[1])
    strategy.entry("BarUp", strategy.long, 1000000, stop=low[1]+(high[1]-low[1])*2/3)

if (high[1] < high[2] and high[2] < high[3] and close >= high[1])
    strategy.entry("BarDown", strategy.short, 1000000, stop=high[1]-(high[1]-low[1])*2/3)

if (timenow >= time_close)
    strategy.close("BarUp")
    strategy.close("BarDown")
````
