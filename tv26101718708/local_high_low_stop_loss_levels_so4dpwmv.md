# Local High Low Stop Loss Levels

- url: https://www.tradingview.com/script/sO4dpWmV-Local-High-Low-Stop-Loss-Levels/
- type: indicator
- pine_id: PUB;3f4606ed1a834beba729114052b02923
- version: 1.0

## Description

Local High Low Stop Loss Levels

Local High Low Stop Loss Levels is a lightweight risk management and structure-based indicator designed to automatically identify recent local highs and lows and project potential stop loss levels directly onto the chart.

Rather than placing stops at arbitrary distances, this indicator uses recent market structure and allows optional buffers to help account for volatility, market noise, and instrument behavior. The goal is to provide cleaner and more objective areas for risk placement based on actual price action.

Features:

• Automatically detects recent local highs and lows
• Dynamic stop level projection using market structure
• Supports custom calculation timeframes
• Optional "Wait Until Bar Close" confirmation logic
• Extend stop levels into future price action
• Optional labels displaying stop values

Buffer options:

• No buffer
• Tick-based buffer
• ATR-based buffer
• Percentage-based buffer

Display options:

• Local High stop levels
• Local Low stop levels
• Extend-right functionality
• Custom colors and labels

Alerts Included:

• Price broke below Local Low Stop Level
• Price broke above Local High Stop Level

Potential use cases:

• Place stop losses using recent structure
• Identify invalidation areas for trades
• Define risk levels for long and short positions
• Add confluence to existing strategies
• Reduce arbitrary stop placement decisions
• Monitor breakouts beyond recent extremes

Interpretation:

Local Low Stop Level

Represents a recent structural low with optional buffer adjustment and can be used as a potential invalidation level for long positions.

Local High Stop Level

Represents a recent structural high with optional buffer adjustment and can be used as a potential invalidation level for short positions.

This indicator is intended to provide a simple structure-based approach to stop placement while allowing flexibility across different instruments and trading styles.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Local High Low Stop Loss Levels", overlay=true, max_lines_count=100, max_labels_count=100)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
calcTF = input.timeframe("", "Calculation Timeframe (blank = chart TF)", group=grpCore)
lookback = input.int(20, "Local High/Low Lookback", minval=2, group=grpCore)
waitClose = input.bool(true, "Wait Until Bar Close", group=grpCore)

grpDisplay = "Display"
showLocalLow = input.bool(true, "Show Local Low SL", group=grpDisplay)
showLocalHigh = input.bool(true, "Show Local High SL", group=grpDisplay)
extendRight = input.bool(true, "Extend Lines Right", group=grpDisplay)
showLabels = input.bool(true, "Show Labels", group=grpDisplay)

grpBuffer = "Stop Buffer"
bufferMode = input.string("Ticks", "Buffer Mode", options=["None", "Ticks", "ATR", "Percent"], group=grpBuffer)
bufferTicks = input.int(5, "Buffer Ticks", minval=0, group=grpBuffer)
atrLen = input.int(14, "ATR Length", minval=1, group=grpBuffer)
atrMult = input.float(0.25, "ATR Multiplier", minval=0.0, step=0.05, group=grpBuffer)
percentBuffer = input.float(0.10, "Percent Buffer", minval=0.0, step=0.01, group=grpBuffer)

grpColors = "Colors"
lowColor = input.color(color.lime, "Local Low Line Color", group=grpColors)
highColor = input.color(color.red, "Local High Line Color", group=grpColors)
labelTextColor = input.color(color.white, "Label Text Color", group=grpColors)

tfToUse = calcTF == "" ? timeframe.period : calcTF
lookaheadMode = waitClose ? barmerge.lookahead_off : barmerge.lookahead_on

//====================================================
// HTF/LTF calculations
//====================================================
tfLow = request.security(syminfo.tickerid, tfToUse, ta.lowest(low, lookback), barmerge.gaps_off, lookaheadMode)
tfHigh = request.security(syminfo.tickerid, tfToUse, ta.highest(high, lookback), barmerge.gaps_off, lookaheadMode)
tfATR = request.security(syminfo.tickerid, tfToUse, ta.atr(atrLen), barmerge.gaps_off, lookaheadMode)

bufferValue(_price) =>
    bufferMode == "None" ? 0.0 :
     bufferMode == "Ticks" ? bufferTicks * syminfo.mintick :
     bufferMode == "ATR" ? tfATR * atrMult :
     _price * (percentBuffer / 100.0)

lowSL = tfLow - bufferValue(tfLow)
highSL = tfHigh + bufferValue(tfHigh)

//====================================================
// Lines
//====================================================
var line lowLine = na
var line highLine = na
var label lowLabel = na
var label highLabel = na

lineExtend = extendRight ? extend.right : extend.none

if barstate.islast
    if not na(lowLine)
        line.delete(lowLine)
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLabel)
        label.delete(lowLabel)
    if not na(highLabel)
        label.delete(highLabel)

    if showLocalLow and not na(lowSL)
        lowLine := line.new(
             bar_index - lookback,
             lowSL,
             bar_index,
             lowSL,
             xloc=xloc.bar_index,
             extend=lineExtend,
             color=lowColor,
             width=2
         )

        if showLabels
            lowLabel := label.new(
                 bar_index,
                 lowSL,
                 "Local Low SL: " + str.tostring(lowSL, format.mintick),
                 style=label.style_label_left,
                 color=lowColor,
                 textcolor=labelTextColor
             )

    if showLocalHigh and not na(highSL)
        highLine := line.new(
             bar_index - lookback,
             highSL,
             bar_index,
             highSL,
             xloc=xloc.bar_index,
             extend=lineExtend,
             color=highColor,
             width=2
         )

        if showLabels
            highLabel := label.new(
                 bar_index,
                 highSL,
                 "Local High SL: " + str.tostring(highSL, format.mintick),
                 style=label.style_label_left,
                 color=highColor,
                 textcolor=labelTextColor
             )

//====================================================
// Optional plots for data window
//====================================================
plot(showLocalLow ? lowSL : na, title="Local Low Stop Level", color=lowColor, display=display.none)
plot(showLocalHigh ? highSL : na, title="Local High Stop Level", color=highColor, display=display.none)

//====================================================
// Alerts
//====================================================
breakBelowLowSL = ta.crossunder(close, lowSL)
breakAboveHighSL = ta.crossover(close, highSL)

alertcondition(breakBelowLowSL, title="Price Broke Local Low SL", message="Price broke below local low stop level on {{ticker}} {{interval}}")
alertcondition(breakAboveHighSL, title="Price Broke Local High SL", message="Price broke above local high stop level on {{ticker}} {{interval}}")
````
