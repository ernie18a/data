# Futures Asia/London + Previous NY High/Low JUCETRADES

- url: https://www.tradingview.com/script/fgcn2eyr-Futures-Asia-London-Previous-NY-High-Low-JUCETRADES/
- type: indicator
- pine_id: PUB;df5ef5be4bc44718bde04c977f4aef8c
- version: 1.0

## Description

Futures Asia/London + Previous NY High/Low. NY session highs and lows are from the previous day, but shown going into new day 6PM EST - 5PM EST. Asia/London sessions are indicated from the overnight session same day. I like to use these as a confluence with supply and demand, ect.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JuceTrades

//@version=6
indicator("Futures Asia/London + Previous NY High/Low", overlay=true, max_lines_count=500, max_labels_count=500)

tz = input.string("America/Los_Angeles", "Timezone")

asianSession  = input.session("1500-0000", "Asian Session")
londonSession = input.session("0000-0630", "London Session")
nySession     = input.session("0630-1400", "New York Session")

futuresOpenHour = input.int(15, "Futures day open hour", minval=0, maxval=23)
cutoffHour      = input.int(14, "Line cutoff hour", minval=0, maxval=23)
cutoffMinute    = input.int(0, "Line cutoff minute", minval=0, maxval=59)

currentDayOnly = input.bool(true, "Show Current Futures Day Only")

asianColor  = input.color(color.rgb(35, 197, 251), "Asian Color")
londonColor = input.color(color.rgb(243, 152, 33), "London Color")
pdhColor    = input.color(color.green, "Previous NY High Color")
pdlColor    = input.color(color.red, "Previous NY Low Color")

lineWidth    = input.int(2, "Line Width", minval=1, maxval=5)
lineOpacity  = input.int(0, "Line Opacity", minval=0, maxval=100)
labelOpacity = input.int(60, "Label Opacity", minval=0, maxval=100)

showLabels = input.bool(true, "Show Labels")

showAsian  = input.bool(true, "Show Asian")
showLondon = input.bool(true, "Show London")
showPNYH   = input.bool(true, "Show Previous NY High")
showPNYL   = input.bool(true, "Show Previous NY Low")

f_futuresDayStart(t) =>
    sameDayStart = timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), futuresOpenHour, 0)
    t >= sameDayStart ? sameDayStart : timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz) - 1, futuresOpenHour, 0)

f_futuresDayEnd(startTime) =>
    timestamp(tz, year(startTime, tz), month(startTime, tz), dayofmonth(startTime, tz) + 1, cutoffHour, cutoffMinute)

isCurrentFuturesDay(t) =>
    f_futuresDayStart(t) == f_futuresDayStart(timenow)

f_sessionLines(sess, sessName, sessColor, enabled) =>
    inSess = not na(time(timeframe.period, sess, tz))
    newSess = inSess and not inSess[1]

    var float sessHigh = na
    var float sessLow = na
    var int startTime = na
    var line highLine = na
    var line lowLine = na
    var label highLabel = na
    var label lowLabel = na

    allowedDay = not currentDayOnly or isCurrentFuturesDay(time)

    if enabled and allowedDay
        if newSess
            if currentDayOnly
                line.delete(highLine)
                line.delete(lowLine)
                label.delete(highLabel)
                label.delete(lowLabel)

            sessHigh := high
            sessLow := low
            startTime := time
            endTime = f_futuresDayEnd(f_futuresDayStart(time))

            highLine := line.new(startTime, sessHigh, endTime, sessHigh, xloc=xloc.bar_time, color=color.new(sessColor, lineOpacity), width=lineWidth)
            lowLine := line.new(startTime, sessLow, endTime, sessLow, xloc=xloc.bar_time, color=color.new(sessColor, lineOpacity), width=lineWidth)

            if showLabels
                highLabel := label.new(endTime, sessHigh, sessName + " High", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=color.new(sessColor, labelOpacity))
                lowLabel := label.new(endTime, sessLow, sessName + " Low", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=color.new(sessColor, labelOpacity))

        if inSess
            sessHigh := math.max(sessHigh, high)
            sessLow := math.min(sessLow, low)
            endTime = f_futuresDayEnd(f_futuresDayStart(time))

            line.set_xy1(highLine, startTime, sessHigh)
            line.set_xy2(highLine, endTime, sessHigh)
            line.set_xy1(lowLine, startTime, sessLow)
            line.set_xy2(lowLine, endTime, sessLow)

            if showLabels
                label.set_xy(highLabel, endTime, sessHigh)
                label.set_xy(lowLabel, endTime, sessLow)

    0

// Previous New York session high/low
inNY = not na(time(timeframe.period, nySession, tz))
newNY = inNY and not inNY[1]
endNY = not inNY and inNY[1]

var float nyHigh = na
var float nyLow = na
var float prevNYHigh = na
var float prevNYLow = na

var line pnyhLine = na
var line pnylLine = na
var label pnyhLabel = na
var label pnylLabel = na

if newNY
    nyHigh := high
    nyLow := low

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

if endNY
    prevNYHigh := nyHigh
    prevNYLow := nyLow

newFuturesDay = ta.change(f_futuresDayStart(time)) != 0

if newFuturesDay
    if currentDayOnly
        line.delete(pnyhLine)
        line.delete(pnylLine)
        label.delete(pnyhLabel)
        label.delete(pnylLabel)

    startLine = f_futuresDayStart(time)
    endLine = f_futuresDayEnd(startLine)

    if showPNYH and not na(prevNYHigh)
        pnyhLine := line.new(startLine, prevNYHigh, endLine, prevNYHigh, xloc=xloc.bar_time, color=color.new(pdhColor, lineOpacity), width=lineWidth)
        if showLabels
            pnyhLabel := label.new(endLine, prevNYHigh, "PDH", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=color.new(pdhColor, labelOpacity))

    if showPNYL and not na(prevNYLow)
        pnylLine := line.new(startLine, prevNYLow, endLine, prevNYLow, xloc=xloc.bar_time, color=color.new(pdlColor, lineOpacity), width=lineWidth)
        if showLabels
            pnylLabel := label.new(endLine, prevNYLow, "PDL", xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.white, color=color.new(pdlColor, labelOpacity))

if not na(pnyhLine)
    line.set_x2(pnyhLine, f_futuresDayEnd(f_futuresDayStart(time)))
    if showLabels and not na(pnyhLabel)
        label.set_x(pnyhLabel, f_futuresDayEnd(f_futuresDayStart(time)))

if not na(pnylLine)
    line.set_x2(pnylLine, f_futuresDayEnd(f_futuresDayStart(time)))
    if showLabels and not na(pnylLabel)
        label.set_x(pnylLabel, f_futuresDayEnd(f_futuresDayStart(time)))

f_sessionLines(asianSession, "Asia", asianColor, showAsian)
f_sessionLines(londonSession, "London", londonColor, showLondon)
````
