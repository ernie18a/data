<!-- tradingview-pine-id: PUB;6226f490217c4bd4bc322b704256e197 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Profit zone trades High Volume Zones

Source: https://www.tradingview.com/script/YO4pM9Ls-Profit-zone-trades-High-Volume-Zones/

## Description

Profit Zone Trades High Volume Zones highlights the price levels that received the greatest concentration of volume within a selected historical window.

Rather than placing a full volume-profile histogram beside the chart, this indicator draws a concise set of horizontal reference levels directly on price. This keeps the chart readable while making the most active historical price areas easy to identify.

How it works

The script builds a simplified volume profile from the selected number of historical bars:

1. It finds the highest high and lowest low within the lookback period.
2. It splits that range into an adjustable number of equal price rows.
3. Each bar’s total volume is assigned to the row containing its closing price.
4. The script adds the volume in each row and ranks the rows from highest to lowest accumulated volume.

The highest-volume row is the Point of Control (POC), shown as a red horizontal line. The remaining top-ranked rows are shown as High-Volume Nodes (HVNs) using the selected line color.

These levels show where the largest amount of historical volume was concentrated in the sampled period. They may be useful for observing price interaction around historically active areas, including acceptance, rejection, consolidation, breakouts, and retests.

Using the indicator

- **Bars for volume profile:** Sets the historical window used in the calculation.
- **Number of rows:** Controls price resolution. Higher values create narrower price rows; lower values create broader rows.
- **Number of HVN zones to display:** Selects how many of the highest-volume rows are drawn.
- **Recalculate profile every X bars:** Sets how often the indicator rebuilds its profile and updates its levels.
- **Extend line right:** Extends the levels beyond the current bar for easier reference.
- **Show price label:** Displays the price of each level on the chart.

Using confluence

These historical volume levels can be used alongside other forms of chart analysis for additional context:

- Trend context from moving averages, VWAP, or market structure.
- Momentum context from RSI, MACD, or Stochastic RSI.
- Price-action confirmation from candles, swing highs and lows, breakouts, retests, and support/resistance.
- Participation context from standard volume bars or relative volume.
- Higher-timeframe reference levels such as previous day, week, or month highs and lows.

Confluence can help organize analysis, but no combination of indicators guarantees a price reaction or trade result.

Important limitations

This script is a simplified, bar-based volume profile. Each bar’s entire volume is assigned to the price row containing that bar’s close. It does not use intrabar, tick-by-tick, bid/ask, or exchange-native volume-at-price data.

The profile uses a rolling historical lookback and is rebuilt at the selected interval. As new bars enter the lookback window and older bars leave it, the calculated POC and HVN levels can change. Results also depend on the symbol’s available volume data, chart timeframe, and selected inputs.

The POC is the highest-volume row and may overlap with one of the displayed HVN lines.

This indicator is intended for educational and chart-analysis purposes only. It does not provide trading signals, predict future price direction, guarantee support or resistance, or constitute financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © profitzonetrades

//@version=6
indicator("Profit zone trades High Volume Zones", overlay=true, max_lines_count=100, max_labels_count=100)

// ================= INPUTS =================
lookback    = input.int(200, "Bars for volume profile", minval=20)
rows        = input.int(30, "Number of rows (profile resolution)", minval=5, maxval=100)
maxZones    = input.int(5, "Number of HVN zones to display", minval=1, maxval=20)
recalcEvery = input.int(55, "Recalculate profile every X bars", minval=5)
hvnColor    = input.color(color.orange, "Line color")
hvnWidth    = input.int(2, "Line width", minval=1, maxval=5)
extendBars  = input.int(60, "Extend line right (bars)", minval=0)
showLabels  = input.bool(true, "Show price label")

// ================= VOLUME PROFILE =================
var line[]  hvnLines  = array.new_line(0)
var label[] hvnLabels = array.new_label(0)

recalcNow = bar_index % recalcEvery == 0

if recalcNow and bar_index >= lookback
    // Clear previous drawings
    if array.size(hvnLines) > 0
        for i = 0 to array.size(hvnLines) - 1
            line.delete(array.get(hvnLines, i))
        array.clear(hvnLines)

    if array.size(hvnLabels) > 0
        for i = 0 to array.size(hvnLabels) - 1
            label.delete(array.get(hvnLabels, i))
        array.clear(hvnLabels)

    hi = ta.highest(high, lookback)
    lo = ta.lowest(low, lookback)
    step = (hi - lo) / rows
    step := step == 0 ? syminfo.mintick : step

    // Accumulate volume by price row
    volArr = array.new_float(rows, 0.0)
    for i = 0 to lookback - 1
        c = close[i]
        idx = int(math.max(0, math.min(rows - 1, math.floor((c - lo) / step))))
        array.set(volArr, idx, array.get(volArr, idx) + volume[i])

    // POC: row with the highest accumulated volume
    pocVolume = array.max(volArr)
    pocIndex = array.indexof(volArr, pocVolume)
    pocPrice = lo + (pocIndex + 0.5) * step

    // Draw POC last so it remains visible above the HVN line
    pocLine = line.new(
         bar_index - lookback, pocPrice,
         bar_index + extendBars, pocPrice,
         color=color.red, width=hvnWidth + 1, style=line.style_solid)
    array.push(hvnLines, pocLine)

    if showLabels
        pocLabel = label.new(
             bar_index + extendBars, pocPrice,
             "POC " + str.tostring(pocPrice, format.mintick),
             style=label.style_label_right,
             color=color.red, textcolor=color.white, size=size.small)
        array.push(hvnLabels, pocLabel)

    // Select the N rows with the highest volume
    volCopy = array.copy(volArr)
    limit = math.min(maxZones, rows)

    for k = 0 to limit - 1
        maxV = -1.0
        maxPos = -1
        for j = 0 to array.size(volCopy) - 1
            vv = array.get(volCopy, j)
            if vv > maxV
                maxV := vv
                maxPos := j

        if maxPos >= 0 and maxV > 0
            rowBot = lo + maxPos * step
            rowTop = rowBot + step
            rowMid = (rowTop + rowBot) / 2

            l = line.new(bar_index - lookback, rowMid, bar_index + extendBars, rowMid, color=hvnColor, width=hvnWidth, style=line.style_solid)
            array.push(hvnLines, l)

            if showLabels
                lbl = label.new(bar_index + extendBars, rowMid, str.tostring(rowMid, format.mintick), style=label.style_label_left, color=color.new(hvnColor, 0), textcolor=color.black, size=size.small)
                array.push(hvnLabels, lbl)

            array.set(volCopy, maxPos, -1.0)
````
