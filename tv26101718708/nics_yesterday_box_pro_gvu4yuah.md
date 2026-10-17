# NICS Yesterday Box PRO

- url: https://www.tradingview.com/script/gVU4yUAH-NICS-Yesterday-Box-PRO/
- type: indicator
- pine_id: PUB;e952a001a03642fab1f6aa00478b5f96
- version: 1.0

## Description

[b]NICS Yesterday Box PRO[/b]

NICS Yesterday Box PRO automatically plots the previous trading day's High, Low, and Midpoint, providing clean institutional reference levels for intraday trading.

Designed for Smart Money Concepts (SMC), ICT, price action, futures, forex, crypto, indices, and commodities.

[b]Features[/b]

• Automatic Yesterday High (YH)
• Automatic Yesterday Low (YL)
• Automatic Yesterday Mid (50%)
• Auto-refresh at the beginning of every trading day
• Optional line extension
• Customizable colors and line width
• Lightweight and optimized Pine Script v6 implementation

[b]Best Used For
[/b]
• Intraday support & resistance
• Liquidity targets
• Market structure analysis
• Breakout confirmation
• Mean reversion setups
• ICT / SMC trading models
• Session-based trading

[b]Markets[/b]

Works on all TradingView-supported markets:

• Forex
• Cryptocurrency
• Stocks
• Futures
• Commodities
• Indices

[b]Recommended Timeframes[/b]

Optimized for:

• 1 Minute
• 3 Minute
• 5 Minute
• 15 Minute
• 30 Minute
• 1 Hour

[b]About NICS[/b]

NICS (Neural Intelligent Cognitive System) develops professional AI-powered trading tools and institutional market analysis solutions for discretionary and systematic traders.

© AI Byte Consult Ltd.
NICS AI Ecosystem

## Source Code

````pine
//@version=6
indicator("NICS Yesterday Box PRO", overlay = true, max_lines_count = 100, max_labels_count = 100)

//====================
// INPUTS
//====================

showHigh = input.bool(true, "Yesterday High")
showLow  = input.bool(true, "Yesterday Low")
showMid  = input.bool(true, "Yesterday Mid")

extendRight = input.bool(true, "Extend Right")

highColor = input.color(color.red, "High Color")
lowColor  = input.color(color.lime, "Low Color")
midColor  = input.color(color.orange, "Mid Color")

lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5)

//====================
// YESTERDAY DATA
//====================

yHigh = request.security(syminfo.tickerid, "D", high[1])
yLow  = request.security(syminfo.tickerid, "D", low[1])

yMid = (yHigh + yLow) / 2.0

//====================
// NEW DAY
//====================

newDay = ta.change(time("D")) != 0

//====================
// OBJECTS
//====================

var line highLine = na
var line lowLine  = na
var line midLine  = na

var label highLabel = na
var label lowLabel  = na
var label midLabel  = na

//====================
// DRAW
//====================

if barstate.isfirst or newDay

    if not na(highLine)
        line.delete(highLine)

    if not na(lowLine)
        line.delete(lowLine)

    if not na(midLine)
        line.delete(midLine)

    if not na(highLabel)
        label.delete(highLabel)

    if not na(lowLabel)
        label.delete(lowLabel)

    if not na(midLabel)
        label.delete(midLabel)

    ext = extendRight ? extend.right : extend.none

    if showHigh
        highLine := line.new(
             bar_index,
             yHigh,
             bar_index + 1,
             yHigh,
             extend = ext,
             color = highColor,
             width = lineWidth)

        highLabel := label.new(
             bar_index,
             yHigh,
             "YH",
             style = label.style_label_left,
             color = highColor,
             textcolor = color.white)

    if showLow
        lowLine := line.new(
             bar_index,
             yLow,
             bar_index + 1,
             yLow,
             extend = ext,
             color = lowColor,
             width = lineWidth)

        lowLabel := label.new(
             bar_index,
             yLow,
             "YL",
             style = label.style_label_left,
             color = lowColor,
             textcolor = color.white)

    if showMid
        midLine := line.new(
             bar_index,
             yMid,
             bar_index + 1,
             yMid,
             extend = ext,
             color = midColor,
             width = lineWidth)

        midLabel := label.new(
             bar_index,
             yMid,
             "MID",
             style = label.style_label_left,
             color = midColor,
             textcolor = color.white)
````
