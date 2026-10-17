# Infinity Signal- High & Low Memory Locations

- url: https://www.tradingview.com/script/Ua3cz5hX-Infinity-Signal-High-Low-Memory-Locations/
- type: indicator
- pine_id: PUB;dc4e27e2e77749f6876f97df7b0767d1
- version: 1.0

## Description

High & Low Cycle Memory Locations is a visual cycle-location tool designed to mark repeated price high and price low areas directly on the chart.

The indicator uses RSI pivot highs and RSI pivot lows to identify previous turning points. After a pivot is detected, the script compares that location against prior cycle locations using the selected cycle length and tolerance setting.

Each balloon shows whether the area was a Price High or Price Low, followed by a Location Hit count. For example, Location Hit twenty-five times means that similar high or low locations have repeated twenty-five times within the selected cycle-memory rules.

The projected balloons show the next probable Price High and Price Low locations based on either Recent Rhythm or the selected cycle-memory model.

Recommended 122-day cycle settings:

1 Hour chart: 2928 bars
2 Hour chart: 1464 bars
4 Hour chart: 720 bars
6 Hour chart: 488 bars
8 Hour chart: 366 bars
12 Hour chart: 244 bars
1 Day chart: 122 bars

These settings are included so users can configure the indicator correctly for the chart timeframe they are using. The 4 Hour setting uses 720 bars.

The Location Hit count depends on the selected cycle length and tolerance setting. Different assets and timeframes may require adjustment.

This indicator does not predict the exact price. It is designed to highlight timing areas where highs or lows have historically repeated. It should be used as a visual timing reference alongside price action, trend, support and resistance, volume, and risk-management methods.

This is not trading advice. Always do your own research.

## Source Code

````pine
//@version=6
indicator("Infinity Signal- High & Low Memory Locations", overlay=true, scale=scale.right, max_labels_count=500)

// Inputs
rsiLen = input.int(14, "RSI Length", minval=1)
pivotBars = input.int(5, "Pivot Strength", minval=1)

cycleBars = input.int(732, "122-Day Cycle Bars", minval=1)
tolerance = input.int(24, "Location Hit Tolerance", minval=1)

projectionMode = input.string("Recent Rhythm", "Projection Mode", options=["Recent Rhythm", "122-Day Memory"])
recentEvents = input.int(6, "Recent Events To Average", minval=2, maxval=20)

showHighBalloons = input.bool(true, "Show Price High Balloons")
showLowBalloons = input.bool(true, "Show Price Low Balloons")
showProjectionBalloons = input.bool(true, "Show Future Projection Balloons")

highColor = input.color(color.red, "Price High Balloon Color")
lowColor = input.color(color.green, "Price Low Balloon Color")
projectedHighColor = input.color(color.red, "Projected Price High Balloon Color")
projectedLowColor = input.color(color.green, "Projected Price Low Balloon Color")

pastHighOffsetATR = input.float(0.75, "Past Price High Vertical Offset ATR", step=0.25)
pastLowOffsetATR = input.float(0.75, "Past Price Low Vertical Offset ATR", step=0.25)

projectedHighOffsetATR = input.float(2.0, "Projected Price High Vertical Offset ATR", step=0.25)
projectedLowOffsetATR = input.float(2.0, "Projected Price Low Vertical Offset ATR", step=0.25)

projectionBarsForwardFallback = input.int(50, "Fallback Projection Bars Forward", minval=1)

labelSizeOpt = input.string("small", "Balloon Size", options=["tiny", "small", "normal", "large", "huge"])
labelSize = labelSizeOpt == "tiny" ? size.tiny : labelSizeOpt == "small" ? size.small : labelSizeOpt == "normal" ? size.normal : labelSizeOpt == "large" ? size.large : size.huge

// Core
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(14)

rsiPeak = ta.pivothigh(rsi, pivotBars, pivotBars)
rsiTrough = ta.pivotlow(rsi, pivotBars, pivotBars)

pivotBar = bar_index - pivotBars

// Arrays
var peakBarsArr = array.new_int()
var peakLabelsArr = array.new_label()

var troughBarsArr = array.new_int()
var troughLabelsArr = array.new_label()

// Location Hit function
f_locationHits(_arr, _idx) =>
    int sz = array.size(_arr)
    int baseBar = array.get(_arr, _idx)
    int count = 0

    for j = 0 to sz - 1
        if j != _idx
            otherBar = array.get(_arr, j)
            gap = math.abs(baseBar - otherBar)
            multiple = math.round(gap / cycleBars)

            if multiple >= 1
                expectedGap = multiple * cycleBars

                if math.abs(gap - expectedGap) <= tolerance
                    count += 1

    count

f_lastLocationHits(_arr) =>
    int sz = array.size(_arr)
    sz > 0 ? f_locationHits(_arr, sz - 1) : 0

// Refresh Price High balloons
f_refreshHighLabels() =>
    int sz = array.size(peakBarsArr)

    if sz > 0
        for i = 0 to sz - 1
            lb = array.get(peakLabelsArr, i)
            hits = f_locationHits(peakBarsArr, i)
            txt = "Price High\nLocation Hit " + str.tostring(hits) + "x"

            if not na(lb)
                label.set_text(lb, txt)
                label.set_size(lb, labelSize)

// Refresh Price Low balloons
f_refreshLowLabels() =>
    int sz = array.size(troughBarsArr)

    if sz > 0
        for i = 0 to sz - 1
            lb = array.get(troughLabelsArr, i)
            hits = f_locationHits(troughBarsArr, i)
            txt = "Price Low\nLocation Hit " + str.tostring(hits) + "x"

            if not na(lb)
                label.set_text(lb, txt)
                label.set_size(lb, labelSize)

// Price High balloons
if not na(rsiPeak)
    array.push(peakBarsArr, pivotBar)

    label newHighLabel = na

    if showHighBalloons
        newHighLabel := label.new(
             pivotBar,
             high[pivotBars] + atr[pivotBars] * pastHighOffsetATR,
             "Price High",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=highColor,
             textcolor=color.white,
             size=labelSize
         )

    array.push(peakLabelsArr, newHighLabel)
    f_refreshHighLabels()

// Price Low balloons
if not na(rsiTrough)
    array.push(troughBarsArr, pivotBar)

    label newLowLabel = na

    if showLowBalloons
        newLowLabel := label.new(
             pivotBar,
             low[pivotBars] - atr[pivotBars] * pastLowOffsetATR,
             "Price Low",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=lowColor,
             textcolor=color.white,
             size=labelSize
         )

    array.push(troughLabelsArr, newLowLabel)
    f_refreshLowLabels()

// Recent rhythm projection
f_recentProjection(_arr) =>
    int sz = array.size(_arr)
    float totalGap = 0.0
    int count = 0
    int projectedBar = na

    if sz >= 2
        lastBar = array.get(_arr, sz - 1)
        maxLoop = math.min(recentEvents, sz - 1)

        for i = 0 to maxLoop - 1
            b1 = array.get(_arr, sz - 1 - i)
            b0 = array.get(_arr, sz - 2 - i)
            totalGap += b1 - b0
            count += 1

        avgGap = count > 0 ? totalGap / count : na
        projectedBar := not na(avgGap) ? int(math.round(lastBar + avgGap)) : na

    projectedBar

// 122-day memory projection
f_cycleProjection(_arr) =>
    int sz = array.size(_arr)
    float totalNormGap = 0.0
    int matches = 0
    int projectedBar = na

    if sz >= 2
        lastBar = array.get(_arr, sz - 1)

        for i = sz - 2 to 0
            oldBar = array.get(_arr, i)
            gap = lastBar - oldBar
            multiple = math.round(gap / cycleBars)

            if multiple >= 1
                expectedGap = multiple * cycleBars

                if math.abs(gap - expectedGap) <= tolerance
                    totalNormGap += gap / multiple
                    matches += 1

        avgGap = matches > 0 ? totalNormGap / matches : cycleBars
        projectedBar := int(math.round(lastBar + avgGap))

    projectedBar

rawProjectedHighBar = projectionMode == "Recent Rhythm" ? f_recentProjection(peakBarsArr) : f_cycleProjection(peakBarsArr)
rawProjectedLowBar = projectionMode == "Recent Rhythm" ? f_recentProjection(troughBarsArr) : f_cycleProjection(troughBarsArr)

// Always create a projection if there is at least one high or low.
// This prevents the missing projected trough balloon problem.
projectedHighBar = not na(rawProjectedHighBar) ? rawProjectedHighBar : array.size(peakBarsArr) > 0 ? bar_index + projectionBarsForwardFallback : na
projectedLowBar = not na(rawProjectedLowBar) ? rawProjectedLowBar : array.size(troughBarsArr) > 0 ? bar_index + projectionBarsForwardFallback : na

// TradingView can fail to show bar_index labels too far into the future.
// This keeps projected balloons visible.
projectedHighBarSafe = not na(projectedHighBar) ? math.min(projectedHighBar, bar_index + 500) : na
projectedLowBarSafe = not na(projectedLowBar) ? math.min(projectedLowBar, bar_index + 500) : na

projectedHighHits = f_lastLocationHits(peakBarsArr)
projectedLowHits = f_lastLocationHits(troughBarsArr)

// Future projection balloons
var label projectedHighLabel = na
var label projectedLowLabel = na

if barstate.islast
    if not na(projectedHighLabel)
        label.delete(projectedHighLabel)

    if not na(projectedLowLabel)
        label.delete(projectedLowLabel)

    if showProjectionBalloons and not na(projectedHighBarSafe)
        projectedHighLabel := label.new(
             projectedHighBarSafe,
             high + atr * projectedHighOffsetATR,
             "Projected Price High\nLocation Hit " + str.tostring(projectedHighHits) + "x",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=projectedHighColor,
             textcolor=color.white,
             size=labelSize
         )

    if showProjectionBalloons and not na(projectedLowBarSafe)
        projectedLowLabel := label.new(
             projectedLowBarSafe,
             low - atr * projectedLowOffsetATR,
             "Projected Price Low\nLocation Hit " + str.tostring(projectedLowHits) + "x",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=projectedLowColor,
             textcolor=color.white,
             size=labelSize
         )

// Mergeable price scale anchor
plot(close, title="Price Scale Anchor — Merge This Scale", color=color.new(color.gray, 75), linewidth=1)
````
