# Reaction Levels

- url: https://www.tradingview.com/script/0vECdEdW-Reaction-Levels/
- type: indicator
- pine_id: PUB;a521a6d5a2934e7b9e1ff023e4c86b06
- version: 1.0

## Description

Shows price reaction levels like support and resistance

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Yasashi

//@version=6
indicator("Reaction Levels", overlay = true, max_bars_back = 500)

// ───── Inputs ────────────────────────────────────────────────────────────────
group_settings = "Settings 🔨"
group_colors   = "Colors"

period      = input.int(30, "Pivot Period", minval = 10, maxval = 100, group = group_settings)
channelW    = input.int(3, "Max Width %", minval = 1, maxval = 10, group = group_settings)
maxSR       = input.int(6, "Max Number of S/R", minval = 1, maxval = 20, group = group_settings) - 1
lookback    = input.int(400, "Lookback Period", minval = 100, maxval = 1440, group = group_settings)

resCol = input.color(color.new(color.red, 85), "Resistance Color", group = group_colors)
supCol = input.color(color.new(color.lime, 85), "Support Color", group = group_colors)
midCol = input.color(color.new(color.gray, 85), "Inside Channel Color", group = group_colors)

// ───── Pivot Detection ───────────────────────────────────────────────────────
ph = ta.pivothigh(high, period, period)
pl = ta.pivotlow(low, period, period)

// ───── Channel Width Calculation ─────────────────────────────────────────────
rangeHigh = ta.highest(400)
rangeLow  = ta.lowest(400)
channelWidth = (rangeHigh - rangeLow) * channelW / 100

// ───── Pivot Storage ─────────────────────────────────────────────────────────
var pivotVals = array.new_float()
var pivotLocs = array.new_int()

if not na(ph) or not na(pl)
    val = not na(ph) ? ph : pl
    array.unshift(pivotVals, val)
    array.unshift(pivotLocs, bar_index)

    // remove old pivots
    for i = array.size(pivotVals) - 1 to 0
        if bar_index - array.get(pivotLocs, i) > lookback
            array.pop(pivotVals)
            array.pop(pivotLocs)
        else
            break

// ───── Build SR Channel from Pivot ───────────────────────────────────────────
getSR(idx) =>
    float lo = array.get(pivotVals, idx)
    float hi = lo
    int strength = 0

    for i = 0 to array.size(pivotVals) - 1
        p = array.get(pivotVals, i)
        width = p <= hi ? hi - p : p - lo

        if width <= channelWidth
            if p <= hi
                lo := math.min(lo, p)
            else
                hi := math.max(hi, p)

            strength += 20

    [hi, lo, strength]

// ───── SR Storage ────────────────────────────────────────────────────────────
var srLevels = array.new_float(20, 0)

// swap helper
swap(idx1, idx2) =>
    h1 = array.get(srLevels, idx1 * 2)
    l1 = array.get(srLevels, idx1 * 2 + 1)
    h2 = array.get(srLevels, idx2 * 2)
    l2 = array.get(srLevels, idx2 * 2 + 1)

    array.set(srLevels, idx1 * 2, h2)
    array.set(srLevels, idx1 * 2 + 1, l2)
    array.set(srLevels, idx2 * 2, h1)
    array.set(srLevels, idx2 * 2 + 1, l1)

// ───── Recalculate SR on New Pivot ───────────────────────────────────────────
if not na(ph) or not na(pl)
    tmpSR  = array.new_float()
    strengthArr = array.new_float(10, 0)

    // build candidates
    for i = 0 to array.size(pivotVals) - 1
        [hi, lo, str] = getSR(i)
        array.push(tmpSR, str)
        array.push(tmpSR, hi)
        array.push(tmpSR, lo)

    // enhance strength with touches
    for i = 0 to array.size(pivotVals) - 1
        hi = array.get(tmpSR, i * 3 + 1)
        lo = array.get(tmpSR, i * 3 + 2)

        touches = 0
        for j = 0 to lookback
            if (high[j] <= hi and high[j] >= lo) or (low[j] <= hi and low[j] >= lo)
                touches += 1

        array.set(tmpSR, i * 3, array.get(tmpSR, i * 3) + touches)

    array.fill(srLevels, 0)

    // select strongest levels
    count = 0
    for _ = 0 to array.size(pivotVals) - 1
        bestVal = -1.0
        bestIdx = -1

        for j = 0 to array.size(pivotVals) - 1
            val = array.get(tmpSR, j * 3)
            if val > bestVal and val >= 20
                bestVal := val
                bestIdx := j

        if bestIdx >= 0
            hi = array.get(tmpSR, bestIdx * 3 + 1)
            lo = array.get(tmpSR, bestIdx * 3 + 2)

            array.set(srLevels, count * 2, hi)
            array.set(srLevels, count * 2 + 1, lo)
            array.set(strengthArr, count, bestVal)

            // invalidate overlapping
            for j = 0 to array.size(pivotVals) - 1
                hi2 = array.get(tmpSR, j * 3 + 1)
                lo2 = array.get(tmpSR, j * 3 + 2)

                if (hi2 <= hi and hi2 >= lo) or (lo2 <= hi and lo2 >= lo)
                    array.set(tmpSR, j * 3, -1)

            count += 1
            if count >= 10
                break

    // sort by strength
    for i = 0 to 8
        for j = i + 1 to 9
            if array.get(strengthArr, j) > array.get(strengthArr, i)
                tmp = array.get(strengthArr, j)
                array.set(strengthArr, j, array.get(strengthArr, i))
                array.set(strengthArr, i, tmp)
                swap(i, j)

// ───── Helpers ───────────────────────────────────────────────────────────────
getLevel(idx) =>
    idx < array.size(srLevels) and array.get(srLevels, idx) != 0 ? array.get(srLevels, idx) : na

getColor(idx) =>
    if idx < array.size(srLevels) and array.get(srLevels, idx) != 0
        hi = array.get(srLevels, idx)
        lo = array.get(srLevels, idx + 1)
        hi > close and lo > close ? resCol : hi < close and lo < close ? supCol : midCol
    else
        na

// ───── Draw Channels ─────────────────────────────────────────────────────────
var boxes = array.new_box(10)

for i = 0 to math.min(9, maxSR)
    box.delete(array.get(boxes, i))

    col = getColor(i * 2)
    if not na(col)
        b = box.new(
            left = bar_index,
            right = bar_index + 1,
            top = getLevel(i * 2),
            bottom = getLevel(i * 2 + 1),
            bgcolor = col,
            border_color = col,
            extend = extend.both
        )
        array.set(boxes, i, b)
````
