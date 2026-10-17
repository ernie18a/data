# ORB High/Low + Fibonacci Targets

- url: https://www.tradingview.com/script/KzKEcLZ5-ORB-High-Low-Fibonacci-Targets/
- type: indicator
- pine_id: PUB;cdb9a5fe67604eb6a55c3d5690698f62
- version: 5.0

## Description

[b]Short Description[/b]
A Opening Range Breakout indicator that plots today’s ORB high/low, Fibonacci-based ORB targets.

[b]Full TradingView Description[/b]
ORB High/Low + Fibonacci Targets is a simple intraday Opening Range Breakout indicator designed for traders who use the first few minutes of the session to define market bias, breakout levels, and measured-move targets.
The indicator calculates the opening range using a fixed 1-minute internal calculation for accuracy, then plots clean horizontal levels for the current session’s ORB High and ORB Low. It also adds Fibonacci-based expansion targets above and below the range.

[b]Key Features[/b]
Opening Range High and Low
Plots the session’s ORB High and ORB Low as horizontal lines.
Useful for identifying breakout, breakdown, and retest zones.

Multiple ORB Duration Options
Choose from:
1m
2m
3m
5m
15m
30m
1h
4h

Session Presets
NYSE RTH: 09:30–16:00
Futures RTH: 09:30–16:15
Futures ETH: 18:00–17:00
Custom session option

Fibonacci ORB Targets
T1 = 0.618 × ORB range
T2 = 1.0 × ORB range
T3 = 1.618 × ORB range
T4 = 2.618 × ORB range

Targets Above and Below ORB
Both bullish and bearish expansion levels are labeled as T1, T2, T3, and T4.

[b]How To Use[/b]
A common ORB trading approach is:
Let the opening range complete.
Watch for price to break above ORB High or below ORB Low.
Use ORB High/Low as breakout and retest zones.
Use Fibonacci targets as potential profit-taking levels.

[b]Example bullish setup:[/b]
Price breaks above ORB High.
Price holds ORB High on a retest.
Targets can be T1, T2, T3, and T4.

[b]Example bearish setup:[/b]
Price breaks below ORB Low.
Price rejects ORB Low on a retest.
Downside targets can be T1, T2, T3, and T4.

[b]Recommended Settings[/b]
For stocks and ETFs:
Session: NYSE RTH 09:30–16:00
ORB Duration: 5m or 15m
Show ORB Sessions: Today only
Show Fibonacci Targets: Enabled

For futures:
Session: Futures RTH or ETH depending on your strategy
ORB Duration: 5m, 15m, or 30m

[b]Notes[/b]
This indicator is designed for intraday timeframes only. It automatically avoids plotting on daily or higher timeframes.
The opening range is calculated internally using 1-minute data for better precision across intraday charts.

[b]Disclaimer[/b]
This indicator is for educational and informational purposes only. It does not provide financial advice, buy/sell recommendations, or guaranteed trading signals. Always use proper risk management and combine this tool with your own trading plan. Markets can move fast — especially around the open — so trade responsibly.

## Source Code

````pine
//@version=6
indicator("ORB High/Low + Fibonacci Targets V9", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sessionPreset = input.string(
     "NYSE RTH 09:30-16:00",
     "Market Session Preset",
     options=[
         "NYSE RTH 09:30-16:00",
         "Futures RTH 09:30-16:15",
         "Futures ETH 18:00-17:00",
         "Custom"
     ],
     display=display.none
)

customSession = input.session("0930-1600", "Custom ORB Session", display=display.none)

timezoneInput = input.string(
     "America/New_York",
     "Session Timezone",
     options=["America/New_York", "America/Chicago", "Etc/UTC", "Exchange"],
     display=display.none
)

orbDurationInput = input.string(
     "5m",
     "Opening Range Duration",
     options=["1m", "2m", "3m", "5m", "15m", "30m", "1h", "4h"],
     display=display.none
)

showSessionsInput = input.string(
     "Today only",
     "Show ORB Sessions",
     options=["Today only", "Last 2 sessions", "Last 3 sessions", "Last 5 sessions", "Last 10 sessions"],
     display=display.none
)

showORB = input.bool(true, "Show ORB Lines", display=display.none)
showWhileBuilding = input.bool(true, "Show Lines While ORB Is Building", display=display.none)
showLabels = input.bool(true, "Show Labels", display=display.none)

labelOffsetBars = input.int(50, "Label Offset Bars", minval=1, maxval=500, display=display.none)
orbLineWidth = input.int(2, "Outer Range Line Width", minval=1, maxval=5, display=display.none)

orbHighColor = input.color(color.new(color.teal, 0), "Outer High Color", display=display.none)
orbLowColor = input.color(color.new(color.red, 0), "Outer Low Color", display=display.none)

orbLineStyleInput = input.string(
     "Solid",
     "Outer Range Line Style",
     options=["Solid", "Dashed", "Dotted"],
     display=display.none
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Center Line Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showCenterLine = input.bool(true, "Show Center Line", display=display.none)



centerLineColor = input.color(color.new(color.black, 0), "Center Line Color", display=display.none)
centerLineWidth = input.int(2, "Center Line Width", minval=1, maxval=5, display=display.none)

centerLineStyleInput = input.string(
     "Dotted",
     "Center Line Style",
     options=["Solid", "Dashed", "Dotted"],
     display=display.none
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fibonacci Target Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showFibTargets = input.bool(true, "Show ORB Fibonacci Targets", display=display.none)
showTargetLabels = input.bool(true, "Show Target Labels", display=display.none)

targetColor = input.color(color.orange, "Target Color", display=display.none)
targetLineWidth = input.int(1, "Target Line Width", minval=1, maxval=5, display=display.none)

targetLineStyleInput = input.string(
     "Dashed",
     "Target Line Style",
     options=["Solid", "Dashed", "Dotted"],
     display=display.none
)

// Fixed Fibonacci ORB expansion targets.
// T2 is exactly 1.0 ORB range.
fibT1 = 0.618
fibT2 = 1.000
fibT3 = 1.618
fibT4 = 2.618

// Fixed fallback calculation timeframe.
calcTf = "1"

// Extended-hours ticker.
// This is what allows pre-market high/low to work even when chart Extended Hours is OFF.
extendedTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Input Conversion
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

orbMinutes =
     orbDurationInput == "1m"  ? 1 :
     orbDurationInput == "2m"  ? 2 :
     orbDurationInput == "3m"  ? 3 :
     orbDurationInput == "5m"  ? 5 :
     orbDurationInput == "15m" ? 15 :
     orbDurationInput == "30m" ? 30 :
     orbDurationInput == "1h"  ? 60 :
     orbDurationInput == "4h"  ? 240 :
     5

keepSessions =
     showSessionsInput == "Today only"       ? 1 :
     showSessionsInput == "Last 2 sessions"  ? 2 :
     showSessionsInput == "Last 3 sessions"  ? 3 :
     showSessionsInput == "Last 5 sessions"  ? 5 :
     showSessionsInput == "Last 10 sessions" ? 10 :
     1

orbSession =
     sessionPreset == "NYSE RTH 09:30-16:00"    ? "0930-1600:23456" :
     sessionPreset == "Futures RTH 09:30-16:15" ? "0930-1615:23456" :
     sessionPreset == "Futures ETH 18:00-17:00" ? "1800-1700:1234567" :
     customSession

startHour =
     sessionPreset == "NYSE RTH 09:30-16:00"    ? 9 :
     sessionPreset == "Futures RTH 09:30-16:15" ? 9 :
     sessionPreset == "Futures ETH 18:00-17:00" ? 18 :
     9

startMinute =
     sessionPreset == "NYSE RTH 09:30-16:00"    ? 30 :
     sessionPreset == "Futures RTH 09:30-16:15" ? 30 :
     sessionPreset == "Futures ETH 18:00-17:00" ? 0 :
     30

sessionTimezone = timezoneInput == "Exchange" ? syminfo.timezone : timezoneInput

orbLineStyle =
     orbLineStyleInput == "Dashed" ? line.style_dashed :
     orbLineStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid


centerLineStyle =
     centerLineStyleInput == "Dashed" ? line.style_dashed :
     centerLineStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid

targetLineStyle =
     targetLineStyleInput == "Solid"  ? line.style_solid :
     targetLineStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Unified ORB Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_orbFull(_session, _minutes, _tz, _startHour, _startMinute) =>
    var int startTs = na

    var float orHigh = na
    var float orLow = na

    var float bodyHigh = na
    var float bodyLow = na

    inSess = not na(time(timeframe.period, _session, _tz))

    barHour = hour(time, _tz)
    barMinute = minute(time, _tz)

    sessStart = inSess and barHour == _startHour and barMinute == _startMinute

    candleBodyHigh = math.max(open, close)
    candleBodyLow = math.min(open, close)

    if sessStart
        startTs := time

        // Outer range = wick high/low.
        orHigh := high
        orLow := low

        // Inner range = body high/body low.
        bodyHigh := candleBodyHigh
        bodyLow := candleBodyLow

    sameSession = inSess and not na(startTs) and time >= startTs
    building = sameSession and time < startTs + _minutes * 60000

    if building
        orHigh := math.max(orHigh, high)
        orLow := math.min(orLow, low)

        bodyHigh := math.max(bodyHigh, candleBodyHigh)
        bodyLow := math.min(bodyLow, candleBodyLow)

    ready = sameSession and time >= startTs + _minutes * 60000

    [orHigh, orLow, bodyHigh, bodyLow, ready, building, startTs, sameSession, inSess]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pre-Market High/Low Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_preMarketHL(_session, _tz) =>
    var int preStartTs = na
    var float preHigh = na
    var float preLow = na

    preSessionTime = time(timeframe.period, _session, _tz)
    inPre = not na(preSessionTime)
    preStart = inPre and na(preSessionTime[1])

    if preStart
        preStartTs := time
        preHigh := high
        preLow := low

    if inPre and not na(preStartTs)
        preHigh := math.max(preHigh, high)
        preLow := math.min(preLow, low)

    preReady = not inPre and not na(preStartTs) and time > preStartTs

    [preHigh, preLow, preStartTs, inPre, preReady]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Chart Timeframe Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[chartOrbHigh, chartOrbLow, chartBodyTop, chartBodyBottom, chartReady, chartBuilding, chartStartTs, chartSameSession, chartInSess] =
     f_orbFull(orbSession, orbMinutes, sessionTimezone, startHour, startMinute)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1-Minute Fallback Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[oneMinOrbHigh, oneMinOrbLow, oneMinBodyTop, oneMinBodyBottom, oneMinReady, oneMinBuilding, oneMinStartTs, oneMinSameSession, oneMinInSess] =
     request.security(
         syminfo.tickerid,
         calcTf,
         f_orbFull(orbSession, orbMinutes, sessionTimezone, startHour, startMinute),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Select Calculation Source
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

chartTfSeconds = timeframe.in_seconds(timeframe.period)
tfMs = na(chartTfSeconds) ? 60000 : chartTfSeconds * 1000

orbSeconds = orbMinutes * 60

useChartTimeframeCalc =
     timeframe.isintraday and
     not na(chartTfSeconds) and
     chartTfSeconds <= orbSeconds and
     orbSeconds % chartTfSeconds == 0

// ORB lines and yellow inner range use the same source.
// This prevents replay/backtest desync.
orbHigh = useChartTimeframeCalc ? chartOrbHigh : oneMinOrbHigh
orbLow = useChartTimeframeCalc ? chartOrbLow : oneMinOrbLow

innerBodyTop = useChartTimeframeCalc ? chartBodyTop : oneMinBodyTop
innerBodyBottom = useChartTimeframeCalc ? chartBodyBottom : oneMinBodyBottom

orbReady = useChartTimeframeCalc ? chartReady : oneMinReady
orbBuilding = useChartTimeframeCalc ? chartBuilding : oneMinBuilding
orbStartTs = useChartTimeframeCalc ? chartStartTs : oneMinStartTs
orbSameSession = useChartTimeframeCalc ? chartSameSession : oneMinSameSession
inSess = useChartTimeframeCalc ? chartInSess : oneMinInSess

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Chart Display Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

canShowOnChart = showORB and timeframe.isintraday

shouldShowORB =
     canShowOnChart and
     orbSameSession and
     not na(orbStartTs) and
     not na(orbHigh) and
     not na(orbLow) and
     (showWhileBuilding ? (orbBuilding or orbReady) : orbReady)


orbRange = orbHigh - orbLow
innerBodyRange = innerBodyTop - innerBodyBottom

outerCenter = (orbHigh + orbLow) / 2.0

centerPrice = outerCenter

centerLabelText = "CENTER "

shouldShowCenterLine =
     shouldShowORB and
     showCenterLine and
     not na(centerPrice)

labelX = time + labelOffsetBars * tfMs

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Object Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int activeOrbStart = na

var line orbHighLine = na
var line orbLowLine = na
var label orbHighLabel = na
var label orbLowLabel = na

var box innerBodyBox = na

var line centerLine = na
var label centerLabel = na

var line upperT1Line = na
var line upperT2Line = na
var line upperT3Line = na
var line upperT4Line = na

var line lowerT1Line = na
var line lowerT2Line = na
var line lowerT3Line = na
var line lowerT4Line = na

var label upperT1Label = na
var label upperT2Label = na
var label upperT3Label = na
var label upperT4Label = na

var label lowerT1Label = na
var label lowerT2Label = na
var label lowerT3Label = na
var label lowerT4Label = na

var line[] allLines = array.new_line()
var int[] allLineSessions = array.new_int()

var label[] allLabels = array.new_label()
var int[] allLabelSessions = array.new_int()

var box[] allBoxes = array.new_box()
var int[] allBoxSessions = array.new_int()

var int[] keptSessions = array.new_int()

// Pre-market objects are kept separate so they refresh cleanly in replay/backtest.
var int activePreMarketStart = na
var line preMarketHighLine = na
var line preMarketLowLine = na
var label preMarketHighLabel = na
var label preMarketLowLabel = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_makeLine(_sessionId, _x1, _price, _color, _width, _style) =>
    newLine = line.new(
         x1=_x1,
         y1=_price,
         x2=labelX,
         y2=_price,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=_color,
         width=_width,
         style=_style
    )

    array.push(allLines, newLine)
    array.push(allLineSessions, _sessionId)

    newLine

f_makeLabel(_sessionId, _price, _text, _color) =>
    newLabel = label.new(
         x=labelX,
         y=_price,
         text=_text,
         xloc=xloc.bar_time,
         style=label.style_label_left,
         color=_color,
         textcolor=color.white,
         size=size.small
    )

    array.push(allLabels, newLabel)
    array.push(allLabelSessions, _sessionId)

    newLabel

f_makeBox(_sessionId, _x1, _top, _bottom, _bgColor) =>
    newBox = box.new(
         left=_x1,
         top=_top,
         right=labelX,
         bottom=_bottom,
         xloc=xloc.bar_time,
         border_color=color.new(_bgColor, 100),
         bgcolor=_bgColor
    )

    array.push(allBoxes, newBox)
    array.push(allBoxSessions, _sessionId)

    newBox

f_makeFreeLine(_x1, _price, _color, _width, _style) =>
    line.new(
         x1=_x1,
         y1=_price,
         x2=labelX,
         y2=_price,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=_color,
         width=_width,
         style=_style
    )

f_makeFreeLabel(_price, _text, _color) =>
    label.new(
         x=labelX,
         y=_price,
         text=_text,
         xloc=xloc.bar_time,
         style=label.style_label_left,
         color=_color,
         textcolor=color.white,
         size=size.small
    )

f_trimOldSessions() =>
    while array.size(keptSessions) > keepSessions
        oldSession = array.shift(keptSessions)

        int b = array.size(allBoxes) - 1
        while b >= 0
            if array.get(allBoxSessions, b) == oldSession
                box.delete(array.get(allBoxes, b))
                array.remove(allBoxes, b)
                array.remove(allBoxSessions, b)
            b -= 1

        int i = array.size(allLines) - 1
        while i >= 0
            if array.get(allLineSessions, i) == oldSession
                line.delete(array.get(allLines, i))
                array.remove(allLines, i)
                array.remove(allLineSessions, i)
            i -= 1

        int j = array.size(allLabels) - 1
        while j >= 0
            if array.get(allLabelSessions, j) == oldSession
                label.delete(array.get(allLabels, j))
                array.remove(allLabels, j)
                array.remove(allLabelSessions, j)
            j -= 1

f_updateLine(_ln, _x1, _price) =>
    if not na(_ln)
        line.set_x1(_ln, _x1)
        line.set_x2(_ln, labelX)
        line.set_y1(_ln, _price)
        line.set_y2(_ln, _price)

f_updateLabel(_lb, _price, _text) =>
    if not na(_lb)
        label.set_x(_lb, labelX)
        label.set_y(_lb, _price)
        label.set_text(_lb, _text)

f_updateBox(_bx, _x1, _top, _bottom) =>
    if not na(_bx)
        box.set_left(_bx, _x1)
        box.set_right(_bx, labelX)
        box.set_top(_bx, _top)
        box.set_bottom(_bx, _bottom)

f_deleteFreeLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

f_deleteFreeLabel(_lb) =>
    if not na(_lb)
        label.delete(_lb)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// New ORB Session Objects
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

newSessionDetected =
     shouldShowORB and
     not na(orbStartTs) and
     (na(activeOrbStart) or activeOrbStart != orbStartTs)

missingMainObjects =
     shouldShowORB and
     activeOrbStart == orbStartTs and
     (na(orbHighLine) or na(orbLowLine))

newOrbObjectsNeeded = newSessionDetected or missingMainObjects

if newOrbObjectsNeeded
    activeOrbStart := orbStartTs

    orbHighLine := na
    orbLowLine := na
    orbHighLabel := na
    orbLowLabel := na

    innerBodyBox := na

    centerLine := na
    centerLabel := na

    upperT1Line := na
    upperT2Line := na
    upperT3Line := na
    upperT4Line := na

    lowerT1Line := na
    lowerT2Line := na
    lowerT3Line := na
    lowerT4Line := na

    upperT1Label := na
    upperT2Label := na
    upperT3Label := na
    upperT4Label := na

    lowerT1Label := na
    lowerT2Label := na
    lowerT3Label := na
    lowerT4Label := na

    if not array.includes(keptSessions, activeOrbStart)
        array.push(keptSessions, activeOrbStart)

    // Outer ORB lines.
    orbHighLine := f_makeLine(activeOrbStart, orbStartTs, orbHigh, orbHighColor, orbLineWidth, orbLineStyle)
    orbLowLine := f_makeLine(activeOrbStart, orbStartTs, orbLow, orbLowColor, orbLineWidth, orbLineStyle)

    if showLabels
        orbHighLabel := f_makeLabel(activeOrbStart, orbHigh, "ORB HIGH " + str.tostring(orbHigh, format.mintick), orbHighColor)
        orbLowLabel := f_makeLabel(activeOrbStart, orbLow, "ORB LOW " + str.tostring(orbLow, format.mintick), orbLowColor)

    // Center line.
    if shouldShowCenterLine
        centerLine := f_makeLine(activeOrbStart, orbStartTs, centerPrice, centerLineColor, centerLineWidth, centerLineStyle)

        if showLabels
            centerLabel := f_makeLabel(activeOrbStart, centerPrice, centerLabelText + str.tostring(centerPrice, format.mintick), centerLineColor)

    f_trimOldSessions()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fibonacci ORB Targets
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upperT1 = orbHigh + orbRange * fibT1
upperT2 = orbHigh + orbRange * fibT2
upperT3 = orbHigh + orbRange * fibT3
upperT4 = orbHigh + orbRange * fibT4

lowerT1 = orbLow - orbRange * fibT1
lowerT2 = orbLow - orbRange * fibT2
lowerT3 = orbLow - orbRange * fibT3
lowerT4 = orbLow - orbRange * fibT4

needFibTargetObjects =
     shouldShowORB and
     orbReady and
     showFibTargets and
     activeOrbStart == orbStartTs and
     not na(orbRange) and
     orbRange > 0 and
     na(upperT1Line)

if needFibTargetObjects
    upperT1Line := f_makeLine(activeOrbStart, orbStartTs, upperT1, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    upperT2Line := f_makeLine(activeOrbStart, orbStartTs, upperT2, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    upperT3Line := f_makeLine(activeOrbStart, orbStartTs, upperT3, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    upperT4Line := f_makeLine(activeOrbStart, orbStartTs, upperT4, color.new(targetColor, 25), targetLineWidth, targetLineStyle)

    lowerT1Line := f_makeLine(activeOrbStart, orbStartTs, lowerT1, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    lowerT2Line := f_makeLine(activeOrbStart, orbStartTs, lowerT2, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    lowerT3Line := f_makeLine(activeOrbStart, orbStartTs, lowerT3, color.new(targetColor, 25), targetLineWidth, targetLineStyle)
    lowerT4Line := f_makeLine(activeOrbStart, orbStartTs, lowerT4, color.new(targetColor, 25), targetLineWidth, targetLineStyle)

    if showTargetLabels
        upperT1Label := f_makeLabel(activeOrbStart, upperT1, "T1 " + str.tostring(upperT1, format.mintick), targetColor)
        upperT2Label := f_makeLabel(activeOrbStart, upperT2, "T2 " + str.tostring(upperT2, format.mintick), targetColor)
        upperT3Label := f_makeLabel(activeOrbStart, upperT3, "T3 " + str.tostring(upperT3, format.mintick), targetColor)
        upperT4Label := f_makeLabel(activeOrbStart, upperT4, "T4 " + str.tostring(upperT4, format.mintick), targetColor)

        lowerT1Label := f_makeLabel(activeOrbStart, lowerT1, "T1 " + str.tostring(lowerT1, format.mintick), targetColor)
        lowerT2Label := f_makeLabel(activeOrbStart, lowerT2, "T2 " + str.tostring(lowerT2, format.mintick), targetColor)
        lowerT3Label := f_makeLabel(activeOrbStart, lowerT3, "T3 " + str.tostring(lowerT3, format.mintick), targetColor)
        lowerT4Label := f_makeLabel(activeOrbStart, lowerT4, "T4 " + str.tostring(lowerT4, format.mintick), targetColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Live Updates
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if shouldShowORB and activeOrbStart == orbStartTs

    // Outer ORB lines.
    f_updateLine(orbHighLine, orbStartTs, orbHigh)
    f_updateLine(orbLowLine, orbStartTs, orbLow)

    if showLabels
        f_updateLabel(orbHighLabel, orbHigh, "ORB HIGH " + str.tostring(orbHigh, format.mintick))
        f_updateLabel(orbLowLabel, orbLow, "ORB LOW " + str.tostring(orbLow, format.mintick))

    // Center line.
    if shouldShowCenterLine
        if na(centerLine)
            centerLine := f_makeLine(activeOrbStart, orbStartTs, centerPrice, centerLineColor, centerLineWidth, centerLineStyle)

        f_updateLine(centerLine, orbStartTs, centerPrice)

        if showLabels
            if na(centerLabel)
                centerLabel := f_makeLabel(activeOrbStart, centerPrice, centerLabelText + str.tostring(centerPrice, format.mintick), centerLineColor)

            f_updateLabel(centerLabel, centerPrice, centerLabelText + str.tostring(centerPrice, format.mintick))

    // Fibonacci targets.
    if orbReady and showFibTargets
        f_updateLine(upperT1Line, orbStartTs, upperT1)
        f_updateLine(upperT2Line, orbStartTs, upperT2)
        f_updateLine(upperT3Line, orbStartTs, upperT3)
        f_updateLine(upperT4Line, orbStartTs, upperT4)

        f_updateLine(lowerT1Line, orbStartTs, lowerT1)
        f_updateLine(lowerT2Line, orbStartTs, lowerT2)
        f_updateLine(lowerT3Line, orbStartTs, lowerT3)
        f_updateLine(lowerT4Line, orbStartTs, lowerT4)

        if showTargetLabels
            f_updateLabel(upperT1Label, upperT1, "T1 " + str.tostring(upperT1, format.mintick))
            f_updateLabel(upperT2Label, upperT2, "T2 " + str.tostring(upperT2, format.mintick))
            f_updateLabel(upperT3Label, upperT3, "T3 " + str.tostring(upperT3, format.mintick))
            f_updateLabel(upperT4Label, upperT4, "T4 " + str.tostring(upperT4, format.mintick))

            f_updateLabel(lowerT1Label, lowerT1, "T1 " + str.tostring(lowerT1, format.mintick))
            f_updateLabel(lowerT2Label, lowerT2, "T2 " + str.tostring(lowerT2, format.mintick))
            f_updateLabel(lowerT3Label, lowerT3, "T3 " + str.tostring(lowerT3, format.mintick))
            f_updateLabel(lowerT4Label, lowerT4, "T4 " + str.tostring(lowerT4, format.mintick))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

orbBreakUp = shouldShowORB and orbReady and ta.crossover(close, orbHigh)
orbBreakDown = shouldShowORB and orbReady and ta.crossunder(close, orbLow)

alertcondition(orbBreakUp, title="ORB High Breakout", message="Price crossed above ORB High.")
alertcondition(orbBreakDown, title="ORB Low Breakdown", message="Price crossed below ORB Low.")
````
