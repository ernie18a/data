# ICT Daily & Weekly Liquidity Map

- url: https://www.tradingview.com/script/nk0rL2yd/
- type: indicator
- pine_id: PUB;e8c8e2bfcc2b4f94957c63a635bb53bf
- version: 1.0

## Description

ICT Daily & Weekly Liquidity Map is a TradingView indicator designed to map key ICT-style liquidity levels and time windows. It automatically plots previous day and previous week highs/lows using New York time, handles daylight saving time, marks daily separators, displays PDH/PDL Fibonacci retracement levels, and highlights major killzone sessions including Asian Range, London, New York, and London Close.

## Source Code

````pine
//@version=6
indicator("Previous Day/Week High/Low - New York", "PD/PW HL NY", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=200)

nyTimezone = "America/New_York"

showDaySeparators = input.bool(true, "Show NY day separators")
showLabels = input.bool(true, "Show labels")
showPreviousWeekLevels = input.bool(true, "Show PWH/PWL")
showPreviousDayFib = input.bool(true, "Show PDH/PDL fib")
showSessionMarkers = input.bool(true, "Show sessions")
displayZonesLimit = input.int(60, "Max timeframe to display sessions (minutes)", minval=1, maxval=1440)
showAsiaDeviations = input.bool(false, "Show Asian Range deviations")
asiaDeviations = input.int(2, "Asian Range deviations", minval=1)
skipWeekends = input.bool(true, "Skip weekends")
highColor = input.color(color.new(color.lime, 0), "Previous day high color")
lowColor = input.color(color.new(color.red, 0), "Previous day low color")
fibColor = input.color(color.new(color.yellow, 0), "PDH/PDL fib color")
weekHighColor = input.color(color.new(color.aqua, 0), "Previous week high color")
weekLowColor = input.color(color.new(color.orange, 0), "Previous week low color")
separatorColor = input.color(color.new(color.gray, 65), "Day separator color")
asianSessionColor = input.color(color.new(color.teal, 88), "Asian Range color")
londonSessionColor = input.color(color.new(color.blue, 88), "London Session color")
newYorkSessionColor = input.color(color.new(color.purple, 88), "New York Session color")
londonCloseSessionColor = input.color(color.new(color.orange, 88), "London Close Session color")
separatorWidth = input.int(1, "Day separator width", minval=1, maxval=4)
sessionBorderWidth = input.int(3, "Session line width", minval=1, maxval=4)
lineWidth = input.int(1, "Line width", minval=1, maxval=4)
fibLineWidth = input.int(1, "PDH/PDL fib line width", minval=1, maxval=4)
weekLineWidth = input.int(2, "PWH/PWL line width", minval=1, maxval=4)
lineStyleInput = input.string("Solid", "PDH/PDL line style", options=["Solid", "Dashed", "Dotted"])
fibLineStyleInput = input.string("Dotted", "PDH/PDL fib line style", options=["Solid", "Dashed", "Dotted"])
weekLineStyleInput = input.string("Dashed", "PWH/PWL line style", options=["Solid", "Dashed", "Dotted"])
asianSession = input.session("1900-0000", "Asian Range")
londonSession = input.session("0200-0600", "London Session")
newYorkSession = input.session("0700-1000", "New York Session")
londonCloseSession = input.session("1000-1300", "London Close Session")

pdLineStyle = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

pwLineStyle = switch weekLineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

fibLineStyle = switch fibLineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

nyMidnight(int barTime) =>
    timestamp(nyTimezone, year(barTime, nyTimezone), month(barTime, nyTimezone), dayofmonth(barTime, nyTimezone), 0, 0)

nextTradingNyMidnight(int nyMidnightTime, bool shouldSkipWeekends) =>
    nyDayOfWeek = dayofweek(nyMidnightTime, nyTimezone)
    daysToAdd = shouldSkipWeekends and nyDayOfWeek == dayofweek.friday ? 3 : 1
    timestamp(nyTimezone, year(nyMidnightTime, nyTimezone), month(nyMidnightTime, nyTimezone), dayofmonth(nyMidnightTime, nyTimezone) + daysToAdd, 0, 0)

nyWeekStart(int barTime) =>
    nyDayOfWeek = dayofweek(barTime, nyTimezone)
    daysFromMonday = nyDayOfWeek == dayofweek.sunday ? 6 : nyDayOfWeek - dayofweek.monday
    timestamp(nyTimezone, year(barTime, nyTimezone), month(barTime, nyTimezone), dayofmonth(barTime, nyTimezone) - daysFromMonday, 0, 0)

previousNyWeekStart(int weekStartTime) =>
    timestamp(nyTimezone, year(weekStartTime, nyTimezone), month(weekStartTime, nyTimezone), dayofmonth(weekStartTime, nyTimezone) - 7, 0, 0)

nextNyWeekStart(int weekStartTime) =>
    timestamp(nyTimezone, year(weekStartTime, nyTimezone), month(weekStartTime, nyTimezone), dayofmonth(weekStartTime, nyTimezone) + 7, 0, 0)

nyDayKey = year(time, nyTimezone) * 10000 + month(time, nyTimezone) * 100 + dayofmonth(time, nyTimezone)
isNewNyDay = ta.change(nyDayKey) != 0
weekStartForBar = nyWeekStart(time)
isNewNyWeek = ta.change(weekStartForBar) != 0
inAsianSession = not na(time(timeframe.period, asianSession, nyTimezone))
inLondonSession = not na(time(timeframe.period, londonSession, nyTimezone))
inNewYorkSession = not na(time(timeframe.period, newYorkSession, nyTimezone))
inLondonCloseSession = not na(time(timeframe.period, londonCloseSession, nyTimezone))
displayZones = timeframe.isintraday and timeframe.multiplier <= displayZonesLimit
sessionDailyHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
sessionDailyLow = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_on)

var float currentDayHigh = na
var float currentDayLow = na
var float currentDayOpen = na
var float currentDayClose = na
var float previousDayHigh = na
var float previousDayLow = na
var float previousDayOpen = na
var float previousDayClose = na
var float currentWeekHigh = na
var float currentWeekLow = na
var float previousWeekHigh = na
var float previousWeekLow = na
var int currentDayStartTime = na
var int previousDayStartTime = na
var int currentWeekStartTime = na
var int previousLevelWeekStartTime = na
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var array<line> fibLines = array.new<line>()
var array<label> fibLabels = array.new<label>()
var array<line> separatorLines = array.new<line>()
var array<int> separatorTimes = array.new<int>()
box asiaRangeBox = na
line londonLowLine = na
line londonHighLine = na
line newYorkLowLine = na
line newYorkHighLine = na
line londonCloseLowLine = na
line londonCloseHighLine = na
float asiaRangeLow = na
float asiaRangeHigh = na

deleteLineArray(array<line> lines) =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)

deleteLabelArray(array<label> labels) =>
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)

inSession(string sessionValue) =>
    not na(time(timeframe.period, sessionValue, nyTimezone))

startTime(string sessionValue) =>
    int sessionStartTime = na
    sessionStartTime := inSession(sessionValue) and not inSession(sessionValue)[1] ? time : sessionStartTime[1]
    sessionStartTime

isNewSession(string resolution, string sessionValue) =>
    sessionTime = time(resolution, sessionValue, nyTimezone)
    na(sessionTime[1]) and not na(sessionTime) or sessionTime[1] < sessionTime

drawHLine(startTimeValue, endTimeValue, price, lineColor, lineStyle, widthValue) =>
    line.new(startTimeValue, price, endTimeValue, price, xloc=xloc.bar_time, extend=extend.none, color=lineColor, style=lineStyle, width=widthValue)

drawFibLevel(float level, int startTime, int endTime, float lowValue, float highValue, bool isBullishDay) =>
    priceRange = highValue - lowValue
    fibPrice = isBullishDay ? highValue - priceRange * level : lowValue + priceRange * level
    fibText = str.tostring(level)
    fibLine = line.new(
         x1=startTime,
         y1=fibPrice,
         x2=endTime,
         y2=fibPrice,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=fibColor,
         style=fibLineStyle,
         width=fibLineWidth)
    array.push(fibLines, fibLine)
    if showLabels
        fibLabel = label.new(
             x=endTime,
             y=fibPrice,
             text=fibText,
             xloc=xloc.bar_time,
             style=label.style_label_left,
             textcolor=color.black,
             color=fibColor,
             size=size.tiny)
        array.push(fibLabels, fibLabel)

if barstate.isfirst
    currentDayHigh := high
    currentDayLow := low
    currentDayOpen := open
    currentDayClose := close
    currentDayStartTime := nyMidnight(time)
    currentWeekHigh := high
    currentWeekLow := low
    currentWeekStartTime := weekStartForBar

asiaSessionStart = isNewSession("1440", asianSession)
asiaStartTime = startTime(asianSession)
asiaRangeLow := asiaSessionStart ? low : inAsianSession ? math.min(low, asiaRangeLow[1]) : na
asiaRangeHigh := asiaSessionStart ? high : inAsianSession ? math.max(high, asiaRangeHigh[1]) : na
asiaRangeDiff = asiaRangeHigh[1] - asiaRangeLow[1]

if showSessionMarkers and displayZones and inAsianSession
    if inAsianSession[1]
        box.delete(asiaRangeBox[1])

    if low < asiaRangeLow
        asiaRangeLow := low
    if high > asiaRangeHigh
        asiaRangeHigh := high

    asiaRangeBox := box.new(asiaStartTime, asiaRangeHigh, time, asiaRangeLow, xloc=xloc.bar_time, bgcolor=asianSessionColor, border_color=asianSessionColor, border_style=line.style_solid)

if showSessionMarkers and displayZones and showAsiaDeviations and not inAsianSession and inAsianSession[1]
    for s = 1 to asiaDeviations
        drawHLine(asiaStartTime, time, asiaRangeHigh[1] + asiaRangeDiff * s, color.new(color.black, 0), line.style_solid, 1)
        drawHLine(asiaStartTime, time, asiaRangeLow[1] - asiaRangeDiff * s, color.new(color.black, 0), line.style_solid, 1)

londonStartTime = startTime(londonSession)

if showSessionMarkers and displayZones and inLondonSession
    if inLondonSession[1]
        line.delete(londonLowLine[1])
        line.delete(londonHighLine[1])

    londonHighLine := line.new(londonStartTime, sessionDailyHigh, time, sessionDailyHigh, xloc=xloc.bar_time, color=londonSessionColor, style=line.style_solid, width=sessionBorderWidth)
    londonLowLine := line.new(londonStartTime, sessionDailyLow, time, sessionDailyLow, xloc=xloc.bar_time, color=londonSessionColor, style=line.style_solid, width=sessionBorderWidth)

newYorkStartTime = startTime(newYorkSession)

if showSessionMarkers and displayZones and inNewYorkSession
    if inNewYorkSession[1]
        line.delete(newYorkLowLine[1])
        line.delete(newYorkHighLine[1])

    newYorkHighLine := line.new(newYorkStartTime, sessionDailyHigh, time, sessionDailyHigh, xloc=xloc.bar_time, color=newYorkSessionColor, style=line.style_solid, width=sessionBorderWidth)
    newYorkLowLine := line.new(newYorkStartTime, sessionDailyLow, time, sessionDailyLow, xloc=xloc.bar_time, color=newYorkSessionColor, style=line.style_solid, width=sessionBorderWidth)

londonCloseStartTime = startTime(londonCloseSession)

if showSessionMarkers and displayZones and inLondonCloseSession
    if inLondonCloseSession[1]
        line.delete(londonCloseLowLine[1])
        line.delete(londonCloseHighLine[1])

    londonCloseHighLine := line.new(londonCloseStartTime, sessionDailyHigh, time, sessionDailyHigh, xloc=xloc.bar_time, color=londonCloseSessionColor, style=line.style_solid, width=sessionBorderWidth)
    londonCloseLowLine := line.new(londonCloseStartTime, sessionDailyLow, time, sessionDailyLow, xloc=xloc.bar_time, color=londonCloseSessionColor, style=line.style_solid, width=sessionBorderWidth)

if isNewNyWeek
    previousWeekHigh := currentWeekHigh
    previousWeekLow := currentWeekLow
    previousLevelWeekStartTime := currentWeekStartTime
    currentWeekStartTime := weekStartForBar
    nextWeekStartTime = nextNyWeekStart(currentWeekStartTime)

    if showPreviousWeekLevels and not na(previousWeekHigh) and not na(previousWeekLow) and not na(previousLevelWeekStartTime)
        line.delete(pwhLine)
        line.delete(pwlLine)
        label.delete(pwhLabel)
        label.delete(pwlLabel)

        pwhLine := line.new(
             x1=previousLevelWeekStartTime,
             y1=previousWeekHigh,
             x2=nextWeekStartTime,
             y2=previousWeekHigh,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=weekHighColor,
             style=pwLineStyle,
             width=weekLineWidth)

        pwlLine := line.new(
             x1=previousLevelWeekStartTime,
             y1=previousWeekLow,
             x2=nextWeekStartTime,
             y2=previousWeekLow,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=weekLowColor,
             style=pwLineStyle,
             width=weekLineWidth)

        if showLabels
            pwhLabel := label.new(
                 x=nextWeekStartTime,
                 y=previousWeekHigh,
                 text="PWH",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=weekHighColor,
                 size=size.tiny)

            pwlLabel := label.new(
                 x=nextWeekStartTime,
                 y=previousWeekLow,
                 text="PWL",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=weekLowColor,
                 size=size.tiny)

    currentWeekHigh := high
    currentWeekLow := low
else
    currentWeekHigh := math.max(nz(currentWeekHigh, high), high)
    currentWeekLow := math.min(nz(currentWeekLow, low), low)

if isNewNyDay
    previousDayHigh := currentDayHigh
    previousDayLow := currentDayLow
    previousDayOpen := currentDayOpen
    previousDayClose := currentDayClose
    previousDayStartTime := currentDayStartTime
    currentDayStartTime := nyMidnight(time)
    nextDayStartTime = nextTradingNyMidnight(currentDayStartTime, skipWeekends)
    dayCurrentWeekStartTime = nyWeekStart(currentDayStartTime)
    previousWeekStartTime = previousNyWeekStart(dayCurrentWeekStartTime)

    if showDaySeparators
        separatorLine = line.new(
             x1=currentDayStartTime,
             y1=low,
             x2=currentDayStartTime,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=separatorColor,
             style=line.style_dotted,
             width=separatorWidth)
        array.push(separatorLines, separatorLine)
        array.push(separatorTimes, currentDayStartTime)

    if array.size(separatorLines) > 0
        i = array.size(separatorLines) - 1
        while i >= 0
            separatorTime = array.get(separatorTimes, i)
            if separatorTime < previousWeekStartTime
                line.delete(array.get(separatorLines, i))
                array.remove(separatorLines, i)
                array.remove(separatorTimes, i)
            i -= 1

    if not na(previousDayHigh) and not na(previousDayLow) and not na(previousDayOpen) and not na(previousDayClose) and not na(previousDayStartTime)
        line.delete(pdhLine)
        line.delete(pdlLine)
        label.delete(pdhLabel)
        label.delete(pdlLabel)
        deleteLineArray(fibLines)
        deleteLabelArray(fibLabels)

        pdhLine := line.new(
             x1=previousDayStartTime,
             y1=previousDayHigh,
             x2=nextDayStartTime,
             y2=previousDayHigh,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=highColor,
             style=pdLineStyle,
             width=lineWidth)

        pdlLine := line.new(
             x1=previousDayStartTime,
             y1=previousDayLow,
             x2=nextDayStartTime,
             y2=previousDayLow,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=lowColor,
             style=pdLineStyle,
             width=lineWidth)

        if showLabels
            pdhLabel := label.new(
                 x=nextDayStartTime,
                 y=previousDayHigh,
                 text="PDH",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=highColor,
                 size=size.tiny)

            pdlLabel := label.new(
                 x=nextDayStartTime,
                 y=previousDayLow,
                 text="PDL",
                 xloc=xloc.bar_time,
                 style=label.style_label_left,
                 textcolor=color.white,
                 color=lowColor,
                 size=size.tiny)

        if showPreviousDayFib
            isPreviousDayBullish = previousDayClose >= previousDayOpen
            drawFibLevel(0.5, currentDayStartTime, nextDayStartTime, previousDayLow, previousDayHigh, isPreviousDayBullish)
            drawFibLevel(0.62, currentDayStartTime, nextDayStartTime, previousDayLow, previousDayHigh, isPreviousDayBullish)
            drawFibLevel(0.705, currentDayStartTime, nextDayStartTime, previousDayLow, previousDayHigh, isPreviousDayBullish)
            drawFibLevel(0.79, currentDayStartTime, nextDayStartTime, previousDayLow, previousDayHigh, isPreviousDayBullish)

    currentDayHigh := high
    currentDayLow := low
    currentDayOpen := open
    currentDayClose := close
else
    currentDayHigh := math.max(nz(currentDayHigh, high), high)
    currentDayLow := math.min(nz(currentDayLow, low), low)
    currentDayClose := close
````
