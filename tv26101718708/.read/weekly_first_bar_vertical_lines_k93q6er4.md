# Weekly First Bar Vertical Lines

- url: https://www.tradingview.com/script/k93Q6Er4-Weekly-First-Bar-Vertical-Lines/
- type: indicator
- pine_id: PUB;e58b1a1dfd304e138fcdc65cc7c0c647
- version: 1.0

## Description

Weekly First Bar Vertical Lines
Weekly First Bar Vertical Lines
Weekly First Bar Vertical Lines
Weekly First Bar Vertical Lines
Weekly First Bar Vertical Lines
Weekly First Bar Vertical Lines

## Source Code

````pine
//@version=6
indicator("Weekly First Bar Vertical Lines", overlay=true, max_lines_count=500)

lineColor = input.color(color.new(color.blue, 0), "Line color")
lineWidth = input.int(1, "Line width", minval=1, maxval=5)
lineStyleInput = input.string("Dashed", "Line style", options=["Solid", "Dashed", "Dotted"])
maxLines = input.int(100, "Max weekly lines", minval=1, maxval=500)

lineStyle = lineStyleInput == "Solid" ? line.style_solid :
     lineStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

isFirstBarOfWeek = timeframe.change("W")

var array<line> weeklyLines = array.new_line()

if isFirstBarOfWeek
    newLine = line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=lineColor,
         style=lineStyle,
         width=lineWidth
     )

    array.push(weeklyLines, newLine)

    if array.size(weeklyLines) > maxLines
        oldLine = array.shift(weeklyLines)
        line.delete(oldLine)
````
