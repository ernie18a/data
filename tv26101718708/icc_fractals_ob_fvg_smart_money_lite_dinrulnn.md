# ICC + Fractals + OB + FVG (Smart Money Lite)

- url: https://www.tradingview.com/script/dInRUlNN-ICC-Fractals-OB-FVG-Smart-Money-Lite/
- type: indicator
- pine_id: PUB;c9a4275d4fd14eb089d8b7a8197d652c
- version: 1.0

## Description

Use BOS labels to identify trend direction. Look for price to return to Order Blocks or FVGs for high-probability entries. Sweeps signal potential reversals. God Bless

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eman4ever53

//@version=6
indicator("ICC + Fractals + OB + FVG (Smart Money Lite)", overlay=true,
     max_lines_count=500, max_boxes_count=500)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
left = input.int(2, "Fractal Left")
right = input.int(2, "Fractal Right")

showTrendlines = input.bool(true, "Fractal Trendlines")
showSweeps = input.bool(true, "Liquidity Sweeps")
showOB = input.bool(true, "Order Blocks")
showFVG = input.bool(true, "Fair Value Gaps")

// ─────────────────────────────
// FRACTALS (Structure)
// ─────────────────────────────
ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ─────────────────────────────
// BOS + SWEEPS
// ─────────────────────────────
bosUp = not na(lastHigh) and close > lastHigh
bosDn = not na(lastLow) and close < lastLow

sweepHigh = showSweeps and not na(lastHigh) and high > lastHigh and close < lastHigh
sweepLow  = showSweeps and not na(lastLow) and low < lastLow and close > lastLow

plotshape(bosUp, style=shape.labelup, color=color.blue, text="BOS↑", location=location.belowbar)
plotshape(bosDn, style=shape.labeldown, color=color.orange, text="BOS↓", location=location.abovebar)

plotshape(sweepHigh, style=shape.triangledown, color=color.red, text="SWEEP", location=location.abovebar)
plotshape(sweepLow, style=shape.triangleup, color=color.green, text="SWEEP", location=location.belowbar)

// ─────────────────────────────
// FAIR VALUE GAPS (FVG)
// ─────────────────────────────
var box[] fvgBoxes = array.new_box()

bullFVG = showFVG and low > high[2]
bearFVG = showFVG and high < low[2]

// Bullish FVG
if bullFVG
    b = box.new(
        left=bar_index-2,
        right=bar_index,
        top=low,
        bottom=high[2],
        bgcolor=color.new(color.green, 85),
        border_color=color.green
    )
    array.push(fvgBoxes, b)

// Bearish FVG
if bearFVG
    b = box.new(
        left=bar_index-2,
        right=bar_index,
        top=low[2],
        bottom=high,
        bgcolor=color.new(color.red, 85),
        border_color=color.red
    )
    array.push(fvgBoxes, b)

// ─────────────────────────────
// ORDER BLOCKS
// ─────────────────────────────
var box[] obBoxes = array.new_box()

bullOB = showOB and bosUp and close[1] < open[1]
bearOB = showOB and bosDn and close[1] > open[1]

// Bullish OB
if bullOB
    b = box.new(
        left=bar_index-1,
        right=bar_index+10,
        top=high[1],
        bottom=low[1],
        bgcolor=color.new(color.lime, 85),
        border_color=color.lime
    )
    array.push(obBoxes, b)

// Bearish OB
if bearOB
    b = box.new(
        left=bar_index-1,
        right=bar_index+10,
        top=high[1],
        bottom=low[1],
        bgcolor=color.new(color.red, 85),
        border_color=color.red
    )
    array.push(obBoxes, b)

// ─────────────────────────────
// ALERTS
// ─────────────────────────────
alertcondition(bosUp, "BOS Up", "Bullish Break of Structure")
alertcondition(bosDn, "BOS Down", "Bearish Break of Structure")
alertcondition(bullFVG, "Bullish FVG", "Fair Value Gap Up")
alertcondition(bearFVG, "Bearish FVG", "Fair Value Gap Down")
````
