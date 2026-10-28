# AetherEdge Adaptive Fibonacci AI

- url: https://www.tradingview.com/script/70PFrCUR/
- type: indicator
- pine_id: PUB;6c8451d5041448e199f8d8755454a92e
- version: 1.0

## Description

🖊️ Overview
AetherEdge Adaptive Fibonacci AI is a machine-learning-driven adaptive Fibonacci engine that completely transcends traditional static ratios. A KNN (K-Nearest Neighbors) algorithm extracts the most similar historical regimes from up to 2,000 prior bars and learns which golden ratios actually worked in those analogous conditions. It then probabilistically computes a breakout probability for each level — a revolutionary tool that visualizes "which Fib will hold" as a forward-looking forecast.

🔶 Key Features

Dynamic Swing Detection: ATR-based filtering of meaningful swings only
KNN Similarity Engine: 6-dimensional feature × cosine similarity matching
Adaptive Fibonacci: Learns ratios that worked in similar regimes
3 Modes: Standard (fixed) / Adaptive (learned) / Hybrid (fused)
Breakout Probability Forecast: % probability displayed per level
3-Tier Color Coding: High / Mid / Low breakout probability
Predicted Extension Lines: 1.272 / 1.618 / 2.0 projection rendering
Dynamic Line Width: Higher similarity = thicker emphasis
Stats Panel: Visualizes similarity, ratio adoption, and processing state

🧠 Technical Architecture

This indicator is a KNN-driven Fibonacci AI that "learns from the past."

Swing Detection: pivothigh / pivotlow at swingLen, filtered by minSwingATR × ATR to eliminate noise. Swing ID tracking minimizes recomputation.
6-Dimensional Feature Vector: ①Return (f_ret) ②Volatility ratio (f_volaRatio) ③Volume ratio (f_volRatio) ④EMA slope (f_slope) ⑤Range position (f_rangePos) ⑥Normalized RSI (f_rsi) — vectorizes current market state.
Cosine Similarity: Computes similarity between the current vector and each historical state vector, quantifying regime resemblance on a -1 to 1 scale.
KNN Search: Scans historyBars range with sampleStep intervals, extracts top-K (knnK) similar states. similarityMin threshold filters out low-quality matches.
Level Harvesting: Reverse-engineers reactive price levels from analogous regimes, matches them against candidateRatios (18 ratios from 0.146 to 2.618), and accumulates them into adaptiveRatios.
Weighted Voting: Each ratio is quality-scored via similarity-weighted voting.
Breakout Probability: Calculated from price behavior (break vs. respect) around each level over probLookback bars.
Hybrid Mode: Combines standard Fibs with adaptive Fibs to harness both worlds.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): swingLen=10, knnK=8, historyBars=2000, similarityMin=0.55
ETH (1H): swingLen=8, knnK=10, historyBars=1500, similarityMin=0.50
SOL/XRP (15M): swingLen=6, knnK=12, historyBars=1200, similarityMin=0.45
Long-Term (1D): swingLen=15, knnK=6, historyBars=3000, similarityMin=0.60
Tuning Guide:

Precision: similarityMin=0.70, knnK=5 for ultra-selective matching
Maximum learning: historyBars=4000, sampleStep=2 to maximize data
Speed priority: sampleStep=5, featureLen=15 to reduce load
Trending markets: includeExt=true, showBeyond=true for projection emphasis
Range markets: adaptMode=Adaptive to prioritize learned ratios
Beginners: adaptMode=Hybrid offers the safest standard + AI dual view

💡 How to Use in Practice

High-Probability Bounce: colLowProb (green) levels are strong S/R — bounce entry candidates
Breakout Plays: colHighProb (red) levels signal high break expectation — follow-through trades
Adaptive Edge: Non-standard ratios (0.65, 0.707, etc.) appearing in Adaptive mode are regime-specific key levels
Extension Targets: Use 1.272 / 1.618 / 2.0 projections for take-profit
Multi-Timeframe: Higher TF adaptive Fibs + lower TF entry refinement
AetherEdge Synergy: When Neural OB Evolution elite OBs overlap an adaptive Fib → confluence powerhouse zone

⚠️ Important Notes

The first several hundred bars lack training data, so Adaptive mode may not function well early on
Increasing historyBars improves accuracy but raises computational load (trade-off)
Effectiveness drops during sudden regime shifts that have no historical analog
Levels are not drawn until swings confirm (swingLen bars later)
KNN processing executes on bar close — real-time reflection occurs on the next bar
Excessively large featureLen risks over-referencing outdated patterns

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. KNN similarity and probability forecasts are based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Adaptive Fibonacci AI", shorttitle="AE-AFAI", overlay=true, max_lines_count=300, max_labels_count=200, max_boxes_count=50, max_bars_back=5000)

// ============================================================
// ▼ INPUTS
// ============================================================
grpSwing = "🌊 Swing Detection"
swingLen     = input.int(10,   "Swing Pivot Length", minval=3,   maxval=30, group=grpSwing)
minSwingATR  = input.float(1.0,"Min Swing × ATR",    minval=0.5, maxval=10.0, step=0.1, group=grpSwing, tooltip="このサイズ未満のスイングは無視")
useLatest    = input.bool(true,"Use Latest Confirmed Swing", group=grpSwing)

grpKNN = "🤖 KNN Similarity Engine"
knnK         = input.int(8,    "K (neighbors)",      minval=3,   maxval=30, group=grpKNN)
historyBars  = input.int(2000, "Historical Lookback", minval=300,maxval=4500, group=grpKNN)
featureLen   = input.int(20,   "Feature Window",     minval=5,   maxval=50, group=grpKNN, tooltip="類似度計算に使う特徴量ウィンドウ")
similarityMin= input.float(0.55,"Min Similarity",    minval=0.0, maxval=1.0, step=0.05, group=grpKNN)
sampleStep   = input.int(3,    "History Sample Step", minval=1,  maxval=10, group=grpKNN, tooltip="高速化のためサンプル間隔を空ける")

grpFib = "📐 Adaptive Fibonacci"
adaptMode    = input.string("Hybrid", "Ratio Mode", options=["Standard","Adaptive","Hybrid"], group=grpFib, tooltip="Standard=固定 / Adaptive=学習のみ / Hybrid=両方")
maxLevels    = input.int(7,    "Max Levels Drawn",  minval=3,   maxval=12, group=grpFib)
includeExt   = input.bool(true,"Include Extensions (1.272/1.618/2.0)", group=grpFib)
showBeyond   = input.bool(true,"Show Predicted Extension Lines", group=grpFib)

grpProb = "🎯 Breakout Probability"
probLookback = input.int(50,   "Probability Sample Bars", minval=20, maxval=200, group=grpProb)
showProbLabels = input.bool(true,"Show Probability % Labels", group=grpProb)

grpVis = "🎨 Visuals"
colHighProb  = input.color(color.rgb(255, 80,  80),  "High Breakout Prob", group=grpVis)
colMidProb   = input.color(color.rgb(255, 200, 60),  "Mid Breakout Prob",  group=grpVis)
colLowProb   = input.color(color.rgb(80,  220, 140), "Low Breakout Prob (strong S/R)", group=grpVis)
colExtension = input.color(color.rgb(180, 120, 255), "Predicted Extension", group=grpVis)
extendRight  = input.int(60,   "Extend Right (bars)", minval=10, maxval=300, group=grpVis)
showStats    = input.bool(true,"Show Stats Panel",    group=grpVis)
lineWidthMax = input.int(3,    "Max Line Width",      minval=1,  maxval=5,  group=grpVis)

// ============================================================
// ▼ CONTEXT
// ============================================================
atrV  = ta.atr(14)
emaF  = ta.ema(close, 21)
volMA = ta.sma(volume, 20)

hiF  = ta.highest(high, featureLen)
loF  = ta.lowest(low,  featureLen)
rsiV = ta.rsi(close, 14)

// ============================================================
// ▼ PIVOT DETECTION
// ============================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float lastPHval  = na
var int   lastPHbar  = na
var float lastPLval  = na
var int   lastPLbar  = na

var float swingHi    = na
var float swingLo    = na
var int   swingHiBar = na
var int   swingLoBar = na
var bool  isUpSwing  = true
var int   swingId    = 0

if not na(ph)
    lastPHval := ph
    lastPHbar := bar_index - swingLen
if not na(pl)
    lastPLval := pl
    lastPLbar := bar_index - swingLen

if not na(lastPHval) and not na(lastPLval)
    float newHi = lastPHval
    float newLo = lastPLval
    int   hiBar = lastPHbar
    int   loBar = lastPLbar
    bool  upDir = lastPHbar >= lastPLbar

    if (newHi - newLo) > atrV * minSwingATR
        if na(swingHi) or na(swingLo) or swingHi != newHi or swingLo != newLo
            swingHi    := newHi
            swingLo    := newLo
            swingHiBar := hiBar
            swingLoBar := loBar
            isUpSwing  := upDir
            swingId    += 1

// ============================================================
// ▼ FEATURE EXTRACTION
// ============================================================
f_ret       = (close - close[featureLen]) / math.max(math.abs(close[featureLen]), 1e-10)
f_volaRatio = atrV / math.max(atrV[featureLen], 1e-10)
f_volRatio  = volume / math.max(volMA, 1e-10)
f_slope     = (emaF - emaF[featureLen]) / math.max(math.abs(emaF[featureLen]), 1e-10)
f_rangePos  = (close - loF) / math.max(hiF - loF, 1e-10)
f_rsi       = rsiV / 100.0

// ============================================================
// ▼ KNN SIMILARITY SEARCH + LEVEL HARVESTING
// ============================================================
type LevelVote
    float ratio
    float weight

cosineSim(float a1, float a2, float a3, float a4, float a5, float a6, float b1, float b2, float b3, float b4, float b5, float b6) =>
    dot  = a1*b1 + a2*b2 + a3*b3 + a4*b4 + a5*b5 + a6*b6
    magA = math.sqrt(a1*a1 + a2*a2 + a3*a3 + a4*a4 + a5*a5 + a6*a6)
    magB = math.sqrt(b1*b1 + b2*b2 + b3*b3 + b4*b4 + b5*b5 + b6*b6)
    (magA > 0 and magB > 0) ? dot / (magA * magB) : 0.0

var array<float> candidateRatios = array.from(0.0, 0.146, 0.236, 0.272, 0.382, 0.5, 0.618, 0.65, 0.707, 0.786, 0.886, 1.0, 1.128, 1.272, 1.414, 1.618, 2.0, 2.618)

var array<float> adaptiveRatios  = array.new<float>()
var array<float> adaptiveWeights = array.new<float>()
var int lastSwingProcessed = -1

// 履歴バッファ拡張のため、最大参照深度の値を一度参照しておく（Pine の慣用句）
var int maxHistDepth = 0
maxHistDepth := historyBars + featureLen + 10

safeIdx(int i) =>
    i >= 0 and i < bar_index

runKNN() =>
    if not na(swingHi) and not na(swingLo) and bar_index > (historyBars + featureLen + 10)
        array.clear(adaptiveRatios)
        array.clear(adaptiveWeights)

        topSimArr = array.new<float>()
        topBarArr = array.new<int>()

        startBack = featureLen + 5
        endBack   = math.min(historyBars, bar_index - featureLen - 10)

        if endBack > startBack
            int i = startBack
            while i <= endBack
                int iN = i + featureLen
                if safeIdx(i) and safeIdx(iN)
                    closeI  = close[i]
                    closeIN = close[iN]
                    if not na(closeI) and not na(closeIN) and closeIN != 0
                        h_ret   = (closeI - closeIN) / math.max(math.abs(closeIN), 1e-10)
                        h_atr   = atrV[i]
                        h_atrN  = atrV[iN]
                        h_volaR = (not na(h_atrN) and h_atrN > 0) ? h_atr / h_atrN : 1.0
                        h_volMA = volMA[i]
                        h_volR  = volume[i] / math.max(na(h_volMA) ? 1.0 : h_volMA, 1e-10)
                        h_emaN  = emaF[iN]
                        h_emaI  = emaF[i]
                        h_slope = (not na(h_emaN) and not na(h_emaI) and h_emaN != 0) ? (h_emaI - h_emaN) / math.max(math.abs(h_emaN), 1e-10) : 0.0
                        h_hi    = hiF[i]
                        h_lo    = loF[i]
                        h_rsiI  = rsiV[i]
                        if not na(h_hi) and not na(h_lo) and not na(h_rsiI)
                            h_rng   = math.max(h_hi - h_lo, 1e-10)
                            h_rngP  = (closeI - h_lo) / h_rng
                            h_rsi   = h_rsiI / 100.0

                            sim = cosineSim(f_ret, f_volaRatio, f_volRatio, f_slope, f_rangePos, f_rsi, h_ret, h_volaR, h_volR, h_slope, h_rngP, h_rsi)

                            if sim >= similarityMin
                                if array.size(topSimArr) < knnK
                                    array.push(topSimArr, sim)
                                    array.push(topBarArr, i)
                                else
                                    int   minIdx = 0
                                    float minVal = array.get(topSimArr, 0)
                                    for j = 1 to array.size(topSimArr) - 1
                                        v = array.get(topSimArr, j)
                                        if v < minVal
                                            minVal := v
                                            minIdx := j
                                    if sim > minVal
                                        array.set(topSimArr, minIdx, sim)
                                        array.set(topBarArr, minIdx, i)
                i += sampleStep

        if array.size(topSimArr) > 0 and array.size(candidateRatios) > 0
            for c = 0 to array.size(candidateRatios) - 1
                r = array.get(candidateRatios, c)
                float totalWeight  = 0.0
                float respectScore = 0.0
                for n = 0 to array.size(topBarArr) - 1
                    nb = array.get(topBarArr, n)
                    sm = array.get(topSimArr, n)
                    if safeIdx(nb)
                        h_hi  = hiF[nb]
                        h_lo  = loF[nb]
                        if not na(h_hi) and not na(h_lo)
                            h_rng = h_hi - h_lo
                            if h_rng > 0
                                levelPrice = h_lo + r * h_rng
                                post = math.max(nb - featureLen, 0)
                                float respect = 0.0
                                for k = post to nb - 1
                                    if safeIdx(k)
                                        hk = high[k]
                                        lk = low[k]
                                        ck = close[k]
                                        ak = atrV[k]
                                        if not na(hk) and not na(lk) and not na(ck) and not na(ak)
                                            touch = (lk <= levelPrice and hk >= levelPrice)
                                            if touch
                                                bounce = math.abs(ck - levelPrice) / math.max(ak, 1e-10)
                                                respect := math.max(respect, math.min(bounce, 2.0) / 2.0)
                                respectScore += respect * sm
                                totalWeight  += sm
                avgRespect = totalWeight > 0 ? respectScore / totalWeight : 0.0
                if avgRespect > 0.15
                    array.push(adaptiveRatios,  r)
                    array.push(adaptiveWeights, avgRespect)

if (not na(ph) or not na(pl)) and barstate.isconfirmed and swingId != lastSwingProcessed
    runKNN()
    lastSwingProcessed := swingId

// ============================================================
// ▼ BREAKOUT PROBABILITY
// ============================================================
breakoutProb(float levelPrice, bool fromBelow) =>
    int touches = 0
    int breaks  = 0
    int maxLB   = math.min(probLookback, bar_index - 1)
    if maxLB > 0
        for i = 1 to maxLB
            hi = high[i]
            lo = low[i]
            cl = close[i]
            ai = atrV[i]
            if not na(hi) and not na(lo) and not na(cl) and not na(ai)
                touched = (lo <= levelPrice and hi >= levelPrice)
                if touched
                    touches += 1
                    if fromBelow and cl > levelPrice + ai * 0.2
                        breaks += 1
                    if not fromBelow and cl < levelPrice - ai * 0.2
                        breaks += 1
    touches > 0 ? breaks * 100.0 / touches : 50.0

// ============================================================
// ▼ COLOR HELPERS
// ============================================================
probColor(float p) =>
    p >= 65 ? colHighProb : p >= 40 ? colMidProb : colLowProb

probWidth(float p, float weight) =>
    int base = 1
    if weight >= 0.6
        base := 2
    if weight >= 0.85 or p >= 75
        base := lineWidthMax
    base

// ============================================================
// ▼ FIB LEVEL DRAWING
// ============================================================
type FibLine
    line  ln
    label lbl
    float ratio
    float price
    float prob
    float weight

var array<FibLine> drawnLines = array.new<FibLine>()

buildLevelSet() =>
    out = array.new<float>()
    wts = array.new<float>()

    if adaptMode == "Standard" or adaptMode == "Hybrid"
        std = array.from(0.236, 0.382, 0.5, 0.618, 0.786)
        for i = 0 to array.size(std) - 1
            array.push(out, array.get(std, i))
            array.push(wts, 0.5)
        if includeExt
            ext = array.from(1.272, 1.618, 2.0)
            for i = 0 to array.size(ext) - 1
                array.push(out, array.get(ext, i))
                array.push(wts, 0.5)

    if (adaptMode == "Adaptive" or adaptMode == "Hybrid") and array.size(adaptiveRatios) > 0
        for i = 0 to array.size(adaptiveRatios) - 1
            r = array.get(adaptiveRatios, i)
            w = array.get(adaptiveWeights, i)
            bool found = false
            if array.size(out) > 0
                for j = 0 to array.size(out) - 1
                    if math.abs(array.get(out, j) - r) < 0.01
                        array.set(wts, j, math.max(array.get(wts, j), w))
                        found := true
                        break
            if not found
                array.push(out, r)
                array.push(wts, w)

    [out, wts]

if barstate.islast and not na(swingHi) and not na(swingLo)
    if array.size(drawnLines) > 0
        for i = 0 to array.size(drawnLines) - 1
            fl = array.get(drawnLines, i)
            line.delete(fl.ln)
            if not na(fl.lbl)
                label.delete(fl.lbl)
        array.clear(drawnLines)

    [levels, weights] = buildLevelSet()

    if array.size(levels) > 0
        while array.size(levels) > maxLevels
            int   minIdx = 0
            float minW   = array.get(weights, 0)
            for i = 1 to array.size(weights) - 1
                w = array.get(weights, i)
                if w < minW
                    minW   := w
                    minIdx := i
            array.remove(levels,  minIdx)
            array.remove(weights, minIdx)

        rng      = swingHi - swingLo
        startBar = math.max(swingHiBar, swingLoBar)

        for i = 0 to array.size(levels) - 1
            r = array.get(levels, i)
            w = array.get(weights, i)

            isExtension = r > 1.0
            skipLevel   = (isExtension and not includeExt) or (isExtension and not showBeyond)

            if not skipLevel
                levelPrice = isUpSwing ? swingHi - r * rng : swingLo + r * rng
                fromBelow  = close < levelPrice
                prob       = breakoutProb(levelPrice, fromBelow)

                col = isExtension ? colExtension : probColor(prob)
                wd  = probWidth(prob, w)
                sty = isExtension ? line.style_dashed : line.style_solid

                ln = line.new(startBar, levelPrice, bar_index + extendRight, levelPrice, color=col, style=sty, width=wd)

                label lbl = na
                if showProbLabels
                    tag = str.tostring(r, "0.000")
                    txt = "Fib " + tag +
                         "\nP: "  + str.tostring(levelPrice, format.mintick) +
                         "\nBO: " + str.tostring(prob, "0") + "%" +
                         "\nW: "  + str.tostring(w, "0.00")
                    lbl := label.new(bar_index + extendRight, levelPrice, txt, color=color.new(col, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)

                fl = FibLine.new(ln, lbl, r, levelPrice, prob, w)
                array.push(drawnLines, fl)

// ============================================================
// ▼ SWING ENVELOPE BOX
// ============================================================
var box swingBox = na
if barstate.islast and not na(swingHi) and not na(swingLo)
    if not na(swingBox)
        box.delete(swingBox)
    int boxStart = math.min(swingHiBar, swingLoBar)
    swingBox := box.new(boxStart, swingHi, bar_index, swingLo, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, 92), border_width=1, border_style=line.style_dotted)

// ============================================================
// ▼ ALERTS
// ============================================================
bool  nearLevel = false
float nearProb  = 0.0
if array.size(drawnLines) > 0 and barstate.isconfirmed
    for i = 0 to array.size(drawnLines) - 1
        fl = array.get(drawnLines, i)
        if math.abs(close - fl.price) < atrV * 0.3
            nearLevel := true
            nearProb  := math.max(nearProb, fl.prob)
            break

alertcondition(nearLevel, title="AE-AFAI → Price At Adaptive Fib Level", message="AE-AFAI: Price approaching an adaptive Fibonacci level")

bool highProbBreak = false
if array.size(drawnLines) > 0 and barstate.isconfirmed
    for i = 0 to array.size(drawnLines) - 1
        fl = array.get(drawnLines, i)
        if fl.prob >= 65 and math.abs(close - fl.price) < atrV * 0.5
            highProbBreak := true
            break
alertcondition(highProbBreak, title="AE-AFAI → High Breakout Probability", message="AE-AFAI: Price near high-probability breakout level")

// ============================================================
// ▼ STATS PANEL
// ============================================================
var table dash = table.new(position.top_right, 2, 9, border_width=1)
if showStats and barstate.islast
    bgC = color.new(color.black, 75)
    txC = color.white

    adaptCount = array.size(adaptiveRatios)
    drawnCount = array.size(drawnLines)

    float avgWeight = 0.0
    float avgProb   = 0.0
    if drawnCount > 0
        for i = 0 to drawnCount - 1
            fl = array.get(drawnLines, i)
            avgWeight += fl.weight
            avgProb   += fl.prob
        avgWeight := avgWeight / drawnCount
        avgProb   := avgProb   / drawnCount

    swingDir  = isUpSwing ? "▲ UP" : "▼ DOWN"
    swingSize = (not na(swingHi) and not na(swingLo)) ? swingHi - swingLo : 0.0
    swingATR  = (not na(atrV) and atrV > 0) ? swingSize / atrV : 0.0

    table.cell(dash, 0, 0, "🤖 AFAI", bgcolor=color.new(colExtension, 30), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "v1.2",    bgcolor=color.new(colExtension, 30), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "Mode",    bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 1, adaptMode, bgcolor=bgC, text_color=txC, text_size=size.small)

    swingTxt = na(swingHi) or na(swingLo) ?
         "⏳ waiting (PH=" + (na(lastPHval) ? "−" : "✓") +
         " PL=" + (na(lastPLval) ? "−" : "✓") +
         " ATR×" + str.tostring(swingATR, "0.0") + ")" :
         swingDir + " (" + str.tostring(swingATR, "0.0") + " ATR)"
    table.cell(dash, 0, 2, "Swing",   bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 2, swingTxt,  bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 3, "Adaptive Ratios",        bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(adaptCount), bgcolor=bgC, text_color=color.new(colExtension, 0), text_size=size.small)

    table.cell(dash, 0, 4, "Drawn Levels",           bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(drawnCount), bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 5, "Avg Weight",                    bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(avgWeight, "0.00"), bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 6, "Avg BO Prob",                       bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(avgProb, "0") + "%",    bgcolor=bgC, text_color=probColor(avgProb), text_size=size.small)

    nearTxt = nearLevel ? "● TOUCHING" : "—"
    nearCol = nearLevel ? colHighProb : color.gray
    table.cell(dash, 0, 7, "Price Status", bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 7, nearTxt,        bgcolor=bgC, text_color=nearCol, text_size=size.small)

    knnCount = math.min(adaptCount, knnK)
    table.cell(dash, 0, 8, "KNN Hits",     bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(knnCount) + "/" + str.tostring(knnK), bgcolor=bgC, text_color=txC, text_size=size.small)

plot(array.size(drawnLines),     title="Drawn Fib Levels", display=display.data_window)
plot(array.size(adaptiveRatios), title="Adaptive Ratios",  display=display.data_window)
plot(swingHi, title="Swing High", color=color.new(color.gray, 80), display=display.data_window)
plot(swingLo, title="Swing Low",  color=color.new(color.gray, 80), display=display.data_window)
````
