# AJDT Auto Support & Resistance - 3 Touch Minimum V2

- url: https://www.tradingview.com/script/X4d4hUS5-AJDT-Auto-Support-Resistance-3-Touch-Minimum-V2/
- type: indicator
- pine_id: PUB;2d4bf797b001439c8a590e38d9f8d2fe
- version: 3.0

## Description

New updated AJDT Support and Resistance levels for any stock. This gives at least 3 touches on the candles to confirm levels.  Version created May 18, 2026

## Source Code

````pine
//@version=6
indicator('AJDT Auto Support & Resistance - 3 Touch Minimum', overlay = true, max_lines_count = 100, max_labels_count = 100)

// =====================================================
// SETTINGS
// =====================================================
pivotStrength = input.int(5, 'Pivot Strength', minval = 2, maxval = 20)
lookbackBars = input.int(500, 'Lookback Bars', minval = 100, maxval = 3000)
touchesNeeded = input.int(3, 'Minimum Candle Touches', minval = 2, maxval = 10)

levelsToShow = input.int(4, 'Levels Above/Below Price', minval = 1, maxval = 8)

tolerancePct = input.float(0.75, 'Touch Tolerance %', step = 0.05)

showLabels = input.bool(true, 'Show Labels')
lineWidth = input.int(2, 'Line Width', minval = 1, maxval = 5)

// =====================================================
// STORAGE ARRAYS
// =====================================================
var array<float> resistanceLevels = array.new_float()
var array<float> supportLevels = array.new_float()

var array<line> activeLines = array.new_line()
var array<label> activeLabels = array.new_label()

// =====================================================
// CLEAR DRAWINGS
// =====================================================
clearDrawings() =>
    while array.size(activeLines) > 0
        ln = array.pop(activeLines)
        line.delete(ln)

    while array.size(activeLabels) > 0
        lb = array.pop(activeLabels)
        label.delete(lb)

// =====================================================
// CHECK IF LEVEL ALREADY EXISTS
// =====================================================
levelExists(arr, level) =>
    exists = false

    tolerance = level * tolerancePct / 100

    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1 by 1

            existing = array.get(arr, i)

            if math.abs(existing - level) <= tolerance
                exists := true
                exists

    exists

// =====================================================
// COUNT TOUCHES
// =====================================================
countTouches(level) =>

    touches = 0

    tolerance = level * tolerancePct / 100

    for i = 0 to lookbackBars by 1

        touched = high[i] >= level - tolerance and low[i] <= level + tolerance

        if touched
            touches := touches + 1
            touches

    touches

// =====================================================
// ADD LEVELS
// =====================================================
addResistance(level) =>

    validTouches = countTouches(level) >= touchesNeeded

    if validTouches and not levelExists(resistanceLevels, level)
        array.push(resistanceLevels, level)

addSupport(level) =>

    validTouches = countTouches(level) >= touchesNeeded

    if validTouches and not levelExists(supportLevels, level)
        array.push(supportLevels, level)

// =====================================================
// PIVOTS
// =====================================================
pivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)
pivotLow = ta.pivotlow(low, pivotStrength, pivotStrength)

if not na(pivotHigh)
    addResistance(pivotHigh)

if not na(pivotLow)
    addSupport(pivotLow)

// =====================================================
// SORT ARRAY ASCENDING
// =====================================================
sortAscending(arr) =>

    if array.size(arr) > 1

        for i = 0 to array.size(arr) - 2 by 1

            for j = i + 1 to array.size(arr) - 1 by 1

                a = array.get(arr, i)
                b = array.get(arr, j)

                if a > b

                    array.set(arr, i, b)
                    array.set(arr, j, a)

// =====================================================
// DRAW LEVEL
// =====================================================
drawLevel(level, isResistance) =>

    levelColor = isResistance ? color.blue : color.red

    levelText = isResistance ? 'R: ' + str.tostring(level, format.mintick) : 'S: ' + str.tostring(level, format.mintick)

    ln = line.new(x1 = bar_index - lookbackBars, y1 = level, x2 = bar_index + 50, y2 = level, extend = extend.right, color = levelColor, width = lineWidth)

    array.push(activeLines, ln)

    if showLabels

        lb = label.new(x = bar_index + 5, y = level, text = levelText, style = label.style_label_left, color = levelColor, textcolor = color.white, size = size.small)

        array.push(activeLabels, lb)

// =====================================================
// MAIN EXECUTION
// =====================================================
if barstate.islast

    clearDrawings()

    sortAscending(resistanceLevels)
    sortAscending(supportLevels)

    resistanceCount = 0
    supportCount = 0

    // -----------------------------
    // RESISTANCE LEVELS ABOVE PRICE
    // -----------------------------
    if array.size(resistanceLevels) > 0

        for i = 0 to array.size(resistanceLevels) - 1 by 1

            level = array.get(resistanceLevels, i)

            if level > close and resistanceCount < levelsToShow

                drawLevel(level, true)

                resistanceCount := resistanceCount + 1
                resistanceCount

    // -----------------------------
    // SUPPORT LEVELS BELOW PRICE
    // -----------------------------
    if array.size(supportLevels) > 0

        for i = array.size(supportLevels) - 1 to 0 by 1

            level = array.get(supportLevels, i)

            if level < close and supportCount < levelsToShow

                drawLevel(level, false)

                supportCount := supportCount + 1
                supportCount
````
