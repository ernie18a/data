# Price Density S&R

- url: https://www.tradingview.com/script/PsWiUXz4/
- type: indicator
- pine_id: PUB;e73ef869c93243769f4275f1cded0892
- version: 2.0

## Description

Price Density S&R

Price Density S&R is a price-action based support and resistance indicator designed to identify levels where market activity has repeatedly concentrated over a selected historical period.

Instead of relying on pivot points, oscillators, or volume-based calculations, the script analyzes historical price interactions and groups nearby price points into density zones. Areas that receive repeated interactions are considered potentially significant market levels and are displayed as dynamic support and resistance lines.

How It Works

The indicator scans historical candles within a user-defined lookback range and collects high, low, and closing prices.

Nearby prices are automatically clustered into zones using a configurable merge threshold. Every time price revisits a zone, the interaction count increases. Zones with the highest interaction frequency are prioritized and displayed on the chart.

The result is a map of price levels that have historically attracted repeated market attention.

Features

• Automatic support and resistance detection

• Price-density clustering algorithm

• Adjustable lookback period

• Customizable zone sensitivity

• Minimum touch-count filtering

• Dynamic level ranking based on interaction frequency

• Visual distinction between support and resistance zones

• Optional touch-count labels

• Lightweight and chart-friendly design

Settings

Lookback Bars:
Defines how many historical bars are analyzed.

Zone Merge Threshold:
Controls how aggressively nearby prices are grouped together.

Minimum Touch Count:
Filters out weaker levels with insufficient historical interactions.

Maximum Levels:
Limits the number of displayed support and resistance levels.

Interpretation

Levels with higher touch counts indicate areas where price has historically interacted more frequently. These zones may represent areas of market interest, potential reactions, consolidation, or previous balance between buyers and sellers.

As with all technical analysis tools, historical interactions do not guarantee future market behavior. The indicator should be used alongside broader market context, trend analysis, and risk management techniques.

Notes

This indicator is designed as a visual market-structure tool and does not generate buy or sell signals. It is intended to help traders identify historically active price regions that may be relevant during future market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano



//@version=6
indicator('Price Density S&R', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
barsBack = input.int(500, 'Lookback Bars', minval = 100, maxval = 5000)
zoneSize = input.float(0.006, 'Zone Merge Threshold (%)', minval = 0.001, maxval = 0.02, step = 0.001)
minTouch = input.int(5, 'Minimum Touch Count', minval = 1, maxval = 50)
maxLevels = input.int(13, 'Maximum Levels', minval = 1, maxval = 40)
showLabel = input.bool(true, 'Show Touch Count Labels')
lineWidth = input.int(5, 'Line Width', minval = 1, maxval = 10)
resCol = input.color(color.rgb(232, 8, 8), 'Resistance Color')
supCol = input.color(color.rgb(10, 236, 18), 'Support Color')
// ─── price options ───────────────────────────────────────────────────
var array<float> zoneCenters = array.new_float()
var array<int> zoneCounts = array.new_int()

touchZone(float price) =>
    if not na(price)
        matched = false
        sz = array.size(zoneCenters)
        if sz > 0
            for i = 0 to sz - 1 by 1
                center = array.get(zoneCenters, i)
                if math.abs(center - price) / price < zoneSize
                    cnt = array.get(zoneCounts, i) + 1
                    array.set(zoneCounts, i, cnt)
                    array.set(zoneCenters, i, (center * (cnt - 1) + price) / cnt)
                    matched := true
                    break
        if not matched
            array.push(zoneCenters, price)
            array.push(zoneCounts, 1)

inRange = bar_index >= last_bar_index - barsBack
if inRange
    touchZone(high)
    touchZone(low)
    touchZone(close)

// ─── last  bar draw ────────────────────────────────────────────────────────────
if barstate.islast
    sz = array.size(zoneCenters)

    if sz > 0
        for i = 0 to sz - 2 by 1
            for j = 0 to sz - 2 - i by 1
                if array.get(zoneCounts, j) < array.get(zoneCounts, j + 1)
                    cTmp = array.get(zoneCounts, j)
                    pTmp = array.get(zoneCenters, j)
                    array.set(zoneCounts, j, array.get(zoneCounts, j + 1))
                    array.set(zoneCounts, j + 1, cTmp)
                    array.set(zoneCenters, j, array.get(zoneCenters, j + 1))
                    array.set(zoneCenters, j + 1, pTmp)

        var array<float> drawnLevels = array.new_float()
        drawn = 0

        for i = 0 to sz - 1 by 1
            if drawn >= maxLevels
                break

            hits = array.get(zoneCounts, i)
            center = array.get(zoneCenters, i)

            if hits < minTouch
                break

            overlaps = false
            dSz = array.size(drawnLevels)
            if dSz > 0
                for k = 0 to dSz - 1 by 1
                    prev = array.get(drawnLevels, k)
                    if math.abs(prev - center) / center < zoneSize * 2
                        overlaps := true
                        break

            if not overlaps
                col = center > close ? resCol : supCol

                line.new(x1 = bar_index - barsBack, y1 = center, x2 = bar_index, y2 = center, color = color.new(col, 30), width = lineWidth, extend = extend.right, style = line.style_solid)

                if showLabel
                    label.new(x = bar_index + 10, y = center, text = str.tostring(hits) + ' touches | ' + str.tostring(math.round(center, 2)), color = color.new(col, 30), textcolor = color.white, style = label.style_label_left, size = size.small)

                array.push(drawnLevels, center)
                drawn := drawn + 1
                drawn
````
