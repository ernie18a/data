# NY Session Time Lines by Jaro

- url: https://www.tradingview.com/script/g0Y4ZBES-NY-Session-Time-Lines-by-Jaro/
- type: indicator
- pine_id: PUB;955affe9cfa843db94742991721c2b56
- version: 1.0

## Description

[b]This indicator draws customizable vertical lines at key New York session times using the London timezone.
[/b]

[b]Features[/b]

Draws vertical lines at:
14:30 London Time (New York market open)
15:45 London Time
16:00 London Time
Individual on/off toggles for each time level.
Customizable line color, width, and style.
Supports Solid, Dashed, and Dotted line styles.
Default appearance uses a semi-transparent dashed red line.
Works on any timeframe by detecting whether a bar contains the specified time, not just bars that start exactly at that time.
Automatically handles London timezone daylight saving time changes.
Use Cases
Mark important New York session events.
Highlight intraday liquidity and volatility periods.
Identify potential market reaction zones around the NY open and other key times.
Improve session-based market analysis and backtesting.

Timezone: Europe/London (automatically adjusted for DST).

## Source Code

````pine
//@version=6
indicator("NY Session Time Lines by Jaro", overlay=true, max_lines_count=500)

// =====================
// Inputs
// =====================

show1430 = input.bool(true, "15:30")
show1545 = input.bool(true, "15:45")
show1600 = input.bool(true, "16:00")

lineColor = input.color(color.new(color.red, 60), "Line Color")

lineWidth = input.int(1, "Line Width", minval = 1, maxval = 5)

lineStyleInput = input.string( "Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"])

lineStyle =
     lineStyleInput == "Solid"  ? line.style_solid :
     lineStyleInput == "Dotted" ? line.style_dotted :
                                  line.style_dashed

// =====================
// Time Detection
// =====================

isTime(hourValue, minuteValue) =>
    targetTime = timestamp(
         "Europe/London",
         year,
         month,
         dayofmonth,
         hourValue,
         minuteValue
     )

    time <= targetTime and time_close > targetTime

// =====================
// Draw Lines
// =====================

drawVerticalLine() =>
    line.new(
         x1 = bar_index,
         y1 = low,
         x2 = bar_index,
         y2 = high,
         extend = extend.both,
         color = lineColor,
         width = lineWidth,
         style = lineStyle
     )

if show1430 and isTime(14, 30)
    drawVerticalLine()

if show1545 and isTime(14, 45)
    drawVerticalLine()

if show1600 and isTime(15, 0)
    drawVerticalLine()
````
