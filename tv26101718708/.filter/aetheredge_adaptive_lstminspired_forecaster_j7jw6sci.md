# AetherEdge Adaptive LSTM-inspired Forecaster

- url: https://www.tradingview.com/script/j7jW6SCI/
- type: indicator
- pine_id: PUB;f4b3c5eaf08e4e069373fc10ebc1a37e
- version: 1.0

## Description

🖊️ Overview
AetherEdge Adaptive LSTM-inspired Forecaster is a next-generation price forecasting engine that recreates the core machinery of the LSTM (Long Short-Term Memory) neural network—the cornerstone of deep learning—directly in Pine Script. Featuring a multi-layered memory structure of forget, input, output gates and cell state, augmented by an Attention mechanism that dynamically references the most relevant past moments, plus residual connections that bypass training instability, it fuses multi-timeframe features to render 1–30 bar price forecasts and uncertainty bands with exceptional fidelity.

🔶 Key Features

LSTM-style Cell: Full implementation of forget/input/output gates + cell state
Parallel Hidden Units: 3–16 units with diverse time constants τ for layered memory
Attention Mechanism: Similarity + recency-decayed weighted context
Residual Connection: Skip connection bypassing vanishing-gradient pitfalls
Multi-Timeframe Features: HTF (1H) + HHTF (4H) hierarchical inputs
8-D Input Vector: retZ / volZ / RSI / Slope / Mom / HTF Ret / HTF Bias / HHTF Bias
Multi-Step Forecast: 1–30 bar projection lines
Uncertainty Bands: √t-decay confidence intervals (inner 1σ / outer 2σ)
3 Band Methods: Residual Std / ATR / Hybrid
Hidden Unit Visualization: τ, Cell, Hidden & activity bars per unit
Attention Heatmap: 30-bar attention weight distribution
Hit Score: Real-time evaluation of last forecast accuracy
Bullish/Bearish Flip & Band-Breach Alerts

🧠 Technical Architecture

This indicator is an industry-leading neural forecasting engine fully reconstructing the mathematical essence of LSTM, the apex of RNN-family models, in Pine Script.

LSTM Cell Equations (per unit u):
Forget Gate f_t = σ(W_f · x_t + b_f) — past memory retention
Input Gate i_t = σ(W_i · x_t + b_i) — new information intake
Candidate g_t = tanh(W_g · x_t + b_g) — new memory candidate
Output Gate o_t = σ(W_o · x_t + b_o) — exposure to hidden state
Cell Update c_t = f_t ⊙ c_{t-1} + i_t ⊙ g_t
Hidden h_t = o_t ⊙ tanh(c_t)
τ Diversity: Each unit assigned distinct τ, processing short-to-long memory in parallel
Pseudo-Weight Generation: Deterministic sin/cos phase for stable initialization
MTF Influence Boost: Input gate amplified by HHTF Bias magnitude
Attention:
Score = h_curr × h_past − |h_curr − h_past|×0.5 + recency decay
Softmax normalization (temperature-adjustable) → context = weighted mean
Residual Path: Upper-half units add raw retZ × residualMix × (1-τ)
Output Projection: h_aggregated × σ_returns × 0.5 + Attention + Residual contributions
Uncertainty Model: σ_h = σ_base × fanOut^h × √h (band widens with horizon)
Decay Forecast: Multi-step uses stepRet × 0.82^(h-1) (extrapolation decay suppresses overshoot)

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–D): Hidden=8, Seq=30, Forecast=10 (standard)
ETH (1H–4H): Hidden=10, Seq=40, MTF Weight=0.4
SOL (high-vol): Hidden=12, Forget=0.88, fanOut=1.20
XRP (short-bias): Hidden=6, Seq=20, Forecast=5
Hidden Units (Memory Capacity):

3–5: Lightweight, short-pattern specialized
8: Standard (recommended)
12–16: Rich memory, heavier compute
Sequence Length (Attention Range):

20: Recency-focused
30: Standard
50–100: Long context, lower TFs
Learning Rate α (lrBase):

0.05–0.10: Conservative, smooth
0.15: Standard
0.25–0.50: Agile, noisier
Forget Gate Base:

0.85–0.90: Agile forgetting, regime-shift responsive
0.92: Standard
0.95–0.98: Long memory, range-favoring
Attention Temperature:

0.5–1.0: Sharp focus, specific-pattern referencing
1.5: Standard
2.5–5.0: Even attention, stable but dull
Band Method:

Residual Std: Empirical, most precise
ATR: Simple, valid early
Hybrid: Geometric mean, robust

💡 How to Use in Practice

Strong Bullish Forecast: σ-breach prediction + positive attention = long entry
Strong Bearish Forecast: Opposite, short consideration
Band Breach: Price exceeded ±2σ band, overheating warning
Forecast Flip: expectedRet zero-cross, early regime-shift signal
Hit Score > 70%: Last forecast accurate, current trustworthy
Hit Score < 40%: Sudden volatility regime, low confidence—wait
Hidden Unit Activity: Multiple units same direction = strong consensus; mixed = regime transition
Attention Heatmap purple-dominant: Strong reference to past similar pattern, repeating-scenario likely
Attention dispersed: No precedent, novel territory—tread cautiously
AetherEdge Synergy:
KNN Regime Classifier: Trending▲ + LSTM bullish forecast = dual AI conviction
NeuraNet Predictor: Direction agreement amplifies signal
Self-Evolving S/R Grid: LSTM band edges ≈ S/R lines = strong reaction candidates
All-in-One Dashboard: HIGH-CONVICTION + Hit Score > 70% = ultimate alignment
Multi-TF: 4H LSTM direction → 1H strategy selection → 15M precision entry

⚠️ Important Notes

Pseudo-Weights: No pre-trained weights; deterministic phase-based approximation
Learning Reset: Cell states wipe on reload; rebuild required
First 50 Bars: States unfinalized, forecasts invalid
Compute Load: Hidden=16 + Seq=100 is heavy; use 8/30 on low-spec
MTF lookahead_off: No future-peeking, real-time integrity guaranteed
Multi-Step Drift: Error accumulates with horizon; Forecast=5–10 recommended
Bands are Probabilistic: σ-range exceedance can occur; not absolute ceilings/floors

🚨 Disclaimer

This indicator is a deep-learning-inspired forecasting model provided for educational and research purposes only and does not constitute financial advice. LSTM-style predictions are mathematical approximations and do not guarantee future profits. Forecast accuracy depends on market conditions, asset, and timeframe. Combine with independent analysis and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Adaptive LSTM-inspired Forecaster", "AE-LSTM",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=500,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpN = "🧠 Network Architecture"
nHidden      = input.int(8, "Hidden Units", minval=3, maxval=16, group=grpN,
     tooltip="Number of parallel 'cell' units. More = richer memory, slower.")
seqLen       = input.int(30, "Sequence Length", minval=10, maxval=100, group=grpN,
     tooltip="Number of past timesteps attention scans over.")
forecastBars = input.int(10, "Forecast Horizon", minval=1, maxval=30, group=grpN)
lrBase       = input.float(0.15, "Base Learning Rate α", step=0.01, minval=0.01, maxval=0.5, group=grpN,
     tooltip="Base smoothing factor for cell states (analogous to input gate strength).")
forgetBase   = input.float(0.92, "Forget Gate Base", step=0.01, minval=0.5, maxval=0.99, group=grpN,
     tooltip="Base retention of previous cell state. Higher = longer memory.")

grpMTF = "🌐 Multi-Timeframe Features"
useMTF       = input.bool(true, "Enable MTF Inputs", group=grpMTF)
tfHigher     = input.timeframe("60",  "Higher TF", group=grpMTF)
tfHighest    = input.timeframe("240", "Highest TF", group=grpMTF)
mtfWeight    = input.float(0.35, "MTF Influence", step=0.05, minval=0.0, maxval=1.0, group=grpMTF)

grpA = "🎯 Attention & Residual"
useAttention = input.bool(true,  "Enable Attention Mechanism", group=grpA)
useResidual  = input.bool(true,  "Enable Residual Connection", group=grpA)
residualMix  = input.float(0.25, "Residual Mix Weight", step=0.05, minval=0.0, maxval=0.8, group=grpA,
     tooltip="Fraction of raw price change added to gated output (skip connection).")
attTemp      = input.float(1.5,  "Attention Temperature", step=0.1, minval=0.3, maxval=5.0, group=grpA,
     tooltip="Lower = sharper focus on single best match, Higher = softer averaging.")

grpU = "📊 Forecast Bands"
bandMethod   = input.string("Residual Std", "Band Width Method",
     options=["Residual Std","ATR","Hybrid"], group=grpU)
bandMult1    = input.float(1.0, "Inner Band σ", step=0.1, group=grpU)
bandMult2    = input.float(2.0, "Outer Band σ", step=0.1, group=grpU)
fanOut       = input.float(1.15, "Band Fan-out per Bar", step=0.01, minval=1.0, maxval=1.5, group=grpU,
     tooltip="Uncertainty grows with forecast distance (√t scaling ≈ 1.10-1.20).")
residLen     = input.int(50, "Residual Window", minval=20, maxval=200, group=grpU)

grpD = "🎨 Display"
darkMode       = input.bool(true, "Dark Mode", group=grpD)
showForecast   = input.bool(true, "Show Forecast Line", group=grpD)
showBands      = input.bool(true, "Show Forecast Bands", group=grpD)
showCells      = input.bool(true, "Show Cell State Subplot", group=grpD)
showAttention  = input.bool(true, "Show Attention Heatmap", group=grpD)
showDashboard  = input.bool(true, "Show Dashboard", group=grpD)
dashPos        = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)
heatPos        = input.string("Bottom Right", "Heatmap Position",
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
cWarn    = color.new(#ffa500, 0)
cPurple  = color.new(#c084fc, 0)

// ═══════════════════════════════════════════════════════════════
//  GLOBAL HELPERS
// ═══════════════════════════════════════════════════════════════
f_sigmoid(x) =>
    1.0 / (1.0 + math.exp(-math.max(-20, math.min(20, x))))

f_tanh(x) =>
    xx = math.max(-20, math.min(20, x))
    e1 = math.exp(xx)
    e2 = math.exp(-xx)
    (e1 - e2) / (e1 + e2)

f_softplus(x) =>
    math.log(1.0 + math.exp(math.max(-20, math.min(20, x))))

f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// Pseudo-weights (deterministic, feature-aligned)
f_weight(unit, feat, nU) =>
    phase = (unit * 1.73 + feat * 2.41)
    0.6 * math.sin(phase) + 0.4 * math.cos(phase * 1.3)

f_bias(unit) =>
    0.1 * math.sin(unit * 0.7)

// ═══════════════════════════════════════════════════════════════
//  FEATURE ENGINEERING (input vector x_t)
// ═══════════════════════════════════════════════════════════════
src = close
logRet   = math.log(src / nz(src[1], src))
retMA    = ta.sma(logRet, 20)
retStd   = ta.stdev(logRet, 20) + 1e-9
retZ     = (logRet - retMA) / retStd

atr14    = ta.atr(14)
atrPct   = atr14 / src
volZ     = (atrPct - ta.sma(atrPct, 50)) / (ta.stdev(atrPct, 50) + 1e-9)

rsiVal   = ta.rsi(src, 14)
rsiNorm  = (rsiVal - 50) / 50

ema20    = ta.ema(src, 20)
ema50    = ta.ema(src, 50)
slopeRaw = (ema20 - ema50) / (atr14 + 1e-9)
slopeNorm = math.max(-3, math.min(3, slopeRaw)) / 3

mom10    = ta.roc(src, 10) / 100
momN     = math.max(-1, math.min(1, mom10 * 5))

// MTF features
htfClose  = useMTF ? request.security(syminfo.tickerid, tfHigher,  close, lookahead=barmerge.lookahead_off) : src
htfRsi    = useMTF ? request.security(syminfo.tickerid, tfHigher,  ta.rsi(close, 14), lookahead=barmerge.lookahead_off) : rsiVal
hhtfClose = useMTF ? request.security(syminfo.tickerid, tfHighest, close, lookahead=barmerge.lookahead_off) : src
hhtfEma   = useMTF ? request.security(syminfo.tickerid, tfHighest, ta.ema(close, 20), lookahead=barmerge.lookahead_off) : ema20

htfRet    = math.log(htfClose / nz(htfClose[1], htfClose))
htfRetZ   = math.max(-3, math.min(3, htfRet / (retStd * 2 + 1e-9))) / 3
htfBias   = (htfRsi - 50) / 50
hhtfBias  = math.sign(hhtfClose - hhtfEma) * math.min(1.0, math.abs(hhtfClose - hhtfEma) / (atr14 * 3 + 1e-9))

// 8-dim input vector x_t
NX = 8
var array<float> x_t = array.new<float>(NX, 0.0)
array.set(x_t, 0, nz(retZ))
array.set(x_t, 1, nz(volZ))
array.set(x_t, 2, nz(rsiNorm))
array.set(x_t, 3, nz(slopeNorm))
array.set(x_t, 4, nz(momN))
array.set(x_t, 5, useMTF ? nz(htfRetZ)  : 0.0)
array.set(x_t, 6, useMTF ? nz(htfBias)  : 0.0)
array.set(x_t, 7, useMTF ? nz(hhtfBias) : 0.0)

// ═══════════════════════════════════════════════════════════════
//  LSTM-INSPIRED CELL
// ═══════════════════════════════════════════════════════════════
var array<float> cellState   = array.new<float>(nHidden, 0.0)
var array<float> hiddenState = array.new<float>(nHidden, 0.0)
var array<float> unitTau     = array.new<float>(nHidden, 0.0)

if barstate.isfirst
    for u = 0 to nHidden - 1
        frac = nHidden > 1 ? u * 1.0 / (nHidden - 1) : 0.5
        array.set(unitTau, u, 0.6 + frac * 0.38)

// Gate preactivation (different gate bias per type)
f_gate(xArr, unit, nU, gateType) =>
    z = 0.0
    for k = 0 to NX - 1
        z += array.get(xArr, k) * f_weight(unit, k, nU)
    z += f_bias(unit)
    z += gateType == 0 ? 2.0 : gateType == 1 ? 0.0 : gateType == 2 ? 0.0 : 0.5
    z

if barstate.isconfirmed and bar_index > 50
    for u = 0 to nHidden - 1
        tauU = array.get(unitTau, u)

        f_raw = f_gate(x_t, u, nHidden, 0)
        i_raw = f_gate(x_t, u, nHidden, 1)
        g_raw = f_gate(x_t, u, nHidden, 2)
        o_raw = f_gate(x_t, u, nHidden, 3)

        fGate = f_sigmoid(f_raw * 0.3) * tauU + (1 - tauU) * forgetBase
        iGate = f_sigmoid(i_raw * 0.3) * lrBase * (1.0 + mtfWeight * math.abs(array.get(x_t, 7)))
        cand  = f_tanh(g_raw * 0.5)
        oGate = f_sigmoid(o_raw * 0.3)

        prevC = array.get(cellState, u)
        newC  = fGate * prevC + iGate * cand

        if useResidual and u < nHidden / 2
            newC += residualMix * array.get(x_t, 0) * (1.0 - tauU)

        array.set(cellState, u, newC)

        newH = oGate * f_tanh(newC)
        array.set(hiddenState, u, newH)

// ═══════════════════════════════════════════════════════════════
//  HIDDEN STATE HISTORY (for attention)
// ═══════════════════════════════════════════════════════════════
var array<float> hiddenHistory = array.new<float>(0)
var array<float> priceHistory  = array.new<float>(0)
var array<float> returnHistory = array.new<float>(0)

if barstate.isconfirmed
    hMean = 0.0
    for u = 0 to nHidden - 1
        hMean += array.get(hiddenState, u)
    hMean /= nHidden

    array.push(hiddenHistory, hMean)
    array.push(priceHistory,  src)
    array.push(returnHistory, nz(logRet))

    if array.size(hiddenHistory) > seqLen
        array.shift(hiddenHistory)
        array.shift(priceHistory)
        array.shift(returnHistory)

// ═══════════════════════════════════════════════════════════════
//  ATTENTION
// ═══════════════════════════════════════════════════════════════
var array<float> attWeights = array.new<float>(0)
attContext = 0.0
attReturn  = 0.0

if array.size(hiddenHistory) >= 10 and useAttention
    n = array.size(hiddenHistory)
    currH = array.get(hiddenHistory, n - 1)

    scores = array.new<float>(n, 0.0)
    maxScore = -1e20
    for i = 0 to n - 1
        pastH = array.get(hiddenHistory, i)
        sim = currH * pastH - math.abs(currH - pastH) * 0.5
        recency = math.exp(-(n - 1 - i) / (seqLen * 0.8))
        rawScore = sim * recency / attTemp
        array.set(scores, i, rawScore)
        maxScore := math.max(maxScore, rawScore)

    sumExp = 0.0
    for i = 0 to n - 1
        e = math.exp(array.get(scores, i) - maxScore)
        array.set(scores, i, e)
        sumExp += e

    array.clear(attWeights)
    for i = 0 to n - 1
        w = array.get(scores, i) / math.max(sumExp, 1e-9)
        array.push(attWeights, w)
        attContext += w * array.get(hiddenHistory, i)
        attReturn  += w * array.get(returnHistory, i)

// ═══════════════════════════════════════════════════════════════
//  OUTPUT PROJECTION
// ═══════════════════════════════════════════════════════════════
hAgg = 0.0
for u = 0 to nHidden - 1
    w = 1.0 / nHidden
    hAgg += array.get(hiddenState, u) * w

retScale = ta.stdev(logRet, 100) + 1e-9
expectedRet = hAgg * retScale * 0.5
if useAttention
    expectedRet += attReturn * 0.35
if useResidual
    expectedRet += array.get(x_t, 0) * retScale * residualMix * 0.3

expectedRet := math.max(-0.05, math.min(0.05, expectedRet))

// ═══════════════════════════════════════════════════════════════
//  RESIDUAL TRACKING
// ═══════════════════════════════════════════════════════════════
var float prevForecast = na
residual = not na(prevForecast) ? (src - prevForecast) / src : 0.0

var array<float> residBuffer = array.new<float>(0)
if barstate.isconfirmed and not na(prevForecast)
    array.push(residBuffer, residual)
    if array.size(residBuffer) > residLen
        array.shift(residBuffer)

residStd = 0.0
if array.size(residBuffer) > 10
    m = 0.0
    for i = 0 to array.size(residBuffer) - 1
        m += array.get(residBuffer, i)
    m /= array.size(residBuffer)
    v = 0.0
    for i = 0 to array.size(residBuffer) - 1
        diff = array.get(residBuffer, i) - m
        v += diff * diff
    residStd := math.sqrt(v / array.size(residBuffer))

atrNorm = atr14 / src
sigma = bandMethod == "Residual Std" ? residStd :
         bandMethod == "ATR"          ? atrNorm  :
                                         math.sqrt(residStd * atrNorm + 1e-12)
sigma := math.max(sigma, atrNorm * 0.3)

nextForecast = src * (1.0 + expectedRet)
prevForecast := nextForecast

// ═══════════════════════════════════════════════════════════════
//  MULTI-STEP FORECAST  ← FIX: pre-declare prev-band vars
// ═══════════════════════════════════════════════════════════════
var line[]  fcLines    = array.new<line>()
var line[]  upLines1   = array.new<line>()
var line[]  loLines1   = array.new<line>()
var line[]  upLines2   = array.new<line>()
var line[]  loLines2   = array.new<line>()
var label[] fcLabels   = array.new<label>()

if barstate.islast
    // Clear previous projections
    if array.size(fcLines) > 0
        for i = 0 to array.size(fcLines) - 1
            line.delete(array.get(fcLines, i))
        array.clear(fcLines)
    if array.size(upLines1) > 0
        for i = 0 to array.size(upLines1) - 1
            line.delete(array.get(upLines1, i))
        array.clear(upLines1)
    if array.size(loLines1) > 0
        for i = 0 to array.size(loLines1) - 1
            line.delete(array.get(loLines1, i))
        array.clear(loLines1)
    if array.size(upLines2) > 0
        for i = 0 to array.size(upLines2) - 1
            line.delete(array.get(upLines2, i))
        array.clear(upLines2)
    if array.size(loLines2) > 0
        for i = 0 to array.size(loLines2) - 1
            line.delete(array.get(loLines2, i))
        array.clear(loLines2)
    if array.size(fcLabels) > 0
        for i = 0 to array.size(fcLabels) - 1
            label.delete(array.get(fcLabels, i))
        array.clear(fcLabels)

    // ── FIX: pre-declare running variables BEFORE loop ──
    curP     = src
    prevP    = src
    up1_prev = src * (1.0 + bandMult1 * sigma * 0.0)  // will be set at h=1
    lo1_prev = src * (1.0 - bandMult1 * sigma * 0.0)
    up2_prev = src * (1.0 + bandMult2 * sigma * 0.0)
    lo2_prev = src * (1.0 - bandMult2 * sigma * 0.0)
    // Initialize "bar 0" band anchor at current bar = src (no width)
    up1_prev := src
    lo1_prev := src
    up2_prev := src
    lo2_prev := src

    for h = 1 to forecastBars
        decayFactor = math.pow(0.82, h - 1)
        stepRet = expectedRet * decayFactor
        nextP = curP * (1.0 + stepRet)

        widthScale = math.pow(fanOut, h) * math.sqrt(h)
        sigmaH = sigma * widthScale

        up1 = nextP * (1.0 + bandMult1 * sigmaH)
        lo1 = nextP * (1.0 - bandMult1 * sigmaH)
        up2 = nextP * (1.0 + bandMult2 * sigmaH)
        lo2 = nextP * (1.0 - bandMult2 * sigmaH)

        lineCol = stepRet > 0 ? cBull : cBear

        if showForecast
            ln = line.new(bar_index + h - 1, prevP, bar_index + h, nextP,
                 color=lineCol, width=2, style=line.style_solid)
            array.push(fcLines, ln)

        if showBands
            upL1 = line.new(bar_index + h - 1, up1_prev, bar_index + h, up1,
                 color=color.new(cAccent, 40), width=1, style=line.style_dotted)
            loL1 = line.new(bar_index + h - 1, lo1_prev, bar_index + h, lo1,
                 color=color.new(cAccent, 40), width=1, style=line.style_dotted)
            upL2 = line.new(bar_index + h - 1, up2_prev, bar_index + h, up2,
                 color=color.new(cPurple, 60), width=1, style=line.style_dashed)
            loL2 = line.new(bar_index + h - 1, lo2_prev, bar_index + h, lo2,
                 color=color.new(cPurple, 60), width=1, style=line.style_dashed)
            array.push(upLines1, upL1)
            array.push(loLines1, loL1)
            array.push(upLines2, upL2)
            array.push(loLines2, loL2)

        if h == forecastBars
            pctChg = (nextP - src) / src * 100
            lblTxt = "ŷ(+" + str.tostring(h) + ") " + str.tostring(nextP, format.mintick) +
                 "\n" + str.tostring(pctChg, "+#.##;-#.##") + "%" +
                 "\n±" + str.tostring(bandMult2 * sigmaH * 100, "#.##") + "%"
            lbl = label.new(bar_index + h, nextP, lblTxt,
                 style=label.style_label_left,
                 color=color.new(lineCol, 15),
                 textcolor=color.white,
                 size=size.small)
            array.push(fcLabels, lbl)

        prevP    := curP
        up1_prev := up1
        lo1_prev := lo1
        up2_prev := up2
        lo2_prev := lo2
        curP     := nextP

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast and showDashboard
    dash := table.new(f_pos(dashPos), 5, 22,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    table.cell(dash, 0, 0, "◆ ADAPTIVE LSTM FORECASTER ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 4, 0)
    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period +
         " · H=" + str.tostring(nHidden) + " · seq=" + str.tostring(seqLen) +
         " · fc=" + str.tostring(forecastBars),
         text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 4, 1)

    table.cell(dash, 0, 2, "⚡ FORECAST",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 4, 2)

    dir = expectedRet > 0 ? "▲ BULLISH" : expectedRet < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
    dirCol = expectedRet > 0 ? cBull : expectedRet < 0 ? cBear : cMute
    table.cell(dash, 0, 3, "Next Bar Ret", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(expectedRet * 100, "+#.###;-#.###") + "%",
         text_color=color.white, bgcolor=color.new(dirCol, 40),
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, "Direction", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 3, dir,
         text_color=color.white, bgcolor=color.new(dirCol, 20),
         text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 3, 3, 4, 3)

    table.cell(dash, 0, 4, "Next Price", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(nextForecast, format.mintick),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, "σ (band)", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 4, str.tostring(sigma * 100, "#.###") + "%",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 3, 4, 4, 4)

    accuracy = na(residual) ? 0.0 : math.max(0.0, 1.0 - math.abs(residual) / math.max(sigma, 1e-6))
    accCol = accuracy > 0.7 ? cBull : accuracy > 0.4 ? cWarn : cBear
    table.cell(dash, 0, 5, "Last Residual", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(nz(residual) * 100, "+#.###;-#.###") + "%",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 5, "Hit Score", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 3, 5, str.tostring(accuracy * 100, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(accCol, 40),
         text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 3, 5, 4, 5)

    table.cell(dash, 0, 6, "🧠 HIDDEN UNIT STATES",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 6, 4, 6)
    table.cell(dash, 0, 7, "Unit", text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 1, 7, "τ (memory)", text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 7, "Cell c",   text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 3, 7, "Hidden h", text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 4, 7, "Activity", text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)

    maxUnitsShown = math.min(nHidden, 8)
    for u = 0 to maxUnitsShown - 1
        tauV = array.get(unitTau, u)
        cV   = array.get(cellState, u)
        hV   = array.get(hiddenState, u)
        absH = math.abs(hV)
        actBar = ""
        nBars = math.round(math.min(10, absH * 12))
        for b = 0 to 9
            actBar := actBar + (b < nBars ? "▮" : "▯")
        hCol = hV > 0.1 ? cBull : hV < -0.1 ? cBear : cMute

        table.cell(dash, 0, 8 + u, "u" + str.tostring(u),
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 1, 8 + u, str.tostring(tauV, "#.##"),
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 2, 8 + u, str.tostring(cV, "+#.##;-#.##"),
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 3, 8 + u, str.tostring(hV, "+#.##;-#.##"),
             text_color=color.white, bgcolor=color.new(hCol, 50),
             text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 4, 8 + u, actBar,
             text_color=hCol, bgcolor=cBg, text_halign=text.align_left, text_size=size.tiny)

    startRow = 8 + maxUnitsShown
    table.cell(dash, 0, startRow, "🎯 INPUT VECTOR x_t",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, startRow, 4, startRow)

    featNames = array.from("retZ","volZ","rsi","slope","mom","htfRet","htfBias","hhtfBias")
    for i = 0 to 3
        v1 = array.get(x_t, i)
        v2 = array.get(x_t, i + 4)
        c1 = v1 > 0.2 ? cBull : v1 < -0.2 ? cBear : cMute
        c2 = v2 > 0.2 ? cBull : v2 < -0.2 ? cBear : cMute
        table.cell(dash, 0, startRow + 1 + i, array.get(featNames, i),
             text_color=cMute, bgcolor=cBg, text_halign=text.align_right, text_size=size.tiny)
        table.cell(dash, 1, startRow + 1 + i, str.tostring(v1, "+#.##;-#.##"),
             text_color=color.white, bgcolor=color.new(c1, 40),
             text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 2, startRow + 1 + i, array.get(featNames, i + 4),
             text_color=cMute, bgcolor=cBg, text_halign=text.align_right, text_size=size.tiny)
        table.cell(dash, 3, startRow + 1 + i, str.tostring(v2, "+#.##;-#.##"),
             text_color=color.white, bgcolor=color.new(c2, 40),
             text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 4, startRow + 1 + i, "", bgcolor=cBg)

    footerRow = startRow + 5
    table.cell(dash, 0, footerRow,
         "AetherEdge LSTM-inspired · residual=" + (useResidual ? "ON" : "OFF") +
         " · attention=" + (useAttention ? "ON" : "OFF"),
         text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.merge_cells(dash, 0, footerRow, 4, footerRow)

// ═══════════════════════════════════════════════════════════════
//  ATTENTION HEATMAP
// ═══════════════════════════════════════════════════════════════
var table attTable = na
if barstate.islast and showAttention and useAttention and array.size(attWeights) > 5
    nCells = math.min(30, array.size(attWeights))
    attTable := table.new(f_pos(heatPos), nCells, 4,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    total = array.size(attWeights)
    startIdx = total - nCells
    maxW = 0.0
    for i = 0 to nCells - 1
        w = array.get(attWeights, startIdx + i)
        maxW := math.max(maxW, w)

    for c = 0 to nCells - 1
        titleTxt = c == 0 ? "🎯 ATTENTION WEIGHTS (oldest → newest)" : ""
        table.cell(attTable, c, 0, titleTxt,
             text_color=cAccent, bgcolor=cBgAlt,
             text_halign=text.align_left,
             text_size=c == 0 ? size.small : size.tiny)

        w = array.get(attWeights, startIdx + c)
        tVal = maxW > 0 ? w / maxW : 0
        heatCol = color.from_gradient(tVal, 0, 1, cMute, cPurple)
        transp = math.round(80 - tVal * 70)
        table.cell(attTable, c, 1, "",
             bgcolor=color.new(heatCol, transp), text_size=size.tiny)

        showVal = c % math.max(1, math.round(nCells / 6)) == 0 or c == nCells - 1
        table.cell(attTable, c, 2, showVal ? str.tostring(w * 100, "#") : "",
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)

        pastRet = array.get(returnHistory, startIdx + c)
        retSym = pastRet > 0 ? "▲" : pastRet < 0 ? "▼" : "◆"
        retCol = pastRet > 0 ? cBull : pastRet < 0 ? cBear : cMute
        table.cell(attTable, c, 3, retSym,
             text_color=color.white, bgcolor=color.new(retCol, 40),
             text_halign=text.align_center, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
modelPrice = src * (1.0 + expectedRet * 0.5)
plot(showCells ? modelPrice : na, "Model Expectation",
     color=color.new(cPurple, 30), linewidth=2)

plot(showForecast ? nextForecast : na, "1-Step Forecast",
     color=expectedRet > 0 ? cBull : cBear, linewidth=2, style=plot.style_circles)

bgConf = math.abs(expectedRet) / math.max(retScale * 2, 1e-6)
bgConf := math.min(bgConf, 1.0)
bgcolor(color.new(expectedRet > 0 ? cBull : cBear,
     math.round(95 - bgConf * 15)), title="Forecast Tint")

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
strongBull = expectedRet > retScale * 1.0 and (not useAttention or attReturn > 0)
strongBear = expectedRet < -retScale * 1.0 and (not useAttention or attReturn < 0)
bandBreach = high > nextForecast * (1.0 + bandMult2 * sigma) or
             low  < nextForecast * (1.0 - bandMult2 * sigma)

alertcondition(strongBull, "Strong Bullish Forecast",
     "AE-LSTM: Strong bullish forecast on {{ticker}} — +σ breach expected")
alertcondition(strongBear, "Strong Bearish Forecast",
     "AE-LSTM: Strong bearish forecast on {{ticker}} — -σ breach expected")
alertcondition(bandBreach, "Forecast Band Breach",
     "AE-LSTM: Price exceeded forecast band on {{ticker}}")
alertcondition(ta.crossover(expectedRet, 0),  "Forecast Flip Bullish", "AE-LSTM: Forecast flipped bullish")
alertcondition(ta.crossunder(expectedRet, 0), "Forecast Flip Bearish", "AE-LSTM: Forecast flipped bearish")
````
