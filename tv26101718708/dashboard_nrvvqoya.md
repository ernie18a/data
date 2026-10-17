# Dashboard

- url: https://www.tradingview.com/script/NRvvQOya-Dashboard/
- type: indicator
- pine_id: PUB;45e0ac46c9b043fb9b81a75be3d8eacd
- version: 1.0

## Description

dashboard to tell the daily bias on 4hr and 1 hr just pops up in the little coerner on teh right top

## Source Code

````pine
//@version=6
indicator("Dashboard", overlay=true)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grp_core = "Strategy"
swingLen    = input.int(5,   "Swing Lookback",       minval=2,  maxval=20,  group=grp_core)
bosWindow   = input.int(12,  "BOS Recency (bars)",   minval=1,  maxval=50,  group=grp_core)
fvgMinATR   = input.float(0.2,"FVG Min (ATR x)",     minval=0,  step=0.1,  group=grp_core)
fvgWindow   = input.int(15,  "FVG Recency (bars)",   minval=1,  maxval=50,  group=grp_core)
eqSwingLen  = input.int(10,  "EQ Swing Lookback",    minval=2,  maxval=50,  group=grp_core)
eqMinPts    = input.int(20,  "EQ Min Swing (pts)",   minval=1,                group=grp_core)

grp_rr = "R:R Calculator"
rrSlBuffer  = input.float(2.0, "SL Buffer (pts beyond zone)", minval=0, step=0.5, group=grp_rr)
rrMinRR     = input.float(2.0, "Minimum R:R to highlight",    minval=0.5, step=0.5, group=grp_rr)
rrContracts = input.int(1,     "Contracts (for $ display)",   minval=1,  maxval=10, group=grp_rr)
rrPiv1H     = input.int(3,     "1H Pivot Lookback",           minval=2,  maxval=10, group=grp_rr)
rrPiv4H     = input.int(2,     "4H Pivot Lookback",           minval=2,  maxval=10, group=grp_rr)

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════

c_bg     = color.new(#1E222D, 0)
c_border = color.new(#2A2E39, 0)
c_txt    = color.new(#D1D4DC, 0)
c_txthdr = color.new(#787B86, 0)
c_green  = color.new(#26A69A, 0)
c_red    = color.new(#EF5350, 0)
c_yellow = color.new(#FFD740, 0)
c_orange = color.new(#FF9800, 0)
c_purple = color.new(#E040FB, 0)

// ═══════════════════════════════════════════════════════════════
// ATR
// ═══════════════════════════════════════════════════════════════

atr      = ta.atr(14)
fvgMinSz = fvgMinATR * nz(atr, 1.0)

dirTxt(int d) =>
    d == 1 ? "BULLISH" : d == -1 ? "BEARISH" : "--"

// ═══════════════════════════════════════════════════════════════
// 4H BIAS
// ═══════════════════════════════════════════════════════════════

h4_close = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)
h4_ph    = request.security(syminfo.tickerid, "240", ta.pivothigh(high, 3, 3), lookahead=barmerge.lookahead_off)
h4_pl    = request.security(syminfo.tickerid, "240", ta.pivotlow(low, 3, 3),   lookahead=barmerge.lookahead_off)

var float h4_swHi = na
var float h4_swLo = na
var int   h4_bias = 0

if not na(h4_ph)
    h4_swHi := h4_ph
if not na(h4_pl)
    h4_swLo := h4_pl
if not na(h4_swHi) and h4_close > h4_swHi
    h4_bias := 1
if not na(h4_swLo) and h4_close < h4_swLo
    h4_bias := -1

// ═══════════════════════════════════════════════════════════════
// 1H TREND
// ═══════════════════════════════════════════════════════════════

h1_close = request.security(syminfo.tickerid, "60", close, lookahead=barmerge.lookahead_off)
h1_ph    = request.security(syminfo.tickerid, "60", ta.pivothigh(high, 3, 3), lookahead=barmerge.lookahead_off)
h1_pl    = request.security(syminfo.tickerid, "60", ta.pivotlow(low, 3, 3),   lookahead=barmerge.lookahead_off)

var float h1_swHi  = na
var float h1_swLo  = na
var int   h1_trend = 0

if not na(h1_ph)
    h1_swHi := h1_ph
if not na(h1_pl)
    h1_swLo := h1_pl
if not na(h1_swHi) and h1_close > h1_swHi
    h1_trend := 1
if not na(h1_swLo) and h1_close < h1_swLo
    h1_trend := -1

isAligned = h4_bias != 0 and h1_trend != 0 and h4_bias == h1_trend
execTF    = isAligned ? "5m" : "15m"

// ═══════════════════════════════════════════════════════════════
// SWINGS + BOS (current TF)
// ═══════════════════════════════════════════════════════════════

pvH = ta.pivothigh(high, swingLen, swingLen)
pvL = ta.pivotlow(low, swingLen, swingLen)

var float lastSwHi = na
var float lastSwLo = na

if not na(pvH)
    lastSwHi := pvH
if not na(pvL)
    lastSwLo := pvL

bullBOS = not na(lastSwHi) and close > lastSwHi and close[1] <= lastSwHi
bearBOS = not na(lastSwLo) and close < lastSwLo and close[1] >= lastSwLo

if bullBOS
    lastSwHi := high
if bearBOS
    lastSwLo := low

bsBull = ta.barssince(bullBOS)
bsBear = ta.barssince(bearBOS)
rBull  = bsBull >= 0 and bsBull <= bosWindow
rBear  = bsBear >= 0 and bsBear <= bosWindow
bosDir = rBull and (not rBear or bsBull < bsBear) ? 1 : rBear and (not rBull or bsBear < bsBull) ? -1 : 0
hasBOS = bosDir != 0

// ═══════════════════════════════════════════════════════════════
// FVG DETECTION
// ═══════════════════════════════════════════════════════════════

bFVG = bar_index >= 2 and low > high[2] and (low - high[2]) >= fvgMinSz
sFVG = bar_index >= 2 and low[2] > high and (low[2] - high) >= fvgMinSz

rBullFVG = ta.barssince(bFVG) >= 0 and ta.barssince(bFVG) <= fvgWindow
rBearFVG = ta.barssince(sFVG) >= 0 and ta.barssince(sFVG) <= fvgWindow
fvgDir   = rBullFVG and (not rBearFVG or ta.barssince(bFVG) < ta.barssince(sFVG)) ? 1 : rBearFVG ? -1 : 0
hasFVG   = fvgDir != 0

// ═══════════════════════════════════════════════════════════════
// FVG ZONE EDGES (for R:R calculator)
// ═══════════════════════════════════════════════════════════════

var float fvgBullTop = na
var float fvgBullBot = na
var float fvgBearTop = na
var float fvgBearBot = na

if bFVG
    fvgBullTop := low
    fvgBullBot := high[2]

if sFVG
    fvgBearTop := low[2]
    fvgBearBot := high

// ═══════════════════════════════════════════════════════════════
// ORDER BLOCK DETECTION
// ═══════════════════════════════════════════════════════════════

var float obBullHi = na
var float obBullLo = na
var int   obBullBI = 0
var float obBearHi = na
var float obBearLo = na
var int   obBearBI = 0

if bullBOS
    for i = 1 to 10
        if close[i] < open[i]
            obBullHi := high[i]
            obBullLo := low[i]
            obBullBI := bar_index - i
            break

if bearBOS
    for i = 1 to 10
        if close[i] > open[i]
            obBearHi := high[i]
            obBearLo := low[i]
            obBearBI := bar_index - i
            break

inBullOB = not na(obBullHi) and bar_index - obBullBI <= bosWindow + 10 and low <= obBullHi and close >= obBullLo
inBearOB = not na(obBearHi) and bar_index - obBearBI <= bosWindow + 10 and high >= obBearLo and close <= obBearHi

// ═══════════════════════════════════════════════════════════════
// EQUILIBRIUM / PREMIUM-DISCOUNT
// ═══════════════════════════════════════════════════════════════

eqPH = ta.pivothigh(high, eqSwingLen, eqSwingLen)
eqPL = ta.pivotlow(low, eqSwingLen, eqSwingLen)

var float eqHi    = na
var float eqLo    = na
var int   eqHiBar = 0
var int   eqLoBar = 0

if not na(eqPH)
    eqHi    := eqPH
    eqHiBar := bar_index - eqSwingLen

if not na(eqPL)
    eqLo    := eqPL
    eqLoBar := bar_index - eqSwingLen

eqCtx  = eqHiBar > 0 and eqLoBar > 0 ? (eqLoBar < eqHiBar ? 1 : -1) : 0
eqRng  = not na(eqHi) and not na(eqLo) ? math.abs(eqHi - eqLo) : 0.0
eqOk   = eqRng >= eqMinPts
eqMid  = eqOk ? (eqHi + eqLo) / 2.0 : na
inDisc = eqOk ? (eqCtx == 1 ? close < eqMid : eqCtx == -1 ? close > eqMid : false) : false

// ═══════════════════════════════════════════════════════════════
// CHECKLIST SCORING
// ═══════════════════════════════════════════════════════════════

mainBias = h4_bias != 0 ? h4_bias : bosDir

chkA = isAligned
chkB = hasBOS and bosDir == mainBias
chkC = (hasFVG and fvgDir == mainBias) or inBullOB or inBearOB
chkE = inDisc

score = (chkA ? 1 : 0) + (chkB ? 1 : 0) + (chkC ? 1 : 0) + (chkE ? 1 : 0)

string lookingFor = "WAITING"
if h4_bias == 0
    lookingFor := "NO BIAS"
else if chkB and chkC
    lookingFor := h4_bias == 1 ? "1m BOS UP -> ENTRY" : "1m BOS DN -> ENTRY"
else if chkB
    lookingFor := "CONFLUENCE ZONE"
else
    lookingFor := "HTF SWEEP or BOS"

// ═══════════════════════════════════════════════════════════════
// R:R CALCULATOR — HTF LEVEL TRACKING
// ═══════════════════════════════════════════════════════════════

rr_h1_ph = request.security(syminfo.tickerid, "60",  ta.pivothigh(high, rrPiv1H, rrPiv1H), lookahead=barmerge.lookahead_off)
rr_h1_pl = request.security(syminfo.tickerid, "60",  ta.pivotlow(low, rrPiv1H, rrPiv1H),   lookahead=barmerge.lookahead_off)
rr_h4_ph = request.security(syminfo.tickerid, "240", ta.pivothigh(high, rrPiv4H, rrPiv4H), lookahead=barmerge.lookahead_off)
rr_h4_pl = request.security(syminfo.tickerid, "240", ta.pivotlow(low, rrPiv4H, rrPiv4H),   lookahead=barmerge.lookahead_off)

var array<float> unsHighs = array.new_float(0)
var array<float> unsLows  = array.new_float(0)

addIfNew(array<float> arr, float val, int maxSize) =>
    bool isDupe = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if math.abs(array.get(arr, i) - val) < 1.0
                isDupe := true
                break
    if not isDupe
        array.push(arr, val)
        if array.size(arr) > maxSize
            array.shift(arr)

if not na(rr_h1_ph)
    addIfNew(unsHighs, rr_h1_ph, 6)
if not na(rr_h4_ph)
    addIfNew(unsHighs, rr_h4_ph, 6)
if not na(rr_h1_pl)
    addIfNew(unsLows, rr_h1_pl, 6)
if not na(rr_h4_pl)
    addIfNew(unsLows, rr_h4_pl, 6)

if array.size(unsHighs) > 0
    for i = array.size(unsHighs) - 1 to 0
        if close > array.get(unsHighs, i)
            array.remove(unsHighs, i)

if array.size(unsLows) > 0
    for i = array.size(unsLows) - 1 to 0
        if close < array.get(unsLows, i)
            array.remove(unsLows, i)

// ═══════════════════════════════════════════════════════════════
// R:R CALCULATOR — COMPUTE ENTRY / SL / TP / RATIO
// ═══════════════════════════════════════════════════════════════

var float zoneTop = na
var float zoneBot = na

if inBullOB and mainBias == 1
    zoneTop := obBullHi
    zoneBot := obBullLo
else if inBearOB and mainBias == -1
    zoneTop := obBearHi
    zoneBot := obBearLo
else if hasFVG and fvgDir == 1 and mainBias == 1
    zoneTop := fvgBullTop
    zoneBot := fvgBullBot
else if hasFVG and fvgDir == -1 and mainBias == -1
    zoneTop := fvgBearTop
    zoneBot := fvgBearBot

float rrEntry = na
float rrSL    = na
float rrTP    = na
float rrRisk  = na
float rrReward = na
float rrRatio  = na
float rrRiskDollars  = na
float rrRewardDollars = na
string rrStatus = "NO ZONE"

// MNQ: $0.50 per tick, 4 ticks per point = $2.00 per point per contract
float dollarPerPt = 2.0

if not na(zoneTop) and not na(zoneBot) and mainBias != 0
    if mainBias == 1
        rrEntry := (zoneTop + zoneBot) / 2.0
        rrSL    := zoneBot - rrSlBuffer
        float nearestHigh = na
        if array.size(unsHighs) > 0
            for i = 0 to array.size(unsHighs) - 1
                float lvl = array.get(unsHighs, i)
                if lvl > rrEntry
                    if na(nearestHigh) or lvl < nearestHigh
                        nearestHigh := lvl
        rrTP := nearestHigh

    else if mainBias == -1
        rrEntry := (zoneTop + zoneBot) / 2.0
        rrSL    := zoneTop + rrSlBuffer
        float nearestLow = na
        if array.size(unsLows) > 0
            for i = 0 to array.size(unsLows) - 1
                float lvl = array.get(unsLows, i)
                if lvl < rrEntry
                    if na(nearestLow) or lvl > nearestLow
                        nearestLow := lvl
        rrTP := nearestLow

    if not na(rrEntry) and not na(rrSL) and not na(rrTP)
        rrRisk   := math.abs(rrEntry - rrSL)
        rrReward := math.abs(rrTP - rrEntry)
        if rrRisk > 0
            rrRatio := rrReward / rrRisk
        rrRiskDollars   := rrRisk * dollarPerPt * rrContracts
        rrRewardDollars := rrReward * dollarPerPt * rrContracts
        if rrRatio >= rrMinRR
            rrStatus := "VALID"
        else
            rrStatus := "SKIP"
    else if na(rrTP)
        rrStatus := "NO TP"

// ═══════════════════════════════════════════════════════════════
// TABLE DISPLAY
// ═══════════════════════════════════════════════════════════════

var table t = table.new(position.top_right, 3, 15, border_width=1, border_color=c_border, frame_width=0)

if barstate.islast

    // --- Row 0: Header ---
    table.cell(t, 0, 0, "Checklist",   text_color=c_txthdr, text_size=size.small, bgcolor=c_bg, text_halign=text.align_left)
    table.cell(t, 1, 0, "Value",       text_color=c_txthdr, text_size=size.small, bgcolor=c_bg, text_halign=text.align_center)
    table.cell(t, 2, 0, "Status",      text_color=c_txthdr, text_size=size.small, bgcolor=c_bg, text_halign=text.align_right)

    // --- Row 1: 4H Bias ---
    color biasCol = h4_bias == 1 ? c_green : h4_bias == -1 ? c_red : c_txt
    table.cell(t, 0, 1, "4H Bias",     text_color=c_txt, text_size=size.small, bgcolor=c_bg, text_halign=text.align_left)
    table.cell(t, 1, 1, dirTxt(h4_bias), text_color=biasCol, text_size=size.small, bgcolor=c_bg, text_halign=text.align_center)
    table.cell(t, 2, 1, h4_bias != 0 ? "YES" : "--", text_color=h4_bias != 0 ? c_green : c_txthdr, text_size=size.small, bgcolor=c_bg, text_halign=text.align_right)

    // --- Row 2: 1H Trend ---
    color trendCol = h1_trend == 1 ? c_green : h1_trend == -1 ? c_red : c_txt
    string alignTxt = isAligned ? "ALIGNED" : "MIXED"
    table.cell(t, 0, 2, "1H Trend",    text_color=c_txt, text_size=size.small, bgcolor=c_bg, text_halign=text.align_left)
    table.cell(t, 1, 2, dirTxt(h1_trend) + "  " + alignTxt, text_color=trendCol, text_size=size.small, bgcolor=c_bg, text_halign=text.align_center)
    table.cell(t, 2, 2, chkA ? "YES" : "--", text_color=chkA ? c_green : c_txthdr, text_size=size.small, bgcolor=c_bg, text_halign=text.align_right)
````
