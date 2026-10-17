# PWH / PWL / PWEQ

- url: https://www.tradingview.com/script/kJTKEQ4g/
- type: indicator
- pine_id: PUB;f2ce8807db974351b30652723ca5ebc0
- version: 2.0

## Description

Previous Weekly High
Previous Weekly Low
Previous Weekly EQ

## Source Code

````pine
//@version=6
indicator("PWH / PWL / PWEQ v2", overlay=true, max_lines_count=50, max_labels_count=50)

// === Settings ===
showWeeklyLevels = input.bool(true, "Show PWH / PWL / PWEQ")
rightOffsetBars  = input.int(150, "Label Right Offset", minval=1, maxval=500)

pwhPwlColor = input.color(color.rgb(60, 60, 60), "PWH / PWL Color")
pweqColor   = input.color(color.red, "PWEQ Color")

// === Futures Trading Week Logic ===
// Sunday evening session belongs to the upcoming Monday trading week

int nyDay = dayofweek(time, "America/New_York")

int oneDayMs = 24 * 60 * 60 * 1000

int tradeWeekTime = nyDay == dayofweek.sunday ? time + oneDayMs : time

int tradeWeek = weekofyear(tradeWeekTime, "America/New_York")
int tradeYear = year(tradeWeekTime, "America/New_York")

int weekKey = tradeYear * 100 + tradeWeek

bool isNewWeek = ta.change(weekKey) != 0

// === Weekly Tracking ===

var float currentWeekHigh = na
var float currentWeekLow = na

var int currentWeekHighBar = na
var int currentWeekLowBar = na

var float prevWeekHigh = na
var float prevWeekLow = na
var float prevWeekEQ = na

var int prevWeekHighBar = na
var int prevWeekLowBar = na

// === Objects ===

var line pwhLine = na
var line pwlLine = na
var line pweqLine = na

var label pwhLabel = na
var label pwlLabel = na
var label pweqLabel = na

// === Initialization ===

if na(currentWeekHigh)
    currentWeekHigh := high
    currentWeekLow := low
    currentWeekHighBar := bar_index
    currentWeekLowBar := bar_index

// === New Trading Week ===

if isNewWeek

    prevWeekHigh := currentWeekHigh
    prevWeekLow := currentWeekLow

    prevWeekHighBar := currentWeekHighBar
    prevWeekLowBar := currentWeekLowBar

    prevWeekEQ := (prevWeekHigh + prevWeekLow) / 2

    currentWeekHigh := high
    currentWeekLow := low

    currentWeekHighBar := bar_index
    currentWeekLowBar := bar_index

    // Delete old objects

    line.delete(pwhLine)
    line.delete(pwlLine)
    line.delete(pweqLine)

    label.delete(pwhLabel)
    label.delete(pwlLabel)
    label.delete(pweqLabel)

    // Draw new levels

    if showWeeklyLevels and not na(prevWeekHigh) and not na(prevWeekLow)

        pwhLine := line.new(
             prevWeekHighBar,
             prevWeekHigh,
             bar_index,
             prevWeekHigh,
             extend = extend.right,
             color = pwhPwlColor,
             width = 1)

        pwlLine := line.new(
             prevWeekLowBar,
             prevWeekLow,
             bar_index,
             prevWeekLow,
             extend = extend.right,
             color = pwhPwlColor,
             width = 1)

        pweqLine := line.new(
             bar_index,
             prevWeekEQ,
             bar_index + 1,
             prevWeekEQ,
             extend = extend.right,
             color = pweqColor,
             width = 1)

        pwhLabel := label.new(
             bar_index + rightOffsetBars,
             prevWeekHigh,
             "PWH",
             style = label.style_none,
             textcolor = pwhPwlColor,
             size = size.small)

        pwlLabel := label.new(
             bar_index + rightOffsetBars,
             prevWeekLow,
             "PWL",
             style = label.style_none,
             textcolor = pwhPwlColor,
             size = size.small)

        pweqLabel := label.new(
             bar_index + rightOffsetBars,
             prevWeekEQ,
             "PWEQ",
             style = label.style_none,
             textcolor = pweqColor,
             size = size.small)

// === Track Current Week High / Low ===

if not isNewWeek

    if high > currentWeekHigh
        currentWeekHigh := high
        currentWeekHighBar := bar_index

    if low < currentWeekLow
        currentWeekLow := low
        currentWeekLowBar := bar_index

// === Keep Labels Moving Right ===

if showWeeklyLevels

    if not na(pwhLabel)
        label.set_x(pwhLabel, bar_index + rightOffsetBars)

    if not na(pwlLabel)
        label.set_x(pwlLabel, bar_index + rightOffsetBars)

    if not na(pweqLabel)
        label.set_x(pweqLabel, bar_index + rightOffsetBars)

else

    line.delete(pwhLine)
    line.delete(pwlLine)
    line.delete(pweqLine)

    label.delete(pwhLabel)
    label.delete(pwlLabel)
    label.delete(pweqLabel)

    pwhLine := na
    pwlLine := na
    pweqLine := na

    pwhLabel := na
    pwlLabel := na
    pweqLabel := na
````
