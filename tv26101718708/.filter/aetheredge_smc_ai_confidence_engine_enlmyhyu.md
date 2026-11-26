# AetherEdge SMC AI Confidence Engine

- url: https://www.tradingview.com/script/enLmyhYu/
- type: indicator
- pine_id: PUB;c98774e8964e4db597b68a97a8d877bc
- version: 1.0

## Description

🖊️ Overview
AetherEdge SMC AI Confidence Engine is a next-generation SMC engine fusing Smart Money Concepts—the language of institutional footprints—with 8-factor AI confidence scoring and kNN pattern matching. It auto-detects the three pillars of smart-money zones (Order Blocks, Fair Value Gaps, Liquidity Sweeps) and instantly delivers an A+ to D conviction grade by integrating eight weighted factors: structure integrity, displacement, volume, MTF consensus, kNN similarity, imbalance, freshness, and confluence. A data-driven SMC intelligence that answers the eternal question: "Which zone is real?"

🔶 Key Features

3 Core SMC Zone Detection: Order Block / Fair Value Gap / Liquidity Sweep
8-Factor AI Scoring: Structure / Displacement / Volume / MTF / kNN / Imbalance / Freshness / Confluence
kNN Pattern Matching: 5-D feature space, K-nearest historical analogs
A+/A/B/C/D Grades: Intuitive five-tier conviction ranking
3-Layer MTF Consensus: 1H / 4H / D triple confirmation
BOS/CHoCH Detection: Auto-identifies structural breaks
Mitigation Tracking: Records zone-touch events; Fresh/Mitigated state
Confluence Detection: Auto-bonuses overlapping zones
Dynamic Visualization: Transparency, border & size scale with score
Top-Zone Detail Panel: Full 8-factor breakdown with bar visualization
Ranking Table: Up to 10 zones sorted by composite score
Custom Weights: Tune all 8 factors to fit your trading style

🧠 Technical Architecture

This indicator elevates SMC theory into a statistical / machine-learning framework, delivering industry-leading smart-money intelligence.

Zone Detection Logic:
Order Block: Strong displacement (ATR×1.5+) + volume Z>0.5 + BOS triggers backward scan to last opposite-colored candle
FVG: 3-bar gap exceeding ATR × fvgMinSize
Liquidity Sweep: Recent swing pierced by sweepTol × ATR then reversal close
8-Factor Scoring (each normalized 0–100):
Structure Integrity — trend alignment + BOS bonus
Displacement Strength — birth-time displacement magnitude
Volume Profile — birth-time volume Z-score
MTF Consensus — sum of 3 HTF EMA20/50 slopes (–3 to +3)
kNN Pattern Match — 5-D feature K-NN average forward magnitude
Imbalance Ratio — zone size ÷ ATR
Freshness/Age — exp(-age/150) decay, –30 if mitigated
Confluence Score — bonus per overlapping zone
kNN Engine:
Features: displacement / volZ / bodyRatio / atrRatio / rangeRatio
300-bar history buffer, K=5 nearest by Euclidean distance
Average 5-bar-forward absolute move scored probabilistically
Weighted Composite: composite = Σ(factor_i × weight_i) / Σweights
Dynamic Update: All active zones rescored every confirmed bar
Grade Mapping: ≥85=A+, ≥75=A, ≥65=B, ≥50=C, <50=D
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–D): Pivot=5, OBLookback=50, MTF=4H/D/W
ETH (1H–4H): Pivot=5, fvgMinSize=0.3, MTF=1H/4H/D (standard)
SOL (high-vol): Pivot=7, sweepTol=0.15, fvgMinSize=0.4
XRP (short-swing): Pivot=3, OBLookback=30, MTF=15M/1H/4H
Pivot Length (structure sensitivity):

3: agile, noisy
5: standard
7–10: major-structure only, HTF use
FVG Min Size:

0.2: catch fine gaps
0.3: standard
0.5: strong FVGs only
Weight Tuning by Style:

Trend Follower: Structure↑, MTF↑, Displacement↑
Counter-Trader: kNN↑, Freshness↑, Imbalance↑
Scalper: Volume↑, Displacement↑, Freshness↑
Swing Trader: MTF↑, Confluence↑, Structure↑
Min Score Display:

40: standard (hide D)
65: B+ only, clean view
75: A+ only, ultra-curated
kNN Config:

K=3: sharp similarity, unstable
K=5: standard
K=10–15: smooth, averaged

💡 How to Use in Practice

A+ Zones (≥85%): Gold-bordered ultimate-conviction zones, primary thesis
A Zones (75–85%): High quality, multi-factor agreement, entry candidates
B Zones (65–75%): Reference level, combine with other evidence
C/D (<65%): Information only, generally ignore
Fresh + A+: Untouched apex zone, optimal ambush
Mitigated + High Score: Past battlefield, high re-test reaction probability
Confluence Areas: OB + FVG + Sweep overlap = institutional decision zones
Trade Scenarios:
Bull OB A+ + MTF Strong Bull: Golden pullback long
Bear FVG A + Liquidity Sweep up-pierce: Short opportunity
BOS Up + Recent A+ Zone: Trend-confirmation entry
AetherEdge Synergy:
Self-Evolving S/R Grid: A+ zone + strong S/R line overlap = ultimate alignment
LSTM Forecaster: Bullish prediction + Bull OB A+ = dual AI conviction
NeuraNet Predictor: Direction match + zone reach = high-probability entry
All-in-One Dashboard: HIGH-CONVICTION + A+ zone = supreme alignment
Multi-TF Workflow: Identify A+ zones on D/4H → precise entry on 1H/15M

⚠️ Important Notes

kNN Warm-up: <300 bars yields unstable similarity, fixed 50-score
Zone Cap: Oldest zones auto-pruned beyond maxZones
Weight Normalization: Auto-normalized regardless of total—relative influence
MTF Lag: HTF references confirmed bars; first few bars unfinalized
Detection Delay: Pivots confirm pivotlen bars later; real-time slight delay
Zone Overlap: Same OB may be detected multiple times—use as confluence signal

🚨 Disclaimer

This indicator is an SMC analysis support tool provided for educational and research purposes only and does not constitute financial advice. AI confidence scores are probabilistic indicators based on mathematical approximation and do not guarantee future profits. Scores are one input among many—combine with independent analysis and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge SMC AI Confidence Engine", "AE-SMC-AI",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=500,
     max_bars_back=1000)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpD = "🎯 Detection Config"
pivLen        = input.int(5, "Pivot Length", minval=2, maxval=15, group=grpD,
     tooltip="Swing high/low lookback for structure detection.")
obLookback    = input.int(50, "OB Search Window", minval=10, maxval=200, group=grpD)
fvgMinSize    = input.float(0.3, "FVG Min Size (ATR×)", minval=0.1, step=0.1, group=grpD,
     tooltip="Minimum FVG size as multiple of ATR to filter noise.")
sweepTol      = input.float(0.1, "Sweep Tolerance (ATR×)", minval=0.0, step=0.05, group=grpD)
maxZones      = input.int(15, "Max Active Zones", minval=5, maxval=30, group=grpD)

grpS = "🧠 AI Scoring Weights"
wStruct       = input.float(15.0, "Structure Integrity",  minval=0, maxval=30, step=1, group=grpS)
wDisplace     = input.float(15.0, "Displacement Strength", minval=0, maxval=30, step=1, group=grpS)
wVolume       = input.float(12.0, "Volume Profile",       minval=0, maxval=30, step=1, group=grpS)
wMTF          = input.float(12.0, "MTF Consensus",        minval=0, maxval=30, step=1, group=grpS)
wKNN          = input.float(12.0, "kNN Pattern Match",    minval=0, maxval=30, step=1, group=grpS)
wImbalance    = input.float(10.0, "Imbalance Ratio",      minval=0, maxval=30, step=1, group=grpS)
wFreshness    = input.float(12.0, "Freshness/Age",        minval=0, maxval=30, step=1, group=grpS)
wConfluence   = input.float(12.0, "Confluence Score",     minval=0, maxval=30, step=1, group=grpS)

grpM = "🔭 Multi-Timeframe"
mtf1          = input.timeframe("60",  "MTF Level 1", group=grpM)
mtf2          = input.timeframe("240", "MTF Level 2", group=grpM)
mtf3          = input.timeframe("D",   "MTF Level 3", group=grpM)

grpK = "🔍 kNN Config"
knnK          = input.int(5, "K Neighbors", minval=3, maxval=15, group=grpK)
knnLookback   = input.int(300, "History Window", minval=100, maxval=1000, group=grpK)
knnFeatures   = input.int(5, "Feature Dims", minval=3, maxval=8, group=grpK)

grpF = "🎨 Display"
darkMode         = input.bool(true,  "Dark Mode", group=grpF)
showOB           = input.bool(true,  "Show Order Blocks", group=grpF)
showFVG          = input.bool(true,  "Show Fair Value Gaps", group=grpF)
showSweep        = input.bool(true,  "Show Liquidity Sweeps", group=grpF)
showScores       = input.bool(true,  "Show Score Labels", group=grpF)
showGrade        = input.bool(true,  "Show Grade Badges", group=grpF)
minScoreDisplay  = input.int(40, "Hide Zones Below Score", minval=0, maxval=100, group=grpF)
extendZones      = input.bool(true,  "Extend Active Zones Right", group=grpF)
showDashboard    = input.bool(true,  "Show Dashboard", group=grpF)
showZoneTable    = input.bool(true,  "Show Top Zones Table", group=grpF)
dashPos          = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpF)
zTablePos        = input.string("Bottom Right", "Zones Table Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpF)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg       = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt    = darkMode ? color.new(#111a2e, 10) : color.new(#ffffff, 0)
cBgRow    = darkMode ? color.new(#0f172a, 0)  : color.new(#f8fafc, 0)
cBorder   = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText     = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute     = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent   = color.new(#00d4ff, 0)
cBull     = color.new(#00d4a0, 0)
cBear     = color.new(#ff5577, 0)
cWarn     = color.new(#ffa500, 0)
cPurple   = color.new(#c084fc, 0)
cGold     = color.new(#fde047, 0)

// Zone type colors
cOBBull   = color.new(#00d4a0, 70)
cOBBear   = color.new(#ff5577, 70)
cFVGBull  = color.new(#60a5fa, 75)
cFVGBear  = color.new(#f472b6, 75)
cSweepUp  = color.new(#c084fc, 60)
cSweepDn  = color.new(#fde047, 60)

// ═══════════════════════════════════════════════════════════════
//  TOP-LEVEL HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════
f_gradeColor(s) =>
    s >= 85 ? color.new(#00ff88, 0) :
     s >= 75 ? color.new(#00d4a0, 0) :
     s >= 65 ? color.new(#60a5fa, 0) :
     s >= 50 ? color.new(#ffa500, 0) :
               color.new(#ff5577, 0)

f_gradeLetter(s) =>
    s >= 85 ? "A+" : s >= 75 ? "A" : s >= 65 ? "B" : s >= 50 ? "C" : "D"

f_posHelper(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_zoneTypeName(t) =>
    t == 1 ? "Bull OB" :
     t == 2 ? "Bear OB" :
     t == 3 ? "Bull FVG" :
     t == 4 ? "Bear FVG" :
     t == 5 ? "Sweep Hi" : "Sweep Lo"

f_zoneTypeShort(t) =>
    t == 1 ? "OB↑" :
     t == 2 ? "OB↓" :
     t == 3 ? "FVG↑" :
     t == 4 ? "FVG↓" :
     t == 5 ? "SW↑" : "SW↓"

f_zoneColor(t) =>
    t == 1 ? cOBBull :
     t == 2 ? cOBBear :
     t == 3 ? cFVGBull :
     t == 4 ? cFVGBear :
     t == 5 ? cSweepUp : cSweepDn

// ── FIX: moved from inside if-block to top level ──
f_scoreBar(v) =>
    nB = math.min(10, math.round(v / 10.0))
    s = ""
    for b = 0 to 9
        s := s + (b < nB ? "▰" : "▱")
    s

// ── FIX: Pine Script の str.tostring() は "正;負" の2部構成までしかサポートしない
//         "+#;-#;0" のような3部構成は無効なため、ゼロは分岐で処理
f_signedStr(v) =>
    v == 0 ? "0" : str.tostring(v, "+#;-#")

// ═══════════════════════════════════════════════════════════════
//  BASE INDICATORS
// ═══════════════════════════════════════════════════════════════
atrV   = ta.atr(14)
atrLong= ta.atr(50)
volMA  = ta.sma(volume, 20)
volStd = ta.stdev(volume, 20) + 1e-9
volZ   = (volume - volMA) / volStd

bodySize  = math.abs(close - open)
rangeSize = high - low
displacement = bodySize / (atrV + 1e-9)

// Market structure via pivots
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)

var float lastPH = na
var float lastPL = na
var int   lastPHBar = 0
var int   lastPLBar = 0
if not na(ph)
    lastPH := ph
    lastPHBar := bar_index - pivLen
if not na(pl)
    lastPL := pl
    lastPLBar := bar_index - pivLen

// BOS / CHoCH detection
var int trendDir = 0
bosUp = close > lastPH and close[1] <= lastPH
bosDn = close < lastPL and close[1] >= lastPL
if bosUp
    trendDir := 1
if bosDn
    trendDir := -1

// MTF trend proxy
htfTrend1 = request.security(syminfo.tickerid, mtf1, math.sign(ta.ema(close, 20) - ta.ema(close, 50)), lookahead=barmerge.lookahead_off)
htfTrend2 = request.security(syminfo.tickerid, mtf2, math.sign(ta.ema(close, 20) - ta.ema(close, 50)), lookahead=barmerge.lookahead_off)
htfTrend3 = request.security(syminfo.tickerid, mtf3, math.sign(ta.ema(close, 20) - ta.ema(close, 50)), lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════
//  ZONE STORAGE
// ═══════════════════════════════════════════════════════════════
var array<int>   zType     = array.new<int>(0)
var array<float> zTop      = array.new<float>(0)
var array<float> zBot      = array.new<float>(0)
var array<int>   zStartBar = array.new<int>(0)
var array<float> zScore    = array.new<float>(0)
var array<float> zVolAtBirth = array.new<float>(0)
var array<float> zDispAtBirth= array.new<float>(0)
var array<int>   zMtfAlign = array.new<int>(0)
var array<bool>  zMitigated = array.new<bool>(0)
var array<box>   zBoxes    = array.new<box>(0)
var array<label> zLabels   = array.new<label>(0)

// ═══════════════════════════════════════════════════════════════
//  kNN PATTERN SIMILARITY ENGINE
// ═══════════════════════════════════════════════════════════════
var array<float> histFeat = array.new<float>(0)
var array<float> histOutcome = array.new<float>(0)

NF_KNN = 5

bodyRatio  = bodySize / (rangeSize + 1e-9)
atrRatio   = atrV / atrLong
rangeRatio = rangeSize / (atrV + 1e-9)

if barstate.isconfirmed
    array.push(histFeat, displacement)
    array.push(histFeat, volZ)
    array.push(histFeat, bodyRatio)
    array.push(histFeat, atrRatio)
    array.push(histFeat, rangeRatio)
    fwdMove = bar_index >= 5 ? math.abs(close - close[5]) / (atrV + 1e-9) : 0.0
    array.push(histOutcome, fwdMove)

    while array.size(histOutcome) > knnLookback
        array.shift(histOutcome)
        for d = 0 to NF_KNN - 1
            array.shift(histFeat)

f_knnScore(disp, vz, br, ar, rr) =>
    nRec = array.size(histOutcome)
    if nRec < knnK * 2
        50.0
    else
        dists = array.new<float>(0)
        outs  = array.new<float>(0)
        for i = 0 to nRec - 1
            d0 = disp - array.get(histFeat, i * NF_KNN + 0)
            d1 = vz   - array.get(histFeat, i * NF_KNN + 1)
            d2 = br   - array.get(histFeat, i * NF_KNN + 2)
            d3 = ar   - array.get(histFeat, i * NF_KNN + 3)
            d4 = rr   - array.get(histFeat, i * NF_KNN + 4)
            dd = math.sqrt(d0*d0 + d1*d1 + d2*d2 + d3*d3 + d4*d4)
            array.push(dists, dd)
            array.push(outs, array.get(histOutcome, i))

        selected = array.new<float>(0)
        kActual = math.min(knnK, array.size(dists))
        for pick = 0 to kActual - 1
            minIdx = 0
            minVal = array.get(dists, 0)
            for j = 1 to array.size(dists) - 1
                v = array.get(dists, j)
                if v < minVal
                    minVal := v
                    minIdx := j
            array.push(selected, array.get(outs, minIdx))
            array.set(dists, minIdx, 1e20)

        sumO = 0.0
        for j = 0 to array.size(selected) - 1
            sumO += array.get(selected, j)
        avg = sumO / array.size(selected)
        math.min(100.0, math.max(0.0, avg / 3.0 * 100.0))

// ═══════════════════════════════════════════════════════════════
//  AI SCORING ENGINE (8 FACTORS)
// ═══════════════════════════════════════════════════════════════
f_score_structure(typ, dir) =>
    zDir = (typ == 1 or typ == 3 or typ == 6) ? 1 : -1
    aligned = zDir == dir
    base = aligned ? 75.0 : 35.0
    bonusBOS = (aligned and (bosUp or bosDn)) ? 15.0 : 0.0
    math.min(100.0, base + bonusBOS)

f_score_displacement(dispAtBirth) =>
    math.min(100.0, dispAtBirth * 35.0)

f_score_volume(volAtBirth) =>
    math.min(100.0, math.max(0.0, 50.0 + volAtBirth * 20.0))

f_score_mtf(align) =>
    (align + 3) / 6.0 * 100.0

f_score_imbalance(typ, top, bot) =>
    sz = top - bot
    ratio = sz / (atrV + 1e-9)
    math.min(100.0, ratio * 50.0)

f_score_freshness(startBar, mitigated) =>
    age = bar_index - startBar
    mitPenalty = mitigated ? 30.0 : 0.0
    raw = 100.0 * math.exp(-age / 150.0)
    math.max(0.0, raw - mitPenalty)

f_score_confluence(top, bot) =>
    n = array.size(zType)
    cnt = 0
    if n > 0
        for i = 0 to n - 1
            oTop = array.get(zTop, i)
            oBot = array.get(zBot, i)
            if not (oTop < bot or oBot > top)
                cnt += 1
    math.min(100.0, 40.0 + cnt * 20.0)

f_computeScore(typ, top, bot, startBar, volBirth, dispBirth, mtfAlign, mitigated, knn) =>
    dir = (typ == 1 or typ == 3 or typ == 6) ? 1 : -1
    sStruct  = f_score_structure(typ, dir)
    sDisp    = f_score_displacement(dispBirth)
    sVol     = f_score_volume(volBirth)
    sMtf     = f_score_mtf(mtfAlign)
    sImb     = f_score_imbalance(typ, top, bot)
    sFresh   = f_score_freshness(startBar, mitigated)
    sConf    = f_score_confluence(top, bot)
    sKnn     = knn

    totalW = wStruct + wDisplace + wVolume + wMTF + wKNN + wImbalance + wFreshness + wConfluence
    weighted = (sStruct * wStruct + sDisp * wDisplace + sVol * wVolume + sMtf * wMTF + sKnn * wKNN + sImb * wImbalance + sFresh * wFreshness + sConf * wConfluence)
    weighted / math.max(totalW, 1.0)

f_allFactors(idx) =>
    typ = array.get(zType, idx)
    top = array.get(zTop, idx)
    bot = array.get(zBot, idx)
    startBar = array.get(zStartBar, idx)
    volB = array.get(zVolAtBirth, idx)
    dispB = array.get(zDispAtBirth, idx)
    align = array.get(zMtfAlign, idx)
    mit = array.get(zMitigated, idx)
    knn = 0.0
    dir = (typ == 1 or typ == 3 or typ == 6) ? 1 : -1
    [f_score_structure(typ, dir),
     f_score_displacement(dispB),
     f_score_volume(volB),
     f_score_mtf(align),
     knn,
     f_score_imbalance(typ, top, bot),
     f_score_freshness(startBar, mit),
     f_score_confluence(top, bot)]

// ═══════════════════════════════════════════════════════════════
//  ZONE DETECTION / CREATION
// ═══════════════════════════════════════════════════════════════
f_addZone(typ, top, bot, startBar, volB, dispB) =>
    mtfAlign = htfTrend1 + htfTrend2 + htfTrend3
    knnVal = f_knnScore(dispB, volB, bodyRatio, atrRatio, rangeRatio)

    array.push(zType, typ)
    array.push(zTop, top)
    array.push(zBot, bot)
    array.push(zStartBar, startBar)
    array.push(zVolAtBirth, volB)
    array.push(zDispAtBirth, dispB)
    array.push(zMtfAlign, int(mtfAlign))
    array.push(zMitigated, false)

    initScore = f_computeScore(typ, top, bot, startBar, volB, dispB, int(mtfAlign), false, knnVal)
    array.push(zScore, initScore)

    col = f_zoneColor(typ)
    bx = box.new(startBar, top, bar_index, bot,
         bgcolor=color.new(col, 80), border_color=color.new(col, 40), border_width=1)
    lb = label.new(bar_index, (top + bot) / 2, "",
         style=label.style_label_left, color=color.new(col, 30),
         textcolor=color.white, size=size.small)
    array.push(zBoxes, bx)
    array.push(zLabels, lb)

    while array.size(zType) > maxZones
        box.delete(array.shift(zBoxes))
        label.delete(array.shift(zLabels))
        array.shift(zType)
        array.shift(zTop)
        array.shift(zBot)
        array.shift(zStartBar)
        array.shift(zScore)
        array.shift(zVolAtBirth)
        array.shift(zDispAtBirth)
        array.shift(zMtfAlign)
        array.shift(zMitigated)

// ── ORDER BLOCK DETECTION ──
obStrongUp = close > open and displacement > 1.5 and volZ > 0.5 and bosUp
obStrongDn = close < open and displacement > 1.5 and volZ > 0.5 and bosDn

if showOB and barstate.isconfirmed and obStrongUp
    found = false
    for i = 1 to obLookback
        if close[i] < open[i] and not found
            array.size(zType) < 999 ? f_addZone(1, high[i], low[i], bar_index - i, volZ, displacement) : na
            found := true

if showOB and barstate.isconfirmed and obStrongDn
    found = false
    for i = 1 to obLookback
        if close[i] > open[i] and not found
            array.size(zType) < 999 ? f_addZone(2, high[i], low[i], bar_index - i, volZ, displacement) : na
            found := true

// ── FVG DETECTION ──
fvgBullCond = low > high[2] and (low - high[2]) > fvgMinSize * atrV
fvgBearCond = high < low[2] and (low[2] - high) > fvgMinSize * atrV

if showFVG and barstate.isconfirmed and fvgBullCond
    f_addZone(3, low, high[2], bar_index - 2, volZ, displacement)
if showFVG and barstate.isconfirmed and fvgBearCond
    f_addZone(4, low[2], high, bar_index - 2, volZ, displacement)

// ── LIQUIDITY SWEEP DETECTION ──
sweepHi = not na(lastPH) and high > lastPH + sweepTol * atrV and close < lastPH
sweepLo = not na(lastPL) and low  < lastPL - sweepTol * atrV and close > lastPL

if showSweep and barstate.isconfirmed and sweepHi
    f_addZone(5, high, lastPH, bar_index, volZ, displacement)
if showSweep and barstate.isconfirmed and sweepLo
    f_addZone(6, lastPL, low, bar_index, volZ, displacement)

// ═══════════════════════════════════════════════════════════════
//  ZONE MAINTENANCE & MITIGATION
// ═══════════════════════════════════════════════════════════════
if barstate.isconfirmed and array.size(zType) > 0
    for i = 0 to array.size(zType) - 1
        typ = array.get(zType, i)
        top = array.get(zTop, i)
        bot = array.get(zBot, i)
        startBar = array.get(zStartBar, i)
        volB = array.get(zVolAtBirth, i)
        dispB = array.get(zDispAtBirth, i)
        align = array.get(zMtfAlign, i)
        mit = array.get(zMitigated, i)

        isBullish = typ == 1 or typ == 3 or typ == 6
        newMit = mit
        if not mit
            if isBullish and low <= top and high >= bot
                newMit := true
            if not isBullish and high >= bot and low <= top
                newMit := true
            array.set(zMitigated, i, newMit)

        knnVal = f_knnScore(dispB, volB, bodyRatio, atrRatio, rangeRatio)
        newScore = f_computeScore(typ, top, bot, startBar, volB, dispB, align, newMit, knnVal)
        array.set(zScore, i, newScore)

// Update visual boxes on last bar
if barstate.islast and array.size(zType) > 0
    for i = 0 to array.size(zType) - 1
        typ = array.get(zType, i)
        top = array.get(zTop, i)
        bot = array.get(zBot, i)
        startBar = array.get(zStartBar, i)
        sc = array.get(zScore, i)
        mit = array.get(zMitigated, i)

        bx = array.get(zBoxes, i)
        lb = array.get(zLabels, i)

        col = f_zoneColor(typ)
        gradeCol = f_gradeColor(sc)

        transp = int(math.max(30.0, 95.0 - sc * 0.7))
        borderTransp = int(math.max(10.0, 80.0 - sc * 0.8))

        hideLowScore = sc < minScoreDisplay

        if hideLowScore
            box.set_bgcolor(bx, na)
            box.set_border_color(bx, na)
            label.set_text(lb, "")
            label.set_color(lb, na)
        else
            rightBar = (extendZones and not mit) ? bar_index + 15 : bar_index
            box.set_right(bx, rightBar)
            box.set_bgcolor(bx, color.new(col, transp))
            box.set_border_color(bx, color.new(gradeCol, borderTransp))
            box.set_border_width(bx, sc >= 75 ? 2 : 1)

            if showScores
                grade = f_gradeLetter(sc)
                typeShort = f_zoneTypeShort(typ)
                lblTxt = typeShort + (mit ? " ~ " : " · ") +
                     (showGrade ? "[" + grade + "] " : "") +
                     str.tostring(sc, "#") + "%"
                label.set_xy(lb, rightBar, (top + bot) / 2)
                label.set_text(lb, lblTxt)
                label.set_color(lb, color.new(gradeCol, 20))
                label.set_textcolor(lb, color.white)
                label.set_style(lb, label.style_label_left)
                label.set_size(lb, sc >= 75 ? size.normal : size.small)
            else
                label.set_text(lb, "")
                label.set_color(lb, na)

// ═══════════════════════════════════════════════════════════════
//  TOP ZONE & STATS
// ═══════════════════════════════════════════════════════════════
topIdx = -1
topScore = 0.0
nZ = array.size(zType)
if nZ > 0
    for i = 0 to nZ - 1
        s = array.get(zScore, i)
        if s > topScore
            topScore := s
            topIdx := i

countOB = 0
countFVG = 0
countSW = 0
avgScore = 0.0
countAplus = 0
if nZ > 0
    sumS = 0.0
    for i = 0 to nZ - 1
        t = array.get(zType, i)
        s = array.get(zScore, i)
        sumS += s
        if s >= 85
            countAplus += 1
        if t == 1 or t == 2
            countOB += 1
        if t == 3 or t == 4
            countFVG += 1
        if t == 5 or t == 6
            countSW += 1
    avgScore := sumS / nZ

// ═══════════════════════════════════════════════════════════════
//  MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast and showDashboard
    dash := table.new(f_posHelper(dashPos), 6, 30,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    table.cell(dash, 0, 0, "◆  AETHEREDGE SMC · AI CONFIDENCE ENGINE  ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 5, 0)

    table.cell(dash, 0, 1,
         syminfo.ticker + "  ·  " + timeframe.period +
         "  ·  Zones: " + str.tostring(nZ) + "/" + str.tostring(maxZones) +
         "  ·  MTF: " + mtf1 + "/" + mtf2 + "/" + mtf3,
         text_color=cMute, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 5, 1)

    // MARKET STRUCTURE
    table.cell(dash, 0, 2, "◢  MARKET STRUCTURE  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 5, 2)

    trendLabel = trendDir > 0 ? "▲ BULLISH" : trendDir < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
    trendCol = trendDir > 0 ? cBull : trendDir < 0 ? cBear : cMute
    mtfSum = htfTrend1 + htfTrend2 + htfTrend3
    mtfLabel = mtfSum >= 2 ? "✓ STRONG BULL" : mtfSum <= -2 ? "✗ STRONG BEAR" :
               mtfSum > 0 ? "↗ MIXED BULL" : mtfSum < 0 ? "↘ MIXED BEAR" : "— NEUTRAL"
    mtfCol = mtfSum >= 2 ? cBull : mtfSum <= -2 ? cBear : mtfSum != 0 ? cWarn : cMute

    table.cell(dash, 0, 3, "Trend Dir",  text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 3, trendLabel,
         text_color=color.white, bgcolor=color.new(trendCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 3, "MTF Consensus", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 3, mtfLabel,
         text_color=color.white, bgcolor=color.new(mtfCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 3, "Score", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 3, f_signedStr(mtfSum) + "/±3",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    mtfBar = ""
    mtfBar := mtfBar + (htfTrend1 > 0 ? "▲" : htfTrend1 < 0 ? "▼" : "◆")
    mtfBar := mtfBar + "  "
    mtfBar := mtfBar + (htfTrend2 > 0 ? "▲" : htfTrend2 < 0 ? "▼" : "◆")
    mtfBar := mtfBar + "  "
    mtfBar := mtfBar + (htfTrend3 > 0 ? "▲" : htfTrend3 < 0 ? "▼" : "◆")

    table.cell(dash, 0, 4, "HTF Breakdown", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 4, mtf1 + ": " + (htfTrend1 > 0 ? "Bull" : htfTrend1 < 0 ? "Bear" : "—"),
         text_color=htfTrend1 > 0 ? cBull : htfTrend1 < 0 ? cBear : cMute,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 4, mtf2 + ": " + (htfTrend2 > 0 ? "Bull" : htfTrend2 < 0 ? "Bear" : "—"),
         text_color=htfTrend2 > 0 ? cBull : htfTrend2 < 0 ? cBear : cMute,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 4, mtf3 + ": " + (htfTrend3 > 0 ? "Bull" : htfTrend3 < 0 ? "Bear" : "—"),
         text_color=htfTrend3 > 0 ? cBull : htfTrend3 < 0 ? cBear : cMute,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 4, "Visual", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 4, mtfBar,
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)

    // ZONE INVENTORY
    table.cell(dash, 0, 5, "◢  ZONE INVENTORY  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 5, 5, 5)

    table.cell(dash, 0, 6, "Order Blocks", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 6, str.tostring(countOB),
         text_color=color.white, bgcolor=color.new(cBull, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 6, "Fair Value Gaps", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 6, str.tostring(countFVG),
         text_color=color.white, bgcolor=color.new(cFVGBull, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 6, "Liq Sweeps", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 6, str.tostring(countSW),
         text_color=color.white, bgcolor=color.new(cPurple, 30),
         text_halign=text.align_center, text_size=size.large)

    table.cell(dash, 0, 7, "Avg Score", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    avgCol = avgScore >= 70 ? cBull : avgScore >= 50 ? cWarn : cBear
    table.cell(dash, 1, 7, str.tostring(avgScore, "#") + "%",
         text_color=color.white, bgcolor=color.new(avgCol, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 7, "A+ Zones", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 7, str.tostring(countAplus),
         text_color=color.white, bgcolor=color.new(cGold, 30),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 7, "Top Score", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    topCol = f_gradeColor(topScore)
    table.cell(dash, 5, 7, str.tostring(topScore, "#") + "% [" + f_gradeLetter(topScore) + "]",
         text_color=color.white, bgcolor=color.new(topCol, 20),
         text_halign=text.align_center, text_size=size.large)

    // TOP ZONE DETAIL
    if topIdx >= 0
        table.cell(dash, 0, 8, "◢  HIGHEST-CONFIDENCE ZONE · 8-FACTOR BREAKDOWN  ◣",
             text_color=color.white, bgcolor=color.new(cGold, 30),
             text_size=size.normal, text_halign=text.align_center)
        table.merge_cells(dash, 0, 8, 5, 8)

        topType = array.get(zType, topIdx)
        topTop  = array.get(zTop, topIdx)
        topBot  = array.get(zBot, topIdx)
        topMit  = array.get(zMitigated, topIdx)
        topAge  = bar_index - array.get(zStartBar, topIdx)

        table.cell(dash, 0, 9, "Type", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
        table.cell(dash, 1, 9, f_zoneTypeName(topType),
             text_color=color.white, bgcolor=color.new(f_zoneColor(topType), 20),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 9, "Range", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
        table.cell(dash, 3, 9, str.tostring(topBot, format.mintick) + " – " + str.tostring(topTop, format.mintick),
             text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 4, 9, "Age / State", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
        table.cell(dash, 5, 9, str.tostring(topAge) + " bars  " + (topMit ? "~ Mitigated" : "· Fresh"),
             text_color=topMit ? cWarn : cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

        [fS, fD, fV, fM, fK, fI, fF, fC] = f_allFactors(topIdx)

        // Factor rows (inlined since nested functions are not allowed in v5)
        // Row 10: Structure
        fCol10 = fS >= 75 ? cBull : fS >= 50 ? cWarn : cBear
        table.cell(dash, 0, 10, "Structure Integrity", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 10, str.tostring(fS, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol10, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 10, f_scoreBar(fS),
             text_color=fCol10, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 10, 5, 10)

        // Row 11: Displacement
        fCol11 = fD >= 75 ? cBull : fD >= 50 ? cWarn : cBear
        table.cell(dash, 0, 11, "Displacement Strength", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 11, str.tostring(fD, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol11, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 11, f_scoreBar(fD),
             text_color=fCol11, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 11, 5, 11)

        // Row 12: Volume
        fCol12 = fV >= 75 ? cBull : fV >= 50 ? cWarn : cBear
        table.cell(dash, 0, 12, "Volume Profile", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 12, str.tostring(fV, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol12, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 12, f_scoreBar(fV),
             text_color=fCol12, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 12, 5, 12)

        // Row 13: MTF
        fCol13 = fM >= 75 ? cBull : fM >= 50 ? cWarn : cBear
        table.cell(dash, 0, 13, "MTF Consensus", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 13, str.tostring(fM, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol13, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 13, f_scoreBar(fM),
             text_color=fCol13, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 13, 5, 13)

        // Row 14: Imbalance
        fCol14 = fI >= 75 ? cBull : fI >= 50 ? cWarn : cBear
        table.cell(dash, 0, 14, "Imbalance Ratio", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 14, str.tostring(fI, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol14, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 14, f_scoreBar(fI),
             text_color=fCol14, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 14, 5, 14)

        // Row 15: Freshness
        fCol15 = fF >= 75 ? cBull : fF >= 50 ? cWarn : cBear
        table.cell(dash, 0, 15, "Freshness / Age", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 15, str.tostring(fF, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol15, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 15, f_scoreBar(fF),
             text_color=fCol15, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 15, 5, 15)

        // Row 16: Confluence
        fCol16 = fC >= 75 ? cBull : fC >= 50 ? cWarn : cBear
        table.cell(dash, 0, 16, "Confluence", text_color=cText, bgcolor=cBgRow,
             text_halign=text.align_right, text_size=size.normal)
        table.cell(dash, 1, 16, str.tostring(fC, "#") + "%",
             text_color=color.white, bgcolor=color.new(fCol16, 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, 16, f_scoreBar(fC),
             text_color=fCol16, bgcolor=cBgRow,
             text_halign=text.align_left, text_size=size.normal)
        table.merge_cells(dash, 2, 16, 5, 16)

        // Composite
        table.cell(dash, 0, 17, "COMPOSITE", text_color=cAccent, bgcolor=cBgAlt,
             text_halign=text.align_right, text_size=size.large)
        table.cell(dash, 1, 17, str.tostring(topScore, "#") + "% · " + f_gradeLetter(topScore),
             text_color=color.white, bgcolor=color.new(f_gradeColor(topScore), 10),
             text_halign=text.align_center, text_size=size.large)
        table.cell(dash, 2, 17, f_scoreBar(topScore),
             text_color=f_gradeColor(topScore), bgcolor=cBgAlt,
             text_halign=text.align_left, text_size=size.large)
        table.merge_cells(dash, 2, 17, 5, 17)

    // SCORING WEIGHTS
    wRow = topIdx >= 0 ? 18 : 8
    table.cell(dash, 0, wRow, "◢  AI SCORING WEIGHTS (%)  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, wRow, 5, wRow)

    totW = wStruct + wDisplace + wVolume + wMTF + wKNN + wImbalance + wFreshness + wConfluence

    table.cell(dash, 0, wRow + 1, "Structure", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, wRow + 1, str.tostring(wStruct / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, wRow + 1, "Displacement", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, wRow + 1, str.tostring(wDisplace / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, wRow + 1, "Volume", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, wRow + 1, str.tostring(wVolume / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, wRow + 2, "MTF", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, wRow + 2, str.tostring(wMTF / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, wRow + 2, "kNN", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, wRow + 2, str.tostring(wKNN / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, wRow + 2, "Imbalance", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, wRow + 2, str.tostring(wImbalance / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, wRow + 3, "Freshness", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, wRow + 3, str.tostring(wFreshness / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, wRow + 3, "Confluence", text_color=cText, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, wRow + 3, str.tostring(wConfluence / totW * 100, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, wRow + 3, "TOTAL", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, wRow + 3, "100%",
         text_color=cGold, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)

// ═══════════════════════════════════════════════════════════════
//  TOP ZONES TABLE
// ═══════════════════════════════════════════════════════════════
var table ztbl = na
if barstate.islast and showZoneTable and nZ > 0
    rows = math.min(nZ, 10) + 3
    ztbl := table.new(f_posHelper(zTablePos), 7, rows,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    table.cell(ztbl, 0, 0, "◆  ACTIVE ZONES · RANKED BY AI CONFIDENCE  ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(ztbl, 0, 0, 6, 0)

    headers = array.from("#", "Type", "Range", "Age", "State", "MTF", "Score")
    for c = 0 to 6
        table.cell(ztbl, c, 1, array.get(headers, c),
             text_color=cMute, bgcolor=cBgAlt,
             text_size=size.normal, text_halign=text.align_center)

    idxArr = array.new<int>(0)
    scArr  = array.new<float>(0)
    for i = 0 to nZ - 1
        array.push(idxArr, i)
        array.push(scArr, array.get(zScore, i))

    nShow = math.min(nZ, 10)
    for p = 0 to nShow - 1
        maxIdx = p
        maxVal = array.get(scArr, p)
        for j = p + 1 to array.size(scArr) - 1
            v = array.get(scArr, j)
            if v > maxVal
                maxVal := v
                maxIdx := j
        if maxIdx != p
            tmp1 = array.get(idxArr, p)
            tmp2 = array.get(scArr, p)
            array.set(idxArr, p, array.get(idxArr, maxIdx))
            array.set(scArr, p, array.get(scArr, maxIdx))
            array.set(idxArr, maxIdx, tmp1)
            array.set(scArr, maxIdx, tmp2)

    for r = 0 to nShow - 1
        zi = array.get(idxArr, r)
        t = array.get(zType, zi)
        tp = array.get(zTop, zi)
        bt = array.get(zBot, zi)
        ag = bar_index - array.get(zStartBar, zi)
        mt = array.get(zMitigated, zi)
        al = array.get(zMtfAlign, zi)
        sc = array.get(zScore, zi)
        rowColor = r % 2 == 0 ? cBgRow : cBgAlt
        gCol = f_gradeColor(sc)

        // ── FIX: "+#;-#;0" は無効な書式のため、f_signedStr() でゼロを処理 ──
        alText = f_signedStr(al)

        table.cell(ztbl, 0, r + 2, "#" + str.tostring(r + 1),
             text_color=cMute, bgcolor=rowColor,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 1, r + 2, f_zoneTypeShort(t),
             text_color=color.white, bgcolor=color.new(f_zoneColor(t), 30),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 2, r + 2, str.tostring(bt, format.mintick) + "–" + str.tostring(tp, format.mintick),
             text_color=cText, bgcolor=rowColor,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 3, r + 2, str.tostring(ag) + "b",
             text_color=cText, bgcolor=rowColor,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 4, r + 2, mt ? "~Mit" : "Fresh",
             text_color=mt ? cWarn : cBull, bgcolor=rowColor,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 5, r + 2, alText,
             text_color=al > 0 ? cBull : al < 0 ? cBear : cMute,
             bgcolor=rowColor, text_halign=text.align_center, text_size=size.normal)
        table.cell(ztbl, 6, r + 2, str.tostring(sc, "#") + "% " + f_gradeLetter(sc),
             text_color=color.white, bgcolor=color.new(gCol, 20),
             text_halign=text.align_center, text_size=size.normal)

// ═══════════════════════════════════════════════════════════════
//  SIGNALS & ALERTS
// ═══════════════════════════════════════════════════════════════
newZoneHighQuality = false
if barstate.isconfirmed and nZ > 0
    lastIdx = nZ - 1
    lastScore = array.get(zScore, lastIdx)
    lastStartBar = array.get(zStartBar, lastIdx)
    if lastScore >= 75 and bar_index - lastStartBar <= 2
        newZoneHighQuality := true

plotshape(newZoneHighQuality, "High-Quality Zone Formed",
     shape.diamond, location.belowbar,
     color=cGold, size=size.small, text="A+", textcolor=color.white)

alertcondition(newZoneHighQuality, "New High-Quality SMC Zone",
     "AE-SMC: New zone with AI confidence ≥75% formed on {{ticker}} @ {{close}}")
alertcondition(bosUp, "Bullish BOS",
     "AE-SMC: Bullish Break of Structure on {{ticker}}")
alertcondition(bosDn, "Bearish BOS",
     "AE-SMC: Bearish Break of Structure on {{ticker}}")

plot(topScore, "Top Zone Score", display=display.none)
plot(avgScore, "Average Score", display=display.none)
plot(nZ, "Active Zone Count", display=display.none)
````
