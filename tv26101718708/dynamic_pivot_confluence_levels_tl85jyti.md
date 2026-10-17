# Dynamic Pivot Confluence Levels

- url: https://www.tradingview.com/script/tl85jytI-Dynamic-Pivot-Confluence-Levels/
- type: indicator
- pine_id: PUB;32c6f738c1a74836a4e2b3fd68d2d9cc
- version: 1.0

## Description

[b]Dynamic Pivot Confluence Levels – Visible Range[/b]

This indicator automatically detects the strongest price levels in your currently visible chart area by counting how many swing highs (maxima) and swing lows (minima) have occurred at or near the same price.
It draws one or two horizontal lines at the level(s) with the highest total number of turning points, helping you quickly identify high-probability support and resistance zones based on real market turning points rather than arbitrary calculations.
The indicator is fully dynamic — it recalculates automatically whenever you zoom or scroll the chart.

[b]How it works[/b]

Detects swing highs and swing lows using a configurable pivot strength (left/right bars).
Groups nearby pivot prices into buckets so that small price differences are treated as the same level.
Counts the combined number of swing highs + swing lows in each price bucket within the visible chart range only.
Draws horizontal line(s) at the strongest level(s):
Single strongest level → Blue line
Multiple levels with the exact same highest count → Green line (higher price) + Red line (lower price)

Optional labels on the right side show the price and the number of pivots that formed the level (a measure of its strength).

[b]Usage Tips[/b]

Works well on timeframes from 5 minutes to daily.
Zoom in for more localized, short-term levels. Zoom out to see broader, higher-timeframe confluence zones.
On highly volatile instruments (e.g. crypto) or lower timeframes, increase Group Ticks to avoid too many fragmented levels.
The lines and labels only consider pivots inside your current visible range. This makes the indicator very responsive to what you are actually looking at.
If you receive a runtime error (RE10045), reduce the Max Lookback Bars value (e.g. to 300 or 250).
The number shown in the label represents how many turning points (swing highs + swing lows) occurred at that level — higher numbers indicate stronger confluence.

[b]Notes[/b]

This indicator is designed to highlight confluence zones where many market participants have previously changed direction. It does not repaint and only uses confirmed pivots within the visible chart window.

## Source Code

````pine
//@version=6
indicator("Dynamic Pivot Confluence Levels", overlay=true, max_lines_count=10, max_labels_count=10)

// === INPUTS ===
leftBars       = input.int(5,  "Pivot Left Bars (Stärke)", minval=1, maxval=50)
rightBars      = input.int(5,  "Pivot Right Bars (Bestätigung)", minval=1, maxval=50)
groupTicks     = input.int(10, "Gruppierung: Pivots innerhalb von X Ticks", minval=1, maxval=100, 
                           tooltip="Höher = breitere Level. Bei RE10045 diesen Wert oder maxLookback reduzieren.")
maxLookback    = input.int(400, "Max. Lookback Bars (Sicherheit)", minval=100, maxval=1500,
                           tooltip="Bei RE10045 diesen Wert auf 300 oder 250 stellen.")

showLabels     = input.bool(true, "Labels anzeigen")
lineWidth      = input.int(2, "Linienbreite", minval=1, maxval=5)

colHigher      = input.color(color.new(#00C853, 0), "Höheres Level (grün)")
colLower       = input.color(color.new(#FF1744, 0), "Niedrigeres Level (rot)")
colSingle      = input.color(color.new(#2196F3, 0), "Einzelnes Level (blau)")

// === VARIABLEN ===
var line   l1 = na
var line   l2 = na
var label  lab1 = na
var label  lab2 = na

if barstate.islast
    line.delete(l1)
    line.delete(l2)
    label.delete(lab1)
    label.delete(lab2)
    l1 := na
    l2 := na
    lab1 := na
    lab2 := na

    float leftTime = chart.left_visible_bar_time
    if na(leftTime)
        leftTime := time[math.min(maxLookback, bar_index)]

    array<float> highPivots = array.new_float()
    array<float> lowPivots  = array.new_float()

    // === Swing Highs sammeln ===
    for int j = rightBars to math.min(maxLookback, bar_index)
        if time[j] < leftTime
            break
        float p = high[j]
        bool isMax = true
        for int k = 1 to leftBars
            if high[j + k] > p
                isMax := false
                break
        if isMax
            for int k = 1 to rightBars
                if high[j - k] > p
                    isMax := false
                    break
        if isMax
            array.push(highPivots, p)

    // === Swing Lows sammeln ===
    for int j = rightBars to math.min(maxLookback, bar_index)
        if time[j] < leftTime
            break
        float p = low[j]
        bool isMin = true
        for int k = 1 to leftBars
            if low[j + k] < p
                isMin := false
                break
        if isMin
            for int k = 1 to rightBars
                if low[j - k] < p
                    isMin := false
                    break
        if isMin
            array.push(lowPivots, p)

    // === Zusammenfassen + runden ===
    float step = syminfo.mintick * groupTicks
    array<float> allPivots = array.new_float()

    for i = 0 to array.size(highPivots) - 1
        array.push(allPivots, math.round(array.get(highPivots, i) / step) * step)
    for i = 0 to array.size(lowPivots) - 1
        array.push(allPivots, math.round(array.get(lowPivots, i) / step) * step)

    if array.size(allPivots) > 0
        // === Effiziente Häufigkeitszählung (sort + single pass) ===
        array.sort(allPivots)

        array<float> unique = array.new_float()
        array<int> counts   = array.new_int()

        float current = array.get(allPivots, 0)
        int cnt = 1
        array.push(unique, current)

        for i = 1 to array.size(allPivots) - 1
            float val = array.get(allPivots, i)
            if val == current
                cnt += 1
            else
                array.push(counts, cnt)
                current := val
                cnt := 1
                array.push(unique, current)
        array.push(counts, cnt)

        // === Top-Level(s) mit höchster Anzahl finden ===
        int maxCount = 0
        array<float> topLevels = array.new_float()

        for i = 0 to array.size(counts) - 1
            int c = array.get(counts, i)
            if c > maxCount
                maxCount := c
                array.clear(topLevels)
                array.push(topLevels, array.get(unique, i))
            else if c == maxCount
                array.push(topLevels, array.get(unique, i))

        // === Linien zeichnen ===
        if array.size(topLevels) > 0 and maxCount > 0
            float higher = array.max(topLevels)
            float lower  = array.min(topLevels)
            bool twoLines = higher != lower

            color c1 = twoLines ? colHigher : colSingle

            l1 := line.new(bar_index - 900, higher, bar_index + 80, higher,
                           color = c1, width = lineWidth, extend = extend.both)

            if twoLines
                l2 := line.new(bar_index - 900, lower, bar_index + 80, lower,
                               color = colLower, width = lineWidth, extend = extend.both)

            // === Labels ===
            if showLabels
                string txt1 = str.tostring(higher, format.mintick) + "  |  Anzahl: " + str.tostring(maxCount)
                lab1 := label.new(bar_index + 35, higher, text = txt1,
                                  color = c1, textcolor = color.white,
                                  style = label.style_label_left, size = size.small)

                if twoLines
                    string txt2 = str.tostring(lower, format.mintick) + "  |  Anzahl: " + str.tostring(maxCount)
                    lab2 := label.new(bar_index + 35, lower, text = txt2,
                                      color = colLower, textcolor = color.white,
                                      style = label.style_label_left, size = size.small)
````
