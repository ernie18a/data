# Session Open Lines PRO (Final Clean)

- url: https://www.tradingview.com/script/IKwWUzwb-Session-Open-Lines-PRO-Final-Clean/
- type: indicator
- pine_id: PUB;ba36b46ab2fb4d27a34840dd12c8c7a1
- version: 1.0

## Description

This indicator can show you session open times on chart drawing a dotted line.

## Source Code

````pine
//@version=5
indicator("Session Open Lines PRO (Final Clean)", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== INPUTS =====
showMidnight = input.bool(true, "00:00 NY")
showNY       = input.bool(true, "09:30 NY")
showFutures  = input.bool(true, "18:00 NY")

labelOffset = input.int(2, "Label Offset (Right Side)")

lineColor = color.black

// ===== GET 1-MIN DATA =====
[o1, t1] = request.security(syminfo.tickerid, "1", [open, time], lookahead=barmerge.lookahead_on)

// ===== NY TIME =====
nyHour = hour(t1, "America/New_York")
nyMin  = minute(t1, "America/New_York")

// ===== STORE VALUES =====
var float midnightOpen = na
var float nyOpen       = na
var float futOpen      = na

// ===== STORE OBJECTS =====
var line lineMidnight = na
var line lineNY       = na
var line lineFut      = na

var label labelMidnight = na
var label labelNY       = na
var label labelFut      = na

// ===== RESET DAILY =====
newDay = ta.change(time("D"))
if newDay
    midnightOpen := na
    nyOpen       := na
    futOpen      := na

    line.delete(lineMidnight)
    line.delete(lineNY)
    line.delete(lineFut)

    label.delete(labelMidnight)
    label.delete(labelNY)
    label.delete(labelFut)

// ===== CAPTURE LEVELS =====
if showMidnight and na(midnightOpen) and nyHour == 0 and nyMin == 0
    midnightOpen := o1

if showNY and na(nyOpen) and nyHour == 9 and nyMin == 30
    nyOpen := o1

if showFutures and na(futOpen) and nyHour == 18 and nyMin == 0
    futOpen := o1

// ===== DRAW / UPDATE =====

// Midnight
if not na(midnightOpen)
    if na(lineMidnight)
        lineMidnight := line.new(bar_index, midnightOpen, bar_index, midnightOpen, color=lineColor, style=line.style_dotted)
        labelMidnight := label.new(bar_index + labelOffset, midnightOpen, "00:00", style=label.style_none, textcolor=color.black)
    else
        line.set_xy2(lineMidnight, bar_index, midnightOpen)
        label.set_xy(labelMidnight, bar_index + labelOffset, midnightOpen)

// NY Open
if not na(nyOpen)
    if na(lineNY)
        lineNY := line.new(bar_index, nyOpen, bar_index, nyOpen, color=lineColor, style=line.style_dotted, width=2)
        labelNY := label.new(bar_index + labelOffset, nyOpen, "NY Open", style=label.style_none, textcolor=color.black)
    else
        line.set_xy2(lineNY, bar_index, nyOpen)
        label.set_xy(labelNY, bar_index + labelOffset, nyOpen)

// Futures Open
if not na(futOpen)
    if na(lineFut)
        lineFut := line.new(bar_index, futOpen, bar_index, futOpen, color=lineColor, style=line.style_dotted)
        labelFut := label.new(bar_index + labelOffset, futOpen, "18:00", style=label.style_none, textcolor=color.black)
    else
        line.set_xy2(lineFut, bar_index, futOpen)
        label.set_xy(labelFut, bar_index + labelOffset, futOpen)
````
