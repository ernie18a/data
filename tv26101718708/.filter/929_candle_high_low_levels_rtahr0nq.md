# 9:29 Candle High Low Levels

- url: https://www.tradingview.com/script/RTAhr0Nq-9-29-Candle-High-Low-Levels/
- type: indicator
- pine_id: PUB;b40683110dfe4730a99bbaf166733a1d
- version: 1.0

## Description

Daily Fair Price Value (9:29 AM Candle)

This indicator automatically marks the open price of the 9:29 AM EST candle and extends it across the entire trading session as a horizontal level.

The concept behind this tool is that the 9:29 AM candle open represents the day's Fair Price Value (FPV). Price often expands away from this level during the New York session and later returns to rebalance around it.

Features
Automatically identifies the 9:29 AM EST candle
Plots the candle's open price
Extends the level throughout the session
Resets automatically each trading day
Fully customizable line color and width
Designed for use on the 1-minute timeframe
How to Use
Use the line as a daily fair value reference.
Monitor whether price is trading at a premium or discount relative to the level.
Watch for mean reversion back to fair value after strong directional moves.
Combine with liquidity sweeps, market structure shifts, PO3, ICT concepts, and Fair Value Gaps for higher-probability setups.
Best Used On
NQ / MNQ
ES / MES
YM / MYM
Futures markets during the New York session
Trading Concept

When there is no significant new information for the market to price in, price often seeks equilibrium and returns toward fair value. The 9:29 AM candle open serves as a simple visual representation of that daily equilibrium level.

## Source Code

````pine
//@version=6
indicator("6:29 Candle High Low Levels", overlay=true, max_lines_count=20)

tz = input.string("America/Los_Angeles", "Timezone")

lineColor = input.color(color.rgb(0,170,255), "Line Color")
lineWidth = input.int(2, "Line Width")

// Detect 6:29 candle
is629 = hour(time, tz) == 6 and minute(time, tz) == 29

// New Day
newDay = ta.change(time("D")) != 0

var line highLine = na
var line lowLine = na

// Reset daily
if newDay
    line.delete(highLine)
    line.delete(lowLine)

    highLine := na
    lowLine := na

// Draw levels from 6:29 candle
if is629

    line.delete(highLine)
    line.delete(lowLine)

    highLine := line.new(
         x1 = bar_index,
         y1 = high,
         x2 = bar_index + 1,
         y2 = high,
         extend = extend.right,
         color = lineColor,
         width = lineWidth
     )

    lowLine := line.new(
         x1 = bar_index,
         y1 = low,
         x2 = bar_index + 1,
         y2 = low,
         extend = extend.right,
         color = lineColor,
         width = lineWidth
     )
````
