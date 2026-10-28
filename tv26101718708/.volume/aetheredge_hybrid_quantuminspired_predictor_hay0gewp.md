# AetherEdge Hybrid Quantum-Inspired Predictor

- url: https://www.tradingview.com/script/HAy0GeWp/
- type: indicator
- pine_id: PUB;28ab7d3ecb394deca00f54557105a5c9
- version: 1.0

## Description

🖊️ Overview
AetherEdge Hybrid Quantum-Inspired Predictor is a next-generation 3-class (UP/DOWN/SIDE) probability prediction engine that fuses three heterogeneous models: a quantum-mechanical wavefunction approach, a K-Nearest Neighbors historical analog search, and a self-learning neural network. Born-rule probabilities derived from complex amplitudes ψ, distance-weighted K-NN voting, and Softmax-based self-optimizing neurons all converge into a single ensemble distribution. With a complete visualization system featuring a radar chart, pie chart, and historical analogs, it decodes the market's "superposition state."

🔶 Key Features

3-Layer Hybrid Architecture: Quantum + KNN + Neural
Quantum Layer: Complex wavefunction ψ, Gaussian amplitudes, decoherence, phase
KNN Layer: K-nearest analog search in 3D feature space
Neural Layer: Online gradient descent + Softmax + Weight decay
3-Class Classification: UP/DOWN/SIDE probability distribution
3 Core Features: Price Structure / Liquidity / Sentiment Proxy
On-Chart Radar Chart: 3-axis visualization
On-Chart Pie Chart: Instant state distribution view
Historical Analogs Display: Top-3 similar past patterns
Quantum Internal State Monitor: Re(ψ), Im(ψ), |ψ|², entropy
State Flip Markers: Auto-detection of directional transitions
Strategy Suggestion Engine: LONG BIAS / SHORT BIAS / RANGE FADE, etc.

🧠 Technical Architecture

This indicator is designed as an ensemble predictor of three heterogeneous models.

Feature Engineering:
Price Structure: EMA20/50/100 + RSI + ATR-deviation composite (tanh normalized)
Liquidity: Close position + wick asymmetry + VWAP deviation + sweep detection
Sentiment Proxy: Vol-Z + price-volume divergence + A/D + volume spike
Quantum Layer:
Wavefunction Construction: ψ_state = Σ A·e^(iθ) per feature
Gaussian Amplitude: A(f, target) = exp(-(f-target)²/(2σ²))
Phase Intensity: θ = f × qPhase × π/2 + offset
Born Rule: P_state = |ψ|² / Σ|ψ|²
Decoherence: P' = (1-γ)·P + γ/3 for quantum→classical transition
Quantum Coherence: 1 - H/log(3) state clarity
KNN Layer:
Euclidean distance search in 3D feature space
Distance-weighted voting w = 1/(1+d)
Aggregates labels (UP/DOWN/SIDE) at past kHorizon-bar future
Records Top-3 analogs (rank, distance, realized return)
Neural Layer:
3-class Softmax classifier (3 inputs → 3 outputs, 12 parameters)
Cross-Entropy Gradient: g = p - target
Update Rule: w_new = w·decay - lr·g·feature
Weight Decay: Prevents overfitting + forgets old patterns
Ensemble Integration:
Weighted average: P = (q·P_q + k·P_k + n·P_n) / Σw
After normalization, max-probability class becomes dominant state
Strategy Engine:
domProb ≥ 0.55 + UP → LONG BIAS
domProb ≥ 0.55 + DOWN → SHORT BIAS
domProb ≥ 0.55 + SIDE → RANGE FADE
confidence < 0.15 → HIGH UNCERTAINTY

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): qWeight=0.35, kWeight=0.35, nWeight=0.30, kK=20
ETH (1H): qWeight=0.30, kWeight=0.40, nWeight=0.30, kHorizon=5
SOL (high-vol): qSigma=1.5, qDecoher=0.15, kThresh=0.5
XRP (short-term): kHorizon=3, kThresh=0.2, nLR=0.02
Quantum Layer:

qWeight=0.20: Conservative (suppress quantum contribution)
qWeight=0.35: Standard
qWeight=0.50: Experimental (quantum-dominant)
qSigma=0.8: Sharp (clear states)
qSigma=1.2: Standard
qSigma=2.0: Smooth (high uncertainty)
qDecoher=0.05: Pure quantum
qDecoher=0.10: Standard
qDecoher=0.30: Strong classical approximation
KNN Layer:

kK=10: Curated matches (sharp)
kK=20: Standard
kK=40: Smooth (conservative)
kLookback=300: Lightweight
kLookback=500: Standard
kLookback=1000: Long-term patterns
kThresh=0.2%: Sensitive (short TF)
kThresh=0.3%: Standard
kThresh=0.5%: Conservative (long TF)
Neural Layer:

nLR=0.005: Cautious learning (stable)
nLR=0.015: Standard
nLR=0.05: Fast adaptation (unstable)
nDecay=0.999: Long-term memory
nDecay=0.997: Standard
nDecay=0.99: Quick forgetting

💡 How to Use in Practice

LONG BIAS + High Q-Coherence: Strongest buy signal, consider entry
SHORT BIAS + High Confidence: Strongest sell signal, build short
RANGE FADE: Range strategies, sell premium, fade both extremes
HIGH UNCERTAINTY: Reduce positions, observe mode
State Flip → UP: Early trend transition, early entry
All Top-3 Analogs Same Direction: Strong historical evidence, raise confidence
3-Model Consensus: Quantum/KNN/Neural all UP → highest confidence
3-Model Divergence: Split opinion, exercise caution
Dir Bias > 0.3: Strong upward bias
Vol Anomaly Detected: Suspend forecasts during normal-time logic
AetherEdge Synergy:
Self-Evolving S/R Grid: LONG BIAS + support reaction = high-win-rate entry
Volatility Regime GAN: SHORT BIAS + EXPAND forecast = powerful drop setup
SMC AI Confidence: 3-model consensus + high-conf zone = conviction entry
Neural Divergence Hunter: State Flip + divergence = reversal confirmation

⚠️ Important Notes

Initial Learning Period: Neural & KNN immature until bar_index > 110
Model Divergence: Split opinions signal weak signal strength
Quantum is Approximation: Mathematical analogy, not actual quantum computing
History Dependent: Cannot handle unprecedented market events
Computation Load: Radar & pie rendering slightly heavy
Repaint: Runs at barstate.islast, displayed only at last bar
Neural Weights: Reset to defaults on chart reload
Confidence < 0.15: Near-uniform distribution, recommend avoiding trades

🚨 Disclaimer

This indicator is an advanced hybrid prediction tool for educational and research purposes only and does not constitute financial advice. "Quantum-inspired" is a mathematical analogy, not actual quantum computing. The 3-model ensemble prediction is a probabilistic method and does not guarantee future price movements. Use with thorough validation and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Hybrid Quantum-Inspired Predictor", "AE-HQP",
     overlay=true, max_labels_count=100, max_lines_count=300,
     max_boxes_count=100, max_polylines_count=100, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpQ = "⚛️ Quantum Layer"
qWeight   = input.float(0.35, "Quantum Weight",     0, 1, 0.05, group=grpQ)
qSigma    = input.float(1.2,  "Coherence Width σ",  0.5, 3.0, 0.1, group=grpQ)
qDecoher  = input.float(0.10, "Decoherence γ",       0, 0.5, 0.05, group=grpQ)
qPhase    = input.float(1.0,  "Phase Intensity",     0.1, 2.0, 0.1, group=grpQ)

grpK = "🎯 KNN Layer"
kWeight   = input.float(0.35, "KNN Weight",         0, 1, 0.05, group=grpK)
kK        = input.int(20, "K Neighbors",            5, 60, group=grpK)
kLookback = input.int(500,"Training Window",        100, 2000, group=grpK)
kHorizon  = input.int(5,  "Forecast Horizon (bars)",1, 20, group=grpK)
kThresh   = input.float(0.3,"Move Threshold %",      0.05, step=0.05, group=grpK)

grpN = "🧠 Neural Layer"
nWeight   = input.float(0.30, "Neural Weight",      0, 1, 0.05, group=grpN)
nLR       = input.float(0.015,"Learning Rate η",    0.001, 0.1, 0.001, group=grpN)
nDecay    = input.float(0.997,"Weight Decay",       0.9, 1.0, 0.001, group=grpN)

grpV = "🎨 Visualization"
showRadar   = input.bool(true, "Show Radar Chart",       group=grpV)
showPie     = input.bool(true, "Show Pie Chart",         group=grpV)
showTrails  = input.bool(true, "Show State Trails",      group=grpV)
radarOffset = input.int(25, "Radar Offset (bars)",       10, 100, group=grpV)
pieOffset   = input.int(55, "Pie Offset (bars)",         10, 100, group=grpV)
chartSize   = input.float(8.0,"Chart Size (× ATR)",      3.0, 20.0, 0.5, group=grpV)
darkMode    = input.bool(true, "Dark Mode",              group=grpV)
dashPos     = input.string("Top Right", "Dashboard",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpV)
dashSize    = input.string("Normal", "Dash Size",
     options=["Tiny","Small","Normal","Large"], group=grpV)

f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

// ── FIX: Pine v5 has no math.tanh → define numerically-stable version ──
f_tanh(x) =>
    xc = math.max(-20.0, math.min(20.0, x))
    e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0b0f1e, 5)  : color.new(#f8fafc, 5)
cBgAlt   = darkMode ? color.new(#131a2e, 0)  : color.new(#ffffff, 0)
cBgRow   = darkMode ? color.new(#0f172a, 0)  : color.new(#f1f5f9, 0)
cBorder  = darkMode ? color.new(#273548, 0)  : color.new(#cbd5e1, 0)
cText    = darkMode ? color.new(#e2e8f0, 0)  : color.new(#0f172a, 0)
cMute    = darkMode ? color.new(#94a3b8, 0)  : color.new(#64748b, 0)
cUp      = color.new(#22c55e, 0)
cDn      = color.new(#ef4444, 0)
cSd      = color.new(#eab308, 0)
cAccent  = color.new(#06b6d4, 0)
cPurple  = color.new(#a855f7, 0)
cQuantum = color.new(#8b5cf6, 0)
cGrid    = darkMode ? color.new(#334155, 50) : color.new(#cbd5e1, 50)

// ═══════════════════════════════════════════════════════════════
//  FEATURE ENGINEERING
// ═══════════════════════════════════════════════════════════════
atr14   = ta.atr(14)
atrSafe = math.max(atr14, syminfo.mintick)

// ── PRICE STRUCTURE ──
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ps_trend = f_tanh((ema20 - ema50) / ema50 * 50)
ps_dev   = f_tanh((close - ema20) / atrSafe / 2)
ps_mom   = (ta.rsi(close, 14) - 50) / 50
ps_tier  = f_tanh((ema50 - ema100) / ema100 * 30)
priceStruct = math.max(-1.0, math.min(1.0, (ps_trend + ps_dev + ps_mom + ps_tier) / 4))

// ── LIQUIDITY ──
barRange   = math.max(high - low, syminfo.mintick)
closePos   = (close - low) / barRange
upperWick  = (high - math.max(open, close)) / barRange
lowerWick  = (math.min(open, close) - low) / barRange
liq_pressure = ta.sma(closePos, 10) * 2 - 1
liq_grab     = f_tanh((lowerWick - upperWick) * 3)
vwapDev = f_tanh((close - ta.vwap) / atrSafe / 2)
liq_sweep = 0.0
sweepUp = high > ta.highest(high, 20)[1] and close < ta.highest(high, 20)[1]
sweepDn = low  < ta.lowest(low, 20)[1]  and close > ta.lowest(low, 20)[1]
liq_sweep := sweepDn ? 0.6 : sweepUp ? -0.6 : 0.0
liquidity = math.max(-1.0, math.min(1.0, (liq_pressure + liq_grab + vwapDev + liq_sweep) / 4))

// ── SENTIMENT PROXY ──
volMean  = ta.sma(volume, 50)
volStd   = ta.stdev(volume, 50)
volZ     = volStd > 0 ? (volume - volMean) / volStd : 0.0
volZclip = math.max(-3.0, math.min(3.0, volZ))
priceDir = math.sign(close - open)
sent_spike = f_tanh(volZclip * priceDir / 2)
priceChg10 = ta.change(close, 10)
volChg10   = volMean > 0 ? (volume - ta.sma(volume, 10)) / volMean : 0.0
sent_diverge = f_tanh(math.sign(priceChg10) * volChg10 * 2)
adValue = closePos * volume
adNorm  = volMean > 0 ? ta.sma(adValue, 20) / volMean - 0.5 : 0.0
sent_ad = f_tanh(adNorm * 2)
sent_extremeVol = f_tanh(math.abs(volZclip) / 2) * math.sign(ta.change(close))
sentiment = math.max(-1.0, math.min(1.0,
     (sent_spike + sent_diverge + sent_ad + sent_extremeVol) / 4))

// ═══════════════════════════════════════════════════════════════
//  QUANTUM LAYER
// ═══════════════════════════════════════════════════════════════
f_gaussAmp(f, target, sigma) =>
    math.exp(-math.pow(f - target, 2) / (2 * sigma * sigma))

// ── FIX: one declaration per line (no comma-separated multi-var) ──
psiU_re = 0.0
psiU_im = 0.0
psiD_re = 0.0
psiD_im = 0.0
psiS_re = 0.0
psiS_im = 0.0

feats = array.from(priceStruct, liquidity, sentiment)
phaseOffsets = array.from(0.0, math.pi / 6, math.pi / 3)

for k = 0 to 2
    f    = array.get(feats, k)
    pOff = array.get(phaseOffsets, k)

    ampU = f_gaussAmp(f, 1.0, qSigma)
    thU  = (f * qPhase * math.pi / 2) + pOff
    psiU_re += ampU * math.cos(thU)
    psiU_im += ampU * math.sin(thU)

    ampD = f_gaussAmp(f, -1.0, qSigma)
    thD  = (-f * qPhase * math.pi / 2) + pOff
    psiD_re += ampD * math.cos(thD)
    psiD_im += ampD * math.sin(thD)

    ampS = f_gaussAmp(f, 0.0, qSigma)
    thS  = (math.abs(f) * qPhase * math.pi) + pOff
    psiS_re += ampS * math.cos(thS)
    psiS_im += ampS * math.sin(thS)

probQup_raw = psiU_re * psiU_re + psiU_im * psiU_im
probQdn_raw = psiD_re * psiD_re + psiD_im * psiD_im
probQsd_raw = psiS_re * psiS_re + psiS_im * psiS_im
sumQ = probQup_raw + probQdn_raw + probQsd_raw

probQup = sumQ > 0 ? probQup_raw / sumQ : 1.0/3
probQdn = sumQ > 0 ? probQdn_raw / sumQ : 1.0/3
probQsd = sumQ > 0 ? probQsd_raw / sumQ : 1.0/3

probQup := (1 - qDecoher) * probQup + qDecoher / 3
probQdn := (1 - qDecoher) * probQdn + qDecoher / 3
probQsd := (1 - qDecoher) * probQsd + qDecoher / 3

qEntropy = -(probQup * math.log(math.max(probQup, 1e-9)) +
              probQdn * math.log(math.max(probQdn, 1e-9)) +
              probQsd * math.log(math.max(probQsd, 1e-9)))
qCoherence = 1.0 - qEntropy / math.log(3.0)

// ═══════════════════════════════════════════════════════════════
//  KNN LAYER (3-class)
// ═══════════════════════════════════════════════════════════════
var hF1  = array.new<float>()
var hF2  = array.new<float>()
var hF3  = array.new<float>()
var hLbl = array.new<int>()
var hRet = array.new<float>()

if barstate.isconfirmed and bar_index > 110
    fwd = (close - close[kHorizon]) / close[kHorizon] * 100
    lbl = fwd >  kThresh ?  1 : fwd < -kThresh ? -1 : 0
    if not na(priceStruct[kHorizon])
        array.push(hF1,  priceStruct[kHorizon])
        array.push(hF2,  liquidity[kHorizon])
        array.push(hF3,  sentiment[kHorizon])
        array.push(hLbl, lbl)
        array.push(hRet, fwd)
        if array.size(hF1) > kLookback
            array.shift(hF1)
            array.shift(hF2)
            array.shift(hF3)
            array.shift(hLbl)
            array.shift(hRet)

var float probKup = 1.0/3
var float probKdn = 1.0/3
var float probKsd = 1.0/3
var float knnAvgDist = 0.0
var int   bestIdx   = 0
var float bestFwd   = 0.0
var int   match2Idx = 0
var float match2Fwd = 0.0
var int   match3Idx = 0
var float match3Fwd = 0.0

hSize = array.size(hF1)
if hSize > 50
    dists = array.new<float>()
    for i = 0 to hSize - 1
        d1 = priceStruct - array.get(hF1, i)
        d2 = liquidity   - array.get(hF2, i)
        d3 = sentiment   - array.get(hF3, i)
        array.push(dists, math.sqrt(d1*d1 + d2*d2 + d3*d3))

    kActual = math.min(kK, hSize)
    wUp = 0.0
    wDn = 0.0
    wSd = 0.0
    sumW = 0.0
    distAcc = 0.0
    for kk = 0 to kActual - 1
        minD = array.get(dists, 0)
        minI = 0
        for j = 1 to array.size(dists) - 1
            if array.get(dists, j) < minD
                minD := array.get(dists, j)
                minI := j
        w = 1.0 / (1.0 + minD)
        lbl2 = array.get(hLbl, minI)
        if lbl2 > 0
            wUp += w
        else if lbl2 < 0
            wDn += w
        else
            wSd += w
        sumW += w
        distAcc += minD
        if kk == 0
            bestIdx := hSize - minI
            bestFwd := array.get(hRet, minI)
        if kk == 1
            match2Idx := hSize - minI
            match2Fwd := array.get(hRet, minI)
        if kk == 2
            match3Idx := hSize - minI
            match3Fwd := array.get(hRet, minI)
        array.set(dists, minI, 1e10)

    if sumW > 0
        probKup := wUp / sumW
        probKdn := wDn / sumW
        probKsd := wSd / sumW
    knnAvgDist := distAcc / kActual

// ═══════════════════════════════════════════════════════════════
//  NEURAL LAYER
// ═══════════════════════════════════════════════════════════════
// ── FIX: one declaration per line ──
var float wU1 =  0.3
var float wU2 =  0.1
var float wU3 =  0.1
var float bU  =  0.0
var float wD1 = -0.3
var float wD2 = -0.1
var float wD3 = -0.1
var float bD  =  0.0
var float wS1 =  0.0
var float wS2 =  0.0
var float wS3 =  0.0
var float bS  =  0.0

f_softmax3(z1, z2, z3) =>
    m = math.max(z1, math.max(z2, z3))
    e1 = math.exp(math.max(-30, math.min(30, z1 - m)))
    e2 = math.exp(math.max(-30, math.min(30, z2 - m)))
    e3 = math.exp(math.max(-30, math.min(30, z3 - m)))
    s = e1 + e2 + e3
    [e1 / s, e2 / s, e3 / s]

if barstate.isconfirmed and bar_index > 110 and not na(priceStruct[kHorizon])
    fwd = (close - close[kHorizon]) / close[kHorizon] * 100
    lbl = fwd > kThresh ? 0 : fwd < -kThresh ? 1 : 2
    ff1 = priceStruct[kHorizon]
    ff2 = liquidity[kHorizon]
    ff3 = sentiment[kHorizon]

    zU = wU1 * ff1 + wU2 * ff2 + wU3 * ff3 + bU
    zD = wD1 * ff1 + wD2 * ff2 + wD3 * ff3 + bD
    zS = wS1 * ff1 + wS2 * ff2 + wS3 * ff3 + bS
    [pU, pD, pS] = f_softmax3(zU, zD, zS)

    tU = lbl == 0 ? 1.0 : 0.0
    tD = lbl == 1 ? 1.0 : 0.0
    tS = lbl == 2 ? 1.0 : 0.0

    gU = pU - tU
    gD = pD - tD
    gS = pS - tS

    wU1 := wU1 * nDecay - nLR * gU * ff1
    wU2 := wU2 * nDecay - nLR * gU * ff2
    wU3 := wU3 * nDecay - nLR * gU * ff3
    bU  := bU  * nDecay - nLR * gU
    wD1 := wD1 * nDecay - nLR * gD * ff1
    wD2 := wD2 * nDecay - nLR * gD * ff2
    wD3 := wD3 * nDecay - nLR * gD * ff3
    bD  := bD  * nDecay - nLR * gD
    wS1 := wS1 * nDecay - nLR * gS * ff1
    wS2 := wS2 * nDecay - nLR * gS * ff2
    wS3 := wS3 * nDecay - nLR * gS * ff3
    bS  := bS  * nDecay - nLR * gS

zUn = wU1 * priceStruct + wU2 * liquidity + wU3 * sentiment + bU
zDn = wD1 * priceStruct + wD2 * liquidity + wD3 * sentiment + bD
zSn = wS1 * priceStruct + wS2 * liquidity + wS3 * sentiment + bS
[probNup, probNdn, probNsd] = f_softmax3(zUn, zDn, zSn)

// ═══════════════════════════════════════════════════════════════
//  ENSEMBLE
// ═══════════════════════════════════════════════════════════════
wSum = qWeight + kWeight + nWeight
pUp = (qWeight * probQup + kWeight * probKup + nWeight * probNup) / wSum
pDn = (qWeight * probQdn + kWeight * probKdn + nWeight * probNdn) / wSum
pSd = (qWeight * probQsd + kWeight * probKsd + nWeight * probNsd) / wSum
sumE = pUp + pDn + pSd
pUp := pUp / sumE
pDn := pDn / sumE
pSd := pSd / sumE

domState = pUp >= math.max(pDn, pSd) ? "UP" : pDn >= math.max(pUp, pSd) ? "DOWN" : "SIDE"
domProb  = math.max(pUp, math.max(pDn, pSd))
domCol   = domState == "UP" ? cUp : domState == "DOWN" ? cDn : cSd

entropy = -(pUp * math.log(math.max(pUp, 1e-9)) +
             pDn * math.log(math.max(pDn, 1e-9)) +
             pSd * math.log(math.max(pSd, 1e-9)))
confidence = 1.0 - entropy / math.log(3.0)

dirBias = pUp - pDn

strategy = domProb >= 0.55 and domState == "UP"   ? "LONG BIAS" : domProb >= 0.55 and domState == "DOWN" ? "SHORT BIAS" : domProb >= 0.55 and domState == "SIDE" ? "RANGE FADE" : confidence < 0.15 ? "HIGH UNCERTAINTY" : pUp > pDn ? "LEAN LONG" : pDn > pUp ? "LEAN SHORT" : "OBSERVE"
strategyCol = str.contains(strategy, "LONG BIAS")   ? cUp :
               str.contains(strategy, "SHORT BIAS")  ? cDn :
               str.contains(strategy, "RANGE")       ? cSd :
               str.contains(strategy, "LEAN LONG")   ? color.new(cUp, 40) :
               str.contains(strategy, "LEAN SHORT")  ? color.new(cDn, 40) :
               str.contains(strategy, "HIGH UNCERT") ? cPurple : cMute

// ═══════════════════════════════════════════════════════════════
//  ON-CHART RADAR & PIE
// ═══════════════════════════════════════════════════════════════
var array<line>     radarLines  = array.new<line>()
var array<polyline> radarPolys  = array.new<polyline>()
var array<label>    radarLabels = array.new<label>()
var array<polyline> piePolys    = array.new<polyline>()
var array<label>    pieLabels   = array.new<label>()
var array<line>     trailLines  = array.new<line>()

f_clearLines(arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

f_clearPolys(arr) =>
    while array.size(arr) > 0
        polyline.delete(array.pop(arr))

f_clearLabels(arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

// ── Radar ──
if barstate.islast and showRadar
    f_clearLines(radarLines)
    f_clearPolys(radarPolys)
    f_clearLabels(radarLabels)

    cxBar = bar_index + radarOffset
    cy    = close
    rY    = atrSafe * chartSize
    rX    = math.round(chartSize * 1.5)

    rings = array.from(0.25, 0.5, 0.75, 1.0)
    for rp in rings
        pts = array.new<chart.point>()
        for a = 0 to 36
            ang = a * math.pi / 18
            xB = math.round(cxBar + rX * rp * math.cos(ang))
            yP = cy + rY * rp * math.sin(ang)
            array.push(pts, chart.point.from_index(xB, yP))
        pl = polyline.new(pts, curved=true, closed=true,
             line_color=color.new(cGrid, 70), line_width=1)
        array.push(radarPolys, pl)

    axAngles = array.from(math.pi / 2, math.pi * 7 / 6, math.pi * 11 / 6)
    axColors = array.from(cUp, cSd, cDn)
    axNames  = array.from("UP", "SIDE", "DOWN")
    axProbs  = array.from(pUp, pSd, pDn)

    for i = 0 to 2
        ang = array.get(axAngles, i)
        col = array.get(axColors, i)
        nm  = array.get(axNames, i)
        pr  = array.get(axProbs, i)
        xEnd = math.round(cxBar + rX * math.cos(ang))
        yEnd = cy + rY * math.sin(ang)
        l = line.new(cxBar, cy, xEnd, yEnd,
             xloc=xloc.bar_index, color=color.new(col, 40), width=1)
        array.push(radarLines, l)
        lblX = math.round(cxBar + rX * 1.12 * math.cos(ang))
        lblY = cy + rY * 1.12 * math.sin(ang)
        lab = label.new(lblX, lblY,
             nm + "\n" + str.tostring(pr * 100, "#.#") + "%",
             xloc=xloc.bar_index, color=color.new(col, 15),
             textcolor=color.white, style=label.style_label_center,
             size=size.small)
        array.push(radarLabels, lab)

    curPts = array.new<chart.point>()
    for i = 0 to 2
        ang = array.get(axAngles, i)
        pr  = array.get(axProbs, i)
        xP = math.round(cxBar + rX * pr * math.cos(ang))
        yP = cy + rY * pr * math.sin(ang)
        array.push(curPts, chart.point.from_index(xP, yP))
    stateFill = domState == "UP" ? cUp : domState == "DOWN" ? cDn : cSd
    statePoly = polyline.new(curPts, closed=true,
         line_color=stateFill, line_width=2,
         fill_color=color.new(stateFill, 75))
    array.push(radarPolys, statePoly)

    clab = label.new(cxBar, cy, "◆",
         xloc=xloc.bar_index, color=color.new(color.black, 100),
         textcolor=cAccent, style=label.style_label_center, size=size.small)
    array.push(radarLabels, clab)

    titleLab = label.new(cxBar,
         cy + rY * 1.35,
         "⚛ QUANTUM STATE RADAR\nCoh: " + str.tostring(qCoherence * 100, "#.#") + "%",
         xloc=xloc.bar_index,
         color=color.new(cQuantum, 20), textcolor=color.white,
         style=label.style_label_down, size=size.small)
    array.push(radarLabels, titleLab)

// ── Pie ──
if barstate.islast and showPie
    f_clearPolys(piePolys)
    f_clearLabels(pieLabels)

    cxBarP = bar_index + pieOffset
    cyP    = close
    rYp    = atrSafe * chartSize * 0.8
    rXp    = math.round(chartSize * 1.2)

    pieProbs  = array.from(pUp, pDn, pSd)
    pieColors = array.from(cUp, cDn, cSd)
    pieNames  = array.from("UP", "DOWN", "SIDE")

    startAng = math.pi / 2
    for i = 0 to 2
        pr  = array.get(pieProbs, i)
        col = array.get(pieColors, i)
        nm  = array.get(pieNames, i)
        if pr > 0.01
            sliceAng = pr * 2 * math.pi
            endAng   = startAng - sliceAng
            pts = array.new<chart.point>()
            array.push(pts, chart.point.from_index(cxBarP, cyP))
            nSegs = math.max(6, math.round(pr * 40))
            for s = 0 to nSegs
                a = startAng - sliceAng * s / nSegs
                xB = math.round(cxBarP + rXp * math.cos(a))
                yP = cyP + rYp * math.sin(a)
                array.push(pts, chart.point.from_index(xB, yP))
            array.push(pts, chart.point.from_index(cxBarP, cyP))
            pl = polyline.new(pts, closed=true,
                 line_color=color.new(col, 30), line_width=1,
                 fill_color=color.new(col, 40))
            array.push(piePolys, pl)

            midA = startAng - sliceAng / 2
            lxB = math.round(cxBarP + rXp * 0.65 * math.cos(midA))
            lyP = cyP + rYp * 0.65 * math.sin(midA)
            pctTxt = nm + "\n" + str.tostring(pr * 100, "#.#") + "%"
            pLab = label.new(lxB, lyP, pctTxt,
                 xloc=xloc.bar_index,
                 color=color.new(color.black, 100),
                 textcolor=color.white,
                 style=label.style_label_center, size=size.small)
            array.push(pieLabels, pLab)
            startAng := endAng

    titleP = label.new(cxBarP,
         cyP + rYp * 1.3,
         "◉ STATE DISTRIBUTION\nConf: " + str.tostring(confidence * 100, "#.#") + "%",
         xloc=xloc.bar_index,
         color=color.new(cAccent, 20), textcolor=color.white,
         style=label.style_label_down, size=size.small)
    array.push(pieLabels, titleP)

// ── State trails ──
if showTrails
    trailCol = domCol
    stateChanged = domState != domState[1]
    if stateChanged
        line.new(bar_index - 1, close, bar_index, close,
             color=color.new(trailCol, 0), width=2,
             extend=extend.none)

// ── State flip markers ──
flipUp = domState == "UP"   and domState[1] != "UP"   and domProb >= 0.45
flipDn = domState == "DOWN" and domState[1] != "DOWN" and domProb >= 0.45
flipSd = domState == "SIDE" and domState[1] != "SIDE" and domProb >= 0.45

if flipUp
    label.new(bar_index, low, "▲ UP " + str.tostring(pUp * 100, "#.#") + "%",
         color=color.new(cUp, 15), textcolor=color.white,
         style=label.style_label_up, size=size.small)
if flipDn
    label.new(bar_index, high, "▼ DOWN " + str.tostring(pDn * 100, "#.#") + "%",
         color=color.new(cDn, 15), textcolor=color.white,
         style=label.style_label_down, size=size.small)
if flipSd
    label.new(bar_index, high, "◆ SIDE " + str.tostring(pSd * 100, "#.#") + "%",
         color=color.new(cSd, 15), textcolor=color.black,
         style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_bar(pct, len) =>
    filled = math.round(pct * len)
    s = ""
    for i = 0 to len - 1
        s := s + (i < filled ? "█" : "░")
    s

var table dash = na
if barstate.islast
    dash := table.new(f_pos(dashPos), 4, 32,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cQuantum, frame_width=2)
    ts = f_size(dashSize)

    // Header
    table.cell(dash, 0, 0, "⚛  AETHEREDGE HYBRID QUANTUM PREDICTOR  ⚛",
         text_color=cQuantum, bgcolor=cBgAlt, text_size=size.large,
         text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 3, 0)

    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period + "  ·  "
         + "K=" + str.tostring(kK) + "  ·  hist " + str.tostring(hSize) + "b  ·  "
         + "σ=" + str.tostring(qSigma, "0.0") + "  γ=" + str.tostring(qDecoher, "0.00"),
         text_color=cMute, bgcolor=cBgAlt, text_size=ts,
         text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 3, 1)

    // State distribution
    table.cell(dash, 0, 2, "◢  MULTI-DIRECTIONAL STATE DISTRIBUTION  ◣",
         text_color=color.white, bgcolor=color.new(cQuantum, 20),
         text_size=ts, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 3, 2)

    table.cell(dash, 0, 3, "State", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 3, "Probability", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, "Pie", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 3, "Trend", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)

    dU = pUp - pUp[1]
    dUarr = dU > 0.005 ? " ↑" : dU < -0.005 ? " ↓" : " →"
    table.cell(dash, 0, 4, "▲ UP",
         text_color=color.white, bgcolor=color.new(cUp, 20),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 4, str.tostring(pUp * 100, "#.##") + "%",
         text_color=color.white, bgcolor=color.new(cUp, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 4, f_bar(pUp, 12),
         text_color=cUp, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 4, str.tostring(dU * 100, "+0.00;-0.00") + "%" + dUarr,
         text_color=dU > 0 ? cUp : cDn, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)

    dD = pDn - pDn[1]
    dDarr = dD > 0.005 ? " ↑" : dD < -0.005 ? " ↓" : " →"
    table.cell(dash, 0, 5, "▼ DOWN",
         text_color=color.white, bgcolor=color.new(cDn, 20),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 5, str.tostring(pDn * 100, "#.##") + "%",
         text_color=color.white, bgcolor=color.new(cDn, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 5, f_bar(pDn, 12),
         text_color=cDn, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 5, str.tostring(dD * 100, "+0.00;-0.00") + "%" + dDarr,
         text_color=dD > 0 ? cDn : cUp, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)

    dS = pSd - pSd[1]
    dSarr = dS > 0.005 ? " ↑" : dS < -0.005 ? " ↓" : " →"
    table.cell(dash, 0, 6, "◆ SIDE",
         text_color=color.white, bgcolor=color.new(cSd, 20),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 6, str.tostring(pSd * 100, "#.##") + "%",
         text_color=color.white, bgcolor=color.new(cSd, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 6, f_bar(pSd, 12),
         text_color=cSd, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 6, str.tostring(dS * 100, "+0.00;-0.00") + "%" + dSarr,
         text_color=dS > 0 ? cSd : cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)

    table.cell(dash, 0, 7, "DOMINANT", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 7, domState + "  " + str.tostring(domProb * 100, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(domCol, 10),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 7, "STRATEGY", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 7, strategy,
         text_color=color.white, bgcolor=color.new(strategyCol, 15),
         text_halign=text.align_center, text_size=size.large)

    // Confidence / coherence
    table.cell(dash, 0, 8, "Confidence", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    confCol = confidence > 0.5 ? cUp : confidence > 0.25 ? cSd : cDn
    table.cell(dash, 1, 8, f_bar(confidence, 10) + " " + str.tostring(confidence * 100, "#.#") + "%",
         text_color=confCol, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 2, 8, "Q-Coherence", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    qcCol = qCoherence > 0.5 ? cQuantum : cMute
    table.cell(dash, 3, 8, f_bar(qCoherence, 10) + " " + str.tostring(qCoherence * 100, "#.#") + "%",
         text_color=qcCol, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)

    // Model breakdown
    table.cell(dash, 0, 9, "◢  MODEL-LEVEL PROBABILITIES  ◣",
         text_color=color.white, bgcolor=color.new(cPurple, 25),
         text_size=ts, text_halign=text.align_center)
    table.merge_cells(dash, 0, 9, 3, 9)

    table.cell(dash, 0, 10, "Model", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 10, "P(Up)", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 10, "P(Dn)", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 10, "P(Sd)", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)

    qMax = math.max(probQup, math.max(probQdn, probQsd))
    table.cell(dash, 0, 11, "⚛ Quantum",
         text_color=color.white, bgcolor=color.new(cQuantum, 30),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 11, str.tostring(probQup * 100, "#.#") + "%",
         text_color=probQup == qMax ? color.white : cText,
         bgcolor=probQup == qMax ? color.new(cUp, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 11, str.tostring(probQdn * 100, "#.#") + "%",
         text_color=probQdn == qMax ? color.white : cText,
         bgcolor=probQdn == qMax ? color.new(cDn, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 11, str.tostring(probQsd * 100, "#.#") + "%",
         text_color=probQsd == qMax ? color.white : cText,
         bgcolor=probQsd == qMax ? color.new(cSd, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)

    kMax = math.max(probKup, math.max(probKdn, probKsd))
    table.cell(dash, 0, 12, "🎯 KNN",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 12, str.tostring(probKup * 100, "#.#") + "%",
         text_color=probKup == kMax ? color.white : cText,
         bgcolor=probKup == kMax ? color.new(cUp, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 12, str.tostring(probKdn * 100, "#.#") + "%",
         text_color=probKdn == kMax ? color.white : cText,
         bgcolor=probKdn == kMax ? color.new(cDn, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 12, str.tostring(probKsd * 100, "#.#") + "%",
         text_color=probKsd == kMax ? color.white : cText,
         bgcolor=probKsd == kMax ? color.new(cSd, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)

    nMax = math.max(probNup, math.max(probNdn, probNsd))
    table.cell(dash, 0, 13, "🧠 Neural",
         text_color=color.white, bgcolor=color.new(cPurple, 30),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 13, str.tostring(probNup * 100, "#.#") + "%",
         text_color=probNup == nMax ? color.white : cText,
         bgcolor=probNup == nMax ? color.new(cUp, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 13, str.tostring(probNdn * 100, "#.#") + "%",
         text_color=probNdn == nMax ? color.white : cText,
         bgcolor=probNdn == nMax ? color.new(cDn, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 13, str.tostring(probNsd * 100, "#.#") + "%",
         text_color=probNsd == nMax ? color.white : cText,
         bgcolor=probNsd == nMax ? color.new(cSd, 40) : cBgRow,
         text_halign=text.align_center, text_size=ts)

    // Feature Vector
    table.cell(dash, 0, 14, "◢  INPUT FEATURE VECTOR  ◣",
         text_color=color.white, bgcolor=color.new(#14b8a6, 25),
         text_size=ts, text_halign=text.align_center)
    table.merge_cells(dash, 0, 14, 3, 14)

    table.cell(dash, 0, 15, "Feature", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 15, "Value", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 15, "Gauge", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 15, "Sign", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)

    psCol = priceStruct > 0.1 ? cUp : priceStruct < -0.1 ? cDn : cMute
    psSig = priceStruct > 0.1 ? "BULLISH" : priceStruct < -0.1 ? "BEARISH" : "NEUTRAL"
    table.cell(dash, 0, 16, "Price Struct", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 1, 16, str.tostring(priceStruct, "+0.000;-0.000"),
         text_color=psCol, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 16, f_bar(math.abs(priceStruct), 10),
         text_color=psCol, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 16, psSig,
         text_color=color.white, bgcolor=color.new(psCol, 40),
         text_halign=text.align_center, text_size=ts)

    lqCol = liquidity > 0.1 ? cUp : liquidity < -0.1 ? cDn : cMute
    lqSig = liquidity > 0.1 ? "BID HVY" : liquidity < -0.1 ? "ASK HVY" : "BAL"
    table.cell(dash, 0, 17, "Liquidity", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 1, 17, str.tostring(liquidity, "+0.000;-0.000"),
         text_color=lqCol, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 17, f_bar(math.abs(liquidity), 10),
         text_color=lqCol, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 17, lqSig,
         text_color=color.white, bgcolor=color.new(lqCol, 40),
         text_halign=text.align_center, text_size=ts)

    stCol = sentiment > 0.1 ? cUp : sentiment < -0.1 ? cDn : cMute
    stSig = sentiment > 0.1 ? "GREED" : sentiment < -0.1 ? "FEAR" : "NEUTRAL"
    table.cell(dash, 0, 18, "Sentiment", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 1, 18, str.tostring(sentiment, "+0.000;-0.000"),
         text_color=stCol, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 18, f_bar(math.abs(sentiment), 10),
         text_color=stCol, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=ts)
    table.cell(dash, 3, 18, stSig,
         text_color=color.white, bgcolor=color.new(stCol, 40),
         text_halign=text.align_center, text_size=ts)

    // Analogs
    table.cell(dash, 0, 19, "◢  TOP-3 HISTORICAL ANALOGS  ◣",
         text_color=color.white, bgcolor=color.new(#f59e0b, 30),
         text_size=ts, text_halign=text.align_center)
    table.merge_cells(dash, 0, 19, 3, 19)

    table.cell(dash, 0, 20, "Rank", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 20, "Bars Ago", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 20, "Avg Dist", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 20, "Fwd Return", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)

    f1col = bestFwd > 0 ? cUp : bestFwd < 0 ? cDn : cMute
    table.cell(dash, 0, 21, "◆ #1", text_color=#f59e0b, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 21, str.tostring(bestIdx) + "b",
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 21, str.tostring(knnAvgDist, "#.###"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 21, str.tostring(bestFwd, "+#.##;-#.##") + "%",
         text_color=color.white, bgcolor=color.new(f1col, 25),
         text_halign=text.align_center, text_size=ts)

    f2col = match2Fwd > 0 ? cUp : match2Fwd < 0 ? cDn : cMute
    table.cell(dash, 0, 22, "◇ #2", text_color=cAccent, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 22, str.tostring(match2Idx) + "b",
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 22, "—",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 22, str.tostring(match2Fwd, "+#.##;-#.##") + "%",
         text_color=color.white, bgcolor=color.new(f2col, 30),
         text_halign=text.align_center, text_size=ts)

    f3col = match3Fwd > 0 ? cUp : match3Fwd < 0 ? cDn : cMute
    table.cell(dash, 0, 23, "◇ #3", text_color=cPurple, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 23, str.tostring(match3Idx) + "b",
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 23, "—",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 23, str.tostring(match3Fwd, "+#.##;-#.##") + "%",
         text_color=color.white, bgcolor=color.new(f3col, 35),
         text_halign=text.align_center, text_size=ts)

    // Quantum internals
    table.cell(dash, 0, 24, "◢  QUANTUM AMPLITUDE INTERNALS  ◣",
         text_color=color.white, bgcolor=color.new(cQuantum, 30),
         text_size=ts, text_halign=text.align_center)
    table.merge_cells(dash, 0, 24, 3, 24)

    table.cell(dash, 0, 25, "|ψ|²",
         text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 25, "Up",
         text_color=cUp, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 25, "Down",
         text_color=cDn, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 25, "Side",
         text_color=cSd, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 26, "Raw",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 26, str.tostring(probQup_raw, "0.000"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 26, str.tostring(probQdn_raw, "0.000"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 26, str.tostring(probQsd_raw, "0.000"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 27, "Re(ψ)",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 27, str.tostring(psiU_re, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 27, str.tostring(psiD_re, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 27, str.tostring(psiS_re, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 28, "Im(ψ)",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 1, 28, str.tostring(psiU_im, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 28, str.tostring(psiD_im, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 28, str.tostring(psiS_im, "+0.00;-0.00"),
         text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=size.small)

    biasCol = dirBias > 0.1 ? cUp : dirBias < -0.1 ? cDn : cSd
    table.cell(dash, 0, 29, "Dir Bias",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 29, str.tostring(dirBias, "+0.000;-0.000"),
         text_color=color.white, bgcolor=color.new(biasCol, 30),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 29, "Entropy",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 29, str.tostring(entropy, "0.000") + " nats",
         text_color=cAccent, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)

    vNB = (volZ > 2 or volZ < -2) ? "⚠ ANOMALY" : "—"
    anomCol = (volZ > 2 or volZ < -2) ? cDn : cMute
    table.cell(dash, 0, 30, "Vol Z",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 1, 30, str.tostring(volZ, "+0.00;-0.00") + "σ",
         text_color=color.white, bgcolor=color.new(anomCol, 30),
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 2, 30, "Status",
         text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_center, text_size=ts)
    table.cell(dash, 3, 30, vNB,
         text_color=color.white, bgcolor=color.new(anomCol, 30),
         text_halign=text.align_center, text_size=ts)

    table.cell(dash, 0, 31, "AetherEdge ⚛ Hybrid Quantum v1.0",
         text_color=cMute, bgcolor=cBgAlt, text_size=size.small,
         text_halign=text.align_center)
    table.merge_cells(dash, 0, 31, 3, 31)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(flipUp, "State Flip → UP",   "AE-HQP: state flipped UP on {{ticker}}")
alertcondition(flipDn, "State Flip → DOWN", "AE-HQP: state flipped DOWN on {{ticker}}")
alertcondition(flipSd, "State Flip → SIDE", "AE-HQP: state flipped SIDE on {{ticker}}")
alertcondition(pUp >= 0.6 and pUp[1] < 0.6, "High Up Prob",   "AE-HQP: P(Up) ≥ 60% on {{ticker}}")
alertcondition(pDn >= 0.6 and pDn[1] < 0.6, "High Down Prob", "AE-HQP: P(Down) ≥ 60% on {{ticker}}")
alertcondition(confidence >= 0.5 and confidence[1] < 0.5,
     "Confidence Spike", "AE-HQP: Confidence ≥ 50% on {{ticker}}")

plot(pUp,        "P_Up",        display=display.none)
plot(pDn,        "P_Down",      display=display.none)
plot(pSd,        "P_Side",      display=display.none)
plot(confidence, "Confidence",  display=display.none)
plot(qCoherence, "Q-Coherence", display=display.none)
plot(dirBias,    "Dir Bias",    display=display.none)
````
