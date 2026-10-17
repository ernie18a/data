# Day Vertical Line

- url: https://www.tradingview.com/script/RVpks4bw-Day-Vertical-Line/
- type: indicator
- pine_id: PUB;f7166ab3e64641e18b933745dc81ffa0
- version: 1.0

## Description

Day Vertical Line
A simple, lightweight tool that draws a vertical line on every occurrence of a chosen weekday. Pick a day from the dropdown — for example, Friday — and the indicator marks every Friday on your chart with a clean vertical line.
Features

Select any day of the week (Sunday through Saturday) from a single dropdown
Vertical lines drawn automatically on every matching day across your full chart history
Customizable line color
Adjustable line width (1–5)
Choice of line style: solid, dashed, or dotted
Lines extend the full height of the chart for clear visual reference

How to Use

Add the indicator to your chart
Open the settings and choose your target day under "Show Line On"
Adjust color, width, and style to match your chart theme

Best Practices
Works on any timeframe. For one clean line per day, apply it to the daily (D1) timeframe. On intraday charts, a line is drawn on each bar belonging to the selected day.
Use Cases
Useful for marking weekly anchor points, highlighting specific session days, backtesting day-of-week patterns, or keeping track of recurring events tied to a particular weekday.

## Source Code

````pine
//@version=6
indicator("Day Vertical Line", overlay=true, max_lines_count=500)

// Select which day to mark
selected_day = input.string("Friday", "Show Line On", options=["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], group="Settings")

// Line appearance
line_color = input.color(color.gray, "Line Color", group="Settings")
line_width = input.int(1, "Line Width", minval=1, maxval=5, group="Settings")
line_style_opt = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Settings")

// Map selection to day number (1=Sunday ... 7=Saturday)
selected_num = switch selected_day
    "Sunday"    => 1
    "Monday"    => 2
    "Tuesday"   => 3
    "Wednesday" => 4
    "Thursday"  => 5
    "Friday"    => 6
    "Saturday"  => 7

// Map style string to constant
line_style = switch line_style_opt
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

// Draw vertical line when current bar's day matches
if dayofweek(time) == selected_num
    line.new(
         x1=bar_index, y1=high,
         x2=bar_index, y2=low,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=line_color,
         width=line_width,
         style=line_style
         )
````
