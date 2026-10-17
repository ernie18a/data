# AetherEdge Neural Regime Switch

- url: https://www.tradingview.com/script/w1QQluia/
- type: indicator
- pine_id: PUB;e9cc27393ceb4b949f7341196a68aede
- version: 1.0

## Description

🖊️ Overview
AetherEdge Neural Regime Switch is the ultimate market regime classifier, fusing k-means clustering with a self-learning 3-layer feedforward neural network. It maps every bar into a 3-dimensional feature space and simultaneously evaluates Uptrend / Downtrend / Range probabilities through two independent AI models, ensembling them for maximum robustness. With nothing on your chart but pure regime-coded background coloring, it serves as the most elegant top-level directional filter in your trading arsenal.

🔶 Key Features

3D feature-space k-means clustering: directional strength, efficiency ratio, volatility Z-score
3→4→3 feedforward neural network with sigmoid activation and softmax output
Online gradient-descent learning using 5-bar realized returns as supervisory signal
Ensemble fusion of k-means and NN probabilities for resilience
Three-regime classification with independent probability streams
Smoothing mechanism requiring N consecutive bars to confirm regime switches
Ultra-minimal visualization: background color only — zero clutter
Three independent alerts for instant regime change notifications
🧠 Technical Architecture

1. Feature Extraction Layer (3D Regime Space)

fA — Directional Strength: 20-bar slope normalized by ATR
fB — Efficiency Ratio: ADX-like path efficiency (1 = trending, 0 = ranging)
fC — Volatility Regime: 50-bar Z-score of Bollinger Band width
2. K-Means Clustering Layer
Three persistent centroids (cBull, cBear, cRng) live in 3D space. Each bar runs kIter EM iterations across a rolling lookback window, then current-bar distances are inverse-normalized into soft probabilities (pBull_km, pBear_km, pRange_km).

3. Neural Network Layer (3→4→3)
3D input → 4 sigmoid hidden nodes → 3 softmax outputs. Output-layer weights update via online gradient descent using 5-bar lagged targets (realized return vs ATR × 0.5), letting the network continuously adapt to evolving market dynamics.

4. Ensemble Fusion + Smoothing
K-means and NN probabilities are blended 50:50 and gated through trendThresh/rangeThresh. Regime switches require smoothBars consecutive confirmations, eliminating flicker and false transitions.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults

BTC (1H–4H): Lookback 150, kIter 8, NN Rate 0.08, Smoothing 3
ETH (30m–2H): Lookback 180, kIter 10, NN Rate 0.06, Smoothing 4
SOL (15m–1H): Lookback 120, kIter 6, NN Rate 0.10, Smoothing 2
XRP (1H–4H): Lookback 150, kIter 8, NN Rate 0.08, Smoothing 3
Parameter Tuning

Lookback: 300–500 for macro analysis; 80–120 for scalping
k-means Iterations: 10–15 in volatile regimes; 8 typically sufficient
NN Learning Rate: 0.10–0.15 in choppy markets; 0.03–0.05 in stable trends
Trend Confidence: 0.55 balanced; ≥0.65 conservative high-conviction
Smoothing Bars: 1–2 on low TFs; 5–8 on high TFs for persistence
💡 How to Use in Practice

Scenario 1 — Master Directional Filter
Green = long-only, red = short-only, blue = mean-reversion / grid / option-selling. The cleanest top-level regime gate for any strategy.

Scenario 2 — Regime-Switch Alerts
Blue → green transitions mark fresh uptrend ignitions — premium entry windows. Set alerts and stop watching the screen.

Scenario 3 — Range-to-Trend Breakout
Extended blue followed by green/red = volatility expansion plus emerging direction — the perfect launchpad for breakout strategies.

Multi-Timeframe Workflow
Confirm direction on 4H → choose strategy class on 1H → execute entries on 15m. Pairs seamlessly with S/R, momentum, and order-flow tools.

⚠️ Important Notes

Centroids stabilize only after the lookback window fills (warm-up phase)
NN weights reset to defaults on chart reload
Smoothing may briefly delay response during sharp regime shifts
K-means can converge to local minima; avoid extreme parameter values
🚨 Disclaimer
This indicator is provided for educational and analytical purposes only and does not constitute financial advice. All trading decisions remain your sole responsibility. Past performance does not guarantee future results, and crypto markets carry substantial risk.

## Source Code

````pine
//@version=5
indicator("AetherEdge Neural Regime Switch", shorttitle="AE-RegimeSwitch", overlay=true)

// ============================================================
// ▼ INPUTS
// ============================================================
grpAI       = "🧠 Neural Engine"
lookback    = input.int(150,  "Clustering Window",       minval=50, maxval=500, group=grpAI)
kIter       = input.int(8,    "k-means Iterations",      minval=3,  maxval=20,  group=grpAI)
nnLearnRate = input.float(0.08,"NN Learning Rate",       minval=0.01,maxval=0.5,step=0.01,group=grpAI)
hiddenBias  = input.float(0.5, "Hidden Layer Bias",      minval=0.0,maxval=1.0,step=0.05,group=grpAI)

grpReg      = "🎯 Regime Sensitivity"
trendThresh = input.float(0.55,"Trend Confidence",       minval=0.4,maxval=0.9, step=0.01, group=grpReg)
rangeThresh = input.float(0.50,"Range Confidence",       minval=0.4,maxval=0.9, step=0.01, group=grpReg)
smoothBars  = input.int(3,    "Regime Smoothing",        minval=1,  maxval=10,  group=grpReg)

grpVis      = "🎨 Visual"
bgTrans     = input.int(80,   "Background Transparency", minval=50, maxval=95,  group=grpVis)
colBull     = input.color(color.green, "Uptrend Color",  group=grpVis)
colBear     = input.color(color.red,   "Downtrend Color",group=grpVis)
colRange    = input.color(color.blue,  "Range Color",    group=grpVis)

// ============================================================
// ▼ FEATURE EXTRACTION (3-Dimensional Regime Space)
// ============================================================
// Feature A: Directional Strength (slope normalized by ATR)
slope     = (close - close[20]) / 20
atrVal    = ta.atr(20)
fA_raw    = slope / (atrVal + 1e-10)
fA        = math.max(-3.0, math.min(3.0, fA_raw))

// Feature B: Range/Trend Ratio (ADX-like efficiency)
priceMove = math.abs(close - close[14])
pathSum   = 0.0
for i = 0 to 13
    pathSum += math.abs(close[i] - close[i+1])
efficiency = pathSum > 0 ? priceMove / pathSum : 0.0
fB         = efficiency  // 0..1 (high = trending, low = ranging)

// Feature C: Volatility Regime (BB width z-score)
basis     = ta.sma(close, 20)
dev       = ta.stdev(close, 20)
bbWidth   = (4 * dev) / basis
bbWidthMA = ta.sma(bbWidth, 50)
bbWidthSD = ta.stdev(bbWidth, 50)
fC_raw    = bbWidthSD > 0 ? (bbWidth - bbWidthMA) / bbWidthSD : 0.0
fC        = math.max(-3.0, math.min(3.0, fC_raw))

// ============================================================
// ▼ K-MEANS CLUSTERING (3 centroids: Bull / Bear / Range)
// ============================================================
// Persistent centroid storage (3D space: fA, fB, fC)
var float cBull_A = 1.5,  cBull_B = 0.7,  cBull_C = 0.5
var float cBear_A = -1.5, cBear_B = 0.7,  cBear_C = 0.5
var float cRng_A  = 0.0,  cRng_B  = 0.2,  cRng_C  = -0.5

// Distance helper
distSq(aA, aB, aC, bA, bB, bC) =>
    (aA-bA)*(aA-bA) + (aB-bB)*(aB-bB) + (aC-bC)*(aC-bC)

// Online k-means update (per bar, lightweight)
if bar_index > lookback
    // Use historical sample window for stable centroids
    var array<float> winA = array.new<float>(0)
    var array<float> winB = array.new<float>(0)
    var array<float> winC = array.new<float>(0)
    
    array.push(winA, fA)
    array.push(winB, fB)
    array.push(winC, fC)
    if array.size(winA) > lookback
        array.shift(winA)
        array.shift(winB)
        array.shift(winC)
    
    // Run k-means iterations
    sz = array.size(winA)
    for iter = 1 to kIter
        sumBA = 0.0, sumBB = 0.0, sumBC = 0.0, cntB = 0
        sumSA = 0.0, sumSB = 0.0, sumSC = 0.0, cntS = 0
        sumRA = 0.0, sumRB = 0.0, sumRC = 0.0, cntR = 0
        
        for i = 0 to sz - 1
            pA = array.get(winA, i)
            pB = array.get(winB, i)
            pC = array.get(winC, i)
            dB = distSq(pA, pB, pC, cBull_A, cBull_B, cBull_C)
            dS = distSq(pA, pB, pC, cBear_A, cBear_B, cBear_C)
            dR = distSq(pA, pB, pC, cRng_A,  cRng_B,  cRng_C)
            
            if dB <= dS and dB <= dR
                sumBA += pA, sumBB += pB, sumBC += pC, cntB += 1
            else if dS <= dB and dS <= dR
                sumSA += pA, sumSB += pB, sumSC += pC, cntS += 1
            else
                sumRA += pA, sumRB += pB, sumRC += pC, cntR += 1
        
        if cntB > 0
            cBull_A := sumBA / cntB
            cBull_B := sumBB / cntB
            cBull_C := sumBC / cntB
        if cntS > 0
            cBear_A := sumSA / cntS
            cBear_B := sumSB / cntS
            cBear_C := sumSC / cntS
        if cntR > 0
            cRng_A  := sumRA / cntR
            cRng_B  := sumRB / cntR
            cRng_C  := sumRC / cntR

// Compute distances of CURRENT bar to each centroid
dCurB = math.sqrt(distSq(fA, fB, fC, cBull_A, cBull_B, cBull_C))
dCurS = math.sqrt(distSq(fA, fB, fC, cBear_A, cBear_B, cBear_C))
dCurR = math.sqrt(distSq(fA, fB, fC, cRng_A,  cRng_B,  cRng_C))

// Convert distances to soft probabilities (inverse, normalized)
invB = 1.0 / (dCurB + 0.1)
invS = 1.0 / (dCurS + 0.1)
invR = 1.0 / (dCurR + 0.1)
sumInv = invB + invS + invR
pBull_km  = invB / sumInv
pBear_km  = invS / sumInv
pRange_km = invR / sumInv

// ============================================================
// ▼ SIMPLE NEURAL NETWORK (3→4→3 feedforward, sigmoid)
// ============================================================
// Persistent weights (input → hidden, hidden → output)
var float w_ih_11 = 0.3,  w_ih_12 = -0.2, w_ih_13 = 0.4,  w_ih_14 = 0.1
var float w_ih_21 = 0.2,  w_ih_22 = 0.5,  w_ih_23 = -0.1, w_ih_24 = 0.3
var float w_ih_31 = -0.1, w_ih_32 = 0.2,  w_ih_33 = 0.3,  w_ih_34 = -0.2

var float w_ho_11 = 0.4,  w_ho_12 = -0.3, w_ho_13 = 0.1
var float w_ho_21 = -0.2, w_ho_22 = 0.3,  w_ho_23 = 0.2
var float w_ho_31 = 0.3,  w_ho_32 = -0.1, w_ho_33 = -0.4
var float w_ho_41 = 0.1,  w_ho_42 = 0.2,  w_ho_43 = 0.3

// Activation
sigmoid(x) => 1.0 / (1.0 + math.exp(-x))

// Forward pass — hidden layer
h1 = sigmoid(w_ih_11*fA + w_ih_21*fB + w_ih_31*fC + hiddenBias)
h2 = sigmoid(w_ih_12*fA + w_ih_22*fB + w_ih_32*fC + hiddenBias)
h3 = sigmoid(w_ih_13*fA + w_ih_23*fB + w_ih_33*fC + hiddenBias)
h4 = sigmoid(w_ih_14*fA + w_ih_24*fB + w_ih_34*fC + hiddenBias)

// Forward pass — output layer (raw scores)
oBull  = w_ho_11*h1 + w_ho_21*h2 + w_ho_31*h3 + w_ho_41*h4
oBear  = w_ho_12*h1 + w_ho_22*h2 + w_ho_32*h3 + w_ho_42*h4
oRange = w_ho_13*h1 + w_ho_23*h2 + w_ho_33*h3 + w_ho_43*h4

// Softmax
expB = math.exp(oBull)
expS = math.exp(oBear)
expR = math.exp(oRange)
sumE = expB + expS + expR
pBull_nn  = expB / sumE
pBear_nn  = expS / sumE
pRange_nn = expR / sumE

// ============================================================
// ▼ ONLINE LEARNING (gradient nudge based on realized outcome)
// ============================================================
// Target label from realized future-ish move (use 5-bar lag)
if bar_index > 30
    realRet = close - close[5]
    realVol = ta.atr(5)[5]
    target_Bull  = realRet >  realVol*0.5 ? 1.0 : 0.0
    target_Bear  = realRet < -realVol*0.5 ? 1.0 : 0.0
    target_Range = (math.abs(realRet) <= realVol*0.5) ? 1.0 : 0.0
    
    // Past forward output (recompute roughly)
    errBull  = target_Bull  - pBull_nn[5]
    errBear  = target_Bear  - pBear_nn[5]
    errRange = target_Range - pRange_nn[5]
    
    // Update output layer weights (simplified gradient descent)
    w_ho_11 := w_ho_11 + nnLearnRate * errBull  * h1[5]
    w_ho_12 := w_ho_12 + nnLearnRate * errBear  * h1[5]
    w_ho_13 := w_ho_13 + nnLearnRate * errRange * h1[5]
    w_ho_21 := w_ho_21 + nnLearnRate * errBull  * h2[5]
    w_ho_22 := w_ho_22 + nnLearnRate * errBear  * h2[5]
    w_ho_23 := w_ho_23 + nnLearnRate * errRange * h2[5]
    w_ho_31 := w_ho_31 + nnLearnRate * errBull  * h3[5]
    w_ho_32 := w_ho_32 + nnLearnRate * errBear  * h3[5]
    w_ho_33 := w_ho_33 + nnLearnRate * errRange * h3[5]
    w_ho_41 := w_ho_41 + nnLearnRate * errBull  * h4[5]
    w_ho_42 := w_ho_42 + nnLearnRate * errBear  * h4[5]
    w_ho_43 := w_ho_43 + nnLearnRate * errRange * h4[5]

// ============================================================
// ▼ ENSEMBLE FUSION (k-means + NN)
// ============================================================
pBull  = (pBull_km  + pBull_nn)  * 0.5
pBear  = (pBear_km  + pBear_nn)  * 0.5
pRange = (pRange_km + pRange_nn) * 0.5

// ============================================================
// ▼ REGIME DECISION + SMOOTHING
// ============================================================
// 0 = Range, 1 = Bull, 2 = Bear
rawRegime = pBull >= trendThresh and pBull > pBear and pBull > pRange ? 1 :pBear >= trendThresh and pBear > pBull and pBear > pRange ? 2 :pRange >= rangeThresh ? 0 :pBull > pBear and pBull > pRange ? 1 :pBear > pBull and pBear > pRange ? 2 : 0

// Smoothing: require N consecutive bars to switch
var int regime = 0
var int countSame = 0
if rawRegime == regime
    countSame := 0
else
    countSame += 1
    if countSame >= smoothBars
        regime := rawRegime
        countSame := 0

// ============================================================
// ▼ VISUAL — BACKGROUND COLOR ONLY (no lines, no shapes)
// ============================================================
bgCol = regime == 1 ? color.new(colBull,  bgTrans) :regime == 2 ? color.new(colBear,  bgTrans) :color.new(colRange, bgTrans)

bgcolor(bgCol, title="Regime Background")

// ============================================================
// ▼ ALERTS
// ============================================================
regimeChanged = regime != regime[1]
alertcondition(regime == 1 and regime[1] != 1, title="Switch → Uptrend",   message="AE Regime: Switched to UPTREND")
alertcondition(regime == 2 and regime[1] != 2, title="Switch → Downtrend", message="AE Regime: Switched to DOWNTREND")
alertcondition(regime == 0 and regime[1] != 0, title="Switch → Range",     message="AE Regime: Switched to RANGE")
````
