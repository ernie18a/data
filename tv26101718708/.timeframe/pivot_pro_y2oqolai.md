# PIVOT PRO

- url: https://www.tradingview.com/script/Y2oqoLAI-PIVOT-PRO/
- type: indicator
- pine_id: PUB;3ead2d82c45f4cdcb32a1cefc3e5b7f0
- version: 1.0

## Description

Ernes Strategy Includes VWAP, ADR Range, Pivot Levels to help react to the market trends

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evelez2405

//@version=6
indicator("Institutional VWAP + Pivots + ADR PRO", overlay=true, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================

// VWAP
showVWAP      = input.bool(true, "Show VWAP")
vwapColor     = input.color(color.orange, "VWAP Color")

// Pivot Settings
pivotTF       = input.string("D", "Pivot Timeframe", options=["D", "W"])
showPivot     = input.bool(true, "Show Pivot")
showR1        = input.bool(true, "Show R1")
showR2        = input.bool(true, "Show R2")
showS1        = input.bool(true, "Show S1")
showS2        = input.bool(true, "Show S2")

// ADR Settings
showADR       = input.bool(true, "Show ADR Levels")
adrLength     = input.int(14, "ADR Length", minval=1)
showADRHigh   = input.bool(true, "Show ADR High")
showADRLow    = input.bool(true, "Show ADR Low")

// Styling
lineWidth     = input.int(2, "Line Width", minval=1, maxval=4)
extendLines   = input.bool(true, "Extend Right")
showLabels    = input.bool(true, "Show Labels")

// Alerts
enableAlerts  = input.bool(true, "Enable Alerts")

//====================================================
// STYLE
//====================================================

lineStyle  = line.style_dotted
lineExtend = extendLines ? extend.right : extend.none

//====================================================
// VWAP
//====================================================

vwap = ta.vwap(hlc3)

//====================================================
// PIVOTS
//====================================================

prevHigh = request.security(
     syminfo.tickerid,
     pivotTF,
     high[1]
)

prevLow = request.security(
     syminfo.tickerid,
     pivotTF,
     low[1]
)

prevClose = request.security(
     syminfo.tickerid,
     pivotTF,
     close[1]
)

pivot = (prevHigh + prevLow + prevClose) / 3

r1 = (2 * pivot) - prevLow
s1 = (2 * pivot) - prevHigh

r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)

//====================================================
// ADR
//====================================================

adr = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(high - low, adrLength)
)

todayOpen = request.security(
     syminfo.tickerid,
     "D",
     open
)

adrHigh = todayOpen + adr
adrLow  = todayOpen - adr

//====================================================
// LINE VARIABLES
//====================================================

var line lineVWAP = na
var line linePivot = na
var line lineR1 = na
var line lineR2 = na
var line lineS1 = na
var line lineS2 = na
var line lineADRHigh = na
var line lineADRLow = na

//====================================================
// DRAW CLEAN LINES
//====================================================

if barstate.islast

    // Delete previous lines
    line.delete(lineVWAP)
    line.delete(linePivot)
    line.delete(lineR1)
    line.delete(lineR2)
    line.delete(lineS1)
    line.delete(lineS2)
    line.delete(lineADRHigh)
    line.delete(lineADRLow)

    // VWAP
    if showVWAP
        lineVWAP := line.new(
             bar_index - 1,
             vwap,
             bar_index + 1,
             vwap,
             extend=lineExtend,
             color=vwapColor,
             width=lineWidth,
             style=lineStyle
         )

    // Pivot
    if showPivot
        linePivot := line.new(
             bar_index - 1,
             pivot,
             bar_index + 1,
             pivot,
             extend=lineExtend,
             color=color.white,
             width=lineWidth,
             style=lineStyle
         )

    // R1
    if showR1
        lineR1 := line.new(
             bar_index - 1,
             r1,
             bar_index + 1,
             r1,
             extend=lineExtend,
             color=color.red,
             width=lineWidth,
             style=lineStyle
         )

    // R2
    if showR2
        lineR2 := line.new(
             bar_index - 1,
             r2,
             bar_index + 1,
             r2,
             extend=lineExtend,
             color=color.maroon,
             width=lineWidth,
             style=lineStyle
         )

    // S1
    if showS1
        lineS1 := line.new(
             bar_index - 1,
             s1,
             bar_index + 1,
             s1,
             extend=lineExtend,
             color=color.lime,
             width=lineWidth,
             style=lineStyle
         )

    // S2
    if showS2
        lineS2 := line.new(
             bar_index - 1,
             s2,
             bar_index + 1,
             s2,
             extend=lineExtend,
             color=color.green,
             width=lineWidth,
             style=lineStyle
         )

    // ADR HIGH
    if showADR and showADRHigh
        lineADRHigh := line.new(
             bar_index - 1,
             adrHigh,
             bar_index + 1,
             adrHigh,
             extend=lineExtend,
             color=color.fuchsia,
             width=lineWidth,
             style=lineStyle
         )

    // ADR LOW
    if showADR and showADRLow
        lineADRLow := line.new(
             bar_index - 1,
             adrLow,
             bar_index + 1,
             adrLow,
             extend=lineExtend,
             color=color.aqua,
             width=lineWidth,
             style=lineStyle
         )

//====================================================
// LABELS
//====================================================

var label lblVWAP = na
var label lblPivot = na
var label lblR1 = na
var label lblR2 = na
var label lblS1 = na
var label lblS2 = na
var label lblADRH = na
var label lblADRL = na

if barstate.islast and showLabels

    label.delete(lblVWAP)
    label.delete(lblPivot)
    label.delete(lblR1)
    label.delete(lblR2)
    label.delete(lblS1)
    label.delete(lblS2)
    label.delete(lblADRH)
    label.delete(lblADRL)

    // VWAP
    lblVWAP := label.new(
         bar_index,
         vwap,
         "VWAP",
         style=label.style_label_left,
         color=vwapColor,
         textcolor=color.white
     )

    // Pivot
    if showPivot
        lblPivot := label.new(
             bar_index,
             pivot,
             "PIVOT",
             style=label.style_label_left,
             color=color.white,
             textcolor=color.black
         )

    // R1
    if showR1
        lblR1 := label.new(
             bar_index,
             r1,
             "R1",
             style=label.style_label_left,
             color=color.red,
             textcolor=color.white
         )

    // R2
    if showR2
        lblR2 := label.new(
             bar_index,
             r2,
             "R2",
             style=label.style_label_left,
             color=color.maroon,
             textcolor=color.white
         )

    // S1
    if showS1
        lblS1 := label.new(
             bar_index,
             s1,
             "S1",
             style=label.style_label_left,
             color=color.lime,
             textcolor=color.black
         )

    // S2
    if showS2
        lblS2 := label.new(
             bar_index,
             s2,
             "S2",
             style=label.style_label_left,
             color=color.green,
             textcolor=color.white
         )

    // ADR HIGH
    if showADR and showADRHigh
        lblADRH := label.new(
             bar_index,
             adrHigh,
             "ADR HIGH",
             style=label.style_label_left,
             color=color.fuchsia,
             textcolor=color.white
         )

    // ADR LOW
    if showADR and showADRLow
        lblADRL := label.new(
             bar_index,
             adrLow,
             "ADR LOW",
             style=label.style_label_left,
             color=color.aqua,
             textcolor=color.black
         )

//====================================================
// BREAKOUTS
//====================================================

bullVWAP = ta.crossover(close, vwap)
bearVWAP = ta.crossunder(close, vwap)

bullPivot = ta.crossover(close, pivot)
bearPivot = ta.crossunder(close, pivot)

//====================================================
// ALERTS
//====================================================

alertcondition(
     enableAlerts and bullVWAP,
     title="Bullish VWAP Breakout",
     message="{{ticker}} broke ABOVE VWAP"
)

alertcondition(
     enableAlerts and bearVWAP,
     title="Bearish VWAP Breakdown",
     message="{{ticker}} broke BELOW VWAP"
)

alertcondition(
     enableAlerts and bullPivot,
     title="Bullish Pivot Breakout",
     message="{{ticker}} broke ABOVE Pivot"
)

alertcondition(
     enableAlerts and bearPivot,
     title="Bearish Pivot Breakdown",
     message="{{ticker}} broke BELOW Pivot"
)

//====================================================
// CLEAN TREND BACKGROUND
//====================================================

bgcolor(
     close > vwap and close > pivot
     ? color.new(color.green, 96)
     : close < vwap and close < pivot
     ? color.new(color.red, 96)
     : na
)
````
