# Daily Initial Balance - One Box Reset

- url: https://www.tradingview.com/script/Owpy4O6k-Daily-Initial-Balance-One-Box-Reset/
- type: indicator
- pine_id: PUB;4418a0e097824938905a76c19847e9c3
- version: 1.0

## Description

Daily Initial Balance - One Box Reset
Daily Initial Balance - One Box Reset
Daily Initial Balance - One Box Reset
Daily Initial Balance - One Box Reset
Daily Initial Balance - One Box Reset
Daily Initial Balance - One Box Reset

## Source Code

````pine
//@version=6
indicator("Daily Initial Balance - One Box Reset", overlay=true, max_boxes_count=20, max_lines_count=20)

// ----------------------------------------------------
// Inputs
// ----------------------------------------------------
tz = input.string("America/New_York", "Timezone")

ibSession = input.session("0930-1030", "Initial Balance Session")

endHour = input.int(16, "Daily Close Hour", minval=0, maxval=23)
endMinute = input.int(0, "Daily Close Minute", minval=0, maxval=59)

showMidpoint = input.bool(true, "Show Midpoint")

boxFillColor = input.color(color.new(color.blue, 88), "IB Box Fill")
boxBorderColor = input.color(color.new(color.blue, 10), "IB Box Border")
midColor = input.color(color.yellow, "Midpoint Color")

midWidth = input.int(2, "Midpoint Width", minval=1, maxval=5)

// ----------------------------------------------------
// Helpers
// ----------------------------------------------------
f_dayKey(int t) =>
    year(t, tz) * 10000 + month(t, tz) * 100 + dayofmonth(t, tz)

f_endTimestamp(int startTime) =>
    y = year(startTime, tz)
    m = month(startTime, tz)
    d = dayofmonth(startTime, tz)

    endTs = timestamp(tz, y, m, d, endHour, endMinute)

    // For IB sessions that start after the close, like 18:00,
    // the end is the next calendar day at 16:00.
    endTs <= startTime ? endTs + 24 * 60 * 60 * 1000 : endTs

f_minTime(int a, int b) =>
    a < b ? a : b

// ----------------------------------------------------
// IB Detection
// ----------------------------------------------------
inIB = not na(time(timeframe.period, ibSession, tz))

currentDayKey = f_dayKey(time)

// ----------------------------------------------------
// State
// ----------------------------------------------------
var int activeIBDayKey = na
var int ibStartTime = na
var int ibEndTime = na

var float ibHigh = na
var float ibLow = na
var float ibMid = na

var box ibBox = na
var line midLine = na

// ----------------------------------------------------
// New IB Reset
// This is the key fix:
// If we are inside IB and today's IB hasn't been started yet,
// delete the old box and create a brand new one.
// ----------------------------------------------------
newIB = inIB and (na(activeIBDayKey) or currentDayKey != activeIBDayKey)

if newIB
    activeIBDayKey := currentDayKey

    ibStartTime := time
    ibEndTime := f_endTimestamp(ibStartTime)

    ibHigh := high
    ibLow := low
    ibMid := (ibHigh + ibLow) / 2.0

    if not na(ibBox)
        box.delete(ibBox)

    if not na(midLine)
        line.delete(midLine)

    rightEdge = f_minTime(time_close, ibEndTime)

    ibBox := box.new(
         left=ibStartTime,
         top=ibHigh,
         right=rightEdge,
         bottom=ibLow,
         xloc=xloc.bar_time,
         bgcolor=boxFillColor,
         border_color=boxBorderColor
    )

    if showMidpoint
        midLine := line.new(
             x1=ibStartTime,
             y1=ibMid,
             x2=rightEdge,
             y2=ibMid,
             xloc=xloc.bar_time,
             color=midColor,
             width=midWidth,
             style=line.style_dashed
        )

// ----------------------------------------------------
// Build IB High/Low During IB Window
// ----------------------------------------------------
if inIB and not na(ibBox)
    ibHigh := math.max(ibHigh, high)
    ibLow := math.min(ibLow, low)
    ibMid := (ibHigh + ibLow) / 2.0

    rightEdge = f_minTime(time_close, ibEndTime)

    box.set_top(ibBox, ibHigh)
    box.set_bottom(ibBox, ibLow)
    box.set_right(ibBox, rightEdge)

    if showMidpoint and not na(midLine)
        line.set_y1(midLine, ibMid)
        line.set_y2(midLine, ibMid)
        line.set_x2(midLine, rightEdge)

// ----------------------------------------------------
// Extend After IB Until Daily Close
// ----------------------------------------------------
afterIBSameDay = not inIB and not na(activeIBDayKey) and currentDayKey == activeIBDayKey
beforeClose = not na(ibEndTime) and time < ibEndTime

if afterIBSameDay and beforeClose and not na(ibBox)
    rightEdge = f_minTime(time_close, ibEndTime)

    box.set_right(ibBox, rightEdge)

    if showMidpoint and not na(midLine)
        line.set_x2(midLine, rightEdge)
````
