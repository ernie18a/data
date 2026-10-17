# AetherEdge Volatility Regime GAN Simulator

- url: https://www.tradingview.com/script/8AxyBq74/
- type: indicator
- pine_id: PUB;a7056105fbbf48a8910466b755928895
- version: 1.0

## Description

🖊️ Overview
AetherEdge Volatility Regime GAN Simulator is a next-generation volatility forecasting engine that encodes the current market state as a 6-dimensional feature vector, performs K-NN search against a historical database of up to 500 bars, and generates 100 Monte Carlo paths of likely future trajectories. By integrating Haar wavelet decomposition, Softmax-weighted sampling, and K-means regime clustering, it visualizes the future σ distribution as a complete fan chart and histogram. Inspired by Generative Adversarial Networks, it reconstructs future scenarios from historical market patterns — an innovative simulator for the modern trader.

🔶 Key Features

3-Scale Volatility: Short/Medium/Long σ (annualized)
Haar Wavelet Decomposition: high/mid/low frequency triple-scale
6D Feature Vector: σ-z (×3) + VoV-z + Wavelet-z (×2)
K-NN Analog Search: Top-K nearest historical states
Softmax-Weighted Sampling: Temperature τ controls similarity allocation
Monte Carlo Path Generation: 100 paths build future distribution
K-Means Regime Clustering: CALM/NORMAL/ELEVATED/STRESSED/EXTREME/CRISIS
Fan Chart Visualization: P5-P95, P25-P75, median line
Terminal Distribution Histogram: σ_T probability density
Complete Statistical Dashboard: E[σ_T], median, CI90, skew, regime distribution
Match Quality Indicator: ⟨d⟩ assesses analog availability

🧠 Technical Architecture

This indicator is designed as a history-based generative model.

Feature Engineering:
Log-return ret = ln(close/close[1])
3-scale stdev × √(annFactor) for annualized σ
Haar wavelet: |W_s| = √(s/2) × |mean_recent - mean_older|
200-bar z-score normalization (outlier robust)
6D Feature Vector:
z1=σS, z2=σM, z3=σL, z4=VoV, z5=W_hi, z6=W_mid
K-NN Search:
Euclidean distance d = √Σ(z_now - z_hist)²
Top kNeighbors selected
Softmax Sampling:
w_i = exp(-d_i / τ) / Σexp(-d_j / τ)
Low τ → focus on closest, High τ → diversify
Monte Carlo Path Generation:
Per simulation: cumulative probability samples a neighbor
σ-ratio projection pathVol = volS × (histFutVol / nVol)
Innovation noise + noiseAmp × volS × U(-0.5, 0.5)
Quantile Computation:
P5/P25/P50/P75/P95 extracted at each time step
Fan chart + smooth polyline rendering
K-Means Clustering:
2D space (σ-z, VoV-z) classified into 4-6 regimes
Lloyd's algorithm for kmIters iterations
σ-z ascending sort (regime 0 = calmest)
Match Quality Metric:
⟨d⟩ < 1.0: TIGHT (high reliability)
⟨d⟩ < 2.5: LOOSE (moderate)
⟨d⟩ ≥ 2.5: POOR (no analog → warning)

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (Daily): volLen=20, annFactor=365, historyLen=500
ETH (4H): volLen=14, volMed=42, kNeighbors=15
SOL (high-vol): volLen=10, nSims=200, noiseAmp=0.12
XRP (short-term): volLen=14, forecastLen=10, kNeighbors=15
History Depth:

historyLen=200: lightweight, recent only
historyLen=500: standard (recommended)
historyLen=1000+: long-term pattern reference
K-NN Settings:

kNeighbors=10: curated, sharp forecast
kNeighbors=20: standard (balanced)
kNeighbors=50: smooth, conservative
Temperature Parameter:

tempSample=0.3: elite concentration (focus on nearest)
tempSample=1.0: standard (recommended)
tempSample=3.0: diversification (high uncertainty)
Monte Carlo:

nSims=50: lightweight, low-resolution
nSims=100: standard
nSims=200+: high-resolution histogram
Noise Amplitude:

noiseAmp=0.05: conservative (history-faithful)
noiseAmp=0.08: standard
noiseAmp=0.15: exploratory (unknown scenarios)
Regime Count:

nRegimes=3: coarse (simple)
nRegimes=4: standard
nRegimes=6: granular (CALM→CRISIS)

💡 How to Use in Practice

EXPAND forecast + STRESSED: Buy options / strengthen hedges
CONTRACT forecast + CALM: Range strategies / sell premium
Narrow CI90 + TIGHT match: High-confidence forecast, execute strategy
Wide CI90 + POOR match: Unknown territory, exercise caution
P95 > 2× volS: Tail-risk alert, reduce position
Regime Transition Detection:
CALM → ELEVATED: Caution mode
STRESSED → EXTREME: Crisis approaching
EXTREME → STRESSED: Storm passing
Skew Interpretation:
right-tail: Upside risk dominant (vol spike possible)
symmetric: Standard scenario
left-tail: Downside risk dominant (vol crash possible)
AetherEdge Synergy:
SMC AI Confidence Engine: CONTRACT forecast + high-conf zone = compression breakout setup
Self-Evolving S/R Grid: EXPAND forecast + line cluster = breakout preparation
Neural Divergence Hunter: STRESSED + divergence = elevated reversal probability
All-in-One Dashboard: Regime + direction = comprehensive judgment

⚠️ Important Notes

History Dependency: Waits for bar_index > 210 to accumulate history (no early rendering)
POOR Match Warning: ⟨d⟩ > 3.0 indicates low forecast reliability
History-Based Prediction: Cannot handle unprecedented market events
Fan Chart Width: Wide CI90 indicates high uncertainty
Repaint Behavior: Runs only on barstate.islast, displayed at last bar
Computation Load: Large nSims × forecastLen may slow rendering
Cluster Initialization Sensitivity: K-means convergence depends on initial values (increase kmIters for stability)

🚨 Disclaimer

This indicator is an advanced volatility-simulation tool for educational and research purposes only and does not constitute financial advice. GAN-style Monte Carlo prediction is a stochastic simulation method and does not guarantee future volatility. Historical patterns may not repeat — particularly during unprecedented events, the forecast may fail. Use with thorough validation and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Volatility Regime GAN Simulator", "AE-VGAN",
     overlay=false, max_labels_count=500, max_lines_count=500,
     max_boxes_count=500, max_polylines_count=100, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpV = "📊 Volatility Engine"
volLen    = input.int(20,  "Short σ Window",    minval=5,  maxval=100, group=grpV)
volMed    = input.int(50,  "Medium σ Window",   minval=10, maxval=200, group=grpV)
volLong   = input.int(100, "Long σ Window",     minval=20, maxval=500, group=grpV)
annFactor = input.float(252, "Annualization Factor", minval=1, group=grpV,
     tooltip="252 daily equities · 365 crypto · 1 raw")

grpW = "🌊 Haar Wavelet Decomposition"
useWavelet = input.bool(true, "Enable Wavelet Features", group=grpW)
wScale1    = input.int(4,  "Scale 1 (high-freq)", minval=2,  maxval=16,  group=grpW)
wScale2    = input.int(16, "Scale 2 (mid-freq)",  minval=8,  maxval=64,  group=grpW)
wScale3    = input.int(64, "Scale 3 (low-freq)",  minval=32, maxval=256, group=grpW)

grpG = "🧬 GAN Sampling Engine"
historyLen  = input.int(500, "History Depth",         minval=100, maxval=2000, group=grpG)
kNeighbors  = input.int(20,  "K Nearest Neighbors",   minval=5,   maxval=100,  group=grpG)
nSims       = input.int(100, "Monte Carlo Paths",     minval=20,  maxval=400,  group=grpG)
forecastLen = input.int(20,  "Forecast Horizon",      minval=5,   maxval=60,   group=grpG)
tempSample  = input.float(1.0, "Sampling Temp τ",     minval=0.1, maxval=5.0, step=0.1, group=grpG,
     tooltip="Low τ → sharp focus on closest matches · High τ → diversify")
noiseAmp    = input.float(0.08, "Innovation Noise",   minval=0.0, maxval=0.5, step=0.01, group=grpG)

grpC = "🎯 Regime K-Means Clustering"
useCluster = input.bool(true, "Enable Clustering", group=grpC)
nRegimes   = input.int(4, "Number of Regimes", minval=2, maxval=6, group=grpC)
kmIters    = input.int(8, "Iterations",        minval=3, maxval=20, group=grpC)

grpViz = "🎨 Visualization"
darkMode      = input.bool(true, "Dark Mode", group=grpViz)
showBands     = input.bool(true, "Prediction Fan Chart", group=grpViz)
showHisto     = input.bool(true, "Terminal Distribution Histogram", group=grpViz)
histBins      = input.int(15, "Histogram Bins", minval=5, maxval=25, group=grpViz)
showPaths     = input.bool(true, "Sample Paths", group=grpViz)
nShowPaths    = input.int(10, "Paths to Display", minval=0, maxval=25, group=grpViz)
showDash      = input.bool(true, "Dashboard", group=grpViz)
dashPos       = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpViz)

f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg     = darkMode ? color.new(#0a0f1c, 5) : color.new(#f7f9fc, 5)
cBgAlt  = darkMode ? color.new(#111a2e, 0) : color.new(#ffffff, 0)
cBgRow  = darkMode ? color.new(#0f172a, 0) : color.new(#f8fafc, 0)
cBorder = darkMode ? color.new(#1f2a44, 0) : color.new(#d8dee9, 0)
cText   = darkMode ? color.new(#e6edf7, 0) : color.new(#1a202c, 0)
cMute   = darkMode ? color.new(#8892b0, 0) : color.new(#64748b, 0)
cAccent = color.new(#00d4ff, 0)
cBull   = color.new(#00d4a0, 0)
cBear   = color.new(#ff5577, 0)
cWarn   = color.new(#ffa500, 0)
cGold   = color.new(#fde047, 0)
cPurple = color.new(#a855f7, 0)

f_regCol(k) =>
    k == 0 ? color.new(#22c55e, 0) :
     k == 1 ? color.new(#3b82f6, 0) :
     k == 2 ? color.new(#f59e0b, 0) :
     k == 3 ? color.new(#ef4444, 0) :
     k == 4 ? color.new(#a855f7, 0) :
              color.new(#ec4899, 0)

f_regName(k) =>
    k == 0 ? "CALM"     :
     k == 1 ? "NORMAL"   :
     k == 2 ? "ELEVATED" :
     k == 3 ? "STRESSED" :
     k == 4 ? "EXTREME"  :
              "CRISIS"

// ═══════════════════════════════════════════════════════════════
//  VOLATILITY + WAVELET FEATURES
// ═══════════════════════════════════════════════════════════════
ret = math.log(close / math.max(close[1], 1e-10))
ret := na(ret) ? 0.0 : ret

volS     = ta.stdev(ret, volLen)  * math.sqrt(annFactor) * 100
volM     = ta.stdev(ret, volMed)  * math.sqrt(annFactor) * 100
volL     = ta.stdev(ret, volLong) * math.sqrt(annFactor) * 100
volOfVol = ta.stdev(volS, volLen)

// Haar wavelet |W_s| ~ sqrt(n/2) · |mean_recent - mean_older|
f_haar(s) =>
    half = math.max(2, math.round(s / 2))
    a1 = ta.sma(ret, half)
    a2 = ta.sma(ret, half)[half]
    na(a2) ? 0.0 : math.abs(a1 - a2) * math.sqrt(half) * 100

w1 = useWavelet ? f_haar(wScale1) : 0.0
w2 = useWavelet ? f_haar(wScale2) : 0.0
w3 = useWavelet ? f_haar(wScale3) : 0.0

f_z(x, len) =>
    m = ta.sma(x, len)
    sd = ta.stdev(x, len)
    sd == 0 ? 0.0 : (x - m) / sd

z1 = f_z(volS,     200)
z2 = f_z(volM,     200)
z3 = f_z(volL,     200)
z4 = f_z(volOfVol, 200)
z5 = f_z(w1,       200)
z6 = f_z(w2,       200)

// ═══════════════════════════════════════════════════════════════
//  HISTORY BUFFERS (6D feature vectors + realized vol)
// ═══════════════════════════════════════════════════════════════
var histF1  = array.new<float>()
var histF2  = array.new<float>()
var histF3  = array.new<float>()
var histF4  = array.new<float>()
var histF5  = array.new<float>()
var histF6  = array.new<float>()
var histVol = array.new<float>()

if barstate.isconfirmed and not na(z1) and bar_index > 210
    array.push(histF1, z1)
    array.push(histF2, z2)
    array.push(histF3, z3)
    array.push(histF4, z4)
    array.push(histF5, z5)
    array.push(histF6, z6)
    array.push(histVol, volS)
    if array.size(histF1) > historyLen
        array.shift(histF1)
        array.shift(histF2)
        array.shift(histF3)
        array.shift(histF4)
        array.shift(histF5)
        array.shift(histF6)
        array.shift(histVol)

// ═══════════════════════════════════════════════════════════════
//  STORAGE
// ═══════════════════════════════════════════════════════════════
var array<float> centX       = array.new<float>(nRegimes, 0.0)
var array<float> centY       = array.new<float>(nRegimes, 0.0)
var array<int>   regimeCount = array.new<int>(nRegimes, 0)
var int   curRegime    = 0
var float avgKnnDist   = 0.0
var int   bestMatchAgo = 0
var float termMed      = 0.0
var float termP5       = 0.0
var float termP95      = 0.0
var float expVol       = 0.0
var float termStd      = 0.0

// Drawing managers
var array<box>      allBoxes      = array.new<box>()
var array<polyline> allPolylines  = array.new<polyline>()
var array<label>    allLabels     = array.new<label>()
var array<line>     allLines      = array.new<line>()

f_clearAll() =>
    while array.size(allBoxes) > 0
        box.delete(array.pop(allBoxes))
    while array.size(allPolylines) > 0
        polyline.delete(array.pop(allPolylines))
    while array.size(allLabels) > 0
        label.delete(array.pop(allLabels))
    while array.size(allLines) > 0
        line.delete(array.pop(allLines))

// ═══════════════════════════════════════════════════════════════
//  MAIN SIMULATION (last bar only)
// ═══════════════════════════════════════════════════════════════
if barstate.islast
    f_clearAll()
    hSize = array.size(histF1)

    if hSize > forecastLen + kNeighbors + 20
        // ─────── K-MEANS CLUSTERING ───────
        if useCluster
            for k = 0 to nRegimes - 1
                idx = math.min(hSize - 1, math.round((k + 0.5) * hSize / nRegimes))
                array.set(centX, k, array.get(histF1, idx))
                array.set(centY, k, array.get(histF4, idx))

            for iter = 0 to kmIters - 1
                sumX = array.new<float>(nRegimes, 0.0)
                sumY = array.new<float>(nRegimes, 0.0)
                cnt  = array.new<int>(nRegimes, 0)
                for i = 0 to hSize - 1
                    x = array.get(histF1, i)
                    y = array.get(histF4, i)
                    bK = 0
                    bD = 1e10
                    for k = 0 to nRegimes - 1
                        dx = x - array.get(centX, k)
                        dy = y - array.get(centY, k)
                        d = dx * dx + dy * dy
                        if d < bD
                            bD := d
                            bK := k
                    array.set(sumX, bK, array.get(sumX, bK) + x)
                    array.set(sumY, bK, array.get(sumY, bK) + y)
                    array.set(cnt,  bK, array.get(cnt,  bK) + 1)
                for k = 0 to nRegimes - 1
                    if array.get(cnt, k) > 0
                        array.set(centX, k, array.get(sumX, k) / array.get(cnt, k))
                        array.set(centY, k, array.get(sumY, k) / array.get(cnt, k))

            // Sort centroids ascending by σ-z (regime 0 = calmest)
            for i = 0 to nRegimes - 2
                for j = 0 to nRegimes - 2 - i
                    if array.get(centX, j) > array.get(centX, j + 1)
                        tX = array.get(centX, j)
                        tY = array.get(centY, j)
                        array.set(centX, j, array.get(centX, j + 1))
                        array.set(centY, j, array.get(centY, j + 1))
                        array.set(centX, j + 1, tX)
                        array.set(centY, j + 1, tY)

            array.fill(regimeCount, 0)
            for i = 0 to hSize - 1
                x = array.get(histF1, i)
                y = array.get(histF4, i)
                bK = 0
                bD = 1e10
                for k = 0 to nRegimes - 1
                    dx = x - array.get(centX, k)
                    dy = y - array.get(centY, k)
                    d = dx * dx + dy * dy
                    if d < bD
                        bD := d
                        bK := k
                array.set(regimeCount, bK, array.get(regimeCount, bK) + 1)

            bK = 0
            bD = 1e10
            for k = 0 to nRegimes - 1
                dx = z1 - array.get(centX, k)
                dy = z4 - array.get(centY, k)
                d = dx * dx + dy * dy
                if d < bD
                    bD := d
                    bK := k
            curRegime := bK

        // ─────── K-NN SEARCH ───────
        maxIdx = hSize - forecastLen - 1
        distances = array.new<float>()
        for i = 0 to maxIdx
            d1 = z1 - array.get(histF1, i)
            d2 = z2 - array.get(histF2, i)
            d3 = z3 - array.get(histF3, i)
            d4 = z4 - array.get(histF4, i)
            d5 = z5 - array.get(histF5, i)
            d6 = z6 - array.get(histF6, i)
            d = math.sqrt(d1*d1 + d2*d2 + d3*d3 + d4*d4 + d5*d5 + d6*d6)
            array.push(distances, d)

        nearIdx  = array.new<int>()
        nearDist = array.new<float>()
        for k = 0 to kNeighbors - 1
            if array.size(distances) == 0
                break
            minD = array.get(distances, 0)
            minI = 0
            for j = 1 to array.size(distances) - 1
                if array.get(distances, j) < minD
                    minD := array.get(distances, j)
                    minI := j
            array.push(nearIdx, minI)
            array.push(nearDist, minD)
            array.set(distances, minI, 1e10)

        // Softmax weights w_i = exp(-d_i / τ) / Σ
        weights = array.new<float>()
        sumW = 0.0
        for k = 0 to array.size(nearDist) - 1
            w = math.exp(-array.get(nearDist, k) / tempSample)
            array.push(weights, w)
            sumW += w
        if sumW > 0
            for k = 0 to array.size(weights) - 1
                array.set(weights, k, array.get(weights, k) / sumW)

        avgKnnDist   := array.size(nearDist) > 0 ? array.avg(nearDist) : 0.0
        bestMatchAgo := array.size(nearIdx) > 0 ? hSize - array.get(nearIdx, 0) : 0

        // ─────── MONTE CARLO PATH GENERATION ───────
        simPaths     = array.new<float>()
        terminalDist = array.new<float>()

        for sim = 0 to nSims - 1
            u = math.random(0.0, 1.0)
            cum = 0.0
            sampledK = 0
            for k = 0 to array.size(weights) - 1
                cum += array.get(weights, k)
                if u <= cum
                    sampledK := k
                    break

            nIdx = array.get(nearIdx, sampledK)
            nVol = array.get(histVol, nIdx)

            for t = 1 to forecastLen
                fIdx = nIdx + t
                pathVol = volS
                if fIdx < hSize
                    histFutVol = array.get(histVol, fIdx)
                    ratio = nVol <= 0 ? 1.0 : histFutVol / nVol
                    baseProj = volS * ratio
                    noise = (math.random(0.0, 1.0) - 0.5) * volS * noiseAmp
                    pathVol := math.max(0.1, baseProj + noise)
                array.push(simPaths, pathVol)
                if t == forecastLen
                    array.push(terminalDist, pathVol)

        // ─────── QUANTILES PER TIME STEP ───────
        qP5  = array.new<float>()
        qP25 = array.new<float>()
        qP50 = array.new<float>()
        qP75 = array.new<float>()
        qP95 = array.new<float>()

        for t = 0 to forecastLen - 1
            vals = array.new<float>()
            for sim = 0 to nSims - 1
                idx = sim * forecastLen + t
                if idx < array.size(simPaths)
                    array.push(vals, array.get(simPaths, idx))
            array.sort(vals)
            n = array.size(vals)
            if n > 0
                array.push(qP5,  array.get(vals, math.max(0, math.floor(n * 0.05))))
                array.push(qP25, array.get(vals, math.max(0, math.floor(n * 0.25))))
                array.push(qP50, array.get(vals, math.max(0, math.floor(n * 0.50))))
                array.push(qP75, array.get(vals, math.min(n-1, math.floor(n * 0.75))))
                array.push(qP95, array.get(vals, math.min(n-1, math.floor(n * 0.95))))

        if array.size(qP50) > 0
            termMed := array.get(qP50, array.size(qP50) - 1)
            termP5  := array.get(qP5,  array.size(qP5)  - 1)
            termP95 := array.get(qP95, array.size(qP95) - 1)
            sumP = 0.0
            for i = 0 to array.size(terminalDist) - 1
                sumP += array.get(terminalDist, i)
            expVol := sumP / array.size(terminalDist)
            // Std of terminal
            sqSum = 0.0
            for i = 0 to array.size(terminalDist) - 1
                d = array.get(terminalDist, i) - expVol
                sqSum += d * d
            termStd := math.sqrt(sqSum / array.size(terminalDist))

        // ─────── DRAW FAN CHART (boxes for fills) ───────
        if showBands and array.size(qP50) > 0
            for t = 0 to array.size(qP50) - 1
                x1 = bar_index + t
                x2 = bar_index + t + 1
                // Outer band (p5..p95)
                array.push(allBoxes, box.new(x1, array.get(qP95, t), x2, array.get(qP5, t),
                     bgcolor=color.new(cBear, 90), border_color=na))
                // Inner band (p25..p75)
                array.push(allBoxes, box.new(x1, array.get(qP75, t), x2, array.get(qP25, t),
                     bgcolor=color.new(cWarn, 80), border_color=na))

            // Median polyline
            medPts = array.new<chart.point>()
            array.push(medPts, chart.point.from_index(bar_index, volS))
            for t = 0 to array.size(qP50) - 1
                array.push(medPts, chart.point.from_index(bar_index + t + 1, array.get(qP50, t)))
            array.push(allPolylines, polyline.new(medPts, curved=false,
                 line_color=cAccent, line_width=3))

            // Envelope polylines
            p5Pts = array.new<chart.point>()
            p95Pts = array.new<chart.point>()
            array.push(p5Pts,  chart.point.from_index(bar_index, volS))
            array.push(p95Pts, chart.point.from_index(bar_index, volS))
            for t = 0 to array.size(qP5) - 1
                array.push(p5Pts,  chart.point.from_index(bar_index + t + 1, array.get(qP5,  t)))
                array.push(p95Pts, chart.point.from_index(bar_index + t + 1, array.get(qP95, t)))
            array.push(allPolylines, polyline.new(p5Pts,  curved=false,
                 line_color=color.new(cBear, 40), line_width=1, line_style=line.style_dashed))
            array.push(allPolylines, polyline.new(p95Pts, curved=false,
                 line_color=color.new(cBear, 40), line_width=1, line_style=line.style_dashed))

            // Terminal labels
            lastT = array.size(qP50) - 1
            array.push(allLabels, label.new(bar_index + lastT + 1, termMed,
                 " μ " + str.tostring(termMed, "#.##"),
                 color=color.new(cAccent, 15), textcolor=color.white,
                 style=label.style_label_left, size=size.small))
            array.push(allLabels, label.new(bar_index + lastT + 1, termP95,
                 " 95% " + str.tostring(termP95, "#.##"),
                 color=color.new(cBear, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.tiny))
            array.push(allLabels, label.new(bar_index + lastT + 1, termP5,
                 " 5% " + str.tostring(termP5, "#.##"),
                 color=color.new(cBull, 30), textcolor=color.white,
                 style=label.style_label_left, size=size.tiny))

        // ─────── SAMPLE PATHS ───────
        if showPaths and nShowPaths > 0
            pShow = math.min(nShowPaths, nSims)
            step  = math.max(1, math.floor(nSims / pShow))
            sim = 0
            pathsDrawn = 0
            while sim < nSims and pathsDrawn < pShow and array.size(allPolylines) < 80
                pathPts = array.new<chart.point>()
                array.push(pathPts, chart.point.from_index(bar_index, volS))
                for t = 0 to forecastLen - 1
                    idx = sim * forecastLen + t
                    if idx < array.size(simPaths)
                        array.push(pathPts, chart.point.from_index(
                             bar_index + t + 1, array.get(simPaths, idx)))
                array.push(allPolylines, polyline.new(pathPts, curved=false,
                     line_color=color.new(cPurple, 75), line_width=1))
                pathsDrawn += 1
                sim += step

        // ─────── TERMINAL DISTRIBUTION HISTOGRAM ───────
        if showHisto and array.size(terminalDist) > 0
            tSorted = array.copy(terminalDist)
            array.sort(tSorted)
            minV = array.get(tSorted, 0)
            maxV = array.get(tSorted, array.size(tSorted) - 1)
            binW = (maxV - minV) / histBins

            if binW > 0
                counts = array.new<int>(histBins, 0)
                for i = 0 to array.size(terminalDist) - 1
                    v = array.get(terminalDist, i)
                    b = math.min(histBins - 1, math.max(0, math.floor((v - minV) / binW)))
                    array.set(counts, b, array.get(counts, b) + 1)

                maxCnt = array.max(counts)
                xStart = bar_index + forecastLen + 3
                mxW = 22
                medianBin = math.min(histBins - 1, math.max(0, math.floor((termMed - minV) / binW)))

                for b = 0 to histBins - 1
                    c = array.get(counts, b)
                    if c > 0 and maxCnt > 0
                        w = math.max(1, math.round(c / maxCnt * mxW))
                        yBot = minV + b * binW
                        yTop = minV + (b + 1) * binW
                        isMed = b == medianBin
                        bc = b < histBins / 3 ? cBull :
                             b < 2 * histBins / 3 ? cAccent : cBear
                        array.push(allBoxes, box.new(xStart, yTop, xStart + w, yBot,
                             bgcolor=color.new(bc, isMed ? 10 : 45),
                             border_color=isMed ? cGold : color.new(bc, 20),
                             border_width=isMed ? 2 : 1))

                // Histogram header
                array.push(allLabels, label.new(xStart + mxW / 2, maxV + binW * 0.5,
                     "P(σ_T)  N=" + str.tostring(array.size(terminalDist)),
                     color=color.new(#111a2e, 20), textcolor=cAccent,
                     style=label.style_label_down, size=size.small))

                // Mean marker
                array.push(allLines, line.new(xStart - 1, expVol, xStart + mxW + 1, expVol,
                     color=cAccent, width=1, style=line.style_dotted))
                array.push(allLabels, label.new(xStart + mxW + 1, expVol,
                     " E[σ_T]=" + str.tostring(expVol, "#.##"),
                     color=color.new(cAccent, 20), textcolor=color.white,
                     style=label.style_label_left, size=size.tiny))

// ═══════════════════════════════════════════════════════════════
//  PRIMARY PLOTS
// ═══════════════════════════════════════════════════════════════
plot(volS, "σ Short",  color=cAccent,                   linewidth=2)
plot(volM, "σ Medium", color=color.new(cGold,   40),    linewidth=1)
plot(volL, "σ Long",   color=color.new(cPurple, 60),    linewidth=1)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 5, 25,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    table.cell(dash, 0, 0, "◆  AETHEREDGE · VOLATILITY GAN SIMULATOR  ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 4, 0)

    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period + "  ·  "
         + "hist " + str.tostring(array.size(histF1)) + "b  ·  "
         + "K=" + str.tostring(kNeighbors) + "  ·  "
         + "M=" + str.tostring(nSims) + " paths",
         text_color=cMute, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 4, 1)

    // Section: Current state
    table.cell(dash, 0, 2, "◢  CURRENT VOLATILITY STATE  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 4, 2)

    table.cell(dash, 0, 3, "σ Short", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 3, str.tostring(volS, "#.##") + "%",
         text_color=color.white, bgcolor=color.new(cAccent, 25),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 3, "σ Medium", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 3, str.tostring(volM, "#.##") + "%",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 3, "σ L " + str.tostring(volL, "#.##") + "%",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    zCol = math.abs(z1) < 0.5 ? cMute :math.abs(z1) < 1.5 ? cWarn :math.abs(z1) < 2.5 ? cBear : cPurple
    table.cell(dash, 0, 4, "Z-score", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 4, str.tostring(z1, "+0.00;-0.00"),
         text_color=color.white, bgcolor=color.new(zCol, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 4, "Vol-of-Vol", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 4, str.tostring(volOfVol, "#.###"),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 4, "VoV-z " + str.tostring(z4, "+0.0"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    regName = useCluster ? f_regName(curRegime) : "—"
    regCol  = useCluster ? f_regCol(curRegime)  : cMute
    regPct  = useCluster and array.size(histF1) > 0 ?
         array.get(regimeCount, curRegime) / array.size(histF1) * 100 : 0.0
    table.cell(dash, 0, 5, "Regime", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 5, regName,
         text_color=color.white, bgcolor=color.new(regCol, 15),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 5, "ID", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 5, useCluster ? str.tostring(curRegime + 1) + "/" + str.tostring(nRegimes) : "—",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 5, str.tostring(regPct, "#.#") + "% hist",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    // Wavelet
    table.cell(dash, 0, 6, "◢  HAAR WAVELET DECOMPOSITION  ◣",
         text_color=color.white, bgcolor=color.new(#14b8a6, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 6, 4, 6)

    table.cell(dash, 0, 7, "|W_hi|",  text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 7, str.tostring(w1, "#.###"),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 7, "|W_mid|", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 7, str.tostring(w2, "#.###"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 7, "|W_lo| " + str.tostring(w3, "#.##"),
         text_color=cPurple, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    // Forecast
    table.cell(dash, 0, 8, "◢  GAN FORECAST · T+" + str.tostring(forecastLen) + "  ◣",
         text_color=color.white, bgcolor=color.new(cGold, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 8, 4, 8)

    direction = termMed > volS * 1.1 ? "↑ EXPAND" :
                 termMed < volS * 0.9 ? "↓ CONTRACT" : "→ STABLE"
    dirCol = termMed > volS * 1.1 ? cBear :
              termMed < volS * 0.9 ? cBull : cMute

    table.cell(dash, 0, 9, "E[σ_T]", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 9, str.tostring(expVol, "#.##") + "%",
         text_color=color.white, bgcolor=color.new(cAccent, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 9, "Median", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 9, str.tostring(termMed, "#.##") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 9, direction,
         text_color=color.white, bgcolor=color.new(dirCol, 20),
         text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 10, "P5", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 10, str.tostring(termP5, "#.##") + "%",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 10, "P95", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 10, str.tostring(termP95, "#.##") + "%",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    ciW = termP95 - termP5
    ciCol = ciW / math.max(volS, 0.01) < 0.3 ? cBull :
             ciW / math.max(volS, 0.01) < 0.6 ? cWarn : cBear
    table.cell(dash, 4, 10, "CI90 " + str.tostring(ciW, "#.#"),
         text_color=ciCol, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 11, "σ(σ_T)", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 11, str.tostring(termStd, "#.###"),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    skewApprox = expVol > 0 ? (expVol - termMed) / math.max(termStd, 0.001) : 0
    skewLabel = skewApprox > 0.2 ? "right-tail" :
                 skewApprox < -0.2 ? "left-tail" : "symmetric"
    table.cell(dash, 2, 11, "Skew", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 11, str.tostring(skewApprox, "+0.00;-0.00"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 11, skewLabel,
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    // K-NN
    table.cell(dash, 0, 12, "◢  K-NN NEAREST MATCHES  ◣",
         text_color=color.white, bgcolor=color.new(cPurple, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 12, 4, 12)

    dCol = avgKnnDist < 1.0 ? cBull : avgKnnDist < 2.5 ? cWarn : cBear
    mq   = avgKnnDist < 1.0 ? "✓ TIGHT" : avgKnnDist < 2.5 ? "~ LOOSE" : "✗ POOR"
    table.cell(dash, 0, 13, "K", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 13, str.tostring(kNeighbors),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 13, "⟨d⟩", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 13, str.tostring(avgKnnDist, "#.###"),
         text_color=color.white, bgcolor=color.new(dCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 13, mq,
         text_color=color.white, bgcolor=color.new(dCol, 20),
         text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 14, "Best Ago", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 14, str.tostring(bestMatchAgo) + "b",
         text_color=cGold, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 14, "τ", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 14, str.tostring(tempSample, "#.##"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 14, "noise " + str.tostring(noiseAmp * 100, "#") + "%",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)

    // Regime distribution
    if useCluster
        table.cell(dash, 0, 15, "◢  REGIME CENTROIDS (σ-z , VoV-z)  ◣",
             text_color=color.white, bgcolor=color.new(#3b82f6, 30),
             text_size=size.normal, text_halign=text.align_center)
        table.merge_cells(dash, 0, 15, 4, 15)

        table.cell(dash, 0, 16, "Regime", text_color=cMute, bgcolor=cBgAlt,
             text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 1, 16, "μ(σ-z)", text_color=cMute, bgcolor=cBgAlt,
             text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 2, 16, "μ(VoV-z)", text_color=cMute, bgcolor=cBgAlt,
             text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 3, 16, "Count", text_color=cMute, bgcolor=cBgAlt,
             text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 4, 16, "Share", text_color=cMute, bgcolor=cBgAlt,
             text_halign=text.align_center, text_size=size.small)

        for k = 0 to math.min(nRegimes - 1, 5)
            row = 17 + k
            cnt = array.get(regimeCount, k)
            pct = array.size(histF1) > 0 ? cnt / array.size(histF1) * 100 : 0.0
            isCur = k == curRegime
            rBg = isCur ? color.new(f_regCol(k), 75) : cBgRow
            nm = f_regName(k) + (isCur ? "  ◀" : "")

            table.cell(dash, 0, row, nm,
                 text_color=color.white, bgcolor=color.new(f_regCol(k), isCur ? 15 : 45),
                 text_halign=text.align_center, text_size=size.small)
            table.cell(dash, 1, row, str.tostring(array.get(centX, k), "+0.00;-0.00"),
                 text_color=cText, bgcolor=rBg,
                 text_halign=text.align_center, text_size=size.small)
            table.cell(dash, 2, row, str.tostring(array.get(centY, k), "+0.00;-0.00"),
                 text_color=cText, bgcolor=rBg,
                 text_halign=text.align_center, text_size=size.small)
            table.cell(dash, 3, row, str.tostring(cnt),
                 text_color=cText, bgcolor=rBg,
                 text_halign=text.align_center, text_size=size.small)
            table.cell(dash, 4, row, str.tostring(pct, "#.#") + "%",
                 text_color=cAccent, bgcolor=rBg,
                 text_halign=text.align_center, text_size=size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(barstate.islast and termMed > volS * 1.2,
     "Vol Expansion Expected", "AE-VGAN: expected σ expansion ≥20% on {{ticker}}")
alertcondition(barstate.islast and termMed < volS * 0.8,
     "Vol Contraction Expected", "AE-VGAN: expected σ contraction ≥20% on {{ticker}}")
alertcondition(barstate.islast and termP95 > volS * 2.0,
     "Tail Risk Elevated", "AE-VGAN: P95 terminal σ >2× current on {{ticker}}")
alertcondition(barstate.islast and avgKnnDist > 3.0,
     "No Historical Analog", "AE-VGAN: current state has no tight historical match — forecast unreliable")

// Payload plots
plot(termMed, "Forecast Median", display=display.none)
plot(expVol,  "Forecast Mean",   display=display.none)
plot(termP95, "Forecast P95",    display=display.none)
plot(termP5,  "Forecast P5",     display=display.none)
plot(curRegime, "Current Regime", display=display.none)
````
