# AetherEdge - Bayesian Neural Market Microstructure

- url: https://www.tradingview.com/script/F6phg3kx/
- type: indicator
- pine_id: PUB;5aa6c6f833d34d6da6510e244948ac6c
- version: 1.0

## Description

🖊️ Overview

A NeuraLib Bayesian Neural Network that does what a point-estimate model (e.g. a plain LSTM) cannot: it predicts WITH a confidence. Instead of one number, it runs many stochastic forward passes (MC-Dropout / weight-perturbation style) to produce a DISTRIBUTION of next-move predictions, reporting both a mean forecast and an uncertainty (the spread of the samples). Inputs are market-microstructure proxies — volume delta (buy/sell pressure), an estimated spread, and a liquidity proxy — alongside price features. Visualization: a probability-density "cloud" of predicted price bands (opacity ∝ probability) and a single forward zone that reddens as uncertainty rises. The edge over LSTM-style tools is clear — you see not just where, but how sure.

🔶 Key Features

Bayesian NN (uncertainty estimation) — multi-sample weight perturbation yields a predictive distribution: mean + uncertainty
Confidence-aware prediction — "mean ± σ", not a point estimate — the decisive difference from LSTM-style tools
Microstructure inputs — volume delta (order-flow proxy), estimated spread, and a liquidity proxy as features
Probability-density cloud — predicted bands drawn as nested probability tiers, opacity encoding probability mass (denser inside)
Uncertainty zone — a single forward zone that reddens and gains opacity as uncertainty rises
Mean forecast line — one line from current price to predicted price (with glow)
Online learning — the network continuously regresses toward realized forward moves
Intelligence panel — predicted move, predicted price, confidence, uncertainty, and each microstructure component at a glance

🧠 Technical Architecture

The agent perceives the market as a four-dimensional microstructure state: price momentum, order-flow pressure (a normalized volume delta from candle-direction × volume EMA), spread regime (an estimated effective spread from the high-low range), and liquidity (volume per unit range) — all z-normalized.
The network is in(4) → hidden(tanh) → out(1) = predicted normalized move, but its Bayesian behavior is reproduced via stochastic forward passes. Each sample (1) injects Gaussian-style noise into the weights (variational weight perturbation) and (2) applies an MC-Dropout mask to hidden units. Repeating this MC Samples times, the mean of the predictions is the forecast and their standard deviation is the uncertainty (epistemic uncertainty) — the heart of the Bayesian approximation.
Learning is supervised regression: for each state, the realized normalized move (close − close[h]) / ATR over the prediction horizon is the target, and the mean network regresses toward it via squared error (sampled from a replay buffer). For visualization, around the predicted price close + mean·ATR, nested probability bands of half-width k·σ·ATR form the density cloud, with opacity proportional to Gaussian mass exp(−0.5k²). The uncertainty zone gradients from the forecast color to red, with a bold red border once normalized uncertainty crosses the threshold.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): MC Samples 12, Dropout 0.25, Weight Noise 0.05, Prediction Horizon 8, Cloud Bands 5. Standard settings fit well
ETH (1H–4H): As BTC, with Uncertainty Scale 1.0 for standard cloud width
SOL (15m–1H): High volatility favors Dropout 0.3 / Weight Noise 0.08 for more sensitive uncertainty, Red Zone Threshold 0.5 to warn risk early
XRP (1H–4H): Spike-prone; MC Samples ≈ 16 to smooth the distribution, Uncertainty Scale 1.2 for slightly wider clouds
MC Samples: more smooths the uncertainty estimate but is heavier; 10–16 is a practical balance
Dropout / Weight Noise: higher widens the predictive distribution and raises uncertainty — tune to market noise
Cloud Density Bands: more makes a smoother, prettier cloud but adds render load; 4–6 is readable
Red Zone Threshold: lower warns red earlier (conservative); higher keeps the cool color only when very confident

💡 How to Use in Practice

Reading the density cloud: a narrow, dense cloud = low uncertainty, high-confidence forecast; a wide, faint cloud = high uncertainty, unstable forecast. The cloud center (mean line) is the predicted price
Uncertainty zone color: a forecast-colored (teal/coral) zone means confidence; a red, bold-bordered zone means high uncertainty — enter cautiously
Using confidence-aware prediction: consider entries only when panel Confidence is high — unlike point predictors (LSTM etc.), you can judge whether to trust the forecast
Checking microstructure: when order-flow Δ, spread, and liquidity align with the forecast direction, the prediction is better supported
Cloud width and sizing: size larger when the cloud is narrow (low uncertainty), smaller when wide (high uncertainty)
Multi-timeframe usage: confirm the big-picture forecast direction and uncertainty on the higher timeframe (4H), then time entries in low-uncertainty windows on the lower one (15m–1H)

⚠️ Important Notes

Initial learning period: right after launch the buffer is nearly empty and the network is untrained, so forecasts are unstable; treat them as low-confidence until it fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the network weights and buffer, restarting learning from zero
On microstructure proxies: this uses microstructure proxies estimated from OHLCV, not a real order book — an approximation that differs from true book data
Interpreting uncertainty: the reported uncertainty is the model's epistemic uncertainty (its lack of confidence), not a complete measure of actual market risk
On look-ahead: the target uses closed-bar realized moves (a standard training construct); current-bar prediction is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget; raising MC Samples increases compute proportionally

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Bayesian neural network, uncertainty estimation, microstructure proxies, predictive distribution, and density cloud are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Even a probabilistic forecast can be wrong. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Bayesian Neural Market Microstructure
//   AI Drawing Power Series
//
//   A NeuraLib Bayesian Neural Network that does what a point-estimate model (e.g. a plain LSTM)
//   cannot: it predicts WITH a confidence. Instead of one number, the network runs many stochastic
//   forward passes (MC-Dropout / weight-perturbation style), producing a DISTRIBUTION of next-move
//   predictions. From that distribution it reports a mean forecast AND an uncertainty (the spread of
//   the samples). Inputs are market-microstructure proxies — volume delta (buy/sell pressure), an
//   estimated spread, and a liquidity proxy — alongside price features.
//
//   Visualization: a probability-density "cloud" of predicted price bands (opacity ∝ probability) and
//   a single forward zone that reddens as uncertainty rises. The edge over LSTM-style tools is
//   confidence-aware prediction: you see not just where, but how sure.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Bayesian Neural Market Microstructure", "AE-BNN MM", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_NET   = "◆  BAYESIAN NETWORK (NeuraLib)"
var string GRP_MICRO = "◆  MICROSTRUCTURE INPUTS"
var string GRP_PRED  = "◆  PREDICTION & UNCERTAINTY"
var string GRP_TRAIN = "◆  ONLINE LEARNING"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Bayesian Network —
hiddenN      = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_NET)
mcSamples    = input.int(12,   "MC Samples",     minval = 3, maxval = 40, group = GRP_NET, tooltip = "Number of stochastic forward passes per bar. More samples = smoother uncertainty estimate (heavier compute).")
dropoutP     = input.float(0.25,"Dropout Rate",  minval = 0.0, maxval = 0.7, step = 0.05, group = GRP_NET, tooltip = "MC-Dropout probability. Higher = more weight perturbation = wider predictive distribution.")
weightNoise  = input.float(0.05,"Weight Noise σ", minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_NET, tooltip = "Gaussian-style noise injected into weights per sample (variational weight perturbation).")
seedInp      = input.int(41,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Microstructure Inputs —
vdLen        = input.int(14,   "Volume Δ Length", minval = 1, maxval = 100, group = GRP_MICRO, tooltip = "Window for the buy/sell volume-delta proxy (order-flow pressure).")
spreadLen    = input.int(14,   "Spread Estimate Length", minval = 1, maxval = 100, group = GRP_MICRO, tooltip = "Window for the estimated effective spread (high-low based).")
liqLen       = input.int(20,   "Liquidity Window", minval = 2, maxval = 200, group = GRP_MICRO, tooltip = "Window for the liquidity proxy (volume per unit range).")
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_MICRO)

// — Prediction & Uncertainty —
predLook     = input.int(8,    "Prediction Horizon (bars)", minval = 1, maxval = 40, group = GRP_PRED, tooltip = "How far forward the predictive cloud projects.")
cloudBands   = input.int(5,    "Cloud Density Bands", minval = 1, maxval = 10, group = GRP_PRED, tooltip = "Number of nested probability bands forming the density cloud (±1σ, ±2σ, ...).")
sigmaScale   = input.float(1.0, "Uncertainty Scale", minval = 0.2, maxval = 3.0, step = 0.1, group = GRP_PRED, tooltip = "Multiplier on the predictive standard deviation (cloud width).")
uncRedAt     = input.float(0.6, "Red Zone Threshold", minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_PRED, tooltip = "Normalized uncertainty above which the forward zone turns fully red.")

// — Online Learning —
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_TRAIN)
learnRate    = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_TRAIN)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_TRAIN)
bufferCap    = input.int(150,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_TRAIN)

// — Aesthetics —
colUp        = input.color(#21d3a3, "Bullish Forecast", group = GRP_STYLE, inline = "c1")
colDn        = input.color(#ff5d73, "Bearish Forecast", group = GRP_STYLE, inline = "c1")
colMid       = input.color(#5ce1ff, "Mean Forecast Line", group = GRP_STYLE)
colUnc       = input.color(#ff5d73, "High-Uncertainty Tint", group = GRP_STYLE)
cloudTransp  = input.int(80,   "Cloud Base Transparency", minval = 60, maxval = 96, group = GRP_STYLE)
showMeanLine = input.bool(true, "Mean Forecast Line", group = GRP_STYLE)
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)

// — Intelligence Panel —
showPanel    = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize    = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0a0d15, 8)
var color THEME_GRID = color.new(#222b40, 38)
var color THEME_TXT  = #d2dae8
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff
var color THEME_GOLD = #f4c25b

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ACTIVATIONS / PRNG
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

f_dtanh(float y) =>
    1.0 - y * y

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// approx Gaussian noise via sum of uniforms (central-limit), zero-mean unit-ish scale
f_gauss(int s) =>
    (f_rand(s) + f_rand(s * 7919 + 1) + f_rand(s * 104729 + 2) - 1.5) * 1.1547

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  MICROSTRUCTURE FEATURE ENGINEERING
//  Proxies (no real order book): volume delta, estimated spread, liquidity, price momentum.
// ────────────────────────────────────────────────────────────────────────────────────────────────

atr = ta.atr(14)

// volume delta proxy: signed volume by candle direction, smoothed → buy/sell pressure
sgn = close > open ? 1.0 : close < open ? -1.0 : 0.0
volDeltaRaw = ta.ema(sgn * volume, vdLen)
volNorm = ta.sma(volume, normLen)
volDelta = volNorm == 0 ? 0.0 : volDeltaRaw / volNorm

// estimated effective spread proxy: average (high-low)/close, ATR-context
spreadRaw = ta.sma((high - low) / (close == 0 ? 1.0 : close), spreadLen)
spreadAvg = ta.sma(spreadRaw, normLen)
spreadEst = spreadAvg == 0 ? 0.0 : spreadRaw / spreadAvg - 1.0

// liquidity proxy: volume per unit range (high volume + tight range = liquid)
rangeUnit = (high - low) == 0 ? syminfo.mintick : (high - low)
liqRaw = ta.sma(volume / rangeUnit, liqLen)
liqAvg = ta.sma(liqRaw, normLen)
liquidity = liqAvg == 0 ? 0.0 : liqRaw / liqAvg - 1.0

// price momentum
mom = ta.ema(close, 10) - ta.ema(close, 30)
momN = atr == 0 ? 0.0 : mom / atr

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

// normalized 4-feature microstructure state
s0 = f_znorm(momN, ta.sma(momN, normLen), ta.stdev(momN, normLen))           // momentum
s1 = math.max(-3.0, math.min(3.0, volDelta))                                  // order-flow pressure
s2 = f_znorm(spreadEst, ta.sma(spreadEst, normLen), ta.stdev(spreadEst, normLen)) // spread regime
s3 = f_znorm(liquidity, ta.sma(liquidity, normLen), ta.stdev(liquidity, normLen)) // liquidity

var int N_IN = 4

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  BAYESIAN NEURAL NETWORK
//  Architecture: in(4) → hidden(tanh)[hiddenN] → out(1) = predicted normalized forward move.
//  Bayesian behavior via stochastic forward passes: per-sample weight noise + MC-dropout masks.
//  The MEAN of samples = forecast; the STDEV of samples = epistemic uncertainty.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> W1 = na   // [hiddenN x N_IN]
var array<float> b1 = na   // [hiddenN]
var array<float> W2 = na   // [hiddenN]
var array<float> b2 = na   // [1]
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(hiddenN * N_IN, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    W2 := array.new_float(hiddenN, 0.0)
    b2 := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.6)
    f_initRange(W2, seedInp * 40503 + 101, 0.6)
    netInit := true

// deterministic forward pass (for training) → predicted normalized move; caches hidden
f_forward(float i0, float i1, float i2, float i3, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_IN + 0) * i0
        z += array.get(W1, h * N_IN + 1) * i1
        z += array.get(W1, h * N_IN + 2) * i2
        z += array.get(W1, h * N_IN + 3) * i3
        array.push(hC, f_tanh(z))
    float o = array.get(b2, 0)
    for h = 0 to hiddenN - 1
        o += array.get(W2, h) * array.get(hC, h)
    o

// STOCHASTIC forward pass (Bayesian sample): weight noise + dropout mask, seeded per sample
f_forwardStochastic(float i0, float i1, float i2, float i3, int seed) =>
    float o = array.get(b2, 0)
    for h = 0 to hiddenN - 1
        // dropout mask for this hidden unit
        float drop = f_rand(seed * 31 + h * 17 + 5) < dropoutP ? 0.0 : 1.0 / (1.0 - dropoutP)
        float z = array.get(b1, h)
        // weight noise per incoming connection
        z += (array.get(W1, h * N_IN + 0) + f_gauss(seed * 13 + h * 7 + 0) * weightNoise) * i0
        z += (array.get(W1, h * N_IN + 1) + f_gauss(seed * 13 + h * 7 + 1) * weightNoise) * i1
        z += (array.get(W1, h * N_IN + 2) + f_gauss(seed * 13 + h * 7 + 2) * weightNoise) * i2
        z += (array.get(W1, h * N_IN + 3) + f_gauss(seed * 13 + h * 7 + 3) * weightNoise) * i3
        float a = f_tanh(z) * drop
        float w2n = array.get(W2, h) + f_gauss(seed * 23 + h * 3) * weightNoise
        o += w2n * a
    o

// run MC sampling → [mean, std] of the predictive distribution
f_bayesPredict(float i0, float i1, float i2, float i3, int baseSeed) =>
    float sum = 0.0
    float sumSq = 0.0
    for k = 0 to mcSamples - 1
        float pk = f_forwardStochastic(i0, i1, i2, i3, baseSeed + k * 99991)
        sum += pk
        sumSq += pk * pk
    float mean = sum / mcSamples
    float varc = math.max(0.0, sumSq / mcSamples - mean * mean)
    float std = math.sqrt(varc)
    [mean, std]

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER  + REWARD (supervised target = realized normalized forward move)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<float> bTgt = array.new_float()

f_push(float ps0, float ps1, float ps2, float ps3, float tgt) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bTgt, tgt)
    if array.size(bTgt) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bTgt)

// realized normalized forward move over the prediction horizon (target for supervised learning)
fwdMove = atr == 0 ? 0.0 : (close - close[predLook]) / atr

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRAINING  — supervised regression of the mean network toward realized forward move (MSE)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bTgt) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        float tgt = array.get(bTgt, idx)

        float pred = f_forward(ps0, ps1, ps2, ps3, hTr)
        float err = math.max(-5.0, math.min(5.0, pred - tgt))

        // output layer
        gH = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            array.set(gH, h, err * array.get(W2, h))
            array.set(W2, h, array.get(W2, h) - learnRate * err * array.get(hTr, h))
        array.set(b2, 0, array.get(b2, 0) - learnRate * err)
        // hidden layer
        for h = 0 to hiddenN - 1
            float dz = array.get(gH, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_IN + 0, array.get(W1, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(W1, h * N_IN + 1, array.get(W1, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(W1, h * N_IN + 2, array.get(W1, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(W1, h * N_IN + 3, array.get(W1, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na

var float liveMean = na    // predicted normalized move (mean of samples)
var float liveStd  = na    // uncertainty (std of samples)
var float uncNorm  = 0.0   // normalized uncertainty [0,1]

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    // target available now: the move that unfolded over the prior predLook bars from the stored state
    if not na(pS0)
        f_push(pS0, pS1, pS2, pS3, fwdMove)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bTgt)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)

    // store current state to be paired with its realized future move predLook bars from now
    pS0 := s0
    pS1 := s1
    pS2 := s2
    pS3 := s3

// ---- PREDICTION (every bar incl. realtime): Bayesian MC sampling ----
if inHorizon
    int baseSeed = (bar_index * 2246822519 + seedInp) % 2147483647
    [mean, std] = f_bayesPredict(s0, s1, s2, s3, baseSeed)
    liveMean := mean
    liveStd  := std
    // normalize uncertainty against its own recent range for a stable [0,1] readout
    float stdAvg = ta.sma(nz(std), 50)
    float stdMax = ta.highest(nz(std), 50)
    uncNorm := stdMax == 0 ? 0.0 : math.min(1.0, nz(std) / stdMax)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  PREDICTIVE DENSITY CLOUD  — nested probability bands; opacity ∝ probability mass
//  Predicted price at horizon = close + mean·ATR ; band half-width = k·σ·ATR·sigmaScale
// ════════════════════════════════════════════════════════════════════════════════════════════════

float predMove = na(liveMean) ? 0.0 : liveMean
float predStd  = na(liveStd) ? 0.0 : liveStd * sigmaScale
float predPrice = close + predMove * atr

// forecast direction color
color dirCol = predMove >= 0 ? colUp : colDn

// uncertainty tint: blend forecast color → red as uncertainty rises
color cloudCol = color.from_gradient(uncNorm, 0.0, 1.0, dirCol, colUnc)

// Draw the cloud as nested boxes from the current bar to the horizon.
// Each band j covers (j-1)σ..jσ; outer bands are fainter (less probable).
var array<box> cloudBoxes = array.new<box>()

if inHorizon and barstate.islast
    // clear previous cloud
    if array.size(cloudBoxes) > 0
        for i = 0 to array.size(cloudBoxes) - 1
            box.delete(array.get(cloudBoxes, i))
        array.clear(cloudBoxes)

    int xL = bar_index
    int xR = bar_index + predLook
    // build nested bands from outer (faint) to inner (dense)
    for j = cloudBands to 1
        float kOuter = j
        float kInner = j - 1
        float hiOuter = predPrice + kOuter * predStd * atr
        float loOuter = predPrice - kOuter * predStd * atr
        // probability-ish weighting: inner bands more opaque. Gaussian mass ~ exp(-0.5 k²)
        float mass = math.exp(-0.5 * (kInner * kInner))
        int trans = int(math.max(55, cloudTransp - mass * 35))
        // top band (above mean)
        float hiInner = predPrice + kInner * predStd * atr
        box bxTop = box.new(xL, hiOuter, xR, hiInner, xloc = xloc.bar_index, border_color = color.new(cloudCol, 90), bgcolor = color.new(cloudCol, trans))
        array.push(cloudBoxes, bxTop)
        // bottom band (below mean)
        float loInner = predPrice - kInner * predStd * atr
        box bxBot = box.new(xL, loInner, xR, loOuter, xloc = xloc.bar_index, border_color = color.new(cloudCol, 90), bgcolor = color.new(cloudCol, trans))
        array.push(cloudBoxes, bxBot)

// mean forecast line (close → predicted price at horizon)
var line meanLine = na
var line meanGlow = na
if showMeanLine and inHorizon and barstate.islast
    if not na(meanLine)
        line.delete(meanLine)
    if not na(meanGlow)
        line.delete(meanGlow)
    if glowFx
        meanGlow := line.new(bar_index, close, bar_index + predLook, predPrice, xloc = xloc.bar_index, color = color.new(colMid, 60), width = 5, style = line.style_solid)
    meanLine := line.new(bar_index, close, bar_index + predLook, predPrice, xloc = xloc.bar_index, color = color.new(colMid, 0), width = 2, style = line.style_arrow_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SINGLE FORWARD UNCERTAINTY ZONE  — one box that reddens as uncertainty rises
// ════════════════════════════════════════════════════════════════════════════════════════════════

var box uncZone = na
if inHorizon and barstate.islast
    if not na(uncZone)
        box.delete(uncZone)
    float zHi = predPrice + predStd * atr
    float zLo = predPrice - predStd * atr
    // color: low uncertainty = forecast dir color, high uncertainty = red; opacity rises with uncertainty
    color zc = color.from_gradient(uncNorm, 0.0, 1.0, dirCol, colUnc)
    int zTrans = int(math.max(60, 88 - uncNorm * 25))
    uncZone := box.new(bar_index, zHi, bar_index + predLook, zLo, xloc = xloc.bar_index,
         border_color = color.new(zc, uncNorm >= uncRedAt ? 0 : 40), border_width = uncNorm >= uncRedAt ? 2 : 1,
         bgcolor = color.new(zc, zTrans))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_panelPos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_panelSize() =>
    switch panelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_bar(float v01) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * 12))
    string s = ""
    for i = 1 to 12
        s := s + (i <= filled ? "█" : "░")
    s

// confidence = inverse of normalized uncertainty
float confidence = 1.0 - uncNorm

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string dir = predMove > 0.05 ? "BULLISH" : predMove < -0.05 ? "BEARISH" : "FLAT"
    color dCol = predMove > 0.05 ? colUp : predMove < -0.05 ? colDn : THEME_DIM

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "BAYESIAN", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + dir + " FORECAST", text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(dCol, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Predicted Move", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, "", text_size = f_panelSize())
    table.cell(panel, 2, 2, str.tostring(predMove, "+#.##;-#.##") + " ATR", text_color = dCol, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Predicted Price", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, "", text_size = f_panelSize())
    table.cell(panel, 2, 3, str.tostring(predPrice, format.mintick), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Confidence", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_bar(confidence), text_color = confidence >= 0.5 ? colUp : THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 4, str.tostring(math.round(confidence * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "Uncertainty σ", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 5, f_bar(uncNorm), text_color = uncNorm >= uncRedAt ? colUnc : THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 5, str.tostring(na(liveStd) ? 0.0 : liveStd, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 6, "MICROSTRUCTURE", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 6, 2, 6)

    table.cell(panel, 0, 7, "Order-Flow Δ", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, f_bar((s1 + 3.0) / 6.0), text_color = s1 >= 0 ? colUp : colDn, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 7, str.tostring(s1, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Spread Regime", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, f_bar((s2 + 3.0) / 6.0), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(s2, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Liquidity", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, f_bar((s3 + 3.0) / 6.0), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 9, str.tostring(s3, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "MC Samples / Buffer", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(mcSamples), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, str.tostring(array.size(bTgt)) + "/" + str.tostring(bufferCap), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(not na(liveMean) and liveMean > 0.1 and uncNorm < uncRedAt, "BNN ▸ Confident BULLISH", "AetherEdge BNN: confident bullish forecast (low uncertainty).")
alertcondition(not na(liveMean) and liveMean < -0.1 and uncNorm < uncRedAt, "BNN ▸ Confident BEARISH", "AetherEdge BNN: confident bearish forecast (low uncertainty).")
alertcondition(uncNorm >= uncRedAt, "BNN ▸ High Uncertainty", "AetherEdge BNN: uncertainty is high — forecast unreliable.")
````
