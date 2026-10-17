# True Day Open - Market Mafia

- url: https://www.tradingview.com/script/lUWBzBUy-True-Day-Open-Market-Mafia/
- type: indicator
- pine_id: PUB;c85f38ce33ea456cb4651e5c6e6e424d
- version: 1.0

## Description

Marks the price level of the True Day Open (11pm CDT)

## Source Code

````pine
//@version=6
indicator("True Day Open (11PM CDT) — Current Day Only", overlay = true)

// --- True Day Open Time (CDT → UTC) ---
// 11:00 PM CDT = 04:00 UTC during Daylight Savings
trueOpenHourUTC   = 4
trueOpenMinuteUTC = 0

// Detect the bar that matches the True Day Open time
isTrueOpen = (hour(time, "UTC") == trueOpenHourUTC) and (minute(time, "UTC") == trueOpenMinuteUTC)

// Track today's date
currentDay = dayofmonth(time)

// Store the True Day Open price ONLY for the current day
var float trueDayOpen = na
var int   trueDay     = na

// When the true open candle appears, store its price + date
if isTrueOpen
    trueDayOpen := open
    trueDay     := currentDay

// Reset at the start of a new day
if currentDay != trueDay
    trueDayOpen := na
    trueDay     := na

// Plot ONLY for the current day
plot(trueDayOpen,
     title = "True Day Open (Current Day)",
     color = color.new(color.yellow, 0),
     linewidth = 2)

// Mark the exact candle with a label
if isTrueOpen
    label.new(bar_index, trueDayOpen,
        "True Day Open\n11PM CDT",
        style = label.style_label_down,
        color = color.new(color.yellow, 0),
        textcolor = color.black)
````
