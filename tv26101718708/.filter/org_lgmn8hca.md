# ORG

- url: https://www.tradingview.com/script/lGMn8hCa-ORG/
- type: indicator
- pine_id: PUB;3f170b6128d548e990fc8d41e711d0bd
- version: 1.0

## Description

This shit is for me and my friends that like to trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BigWickEnergy1696

//@version=6
indicator(title="ORG", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
lineColor    = input.color(color.new(color.gray, 0), "Line Color")
boxColor     = input.color(color.new(color.gray, 0), "Box Color")
lineWidth    = input.int(1, "Line Width", minval=1, maxval=4)
styleInput   = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
showLabels   = input.bool(true, "Show Labels")
candleOffset = input.int(2, "Candles Ahead (current day only)", minval=1, maxval=10)

// ─────────────────────────────────────────────
// LINE STYLE HELPER
// ─────────────────────────────────────────────
getStyle() =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

// ─────────────────────────────────────────────
// PD ARRAY LEVELS (0 = top, 1 = bottom)
// ─────────────────────────────────────────────
levelLabels  = array.from("0", "0.25", "0.5", "0.75", "1")
levelRatios  = array.from(0.0, 0.25, 0.5, 0.75, 1.0)
boxOpacities = array.from(78, 88, 88, 78)

// ─────────────────────────────────────────────
// PERSISTENT STORAGE
// ─────────────────────────────────────────────
var float[] dayPrevClose = array.new_float()
var float[] dayNYOpen    = array.new_float()
var int[]   dayNYOpenBar = array.new_int()

// Store drawing objects per day (5 lines + 4 boxes + 5 labels = 14 objects per day)
// We keep them persistent so we only modify x2/label x, never delete mid-candle
var line[]  allLines  = array.new_line()
var box[]   allBoxes  = array.new_box()
var label[] allLabels = array.new_label()

var bool  nyOpenCaptured = false
var float prevDayClose   = na
var bool  needsFullRedraw = false

// ─────────────────────────────────────────────
// SESSION & DAY DETECTION
// ─────────────────────────────────────────────
isNYOpen    = not na(time("1", "0930-1600:23456", "America/New_York"))
isNYOpenBar = isNYOpen and not isNYOpen[1]
isNewDay    = ta.change(time("D")) != 0

if isNewDay
    if not na(close[1])
        prevDayClose := close[1]
    nyOpenCaptured := false

if isNYOpenBar and not nyOpenCaptured and not na(prevDayClose)
    nyOpenCaptured   := true
    needsFullRedraw  := true
    array.push(dayPrevClose, prevDayClose)
    array.push(dayNYOpen,    open)
    array.push(dayNYOpenBar, bar_index)
    if array.size(dayPrevClose) > 5
        array.shift(dayPrevClose)
        array.shift(dayNYOpen)
        array.shift(dayNYOpenBar)

// ─────────────────────────────────────────────
// FULL REDRAW FUNCTION — only called when a new
// NY session opens (new day added to the array)
// ─────────────────────────────────────────────
drawAll() =>
    // Delete existing objects
    for l in allLines
        line.delete(l)
    for b in allBoxes
        box.delete(b)
    for lb in allLabels
        label.delete(lb)
    array.clear(allLines)
    array.clear(allBoxes)
    array.clear(allLabels)

    int numDays = array.size(dayPrevClose)
    for i = 0 to numDays - 1
        float pClose = array.get(dayPrevClose, i)
        float nyOpen = array.get(dayNYOpen,    i)
        int   x1     = array.get(dayNYOpenBar, i)
        int   x2     = i < numDays - 1 ? array.get(dayNYOpenBar, i + 1) : bar_index + candleOffset

        if na(pClose) or na(nyOpen)
            continue

        float topPrice = math.max(pClose, nyOpen)
        float botPrice = math.min(pClose, nyOpen)
        float rng      = topPrice - botPrice

        float lvl0  = topPrice
        float lvl25 = topPrice - 0.25 * rng
        float lvl50 = topPrice - 0.50 * rng
        float lvl75 = topPrice - 0.75 * rng
        float lvl1  = botPrice

        float[] zoneTops  = array.from(lvl0,  lvl25, lvl50, lvl75)
        float[] zoneBots  = array.from(lvl25, lvl50, lvl75, lvl1)
        float[] lvlPrices = array.from(lvl0,  lvl25, lvl50, lvl75, lvl1)

        // Boxes
        for z = 0 to 3
            float zt = array.get(zoneTops, z)
            float zb = array.get(zoneBots, z)
            int   op = array.get(boxOpacities, z)
            array.push(allBoxes, box.new(
             left         = x1,
             top          = zt,
             right        = x2,
             bottom       = zb,
             bgcolor      = color.new(boxColor, op),
             border_color = color.new(color.white, 100),
             border_width = 0))

        // Lines + Labels
        for j = 0 to 4
            float  lvl  = array.get(lvlPrices, j)
            string lbl  = array.get(levelLabels, j)

            array.push(allLines, line.new(
             x1    = x1,
             y1    = lvl,
             x2    = x2,
             y2    = lvl,
             color = lineColor,
             width = lineWidth,
             style = getStyle()))

            if showLabels
                string priceStr = str.tostring(lvl, format.mintick)
                array.push(allLabels, label.new(
                 x         = x2,
                 y         = lvl,
                 text      = lbl + " (" + priceStr + ")",
                 color     = color.new(color.black, 100),
                 textcolor = lineColor,
                 style     = label.style_label_left,
                 size      = size.small))

// ─────────────────────────────────────────────
// LIGHT UPDATE — just nudge x2 of the most
// recent day's objects forward each new bar
// ─────────────────────────────────────────────
updateCurrentDay() =>
    int numDays     = array.size(dayPrevClose)
    int totalLines  = array.size(allLines)
    int totalBoxes  = array.size(allBoxes)
    int totalLabels = array.size(allLabels)
    if numDays > 0 and totalLines >= 5 and totalBoxes >= 4
        int newX2 = bar_index + candleOffset
        for j = 0 to 4
            line.set_x2(array.get(allLines, totalLines - 5 + j), newX2)
        for z = 0 to 3
            box.set_right(array.get(allBoxes, totalBoxes - 4 + z), newX2)
        if totalLabels >= 5
            for j = 0 to 4
                label.set_x(array.get(allLabels, totalLabels - 5 + j), newX2)

// ─────────────────────────────────────────────
// EXECUTION
// ─────────────────────────────────────────────
if needsFullRedraw
    drawAll()
    needsFullRedraw := false
else if barstate.islast or barstate.isrealtime
    updateCurrentDay()
````
