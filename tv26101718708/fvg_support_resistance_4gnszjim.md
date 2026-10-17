# FVG Support & Resistance

- url: https://www.tradingview.com/script/4GNSzjIM-FVG-Support-Resistance/
- type: indicator
- pine_id: PUB;b702c5deaa134d22bf07c29c1cf41f1a
- version: 1.0

## Description

[b]Auto FVG Target (1:2 RR)[/b]

This indicator automatically detects bullish and bearish Fair Value Gaps (FVGs) and helps traders visualize potential trade setups using a fixed Risk-to-Reward framework.
Features
Automatic detection of Bullish and Bearish Fair Value Gaps.
Clear FVG box visualization on the chart.
Entry signals based on price rejecting the Fair Value Gap and closing outside the zone.
Fixed Stop Loss calculated using the gap size (1× gap).
Automatic Take Profit based on a fixed 1:2 Risk-to-Reward ratio.
Buy and Sell labels for easy signal identification.
Configurable display settings for FVG visualization.
Designed to work across multiple markets and timeframes.
How It Works
A bullish Fair Value Gap is identified when the current candle's low is above the high of two candles earlier. A bearish Fair Value Gap is identified when the current candle's high is below the low of two candles earlier.
The indicator monitors these imbalance zones and waits for price to interact with them. When price rejects an FVG and closes outside the zone, a potential trade setup is generated. The stop loss is based on the size of the Fair Value Gap, while the take-profit target is automatically set to a fixed 1:2 Risk-to-Reward ratio.
Intended Use
This indicator is designed as a chart analysis tool to assist with identifying Fair Value Gap opportunities. It does not predict future price movement or guarantee profitable trades. Users should always combine its signals with their own analysis, risk management, and trading plan.
Notes
Works on all timeframes.
Suitable for Forex, Crypto, Indices, Commodities, and Stocks.
Best used alongside market structure, liquidity concepts, or other confirmation tools.
Historical results and plotted signals should not be considered a guarantee of future performance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Auto FVG Target v1 - Part 1", overlay=true, max_boxes_count=500)

// ===================== INPUTS =====================
showBull = input.bool(true, "Show Bullish FVG")
showBear = input.bool(true, "Show Bearish FVG")
extendBars = input.int(40, "Extend Boxes", minval=5)
bullColor = input.color(color.new(color.green, 80), "Bull FVG")
bearColor = input.color(color.new(color.red, 80), "Bear FVG")

// ===================== ARRAYS =====================
var box[] bullBoxes = array.new_box()
var box[] bearBoxes = array.new_box()

var float[] bullTop = array.new_float()
var float[] bullBottom = array.new_float()

var float[] bearTop = array.new_float()
var float[] bearBottom = array.new_float()

// ===================== FVG CONDITIONS =====================
bullFVG = low > high[2]
bearFVG = high < low[2]

// ===================== CREATE BULLISH BOX =====================
if bullFVG and showBull
    top = low
    bottom = high[2]

    b = box.new(
         left = bar_index - 2,
         right = bar_index + extendBars,
         top = top,
         bottom = bottom,
         bgcolor = bullColor,
         border_color = color.green)

    array.push(bullBoxes, b)
    array.push(bullTop, top)
    array.push(bullBottom, bottom)

// ===================== CREATE BEARISH BOX =====================
if bearFVG and showBear
    top = low[2]
    bottom = high

    b = box.new(
         left = bar_index - 2,
         right = bar_index + extendBars,
         top = top,
         bottom = bottom,
         bgcolor = bearColor,
         border_color = color.red)

    array.push(bearBoxes, b)
    array.push(bearTop, top)
    array.push(bearBottom, bottom)

// ===================== CLEAN FILLED BULL FVG =====================
if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        bot = array.get(bullBottom, i)

        if low <= bot
            box.delete(array.get(bullBoxes, i))
            array.remove(bullBoxes, i)
            array.remove(bullTop, i)
            array.remove(bullBottom, i)

// ===================== CLEAN FILLED BEAR FVG =====================
if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        top = array.get(bearTop, i)

        if high >= top
            box.delete(array.get(bearBoxes, i))
            array.remove(bearBoxes, i)
            array.remove(bearTop, i)
            array.remove(bearBottom, i)
````
