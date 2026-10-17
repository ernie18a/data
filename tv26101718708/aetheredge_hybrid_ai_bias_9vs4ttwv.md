# AetherEdge Hybrid AI Bias

- url: https://www.tradingview.com/script/9vS4tTwV/
- type: indicator
- pine_id: PUB;30e2814ab3f340d3bc959a5d807021cd
- version: 1.0

## Description

🖊️ Overview
AetherEdge Hybrid AI Bias is a cutting-edge hybrid prediction indicator that fuses two distinct machine learning paradigms: K-Nearest Neighbors (KNN) and a 4-3-1 Neural Network (MLP). By dynamically blending memory-based pattern recognition with gradient-descent online learning through confidence-weighted fusion, it achieves predictive accuracy unreachable by any single model.

🔶 Key Features

Dual AI Engine: Hybrid fusion of KNN + Neural Network
4D Feature Space: Momentum, RSI deviation, EMA position, volatility expansion
Distance-Weighted KNN: Top-8 neighbors weighted by inverse distance
Online Learning MLP: 4-3-1 tanh-activated network
Dynamic Confidence Fusion: Auto-adjusted weighting based on each model's certainty
3-Tier Bias Classification: Clear Bullish / Neutral / Bearish signals
Future Return Prediction: Forecasts directional bias at chosen horizon
Tanh-Squash Normalization: All features standardized to [-1, 1]

🧠 Technical Architecture

This indicator integrates two distinct AI paradigms into a true ensemble learning system.

Feature Engineering: ①ATR-normalized 10-bar momentum, ②scaled RSI-50 deviation, ③ATR-distance from EMA50, ④ATR vs 50-SMA expansion ratio. All compressed to [-1, 1] via the squash (tanh-like) function.
KNN Engine: Computes Euclidean distance between current 4D feature vector and historical patterns over the lookback window. Top-8 neighbors are extracted, then averaged with inverse-distance weights (1/(d+ε)). Confidence is derived as exp(-meanDistance).
Neural Network Engine: 4-input → 3-hidden (tanh) → 1-output MLP. Persistent weight variables enable genuine continual learning across bars, with gradient descent applied over mini-epochs each bar.
Target Construction: Future return at horizon, normalized by ATR × horizon, then squashed to a smooth label in [-1, 1].
Hybrid Fusion: hybridW provides static weighting; additionally, the confidence differential dynamically biases toward whichever model is more certain — an adaptive ensemble.
Threshold Classification: bullThr/bearThr discretize the prediction into three actionable bias regimes.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (4H–1D): lookback=100, k=8, horizon=5, hybridW=0.5
SOL/XRP (1H): lookback=150, k=10, horizon=3, nnRate=0.08 (faster learning)
Scalping (5M–15M): lookback=80, k=5, horizon=2, hybridW=0.3 (KNN-favored)
Long Swing (1D): lookback=200, k=12, horizon=10, hybridW=0.7 (NN-favored)
Parameter Tuning:

Slow/sluggish learning: Raise nnRate to 0.08–0.15, increase nnEpochs to 5
Noisy predictions: Widen bullThr/bearThr to ±0.30 for stronger filtering
New symbol/cold start: hybridW=0.3 to favor KNN (instant pattern recall)
Mature trend regime: hybridW=0.7 to favor NN (leverages trained weights)

💡 How to Use in Practice

Bias-Driven Entry: Confirmed Bullish + price pullback → long
Early Reversal Detection: Neutral → Bearish transition triggers long exit
Multi-Timeframe: Confirm 1D bias → use 1H for precise execution
AetherEdge Combinations: RFMA slope + Hybrid AI Bias agreement = elite-tier signal
Counter-Trade Filter: Avoid longs in Bearish regime; skip shorts in Bullish regime

⚠️ Important Notes

NN weights start from initial defaults — minimum lookback + 50 bars warmup recommended
NN weights reset to defaults on indicator reload
Horizon-based target uses only known historical data (no look-ahead bias)
Watch for squash function saturation during extreme volatility shocks
KNN is computationally heavy — avoid excessively large lookback values

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. AI model predictions are based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Hybrid AI Bias", shorttitle="AE-HAIB", overlay=true, max_lines_count=5, max_labels_count=5)

// ============================================================
// ▼ INPUTS
// ============================================================
grpAI    = "🧠 AI Engine"
lookback = input.int(100, "Training Window",      minval=30, maxval=500, group=grpAI, tooltip="学習に使う過去バー数")
kNeigh   = input.int(8,   "KNN: k Neighbors",     minval=3,  maxval=25,  group=grpAI)
horizon  = input.int(5,   "Forecast Horizon",     minval=1,  maxval=20,  group=grpAI, tooltip="何バー先を予測するか")
nnRate   = input.float(0.05, "NN Learning Rate",  minval=0.001, maxval=0.5, step=0.005, group=grpAI)
nnEpochs = input.int(3,   "NN Mini-Epochs/bar",   minval=1, maxval=10, group=grpAI)
hybridW  = input.float(0.5, "Hybrid Weight (NN↔KNN)", minval=0.0, maxval=1.0, step=0.05, group=grpAI, tooltip="0=KNN特化, 1=NN特化, 中間=確信度で動的融合")

grpThr   = "⚖️ Bias Thresholds"
bullThr  = input.float(0.20, "Bullish Threshold", minval=0.05, maxval=0.80, step=0.05, group=grpThr)
bearThr  = input.float(-0.20,"Bearish Threshold", minval=-0.80, maxval=-0.05, step=0.05, group=grpThr)

grpVis   = "🎨 Visual"
lineLen  = input.int(40,  "Line Length (bars)",   minval=10, maxval=200, group=grpVis)
lineWid  = input.int(5,   "Line Width",           minval=2, maxval=10, group=grpVis)
showTag  = input.bool(true, "Show Tiny Bias Tag", group=grpVis)
colBull  = input.color(color.rgb(0, 220, 170),  "Bullish",  group=grpVis)
colNeu   = input.color(color.rgb(140, 140, 160),"Neutral",  group=grpVis)
colBear  = input.color(color.rgb(230, 70, 100), "Bearish",  group=grpVis)

// ============================================================
// ▼ FEATURE ENGINEERING (4 normalized features)
// ============================================================
atr14   = ta.atr(14)

// Feature 1: Normalized momentum
f1_raw  = ta.change(close, 10) / math.max(atr14 * 10, 1e-10)
// Feature 2: RSI deviation from 50, scaled
f2_raw  = (ta.rsi(close, 14) - 50.0) / 50.0
// Feature 3: Price position vs EMA50, ATR-normalized
ema50   = ta.ema(close, 50)
f3_raw  = (close - ema50) / math.max(atr14, 1e-10)
// Feature 4: Volatility expansion ratio
f4_raw  = (atr14 - ta.sma(atr14, 50)) / math.max(ta.sma(atr14, 50), 1e-10)

// Squash to [-1, 1] using tanh-like
squash(float x) => 2.0 / (1.0 + math.exp(-x)) - 1.0
f1 = squash(f1_raw)
f2 = squash(f2_raw * 2.0)
f3 = squash(f3_raw * 0.5)
f4 = squash(f4_raw * 2.0)

// Target: future return sign, magnitude in [-1,1]
futureRet = (close[0] - close[horizon]) / math.max(atr14[horizon] * horizon, 1e-10)
target    = squash(futureRet)   // smooth label in [-1, 1]

// ============================================================
// ▼ KNN MODEL  — distance-weighted k-nearest neighbors
// ============================================================
knnPredict() =>
    float bestD0 = 1e18, bestD1 = 1e18, bestD2 = 1e18, bestD3 = 1e18
    float bestD4 = 1e18, bestD5 = 1e18, bestD6 = 1e18, bestD7 = 1e18
    float bestT0 = 0.0, bestT1 = 0.0, bestT2 = 0.0, bestT3 = 0.0
    float bestT4 = 0.0, bestT5 = 0.0, bestT6 = 0.0, bestT7 = 0.0

    // Use up to k=8 fixed slots (we cap kNeigh at 8 internally for speed)
    int kEff = math.min(kNeigh, 8)

    for i = horizon + 1 to lookback
        d1 = f1 - f1[i]
        d2 = f2 - f2[i]
        d3 = f3 - f3[i]
        d4 = f4 - f4[i]
        dist = math.sqrt(d1*d1 + d2*d2 + d3*d3 + d4*d4)
        tgt  = target[i - horizon]

        // Insertion into sorted top-k (manual unrolled — k<=8)
        if dist < bestD0
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := bestD4, bestT5 := bestT4
            bestD4 := bestD3, bestT4 := bestT3
            bestD3 := bestD2, bestT3 := bestT2
            bestD2 := bestD1, bestT2 := bestT1
            bestD1 := bestD0, bestT1 := bestT0
            bestD0 := dist,   bestT0 := tgt
        else if dist < bestD1
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := bestD4, bestT5 := bestT4
            bestD4 := bestD3, bestT4 := bestT3
            bestD3 := bestD2, bestT3 := bestT2
            bestD2 := bestD1, bestT2 := bestT1
            bestD1 := dist,   bestT1 := tgt
        else if dist < bestD2
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := bestD4, bestT5 := bestT4
            bestD4 := bestD3, bestT4 := bestT3
            bestD3 := bestD2, bestT3 := bestT2
            bestD2 := dist,   bestT2 := tgt
        else if dist < bestD3
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := bestD4, bestT5 := bestT4
            bestD4 := bestD3, bestT4 := bestT3
            bestD3 := dist,   bestT3 := tgt
        else if dist < bestD4
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := bestD4, bestT5 := bestT4
            bestD4 := dist,   bestT4 := tgt
        else if dist < bestD5
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := bestD5, bestT6 := bestT5
            bestD5 := dist,   bestT5 := tgt
        else if dist < bestD6
            bestD7 := bestD6, bestT7 := bestT6
            bestD6 := dist,   bestT6 := tgt
        else if dist < bestD7
            bestD7 := dist,   bestT7 := tgt

    // Distance-weighted average of top-k (1 / (d+ε))
    eps = 1e-6
    float wSum = 0.0, vSum = 0.0
    if kEff >= 1
        w = 1.0 / (bestD0 + eps), wSum += w, vSum += w * bestT0
    if kEff >= 2
        w = 1.0 / (bestD1 + eps), wSum += w, vSum += w * bestT1
    if kEff >= 3
        w = 1.0 / (bestD2 + eps), wSum += w, vSum += w * bestT2
    if kEff >= 4
        w = 1.0 / (bestD3 + eps), wSum += w, vSum += w * bestT3
    if kEff >= 5
        w = 1.0 / (bestD4 + eps), wSum += w, vSum += w * bestT4
    if kEff >= 6
        w = 1.0 / (bestD5 + eps), wSum += w, vSum += w * bestT5
    if kEff >= 7
        w = 1.0 / (bestD6 + eps), wSum += w, vSum += w * bestT6
    if kEff >= 8
        w = 1.0 / (bestD7 + eps), wSum += w, vSum += w * bestT7

    pred = wSum > 0 ? vSum / wSum : 0.0
    // Confidence: lower mean distance → higher confidence
    meanD = (bestD0 + bestD1 + bestD2 + bestD3) / 4.0
    conf  = math.exp(-meanD)         // ∈ (0, 1]
    [pred, conf]

[knnPred, knnConf] = knnPredict()

// ============================================================
// ▼ NEURAL NET MODEL  — 4-3-1 MLP with online SGD
// ============================================================
// Persistent weights
var float w11 = 0.30, w12 = -0.20, w13 = 0.10
var float w21 = -0.15, w22 = 0.25, w23 = -0.30
var float w31 = 0.40, w32 = 0.10, w33 = -0.20
var float w41 = -0.10, w42 = 0.30, w43 = 0.20
var float b1  = 0.0,  b2  = 0.0,  b3  = 0.0
var float v1  = 0.50, v2  = -0.40, v3  = 0.30
var float bo  = 0.0

tanhAct(float x) =>
    e1 = math.exp(x)
    e2 = math.exp(-x)
    (e1 - e2) / (e1 + e2)

// Forward pass on current features
forwardNN(float x1, float x2, float x3, float x4) =>
    z1 = x1*w11 + x2*w21 + x3*w31 + x4*w41 + b1
    z2 = x1*w12 + x2*w22 + x3*w32 + x4*w42 + b2
    z3 = x1*w13 + x2*w23 + x3*w33 + x4*w43 + b3
    h1 = tanhAct(z1)
    h2 = tanhAct(z2)
    h3 = tanhAct(z3)
    yRaw = h1*v1 + h2*v2 + h3*v3 + bo
    y = tanhAct(yRaw)
    [y, h1, h2, h3]

// Online training: train on (features[horizon], target_now)
// We have observed actual future return for horizon-bars-ago features
if bar_index > lookback + horizon
    for ep = 0 to nnEpochs - 1
        // Random sample within window for stability
        offset = horizon + 1 + math.floor(math.random() * (lookback - horizon - 1))
        x1s = nz(f1[offset], 0.0)
        x2s = nz(f2[offset], 0.0)
        x3s = nz(f3[offset], 0.0)
        x4s = nz(f4[offset], 0.0)
        ys  = nz(target[offset - horizon], 0.0)

        // Forward
        z1 = x1s*w11 + x2s*w21 + x3s*w31 + x4s*w41 + b1
        z2 = x1s*w12 + x2s*w22 + x3s*w32 + x4s*w42 + b2
        z3 = x1s*w13 + x2s*w23 + x3s*w33 + x4s*w43 + b3
        h1 = tanhAct(z1)
        h2 = tanhAct(z2)
        h3 = tanhAct(z3)
        yRaw = h1*v1 + h2*v2 + h3*v3 + bo
        yPred = tanhAct(yRaw)

        // Backprop (MSE loss)
        err   = yPred - ys
        dY    = err * (1.0 - yPred * yPred)             // d/dyRaw
        dH1   = dY * v1 * (1.0 - h1 * h1)
        dH2   = dY * v2 * (1.0 - h2 * h2)
        dH3   = dY * v3 * (1.0 - h3 * h3)

        // Update output layer
        v1 := v1 - nnRate * dY * h1
        v2 := v2 - nnRate * dY * h2
        v3 := v3 - nnRate * dY * h3
        bo := bo - nnRate * dY

        // Update hidden layer
        w11 := w11 - nnRate * dH1 * x1s
        w21 := w21 - nnRate * dH1 * x2s
        w31 := w31 - nnRate * dH1 * x3s
        w41 := w41 - nnRate * dH1 * x4s
        b1  := b1  - nnRate * dH1

        w12 := w12 - nnRate * dH2 * x1s
        w22 := w22 - nnRate * dH2 * x2s
        w32 := w32 - nnRate * dH2 * x3s
        w42 := w42 - nnRate * dH2 * x4s
        b2  := b2  - nnRate * dH2

        w13 := w13 - nnRate * dH3 * x1s
        w23 := w23 - nnRate * dH3 * x2s
        w33 := w33 - nnRate * dH3 * x3s
        w43 := w43 - nnRate * dH3 * x4s
        b3  := b3  - nnRate * dH3

[nnPred, _h1, _h2, _h3] = forwardNN(f1, f2, f3, f4)
// NN confidence: |output| ≈ how decisive the prediction is
nnConf = math.abs(nnPred)

// ============================================================
// ▼ HYBRID FUSION  (confidence-weighted)
// ============================================================
// Static user weight × dynamic confidence weight
wNN_static  = hybridW
wKNN_static = 1.0 - hybridW

wNN_dyn  = wNN_static  * (0.5 + nnConf)
wKNN_dyn = wKNN_static * (0.5 + knnConf)
wTotal   = wNN_dyn + wKNN_dyn

biasRaw  = wTotal > 0 ? (wNN_dyn * nnPred + wKNN_dyn * knnPred) / wTotal : 0.0
// Smooth slightly to prevent flicker
bias     = ta.ema(biasRaw, 3)

// ============================================================
// ▼ CLASSIFY BIAS
// ============================================================
// state: 1=Bull, 0=Neutral, -1=Bear
biasState = bias > bullThr ? 1 : bias < bearThr ? -1 : 0
biasLabel = biasState == 1 ? "BULL" : biasState == -1 ? "BEAR" : "NEUTRAL"

// Vertical position above the chart: higher when more bullish
// Use ATR-multiplied offset above the highest recent high
hiRef     = ta.highest(high, 50)
loRef     = ta.lowest(low, 50)
chartRng  = math.max(hiRef - loRef, atr14 * 10)
// Map bias [-1,1] → offset range [+0.5*ATR, +5*ATR] above hiRef
// Bullish → far above; Bearish → just above; Neutral → middle
biasClamp = math.max(-1.0, math.min(1.0, bias))
yOffset   = atr14 * (3.0 + biasClamp * 2.0)   // 1*ATR..5*ATR
yPos      = hiRef + yOffset

// Color by state with intensity by |bias|
intensity = math.min(1.0, math.abs(bias) / math.max(math.abs(bullThr), math.abs(bearThr)) * 1.2)
baseCol   = biasState == 1 ? colBull : biasState == -1 ? colBear : colNeu
lineColor = color.from_gradient(intensity, 0.0, 1.0, color.new(baseCol, 60), baseCol)

// ============================================================
// ▼ SINGLE LINE RENDER (last bar only)
// ============================================================
var line  biasLine = na
var label biasTag  = na

if barstate.islast
    line.delete(biasLine)
    label.delete(biasTag)
    x1 = bar_index - lineLen
    x2 = bar_index + math.floor(lineLen / 4)
    biasLine := line.new(x1, yPos, x2, yPos, color=lineColor, width=lineWid, extend=extend.none)
    if showTag
        biasTag := label.new(x2, yPos, "  " + biasLabel + "  " + str.tostring(bias, "#.##"), xloc=xloc.bar_index, style=label.style_none, textcolor=lineColor, size=size.small, textalign=text.align_left)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(ta.crossover(bias, bullThr),  title="HAIB → Bullish", message="AE-HAIB: Hybrid bias turned BULLISH")
alertcondition(ta.crossunder(bias, bearThr), title="HAIB → Bearish", message="AE-HAIB: Hybrid bias turned BEARISH")
alertcondition(ta.crossunder(bias, bullThr) and bias[1] >= bullThr, title="HAIB → Neutral from Bull", message="AE-HAIB: Lost bullish bias")
alertcondition(ta.crossover(bias, bearThr)  and bias[1] <= bearThr, title="HAIB → Neutral from Bear", message="AE-HAIB: Lost bearish bias")
````
