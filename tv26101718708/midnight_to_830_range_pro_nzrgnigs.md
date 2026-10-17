# Midnight to 8:30 Range Pro

- url: https://www.tradingview.com/script/NZrgnIgS-Midnight-to-8-30-Range-Pro/
- type: indicator
- pine_id: PUB;7f4aafe5d8c54b00a5d7e13e1273c61e
- version: 1.0

## Description

Description
Midnight to 8:30 Range Pro is a time-based session range indicator that tracks price action from midnight to a user-defined main time, with the default set to 8:30 AM. It is designed to help traders mark the overnight range, identify the latest high and low formed before the main session reference time, and visualize how price is positioned relative to that range.

The script draws a vertical line at midnight and another vertical line at the selected main time using a user-defined timezone. Between those two points, it tracks the highest high and lowest low, then draws horizontal lines from the exact candles that created those extremes to the main time line without extending beyond it

Features
Midnight vertical line with custom color and width.
Main time vertical line with custom hour, minute, color, and width.
Timezone-based logic for more reliable alignment.
High and low range tracking from midnight to the selected main time.
Horizontal range lines that start only from the candle that formed the extreme and stop at the main time line.
Latest equal high / latest equal low logic, so the closest matching extreme to the main candle is used.
Optional labels and markers for the latest session high and low candles.
Optional mitigation behavior after the main time.
Optional alerts and a stats board.

## Source Code

````pine
//@version=6
indicator("Midnight to 8:30 Range Pro", overlay=true, max_lines_count=500, max_labels_count=500)

//────────────────────────────────────
// TIME SETTINGS
//────────────────────────────────────
groupTime = "Time Settings"
tzInput      = input.string("America/New_York", "Timezone", group=groupTime)
mainHour     = input.int(8, "Main Hour", minval=0, maxval=23, group=groupTime)
mainMinute   = input.int(30, "Main Minute", minval=0, maxval=59, group=groupTime)
showMidnight = input.bool(true, "Show Midnight Line", group=groupTime)

//────────────────────────────────────
// MAIN VERTICAL LINE
//────────────────────────────────────
groupMain = "Main Vertical Line"
showMainLine = input.bool(true, "Show Main Vertical Line", group=groupMain)
mainColor    = input.color(color.green, "Main Line Color", group=groupMain)
mainWidth    = input.int(2, "Main Line Width", minval=1, maxval=5, group=groupMain)

//────────────────────────────────────
// MIDNIGHT VERTICAL LINE
//────────────────────────────────────
groupMid = "Midnight Vertical Line"
midnightColor = input.color(color.gray, "Midnight Line Color", group=groupMid)
midnightWidth = input.int(1, "Midnight Line Width", minval=1, maxval=5, group=groupMid)
midnightLabelColor = input.color(color.gray, "Midnight Label Color", group=groupMid)
showMidnightLabel  = input.bool(false, "Show Midnight Label", group=groupMid)

//────────────────────────────────────
// RANGE LINES
//────────────────────────────────────
groupRange = "Range Lines"
showRangeLines  = input.bool(true, "Show High/Low Range Lines", group=groupRange)
highLineColor   = input.color(color.green, "High Line Color", group=groupRange)
lowLineColor    = input.color(color.red, "Low Line Color", group=groupRange)
rangeLineWidth  = input.int(2, "Range Line Width", minval=1, maxval=5, group=groupRange)
mitigateLines   = input.bool(false, "Stop Range Lines When Touched After 8:30", group=groupRange)
useBodyExtremes = input.bool(false, "Use Candle Bodies Instead of Wicks", group=groupRange)

//────────────────────────────────────
// MARKERS
//────────────────────────────────────
groupMarkers = "Markers"
showMarkers     = input.bool(true, "Mark Latest High/Low Candles", group=groupMarkers)
highMarkerColor = input.color(color.green, "High Marker Color", group=groupMarkers)
lowMarkerColor  = input.color(color.red, "Low Marker Color", group=groupMarkers)
markerText      = input.bool(true, "Show Marker Text", group=groupMarkers)

//────────────────────────────────────
// LABELS
//────────────────────────────────────
groupLabels = "Labels"
showMainLabel  = input.bool(true, "Show Main Time Label", group=groupLabels)
labelTextColor = input.color(color.white, "Label Text Color", group=groupLabels)
labelBgColor   = input.color(color.green, "Label Background Color", group=groupLabels)

//────────────────────────────────────
// STATS BOARD
//────────────────────────────────────
groupTable = "Stats Board"
showTable = input.bool(true, "Show Stats Board", group=groupTable)
tablePos  = input.string("Top Right", "Board Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupTable)

//────────────────────────────────────
// ALERTS
//────────────────────────────────────
groupAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable Alert Conditions", group=groupAlerts)

//────────────────────────────────────
// HELPER
//────────────────────────────────────
f_tablePos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

//────────────────────────────────────
// TIME LOGIC
//────────────────────────────────────
currHour   = hour(time, tzInput)
currMinute = minute(time, tzInput)

midnightHit = currHour == 0 and currMinute == 0
mainHitRaw  = currHour == mainHour and currMinute == mainMinute

tfMinutes = timeframe.in_seconds() / 60
isIntradayMinutes = timeframe.isintraday and timeframe.isminutes
usePrevBar = isIntradayMinutes and (mainMinute % int(tfMinutes) == int(tfMinutes) - 1)

mainBarIndex = usePrevBar ? bar_index - 1 : bar_index
mainBarHigh  = usePrevBar ? high[1] : high
mainBarLow   = usePrevBar ? low[1] : low
mainBarClose = usePrevBar ? close[1] : close

mainHit = mainHitRaw

//────────────────────────────────────
// SOURCE FOR EXTREMES
//────────────────────────────────────
srcHigh = useBodyExtremes ? math.max(open, close) : high
srcLow  = useBodyExtremes ? math.min(open, close) : low

//────────────────────────────────────
// SESSION TRACKING
//────────────────────────────────────
var bool trackingRange = false
var float sessionHigh = na
var float sessionLow = na
var int sessionHighBar = na
var int sessionLowBar = na

var line activeHighLine = na
var line activeLowLine = na
var float activeHighPrice = na
var float activeLowPrice = na
var bool highLineMitigated = false
var bool lowLineMitigated = false

if midnightHit
    trackingRange := true
    sessionHigh := srcHigh
    sessionLow := srcLow
    sessionHighBar := bar_index
    sessionLowBar := bar_index
    highLineMitigated := false
    lowLineMitigated := false

if trackingRange
    if na(sessionHigh) or srcHigh > sessionHigh
        sessionHigh := srcHigh
        sessionHighBar := bar_index
    else if srcHigh == sessionHigh
        sessionHighBar := bar_index

    if na(sessionLow) or srcLow < sessionLow
        sessionLow := srcLow
        sessionLowBar := bar_index
    else if srcLow == sessionLow
        sessionLowBar := bar_index

//────────────────────────────────────
// MIDNIGHT LINE
//────────────────────────────────────
if showMidnight and midnightHit
    line.new(
         bar_index,
         low - 10 * syminfo.mintick,
         bar_index,
         high + 10 * syminfo.mintick,
         extend=extend.both,
         color=midnightColor,
         width=midnightWidth
     )

    if showMidnightLabel
        label.new(
             bar_index,
             high,
             text="Midnight",
             style=label.style_label_down,
             textcolor=color.white,
             color=midnightLabelColor
         )

//────────────────────────────────────
// MAIN LINE + RANGE DRAW
//────────────────────────────────────
if showMainLine and mainHit
    line.new(
         bar_index,
         low - 10 * syminfo.mintick,
         bar_index,
         high + 10 * syminfo.mintick,
         extend=extend.both,
         color=mainColor,
         width=mainWidth
     )

    if showMainLabel
        txt = str.tostring(mainHour) + ":" + str.tostring(mainMinute) + " | Close: " + str.tostring(mainBarClose)
        label.new(
             mainBarIndex,
             mainBarHigh,
             text=txt,
             style=label.style_label_down,
             textcolor=labelTextColor,
             color=labelBgColor
         )

    if showRangeLines and trackingRange
        activeHighLine := line.new(
             sessionHighBar,
             sessionHigh,
             mainBarIndex,
             sessionHigh,
             extend=extend.none,
             color=highLineColor,
             width=rangeLineWidth
         )

        activeLowLine := line.new(
             sessionLowBar,
             sessionLow,
             mainBarIndex,
             sessionLow,
             extend=extend.none,
             color=lowLineColor,
             width=rangeLineWidth
         )

        activeHighPrice := sessionHigh
        activeLowPrice := sessionLow

    if showMarkers and trackingRange
        highTxt = markerText ? "Latest High" : ""
        lowTxt  = markerText ? "Latest Low" : ""

        label.new(
             sessionHighBar,
             sessionHigh,
             text=highTxt,
             style=label.style_label_down,
             textcolor=color.white,
             color=highMarkerColor
         )

        label.new(
             sessionLowBar,
             sessionLow,
             text=lowTxt,
             style=label.style_label_up,
             textcolor=color.white,
             color=lowMarkerColor
         )

    trackingRange := false

//────────────────────────────────────
// MITIGATION
//────────────────────────────────────
afterMainTime = currHour > mainHour or (currHour == mainHour and currMinute > mainMinute)

if mitigateLines and not na(activeHighLine) and not highLineMitigated and afterMainTime
    if high >= activeHighPrice
        line.set_x2(activeHighLine, bar_index)
        highLineMitigated := true

if mitigateLines and not na(activeLowLine) and not lowLineMitigated and afterMainTime
    if low <= activeLowPrice
        line.set_x2(activeLowLine, bar_index)
        lowLineMitigated := true

//────────────────────────────────────
// STATS BOARD
//────────────────────────────────────
var table stats = table.new(f_tablePos(tablePos), 2, 6, border_width=1)

rangePoints = na(sessionHigh) or na(sessionLow) ? na : sessionHigh - sessionLow
distCloseToHigh = na(sessionHigh) ? na : sessionHigh - mainBarClose
distCloseToLow  = na(sessionLow) ? na : mainBarClose - sessionLow
lastExtreme = sessionHighBar > sessionLowBar ? "High" : "Low"

if barstate.islast and showTable
    table.cell(stats, 0, 0, "Metric", text_color=color.white, bgcolor=color.rgb(40, 40, 40))
    table.cell(stats, 1, 0, "Value", text_color=color.white, bgcolor=color.rgb(40, 40, 40))
    table.cell(stats, 0, 1, "Timezone", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 1, 1, tzInput, text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 0, 2, "Range H-L", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 1, 2, str.tostring(rangePoints), text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 0, 3, "Close to High", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 1, 3, str.tostring(distCloseToHigh), text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 0, 4, "Close to Low", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 1, 4, str.tostring(distCloseToLow), text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 0, 5, "Latest Extreme", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(stats, 1, 5, lastExtreme, text_color=color.white, bgcolor=color.rgb(30, 30, 30))

//────────────────────────────────────
// ALERTS
//────────────────────────────────────
alertcondition(enableAlerts and midnightHit, "Midnight Hit", "Midnight line printed on {{ticker}}")
alertcondition(enableAlerts and mainHit, "Main Time Hit", "Main time line printed on {{ticker}}")
alertcondition(enableAlerts and mainHit and sessionHighBar > sessionLowBar, "Latest Extreme High", "Latest extreme before main time is HIGH on {{ticker}}")
alertcondition(enableAlerts and mainHit and sessionLowBar > sessionHighBar, "Latest Extreme Low", "Latest extreme before main time is LOW on {{ticker}}")
alertcondition(enableAlerts and mitigateLines and afterMainTime and not na(activeHighPrice) and high >= activeHighPrice, "High Line Mitigated", "Session high line mitigated on {{ticker}}")
alertcondition(enableAlerts and mitigateLines and afterMainTime and not na(activeLowPrice) and low <= activeLowPrice, "Low Line Mitigated", "Session low line mitigated on {{ticker}}")
````
