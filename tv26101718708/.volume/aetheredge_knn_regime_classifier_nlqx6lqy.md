# AetherEdge KNN Regime Classifier

- url: https://www.tradingview.com/script/nLqX6lQy/
- type: indicator
- pine_id: PUB;925273d1dd6f491eb1a3444f307563c8
- version: 1.0

## Description

🖊️ Overview
AetherEdge KNN Regime Classifier is an innovative memory-based machine learning regime classifier that fully implements the k-Nearest Neighbors (k-NN) algorithm in Pine Script. It memorizes up to 2,000 historical patterns, retrieves the k most similar past patterns matching the current 8-dimensional feature vector, and classifies the market into five regimes (Trending Up / Trending Down / Range / Breakout / Reversal) in real time via majority voting. Each regime's forward returns and historical win-rate are statistically tracked, providing multi-dimensional data-driven trade support.

🔶 Key Features

True k-NN Implementation: k tunable from 3–50, odd numbers preferred
Memory Bank: Up to 2,000 patterns stored, FIFO auto-discard
3 Distance Metrics: Euclidean / Manhattan / Cosine
2 Voting Schemes: Majority / Distance-weighted (1/d)
5 Regime Classification: Trending▲ / Trending▼ / Range / Breakout / Reversal
Forward-Looking Validation: Each pattern verified against N-bar future return
8-D Feature Vector: ADX/DMI/BBW/RSI/Volume/Slope/Position/ROC
Live Win-Rate Table: Statistical edge of each regime visualized
KNN Distance Heatmap: Nearest-to-farthest distance distribution
Vote Distribution Bars: % bars showing votes per regime
Confidence Computation: Auto-derived from vote concentration
Regime Background Tinting: Instant chart-wide regime visibility
High-Confidence Regime Shift Alert: Triggered at Confidence > 85%

🧠 Technical Architecture

This indicator is a top-tier regime classification engine fully implementing k-NN, the flagship of memory-based (lazy) learning.

k-NN Algorithm:
Compute query vector q = [f1, f2, ..., f8]
Calculate distance d(q, m_i) to all memory patterns
Select top-k by ascending distance
Vote: argmax_l Σ w_i × [label_i == l]
Distance Metrics:
Euclidean: √Σ(q_i - m_i)² — standard geometric
Manhattan: Σ|q_i - m_i| — outlier-robust
Cosine: 1 - (q·m)/(|q||m|) — direction-focused
Weighting Schemes:
Majority: Plain vote
Distance-weighted: w = 1/(d + ε) — closer = stronger
Feature Engineering (8-D):
f1: ADX strength (trend presence)
f2: DMI differential (direction)
f3: BBW ratio (volatility expansion)
f4: RSI normalized (momentum)
f5: Volume z-score (liquidity)
f6: Linear Regression Slope (structural tilt)
f7: Range Position (within high-low)
f8: ROC (rate of change)
Regime Labeling Rules:
Breakout: BBW > 1.5×avg AND Volume > 1.8×avg AND |ROC| > 1.0
Reversal: RSI extreme AND ROC sign flipped
Trending Up: ADX > 25 AND DI+ > DI- AND Slope > 0
Trending Down: ADX > 25 AND DI- > DI+ AND Slope < 0
Range: ADX < 18 AND BBW < 1.2×avg
Forward-Looking Validation: Win/loss decided after N (default 5) bars
Memory Management: Staging queue → committed after forward window → FIFO once size exceeded

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–D): k=15, Memory=500, Forward=5 (standard)
ETH (1H–4H): k=11, Cosine, Forward=8
SOL (high-vol): k=21, Manhattan (outlier-robust)
XRP (range-heavy): k=9, Forward=3 for short-horizon edge
k Tuning:

k=3–7: High sensitivity, noisy
k=11–15: Balanced (recommended)
k=21–31: Smooth, may dilute rare patterns
Memory Size:

300: Lightweight, recent-trend focused
500: Standard
1000–2000: Long-term stats, heavy compute
Forward Bars:

3: Scalping
5: Standard
10–15: Swing-oriented
Distance Metric Selection:

Euclidean: Standard, balanced
Manhattan: High-vol assets, outlier-heavy
Cosine: Pattern-shape focus, magnitude-agnostic

💡 How to Use in Practice

Trending▲ + Confidence > 70%: Optimal trend-following entry
Breakout detected: Activate volatility-breakout strategies
Reversal warning: Reduce trend-follow size, consider counter-trend
Range: Range/grid strategies fit
Win-Rate Table analysis: Discover statistically dominant regimes for your asset
Avg Ret monitoring: Trending▲ with high +Avg Ret = trend-follow valid
Confidence < 50%: Vote dispersion, regime unclear—reduce size
Heatmap green-dominant: Abundant similar patterns, high prediction trust
Heatmap red-dominant: Uncharted territory—proceed cautiously
AetherEdge Synergy:
NeuraNet Predictor: KNN Trending▲ + NeuraNet > 0.7 = dual AI conviction
Self-Evolving S/R Grid: Breakout regime + line breach = strong entry
All-in-One Dashboard: HIGH-CONVICTION + high KNN confidence = ultimate alignment
Multi-TF: 4H KNN regime → 1H strategy selection → 15M precision entry

⚠️ Important Notes

Learning Reset: Memory wipes on chart reload; rebuild required
Min Samples (50): Classification disabled prior; wait phase mandatory
FIFO Memory: Old patterns auto-discarded for regime adaptation
Compute Load: Memory=2000 + k=50 is heavy; use 500/15 on low-spec
Feature NaN: Features undefined initially; accumulation starts after structLen+50 bars
Rare regimes: Reversal/Breakout occur infrequently; small N = unstable stats
Forward Window Lag: Most recent N bars not yet labeled; memory commit delayed

🚨 Disclaimer

This indicator is a machine learning demonstration provided for educational and research purposes only and does not constitute financial advice. k-NN classification results derive from statistical similarity to past patterns and do not guarantee future profits. Reliability depends on market conditions, asset, and timeframe. Combine with independent analysis and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge KNN Regime Classifier", "AE-KNN",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpK = "🎯 KNN Algorithm"
kNeighbors   = input.int(15, "k (neighbors)", minval=3, maxval=50, group=grpK,
     tooltip="Number of nearest neighbors to poll. Odd numbers preferred.")
memorySize   = input.int(500, "Memory Bank Size", minval=100, maxval=2000, group=grpK,
     tooltip="Max historical patterns stored. Older patterns get discarded (FIFO).")
distMetric   = input.string("Euclidean", "Distance Metric",
     options=["Euclidean","Manhattan","Cosine"], group=grpK)
weighting    = input.string("Distance-weighted", "Voting Scheme",
     options=["Majority","Distance-weighted"], group=grpK,
     tooltip="Distance-weighted gives closer neighbors more influence (1/d).")
forwardBars  = input.int(5, "Forward-looking Win Bars", minval=1, maxval=20, group=grpK,
     tooltip="Bars ahead to measure each regime's historical win rate.")
minSamples   = input.int(50, "Min Memory before Classification", minval=20, group=grpK)

grpF = "📊 Feature Engineering"
adxLen   = input.int(14,  "ADX Length", minval=2, group=grpF)
atrLen   = input.int(14,  "ATR Length", minval=2, group=grpF)
bbLen    = input.int(20,  "BB Length",  minval=2, group=grpF)
bbMult   = input.float(2.0, "BB Mult",  step=0.1, group=grpF)
rsiLen   = input.int(14,  "RSI Length", minval=2, group=grpF)
volLen   = input.int(20,  "Volume MA",  minval=2, group=grpF)
structLen = input.int(20, "Structure Lookback", minval=5, group=grpF)

grpL = "🏷 Regime Labeling Rules"
adxTrend    = input.float(25.0, "ADX Trend Threshold",   step=0.5, group=grpL,
     tooltip="ADX above this = trend candidate")
adxRange    = input.float(18.0, "ADX Range Threshold",   step=0.5, group=grpL,
     tooltip="ADX below this = range candidate")
bbwBreakout = input.float(1.5,  "BBW Expansion (× avg)", step=0.1, group=grpL,
     tooltip="Band width multiple for breakout regime")
volBreakout = input.float(1.8,  "Volume Spike (× avg)",  step=0.1, group=grpL)
revRsiHi    = input.float(70.0, "Reversal RSI High", step=0.5, group=grpL)
revRsiLo    = input.float(30.0, "Reversal RSI Low",  step=0.5, group=grpL)

grpD = "🎨 Display"
darkMode     = input.bool(true, "Dark Mode", group=grpD)
showBG       = input.bool(true, "Regime Background Tint", group=grpD)
showHeatmap  = input.bool(true, "Show KNN Distance Heatmap", group=grpD)
showWinTable = input.bool(true, "Show Regime Win-Rate Table", group=grpD)
heatmapCells = input.int(20, "Heatmap Cells", minval=10, maxval=40, group=grpD)
dashPos      = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)
heatPos      = input.string("Bottom Right", "Heatmap Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)

// ═══════════════════════════════════════════════════════════════
//  PALETTE  ← FIX: cBear declared here, BEFORE f_labelCol uses it
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt   = darkMode ? color.new(#111a2e, 10) : color.new(#ffffff, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)

// Regime colors
cTrend   = color.new(#00d4a0, 0)  // Trending up (green)
cBear    = color.new(#ff5577, 0)  // Trending down (red)  ← FIX: added here
cRange   = color.new(#ffa500, 0)  // Range (orange)
cBreak   = color.new(#c084fc, 0)  // Breakout (purple)
cRev     = color.new(#ff5577, 0)  // Reversal (red/pink)
cUnknown = color.new(#64748b, 0)

// ═══════════════════════════════════════════════════════════════
//  GLOBAL HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════
f_labelName(l) =>
    l == 0 ? "Trending ▲" :
     l == 1 ? "Trending ▼" :
     l == 2 ? "Range" :
     l == 3 ? "Breakout" :
     l == 4 ? "Reversal" : "Unknown"

f_labelShort(l) =>
    l == 0 ? "TRN▲" :
     l == 1 ? "TRN▼" :
     l == 2 ? "RNG" :
     l == 3 ? "BRK" :
     l == 4 ? "REV" : "???"

f_labelCol(l) =>
    l == 0 ? cTrend :
     l == 1 ? cBear :
     l == 2 ? cRange :
     l == 3 ? cBreak :
     l == 4 ? cRev : cUnknown

f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// Distance function for KNN
f_dist(metric, xArr, memArr, memIdx, nf) =>
    d = 0.0
    if metric == "Euclidean"
        for i = 0 to nf - 1
            diff = array.get(xArr, i) - array.get(memArr, memIdx * nf + i)
            d += diff * diff
        d := math.sqrt(d)
    else if metric == "Manhattan"
        for i = 0 to nf - 1
            d += math.abs(array.get(xArr, i) - array.get(memArr, memIdx * nf + i))
    else  // Cosine distance = 1 - cosine similarity
        dot = 0.0
        na2 = 0.0
        nb2 = 0.0
        for i = 0 to nf - 1
            a = array.get(xArr, i)
            b = array.get(memArr, memIdx * nf + i)
            dot += a * b
            na2 += a * a
            nb2 += b * b
        denom = math.sqrt(na2) * math.sqrt(nb2)
        d := denom > 0 ? 1.0 - dot / denom : 1.0
    d

// ═══════════════════════════════════════════════════════════════
//  FEATURE ENGINEERING (normalized to ~[-1, +1] or [0, 1])
// ═══════════════════════════════════════════════════════════════
[dip, dim, adxVal] = ta.dmi(adxLen, adxLen)
atr      = ta.atr(atrLen)
atrPct   = atr / close * 100

bbBasis  = ta.sma(close, bbLen)
bbDev    = bbMult * ta.stdev(close, bbLen)
bbUpper  = bbBasis + bbDev
bbLower  = bbBasis - bbDev
bbWidth  = (bbUpper - bbLower) / bbBasis * 100
bbwAvg   = ta.sma(bbWidth, 50)
bbwRatio = bbwAvg > 0 ? bbWidth / bbwAvg : 1.0

rsi      = ta.rsi(close, rsiLen)
volMa    = ta.sma(volume, volLen)
volRatio = volMa > 0 ? volume / volMa : 1.0

// Structural slope
slope    = ta.linreg(close, structLen, 0) - ta.linreg(close, structLen, structLen - 1)
slopePct = close > 0 ? slope / close * 100 : 0

// High-low range position
hh = ta.highest(high, structLen)
ll = ta.lowest(low, structLen)
rangePos = hh > ll ? (close - ll) / (hh - ll) : 0.5

// Momentum (ROC)
rocVal = ta.roc(close, 10)

// Feature vector (8 dimensions), normalized
f1 = math.max(-1, math.min(1, (adxVal - 25) / 25))
f2 = math.max(-1, math.min(1, (dip - dim) / 50))
f3 = math.max(-1, math.min(1, (bbwRatio - 1) / 2))
f4 = math.max(-1, math.min(1, (rsi - 50) / 50))
f5 = math.max(-1, math.min(1, math.log(volRatio) / 1.5))
f6 = math.max(-1, math.min(1, slopePct / 2))
f7 = (rangePos - 0.5) * 2
f8 = math.max(-1, math.min(1, rocVal / 5))

NF = 8

// ═══════════════════════════════════════════════════════════════
//  REGIME LABELING  ← FIX: 'label' renamed to 'curLabel'
// ═══════════════════════════════════════════════════════════════
isTrendingUp   = adxVal > adxTrend and dip > dim and slopePct > 0
isTrendingDown = adxVal > adxTrend and dim > dip and slopePct < 0
isRange        = adxVal < adxRange and bbwRatio < 1.2
isBreakout     = bbwRatio > bbwBreakout and volRatio > volBreakout and math.abs(rocVal) > 1.0
isReversal     = (rsi > revRsiHi or rsi < revRsiLo) and math.sign(rocVal) != math.sign(nz(rocVal[5], rocVal))

curLabel =
     isBreakout     ? 3 :
     isReversal     ? 4 :
     isTrendingUp   ? 0 :
     isTrendingDown ? 1 :
     isRange        ? 2 :
                      2

// ═══════════════════════════════════════════════════════════════
//  MEMORY BANK
// ═══════════════════════════════════════════════════════════════
var array<float> memFeat   = array.new<float>(0)
var array<int>   memLabel  = array.new<int>(0)
var array<float> memFwdRet = array.new<float>(0)
var array<int>   memBar    = array.new<int>(0)

// Staging queue
var array<float> stagedFeat   = array.new<float>(0)
var array<int>   stagedLabel  = array.new<int>(0)
var array<float> stagedClose  = array.new<float>(0)
var array<int>   stagedBarIdx = array.new<int>(0)

if barstate.isconfirmed and bar_index > structLen + 50 and not na(adxVal) and not na(bbwRatio)
    array.push(stagedFeat, f1)
    array.push(stagedFeat, f2)
    array.push(stagedFeat, f3)
    array.push(stagedFeat, f4)
    array.push(stagedFeat, f5)
    array.push(stagedFeat, f6)
    array.push(stagedFeat, f7)
    array.push(stagedFeat, f8)
    array.push(stagedLabel, curLabel)
    array.push(stagedClose, close)
    array.push(stagedBarIdx, bar_index)

    while array.size(stagedBarIdx) > 0 and bar_index - array.get(stagedBarIdx, 0) >= forwardBars
        pastClose = array.get(stagedClose, 0)
        fwdRet = pastClose > 0 ? (close - pastClose) / pastClose * 100 : 0

        for i = 0 to NF - 1
            array.push(memFeat, array.get(stagedFeat, i))
        array.push(memLabel,  array.get(stagedLabel,  0))
        array.push(memFwdRet, fwdRet)
        array.push(memBar,    array.get(stagedBarIdx, 0))

        for i = 0 to NF - 1
            array.shift(stagedFeat)
        array.shift(stagedLabel)
        array.shift(stagedClose)
        array.shift(stagedBarIdx)

        if array.size(memLabel) > memorySize
            for i = 0 to NF - 1
                array.shift(memFeat)
            array.shift(memLabel)
            array.shift(memFwdRet)
            array.shift(memBar)

// ═══════════════════════════════════════════════════════════════
//  KNN CLASSIFICATION
// ═══════════════════════════════════════════════════════════════
var array<float> qFeat = array.new<float>(NF, 0.0)
array.set(qFeat, 0, nz(f1))
array.set(qFeat, 1, nz(f2))
array.set(qFeat, 2, nz(f3))
array.set(qFeat, 3, nz(f4))
array.set(qFeat, 4, nz(f5))
array.set(qFeat, 5, nz(f6))
array.set(qFeat, 6, nz(f7))
array.set(qFeat, 7, nz(f8))

var int    predictedLabel = -1
var float  conf = 0.0
var array<float> labelVotes = array.new<float>(5, 0.0)
var array<float> kDists     = array.new<float>(0)
var array<int>   kLabels    = array.new<int>(0)
var array<float> kFwdRets   = array.new<float>(0)

memCount = array.size(memLabel)
ready = memCount >= minSamples

if barstate.isconfirmed and ready
    dists = array.new<float>(memCount, 0.0)
    for m = 0 to memCount - 1
        array.set(dists, m, f_dist(distMetric, qFeat, memFeat, m, NF))

    kReal = math.min(kNeighbors, memCount)
    array.clear(kDists)
    array.clear(kLabels)
    array.clear(kFwdRets)

    usedMask = array.new<bool>(memCount, false)
    for kk = 0 to kReal - 1
        bestD = 1e20
        bestI = -1
        for m = 0 to memCount - 1
            if not array.get(usedMask, m)
                dd = array.get(dists, m)
                if dd < bestD
                    bestD := dd
                    bestI := m
        if bestI >= 0
            array.set(usedMask, bestI, true)
            array.push(kDists,   bestD)
            array.push(kLabels,  array.get(memLabel,  bestI))
            array.push(kFwdRets, array.get(memFwdRet, bestI))

    // Vote
    array.fill(labelVotes, 0.0)
    totalW = 0.0
    for kk = 0 to array.size(kDists) - 1
        lab = array.get(kLabels, kk)
        w = weighting == "Distance-weighted" ? 1.0 / (array.get(kDists, kk) + 1e-6) : 1.0
        array.set(labelVotes, lab, array.get(labelVotes, lab) + w)
        totalW += w

    // Argmax
    bestLab = 0
    bestV = array.get(labelVotes, 0)
    for l = 1 to 4
        if array.get(labelVotes, l) > bestV
            bestV := array.get(labelVotes, l)
            bestLab := l
    predictedLabel := bestLab
    conf := totalW > 0 ? bestV / totalW : 0.0

// ═══════════════════════════════════════════════════════════════
//  REGIME WIN-RATE STATISTICS
// ═══════════════════════════════════════════════════════════════
var array<int>   regCount  = array.new<int>(5, 0)
var array<int>   regWin    = array.new<int>(5, 0)
var array<float> regSumRet = array.new<float>(5, 0.0)
var array<float> regSumAbs = array.new<float>(5, 0.0)

if barstate.islast and memCount > 0
    array.fill(regCount, 0)
    array.fill(regWin, 0)
    array.fill(regSumRet, 0.0)
    array.fill(regSumAbs, 0.0)
    for m = 0 to memCount - 1
        lab = array.get(memLabel, m)
        ret = array.get(memFwdRet, m)
        array.set(regCount,  lab, array.get(regCount,  lab) + 1)
        array.set(regSumRet, lab, array.get(regSumRet, lab) + ret)
        array.set(regSumAbs, lab, array.get(regSumAbs, lab) + math.abs(ret))
        isWin = (lab == 0 and ret > 0) or (lab == 1 and ret < 0) or (lab >= 2 and math.abs(ret) > 0.1)
        if isWin
            array.set(regWin, lab, array.get(regWin, lab) + 1)

regimeCol = f_labelCol(predictedLabel)

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
bgcolor(showBG and ready ? color.new(regimeCol, math.round(95 - conf * 20)) : na,
     title="Regime Background")

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast
    dash := table.new(f_pos(dashPos), 5, 24,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    table.cell(dash, 0, 0, "◆ KNN REGIME CLASSIFIER ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 4, 0)
    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period + " · k=" + str.tostring(kNeighbors) + " · " + distMetric + " · mem=" + str.tostring(memCount) + "/" + str.tostring(memorySize),
         text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 4, 1)

    table.cell(dash, 0, 2, "⚡ CURRENT REGIME",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 4, 2)

    statusTxt = ready ? "● LIVE" : "◐ LEARNING (" + str.tostring(math.max(0, minSamples - memCount)) + " more)"
    statusCol = ready ? cTrend : cRange
    table.cell(dash, 0, 3, "Status", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 3, statusTxt, text_color=color.white, bgcolor=color.new(statusCol, 40), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 3, 2, 3)
    table.cell(dash, 3, 3, "Confidence", text_color=cMute, bgcolor=cBg, text_size=size.small)
    confCol = conf > 0.7 ? cTrend : conf > 0.5 ? cRange : cBear
    table.cell(dash, 4, 3, str.tostring(conf * 100, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(confCol, 40), text_halign=text.align_center, text_size=size.small)

    bigRegime = ready ? f_labelName(predictedLabel) : "—"
    table.cell(dash, 0, 4, "REGIME", text_color=cMute, bgcolor=cBg, text_size=size.small)
    table.cell(dash, 1, 4, bigRegime,
         text_color=color.white, bgcolor=color.new(regimeCol, 15), text_halign=text.align_center, text_size=size.large)
    table.merge_cells(dash, 1, 4, 4, 4)

    // ─── VOTE DISTRIBUTION ───
    table.cell(dash, 0, 5, "🗳 NEIGHBOR VOTES (k=" + str.tostring(kNeighbors) + ")",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 5, 4, 5)

    totalVotes = 0.0
    for l = 0 to 4
        totalVotes += array.get(labelVotes, l)

    for l = 0 to 4
        v = array.get(labelVotes, l)
        pct = totalVotes > 0 ? v / totalVotes * 100 : 0
        barLen = math.round(pct / 5)
        barStr = ""
        for b = 0 to 19
            barStr := barStr + (b < barLen ? "█" : "░")
        table.cell(dash, 0, 6 + l, f_labelShort(l),
             text_color=color.white, bgcolor=color.new(f_labelCol(l), l == predictedLabel ? 20 : 60),
             text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 1, 6 + l, barStr,
             text_color=f_labelCol(l), bgcolor=cBg, text_halign=text.align_left, text_size=size.tiny)
        table.merge_cells(dash, 1, 6 + l, 3, 6 + l)
        table.cell(dash, 4, 6 + l, str.tostring(pct, "#.#") + "%",
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // ─── REGIME WIN-RATE TABLE ───
    if showWinTable
        table.cell(dash, 0, 11, "📊 HISTORICAL WIN-RATE PER REGIME",
             text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
        table.merge_cells(dash, 0, 11, 4, 11)
        table.cell(dash, 0, 12, "Regime",   text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 1, 12, "N",        text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 2, 12, "Win%",     text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 3, 12, "Avg Ret",  text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 4, 12, "Avg |Ret|", text_color=cMute, bgcolor=cBgAlt, text_size=size.tiny, text_halign=text.align_center)

        for l = 0 to 4
            n = array.get(regCount, l)
            w = array.get(regWin, l)
            wr = n > 0 ? w / n * 100 : 0.0
            avgR = n > 0 ? array.get(regSumRet, l) / n : 0.0
            avgA = n > 0 ? array.get(regSumAbs, l) / n : 0.0

            wrCol = wr > 60 ? cTrend : wr > 50 ? cRange : cBear
            retCol = avgR > 0 ? cTrend : avgR < 0 ? cBear : cMute

            isCurrent = l == predictedLabel
            rowBg = isCurrent ? color.new(f_labelCol(l), 70) : cBg

            table.cell(dash, 0, 13 + l, f_labelShort(l),
                 text_color=color.white, bgcolor=color.new(f_labelCol(l), isCurrent ? 10 : 40),
                 text_halign=text.align_center, text_size=size.tiny)
            table.cell(dash, 1, 13 + l, str.tostring(n),
                 text_color=cText, bgcolor=rowBg, text_halign=text.align_center, text_size=size.tiny)
            table.cell(dash, 2, 13 + l, n > 0 ? str.tostring(wr, "#.#") + "%" : "—",
                 text_color=color.white, bgcolor=n > 0 ? color.new(wrCol, 40) : rowBg,
                 text_halign=text.align_center, text_size=size.tiny)
            table.cell(dash, 3, 13 + l, n > 0 ? str.tostring(avgR, "+#.##;-#.##") + "%" : "—",
                 text_color=color.white, bgcolor=n > 0 ? color.new(retCol, 40) : rowBg,
                 text_halign=text.align_center, text_size=size.tiny)
            table.cell(dash, 4, 13 + l, n > 0 ? str.tostring(avgA, "#.##") + "%" : "—",
                 text_color=cText, bgcolor=rowBg, text_halign=text.align_center, text_size=size.tiny)

    // ─── FEATURE VECTOR ───
    table.cell(dash, 0, 18, "🎯 QUERY VECTOR",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 0, 18, 4, 18)
    featNames = array.from("ADX","DMI","BBW","RSI","Vol","Slp","Pos","ROC")
    featVals  = array.from(f1, f2, f3, f4, f5, f6, f7, f8)
    for i = 0 to 3
        table.cell(dash, 0, 19 + i, array.get(featNames, i), text_color=cMute, bgcolor=cBg, text_size=size.tiny, text_halign=text.align_right)
        v = array.get(featVals, i)
        vCol = v > 0.2 ? cTrend : v < -0.2 ? cBear : cMute
        table.cell(dash, 1, 19 + i, str.tostring(v, "+#.##;-#.##"),
             text_color=color.white, bgcolor=color.new(vCol, 40), text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 2, 19 + i, array.get(featNames, i + 4), text_color=cMute, bgcolor=cBg, text_size=size.tiny, text_halign=text.align_right)
        v2 = array.get(featVals, i + 4)
        vCol2 = v2 > 0.2 ? cTrend : v2 < -0.2 ? cBear : cMute
        table.cell(dash, 3, 19 + i, str.tostring(v2, "+#.##;-#.##"),
             text_color=color.white, bgcolor=color.new(vCol2, 40), text_halign=text.align_center, text_size=size.tiny)
        table.cell(dash, 4, 19 + i, "", bgcolor=cBg)

    table.cell(dash, 0, 23, "AetherEdge KNN · k-NN memory-based classifier",
         text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.merge_cells(dash, 0, 23, 4, 23)

// ═══════════════════════════════════════════════════════════════
//  KNN DISTANCE HEATMAP
// ═══════════════════════════════════════════════════════════════
var table heatmap = na
if barstate.islast and showHeatmap and ready and array.size(kDists) > 0
    nCells = math.min(heatmapCells, array.size(kDists))
    heatmap := table.new(f_pos(heatPos), nCells, 5,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    minD = array.get(kDists, 0)
    maxD = minD
    for i = 0 to array.size(kDists) - 1
        d = array.get(kDists, i)
        minD := math.min(minD, d)
        maxD := math.max(maxD, d)
    rangeD = math.max(maxD - minD, 1e-6)

    // Row 0: title
    for c = 0 to nCells - 1
        titleTxt = c == 0 ? "🔥 KNN HEATMAP · nearest → farthest" : ""
        table.cell(heatmap, c, 0, titleTxt,
             text_color=cAccent, bgcolor=cBgAlt, text_halign=text.align_left,
             text_size=c == 0 ? size.small : size.tiny)

    // Row 1: distance heat cells
    for c = 0 to nCells - 1
        d = array.get(kDists, c)
        t = (d - minD) / rangeD
        heatCol = color.from_gradient(t, 0, 1, cTrend, cRev)
        transp = math.round(10 + t * 60)
        table.cell(heatmap, c, 1, "",
             bgcolor=color.new(heatCol, transp),
             text_color=color.white, text_size=size.tiny)

    // Row 2: distance values
    for c = 0 to nCells - 1
        d = array.get(kDists, c)
        showVal = c % math.max(1, math.round(nCells / 8)) == 0 or c == 0 or c == nCells - 1
        table.cell(heatmap, c, 2, showVal ? str.tostring(d, "#.##") : "",
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.tiny)

    // Row 3: neighbor labels
    for c = 0 to nCells - 1
        lab = array.get(kLabels, c)
        table.cell(heatmap, c, 3, f_labelShort(lab),
             text_color=color.white, bgcolor=color.new(f_labelCol(lab), 30),
             text_halign=text.align_center, text_size=size.tiny)

    // Row 4: forward return sign
    for c = 0 to nCells - 1
        fr = array.get(kFwdRets, c)
        retSym = fr > 0.1 ? "▲" : fr < -0.1 ? "▼" : "◆"
        retCol = fr > 0.1 ? cTrend : fr < -0.1 ? cBear : cMute
        table.cell(heatmap, c, 4, retSym,
             text_color=color.white, bgcolor=color.new(retCol, 40),
             text_halign=text.align_center, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
regimeChanged = ready and predictedLabel != nz(predictedLabel[1], -1)

alertcondition(regimeChanged and predictedLabel == 0, "Regime: Trending Up",   "AE-KNN: Trending Up regime on {{ticker}}")
alertcondition(regimeChanged and predictedLabel == 1, "Regime: Trending Down", "AE-KNN: Trending Down regime on {{ticker}}")
alertcondition(regimeChanged and predictedLabel == 2, "Regime: Range",         "AE-KNN: Range regime on {{ticker}}")
alertcondition(regimeChanged and predictedLabel == 3, "Regime: Breakout",      "AE-KNN: Breakout regime on {{ticker}}")
alertcondition(regimeChanged and predictedLabel == 4, "Regime: Reversal",      "AE-KNN: Reversal regime on {{ticker}}")
alertcondition(conf > 0.85 and regimeChanged, "High-Confidence Regime Shift", "AE-KNN: High-confidence regime shift on {{ticker}}")
````
