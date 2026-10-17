# Daily Mid Line

- url: https://www.tradingview.com/script/Jalo7TVr-Daily-Mid-Line/
- type: indicator
- pine_id: PUB;e54c4ed30b6c48a0bb42e004fb990eb7
- version: 1.0

## Description

Mid line tempoict ifvg fbr 50% range mid line tempotrades

## Source Code

````pine
//@version=6
indicator("Daily Mid Line", overlay=true)

// ── Inputs ──────────────────────────────────────────────────────────
lineColor = input.color(color.new(color.orange, 0), "Line color")
lineWidth = input.int(1, "Line width", minval=1, maxval=4)
showLabel = input.bool(true, "Show label on last bar")

// ── Use time("D") to track the exchange trading day ─────────────────
// time("D") returns the timestamp of the daily bar the current bar
// belongs to — this respects the exchange session, not the clock.
currentDayTime = time("D")
isNewDay = ta.change(currentDayTime) != 0

// ── Accumulate today's high/low within the exchange session ──────────
var float dayHigh = na
var float dayLow  = na
var int   dayID   = na

if isNewDay or na(dayID)
    dayHigh := high
    dayLow  := low
    dayID   := int(currentDayTime)
else
    dayHigh := math.max(dayHigh, high)
    dayLow  := math.min(dayLow,  low)

midpoint = (dayHigh + dayLow) / 2

// ── Only draw on bars belonging to the current trading day ──────────
onCurrentDay = int(currentDayTime) == dayID

// ── Dotted midline via circles ───────────────────────────────────────
plot(onCurrentDay ? midpoint : na,
     color     = lineColor,
     linewidth = lineWidth,
     style     = plot.style_circles,
     title     = "Day Mid")

// ── Price label on the rightmost bar ────────────────────────────────
if showLabel and barstate.islast and onCurrentDay
    label.new(bar_index, midpoint,
         text      = "Mid " + str.tostring(midpoint, format.mintick),
         style     = label.style_label_left,
         color     = lineColor,
         textcolor = color.white,
         size      = size.small)
````
