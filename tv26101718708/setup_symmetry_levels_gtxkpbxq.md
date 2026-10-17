# Setup Symmetry Levels

- url: https://www.tradingview.com/script/gtXkpBXq/
- type: indicator
- pine_id: PUB;9384bd1af590466a9d1ec29c70b0ce74
- version: 2.0

## Description

Setup Symmetry Levels

Setup Symmetry Levels is a market structure indicator designed to identify potential reaction levels based on completed bullish and bearish price setups.

The script tracks consecutive price behavior and plots horizontal levels whenever a user-defined setup threshold is reached. These levels can help traders visualize areas where the market has previously shown notable reactions and may provide useful context for future price analysis.

Features:

• User-configurable bullish and bearish setup thresholds

• Automatic support and resistance level plotting

• Forward projection of detected levels

• Optional setup completion markers displayed on the chart

• Symmetry-based projection levels derived from previous reaction points

• Adjustable colors, line styles, line widths, and label visibility

• Compatible with all symbols and timeframes

The symmetry calculation uses historical reaction levels to generate additional projected levels around the most recent completed setup. These projections are intended to provide a structured visual framework for studying price behavior and market structure.

This indicator is provided for analytical and educational purposes only. It does not provide financial advice, trading recommendations, guaranteed outcomes, or predictions of future market performance. Users should combine this tool with their own analysis, risk management practices, and market research.

The indicator can be applied to cryptocurrencies, stocks, forex, indices, commodities, and other liquid markets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator('Setup Symmetry Levels', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── SETTINGS ──────────────────────────────────────────────
bearTrigger = input.int(9, 'Bearish Setup Trigger (9-15)', minval = 9, maxval = 15)
bullTrigger = input.int(9, 'Bullish Setup Trigger (9-15)', minval = 9, maxval = 15)
extendBars = input.int(500, 'Line Extension (Bars)', minval = 1, maxval = 5000)
lineWidth = input.int(5, 'Line Width', minval = 1, maxval = 10)
showLabels = input.bool(true, 'Show Labels')
bullColorInput = input.color(#00e676, 'Bullish S/R Color')
bearColorInput = input.color(#ff1744, 'Bearish S/R Color')
maxLines = input.int(5, 'Maximum S/R Levels', minval = 1, maxval = 10)

// ─── SYMMETRY SETTINGS ─────────────────────────────────────
showMirror = input.bool(true, 'Show Symmetry Levels')
mirrorColorInput = input.color(#ff9800, 'Symmetry Line Color')
mirrorWidth = input.int(2, 'Symmetry Line Width', minval = 1, maxval = 10)
mirrorStyle = input.string('dashed', 'Symmetry Line Style', options = ['solid', 'dashed', 'dotted'])

bullColor = color.new(bullColorInput, 50)
bearColor = color.new(bearColorInput, 50)
mirrorColor = color.new(mirrorColorInput, 60)

// ─── ARRAYS ────────────────────────────────────────────────
var array<line> allLines = array.new_line()
var array<label> allLabels = array.new_label()
var array<float> levelHistory = array.new_float()
var array<line> mirrorLines = array.new_line()
var array<label> mirrorLabels = array.new_label()

// ─── TD SEQUENTIAL ─────────────────────────────────────────
var int buyCount = 0
var int sellCount = 0
var float buyStartPrice = na
var float sellStartPrice = na

if close > close[4]
    buyCount := buyCount + 1
    sellCount := 0
    if buyCount == 1
        buyStartPrice := close
        buyStartPrice
else if close < close[4]
    sellCount := sellCount + 1
    buyCount := 0
    if sellCount == 1
        sellStartPrice := close
        sellStartPrice
else
    buyCount := 0
    sellCount := 0
    sellCount

isBearTrigger = sellCount == bearTrigger
isBullTrigger = buyCount == bullTrigger

bullPct = not na(buyStartPrice) ? (close - buyStartPrice) / buyStartPrice * 100 : na
bearPct = not na(sellStartPrice) ? (close - sellStartPrice) / sellStartPrice * 100 : na

// ─── FUNCTION: STORE MAIN LEVEL ────────────────────────────
f_store(_ln, _lb) =>
    array.push(allLines, _ln)
    array.push(allLabels, _lb)

    if array.size(allLines) > maxLines
        line.delete(array.shift(allLines))
        label.delete(array.shift(allLabels))

// ─── FUNCTION: DRAW SYMMETRY LEVELS ────────────────────────
f_drawMirrors() =>
    while array.size(mirrorLines) > 0
        line.delete(array.pop(mirrorLines))

    while array.size(mirrorLabels) > 0
        label.delete(array.pop(mirrorLabels))

    histSize = array.size(levelHistory)

    if histSize >= 2 and showMirror
        center = array.get(levelHistory, histSize - 1)
        available = histSize - 1
        toMirror = math.min(maxLines - 1, available)

        lStyle = mirrorStyle == 'dashed' ? line.style_dashed : mirrorStyle == 'dotted' ? line.style_dotted : line.style_solid

        for i = 0 to toMirror - 1 by 1
            oldLevel = array.get(levelHistory, histSize - 2 - i)
            mirrorLevel = 2.0 * center - oldLevel

            ln = line.new(x1 = bar_index, y1 = mirrorLevel, x2 = bar_index + extendBars, y2 = mirrorLevel, color = mirrorColor, width = mirrorWidth, style = lStyle)

            array.push(mirrorLines, ln)

            if showLabels
                lb = label.new(x = bar_index + 7, y = mirrorLevel, text = 'M' + str.tostring(i + 1) + ' ' + str.tostring(math.round(mirrorLevel, 2)), color = color.new(mirrorColor, 75), textcolor = color.white, style = label.style_label_left, size = size.small)

                array.push(mirrorLabels, lb)

// ─── BEARISH RESISTANCE LEVEL ──────────────────────────────
if isBearTrigger
    lvl = close

    ln = line.new(x1 = bar_index, y1 = lvl, x2 = bar_index + extendBars, y2 = lvl, color = bearColor, width = lineWidth, style = line.style_solid)

    lb = showLabels ? label.new(x = bar_index + 7, y = lvl, text = 'R' + str.tostring(bearTrigger) + ' ' + str.tostring(math.round(lvl, 2)) + ' (' + str.tostring(math.round(bearPct, 2)) + '%)', color = color.new(bearColor, 75), textcolor = color.white, style = label.style_label_left, size = size.small) : label(na)

    f_store(ln, lb)

    array.push(levelHistory, lvl)

    if array.size(levelHistory) > maxLines + 1
        array.shift(levelHistory)

    f_drawMirrors()

// ─── BULLISH SUPPORT LEVEL ─────────────────────────────────
if isBullTrigger
    lvl = close

    ln = line.new(x1 = bar_index, y1 = lvl, x2 = bar_index + extendBars, y2 = lvl, color = bullColor, width = lineWidth, style = line.style_solid)

    lb = showLabels ? label.new(x = bar_index + 7, y = lvl, text = 'S' + str.tostring(bullTrigger) + ' ' + str.tostring(math.round(lvl, 2)) + ' (' + str.tostring(math.round(bullPct, 2)) + '%)', color = color.new(bullColor, 75), textcolor = color.white, style = label.style_label_left, size = size.small) : label(na)

    f_store(ln, lb)

    array.push(levelHistory, lvl)

    if array.size(levelHistory) > maxLines + 1
        array.shift(levelHistory)

    f_drawMirrors()

// ─── BAR COLORING ──────────────────────────────────────────
barcolor(sellCount == bearTrigger ? bearColor : buyCount == bullTrigger ? bullColor : na)

// ─── SETUP COMPLETION LABELS ───────────────────────────────

if sellCount == bearTrigger
    label.new(bar_index, high + ta.atr(14) * 0.15, str.tostring(bearTrigger), style = label.style_label_down, size = size.small, color = bearColorInput, textcolor = color.white)

if buyCount == bullTrigger
    label.new(bar_index, low - ta.atr(14) * 0.15, str.tostring(bullTrigger), style = label.style_label_up, size = size.small, color = bullColorInput, textcolor = color.white)
````
