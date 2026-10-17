# 3-Bar Role Reversal Minimum

- url: https://www.tradingview.com/script/uyCMJwNM/
- type: indicator
- pine_id: PUB;e462101f44fa4124b875890fc2935f54
- version: 1.0

## Description

Title
3-Bar Role Reversal Minimum

Short Description
A minimal 3-bar role reversal detector with level lines and confirmed alerts.

Full Description
This indicator detects a simple 3-bar role reversal structure.

Bullish setup:

* Bar 1 provides the reference high
* Bar 2 is bullish
* Bar 2 closes above the reference high
* Bar 3 wicks back to the reference high
* Bar 3 closes at or above the reference high

Bearish setup:

* Bar 1 provides the reference low
* Bar 2 is bearish
* Bar 2 closes below the reference low
* Bar 3 wicks back to the reference low
* Bar 3 closes at or below the reference low

Features:

* Bull and bear signal markers
* Horizontal level lines for detected setups
* Custom line colors, signal colors, width, and style
* Confirmed alerts

Notes:

* Signal markers and level lines can appear in real time
* Alerts are confirmed-bar only
* Designed to keep the logic minimal and easy to read

How to Use

* Watch for triangle markers as the setup trigger
* Use the horizontal line as the key reference level
* Create alerts if you only want confirmed-bar notifications
* Works best when combined with higher timeframe bias, trend filters, or market structure context

Disclaimer
This script is for educational and research purposes only.
Use it at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kamikaze2090

//@version=6
indicator("3-Bar Role Reversal Minimum", overlay=true, max_lines_count=500)

// ==============================
// Inputs
// ==============================
group_base = "Base"
showBullSignals = input.bool(true, "Show Bull Signals", group=group_base)
showBearSignals = input.bool(true, "Show Bear Signals", group=group_base)
showLevelLines = input.bool(true, "Show Level Lines", group=group_base)
maxStoredLines = input.int(200, "Max Stored Lines", minval=20, maxval=500, group=group_base)

group_style = "Style"
bullLineColor = input.color(color.aqua, "Bull Line Color", group=group_style)
bearLineColor = input.color(color.orange, "Bear Line Color", group=group_style)
bullSignalColor = input.color(color.aqua, "Bull Signal Color", group=group_style)
bearSignalColor = input.color(color.orange, "Bear Signal Color", group=group_style)
lineWidth = input.int(3, "Line Width", minval=1, maxval=5, group=group_style)
lineStyleInput = input.string("solid", "Line Style", options=["solid", "dashed", "dotted"], group=group_style)

// ==============================
// Helpers
// ==============================
toLineStyle(s) =>
    s == "dashed" ? line.style_dashed :
     s == "dotted" ? line.style_dotted :
     line.style_solid

lineStyle = toLineStyle(lineStyleInput)

// ==============================
// Storage
// ==============================
var line[] levelLines = array.new_line()

cleanupOldLines() =>
    while array.size(levelLines) > maxStoredLines
        oldLine = array.shift(levelLines)
        line.delete(oldLine)

pushLevelLine(_x1, _x2, _y, _clr) =>
    ln = line.new(_x1, _y, _x2, _y, xloc=xloc.bar_index, extend=extend.none, color=_clr, style=lineStyle, width=lineWidth)
    array.push(levelLines, ln)
    cleanupOldLines()

// ==============================
// Minimal 3-bar role reversal
// [2] = 1st bar (reference)
// [1] = 2nd bar (body break)
// [0] = 3rd bar (wick return)
// signal/line = realtime allowed
// alert only = confirmed
// ==============================

// ---- Bull side ----
bullRefLevel = high[2]
bullBreakBarIsBull = close[1] > open[1]
bullBodyBreak = not na(bullRefLevel) and close[1] > bullRefLevel
bullWickReturn = low <= bullRefLevel
bullCloseValid = close >= bullRefLevel

bullSignal = showBullSignals and bullBreakBarIsBull and bullBodyBreak and bullWickReturn and bullCloseValid

// ---- Bear side ----
bearRefLevel = low[2]
bearBreakBarIsBear = close[1] < open[1]
bearBodyBreak = not na(bearRefLevel) and close[1] < bearRefLevel
bearWickReturn = high >= bearRefLevel
bearCloseValid = close <= bearRefLevel

bearSignal = showBearSignals and bearBreakBarIsBear and bearBodyBreak and bearWickReturn and bearCloseValid

// ==============================
// Line creation
// ==============================
if bullSignal and showLevelLines
    pushLevelLine(bar_index - 2, bar_index, bullRefLevel, bullLineColor)

if bearSignal and showLevelLines
    pushLevelLine(bar_index - 2, bar_index, bearRefLevel, bearLineColor)

// ==============================
// Signal plots
// ==============================
plotshape(
     bullSignal,
     title="Bull Role Reversal Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullSignalColor,
     size=size.tiny)

plotshape(
     bearSignal,
     title="Bear Role Reversal Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearSignalColor,
     size=size.tiny)

// ==============================
// Alerts
// confirmed only
// ==============================
bullAlert = bullSignal and barstate.isconfirmed
bearAlert = bearSignal and barstate.isconfirmed
anyAlert = (bullSignal or bearSignal) and barstate.isconfirmed

alertcondition(bullAlert, title="Bull Role Reversal", message="Bull 3-bar role reversal detected")
alertcondition(bearAlert, title="Bear Role Reversal", message="Bear 3-bar role reversal detected")
alertcondition(anyAlert, title="Any Role Reversal", message="Bull or bear 3-bar role reversal detected")
````
