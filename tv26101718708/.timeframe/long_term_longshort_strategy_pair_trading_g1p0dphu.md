# Long Term Long/Short Strategy (Pair Trading)

- url: https://www.tradingview.com/script/G1P0dpHu-Long-Term-Long-Short-Strategy-Pair-Trading/
- type: strategy
- pine_id: PUB;h2VKSQtc8kSIqHR2vS9yDIMjgsUDdN8v
- version: 1.0

## Description

Longing or shorting an asset ratio depending on long term trend.

Long term trend is defined by crossing of an asset or index and its SMA.

Input values:
* trend asset
* SMA configuration (periods, resolution)
* strategy: long only, long/short, short only

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danilogalisteu

//@version=4
strategy("Long Term L/S", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

base = input("BMFBOVESPA:IBOV")
period = input(5, 'SMA Period', input.integer)
resolution = input(title="SMA Resolution", type=input.resolution, defval='M')
strat = input(title="Strategy", defval="Long/Short", options=["Long Only", "Long/Short", "Short Only"])
strat_val = strat == "Long Only" ? 1 : strat == "Long/Short" ? 0 : -1

base_cl = security((base), resolution, close)
base_ma = sma(base_cl, period)

longCondition = crossover(base_cl, base_ma)
if (longCondition)
    if strat_val > -1
        strategy.entry("LONG", strategy.long)
    if strat_val < 1
        strategy.close("SHORT")

shortCondition = crossunder(base_cl, base_ma)
if (shortCondition)
    if strat_val > -1
        strategy.close("LONG")
    if strat_val < 1
        strategy.entry("SHORT", strategy.short)

//plot(longCondition?1:0, 'L', color.blue)
//plot(shortCondition?-1:0, 'S', color.red)
````
