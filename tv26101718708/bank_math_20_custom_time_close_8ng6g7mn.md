# Bank Math 2.0 - Custom Time Close

- url: https://www.tradingview.com/script/8nG6G7mn-Bank-Math-2-0-Custom-Time-Close/
- type: indicator
- pine_id: PUB;d5acc3f985f646ce88e2b071c799713e
- version: 2.0

## Description

Brief Description
"75% of yesterday's high to low range then added/subtracted from yesterday's close"

This indicator lets you choose any time of day (e.g. 14:00 ET).
At that exact time it takes the last traded price as the “Close”, measures the full High-to-Low range of the previous 24 hours ending at that time, then projects a user-defined percentage (default 75%) of that range above and below the Close. The levels stay locked until the same time the next day.

Use Case
Traders who work with institutional / bank-style levels often use a fixed time of day (cash close, 15:00, 14:00, etc.) as their reference point.

This tool automatically calculates and plots the classic “75% of prior range” upside and downside targets from that chosen time, giving clean, non-repainting levels that can be used for intraday targets, mean-reversion zones, or breakout references.

## Source Code

````pine
//@version=6
indicator('Bank Math 4.0 - Custom Times', shorttitle = 'Bank Math 2.0', overlay = true)

// ─── RANGE WINDOW (Where H/L are captured) ──────────────────
rangeStartHour   = input.int(9, 'Range Start Hour (ET)', minval = 0, maxval = 23)
rangeStartMinute = input.int(30, 'Range Start Minute', minval = 0, maxval = 59)

rangeEndHour     = input.int(14, 'Range End Hour (ET)', minval = 0, maxval = 23)
rangeEndMinute   = input.int(30, 'Range End Minute', minval = 0, maxval = 59)

// ─── CLOSE TIME (When to lock & calculate targets) ──────────
closeHour   = input.int(14, 'Close Hour (24h ET)', minval = 0, maxval = 23)
closeMinute = input.int(30,  'Close Minute', minval = 0, maxval = 59)

pct         = input.float(75.0, 'Projection % of Range', minval = 1, maxval = 200, step = 1) / 100

// ─── Display Options ────────────────────────────────────────
showCloseLine    = input.bool(true, 'Show Close Line')
showTargets      = input.bool(true, 'Show Upside / Downside Targets')
showRangeHL      = input.bool(true, 'Show Range High / Low')
showDebugLabel   = input.bool(true, 'Show Debug Label')

// ─── New York Time ──────────────────────────────────────────
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
timeNow  = nyHour * 60 + nyMinute

nyHourPrev   = hour(time[1], "America/New_York")
nyMinutePrev = minute(time[1], "America/New_York")
timePrev     = nyHourPrev * 60 + nyMinutePrev

// Convert inputs to minutes
startMin  = rangeStartHour * 60 + rangeStartMinute
endMin    = rangeEndHour * 60 + rangeEndMinute
closeMin  = closeHour * 60 + closeMinute

// ─── Time Transitions ───────────────────────────────────────
isNewDay        = timePrev > timeNow                              // Midnight crossing
isInRangeStart  = (timeNow >= startMin) and (timePrev < startMin)   // Entering range window
isInRangeEnd    = (timeNow >= endMin) and (timePrev < endMin)       // Leaving range window
isCloseTime     = (timeNow >= closeMin) and (timePrev < closeMin)   // Hitting close time

// ─── Track H/L During Range Window Only ──────────────────────
var float rangeHigh = na
var float rangeLow  = na
var bool  inRange   = false

// Reset on new day
if isNewDay
    rangeHigh := na
    rangeLow  := na
    inRange   := false

// Enter range window
if isInRangeStart
    rangeHigh := high
    rangeLow  := low
    inRange   := true

// Track while in range
if inRange and (timeNow < endMin)
    rangeHigh := math.max(rangeHigh, high)
    rangeLow  := math.min(rangeLow, low)

// Exit range window
if inRange and (timeNow >= endMin)
    inRange := false

// ─── Lock Values at Close Time ───────────────────────────────
var float lockedClose = na
var float lockedHigh  = na
var float lockedLow   = na
var float lockedRange = na
var float upTarget    = na
var float dnTarget    = na

// At close time, use the H/L from range window
if isCloseTime and not na(rangeHigh) and not na(rangeLow)
    lockedClose := close[1]                    // Last completed close
    lockedHigh  := rangeHigh                   // From range window
    lockedLow   := rangeLow
    lockedRange := lockedHigh - lockedLow
    
    projection  = lockedRange * pct
    upTarget    := lockedClose + projection
    dnTarget    := lockedClose - projection

// ─── Debug Label ────────────────────────────────────────────
if showDebugLabel and barstate.islast and not na(lockedClose)
    label.new(bar_index, high,
         "Range: " + str.tostring(rangeStartHour) + ":" + str.tostring(rangeStartMinute, "00") + 
                 " → " + str.tostring(rangeEndHour) + ":" + str.tostring(rangeEndMinute, "00") + " ET\n" +
         "Close Time: " + str.tostring(closeHour) + ":" + str.tostring(closeMinute, "00") + " ET\n\n" +
         "Close:       " + str.tostring(lockedClose, "#.##") + "\n" +
         "Range High:  " + str.tostring(lockedHigh, "#.##") + "\n" +
         "Range Low:   " + str.tostring(lockedLow, "#.##") + "\n" +
         "Range Size:  " + str.tostring(lockedRange, "#.##") + "\n" +
         "Projection:  " + str.tostring(lockedRange * pct, "#.##") + "\n\n" +
         "Upside:      " + str.tostring(upTarget, "#.##") + " ←\n" +
         "Downside:    " + str.tostring(dnTarget, "#.##") + " ←",
         style = label.style_label_left, color = color.black, textcolor = color.white, size = size.normal)

// ─── Plots (Persist Until Next Close Time Overwrites) ────────
plot(showCloseLine and not na(lockedClose) ? lockedClose : na, "Locked Close", 
     color = color.white, style = plot.style_circles, linewidth = 1)

plot(showTargets ? upTarget : na, "Upside Target", 
     color = color.orange, style = plot.style_cross, linewidth = 2)
plot(showTargets ? dnTarget : na, "Downside Target", 
     color = color.blue, style = plot.style_cross, linewidth = 2)

plot(showRangeHL and not na(lockedHigh) ? lockedHigh : na, "Range High", 
     color = color.new(color.red, 50), style = plot.style_circles)
plot(showRangeHL and not na(lockedLow) ? lockedLow : na, "Range Low", 
     color = color.new(color.aqua, 50), style = plot.style_circles)
````
