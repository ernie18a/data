# OBR USA - JKR

- url: https://www.tradingview.com/script/2VN06xP2/
- type: indicator
- pine_id: PUB;8e1e5f16e01344f48386c36482ab61d4
- version: 3.0

## Description

This indicator displays the Opening Range based on a configurable time window.

By default, it tracks the highest and lowest price between 15:30 and 15:45. Once the range period is finished, it draws two horizontal lines showing the Opening Range High and Opening Range Low.

The line color, line width, timezone, and range time can be adjusted in the settings. Historical opening ranges can also be displayed if enabled.

Best used on intraday timeframes such as 1m, 3m, 5m, or 15m.

## Source Code

````pine
//@version=6
indicator("Opening Range 15:30 - 15:45", overlay = true, max_lines_count = 500)

// Inputs
tz = input.string("Europe/Berlin", "Zeitzone")

startHour   = input.int(15, "Start Stunde", minval = 0, maxval = 23)
startMinute = input.int(30, "Start Minute", minval = 0, maxval = 59)

endHour     = input.int(15, "Ende Stunde", minval = 0, maxval = 23)
endMinute   = input.int(45, "Ende Minute", minval = 0, maxval = 59)

orColor = input.color(color.rgb(255, 140, 0), "Linienfarbe")
orWidth = input.int(2, "Linienbreite", minval = 1, maxval = 5)

showPreviousDays = input.bool(true, "Vorherige Tage anzeigen")
extendCurrentDay = input.bool(true, "Aktuelle Linien nach rechts verlängern")

showRangeBackground = input.bool(false, "Opening-Range-Zeitfenster markieren")

enableAlerts = input.bool(true, "Breakout-Alarm aktivieren")
showBreakoutMarkers = input.bool(true, "Breakout-Marker anzeigen")

// Fixed alert timeframe.
// The breakout alert always uses 1-minute candles, independent of the chart timeframe.
alertTimeframe = "1"

// Time calculation
curMinuteOfDay = hour(time, tz) * 60 + minute(time, tz)
startMinuteOfDay = startHour * 60 + startMinute
endMinuteOfDay = endHour * 60 + endMinute

isIntraday = timeframe.isintraday
inOpeningRange = isIntraday and curMinuteOfDay >= startMinuteOfDay and curMinuteOfDay < endMinuteOfDay

dayId = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

// 1-minute Opening Range and Breakout calculation
f_openingRange1m() =>
    curMinute1m = hour(time, tz) * 60 + minute(time, tz)
    prevMinute1m = hour(time[1], tz) * 60 + minute(time[1], tz)

    dayId1m = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

    inRange1m = curMinute1m >= startMinuteOfDay and curMinute1m < endMinuteOfDay
    afterRangePrev1m = prevMinute1m >= endMinuteOfDay

    var int activeDayId1m = na
    var float high1m = na
    var float low1m = na
    var bool rangeReady1m = false
    var bool breakoutDone1m = false
    var int breakoutDirection1m = 0
    var int breakoutCounter1m = 0

    newDay1m = na(activeDayId1m) or dayId1m != activeDayId1m

    if newDay1m
        activeDayId1m := dayId1m
        high1m := na
        low1m := na
        rangeReady1m := false
        breakoutDone1m := false
        breakoutDirection1m := 0

    // Collect high/low on real 1-minute candles
    if inRange1m
        high1m := na(high1m) ? high : math.max(high1m, high)
        low1m := na(low1m) ? low : math.min(low1m, low)

    // Range is ready after the configured time window has ended
    if curMinute1m >= endMinuteOfDay and not rangeReady1m and not na(high1m) and not na(low1m)
        rangeReady1m := true

    // Use the previous 1-minute candle because it is completed.
    breakoutUp1m = rangeReady1m and not breakoutDone1m and afterRangePrev1m and close[1] > high1m
    breakoutDown1m = rangeReady1m and not breakoutDone1m and afterRangePrev1m and close[1] < low1m

    if breakoutUp1m
        breakoutDone1m := true
        breakoutDirection1m := 1
        breakoutCounter1m += 1

    if breakoutDown1m
        breakoutDone1m := true
        breakoutDirection1m := -1
        breakoutCounter1m += 1

    [high1m, low1m, rangeReady1m, breakoutDirection1m, breakoutCounter1m]

// Request fixed 1-minute data, independent of chart timeframe
[orHigh1m, orLow1m, rangeReady1m, breakoutDirection1m, breakoutCounter1m] = request.security(
     syminfo.tickerid,
     alertTimeframe,
     f_openingRange1m(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// Drawing state
var int activeDayId = na
var bool rangeDrawn = false

var line highLine = na
var line lowLine = na

newDay = na(activeDayId) or dayId != activeDayId

if newDay
    if not showPreviousDays
        if not na(highLine)
            line.delete(highLine)
        if not na(lowLine)
            line.delete(lowLine)

    activeDayId := dayId
    rangeDrawn := false
    highLine := na
    lowLine := na

// Draw lines once the 1-minute range is ready
shouldDrawRange = rangeReady1m and not rangeDrawn and not na(orHigh1m) and not na(orLow1m)

if shouldDrawRange
    rangeEndTime = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), endHour, endMinute)

    highLine := line.new(
         x1 = rangeEndTime,
         y1 = orHigh1m,
         x2 = time_close,
         y2 = orHigh1m,
         xloc = xloc.bar_time,
         extend = not showPreviousDays and extendCurrentDay ? extend.right : extend.none,
         color = orColor,
         width = orWidth
     )

    lowLine := line.new(
         x1 = rangeEndTime,
         y1 = orLow1m,
         x2 = time_close,
         y2 = orLow1m,
         xloc = xloc.bar_time,
         extend = not showPreviousDays and extendCurrentDay ? extend.right : extend.none,
         color = orColor,
         width = orWidth
     )

    rangeDrawn := true

// If lines are not extended infinitely, keep extending them until the day changes
if rangeDrawn and not na(highLine) and not na(lowLine) and (showPreviousDays or not extendCurrentDay)
    line.set_x2(highLine, time_close)
    line.set_x2(lowLine, time_close)

// Breakout event from fixed 1-minute logic
breakoutEvent1m = enableAlerts and not na(breakoutCounter1m[1]) and breakoutCounter1m != breakoutCounter1m[1]

breakoutUp = breakoutEvent1m and breakoutDirection1m == 1
breakoutDown = breakoutEvent1m and breakoutDirection1m == -1
breakoutAny = breakoutUp or breakoutDown

// Alert conditions
alertcondition(
     breakoutUp,
     title = "Opening Range Breakout Up 1m",
     message = "Opening Range Breakout UP: The first completed 1-minute candle closed above the Opening Range High."
)

alertcondition(
     breakoutDown,
     title = "Opening Range Breakout Down 1m",
     message = "Opening Range Breakout DOWN: The first completed 1-minute candle closed below the Opening Range Low."
)

alertcondition(
     breakoutAny,
     title = "Opening Range Breakout Any Direction 1m",
     message = "Opening Range Breakout: The first completed 1-minute candle closed outside the Opening Range."
)

// Optional visual marker
plotshape(
     showBreakoutMarkers and breakoutUp,
     title = "Breakout Up Marker",
     style = shape.triangleup,
     location = location.belowbar,
     size = size.small,
     text = "OR↑"
)

plotshape(
     showBreakoutMarkers and breakoutDown,
     title = "Breakout Down Marker",
     style = shape.triangledown,
     location = location.abovebar,
     size = size.small,
     text = "OR↓"
)

// Optional visual marker during collection phase
bgcolor(showRangeBackground and inOpeningRange ? color.new(orColor, 90) : na)
````
