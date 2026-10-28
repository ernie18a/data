# AetherEdge Quantum-Inspired Breakout Scanner

- url: https://www.tradingview.com/script/dLjt3zl2/
- type: indicator
- pine_id: PUB;f06af299a8054871a1c8591be6576ace
- version: 1.0

## Description

🖊️ Overview
AetherEdge Quantum-Inspired Breakout Scanner is a next-generation breakout prediction engine fusing KNN (k-Nearest Neighbors) pattern recognition with neural-net-style weighted scoring, built on quantum-inspired probabilistic thinking. It instantly searches similar historical patterns within a 6-dimensional feature vector space and computes probability waveforms across three states: Up, Down, and Sideways. The most likely scenario is "observed" (collapsed) from the superposition — a truly quantum-inspired advanced approach.

🔶 Key Features

Dual AI Engine: Hybrid prediction via KNN + Neural Net
6-Dimensional Feature Space: Returns / Volatility / RSI / Momentum / Volume / Trend
3-State Probability Model: Up / Down / Sideways via softmax probability output
KNN Historical Learning: Dynamic accumulation of up to 2,000 past patterns
Tunable Neural Net Weights: Customizable across 6 features × 6 weights
Trendline Projection: Probabilistic projection fans from pivot anchors
Break Confirmation Logic: ATR-based false-positive suppression
Probability Histogram & Fan: Visualizes future scenarios
Stats Panel: Active predictions and dominant scenario in real time

🧠 Technical Architecture

This indicator integrates two pillars of machine learning into a quantum-inspired probability model.

Feature Engineering (6D): ①ret5 (5-bar return/ATR) ②volat (ATR volatility Z-score) ③rsiNorm (RSI deviation) ④mom (10-bar momentum/ATR) ⑤volNorm (volume Z-score) ⑥trendStr (DMI delta). All clipped to [-3, +3] and normalized.
KNN Pattern Recognition: On barstate.isconfirmed, generates 3-state labels (Up/Side/Down) from forwardBars-ahead returns and stores them with 6 features in a ring buffer (up to knnLookback). Computes Euclidean distance to current vector, extracts top-K, votes for class probabilities.
Neural Net Scoring: Linear combination of 6 features × tunable weights (nnW1–nnW6) passed through softmax(temperature=nnTemp) to produce 3-class probabilities. Lower temperature sharpens conviction — a quantum-observation model.
Hybrid Mixing: hybridMix linearly interpolates KNN and NN probabilities (0=pure KNN, 1=pure NN, 0.5=balanced).
Sideways Classification: Range within sidewaysATR × ATR is labeled "Sideways," preventing noise-induced trend misclassification.
Trendline Projection: Anchors at pivotLR-detected pivots and projects projBars forward in the dominant direction. Drawn only when probability exceeds minProb.
Break Confirmation: Confirmed when price exceeds the line by breakATR × ATR, then highlighted.
Defensive Coding: Dynamic array-size alignment, explicit boundary checks, and local variables fully eliminate state leakage.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): knnK=15, forwardBars=10, hybridMix=0.5, minProb=0.45
ETH (1H): knnK=20, forwardBars=8, hybridMix=0.4, sidewaysATR=0.5
SOL/XRP (15M): knnK=10, forwardBars=6, hybridMix=0.6, minProb=0.50
Long-Term (1D): knnK=25, forwardBars=15, knnLookback=1000, sidewaysATR=0.8
Tuning Guide:

Pure KNN: hybridMix=0.0, knnK=20 to emphasize historical patterns
Pure NN: hybridMix=1.0, nnTemp=1.0 to emphasize weighted logic
Trending markets: sidewaysATR=0.4 to narrow Sideways and emphasize directionality
Ranging markets: sidewaysATR=1.0 to widen Sideways and suppress noise
High-conviction only: minProb=0.60, nnTemp=0.8 for sharp observation
Multi-scenario display: minProb=0.35, maxActive=5 for diversified prediction
Strict break filter: breakATR=0.3 to eliminate fakeouts

💡 How to Use in Practice

Up probability > 60% + confirmed break: Bullish entry, projection line as profit target
Down probability > 60% + downside break: Short on retest, bearish setup
Sideways dominant: Range trade or wait for breakout
Multi-Timeframe: Higher-TF Up probability + lower-TF break = high-confidence entry
Probability Fan Reading: Wide fan = uncertainty; narrow fan = high conviction
AetherEdge Synergy: Pair with Liquidity Void Detector for liquidity × probability synergy
Pivot Projection Use: Projection lines often act as dynamic S/R
Avoid: Stand aside when all three probabilities cluster around 33%

⚠️ Important Notes

Requires an initial accumulation period (at least forwardBars + 50 bars)
KNN accuracy improves progressively until knnLookback is filled
Neural net weights are not auto-trained; tuning per asset/timeframe is recommended
Long forwardBars reduces accuracy; too short increases noise
Optimal hybrid ratio varies with market regime
Probability model relies on past patterns; accuracy may drop in unprecedented regimes

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. KNN and neural-net-style probability models produce statistical forecasts based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Quantum-Inspired Breakout Scanner", shorttitle="AE-QBS", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ============================================================
// ▼ INPUTS
// ============================================================
grpQ = "🔮 Quantum Model"
useKNN     = input.bool(true,  "Enable KNN",          inline="m1", group=grpQ)
useNN      = input.bool(true,  "Enable Neural Net",   inline="m1", group=grpQ)
knnK       = input.int(15,     "KNN: K Neighbors",    minval=3, maxval=50, group=grpQ)
knnLookback= input.int(500,    "KNN: History Depth",  minval=50, maxval=2000, group=grpQ)
forwardBars= input.int(10,     "Forward Horizon",     minval=3, maxval=50, group=grpQ, tooltip="未来何本先を予測するか")
sidewaysATR= input.float(0.6,  "Sideways Threshold × ATR", minval=0.1, maxval=3.0, step=0.1, group=grpQ)
hybridMix  = input.float(0.5,  "Hybrid Mix (0=KNN, 1=NN)", minval=0.0, maxval=1.0, step=0.05, group=grpQ)

grpFeat = "📐 Feature Engineering"
useReturn  = input.bool(true,  "Feature: Returns",        group=grpFeat)
useVolat   = input.bool(true,  "Feature: Volatility",     group=grpFeat)
useRSI     = input.bool(true,  "Feature: RSI",            group=grpFeat)
useMom     = input.bool(true,  "Feature: Momentum",       group=grpFeat)
useVolFeat = input.bool(true,  "Feature: Volume Δ",       group=grpFeat)
useTrend   = input.bool(true,  "Feature: Trend Strength", group=grpFeat)

grpNN = "🧠 Neural Net Weights"
nnW1 = input.float(1.2, "w₁ Returns",   minval=-3, maxval=3, step=0.1, group=grpNN)
nnW2 = input.float(0.8, "w₂ Volatility",minval=-3, maxval=3, step=0.1, group=grpNN)
nnW3 = input.float(1.0, "w₃ RSI",       minval=-3, maxval=3, step=0.1, group=grpNN)
nnW4 = input.float(1.3, "w₄ Momentum",  minval=-3, maxval=3, step=0.1, group=grpNN)
nnW5 = input.float(0.6, "w₅ Volume",    minval=-3, maxval=3, step=0.1, group=grpNN)
nnW6 = input.float(1.1, "w₆ Trend",     minval=-3, maxval=3, step=0.1, group=grpNN)
nnTemp = input.float(1.5, "Softmax Temperature", minval=0.3, maxval=5.0, step=0.1, group=grpNN, tooltip="低いほど確信度が尖る")

grpLine = "📈 Trendline Projection"
pivotLR  = input.int(5, "Pivot Lookback/Forward", minval=2, maxval=20, group=grpLine)
projBars = input.int(30,"Projection Length",      minval=5, maxval=200, group=grpLine)
minProb  = input.float(0.45,"Min Probability to Draw", minval=0.34, maxval=0.95, step=0.01, group=grpLine)
breakATR = input.float(0.15,"Break Confirm × ATR", minval=0.0, maxval=1.0, step=0.05, group=grpLine)
maxActive= input.int(3, "Max Active Predictions",  minval=1, maxval=10, group=grpLine)

grpVis = "🎨 Visuals"
colUp     = input.color(color.rgb(80, 230, 180), "Up Color",      group=grpVis)
colDown   = input.color(color.rgb(255, 100, 130),"Down Color",    group=grpVis)
colSide   = input.color(color.rgb(180, 180, 200),"Sideways Color",group=grpVis)
colBroken = input.color(color.rgb(255, 220, 80), "Break Highlight",group=grpVis)
colHit    = input.color(color.rgb(120, 220, 255),"Target Hit",    group=grpVis)
showHistogram = input.bool(true, "Show Probability Histogram", group=grpVis)
showFan      = input.bool(true,  "Show Probability Fan",       group=grpVis)
showPanel    = input.bool(true,  "Show Stats Panel",           group=grpVis)
panelPos     = input.string("Top Right","Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)

// ============================================================
// ▼ FEATURE EXTRACTION
// ============================================================
atrV   = ta.atr(14)
volSma = ta.sma(volume, 20)

ret5    = (close - close[5]) / (atrV * 5 + 1e-10)
volat   = (atrV - ta.sma(atrV, 20)) / (ta.stdev(atrV, 20) + 1e-10)
rsiNorm = (ta.rsi(close, 14) - 50.0) / 50.0
mom     = ta.mom(close, 10) / (atrV * 5 + 1e-10)
volNorm = (volume - volSma) / (ta.stdev(volume, 20) + 1e-10)

plusDM   = high - high[1] > low[1] - low ? math.max(high - high[1], 0) : 0
minusDM  = low[1] - low > high - high[1] ? math.max(low[1] - low, 0) : 0
plusDI   = 100 * ta.rma(plusDM, 14) / (atrV + 1e-10)
minusDI  = 100 * ta.rma(minusDM, 14) / (atrV + 1e-10)
trendStr = (plusDI - minusDI) / 100.0

clip(float x) => math.max(-3.0, math.min(3.0, x))

f1 = useReturn  ? clip(ret5)         : 0.0
f2 = useVolat   ? clip(volat)        : 0.0
f3 = useRSI     ? clip(rsiNorm * 3)  : 0.0
f4 = useMom     ? clip(mom)          : 0.0
f5 = useVolFeat ? clip(volNorm)      : 0.0
f6 = useTrend   ? clip(trendStr * 3) : 0.0

// ============================================================
// ▼ HISTORICAL PATTERN STORAGE (for KNN)
// ============================================================
var array<float> hF1 = array.new<float>()
var array<float> hF2 = array.new<float>()
var array<float> hF3 = array.new<float>()
var array<float> hF4 = array.new<float>()
var array<float> hF5 = array.new<float>()
var array<float> hF6 = array.new<float>()
var array<int>   hOutcome = array.new<int>()  // 0=Down, 1=Side, 2=Up

if barstate.isconfirmed and bar_index > forwardBars + 50
    pastClose = close[forwardBars]
    pastATR   = atrV[forwardBars]
    diff      = close - pastClose
    int outcome = 1
    if diff > pastATR * sidewaysATR
        outcome := 2
    else if diff < -pastATR * sidewaysATR
        outcome := 0

    array.push(hF1, f1[forwardBars])
    array.push(hF2, f2[forwardBars])
    array.push(hF3, f3[forwardBars])
    array.push(hF4, f4[forwardBars])
    array.push(hF5, f5[forwardBars])
    array.push(hF6, f6[forwardBars])
    array.push(hOutcome, outcome)

    while array.size(hF1) > knnLookback
        array.shift(hF1)
        array.shift(hF2)
        array.shift(hF3)
        array.shift(hF4)
        array.shift(hF5)
        array.shift(hF6)
        array.shift(hOutcome)

// ============================================================
// ▼ KNN PROBABILITY ESTIMATION  (defensive rewrite)
// ============================================================
knnProbs() =>
    // 全配列のサイズを揃えて使用
    int n = math.min(math.min(math.min(array.size(hF1), array.size(hF2)),
                              math.min(array.size(hF3), array.size(hF4))),
                     math.min(math.min(array.size(hF5), array.size(hF6)),
                              array.size(hOutcome)))

    float pUp = 1.0 / 3.0
    float pDn = 1.0 / 3.0
    float pSd = 1.0 / 3.0

    if useKNN and n >= knnK and n >= 3
        // ローカル配列（毎回生成）— var を使わないので状態リークなし
        array<float> dists = array.new<float>(0)
        array<int>   idxs  = array.new<int>(0)

        for i = 0 to n - 1
            d1 = f1 - array.get(hF1, i)
            d2 = f2 - array.get(hF2, i)
            d3 = f3 - array.get(hF3, i)
            d4 = f4 - array.get(hF4, i)
            d5 = f5 - array.get(hF5, i)
            d6 = f6 - array.get(hF6, i)
            d  = math.sqrt(d1*d1 + d2*d2 + d3*d3 + d4*d4 + d5*d5 + d6*d6)
            array.push(dists, d)
            array.push(idxs, i)

        int sz     = array.size(dists)
        int kLimit = math.min(knnK, sz)

        // 部分選択ソート（K個だけ昇順に並べる）— 明示的な境界チェック付き
        if kLimit > 0
            for k = 0 to kLimit - 1
                int   minI = k
                float minD = array.get(dists, k)
                // 内側ループは境界を明示的に検査してから入る
                int jStart = k + 1
                int jEnd   = sz - 1
                if jStart <= jEnd
                    for j = jStart to jEnd
                        float dj = array.get(dists, j)
                        if dj < minD
                            minD := dj
                            minI := j
                if minI != k and minI < sz
                    float tD = array.get(dists, k)
                    int   tI = array.get(idxs,  k)
                    array.set(dists, k,    minD)
                    array.set(idxs,  k,    array.get(idxs, minI))
                    array.set(dists, minI, tD)
                    array.set(idxs,  minI, tI)

        float wU = 0.0
        float wD = 0.0
        float wS = 0.0
        if kLimit > 0
            for k = 0 to kLimit - 1
                if k < array.size(dists) and k < array.size(idxs)
                    float di = array.get(dists, k)
                    float w  = 1.0 / (1.0 + di * di)
                    int   ix = array.get(idxs, k)
                    if ix >= 0 and ix < array.size(hOutcome)
                        int outc = array.get(hOutcome, ix)
                        if outc == 2
                            wU += w
                        else if outc == 0
                            wD += w
                        else
                            wS += w

        sm = wU + wD + wS + 1e-10
        pUp := wU / sm
        pDn := wD / sm
        pSd := wS / sm
    [pUp, pDn, pSd]

// ============================================================
// ▼ NEURAL NET PROBABILITY ESTIMATION
// ============================================================
nnProbs() =>
    float scoreUp = 1.0 / 3.0
    float scoreDn = 1.0 / 3.0
    float scoreSd = 1.0 / 3.0

    if useNN
        rawSignal = nnW1*f1 + nnW2*f2*0.3 + nnW3*f3 + nnW4*f4 + nnW5*f5*0.5 + nnW6*f6
        absSig    = math.abs(f1)*nnW1 + math.abs(f4)*nnW4 + math.abs(f6)*nnW6

        float sU = rawSignal
        float sD = -rawSignal
        float sS = -absSig * 0.5 + nnW2 * f2 * 0.5

        T  = nnTemp
        eU = math.exp(sU / T)
        eD = math.exp(sD / T)
        eS = math.exp(sS / T)
        sm = eU + eD + eS + 1e-10
        scoreUp := eU / sm
        scoreDn := eD / sm
        scoreSd := eS / sm
    [scoreUp, scoreDn, scoreSd]

// ============================================================
// ▼ HYBRID FUSION
// ============================================================
[pkU, pkD, pkS] = knnProbs()
[pnU, pnD, pnS] = nnProbs()

float pUp   = (1.0 - hybridMix) * pkU + hybridMix * pnU
float pDown = (1.0 - hybridMix) * pkD + hybridMix * pnD
float pSide = (1.0 - hybridMix) * pkS + hybridMix * pnS

pSum = pUp + pDown + pSide + 1e-10
pUp   := pUp   / pSum
pDown := pDown / pSum
pSide := pSide / pSum

maxP    = math.max(pUp, math.max(pDown, pSide))
secondP = pUp == maxP ? math.max(pDown, pSide) : pDown == maxP ? math.max(pUp, pSide) : math.max(pUp, pDown)
quantumConfidence = maxP - secondP

int direction = pUp == maxP ? 0 : pDown == maxP ? 1 : 2

// ============================================================
// ▼ PIVOTS
// ============================================================
ph = ta.pivothigh(high, pivotLR, pivotLR)
pl = ta.pivotlow(low,  pivotLR, pivotLR)

var float lastPivotHigh    = na
var int   lastPivotHighBar = na
var float lastPivotHigh2   = na
var int   lastPivotHigh2Bar = na

var float lastPivotLow    = na
var int   lastPivotLowBar = na
var float lastPivotLow2   = na
var int   lastPivotLow2Bar = na

if not na(ph)
    lastPivotHigh2    := lastPivotHigh
    lastPivotHigh2Bar := lastPivotHighBar
    lastPivotHigh     := ph
    lastPivotHighBar  := bar_index - pivotLR

if not na(pl)
    lastPivotLow2    := lastPivotLow
    lastPivotLow2Bar := lastPivotLowBar
    lastPivotLow     := pl
    lastPivotLowBar  := bar_index - pivotLR

// ============================================================
// ▼ PREDICTION TYPE
// ============================================================
type Prediction
    line  ln
    line  upBand
    line  dnBand
    label lb
    int   dir
    float prob
    float qConf
    int   bornBar
    float startPrice
    float targetPrice
    int   targetBar
    bool  closed
    bool  hitTarget
    int   closedBar
    float slope
    color lnColor
    int   lnWidth

var array<Prediction> preds = array.new<Prediction>()

// ============================================================
// ▼ DRAW PREDICTION
// ============================================================
drawPrediction(int dir, float prob, float qC) =>
    float startPrice = close
    float endPrice   = close
    float slopeATR   = atrV * (0.5 + qC * 1.5)
    color baseCol    = dir == 0 ? colUp : dir == 1 ? colDown : colSide

    if dir == 0
        endPrice := close + slopeATR * (projBars / 10.0)
    else if dir == 1
        endPrice := close - slopeATR * (projBars / 10.0)
    else
        endPrice := close

    int lw = math.max(1, math.round(qC * 4 + 1))

    line mainLine = line.new(bar_index, startPrice, bar_index + projBars, endPrice, color=baseCol, width=lw, style=line.style_solid)

    float bandWidth = atrV * (1.0 - qC) * 3.0
    line upBand = na
    line dnBand = na
    if showFan
        upBand := line.new(bar_index, startPrice, bar_index + projBars, endPrice + bandWidth, color=color.new(baseCol, 75), width=1, style=line.style_dotted)
        dnBand := line.new(bar_index, startPrice, bar_index + projBars, endPrice - bandWidth, color=color.new(baseCol, 75), width=1, style=line.style_dotted)

    string dirSym  = dir == 0 ? "▲ UP" : dir == 1 ? "▼ DOWN" : "↔ SIDE"
    string lblText = dirSym + " " + str.tostring(math.round(prob * 100)) + "%\nQ-Conf: " + str.tostring(math.round(qC * 100)) + "%"
    label  lbl     = label.new(bar_index + projBars, endPrice, lblText, color=color.new(baseCol, 30), textcolor=color.white, style=label.style_label_left, size=size.small)

    Prediction pred = Prediction.new(mainLine, upBand, dnBand, lbl, dir, prob, qC, bar_index, startPrice, endPrice, bar_index + projBars, false, false, 0, slopeATR, baseCol, lw)
    array.push(preds, pred)

// ============================================================
// ▼ FIRE LOGIC
// ============================================================
canFireNew = quantumConfidence >= (minProb - 0.34) and maxP >= minProb

var int lastFireBar = -1000
cooldown = bar_index - lastFireBar > 5

bool shouldFire = false
if barstate.isconfirmed and canFireNew and cooldown
    if array.size(preds) == 0
        shouldFire := true
    else
        Prediction lastPred = array.get(preds, array.size(preds) - 1)
        if lastPred.closed
            shouldFire := true
        else if lastPred.dir != direction and quantumConfidence > lastPred.qConf + 0.15
            shouldFire := true
        else if lastPred.dir == direction and quantumConfidence > lastPred.qConf + 0.25
            shouldFire := true

if shouldFire
    drawPrediction(direction, maxP, quantumConfidence)
    lastFireBar := bar_index

    int activeCount = 0
    if array.size(preds) > 0
        for i = 0 to array.size(preds) - 1
            Prediction p = array.get(preds, i)
            if not p.closed
                activeCount += 1
        while activeCount > maxActive
            for i = 0 to array.size(preds) - 1
                Prediction p = array.get(preds, i)
                if not p.closed
                    p.closed    := true
                    p.closedBar := bar_index
                    color fadedCol = color.new(p.lnColor, 70)
                    line.set_style(p.ln, line.style_dashed)
                    line.set_color(p.ln, fadedCol)
                    p.lnColor := fadedCol
                    array.set(preds, i, p)
                    activeCount -= 1
                    break

// ============================================================
// ▼ MAINTAIN PREDICTIONS
// ============================================================
if barstate.isconfirmed and array.size(preds) > 0
    for i = 0 to array.size(preds) - 1
        Prediction p = array.get(preds, i)
        if not p.closed
            int   barsElapsed = bar_index - p.bornBar
            int   totalSpan   = math.max(p.targetBar - p.bornBar, 1)
            float lineY       = p.startPrice + (p.targetPrice - p.startPrice) * (barsElapsed / totalSpan)

            bool broken = false
            if p.dir == 0
                if close < lineY - atrV * breakATR
                    broken := true
            else if p.dir == 1
                if close > lineY + atrV * breakATR
                    broken := true
            else
                float bandW1 = atrV * (1.0 - p.qConf) * 3.0
                if close > p.startPrice + bandW1 or close < p.startPrice - bandW1
                    broken := true

            bool hit = false
            if not broken
                if p.dir == 0 and high >= p.targetPrice
                    hit := true
                else if p.dir == 1 and low <= p.targetPrice
                    hit := true
                else if p.dir == 2 and bar_index >= p.targetBar
                    float bandW2 = atrV * (1.0 - p.qConf) * 3.0
                    if math.abs(close - p.startPrice) < bandW2 * 0.5
                        hit := true

            bool expired = bar_index > p.targetBar + 5

            if broken
                p.closed    := true
                p.closedBar := bar_index
                int newW = math.max(1, p.lnWidth - 1)
                line.set_color(p.ln, colBroken)
                line.set_style(p.ln, line.style_dashed)
                line.set_width(p.ln, newW)
                p.lnColor := colBroken
                p.lnWidth := newW
                if not na(p.upBand)
                    line.set_color(p.upBand, color.new(colBroken, 90))
                    line.set_color(p.dnBand, color.new(colBroken, 90))
                label.set_color(p.lb, color.new(colBroken, 30))
                label.set_text(p.lb, label.get_text(p.lb) + "\n💥 BROKEN")

                label.new(bar_index, close, "💥", color=color.new(colBroken, 30), textcolor=color.black, style=label.style_label_center, size=size.small)
            else if hit
                p.closed    := true
                p.hitTarget := true
                p.closedBar := bar_index
                line.set_color(p.ln, colHit)
                line.set_style(p.ln, line.style_solid)
                p.lnColor := colHit
                if not na(p.upBand)
                    line.set_color(p.upBand, color.new(colHit, 80))
                    line.set_color(p.dnBand, color.new(colHit, 80))
                label.set_color(p.lb, color.new(colHit, 30))
                label.set_text(p.lb, label.get_text(p.lb) + "\n🎯 HIT")

                label.new(bar_index, close, "🎯", color=color.new(colHit, 30), textcolor=color.black, style=label.style_label_center, size=size.small)
            else if expired
                p.closed    := true
                p.closedBar := bar_index
                color fadedCol = color.new(p.lnColor, 70)
                line.set_color(p.ln, fadedCol)
                line.set_style(p.ln, line.style_dashed)
                p.lnColor := fadedCol

            array.set(preds, i, p)

    while array.size(preds) > 30
        Prediction old = array.shift(preds)
        line.delete(old.ln)
        if not na(old.upBand)
            line.delete(old.upBand)
            line.delete(old.dnBand)
        label.delete(old.lb)

// ============================================================
// ▼ HISTOGRAM
// ============================================================
var box hUp = na
var box hDn = na
var box hSd = na

if showHistogram and barstate.islast
    box.delete(hUp)
    box.delete(hDn)
    box.delete(hSd)

    int xStart = bar_index + 2
    int xEnd1  = bar_index + 2 + math.round(pUp   * 15)
    int xEnd2  = bar_index + 2 + math.round(pDown * 15)
    int xEnd3  = bar_index + 2 + math.round(pSide * 15)

    yBase = close
    yStep = atrV * 0.6

    hUp := box.new(xStart, yBase + yStep,        xEnd1, yBase + yStep * 0.5, bgcolor=color.new(colUp,   30), border_color=colUp)
    hSd := box.new(xStart, yBase + yStep * 0.4,  xEnd3, yBase - yStep * 0.4, bgcolor=color.new(colSide, 30), border_color=colSide)
    hDn := box.new(xStart, yBase - yStep * 0.5,  xEnd2, yBase - yStep,       bgcolor=color.new(colDown, 30), border_color=colDown)

// ============================================================
// ▼ STATS PANEL
// ============================================================
panelPosition() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

var table dash = table.new(panelPosition(), 2, 14, border_width=1)

if showPanel and barstate.islast
    int totalPreds = array.size(preds)
    int activeP = 0
    int hitP    = 0
    int brokenP = 0
    if totalPreds > 0
        for i = 0 to totalPreds - 1
            Prediction p = array.get(preds, i)
            if not p.closed
                activeP += 1
            else if p.hitTarget
                hitP += 1
            else
                brokenP += 1

    int   closedTotal = hitP + brokenP
    float winRate     = closedTotal > 0 ? hitP / float(closedTotal) * 100 : 0.0

    bg     = color.new(color.black, 75)
    accent = color.rgb(160, 200, 255)
    fg     = color.white

    table.cell(dash, 0, 0, "🔮 AE-QBS",      bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "Quantum Hybrid", bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "P(Up)",          bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(pUp * 100, "0.0") + "%",   bgcolor=bg, text_color=colUp,   text_size=size.normal)

    table.cell(dash, 0, 2, "P(Down)",        bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(pDown * 100, "0.0") + "%", bgcolor=bg, text_color=colDown, text_size=size.normal)

    table.cell(dash, 0, 3, "P(Sideways)",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(pSide * 100, "0.0") + "%", bgcolor=bg, text_color=colSide, text_size=size.normal)

    table.cell(dash, 0, 4, "Q-Confidence",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(quantumConfidence * 100, "0.0") + "%", bgcolor=bg, text_color=accent, text_size=size.normal)

    qState = quantumConfidence < 0.10 ? "🌫 Superposed" : quantumConfidence < 0.25 ? "💫 Decohering" : quantumConfidence < 0.50 ? "⚡ Collapsing" : "💎 Collapsed"
    table.cell(dash, 0, 5, "Wave State",     bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 5, qState,           bgcolor=bg, text_color=accent, text_size=size.small)

    dirStr = direction == 0 ? "▲ UP" : direction == 1 ? "▼ DOWN" : "↔ SIDE"
    dirCol = direction == 0 ? colUp : direction == 1 ? colDown   : colSide
    table.cell(dash, 0, 6, "Forecast",       bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 6, dirStr,           bgcolor=bg, text_color=dirCol, text_size=size.normal)

    table.cell(dash, 0, 7, "KNN Samples",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(array.size(hF1)) + "/" + str.tostring(knnLookback), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 8, "Active Preds",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(activeP) + "/" + str.tostring(maxActive), bgcolor=bg, text_color=accent, text_size=size.small)

    table.cell(dash, 0, 9, "Targets Hit",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(hitP),    bgcolor=bg, text_color=colHit,    text_size=size.small)

    table.cell(dash, 0,10, "Broken",         bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,10, str.tostring(brokenP), bgcolor=bg, text_color=colBroken, text_size=size.small)

    table.cell(dash, 0,11, "Hit Rate",       bgcolor=bg, text_color=fg, text_size=size.small)
    wRateCol = winRate >= 60 ? color.lime : winRate >= 40 ? color.yellow : color.orange
    table.cell(dash, 1,11, closedTotal > 0 ? str.tostring(winRate, "0.0") + "%" : "—", bgcolor=bg, text_color=wRateCol, text_size=size.small)

    table.cell(dash, 0,12, "Hybrid Mix",     bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,12, "KNN " + str.tostring(math.round((1-hybridMix)*100)) + "% / NN " + str.tostring(math.round(hybridMix*100)) + "%", bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0,13, "Horizon",        bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,13, str.tostring(forwardBars) + " bars",  bgcolor=bg, text_color=fg, text_size=size.small)

// ============================================================
// ▼ BAR COLOR
// ============================================================
barCol = direction == 0 ? color.new(colUp, 80) : direction == 1 ? color.new(colDown, 80) : color.new(colSide, 90)
barcolor(quantumConfidence > 0.4 ? barCol : na)

// ============================================================
// ▼ ALERTS
// ============================================================
upFire     = shouldFire and direction == 0
downFire   = shouldFire and direction == 1
sideFire   = shouldFire and direction == 2
hiConfFire = shouldFire and quantumConfidence > 0.5

alertcondition(upFire,     title="AE-QBS: New UP Prediction",      message="量子モデルがUP方向のブレイクアウトを高確率で検出しました。")
alertcondition(downFire,   title="AE-QBS: New DOWN Prediction",    message="量子モデルがDOWN方向のブレイクアウトを高確率で検出しました。")
alertcondition(sideFire,   title="AE-QBS: New SIDEWAYS Prediction",message="量子モデルがレンジ継続を高確率で予測しました。")
alertcondition(hiConfFire, title="AE-QBS: HIGH CONFIDENCE Fire",   message="量子確信度50%超の強シグナルが発生しました。")

plot(pUp,   "P(Up)",    color=color.new(colUp,    100), display=display.data_window)
plot(pDown, "P(Down)",  color=color.new(colDown,  100), display=display.data_window)
plot(pSide, "P(Side)",  color=color.new(colSide,  100), display=display.data_window)
plot(quantumConfidence, "Q-Confidence", color=color.new(color.yellow, 100), display=display.data_window)
````
