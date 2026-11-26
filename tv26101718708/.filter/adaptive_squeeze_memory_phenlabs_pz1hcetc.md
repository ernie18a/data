# Adaptive Squeeze Memory [PhenLabs]

- url: https://www.tradingview.com/script/pz1hcetC-Adaptive-Squeeze-Memory-PhenLabs/
- type: indicator
- pine_id: PUB;204f3c6278a7491286144b4fb1836482
- version: 1.0

## Description

[b]🚀 #66 Adaptive Squeeze Memory [PhenLabs][/b]

https://www.tradingview.com/x/KE4O1WfA/

[b]📌 Overview[/b]
Adaptive Squeeze Memory turns a standard public-domain BB/KC squeeze into a clear “what happened after similar squeezes?” dashboard. Instead of forcing traders to decode a complex probability model, ASM gives a simple setup read first: Long Breakout Watch, Short Breakdown Watch, Lean Long, Lean Short, Two-Way Volatility, or Building Memory.

Behind that simple read, ASM compares the current squeeze event against prior confirmed squeezes with similar volatility, RSI, and volume conditions, then projects the historical distribution of forward returns as a cone.

This is an original public-concept interpretation built from standard market primitives: Bollinger Band width, Keltner Channel width, ATR, RSI, volume ratio, Euclidean similarity scoring, and nearest-rank percentiles. It does not copy, clone, reproduce, deobfuscate, or attempt to recreate any commercial squeeze, memory, or prediction product.

[b]📊 What Makes It Different[/b]
Most squeeze tools answer one question: “Is price compressed?” Adaptive Squeeze Memory asks a sharper and more tradable question: “When the market has compressed like this before, did the forward memory favor an upside breakout, a downside breakdown, or volatility expansion without a clean directional edge?”

The result is a cleaner TradingView experience: a plain-English memory dashboard for fast interpretation, plus a projected return cone for traders who want the deeper statistical context.

[b]🚀 Core Features[/b]
✅ Public-domain BB/KC squeeze detection using Bollinger Band width versus Keltner Channel width
✅ Similarity memory engine using normalized ATR, RSI, and volume ratio
✅ Configurable nearest-match count for comparing the current squeeze against prior events
✅ 1-bar, 3-bar, 5-bar, and 10-bar forward return distributions
✅ Median projection plus optional 25th/75th and 10th/90th percentile bands
✅ Memory Dashboard with setup state, median edge, likely range, bullish probability, score, matches, and next-step guidance
✅ Memory Bias Score from -100 to +100 for fast data-window scanning
✅ Long Breakout Watch and Short Breakdown Watch markers for stronger memory skews
✅ Confirmed-bar only logic with no request.security() and no lookahead
✅ Capped projection-line arrays for stable long-chart performance

[b]🔧 Settings[/b]
[b]Squeeze Memory Lookback[/b]
Default: 252
Range: 50–2000
Description: Maximum number of mature prior squeeze events retained for similarity matching.

[b]Similarity Match Count[/b]
Default: 10
Range: 3–50
Description: Number of closest historical squeeze events used to build the probability cone.

[b]Cone Projection Bars[/b]
Default: 10
Range: 10–50
Description: Forward visual projection window. The statistical anchors are 1, 3, 5, and 10 bars.

[b]BB Length / BB Multiplier[/b]
Default: 20 / 2.0
Range: Length 5–200, Multiplier 0.5–5.0
Description: Bollinger Band settings used to measure compression.

[b]KC Length / KC Multiplier[/b]
Default: 20 / 1.5
Range: Length 5–200, Multiplier 0.5–5.0
Description: Keltner Channel settings used as the volatility envelope comparison.

[b]ATR Length[/b]
Default: 14
Range: 2–200
Description: ATR input for the normalized volatility feature.

[b]RSI Length[/b]
Default: 14
Range: 2–200
Description: RSI input for the momentum-position feature.

[b]Volume MA Length[/b]
Default: 50
Range: 5–300
Description: Moving average baseline for the relative volume feature.

[b]Similarity Weight: ATR / RSI / Volume[/b]
Default: 1.0 / 1.0 / 1.0
Range: 0.0–5.0
Description: Controls how strongly each feature influences the Euclidean distance score.

[b]Bull Cone Color / Bear Cone Color[/b]
Default: Lime / Red
Range: Any TradingView color
Description: Sets the projection color based on whether the 10-bar median return is positive or negative.

[b]Show Percentile Bands[/b]
Default: On
Range: On/Off
Description: Toggles the inner 25th/75th percentile and outer 10th/90th percentile cone paths.

[b]Show Memory Dashboard[/b]
Default: On
Range: On/Off
Description: Displays the simplified readout so users do not need to interpret the full cone manually.

[b]Median Edge Threshold %[/b]
Default: 0.20
Range: 0.05–5.0
Description: Minimum median 10-bar edge required before ASM can classify a strong directional watch.

[b]Directional Probability Threshold %[/b]
Default: 55
Range: 50–80
Description: Minimum matched-outcome probability required before ASM classifies a strong long or short watch.

[b]🔥 How It Works[/b]
1. Detect compression
   • ASM compares Bollinger Band width against Keltner Channel width.
   • A squeeze event fires only when compression begins on a confirmed bar.

2. Capture the squeeze fingerprint
   • Each confirmed squeeze stores normalized ATR, RSI, and relative volume.
   • Events are stored in flat parallel arrays for Pine v6 compatibility.

3. Let history mature naturally
   • Forward returns are filled only after the 1st, 3rd, 5th, and 10th future bars have actually printed.
   • No future data is read early, and no request.security() calls are used.

4. Match the current event to memory
   • The current squeeze is compared against mature prior squeezes.
   • Weighted Euclidean distance ranks the most similar historical events.
   • The closest N matches form the statistical sample.

5. Convert the distribution into a simple read
   • Long Breakout Watch appears when the median edge and bullish outcome probability both clear their thresholds.
   • Short Breakdown Watch appears when the median edge and bearish outcome probability both clear their thresholds.
   • Lean Long and Lean Short appear when the sample has directional skew but not enough strength for a full watch.
   • Two-Way Volatility appears when the historical memory favors expansion but not a clean direction.

6. Project the probability cone
   • ASM computes nearest-rank percentiles of the matched forward returns.
   • Median, 25th/75th, and 10th/90th percentile paths are drawn forward from the current squeeze bar.

[b]🎨 Visual Guide[/b]
• Solid path: median projected forward return
• Dashed paths: 25th and 75th percentile range
• Dotted paths: 10th and 90th percentile range
• Column plot: latest 10-bar median memory edge
• Dashboard: plain-English setup state, range, bullish probability, score, matches, and next-step guidance
• LONG / SHORT markers: stronger confirmed directional memory events
• Yellow marker: confirmed squeeze-memory event

[b]📖 Best Used For[/b]
Adaptive Squeeze Memory is designed for traders who want context around volatility compression. It is especially useful for crypto, indices, liquid equities, and FX pairs where squeeze events repeat often enough to build a meaningful memory sample.

[b]✅ Notes[/b]
• Pine Script v6 indicator
• Separate pane output
• Confirmed-bar only
• No external data
• No request.security()
• No lookahead
• No commercial/proprietary logic

[quote][b]⚠️ Limitations[/b]
ASM is a statistical context tool, not a prediction engine. Percentile cones summarize what similar prior squeezes did; they do not guarantee what the current squeeze will do. Early charts or rare symbols may have too few mature matches for a useful cone until enough events accumulate.[/quote]

## Source Code

````pine
// Copyright 2026 PhenLabs
// Author: PhenLabs
//@version=6
indicator("Adaptive Squeeze Memory [PhenLabs]", shorttitle="ASM #66", overlay=false, max_lines_count=500, max_labels_count=50)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
squeezeLookback = input.int(252, "Squeeze Memory Lookback", minval=50, maxval=2000)
matchCountInput = input.int(10, "Similarity Match Count", minval=3, maxval=50)
coneBars = input.int(10, "Cone Projection Bars", minval=10, maxval=50)
bbLen = input.int(20, "BB Length", minval=5, maxval=200)
bbMult = input.float(2.0, "BB Multiplier", minval=0.5, maxval=5.0, step=0.1)
kcLen = input.int(20, "KC Length", minval=5, maxval=200)
kcMult = input.float(1.5, "KC Multiplier", minval=0.5, maxval=5.0, step=0.1)
atrLen = input.int(14, "ATR Length", minval=2, maxval=200)
rsiLen = input.int(14, "RSI Length", minval=2, maxval=200)
volMaLen = input.int(50, "Volume MA Length", minval=5, maxval=300)
atrWeight = input.float(1.0, "Similarity Weight: ATR", minval=0.0, maxval=5.0, step=0.1)
rsiWeight = input.float(1.0, "Similarity Weight: RSI", minval=0.0, maxval=5.0, step=0.1)
volWeight = input.float(1.0, "Similarity Weight: Volume", minval=0.0, maxval=5.0, step=0.1)
bullConeColor = input.color(color.new(color.lime, 0), "Bull Cone Color")
bearConeColor = input.color(color.new(color.red, 0), "Bear Cone Color")
showInnerBand = input.bool(true, "Show 25th/75th Percentile Band")
showOuterBand = input.bool(true, "Show 10th/90th Percentile Band")
showMedianPath = input.bool(true, "Show Median Projection")
showDashboard = input.bool(true, "Show Memory Dashboard")
biasThreshold = input.float(0.20, "Median Edge Threshold %", minval=0.05, maxval=5.0, step=0.05)
probThreshold = input.float(55.0, "Directional Probability Threshold %", minval=50.0, maxval=80.0, step=1.0)
maxConeLines = input.int(160, "Max Cone Lines", minval=20, maxval=480)

// ─────────────────────────────────────────────────────────────────────────────
// Public-domain BB/KC squeeze state
// ─────────────────────────────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidth = math.abs(bbBasis) > 0.0 ? (bbUpper - bbLower) / math.abs(bbBasis) : na

kcMid = ta.ema(hlc3, kcLen)
atr = ta.atr(atrLen)
kcUpper = kcMid + atr * kcMult
kcLower = kcMid - atr * kcMult
kcWidth = math.abs(kcMid) > 0.0 ? (kcUpper - kcLower) / math.abs(kcMid) : na

squeezeActive = not na(bbWidth) and not na(kcWidth) and bbWidth < kcWidth
squeezeWasActive = squeezeActive[1] == true
warmupReady = bar_index > math.max(math.max(bbLen, kcLen), math.max(atrLen, math.max(rsiLen, volMaLen))) + 10
squeezeFired = barstate.isconfirmed and warmupReady and squeezeActive and not squeezeWasActive

// ─────────────────────────────────────────────────────────────────────────────
// Feature vector: normalized ATR, RSI, and volume ratio
// ─────────────────────────────────────────────────────────────────────────────
rsiValue = ta.rsi(close, rsiLen)
volMa = ta.sma(volume, volMaLen)
atrFeature = close != 0.0 ? atr / math.abs(close) : na
rsiFeature = not na(rsiValue) ? rsiValue / 100.0 : na
volFeature = not na(volMa) and volMa > 0.0 ? volume / volMa : na
featuresReady = not na(atrFeature) and not na(rsiFeature) and not na(volFeature)

// ─────────────────────────────────────────────────────────────────────────────
// Parallel flat arrays. Pending squeeze events mature after 10 confirmed bars.
// ─────────────────────────────────────────────────────────────────────────────
var array<int> pendingIndex = array.new_int()
var array<float> pendingClose = array.new_float()
var array<float> pendingAtr = array.new_float()
var array<float> pendingRsi = array.new_float()
var array<float> pendingVol = array.new_float()
var array<float> pendingRet1 = array.new_float()
var array<float> pendingRet3 = array.new_float()
var array<float> pendingRet5 = array.new_float()
var array<float> pendingRet10 = array.new_float()
var array<bool> pendingDone = array.new_bool()

var array<int> histIndex = array.new_int()
var array<float> histAtr = array.new_float()
var array<float> histRsi = array.new_float()
var array<float> histVol = array.new_float()
var array<float> histRet1 = array.new_float()
var array<float> histRet3 = array.new_float()
var array<float> histRet5 = array.new_float()
var array<float> histRet10 = array.new_float()
var array<line> coneLines = array.new_line()
var table dash = table.new(position.top_right, 2, 6, border_width=1)

f_percentile_nearest(src, pct) =>
    float out = na
    int n = array.size(src)
    if n > 0
        tmp = array.copy(src)
        array.sort(tmp, order.ascending)
        int rank = int(math.ceil((pct / 100.0) * n))
        int idx = int(math.max(0, math.min(n - 1, rank - 1)))
        out := array.get(tmp, idx)
    out

f_track_line(id) =>
    array.push(coneLines, id)
    if array.size(coneLines) > maxConeLines
        old = array.shift(coneLines)
        line.delete(old)

f_new_line(x1, y1, x2, y2, lineColor, lineWidth, lineStyle) =>
    id = line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth, style=lineStyle)
    f_track_line(id)

f_cap_history() =>
    while array.size(histIndex) > squeezeLookback
        array.shift(histIndex)
        array.shift(histAtr)
        array.shift(histRsi)
        array.shift(histVol)
        array.shift(histRet1)
        array.shift(histRet3)
        array.shift(histRet5)
        array.shift(histRet10)
    while array.size(pendingIndex) > squeezeLookback
        array.shift(pendingIndex)
        array.shift(pendingClose)
        array.shift(pendingAtr)
        array.shift(pendingRsi)
        array.shift(pendingVol)
        array.shift(pendingRet1)
        array.shift(pendingRet3)
        array.shift(pendingRet5)
        array.shift(pendingRet10)
        array.shift(pendingDone)

f_push_match(sortedDist, sortedIndex, dist, idx, maxMatches) =>
    int n = array.size(sortedDist)
    int insertAt = n
    if n > 0
        for j = 0 to n - 1
            if dist < array.get(sortedDist, j)
                insertAt := j
                break
    array.insert(sortedDist, insertAt, dist)
    array.insert(sortedIndex, insertAt, idx)
    if array.size(sortedDist) > maxMatches
        array.pop(sortedDist)
        array.pop(sortedIndex)

f_draw_path(y1, y3, y5, y10, lineColor, lineWidth, lineStyle) =>
    f_new_line(bar_index + 1, y1, bar_index + 3, y3, lineColor, lineWidth, lineStyle)
    f_new_line(bar_index + 3, y3, bar_index + 5, y5, lineColor, lineWidth, lineStyle)
    f_new_line(bar_index + 5, y5, bar_index + 10, y10, lineColor, lineWidth, lineStyle)

// Mature pending records as future returns become known. No lookahead is used:
// each return is filled only when the confirmed future bar has actually printed.
if barstate.isconfirmed and array.size(pendingIndex) > 0
    int pendingSize = array.size(pendingIndex)
    for k = 0 to pendingSize - 1
        bool done = array.get(pendingDone, k)
        int age = bar_index - array.get(pendingIndex, k)
        float entry = array.get(pendingClose, k)
        float realized = entry != 0.0 ? close / entry - 1.0 : na
        if not done and age == 1
            array.set(pendingRet1, k, realized)
        if not done and age == 3
            array.set(pendingRet3, k, realized)
        if not done and age == 5
            array.set(pendingRet5, k, realized)
        if not done and age == 10
            array.set(pendingRet10, k, realized)
            array.set(pendingDone, k, true)
            array.push(histIndex, array.get(pendingIndex, k))
            array.push(histAtr, array.get(pendingAtr, k))
            array.push(histRsi, array.get(pendingRsi, k))
            array.push(histVol, array.get(pendingVol, k))
            array.push(histRet1, array.get(pendingRet1, k))
            array.push(histRet3, array.get(pendingRet3, k))
            array.push(histRet5, array.get(pendingRet5, k))
            array.push(histRet10, array.get(pendingRet10, k))

f_cap_history()

var float latestMedian10Pct = na
var float latestUpper10Pct = na
var float latestLower10Pct = na
var float latestTailHigh10Pct = na
var float latestTailLow10Pct = na
var float latestMemoryScore = na
var float latestConfidence = na
var float latestBullProb = na
var int latestMatches = 0
var string latestState = "Building Memory"
var bool latestLongWatch = false
var bool latestShortWatch = false
var bool latestLeanLong = false
var bool latestLeanShort = false

if squeezeFired and featuresReady
    // Find the N nearest mature prior squeeze events by weighted Euclidean distance.
    sortedDist = array.new_float()
    sortedIndex = array.new_int()
    int histSize = array.size(histIndex)
    int maxMatches = math.min(matchCountInput, histSize)
    if histSize > 0
        for i = 0 to histSize - 1
            float da = (atrFeature - array.get(histAtr, i)) * atrWeight
            float dr = (rsiFeature - array.get(histRsi, i)) * rsiWeight
            float dv = (volFeature - array.get(histVol, i)) * volWeight
            float dist = math.sqrt(da * da + dr * dr + dv * dv)
            f_push_match(sortedDist, sortedIndex, dist, i, maxMatches)

    latestMatches := array.size(sortedIndex)
    if latestMatches >= 3
        r1 = array.new_float()
        r3 = array.new_float()
        r5 = array.new_float()
        r10 = array.new_float()
        for m = 0 to latestMatches - 1
            int h = array.get(sortedIndex, m)
            array.push(r1, array.get(histRet1, h) * 100.0)
            array.push(r3, array.get(histRet3, h) * 100.0)
            array.push(r5, array.get(histRet5, h) * 100.0)
            array.push(r10, array.get(histRet10, h) * 100.0)

        float p10_1 = f_percentile_nearest(r1, 10.0)
        float p25_1 = f_percentile_nearest(r1, 25.0)
        float p50_1 = f_percentile_nearest(r1, 50.0)
        float p75_1 = f_percentile_nearest(r1, 75.0)
        float p90_1 = f_percentile_nearest(r1, 90.0)
        float p10_3 = f_percentile_nearest(r3, 10.0)
        float p25_3 = f_percentile_nearest(r3, 25.0)
        float p50_3 = f_percentile_nearest(r3, 50.0)
        float p75_3 = f_percentile_nearest(r3, 75.0)
        float p90_3 = f_percentile_nearest(r3, 90.0)
        float p10_5 = f_percentile_nearest(r5, 10.0)
        float p25_5 = f_percentile_nearest(r5, 25.0)
        float p50_5 = f_percentile_nearest(r5, 50.0)
        float p75_5 = f_percentile_nearest(r5, 75.0)
        float p90_5 = f_percentile_nearest(r5, 90.0)
        float p10_10 = f_percentile_nearest(r10, 10.0)
        float p25_10 = f_percentile_nearest(r10, 25.0)
        float p50_10 = f_percentile_nearest(r10, 50.0)
        float p75_10 = f_percentile_nearest(r10, 75.0)
        float p90_10 = f_percentile_nearest(r10, 90.0)

        latestMedian10Pct := p50_10
        latestUpper10Pct := p75_10
        latestLower10Pct := p25_10
        latestTailHigh10Pct := p90_10
        latestTailLow10Pct := p10_10
        float iqr = math.max(math.abs(p75_10 - p25_10), 0.01)
        float rawScore = p50_10 / iqr * 50.0
        latestMemoryScore := math.max(-100.0, math.min(100.0, rawScore))
        latestConfidence := math.min(100.0, latestMatches / math.max(matchCountInput, 1) * 100.0)
        int bullCount = 0
        if array.size(r10) > 0
            for b = 0 to array.size(r10) - 1
                bullCount += array.get(r10, b) > 0.0 ? 1 : 0
        latestBullProb := latestMatches > 0 ? bullCount / latestMatches * 100.0 : na
        bool strongBull = p50_10 > biasThreshold and latestBullProb >= probThreshold
        bool strongBear = p50_10 < -biasThreshold and latestBullProb <= 100.0 - probThreshold
        bool softBull = p50_10 > 0.0 or latestBullProb >= probThreshold
        bool softBear = p50_10 < 0.0 or latestBullProb <= 100.0 - probThreshold
        latestLongWatch := strongBull
        latestShortWatch := strongBear
        latestLeanLong := not strongBull and softBull and not strongBear
        latestLeanShort := not strongBear and softBear and not strongBull and not latestLeanLong
        latestState := strongBull ? "Long Breakout Watch" : strongBear ? "Short Breakdown Watch" : latestLeanLong ? "Lean Long" : latestLeanShort ? "Lean Short" : "Two-Way Volatility"
        color coneColor = p50_10 >= 0.0 ? bullConeColor : bearConeColor
        color innerColor = color.new(coneColor, 35)
        color outerColor = color.new(coneColor, 65)

        if showOuterBand
            f_draw_path(p90_1, p90_3, p90_5, p90_10, outerColor, 1, line.style_dotted)
            f_draw_path(p10_1, p10_3, p10_5, p10_10, outerColor, 1, line.style_dotted)
        if showInnerBand
            f_draw_path(p75_1, p75_3, p75_5, p75_10, innerColor, 2, line.style_dashed)
            f_draw_path(p25_1, p25_3, p25_5, p25_10, innerColor, 2, line.style_dashed)
        if showMedianPath
            f_draw_path(p50_1, p50_3, p50_5, p50_10, coneColor, 3, line.style_solid)

    // Add the current event to pending memory only after matching against prior events.
    array.push(pendingIndex, bar_index)
    array.push(pendingClose, close)
    array.push(pendingAtr, atrFeature)
    array.push(pendingRsi, rsiFeature)
    array.push(pendingVol, volFeature)
    array.push(pendingRet1, na)
    array.push(pendingRet3, na)
    array.push(pendingRet5, na)
    array.push(pendingRet10, na)
    array.push(pendingDone, false)

// ─────────────────────────────────────────────────────────────────────────────
// Pane output
// ─────────────────────────────────────────────────────────────────────────────
scoreColor = latestLongWatch or latestLeanLong ? color.new(bullConeColor, 0) : latestShortWatch or latestLeanShort ? color.new(bearConeColor, 0) : color.new(color.gray, 20)
plot(0.0, "Zero Line", color=color.new(color.gray, 70))
plot(latestMedian10Pct, "Median 10-Bar Memory Edge %", color=scoreColor, linewidth=3, style=plot.style_columns)
plot(latestUpper10Pct, "Likely Range High: 75th %", color=color.new(color.lime, 55), linewidth=1)
plot(latestLower10Pct, "Likely Range Low: 25th %", color=color.new(color.red, 55), linewidth=1)
plot(latestTailHigh10Pct, "Stretch Range High: 90th %", color=color.new(color.lime, 78), linewidth=1)
plot(latestTailLow10Pct, "Stretch Range Low: 10th %", color=color.new(color.red, 78), linewidth=1)
plot(latestMemoryScore, "Memory Bias Score (-100 to +100)", color=scoreColor, display=display.data_window)
plot(latestBullProb, "Bullish Outcome Probability %", color=color.new(color.aqua, 0), display=display.data_window)
plot(latestConfidence, "Match Confidence %", color=color.new(color.yellow, 0), display=display.data_window)
plot(float(latestMatches), "Matched Prior Squeezes", color=color.new(color.aqua, 35), display=display.data_window)

plotshape(squeezeFired, title="Confirmed Squeeze Memory Event", style=shape.circle, location=location.bottom, color=color.new(color.yellow, 0), size=size.tiny, text="ASM")
plotshape(squeezeFired and latestLongWatch, title="ASM Long Breakout Watch", style=shape.triangleup, location=location.bottom, color=color.new(bullConeColor, 0), size=size.small, text="LONG")
plotshape(squeezeFired and latestShortWatch, title="ASM Short Breakdown Watch", style=shape.triangledown, location=location.top, color=color.new(bearConeColor, 0), size=size.small, text="SHORT")

if barstate.islast and showDashboard
    color stateBg = latestLongWatch or latestLeanLong ? color.new(bullConeColor, 72) : latestShortWatch or latestLeanShort ? color.new(bearConeColor, 72) : color.new(color.gray, 78)
    table.cell(dash, 0, 0, "ASM Read", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, latestState, text_color=color.white, bgcolor=stateBg)
    table.cell(dash, 0, 1, "Median Edge", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(dash, 1, 1, na(latestMedian10Pct) ? "Waiting" : str.tostring(latestMedian10Pct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(dash, 0, 2, "Likely Range", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(dash, 1, 2, na(latestLower10Pct) or na(latestUpper10Pct) ? "Waiting" : str.tostring(latestLower10Pct, "#.##") + "% to " + str.tostring(latestUpper10Pct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(dash, 0, 3, "Memory Score", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(dash, 1, 3, na(latestMemoryScore) ? "Waiting" : str.tostring(latestMemoryScore, "#") + " / 100", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(dash, 0, 4, "Bull Prob / Matches", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(dash, 1, 4, (na(latestBullProb) ? "Waiting" : str.tostring(latestBullProb, "#") + "%") + " / " + str.tostring(latestMatches), text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(dash, 0, 5, "Next Step", text_color=color.white, bgcolor=color.new(color.black, 65))
    table.cell(dash, 1, 5, latestLongWatch ? "Plan upside trigger" : latestShortWatch ? "Plan downside trigger" : latestLeanLong ? "Upside bias only" : latestLeanShort ? "Downside bias only" : "Trade expansion, not direction", text_color=color.white, bgcolor=stateBg)

alertcondition(squeezeFired, title="ASM Squeeze Memory Event", message="Adaptive Squeeze Memory: confirmed squeeze event fired. Review projected probability cone.")
alertcondition(squeezeFired and latestLongWatch, title="ASM Long Breakout Watch", message="Adaptive Squeeze Memory: long breakout watch fired on confirmed squeeze memory.")
alertcondition(squeezeFired and latestShortWatch, title="ASM Short Breakdown Watch", message="Adaptive Squeeze Memory: short breakdown watch fired on confirmed squeeze memory.")
````
