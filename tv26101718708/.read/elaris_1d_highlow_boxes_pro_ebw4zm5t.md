# Elaris 1D High-Low Boxes Pro

- url: https://www.tradingview.com/script/ebW4Zm5T-Elaris-1D-High-Low-Boxes-Pro/
- type: indicator
- pine_id: PUB;2f50193612dc4c13b5aa2f8b14aebda3
- version: 1.0

## Description

# Elaris 1D High-Low Boxes Pro

This indicator was built around a simple idea:

Higher timeframe ranges often control intraday price behavior more than most traders realize.

The script maps Daily range activity directly onto lower timeframes and focuses on how price reacts around previous highs, lows, compression zones, and liquidity areas during the session.

Instead of plotting static support/resistance levels, the indicator continuously tracks the active Daily range and updates its structure in real time as the session develops.

Main features included in the script:

• Dynamic Daily high-low boxes
• Previous Daily high/low projections
• Liquidity sweep detection
• Volatility compression detection
• Expansion projection levels
• Market condition dashboard
• Bullish/Bearish range visualization

The liquidity sweep logic is designed to highlight situations where price trades above or below a previous Daily level and quickly reclaims the range. These areas can sometimes provide useful context for reversals, failed breakouts, or continuation setups.

The compression engine monitors decreasing Daily ranges and attempts to identify periods where volatility is contracting before expansion. When compression conditions appear, the script labels the chart to indicate potential pressure buildup.

Projected expansion zones are calculated using previous Daily range behavior and can be used as reference areas during breakout conditions.

Recommended usage:

* Intraday trading
* Scalping
* Session trading
* Market structure analysis
* Liquidity-based trading models

Recommended chart timeframes:

* 5m
* 15m
* 30m
* 1H

The script is intended as a market context and visualization tool rather than a standalone trading system.

Built by ElarisGroup.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © ElarisGroup

//@version=6
indicator("Elaris 1D High-Low Boxes Pro", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
d1Tf = input.timeframe("1D", "Box Timeframe")
showSweeps = input.bool(true, "Show Liquidity Sweeps")
showProjection = input.bool(true, "Show Expansion Projection")
showDashboard = input.bool(true, "Show Dashboard")

compressionLookback = input.int(3, "Compression Lookback", minval=2)
projectionMultiplier = input.float(1.0, "Projection Multiplier", minval=0.25, step=0.25)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// D1 Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
d1Time = request.security(syminfo.tickerid, d1Tf, time)
isNewD1 = ta.change(d1Time) != 0

barCount = int(24 * 60 / timeframe.multiplier)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Persistent Box Variables
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float d1High = na
var float d1Low = na
var float d1Open = na
var float prevD1High = na
var float prevD1Low = na
var float prevD1Range = na

var box currentBox = na
var bool wasNewD1 = false

var line prevHighLine = na
var line prevLowLine = na
var line projectionUpLine = na
var line projectionDownLine = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Finalize Previous Box
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isNewD1 and not na(currentBox)
    box.set_right(currentBox, bar_index - 1)

    prevD1High := d1High
    prevD1Low := d1Low
    prevD1Range := d1High - d1Low

    if not na(prevHighLine)
        line.delete(prevHighLine)

    if not na(prevLowLine)
        line.delete(prevLowLine)

    prevHighLine := line.new(bar_index, prevD1High, bar_index + barCount, prevD1High, extend=extend.right, color=color.new(color.red, 20), style=line.style_dashed)
    prevLowLine := line.new(bar_index, prevD1Low, bar_index + barCount, prevD1Low, extend=extend.right, color=color.new(color.green, 20), style=line.style_dashed)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Start New Box With One-Bar Delay
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if wasNewD1
    d1Open := open
    d1High := high
    d1Low := low

    currentBox := box.new(
         left=bar_index,
         right=bar_index + barCount - 1,
         top=high,
         bottom=low,
         border_color=color.gray,
         bgcolor=color.new(color.gray, 85)
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Update Current D1 Box
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not isNewD1
    d1High := math.max(nz(d1High, high), high)
    d1Low := math.min(nz(d1Low, low), low)

    if not na(currentBox)
        box.set_top(currentBox, d1High)
        box.set_bottom(currentBox, d1Low)

if not na(currentBox) and not na(d1Open)
    isBull = close >= d1Open
    box.set_bgcolor(currentBox, isBull ? color.new(color.green, 75) : color.new(color.maroon, 75))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Liquidity Sweep Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buySideSweep = showSweeps and not na(prevD1High) and high > prevD1High and close < prevD1High
sellSideSweep = showSweeps and not na(prevD1Low) and low < prevD1Low and close > prevD1Low

if buySideSweep
    label.new(
         bar_index,
         high,
         "BUY-SIDE LIQUIDITY TAKEN",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white
    )

if sellSideSweep
    label.new(
         bar_index,
         low,
         "SELL-SIDE LIQUIDITY TAKEN",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Compression Engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
d1Range = d1High - d1Low

range1 = request.security(syminfo.tickerid, d1Tf, high[1] - low[1])
range2 = request.security(syminfo.tickerid, d1Tf, high[2] - low[2])
range3 = request.security(syminfo.tickerid, d1Tf, high[3] - low[3])

isCompression = range1 < range2 and range2 < range3

if isNewD1 and isCompression
    label.new(
         bar_index,
         close,
         "PRESSURE BUILDING\nVolatility Compression",
         style=label.style_label_left,
         color=color.new(color.orange, 0),
         textcolor=color.white
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Expansion Projection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
projectedRange = prevD1Range * projectionMultiplier
projectedUp = not na(prevD1High) and not na(projectedRange) ? prevD1High + projectedRange : na
projectedDown = not na(prevD1Low) and not na(projectedRange) ? prevD1Low - projectedRange : na

if isNewD1 and showProjection and not na(projectedUp) and not na(projectedDown)
    if not na(projectionUpLine)
        line.delete(projectionUpLine)

    if not na(projectionDownLine)
        line.delete(projectionDownLine)

    projectionUpLine := line.new(bar_index, projectedUp, bar_index + barCount, projectedUp, extend=extend.right, color=color.new(color.blue, 20), style=line.style_dotted)
    projectionDownLine := line.new(bar_index, projectedDown, bar_index + barCount, projectedDown, extend=extend.right, color=color.new(color.blue, 20), style=line.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Premium Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     position.top_right,
     2,
     6,
     border_width = 1,
     frame_color = color.new(color.white, 70),
     border_color = color.new(color.white, 70)
)

boxState = close >= d1Open ? "Bullish" : "Bearish"
compressionState = isCompression ? "HIGH" : "Normal"

rangeText = not na(d1Range)
     ? str.tostring(d1Range, format.mintick)
     : "N/A"

prevRangeText = not na(prevD1Range)
     ? str.tostring(prevD1Range, format.mintick)
     : "N/A"

biasColor =
     boxState == "Bullish"
     ? color.new(color.green, 0)
     : color.new(color.red, 0)

compressionColor =
     compressionState == "HIGH"
     ? color.new(color.orange, 0)
     : color.new(color.gray, 20)

headerBg = color.rgb(15, 15, 20)
cellBg = color.rgb(25, 25, 35)
textCol = color.white

if showDashboard and barstate.islast

    // Header
    table.cell(
         dash,
         0,
         0,
         "Elaris D1 Engine",
         text_color = color.white,
         bgcolor = headerBg,
         text_size = size.normal
    )

    table.cell(
         dash,
         1,
         0,
         "LIVE",
         text_color = color.lime,
         bgcolor = headerBg,
         text_size = size.normal
    )

    // Bias
    table.cell(dash, 0, 1, "Current Bias", text_color=textCol, bgcolor=cellBg)
    table.cell(dash, 1, 1, boxState, text_color=color.white, bgcolor=biasColor)

    // Current Range
    table.cell(dash, 0, 2, "Current Range", text_color=textCol, bgcolor=cellBg)
    table.cell(dash, 1, 2, rangeText, text_color=color.white, bgcolor=cellBg)

    // Previous Range
    table.cell(dash, 0, 3, "Previous Range", text_color=textCol, bgcolor=cellBg)
    table.cell(dash, 1, 3, prevRangeText, text_color=color.white, bgcolor=cellBg)

    // Compression
    table.cell(dash, 0, 4, "Compression", text_color=textCol, bgcolor=cellBg)
    table.cell(dash, 1, 4, compressionState, text_color=color.white, bgcolor=compressionColor)

    // Liquidity
    liquidityState =
         buySideSweep
         ? "BUY SWEEP"
         : sellSideSweep
         ? "SELL SWEEP"
         : "Neutral"

    liquidityColor =
         buySideSweep
         ? color.new(color.red, 0)
         : sellSideSweep
         ? color.new(color.green, 0)
         : color.new(color.gray, 20)

    table.cell(dash, 0, 5, "Liquidity", text_color=textCol, bgcolor=cellBg)
    table.cell(dash, 1, 5, liquidityState, text_color=color.white, bgcolor=liquidityColor)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trigger Flag
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wasNewD1 := isNewD1
````
