# Enhanced Buy/Sell Profile Logic 

- url: https://www.tradingview.com/script/afS1M6OM-Enhanced-Buy-Sell-Profile-Logic/
- type: indicator
- pine_id: PUB;50b38531c4e24f7795dcc63fb264cf69
- version: 4.0

## Description

Enhanced Buy/Sell Profile is an intraday market-structure tool that combines estimated buy/sell pressure with a rolling volume-style profile. It highlights key reference levels such as POC, value area, and VWMP, tracks imbalance and cluster zones, and summarizes market condition in a table so you can judge whether the auction is balanced, transitioning, or directional.

This indicator does three main jobs at once:

It estimates buy vs sell participation from candles and volume.
It builds a live price-level profile with POC, VAH, VAL, VWMP, and imbalance/cluster logic.
It summarizes the current state in the table using Pressure, Structure, Flow, and Bias.

The most important levels in the script are:

POC = highest traded/allocated volume row
VAH / VAL = value area boundaries
VWMP = volume-weighted midpoint of the profile
optional VWMP sigma bands = dispersion around VWMP

Practical use:

Above POC and VWMP usually strengthens bullish structure
Below POC and VWMP usually strengthens bearish structure
Between them or repeatedly crossing them usually means weaker control / rotation

The highlighted transition candle It appears when estimated net pressure is no longer Balanced, but has not yet reached Bull, Strong Bull, Bear, or Strong Bear. It is based on netPctHist and the thresholds set by neutralBandPct, bullPressurePct, and strongPressurePct.

Why it matters:

It signals change, not confirmation.
It is more useful than constant bull/bear coloring because it is rarer and highlights when conditions are shifting.
Its meaning depends on location: near POC/VWMP, VAH/VAL, clusters, or after a strong move, it can hint at reclaim, rejection, exhaustion, or expansion.
It is not automatically bullish or bearish.

How to use it:

Treat it as an attention candle, not an entry by itself.
Then check:
Table = interpretation
POC / VAH / VAL / VWMP = map
Clusters / imbalances = reaction zones
Price action = confirmation

Bottom line:
A TRANSITION candle means pressure is changing, but direction is not confirmed yet. It tells you to watch structure, flow, and location more closely.

Where it gets weaker:

1. It is weaker in chop.
Because lookbackBars feeds both the historical pressure engine and the live profile window, a shorter lookback makes the state change faster. That is good in expansion, but in sideways trade it can flip between Balanced → Transition → Bull/Bear too easily. So the weakness is not trend days — it is rotational conditions.

2. It is weaker as a “big picture” read.
With 30 bars, POC, VWMP, VAH, and VAL are derived from a more local auction rather than a broader one. That makes them more useful for tactical execution, but weaker as major session structure references. In other words, the map updates faster, but it is less durable.

3. It is weaker against fake momentum bursts.
The script estimates buy/sell pressure from candle structure using f_buyShare(...) rather than true bid/ask trade classification. That means a sharp candle burst can look more directional than the underlying tape really is. Your faster thresholds make that more responsive, but also more vulnerable to short-lived pushes.

4. It is weaker when volume is average but price is noisy.
The reclaim/reject and absorption logic relies on cluster location, price behavior, and optional volume confirmation using volume >= volAvg20 * volumeConfirmMult. If price is whipping around key levels without meaningful expansion in volume, the faster preset can make the script “see” state change sooner than the market has actually committed.

5. It is weaker when clusters are thin or shifting.
Cluster detection depends on row-level estimated buy/sell imbalance crossing clusterThresholdPct and clusterMinRows. With a shorter lookback, the profile range is more local and row boundaries shift faster, so clusters can be more fragile. That means the top active cluster can become less stable than in a broader window. [b]Best to use longer lookback 78 and above [/b]

6. It is weaker if you treat Transition as confirmation instead of warning.
In this script, Transition is just the zone between Balanced and Bull/Bear. With your settings, that zone is narrower than before, so it is useful, but it is still an “attention” state, not a completed signal. The faster preset makes Transition appear sooner, which is helpful, but also easier to overread.

So the honest answer is:

Stronger at: early detection, tactical intraday use, faster changes, execution timing
Weaker at: chop resistance, structural stability, broader session context, filtering false bursts

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © getakabu

//@version=6
indicator("Enhanced Buy/Sell Profile Logic", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
grpCore = "Core"
modeProfile      = input.string("Lookback", "Profile Mode", options=["Lookback", "Session"], group=grpCore)
lookbackBars     = input.int(30, "Lookback bars", minval=2, maxval=5000, group=grpCore)
rows             = input.int(20, "Price bins (rows)", minval=8, maxval=400, group=grpCore)
splitNeutral     = input.bool(true, "Split neutral bars 50/50", group=grpCore)
sessionInput     = input.session("0930-1600", "Session (Exchange Time)", group=grpCore)

grpPerf = "Performance"
fastMode    = input.bool(true, "Fast Mode", group=grpPerf)
fastMaxBars = input.int(500, "Fast Mode Max Bars", minval=50, maxval=5000, group=grpPerf)

grpModel = "Estimation Model"
estMode = input.string("Body + Close", "Buy/Sell Estimation",
     options=["Close Position", "Body + Close", "Bar Direction"], group=grpModel)
bodyWeight  = input.float(0.35, "Body Weight", minval=0.0, maxval=1.0, step=0.05, group=grpModel)
closeWeight = input.float(0.45, "Close Position Weight", minval=0.0, maxval=1.0, step=0.05, group=grpModel)
dirWeight   = input.float(0.20, "Directional Weight", minval=0.0, maxval=1.0, step=0.05, group=grpModel)

grpDist = "Row Distribution Model"
rowDistMode         = input.string("Segment + Close Bias", "Row Volume Distribution",
     options = ["Equal Spread", "Segment Weighted", "Segment + Close Bias"], group = grpDist)
bodyRowWeight       = input.float(2.0, "Body Row Weight", minval = 0.1, step = 0.1, group = grpDist)
wickRowWeight       = input.float(0.7, "Wick Row Weight", minval = 0.0, step = 0.1, group = grpDist)
closeBiasStrength   = input.float(0.6, "Close Bias Strength", minval = 0.0, maxval = 3.0, step = 0.1, group = grpDist)
minRowScoreFallback = input.float(0.000001, "Min Row Score Fallback", minval = 0.0000001, step = 0.0000001, group = grpDist)

grpLTF = "Lower-Timeframe Reconstruction"
useLTFReconstruction     = input.bool(false, "Use LTF Buy/Sell Reconstruction", group=grpLTF)
ltfTf                    = input.timeframe("1", "LTF Source", group=grpLTF)
useTrueLTFCurrentBarRows = input.bool(true, "Use True LTF Row Placement For Current Bar", group=grpLTF)
ltfFallbackToHTF         = input.bool(true, "Fallback To HTF Model If LTF Missing", group=grpLTF)

grpVisual = "Profile Visual"
showRightProfile = input.bool(true, "Show right-side profile", group=grpVisual)
profileWidthBars = input.int(18, "Profile width (bars)", minval=4, maxval=80, group=grpVisual)
profileOpacity   = input.int(78, "Profile opacity (0 solid → 100 invisible)", minval=0, maxval=100, group=grpVisual)
xOffsetBars      = input.int(10, "Profile x-offset", minval=0, maxval=30, group=grpVisual)
showProfileBoxes = input.bool(true, "Show buy/sell profile boxes", group=grpVisual)

grpLevels = "Profile Levels"
showPOC = input.bool(true, "Show POC", group=grpLevels)
showVA  = input.bool(true, "Show VAH / VAL", group=grpLevels)
vaPct   = input.float(70.0, "Value Area %", minval=50, maxval=99, step=1.0, group=grpLevels)
showVWMP = input.bool(true, "Show VWMP", group=grpLevels)
vwmpColor = input.color(color.new(color.orange, 0), "VWMP Color", group=grpLevels)
vwmpWidth = input.int(2, "VWMP Width", minval=1, maxval=5, group=grpLevels)
showVWMPSigma = input.bool(false, "Show VWMP ± Sigma", group=grpLevels)
vwmpSigmaMult = input.float(1.0, "VWMP Sigma Mult", minval=0.25, maxval=3.0, step=0.25, group=grpLevels)
vwmpSigmaColor = input.color(color.new(color.aqua, 45), "VWMP Sigma Color", group=grpLevels)
vwmpSigmaWidth = input.int(1, "VWMP Sigma Width", minval=1, maxval=3, group=grpLevels)

grpImb = "Imbalance Levels"
showTopLevels   = input.bool(true, "Show top imbalance levels", group=grpImb)
topNLevels      = input.int(4, "Top N buy & sell levels", minval=1, maxval=20, group=grpImb)
levelLineWidth  = input.int(2, "Level line width", minval=1, maxval=5, group=grpImb)
minImbalancePct = input.float(15.0, "Min imbalance %", minval=1.0, maxval=100.0, step=0.5, group=grpImb)

grpImbFilter = "Imbalance Quality Filter"
minRowVolPctOfPOC = input.float(2.0, "Min Row Volume % of POC", minval=0.0, maxval=100.0, step=0.25, group=grpImbFilter)
useVolumeWeightedImbalanceRank = input.bool(true, "Rank Levels By Imbalance × Row Volume", group=grpImbFilter)
showDominantOnlyLevels = input.bool(false, "Show Only Strongest Buy/Sell Level", group=grpImbFilter)

grpCluster = "Stacked Imbalance"
showClusters           = input.bool(true, "Show stacked imbalance clusters", group=grpCluster)
clusterMinRows         = input.int(2, "Min adjacent rows", minval=1, maxval=20, group=grpCluster)
clusterThresholdPct    = input.float(20.0, "Cluster threshold %", minval=1.0, maxval=100.0, step=0.5, group=grpCluster)
showOnlyTopActiveLabel = input.bool(false, "Only top active cluster labels", group=grpCluster)

grpSig = "Reclaim / Reject Signals"
showSignals          = input.bool(true, "Show reclaim/reject signals", group=grpSig)
signalCooldownBars   = input.int(12, "Signal cooldown bars", minval=1, group=grpSig)
clusterBufferRows    = input.float(1.0, "Cluster buffer (rows)", minval=0.0, maxval=10.0, step=0.5, group=grpSig)
signalLookbackBars   = input.int(10, "Signal lookback bars", minval=2, maxval=100, group=grpSig)
useVolumeConfirm     = input.bool(true, "Use volume confirmation", group=grpSig)
volumeConfirmMult    = input.float(1.0, "Volume confirm × AvgVol", minval=0.1, step=0.1, group=grpSig)
requireCandleFlip    = input.bool(true, "Require reversal candle", group=grpSig)
confirmSignalsOnClose = input.bool(true, "Confirm Signals On Bar Close", group=grpSig)

grpAbs = "Absorption"
showAbsorption = input.bool(true, "Show absorption markers", group=grpAbs)

grpPanel = "Stats Panel"
showStats = input.bool(true, "Show stats panel", group=grpPanel)
biasThreshPct = input.float(1.0, "Flow Net Δ Threshold %", minval=0.0, maxval=50.0, step=0.5, group=grpPanel)
showStructureFlow = input.bool(true, "Show Structure / Flow", group=grpPanel)
showLowNetDeltaSignal = input.bool(true, "Show Low Net Δ Signal Candle", group=grpPanel)
lowNetDeltaThreshPct  = input.float(1.0, "Low Net Δ Threshold % (strict band)", minval=0.0, maxval=10.0, step=0.1, group=grpPanel)
lowNetBullColor       = input.color(color.new(color.yellow, 0), "Low Net Δ Bull Candle Color", group=grpPanel)
lowNetBearColor       = input.color(color.new(color.fuchsia, 0), "Low Net Δ Bear Candle Color", group=grpPanel)
dashboardTextSizeOpt  = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal"], group=grpPanel)
dashboardCompact      = input.bool(false, "Compact Dashboard Labels", group=grpPanel)

grpDecision = "Decision Quality / Transparency"
showConfidenceScore = input.bool(true, "Show Confidence Score", group=grpDecision)
showPOCContext      = input.bool(true, "Show POC/VWMP Context", group=grpDecision)
showModelNote       = input.bool(true, "Show OHLCV Proxy Note", group=grpDecision)
showPerformanceWarning = input.bool(true, "Show Performance Warning", group=grpDecision)
perfWarnRows        = input.int(120, "Warn If Rows Above", minval=20, maxval=400, group=grpDecision)
perfWarnBars        = input.int(1000, "Warn If Lookback Above", minval=100, maxval=5000, group=grpDecision)

grpPressure = "Directional Pressure"
showPressureInPanel      = input.bool(true, "Show Pressure in Stats Panel", group=grpPressure)
showPressureColoring     = input.bool(true, "Show Pressure Candle Coloring", group=grpPressure)
neutralBandPct           = input.float(1.0, "Neutral Band % (±)", minval=0.1, maxval=10.0, step=0.1, group=grpPressure)
bullPressurePct          = input.float(2.4, "Bull/Bear Pressure Threshold %", minval=0.1, maxval=20.0, step=0.1, group=grpPressure)
strongPressurePct        = input.float(4.0, "Strong Pressure Threshold %", minval=0.1, maxval=30.0, step=0.1, group=grpPressure)
neutralColor             = input.color(color.new(color.gray, 0), "Balanced Candle Color", group=grpPressure)
transitionColor          = input.color(color.new(color.silver, 0), "Transition Candle Color", group=grpPressure)
bullPressureColor        = input.color(color.new(color.lime, 0), "Bull Pressure Candle Color", group=grpPressure)
strongBullPressureColor  = input.color(color.new(color.green, 0), "Strong Bull Pressure Candle Color", group=grpPressure)
bearPressureColor        = input.color(color.new(color.orange, 0), "Bear Pressure Candle Color", group=grpPressure)
strongBearPressureColor  = input.color(color.new(color.red, 0), "Strong Bear Pressure Candle Color", group=grpPressure)

grpPressureRules = "Directional Pressure Rules"
enablePressureEngine        = input.bool(true, "Enable Directional Pressure Engine", group=grpPressureRules)
useBalancedRule             = input.bool(true, "Use Balanced Rule", group=grpPressureRules)
useTransitionRule           = input.bool(true, "Use Transition Rule", group=grpPressureRules)
useBullPressureRule         = input.bool(true, "Use Bull Pressure Rule", group=grpPressureRules)
useStrongBullPressureRule   = input.bool(true, "Use Strong Bull Pressure Rule", group=grpPressureRules)
useBearPressureRule         = input.bool(true, "Use Bear Pressure Rule", group=grpPressureRules)
useStrongBearPressureRule   = input.bool(true, "Use Strong Bear Pressure Rule", group=grpPressureRules)

grpMismatch = "Pressure Mismatch Signals"
showMismatchSignals      = input.bool(true, "Show Pressure Mismatch Signals", group=grpMismatch)
useMismatchStructure     = input.bool(true, "Require Structure Confirmation (Live Profile Only)", group=grpMismatch)
useMismatchPrevClose     = input.bool(true, "Use Previous Close Confirmation", group=grpMismatch)
showBearPressureFailure  = input.bool(true, "Show Bear Pressure Failure", group=grpMismatch)
showBullPressureFailure  = input.bool(true, "Show Bull Pressure Failure", group=grpMismatch)
keepMismatchHistory      = input.bool(true, "Keep Mismatch Signal History", group=grpMismatch)
maxMismatchLabels        = input.int(50, "Max Stored Mismatch Labels", minval=1, maxval=500, group=grpMismatch)

grpFlipBox = "Net Δ Sign Flip Boxes"
showFlipBoxes          = input.bool(false, "Show Net Δ Sign Flip Boxes", group=grpFlipBox)
flipBoxMode            = input.string("Until Next Flip", "Box Extension", options=["Candle Only", "Fixed Bars", "Until Next Flip"], group=grpFlipBox)
flipBoxExtendBars      = input.int(20, "Fixed Extension Bars", minval=1, maxval=500, group=grpFlipBox)
bullFlipBoxColor       = input.color(color.new(color.lime, 82), "Bull Flip Box Color", group=grpFlipBox)
bearFlipBoxColor       = input.color(color.new(color.red, 82), "Bear Flip Box Color", group=grpFlipBox)
bullFlipBoxBorderColor = input.color(color.lime, "Bull Flip Border Color", group=grpFlipBox)
bearFlipBoxBorderColor = input.color(color.red, "Bear Flip Border Color", group=grpFlipBox)
flipBoxBorderWidth     = input.int(1, "Box Border Width", minval=1, maxval=4, group=grpFlipBox)
showFlipBoxMidline     = input.bool(false, "Show Flip Box Center Line", group=grpFlipBox)
bullFlipMidlineColor   = input.color(color.lime, "Bull Midline Color", group=grpFlipBox)
bearFlipMidlineColor   = input.color(color.red, "Bear Midline Color", group=grpFlipBox)
flipMidlineWidth       = input.int(1, "Midline Width", minval=1, maxval=4, group=grpFlipBox)
flipMidlineStyle       = input.string("Solid", "Midline Style", options=["Solid", "Dashed", "Dotted"], group=grpFlipBox)

grpStyle = "Style"
buyColor  = input.color(color.lime, "Buy Color", group=grpStyle)
sellColor = input.color(color.red, "Sell Color", group=grpStyle)
pocColor  = input.color(color.white, "POC Color", group=grpStyle)
vaColor   = input.color(color.orange, "VAH/VAL Color", group=grpStyle)

//────────────────────────────────────────────
// HELPERS
//────────────────────────────────────────────
f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_clear_lines(line[] arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

f_clear_labels(label[] arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

f_clear_boxes(box[] arr) =>
    while array.size(arr) > 0
        box.delete(array.pop(arr))

f_buyShare(float o, float h, float l, float c, string mode, bool splitNeutralBars, float bw, float cw, float dw) =>
    float rng = math.max(h - l, syminfo.mintick)
    float mid = (h + l) * 0.5
    float out = 0.5

    if mode == "Bar Direction"
        if c > o
            out := 1.0
        else if c < o
            out := 0.0
        else
            out := splitNeutralBars ? 0.5 : ((c - l) / rng)
    else if mode == "Close Position"
        out := (c - l) / rng
        if math.abs(c - o) <= syminfo.mintick and splitNeutralBars
            out := 0.5
    else
        float closePos = (c - l) / rng
        float bodyBias = f_clamp((c - o) / rng, -1.0, 1.0)
        float dirBias  = c > mid ? 1.0 : c < mid ? 0.0 : 0.5
        float wsum = math.max(bw + cw + dw, 0.0001)
        out := (cw * closePos + bw * (0.5 + 0.5 * bodyBias) + dw * dirBias) / wsum
        if math.abs(c - o) <= syminfo.mintick and splitNeutralBars
            out := 0.5

    f_clamp(out, 0.0, 1.0)

f_best_index(float[] scores) =>
    int bestPos = na
    float best = -1.0
    int n = array.size(scores)
    if n > 0
        for i = 0 to n - 1
            float sc = array.get(scores, i)
            if sc > best
                best := sc
                bestPos := i
    bestPos

f_lineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_overlap(float a1, float a2, float b1, float b2) =>
    math.max(0.0, math.min(a2, b2) - math.max(a1, b1))

f_rowAllocScore(
    float rowLo, float rowHi,
    float barLo, float barHi,
    float barOpen, float barClose,
    string distMode,
    float bodyW, float wickW, float closeBiasStr
) =>
    float bodyLo = math.min(barOpen, barClose)
    float bodyHi = math.max(barOpen, barClose)

    float lowerWickLo = barLo
    float lowerWickHi = bodyLo

    float upperWickLo = bodyHi
    float upperWickHi = barHi

    float bodyOverlap  = f_overlap(rowLo, rowHi, bodyLo, bodyHi)
    float lowerOverlap = f_overlap(rowLo, rowHi, lowerWickLo, lowerWickHi)
    float upperOverlap = f_overlap(rowLo, rowHi, upperWickLo, upperWickHi)

    float score =
         distMode == "Equal Spread" ? 1.0 :
         distMode == "Segment Weighted" ?
             (bodyOverlap * bodyW + (lowerOverlap + upperOverlap) * wickW) :
             (bodyOverlap * bodyW + (lowerOverlap + upperOverlap) * wickW)

    if distMode == "Segment + Close Bias"
        float rowMid = (rowLo + rowHi) * 0.5
        float rng = math.max(barHi - barLo, syminfo.mintick)
        float closeProx = f_clamp(1.0 - math.abs(rowMid - barClose) / rng, 0.0, 1.0)
        score *= (1.0 + closeBiasStr * closeProx)

    score

f_buyImbalanceText(float pct) =>
    pct >= 60 ? "Strong Buy " + str.tostring(pct, "#.1") + "%" :
 pct >= 35 ? "Buy Edge " + str.tostring(pct, "#.1") + "%" :
             "Buy Lean " + str.tostring(pct, "#.1") + "%"

f_sellImbalanceText(float pct) =>
    pct >= 60 ? "Strong Sell " + str.tostring(pct, "#.1") + "%" :
 pct >= 35 ? "Sell Edge " + str.tostring(pct, "#.1") + "%" :
             "Sell Lean " + str.tostring(pct, "#.1") + "%"

f_accumulateBarToRows(
    float bo, float bh, float bl, float bc, float bv,
    float lo, float rowH, int rows,
    string estMode, bool splitNeutral, float bodyWeight, float closeWeight, float dirWeight,
    string rowDistMode, float bodyRowWeight, float wickRowWeight, float closeBiasStrength, float minRowScoreFallback,
    array<float> rowBuy, array<float> rowSell, array<float> rowTot
) =>
    float bs = f_buyShare(bo, bh, bl, bc, estMode, splitNeutral, bodyWeight, closeWeight, dirWeight)

    float buyV = bv * bs
    float sellV = bv * (1.0 - bs)

    int startRow = int(math.floor((bl - lo) / rowH))
    int endRow   = int(math.floor((bh - lo) / rowH))
    startRow := int(f_clamp(startRow, 0, rows - 1))
    endRow   := int(f_clamp(endRow, 0, rows - 1))

    float scoreSum = 0.0

    for r = startRow to endRow
        float rowLo = lo + r * rowH
        float rowHi = rowLo + rowH
        float rowScore = f_rowAllocScore(
             rowLo, rowHi,
             bl, bh,
             bo, bc,
             rowDistMode,
             bodyRowWeight, wickRowWeight, closeBiasStrength)
        scoreSum += rowScore

    if scoreSum <= minRowScoreFallback
        int touched = math.max(endRow - startRow + 1, 1)
        float buyPerRow  = buyV / touched
        float sellPerRow = sellV / touched
        float totPerRow  = bv / touched

        for r = startRow to endRow
            array.set(rowBuy,  r, array.get(rowBuy, r) + buyPerRow)
            array.set(rowSell, r, array.get(rowSell, r) + sellPerRow)
            array.set(rowTot,  r, array.get(rowTot, r) + totPerRow)
    else
        for r = startRow to endRow
            float rowLo = lo + r * rowH
            float rowHi = rowLo + rowH
            float rowScore = f_rowAllocScore(
                 rowLo, rowHi,
                 bl, bh,
                 bo, bc,
                 rowDistMode,
                 bodyRowWeight, wickRowWeight, closeBiasStrength)

            float frac = rowScore / scoreSum
            array.set(rowBuy,  r, array.get(rowBuy, r) + buyV * frac)
            array.set(rowSell, r, array.get(rowSell, r) + sellV * frac)
            array.set(rowTot,  r, array.get(rowTot, r) + bv * frac)

    [buyV, sellV]

f_accumulateSplitBarToRows(
    float bo, float bh, float bl, float bc,
    float buyV, float sellV, float totalV,
    float lo, float rowH, int rows,
    string rowDistMode, float bodyRowWeight, float wickRowWeight, float closeBiasStrength, float minRowScoreFallback,
    array<float> rowBuy, array<float> rowSell, array<float> rowTot
) =>
    int startRow = int(math.floor((bl - lo) / rowH))
    int endRow   = int(math.floor((bh - lo) / rowH))
    startRow := int(f_clamp(startRow, 0, rows - 1))
    endRow   := int(f_clamp(endRow, 0, rows - 1))

    float scoreSum = 0.0

    for r = startRow to endRow
        float rowLo = lo + r * rowH
        float rowHi = rowLo + rowH
        float rowScore = f_rowAllocScore(
             rowLo, rowHi,
             bl, bh,
             bo, bc,
             rowDistMode,
             bodyRowWeight, wickRowWeight, closeBiasStrength)
        scoreSum += rowScore

    if scoreSum <= minRowScoreFallback
        int touched = math.max(endRow - startRow + 1, 1)
        float buyPerRow  = buyV / touched
        float sellPerRow = sellV / touched
        float totPerRow  = totalV / touched

        for r = startRow to endRow
            array.set(rowBuy,  r, array.get(rowBuy, r) + buyPerRow)
            array.set(rowSell, r, array.get(rowSell, r) + sellPerRow)
            array.set(rowTot,  r, array.get(rowTot, r) + totPerRow)
    else
        for r = startRow to endRow
            float rowLo = lo + r * rowH
            float rowHi = rowLo + rowH
            float rowScore = f_rowAllocScore(
                 rowLo, rowHi,
                 bl, bh,
                 bo, bc,
                 rowDistMode,
                 bodyRowWeight, wickRowWeight, closeBiasStrength)

            float frac = rowScore / scoreSum
            array.set(rowBuy,  r, array.get(rowBuy, r) + buyV * frac)
            array.set(rowSell, r, array.get(rowSell, r) + sellV * frac)
            array.set(rowTot,  r, array.get(rowTot, r) + totalV * frac)

    [buyV, sellV]

f_tableTextSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_dashLabel(string fullLabel, string compactLabel, bool compact) =>
    compact ? compactLabel : fullLabel

//────────────────────────────────────────────
// DASHBOARD COLOR HELPERS
//────────────────────────────────────────────
f_stateBg(string s) =>
    s == "STRONG BULL" or s == "STRONG BUY" ? color.new(color.green, 0) :
 s == "BULL" or s == "BUY"               ? color.new(color.lime, 15) :
 s == "BALANCED" or s == "NEUTRAL"       ? color.new(color.gray, 35) :
 s == "TRANSITION"                       ? color.new(color.silver, 20) :
 s == "BEAR" or s == "SELL"              ? color.new(color.orange, 10) :
 s == "STRONG BEAR" or s == "STRONG SELL"? color.new(color.red, 0) :
                                              color.new(color.black, 20)

f_stateText(string s) =>
    s == "BALANCED" or s == "NEUTRAL" or s == "TRANSITION" ? color.black : color.white

f_netDeltaState(float _netPct, float neutralBand, float bullThresh, float strongThresh) =>
    string out = "NA"
    if not na(_netPct)
        out :=
             _netPct >= strongThresh  ? "STRONG BULL" :
             _netPct >= bullThresh    ? "BULL" :
             _netPct <= -strongThresh ? "STRONG BEAR" :
             _netPct <= -bullThresh   ? "BEAR" :
             math.abs(_netPct) < neutralBand ? "BALANCED" :
             "TRANSITION"
    out

f_netDeltaBg(float _netPct, float neutralBand, float bullThresh, float strongThresh) =>
    f_stateBg(f_netDeltaState(_netPct, neutralBand, bullThresh, strongThresh))

f_netDeltaText(float _netPct, float neutralBand, float bullThresh, float strongThresh) =>
    f_stateText(f_netDeltaState(_netPct, neutralBand, bullThresh, strongThresh))

f_contextBg(string s) =>
    s == "Bull Acceptance" or s == "POC Up" ? color.new(color.lime, 10) :
     s == "Bear Acceptance" or s == "POC Down" ? color.new(color.red, 0) :
     s == "Top Heavy" ? color.new(color.orange, 10) :
     s == "Bottom Heavy" ? color.new(color.teal, 10) :
     s == "Balance" or s == "POC Flat" ? color.new(color.gray, 35) :
     color.new(color.black, 20)

f_confidenceBg(float c) =>
    c >= 75 ? color.new(color.green, 0) :
     c >= 55 ? color.new(color.lime, 15) :
     c >= 35 ? color.new(color.orange, 10) :
     color.new(color.red, 0)

f_confidenceText(float c) =>
    c >= 55 ? color.white : color.black

f_structureBg(float score) =>
    score >= 2.0 ? color.new(color.lime, 10) :
 score <= -2.0 ? color.new(color.red, 0) :
 color.new(color.gray, 35)

f_structureText(float score) =>
    score == 0 ? color.black : color.white

f_buySellBg(float buyEst, float sellEst) =>
    float denom = math.max(buyEst + sellEst, 0.0001)
    float pct = (buyEst - sellEst) / denom * 100.0
    pct >= strongPressurePct  ? color.new(color.green, 0) :
 pct >= bullPressurePct    ? color.new(color.lime, 10) :
 pct <= -strongPressurePct ? color.new(color.red, 0) :
 pct <= -bullPressurePct   ? color.new(color.orange, 0) :
                         color.new(color.gray, 35)

f_buySellText(float buyEst, float sellEst) =>
    float denom = math.max(buyEst + sellEst, 0.0001)
    float pct = (buyEst - sellEst) / denom * 100.0
    math.abs(pct) < neutralBandPct ? color.black : color.white

dashboardTextSize = f_tableTextSize(dashboardTextSizeOpt)

//────────────────────────────────────────────
// SHARED SERIES
//────────────────────────────────────────────
bool inSession = not na(time(timeframe.period, sessionInput))
bool newSession = inSession and not inSession[1]
float volAvg20 = ta.sma(volume, 20)

array<float> ltfOpenArr   = request.security_lower_tf(syminfo.tickerid, ltfTf, open)
array<float> ltfHighArr   = request.security_lower_tf(syminfo.tickerid, ltfTf, high)
array<float> ltfLowArr    = request.security_lower_tf(syminfo.tickerid, ltfTf, low)
array<float> ltfCloseArr  = request.security_lower_tf(syminfo.tickerid, ltfTf, close)
array<float> ltfVolumeArr = request.security_lower_tf(syminfo.tickerid, ltfTf, volume)

var int trackedSessionStartBar = na
if newSession
    trackedSessionStartBar := bar_index
else if not inSession
    trackedSessionStartBar := na

//────────────────────────────────────────────
// HISTORICAL WINDOW-LEVEL PRESSURE ENGINE
//────────────────────────────────────────────
//────────────────────────────────────────────
// HISTORICAL / LTF-RECONSTRUCTED BUY-SELL SERIES
//────────────────────────────────────────────
float htfBuyShareBar = f_buyShare(open, high, low, close, estMode, splitNeutral, bodyWeight, closeWeight, dirWeight)
float htfBuyVolBar   = volume * htfBuyShareBar
float htfSellVolBar  = volume * (1.0 - htfBuyShareBar)

float ltfBuyVolBar = na
float ltfSellVolBar = na
float ltfTotalVolBar = na

if useLTFReconstruction and array.size(ltfOpenArr) > 0
    float bSum = 0.0
    float sSum = 0.0
    float tSum = 0.0

    int nLtf = array.size(ltfOpenArr)
    for j = 0 to nLtf - 1
        float lo_ = array.get(ltfOpenArr, j)
        float lh_ = array.get(ltfHighArr, j)
        float ll_ = array.get(ltfLowArr, j)
        float lc_ = array.get(ltfCloseArr, j)
        float lv_ = array.get(ltfVolumeArr, j)

        if not na(lo_) and not na(lh_) and not na(ll_) and not na(lc_) and not na(lv_) and lv_ > 0
            float bs_ = f_buyShare(lo_, lh_, ll_, lc_, estMode, splitNeutral, bodyWeight, closeWeight, dirWeight)
            bSum += lv_ * bs_
            sSum += lv_ * (1.0 - bs_)
            tSum += lv_

    if tSum > 0
        ltfBuyVolBar := bSum
        ltfSellVolBar := sSum
        ltfTotalVolBar := tSum

bool ltfAvailable = useLTFReconstruction and not na(ltfBuyVolBar) and not na(ltfSellVolBar)

float buyVolBar =
     ltfAvailable ? ltfBuyVolBar :
     ltfFallbackToHTF ? htfBuyVolBar :
     0.0

float sellVolBar =
     ltfAvailable ? ltfSellVolBar :
     ltfFallbackToHTF ? htfSellVolBar :
     0.0

int histLookbackLen = fastMode ? math.min(lookbackBars, fastMaxBars) : lookbackBars
histLookbackLen := math.max(histLookbackLen, 1)

float cumBuyVol  = ta.cum(buyVolBar)
float cumSellVol = ta.cum(sellVolBar)

float histBuyLookback  = cumBuyVol  - nz(cumBuyVol[histLookbackLen], 0.0)
float histSellLookback = cumSellVol - nz(cumSellVol[histLookbackLen], 0.0)

var float histSessBuy  = na
var float histSessSell = na

if inSession
    histSessBuy  := newSession ? buyVolBar  : nz(histSessBuy[1])  + buyVolBar
    histSessSell := newSession ? sellVolBar : nz(histSessSell[1]) + sellVolBar
else
    histSessBuy  := na
    histSessSell := na

float histBuyWindow  = modeProfile == "Lookback" ? histBuyLookback  : histSessBuy
float histSellWindow = modeProfile == "Lookback" ? histSellLookback : histSessSell
float histDenom      = histBuyWindow + histSellWindow
float netPctHist     = histDenom > 0 ? (histBuyWindow - histSellWindow) / histDenom * 100.0 : na

bool histBalanced   = not na(netPctHist) and netPctHist > -neutralBandPct and netPctHist < neutralBandPct
bool histBull       = not na(netPctHist) and netPctHist >= bullPressurePct and netPctHist < strongPressurePct
bool histStrongBull = not na(netPctHist) and netPctHist >= strongPressurePct
bool histBear       = not na(netPctHist) and netPctHist <= -bullPressurePct and netPctHist > -strongPressurePct
bool histStrongBear = not na(netPctHist) and netPctHist <= -strongPressurePct
bool histTransition = not na(netPctHist) and not histBalanced and not histBull and not histStrongBull and not histBear and not histStrongBear

color histFinalBarColor =
     showPressureColoring and enablePressureEngine and useTransitionRule and histTransition
     ? transitionColor
     : na

//────────────────────────────────────────────
// HISTORICAL Net Δ SIGN-FLIP MIDLINES ONLY
//────────────────────────────────────────────
var line activeBullFlipMidline = na
var line activeBearFlipMidline = na

bool posHist = not na(netPctHist) and netPctHist > 0
bool negHist = not na(netPctHist) and netPctHist < 0

bool bullFlip = showFlipBoxes and posHist and not na(netPctHist[1]) and netPctHist[1] < 0
bool bearFlip = showFlipBoxes and negHist and not na(netPctHist[1]) and netPctHist[1] > 0

if bullFlip
    if flipBoxMode == "Until Next Flip" and not na(activeBearFlipMidline)
        line.set_x2(activeBearFlipMidline, bar_index)
        activeBearFlipMidline := na

    int bullRight = flipBoxMode == "Candle Only" ? bar_index : flipBoxMode == "Fixed Bars" ? bar_index + flipBoxExtendBars : bar_index
    float bullMid = (high + low) * 0.5

    if showFlipBoxMidline
        line newBullMid = line.new(bar_index, bullMid, bullRight, bullMid, color=bullFlipMidlineColor, width=flipMidlineWidth, style=f_lineStyle(flipMidlineStyle))
        if flipBoxMode == "Until Next Flip"
            activeBullFlipMidline := newBullMid

if bearFlip
    if flipBoxMode == "Until Next Flip" and not na(activeBullFlipMidline)
        line.set_x2(activeBullFlipMidline, bar_index)
        activeBullFlipMidline := na

    int bearRight = flipBoxMode == "Candle Only" ? bar_index : flipBoxMode == "Fixed Bars" ? bar_index + flipBoxExtendBars : bar_index
    float bearMid = (high + low) * 0.5

    if showFlipBoxMidline
        line newBearMid = line.new(bar_index, bearMid, bearRight, bearMid, color=bearFlipMidlineColor, width=flipMidlineWidth, style=f_lineStyle(flipMidlineStyle))
        if flipBoxMode == "Until Next Flip"
            activeBearFlipMidline := newBearMid

if flipBoxMode == "Until Next Flip"
    if not na(activeBullFlipMidline)
        line.set_x2(activeBullFlipMidline, bar_index)
    if not na(activeBearFlipMidline)
        line.set_x2(activeBearFlipMidline, bar_index)

//────────────────────────────────────────────
// LIVE CURRENT-PROFILE ENGINE
//────────────────────────────────────────────
int sessionBars = modeProfile == "Session" and inSession and not na(trackedSessionStartBar) ? (bar_index - trackedSessionStartBar + 1) : 0
bool sessionActive = modeProfile != "Session" ? true : inSession

int barsUsedRaw = modeProfile == "Lookback" ? math.min(lookbackBars, bar_index + 1) : sessionBars
int barsUsed = fastMode ? math.min(barsUsedRaw, fastMaxBars) : barsUsedRaw
barsUsed := math.min(barsUsed, math.min(bar_index + 1, 5000))

float sigLow  = modeProfile == "Session" ? ta.lowest(low, math.max(sessionBars, 1)) : ta.lowest(low, signalLookbackBars)
float sigHigh = modeProfile == "Session" ? ta.highest(high, math.max(sessionBars, 1)) : ta.highest(high, signalLookbackBars)

float hi = barsUsed > 0 ? ta.highest(high, barsUsed) : na
float lo = barsUsed > 0 ? ta.lowest(low, barsUsed) : na
float span = barsUsed > 0 ? math.max(hi - lo, syminfo.mintick * rows) : na
float rowH = barsUsed > 0 ? span / rows : na

var float[] rowBuy  = array.new_float()
var float[] rowSell = array.new_float()
var float[] rowTot  = array.new_float()

var line[] lvlLines    = array.new_line()
var label[] lvlLabels  = array.new_label()

var line pocLine       = na
var line vahLine       = na
var line valLine       = na
var line vwmpLine      = na
var line vwmpUpperLine = na
var line vwmpLowerLine = na
var box[] profileBoxes = array.new_box()
var table statsTable   = table.new(position.bottom_right, 2, 17, border_width = 1, force_overlay=true)
var label bullAbsLbl   = na
var label bearAbsLbl   = na
var label bullReclaimLbl = na
var label bearRejectLbl  = na
var label topBuyClusterLbl = na
var label topSellClusterLbl = na
var label[] bearMismatchLabels = array.new_label()
var label[] bullMismatchLabels = array.new_label()

var int lastBullAbsBar = na
var int lastBearAbsBar = na
var int lastBullReclaimBar = na
var int lastBearRejectBar  = na
var int lastBearMismatchBar = na
var int lastBullMismatchBar = na

var bool bullReclaimArmed = false
var bool bearRejectArmed  = false
var bool bullAbsArmed     = false
var bool bearAbsArmed     = false
var bool bearMismatchArmed = false
var bool bullMismatchArmed = false

float totalBuyEst = 0.0
float totalSellEst = 0.0
totalBuyEst := 0.0
totalSellEst := 0.0

var color lowNetBarColor = na
lowNetBarColor := na

// outer-scope variables used by dashboard
float pocPrice = na
float vahPrice = na
float valPrice = na
float vwmpPrice = na
float volStd = na
float net = na
float netPct = na
float topBuyClusterScore = na
float topBuyClusterBot = na
float topBuyClusterTop = na
float topSellClusterScore = na
float topSellClusterBot = na
float topSellClusterTop = na
string pressureStateRaw = "NA"
float confidenceScore = na
float pocDominancePct = na
string pocMigrationState = "N/A"
string pocVwmpState = "N/A"
string modelNoteText = "OHLCV Proxy"
bool performanceWarningNow = false
float structureScore = na
float flowScore = na

var float priorTrackedPOC = na

// Alert bridge variables for labels/signals calculated inside the last-bar profile engine.
bool bullAbsFireOut = false
bool bearAbsFireOut = false
bool bullReclaimFireOut = false
bool bearRejectFireOut = false
bool bearPressureFailureFireOut = false
bool bullPressureFailureFireOut = false
bool bullFlipOut = bullFlip
bool bearFlipOut = bearFlip
bool signalConfirmOK = not confirmSignalsOnClose or barstate.isconfirmed
bool strongBullPressureOut = histStrongBull and not histStrongBull[1] and signalConfirmOK
bool strongBearPressureOut = histStrongBear and not histStrongBear[1] and signalConfirmOK

if barstate.islast and sessionActive and barsUsed > 0
    array.clear(rowBuy)
    array.clear(rowSell)
    array.clear(rowTot)
    for _ = 0 to rows - 1
        array.push(rowBuy, 0.0)
        array.push(rowSell, 0.0)
        array.push(rowTot, 0.0)

    for b = 0 to barsUsed - 1
        bool useBar = modeProfile == "Lookback" or inSession[b]
        if useBar
            bool useTrueCurrentBarLTF =
                 useLTFReconstruction and
                 useTrueLTFCurrentBarRows and
                 b == 0 and
                 array.size(ltfOpenArr) > 0

            float buyVPart = na
            float sellVPart = na

            if useTrueCurrentBarLTF
                int nLtf = array.size(ltfOpenArr)
                for j = 0 to nLtf - 1
                    float bo = array.get(ltfOpenArr, j)
                    float bh = array.get(ltfHighArr, j)
                    float bl = array.get(ltfLowArr, j)
                    float bc = array.get(ltfCloseArr, j)
                    float bv = array.get(ltfVolumeArr, j)

                    if not na(bo) and not na(bh) and not na(bl) and not na(bc) and not na(bv) and bv > 0
                        [buyVPart, sellVPart] = f_accumulateBarToRows(
                             bo, bh, bl, bc, bv,
                             lo, rowH, rows,
                             estMode, splitNeutral, bodyWeight, closeWeight, dirWeight,
                             rowDistMode, bodyRowWeight, wickRowWeight, closeBiasStrength, minRowScoreFallback,
                             rowBuy, rowSell, rowTot)

                        totalBuyEst += buyVPart
                        totalSellEst += sellVPart
            else
                float bo = open[b]
                float bh = high[b]
                float bl = low[b]
                float bc = close[b]

                float useBuyV = useLTFReconstruction ? buyVolBar[b] : htfBuyVolBar[b]
                float useSellV = useLTFReconstruction ? sellVolBar[b] : htfSellVolBar[b]
                float useTotV = math.max(useBuyV + useSellV, 0.0)

                if useTotV > 0
                    [buyVPart, sellVPart] = f_accumulateSplitBarToRows(
                         bo, bh, bl, bc,
                         useBuyV, useSellV, useTotV,
                         lo, rowH, rows,
                         rowDistMode, bodyRowWeight, wickRowWeight, closeBiasStrength, minRowScoreFallback,
                         rowBuy, rowSell, rowTot)

                    totalBuyEst += buyVPart
                    totalSellEst += sellVPart

    f_clear_lines(lvlLines)
    f_clear_labels(lvlLabels)
    f_clear_boxes(profileBoxes)

    if not na(pocLine)
        line.delete(pocLine)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)
    if not na(vwmpLine)
        line.delete(vwmpLine)
    if not na(vwmpUpperLine)
        line.delete(vwmpUpperLine)
    if not na(vwmpLowerLine)
        line.delete(vwmpLowerLine)
    if not na(bullAbsLbl)
        label.delete(bullAbsLbl)
    if not na(bearAbsLbl)
        label.delete(bearAbsLbl)
    if not na(bullReclaimLbl)
        label.delete(bullReclaimLbl)
    if not na(bearRejectLbl)
        label.delete(bearRejectLbl)
    if not na(topBuyClusterLbl)
        label.delete(topBuyClusterLbl)
    if not na(topSellClusterLbl)
        label.delete(topSellClusterLbl)

    float maxRowTot = 0.0
    int pocRow = 0
    for r = 0 to rows - 1
        float totR = array.get(rowTot, r)
        if totR > maxRowTot
            maxRowTot := totR
            pocRow := r

    float totalVolAll = 0.0
    for r = 0 to rows - 1
        totalVolAll += array.get(rowTot, r)

    float volPriceSum = 0.0
    for r = 0 to rows - 1
        float rowPriceForVWMP = lo + (r + 0.5) * rowH
        float rowVolForVWMP = array.get(rowTot, r)
        volPriceSum += rowPriceForVWMP * rowVolForVWMP
    vwmpPrice := totalVolAll > 0 ? volPriceSum / totalVolAll : na

    float targetVA = totalVolAll * (vaPct * 0.01)
    int left = pocRow
    int right = pocRow
    float vaVol = array.get(rowTot, pocRow)

    while vaVol < targetVA and (left > 0 or right < rows - 1)
        float leftVol = left > 0 ? array.get(rowTot, left - 1) : -1.0
        float rightVol = right < rows - 1 ? array.get(rowTot, right + 1) : -1.0

        if leftVol >= rightVol and left > 0
            left -= 1
            vaVol += array.get(rowTot, left)
        else if right < rows - 1
            right += 1
            vaVol += array.get(rowTot, right)
        else if left > 0
            left -= 1
            vaVol += array.get(rowTot, left)

    int valRowInt = left
    int vahRowInt = right

    pocPrice := lo + (pocRow + 0.5) * rowH
    vahPrice := lo + (vahRowInt + 1.0) * rowH
    valPrice := lo + valRowInt * rowH

    float volVar = 0.0
    for r = 0 to rows - 1
        float rowPrice = lo + (r + 0.5) * rowH
        float rowVol = array.get(rowTot, r)
        volVar += rowVol * math.pow(rowPrice - vwmpPrice, 2)
    volStd := totalVolAll > 0 ? math.sqrt(volVar / totalVolAll) : 0.0

    int xLeft = bar_index + xOffsetBars + 1
    int xRightMax = xLeft + profileWidthBars

    //────────────────────────────────────────────
    // RIGHT-SIDE ESTIMATED BUY / SELL PROFILE BOXES
    // Corrected orientation:
    // - xRightMax is the fixed right anchor.
    // - Each row expands LEFT from xRightMax, like a normal right-side profile.
    // - Buy segment is drawn closer to the price/left side.
    // - Sell segment is drawn closer to the far-right edge.
    //────────────────────────────────────────────
    if showRightProfile and showProfileBoxes and maxRowTot > 0
        for r = 0 to rows - 1
            float bEst = array.get(rowBuy, r)
            float sEst = array.get(rowSell, r)
            float tEst = array.get(rowTot, r)

            if tEst > 0
                float rowLo = lo + r * rowH
                float rowHi = rowLo + rowH

                int totalW = int(math.round(profileWidthBars * tEst / maxRowTot))
                totalW := math.max(totalW, 1)

                float denom = math.max(bEst + sEst, 0.0001)

                int buyW = int(math.round(totalW * bEst / denom))
                buyW := math.max(math.min(buyW, totalW), 0)

                int sellW = totalW - buyW

                int rowRight = xRightMax
                int rowLeft  = xRightMax - totalW

                int buyLeft  = rowLeft
                int buyRight = rowLeft + buyW

                int sellLeft  = buyRight
                int sellRight = rowRight

                if buyW > 0
                    box buyBx = box.new(
                         left=buyLeft,
                         top=rowHi,
                         right=buyRight,
                         bottom=rowLo,
                         bgcolor=color.new(buyColor, profileOpacity),
                         border_color=color.new(buyColor, 100))
                    array.push(profileBoxes, buyBx)

                if sellW > 0
                    box sellBx = box.new(
                         left=sellLeft,
                         top=rowHi,
                         right=sellRight,
                         bottom=rowLo,
                         bgcolor=color.new(sellColor, profileOpacity),
                         border_color=color.new(sellColor, 100))
                    array.push(profileBoxes, sellBx)

    if showPOC
        pocLine := line.new(xRightMax - profileWidthBars - 8, pocPrice, xRightMax + 8, pocPrice, color=pocColor, width=4)
    if showVA
        vahLine := line.new(xRightMax - profileWidthBars - 8, vahPrice, xRightMax + 8, vahPrice, color=vaColor, width=2, style=line.style_dashed)
        valLine := line.new(xRightMax - profileWidthBars - 8, valPrice, xRightMax + 8, valPrice, color=vaColor, width=2, style=line.style_dashed)
    if showVWMP and not na(vwmpPrice)
        vwmpLine := line.new(xRightMax - profileWidthBars - 8, vwmpPrice, xRightMax + 8, vwmpPrice, color=vwmpColor, width=vwmpWidth)
        if showVWMPSigma and volStd > 0
            vwmpUpperLine := line.new(xRightMax - profileWidthBars - 8, vwmpPrice + volStd * vwmpSigmaMult, xRightMax + 8, vwmpPrice + volStd * vwmpSigmaMult, color=vwmpSigmaColor, width=vwmpSigmaWidth)
            vwmpLowerLine := line.new(xRightMax - profileWidthBars - 8, vwmpPrice - volStd * vwmpSigmaMult, xRightMax + 8, vwmpPrice - volStd * vwmpSigmaMult, color=vwmpSigmaColor, width=vwmpSigmaWidth)

    float[] buyScore = array.new_float()
    float[] sellScore = array.new_float()
    float[] buyPctLabel = array.new_float()
    float[] sellPctLabel = array.new_float()
    int[] buyIdx = array.new_int()
    int[] sellIdx = array.new_int()

    for r = 0 to rows - 1
        float bEst = array.get(rowBuy, r)
        float sEst = array.get(rowSell, r)
        float denom = math.max(bEst + sEst, 0.0001)
        float diffPct = math.abs(bEst - sEst) / denom * 100.0
        bool rowVolOK = maxRowTot > 0 and array.get(rowTot, r) >= maxRowTot * minRowVolPctOfPOC * 0.01
        if rowVolOK and diffPct >= minImbalancePct
            float volWeight = maxRowTot > 0 ? array.get(rowTot, r) / maxRowTot : 0.0
            float rankScore = useVolumeWeightedImbalanceRank ? diffPct * volWeight : diffPct
            if bEst > sEst
                array.push(buyScore, rankScore)
                array.push(buyPctLabel, diffPct)
                array.push(buyIdx, r)
            else if sEst > bEst
                array.push(sellScore, rankScore)
                array.push(sellPctLabel, diffPct)
                array.push(sellIdx, r)

    if showTopLevels
        int buySz = array.size(buyScore)
        if buySz > 0
            int buyCount = showDominantOnlyLevels ? 1 : math.min(topNLevels, buySz)
            for _k = 0 to buyCount - 1
                int bestPos = f_best_index(buyScore)
                if not na(bestPos)
                    float best = array.get(buyScore, bestPos)
                    float bestPct = array.get(buyPctLabel, bestPos)
                    int rr = array.get(buyIdx, bestPos)
                    float y = lo + (rr + 0.5) * rowH
                    line ln = line.new(xRightMax - profileWidthBars - 8, y, xRightMax, y, color=color.new(buyColor, 0), width=levelLineWidth)
                    array.push(lvlLines, ln)
                    string rankTxt = useVolumeWeightedImbalanceRank ? " | R " + str.tostring(best, "#.1") : ""
                    label lb = label.new(xRightMax + 1, y, f_buyImbalanceText(bestPct) + rankTxt, style=label.style_label_left, color=color.new(buyColor, 0), textcolor=color.black, size=size.small)
                    array.push(lvlLabels, lb)
                    array.set(buyScore, bestPos, -1.0)

        int sellSz = array.size(sellScore)
        if sellSz > 0
            int sellCount = showDominantOnlyLevels ? 1 : math.min(topNLevels, sellSz)
            for _k = 0 to sellCount - 1
                int bestPos = f_best_index(sellScore)
                if not na(bestPos)
                    float best = array.get(sellScore, bestPos)
                    float bestPct = array.get(sellPctLabel, bestPos)
                    int rr = array.get(sellIdx, bestPos)
                    float y = lo + (rr + 0.5) * rowH
                    line ln = line.new(xRightMax - profileWidthBars - 8, y, xRightMax, y, color=color.new(sellColor, 0), width=levelLineWidth)
                    array.push(lvlLines, ln)
                    string rankTxt = useVolumeWeightedImbalanceRank ? " | R " + str.tostring(best, "#.1") : ""
                    label lb = label.new(xRightMax + 1, y, f_sellImbalanceText(bestPct) + rankTxt, style=label.style_label_left, color=color.new(sellColor, 0), textcolor=color.white, size=size.small)
                    array.push(lvlLabels, lb)
                    array.set(sellScore, bestPos, -1.0)

    topBuyClusterScore := na
    topBuyClusterBot := na
    topBuyClusterTop := na
    topSellClusterScore := na
    topSellClusterBot := na
    topSellClusterTop := na

    if showClusters
        int r = 0
        while r < rows
            float bEst = array.get(rowBuy, r)
            float sEst = array.get(rowSell, r)
            float denom = math.max(bEst + sEst, 0.0001)
            float diffPct = math.abs(bEst - sEst) / denom * 100.0
            bool rowVolOK = maxRowTot > 0 and array.get(rowTot, r) >= maxRowTot * minRowVolPctOfPOC * 0.01
            bool isBuyDom = rowVolOK and bEst > sEst and diffPct >= clusterThresholdPct
            bool isSellDom = rowVolOK and sEst > bEst and diffPct >= clusterThresholdPct

            if isBuyDom or isSellDom
                int startR = r
                int countR = 1
                float score = diffPct
                r += 1
                while r < rows
                    float b2 = array.get(rowBuy, r)
                    float s2 = array.get(rowSell, r)
                    float d2 = math.max(b2 + s2, 0.0001)
                    float p2 = math.abs(b2 - s2) / d2 * 100.0
                    bool rowVolOK2 = maxRowTot > 0 and array.get(rowTot, r) >= maxRowTot * minRowVolPctOfPOC * 0.01
                    bool sameType = isBuyDom ? (rowVolOK2 and b2 > s2 and p2 >= clusterThresholdPct) : (rowVolOK2 and s2 > b2 and p2 >= clusterThresholdPct)
                    if sameType
                        countR += 1
                        score += p2
                        r += 1
                    else
                        break

                int endR = r - 1
                if countR >= clusterMinRows
                    float y1 = lo + startR * rowH
                    float y2 = lo + (endR + 1) * rowH

                    if isBuyDom
                        if na(topBuyClusterScore) or score > topBuyClusterScore
                            topBuyClusterScore := score
                            topBuyClusterBot := y1
                            topBuyClusterTop := y2
                    else
                        if na(topSellClusterScore) or score > topSellClusterScore
                            topSellClusterScore := score
                            topSellClusterBot := y1
                            topSellClusterTop := y2
            else
                r += 1

    if showClusters and showOnlyTopActiveLabel
        if not na(topBuyClusterScore)
            topBuyClusterLbl := label.new(xRightMax + 8, topBuyClusterBot, "Top Active Buy Cluster", style=label.style_label_left, color=color.new(buyColor, 0), textcolor=color.black, size=size.small)
        if not na(topSellClusterScore)
            topSellClusterLbl := label.new(xRightMax + 8, topSellClusterTop, "Top Active Sell Cluster", style=label.style_label_left, color=color.new(sellColor, 0), textcolor=color.black, size=size.small)

    if showSignals
        bool volOK = not useVolumeConfirm or volume >= volAvg20 * volumeConfirmMult
        float clusterBuf = clusterBufferRows * rowH

        if not na(topSellClusterTop)
            if close < topSellClusterTop - clusterBuf
                bullReclaimArmed := true
            if low <= topSellClusterTop + clusterBuf
                bullAbsArmed := true
            if close > topSellClusterTop + clusterBuf * 2.0
                bullAbsArmed := false

        if not na(topBuyClusterBot)
            if close > topBuyClusterBot + clusterBuf
                bearRejectArmed := true
            if high >= topBuyClusterBot - clusterBuf
                bearAbsArmed := true
            if close < topBuyClusterBot - clusterBuf * 2.0
                bearAbsArmed := false

        bool bullAbsRaw =
             showAbsorption and
             not na(topSellClusterTop) and
             bullAbsArmed and
             low <= topSellClusterTop + clusterBuf and
             close > topSellClusterTop + clusterBuf and
             close > open and close > close[1] and
             volOK

        bool bearAbsRaw =
             showAbsorption and
             not na(topBuyClusterBot) and
             bearAbsArmed and
             high >= topBuyClusterBot - clusterBuf and
             close < topBuyClusterBot - clusterBuf and
             close < open and close < close[1] and
             volOK

        bool bullReclaimRaw =
             not na(topSellClusterTop) and
             bullReclaimArmed and
             close[1] < topSellClusterTop and
             close > topSellClusterTop + clusterBuf and
             volOK and
             (not requireCandleFlip or close > open)

        bool bearRejectRaw =
             not na(topBuyClusterBot) and
             bearRejectArmed and
             close[1] > topBuyClusterBot and
             close < topBuyClusterBot - clusterBuf and
             volOK and
             (not requireCandleFlip or close < open)

        bool bullAbsFire = signalConfirmOK and bullAbsRaw and (na(lastBullAbsBar) or bar_index - lastBullAbsBar > signalCooldownBars)
        bool bearAbsFire = signalConfirmOK and bearAbsRaw and (na(lastBearAbsBar) or bar_index - lastBearAbsBar > signalCooldownBars)
        bool bullReclaimFire = signalConfirmOK and bullReclaimRaw and (na(lastBullReclaimBar) or bar_index - lastBullReclaimBar > signalCooldownBars)
        bool bearRejectFire = signalConfirmOK and bearRejectRaw and (na(lastBearRejectBar) or bar_index - lastBearRejectBar > signalCooldownBars)

        if bullAbsFire
            bullAbsFireOut := true
            bullAbsLbl := label.new(bar_index, low, "Bullish Absorption", style=label.style_label_up, color=color.new(buyColor, 0), textcolor=color.black, size=size.small)
            lastBullAbsBar := bar_index
            bullAbsArmed := false

        if bearAbsFire
            bearAbsFireOut := true
            bearAbsLbl := label.new(bar_index, high, "Bearish Absorption", style=label.style_label_down, color=color.new(sellColor, 0), textcolor=color.black, size=size.small)
            lastBearAbsBar := bar_index
            bearAbsArmed := false

        if bullReclaimFire
            bullReclaimFireOut := true
            bullReclaimLbl := label.new(bar_index, low, "Bull Reclaim", style=label.style_label_up, color=color.new(color.teal, 0), textcolor=color.black, size=size.small)
            lastBullReclaimBar := bar_index
            bullReclaimArmed := false

        if bearRejectFire
            bearRejectFireOut := true
            bearRejectLbl := label.new(bar_index, high, "Bear Reject", style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.black, size=size.small)
            lastBearRejectBar := bar_index
            bearRejectArmed := false

    float mismatchBuf = rowH * clusterBufferRows
    bool mismatchVolOK = not useVolumeConfirm or volume >= volAvg20 * volumeConfirmMult

    bool nearPOC  = not na(pocPrice) and low <= pocPrice + mismatchBuf and high >= pocPrice - mismatchBuf
    bool nearVWMP = not na(vwmpPrice) and low <= vwmpPrice + mismatchBuf and high >= vwmpPrice - mismatchBuf

    bool bearStructFail =
         (nearPOC and close > pocPrice + mismatchBuf) or
         (nearVWMP and close > vwmpPrice + mismatchBuf) or
         (not na(topSellClusterTop) and close > topSellClusterTop + mismatchBuf)

    bool bullStructFail =
         (nearPOC and close < pocPrice - mismatchBuf) or
         (nearVWMP and close < vwmpPrice - mismatchBuf) or
         (not na(topBuyClusterBot) and close < topBuyClusterBot - mismatchBuf)

    if showMismatchSignals
        if histStrongBear and not bearStructFail
            bearMismatchArmed := true
        if histStrongBull and not bullStructFail
            bullMismatchArmed := true

        if not histStrongBear
            bearMismatchArmed := false
        if not histStrongBull
            bullMismatchArmed := false

    bool bearPressureFailureRaw =
         showMismatchSignals and
         showBearPressureFailure and
         histStrongBear and
         mismatchVolOK and
         bearStructFail and
         (not useMismatchPrevClose or close > close[1])

    bool bullPressureFailureRaw =
         showMismatchSignals and
         showBullPressureFailure and
         histStrongBull and
         mismatchVolOK and
         bullStructFail and
         (not useMismatchPrevClose or close < close[1])

    if useMismatchStructure
        bearPressureFailureRaw := bearPressureFailureRaw and (nearPOC or nearVWMP or not na(topSellClusterTop))
        bullPressureFailureRaw := bullPressureFailureRaw and (nearPOC or nearVWMP or not na(topBuyClusterBot))

    bool bearPressureFailureFire =
         signalConfirmOK and
         bearMismatchArmed and
         bearPressureFailureRaw and
         (na(lastBearMismatchBar) or bar_index - lastBearMismatchBar > signalCooldownBars)

    bool bullPressureFailureFire =
         signalConfirmOK and
         bullMismatchArmed and
         bullPressureFailureRaw and
         (na(lastBullMismatchBar) or bar_index - lastBullMismatchBar > signalCooldownBars)

    if bearPressureFailureFire
        bearPressureFailureFireOut := true
        label newBearFail = label.new(bar_index, low, "", style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
        if keepMismatchHistory
            array.push(bearMismatchLabels, newBearFail)
            while array.size(bearMismatchLabels) > maxMismatchLabels
                label.delete(array.shift(bearMismatchLabels))
        lastBearMismatchBar := bar_index
        bearMismatchArmed := false

    if bullPressureFailureFire
        bullPressureFailureFireOut := true
        label newBullFail = label.new(bar_index, high, "", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.black, size=size.small)
        if keepMismatchHistory
            array.push(bullMismatchLabels, newBullFail)
            while array.size(bullMismatchLabels) > maxMismatchLabels
                label.delete(array.shift(bullMismatchLabels))
        lastBullMismatchBar := bar_index
        bullMismatchArmed := false

    net := totalBuyEst - totalSellEst
    netPct := (totalBuyEst + totalSellEst) > 0 ? net / (totalBuyEst + totalSellEst) * 100.0 : na

    pressureStateRaw := "NA"
    bool isBalanced    = not na(netPct) and netPct > -neutralBandPct and netPct < neutralBandPct
    bool isBull        = not na(netPct) and netPct >= bullPressurePct and netPct < strongPressurePct
    bool isStrongBull  = not na(netPct) and netPct >= strongPressurePct
    bool isBear        = not na(netPct) and netPct <= -bullPressurePct and netPct > -strongPressurePct
    bool isStrongBear  = not na(netPct) and netPct <= -strongPressurePct
    bool isTransition  = not na(netPct) and not isBalanced and not isBull and not isStrongBull and not isBear and not isStrongBear

    if isStrongBull
        pressureStateRaw := "STRONG BULL"
    else if isBull
        pressureStateRaw := "BULL"
    else if isStrongBear
        pressureStateRaw := "STRONG BEAR"
    else if isBear
        pressureStateRaw := "BEAR"
    else if isBalanced
        pressureStateRaw := "BALANCED"
    else if isTransition
        pressureStateRaw := "TRANSITION"

    int activeRowCount = 0
    for cr = 0 to rows - 1
        if array.get(rowTot, cr) > 0
            activeRowCount += 1

    pocDominancePct := totalVolAll > 0 ? maxRowTot / totalVolAll * 100.0 : na
    float activeRowsPct = rows > 0 ? activeRowCount / rows * 100.0 : 0.0
    float pressureConf = not na(netPct) and strongPressurePct > 0 ? f_clamp(math.abs(netPct) / strongPressurePct * 25.0, 0.0, 25.0) : 0.0
    float pocConf = not na(pocDominancePct) ? f_clamp(pocDominancePct * 1.2, 0.0, 20.0) : 0.0
    float clusterConf = (not na(topBuyClusterScore) or not na(topSellClusterScore)) ? 20.0 : 5.0
    float rowConf = activeRowsPct >= 35 ? 15.0 : activeRowsPct >= 20 ? 10.0 : 5.0
    float ltfConf = useLTFReconstruction ? (ltfAvailable ? 20.0 : 6.0) : 10.0
    confidenceScore := f_clamp(pressureConf + pocConf + clusterConf + rowConf + ltfConf, 0.0, 100.0)

    pocVwmpState := na(pocPrice) or na(vwmpPrice) ? "N/A" :
         close > pocPrice and close > vwmpPrice ? "Bull Acceptance" :
         close < pocPrice and close < vwmpPrice ? "Bear Acceptance" :
         pocPrice > vwmpPrice ? "Top Heavy" :
         pocPrice < vwmpPrice ? "Bottom Heavy" :
         "Balance"

    pocMigrationState := na(priorTrackedPOC) ? "New" :
         pocPrice > priorTrackedPOC + rowH * 0.25 ? "POC Up" :
         pocPrice < priorTrackedPOC - rowH * 0.25 ? "POC Down" :
         "POC Flat"
    priorTrackedPOC := pocPrice

    performanceWarningNow := showPerformanceWarning and (rows > perfWarnRows or lookbackBars > perfWarnBars or useLTFReconstruction)

lowNetBarColor := showLowNetDeltaSignal and not na(netPct) and math.abs(netPct) <= lowNetDeltaThreshPct ? (close >= open ? lowNetBullColor : lowNetBearColor) : na

structureScore := na
flowScore := na

if showStats and not na(pocPrice) and not na(vwmpPrice)
    structureScore := 0.0
    structureScore += close > pocPrice ? 1.0 : close < pocPrice ? -1.0 : 0.0
    structureScore += close > vwmpPrice ? 1.0 : close < vwmpPrice ? -1.0 : 0.0

    string structureState =
         structureScore >= 2.0 ? "BULL" :
         structureScore <= -2.0 ? "BEAR" :
         "BALANCED"

    flowScore := 0.0
    flowScore += netPct > biasThreshPct ? 1.0 : netPct < -biasThreshPct ? -1.0 : 0.0
    flowScore += not na(topBuyClusterScore) and (na(topSellClusterScore) or topBuyClusterScore > topSellClusterScore) ? (topBuyClusterScore >= 60 ? 1.0 : 0.5) : 0.0
    flowScore += not na(topSellClusterScore) and (na(topBuyClusterScore) or topSellClusterScore > topBuyClusterScore) ? (topSellClusterScore >= 60 ? -1.0 : -0.5) : 0.0

    string flowState =
         flowScore >= 1.5 ? "STRONG BUY" :
         flowScore >= 0.5 ? "BUY" :
         flowScore <= -1.5 ? "STRONG SELL" :
         flowScore <= -0.5 ? "SELL" :
         "NEUTRAL"

    float biasScore = structureScore + flowScore

    string bias =
         biasScore >= 2.5 ? "STRONG BULL" :
         biasScore >= 1.0 ? "BULL" :
         biasScore <= -2.5 ? "STRONG BEAR" :
         biasScore <= -1.0 ? "BEAR" :
         "NEUTRAL"

    string lblLookback  = f_dashLabel("Lookback", "Bars", dashboardCompact)
    string lblBuy       = f_dashLabel("Buy (est)", "Buy", dashboardCompact)
    string lblSell      = f_dashLabel("Sell (est)", "Sell", dashboardCompact)
    string lblNet       = f_dashLabel("Net Δ (est)", "Net Δ", dashboardCompact)
    string lblPOC       = "POC"
    string lblVWMP      = "VWMP"
    string lblPressure  = f_dashLabel("Pressure", "Press", dashboardCompact)
    string lblStructure = f_dashLabel("Structure", "Struct", dashboardCompact)
    string lblFlow      = "Flow"
    string lblBias      = "Bias"

    table.clear(statsTable, 0, 0, 1, 16)

    table.cell(statsTable, 0, 0, lblLookback, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 0, str.tostring(barsUsed), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashboardTextSize)

    table.cell(statsTable, 0, 1, lblBuy, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 1, str.tostring(totalBuyEst, format.volume), text_color=f_buySellText(totalBuyEst, totalSellEst), bgcolor=f_buySellBg(totalBuyEst, totalSellEst), text_size=dashboardTextSize)

    table.cell(statsTable, 0, 2, lblSell, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 2, str.tostring(totalSellEst, format.volume), text_color=f_buySellText(totalBuyEst, totalSellEst), bgcolor=f_buySellBg(totalBuyEst, totalSellEst), text_size=dashboardTextSize)

    table.cell(statsTable, 0, 3, lblNet, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 3, str.tostring(net, format.volume) + " (" + str.tostring(netPct, "#.1") + "%)", text_color=f_netDeltaText(netPct, neutralBandPct, bullPressurePct, strongPressurePct), bgcolor=f_netDeltaBg(netPct, neutralBandPct, bullPressurePct, strongPressurePct), text_size=dashboardTextSize)

    table.cell(statsTable, 0, 4, lblPressure, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 4, showPressureInPanel ? pressureStateRaw : "OFF",
         text_color=showPressureInPanel ? f_stateText(pressureStateRaw) : color.white,
         bgcolor=showPressureInPanel ? f_stateBg(pressureStateRaw) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    string histPressureState = f_netDeltaState(netPctHist, neutralBandPct, bullPressurePct, strongPressurePct)

    table.cell(statsTable, 0, 5, "Hist Pressure", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 5, histPressureState,
         text_color=f_stateText(histPressureState),
         bgcolor=f_stateBg(histPressureState),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 6, "Live Pressure", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 6, pressureStateRaw,
         text_color=f_stateText(pressureStateRaw),
         bgcolor=f_stateBg(pressureStateRaw),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 7, lblStructure, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 7, showStructureFlow ? structureState : "OFF",
         text_color=showStructureFlow ? f_structureText(structureScore) : color.white,
         bgcolor=showStructureFlow ? f_structureBg(structureScore) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 8, lblFlow, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 8, showStructureFlow ? flowState : "OFF",
         text_color=showStructureFlow ? f_stateText(flowState) : color.white,
         bgcolor=showStructureFlow ? f_stateBg(flowState) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 9, lblBias, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 9, bias,
         text_color=f_stateText(bias),
         bgcolor=f_stateBg(bias),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 10, "Confidence", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 10, showConfidenceScore and not na(confidenceScore) ? str.tostring(confidenceScore, "#.0") + "/100" : "OFF",
         text_color=showConfidenceScore and not na(confidenceScore) ? f_confidenceText(confidenceScore) : color.white,
         bgcolor=showConfidenceScore and not na(confidenceScore) ? f_confidenceBg(confidenceScore) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 11, "POC Move", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 11, showPOCContext ? pocMigrationState : "OFF",
         text_color=f_stateText(pocMigrationState),
         bgcolor=showPOCContext ? f_contextBg(pocMigrationState) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 12, "POC/VWMP", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 12, showPOCContext ? pocVwmpState : "OFF",
         text_color=f_stateText(pocVwmpState),
         bgcolor=showPOCContext ? f_contextBg(pocVwmpState) : color.new(color.black, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 13, "POC Dom", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 13, na(pocDominancePct) ? "N/A" : str.tostring(pocDominancePct, "#.1") + "%",
         text_color=color.white,
         bgcolor=na(pocDominancePct) ? color.new(color.black, 20) : pocDominancePct >= 20 ? color.new(color.orange, 10) : color.new(color.gray, 35),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 14, "Model", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 14, showModelNote ? modelNoteText : "OFF", text_color=color.white, bgcolor=color.new(color.gray, 35), text_size=dashboardTextSize)

    table.cell(statsTable, 0, 15, "Perf", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 15, performanceWarningNow ? "HEAVY" : "OK",
         text_color=performanceWarningNow ? color.white : color.black,
         bgcolor=performanceWarningNow ? color.new(color.red, 0) : color.new(color.lime, 20),
         text_size=dashboardTextSize)

    table.cell(statsTable, 0, 16, "Signals", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=dashboardTextSize)
    table.cell(statsTable, 1, 16, confirmSignalsOnClose ? "Close Only" : "Realtime", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashboardTextSize)
else
    table.clear(statsTable, 0, 0, 1, 16)

//────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────
alertcondition(bullAbsFireOut, "Bullish Absorption", "Bullish absorption detected near sell-dominant profile structure.")
alertcondition(bearAbsFireOut, "Bearish Absorption", "Bearish absorption detected near buy-dominant profile structure.")
alertcondition(bullReclaimFireOut, "Bull Reclaim", "Price reclaimed a sell-dominant cluster.")
alertcondition(bearRejectFireOut, "Bear Reject", "Price rejected from a buy-dominant cluster.")
alertcondition(bearPressureFailureFireOut, "Bear Pressure Failure", "Strong estimated bear pressure failed structurally.")
alertcondition(bullPressureFailureFireOut, "Bull Pressure Failure", "Strong estimated bull pressure failed structurally.")
alertcondition(bullFlipOut, "Estimated Net Delta Bull Flip", "Estimated net delta flipped from negative to positive.")
alertcondition(bearFlipOut, "Estimated Net Delta Bear Flip", "Estimated net delta flipped from positive to negative.")
alertcondition(strongBullPressureOut, "Strong Bull Pressure", "Estimated pressure entered strong bull state.")
alertcondition(strongBearPressureOut, "Strong Bear Pressure", "Estimated pressure entered strong bear state.")
alertcondition(not na(confidenceScore) and confidenceScore < 35 and signalConfirmOK, "Low Confidence Pressure Reading", "Estimated pressure confidence is low; profile may be thin, fragmented, or unstable.")

//────────────────────────────────────────────
// FINAL BAR COLOR
//────────────────────────────────────────────
color finalBarColor = not na(lowNetBarColor) ? lowNetBarColor : histFinalBarColor
barcolor(finalBarColor)
````
