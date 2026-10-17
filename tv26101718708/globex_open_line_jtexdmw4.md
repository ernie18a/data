# Globex Open Line

- url: https://www.tradingview.com/script/JteXdMW4-Globex-Open-Line/
- type: indicator
- pine_id: PUB;413aee2a750649ca91ecbe0f714b2459
- version: 1.0

## Description

Globex Open Line

Globex Open Line is a session-based indicator that plots the opening price of the Globex session and extends it forward on the chart. It provides a clean reference level for tracking how price reacts to the start of the futures trading session.

Overview

The indicator detects the exact moment when the Globex session begins (based on a configurable time and timezone) and draws a horizontal line at the session open price. This level is then extended forward for a user-defined duration, allowing traders to monitor its influence throughout the session.

Key Features
Automatic Globex Open Detection
Identifies the first bar of the Globex session using custom time and timezone settings.
Session Open Level Projection
Draws a horizontal line at the opening price and extends it forward for a configurable number of hours.
Custom Timezone Support
Ensures accurate session alignment across different markets and instruments.
Optional Price Label
Displays the exact Globex open value directly on the chart for quick reference.
Flexible Styling
Customize line color, width, and style (solid, dashed, dotted) to match your chart layout.
Use Cases
Key Level Identification
The Globex open often acts as a reference for intraday bias and price positioning.
Support & Resistance
Monitor reactions around the open level, which can behave as dynamic support or resistance.
Session Context
Helps distinguish whether price is trading above or below the Globex open, providing directional context.
Confluence Tool
Combine with market structure, VWAP, or volume-based indicators to strengthen trade ideas.
Inputs
Globex start time (hour and minute)
Timezone selection
Line extension duration (in hours)
Label visibility toggle
Line styling options
Notes

This indicator is session-dependent and works best on intraday timeframes. Accurate timezone configuration is essential for correct alignment with the intended market session.

Summary

Globex Open Line provides a precise and customizable way to track the Globex session opening price, helping traders incorporate a widely observed reference level into their analysis.

## Source Code

````pine
//@version=5
indicator("Globex Open Line", overlay=true, max_lines_count=100, max_labels_count=100)

grp1 = "Settings"
showLabel    = input.bool(true,  "Show Label",          group=grp1)
extendHours  = input.float(8.0,  "Extend (hours)",       group=grp1, minval=0.5, maxval=24.0, step=0.5)
timezone     = input.string("America/New_York", "Timezone", group=grp1, options=["America/New_York", "Europe/London", "Europe/Berlin", "Asia/Tokyo"])
globexHour   = input.int(18, "Globex Start Hour",       group=grp1, minval=0, maxval=23)
globexMin    = input.int(0,  "Globex Start Minute",     group=grp1, minval=0, maxval=59)

grp2 = "Style"
lineCol      = input.color(color.new(#ce93d8, 0), "Line Color",  group=grp2)
lineWidth    = input.int(1, "Line Width", group=grp2, minval=1, maxval=4)
lineStyle    = input.string("dashed", "Line Style", group=grp2, options=["solid","dashed","dotted"])

barHour      = hour(time, timezone)
barMin       = minute(time, timezone)
barTotalMins = barHour * 60 + barMin
startMins    = globexHour * 60 + globexMin

barsPerHour  = int(60 / timeframe.multiplier)
extendBars   = int(barsPerHour * extendHours)

ls = lineStyle == "dashed" ? line.style_dashed : lineStyle == "dotted" ? line.style_dotted : line.style_solid

var int lastDrawnDay = na

currentDay   = dayofmonth(time, timezone)
isGlobexBar  = barTotalMins >= startMins and barTotalMins < startMins + timeframe.multiplier

// Desenam linia exact cand detectam prima bara Globex din ziua respectiva
if isGlobexBar and (na(lastDrawnDay) or currentDay != lastDrawnDay)
    lastDrawnDay := currentDay
    lineEnd = bar_index + extendBars
    line.new(bar_index, open, lineEnd, open, color=lineCol, width=lineWidth, style=ls)
    if showLabel
        label.new(bar_index, open, "GLB  " + str.tostring(open, "#.####"), color=color.new(color.black, 100), textcolor=lineCol, size=size.tiny, style=label.style_label_right)
````
