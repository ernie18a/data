# 2026 Numerology 7 Dates - Full Year Projection

- url: https://www.tradingview.com/script/MSccKgMs-2026-Numerology-7-Dates-Full-Year-Projection/
- type: indicator
- pine_id: PUB;02513607c8a441b8b1ecec62eb5295a6
- version: 1.0

## Description

This script applies vertical lines to all dates with Numerology 7 for the year 2026.

## Source Code

````pine
//@version=6
indicator("2026 Numerology 7 Dates - Full Year Projection", overlay=true, max_lines_count=500, max_labels_count=500)

// Inputs
lineColor      = input.color(color.fuchsia, "Line Color")
lineWidth      = input.int(2, "Line Width", minval=1, maxval=5)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
showLabels     = input.bool(false, "Show Labels")

lineStyle = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// Build date array once
var dates = array.new_int()

if barstate.isfirst
    // January
    array.push(dates, timestamp(syminfo.timezone, 2026, 1, 5, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 1, 14, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 1, 23, 0, 0))

    // February
    array.push(dates, timestamp(syminfo.timezone, 2026, 2, 4, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 2, 13, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 2, 22, 0, 0))

    // March
    array.push(dates, timestamp(syminfo.timezone, 2026, 3, 3, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 3, 12, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 3, 21, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 3, 30, 0, 0))

    // April
    array.push(dates, timestamp(syminfo.timezone, 2026, 4, 2, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 4, 11, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 4, 20, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 4, 29, 0, 0))

    // May
    array.push(dates, timestamp(syminfo.timezone, 2026, 5, 1, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 5, 10, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 5, 19, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 5, 28, 0, 0))

    // June
    array.push(dates, timestamp(syminfo.timezone, 2026, 6, 9, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 6, 18, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 6, 27, 0, 0))

    // July
    array.push(dates, timestamp(syminfo.timezone, 2026, 7, 8, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 7, 17, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 7, 26, 0, 0))

    // August
    array.push(dates, timestamp(syminfo.timezone, 2026, 8, 7, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 8, 16, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 8, 25, 0, 0))

    // September
    array.push(dates, timestamp(syminfo.timezone, 2026, 9, 6, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 9, 15, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 9, 24, 0, 0))

    // October
    array.push(dates, timestamp(syminfo.timezone, 2026, 10, 5, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 10, 14, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 10, 23, 0, 0))

    // November
    array.push(dates, timestamp(syminfo.timezone, 2026, 11, 4, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 11, 13, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 11, 22, 0, 0))

    // December
    array.push(dates, timestamp(syminfo.timezone, 2026, 12, 3, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 12, 12, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 12, 21, 0, 0))
    array.push(dates, timestamp(syminfo.timezone, 2026, 12, 30, 0, 0))

// Draw once
var bool drawn = false

if barstate.islast and not drawn
    for i = 0 to array.size(dates) - 1
        ts = array.get(dates, i)

        line.new(
             x1 = ts,
             y1 = 0.0,
             x2 = ts,
             y2 = 1.0,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = lineColor,
             width = lineWidth,
             style = lineStyle
         )

        if showLabels
            label.new(
                 x = ts,
                 y = close,
                 text = str.format_time(ts, "M/d", syminfo.timezone),
                 xloc = xloc.bar_time,
                 style = label.style_label_down,
                 color = color.new(lineColor, 75),
                 textcolor = color.white
             )

    drawn := true
````
