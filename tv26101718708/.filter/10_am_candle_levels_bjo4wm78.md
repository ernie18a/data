# 10 AM Candle Levels 

- url: https://www.tradingview.com/script/bJO4wm78-10-AM-Candle-Levels/
- type: indicator
- pine_id: PUB;47a7fec6296542e2921122acc05a4d08
- version: 1.0

## Description

10 AM Candle Levels
Marks the 10:00 AM ET candle on intraday charts and projects its key levels forward across the session. The 10 AM candle often sets a reference point for the New York morning — this tool keeps its high, low, and body in view so you can track how price reacts to them.
Features

Auto-detects the 10:00 AM ET candle on any intraday timeframe
Plots the candle high and low as horizontal levels that extend to the right
Draws an extended body box (open–close range) for a clean visual zone
Historical lookback to display levels from prior sessions, not just today
Works as a clean reference layer alongside FVGs, liquidity, and other ICT tools

How to use

Watch how price interacts with the 10 AM high, low, and body. Reactions at these levels — rejections, retests, or clean breaks — can help frame bias and entries during the New York session.

## Source Code

````pine
//@version=6
// ============================================================================
//  10 AM Candle Levels — 1-min body
//  Marks the 1-minute 10:00 candle:
//    • solid line at the OPEN
//    • solid line at the CLOSE
//    • dotted line at the body MIDPOINT  =  (open + close) / 2
//    • gray shading of the BODY (open→close)
//    • optional shading of the FULL CANDLE (high→low, wick to wick)
//    • day label centered on the right edge of the box (weekday + date)
//  Plus the ICT TRUE DAY OPEN (midnight ET open) as a dotted purple line.
//  All values are pulled from the 1-minute candle, so the levels stay locked
//  to that candle no matter which chart timeframe you switch to.
// ============================================================================
indicator("10 AM Candle Levels (1-min body)", shorttitle = "10AM 1m",
     overlay = true, max_lines_count = 500, max_boxes_count = 500,
     max_labels_count = 500)

// ---------------------------------------------------------------------------
//  INPUTS
// ---------------------------------------------------------------------------
grpT   = "Target candle"
tz     = input.string("America/New_York", "Timezone", group = grpT,
     options = ["America/New_York", "America/Chicago", "America/Denver",
                "America/Los_Angeles", "Europe/London", "UTC"])
hr     = input.int(10, "Hour (24h)",  minval = 0, maxval = 23, group = grpT)
mn     = input.int(0,  "Minute",      minval = 0, maxval = 59, group = grpT)
srcTF  = input.timeframe("1", "Source timeframe", group = grpT,
     tooltip = "The candle the levels are read from. Stays fixed when you change the chart timeframe.")

grpE   = "Elements"
showOpen  = input.bool(true,  "Open line",         group = grpE, inline = "o")
openCol   = input.color(#2962FF, "",               group = grpE, inline = "o")
showClose = input.bool(true,  "Close line",        group = grpE, inline = "c")
closeCol  = input.color(#FF6D00, "",               group = grpE, inline = "c")
showMid   = input.bool(true,  "Midpoint (dotted)", group = grpE, inline = "m")
midCol    = input.color(#787B86, "",               group = grpE, inline = "m")
showFill  = input.bool(true,  "Shade body (open→close)", group = grpE, inline = "f")
fillCol   = input.color(color.new(color.gray, 80), "", group = grpE, inline = "f")
showRange = input.bool(false, "Shade full candle (high→low)", group = grpE, inline = "r",
     tooltip = "Shades the whole 10AM candle from the top wick to the bottom wick. Border lines mark the high and low.")
rangeFill   = input.color(color.new(#2962FF, 90), "", group = grpE, inline = "r")
rangeBorder = input.color(color.new(#2962FF, 30), "", group = grpE, inline = "r")
showLabel = input.bool(true,  "Day label",         group = grpE, inline = "d")
labelCol  = input.color(#787B86, "",               group = grpE, inline = "d")
showDayOpen = input.bool(true, "True day open (midnight ET)", group = grpE, inline = "t",
     tooltip = "Dotted line at the open of the 00:00 candle in the Timezone above. Keep Timezone on New York for the canonical ICT true day open.")
dayOpenCol  = input.color(#9C27B0, "",             group = grpE, inline = "t")

grpS   = "Style"
lineWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = grpS)
daysKeep  = input.int(10, "Days to keep (0 = all)", minval = 0, maxval = 250, group = grpS,
     tooltip = "How many past days to retain. Note: 1-minute history is limited by your TradingView plan, so older days only appear if that data loads.")
extendRight = input.bool(true, "Extend levels to the right", group = grpS)
extendBars  = input.int(10, "Extend distance (bars, max 500)", minval = 0, maxval = 500, group = grpS,
     tooltip = "How far the zone projects into the future whitespace. 500 is the Pine maximum.")
extendPrev  = input.bool(true, "Extend previous days forward", group = grpS,
     tooltip = "Keep every past day's lines AND shaded boxes running forward as live reference zones. They project the full extend distance past price.")

// ---------------------------------------------------------------------------
//  FETCH FROM THE SOURCE TIMEFRAME
//  - target candle full OHLC at hr:mn
//  - true day open: the open of the 00:00 candle (ICT midnight)
//  Both run in the source-TF context and carry forward until the next event.
// ---------------------------------------------------------------------------
f_levels() =>
    isTarget   = hour(time, tz) == hr and minute(time, tz) == mn
    isMidnight = hour(time, tz) == 0  and minute(time, tz) == 0
    var float o     = na
    var float c     = na
    var float h     = na
    var float l     = na
    var int   t     = na
    var float dOpen = na
    var int   dTime = na
    if isTarget
        o := open
        c := close
        h := high
        l := low
        t := time
    if isMidnight
        dOpen := open
        dTime := time
    [o, c, h, l, t, dOpen, dTime]

[tOpen, tClose, tHigh, tLow, tTime, dOpen, dTime] = request.security(syminfo.tickerid, srcTF, f_levels())

// New events detected (their timestamp changed = a new day's candle)
newTarget  = not na(tTime) and (na(tTime[1]) or tTime != tTime[1])
newDayOpen = not na(dTime) and (na(dTime[1]) or dTime != dTime[1])

// How far drawings project to the right
rightX = extendRight ? bar_index + extendBars : bar_index

// ---------------------------------------------------------------------------
//  TRUE DAY OPEN (midnight ET)
// ---------------------------------------------------------------------------
var line  lnDayOpen  = na
var label lblDayOpen = na
var array<line>  allDayOpen      = array.new<line>()
var array<label> allDayOpenLabel = array.new<label>()

if newDayOpen
    if not extendPrev
        if not na(lnDayOpen)
            line.set_x2(lnDayOpen, bar_index)
        if not na(lblDayOpen)
            label.set_x(lblDayOpen, bar_index)
    lnDayOpen := showDayOpen ? line.new(bar_index, dOpen, bar_index, dOpen,
                   color = dayOpenCol, width = 1, style = line.style_dotted) : na
    lblDayOpen := showDayOpen ? label.new(bar_index, dOpen, "True Day Open",
                   style = label.style_label_left, color = dayOpenCol,
                   textcolor = color.white, size = size.small) : na
    if not na(lnDayOpen)
        array.push(allDayOpen, lnDayOpen)
    if not na(lblDayOpen)
        array.push(allDayOpenLabel, lblDayOpen)
    if daysKeep > 0
        while array.size(allDayOpen) > daysKeep
            line.delete(array.shift(allDayOpen))
        while array.size(allDayOpenLabel) > daysKeep
            label.delete(array.shift(allDayOpenLabel))

// ---------------------------------------------------------------------------
//  10 AM LEVELS
// ---------------------------------------------------------------------------
var line  lnOpen  = na
var line  lnClose = na
var line  lnMid   = na
var box   bxBody  = na
var box   bxRange = na
var label lblDay  = na
var array<line>  allLines  = array.new<line>()
var array<box>   allBoxes  = array.new<box>()
var array<box>   allRange  = array.new<box>()
var array<label> allLabels = array.new<label>()

if newTarget
    // Freeze the previous candle's drawings at this boundary unless extending.
    if not extendPrev
        if not na(bxBody)
            box.set_right(bxBody, bar_index)
        if not na(bxRange)
            box.set_right(bxRange, bar_index)
        if not na(lnOpen)
            line.set_x2(lnOpen, bar_index)
        if not na(lnClose)
            line.set_x2(lnClose, bar_index)
        if not na(lnMid)
            line.set_x2(lnMid, bar_index)
        if not na(lblDay)
            label.set_x(lblDay, bar_index)

    mid    = (tOpen + tClose) / 2.0
    bodyTop = math.max(tOpen, tClose)
    bodyBot = math.min(tOpen, tClose)

    lnOpen  := showOpen  ? line.new(bar_index, tOpen,  bar_index, tOpen,
                 color = openCol,  width = lineWidth) : na
    lnClose := showClose ? line.new(bar_index, tClose, bar_index, tClose,
                 color = closeCol, width = lineWidth) : na
    lnMid   := showMid   ? line.new(bar_index, mid,    bar_index, mid,
                 color = midCol,   width = 1, style = line.style_dotted) : na
    bxBody  := showFill  ? box.new(bar_index, bodyTop, bar_index, bodyBot,
                 border_width = 0, bgcolor = fillCol) : na
    bxRange := showRange ? box.new(bar_index, tHigh, bar_index, tLow,
                 border_color = rangeBorder, border_width = 1, bgcolor = rangeFill) : na
    // Day label: centered vertically on the body midpoint, anchored to the
    // right edge and pointing left so the text sits in the whitespace.
    lblDay  := showLabel ? label.new(bar_index, mid,
                 str.format_time(tTime, "EEE MMM dd", tz),
                 style = label.style_label_left, color = labelCol,
                 textcolor = color.white, size = size.small) : na

    if not na(lnOpen)
        array.push(allLines, lnOpen)
    if not na(lnClose)
        array.push(allLines, lnClose)
    if not na(lnMid)
        array.push(allLines, lnMid)
    if not na(bxBody)
        array.push(allBoxes, bxBody)
    if not na(bxRange)
        array.push(allRange, bxRange)
    if not na(lblDay)
        array.push(allLabels, lblDay)

    // Trim history to the requested number of days
    if daysKeep > 0
        perDay   = (showOpen ? 1 : 0) + (showClose ? 1 : 0) + (showMid ? 1 : 0)
        maxLines = daysKeep * math.max(perDay, 1)
        while array.size(allLines) > maxLines
            line.delete(array.shift(allLines))
        while array.size(allBoxes) > daysKeep
            box.delete(array.shift(allBoxes))
        while array.size(allRange) > daysKeep
            box.delete(array.shift(allRange))
        while array.size(allLabels) > daysKeep
            label.delete(array.shift(allLabels))

// ---------------------------------------------------------------------------
//  EXTEND DRAWINGS RIGHTWARD
// ---------------------------------------------------------------------------
// Drag every past day's drawings forward the FULL extend distance, so they
// all project past price into the future whitespace. Labels ride the right edge.
if extendPrev
    for ln in allLines
        line.set_x2(ln, rightX)
    for bx in allBoxes
        box.set_right(bx, rightX)
    for bx in allRange
        box.set_right(bx, rightX)
    for ln in allDayOpen
        line.set_x2(ln, rightX)
    for lb in allDayOpenLabel
        label.set_x(lb, rightX)
    for lb in allLabels
        label.set_x(lb, rightX)

// Current candle's drawings take priority and project into the future
if not na(lnOpen)
    line.set_x2(lnOpen, rightX)
if not na(lnClose)
    line.set_x2(lnClose, rightX)
if not na(lnMid)
    line.set_x2(lnMid, rightX)
if not na(bxBody)
    box.set_right(bxBody, rightX)
if not na(bxRange)
    box.set_right(bxRange, rightX)
if not na(lnDayOpen)
    line.set_x2(lnDayOpen, rightX)
if not na(lblDayOpen)
    label.set_x(lblDayOpen, rightX)
if not na(lblDay)
    label.set_x(lblDay, rightX)
````
