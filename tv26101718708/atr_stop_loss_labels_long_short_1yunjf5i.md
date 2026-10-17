# ATR Stop Loss Labels (Long / Short)

- url: https://www.tradingview.com/script/1YUnjF5i-ATR-Stop-Loss-Labels-Long-Short/
- type: indicator
- pine_id: PUB;6f14ccdcc37f469590b5fb93da5e36da
- version: 2.0

## Description

ATR Stop Loss Labels (Long / Short)

Description:

This indicator provides a clean and practical way to calculate and display ATR-based stop loss levels directly on the chart—without cluttering it with lines.

Instead of drawing dynamic lines, it shows clear labels for Long and Short stop levels on the latest candle, making it ideal for traders who want precise risk levels without visual noise.

How it works:

The script uses the Average True Range (ATR) to measure market volatility.
A user-defined multiplier is applied to the ATR to calculate stop distances.
Stop levels are updated in real-time based on the latest price.

Stop Loss Logic:

Long SL: Close − (ATR × Multiplier)
Short SL: Close + (ATR × Multiplier)

Features:

Toggle between Long, Short, or Both stop loss labels
Clean label-based display (no lines, no clutter)
Real-time updates on the latest candle
Built-in ATR value display table
Customizable colors and settings

Best Use Cases:

Intraday trading (15m / 1H)
Swing trading (4H / 1D)
Works well with trend-following systems (EMA, RSI, etc.)
Ideal for traders who prefer manual entries with structured risk management

Recommended Settings:

Multiplier 1.5–2.0 → tighter stops (intraday)
Multiplier 2.0–2.5 → wider stops (swing trades)

Notes:

This indicator does not generate buy/sell signals.
It is designed purely for risk management and stop placement.
For best results, combine it with your own entry strategy.

Summary:
A simple, professional tool to define stop losses using volatility—focused on clarity, speed, and practical trading execution.

## Source Code

````pine
//@version=6
indicator("ATR SL + TP Zones Labels", shorttitle="ATR SL TP", overlay=true)

atrLength = input.int(14, "ATR Length")
atrMult   = input.float(2.5, "SL ATR Multiplier")

mode = input.string("Both", "Mode", options=["Long", "Short", "Both"])

tp1R = input.float(1.0, "TP1 R Multiple")
tp2R = input.float(2.0, "TP2 R Multiple")
tp3R = input.float(3.0, "TP3 R Multiple")

showSL    = input.bool(true, "Show SL Label")
showTP    = input.bool(true, "Show TP Labels")
showTable = input.bool(true, "Show Table")

slOffset  = input.int(25, "SL Label Offset Bars")
tp1Offset = input.int(50, "TP1 Label Offset Bars")
tp2Offset = input.int(50, "TP2 Label Offset Bars")
tp3Offset = input.int(50, "TP3 Label Offset Bars")

yOffsetATR = input.float(0.2, "Vertical Label Offset ATR Multiplier")

longColor  = input.color(color.teal, "Long Color")
shortColor = input.color(color.red, "Short Color")
textColor  = input.color(color.white, "Label Text Color")

atr = ta.atr(atrLength)
slDistance = atr * atrMult
yOffset = atr * yOffsetATR

longSL  = close - slDistance
shortSL = close + slDistance

longRisk  = close - longSL
shortRisk = shortSL - close

longTP1 = close + longRisk * tp1R
longTP2 = close + longRisk * tp2R
longTP3 = close + longRisk * tp3R

shortTP1 = close - shortRisk * tp1R
shortTP2 = close - shortRisk * tp2R
shortTP3 = close - shortRisk * tp3R

slPct = slDistance / close * 100

tp1Pct = slPct * tp1R
tp2Pct = slPct * tp2R
tp3Pct = slPct * tp3R

showLong  = mode == "Long" or mode == "Both"
showShort = mode == "Short" or mode == "Both"

var label l1 = na
var label l2 = na
var label l3 = na
var label l4 = na
var label l5 = na
var label l6 = na
var label l7 = na
var label l8 = na

if barstate.islast
    label.delete(l1), label.delete(l2), label.delete(l3), label.delete(l4)
    label.delete(l5), label.delete(l6), label.delete(l7), label.delete(l8)

    if showLong
        if showSL
            l1 := label.new(bar_index + slOffset, longSL - yOffset, "Long SL\n" + str.tostring(longSL, "#.##") + "\nDist: " + str.tostring(slPct, "#.##") + "%", color=longColor, textcolor=textColor)

        if showTP
            l2 := label.new(bar_index + tp1Offset, longTP1 + yOffset, "Long TP1\n" + str.tostring(longTP1, "#.##") + "\nDist: " + str.tostring(tp1Pct, "#.##") + "%", color=color.new(longColor, 0), textcolor=textColor)
            l3 := label.new(bar_index + tp2Offset, longTP2 + yOffset * 2, "Long TP2\n" + str.tostring(longTP2, "#.##") + "\nDist: " + str.tostring(tp2Pct, "#.##") + "%", color=color.new(longColor, 20), textcolor=textColor)
            l4 := label.new(bar_index + tp3Offset, longTP3 + yOffset * 3, "Long TP3\n" + str.tostring(longTP3, "#.##") + "\nDist: " + str.tostring(tp3Pct, "#.##") + "%", color=color.new(longColor, 40), textcolor=textColor)

    if showShort
        if showSL
            l5 := label.new(bar_index + slOffset, shortSL + yOffset, "Short SL\n" + str.tostring(shortSL, "#.##") + "\nDist: " + str.tostring(slPct, "#.##") + "%", color=shortColor, textcolor=textColor)

        if showTP
            l6 := label.new(bar_index + tp1Offset, shortTP1 - yOffset, "Short TP1\n" + str.tostring(shortTP1, "#.##") + "\nDist: " + str.tostring(tp1Pct, "#.##") + "%", color=color.new(shortColor, 0), textcolor=textColor)
            l7 := label.new(bar_index + tp2Offset, shortTP2 - yOffset * 2, "Short TP2\n" + str.tostring(shortTP2, "#.##") + "\nDist: " + str.tostring(tp2Pct, "#.##") + "%", color=color.new(shortColor, 20), textcolor=textColor)
            l8 := label.new(bar_index + tp3Offset, shortTP3 - yOffset * 3, "Short TP3\n" + str.tostring(shortTP3, "#.##") + "\nDist: " + str.tostring(tp3Pct, "#.##") + "%", color=color.new(shortColor, 40), textcolor=textColor)

var table t = table.new(position.bottom_center, 5, 1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "ATR: " + str.tostring(atr, "#.##"))
    table.cell(t, 1, 0, "SL Dist: " + str.tostring(slDistance, "#.##") + " / " + str.tostring(slPct, "#.##") + "%")
    table.cell(t, 2, 0, "TP1: " + str.tostring(tp1Pct, "#.##") + "%")
    table.cell(t, 3, 0, "TP2: " + str.tostring(tp2Pct, "#.##") + "%")
    table.cell(t, 4, 0, "TP3: " + str.tostring(tp3Pct, "#.##") + "%")

if barstate.islast and not showTable
    table.clear(t, 0, 0, 4, 0)
````
