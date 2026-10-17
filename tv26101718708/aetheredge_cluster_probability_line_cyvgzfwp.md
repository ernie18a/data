# AetherEdge Cluster Probability Line

- url: https://www.tradingview.com/script/cyVgZFWP/
- type: indicator
- pine_id: PUB;053649f015c54a79b33d8f85e669b265
- version: 1.0

## Description

🖊️ Overview
AetherEdge Cluster Probability Line fuses K-means clustering with Markov-style state transition probabilities to deliver a next-generation probabilistic direction forecasting engine. It automatically classifies market behavior into three regimes (bearish, neutral, bullish) and computes the probability of the next state from learned historical transitions — projecting a forward-looking prediction line that reveals the market's hidden statistical bias.

🔶 Key Features

K-means Auto-Clustering: Dynamically classifies price behavior into 3 regimes
Transition Probability Matrix: 3×3 Markov-style matrix estimates next-state odds
2D Feature Space: Custom momentum × range expansion features
Forward Projection Line: Visualizes directional bias N bars ahead
5-Tier Color Gradient: Intuitive visualization of strength and direction
Probability Label: Minimalist confidence percentage with directional arrow
Bullish/Bearish Alerts: High-conviction signal notifications
🧠 Technical Architecture
This indicator is built on a unique fusion of K-means clustering × Markov transition probabilities.

Feature Engineering: ATR-normalized momentum and SMA-based range expansion are smoothed with 3-period EMA, producing a regime-agnostic 2D feature vector.
K-means Implementation: lookback bars are partitioned into 3 clusters, with centroids (c1, c2, c3) converging through up to iterMax iterations to extract the market's natural state structure.
Transition Matrix: Counts cluster transitions between consecutive bars and normalizes into a 3×3 matrix, statistically learning "which state is most likely next from current state."
Current State Detection: The latest feature vector's nearest centroid determines the current cluster ID.
Bias Calculation: bias = (P→Bull − P→Bear) × sensitivity gives net direction, while confidence captures conviction.
Forward Projection: close + bias × ATR × forwardN projects future price on an ATR scale, rendered as a directional line.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (4H–1D): Lookback=100, Forward=8, Sensitivity=1.0
SOL/XRP (1H): Lookback=80, Forward=6, Sensitivity=1.2 (high volatility)
Scalping (5M–15M): Lookback=50, Forward=4, Feature Smoothing=8
Long Swing (1D–1W): Lookback=200, Forward=12, Sensitivity=0.8
Tuning Tips:

Choppy predictions: Raise Feature Smoothing to 20–30 to reduce noise
Sluggish response: Sensitivity to 1.5–2.0, Iterations to 12+
Ranging markets: Shorter Forward Bars (3–5) for near-term focus
Trending markets: Longer Forward Bars (10–15) for big-picture view
💡 How to Use in Practice

Bias Confirmation: Strong color + high confidence (>55%) confirms directional bias
Entry Timing: Use slope flips of the prediction line as early signals
Multi-Timeframe: HTF (4H) line for macro bias → LTF (15M) for precise entries
AetherEdge Combinations: Liquidity Sentinel sweep + matching Cluster Line direction = elite conviction
Risk Management: Stand aside when confidence <0.5; engage aggressively at >0.6
⚠️ Important Notes

K-means runs only on barstate.islast — historical bars are not rendered (real-time-focused design)
Clustering accuracy is unstable below the initial lookback bars
The prediction line represents statistical tendency, not deterministic future
Sudden regime shifts may require time for the transition matrix to relearn
🚨 Disclaimer
This indicator is provided for educational and research purposes only and does not constitute financial advice. All trading decisions are made at your own risk and should be accompanied by proper risk management. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("AetherEdge Cluster Probability Line", shorttitle="AE-Cluster", overlay=true, max_lines_count=50, max_labels_count=5)

// ============================================================
// INPUTS
// ============================================================
lookback = input.int(100, "Clustering Window", minval=30, maxval=500)
iterMax  = input.int(8,   "Max Iterations", minval=3, maxval=20)
featLen  = input.int(14,  "Feature Smoothing", minval=5, maxval=50)

forwardN = input.int(8, "Forward Projection Bars", minval=3, maxval=30)
sensitivity = input.float(1.0, "Direction Sensitivity", minval=0.3, maxval=3.0, step=0.1)

lineWidth   = input.int(2, "Line Width", minval=1, maxval=4)
colStrong   = input.color(color.rgb(0,230,180), "Strong Bullish")
colWeakBull = input.color(color.rgb(120,200,160), "Weak Bullish")
colNeutral  = input.color(color.rgb(150,150,170), "Neutral")
colWeakBear = input.color(color.rgb(200,140,140), "Weak Bearish")
colStrongBr = input.color(color.rgb(230,60,90), "Strong Bearish")
showProb    = input.bool(true, "Show Tiny Probability Label")

// ============================================================
// FEATURES
// ============================================================
atr      = ta.atr(featLen)
momentum = ta.change(close, featLen) / math.max(atr * featLen, 0.0001)
rangeExp = (high - low) / math.max(ta.sma(high - low, featLen), 0.0001) - 1.0

fM = ta.ema(momentum, 3)
fR = ta.ema(rangeExp, 3)

// ============================================================
// INITIAL CENTROIDS
// ============================================================
var float c1x = -1.0
var float c1y = 0.0
var float c2x =  0.0
var float c2y =  0.0
var float c3x =  1.0
var float c3y =  0.5

var clusterIds = array.new_int()
var probTrans  = array.new_float(9, 1.0/3.0)

// ✅ by → by_
dist(ax, ay, bx, by_) =>
    math.sqrt(math.pow(ax - bx, 2) + math.pow(ay - by_, 2))

// ============================================================
// KMEANS (last bar only)
// ============================================================
if barstate.islast

    dataX = array.new_float()
    dataY = array.new_float()

    n = math.min(lookback, bar_index)

    for i = 0 to n - 1
        array.push(dataX, nz(fM[i]))
        array.push(dataY, nz(fR[i]))

    array.clear(clusterIds)
    for i = 0 to array.size(dataX) - 1
        array.push(clusterIds, 0)

    for iter = 0 to iterMax - 1

        // Assignment
        for i = 0 to array.size(dataX) - 1
            px = array.get(dataX, i)
            py = array.get(dataY, i)

            d1 = dist(px, py, c1x, c1y)
            d2 = dist(px, py, c2x, c2y)
            d3 = dist(px, py, c3x, c3y)

            cid = 1
            if d2 < d1 and d2 <= d3
                cid := 2
            if d3 < d1 and d3 < d2
                cid := 3

            array.set(clusterIds, i, cid)

        // Update
        float sx1 = 0.0
        float sy1 = 0.0
        float n1  = 0.0

        float sx2 = 0.0
        float sy2 = 0.0
        float n2  = 0.0

        float sx3 = 0.0
        float sy3 = 0.0
        float n3  = 0.0

        for i = 0 to array.size(dataX) - 1
            cid = array.get(clusterIds, i)
            px  = array.get(dataX, i)
            py  = array.get(dataY, i)

            if cid == 1
                sx1 += px
                sy1 += py
                n1  += 1
            else if cid == 2
                sx2 += px
                sy2 += py
                n2  += 1
            else
                sx3 += px
                sy3 += py
                n3  += 1

        if n1 > 0
            c1x := sx1 / n1
            c1y := sy1 / n1
        if n2 > 0
            c2x := sx2 / n2
            c2y := sy2 / n2
        if n3 > 0
            c3x := sx3 / n3
            c3y := sy3 / n3

    // ============================================================
    // TRANSITION MATRIX
    // ============================================================
    array.clear(probTrans)
    for i = 0 to 8
        array.push(probTrans, 0.0)

    rowSum = array.new_float(3, 0.0)

    if array.size(clusterIds) > 1
        for i = 0 to array.size(clusterIds) - 2
            toC   = array.get(clusterIds, i)     - 1
            fromC = array.get(clusterIds, i + 1) - 1
            idx   = fromC * 3 + toC
            array.set(probTrans, idx, array.get(probTrans, idx) + 1.0)
            array.set(rowSum, fromC, array.get(rowSum, fromC) + 1.0)

        for f = 0 to 2
            rs = array.get(rowSum, f)
            if rs > 0
                for t = 0 to 2
                    idx = f * 3 + t
                    array.set(probTrans, idx, array.get(probTrans, idx) / rs)

// ============================================================
// CURRENT CLUSTER
// ============================================================
d1Now = dist(fM, fR, c1x, c1y)
d2Now = dist(fM, fR, c2x, c2y)
d3Now = dist(fM, fR, c3x, c3y)

currentCluster = 2
if d1Now < d2Now and d1Now < d3Now
    currentCluster := 1
if d3Now < d1Now and d3Now < d2Now
    currentCluster := 3

fromIdx = currentCluster - 1

pToBear = array.size(probTrans) >= 9 ? array.get(probTrans, fromIdx * 3 + 0) : 0.33
pToBull = array.size(probTrans) >= 9 ? array.get(probTrans, fromIdx * 3 + 2) : 0.33

bias = (pToBull - pToBear) * sensitivity
confidence = math.max(pToBull, pToBear)

// ============================================================
// COLOR
// ============================================================
lineColor = colNeutral
if bias > 0.35 and confidence > 0.5
    lineColor := colStrong
else if bias > 0.10
    lineColor := colWeakBull
else if bias < -0.35 and confidence > 0.5
    lineColor := colStrongBr
else if bias < -0.10
    lineColor := colWeakBear

// ============================================================
// PREDICTION LINE
// ============================================================
var line predLine = na

if barstate.islast
    line.delete(predLine)
    endPrice = close + bias * atr * forwardN
    predLine := line.new(bar_index, close, bar_index + forwardN, endPrice, color=lineColor, width=lineWidth)

// ============================================================
// LABEL
// ============================================================
var label probLbl = na

if showProb and barstate.islast
    label.delete(probLbl)
    pct = math.round(confidence * 100)
    direction = bias > 0.05 ? "▲" : bias < -0.05 ? "▼" : "◆"
    endPrice = close + bias * atr * forwardN
    probLbl := label.new(bar_index + forwardN, endPrice, direction + " " + str.tostring(pct) + "%", style=label.style_none, textcolor=lineColor, size=size.tiny)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bias > 0.35 and confidence > 0.55, title="Strong Bullish Cluster")
alertcondition(bias < -0.35 and confidence > 0.55, title="Strong Bearish Cluster")
````
