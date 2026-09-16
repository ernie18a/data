<!-- tradingview-pine-id: PUB;44311d7ea6684c96846add3ca1878ad9 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Premkt 5 15 30 Min

Source: https://www.tradingview.com/script/M92vyyv2-Premkt-5-15-30-Min/

## Description

If your trading focuses on the Premarket range or the first 5, 15 or 30 Minutes of the market, you might like this script.  
It automatically creates different colored rectangles for each of these timeframes. 

Each rectangle displays the Title in the color of the rectangle.  
Premarket displays from 0400 to 1600 Market time.
The 5, 15 and 30 Minute display from 0930 to 1600, although they don't appear until that timeframe has completed.  
The 15 and 30 Minute display a dashed horizontal line at the 50% level in the same color as the Title. 

User adjustable features:  colors and opacity and show/hide on the chart.
When hidden, the Title and 50% line for that rectangle also hides.
The rectangles are retained on prior days for quick visual on a multi-day chart.

---

## Source Code

````pine
//@version=6
indicator("Premkt 5 15 30 Min", overlay = true, max_boxes_count = 450, max_lines_count = 450)

// ─── Settings ───────────────────────────────────────────────────────────────
tz = "America/New_York"

// Visibility checkboxes
showPremarket   = input.bool(true,  "Show Premarket")
showFive        = input.bool(true,  "Show 5 Minute")
showFifteen     = input.bool(true,  "Show 15 Minute")
showThirty      = input.bool(true,  "Show 30 Minute")

// Days to keep
daysToKeepStr = input.string("10", "Days to keep",
     options = ["10", "20", "30", "60", "90", "150", "250", "Max"])

maxDays = switch daysToKeepStr
    "10"  => 10
    "20"  => 20
    "30"  => 30
    "60"  => 60
    "90"  => 90
    "150" => 150
    "250" => 250
    => 9999   // Max

// Colors
pmBaseColor         = input.color(color.yellow, "Premarket Color")
fiveBaseColor       = input.color(color.red,    "5 Minute Color")
fifteenBaseColor    = input.color(color.blue,   "15 Minute Color")
thirtyBaseColor     = input.color(color.green,  "30 Minute Color")

// Opacity
pmOpacity           = input.int(85, "Premarket Opacity %", minval = 0, maxval = 100, step = 5)
fiveOpacity         = input.int(85, "5 Minute Opacity %",  minval = 0, maxval = 100, step = 5)
fifteenOpacity      = input.int(80, "15 Minute Opacity %", minval = 0, maxval = 100, step = 5)
thirtyOpacity       = input.int(80, "30 Minute Opacity %", minval = 0, maxval = 100, step = 5)

// Titles
showTitles          = input.bool(true, "Show Rectangle Titles")

pmColor             = color.new(pmBaseColor,      pmOpacity)
fiveColor           = color.new(fiveBaseColor,    fiveOpacity)
fifteenColor        = color.new(fifteenBaseColor, fifteenOpacity)
thirtyColor         = color.new(thirtyBaseColor,  thirtyOpacity)
borderWidth         = 1

// ─── Time helpers (New York) ────────────────────────────────────────────────
nyHour   = hour(time, tz)
nyMinute = minute(time, tz)
nyTime   = nyHour * 60 + nyMinute          // minutes since midnight NY

// Session boundaries (minutes since midnight)
pmStart     = 4 * 60          // 04:00
rthStart    = 9 * 60 + 30     // 09:30
fiveEnd     = 9 * 60 + 35     // 09:35
fifteenEnd  = 9 * 60 + 45     // 09:45
thirtyEnd   = 10 * 60         // 10:00
rthEnd      = 16 * 60         // 16:00

isPremarket = nyTime >= pmStart and nyTime < rthStart
isFirst5    = nyTime >= rthStart and nyTime < fiveEnd
isFirst15   = nyTime >= rthStart and nyTime < fifteenEnd
isFirst30   = nyTime >= rthStart and nyTime < thirtyEnd

// Detect new trading day (first bar of the day in NY time)
newDay = ta.change(time("D", "America/New_York")) != 0

// ─── State variables ────────────────────────────────────────────────────────
var float pmHigh      = na
var float pmLow       = na
var float fiveHigh    = na
var float fiveLow     = na
var float fifteenHigh = na
var float fifteenLow  = na
var float thirtyHigh  = na
var float thirtyLow   = na

var int   pmLeftTime      = na
var int   fiveLeftTime    = na
var int   fifteenLeftTime = na
var int   thirtyLeftTime  = na
var int   rightTime       = na          // 16:00 of the current day

var box   pmBox       = na
var box   fiveBox     = na
var box   fifteenBox  = na
var box   thirtyBox   = na
var line  fifteenMid  = na
var line  thirtyMid   = na

// History arrays
var array<box>  pmHistory       = array.new_box()
var array<box>  fiveHistory     = array.new_box()
var array<box>  fifteenHistory  = array.new_box()
var array<box>  thirtyHistory   = array.new_box()
var array<line> fifteenMidHist  = array.new_line()
var array<line> thirtyMidHist   = array.new_line()

// ─── Helper: trim a box array ───────────────────────────────────────────────
trimBoxes(arr) =>
    while array.size(arr) > maxDays
        old = array.shift(arr)
        if not na(old)
            box.delete(old)

// ─── Helper: trim a line array ──────────────────────────────────────────────
trimLines(arr) =>
    while array.size(arr) > maxDays
        old = array.shift(arr)
        if not na(old)
            line.delete(old)

// ─── Reset & capture logic ──────────────────────────────────────────────────
if newDay
    // Archive the just-finished day
    if not na(pmBox)
        array.push(pmHistory, pmBox)
    if not na(fiveBox)
        array.push(fiveHistory, fiveBox)
    if not na(fifteenBox)
        array.push(fifteenHistory, fifteenBox)
    if not na(thirtyBox)
        array.push(thirtyHistory, thirtyBox)
    if not na(fifteenMid)
        array.push(fifteenMidHist, fifteenMid)
    if not na(thirtyMid)
        array.push(thirtyMidHist, thirtyMid)

    // Trim to selected number of days
    trimBoxes(pmHistory)
    trimBoxes(fiveHistory)
    trimBoxes(fifteenHistory)
    trimBoxes(thirtyHistory)
    trimLines(fifteenMidHist)
    trimLines(thirtyMidHist)

    // Reset daily state
    pmHigh      := na
    pmLow       := na
    fiveHigh    := na
    fiveLow     := na
    fifteenHigh := na
    fifteenLow  := na
    thirtyHigh  := na
    thirtyLow   := na
    pmLeftTime  := na
    fiveLeftTime:= na
    fifteenLeftTime := na
    thirtyLeftTime  := na
    rightTime   := na

    // Release references
    pmBox       := na
    fiveBox     := na
    fifteenBox  := na
    thirtyBox   := na
    fifteenMid  := na
    thirtyMid   := na

// Premarket high / low
if isPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)
    if na(pmLeftTime)
        pmLeftTime := time

// First 5-minute high / low
if isFirst5
    fiveHigh := na(fiveHigh) ? high : math.max(fiveHigh, high)
    fiveLow  := na(fiveLow)  ? low  : math.min(fiveLow, low)
    if na(fiveLeftTime)
        fiveLeftTime := time

// First 15-minute high / low
if isFirst15
    fifteenHigh := na(fifteenHigh) ? high : math.max(fifteenHigh, high)
    fifteenLow  := na(fifteenLow)  ? low  : math.min(fifteenLow, low)
    if na(fifteenLeftTime)
        fifteenLeftTime := time

// First 30-minute high / low
if isFirst30
    thirtyHigh := na(thirtyHigh) ? high : math.max(thirtyHigh, high)
    thirtyLow  := na(thirtyLow)  ? low  : math.min(thirtyLow, low)
    if na(thirtyLeftTime)
        thirtyLeftTime := time

// Calculate 16:00 timestamp of the current day
if na(rightTime) and not na(pmLeftTime)
    rightTime := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 16, 0, 0)

// ─── Draw / update boxes ────────────────────────────────────────────────────

// Premarket box
if showPremarket and not na(pmHigh) and not na(pmLow) and not na(pmLeftTime) and not na(rightTime)
    if na(pmBox)
        pmBox := box.new(pmLeftTime, pmHigh, rightTime, pmLow,
             xloc = xloc.bar_time,
             border_color = pmColor,
             bgcolor = pmColor,
             border_width = borderWidth,
             text = showTitles ? "Premarket" : "",
             text_color = pmBaseColor,
             text_size = size.small)
    else
        box.set_top(pmBox, pmHigh)
        box.set_bottom(pmBox, pmLow)
        box.set_left(pmBox, pmLeftTime)
        box.set_right(pmBox, rightTime)
        box.set_bgcolor(pmBox, pmColor)
        box.set_border_color(pmBox, pmColor)
        box.set_text(pmBox, showTitles ? "Premarket" : "")
        box.set_text_color(pmBox, pmBaseColor)
else
    if not na(pmBox)
        box.delete(pmBox)
        pmBox := na

// 5-minute box
if showFive and not na(fiveHigh) and not na(fiveLow) and not na(fiveLeftTime) and not na(rightTime)
    if na(fiveBox)
        fiveBox := box.new(fiveLeftTime, fiveHigh, rightTime, fiveLow,
             xloc = xloc.bar_time,
             border_color = fiveColor,
             bgcolor = fiveColor,
             border_width = borderWidth,
             text = showTitles ? "5 Minute" : "",
             text_color = fiveBaseColor,
             text_size = size.small)
    else
        box.set_top(fiveBox, fiveHigh)
        box.set_bottom(fiveBox, fiveLow)
        box.set_left(fiveBox, fiveLeftTime)
        box.set_right(fiveBox, rightTime)
        box.set_bgcolor(fiveBox, fiveColor)
        box.set_border_color(fiveBox, fiveColor)
        box.set_text(fiveBox, showTitles ? "5 Minute" : "")
        box.set_text_color(fiveBox, fiveBaseColor)
else
    if not na(fiveBox)
        box.delete(fiveBox)
        fiveBox := na

// 15-minute box + 50% dashed midline
if showFifteen and not na(fifteenHigh) and not na(fifteenLow) and not na(fifteenLeftTime) and not na(rightTime)
    midPrice15 = (fifteenHigh + fifteenLow) / 2

    if na(fifteenBox)
        fifteenBox := box.new(fifteenLeftTime, fifteenHigh, rightTime, fifteenLow,
             xloc = xloc.bar_time,
             border_color = fifteenColor,
             bgcolor = fifteenColor,
             border_width = borderWidth,
             text = showTitles ? "15 Minute" : "",
             text_color = fifteenBaseColor,
             text_size = size.small)
    else
        box.set_top(fifteenBox, fifteenHigh)
        box.set_bottom(fifteenBox, fifteenLow)
        box.set_left(fifteenBox, fifteenLeftTime)
        box.set_right(fifteenBox, rightTime)
        box.set_bgcolor(fifteenBox, fifteenColor)
        box.set_border_color(fifteenBox, fifteenColor)
        box.set_text(fifteenBox, showTitles ? "15 Minute" : "")
        box.set_text_color(fifteenBox, fifteenBaseColor)

    if na(fifteenMid)
        fifteenMid := line.new(fifteenLeftTime, midPrice15, rightTime, midPrice15,
             xloc = xloc.bar_time,
             color = fifteenBaseColor,
             style = line.style_dashed,
             width = 1)
    else
        line.set_xy1(fifteenMid, fifteenLeftTime, midPrice15)
        line.set_xy2(fifteenMid, rightTime, midPrice15)
        line.set_color(fifteenMid, fifteenBaseColor)
else
    if not na(fifteenBox)
        box.delete(fifteenBox)
        fifteenBox := na
    if not na(fifteenMid)
        line.delete(fifteenMid)
        fifteenMid := na

// 30-minute box + 50% dashed midline
if showThirty and not na(thirtyHigh) and not na(thirtyLow) and not na(thirtyLeftTime) and not na(rightTime)
    midPrice30 = (thirtyHigh + thirtyLow) / 2

    if na(thirtyBox)
        thirtyBox := box.new(thirtyLeftTime, thirtyHigh, rightTime, thirtyLow,
             xloc = xloc.bar_time,
             border_color = thirtyColor,
             bgcolor = thirtyColor,
             border_width = borderWidth,
             text = showTitles ? "30 Minute" : "",
             text_color = thirtyBaseColor,
             text_size = size.small)
    else
        box.set_top(thirtyBox, thirtyHigh)
        box.set_bottom(thirtyBox, thirtyLow)
        box.set_left(thirtyBox, thirtyLeftTime)
        box.set_right(thirtyBox, rightTime)
        box.set_bgcolor(thirtyBox, thirtyColor)
        box.set_border_color(thirtyBox, thirtyColor)
        box.set_text(thirtyBox, showTitles ? "30 Minute" : "")
        box.set_text_color(thirtyBox, thirtyBaseColor)

    if na(thirtyMid)
        thirtyMid := line.new(thirtyLeftTime, midPrice30, rightTime, midPrice30,
             xloc = xloc.bar_time,
             color = thirtyBaseColor,
             style = line.style_dashed,
             width = 1)
    else
        line.set_xy1(thirtyMid, thirtyLeftTime, midPrice30)
        line.set_xy2(thirtyMid, rightTime, midPrice30)
        line.set_color(thirtyMid, thirtyBaseColor)
else
    if not na(thirtyBox)
        box.delete(thirtyBox)
        thirtyBox := na
    if not na(thirtyMid)
        line.delete(thirtyMid)
        thirtyMid := na
````
