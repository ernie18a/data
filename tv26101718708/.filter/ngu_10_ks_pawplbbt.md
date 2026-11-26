# NGU 1.0 [KS]

- url: https://www.tradingview.com/script/pAwpLBbT-NGU-1-0-KS/
- type: indicator
- pine_id: PUB;39c6e64c631d483cb639d49782a414c2
- version: 8.0

## Description

based on ichi moku cloud and FVG breakouts. But when a range is detected, it shoows based on support and resistence, basically I try to make my NGU strategy objective.

## Source Code

````pine
//@version=6
indicator("NGU", shorttitle="NGU", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════
//  PALETTE — warm cream, dark-mode optimised
//  C_CREAM  #E8DCC8   bull / primary
//  C_SAND   #C9B99A   bear / secondary
//  C_ASH    #8C7B6B   muted / SL fills
//  C_DIM    #3E3530   near-invisible borders
// ══════════════════════════════════════════════════════════════════

color C_CREAM = #E8DCC8
color C_SAND  = #C9B99A
color C_ASH   = #8C7B6B
color C_DIM   = #3E3530

// ══════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════

grp_vis    = "─── Display ───"
showIchi   = input.bool(true,  "Ichimoku Cloud",       group=grp_vis)
showFvg    = input.bool(true,  "Fair Value Gaps",      group=grp_vis)
showTl     = input.bool(true,  "Trendlines",           group=grp_vis)
showSR     = input.bool(true,  "Support & Resistance", group=grp_vis)
showDiv    = input.bool(true,  "RSI Divergence",       group=grp_vis)
showRegime = input.bool(true,  "Regime Label",         group=grp_vis)

grp_struct = "─── Structure / Regime ───"
pivotLen   = input.int(5,    "Trendline Pivot Bars",    minval=2,  maxval=20, group=grp_struct)
rangeLen   = input.int(50,   "Regime Lookback",         minval=20,            group=grp_struct)
regimeConf = input.int(3,    "Regime Confirm Bars",     minval=1,  maxval=10, group=grp_struct,
     tooltip="Consecutive bars required before regime switches — prevents flicker")

grp_sr     = "─── Support & Resistance ───"
srPivotLen = input.int(20,   "S/R Pivot Strength",      minval=5,  maxval=50, group=grp_sr,
     tooltip="Higher = only major swing highs/lows. 20 = significant levels. 5 = noise.")
srZone     = input.float(0.8,"Cluster Zone (ATR ×)",    minval=0.1, step=0.1, group=grp_sr,
     tooltip="Pivots within this ATR distance merge into one level")
srMinTouch = input.int(2,    "Min Touches",             minval=1,             group=grp_sr)
srMaxLevels= input.int(6,    "Max Levels (per side)",   minval=1,  maxval=6,  group=grp_sr)
srResColor = input.color(color.new(#E8DCC8, 10), "Resistance Color",          group=grp_sr)
srSupColor = input.color(color.new(#C9B99A, 10), "Support Color",             group=grp_sr)
srLineStyle= input.string("solid", "Line Style",                              group=grp_sr,
     options=["solid","dashed","dotted"])
srWidth1   = input.int(1,    "Width — 1 Touch",         minval=1,  maxval=5,  group=grp_sr)
srWidth2   = input.int(2,    "Width — 3+ Touches",      minval=1,  maxval=5,  group=grp_sr)
srWidth3   = input.int(3,    "Width — 5+ Touches",      minval=1,  maxval=5,  group=grp_sr)

grp_div    = "─── RSI Divergence ───"
rsiLen     = input.int(14,   "RSI Length",              minval=2,             group=grp_div)
divPivLen  = input.int(8,    "Divergence Pivot Bars",   minval=2,  maxval=30, group=grp_div,
     tooltip="Higher = fewer but more significant divergences. 8 recommended for most TFs.")
showHidden = input.bool(true, "Show Hidden Divergence", group=grp_div,
     tooltip="Hidden bull: price HL + RSI LL = trend continuation up. Hidden bear: price LH + RSI HH.")

grp_fvg    = "─── Fair Value Gaps ───"
fvgMinPct  = input.float(0.05,"Min Gap Size (%)",       minval=0.01, step=0.01, group=grp_fvg,
     tooltip="Gap must be this % of price — scales correctly across all instruments")
fvgMaxAge  = input.int(60,   "Max Age (Bars)",           minval=5,             group=grp_fvg)
fvgMitig   = input.bool(true,"Mitigate at 50% Fill",                          group=grp_fvg)

grp_ichi     = "─── Ichimoku ───"
tenkanLen    = input.int(9,   "Tenkan Length",             group=grp_ichi)
kijunLen     = input.int(26,  "Kijun Length",              group=grp_ichi)
displace     = input.int(26,  "Displacement",              group=grp_ichi)
tenkanColor  = input.color(color.new(#E8DCC8, 45), "Tenkan Color",  group=grp_ichi)
kijunColor   = input.color(color.new(#C9B99A, 45), "Kijun Color",   group=grp_ichi)
cloudBullCol = input.color(color.new(#E8DCC8, 70), "Cloud Bull Fill", group=grp_ichi,
     tooltip="Color when Senkou A > Senkou B (bullish cloud)")
cloudBearCol = input.color(color.new(#8C7B6B, 70), "Cloud Bear Fill", group=grp_ichi,
     tooltip="Color when Senkou A < Senkou B (bearish cloud)")
ssaColor     = input.color(color.new(#E8DCC8, 30), "SSA Line Color", group=grp_ichi)
ssbColor     = input.color(color.new(#8C7B6B, 30), "SSB Line Color", group=grp_ichi)

grp_rr     = "─── Risk / Reward ───"
atrLen      = input.int(14,   "ATR Length",             group=grp_rr)
tpMult      = input.float(2.0,"TP (ATR ×)",             group=grp_rr, minval=0.1, step=0.1)
slMult      = input.float(1.0,"SL (ATR ×)",             group=grp_rr, minval=0.1, step=0.1)
tpBarWidth  = input.int(20,   "TP/SL Box Width (Bars)", group=grp_rr, minval=5)
maxSigBoxes = input.int(20,   "Max Signal Boxes",       group=grp_rr, minval=5)

grp_time   = "─── Session ───"
useTime    = input.bool(true,           "Enable Filter", group=grp_time)
sessionInp = input.session("0700-1700", "Window",        group=grp_time,
     tooltip="Session uses exchange timezone by default. Adjust the session string to match your timezone.")

// ══════════════════════════════════════════════════════════════════
//  BASE
// ══════════════════════════════════════════════════════════════════

atr       = ta.atr(atrLen)
inSession = not useTime or not na(time(timeframe.period, sessionInp))
bgcolor(useTime and inSession ? color.new(C_ASH, 97) : na, title="Session BG")

// ══════════════════════════════════════════════════════════════════
//  ICHIMOKU
// ══════════════════════════════════════════════════════════════════

tenkan      = math.avg(ta.highest(high, tenkanLen), ta.lowest(low, tenkanLen))
kijun       = math.avg(ta.highest(high, kijunLen),  ta.lowest(low, kijunLen))
senkouA_raw = math.avg(tenkan, kijun)
senkouB_raw = math.avg(ta.highest(high, 52), ta.lowest(low, 52))
cloudTop    = math.max(senkouA_raw[displace], senkouB_raw[displace])
cloudBot    = math.min(senkouA_raw[displace], senkouB_raw[displace])
aboveCloud  = close > cloudTop
belowCloud  = close < cloudBot

p_ten = plot(showIchi ? tenkan      : na, "Tenkan", color=tenkanColor,  linewidth=1)
p_kij = plot(showIchi ? kijun       : na, "Kijun",  color=kijunColor,   linewidth=1)
p_ssa = plot(showIchi ? senkouA_raw : na, "SSA",    color=ssaColor, offset=displace, display=display.none)
p_ssb = plot(showIchi ? senkouB_raw : na, "SSB",    color=ssbColor, offset=displace, display=display.none)
fill(p_ssa, p_ssb,
     senkouA_raw > senkouB_raw ? cloudBullCol : cloudBearCol,
     title="Cloud")

// ══════════════════════════════════════════════════════════════════
//  TRENDLINE PIVOTS (small lookback — for trendlines only)
// ══════════════════════════════════════════════════════════════════

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

var float ph1 = na
var float ph2 = na
var int   ph1i = 0
var int   ph2i = 0
var float pl1 = na
var float pl2 = na
var int   pl1i = 0
var int   pl2i = 0

if not na(ph)
    ph2  := ph1
    ph2i := ph1i
    ph1  := ph
    ph1i := bar_index[pivotLen]

if not na(pl)
    pl2  := pl1
    pl2i := pl1i
    pl1  := pl
    pl1i := bar_index[pivotLen]

// ══════════════════════════════════════════════════════════════════
//  REGIME DETECTION — debounced
// ══════════════════════════════════════════════════════════════════

lrSlope    = ta.linreg(close, rangeLen, 0) - ta.linreg(close, rangeLen, 1)
priceSwing = ta.highest(high, rangeLen) - ta.lowest(low, rangeLen)
normSwing  = priceSwing / atr

bool rawUp    = lrSlope > 0 and normSwing > 1.5
bool rawDown  = lrSlope < 0 and normSwing > 1.5
bool rawRange = not rawUp and not rawDown

var int  upCnt    = 0
var int  dnCnt    = 0
var int  rgCnt    = 0
var bool isUp     = false
var bool isDn     = false
var bool isRng    = true

upCnt := rawUp    ? upCnt + 1 : 0
dnCnt := rawDown  ? dnCnt + 1 : 0
rgCnt := rawRange ? rgCnt + 1 : 0

if upCnt >= regimeConf
    isUp  := true
    isDn  := false
    isRng := false

if dnCnt >= regimeConf
    isUp  := false
    isDn  := true
    isRng := false

if rgCnt >= regimeConf
    isUp  := false
    isDn  := false
    isRng := true

isTrend = isUp or isDn

// ══════════════════════════════════════════════════════════════════
//  TRENDLINES — slope-validated descending res / ascending sup
// ══════════════════════════════════════════════════════════════════

validRes = not na(ph1) and not na(ph2) and ph1 < ph2 and ph1i != ph2i
validSup = not na(pl1) and not na(pl2) and pl1 > pl2 and pl1i != pl2i

float resLine = na
float supLine = na

if validRes
    float sr = (ph1 - ph2) / (ph1i - ph2i)
    resLine  := ph1 + sr * (bar_index - ph1i)

if validSup
    float ss = (pl1 - pl2) / (pl1i - pl2i)
    supLine  := pl1 + ss * (bar_index - pl1i)

var line resObj = na
var line supObj = na

if showTl
    if isTrend
        line.delete(resObj)
        line.delete(supObj)
        if validRes and not na(resLine)
            resObj := line.new(ph1i, ph1, bar_index, resLine,
                 color=color.new(C_CREAM, 30), style=line.style_dashed, width=1, extend=extend.right)
        if validSup and not na(supLine)
            supObj := line.new(pl1i, pl1, bar_index, supLine,
                 color=color.new(C_SAND, 30), style=line.style_dashed, width=1, extend=extend.right)
    else
        line.delete(resObj)
        line.delete(supObj)
        resObj := na
        supObj := na

// ══════════════════════════════════════════════════════════════════
//  S/R ENGINE — Agent 1 full rebuild
//
//  Uses srPivotLen (default 20) for significant swing detection
//  Score = touches² / distance  (strength-weighted, not just proximity)
//  Draws srMaxLevels above AND below price independently
//  Label spacing: minimum 0.5 ATR between adjacent labels
// ══════════════════════════════════════════════════════════════════

// Significant pivots — separate from trendline pivots
srPH = ta.pivothigh(high, srPivotLen, srPivotLen)
srPL = ta.pivotlow(low,   srPivotLen, srPivotLen)

var float[] srPrices      = array.new_float()
var int[]   srCounts      = array.new_int()
var int[]   srOrigins     = array.new_int()
var int[]   srOriginTimes = array.new_int()   // timestamp at origin bar
var int[]   srLastBar     = array.new_int()
var line[]  srLines       = array.new_line()
var label[] srLabels      = array.new_label()

// Register significant pivots
if not na(srPH) or not na(srPL)
    float newLvl = not na(srPH) ? srPH : srPL
    int   newBar = bar_index[srPivotLen]
    float zone   = atr * srZone
    bool  found  = false
    int   mi     = 0
    while mi < array.size(srPrices)
        if math.abs(newLvl - array.get(srPrices, mi)) <= zone
            int prev = array.get(srCounts, mi)
            array.set(srCounts,  mi, prev + 1)
            array.set(srPrices,  mi, (array.get(srPrices, mi) * prev + newLvl) / (prev + 1))
            array.set(srLastBar, mi, newBar)
            found := true
            mi    := array.size(srPrices)
        mi += 1
    if not found
        array.push(srPrices,      newLvl)
        array.push(srCounts,      1)
        array.push(srOrigins,     newBar)
        array.push(srOriginTimes, int(time[srPivotLen]))
        array.push(srLastBar,     newBar)

if barstate.islast and showSR
    // Clear old drawings
    int ci = 0
    while ci < array.size(srLines)
        line.delete(array.get(srLines, ci))
        ci += 1
    array.clear(srLines)
    int di = 0
    while di < array.size(srLabels)
        label.delete(array.get(srLabels, di))
        di += 1
    array.clear(srLabels)

    // Build candidates above and below price separately
    int[]   resIdx   = array.new_int()
    float[] resScore = array.new_float()
    int[]   supIdx   = array.new_int()
    float[] supScore = array.new_float()

    int qi = 0
    while qi < array.size(srPrices)
        float lvl     = array.get(srPrices, qi)
        int   touches = array.get(srCounts, qi)
        if touches >= srMinTouch
            // Agent 1: score = touches² / dist — strength heavily weighted
            float dist  = math.max(math.abs(lvl - close) / atr, 0.1)
            float score = (touches * touches) / dist
            if lvl > close
                array.push(resIdx,   qi)
                array.push(resScore, score)
            else
                array.push(supIdx,   qi)
                array.push(supScore, score)
        qi += 1

    // Sort resistance by score desc
    int rLen = array.size(resIdx)
    int oi   = 0
    while oi < rLen - 1
        int oj = 0
        while oj < rLen - 1 - oi
            if array.get(resScore, oj) < array.get(resScore, oj + 1)
                float ts = array.get(resScore, oj)
                array.set(resScore, oj,     array.get(resScore, oj + 1))
                array.set(resScore, oj + 1, ts)
                int ti = array.get(resIdx, oj)
                array.set(resIdx, oj,     array.get(resIdx, oj + 1))
                array.set(resIdx, oj + 1, ti)
            oj += 1
        oi += 1

    // Sort support by score desc
    int sLen2 = array.size(supIdx)
    int oi2   = 0
    while oi2 < sLen2 - 1
        int oj2 = 0
        while oj2 < sLen2 - 1 - oi2
            if array.get(supScore, oj2) < array.get(supScore, oj2 + 1)
                float ts2 = array.get(supScore, oj2)
                array.set(supScore, oj2,     array.get(supScore, oj2 + 1))
                array.set(supScore, oj2 + 1, ts2)
                int ti2 = array.get(supIdx, oj2)
                array.set(supIdx, oj2,     array.get(supIdx, oj2 + 1))
                array.set(supIdx, oj2 + 1, ti2)
            oj2 += 1
        oi2 += 1

    // Resolve line style from input string
    srStyle = srLineStyle == "dashed" ? line.style_dashed :
         srLineStyle == "dotted" ? line.style_dotted :
         line.style_solid

    // Draw resistance levels — track last drawn Y for label spacing
    float lastResY = na
    int   drawnRes = 0
    int   ri       = 0
    while ri < array.size(resIdx) and drawnRes < srMaxLevels
        int   idx     = array.get(resIdx, ri)
        float lvl     = array.get(srPrices,  idx)
        int   touches = array.get(srCounts,  idx)

        int lw = touches >= 5 ? srWidth3 : touches >= 3 ? srWidth2 : srWidth1

        int originTime = array.get(srOriginTimes, idx)
        ln = line.new(originTime, lvl, time, lvl,
             color=srResColor, style=srStyle, width=lw,
             xloc=xloc.bar_time, extend=extend.right)
        array.push(srLines, ln)

        bool labelOk = na(lastResY) or math.abs(lvl - lastResY) >= atr * 0.5
        if labelOk
            lb = label.new(time, lvl,
                 str.tostring(touches) + "×",
                 color=color.new(C_DIM, 70),
                 textcolor=srResColor,
                 style=label.style_label_left,
                 size=size.tiny,
                 xloc=xloc.bar_time)
            array.push(srLabels, lb)
            lastResY := lvl

        drawnRes += 1
        ri       += 1

    // Draw support levels
    float lastSupY = na
    int   drawnSup = 0
    int   si2      = 0
    while si2 < array.size(supIdx) and drawnSup < srMaxLevels
        int   idx     = array.get(supIdx, si2)
        float lvl     = array.get(srPrices,  idx)
        int   touches = array.get(srCounts,  idx)

        int lw2 = touches >= 5 ? srWidth3 : touches >= 3 ? srWidth2 : srWidth1

        int originTime2 = array.get(srOriginTimes, idx)
        ln = line.new(originTime2, lvl, time, lvl,
             color=srSupColor, style=srStyle, width=lw2,
             xloc=xloc.bar_time, extend=extend.right)
        array.push(srLines, ln)

        bool labelOk = na(lastSupY) or math.abs(lvl - lastSupY) >= atr * 0.5
        if labelOk
            lb = label.new(time, lvl,
                 str.tostring(touches) + "×",
                 color=color.new(C_DIM, 70),
                 textcolor=srSupColor,
                 style=label.style_label_left,
                 size=size.tiny,
                 xloc=xloc.bar_time)
            array.push(srLabels, lb)
            lastSupY := lvl

        drawnSup += 1
        si2      += 1

// ══════════════════════════════════════════════════════════════════
//  NEAREST S/R (for signal logic — uses srPrices built above)
// ══════════════════════════════════════════════════════════════════

float nearSup = na
float nearRes = na
int   nsi     = 0
while nsi < array.size(srPrices)
    if array.get(srCounts, nsi) >= srMinTouch
        float lvl = array.get(srPrices, nsi)
        if lvl < close
            if na(nearSup) or lvl > nearSup
                nearSup := lvl
        else
            if na(nearRes) or lvl < nearRes
                nearRes := lvl
    nsi += 1

atSup = not na(nearSup) and low  <= nearSup + atr * srZone
atRes = not na(nearRes) and high >= nearRes - atr * srZone

// ══════════════════════════════════════════════════════════════════
//  RSI DIVERGENCE — Agent 2 full rebuild
//
//  Regular divergence:
//    Bullish: price LL, RSI HL   → reversal up
//    Bearish: price HH, RSI LH   → reversal down
//
//  Hidden divergence (Agent 2 addition):
//    Hidden Bull: price HL, RSI LL  → continuation up (trend pullback)
//    Hidden Bear: price LH, RSI HH  → continuation down (trend pullback)
//
//  Bar tolerance: abs(priceBar - rsiBar) <= 1  (Agent 2 fix)
//  3-pivot history per side  (Agent 2 fix)
//  Fires once per unique pivot, separate lastBar guards
// ══════════════════════════════════════════════════════════════════

rsi    = ta.rsi(close, rsiLen)

// RSI pivots
rsiPH  = ta.pivothigh(rsi,  divPivLen, divPivLen)
rsiPL  = ta.pivotlow(rsi,   divPivLen, divPivLen)

// Price pivots (separate from trendline/SR pivots)
prcPH  = ta.pivothigh(high, divPivLen, divPivLen)
prcPL  = ta.pivotlow(low,   divPivLen, divPivLen)

// 3-pivot history for price highs
var float pH1 = na
var float pH2 = na
var float pH3 = na
var int   pH1i = 0
var int   pH2i = 0
var int   pH3i = 0

// 3-pivot history for price lows
var float pL1 = na
var float pL2 = na
var float pL3 = na
var int   pL1i = 0
var int   pL2i = 0
var int   pL3i = 0

// 3-pivot history for RSI highs
var float rH1 = na
var float rH2 = na
var float rH3 = na
var int   rH1i = 0
var int   rH2i = 0
var int   rH3i = 0

// 3-pivot history for RSI lows
var float rL1 = na
var float rL2 = na
var float rL3 = na
var int   rL1i = 0
var int   rL2i = 0
var int   rL3i = 0

if not na(prcPH) and bar_index[divPivLen] != pH1i
    pH3  := pH2
    pH3i := pH2i
    pH2  := pH1
    pH2i := pH1i
    pH1  := prcPH
    pH1i := bar_index[divPivLen]

if not na(prcPL) and bar_index[divPivLen] != pL1i
    pL3  := pL2
    pL3i := pL2i
    pL2  := pL1
    pL2i := pL1i
    pL1  := prcPL
    pL1i := bar_index[divPivLen]

if not na(rsiPH) and bar_index[divPivLen] != rH1i
    rH3  := rH2
    rH3i := rH2i
    rH2  := rH1
    rH2i := rH1i
    rH1  := rsiPH
    rH1i := bar_index[divPivLen]

if not na(rsiPL) and bar_index[divPivLen] != rL1i
    rL3  := rL2
    rL3i := rL2i
    rL2  := rL1
    rL2i := rL1i
    rL1  := rsiPL
    rL1i := bar_index[divPivLen]

// Agent 2: bar tolerance ≤ 1 instead of strict equality
bool rsiLowAligned  = not na(pL1) and not na(rL1) and math.abs(pL1i - rL1i) <= 1
bool rsiHighAligned = not na(pH1) and not na(rH1) and math.abs(pH1i - rH1i) <= 1

// ── Regular Divergence ──
// Bullish regular: price LL, RSI HL
bool regBullDiv = showDiv and rsiLowAligned
     and not na(pL2) and not na(rL2)
     and pL1 < pL2    // price: lower low
     and rL1 > rL2    // RSI:  higher low

// Bearish regular: price HH, RSI LH
bool regBearDiv = showDiv and rsiHighAligned
     and not na(pH2) and not na(rH2)
     and pH1 > pH2    // price: higher high
     and rH1 < rH2    // RSI:  lower high

// ── Hidden Divergence ──
// Hidden bull: price HL (higher low), RSI LL (lower low) → trend continuation up
bool hidBullDiv = showDiv and showHidden and rsiLowAligned
     and not na(pL2) and not na(rL2)
     and pL1 > pL2    // price: higher low
     and rL1 < rL2    // RSI:  lower low

// Hidden bear: price LH (lower high), RSI HH (higher high) → trend continuation down
bool hidBearDiv = showDiv and showHidden and rsiHighAligned
     and not na(pH2) and not na(rH2)
     and pH1 < pH2    // price: lower high
     and rH1 > rH2    // RSI:  higher high

// Dedup — fire once per unique pivot bar
var int lastRegBullBar = -1
var int lastRegBearBar = -1
var int lastHidBullBar = -1
var int lastHidBearBar = -1

bool regBullNew = regBullDiv and pL1i != lastRegBullBar
bool regBearNew = regBearDiv and pH1i != lastRegBearBar
bool hidBullNew = hidBullDiv and pL1i != lastHidBullBar
bool hidBearNew = hidBearDiv and pH1i != lastHidBearBar

if regBullNew
    lastRegBullBar := pL1i
    line.new(pL2i, pL2, pL1i, pL1,
         color=color.new(C_CREAM, 5), style=line.style_dotted, width=3)
    label.new(pL1i, pL1 - atr * 0.7, "DIV ▲",
         color=color.new(C_CREAM, 8),
         style=label.style_label_up,
         textcolor=color.new(#1C1C1E, 0),
         size=size.small)

if regBearNew
    lastRegBearBar := pH1i
    line.new(pH2i, pH2, pH1i, pH1,
         color=color.new(C_SAND, 5), style=line.style_dotted, width=3)
    label.new(pH1i, pH1 + atr * 0.7, "DIV ▼",
         color=color.new(C_SAND, 8),
         style=label.style_label_down,
         textcolor=color.new(#1C1C1E, 0),
         size=size.small)

if hidBullNew
    lastHidBullBar := pL1i
    line.new(pL2i, pL2, pL1i, pL1,
         color=color.new(C_CREAM, 30), style=line.style_dashed, width=2)
    label.new(pL1i, pL1 - atr * 0.7, "hDIV ▲",
         color=color.new(C_CREAM, 25),
         style=label.style_label_up,
         textcolor=color.new(#1C1C1E, 0),
         size=size.tiny)

if hidBearNew
    lastHidBearBar := pH1i
    line.new(pH2i, pH2, pH1i, pH1,
         color=color.new(C_SAND, 30), style=line.style_dashed, width=2)
    label.new(pH1i, pH1 + atr * 0.7, "hDIV ▼",
         color=color.new(C_SAND, 25),
         style=label.style_label_down,
         textcolor=color.new(#1C1C1E, 0),
         size=size.tiny)

// ══════════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS — Agent 4 fixes
//
//  Min size: % of price (not ATR) — scales across instruments
//  Opacity fades with age — fresh = solid, old = ghosted
//  Creation and lifecycle separated — no same-bar self-delete
// ══════════════════════════════════════════════════════════════════

var box[] bullFvgB = array.new_box()
var int[] bullFvgT = array.new_int()
var box[] bearFvgB = array.new_box()
var int[] bearFvgT = array.new_int()

// Percentage-based gap filter (Agent 4)
bullGapPct = low > high[2] ? (low - high[2]) / close * 100 : 0.0
bearGapPct = high < low[2] ? (low[2] - high) / close * 100 : 0.0

isBullFvg = low > high[2] and bullGapPct >= fvgMinPct
isBearFvg = high < low[2] and bearGapPct >= fvgMinPct

if showFvg
    // Create new FVG boxes
    if isBullFvg
        bx = box.new(bar_index[1], high[2], bar_index, low,
             bgcolor=color.new(C_CREAM, 86), border_color=color.new(C_CREAM, 55))
        array.push(bullFvgB, bx)
        array.push(bullFvgT, bar_index[1])

    if isBearFvg
        bx = box.new(bar_index[1], high, bar_index, low[2],
             bgcolor=color.new(C_SAND, 86), border_color=color.new(C_SAND, 55))
        array.push(bearFvgB, bx)
        array.push(bearFvgT, bar_index[1])

    // Bull FVG lifecycle — skip boxes created this bar (Agent 4)
    int bi = array.size(bullFvgB) - 1
    while bi >= 0
        box   bx   = array.get(bullFvgB, bi)
        int   born = array.get(bullFvgT, bi)
        int   age  = bar_index - born

        // Skip same-bar deletion
        if age > 0
            float gTop = box.get_top(bx)
            float gBot = box.get_bottom(bx)
            float mid  = gBot + (gTop - gBot) * 0.5
            bool  aged = age >= fvgMaxAge
            bool  fill = fvgMitig and low < mid

            if aged or fill
                box.delete(bx)
                array.remove(bullFvgB, bi)
                array.remove(bullFvgT, bi)
            else
                // Agent 4: fade opacity with age — fresh=86 transparent, old=95
                int ageFade = math.min(86 + age, 95)
                box.set_bgcolor(bx, color.new(C_CREAM, ageFade))
                box.set_right(bx, bar_index)
        bi -= 1

    // Bear FVG lifecycle
    int bj = array.size(bearFvgB) - 1
    while bj >= 0
        box   bx   = array.get(bearFvgB, bj)
        int   born = array.get(bearFvgT, bj)
        int   age  = bar_index - born

        if age > 0
            float gTop = box.get_top(bx)
            float gBot = box.get_bottom(bx)
            float mid  = gBot + (gTop - gBot) * 0.5
            bool  aged = age >= fvgMaxAge
            bool  fill = fvgMitig and high > mid

            if aged or fill
                box.delete(bx)
                array.remove(bearFvgB, bj)
                array.remove(bearFvgT, bj)
            else
                int ageFade = math.min(86 + age, 95)
                box.set_bgcolor(bx, color.new(C_SAND, ageFade))
                box.set_right(bx, bar_index)
        bj -= 1

// ══════════════════════════════════════════════════════════════════
//  SIGNALS — adaptive per regime
//  Agent 3 fixes:
//   - Div signals fire in trend AND range
//   - Bounce confirmation: candle body position, not close>low[1]
//   - Cooldown: min bars between same-direction signals
//   - BREAK = size.normal (higher visual weight)
// ══════════════════════════════════════════════════════════════════

// Candle body position filter (Agent 3)
candleRange  = high - low
bodyTop      = math.max(open, close)
bodyBot      = math.min(open, close)
bullBodyPos  = candleRange > 0 ? (bodyBot - low)  / candleRange : 0.5  // 1 = full bull body
bearBodyPos  = candleRange > 0 ? (high - bodyTop) / candleRange : 0.5  // 1 = full bear body

// Hoist crossover/crossunder to global scope (avoid CW10002)
crossOverRes  = ta.crossover(close, resLine)
crossUnderSup = ta.crossunder(close, supLine)

// Trend signals
bullBreak = isTrend and validRes and crossOverRes  and aboveCloud
bearBreak = isTrend and validSup and crossUnderSup and belowCloud

// Range bounce — body must be in upper/lower 40% of candle
bullBounce = isRng and atSup and bullBodyPos >= 0.4
bearBounce = isRng and atRes and bearBodyPos >= 0.4

// Divergence signals — fire in both regimes independently (Agent 3)
bullDivSig = (regBullNew or hidBullNew) and atSup
bearDivSig = (regBearNew or hidBearNew) and atRes

bullSignal = (bullBreak or bullBounce or bullDivSig) and inSession
bearSignal = (bearBreak or bearBounce or bearDivSig) and inSession

// Agent 3: cooldown — minimum bars between same-direction signals
var int lastBullSig = -999
var int lastBearSig = -999
int cooldown = pivotLen * 2

bullSignal := bullSignal and (bar_index - lastBullSig) >= cooldown
bearSignal := bearSignal and (bar_index - lastBearSig) >= cooldown

// Signal label text
string bullLbl = bullBreak ? "BREAK ▲" : (regBullNew ? "DIV ▲" : (hidBullNew ? "hDIV ▲" : "BOUNCE ▲"))
string bearLbl = bearBreak ? "BREAK ▼" : (regBearNew ? "DIV ▼" : (hidBearNew ? "hDIV ▼" : "BOUNCE ▼"))

// ══════════════════════════════════════════════════════════════════
//  SIGNAL LABELS + TP/SL BOXES
//  Agent 5: BREAK = size.normal, BOUNCE/DIV = size.small
// ══════════════════════════════════════════════════════════════════

var box[] sigBoxes = array.new_box()

if bullSignal
    lastBullSig  := bar_index
    float tp      = close + atr * tpMult
    float sl      = close - atr * slMult
    // Prune oldest pair if over cap
    if array.size(sigBoxes) >= maxSigBoxes * 2
        box.delete(array.shift(sigBoxes))
        box.delete(array.shift(sigBoxes))
    // Agent 5: BREAK gets larger label
    label.new(bar_index, low - atr * 0.4, bullLbl,
         color=color.new(C_CREAM, 8),
         style=label.style_label_up,
         textcolor=color.new(#1C1C1E, 0),
         size=bullBreak ? size.normal : size.small)
    tpB = box.new(bar_index, close, bar_index + tpBarWidth, tp,
         bgcolor=color.new(C_CREAM, 83), border_color=color.new(C_CREAM, 40))
    slB = box.new(bar_index, sl, bar_index + tpBarWidth, close,
         bgcolor=color.new(C_ASH, 87),   border_color=color.new(C_DIM,  50))
    array.push(sigBoxes, tpB)
    array.push(sigBoxes, slB)

if bearSignal
    lastBearSig  := bar_index
    float tp      = close - atr * tpMult
    float sl      = close + atr * slMult
    if array.size(sigBoxes) >= maxSigBoxes * 2
        box.delete(array.shift(sigBoxes))
        box.delete(array.shift(sigBoxes))
    label.new(bar_index, high + atr * 0.4, bearLbl,
         color=color.new(C_SAND, 8),
         style=label.style_label_down,
         textcolor=color.new(#1C1C1E, 0),
         size=bearBreak ? size.normal : size.small)
    tpB2 = box.new(bar_index, tp, bar_index + tpBarWidth, close,
         bgcolor=color.new(C_SAND, 83),  border_color=color.new(C_SAND, 40))
    slB2 = box.new(bar_index, close, bar_index + tpBarWidth, sl,
         bgcolor=color.new(C_ASH, 87),   border_color=color.new(C_DIM,  50))
    array.push(sigBoxes, tpB2)
    array.push(sigBoxes, slB2)

// ══════════════════════════════════════════════════════════════════
//  REGIME LABEL — stable position, no flicker
//  Agent 5: use ta.highest(high, 3) to avoid wick float
// ══════════════════════════════════════════════════════════════════

var label regimeLbl = na

if showRegime and barstate.islast
    label.delete(regimeLbl)
    string rTxt  = isUp ? "TREND ↑" : isDn ? "TREND ↓" : "RANGE"
    color  rCol  = isTrend ? color.new(C_CREAM, 12) : color.new(C_SAND, 12)
    float  rY    = ta.highest(high, 3)
    regimeLbl   := label.new(bar_index + 2, rY, rTxt,
         color=rCol,
         style=label.style_label_left,
         textcolor=color.new(#1C1C1E, 0),
         size=size.small)
````
