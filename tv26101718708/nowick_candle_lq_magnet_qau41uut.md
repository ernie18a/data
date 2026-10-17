# No-Wick Candle LQ Magnet

- url: https://www.tradingview.com/script/QAU41UUT-No-Wick-Candle-LQ-Magnet/
- type: indicator
- pine_id: PUB;7cf47fb4d67249d6b192b00f7108bcfd
- version: 2.0

## Description

Since No wick act as strong magnets for price action. 

In this you will see candle with No Wicks
[list]
[*]Bullish - No bottom wick
[*]Bearish - No top wick 
[*]Liquidity Lines - Untapped Liquidity at No Wicks candle

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alphachinozz
//@version=6
//@version=6
indicator("No-Wick Candle Liquidity Lines [Improved]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── INPUTS ──
showBull      = input.bool(true,  "Show Bullish No-Bottom-Wick")
showBear      = input.bool(true,  "Show Bearish No-Top-Wick")
maxExtendBars = input.int(200,    "Max Extend Bars (0 = until crossed)", minval=0)
lineWidth     = input.int(2,      "Line Width")
bullColor     = input.color(color.new(color.green, 0), "Bullish Line Color")
bearColor     = input.color(color.new(color.red, 0),   "Bearish Line Color")

useWickForLiquidity = input.bool(true, "Remove Line on Wick Touch (True = More Sensitive)")

// ── DETECTION ──
bullNoWick = (close > open) and (low == open)
bearNoWick = (close < open) and (high == open)

// ── MARKERS ──
plotshape(bullNoWick and showBull, title="Bull No Bottom Wick", location=location.belowbar, 
          color=color.green, style=shape.triangleup, size=size.small)

plotshape(bearNoWick and showBear, title="Bear No Top Wick", location=location.abovebar, 
          color=color.red, style=shape.triangledown, size=size.small)

// ── ARRAYS ──
var line[]   bullLines  = array.new<line>()
var line[]   bearLines  = array.new<line>()
var float[]  bullLevels = array.new<float>()
var float[]  bearLevels = array.new<float>()

// ── CREATE NEW LINES ──
if bullNoWick and showBull
    level   = open
    newLine = line.new(bar_index, level, bar_index + (maxExtendBars > 0 ? maxExtendBars : 500), level,
                       color = bullColor, width = lineWidth)
    array.push(bullLines, newLine)
    array.push(bullLevels, level)

if bearNoWick and showBear
    level   = open
    newLine = line.new(bar_index, level, bar_index + (maxExtendBars > 0 ? maxExtendBars : 500), level,
                       color = bearColor, width = lineWidth)
    array.push(bearLines, newLine)
    array.push(bearLevels, level)

// ── IMPROVED UPDATE FUNCTION ──
updateLines(lineArr, levelArr, isBull) =>
    int size = array.size(lineArr)
    for i = size - 1 to 0
        if size > 0
            line  l   = array.get(lineArr, i)
            float lvl = array.get(levelArr, i)
            
            // Extend line
            line.set_x2(l, bar_index)
            
            // Liquidity Taken Logic
            bool crossed = false
            if isBull
                // Bullish support line → remove if price goes below
                crossed := useWickForLiquidity ? (low < lvl) : (close < lvl)
            else
                // Bearish resistance line → remove if price goes above
                crossed := useWickForLiquidity ? (high > lvl) : (close > lvl)
            
            if crossed
                line.delete(l)
                array.remove(lineArr, i)
                array.remove(levelArr, i)

// ── EXECUTE ──
updateLines(bullLines, bullLevels, true)
updateLines(bearLines, bearLevels, false)

// Background
bgcolor(bullNoWick ? color.new(color.green, 90) : na)
bgcolor(bearNoWick ? color.new(color.red, 90)   : na)
````
