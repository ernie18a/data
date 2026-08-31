<!-- tradingview-pine-id: PUB;a9a684054b1f4326801b692ecbeb2dbe -->
<!-- tradingviewscripts-format: 1 -->
# Price Grid (Fixed Interval) v4

Source: https://www.tradingview.com/script/Lwtm0c2L-Claudia-Rea-inspired-Price-Grid/

## Description

Inspired by Claudia Rea

Price Grid (Fixed Interval)

A configurable horizontal price grid that anchors to the current price and extends a fixed number of evenly-spaced levels above and below it — rather than to a fixed historical high/low, so the grid stays consistent regardless of timeframe or how much chart history has loaded.

How it works

Finds the nearest grid level below the current close, then draws lines at fixed Grid Spacing intervals above and below that anchor
Every Nth line (set by Major Line Every N Lines) is rendered thicker and in a different color, with a price label — useful for marking round numbers or larger intervals (e.g. $25 minor / $100 major) inside the same grid
Redraws only on the most recent bar, so it stays lightweight even on lower timeframes

Inputs

Grid Spacing — distance between minor lines
Major Line Every N Lines — how many minor steps between each major (labeled) line
Lines Above/Below Price — how many lines to draw on each side of price
Bars of History to Span Left — cosmetic only, controls how far left the lines are drawn
Show Price Labels / Extend Lines Right / line colors — display options

Notes

This is a purely mechanical price grid — it does not predict direction or generate signals. Round-number and fixed-interval levels can act as areas of interest on some instruments, but reactions at any given line are not guaranteed and should be combined with your own market structure analysis.
Works on any symbol or timeframe; grid spacing should be adjusted to match the instrument's typical volatility (e.g. smaller spacing for lower-priced or less volatile instruments).

---

## Source Code

````pine
//@version=6
indicator("Price Grid (Fixed Interval) v4", overlay=true, max_lines_count=300, max_labels_count=300)

// ── Inputs ──────────────────────────────────────────────
gridSpacing  = input.float(25, title="Grid Spacing ($)", minval=0.01, tooltip="Distance between minor grid lines, e.g. 25 for gold")
majorEvery   = input.int(4, title="Major Line Every N Lines", minval=1, tooltip="e.g. 4 lines of $25 = a major line every $100")
linesEachSide = input.int(10, title="Lines Above/Below Price", minval=1, maxval=100, tooltip="How many grid lines to draw above and below current price")
barsBack     = input.int(200, title="Bars of History to Span Left", minval=10, maxval=5000)
showLabels   = input.bool(true, title="Show Price Labels")
extendRight  = input.bool(true, title="Extend Lines Right")

minorColor = input.color(color.new(color.green, 65), title="Minor Line Color")
majorColor = input.color(color.new(color.yellow, 30), title="Major Line Color")
minorWidth = 1
majorWidth = 2

// ── State ───────────────────────────────────────────────
var line[]  gridLines  = array.new_line()
var label[] gridLabels = array.new_label()

if barstate.islast
    if array.size(gridLines) > 0
        for i = 0 to array.size(gridLines) - 1
            line.delete(array.get(gridLines, i))
        array.clear(gridLines)
    if array.size(gridLabels) > 0
        for i = 0 to array.size(gridLabels) - 1
            label.delete(array.get(gridLabels, i))
        array.clear(gridLabels)

    // anchor grid to the nearest gridline below current close
    centerLevel = math.floor(close / gridSpacing) * gridSpacing

    x1 = bar_index - barsBack
    x2 = bar_index + 15

    for i = -linesEachSide to linesEachSide
        level = centerLevel + i * gridSpacing
        stepsFromZero = math.round(level / gridSpacing)
        isMajor = stepsFromZero % majorEvery == 0
        col = isMajor ? majorColor : minorColor
        wid = isMajor ? majorWidth : minorWidth

        ln = line.new(x1, level, x2, level, extend = extendRight ? extend.right : extend.none, color = col, width = wid)
        array.push(gridLines, ln)

        if showLabels and isMajor
            lb = label.new(x2, level, str.tostring(level, format.mintick), xloc.bar_index, yloc.price, color=color.new(color.black, 100), textcolor=majorColor, style=label.style_label_left, size=size.small)
            array.push(gridLabels, lb)
````
