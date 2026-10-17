# ICT Weekly Gap NY

- url: https://www.tradingview.com/script/NQcF0A2H-ICT-Weekly-Gap-NY/
- type: indicator
- pine_id: PUB;780b93a563784203b4ed11a8b44a75b8
- version: 1.0

## Description

This indicator plots weekly reference levels based on ICT-style weekly gap analysis.

It marks the Friday 17:00 New York close, the Monday 01:00 New York open, and the equilibrium level between those two prices. The purpose is to help traders visually track weekly gap levels, premium/discount reference areas, and possible reaction zones during the trading week.

The script allows users to choose how many previous weekly gaps to display, adjust the Monday open time, extend lines to the right, and show or hide the gap zone and labels.

This tool is designed for discretionary analysis only and does not provide buy or sell signals.

## Source Code

````pine
//@version=6
indicator("ICT Weekly Gap NY", overlay=true, max_lines_count=300, max_boxes_count=100, max_labels_count=300)

tz = input.string("America/New_York", "Time Zone")
weeksToShow = input.int(3, "Weeks To Show", minval=1, maxval=10)

mondayHour = input.int(1, "Monday Open Hour NY", minval=0, maxval=23)
mondayMinute = input.int(0, "Monday Open Minute NY", minval=0, maxval=59)

extendLinesRight = input.bool(true, "Extend Lines Right")
lineLengthDays = input.int(7, "Line Length Days If Not Extended", minval=1, maxval=30)

showZone = input.bool(true, "Show Gap Zone")
showLabels = input.bool(true, "Show Labels")

fridayColor = input.color(color.red, "Friday 17:00 Close")
mondayColor = input.color(color.lime, "Monday 01:00 Open")
eqColor = input.color(color.white, "Equilibrium")
zoneColor = input.color(color.new(color.yellow, 85), "Gap Zone")

var float fridayClose = na
var int fridayCloseTime = na

var line[] fridayLines = array.new_line()
var line[] mondayLines = array.new_line()
var line[] eqLines = array.new_line()
var box[] gapBoxes = array.new_box()
var label[] gapLabels = array.new_label()

friTarget = timestamp(tz, year(time_close, tz), month(time_close, tz), dayofmonth(time_close, tz), 17, 0)
isFridayClose = dayofweek(time_close, tz) == dayofweek.friday and time_close >= friTarget and nz(time_close[1], 0) < friTarget

if isFridayClose
    fridayClose := close
    fridayCloseTime := time_close

monTarget = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), mondayHour, mondayMinute)
isMondayOpen = dayofweek(time, tz) == dayofweek.monday and time >= monTarget and nz(time[1], 0) < monTarget

if isMondayOpen and not na(fridayClose) and not na(fridayCloseTime) and time > fridayCloseTime
    mondayOpen = open
    equilibrium = (fridayClose + mondayOpen) / 2.0

    friX1 = fridayCloseTime
    monX1 = time

    friX2 = fridayCloseTime + lineLengthDays * 24 * 60 * 60 * 1000
    monX2 = time + lineLengthDays * 24 * 60 * 60 * 1000

    lineExtend = extendLinesRight ? extend.right : extend.none

    friLine = line.new(friX1, fridayClose, friX2, fridayClose, xloc=xloc.bar_time, extend=lineExtend, color=fridayColor, width=2)
    monLine = line.new(monX1, mondayOpen, monX2, mondayOpen, xloc=xloc.bar_time, extend=lineExtend, color=mondayColor, width=2)
    midLine = line.new(monX1, equilibrium, monX2, equilibrium, xloc=xloc.bar_time, extend=lineExtend, color=eqColor, width=1, style=line.style_dashed)

    array.unshift(fridayLines, friLine)
    array.unshift(mondayLines, monLine)
    array.unshift(eqLines, midLine)

    if showZone
        gapBox = box.new(left=monX1, top=math.max(fridayClose, mondayOpen), right=monX2, bottom=math.min(fridayClose, mondayOpen), xloc=xloc.bar_time, extend=lineExtend, bgcolor=zoneColor, border_color=color.new(zoneColor, 40))
        array.unshift(gapBoxes, gapBox)

    if showLabels
        txt = "Weekly Gap\nFri 17:00: " + str.tostring(fridayClose, format.mintick) + "\nMon 01:00: " + str.tostring(mondayOpen, format.mintick) + "\nEQ: " + str.tostring(equilibrium, format.mintick)
        lbl = label.new(x=monX1, y=equilibrium, xloc=xloc.bar_time, text=txt, style=label.style_label_left, color=color.new(color.black, 0), textcolor=color.white, size=size.small)
        array.unshift(gapLabels, lbl)

    while array.size(fridayLines) > weeksToShow
        line.delete(array.pop(fridayLines))

    while array.size(mondayLines) > weeksToShow
        line.delete(array.pop(mondayLines))

    while array.size(eqLines) > weeksToShow
        line.delete(array.pop(eqLines))

    while array.size(gapBoxes) > weeksToShow
        box.delete(array.pop(gapBoxes))

    while array.size(gapLabels) > weeksToShow
        label.delete(array.pop(gapLabels))
````
