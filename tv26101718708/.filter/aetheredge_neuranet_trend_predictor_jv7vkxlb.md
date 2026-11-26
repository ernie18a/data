# AetherEdge NeuraNet Trend Predictor

- url: https://www.tradingview.com/script/Jv7VkxlB/
- type: indicator
- pine_id: PUB;c114cc21006c4fb29d695d18d80ec705
- version: 1.0

## Description

🖊️ Overview
AetherEdge NeuraNet Trend Predictor is a next-generation AI-driven trend forecasting indicator that fully implements a true Multi-Layer Perceptron (MLP) neural network in Pine Script. Nine-dimensional features flow through input → hidden → output layers, with weights self-updating every bar via backpropagation + Nesterov momentum + L2 regularization. This is the pinnacle of machine learning engines on TradingView—a system that perpetually evolves with market structure changes.

🔶 Key Features

True MLP Implementation: 9-H-1 architecture (hidden 3–12 neurons)
Online Learning: Deterministic gradient descent updating weights every bar
Nesterov-Style Momentum: Accelerated convergence via gradient inertia
L2 Regularization: Overfitting suppression
Xavier Initialization: Theoretically optimal weight init
Binary Cross-Entropy Loss: Optimal for probabilistic prediction
9-D Feature Engine: Price/EMA/RSI/ATR/Volume/MACD/BB/DMI/Structure
Robust Normalization: z-score based statistical standardization
Live Accuracy Tracking: Cumulative prediction accuracy %
Loss EMA Monitoring: Visualized learning progress
Network Visualization: Real-time input → hidden activation → output
Probability Bar (right edge): 10-tier prediction visualization
Confidence Computation: Auto-calculated via |prob - 0.5| × 2
AI VERDICT: 5-tier decision support messaging

🧠 Technical Architecture

This indicator is an advanced neural network implementation grounded in genuine deep learning theory.

Network Structure:
Input layer: 9 neurons (feature vector)
Hidden layer: 3–12 neurons (tanh activation)
Output layer: 1 neuron (sigmoid, probability)
Total params: 9×H + H + H + 1
Feature Engineering (9-D):
f1: Price/EMA Fast deviation
f2: EMA Spread (Fast vs Slow)
f3: RSI normalized
f4: ATR% z-score
f5: Volume z-score (log-transformed)
f6: MACD Histogram normalized
f7: Bollinger Band Position
f8: DMI differential
f9: Structural position (high/low range)
Forward Pass:
h_j = tanh(Σ x_i × W1_ij + b1_j)
prob = sigmoid(Σ h_j × W2_j + b2)
Backpropagation:
Output error: err = ŷ - y (BCE gradient)
Hidden error: δ = err × W2 × (1 - h²) (tanh derivative)
L2-regularized gradient: g = δ × x + λ × W
Nesterov update: v = β×v - η×g; W += v
Target Signal: Next bar direction (close > close[1])
Warmup: Signals activate after 200 bars of training
Learning Statistics: Train Steps / Accuracy / Loss EMA / 100-bar Loss

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (1H–4H): Standard (Hidden=6, η=0.05, β=0.9)
ETH (15M–1H): Hidden=8, η=0.03 for precision
SOL (high-vol): λ=0.005 to enhance overfitting suppression
XRP (range): Hidden=4, η=0.07 for rapid adaptation
Learning Rate (η):

0.01–0.03: Stability-focused, long-term trends
0.05: Balanced (recommended)
0.1–0.2: Fast adaptation for regime shifts
Hidden Neurons:

3–4: Simple, low overfit risk
6: Balanced (recommended)
8–12: High capacity, requires sufficient data
Warmup Period:

200 bars: Standard
500 bars: High-precision focus
100 bars: Quick activation
Thresholds:

Conservative: Long=0.75, Short=0.25, MinConf=0.7
Standard: Long=0.65, Short=0.35, MinConf=0.6
Aggressive: Long=0.6, Short=0.4, MinConf=0.5

💡 How to Use in Practice

VERDICT = STRONG LONG CONVICTION: Neural net at >80% conviction—strongest entry
Accuracy > 55%: Network in hot streak, high signal trust
Accuracy < 50%: Regime shift in progress, stand aside
Loss EMA declining: Learning healthy, precision improving
Confidence > 70%: High-quality signal, full position consideration
Feature panel watch: All features unidirectional = multi-faceted consensus
Hidden activations: ●●● (strong) aligned = internal network consensus
Probability bar extreme (>90%): Watch for reversal risk
AetherEdge Synergy:
All-in-One Dashboard HIGH-CONVICTION + NeuraNet STRONG = dual AI confirmation
Self-Evolving S/R Grid strong line + NeuraNet aligned = ML × RL fusion
Liquidity Sweep Bull Sweep + NeuraNet > 0.8 = institutional + AI sync
Multi-TF: 4H for direction → 1H for NeuraNet wait → 15M for precision entry

⚠️ Important Notes

Learning Reset: Weights initialize on every chart reload—warmup mandatory
Initial Warmup: Minimum 200 bars required before predictions
Accuracy Metric: Cumulative; treat <100 samples as preliminary
Overfit Risk: Excess Hidden + low λ = overfitting—balance carefully
Diverging η: η > 0.2 risks weight explosion—use cautiously
Regime Changes: Sudden market shifts temporarily reduce Accuracy, auto-recovers
Compute Load: Hidden=12 is heavy—use 6 on low-spec setups

🚨 Disclaimer

This indicator is a machine learning demonstration provided for educational and research purposes only and does not constitute financial advice. Neural network predictions are statistical estimates based on historical patterns and do not guarantee future profits. Do not blindly trust AI model outputs—combine with independent analysis and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge NeuraNet Trend Predictor", "AE-NNT",
     overlay=true,
     max_labels_count=500,
     max_lines_count=100,
     max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpN = "🧠 Neural Network Architecture"
hiddenN   = input.int(6,  "Hidden Neurons", minval=3, maxval=12, group=grpN,
     tooltip="Hidden layer size. More = higher capacity, slower learning.")
learnRate = input.float(0.05, "Learning Rate η", minval=0.001, maxval=0.3, step=0.005, group=grpN,
     tooltip="Gradient descent step size. 0.05 recommended.")
momentum  = input.float(0.9, "Momentum β", minval=0.0, maxval=0.99, step=0.01, group=grpN,
     tooltip="Momentum coefficient for weight updates (Nesterov-style).")
l2Reg     = input.float(0.001, "L2 Regularization λ", minval=0.0, maxval=0.1, step=0.001, group=grpN,
     tooltip="Prevents overfitting by penalizing large weights.")
warmupBars = input.int(200, "Warmup Bars (no prediction)", minval=50, group=grpN,
     tooltip="Bars to train before predictions activate.")

grpF = "📊 Feature Engineering"
emaLen1  = input.int(21,  "Fast EMA",  minval=2, group=grpF)
emaLen2  = input.int(50,  "Slow EMA",  minval=2, group=grpF)
rsiLen   = input.int(14,  "RSI Length", minval=2, group=grpF)
atrLen   = input.int(14,  "ATR Length", minval=2, group=grpF)
volLen   = input.int(20,  "Volume MA",  minval=2, group=grpF)
bbLen    = input.int(20,  "BB Length",  minval=2, group=grpF)
bbMult   = input.float(2.0, "BB Mult",  minval=0.1, step=0.1, group=grpF)
structLen = input.int(10, "Structure Lookback", minval=3, group=grpF)

grpS = "🎯 Signal Filters"
longThresh  = input.float(0.65, "Long Probability Threshold",  minval=0.5, maxval=0.95, step=0.01, group=grpS)
shortThresh = input.float(0.35, "Short Probability Threshold", minval=0.05, maxval=0.5, step=0.01, group=grpS)
minConfidence = input.float(0.6, "Min Confidence to Display", minval=0.5, maxval=0.99, step=0.01, group=grpS,
     tooltip="Confidence = |probability - 0.5| × 2. Filters weak signals.")

grpD = "🎨 Display"
darkMode  = input.bool(true, "Dark Mode", group=grpD)
showProbBar = input.bool(true, "Show Probability Bar (right side)", group=grpD)
showArrows  = input.bool(true, "Show Prediction Arrows", group=grpD)
showColorBg = input.bool(true, "Confidence Background Tint", group=grpD)
showNetwork = input.bool(true, "Show Neural Network Diagram", group=grpD)
dashPos   = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt   = darkMode ? color.new(#111a2e, 10) : color.new(#ffffff, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)
cBull    = color.new(#00d4a0, 0)
cBear    = color.new(#ff5577, 0)
cNeutral = color.new(#ffa500, 0)
cPurple  = color.new(#c084fc, 0)

// ═══════════════════════════════════════════════════════════════
//  GLOBAL HELPER FUNCTIONS  ← FIX: must be at top level
// ═══════════════════════════════════════════════════════════════
// z-score helper for robust normalization
f_zscore(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0

// Pseudo-random init using bar_index hash (deterministic)
f_rand(seed) =>
    x = math.sin(seed * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)

// Activations
f_tanh(x) =>
    e1 = math.exp(x)
    e2 = math.exp(-x)
    (e1 - e2) / (e1 + e2)

f_sigmoid(x) =>
    xc = math.max(-30, math.min(30, x))
    1.0 / (1.0 + math.exp(-xc))

// Forward pass
f_forward(W1_, b1_, W2_, b2_, hN, nf, xArr, hArr) =>
    for j = 0 to hN - 1
        s = array.get(b1_, j)
        for i = 0 to nf - 1
            s += array.get(xArr, i) * array.get(W1_, i * hN + j)
        array.set(hArr, j, f_tanh(s))
    o = b2_
    for j = 0 to hN - 1
        o += array.get(hArr, j) * array.get(W2_, j)
    f_sigmoid(o)

// Mean of array
f_arrMean(a) =>
    n = array.size(a)
    result = 0.0
    if n > 0
        s = 0.0
        for i = 0 to n - 1
            s += array.get(a, i)
        result := s / n
    result

// Dashboard position
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// Feature color / text helpers  ← FIX: moved out of if-block
f_featCol(v) =>
    v > 0.3 ? cBull : v > 0.1 ? color.new(cBull, 40) : v > -0.1 ? cMute : v > -0.3 ? color.new(cBear, 40) : cBear

f_featTxt(v) =>
    str.tostring(v, "+#.##;-#.##")

// ═══════════════════════════════════════════════════════════════
//  FEATURE ENGINEERING
// ═══════════════════════════════════════════════════════════════
eFast = ta.ema(close, emaLen1)
eSlow = ta.ema(close, emaLen2)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
atrPct = atr / close * 100

[macdLine, macdSig, macdHist] = ta.macd(close, 12, 26, 9)
macdHistNorm = macdHist / close * 1000

bbBasis = ta.sma(close, bbLen)
bbDev = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbPos = (close - bbLower) / (bbUpper - bbLower) - 0.5

[dip, dim, adxVal] = ta.dmi(14, 14)

volMa = ta.sma(volume, volLen)
volRatio = volume / volMa

// Feature vector (9 dimensions)
f1 = math.max(-3, math.min(3, (close - eFast) / eFast * 100)) / 3
f2 = math.max(-3, math.min(3, (eFast - eSlow) / eSlow * 100)) / 3
f3 = (rsi - 50) / 50
f4 = math.max(-2, math.min(2, f_zscore(atrPct, 50))) / 2
f5 = math.max(-2, math.min(2, f_zscore(math.log(volRatio), 50))) / 2
f6 = math.max(-1, math.min(1, macdHistNorm))
f7 = math.max(-1, math.min(1, bbPos * 2))
f8 = math.max(-1, math.min(1, (dip - dim) / 50))

hh = ta.highest(high, structLen)
ll = ta.lowest(low, structLen)
f9 = hh > ll ? ((close - ll) / (hh - ll) - 0.5) * 2 : 0.0

NF = 9

// ═══════════════════════════════════════════════════════════════
//  NEURAL NETWORK: 9 → H → 1
// ═══════════════════════════════════════════════════════════════
var array<float> W1 = array.new<float>(NF * hiddenN, 0.0)
var array<float> b1 = array.new<float>(hiddenN, 0.0)
var array<float> W2 = array.new<float>(hiddenN, 0.0)
var float        b2 = 0.0

var array<float> vW1 = array.new<float>(NF * hiddenN, 0.0)
var array<float> vb1 = array.new<float>(hiddenN, 0.0)
var array<float> vW2 = array.new<float>(hiddenN, 0.0)
var float        vb2 = 0.0

var bool initialized = false
if not initialized
    xav1 = math.sqrt(6.0 / (NF + hiddenN))
    xav2 = math.sqrt(6.0 / (hiddenN + 1))
    for i = 0 to NF * hiddenN - 1
        array.set(W1, i, (f_rand(i + 1) - 0.5) * 2 * xav1)
    for i = 0 to hiddenN - 1
        array.set(W2, i, (f_rand(i + NF * hiddenN + 1) - 0.5) * 2 * xav2)
    initialized := true

var array<float> hAct = array.new<float>(hiddenN, 0.0)
var array<float> xInp = array.new<float>(NF, 0.0)

// Build input vector
array.set(xInp, 0, nz(f1))
array.set(xInp, 1, nz(f2))
array.set(xInp, 2, nz(f3))
array.set(xInp, 3, nz(f4))
array.set(xInp, 4, nz(f5))
array.set(xInp, 5, nz(f6))
array.set(xInp, 6, nz(f7))
array.set(xInp, 7, nz(f8))
array.set(xInp, 8, nz(f9))

prob = f_forward(W1, b1, W2, b2, hiddenN, NF, xInp, hAct)

// ═══════════════════════════════════════════════════════════════
//  ONLINE BACKPROPAGATION
// ═══════════════════════════════════════════════════════════════
var array<float> xInpPrev = array.new<float>(NF, 0.0)
var array<float> hActPrev = array.new<float>(hiddenN, 0.0)
var float probPrev = 0.5
var bool hasPrev = false

var int    trainSteps = 0
var float  lossEMA = 0.5
var int    correctPreds = 0
var int    totalPreds = 0
var array<float> recentLoss = array.new<float>(0)

if barstate.isconfirmed and hasPrev and bar_index > 2
    // Label: did price go up from the previous bar?
    yLabel = close > close[1] ? 1.0 : 0.0

    yhat = probPrev
    err = yhat - yLabel

    eps = 1e-7
    bce = -(yLabel * math.log(math.max(eps, yhat)) + (1 - yLabel) * math.log(math.max(eps, 1 - yhat)))
    lossEMA := lossEMA * 0.98 + bce * 0.02
    array.push(recentLoss, bce)
    if array.size(recentLoss) > 100
        array.shift(recentLoss)

    pred = yhat > 0.5 ? 1.0 : 0.0
    totalPreds += 1
    if pred == yLabel
        correctPreds += 1

    // Update W2, b2
    for j = 0 to hiddenN - 1
        hp = array.get(hActPrev, j)
        gW2 = err * hp + l2Reg * array.get(W2, j)
        vOld = array.get(vW2, j)
        vNew = momentum * vOld - learnRate * gW2
        array.set(vW2, j, vNew)
        array.set(W2, j, array.get(W2, j) + vNew)

    gb2 = err
    vb2 := momentum * vb2 - learnRate * gb2
    b2 := b2 + vb2

    // Update W1, b1
    for j = 0 to hiddenN - 1
        hp = array.get(hActPrev, j)
        dh = err * array.get(W2, j)
        dz = dh * (1.0 - hp * hp)
        gb1 = dz + l2Reg * array.get(b1, j)
        vb1Old = array.get(vb1, j)
        vb1New = momentum * vb1Old - learnRate * gb1
        array.set(vb1, j, vb1New)
        array.set(b1, j, array.get(b1, j) + vb1New)
        for i = 0 to NF - 1
            gW1 = dz * array.get(xInpPrev, i) + l2Reg * array.get(W1, i * hiddenN + j)
            vW1Old = array.get(vW1, i * hiddenN + j)
            vW1New = momentum * vW1Old - learnRate * gW1
            array.set(vW1, i * hiddenN + j, vW1New)
            array.set(W1, i * hiddenN + j, array.get(W1, i * hiddenN + j) + vW1New)

    trainSteps += 1

if barstate.isconfirmed
    for i = 0 to NF - 1
        array.set(xInpPrev, i, array.get(xInp, i))
    for j = 0 to hiddenN - 1
        array.set(hActPrev, j, array.get(hAct, j))
    probPrev := prob
    hasPrev := true

// ═══════════════════════════════════════════════════════════════
//  INTERPRETATION LAYER
// ═══════════════════════════════════════════════════════════════
confidence = math.abs(prob - 0.5) * 2
bullPct = prob * 100
bearPct = (1 - prob) * 100

isReady = bar_index > warmupBars and trainSteps > 50

longSignal  = isReady and prob > longThresh  and confidence > minConfidence and ta.crossover(prob, longThresh)
shortSignal = isReady and prob < shortThresh and confidence > minConfidence and ta.crossunder(prob, shortThresh)

rollAcc = totalPreds > 0 ? correctPreds / totalPreds * 100 : 0.0

recentLossMean = f_arrMean(recentLoss)

confCol = prob > 0.5 ? color.from_gradient(confidence, 0, 1, color.new(cNeutral, 50), cBull) : color.from_gradient(confidence, 0, 1, color.new(cNeutral, 50), cBear)

signalLabel = prob > 0.8 ? "STRONG BULL" : prob > 0.65 ? "BULL" : prob > 0.55 ? "Lean Bull" : prob > 0.45 ? "NEUTRAL" : prob > 0.35 ? "Lean Bear" : prob > 0.2 ? "BEAR" : "STRONG BEAR"

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
bgcolor(showColorBg and isReady ? color.new(confCol, 92) : na, title="Confidence Background")

plotshape(showArrows and longSignal ? low : na, "Long Predicted",
     shape.triangleup, location.belowbar, color=cBull,
     text="◆", textcolor=color.white, size=size.small)
plotshape(showArrows and shortSignal ? high : na, "Short Predicted",
     shape.triangledown, location.abovebar, color=cBear,
     text="◆", textcolor=color.white, size=size.small)

var line probLine = na
if isReady
    line.delete(probLine)

// ═══════════════════════════════════════════════════════════════
//  PROBABILITY BAR (right side)
// ═══════════════════════════════════════════════════════════════
var table probBar = na
if barstate.islast and showProbBar
    probBar := table.new(position.middle_right, 1, 11,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)
    table.cell(probBar, 0, 0, "🧠", text_color=cAccent, text_size=size.small, bgcolor=cBgAlt)
    for i = 0 to 9
        upperBound = 1.0 - i * 0.1
        lowerBound = 0.9 - i * 0.1
        isActive = prob >= lowerBound and prob <= upperBound
        isAbove50 = upperBound > 0.5
        cellCol = isActive ? (isAbove50 ? cBull : cBear) : cBgAlt
        cellLabel = isActive ? str.tostring(math.round(bullPct)) + "%" : ""
        table.cell(probBar, 0, i + 1, cellLabel,
             text_color=isActive ? color.white : cMute,
             bgcolor=cellCol, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast
    dash := table.new(f_pos(dashPos), 4, 22,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    table.cell(dash, 0, 0, "◆ NEURANET TREND PREDICTOR ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 3, 0)

    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period + " · MLP " + str.tostring(NF) + "-" + str.tostring(hiddenN) + "-1",
         text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 3, 1)

    // ─── PREDICTION ───
    table.cell(dash, 0, 2, "⚡ PREDICTION",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 3, 2)

    statusTxt = isReady ? "● LIVE" : "◐ WARMUP " + str.tostring(math.max(0, warmupBars - bar_index))
    statusCol = isReady ? cBull : cNeutral
    table.cell(dash, 0, 3, "Status", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 3, statusTxt, text_color=color.white, bgcolor=color.new(statusCol, 40),
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, "Signal", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 3, signalLabel, text_color=color.white, bgcolor=color.new(confCol, 20),
         text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 4, "Bull %", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(bullPct, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(cBull, math.round(100 - bullPct * 0.7)),
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, "Bear %", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 4, str.tostring(bearPct, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(cBear, math.round(100 - bearPct * 0.7)),
         text_halign=text.align_center, text_size=size.small)

    pctFilled = math.round(prob * 20)
    barStr = ""
    for i = 0 to 19
        barStr := barStr + (i < pctFilled ? (i < 10 ? "▓" : "█") : "░")
    table.cell(dash, 0, 5, "◀ Bear " + barStr + " Bull ▶",
         text_color=confCol, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 0, 5, 3, 5)

    confCol2 = confidence > 0.7 ? cBull : confidence > 0.4 ? cNeutral : cMute
    table.cell(dash, 0, 6, "Confidence", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(confidence * 100, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(confCol2, 40),
         text_halign=text.align_center, text_size=size.small)
    entrTxt = confidence > 0.7 ? "High Conv" : confidence > 0.4 ? "Moderate" : confidence > 0.2 ? "Low" : "Uncertain"
    table.cell(dash, 2, 6, "Quality", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 6, entrTxt, text_color=color.white, bgcolor=color.new(confCol2, 40),
         text_halign=text.align_center, text_size=size.small)

    // ─── NETWORK HEALTH ───
    table.cell(dash, 0, 7, "🧠 NETWORK HEALTH",
         text_color=color.white, bgcolor=color.new(cPurple, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 7, 3, 7)

    table.cell(dash, 0, 8, "Train Steps", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(trainSteps), text_color=cText, bgcolor=cBg,
         text_halign=text.align_center, text_size=size.small)
    accCol = rollAcc > 55 ? cBull : rollAcc > 50 ? cNeutral : cBear
    table.cell(dash, 2, 8, "Accuracy", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 8, str.tostring(rollAcc, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(accCol, 40),
         text_halign=text.align_center, text_size=size.small)

    lossCol = lossEMA < 0.5 ? cBull : lossEMA < 0.65 ? cNeutral : cBear
    table.cell(dash, 0, 9, "Loss (EMA)", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(lossEMA, "#.####"),
         text_color=color.white, bgcolor=color.new(lossCol, 40),
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 9, "Loss (100-bar)", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 9, str.tostring(recentLossMean, "#.####"),
         text_color=cText, bgcolor=cBg,
         text_halign=text.align_center, text_size=size.small)

    // ─── FEATURES ───
    table.cell(dash, 0, 10, "📊 NORMALIZED FEATURES",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 10, 3, 10)

    table.cell(dash, 0, 11, "Px/EMA", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 11, f_featTxt(f1), text_color=color.white, bgcolor=color.new(f_featCol(f1), 40), text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 11, "EMA Spr", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 11, f_featTxt(f2), text_color=color.white, bgcolor=color.new(f_featCol(f2), 40), text_halign=text.align_center, text_size=size.tiny)

    table.cell(dash, 0, 12, "RSI", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 12, f_featTxt(f3), text_color=color.white, bgcolor=color.new(f_featCol(f3), 40), text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 12, "ATR z", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 12, f_featTxt(f4), text_color=color.white, bgcolor=color.new(f_featCol(f4), 40), text_halign=text.align_center, text_size=size.tiny)

    table.cell(dash, 0, 13, "Vol z", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 13, f_featTxt(f5), text_color=color.white, bgcolor=color.new(f_featCol(f5), 40), text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 13, "MACD", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 13, f_featTxt(f6), text_color=color.white, bgcolor=color.new(f_featCol(f6), 40), text_halign=text.align_center, text_size=size.tiny)

    table.cell(dash, 0, 14, "BB Pos", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 14, f_featTxt(f7), text_color=color.white, bgcolor=color.new(f_featCol(f7), 40), text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 14, "DMI", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 14, f_featTxt(f8), text_color=color.white, bgcolor=color.new(f_featCol(f8), 40), text_halign=text.align_center, text_size=size.tiny)

    table.cell(dash, 0, 15, "Struct", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 15, f_featTxt(f9), text_color=color.white, bgcolor=color.new(f_featCol(f9), 40), text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 15, "Features", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 15, str.tostring(NF) + " dims", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)

    // ─── HYPERPARAMS ───
    table.cell(dash, 0, 16, "⚙ HYPERPARAMETERS",
         text_color=color.white, bgcolor=color.new(cPurple, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 16, 3, 16)
    table.cell(dash, 0, 17, "η (LR)", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 17, str.tostring(learnRate), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 17, "β (Mom)", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 17, str.tostring(momentum), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 0, 18, "λ (L2)", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 1, 18, str.tostring(l2Reg), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 18, "Hidden", text_color=cMute, bgcolor=cBg, text_size=size.tiny)
    table.cell(dash, 3, 18, str.tostring(hiddenN), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)

    // ─── VERDICT ───
    verdict = not isReady ? "◐ TRAINING... PLEASE WAIT" :
               prob > 0.8 and confidence > 0.7  ? "⚡ STRONG LONG CONVICTION" :
               prob > 0.65 and confidence > 0.5 ? "▲ Long bias" :
               prob < 0.2 and confidence > 0.7  ? "⚡ STRONG SHORT CONVICTION" :
               prob < 0.35 and confidence > 0.5 ? "▼ Short bias" :
                                                  "◆ Neural net undecided"
    verdictCol = not isReady ? cNeutral :prob > 0.65 ? cBull :prob < 0.35 ? cBear :cNeutral
    table.cell(dash, 0, 19, "VERDICT", text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 19, verdict, text_color=color.white, bgcolor=color.new(verdictCol, 20),
         text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 19, 3, 19)

    table.cell(dash, 0, 20, "AetherEdge NeuraNet · online-learning MLP",
         text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.merge_cells(dash, 0, 20, 3, 20)

// ═══════════════════════════════════════════════════════════════
//  MINI NETWORK DIAGRAM
// ═══════════════════════════════════════════════════════════════
var table netDiag = na
if barstate.islast and showNetwork
    netDiag := table.new(position.bottom_left, 3, 9, bgcolor=cBg,
         border_color=cBorder, border_width=1, frame_color=cPurple, frame_width=1)
    table.cell(netDiag, 0, 0, "🧠 NETWORK", text_color=cPurple, bgcolor=cBgAlt, text_size=size.small)
    table.merge_cells(netDiag, 0, 0, 2, 0)
    table.cell(netDiag, 0, 1, "INPUT", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.cell(netDiag, 1, 1, "HIDDEN", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.cell(netDiag, 2, 1, "OUTPUT", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)

    inputNames = array.from("Px","EMA","RSI","ATR","Vol","MACD")
    inputVals  = array.from(f1, f2, f3, f4, f5, f6)
    for i = 0 to 5
        v = array.get(inputVals, i)
        dotCol = v > 0.1 ? cBull : v < -0.1 ? cBear : cMute
        table.cell(netDiag, 0, i + 2, "● " + array.get(inputNames, i),
             text_color=dotCol, bgcolor=cBg, text_halign=text.align_left, text_size=size.tiny)

    for j = 0 to math.min(5, hiddenN - 1)
        act = array.get(hAct, j)
        hCol = act > 0.3 ? cBull : act < -0.3 ? cBear : cMute
        actBar = math.abs(act) > 0.7 ? "●●●" : math.abs(act) > 0.3 ? "●●" : "●"
        table.cell(netDiag, 1, j + 2, actBar + " h" + str.tostring(j),
             text_color=hCol, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)

    outSymbol = prob > 0.65 ? "▲▲" : prob > 0.55 ? "▲" : prob > 0.45 ? "◆" : prob > 0.35 ? "▼" : "▼▼"
    table.cell(netDiag, 2, 2, outSymbol, text_color=color.white, bgcolor=color.new(confCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(netDiag, 2, 3, str.tostring(bullPct, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(confCol, 40),
         text_halign=text.align_center, text_size=size.small)
    table.merge_cells(netDiag, 2, 2, 2, 3)
    for r = 4 to 7
        table.cell(netDiag, 2, r, "", bgcolor=cBg)
    table.cell(netDiag, 0, 8, "● = activation sign/magnitude",
         text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.merge_cells(netDiag, 0, 8, 2, 8)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSignal,  "NN Long Prediction",
     "AE-NNT: Neural net predicts LONG with high confidence on {{ticker}}")
alertcondition(shortSignal, "NN Short Prediction",
     "AE-NNT: Neural net predicts SHORT with high confidence on {{ticker}}")
alertcondition(ta.crossover(prob, 0.9),  "Extreme Bullish Conviction", "AE-NNT: Bull probability > 90%")
alertcondition(ta.crossunder(prob, 0.1), "Extreme Bearish Conviction", "AE-NNT: Bear probability > 90%")
````
