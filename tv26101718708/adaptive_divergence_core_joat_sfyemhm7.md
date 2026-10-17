# Adaptive Divergence Core [JOAT]

- url: https://www.tradingview.com/script/sFYemHM7-Adaptive-Divergence-Core-JOAT/
- type: indicator
- pine_id: PUB;179d124362fb4626bcf96e79ce35657c
- version: 1.0

## Description

Adaptive Divergence Core is an open-source Pine Script v6 oscillator that combines HMA-smoothed RSI behavior, adaptive percentile bands, confirmed divergence lines, and regime fills. It is designed to make oscillator extremes relative to the current chart sample instead of relying only on fixed overbought and oversold levels.

The script is useful when standard oscillator thresholds are too rigid. A market can stay strong or weak for long periods. Adaptive Divergence Core recalculates upper and lower fields from recent oscillator distribution, then plots confirmed divergence only after both price and oscillator pivots are confirmed.

[image]https://www.tradingview.com/x/lIdYvikh/[/image]

[b]Core Concepts[/b]

[b]1. HMA-RSI Core[/b]

The oscillator blends RSI on raw price, RSI on HMA-smoothed price, and an HMA-smoothed RSI value. It is centered around zero for easier bullish and bearish reading.

[pine]
hmaSource = ta.hma(src, hmaLen)
rawRsi = ta.rsi(src, rsiLen)
rsiOnHma = ta.rsi(hmaSource, rsiLen)
smoothedRsi = ta.hma(rawRsi, smoothLen)
core = (rsiOnHma * 0.58 + smoothedRsi * 0.42) - 50.0
[/pine]

[b]2. Adaptive Percentile Bands[/b]

The upper and lower bands are calculated from rolling percentiles of the oscillator. This lets the bands adapt to the recent distribution of momentum.

[pine]
upperRaw = ta.percentile_nearest_rank(core, percentileLength, upperPercentile)
lowerRaw = ta.percentile_nearest_rank(core, percentileLength, lowerPercentile)
[/pine]

[b]3. Extreme Fields[/b]

Additional 95th and 5th percentile fields help show deeper oscillator stretch zones beyond the primary adaptive bands.

[b]4. Confirmed Divergence Detection[/b]

Bearish divergence requires price to form a higher confirmed pivot high while the oscillator forms a lower confirmed pivot high. Bullish divergence requires price to form a lower confirmed pivot low while the oscillator forms a higher confirmed pivot low.

[b]5. Regime Fill[/b]

The script fills the oscillator against zero and against its guide line, making positive and negative regimes easy to read without large markers.

[b]Features[/b]

[list]
[*][b]HMA-RSI oscillator:[/b] Blends raw RSI, RSI on HMA, and smoothed RSI
[*][b]Adaptive percentile bands:[/b] Upper and lower thresholds adjust to recent oscillator behavior
[*][b]Extreme bands:[/b] Additional outer fields for deeper stretch readings
[*][b]Confirmed divergence lines:[/b] Divergences plot only after price and oscillator pivots confirm
[*][b]Divergence labels:[/b] Small S Div and B Div labels are placed near confirmed divergence lines
[*][b]Divergence line cap:[/b] Old lines are deleted to respect object limits
[*][b]Optional candle tint:[/b] Can color chart candles from the oscillator pane setting
[*][b]Dashboard:[/b] Shows core value, bands, divergence counts, and current field
[*][b]Alerts:[/b] Divergence, band entry, and band release conditions
[/list]

[b]Input Parameters[/b]

[b]Core:[/b]
[list]
[*]Source: Price source
[*]RSI Length: Base RSI period
[*]HMA Price Length: HMA source smoothing
[*]HMA RSI Smooth: Smoothing for the raw RSI component
[/list]

[b]Adaptive Bands:[/b]
[list]
[*]Percentile Length: Lookback used for adaptive thresholds
[*]Upper Percentile: Upper adaptive threshold percentile
[*]Lower Percentile: Lower adaptive threshold percentile
[/list]

[b]Divergence:[/b]
[list]
[*]Divergence Left Bars / Right Bars: Pivot confirmation settings
[*]Maximum Divergence Lines: Object cap for plotted divergence lines
[*]Divergence Labels: Shows or hides compact divergence labels
[/list]

[b]Visuals:[/b]
[list]
[*]Tint Candles: Optional candle tint from the oscillator state
[*]Show Dashboard: Shows or hides the compact top-right pane dashboard
[*]Palette: Selects the local JOAT color preset
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Core Relative to Zero[/b]
Values above zero show positive oscillator regime. Values below zero show negative oscillator regime.

[b]Step 2: Use Adaptive Bands[/b]
When core enters the upper or lower adaptive band, momentum is stretched relative to its recent sample.

[b]Step 3: Evaluate Divergence After Confirmation[/b]
Divergence lines are delayed by pivot confirmation. This is intentional and avoids projecting unconfirmed pivots into the past.

[b]Indicator Limitations[/b]

[list]
[*]Divergences confirm late because pivots need right-side bars
[*]Adaptive bands depend on the selected lookback and can shift over time
[*]Divergence is context, not a complete trade plan
[*]During strong trends, oscillator stretch can persist for many bars
[/list]

[b]Originality Statement[/b]

Adaptive Divergence Core is original in its HMA-RSI blend, rolling percentile threshold system, confirmed pivot divergence logic, and compact dashboard. It uses public Pine v6 functions to build a distinct oscillator workflow.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Oscillator divergences can fail or remain early for extended periods. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Divergence Core [JOAT]", overlay = false, max_lines_count = 200, max_labels_count = 80)

source = input.source(close, "Source", group = "Core")
rsiLength = input.int(14, "RSI Length", minval = 3, maxval = 100, group = "Core")
hmaLength = input.int(21, "HMA Price Length", minval = 3, maxval = 150, group = "Core")
smoothLength = input.int(9, "HMA RSI Smooth", minval = 2, maxval = 80, group = "Core")

percentileLength = input.int(160, "Percentile Length", minval = 40, maxval = 500, group = "Adaptive Bands")
upperPercentile = input.int(82, "Upper Percentile", minval = 55, maxval = 98, group = "Adaptive Bands")
lowerPercentile = input.int(18, "Lower Percentile", minval = 2, maxval = 45, group = "Adaptive Bands")

divLeft = input.int(4, "Divergence Left Bars", minval = 2, maxval = 20, group = "Divergence")
divRight = input.int(3, "Divergence Right Bars", minval = 2, maxval = 20, group = "Divergence")
maxDivergenceLines = input.int(35, "Maximum Divergence Lines", minval = 5, maxval = 100, group = "Divergence")
showDivergenceLabels = input.bool(true, "Divergence Labels", group = "Divergence")

tintCandles = input.bool(false, "Tint Candles", group = "Visuals")
showDashboard = input.bool(true, "Show Dashboard", group = "Visuals")
palettePreset = input.string("Aqua Rose", "Palette", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = "Visuals")

getBullColor(string preset) =>
    switch preset
        "Neon Desk" => #00ff00
        "Mint Pulse" => #00FFD5
        "VWAP Field" => #1ac200
        => #00C8FF

getBearColor(string preset) =>
    switch preset
        "Neon Desk" => #ff0000
        "Mint Pulse" => #FF0066
        "VWAP Field" => #ff4040
        => #FF005D

hmaRsiCore(series float src, int rsiLen, int hmaLen, int smoothLen) =>
    hmaSource = ta.hma(src, hmaLen)
    rawRsi = ta.rsi(src, rsiLen)
    rsiOnHma = ta.rsi(hmaSource, rsiLen)
    smoothedRsi = ta.hma(rawRsi, smoothLen)
    (rsiOnHma * 0.58 + smoothedRsi * 0.42) - 50.0

bullColor = getBullColor(palettePreset)
bearColor = getBearColor(palettePreset)
neutralColor = color.rgb(154, 163, 176)

core = hmaRsiCore(source, rsiLength, hmaLength, smoothLength)
guideLength = math.max(2, int(math.round(math.sqrt(smoothLength * hmaLength))))
guide = ta.hma(core, guideLength)

upperRaw = ta.percentile_nearest_rank(core, percentileLength, upperPercentile)
lowerRaw = ta.percentile_nearest_rank(core, percentileLength, lowerPercentile)
upperBand = math.max(upperRaw, 4.0)
lowerBand = math.min(lowerRaw, -4.0)
extremeUpperRaw = ta.percentile_nearest_rank(core, percentileLength, 95)
extremeLowerRaw = ta.percentile_nearest_rank(core, percentileLength, 5)
extremeUpper = math.max(extremeUpperRaw, upperBand + 2.0)
extremeLower = math.min(extremeLowerRaw, lowerBand - 2.0)

gradientLow = na(lowerBand) ? -25.0 : lowerBand
gradientHigh = na(upperBand) ? 25.0 : upperBand
bandSpan = na(upperBand) or na(lowerBand) ? 50.0 : math.max(upperBand - lowerBand, 10.0)
labelPadding = bandSpan * 0.08

coreColor = color.from_gradient(core, gradientLow, gradientHigh, color.new(bearColor, 0), color.new(bullColor, 0))
guideColor = core >= guide ? color.new(bullColor, 20) : color.new(bearColor, 20)
regimeFill = core >= 0.0 ? color.new(bullColor, 88) : color.new(bearColor, 88)
distanceFill = color.from_gradient(math.abs(core - guide), 0.0, math.max(bandSpan, 10.0), color.new(neutralColor, 88), core >= guide ? color.new(bullColor, 62) : color.new(bearColor, 62))

upperPlot = plot(upperBand, "Adaptive Upper", color = color.new(bearColor, 20), linewidth = 2)
lowerPlot = plot(lowerBand, "Adaptive Lower", color = color.new(bullColor, 20), linewidth = 2)
extremeUpperPlot = plot(extremeUpper, "Upper Extreme", color = color.new(bearColor, 58), linewidth = 1)
extremeLowerPlot = plot(extremeLower, "Lower Extreme", color = color.new(bullColor, 58), linewidth = 1)
zeroPlot = plot(0.0, "Zero", color = color.new(neutralColor, 35), linewidth = 1)
corePlot = plot(core, "HMA-RSI Core", color = coreColor, linewidth = 3)
guidePlot = plot(guide, "Core Guide", color = guideColor, linewidth = 2)

fill(corePlot, zeroPlot, color = regimeFill, title = "Regime Fill")
fill(corePlot, guidePlot, color = distanceFill, title = "Core Guide Fill")
fill(upperPlot, extremeUpperPlot, color = color.new(bearColor, 91), title = "Upper Extreme Band")
fill(lowerPlot, extremeLowerPlot, color = color.new(bullColor, 91), title = "Lower Extreme Band")

barcolor(tintCandles ? color.new(core >= 0.0 ? bullColor : bearColor, 72) : na, title = "Candle Tint")

priceHighPivot = ta.pivothigh(high, divLeft, divRight)
priceLowPivot = ta.pivotlow(low, divLeft, divRight)
coreHighPivot = ta.pivothigh(core, divLeft, divRight)
coreLowPivot = ta.pivotlow(core, divLeft, divRight)

var float lastPriceHigh = na
var float lastCoreHigh = na
var int lastHighBar = na
var float lastPriceLow = na
var float lastCoreLow = na
var int lastLowBar = na
var int bullishDivergences = 0
var int bearishDivergences = 0
var array<line> divergenceLines = array.new_line()
var array<label> divergenceLabels = array.new_label()

bool bullishDivergence = false
bool bearishDivergence = false

if barstate.isconfirmed and not na(priceHighPivot) and not na(coreHighPivot)
    pivotBar = bar_index - divRight
    currentPriceHigh = priceHighPivot
    currentCoreHigh = coreHighPivot
    bearishDivergence := not na(lastPriceHigh) and currentPriceHigh > lastPriceHigh and currentCoreHigh < lastCoreHigh and currentCoreHigh > 0.0
    if bearishDivergence
        newLine = line.new(lastHighBar, lastCoreHigh, pivotBar, currentCoreHigh, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = 2)
        array.push(divergenceLines, newLine)
        if showDivergenceLabels
            labelX = int(math.round((lastHighBar + pivotBar) * 0.5))
            labelY = math.max(lastCoreHigh, currentCoreHigh) + labelPadding
            newLabel = label.new(labelX, labelY, "S Div", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearColor, 8), textcolor = color.white, size = size.tiny)
            array.push(divergenceLabels, newLabel)
        bearishDivergences += 1
    lastPriceHigh := currentPriceHigh
    lastCoreHigh := currentCoreHigh
    lastHighBar := pivotBar

if barstate.isconfirmed and not na(priceLowPivot) and not na(coreLowPivot)
    pivotBar = bar_index - divRight
    currentPriceLow = priceLowPivot
    currentCoreLow = coreLowPivot
    bullishDivergence := not na(lastPriceLow) and currentPriceLow < lastPriceLow and currentCoreLow > lastCoreLow and currentCoreLow < 0.0
    if bullishDivergence
        newLine = line.new(lastLowBar, lastCoreLow, pivotBar, currentCoreLow, xloc = xloc.bar_index, color = color.new(bullColor, 0), width = 2)
        array.push(divergenceLines, newLine)
        if showDivergenceLabels
            labelX = int(math.round((lastLowBar + pivotBar) * 0.5))
            labelY = math.min(lastCoreLow, currentCoreLow) - labelPadding
            newLabel = label.new(labelX, labelY, "B Div", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullColor, 8), textcolor = color.white, size = size.tiny)
            array.push(divergenceLabels, newLabel)
        bullishDivergences += 1
    lastPriceLow := currentPriceLow
    lastCoreLow := currentCoreLow
    lastLowBar := pivotBar

while array.size(divergenceLines) > maxDivergenceLines
    removedLine = array.shift(divergenceLines)
    line.delete(removedLine)

while array.size(divergenceLabels) > maxDivergenceLines
    removedLabel = array.shift(divergenceLabels)
    label.delete(removedLabel)

plotshape(bullishDivergence ? coreLowPivot : na, "Confirmed Bullish Divergence [JOAT]", style = shape.circle, location = location.absolute, color = bullColor, size = size.tiny)
plotshape(bearishDivergence ? coreHighPivot : na, "Confirmed Bearish Divergence [JOAT]", style = shape.circle, location = location.absolute, color = bearColor, size = size.tiny)

upperCross = ta.crossover(core, upperBand)
lowerCross = ta.crossunder(core, lowerBand)
upperRelease = ta.crossunder(core, upperBand)
lowerRelease = ta.crossover(core, lowerBand)

regimeText = core > upperBand ? "Upper Stretch" : core < lowerBand ? "Lower Stretch" : core >= guide ? "Rising" : "Falling"

var table dashboard = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 78), frame_color = color.new(neutralColor, 60), frame_width = 1, border_width = 1)

if barstate.islast and showDashboard
    headerColor = core >= 0.0 ? color.new(bullColor, 35) : color.new(bearColor, 35)
    table.cell(dashboard, 0, 0, "Adaptive Divergence Core [JOAT]", text_color = color.white, bgcolor = headerColor, text_size = size.small)
    table.cell(dashboard, 1, 0, regimeText, text_color = color.white, bgcolor = headerColor, text_size = size.small)
    table.cell(dashboard, 0, 1, "Core", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 1, str.tostring(core, "#.##"), text_color = coreColor, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 2, "Adaptive bands", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 2, str.tostring(lowerBand, "#.#") + " / " + str.tostring(upperBand, "#.#"), text_color = color.white, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 3, "Divergences", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 3, str.tostring(bullishDivergences) + " up / " + str.tostring(bearishDivergences) + " down", text_color = color.white, bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 0, 4, "Status", text_color = color.new(color.white, 10), bgcolor = color.new(color.black, 82), text_size = size.tiny)
    table.cell(dashboard, 1, 4, regimeText, text_color = core >= 0.0 ? bullColor : bearColor, bgcolor = color.new(color.black, 82), text_size = size.tiny)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 4)

alertcondition(bullishDivergence and barstate.isconfirmed, "Bullish Divergence Confirmed [JOAT]", "Adaptive Divergence Core [JOAT]: bullish divergence confirmed on a closed bar.")
alertcondition(bearishDivergence and barstate.isconfirmed, "Bearish Divergence Confirmed [JOAT]", "Adaptive Divergence Core [JOAT]: bearish divergence confirmed on a closed bar.")
alertcondition(upperCross and barstate.isconfirmed, "Upper Adaptive Band Entry [JOAT]", "Adaptive Divergence Core [JOAT]: oscillator entered the upper adaptive band on a closed bar.")
alertcondition(lowerCross and barstate.isconfirmed, "Lower Adaptive Band Entry [JOAT]", "Adaptive Divergence Core [JOAT]: oscillator entered the lower adaptive band on a closed bar.")
alertcondition((upperRelease or lowerRelease) and barstate.isconfirmed, "Adaptive Band Release [JOAT]", "Adaptive Divergence Core [JOAT]: oscillator returned inside an adaptive band on a closed bar.")
````
