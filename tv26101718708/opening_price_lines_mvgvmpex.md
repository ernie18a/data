# Opening Price Lines

- url: https://www.tradingview.com/script/mvgVmPEX-Opening-Price-Lines/
- type: indicator
- pine_id: PUB;cd09ada2d9464d028b3feab8c8fb6f43
- version: 1.0

## Description

This indicator plots up to five customizable horizontal price lines based on the opening price at user-selected times. It is useful for marking key session opens, market opens, liquidity reference levels, or any specific time-based price level directly on the chart.

Each line can be individually enabled, named, colored, styled, and adjusted for width. The lines automatically update so their endpoints stay just ahead of the current price action, keeping the chart clean while preserving the key opening levels.

Features:

Plot up to 5 separate time-based opening price lines
Customize each line’s time, label, color, style, and width
Supports solid, dotted, and dashed line styles
Adjustable line extension length
Optional label offset control
Daylight Saving Time toggle for U.S. market timing
Designed for clean session-level tracking without clutter
Common uses:

New York open
London open
Asia session open
Custom session reference levels
Intraday support and resistance tracking
This tool is intended as a visual reference aid and does not provide buy or sell signals.

## Source Code

````pine
//@version=6
indicator("Five Editable Opening Price Lines", overlay=true, max_lines_count=10, max_labels_count=10)
plot(close, title="Hidden compiler output", display=display.none)
useDST = input.bool(true, "Use Daylight Saving Time", group="General")
lineLength = input.int(20, "Line Bars Right", minval=1, maxval=500, group="General")
labelOffset = input.int(0, "Label Bars Past Line", minval=0, maxval=500, group="General")
timeZoneStr = useDST ? "GMT-4" : "GMT-5"
var lineGroup = "Price Lines"
showLine1 = input.bool(true, "Line 1", inline="line1_time", group=lineGroup)
line1Hour = input.int(9, "Hour", minval=0, maxval=23, inline="line1_time", group=lineGroup)
line1Min = input.int(30, "Min", minval=0, maxval=59, inline="line1_time", group=lineGroup)
line1Text = input.string("NY Open", "Label", group=lineGroup)
line1Color = input.color(color.lime, "Color", inline="line1_style", group=lineGroup)
line1Style = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], inline="line1_style", group=lineGroup)
line1Width = input.int(2, "Width", minval=1, maxval=5, inline="line1_style", group=lineGroup)
showLine2 = input.bool(false, "Line 2", inline="line2_time", group=lineGroup)
line2Hour = input.int(10, "Hour", minval=0, maxval=23, inline="line2_time", group=lineGroup)
line2Min = input.int(0, "Min", minval=0, maxval=59, inline="line2_time", group=lineGroup)
line2Text = input.string("Line 2", "Label", group=lineGroup)
line2Color = input.color(color.purple, "Color", inline="line2_style", group=lineGroup)
line2Style = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], inline="line2_style", group=lineGroup)
line2Width = input.int(2, "Width", minval=1, maxval=5, inline="line2_style", group=lineGroup)
showLine3 = input.bool(false, "Line 3", inline="line3_time", group=lineGroup)
line3Hour = input.int(11, "Hour", minval=0, maxval=23, inline="line3_time", group=lineGroup)
line3Min = input.int(0, "Min", minval=0, maxval=59, inline="line3_time", group=lineGroup)
line3Text = input.string("Line 3", "Label", group=lineGroup)
line3Color = input.color(color.orange, "Color", inline="line3_style", group=lineGroup)
line3Style = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], inline="line3_style", group=lineGroup)
line3Width = input.int(2, "Width", minval=1, maxval=5, inline="line3_style", group=lineGroup)
showLine4 = input.bool(false, "Line 4", inline="line4_time", group=lineGroup)
line4Hour = input.int(12, "Hour", minval=0, maxval=23, inline="line4_time", group=lineGroup)
line4Min = input.int(0, "Min", minval=0, maxval=59, inline="line4_time", group=lineGroup)
line4Text = input.string("Line 4", "Label", group=lineGroup)
line4Color = input.color(color.aqua, "Color", inline="line4_style", group=lineGroup)
line4Style = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], inline="line4_style", group=lineGroup)
line4Width = input.int(2, "Width", minval=1, maxval=5, inline="line4_style", group=lineGroup)
showLine5 = input.bool(false, "Line 5", inline="line5_time", group=lineGroup)
line5Hour = input.int(13, "Hour", minval=0, maxval=23, inline="line5_time", group=lineGroup)
line5Min = input.int(0, "Min", minval=0, maxval=59, inline="line5_time", group=lineGroup)
line5Text = input.string("Line 5", "Label", group=lineGroup)
line5Color = input.color(color.fuchsia, "Color", inline="line5_style", group=lineGroup)
line5Style = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], inline="line5_style", group=lineGroup)
line5Width = input.int(2, "Width", minval=1, maxval=5, inline="line5_style", group=lineGroup)
targetTime(lineHour, lineMin) =>
    timestamp(timeZoneStr, year(time, timeZoneStr), month(time, timeZoneStr), dayofmonth(time, timeZoneStr), lineHour, lineMin)
hitsTime(lineHour, lineMin) =>
    target = targetTime(lineHour, lineMin)
    time >= target and time[1] < target
getLineStyle(styleText) =>
    styleText == "Dotted" ? line.style_dotted : styleText == "Dashed" ? line.style_dashed : line.style_solid
var line activeLine1 = na
var line activeLine2 = na
var line activeLine3 = na
var line activeLine4 = na
var line activeLine5 = na
var label activeLabel1 = na
var label activeLabel2 = na
var label activeLabel3 = na
var label activeLabel4 = na
var label activeLabel5 = na
if hitsTime(line1Hour, line1Min)
    line.delete(activeLine1)
    label.delete(activeLabel1)
    activeLine1 := showLine1 ? line.new(bar_index, open, bar_index + lineLength, open, color=line1Color, width=line1Width, style=getLineStyle(line1Style)) : na
    activeLabel1 := showLine1 and line1Text != "" ? label.new(bar_index + lineLength + labelOffset, open, line1Text, color=color.new(color.black, 100), textcolor=line1Color, style=label.style_label_left, size=size.tiny) : na
if hitsTime(line2Hour, line2Min)
    line.delete(activeLine2)
    label.delete(activeLabel2)
    activeLine2 := showLine2 ? line.new(bar_index, open, bar_index + lineLength, open, color=line2Color, width=line2Width, style=getLineStyle(line2Style)) : na
    activeLabel2 := showLine2 and line2Text != "" ? label.new(bar_index + lineLength + labelOffset, open, line2Text, color=color.new(color.black, 100), textcolor=line2Color, style=label.style_label_left, size=size.tiny) : na
if hitsTime(line3Hour, line3Min)
    line.delete(activeLine3)
    label.delete(activeLabel3)
    activeLine3 := showLine3 ? line.new(bar_index, open, bar_index + lineLength, open, color=line3Color, width=line3Width, style=getLineStyle(line3Style)) : na
    activeLabel3 := showLine3 and line3Text != "" ? label.new(bar_index + lineLength + labelOffset, open, line3Text, color=color.new(color.black, 100), textcolor=line3Color, style=label.style_label_left, size=size.tiny) : na
if hitsTime(line4Hour, line4Min)
    line.delete(activeLine4)
    label.delete(activeLabel4)
    activeLine4 := showLine4 ? line.new(bar_index, open, bar_index + lineLength, open, color=line4Color, width=line4Width, style=getLineStyle(line4Style)) : na
    activeLabel4 := showLine4 and line4Text != "" ? label.new(bar_index + lineLength + labelOffset, open, line4Text, color=color.new(color.black, 100), textcolor=line4Color, style=label.style_label_left, size=size.tiny) : na
if hitsTime(line5Hour, line5Min)
    line.delete(activeLine5)
    label.delete(activeLabel5)
    activeLine5 := showLine5 ? line.new(bar_index, open, bar_index + lineLength, open, color=line5Color, width=line5Width, style=getLineStyle(line5Style)) : na
    activeLabel5 := showLine5 and line5Text != "" ? label.new(bar_index + lineLength + labelOffset, open, line5Text, color=color.new(color.black, 100), textcolor=line5Color, style=label.style_label_left, size=size.tiny) : na
lineEndBar = bar_index + lineLength
labelBar = lineEndBar + labelOffset
if not na(activeLine1)
    line.set_x2(activeLine1, lineEndBar)
if not na(activeLabel1)
    label.set_x(activeLabel1, labelBar)
if not na(activeLine2)
    line.set_x2(activeLine2, lineEndBar)
if not na(activeLabel2)
    label.set_x(activeLabel2, labelBar)
if not na(activeLine3)
    line.set_x2(activeLine3, lineEndBar)
if not na(activeLabel3)
    label.set_x(activeLabel3, labelBar)
if not na(activeLine4)
    line.set_x2(activeLine4, lineEndBar)
if not na(activeLabel4)
    label.set_x(activeLabel4, labelBar)
if not na(activeLine5)
    line.set_x2(activeLine5, lineEndBar)
if not na(activeLabel5)
    label.set_x(activeLabel5, labelBar)
````
