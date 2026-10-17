# H4 open times

- url: https://www.tradingview.com/script/FPFZWtCp-H4-open-times/
- type: indicator
- pine_id: PUB;bd6759c3becf4e039f10872db36ce16c
- version: 1.0

## Description

This can plot lines vertical & horizontal for every h4 open.

## Source Code

````pine
//@version=5
indicator("NY Times + Levels SAFE", overlay=true, max_lines_count=200, max_labels_count=200)

// === SETTINGS ===
lineColor = input.color(color.gray, "Line Color")
tz = "America/New_York"

// === NY TIME ===
nyHour = hour(time, tz)
nyMin  = minute(time, tz)

// === SESSION (START 18:00 NY) ===
sessionDay = nyHour >= 18 ? dayofmonth(time, tz) : dayofmonth(time - 86400000, tz)
newSession = sessionDay != sessionDay[1]

// === STORAGE ===
var line[] hLines = array.new_line()
var label[] hLabels = array.new_label()

// === SAFE CLEAR ===
if newSession
    if array.size(hLines) > 0
        for i = 0 to array.size(hLines) - 1
            line.delete(array.get(hLines, i))
            label.delete(array.get(hLabels, i))
        array.clear(hLines)
        array.clear(hLabels)

// === TIME CHECK ===
isTime(h, m) =>
    nyHour == h and nyMin == m

// === CREATE LINES ===
createLines(txt, price) =>
    // horizontal
    l = line.new(bar_index, price, bar_index, price, color=lineColor, style=line.style_dotted, width=1)
    lb = label.new(bar_index, price, txt, style=label.style_label_left, textcolor=color.white, size=size.tiny, color=color.new(color.black, 70))

    // vertical
    line.new(bar_index, high, bar_index, low, color=lineColor, style=line.style_dotted, width=1, extend=extend.both)

    array.push(hLines, l)
    array.push(hLabels, lb)

// === CONDITIONS ===
if isTime(18, 0)
    createLines("18:00 NY", open)

if isTime(22, 0)
    createLines("22:00 NY", open)

if isTime(2, 0)
    createLines("02:00 NY", open)

if isTime(6, 0)
    createLines("06:00 NY", open)

if isTime(9, 30)
    createLines("09:30 NY", open)

if isTime(10, 0)
    createLines("10:00 NY", open)

// === UPDATE HORIZONTAL LINES ===
if array.size(hLines) > 0
    for i = 0 to array.size(hLines) - 1
        l = array.get(hLines, i)
        line.set_x2(l, bar_index)

        lb = array.get(hLabels, i)
        label.set_x(lb, bar_index)
````
