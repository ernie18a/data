# Teeje9 Opening Range To End Of Day

- url: https://www.tradingview.com/script/Zu13GHzh-Teeje9-Opening-Range-To-End-Of-Day/
- type: indicator
- pine_id: PUB;52902bdead9743599ccfb97dc3e64726
- version: 1.0

## Description

Tracks and marks the high and low of the morning session (default: 9:30–10:00 AM) and projects those levels across the rest of the trading day.

## Source Code

````pine
//@version=6
indicator("TJ Opening Range To End Of Day", overlay=true, max_lines_count=500)

// =========================
// Inputs
// =========================
openingRangeSession = input.session("0930-1000", "Opening Range Window")
marketSession       = input.session("0930-1600", "Market Session")
lineWidth           = input.int(2, "Line Width", minval=1, maxval=5)

// =========================
// Session logic
// =========================
inOpeningRange = not na(time(timeframe.period, openingRangeSession))
inMarket       = not na(time(timeframe.period, marketSession))
newDay         = ta.change(time("D")) != 0
rangeEnded     = not inOpeningRange and inOpeningRange[1]
marketEnded    = not inMarket and inMarket[1]

// =========================
// State
// =========================
var float sessionHigh = na
var float sessionLow  = na

var line activeHighLine = na
var line activeLowLine  = na

// =========================
// Reset daily values
// =========================
if newDay
    sessionHigh := na
    sessionLow  := na
    activeHighLine := na
    activeLowLine := na

// =========================
// Build opening range
// =========================
if inOpeningRange
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow  := na(sessionLow)  ? low  : math.min(sessionLow, low)

// =========================
// Create lines when range ends
// Start them at the bar where the OR window finishes
// =========================
if rangeEnded and not na(sessionHigh) and not na(sessionLow)
    activeHighLine := line.new(
         x1 = bar_index,
         y1 = sessionHigh,
         x2 = bar_index,
         y2 = sessionHigh,
         color = color.lime,
         width = lineWidth
     )

    activeLowLine := line.new(
         x1 = bar_index,
         y1 = sessionLow,
         x2 = bar_index,
         y2 = sessionLow,
         color = color.red,
         width = lineWidth
     )

// =========================
// Extend lines only during market hours
// =========================
if inMarket
    if not na(activeHighLine)
        line.set_x2(activeHighLine, bar_index)
    if not na(activeLowLine)
        line.set_x2(activeLowLine, bar_index)

// =========================
// Lock lines at end of day
// =========================
if marketEnded
    if not na(activeHighLine)
        line.set_x2(activeHighLine, bar_index - 1)
    if not na(activeLowLine)
        line.set_x2(activeLowLine, bar_index - 1)
````
