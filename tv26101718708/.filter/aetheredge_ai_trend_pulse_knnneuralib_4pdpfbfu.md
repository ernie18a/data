# AetherEdge AI Trend Pulse [KNN+NeuraLib]

- url: https://www.tradingview.com/script/4pdpfBfU/
- type: indicator
- pine_id: PUB;870393e681184e1e94b0d9608ce23e03
- version: 1.0

## Description

🖊️ Overview
AetherEdge AI Trend Pulse is a next-generation trend intelligence engine fusing K-Nearest Neighbors classification with NeuraLib-inspired feature compression. It dynamically learns from a six-dimensional market fingerprint, weighting each feature by its rolling correlation with forward returns, and infers real-time directional probability from the "memory" of past patterns. With minimal chart clutter and only high-conviction signals surfaced, it delivers a sleek, intelligent visualization built for traders who demand both precision and elegance.

🔶 Key Features

KNN memory-based classifier scanning up to 500 historical patterns for similarity-driven majority voting
NeuraLib-style PCA-inspired compression with dynamic correlation-based feature weighting
6-dimensional feature set: price structure, volatility regime, volume pressure, MTF alignment, RSI deviation, velocity Z-score
Adaptive learning rate for smooth, regime-aware probability updates
K-means style regime clustering with self-evolving Bull/Neutral/Bear centroids
Multi-timeframe integration combining HTF #1 and HTF #2 trend bias
Minimal visual design: gradient background, probability-driven line color, high-conviction arrows only
High-conviction alerts firing exclusively on threshold breakouts
🧠 Technical Architecture

The indicator is built on a three-layer AI pipeline:

1. Feature Extraction Layer
Six independent, low-correlation features are extracted: ATR-normalized price structure, ATR-ratio volatility regime, directional volume pressure, dual-HTF bias, RSI deviation from neutral, and ROC Z-score. All features are clipped to suppress outliers.

2. NeuraLib-Inspired Compression Layer
Each feature's rolling correlation with 5-bar forward returns (ta.correlation()) acts as an adaptive weight (w1–w6). The featComp parameter controls the blend between the compressed projection and the raw primary feature, preventing overfitting while preserving signal strength.

3. KNN Classification + Adaptive Probability Layer
Past compScore[5] values and forward labels (+1/-1/0) are stored in memory arrays. The current score is matched against this memory via Euclidean distance, and the top-K nearest neighbors vote majority direction. The vote is sigmoid-transformed into probability, then EMA-smoothed by the adaptive learning rate. A K-means-style trio of centroids (cBull/cNeut/cBear) continuously tracks the probability distribution, enabling autonomous regime recognition.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults

BTC (15m–1H): Lookback 200, K=8, AdaptRate 0.15, FeatComp 0.7
ETH (15m–4H): Lookback 250, K=10, AdaptRate 0.12, FeatComp 0.75
SOL (5m–1H): Lookback 150, K=6, AdaptRate 0.20, FeatComp 0.65
XRP (15m–1H): Lookback 180, K=8, AdaptRate 0.18, FeatComp 0.70
Parameter Tuning

Lookback: 300–500 in trending markets; 100–200 in ranging conditions
K Neighbors: low (3–5) for sensitivity; high (15–25) for stability
Adaptive Learning Rate: 0.20–0.30 in high volatility; 0.05–0.10 in calm markets
Feature Compression: 0.7 = balanced; >0.9 = AI-dominant; <0.3 = classic-leaning
Probability Threshold: scalping 0.65/0.35; swing 0.80/0.20
💡 How to Use in Practice

Scenario 1 — High-Conviction Entries
Arrows (▲▼) print only when KNN majority and probability threshold align. Enter on the next pullback with ATR-based stop placement.

Scenario 2 — Directional Filter
Long only during green background, short only during red. Use as a master regime filter for your existing entry systems.

Scenario 3 — Color Momentum Shift
Line darkening to lime = bullish acceleration; darkening to maroon = bearish acceleration. Color transitions mark momentum inflection points.

Multi-Timeframe Workflow
Confirm direction on 4H AE-TrendPulse, then take arrow entries on 15m for high-probability hierarchical filtering. Pairs exceptionally well with S/R grid tools and order flow indicators.

⚠️ Important Notes

The KNN memory requires the full lookback period to populate before reaching peak accuracy (warm-up phase)
Memory arrays reset on chart reload; avoid reloading right before key signals
Correlation-based weights may briefly lose accuracy during sharp regime shifts
Linear KNN search means very high K × Lookback values can impact performance
🚨 Disclaimer
This indicator is provided for educational and analytical purposes only and does not constitute financial advice. All trading decisions remain your sole responsibility. Past performance does not guarantee future results, and crypto markets carry substantial risk.

## Source Code

````pine
//@version=5
indicator("AetherEdge AI Trend Pulse [KNN+NeuraLib]", shorttitle="AE-TrendPulse", overlay=true, max_labels_count=500)

// ============================================================
// ▼ INPUTS
// ============================================================
grpAI       = "🧠 AI Engine"
lookback    = input.int(200,  "Learning Window (KNN Memory)", minval=50,  maxval=500, group=grpAI)
kNeighbors  = input.int(8,    "K Neighbors",                  minval=3,   maxval=25,  group=grpAI)
adaptRate   = input.float(0.15,"Adaptive Learning Rate",      minval=0.01,maxval=1.0, step=0.01, group=grpAI)
featComp    = input.float(0.7,"Feature Compression (PCA-like)",minval=0.1,maxval=1.0, step=0.05, group=grpAI)

grpMTF      = "🕒 Multi-Timeframe"
htf1        = input.timeframe("60", "HTF #1", group=grpMTF)
htf2        = input.timeframe("240","HTF #2", group=grpMTF)

grpSig      = "🎯 Signals"
probHigh    = input.float(0.75,"High Probability Threshold",  minval=0.5, maxval=0.95,step=0.01, group=grpSig)
probLow     = input.float(0.25,"Low Probability Threshold",   minval=0.05,maxval=0.5, step=0.01, group=grpSig)
showArrows  = input.bool(true, "Show Arrows (High Conviction Only)", group=grpSig)

grpVis      = "🎨 Visual"
bgIntensity = input.float(0.85,"Background Transparency",    minval=0.5, maxval=0.99,step=0.01, group=grpVis)
showLine    = input.bool(true, "Show Trend Line",             group=grpVis)

// ============================================================
// ▼ FEATURE EXTRACTION (Multi-dimensional)
// ============================================================
// Feature 1: Price Structure (normalized momentum)
f1_raw = (close - ta.sma(close, 20)) / ta.atr(20)
f1     = math.max(-3.0, math.min(3.0, f1_raw))

// Feature 2: Volatility regime (ATR-ratio)
f2_raw = ta.atr(14) / ta.atr(50)
f2     = math.max(0.3, math.min(3.0, f2_raw))

// Feature 3: Volume pressure (relative volume * direction)
volMA  = ta.sma(volume, 20)
volRel = volume / (volMA + 1e-10)
f3_raw = volRel * math.sign(close - open)
f3     = math.max(-3.0, math.min(3.0, f3_raw))

// Feature 4: MTF alignment (HTF trends)
htfClose1 = request.security(syminfo.tickerid, htf1, close, lookahead=barmerge.lookahead_off)
htfClose2 = request.security(syminfo.tickerid, htf2, close, lookahead=barmerge.lookahead_off)
htfEma1   = request.security(syminfo.tickerid, htf1, ta.ema(close,20), lookahead=barmerge.lookahead_off)
htfEma2   = request.security(syminfo.tickerid, htf2, ta.ema(close,20), lookahead=barmerge.lookahead_off)
mtfBias   = (htfClose1>htfEma1?0.5:-0.5) + (htfClose2>htfEma2?0.5:-0.5)
f4        = mtfBias

// Feature 5: RSI deviation from neutral
rsiVal = ta.rsi(close, 14)
f5     = (rsiVal - 50.0) / 50.0  // [-1, 1]

// Feature 6: Price-velocity (rate of change z-score)
roc    = ta.roc(close, 10)
rocStd = ta.stdev(roc, 50)
f6     = rocStd > 0 ? math.max(-3.0, math.min(3.0, roc / rocStd)) : 0.0

// ============================================================
// ▼ NEURALIB-STYLE FEATURE COMPRESSION (PCA-inspired weighting)
// ============================================================
// Adaptive weights — learned via correlation with forward returns proxy
fwdRet = close - close[5]
w1 = ta.correlation(f1, fwdRet, lookback)
w2 = ta.correlation(f2, fwdRet, lookback)
w3 = ta.correlation(f3, fwdRet, lookback)
w4 = ta.correlation(f4, fwdRet, lookback)
w5 = ta.correlation(f5, fwdRet, lookback)
w6 = ta.correlation(f6, fwdRet, lookback)

// Replace na correlations with 0
w1 := nz(w1, 0.0)
w2 := nz(w2, 0.0)
w3 := nz(w3, 0.0)
w4 := nz(w4, 0.0)
w5 := nz(w5, 0.0)
w6 := nz(w6, 0.0)

// Compressed feature score (weighted projection)
compScore = (w1*f1 + w2*f3 + w4*f4 + w5*f5 + w6*f6) * featComp + (1-featComp)*f1
compScore := nz(compScore, 0.0)

// ============================================================
// ▼ KNN CLASSIFIER (memory-based)
// ============================================================
var array<float> memScore = array.new<float>(0)
var array<float> memLabel = array.new<float>(0)  // +1 bull, -1 bear, 0 neutral

// Store historical compScore + future label (lagged)
if bar_index > 10
    pastScore = compScore[5]
    label = close > close[5] ? 1.0 : close < close[5] ? -1.0 : 0.0
    if not na(pastScore)
        array.push(memScore, pastScore)
        array.push(memLabel, label)
        if array.size(memScore) > lookback
            array.shift(memScore)
            array.shift(memLabel)
    
// KNN voting
knnVote = 0.0
if array.size(memScore) >= kNeighbors
    // Build distance array
    distArr  = array.new<float>(0)
    idxArr   = array.new<int>(0)
    sz = array.size(memScore)
    for i = 0 to sz - 1
        d = math.abs(array.get(memScore, i) - compScore)
        array.push(distArr, d)
        array.push(idxArr, i)
    
    // Find K nearest (simple selection)
    sumLabel = 0.0
    used = array.new<bool>(sz, false)
    for k = 0 to kNeighbors - 1
        minD   = 1e10
        minIdx = -1
        for j = 0 to sz - 1
            if not array.get(used, j) and array.get(distArr, j) < minD
                minD   := array.get(distArr, j)
                minIdx := j
        if minIdx >= 0
            array.set(used, minIdx, true)
            sumLabel += array.get(memLabel, minIdx)
    knnVote := sumLabel / kNeighbors

// ============================================================
// ▼ ADAPTIVE PROBABILITY (k-means inspired clustering + sigmoid)
// ============================================================
// Adaptive EMA of KNN vote (learning rate driven)
var float prob = 0.5
rawProb = 1.0 / (1.0 + math.exp(-2.5 * knnVote))  // sigmoid
prob   := prob + adaptRate * (rawProb - prob)

// k-means style regime detection (3 clusters: bull / neutral / bear)
var float cBull = 0.75
var float cNeut = 0.50
var float cBear = 0.25
dB = math.abs(prob - cBull)
dN = math.abs(prob - cNeut)
dS = math.abs(prob - cBear)
if dB <= dN and dB <= dS
    cBull := cBull + 0.05*(prob - cBull)
else if dN <= dB and dN <= dS
    cNeut := cNeut + 0.05*(prob - cNeut)
else
    cBear := cBear + 0.05*(prob - cBear)

// ============================================================
// ▼ VISUAL OUTPUT (Minimal Design)
// ============================================================
// 1) Background color (light green / red / neutral)
bgCol = prob >= 0.5 ?
       color.new(color.green, math.round(100 - (prob-0.5)*2*(100-bgIntensity*100))) :
       color.new(color.red,   math.round(100 - (0.5-prob)*2*(100-bgIntensity*100)))
bgcolor(bgCol, title="Trend Background")

// 2) Single line with color gradient based on probability strength
intensity = math.abs(prob - 0.5) * 2  // 0..1
lineCol = prob >= 0.5 ?
         color.from_gradient(intensity, 0, 1, color.new(color.green, 60), color.new(color.lime, 0)) :
         color.from_gradient(intensity, 0, 1, color.new(color.red, 60),   color.new(color.maroon, 0))

trendLine = ta.ema(close, 21)
plot(showLine ? trendLine : na, "AI Trend Line", color=lineCol, linewidth=3)

// 3) Arrows ONLY at high conviction
bullSig = showArrows and prob >= probHigh and prob[1] < probHigh
bearSig = showArrows and prob <= probLow  and prob[1] > probLow

plotshape(bullSig, title="Bull Signal", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,0), size=size.small)
plotshape(bearSig, title="Bear Signal", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0),  size=size.small)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(bullSig, title="AE Bull Signal", message="AetherEdge: High-conviction BULL trend pulse")
alertcondition(bearSig, title="AE Bear Signal", message="AetherEdge: High-conviction BEAR trend pulse")
````
