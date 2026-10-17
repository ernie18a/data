# Current TF Open Line - Daily / 6H / 90M

- url: https://www.tradingview.com/script/64S0pNOE-Current-TF-Open-Line-Daily-6H-90M/
- type: indicator
- pine_id: PUB;af9a187bcfe345a2a0f6728560ce1b4f
- version: 1.0

## Description

Current TF Open Line is a lightweight price reference indicator that automatically plots the opening price of the currently active timeframe candle.

The indicator detects whether the chart is set to Daily (1D), 6 Hour (6H), or 90 Minute (90M) and draws a clean horizontal line at the candle's opening price.

This provides traders with an immediate visual reference for market bias, premium & discount analysis, liquidity positioning, and intraday decision making.

Features:

• Automatic Timeframe Detection
• Daily Open Tracking
• 6 Hour Open Tracking
• 90 Minute Open Tracking
• Custom Colors
• Adjustable Line Width
• Multiple Line Styles
• Configurable Historical Projection
• Clean Minimal Design

Ideal for traders using ICT concepts, market structure, session analysis, and time-based trading models who want a clear view of the most important opening price levels.

## Source Code

````pine
//@version=6
indicator("Current TF Open Line - Daily / 6H / 90M", overlay=true, max_lines_count=50)

// ─────────────────────
// Inputs
// ─────────────────────
showDaily = input.bool(true, "Enable Daily Open")
show6H    = input.bool(true, "Enable 6H Open")
show90M   = input.bool(true, "Enable 90M Open")

dailyColor = input.color(color.green, "Daily Open Color")
h6Color    = input.color(color.blue, "6H Open Color")
m90Color   = input.color(color.orange, "90M Open Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
leftBars  = input.int(500, "How Many Bars Left", minval=10, maxval=5000)

lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleInput == "Solid" ? line.style_solid :
     lineStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

// ─────────────────────
// Detect current chart timeframe
// ─────────────────────
isDailyChart = timeframe.isdaily
is6HChart    = timeframe.isminutes and timeframe.multiplier == 360
is90MChart   = timeframe.isminutes and timeframe.multiplier == 90

activeDaily = isDailyChart and showDaily
active6H    = is6HChart and show6H
active90M   = is90MChart and show90M

isActiveTF = activeDaily or active6H or active90M

activeColor = activeDaily ? dailyColor :
     active6H ? h6Color :
     active90M ? m90Color :
     color.green

// ─────────────────────
// Current candle open line - FROM CURRENT BAR LEFT ONLY
// ─────────────────────
var line openLine = na

if barstate.islast
    if not na(openLine)
        line.delete(openLine)

    if isActiveTF
        openLine := line.new(
             x1=bar_index - leftBars,
             y1=open,
             x2=bar_index,
             y2=open,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=activeColor,
             width=lineWidth,
             style=lineStyle
         )
    else
        openLine := na
````
