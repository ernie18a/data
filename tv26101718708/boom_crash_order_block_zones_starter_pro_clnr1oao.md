# Boom & Crash Order Block Zones (Starter Pro)      

- url: https://www.tradingview.com/script/clNR1OaO-Boom-Crash-Order-Block-Zones-Starter-Pro/
- type: indicator
- pine_id: PUB;eda55b66e668447f806621c8ba8b93a7
- version: 1.0

## Description

MR K boom and crash engine using orderblock entries i hope to guys enjoy it

## Source Code

````pine
//@version=6
indicator('Boom & Crash Order Block Zones (Starter Pro)', overlay = true)

// ───── Inputs ─────
lookback = input.int(20, 'Structure Lookback')

// ───── Market Structure ─────
recentHigh = ta.highest(high, lookback)
recentLow = ta.lowest(low, lookback)

// ───── Liquidity Sweeps ─────
sweepHigh = high > recentHigh[1] and close < recentHigh[1]
sweepLow = low < recentLow[1] and close > recentLow[1]

// ───── Order Block Detection ─────
// We define OB as last opposite candle before a sweep

bearOB = sweepHigh and close[1] > open[1]
bullOB = sweepLow and close[1] < open[1]

// ───── ZONE STORAGE ─────
var box bearBox = na
var box bullBox = na

// ───── CREATE BEARISH ORDER BLOCK ZONE ─────
if bearOB
    bearBox := box.new(left = bar_index - 1, right = bar_index + 20, top = high[1], bottom = low[1], bgcolor = color.new(color.red, 85), border_color = color.red)
    bearBox

// ───── CREATE BULLISH ORDER BLOCK ZONE ─────
if bullOB
    bullBox := box.new(left = bar_index - 1, right = bar_index + 20, top = high[1], bottom = low[1], bgcolor = color.new(color.green, 85), border_color = color.green)
    bullBox

// ───── SPIKE CONFIRMATION ─────
crashSignal = sweepHigh and close < open
boomSignal = sweepLow and close > open

plotshape(crashSignal, title = 'Crash Spike', location = location.abovebar, style = shape.triangledown, color = color.red, text = 'CRASH')

plotshape(boomSignal, title = 'Boom Spike', location = location.belowbar, style = shape.triangleup, color = color.green, text = 'BOOM')
````
