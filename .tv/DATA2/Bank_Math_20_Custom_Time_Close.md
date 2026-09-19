<!-- tradingview-pine-id: PUB;d5acc3f985f646ce88e2b071c799713e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bank Math 2.0 - Custom Time Close

Source: https://www.tradingview.com/script/8nG6G7mn-Bank-Math-2-0-Custom-Time-Close/

## Description

Brief Description
"75% of yesterday's high to low range then added/subtracted from yesterday's close"

This indicator lets you choose any time of day (e.g. 14:00 ET).
At that exact time it takes the last traded price as the “Close”, measures the full High-to-Low range of the previous 24 hours ending at that time, then projects a user-defined percentage (default 75%) of that range above and below the Close. The levels stay locked until the same time the next day.

Use Case
Traders who work with institutional / bank-style levels often use a fixed time of day (cash close, 15:00, 14:00, etc.) as their reference point.

This tool automatically calculates and plots the classic “75% of prior range” upside and downside targets from that chosen time, giving clean, non-repainting levels that can be used for intraday targets, mean-reversion zones, or breakout references.

---

## Source Code

````pine
//@version=6
indicator('Bank Math 2.0 - Custom Time Close', shorttitle = 'Bank Math 2.0 Time', overlay = true)

// ─── Inputs ────────────────────────────────────────────────
chosenHour = input.int(17, 'Close Hour (24h format)', minval = 0, maxval = 23)
chosenMinute = input.int(0, 'Close Minute', minval = 0, maxval = 59)
pct = input.float(75.0, 'Projection % of Range', minval = 1, maxval = 200, step = 1) / 100

showClose = input.bool(true, 'Show Close Line')
showTargets = input.bool(true, 'Show Upside / Downside Targets')
showRangeHL = input.bool(true, 'Show Range High / Low')

// ─── Time in New York ──────────────────────────────────────
nyHour = hour(time, 'America/New_York')
nyMinute = minute(time, 'America/New_York')

nyHourPrev = hour(time[1], 'America/New_York')
nyMinutePrev = minute(time[1], 'America/New_York')

// Correct detection: we just passed the chosen time
// → take the previous bar as the last print up to the chosen time
isCloseTime = (nyHour > chosenHour or nyHour == chosenHour and nyMinute > chosenMinute) and (nyHourPrev < chosenHour or nyHourPrev == chosenHour and nyMinutePrev <= chosenMinute)

// ─── Running High / Low ────────────────────────────────────
var float runningHigh = na
var float runningLow = na

// ─── Locked values ─────────────────────────────────────────
var float lockedClose = na
var float lockedHigh = na
var float lockedLow = na
var float lockedRange = na
var float upTarget = na
var float dnTarget = na

if isCloseTime
    // Last print up to the chosen time
    lockedClose := close[1]

    // Finalize range
    lockedHigh := runningHigh
    lockedLow := runningLow
    lockedRange := lockedHigh - lockedLow

    // Project
    projection = lockedRange * pct
    upTarget := lockedClose + projection
    dnTarget := lockedClose - projection

    // Reset only here (no other resets)
    runningHigh := high
    runningLow := low
    runningLow
else
    runningHigh := math.max(nz(runningHigh, high), high)
    runningLow := math.min(nz(runningLow, low), low)
    runningLow

// ─── Debug ─────────────────────────────────────────────────
if barstate.islast and not na(lockedClose)
    label.new(bar_index, high, 'Close Time: ' + str.tostring(chosenHour) + ':' + str.tostring(chosenMinute, '00') + ' ET\n\n' + 'Close:      ' + str.tostring(lockedClose, '#.##') + '\n' + 'Range High: ' + str.tostring(lockedHigh, '#.##') + '\n' + 'Range Low:  ' + str.tostring(lockedLow, '#.##') + '\n' + 'Range:      ' + str.tostring(lockedRange, '#.##') + '\n' + 'Projection: ' + str.tostring(lockedRange * pct, '#.##') + '\n\n' + 'Upside:     ' + str.tostring(upTarget, '#.##') + '\n' + 'Downside:   ' + str.tostring(dnTarget, '#.##'), style = label.style_label_left, color = color.black, textcolor = color.white, size = size.normal)

// ─── Plots ─────────────────────────────────────────────────
plot(showClose and not na(lockedClose) ? lockedClose : na, 'Close', color = color.white, style = plot.style_circles, linewidth = 1)

plot(showTargets ? upTarget : na, 'Upside Target', color = color.orange, style = plot.style_cross, linewidth = 2)

plot(showTargets ? dnTarget : na, 'Downside Target', color = color.blue, style = plot.style_cross, linewidth = 2)

plot(showRangeHL and not na(lockedHigh) ? lockedHigh : na, 'Range High', color = color.new(color.red, 50), style = plot.style_circles)

plot(showRangeHL and not na(lockedLow) ? lockedLow : na, 'Range Low', color = color.new(color.aqua, 50), style = plot.style_circles)
````
