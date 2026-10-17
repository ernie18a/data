# UTC-4 Session Opens

- url: https://www.tradingview.com/script/wI2CWQLd-UTC-4-Session-Opens/
- type: indicator
- pine_id: PUB;3cd68c2bced9471b808d310b6f20eec9
- version: 1.0

## Description

Marks key UTC-4 session opening levels with thin Baby Blue horizontal lines. Includes the 12:00 AM Midnight Open, 06:00 AM Open, and 10:00 AM Open. Previous day levels are automatically removed to keep the chart clean and focused on the current trading day.

## Source Code

````pine
//@version=6
indicator("UTC-4 Session Opens", overlay=true, max_lines_count=50)

// ===== SETTINGS =====
showMidnight = input.bool(true, "Show 12:00 AM Midnight UTC-4")
show06 = input.bool(true, "Show 06:00 UTC-4")
show10 = input.bool(true, "Show 10:00 UTC-4")

lineColor = input.color(color.rgb(173, 216, 230), "Baby Blue")

// ===== STORAGE =====
var line[] lines = array.new<line>()

// ===== UTC-4 TIME =====
utcHour = hour(time, "GMT-4")
utcMinute = minute(time, "GMT-4")

// ===== NEW DAY RESET =====
newDay = utcHour == 0 and utcMinute == 0

if newDay
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    array.clear(lines)


// ===== DRAW FUNCTION =====
drawOpen() =>
    l = line.new(
         x1 = bar_index,
         y1 = open,
         x2 = bar_index + 1,
         y2 = open,
         extend = extend.right,
         color = lineColor,
         width = 1
     )
    array.push(lines, l)


// ===== LEVELS UTC-4 =====

// Midnight 12:00 AM
if showMidnight and utcHour == 0 and utcMinute == 0
    drawOpen()

// 6:00 AM
if show06 and utcHour == 6 and utcMinute == 0
    drawOpen()

// 10:00 AM
if show10 and utcHour == 10 and utcMinute == 0
    drawOpen()
````
