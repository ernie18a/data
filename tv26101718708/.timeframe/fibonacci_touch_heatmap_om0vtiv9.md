# Fibonacci Touch Heatmap

- url: https://www.tradingview.com/script/Om0VtIV9/
- type: indicator
- pine_id: PUB;7e148e5dd6cd48eaaa138a6353f63e33
- version: 1.0

## Description

Fibonacci Touch Heatmap
Fibonacci Touch Heatmap is an advanced Fibonacci channel indicator that dynamically builds a full upper and lower Fibonacci structure over a user-defined lookback window, then scores each level by how many times price has genuinely touched or respected it. The result is a ranked, color-coded map of the most statistically significant support and resistance zones on your chart — updated automatically on every bar.

What Problem This Solves
Standard Fibonacci tools require manual swing selection and draw static levels with no feedback on whether price actually reacted to them. This indicator eliminates both limitations: it auto-detects the range, draws all 14 Fibonacci levels (7 upper + 7 lower), and continuously counts how many times each level has been touched — giving traders an objective, data-driven view of which levels the market genuinely respects.

How It Works — Technical Details
Range Detection:
The indicator uses ta.highest(high, lookback) and ta.lowest(low, lookback) to identify the high and low of the most recent N bars (default: 300). The midpoint is calculated as the arithmetic average of these two values.
Fibonacci Level Construction:
Seven standard Fibonacci ratios (0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0) are applied symmetrically from the midpoint — upward toward the range high (upper channel) and downward toward the range low (lower channel) — producing 14 distinct price levels in total.
Touch Counting Algorithm:
On the final bar (barstate.islast), the script iterates backward through every bar in the lookback window. For each bar, it checks whether the high or low came within a user-defined sensitivity threshold of any Fibonacci level. The threshold is calculated as a percentage of the level price (default: 0.2%), making it adaptive across different asset classes and price scales. Each qualifying bar increments that level's touch counter.
Gradient Coloring:
A custom gradColor() function interpolates RGB values across three anchor colors — bottom (green), mid (yellow), top (red) — based on the level's vertical position within the channel. This creates a smooth visual gradient that immediately communicates zone type: green = support territory, red = resistance territory.
Touch Heatmap:
Line opacity and the color in the top-right table are determined by each level's touch count relative to the maximum touch count across all 14 levels, using the touchColor() function. Levels with more touches render with warmer, more opaque colors.
Background Zones:
The channel is divided into 9 equal vertical slices, each rendered as a semi-transparent colored box, creating a heat gradient background that visually reinforces price zone significance.

Multi-Timeframe Panel
Two additional timeframes (default: 1H and 4H, fully customizable) are analyzed via request.security(). For each external timeframe, the script independently fetches the 500-bar high/low range, builds the complete Fibonacci channel, runs the touch-counting algorithm, and identifies the top 2 most-touched levels. These are displayed in the bottom-right table, color-coded by timeframe (blue = TF1, purple = TF2), allowing traders to instantly identify cross-timeframe Fibonacci confluences.

Top-Right Table — Most Touched Fib Levels
Displays the top 4 most-touched Fibonacci levels from the current chart timeframe, ranked using a bubble sort across all 14 levels. Each row shows:

Fib ratio with direction arrow (↑ upper channel / ↓ lower channel)
Exact price of the level
Touch count (colored from blue → red based on relative touch frequency)
Zone — Upper (resistance side) or Lower (support side)


How To Use

Set Lookback Bars to define the range of history to analyze. Higher values (500+) reveal macro structure; lower values (50–150) focus on recent structure.
Identify high-touch levels from the top-right table — these are the levels price has tested most frequently and are the strongest candidate zones for future reactions.
Use the multi-TF table to find confluences: when the same Fibonacci level appears as most-touched on both TF1 and TF2 simultaneously, it indicates a high-probability reaction zone.
Adjust Touch Sensitivity (%) based on asset volatility:

Crypto: 0.2–0.5% recommended
Forex: 0.05–0.15% recommended
Equities: 0.1–0.3% recommended


Color gradient gives immediate visual context — price trading near red zones suggests resistance pressure; near green zones suggests support.


Inputs Summary
InputDefaultDescriptionLookback Bars300Number of bars used for range and touch detectionTouch Sensitivity (%)0.002Tolerance for a bar high/low to qualify as a touchFib Line Width1Visual thickness of dashed level linesTop / Mid / Bottom ColorRed / Yellow / GreenGradient anchor colorsTimeframe 160 (1H)First external TF for multi-TF panelTimeframe 2240 (4H)Second external TF for multi-TF panel

Originality
This script is an original work combining automatic range-based Fibonacci channel construction with a bar-by-bar touch counting algorithm and multi-timeframe confluence detection. While Fibonacci retracement is a widely used concept, the specific implementation — symmetric dual-channel construction from a dynamic midpoint, percentage-adaptive touch sensitivity, RGB gradient heatmap coloring, bubble-sort level ranking, and simultaneous multi-timeframe touch analysis via request.security() — represents the author's own methodology for transforming static Fibonacci levels into a dynamic, data-scored support/resistance framework.

Disclaimer
This indicator is intended for educational and analytical purposes only. No indicator can predict future price movements with certainty. Always combine multiple forms of analysis and apply proper risk management before making any trading decisions.

Short Description:
Automatically builds a dual Fibonacci channel from the N-bar range high/low, counts how many times price has touched each of the 14 levels, and ranks them by touch frequency. Includes a multi-timeframe panel showing the most-respected Fibonacci levels across two additional timeframes for confluence analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('Fibonacci Touch Heatmap', overlay = true, max_lines_count = 500, max_labels_count = 200, max_boxes_count = 50)

// ─── SETTINGS ────────────────────────────────────────────────────────────────
lookback = input.int(300, 'Lookback (Bars)', minval = 10)
touchThresh = input.float(0.002, 'Touch Sensitivity (%)', minval = 0.0001, maxval = 0.01, step = 0.0001)
lineWidth = input.int(1, 'Fib Line Width', minval = 1, maxval = 4)

colTop = input.color(color.rgb(255, 50, 50), 'Top Color (Peak)')
colMid = input.color(color.rgb(255, 220, 0), 'Mid Color')
colBot = input.color(color.rgb(50, 200, 100), 'Bottom Color (Trough)')

// ─── CALCULATIONS ────────────────────────────────────────────────────────────
hiVal = ta.highest(high, lookback)
loVal = ta.lowest(low, lookback)
mid = math.avg(hiVal, loVal)

fibRatios = array.from(0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0)

upperFib(r) =>
    mid + (hiVal - mid) * r
lowerFib(r) =>
    mid - (mid - loVal) * r

var touchCounts = array.new_int(14, 0)

if barstate.islast
    array.fill(touchCounts, 0)
    for b = 0 to lookback - 1 by 1
        h = high[b]
        l = low[b]
        for i = 0 to 6 by 1
            lvl = upperFib(array.get(fibRatios, i))
            band = lvl * touchThresh
            if math.abs(h - lvl) <= band or math.abs(l - lvl) <= band
                array.set(touchCounts, i, array.get(touchCounts, i) + 1)
        for i = 0 to 6 by 1
            lvl = lowerFib(array.get(fibRatios, i))
            band = lvl * touchThresh
            if math.abs(h - lvl) <= band or math.abs(l - lvl) <= band
                array.set(touchCounts, i + 7, array.get(touchCounts, i + 7) + 1)

gradColor(t, transparency) =>
    r1 = color.r(colBot)
    g1 = color.g(colBot)
    b1 = color.b(colBot)
    r2 = color.r(colMid)
    g2 = color.g(colMid)
    b2 = color.b(colMid)
    r3 = color.r(colTop)
    g3 = color.g(colTop)
    b3 = color.b(colTop)
    rr = t <= 0.5 ? r1 + (r2 - r1) * (t / 0.5) : r2 + (r3 - r2) * ((t - 0.5) / 0.5)
    gg = t <= 0.5 ? g1 + (g2 - g1) * (t / 0.5) : g2 + (g3 - g2) * ((t - 0.5) / 0.5)
    bb = t <= 0.5 ? b1 + (b2 - b1) * (t / 0.5) : b2 + (b3 - b2) * ((t - 0.5) / 0.5)
    color.new(color.rgb(math.round(rr), math.round(gg), math.round(bb)), transparency)

touchColor(tc, maxTc) =>
    if maxTc == 0
        color.new(color.gray, 40)
    else
        ratio = tc / maxTc
        r = math.round(50 + (255 - 50) * ratio)
        g = math.round(150 - 150 * ratio)
        b = math.round(255 - 255 * ratio)
        color.new(color.rgb(r, g, b), 40)

if barstate.islast
    startBar = bar_index - lookback + 1

    slices = 9
    sliceH = (hiVal - loVal) / slices
    for s = 0 to slices - 1 by 1
        sliceBot = loVal + s * sliceH
        sliceTop = sliceBot + sliceH
        t = (s + 0.5) / slices
        box.new(left = startBar, top = sliceTop, right = bar_index, bottom = sliceBot, bgcolor = gradColor(t, 82), border_color = color.new(color.white, 100), border_width = 0)

    line.new(startBar, hiVal, bar_index, hiVal, color = colTop, width = 2)
    line.new(startBar, loVal, bar_index, loVal, color = colBot, width = 2)
    line.new(startBar, mid, bar_index, mid, color = colMid, width = 2)

    tcPeak = array.get(touchCounts, 6)
    tcMid = array.get(touchCounts, 0)
    tcTrou = array.get(touchCounts, 7)

    label.new(bar_index + 1, hiVal, text = 'Peak ' + str.tostring(hiVal, '#.#') + '  ●' + str.tostring(tcPeak), style = label.style_label_left, color = color.new(colTop, 30), textcolor = color.white, size = size.small)

    label.new(bar_index + 1, mid, text = 'Mid ' + str.tostring(mid, '#.#') + '  ●' + str.tostring(tcMid), style = label.style_label_left, color = color.new(colMid, 30), textcolor = color.white, size = size.small)

    label.new(bar_index + 1, loVal, text = 'Trough ' + str.tostring(loVal, '#.#') + '  ●' + str.tostring(tcTrou), style = label.style_label_left, color = color.new(colBot, 30), textcolor = color.white, size = size.small)

    for i = 1 to 5 by 1
        r = array.get(fibRatios, i)
        lvl = upperFib(r)
        t = 0.5 + r * 0.5
        lc = gradColor(t, 20)
        tc = array.get(touchCounts, i)
        lbl = str.tostring(r, '#.###') + ' ' + str.tostring(lvl, '#.#') + '  ●' + str.tostring(tc)
        line.new(startBar, lvl, bar_index, lvl, color = lc, width = lineWidth, style = line.style_dashed)
        label.new(bar_index + 1, lvl, text = lbl, style = label.style_label_left, color = color.new(lc, 40), textcolor = color.white, size = size.small)

    for i = 1 to 5 by 1
        r = array.get(fibRatios, i)
        lvl = lowerFib(r)
        t = 0.5 - r * 0.5
        lc = gradColor(t, 20)
        tc = array.get(touchCounts, i + 7)
        lbl = str.tostring(r, '#.###') + ' ' + str.tostring(lvl, '#.#') + '  ●' + str.tostring(tc)
        line.new(startBar, lvl, bar_index, lvl, color = lc, width = lineWidth, style = line.style_dashed)
        label.new(bar_index + 1, lvl, text = lbl, style = label.style_label_left, color = color.new(lc, 40), textcolor = color.white, size = size.small)

    // ── Max touch count ───────────────────────────────────────────────────
    maxTcAll = 0
    for i = 0 to 13 by 1
        if array.get(touchCounts, i) > maxTcAll
            maxTcAll := array.get(touchCounts, i)
            maxTcAll

    // ─── TOP-RIGHT TABLE — Top 4 most-touched levels (current TF) ────────────
    sortedIdx = array.new_int(14, 0)
    for i = 0 to 13 by 1
        array.set(sortedIdx, i, i)

    for i = 0 to 12 by 1
        for j = 0 to 12 - i by 1
            a = array.get(sortedIdx, j)
            b = array.get(sortedIdx, j + 1)
            if array.get(touchCounts, a) < array.get(touchCounts, b)
                array.set(sortedIdx, j, b)
                array.set(sortedIdx, j + 1, a)

    fibLabels14 = array.from('0.000↑', '0.236↑', '0.382↑', '0.500↑', '0.618↑', '0.786↑', '1.000↑', '0.000↓', '0.236↓', '0.382↓', '0.500↓', '0.618↓', '0.786↓', '1.000↓')

    // 4 columns, 6 rows: 1 title + 1 header + 4 data rows
    tblTop = table.new(position.top_right, 4, 6, bgcolor = color.new(color.black, 60), border_color = color.new(color.white, 70), border_width = 1, frame_color = color.new(color.white, 50), frame_width = 1)

    titleBg = color.new(color.navy, 20)
    hdrBg = color.new(color.gray, 45)

    // Row 0 — Table title
    table.cell(tblTop, 0, 0, 'Most\nTouched\nFib\nLevels', text_color = color.yellow, text_size = size.small, bgcolor = titleBg)
    table.cell(tblTop, 1, 0, 'Supp\nRes', text_color = color.yellow, text_size = size.small, bgcolor = titleBg)
    table.cell(tblTop, 2, 0, 'Touch', text_color = color.yellow, text_size = size.small, bgcolor = titleBg)
    table.cell(tblTop, 3, 0, 'Where', text_color = color.yellow, text_size = size.small, bgcolor = titleBg)

    // Row 1 — Column headers
    table.cell(tblTop, 0, 1, 'Fib', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblTop, 1, 1, 'Price', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblTop, 2, 1, '●', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblTop, 3, 1, 'Zone', text_color = color.white, text_size = size.small, bgcolor = hdrBg)

    // Row 2-5 — Top 4 data rows
    for rank = 0 to 3 by 1
        idx = array.get(sortedIdx, rank)
        tc = array.get(touchCounts, idx)
        rc = touchColor(tc, maxTcAll)
        isUp = idx <= 6
        ratIdx = isUp ? idx : idx - 7
        rat = array.get(fibRatios, ratIdx)
        lvl = isUp ? upperFib(rat) : lowerFib(rat)
        lbl = array.get(fibLabels14, idx)
        zone = isUp ? 'Upper' : 'Lower'
        zoneC = isUp ? color.new(colTop, 20) : color.new(colBot, 20)
        row = rank + 2

        table.cell(tblTop, 0, row, lbl, text_color = color.white, text_size = size.small, bgcolor = rc)
        table.cell(tblTop, 1, row, str.tostring(math.round(lvl)), text_color = color.white, text_size = size.small, bgcolor = rc)
        table.cell(tblTop, 2, row, str.tostring(tc), text_color = color.white, text_size = size.small, bgcolor = rc)
        table.cell(tblTop, 3, row, zone, text_color = color.white, text_size = size.small, bgcolor = zoneC)

// ─── MID TABLE TIMEFRAME SETTINGS ───────────────────────────────────────────
tf1 = input.timeframe('60', 'Timeframe 1', group = 'Multi-Timeframe Settings')
tf2 = input.timeframe('240', 'Timeframe 2', group = 'Multi-Timeframe Settings')

hi1 = request.security(syminfo.tickerid, tf1, ta.highest(high, 500), lookahead = barmerge.lookahead_off)
lo1 = request.security(syminfo.tickerid, tf1, ta.lowest(low, 500), lookahead = barmerge.lookahead_off)
hi2 = request.security(syminfo.tickerid, tf2, ta.highest(high, 500), lookahead = barmerge.lookahead_off)
lo2 = request.security(syminfo.tickerid, tf2, ta.lowest(low, 500), lookahead = barmerge.lookahead_off)

tfTouch(hiV, loV) =>
    midV = math.avg(hiV, loV)
    rats = array.from(0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0)
    counts = array.new_int(14, 0)
    thresh = touchThresh
    for b = 0 to lookback - 1 by 1
        h = high[b]
        l = low[b]
        for i = 0 to 6 by 1
            lvlU = midV + (hiV - midV) * array.get(rats, i)
            bandU = math.abs(lvlU) * thresh
            if math.abs(h - lvlU) <= bandU or math.abs(l - lvlU) <= bandU
                array.set(counts, i, array.get(counts, i) + 1)
        for i = 0 to 6 by 1
            lvlL = midV - (midV - loV) * array.get(rats, i)
            bandL = math.abs(lvlL) * thresh
            if math.abs(h - lvlL) <= bandL or math.abs(l - lvlL) <= bandL
                array.set(counts, i + 7, array.get(counts, i + 7) + 1)
    best1idx = 0
    best2idx = 1
    for j = 0 to 13 by 1
        cv = array.get(counts, j)
        if cv > array.get(counts, best1idx)
            best2idx := best1idx
            best1idx := j
            best1idx
        else if cv > array.get(counts, best2idx) and j != best1idx
            best2idx := j
            best2idx
    rats2 = array.from(0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0, 0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0)
    r1 = array.get(rats2, best1idx)
    r2 = array.get(rats2, best2idx)
    isUpper1 = best1idx <= 6
    isUpper2 = best2idx <= 6
    lv1 = isUpper1 ? midV + (hiV - midV) * r1 : midV - (midV - loV) * r1
    lv2 = isUpper2 ? midV + (hiV - midV) * r2 : midV - (midV - loV) * r2
    c1 = array.get(counts, best1idx)
    c2 = array.get(counts, best2idx)
    dir1 = isUpper1 ? '↑' : '↓'
    dir2 = isUpper2 ? '↑' : '↓'
    maxC = 0
    for j = 0 to 13 by 1
        if array.get(counts, j) > maxC
            maxC := array.get(counts, j)
            maxC
    [r1, lv1, c1, dir1, r2, lv2, c2, dir2, maxC]

[r1a, lv1a, c1a, d1a, r1b, lv1b, c1b, d1b, mx1] = tfTouch(hi1, lo1)
[r2a, lv2a, c2a, d2a, r2b, lv2b, c2b, d2b, mx2] = tfTouch(hi2, lo2)

if barstate.islast

    // ─── BOTTOM-RIGHT TABLE — Multi-Timeframe Summary ────────────────────
    tblM = table.new(position.bottom_right, 4, 5, bgcolor = color.new(color.black, 55), border_color = color.new(color.white, 60), border_width = 1, frame_color = color.new(color.white, 40), frame_width = 1)

    hdrBg = color.new(color.gray, 45)
    table.cell(tblM, 0, 0, 'TF', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblM, 1, 0, 'Fib\nLevels', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblM, 2, 0, 'Price', text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tblM, 3, 0, 'Most\nTouch\n●', text_color = color.white, text_size = size.small, bgcolor = hdrBg)

    tfNames = array.from(tf1, tf1, tf2, tf2)
    fib_arr = array.from(r1a, r1b, r2a, r2b)
    lvl_arr = array.from(lv1a, lv1b, lv2a, lv2b)
    cnt_arr = array.from(c1a, c1b, c2a, c2b)
    dir_arr = array.from(d1a, d1b, d2a, d2b)
    mx_arr = array.from(mx1, mx1, mx2, mx2)

    tfBgColors = array.from(color.new(color.blue, 30), color.new(color.blue, 50), color.new(color.purple, 30), color.new(color.purple, 50))

    for i = 0 to 3 by 1
        row = i + 1
        tfc = array.get(tfBgColors, i)
        mx = array.get(mx_arr, i)
        cnt = array.get(cnt_arr, i)
        rc = touchColor(cnt, mx)

        table.cell(tblM, 0, row, array.get(tfNames, i), text_color = color.white, text_size = size.small, bgcolor = tfc)
        table.cell(tblM, 1, row, str.tostring(array.get(fib_arr, i), '#.###') + array.get(dir_arr, i), text_color = color.white, text_size = size.small, bgcolor = rc)
        table.cell(tblM, 2, row, str.tostring(math.round(array.get(lvl_arr, i))), text_color = color.white, text_size = size.small, bgcolor = rc)
        table.cell(tblM, 3, row, str.tostring(cnt), text_color = color.white, text_size = size.small, bgcolor = rc)
````
