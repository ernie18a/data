# Sentinel Trailing Bench [JOAT]

- url: https://www.tradingview.com/script/iCno85eD-Sentinel-Trailing-Bench-JOAT/
- type: indicator
- pine_id: PUB;ba3e9900590848b8875eaef40406bb52
- version: 1.0

## Description

[b]Sentinel Trailing Bench [JOAT][/b]

[b]Introduction[/b]

Sentinel Trailing Bench is an open-source contextual trailing-stop overlay designed to behave differently from a standard ATR stop. It blends a sorted price-distribution engine, ATR protection, adaptive recovery behavior, and a benchmark rail so the trailing structure can react to both volatility and local value geometry.

The problem Sentinel solves is stop quality. Simple trailing stops either hug price too tightly in noisy conditions or drift too far away to be useful. Sentinel uses neighborhood structure from a sorted close buffer to estimate contextual bands, then mixes that with ATR logic and recovery tightening when the active side is under pressure.

[image]https://www.tradingview.com/x/NKzBMDCM/[/image]

[b]Core Concepts[/b]

[b]1. Sorted distribution engine[/b]

The script maintains a rolling close buffer and a sorted mirror of that buffer. This allows it to derive contextual neighborhood slices around the current price instead of relying on ATR alone.

[b]2. Percentile-derived context bands[/b]

Supportive and defensive reference levels are estimated from the nearby distribution rather than only from recent swing points.

[b]3. ATR-backed resilience[/b]

An ATR anchor remains part of the design so the stop still respects current volatility when distribution structure becomes thin or unstable.

[b]4. Recovery tightening[/b]

If price moves materially against the active side relative to the last switch price, the adaptive rail is pulled closer to price to avoid stale trailing behavior.

[b]5. Institutional bench display[/b]

The overlay shows the active stop, a benchmark line, the adaptive rail, directional clouding, candle tinting, and a compact dashboard that summarizes trend state, value state, stop gap, and recovery status.

[image]https://www.tradingview.com/x/PQXzNLuh/[/image]

[b]Features[/b]

[list]
[*][b]Distribution-aware trailing stop:[/b] Uses a sorted close engine and local neighborhood structure
[*][b]ATR defensive anchor:[/b] Keeps the stop grounded in current volatility
[*][b]Adaptive recovery pull:[/b] Tightens the guidance rail when the active side is stressed
[*][b]Benchmark line and adaptive rail:[/b] Adds visual context beyond the raw stop itself
[*][b]Directional cloud and candle tint:[/b] Clean visual bias cues without retail-style arrows
[*][b]Top-right dashboard:[/b] Reports trend state, regime context, value position, stop gap, and recovery status
[*][b]Confirmed-bar flips:[/b] Regime flips are confirmed on closed bars only
[/list]

[b]Input Parameters[/b]

[b]Core:[/b]
[list]
[*]Distribution Buffer
[*]Neighborhood Radius
[*]ATR Length
[*]ATR Anchor
[*]Benchmark Length
[/list]

[b]Context:[/b]
[list]
[*]Distribution Blend
[*]Recovery Threshold xATR
[*]Recovery Pull
[*]Anchor Smoothing
[/list]

[b]Visuals:[/b]
[list]
[*]Show Benchmark
[*]Show Adaptive Rail
[*]Show Band Clouds
[*]Color Candles
[*]Show Dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the active side[/b]
The dashboard and cloud color show whether the stop is currently managing an ascent or descent state.

[b]Step 2: Watch stop gap and rail gap[/b]
The dashboard shows how far price sits from the active stop and adaptive rail in ATR terms. This helps frame whether the trailing structure is loose or tight.

[b]Step 3: Monitor recovery[/b]
If recovery becomes active, the stop structure is signaling that the current side is under stress and the rail is tightening.

[b]Step 4: Use it as trade management context[/b]
Sentinel is most effective as a management tool layered onto entries generated elsewhere.

[b]Indicator Limitations[/b]

[list]
[*]Distribution-derived bands depend on the sample window and will evolve as new closes enter the buffer
[*]In extremely fast conditions, any trailing stop can still gap beyond the intended exit area
[*]Recovery tightening improves responsiveness but can also accelerate exits in choppy reversals
[/list]

[b]Originality Statement[/b]

Sentinel Trailing Bench is original in how it fuses sorted-distribution neighborhood structure, ATR resilience, and adaptive recovery behavior into one trailing-stop overlay. It is published because:

[list]
[*]The stop uses local price distribution context instead of ATR alone
[*]The recovery module changes behavior when the active side is materially under pressure
[*]The benchmark, rail, cloud, and dashboard turn trailing logic into a full management framework rather than a single line
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not guarantee future market behavior. Trailing stops can still be affected by volatility shocks, gaps, and structural changes in the market. Always use independent judgment and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Sentinel Trailing Bench [JOAT]", "STB [JOAT]", overlay = true, max_labels_count = 10, max_lines_count = 20, max_boxes_count = 10)

//====================================================================================
// Institutional palette
//====================================================================================
color bullTone   = #2dd4bf
color bearTone   = #fb7185
color benchTone  = #94a3b8
color accelTone  = #fbbf24
color panelTone  = #0b1220
color panelLine  = #1f2a3a
color textTone   = #e5eef9
color mutedTone  = #8b98ae

//====================================================================================
// Inputs
//====================================================================================
string coreGroup = "Core"
int bufferBars = input.int(220, "Distribution Buffer", minval = 60, maxval = 2000, group = coreGroup, tooltip = "Historical closes stored in the sorted distribution engine.")
int neighborBars = input.int(24, "Neighborhood Radius", minval = 5, maxval = 150, group = coreGroup, tooltip = "Local slice used to derive contextual support and resistance bands.")
int atrLength = input.int(14, "ATR Length", minval = 1, group = coreGroup)
float atrMult = input.float(2.8, "ATR Anchor", minval = 0.1, step = 0.1, group = coreGroup, tooltip = "Baseline ATR distance used as the defensive stop anchor.")
int benchLength = input.int(34, "Benchmark Length", minval = 2, group = coreGroup, tooltip = "Directional benchmark used to seed and contextualize the stop state.")

string contextGroup = "Context"
float densityMix = input.float(0.62, "Distribution Blend", minval = 0.05, maxval = 0.95, step = 0.01, group = contextGroup, tooltip = "Controls how strongly the stop leans on distribution structure when compared to ATR protection.")
float recoveryThreshold = input.float(1.15, "Recovery Threshold xATR", minval = 0.1, step = 0.05, group = contextGroup, tooltip = "Activates recovery tightening once the move against the active side exceeds this many ATRs from the last switch price.")
float recoveryPull = input.float(0.18, "Recovery Pull", minval = 0.01, maxval = 0.5, step = 0.01, group = contextGroup, tooltip = "Pulls the adaptive guide closer to price when the active side is under pressure.")
int anchorSmoothing = input.int(8, "Anchor Smoothing", minval = 1, maxval = 50, group = contextGroup, tooltip = "Smooths the adaptive rail used for fills and dashboard context.")

string visualGroup = "Visuals"
bool showBench = input.bool(true, "Show Benchmark", group = visualGroup)
bool showAdaptiveRail = input.bool(true, "Show Adaptive Rail", group = visualGroup)
bool showClouds = input.bool(true, "Show Band Clouds", group = visualGroup)
bool showCandleTint = input.bool(true, "Color Candles", group = visualGroup)
bool showSignals = input.bool(true, "Show Signals", group = visualGroup)

string dashGroup = "Dashboard"
bool showDashboard = input.bool(true, "Show Dashboard", group = dashGroup)

//====================================================================================
// Helper functions
//====================================================================================
f_clamp(float value, float floorValue, float ceilValue) =>
    math.max(floorValue, math.min(ceilValue, value))

f_ratio(float numerator, float denominator) =>
    na(numerator) or na(denominator) ? 0.0 : numerator / math.max(denominator, syminfo.mintick)

f_percentile(float[] values, float percentile) =>
    float result = na
    int size = array.size(values)
    if size > 0
        float position = (size - 1) * percentile / 100.0
        int lowerIndex = int(math.floor(position))
        int upperIndex = int(math.ceil(position))
        float lowerValue = array.get(values, lowerIndex)
        float upperValue = array.get(values, upperIndex)
        result := lowerIndex == upperIndex ? lowerValue : lowerValue + (upperValue - lowerValue) * (position - lowerIndex)
    result

f_insertSorted(float[] values, float price) =>
    int size = array.size(values)
    int insertIndex = size > 0 ? array.binary_search_leftmost(values, price) : 0
    if size > 0 and insertIndex < size and array.get(values, insertIndex) < price
        insertIndex += 1
    array.insert(values, insertIndex, price)

f_removeSorted(float[] values, float price) =>
    int size = array.size(values)
    if size > 0
        int removeIndex = array.binary_search_leftmost(values, price)
        if removeIndex < size and array.get(values, removeIndex) == price
            array.remove(values, removeIndex)

f_slicePercentile(float[] values, int startIndex, int endIndexExclusive, float percentile) =>
    float result = na
    int size = array.size(values)
    int safeStart = math.max(0, math.min(startIndex, size))
    int safeEnd = math.max(0, math.min(endIndexExclusive, size))
    if safeEnd > safeStart
        float[] sliceValues = array.slice(values, safeStart, safeEnd)
        result := f_percentile(sliceValues, percentile)
    result

f_dashRow(table dash, int rowIndex, string leftText, string rightText, color rightTextColor, color rightBgColor) =>
    table.cell(dash, 0, rowIndex, leftText, text_color = mutedTone, bgcolor = color.new(panelTone, 0), text_size = size.normal)
    table.cell(dash, 1, rowIndex, rightText, text_color = rightTextColor, bgcolor = rightBgColor, text_size = size.normal)

//====================================================================================
// Distribution buffer engine
//====================================================================================
var array<float> liveQueue = array.new_float()
var array<float> sortedQueue = array.new_float()
var int bufferedBarIndex = na

if na(bufferedBarIndex) or bufferedBarIndex != bar_index
    int overflow = array.size(liveQueue) - bufferBars
    if overflow > 0
        for trimIndex = 0 to overflow - 1
            float removedValue = array.shift(liveQueue)
            f_removeSorted(sortedQueue, removedValue)
    array.push(liveQueue, close)
    f_insertSorted(sortedQueue, close)
    bufferedBarIndex := bar_index
else
    int lastIndex = array.size(liveQueue) - 1
    if lastIndex >= 0
        float priorValue = array.get(liveQueue, lastIndex)
        if priorValue != close
            array.set(liveQueue, lastIndex, close)
            f_removeSorted(sortedQueue, priorValue)
            f_insertSorted(sortedQueue, close)

//====================================================================================
// Context model
//====================================================================================
float atrValue = nz(ta.atr(atrLength), syminfo.mintick * 10)
float atrBaseline = nz(ta.ema(atrValue, math.max(5, atrLength * 3)), atrValue)
float benchLine = nz(ta.ema(close, benchLength), close)
int fastLength = math.max(3, int(math.round(benchLength * 0.5)))
float fastLine = nz(ta.ema(close, fastLength), close)

int poolSize = array.size(sortedQueue)
int searchIndex = poolSize > 0 ? array.binary_search_leftmost(sortedQueue, close) : 0
int safeIndex = poolSize > 0 ? math.max(0, math.min(searchIndex, poolSize - 1)) : 0

int lowerStart = math.max(0, safeIndex - neighborBars)
int upperEnd = math.min(poolSize, safeIndex + neighborBars + 1)

float lowerSupport = poolSize >= 6 and safeIndex > lowerStart ? f_slicePercentile(sortedQueue, lowerStart, safeIndex, 25) : na
float upperResistance = poolSize >= 6 and upperEnd > safeIndex + 1 ? f_slicePercentile(sortedQueue, safeIndex + 1, upperEnd, 75) : na
float valueCenter = poolSize >= 6 ? f_slicePercentile(sortedQueue, lowerStart, upperEnd, 50) : benchLine

float supportSpan = na(lowerSupport) or na(upperResistance) ? atrValue : upperResistance - lowerSupport
supportSpan := math.max(supportSpan, syminfo.mintick)

float atrPressure = nz(f_ratio(atrValue, atrBaseline), 1.0)
float noiseScore = f_clamp(atrPressure - 1.0, 0.0, 1.0)
float densityScore = nz(f_clamp(1.0 - f_ratio(supportSpan, atrValue * 2.0), 0.0, 1.0), 0.5)
float biasScore = nz(f_clamp(math.abs(f_ratio(fastLine - benchLine, atrValue)), 0.0, 1.0), 0.0)
float blendWeight = f_clamp(0.25 + 0.50 * densityScore + 0.20 * biasScore - 0.25 * noiseScore, 0.10, 0.90)
blendWeight := f_clamp(blendWeight * (0.55 + densityMix * 0.45), 0.10, 0.90)

float atrBullAnchor = hl2 - atrValue * atrMult
float atrBearAnchor = hl2 + atrValue * atrMult

float distBullAnchor = na(lowerSupport) ? atrBullAnchor : lowerSupport - supportSpan * 0.15
float distBearAnchor = na(upperResistance) ? atrBearAnchor : upperResistance + supportSpan * 0.15

float bullCore = atrBullAnchor + (distBullAnchor - atrBullAnchor) * blendWeight
float bearCore = atrBearAnchor + (distBearAnchor - atrBearAnchor) * blendWeight

bullCore := na(bullCore) ? atrBullAnchor : bullCore
bearCore := na(bearCore) ? atrBearAnchor : bearCore

float normalizedSpread = f_clamp(f_ratio(supportSpan, math.max(atrValue, syminfo.mintick) * 1.75), 0.0, 2.0)
string regimeText = noiseScore > 0.65 ? "EXPANSIVE" : densityScore > 0.65 ? "COMPACT" : "BALANCED"
float valueAnchor = na(valueCenter) ? nz(benchLine, close) : valueCenter
string valueText = close >= valueAnchor ? "ABOVE VALUE" : "BELOW VALUE"

//====================================================================================
// Trailing stop state
//====================================================================================
var int trailState = 1
var float trailStop = na
var float switchPrice = na
var float adaptiveRail = na

float longGuidance = bullCore
float shortGuidance = bearCore

if barstate.isfirst
    trailState := nz(fastLine, close) >= nz(benchLine, close) ? 1 : -1
    switchPrice := close
    trailStop := trailState == 1 ? longGuidance : shortGuidance
    adaptiveRail := trailStop

bool longRecoveryNow = trailState == 1 and not na(switchPrice) and (switchPrice - close) > atrValue * recoveryThreshold
bool shortRecoveryNow = trailState == -1 and not na(switchPrice) and (close - switchPrice) > atrValue * recoveryThreshold
bool recoveryNow = trailState == 1 ? longRecoveryNow : shortRecoveryNow

if longRecoveryNow
    longGuidance += (close - longGuidance) * recoveryPull
    longGuidance := math.min(longGuidance, close - syminfo.mintick)
if shortRecoveryNow
    shortGuidance -= (shortGuidance - close) * recoveryPull
    shortGuidance := math.max(shortGuidance, close + syminfo.mintick)

bool bullishFlip = false
bool bearishFlip = false

if barstate.isconfirmed and not barstate.isfirst
    int priorState = trailState
    float priorStop = nz(trailStop[1], priorState == 1 ? longGuidance : shortGuidance)

    if priorState == 1
        if close < priorStop
            trailState := -1
            switchPrice := close
            trailStop := shortGuidance
            adaptiveRail := shortGuidance
            bearishFlip := true
        else
            trailState := 1
            trailStop := math.max(priorStop, longGuidance)
            adaptiveRail := longGuidance
    else
        if close > priorStop
            trailState := 1
            switchPrice := close
            trailStop := longGuidance
            adaptiveRail := longGuidance
            bullishFlip := true
        else
            trailState := -1
            trailStop := math.min(priorStop, shortGuidance)
            adaptiveRail := shortGuidance

//====================================================================================
// Derived display state
//====================================================================================
float stopGapAtr = na(trailStop) ? na : f_ratio(math.abs(close - trailStop), atrValue)
float benchGapAtr = na(adaptiveRail) ? na : f_ratio(math.abs(close - adaptiveRail), atrValue)
float smoothRail = na(adaptiveRail) ? na : ta.ema(adaptiveRail, anchorSmoothing)
float smoothSupport = ta.ema(lowerSupport, math.max(2, int(math.round(anchorSmoothing * 0.5))))
float smoothResistance = ta.ema(upperResistance, math.max(2, int(math.round(anchorSmoothing * 0.5))))
float valueMid = ta.ema(valueAnchor, math.max(2, int(math.round(anchorSmoothing * 0.5))))
float thrustScore = f_clamp(math.abs(f_ratio(close - benchLine, atrValue)) * 0.5 + biasScore * 0.5, 0.0, 2.0)
bool reclaimBull = barstate.isconfirmed and trailState == 1 and ta.crossover(close, valueMid)
bool reclaimBear = barstate.isconfirmed and trailState == -1 and ta.crossunder(close, valueMid)
bool continuationBull = barstate.isconfirmed and trailState == 1 and close > nz(upperResistance, close + syminfo.mintick) and close > close[1]
bool continuationBear = barstate.isconfirmed and trailState == -1 and close < nz(lowerSupport, close - syminfo.mintick) and close < close[1]

string trendText = trailState == 1 ? "ASCENT" : "DESCENT"
string recoveryText = recoveryNow ? "ACTIVE" : "IDLE"
string gapText = na(stopGapAtr) ? "n/a" : str.tostring(stopGapAtr, "#.00") + " ATR"
string railText = na(benchGapAtr) ? "n/a" : str.tostring(benchGapAtr, "#.00") + " ATR"
string densityText = str.tostring(densityScore, "#.00")
string spreadText = str.tostring(normalizedSpread, "#.00")
color trendTone = trailState == 1 ? bullTone : bearTone
int trailTransparency = int(math.round(f_clamp(72 - densityScore * 26 - (recoveryNow ? 8 : 0), 12, 88)))
color trailTone = color.new(trendTone, trailTransparency)
color railTone = color.new(trendTone, 70)
color benchFade = color.new(benchTone, 45)
color recoveryTone = recoveryNow ? color.new(accelTone, 20) : color.new(trendTone, 80)
int candleTransparency = int(f_clamp(float(trailTransparency - (recoveryNow ? 8 : 0)), 0.0, 100.0))
color supportTone = color.new(bullTone, 45)
color resistanceTone = color.new(bearTone, 45)
color midTone = color.new(accelTone, 50)

//====================================================================================
// Visual structure
//====================================================================================
plotBench = plot(showBench ? benchLine : na, "Benchmark", color = benchFade, linewidth = 1)

plotTrailBull = plot(trailState == 1 ? trailStop : na, "Bull Trail", color = trailTone, linewidth = 2, style = plot.style_linebr)
plotTrailBear = plot(trailState == -1 ? trailStop : na, "Bear Trail", color = trailTone, linewidth = 2, style = plot.style_linebr)

plotRailBull = plot(showAdaptiveRail and trailState == 1 ? smoothRail : na, "Bull Rail", color = railTone, linewidth = 1, style = plot.style_linebr)
plotRailBear = plot(showAdaptiveRail and trailState == -1 ? smoothRail : na, "Bear Rail", color = railTone, linewidth = 1, style = plot.style_linebr)
plotSupport = plot(showAdaptiveRail ? smoothSupport : na, "Value Support", color = supportTone, linewidth = 1, style = plot.style_linebr)
plotResistance = plot(showAdaptiveRail ? smoothResistance : na, "Value Resistance", color = resistanceTone, linewidth = 1, style = plot.style_linebr)
plotValueMid = plot(showAdaptiveRail ? valueMid : na, "Value Mid", color = midTone, linewidth = 1, style = plot.style_linebr)

color bullCloud = showClouds ? color.new(bullTone, 88) : color.new(bullTone, 100)
color bearCloud = showClouds ? color.new(bearTone, 88) : color.new(bearTone, 100)
color bullRailCloud = showClouds ? color.new(bullTone, 92) : color.new(bullTone, 100)
color bearRailCloud = showClouds ? color.new(bearTone, 92) : color.new(bearTone, 100)
color valueCloud = showClouds ? color.new(color.from_gradient(trailState, -1, 1, bearTone, bullTone), 94) : color.new(panelTone, 100)

fill(plotTrailBull, plotBench, color = bullCloud, title = "Bull Cloud")
fill(plotTrailBear, plotBench, color = bearCloud, title = "Bear Cloud")
fill(plotTrailBull, plotRailBull, color = bullRailCloud, title = "Bull Rail Cloud")
fill(plotTrailBear, plotRailBear, color = bearRailCloud, title = "Bear Rail Cloud")
fill(plotSupport, plotResistance, color = valueCloud, title = "Value Corridor")
fill(plotValueMid, plotBench, color = color.new(accelTone, 95), title = "Benchmark Pressure")

barcolor(showCandleTint ? color.new(trendTone, candleTransparency) : na)
bgcolor(showClouds ? color.new(trendTone, trailState == 1 ? 96 : 97) : na)

plotshape(showSignals and bullishFlip, "Bullish Flip Signal", shape.triangleup, location.belowbar, color.new(bullTone, 0), size = size.small, text = "LONG", textcolor = textTone)
plotshape(showSignals and bearishFlip, "Bearish Flip Signal", shape.triangledown, location.abovebar, color.new(bearTone, 0), size = size.small, text = "SHORT", textcolor = textTone)
plotshape(showSignals and reclaimBull, "Bull Reclaim", shape.circle, location.belowbar, color.new(accelTone, 0), size = size.tiny)
plotshape(showSignals and reclaimBear, "Bear Reclaim", shape.circle, location.abovebar, color.new(accelTone, 0), size = size.tiny)
plotshape(showSignals and continuationBull, "Bull Continuation", shape.diamond, location.abovebar, color.new(bullTone, 0), size = size.tiny)
plotshape(showSignals and continuationBear, "Bear Continuation", shape.diamond, location.belowbar, color.new(bearTone, 0), size = size.tiny)

//====================================================================================
// Dashboard
//====================================================================================
var table dash = table.new(position.top_right, 2, 6, frame_color = panelLine, border_color = panelLine, border_width = 1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Sentinel Trailing Bench", text_color = textTone, bgcolor = color.new(trendTone, 88), text_size = size.normal)
    table.cell(dash, 1, 0, trailState == 1 ? "LONG" : "SHORT", text_color = trendTone, bgcolor = color.new(trendTone, 92), text_size = size.normal)

    f_dashRow(dash, 1, "Trend", trendText, trendTone, color.new(trendTone, 86))
    f_dashRow(dash, 2, "Regime", regimeText + " / " + densityText, noiseScore > 0.65 ? accelTone : benchTone, color.new(accelTone, 92))
    f_dashRow(dash, 3, "Value", valueText + " / " + spreadText, close >= valueCenter ? bullTone : bearTone, color.new(color.from_gradient(close >= valueCenter ? 1 : -1, -1, 1, bearTone, bullTone), 92))
    f_dashRow(dash, 4, "Stop Gap", gapText + " | " + railText, trendTone, recoveryTone)
    f_dashRow(dash, 5, "Recovery / Thrust", recoveryText + " / " + str.tostring(thrustScore, "#.00"), recoveryNow ? accelTone : mutedTone, color.new(accelTone, 94))
else if barstate.islast and not showDashboard
    table.cell(dash, 0, 0, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 0, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 0, 1, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 1, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 0, 2, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 2, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 0, 3, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 3, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 0, 4, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 4, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 0, 5, "", bgcolor = color.new(panelTone, 100))
    table.cell(dash, 1, 5, "", bgcolor = color.new(panelTone, 100))

//====================================================================================
// Alerts
//====================================================================================
alertcondition(bullishFlip, "Sentinel Bullish Flip", "Sentinel Trailing Bench confirmed a bullish regime flip.")
alertcondition(bearishFlip, "Sentinel Bearish Flip", "Sentinel Trailing Bench confirmed a bearish regime flip.")
````
