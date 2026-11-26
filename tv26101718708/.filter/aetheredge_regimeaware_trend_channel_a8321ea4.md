# AetherEdge Regime-Aware Trend Channel

- url: https://www.tradingview.com/script/a8321Ea4/
- type: indicator
- pine_id: PUB;adc12478150d4bff835560ab1b973787
- version: 1.0

## Description

🖊️ Overview
AetherEdge Regime-Aware Trend Channel is a next-generation dynamic channel system in which K-means clustering automatically classifies the market into three regimes — Range, Trend, and Volatile — and generates regime-specific channels in real time. Unlike conventional one-size-fits-all channels, it identifies the market's underlying character through unsupervised machine learning and reshapes itself accordingly. Upon breakout, it projects a confidence-decaying forward cone, visualizing "where price is likely heading next."

🔶 Key Features

Automatic K-means Regime Classification: 4 features × 3 clusters
Regime-Specific Channels: Optimal length & width per Range/Trend/Volatile
Dynamic Retraining: Centroids recompute every recalcBars to track shifts
Breakout Detection: ATR threshold + confirmation bars filter false breaks
Forward Projection: Confidence-decaying cone for projBars after breakout
Regime Color Visualization: Blue=Range / Green=Trend / Orange=Volatile
Stats Panel: Real-time regime, centroid, and feature display
Multi-Timeframe Friendly: Self-adapting design across all timeframes

🧠 Technical Architecture

This indicator is an adaptive channel AI built around unsupervised K-means learning.

4-Dimensional Feature Vector: ①EMA21–50 divergence (f1: trend strength) ②Normalized stdev (f2: volatility) ③High–low range / ATR (f3: range-ness) ④EMA21 slope (f4: directionality) — multidimensional market character.
Min-Max Normalization: All features scaled to 0–1 over trainBars window for fair distance computation.
K-means Clustering: regimeK centroids initialized evenly across trainBars → maxIter iterations of nearest-centroid assignment → centroid update until convergence.
Centroid Classification: trendScore = c1 + c4, volaScore = c2, rangeScore = 1 − c3 − c1; the maximum determines regime type per centroid.
Real-time Prediction: Computes Euclidean distance from current vector to all centroids; nearest centroid's regimeType is adopted.
Adaptive Channel Engine: Different lengths (chRangeLen / chTrendLen / chVolaLen) per regime extract highs/lows, scaled by WidthMul × ATR.
Breakout Detection: Triggered when deviation exceeds breakATRMul × ATR for breakConfirmBars consecutive bars.
Forward Projection: Cone-shaped confidence band drawn projBars ahead with projDecay exponential decay.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): trainBars=500, regimeK=3, recalcBars=50, featureWin=20
ETH (1H): trainBars=400, regimeK=3, recalcBars=40, chTrendLen=50
SOL/XRP (15M): trainBars=300, regimeK=3, recalcBars=30, featureWin=15
Long-Term (1D): trainBars=800, regimeK=4, recalcBars=80, chTrendLen=100
Tuning Guide:

Granular classification: regimeK=4–5 (requires more data)
Fast response: recalcBars=20 for frequent retraining (heavier load)
Stability priority: recalcBars=100, maxIter=20 for robust centroids
Trend-following: trendWidthMul=2.5 for wider breakout tolerance
Mean-reversion: rangeWidthMul=0.8 for tight Range channels
Volatile markets: volaWidthMul=3.0 to suppress false signals
Conservative breakouts: breakConfirmBars=3, breakATRMul=0.7

💡 How to Use in Practice

Range Strategy: In blue regimes, fade extremes — mean-reversion plays
Trend Strategy: In green regimes, buy dips / sell rallies — trend-following
Volatile Strategy: In orange regimes, reduce size and await clean breaks
Breakout Follow-through: Enter in cone direction; consider TP at cone tail
Regime Shift Signal: Color changes mark regime transitions = strategy switch points
Multi-Timeframe: Higher-TF regime + lower-TF channel edges for entry precision
AetherEdge Synergy: When Adaptive Fibonacci AI ratios align with channel edges → ultra-high-confidence zones

⚠️ Important Notes

Regime classification is inactive until trainBars of data accumulates
K-means is initialization-sensitive; classification may fluctuate at retraining moments
Too-short recalcBars destabilizes centroids and adds noise
Sudden regime shifts may incur a few bars of lag
Excessive regimeK fragments data per cluster, reducing classification accuracy
The projection cone is a probabilistic forecast, not a price guarantee

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. K-means classification and projection forecasts are based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Regime-Aware Trend Channel", shorttitle="AE-RATC", overlay=true, max_lines_count=300, max_labels_count=100, max_boxes_count=50, max_polylines_count=50, max_bars_back=2000)

// ============================================================
// ▼ INPUTS
// ============================================================
grpRegime = "🧬 Regime Classifier (K-means)"
regimeK     = input.int(3,    "K (clusters)",      minval=2, maxval=5, group=grpRegime, tooltip="3=Range/Trend/Volatile が標準")
trainBars   = input.int(500,  "Training Window",   minval=100,maxval=2000, group=grpRegime)
maxIter     = input.int(15,   "K-means Iterations",minval=5, maxval=50, group=grpRegime)
featureWin  = input.int(20,   "Feature Window",    minval=5, maxval=50, group=grpRegime)
recalcBars  = input.int(50,   "Recalc Every N Bars",minval=10,maxval=200, group=grpRegime)

grpChannel = "📐 Channel Engine"
chRangeLen    = input.int(30,    "Range Channel Length",   minval=10, maxval=100, group=grpChannel)
chTrendLen    = input.int(60,    "Trend Channel Length",   minval=20, maxval=200, group=grpChannel)
chVolaLen     = input.int(40,    "Volatile Channel Length",minval=15, maxval=150, group=grpChannel)
rangeWidthMul = input.float(1.0, "Range Width × ATR",     minval=0.5,maxval=3.0,step=0.1, group=grpChannel)
trendWidthMul = input.float(2.0, "Trend Width × ATR",     minval=1.0,maxval=5.0,step=0.1, group=grpChannel)
volaWidthMul  = input.float(2.5, "Volatile Width × ATR",  minval=1.0,maxval=6.0,step=0.1, group=grpChannel)

grpProj = "🔮 Forward Projection"
showProjection = input.bool(true, "Show Projection on Breakout", group=grpProj)
projBars       = input.int(20,    "Projection Bars Ahead", minval=5, maxval=80, group=grpProj)
projConfidence = input.float(1.5, "Projection Width × ATR", minval=0.5,maxval=4.0,step=0.1, group=grpProj)
projDecay      = input.float(0.92,"Projection Decay",       minval=0.7,maxval=1.0,step=0.01, group=grpProj, tooltip="先に行くほど信頼度減衰")

grpBreak = "💥 Breakout Detection"
breakATRMul      = input.float(0.5, "Breakout Threshold × ATR", minval=0.1,maxval=2.0,step=0.1, group=grpBreak)
breakConfirmBars = input.int(2,     "Confirmation Bars",        minval=1,  maxval=5, group=grpBreak)

grpVis = "🎨 Visuals"
colRange   = input.color(color.rgb(80, 200, 255), "Range Regime",    group=grpVis)
colTrend   = input.color(color.rgb(120,255,140),  "Trend Regime",    group=grpVis)
colVola    = input.color(color.rgb(255,150,80),   "Volatile Regime", group=grpVis)
colBreakUp = input.color(color.rgb(80, 255,160),  "Bullish Break",   group=grpVis)
colBreakDn = input.color(color.rgb(255,80, 120),  "Bearish Break",   group=grpVis)
fillAlpha  = input.int(88, "Fill Transparency", minval=70, maxval=98, group=grpVis)
showLabels = input.bool(true,"Show Channel Labels", group=grpVis)
showPanel  = input.bool(true,"Show Stats Panel",    group=grpVis)
panelPos   = input.string("Top Right","Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)

// ============================================================
// ▼ INDICATORS & FEATURES
// ============================================================
atrV    = ta.atr(14)
ema21   = ta.ema(close, 21)
ema50   = ta.ema(close, 50)
rsi14   = ta.rsi(close, 14)
stdev20 = ta.stdev(close, 20)
volMA   = ta.sma(volume, 20)

f1 = math.abs(ema21 - ema50) / math.max(atrV, 1e-10)
f2 = stdev20 / math.max(close, 1e-10) * 100
f3 = (ta.highest(high, featureWin) - ta.lowest(low, featureWin)) / math.max(atrV, 1e-10)
f4 = (ema21 - ema21[featureWin]) / math.max(atrV * featureWin, 1e-10)

normalize(float v, float minV, float maxV) =>
    rng = maxV - minV
    rng > 0 ? (v - minV) / rng : 0.5

f1Norm = normalize(f1, ta.lowest(f1, trainBars), ta.highest(f1, trainBars))
f2Norm = normalize(f2, ta.lowest(f2, trainBars), ta.highest(f2, trainBars))
f3Norm = normalize(f3, ta.lowest(f3, trainBars), ta.highest(f3, trainBars))
f4Norm = normalize(math.abs(f4), ta.lowest(math.abs(f4), trainBars), ta.highest(math.abs(f4), trainBars))

// ============================================================
// ▼ K-MEANS CLUSTERING
// ============================================================
type Centroid
    float c1
    float c2
    float c3
    float c4
    int   count
    int   regimeType

var array<Centroid> centroids = array.new<Centroid>()
var int lastTrainBar  = 0
var int currentRegime = 0

euclid(float a1, float a2, float a3, float a4, float b1, float b2, float b3, float b4) =>
    math.sqrt(math.pow(a1-b1,2) + math.pow(a2-b2,2) + math.pow(a3-b3,2) + math.pow(a4-b4,2))

classifyCentroid(Centroid c) =>
    trendScore = c.c1 + c.c4
    volaScore  = c.c2
    rangeScore = 1.0 - c.c3 - c.c1
    int result = 0
    if trendScore >= volaScore and trendScore >= rangeScore
        result := 1
    else if volaScore >= rangeScore
        result := 2
    else
        result := 0
    result

trainKMeans() =>
    bool ok = false
    if bar_index >= trainBars + featureWin
        array.clear(centroids)
        for i = 0 to regimeK - 1
            int offset = math.round(trainBars * i / math.max(regimeK - 1, 1))
            offset := math.min(offset, trainBars - 1)
            c = Centroid.new(nz(f1Norm[offset], 0.5), nz(f2Norm[offset], 0.5), nz(f3Norm[offset], 0.5), nz(f4Norm[offset], 0.5), 0, 0)
            array.push(centroids, c)

        for iter = 0 to maxIter - 1
            sumC1 = array.new<float>(regimeK, 0.0)
            sumC2 = array.new<float>(regimeK, 0.0)
            sumC3 = array.new<float>(regimeK, 0.0)
            sumC4 = array.new<float>(regimeK, 0.0)
            cnts  = array.new<int>(regimeK, 0)

            for b = 0 to trainBars - 1
                v1 = nz(f1Norm[b], 0.5)
                v2 = nz(f2Norm[b], 0.5)
                v3 = nz(f3Norm[b], 0.5)
                v4 = nz(f4Norm[b], 0.5)

                float minDist = 1e10
                int   minIdx  = 0
                for k = 0 to regimeK - 1
                    cc = array.get(centroids, k)
                    d  = euclid(v1, v2, v3, v4, cc.c1, cc.c2, cc.c3, cc.c4)
                    if d < minDist
                        minDist := d
                        minIdx  := k

                array.set(sumC1, minIdx, array.get(sumC1, minIdx) + v1)
                array.set(sumC2, minIdx, array.get(sumC2, minIdx) + v2)
                array.set(sumC3, minIdx, array.get(sumC3, minIdx) + v3)
                array.set(sumC4, minIdx, array.get(sumC4, minIdx) + v4)
                array.set(cnts,  minIdx, array.get(cnts,  minIdx) + 1)

            for k = 0 to regimeK - 1
                cnt = array.get(cnts, k)
                if cnt > 0
                    cc = array.get(centroids, k)
                    cc.c1    := array.get(sumC1, k) / cnt
                    cc.c2    := array.get(sumC2, k) / cnt
                    cc.c3    := array.get(sumC3, k) / cnt
                    cc.c4    := array.get(sumC4, k) / cnt
                    cc.count := cnt

        for k = 0 to regimeK - 1
            cc = array.get(centroids, k)
            cc.regimeType := classifyCentroid(cc)
        ok := true
    ok

predictRegime() =>
    int bestRegime = 0
    if array.size(centroids) > 0
        v1 = nz(f1Norm, 0.5)
        v2 = nz(f2Norm, 0.5)
        v3 = nz(f3Norm, 0.5)
        v4 = nz(f4Norm, 0.5)

        float minDist = 1e10
        for k = 0 to array.size(centroids) - 1
            cc = array.get(centroids, k)
            d  = euclid(v1, v2, v3, v4, cc.c1, cc.c2, cc.c3, cc.c4)
            if d < minDist
                minDist    := d
                bestRegime := cc.regimeType
    bestRegime

if barstate.isconfirmed and (bar_index - lastTrainBar >= recalcBars or array.size(centroids) == 0)
    if trainKMeans()
        lastTrainBar := bar_index

if barstate.isconfirmed and array.size(centroids) > 0
    currentRegime := predictRegime()

// ============================================================
// ▼ REGIME-SPECIFIC CHANNEL CONSTRUCTION
// ============================================================
rangeUpper = ta.highest(high, chRangeLen)
rangeLower = ta.lowest(low,  chRangeLen)
rangeMid   = (rangeUpper + rangeLower) / 2
rangeWidth = math.max((rangeUpper - rangeLower) / 2 * 0.85, atrV * rangeWidthMul)

trendMid   = ta.linreg(close, chTrendLen, 0)
trendSlope = ta.linreg(close, chTrendLen, 0) - ta.linreg(close, chTrendLen, 1)

float sumX_t  = 0.0
float sumY_t  = 0.0
float sumXY_t = 0.0
float sumX2_t = 0.0
for i = 0 to chTrendLen - 1
    float xv = i
    float yv = nz(close[i], close)
    sumX_t  += xv
    sumY_t  += yv
    sumXY_t += xv * yv
    sumX2_t += xv * xv
float n_t      = chTrendLen
float denom_t  = n_t * sumX2_t - sumX_t * sumX_t
float mSlope_t = denom_t != 0 ? (n_t * sumXY_t - sumX_t * sumY_t) / denom_t : 0.0
float mInter_t = (sumY_t - mSlope_t * sumX_t) / n_t

float sumDev_t = 0.0
for i = 0 to chTrendLen - 1
    float pred = mInter_t + mSlope_t * i
    sumDev_t += math.pow(nz(close[i], close) - pred, 2)
float trendDev   = math.sqrt(sumDev_t / chTrendLen)
float trendWidth = math.max(trendDev, atrV * trendWidthMul)

volaMid   = ta.ema(close, chVolaLen)
volaWidth = atrV * volaWidthMul

var float chUpper = na
var float chLower = na
var float chMid   = na
var float chSlope = 0.0
var int   chLen   = chRangeLen
var color chColor = colRange

if currentRegime == 0
    chUpper := rangeMid + rangeWidth
    chLower := rangeMid - rangeWidth
    chMid   := rangeMid
    chSlope := 0.0
    chLen   := chRangeLen
    chColor := colRange
else if currentRegime == 1
    chUpper := trendMid + trendWidth
    chLower := trendMid - trendWidth
    chMid   := trendMid
    chSlope := trendSlope
    chLen   := chTrendLen
    chColor := colTrend
else
    chUpper := volaMid + volaWidth
    chLower := volaMid - volaWidth
    chMid   := volaMid
    chSlope := 0.0
    chLen   := chVolaLen
    chColor := colVola

// ============================================================
// ▼ CHANNEL DRAWING
// ============================================================
var line  lnUpper = na
var line  lnLower = na
var line  lnMid   = na
var label lblTop  = na
var label lblBot  = na
var label lblMid  = na
var box   bgBox   = na

if barstate.islast and not na(chUpper) and not na(chLower)
    int   startBar   = bar_index - chLen
    float upperStart = chUpper - chSlope * chLen
    float lowerStart = chLower - chSlope * chLen
    float midStart   = chMid   - chSlope * chLen

    line.delete(lnUpper)
    line.delete(lnLower)
    line.delete(lnMid)
    box.delete(bgBox)
    label.delete(lblTop)
    label.delete(lblBot)
    label.delete(lblMid)

    lnUpper := line.new(startBar, upperStart, bar_index, chUpper, color=chColor, width=2, style=line.style_solid)
    lnLower := line.new(startBar, lowerStart, bar_index, chLower, color=chColor, width=2, style=line.style_solid)
    lnMid   := line.new(startBar, midStart,   bar_index, chMid,   color=color.new(chColor, 30), width=1, style=line.style_dotted)

    bgBox := box.new(startBar, chUpper, bar_index, chLower, border_color=color.new(chColor, 95), bgcolor=color.new(chColor, fillAlpha), border_width=0)

    if showLabels
        regimeName = currentRegime == 0 ? "RANGE" : currentRegime == 1 ? "TREND" : "VOLATILE"
        lblTop := label.new(bar_index, chUpper, "⤴ Upper · " + str.tostring(chUpper, format.mintick), color=color.new(chColor, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        lblBot := label.new(bar_index, chLower, "⤵ Lower · " + str.tostring(chLower, format.mintick), color=color.new(chColor, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        lblMid := label.new(bar_index - chLen, chMid, "[" + regimeName + "]", color=color.new(chColor, 40), textcolor=color.white, style=label.style_label_right, size=size.small)

// ============================================================
// ▼ BREAKOUT DETECTION
// ============================================================
breakUp = not na(chUpper) and close > chUpper + atrV * breakATRMul
breakDn = not na(chLower) and close < chLower - atrV * breakATRMul

var int upConfCount = 0
var int dnConfCount = 0

if breakUp
    upConfCount += 1
    dnConfCount := 0
else
    upConfCount := 0

if breakDn
    dnConfCount += 1
    upConfCount := 0
else
    dnConfCount := 0

confirmedBreakUp = upConfCount == breakConfirmBars
confirmedBreakDn = dnConfCount == breakConfirmBars

// ============================================================
// ▼ FORWARD PROJECTION BANDS
// (label is stored in a 1-element array so functions can mutate it)
// ============================================================
var array<line>  projUpperLines = array.new<line>()
var array<line>  projLowerLines = array.new<line>()
var array<line>  projMidLines   = array.new<line>()
var array<label> projLabelArr   = array.new<label>(1, na)

clearProjection() =>
    if array.size(projUpperLines) > 0
        for i = 0 to array.size(projUpperLines) - 1
            line.delete(array.get(projUpperLines, i))
            line.delete(array.get(projLowerLines, i))
            line.delete(array.get(projMidLines,   i))
        array.clear(projUpperLines)
        array.clear(projLowerLines)
        array.clear(projMidLines)
    label oldLbl = array.get(projLabelArr, 0)
    if not na(oldLbl)
        label.delete(oldLbl)
        array.set(projLabelArr, 0, na)

drawProjection(bool isUp) =>
    clearProjection()

    float anchor   = close
    float velocity = (close - close[5]) / 5.0
    if not isUp
        velocity := math.min(velocity, -atrV * 0.1)
    else
        velocity := math.max(velocity,  atrV * 0.1)

    color projCol   = isUp ? colBreakUp : colBreakDn
    int   segments  = 10
    int   barsPerSeg = math.max(math.floor(projBars / segments), 1)

    int   prevBar = bar_index
    float prevMid = anchor
    float prevUp  = anchor
    float prevDn  = anchor

    for s = 1 to segments
        int   elapsed    = s * barsPerSeg
        float decay      = math.pow(projDecay, s)
        float widthAtSeg = atrV * projConfidence * math.sqrt(elapsed) * (1.0 / math.max(decay, 0.3))

        float midAtSeg = anchor + velocity * elapsed
        float upAtSeg  = midAtSeg + widthAtSeg
        float dnAtSeg  = midAtSeg - widthAtSeg

        int curBar = bar_index + elapsed

        lMid = line.new(prevBar, prevMid, curBar, midAtSeg, color=color.new(projCol, 40), style=line.style_dashed, width=1)
        array.push(projMidLines, lMid)

        int alphaU = math.round(30 + s * 5)
        int aClamp = math.min(alphaU, 80)
        lUp = line.new(prevBar, prevUp, curBar, upAtSeg, color=color.new(projCol, aClamp), style=line.style_solid, width=1)
        array.push(projUpperLines, lUp)

        lDn = line.new(prevBar, prevDn, curBar, dnAtSeg, color=color.new(projCol, aClamp), style=line.style_solid, width=1)
        array.push(projLowerLines, lDn)

        prevBar := curBar
        prevMid := midAtSeg
        prevUp  := upAtSeg
        prevDn  := dnAtSeg

    int    endBar   = bar_index + projBars
    string arrowTxt = isUp ? "🚀 UP PROJECTION" : "🩸 DOWN PROJECTION"
    label newLbl = label.new(endBar, prevMid, arrowTxt, color=color.new(projCol, 20), textcolor=color.white, style=isUp ? label.style_label_lower_left : label.style_label_upper_left, size=size.small)
    array.set(projLabelArr, 0, newLbl)

if showProjection and barstate.isconfirmed
    if confirmedBreakUp
        drawProjection(true)
    else if confirmedBreakDn
        drawProjection(false)

// ============================================================
// ▼ BREAKOUT MARKERS
// ============================================================
plotshape(confirmedBreakUp, title="Break Up",   location=location.belowbar, color=colBreakUp, style=shape.triangleup,   size=size.normal, text="BRK")
plotshape(confirmedBreakDn, title="Break Down", location=location.abovebar, color=colBreakDn, style=shape.triangledown, size=size.normal, text="BRK")

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

var table dash = table.new(panelPosition(), 2, 11, border_width=1)

regimeName(int r) =>
    r == 0 ? "RANGE" : r == 1 ? "TREND" : "VOLATILE"

regimeColor(int r) =>
    r == 0 ? colRange : r == 1 ? colTrend : colVola

chPos = (not na(chUpper) and not na(chLower) and (chUpper - chLower) > 0) ? (close - chLower) / (chUpper - chLower) : 0.5

if showPanel and barstate.islast
    bg = color.new(color.black, 70)
    fg = color.white

    table.cell(dash, 0, 0, "🧬 RA-TC", bgcolor=color.new(regimeColor(currentRegime), 20), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "v1.0",     bgcolor=color.new(regimeColor(currentRegime), 20), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "Regime", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 1, regimeName(currentRegime), bgcolor=bg, text_color=regimeColor(currentRegime), text_size=size.normal)

    table.cell(dash, 0, 2, "Channel Length", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(chLen), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 3, "Upper", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 3, na(chUpper) ? "—" : str.tostring(chUpper, format.mintick), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 4, "Lower", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 4, na(chLower) ? "—" : str.tostring(chLower, format.mintick), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 5, "Position", bgcolor=bg, text_color=fg, text_size=size.small)
    posCol = chPos > 0.7 ? colBreakUp : chPos < 0.3 ? colBreakDn : fg
    table.cell(dash, 1, 5, str.tostring(chPos * 100, "0") + "%", bgcolor=bg, text_color=posCol, text_size=size.small)

    table.cell(dash, 0, 6, "Slope (ATR/bar)", bgcolor=bg, text_color=fg, text_size=size.small)
    slopeNorm = atrV > 0 ? chSlope / atrV : 0
    table.cell(dash, 1, 6, str.tostring(slopeNorm, "0.000"), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 7, "Trend Str (f1)", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(f1Norm, "0.00"), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 8, "Volatility (f2)", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(f2Norm, "0.00"), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 9, "Clusters", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(array.size(centroids)) + "/" + str.tostring(regimeK), bgcolor=bg, text_color=fg, text_size=size.small)

    brkStatus = confirmedBreakUp ? "▲ BREAK UP" : confirmedBreakDn ? "▼ BREAK DOWN" : chPos > 0.85 ? "⚠ NEAR UPPER" : chPos < 0.15 ? "⚠ NEAR LOWER" : "—"
    brkCol    = confirmedBreakUp or chPos > 0.85 ? colBreakUp : confirmedBreakDn or chPos < 0.15 ? colBreakDn : fg
    table.cell(dash, 0, 10, "Status", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 10, brkStatus, bgcolor=bg, text_color=brkCol, text_size=size.small)

// ============================================================
// ▼ BAR COLORING
// ============================================================
barColorTint = currentRegime == 0 ? colRange : currentRegime == 1 ? colTrend : colVola
barcolor(color.new(barColorTint, 80))

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(confirmedBreakUp, title="AE-RATC: Upside Breakout",   message="AE-RATC: Channel broken to UPSIDE. Projection cone deployed.")
alertcondition(confirmedBreakDn, title="AE-RATC: Downside Breakout", message="AE-RATC: Channel broken to DOWNSIDE. Projection cone deployed.")
alertcondition(ta.change(currentRegime) != 0, title="AE-RATC: Regime Shift", message="AE-RATC: Market regime has changed.")

// ============================================================
// ▼ DATA WINDOW PLOTS
// ============================================================
plot(chUpper, "Channel Upper", color=color.new(chColor, 70), display=display.data_window)
plot(chLower, "Channel Lower", color=color.new(chColor, 70), display=display.data_window)
plot(chMid,   "Channel Mid",   color=color.new(chColor, 70), display=display.data_window)
plot(currentRegime, "Regime ID", color=color.gray, display=display.data_window)
````
