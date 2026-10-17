# Multimarket Direction indicator

- url: https://www.tradingview.com/script/QDBvyqEv/
- type: indicator
- pine_id: PUB;e975d1c3413345548e8c4b725e423449
- version: 2.0

## Description

Trendline trading with resistant and support made by me.
Im bad coder and just jump into the tradingview pine script 1 days before so please don't hates me
- I don't know why my script is ded before lol
Signals to trade up
1. The big candles up cross the ema200 (last 5 candles for confirmation)
2. Wait for showing the up triangle.
3. Lookup the resistant/support line. If near the resistant please consider to wait if it break then join the trade
4. Only out trade when it has a down triagle or the candles has big down candles at the resistant/support line.

That it...

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © quanvntaoiyeuquehuongvn

//@version=5
indicator("Multimarket Direction indicator", overlay=true)
ema21 = ta.ema(close, 20)
ema81 = ta.ema(close, 50)
macd1 = ta.ema(close, 7)
macd2 = ta.ema(close, 12)
ema200 = ta.ema(close, 200)
downtrend = ta.crossunder(ema21, ema81)
uptrend = ta.crossover(ema21, ema81)
highest_close = ta.highest(close, 200)
lowest_close = ta.lowest(close, 200)
sp = ta.rising(lowest_close, 2)
p1PlotID = plot(ema21, color=color.blue, linewidth=1, title="Ema 21")
p2PlotID = plot(ema81, color=color.orange, linewidth=1, title="Ema 81")
plot(ema200, color=color.green, linewidth=2, title="Ema 200")
fill(p1PlotID, p2PlotID, ema21 > ema81 ? color.new(color.green, 90) : color.new(color.red, 90))
plot (highest_close, color=color.new(color.red, 20), linewidth=5)
plot (lowest_close, color=color.new(color.green, 20), linewidth=5)
buySignal = uptrend and macd1 > macd2
plotshape(buySignal ? macd1 : na, "Buy", shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
sellSignal = downtrend and macd1 < macd2
plotshape(sellSignal ? macd1 : na, "Sell", shape.triangledown, location = location.abovebar, color = color.red, size = size.small)
````
