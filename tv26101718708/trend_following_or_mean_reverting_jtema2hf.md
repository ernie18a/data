# Trend Following or Mean Reverting

- url: https://www.tradingview.com/script/JTEmA2hf-Trend-Following-or-Mean-Reverting/
- type: strategy
- pine_id: PUB;L609uWVuKCEKXYRAQg5zZZ6WQLYQHxLo
- version: 1.0

## Description

The strategy checks nature of the instruments. It Buys if the close is greater than yesterday's high, reverse the position if the close is lower than yesterday's low and repeat the process.

1. If it is trend following then the equity curve will be in uptrend
2. If it is mean reverting then the equity curve will be downtrend

Thanks to Rayner Teo.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Senthaamizh

//Identifies whether the instrument is trending or mean reverting 
//@version=4

strategy("Trend Following or Mean Reverting",shorttitle = "TF/MR",default_qty_type = strategy.percent_of_equity,default_qty_value = 100, overlay=true)

buy = close>high[1]
sell = close<low[1]
if (buy)
    strategy.entry("Long", strategy.long,qty=1)
if (sell)
    strategy.entry("Short", strategy.short,qty=1)
````
