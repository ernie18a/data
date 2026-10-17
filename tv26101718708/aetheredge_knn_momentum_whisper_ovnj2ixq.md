# AetherEdge KNN Momentum Whisper

- url: https://www.tradingview.com/script/Ovnj2IxQ/
- type: indicator
- pine_id: PUB;a4fe1ecb8eaf4abab03ddbf628899e1b
- version: 1.0

## Description

🖊️ Overview
AetherEdge KNN Momentum Whisper is a next-generation momentum forecasting engine powered by the K-Nearest Neighbors algorithm. It builds a rolling library of up to 300 historical market patterns, instantly retrieves the K most similar precedents to the current setup, and computes a distance-weighted forecast of next-bar momentum. The result is delivered through a single, elegant histogram whose color intensity simultaneously encodes direction, magnitude, and consensus confidence.

🔶 Key Features

True KNN pattern-matching engine with rolling historical dictionary
3D feature vectors: returns, normalized RSI, ATR Z-score
Variable pattern length (3–10 bars) for tunable temporal context
Inverse-distance weighted prediction — closer matches dominate
Consensus confidence scoring measuring directional agreement among neighbors
Dynamic color intensity driven by strength × confidence
Ultra-clean single histogram visualization — direction, power, and conviction in one bar
Four smart alerts for strong signals and directional flips
🧠 Technical Architecture

1. Feature Extraction Layer (Multi-dimensional Pattern Vector)

Return: single-bar percent change
RSI Normalized: scaled to -1..+1 (×2 amplified)
ATR Z-Score: 50-bar standardized volatility
These are concatenated across patternLen bars to form vectors up to 30 dimensions.

2. Pattern Library Layer (Rolling Dictionary)
Every bar appends a (past pattern, realized future return) pair to the library. Once historySize is exceeded, oldest entries are automatically pruned — always keeping the freshest learning corpus.

3. KNN Search Layer
Computes Euclidean distances from the current pattern to every library entry, then performs selection-based extraction of the K nearest neighbors. Their future-return labels are blended via 1/(d+ε) weighting to produce the momentum forecast.

4. Confidence Scoring Layer
Counts how many of the K neighbors agree on direction (bullish vs bearish). The dominant ratio becomes the confidence score (0–1).

5. Dynamic Visualization Layer
The forecast is ATR-normalized; strength = |normalized forecast| × confidence. Transparency is interpolated between minAlpha and maxAlpha — strong signals appear bold, weak signals fade.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults

BTC (1H–4H): History 300, K=8, Pattern 5, Forecast 1
ETH (30m–2H): History 300, K=8, Pattern 5, Forecast 1
SOL (15m–1H): History 250, K=10, Pattern 4, Forecast 1
XRP (1H–4H): History 350, K=8, Pattern 6, Forecast 2
Parameter Tuning

History Size: larger = more statistical stability (300 is the sweet spot)
K (Neighbors): 3–5 = reactive, 10–15 = stable
Pattern Length: 3–4 for short-term reversals, 6–8 for trend continuation
Forecast Horizon: 1–2 highest accuracy; 3+ adds noise
Features: Return + ATR for trends, prioritize RSI in ranges
💡 How to Use in Practice

Scenario 1 — Bold-Bar Entries
Vivid (low-transparency) bars indicate high strength × high confidence — historical neighbors overwhelmingly agree. Premium signals for trend-following entries.

Scenario 2 — Histogram Flip Detection
Zero-line crossover is the earliest "whisper" of momentum reversal. Use it as exit signal in trend-following or entry in mean-reversion strategies.

Scenario 3 — Faded Bars = Caution
Highly transparent bars indicate disagreement among neighbors — the market is in unfamiliar territory. Stand aside.

Multi-Timeframe Workflow
Confirm macro direction on 4H KNN → identify setup on 1H → time entries on 15m. Pairs powerfully with S/R and regime-detection tools.

⚠️ Important Notes

Forecasts activate only after historySize + patternLen bars are accumulated
Pattern library resets on chart reload
Computationally heavy — reduce historySize to 200 on low-spec setups
Sudden regime shifts may render past patterns less informative
🚨 Disclaimer
This indicator is provided for educational and analytical purposes only and does not constitute financial advice. All trading decisions remain your sole responsibility. Past performance does not guarantee future results, and crypto markets carry substantial risk.

## Source Code

````pine
//@version=5
indicator("AetherEdge KNN Momentum Whisper", shorttitle="AE-KNN-Whisper", overlay=false, precision=4)

// ============================================================
// ▼ INPUTS
// ============================================================
grpKNN      = "🔍 KNN Engine"
historySize = input.int(300, "Pattern Library Size",   minval=100, maxval=500, group=grpKNN, tooltip="過去パターン保存数")
kNeighbors  = input.int(8,   "K (Neighbors)",          minval=3,   maxval=20,  group=grpKNN, tooltip="参照する近傍数")
patternLen  = input.int(5,   "Pattern Length",         minval=3,   maxval=10,  group=grpKNN, tooltip="比較パターンのバー数")
forecastBar = input.int(1,   "Forecast Horizon",       minval=1,   maxval=5,   group=grpKNN, tooltip="何バー先のモメンタムを予測")

grpFeat     = "📐 Features"
useReturn   = input.bool(true, "Use Return Pattern",   group=grpFeat)
useRSI      = input.bool(true, "Use RSI Pattern",      group=grpFeat)
useATR      = input.bool(true, "Use Volatility Pattern",group=grpFeat)

grpVis      = "🎨 Visual"
colBull     = input.color(color.green, "Bullish Color", group=grpVis)
colBear     = input.color(color.red,   "Bearish Color", group=grpVis)
maxAlpha    = input.int(0,   "Max Opacity (strong)",   minval=0,   maxval=50,  group=grpVis, tooltip="強い予測時の透明度（小さいほど濃い）")
minAlpha    = input.int(75,  "Min Opacity (weak)",     minval=50,  maxval=95,  group=grpVis, tooltip="弱い予測時の透明度（大きいほど薄い）")

// ============================================================
// ▼ FEATURE EXTRACTION
// ============================================================
ret    = (close - close[1]) / close[1] * 100
rsiVal = ta.rsi(close, 14)
rsiNorm = (rsiVal - 50) / 50           // -1..+1
atrVal = ta.atr(14)
atrPct = atrVal / close * 100
atrMA  = ta.sma(atrPct, 50)
atrSD  = ta.stdev(atrPct, 50)
atrZ   = atrSD > 0 ? (atrPct - atrMA) / atrSD : 0.0

// Build current pattern vector (concatenated features over patternLen bars)
buildPattern(int offset) =>
    arr = array.new<float>(0)
    for i = 0 to patternLen - 1
        idx = offset + i
        if useReturn
            array.push(arr, nz(ret[idx]))
        if useRSI
            array.push(arr, nz(rsiNorm[idx]) * 2.0)  // scale up
        if useATR
            array.push(arr, nz(atrZ[idx]))
    arr

// ============================================================
// ▼ PATTERN LIBRARY (rolling window)
// ============================================================
// Each library entry: pattern vector + future return label
var array<float> libPatterns = array.new<float>(0)  // flattened
var array<float> libLabels   = array.new<float>(0)
var int featDim = 0

// Compute feature dimension once
if barstate.isfirst
    fd = 0
    if useReturn
        fd += 1
    if useRSI
        fd += 1
    if useATR
        fd += 1
    featDim := fd * patternLen

// Add to library (with forecastBar offset so we know the future outcome)
if bar_index > patternLen + forecastBar + 50 and featDim > 0
    pastPattern = buildPattern(forecastBar)            // pattern that ended forecastBar ago
    futureRet   = (close - close[forecastBar]) / close[forecastBar] * 100  // realized "future" return for that pattern
    
    // Append pattern features
    for i = 0 to array.size(pastPattern) - 1
        array.push(libPatterns, array.get(pastPattern, i))
    array.push(libLabels, futureRet)
    
    // Trim library if exceeds size
    if array.size(libLabels) > historySize
        array.shift(libLabels)
        for i = 0 to featDim - 1
            array.shift(libPatterns)

// ============================================================
// ▼ KNN SEARCH
// ============================================================
var float predMomentum = 0.0
var float predConfidence = 0.0

if array.size(libLabels) >= kNeighbors and featDim > 0
    currPattern = buildPattern(0)
    libCount    = array.size(libLabels)
    
    // Compute distances to all library patterns
    distances = array.new<float>(libCount, 0.0)
    for i = 0 to libCount - 1
        dSum = 0.0
        baseIdx = i * featDim
        for j = 0 to featDim - 1
            diff = array.get(currPattern, j) - array.get(libPatterns, baseIdx + j)
            dSum += diff * diff
        array.set(distances, i, math.sqrt(dSum))
    
    // Find K nearest (selection-based, lightweight)
    nearestLabels = array.new<float>(0)
    nearestDists  = array.new<float>(0)
    distsCopy     = array.copy(distances)
    
    for n = 0 to kNeighbors - 1
        minVal = 1e10
        minIdx = -1
        for i = 0 to libCount - 1
            v = array.get(distsCopy, i)
            if v < minVal
                minVal := v
                minIdx := i
        if minIdx >= 0
            array.push(nearestLabels, array.get(libLabels, minIdx))
            array.push(nearestDists, minVal)
            array.set(distsCopy, minIdx, 1e10)  // mark used
    
    // Weighted average (inverse distance) → predicted momentum
    weightSum = 0.0
    valueSum  = 0.0
    agreeBull = 0
    agreeBear = 0
    
    for n = 0 to array.size(nearestLabels) - 1
        d = array.get(nearestDists, n)
        l = array.get(nearestLabels, n)
        w = 1.0 / (d + 0.01)
        weightSum += w
        valueSum  += w * l
        if l > 0
            agreeBull += 1
        else if l < 0
            agreeBear += 1
    
    predMomentum := weightSum > 0 ? valueSum / weightSum : 0.0
    
    // Confidence: agreement ratio among K neighbors
    maxAgree = math.max(agreeBull, agreeBear)
    predConfidence := maxAgree / kNeighbors  // 0..1

// ============================================================
// ▼ NORMALIZE PREDICTION FOR PLOTTING
// ============================================================
// Normalize momentum by recent volatility for stable scale
volRef = ta.atr(14) / close * 100
normMomentum = volRef > 0 ? predMomentum / (volRef * 1.5) : 0.0
normMomentum := math.max(-1.5, math.min(1.5, normMomentum))

// Strength = combination of magnitude × confidence
strength = math.min(1.0, math.abs(normMomentum)) * predConfidence

// ============================================================
// ▼ DYNAMIC COLOR (intensity by strength)
// ============================================================
// Map strength (0..1) to transparency (minAlpha..maxAlpha)
alpha = minAlpha - int((minAlpha - maxAlpha) * strength)
alpha := math.max(maxAlpha, math.min(minAlpha, alpha))

barCol = normMomentum >= 0 ? color.new(colBull, alpha) : color.new(colBear, alpha)

// ============================================================
// ▼ PLOT — SINGLE HISTOGRAM ONLY
// ============================================================
plot(normMomentum, title="KNN Momentum Forecast", color=barCol, style=plot.style_columns, linewidth=4)

// Zero line (subtle reference, optional — removable if you want pure mono-display)
hline(0, "", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// ============================================================
// ▼ ALERTS
// ============================================================
strongBull = normMomentum > 0 and strength > 0.6 and ta.crossover(strength, 0.6)
strongBear = normMomentum < 0 and strength > 0.6 and ta.crossover(strength, 0.6)

alertcondition(strongBull, title="KNN Strong Bullish Whisper", message="AE-KNN: Strong bullish momentum predicted")
alertcondition(strongBear, title="KNN Strong Bearish Whisper", message="AE-KNN: Strong bearish momentum predicted")
alertcondition(ta.crossover(normMomentum, 0),  title="KNN Flip Bull", message="AE-KNN: Momentum flipped bullish")
alertcondition(ta.crossunder(normMomentum, 0), title="KNN Flip Bear", message="AE-KNN: Momentum flipped bearish")
````
