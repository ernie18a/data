# Multi Timeframe Support and Resistance

- url: https://www.tradingview.com/script/uFvYYMVX-Multi-Timeframe-Support-and-Resistance/
- type: indicator
- pine_id: PUB;eab46de510d14fdb999a4a741ec21c81
- version: 1.0

## Description

[b]Multi Timeframe Support and Resistance[/b]
This indicator detects swing-based support and resistance levels from a user-selected timeframe and plots them as horizontal lines on the current chart. It is designed for use on a lower timeframe chart while sourcing levels from a higher timeframe.

[b]How it works[/b]
Pivot highs and pivot lows are calculated on the source timeframe using request.security with lookahead_on. Because gaps_off causes pivot values to repeat until a new pivot fires, the indicator tracks the last seen value and records only genuinely new pivots into separate high and low history arrays.

On the final bar, all stored pivots are processed most-recent-first. A clustering filter discards any new level that falls within a configurable percentage of an already-accepted level, preventing duplicate lines at nearly identical prices. The resulting lists are capped at the configured maximum and drawn as horizontal lines spanning a fixed number of bars to the left and right of the current bar.

Each level is classified as resistance if it is above the current source-timeframe close, or support if it is below. Levels within 1.5% of the current price are drawn with a thicker line and full opacity to highlight nearby key zones.

[b]Settings[/b]
[list]
[*]Source Timeframe — the timeframe from which pivots are sourced (default: 15m)
[*]Swing Left Bars — bars to the left required to confirm a pivot (default: 10)
[*]Swing Right Bars — bars to the right required to confirm a pivot (default: 10)
[*]Max S/R Lines — maximum number of levels drawn for each side (default: 8)
[*]Zone Cluster % — minimum percentage distance between two accepted levels (default: 0.5%)
[*]Line Length (bars) — how many bars left and right each line spans (default: 300)
[*]Show Labels — toggle S/R labels with timeframe and price on or off
[*]Resistance Color — color for levels above the current price
[*]Support Color — color for levels below the current price
[*]Line Width — base thickness of drawn lines (default: 2)
[/list]

Works on any symbol and any chart timeframe. The source timeframe should be equal to or higher than the chart timeframe for meaningful results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © lazyhacker

//@version=6
indicator("Multi Timeframe Support and Resistance", shorttitle="MTF S/R", overlay=true, max_lines_count=200, max_labels_count=200)

// --- Inputs ---
tfInput    = input.timeframe("15", "Source Timeframe", tooltip="Enter timeframe: 1,3,5,10,15,30,60,120,240,D,W")
leftBars   = input.int(10,   "Swing Left Bars",    minval=2, maxval=50)
rightBars  = input.int(10,   "Swing Right Bars",   minval=2, maxval=50)
maxLevels  = input.int(8,    "Max S/R Lines",      minval=2, maxval=20)
zonePct    = input.float(0.5,"Zone Cluster %",     minval=0.1, maxval=2.0, step=0.1)
lineLen    = input.int(300,  "Line Length (bars)", minval=50, maxval=500)
showLabels = input.bool(true,"Show Labels")
resColor   = input.color(color.new(color.red,   20), "Resistance Color")
supColor   = input.color(color.new(color.green, 20), "Support Color")
lineWidth  = input.int(2,    "Line Width",         minval=1, maxval=4)

// --- Fetch pivot highs, pivot lows, and close from source timeframe ---
[ph, pl, c_tf] = request.security(syminfo.tickerid, tfInput,
     [ta.pivothigh(high, leftBars, rightBars),
      ta.pivotlow (low,  leftBars, rightBars),
      close],
     gaps     = barmerge.gaps_off,
     lookahead= barmerge.lookahead_on)

// --- Record only new pivot values (gaps_off causes values to repeat) ---
var float lastPH = na
var float lastPL = na

var float[] phHistory = array.new<float>()
var float[] plHistory = array.new<float>()

if not na(ph) and (na(lastPH) or ph != lastPH)
    array.push(phHistory, ph)
    lastPH := ph

if not na(pl) and (na(lastPL) or pl != lastPL)
    array.push(plHistory, pl)
    lastPL := pl

// --- Helper: return true if price is not within zonePct% of any existing level ---
isNewLevel(arr, price) =>
    isNew = true
    n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            if math.abs(array.get(arr, i) - price) / price * 100 < zonePct
                isNew := false
                break
    isNew

// --- Storage for drawn objects ---
var line[]  drawnLines  = array.new<line>()
var label[] drawnLabels = array.new<label>()

// --- Redraw all levels on the last bar ---
if barstate.islast

    // Clear previous drawings — guard required: loop crashes on empty array
    int nLines = array.size(drawnLines)
    if nLines > 0
        for i = 0 to nLines - 1
            line.delete(array.get(drawnLines, i))
    array.clear(drawnLines)

    int nLabels = array.size(drawnLabels)
    if nLabels > 0
        for i = 0 to nLabels - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLabels)

    // Build resistance levels from pivot highs (most recent first)
    float[] resLevels = array.new<float>()
    int phSize = array.size(phHistory)
    if phSize > 0
        for i = phSize - 1 to 0
            if array.size(resLevels) >= maxLevels
                break
            lvl = array.get(phHistory, i)
            if isNewLevel(resLevels, lvl)
                array.push(resLevels, lvl)

    // Build support levels from pivot lows (most recent first)
    float[] supLevels = array.new<float>()
    int plSize = array.size(plHistory)
    if plSize > 0
        for i = plSize - 1 to 0
            if array.size(supLevels) >= maxLevels
                break
            lvl = array.get(plHistory, i)
            if isNewLevel(supLevels, lvl)
                array.push(supLevels, lvl)

    // --- Draw resistance levels ---
    int resSize = array.size(resLevels)
    if resSize > 0
        for i = 0 to resSize - 1
            lvl     = array.get(resLevels, i)
            dist    = math.abs(lvl - c_tf) / c_tf * 100
            isAbove = lvl > c_tf
            lColor  = isAbove ? (dist < 1.5 ? color.new(color.red,   0) : resColor)
                              : (dist < 1.5 ? color.new(color.green, 0) : supColor)
            lWidth  = dist < 1.5 ? lineWidth + 1 : lineWidth
            srLabel = isAbove ? "R" : "S"

            ln = line.new(
                 x1=bar_index - lineLen, y1=lvl,
                 x2=bar_index + 15,     y2=lvl,
                 color=lColor, width=lWidth, style=line.style_solid)
            array.push(drawnLines, ln)

            if showLabels
                lbl = label.new(
                     x=bar_index + 15, y=lvl,
                     text      = srLabel + " [" + tfInput + "]  " + str.tostring(lvl, "#.##"),
                     color     = isAbove ? color.new(color.red,   80) : color.new(color.green, 80),
                     textcolor = isAbove ? color.red : color.green,
                     style     = label.style_label_left,
                     size      = size.small)
                array.push(drawnLabels, lbl)

    // --- Draw support levels ---
    int supSize = array.size(supLevels)
    if supSize > 0
        for i = 0 to supSize - 1
            lvl     = array.get(supLevels, i)
            dist    = math.abs(lvl - c_tf) / c_tf * 100
            isAbove = lvl > c_tf
            lColor  = isAbove ? (dist < 1.5 ? color.new(color.red,   0) : resColor)
                              : (dist < 1.5 ? color.new(color.green, 0) : supColor)
            lWidth  = dist < 1.5 ? lineWidth + 1 : lineWidth
            srLabel = isAbove ? "R" : "S"

            ln = line.new(
                 x1=bar_index - lineLen, y1=lvl,
                 x2=bar_index + 15,     y2=lvl,
                 color=lColor, width=lWidth, style=line.style_solid)
            array.push(drawnLines, ln)

            if showLabels
                lbl = label.new(
                     x=bar_index + 15, y=lvl,
                     text      = srLabel + " [" + tfInput + "]  " + str.tostring(lvl, "#.##"),
                     color     = isAbove ? color.new(color.red,   80) : color.new(color.green, 80),
                     textcolor = isAbove ? color.red : color.green,
                     style     = label.style_label_left,
                     size      = size.small)
                array.push(drawnLabels, lbl)
````
