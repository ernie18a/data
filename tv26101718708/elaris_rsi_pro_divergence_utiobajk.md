# Elaris RSI Pro [Divergence]

- url: https://www.tradingview.com/script/utiOBaJk-Elaris-RSI-Pro-Divergence/
- type: indicator
- pine_id: PUB;cb50a4a3ed4a4e72bab7a3759aea2baa
- version: 1.0

## Description

Elaris RSI Pro [Divergence] is a professional-grade RSI momentum and divergence indicator built for traders who want cleaner market structure signals, smarter divergence detection, and a more refined trading workflow.

The indicator combines a responsive RSI engine with advanced bullish and bearish divergence detection to help identify potential reversals, continuation setups, and momentum shifts across all market conditions.

Designed with a clean visual experience and optimized performance in mind, Elaris RSI Pro delivers clear signals without unnecessary chart clutter, making it suitable for scalpers, swing traders, and intraday traders alike.

Key Features:
• Regular Bullish & Bearish Divergence Detection
• Hidden Bullish & Bearish Divergence Detection
• Configurable Pivot Detection Engine
• Adjustable Minimum & Maximum Pivot Distance Filters
• Dynamic RSI Momentum Coloring
• Signal Smoothing with EMA Filter
• Overbought / Oversold Zone Visualization
• Optional Divergence Lines & Labels
• Optional Pivot Markers for Advanced Analysis
• Professional Alert Conditions
• Non-Repainting Confirmed Pivot Logic
• Optimized Object Management for Better Performance

Elaris RSI Pro is built using confirmed pivot logic, meaning divergence signals are generated only after pivot confirmation to reduce repainting behavior and improve signal reliability.

The indicator is highly customizable, allowing traders to adapt the sensitivity and visual behavior to different trading styles, markets, and timeframes.

Works well with:
• Market Structure Analysis
• Trend Following Systems
• Support & Resistance Trading
• Smart Money Concepts (SMC)
• Liquidity Sweep Confirmation
• Multi-Timeframe Confluence Strategies

Best used alongside proper risk management and confirmation tools.

Non-Repainting:
This indicator uses confirmed pivot-based calculations. Signals appear only after pivot confirmation and do not repaint historically after confirmation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ElarisGroup



//@version=6
indicator("Elaris RSI Pro [Divergence]", shorttitle="Elaris RSI Pro", overlay=false, precision=2, max_lines_count=200, max_labels_count=200)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupRsi = "RSI"
groupDiv = "Divergence"
groupVis = "Visuals"
groupAlt = "Alerts"

rsiLength      = input.int(14, "Length", minval=2, group=groupRsi)
rsiSource      = input.source(close, "Source", group=groupRsi)
signalLength   = input.int(9, "Signal Smoothing", minval=1, group=groupRsi)
overbought     = input.int(70, "Overbought", minval=50, maxval=100, group=groupRsi)
oversold       = input.int(30, "Oversold", minval=0, maxval=50, group=groupRsi)
midline        = input.int(50, "Midline", minval=0, maxval=100, group=groupRsi)

pivotLeft      = input.int(5, "Pivot Left", minval=1, maxval=20, group=groupDiv)
pivotRight     = input.int(5, "Pivot Right", minval=1, maxval=20, group=groupDiv)
minBarsBetween = input.int(5, "Min Bars Between Pivots", minval=1, maxval=100, group=groupDiv)
maxBarsBetween = input.int(60, "Max Bars Between Pivots", minval=2, maxval=300, group=groupDiv)
showRegular    = input.bool(true, "Regular Divergence", group=groupDiv)
showHidden     = input.bool(true, "Hidden Divergence", group=groupDiv)

showSignal     = input.bool(true, "Show Signal Line", group=groupVis)
showZones      = input.bool(true, "Show OB/OS Zones", group=groupVis)
showPivotMarks = input.bool(false, "Show Pivot Marks", group=groupVis)
showLines      = input.bool(true, "Show Divergence Lines", group=groupVis)
showLabels     = input.bool(true, "Show Divergence Labels", group=groupVis)
maxObjects     = input.int(50, "Stored Divergences", minval=10, maxval=200, group=groupVis)

alertsOnClose  = input.bool(true, "Only Trigger On Bar Close", group=groupAlt)

//------------------------------------------------------------------------------
// RSI
//------------------------------------------------------------------------------
rsi = ta.rsi(rsiSource, rsiLength)
signal = ta.ema(rsi, signalLength)

rsiColor = rsi >= midline ? color.new(color.teal, 0) : color.new(color.orange, 0)

plot(rsi, "RSI", color=rsiColor, linewidth=2)
plot(showSignal ? signal : na, "Signal", color=color.new(color.white, 20), linewidth=2)

hOb  = hline(overbought, "Overbought", color=color.new(color.red, 35), linestyle=hline.style_dashed)
hOs  = hline(oversold, "Oversold", color=color.new(color.lime, 35), linestyle=hline.style_dashed)
hMid = hline(midline, "Midline", color=color.new(color.gray, 65), linestyle=hline.style_dotted)

fill(hOb, hMid, color=showZones ? color.new(color.red, 92) : na, title="Overbought Zone")
fill(hOs, hMid, color=showZones ? color.new(color.green, 92) : na, title="Oversold Zone")

//------------------------------------------------------------------------------
// Pivot detection
//------------------------------------------------------------------------------
pricePivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)
pricePivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

isPivotLow  = not na(pricePivotLow)
isPivotHigh = not na(pricePivotHigh)

pivotLowBar   = isPivotLow ? bar_index - pivotRight : na
pivotHighBar  = isPivotHigh ? bar_index - pivotRight : na
pivotLowPrice = isPivotLow ? low[pivotRight] : na
pivotHighPrice= isPivotHigh ? high[pivotRight] : na
pivotLowRsi   = isPivotLow ? rsi[pivotRight] : na
pivotHighRsi  = isPivotHigh ? rsi[pivotRight] : na

plotshape(showPivotMarks and isPivotLow  ? pivotLowRsi  : na,
     title="Pivot Low",
     style=shape.circle,
     location=location.absolute,
     color=color.new(color.lime, 0),
     size=size.tiny)

plotshape(showPivotMarks and isPivotHigh ? pivotHighRsi : na,
     title="Pivot High",
     style=shape.circle,
     location=location.absolute,
     color=color.new(color.red, 0),
     size=size.tiny)
//------------------------------------------------------------------------------
// Pivot state
//------------------------------------------------------------------------------
var float prevLowPrice  = na
var float prevLowRsi    = na
var int   prevLowBar    = na

var float prevHighPrice = na
var float prevHighRsi   = na
var int   prevHighBar   = na

var line[]  divLines  = array.new_line()
var label[] divLabels = array.new_label()

trimObjects() =>
    while array.size(divLines) > maxObjects
        l = array.shift(divLines)
        line.delete(l)
    while array.size(divLabels) > maxObjects
        lb = array.shift(divLabels)
        label.delete(lb)

validPivotDistance(prevBar, currBar) =>
    not na(prevBar) and not na(currBar) and (currBar - prevBar >= minBarsBetween) and (currBar - prevBar <= maxBarsBetween)

barReady() =>
    alertsOnClose ? barstate.isconfirmed : true

drawDivergence(x1, y1, x2, y2, txt, lineColor, labelStyle) =>
    if showLines
        l = line.new(x1, y1, x2, y2, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=2)
        array.push(divLines, l)
    if showLabels
        lb = label.new(x2, y2, txt, xloc=xloc.bar_index, style=labelStyle, color=lineColor, textcolor=color.white, size=size.small)
        array.push(divLabels, lb)
    trimObjects()

//------------------------------------------------------------------------------
// Divergence logic
//------------------------------------------------------------------------------
var bool regularBull = false
var bool hiddenBull  = false
var bool regularBear = false
var bool hiddenBear  = false

regularBull := false
hiddenBull  := false
regularBear := false
hiddenBear  := false

if isPivotLow and barReady()
    canCompare = validPivotDistance(prevLowBar, pivotLowBar)

    if canCompare
        regularBull := showRegular and pivotLowPrice < prevLowPrice and pivotLowRsi > prevLowRsi
        hiddenBull  := showHidden and pivotLowPrice > prevLowPrice and pivotLowRsi < prevLowRsi

        if regularBull
            drawDivergence(prevLowBar, prevLowRsi, pivotLowBar, pivotLowRsi, "RB", color.new(color.lime, 0), label.style_label_up)

        if hiddenBull
            drawDivergence(prevLowBar, prevLowRsi, pivotLowBar, pivotLowRsi, "HB", color.new(color.teal, 0), label.style_label_up)

    prevLowPrice := pivotLowPrice
    prevLowRsi   := pivotLowRsi
    prevLowBar   := pivotLowBar

if isPivotHigh and barReady()
    canCompare = validPivotDistance(prevHighBar, pivotHighBar)

    if canCompare
        regularBear := showRegular and pivotHighPrice > prevHighPrice and pivotHighRsi < prevHighRsi
        hiddenBear  := showHidden and pivotHighPrice < prevHighPrice and pivotHighRsi > prevHighRsi

        if regularBear
            drawDivergence(prevHighBar, prevHighRsi, pivotHighBar, pivotHighRsi, "RS", color.new(color.red, 0), label.style_label_down)

        if hiddenBear
            drawDivergence(prevHighBar, prevHighRsi, pivotHighBar, pivotHighRsi, "HS", color.new(color.orange, 0), label.style_label_down)

    prevHighPrice := pivotHighPrice
    prevHighRsi   := pivotHighRsi
    prevHighBar   := pivotHighBar

//------------------------------------------------------------------------------
// Markers
//------------------------------------------------------------------------------
plotshape(regularBull ? pivotLowRsi : na, title="Regular Bullish Divergence", style=shape.triangleup, location=location.absolute, color=color.new(color.lime, 0), size=size.small, text="RB", textcolor=color.white)
plotshape(hiddenBull ? pivotLowRsi : na,  title="Hidden Bullish Divergence",  style=shape.triangleup, location=location.absolute, color=color.new(color.teal, 0), size=size.small, text="HB", textcolor=color.white)

plotshape(regularBear ? pivotHighRsi : na, title="Regular Bearish Divergence", style=shape.triangledown, location=location.absolute, color=color.new(color.red, 0), size=size.small, text="RS", textcolor=color.white)
plotshape(hiddenBear ? pivotHighRsi : na,  title="Hidden Bearish Divergence",  style=shape.triangledown, location=location.absolute, color=color.new(color.orange, 0), size=size.small, text="HS", textcolor=color.white)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(regularBull, title="Regular Bullish Divergence", message="Elaris RSI Pro: Regular Bullish Divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBull,  title="Hidden Bullish Divergence",  message="Elaris RSI Pro: Hidden Bullish Divergence on {{ticker}} ({{interval}})")
alertcondition(regularBear, title="Regular Bearish Divergence", message="Elaris RSI Pro: Regular Bearish Divergence on {{ticker}} ({{interval}})")
alertcondition(hiddenBear,  title="Hidden Bearish Divergence",  message="Elaris RSI Pro: Hidden Bearish Divergence on {{ticker}} ({{interval}})")

alertcondition(regularBull or hiddenBull, title="Any Bullish Divergence", message="Elaris RSI Pro: Bullish divergence on {{ticker}} ({{interval}})")
alertcondition(regularBear or hiddenBear, title="Any Bearish Divergence", message="Elaris RSI Pro: Bearish divergence on {{ticker}} ({{interval}})")
````
