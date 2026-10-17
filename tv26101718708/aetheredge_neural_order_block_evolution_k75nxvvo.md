# AetherEdge Neural Order Block Evolution

- url: https://www.tradingview.com/script/K75NxVvO/
- type: indicator
- pine_id: PUB;b2e823034d644d4696fe74230dbdbda1
- version: 1.0

## Description

🖊️ Overview
AetherEdge Neural Order Block Evolution is a next-generation ICT/SMT tool that auto-detects institutional order blocks (OBs) and isolates only "elite OBs" through neural-network-style weighted scoring. Four core features — volume anomaly, liquidity sweeps, MTF consensus, and displacement — are aggregated via sigmoid activation, ruthlessly eliminating noise OBs and rendering only the true zones defended by smart money. This is the ultimate order block engine that visualizes institutional footprints with AI precision.

🔶 Key Features

Swing Pivot Detection: High-precision displacement-based OB identification
Neural Quality Score: 4-feature × weighted × sigmoid aggregation
Volume Anomaly Detection: Z-score-based abnormal volume scoring
Liquidity Score: Cluster detection + liquidity sweep recognition
MTF Consensus System: 3-timeframe trend bias integration
Displacement Score: ATR-based impulse strength evaluation
Elite OB Highlighting: Top-scored OBs marked with gold border
Lifecycle Management: Mitigated OBs preserved as history
Proximity Highlighting: Visual emphasis when price approaches OB
Stats Panel: Tracks created / broken / respected counts

🧠 Technical Architecture

This indicator is a neural evaluation engine designed to "decode institutional intent."

OB Detection: After swingLen pivot detection, scans within obLookback for the Last Up/Down Candle. Only candidates with displacement ≥ displaceMult × ATR qualify as OBs.
Volume Anomaly Score: Volume at OB formation Z-scored against 20-bar mean/std, then sigmoid-normalized to 0–1. Abnormal volume = institutional footprint.
Liquidity Score: Counts price clusters near OB level over 30 bars (liquidity pool detection) + identifies liquidity sweep patterns (e.g., sharp reversal after low sweep).
MTF Consensus: Retrieves close > EMA21 bias from mtf1/mtf2/mtf3. Aggregated with weights 1.0/1.2/1.5 (higher TF prioritized) and sigmoid-converted.
Displacement Score: Displacement size normalized by ATR, excess over displaceMult threshold sigmoid-mapped.
Neural Aggregation: Linear combination of 4 scores via wVolume / wLiquidity / wMTF / wDisplace yields final quality score. OBs below qualityMin are excluded.
Lifecycle: Break detected via mitigationMode (Wick / Close) and breakBuf × ATR. With keepBroken, OBs migrate to historyOBs and persist for historyBars.
Stats Tracking: totalCreated / Broken / Respects metrics for performance visualization.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): swingLen=5, displaceMult=1.5, qualityMin=0.55, MTF=4H/D/W
ETH (1H): swingLen=4, displaceMult=1.3, qualityMin=0.50, MTF=1H/4H/D
SOL/XRP (15M): swingLen=3, displaceMult=1.2, qualityMin=0.45, MTF=15M/1H/4H
Long-Term (1D): swingLen=8, displaceMult=2.0, qualityMin=0.60, MTF=D/W/M
Weight Tuning:

Trending markets: Raise wMTF=0.40, wDisplace=0.30
Range markets: Raise wLiquidity=0.40, wVolume=0.35
Elite-only display: qualityMin=0.70 + maxBlocks=4
Maximum visibility: qualityMin=0.40 + maxBlocks=12
Early detection: obLookback=20 for wider search
Strict mode: displaceMult=2.0 for only powerful displacements

💡 How to Use in Practice

Elite OB Reversal: Gold-bordered OBs are top-priority entry zones
MTF Consensus Play: High sMTF OBs align with the macro-trend fortress
Post-Sweep OB: High sLiq OBs form after institutional stop hunts — extremely strong zones
Mitigation Strategy: Trade the first touch of an unmitigated OB
History OB Analysis: Broken historic OBs are future support/resistance flip candidates
AetherEdge Combinations: When KNN Breakout Fortress strong walls overlap an OB → ironclad zone

⚠️ Important Notes

Too-small swingLen creates excessive, noisy OBs
MTF settings must be higher than the current chart timeframe
Liquidity score depends on the prior 30 bars — accuracy drops on early bars
sVol becomes unreliable on assets without volume data
Neural weights should sum to approximately 1.0 for balanced scoring

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. Neural scores and OB quality evaluations are based on historical data and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Neural Order Block Evolution", shorttitle="AE-NOBE", overlay=true, max_boxes_count=300, max_lines_count=100, max_labels_count=300)

// ============================================================
// ▼ INPUTS
// ============================================================
grpDet = "🔍 Order Block Detection"
swingLen     = input.int(5,    "Swing Pivot Length",  minval=2,   maxval=20,  group=grpDet)
obLookback   = input.int(15,   "OB Search Window",    minval=5,   maxval=50,  group=grpDet, tooltip="ピボットからこの範囲内で逆向きキャンドルを検索")
displaceMult = input.float(1.5,"Displacement × ATR",  minval=0.5, maxval=5.0, step=0.1, group=grpDet, tooltip="変位の最小サイズ（ATR倍率）")
maxBlocks    = input.int(8,    "Max Active Blocks",   minval=2,   maxval=20,  group=grpDet)

grpNN = "🧠 Neural Weighting"
wVolume    = input.float(0.30, "Volume Anomaly Weight", minval=0.0, maxval=1.0, step=0.05, group=grpNN)
wLiquidity = input.float(0.25, "Liquidity Weight",      minval=0.0, maxval=1.0, step=0.05, group=grpNN)
wMTF       = input.float(0.25, "MTF Consensus Weight",  minval=0.0, maxval=1.0, step=0.05, group=grpNN)
wDisplace  = input.float(0.20, "Displacement Weight",   minval=0.0, maxval=1.0, step=0.05, group=grpNN)
qualityMin = input.float(0.50, "Min Quality Score",     minval=0.0, maxval=1.0, step=0.05, group=grpNN, tooltip="このスコア未満のOBは描画しない")

grpMTF = "📊 Multi-Timeframe"
mtf1 = input.timeframe("60",  "MTF #1", group=grpMTF)
mtf2 = input.timeframe("240", "MTF #2", group=grpMTF)
mtf3 = input.timeframe("D",   "MTF #3", group=grpMTF)

grpLife = "♻️ Lifecycle & Mitigation"
mitigationMode = input.string("Wick", "Mitigation Mode", options=["Wick","Close"], group=grpLife)
breakBuf       = input.float(0.05, "Break Buffer × ATR", minval=0.0, maxval=1.0, step=0.05, group=grpLife)
extendRight    = input.int(80,    "Extend Right (bars)", minval=10, maxval=500, group=grpLife)
keepBroken     = input.bool(true, "Keep Broken as History", group=grpLife)
historyBars    = input.int(30,    "History Length",        minval=5, maxval=200, group=grpLife)

grpVis = "🎨 Visuals"
bullColor    = input.color(color.rgb(60,  220, 150), "Bullish OB",      group=grpVis)
bearColor    = input.color(color.rgb(240, 90,  130), "Bearish OB",      group=grpVis)
eliteColor   = input.color(color.rgb(255, 215, 0),   "Elite OB Border", group=grpVis)
showScores   = input.bool(true,  "Show Quality Scores",     group=grpVis)
showMidline  = input.bool(true,  "Show OB Midlines",        group=grpVis)
showStats    = input.bool(true,  "Show Stats Panel",        group=grpVis)
proximityATR = input.float(2.0,  "Proximity Highlight ATR", minval=0.5, maxval=5.0, step=0.1, group=grpVis)

// ============================================================
// ▼ CONTEXT
// ============================================================
atrV    = ta.atr(14)
atrV50  = ta.atr(50)
volMA20 = ta.sma(volume, 20)
volStd  = ta.stdev(volume, 20)
emaF    = ta.ema(close, 21)
emaS    = ta.ema(close, 50)

// Pre-compute rolling extrema (cannot use variable length inside fn loops safely)
recentLow30  = ta.lowest(low, 30)
recentHigh30 = ta.highest(high, 30)

// MTF trend bias (close > EMA21 → bullish)
mtfBias1 = request.security(syminfo.tickerid, mtf1, close > ta.ema(close, 21) ? 1.0 : -1.0, lookahead=barmerge.lookahead_off)
mtfBias2 = request.security(syminfo.tickerid, mtf2, close > ta.ema(close, 21) ? 1.0 : -1.0, lookahead=barmerge.lookahead_off)
mtfBias3 = request.security(syminfo.tickerid, mtf3, close > ta.ema(close, 21) ? 1.0 : -1.0, lookahead=barmerge.lookahead_off)

// ============================================================
// ▼ TYPES
// ============================================================
type OB
    box     bx
    line    midLn
    label   lbl
    float   top
    float   bot
    float   mid
    bool    isBull
    int     created
    float   score
    float   sVol
    float   sLiq
    float   sMTF
    float   sDisp
    int     touchCount
    bool    broken
    int     breakBar
    box     histBox

// ============================================================
// ▼ STORAGE
// ============================================================
var array<OB> activeOBs  = array.new<OB>()
var array<OB> historyOBs = array.new<OB>()

var int   lastBullPivBar = na
var float lastBullPivVal = na
var int   lastBearPivBar = na
var float lastBearPivVal = na

var int totalCreated  = 0
var int totalBroken   = 0
var int totalRespects = 0

// ============================================================
// ▼ NEURAL ACTIVATION
// ============================================================
sigmoid(float x) =>
    1.0 / (1.0 + math.exp(-math.max(-15.0, math.min(15.0, x))))

// ============================================================
// ▼ FEATURE: VOLUME ANOMALY
// ============================================================
volumeAnomalyAt(int barsBack) =>
    v  = volume[barsBack]
    m  = volMA20[barsBack]
    sd = volStd[barsBack]
    z  = sd > 0 ? (v - m) / sd : 0.0
    sigmoid(z * 0.7)

// ============================================================
// ▼ FEATURE: LIQUIDITY
// ============================================================
liquidityScoreAt(int barsBack, float topL, float botL, bool isBull) =>
    int cluster = 0
    int look = 30
    for i = barsBack to barsBack + look
        if i >= 0 and i < bar_index
            ref    = isBull ? low[i]  : high[i]
            target = isBull ? botL    : topL
            if math.abs(ref - target) < atrV * 0.5
                cluster += 1

    float sweep = 0.0
    if isBull
        rl = recentLow30[barsBack]
        if low[barsBack] <= rl + atrV * 0.1 and close[barsBack] > low[barsBack] + (high[barsBack] - low[barsBack]) * 0.5
            sweep := 1.0
    else
        rh = recentHigh30[barsBack]
        if high[barsBack] >= rh - atrV * 0.1 and close[barsBack] < high[barsBack] - (high[barsBack] - low[barsBack]) * 0.5
            sweep := 1.0

    base = math.min(cluster / 8.0, 1.0)
    sigmoid((base * 1.5 + sweep * 1.2) - 1.0)

// ============================================================
// ▼ FEATURE: MTF CONSENSUS
// ============================================================
mtfConsensusScore(bool isBull) =>
    target = isBull ? 1.0 : -1.0
    float agree = 0.0
    if mtfBias1 == target
        agree += 1.0
    if mtfBias2 == target
        agree += 1.2
    if mtfBias3 == target
        agree += 1.5
    sigmoid(agree - 1.5)

// ============================================================
// ▼ FEATURE: DISPLACEMENT
// ============================================================
displacementScore(float disp) =>
    sigmoid((disp / math.max(atrV, 1e-10)) - displaceMult)

// ============================================================
// ▼ NEURAL AGGREGATION
// ============================================================
neuralScore(float sV, float sL, float sM, float sD) =>
    wTotal = wVolume + wLiquidity + wMTF + wDisplace
    raw    = sV * wVolume + sL * wLiquidity + sM * wMTF + sD * wDisplace
    wTotal > 0 ? raw / wTotal : 0.5

// ============================================================
// ▼ COLOR HELPERS
// ============================================================
obFillColor(bool isBull, float score, bool nearPrice) =>
    base = isBull ? bullColor : bearColor
    int qOpac = math.round(85 - score * 35)
    if nearPrice
        qOpac := math.max(qOpac - 15, 25)
    color.new(base, qOpac)

obBorderColor(float score, bool isBull) =>
    score >= 0.80 ? eliteColor : color.new(isBull ? bullColor : bearColor, 30)

// ============================================================
// ▼ PIVOT DETECTION
// ============================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

if not na(ph)
    lastBearPivBar := bar_index - swingLen
    lastBearPivVal := ph
if not na(pl)
    lastBullPivBar := bar_index - swingLen
    lastBullPivVal := pl

// ============================================================
// ▼ ORDER BLOCK FORMATION
// ============================================================
detectBullOB() =>
    bool  found = false
    int   obBar = 0
    float topV  = 0.0
    float botV  = 0.0
    float disp  = 0.0
    if not na(lastBearPivVal) and close > lastBearPivVal and close[1] <= lastBearPivVal
        for i = 1 to obLookback
            if close[i] < open[i]
                obBar := i
                topV  := math.max(open[i], high[i])
                botV  := math.min(close[i], low[i])
                topAfter = ta.highest(high, i)
                disp := topAfter - topV
                if disp > atrV * displaceMult
                    found := true
                    break
    [found, obBar, topV, botV, disp]

detectBearOB() =>
    bool  found = false
    int   obBar = 0
    float topV  = 0.0
    float botV  = 0.0
    float disp  = 0.0
    if not na(lastBullPivVal) and close < lastBullPivVal and close[1] >= lastBullPivVal
        for i = 1 to obLookback
            if close[i] > open[i]
                obBar := i
                topV  := math.max(close[i], high[i])
                botV  := math.min(open[i], low[i])
                botAfter = ta.lowest(low, i)
                disp := botV - botAfter
                if disp > atrV * displaceMult
                    found := true
                    break
    [found, obBar, topV, botV, disp]

// ============================================================
// ▼ DUPLICATE GUARD
// ============================================================
isDuplicateOB(float topV, float botV, bool isBull) =>
    bool dup = false
    if array.size(activeOBs) > 0
        for i = 0 to array.size(activeOBs) - 1
            o = array.get(activeOBs, i)
            if o.isBull == isBull and not o.broken
                overlap = math.min(o.top, topV) - math.max(o.bot, botV)
                obSize  = topV - botV
                if obSize > 0 and overlap / obSize > 0.5
                    dup := true
                    break
    dup

// ============================================================
// ▼ CREATE OB  (returns true if a block was actually drawn)
// ============================================================
createOB(bool isBull, int obBar, float topV, float botV, float disp) =>
    bool created = false
    sV = volumeAnomalyAt(obBar)
    sL = liquidityScoreAt(obBar, topV, botV, isBull)
    sM = mtfConsensusScore(isBull)
    sD = displacementScore(disp)
    score = neuralScore(sV, sL, sM, sD)

    if score >= qualityMin and not isDuplicateOB(topV, botV, isBull)
        mid       = (topV + botV) / 2.0
        nearPrice = math.abs(close - mid) < atrV * proximityATR
        fillC     = obFillColor(isBull, score, nearPrice)
        bordC     = obBorderColor(score, isBull)
        bw        = score >= 0.80 ? 2 : 1

        bx = box.new(bar_index - obBar, topV, bar_index + extendRight, botV, border_color=bordC, bgcolor=fillC, border_width=bw, extend=extend.none)

        line  midLn = na
        if showMidline
            midLn := line.new(bar_index - obBar, mid, bar_index + extendRight, mid, color=color.new(bordC, 40), style=line.style_dotted, width=1)

        label lbl = na
        if showScores
            tag = (score >= 0.80 ? "★ ELITE " : "") + (isBull ? "BULL OB" : "BEAR OB")
            txt = tag + " " + str.tostring(score, "0.00") +
                 "\nV:" + str.tostring(sV, "0.00") +
                 " L:" + str.tostring(sL, "0.00") +
                 " M:" + str.tostring(sM, "0.00") +
                 " D:" + str.tostring(sD, "0.00")
            lbl := label.new(bar_index + extendRight, mid, txt, color=color.new(bordC, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)

        box histBox = na
        ob = OB.new(bx, midLn, lbl, topV, botV, mid, isBull, bar_index, score, sV, sL, sM, sD, 0, false, 0, histBox)
        array.push(activeOBs, ob)
        created := true

        // Cap maximum active OBs (drop lowest score)
        while array.size(activeOBs) > maxBlocks
            int   worstIdx = 0
            float worstSc  = 1e9
            for i = 0 to array.size(activeOBs) - 1
                oo = array.get(activeOBs, i)
                if oo.score < worstSc
                    worstSc  := oo.score
                    worstIdx := i
            removed = array.get(activeOBs, worstIdx)
            box.delete(removed.bx)
            if not na(removed.midLn)
                line.delete(removed.midLn)
            if not na(removed.lbl)
                label.delete(removed.lbl)
            array.remove(activeOBs, worstIdx)
    created

// ============================================================
// ▼ RUN DETECTION (counters incremented in main scope)
// ============================================================
[bullF, bullBar, bullTop, bullBot, bullDisp] = detectBullOB()
if bullF
    if createOB(true, bullBar, bullTop, bullBot, bullDisp)
        totalCreated += 1

[bearF, bearBar, bearTop, bearBot, bearDisp] = detectBearOB()
if bearF
    if createOB(false, bearBar, bearTop, bearBot, bearDisp)
        totalCreated += 1

// ============================================================
// ▼ DYNAMIC PROXIMITY UPDATE
// ============================================================
if array.size(activeOBs) > 0
    for i = 0 to array.size(activeOBs) - 1
        o = array.get(activeOBs, i)
        if not o.broken
            nearPrice = math.abs(close - o.mid) < atrV * proximityATR
            touched   = low <= o.top and high >= o.bot
            if touched
                o.touchCount += 1
                totalRespects += 1

            fillC = obFillColor(o.isBull, o.score, nearPrice)
            box.set_bgcolor(o.bx, fillC)
            box.set_right(o.bx, bar_index + extendRight)
            if not na(o.midLn)
                line.set_x2(o.midLn, bar_index + extendRight)
            if not na(o.lbl)
                label.set_x(o.lbl, bar_index + extendRight)
                label.set_y(o.lbl, o.mid)

// ============================================================
// ▼ MITIGATION / BREAK CHECK
// ============================================================
if array.size(activeOBs) > 0
    int i = array.size(activeOBs) - 1
    while i >= 0
        o = array.get(activeOBs, i)
        priceRef = mitigationMode == "Close" ? close : (o.isBull ? low : high)
        bool broken = false
        if o.isBull and priceRef < o.bot - atrV * breakBuf
            broken := true
        if not o.isBull and priceRef > o.top + atrV * breakBuf
            broken := true

        if broken
            o.broken   := true
            o.breakBar := bar_index

            box.set_right(o.bx, bar_index)
            if not na(o.midLn)
                line.set_x2(o.midLn, bar_index)

            if keepBroken
                histC = color.new(o.isBull ? bullColor : bearColor, 88)
                histB = color.new(o.isBull ? bullColor : bearColor, 75)
                o.histBox := box.new(bar_index, o.top, bar_index + historyBars, o.bot, border_color=histB, bgcolor=histC, border_width=1, border_style=line.style_dashed)
                array.push(historyOBs, o)
            else
                box.delete(o.bx)
                if not na(o.midLn)
                    line.delete(o.midLn)

            // Always remove the live tracker label when broken
            if not na(o.lbl)
                label.delete(o.lbl)

            arrowY     = o.isBull ? o.bot - atrV * 0.5 : o.top + atrV * 0.5
            arrowStyle = o.isBull ? label.style_label_up : label.style_label_down
            arrowCol   = o.isBull ? bearColor : bullColor
            label.new(bar_index, arrowY, "✕", color=color.new(arrowCol, 20), textcolor=color.white, style=arrowStyle, size=size.small)

            totalBroken += 1
            array.remove(activeOBs, i)
        i := i - 1

// ============================================================
// ▼ HISTORY CLEANUP
// ============================================================
while array.size(historyOBs) > 20
    old = array.shift(historyOBs)
    if not na(old.histBox)
        box.delete(old.histBox)
    if not na(old.bx)
        box.delete(old.bx)

// ============================================================
// ▼ ALERTS
// ============================================================
var bool fireBullCreate = false
var bool fireBearCreate = false
fireBullCreate := bullF
fireBearCreate := bearF

alertcondition(fireBullCreate, title="AE-NOBE → New Bullish OB", message="AE-NOBE: Quality Bullish Order Block formed")
alertcondition(fireBearCreate, title="AE-NOBE → New Bearish OB", message="AE-NOBE: Quality Bearish Order Block formed")

bool nearAny = false
if array.size(activeOBs) > 0
    for i = 0 to array.size(activeOBs) - 1
        o = array.get(activeOBs, i)
        if not o.broken and math.abs(close - o.mid) < atrV * 0.5
            nearAny := true
            break
alertcondition(nearAny, title="AE-NOBE → Price Approaching OB", message="AE-NOBE: Price entering active OB zone")

// ============================================================
// ▼ STATS PANEL
// ============================================================
var table dash = table.new(position.top_right, 2, 8, border_width=1)
if showStats and barstate.islast
    bgC      = color.new(color.black, 75)
    txC      = color.white
    actCount = array.size(activeOBs)
    int   eliteCount = 0
    float avgScore   = 0.0
    if actCount > 0
        for i = 0 to actCount - 1
            o = array.get(activeOBs, i)
            avgScore += o.score
            if o.score >= 0.80
                eliteCount += 1
        avgScore := avgScore / actCount

    respectRate = (totalBroken + totalRespects) > 0 ? totalRespects * 100.0 / (totalBroken + totalRespects) : 0.0

    table.cell(dash, 0, 0, "🧠 NEURAL OB", bgcolor=color.new(eliteColor, 40), text_color=color.black, text_size=size.normal)
    table.cell(dash, 1, 0, "v1.0",         bgcolor=color.new(eliteColor, 40), text_color=color.black, text_size=size.small)

    table.cell(dash, 0, 1, "Active OBs", bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(actCount) + "/" + str.tostring(maxBlocks), bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 2, "★ Elite",                     bgcolor=bgC, text_color=color.new(eliteColor, 0), text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(eliteCount),      bgcolor=bgC, text_color=color.new(eliteColor, 0), text_size=size.small)

    table.cell(dash, 0, 3, "Avg Score",                   bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(avgScore, "0.00"),bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 4, "Total Created",               bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(totalCreated),    bgcolor=bgC, text_color=txC, text_size=size.small)

    table.cell(dash, 0, 5, "Broken",                      bgcolor=bgC, text_color=color.new(bearColor,0), text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(totalBroken),     bgcolor=bgC, text_color=color.new(bearColor,0), text_size=size.small)

    table.cell(dash, 0, 6, "Respects",                    bgcolor=bgC, text_color=color.new(bullColor,0), text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(totalRespects),   bgcolor=bgC, text_color=color.new(bullColor,0), text_size=size.small)

    table.cell(dash, 0, 7, "Respect %",                                              bgcolor=bgC, text_color=txC, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(respectRate, "0.0") + "%",                   bgcolor=bgC, text_color=txC, text_size=size.small)

plot(array.size(activeOBs),  title="Active OBs",  display=display.data_window)
plot(array.size(historyOBs), title="History OBs", display=display.data_window)
````
