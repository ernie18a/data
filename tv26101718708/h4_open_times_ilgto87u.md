# H4 open times.

- url: https://www.tradingview.com/script/IlGto87u-H4-open-times/
- type: indicator
- pine_id: PUB;d62be57968f847809bab1c97ed20d3d7
- version: 1.0

## Description

this can show you every H4 candle open time, dotted lines and stamp levels.

## Source Code

````pine
//@version=5
indicator("NY Levels (Session Based)", overlay=true, max_lines_count=100, max_labels_count=100)

// === SETTINGS ===
lineColor = input.color(color.gray, "Line Color")
tz = "America/New_York"

// === GET NY TIME ===
nyHour = hour(time, tz)
nyMin  = minute(time, tz)

// === CUSTOM SESSION DAY (STARTS 18:00 NY) ===
sessionDay = nyHour >= 18 ? dayofmonth(time, tz) : dayofmonth(time - 86400000, tz)

// === DETECT NEW SESSION ===
newSession = sessionDay != sessionDay[1]

// === STORAGE ===
var line[] lines = array.new_line()
var label[] labels = array.new_label()

// === CLEAR OLD LINES ===
if newSession and array.size(lines) > 0
    for i = 0 to array.size(lines) - 1
        line.delete(array.get(lines, i))
        label.delete(array.get(labels, i))
    array.clear(lines)
    array.clear(labels)

// === TIME CHECK ===
isTime(h, m) =>
    nyHour == h and nyMin == m

// === CREATE LINE ===
createLine(txt, price) =>
    l = line.new(bar_index, price, bar_index, price, color=lineColor, style=line.style_dotted, width=1)
    lb = label.new(bar_index, price, txt, style=label.style_label_left, textcolor=color.white, size=size.tiny, color=color.new(color.black, 70))
    array.push(lines, l)
    array.push(labels, lb)

// === CONDITIONS ===
if isTime(18, 0)
    createLine("18:00 NY", open)

if isTime(22, 0)
    createLine("22:00 NY", open)

if isTime(2, 0)
    createLine("02:00 NY", open)

if isTime(6, 0)
    createLine("06:00 NY", open)

if isTime(9, 30)
    createLine("09:30 NY", open)

if isTime(10, 0)
    createLine("10:00 NY", open)

// === UPDATE LINES TO CURRENT BAR ===
if array.size(lines) > 0
    for i = 0 to array.size(lines) - 1
        l = array.get(lines, i)
        line.set_x2(l, bar_index)

        lb = array.get(labels, i)
        label.set_x(lb, bar_index)
````
