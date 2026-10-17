# Two level TP + TrailStp exits example

- url: https://www.tradingview.com/script/tWS24Z2K-Two-level-TP-TrailStp-exits-example/
- type: strategy
- pine_id: PUB;qqWPJkKlIkytx0HwawRwu6IRBTjzuUQO
- version: 1.0

## Description

Multi level exist example.
When you need take profit 50% of position size and trailing stop for remain part.
The different ids names for exits is important. Same id needs when we want to modify exit's parameters.

## Source Code

````pine
 // This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © adolgov

//@version=4
strategy("Two level TP + TrailStp exits example", overlay=false, default_qty_value = 100)

longCondition = crossover(sma(close, 14), sma(close, 28))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 14), sma(close, 28))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)

trailingPoints = input(1000)
trailingOffset = input(300)
takeProfitPoints = input(1000)

strategy.exit("partial", qty_percent = 50, profit = takeProfitPoints)
strategy.exit("full", trail_points = trailingPoints, trail_offset = trailingOffset)

profitPercent(price) =>
    posSign = strategy.position_size > 0 ? 1 : strategy.position_size < 0 ? -1 : 0
    (price - strategy.position_avg_price) / strategy.position_avg_price * posSign * 100

p1 = plot(profitPercent(high), style=plot.style_linebr, title = "open profit % upper bound")
p2 = plot(profitPercent(low), style=plot.style_linebr, title = "open profit % lower bound")
fill(p1, p2, color = color.red)
````
