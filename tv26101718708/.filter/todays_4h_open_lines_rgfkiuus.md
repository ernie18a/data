# Today's 4H Open Lines

- url: https://www.tradingview.com/script/rGfkiUUs-Today-s-4H-Open-Lines/
- type: indicator
- pine_id: PUB;72e8c91832954400a0cfb2ff5c9e42e3
- version: 1.0

## Description

**Description:**

Displays today's 4-hour opening prices as thin Baby Blue horizontal lines. All lines from previous days are automatically removed at the start of a new trading day, keeping the chart clean and focused on the current day's key 4H open levels. Suitable for intraday and ICT-style market analysis.

## Source Code

````pine
//@version=6
indicator("Today's 4H Open Lines", overlay = true, max_lines_count = 100)

var line[] lines = array.new<line>()

// Nov dan
newDay = ta.change(time("D")) != 0

if newDay
    for i = 0 to array.size(lines) - 1
        line.delete(array.get(lines, i))
    array.clear(lines)

// Nova 4H sveča
new4h = ta.change(time("240")) != 0

if new4h
    line l = line.new(
         x1 = bar_index,
         y1 = open,
         x2 = bar_index + 1,
         y2 = open,
         extend = extend.right,
         color = color.rgb(173, 216, 230), // Baby Blue
         width = 1
     )

    array.push(lines, l)
````
