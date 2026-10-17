# Wednesday open & close

- url: https://www.tradingview.com/script/rA1w96HK-Wednesday-open-close/
- type: indicator
- pine_id: PUB;0a7dc3e4d9814f8ebcd4517e1ff8841d
- version: 5.0

## Description

[b]Wednesday open & close[/b]

This indicator draws two vertical lines each week to clearly mark key time boundaries:

The start of Wednesday at 12:00 AM
The start of Thursday at 12:00 AM (end of Wednesday)

It is designed to help traders easily identify and analyze midweek price behavior and patterns. Users can customize the line colors, style, width, and choose how many months of historical levels to display for a cleaner chart.

Ideal for traders who focus on weekly structure, session timing, or Wednesday-specific strategies.

## Source Code

````pine
//@version=5
indicator("Wednesday Open & Close (Replay Compatible)", overlay=true)

// === USER INPUTS ===
monthsBack = input.int(3, title="Months to Display", minval=1)
startColor = input.color(color.green, title="Wednesday 12:00 AM NY")
endColor   = input.color(color.red, title="Thursday 12:00 AM NY")
lineWidth  = input.int(2, title="Line Width", minval=1, maxval=5)
lineStyle  = input.string("Solid", title="Line Style", options=["Solid", "Dotted", "Dashed"])

// === LINE STYLE ===
style = line.style_solid
if lineStyle == "Dotted"
    style := line.style_dotted
else if lineStyle == "Dashed"
    style := line.style_dashed

// === NEW YORK TIMEZONE ===
tz = "America/New_York"

// === REPLAY-COMPATIBLE TIME FILTER ===
// Uses last_bar_time instead of timenow so it works in Bar Replay.
msInMonth = 30 * 24 * 60 * 60 * 1000
timeLimit = last_bar_time - (monthsBack * msInMonth)

// === GET NEW YORK DATE COMPONENTS FOR CURRENT BAR ===
nyYear  = year(time, tz)
nyMonth = month(time, tz)
nyDay   = dayofmonth(time, tz)

// === NEW YORK MIDNIGHT FOR THIS BAR'S NY DATE ===
nyMidnight = timestamp(tz, nyYear, nyMonth, nyDay, 0, 0)

// === DETECT WHEN CURRENT BAR CROSSES NY MIDNIGHT ===
crossedNyMidnight = not na(time[1]) and time[1] < nyMidnight and time >= nyMidnight

// === GET NY DAY OF WEEK AT THAT MIDNIGHT ===
nyDayOfWeek = dayofweek(nyMidnight)

// === CONDITIONS ===
isWednesdayStart = crossedNyMidnight and nyDayOfWeek == dayofweek.wednesday
isThursdayStart  = crossedNyMidnight and nyDayOfWeek == dayofweek.thursday

// === DRAW LINES ===
if time >= timeLimit
    if isWednesdayStart
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=startColor, width=lineWidth, style=style)

    if isThursdayStart
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=endColor, width=lineWidth, style=style)
````
