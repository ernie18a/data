# Open Grid Matrix

- url: https://www.tradingview.com/script/vCkxavum/
- type: indicator
- pine_id: PUB;59fa20c5b703444da99b80b85ffd2c50
- version: 1.0

## Description

Have you ever paid close attention to the open price?

It is more than just the first traded price of a session or timeframe.
It often becomes the boundary between bullish and bearish intent, a line where conflicting expectations, positioning, and reactions collide.

This indicator was built to visualize those open prices across multiple timeframes in a clean and practical way.

Open Grid Matrix displays the open levels of several key timeframes on a single chart, allowing you to track how price behaves around them in real time. These levels often act as subtle but important reference points for continuation, rejection, hesitation, and momentum shifts.

In addition to the horizontal open lines, the indicator also plots vertical marker lines. These are aligned with repeating interval structures, especially the common 30-minute rhythm where scheduled data releases, market transitions, liquidity shifts, and session-based reactions often cluster.

What this indicator does

* Plots multiple timeframe open prices on one chart
* Extends each open line forward until the next open of the same timeframe
* Displays vertical interval markers to help frame timing structure
* Lets higher timeframe opens stand out more clearly with thicker line settings
* Uses distinct colors for each timeframe so you can quickly separate lower and higher timeframe references

Why open prices matter

Open prices are often overlooked compared to highs, lows, or closing levels, but they can be highly useful because they represent a reset point in market participation.

They can help you identify:

* bullish or bearish acceptance around a level
* hesitation and indecision zones
* intraday reaction points
* higher timeframe directional references
* areas where multiple opens begin to cluster together

How to read it

Lower timeframe opens can help with short-term structure and execution.
Higher timeframe opens can serve as broader directional anchors.

For example:

* lower timeframe open lines can highlight intraday balance shifts
* daily and weekly opens can act as strong reference zones
* monthly opens can provide a wider structural boundary
* vertical interval lines can help you anticipate moments where timing itself becomes important

Who it is for

This tool is designed for traders who like to read the chart through structure, timing, and reaction rather than relying only on conventional indicators.

It is especially useful for traders who want to keep important session and timeframe opens visible at all times without manually drawing them.

Open Grid Matrix is a visual framework for traders who believe that where price opens often matters just as much as where price moves.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kamikaze2090

//@version=6
indicator("Open Grid Matrix", overlay=true, max_lines_count=500)

// ==============================
// Inputs
// ==============================
group_time = "Time Interval"
markerTf = input.timeframe("30", "TF1 Timeframe", group=group_time)

showH1Markers = input.bool(true, "Show TF2 Markers", group=group_time)
h1Tf = input.timeframe("60", "TF2 Timeframe", group=group_time)

showH4Markers = input.bool(true, "Show TF3 Markers", group=group_time)
h4Tf = input.timeframe("240", "TF3 Timeframe", group=group_time)

showDayMarkers = input.bool(true, "Show TF4 Markers", group=group_time)
dayTf = input.timeframe("D", "TF4 Timeframe", group=group_time)

showWeekMarkers = input.bool(true, "Show TF5 Markers", group=group_time)
weekTf = input.timeframe("W", "TF5 Timeframe", group=group_time)

showMonthMarkers = input.bool(true, "Show TF6 Markers", group=group_time)
monthTf = input.timeframe("M", "TF6 Timeframe", group=group_time)

group_style = "Vertical Line Style"
lineColor = input.color(color.new(color.white, 65), "Line Color", group=group_style)
lineWidth = input.int(1, "Line Width", minval=1, maxval=5, group=group_style)
lineStyleInput = input.string("dotted", "Line Style", options=["solid", "dashed", "dotted"], group=group_style)

group_open = "Marker Open Line Style"
showMarkerOpenLine = input.bool(true, "Show Marker Open Line", group=group_open)

// Recommended default palette
openLineColor = input.color(color.rgb(255, 215, 90), "TF1 Open Line Color", group=group_open)
h1OpenLineColor = input.color(color.rgb(255, 127, 80), "TF2 Open Line Color", group=group_open)
h4OpenLineColor = input.color(color.rgb(255, 105, 180), "TF3 Open Line Color", group=group_open)
dayOpenLineColor = input.color(color.aqua, "TF4 Open Line Color", group=group_open)
weekOpenLineColor = input.color(color.green, "TF5 Open Line Color", group=group_open)
monthOpenLineColor = input.color(color.rgb(190, 160, 220), "TF6 Open Line Color", group=group_open)

openLineWidth30 = input.int(1, "TF1 Open Line Width", minval=1, maxval=5, group=group_open)
openLineWidth1H = input.int(1, "TF2 Open Line Width", minval=1, maxval=5, group=group_open)
openLineWidth4H = input.int(2, "TF3 Open Line Width", minval=1, maxval=5, group=group_open)
openLineWidthDay = input.int(2, "TF4 Open Line Width", minval=1, maxval=5, group=group_open)
openLineWidthWeek = input.int(3, "TF5 Open Line Width", minval=1, maxval=5, group=group_open)
openLineWidthMonth = input.int(3, "TF6 Open Line Width", minval=1, maxval=5, group=group_open)

openLineStyleInput = input.string("dotted", "Open Line Style", options=["solid", "dashed", "dotted"], group=group_open)

group_display = "Display"
showLines = input.bool(true, "Show Vertical Lines", group=group_display)
maxStoredLines = input.int(200, "Max Stored Lines", minval=20, maxval=500, group=group_display)

// ==============================
// Helpers
// ==============================
toLineStyle(s) =>
    s == "dashed" ? line.style_dashed :
     s == "dotted" ? line.style_dotted :
     line.style_solid

lineStyle = toLineStyle(lineStyleInput)
openLineStyle = toLineStyle(openLineStyleInput)

cleanupOldLines(_arr) =>
    while array.size(_arr) > maxStoredLines
        oldLine = array.shift(_arr)
        line.delete(oldLine)

// ==============================
// Storage
// ==============================
var line[] verticalLines = array.new_line()
var line[] markerOpenLines = array.new_line()

var line activeMarkerOpenLine30 = na
var float activeMarkerOpenPrice30 = na
var int activeMarkerStartTime30 = na

var line activeMarkerOpenLine1H = na
var float activeMarkerOpenPrice1H = na
var int activeMarkerStartTime1H = na

var line activeMarkerOpenLine4H = na
var float activeMarkerOpenPrice4H = na
var int activeMarkerStartTime4H = na

var line activeMarkerOpenLineDay = na
var float activeMarkerOpenPriceDay = na
var int activeMarkerStartTimeDay = na

var line activeMarkerOpenLineWeek = na
var float activeMarkerOpenPriceWeek = na
var int activeMarkerStartTimeWeek = na

var line activeMarkerOpenLineMonth = na
var float activeMarkerOpenPriceMonth = na
var int activeMarkerStartTimeMonth = na

// ==============================
// Events
// ==============================
timeIntervalEvent =
     showLines and
     ta.change(time(markerTf)) != 0

h1TimeIntervalEvent =
     showLines and
     showH1Markers and
     ta.change(time(h1Tf)) != 0

h4TimeIntervalEvent =
     showLines and
     showH4Markers and
     ta.change(time(h4Tf)) != 0

dayTimeIntervalEvent =
     showLines and
     showDayMarkers and
     ta.change(time(dayTf)) != 0

weekTimeIntervalEvent =
     showLines and
     showWeekMarkers and
     ta.change(time(weekTf)) != 0

monthTimeIntervalEvent =
     showLines and
     showMonthMarkers and
     ta.change(time(monthTf)) != 0

// ==============================
// Draw vertical lines
// ==============================
if timeIntervalEvent
    newLine30 = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLine30)
    cleanupOldLines(verticalLines)

if h1TimeIntervalEvent
    newLine1H = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLine1H)
    cleanupOldLines(verticalLines)

if h4TimeIntervalEvent
    newLine4H = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLine4H)
    cleanupOldLines(verticalLines)

if dayTimeIntervalEvent
    newLineDay = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLineDay)
    cleanupOldLines(verticalLines)

if weekTimeIntervalEvent
    newLineWeek = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLineWeek)
    cleanupOldLines(verticalLines)

if monthTimeIntervalEvent
    newLineMonth = line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=lineStyle, width=lineWidth)
    array.push(verticalLines, newLineMonth)
    cleanupOldLines(verticalLines)

// ==============================
// Draw TF1 marker open line
// ==============================
if timeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLine30)
        line.set_x2(activeMarkerOpenLine30, time)
        line.set_y2(activeMarkerOpenLine30, activeMarkerOpenPrice30)
        array.push(markerOpenLines, activeMarkerOpenLine30)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPrice30 := open
    activeMarkerStartTime30 := int(time)

    activeMarkerOpenLine30 := line.new(
         activeMarkerStartTime30, activeMarkerOpenPrice30,
         time, activeMarkerOpenPrice30,
         xloc=xloc.bar_time, extend=extend.none,
         color=openLineColor, style=openLineStyle, width=openLineWidth30)

if showMarkerOpenLine and not na(activeMarkerOpenLine30)
    line.set_x2(activeMarkerOpenLine30, time)
    line.set_y2(activeMarkerOpenLine30, activeMarkerOpenPrice30)
    line.set_color(activeMarkerOpenLine30, openLineColor)
    line.set_style(activeMarkerOpenLine30, openLineStyle)
    line.set_width(activeMarkerOpenLine30, openLineWidth30)

// ==============================
// Draw TF2 marker open line
// ==============================
if h1TimeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLine1H)
        line.set_x2(activeMarkerOpenLine1H, time)
        line.set_y2(activeMarkerOpenLine1H, activeMarkerOpenPrice1H)
        array.push(markerOpenLines, activeMarkerOpenLine1H)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPrice1H := open
    activeMarkerStartTime1H := int(time)

    activeMarkerOpenLine1H := line.new(
         activeMarkerStartTime1H, activeMarkerOpenPrice1H,
         time, activeMarkerOpenPrice1H,
         xloc=xloc.bar_time, extend=extend.none,
         color=h1OpenLineColor, style=openLineStyle, width=openLineWidth1H)

if showMarkerOpenLine and not na(activeMarkerOpenLine1H)
    line.set_x2(activeMarkerOpenLine1H, time)
    line.set_y2(activeMarkerOpenLine1H, activeMarkerOpenPrice1H)
    line.set_color(activeMarkerOpenLine1H, h1OpenLineColor)
    line.set_style(activeMarkerOpenLine1H, openLineStyle)
    line.set_width(activeMarkerOpenLine1H, openLineWidth1H)

// ==============================
// Draw TF3 marker open line
// ==============================
if h4TimeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLine4H)
        line.set_x2(activeMarkerOpenLine4H, time)
        line.set_y2(activeMarkerOpenLine4H, activeMarkerOpenPrice4H)
        array.push(markerOpenLines, activeMarkerOpenLine4H)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPrice4H := open
    activeMarkerStartTime4H := int(time)

    activeMarkerOpenLine4H := line.new(
         activeMarkerStartTime4H, activeMarkerOpenPrice4H,
         time, activeMarkerOpenPrice4H,
         xloc=xloc.bar_time, extend=extend.none,
         color=h4OpenLineColor, style=openLineStyle, width=openLineWidth4H)

if showMarkerOpenLine and not na(activeMarkerOpenLine4H)
    line.set_x2(activeMarkerOpenLine4H, time)
    line.set_y2(activeMarkerOpenLine4H, activeMarkerOpenPrice4H)
    line.set_color(activeMarkerOpenLine4H, h4OpenLineColor)
    line.set_style(activeMarkerOpenLine4H, openLineStyle)
    line.set_width(activeMarkerOpenLine4H, openLineWidth4H)

// ==============================
// Draw TF4 marker open line
// ==============================
if dayTimeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLineDay)
        line.set_x2(activeMarkerOpenLineDay, time)
        line.set_y2(activeMarkerOpenLineDay, activeMarkerOpenPriceDay)
        array.push(markerOpenLines, activeMarkerOpenLineDay)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPriceDay := open
    activeMarkerStartTimeDay := int(time)

    activeMarkerOpenLineDay := line.new(
         activeMarkerStartTimeDay, activeMarkerOpenPriceDay,
         time, activeMarkerOpenPriceDay,
         xloc=xloc.bar_time, extend=extend.none,
         color=dayOpenLineColor, style=openLineStyle, width=openLineWidthDay)

if showMarkerOpenLine and not na(activeMarkerOpenLineDay)
    line.set_x2(activeMarkerOpenLineDay, time)
    line.set_y2(activeMarkerOpenLineDay, activeMarkerOpenPriceDay)
    line.set_color(activeMarkerOpenLineDay, dayOpenLineColor)
    line.set_style(activeMarkerOpenLineDay, openLineStyle)
    line.set_width(activeMarkerOpenLineDay, openLineWidthDay)

// ==============================
// Draw TF5 marker open line
// ==============================
if weekTimeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLineWeek)
        line.set_x2(activeMarkerOpenLineWeek, time)
        line.set_y2(activeMarkerOpenLineWeek, activeMarkerOpenPriceWeek)
        array.push(markerOpenLines, activeMarkerOpenLineWeek)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPriceWeek := open
    activeMarkerStartTimeWeek := int(time)

    activeMarkerOpenLineWeek := line.new(
         activeMarkerStartTimeWeek, activeMarkerOpenPriceWeek,
         time, activeMarkerOpenPriceWeek,
         xloc=xloc.bar_time, extend=extend.none,
         color=weekOpenLineColor, style=openLineStyle, width=openLineWidthWeek)

if showMarkerOpenLine and not na(activeMarkerOpenLineWeek)
    line.set_x2(activeMarkerOpenLineWeek, time)
    line.set_y2(activeMarkerOpenLineWeek, activeMarkerOpenPriceWeek)
    line.set_color(activeMarkerOpenLineWeek, weekOpenLineColor)
    line.set_style(activeMarkerOpenLineWeek, openLineStyle)
    line.set_width(activeMarkerOpenLineWeek, openLineWidthWeek)

// ==============================
// Draw TF6 marker open line
// ==============================
if monthTimeIntervalEvent and showMarkerOpenLine
    if not na(activeMarkerOpenLineMonth)
        line.set_x2(activeMarkerOpenLineMonth, time)
        line.set_y2(activeMarkerOpenLineMonth, activeMarkerOpenPriceMonth)
        array.push(markerOpenLines, activeMarkerOpenLineMonth)
        cleanupOldLines(markerOpenLines)

    activeMarkerOpenPriceMonth := open
    activeMarkerStartTimeMonth := int(time)

    activeMarkerOpenLineMonth := line.new(
         activeMarkerStartTimeMonth, activeMarkerOpenPriceMonth,
         time, activeMarkerOpenPriceMonth,
         xloc=xloc.bar_time, extend=extend.none,
         color=monthOpenLineColor, style=openLineStyle, width=openLineWidthMonth)

if showMarkerOpenLine and not na(activeMarkerOpenLineMonth)
    line.set_x2(activeMarkerOpenLineMonth, time)
    line.set_y2(activeMarkerOpenLineMonth, activeMarkerOpenPriceMonth)
    line.set_color(activeMarkerOpenLineMonth, monthOpenLineColor)
    line.set_style(activeMarkerOpenLineMonth, openLineStyle)
    line.set_width(activeMarkerOpenLineMonth, openLineWidthMonth)

// ==============================
// Hide open lines when disabled
// ==============================
if not showMarkerOpenLine and not na(activeMarkerOpenLine30)
    line.delete(activeMarkerOpenLine30)
    activeMarkerOpenLine30 := na
    activeMarkerOpenPrice30 := na

if not showMarkerOpenLine and not na(activeMarkerOpenLine1H)
    line.delete(activeMarkerOpenLine1H)
    activeMarkerOpenLine1H := na
    activeMarkerOpenPrice1H := na

if not showMarkerOpenLine and not na(activeMarkerOpenLine4H)
    line.delete(activeMarkerOpenLine4H)
    activeMarkerOpenLine4H := na
    activeMarkerOpenPrice4H := na

if not showMarkerOpenLine and not na(activeMarkerOpenLineDay)
    line.delete(activeMarkerOpenLineDay)
    activeMarkerOpenLineDay := na
    activeMarkerOpenPriceDay := na

if not showMarkerOpenLine and not na(activeMarkerOpenLineWeek)
    line.delete(activeMarkerOpenLineWeek)
    activeMarkerOpenLineWeek := na
    activeMarkerOpenPriceWeek := na

if not showMarkerOpenLine and not na(activeMarkerOpenLineMonth)
    line.delete(activeMarkerOpenLineMonth)
    activeMarkerOpenLineMonth := na
    activeMarkerOpenPriceMonth := na

// ==============================
// Alerts
// ==============================
alertcondition(showLines and ta.change(time(markerTf)) != 0, title="TF1 Marker", message="TF1 marker updated")
alertcondition(showH1Markers and ta.change(time(h1Tf)) != 0, title="TF2 Marker", message="TF2 marker updated")
alertcondition(showH4Markers and ta.change(time(h4Tf)) != 0, title="TF3 Marker", message="TF3 marker updated")
alertcondition(showDayMarkers and ta.change(time(dayTf)) != 0, title="TF4 Marker", message="TF4 marker updated")
alertcondition(showWeekMarkers and ta.change(time(weekTf)) != 0, title="TF5 Marker", message="TF5 marker updated")
alertcondition(showMonthMarkers and ta.change(time(monthTf)) != 0, title="TF6 Marker", message="TF6 marker updated")

alertcondition(
     (showLines and ta.change(time(markerTf)) != 0) or
     (showH1Markers and ta.change(time(h1Tf)) != 0) or
     (showH4Markers and ta.change(time(h4Tf)) != 0) or
     (showDayMarkers and ta.change(time(dayTf)) != 0) or
     (showWeekMarkers and ta.change(time(weekTf)) != 0) or
     (showMonthMarkers and ta.change(time(monthTf)) != 0),
     title="Any Marker",
     message="One of the open grid markers updated")

// End
````
