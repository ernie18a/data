# AZT Strategy V11 First Draft

- url: https://www.tradingview.com/script/BmKZsX1b-AZT-Strategy-V11-First-Draft/
- type: indicator
- pine_id: PUB;b60c09922a064186b9f12a28d5f1787c
- version: 1.0

## Description

This strategy follow multi time frame analysis, bar by bar/candle analysis, market structure and indicators to take into account trade positions

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nightowlxtrader
//@version=6
plot(close)
//@version=6
indicator("AZT Strategy — Core v11 (2m + mirrored 5m signal on one chart)", "AZT Core v11", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================================
//  AZT STRATEGY — CORE v9  (stripped to the parts you trust + verify)
//  >>> Run on the 2-MINUTE chart. HTF + 15m/5m read in BACKGROUND.
//
//  KEPT (and meant to be 100% faithful + checkable):
//   - Bar-by-bar structure bias on 1H / 4H / D / 15m / 5m / 2m.
//   - 5m 9/20 EMA cross.
//   - 2m cluster of 200 EMA + VWAP (the FF trigger line is NOT computed — you
//     confirm it by eye and take the setup if it's there).
//   - EMAs as confluence, regime classifier, 2m candle trigger (all toggleable).
//   - Session opens NYO / Globex / London — auto-erased after N days (default 2),
//     and the next opens keep getting marked automatically.
//   - Dashboard + Verification mode so every claim is checkable vs TradingView's
//     own 9 / 20 / 200 EMA + VWAP.
//
//  REMOVED (you plot these manually now):
//   - Hourly RTH levels, channels, AOIs, prior-day H/L levels, manual levels.
//   - The 65-length proxy "trigger line" (couldn't reproduce the real FF trigger).
//
//  Decision-support, NOT a guaranteed win rate. Out-of-sample test first.
// ============================================================================

sym = syminfo.tickerid

// ----------------------------- INPUTS ---------------------------------------
gDir   = "① Direction & Tier"
allowLongs   = input.bool(true,  "Allow longs",  group=gDir)
allowShorts  = input.bool(true,  "Allow shorts", group=gDir)
minTier      = input.string("A+", "Minimum tier to signal", options=["A+","S","S+"], group=gDir)
confirmClose = input.bool(true,  "Only confirm on bar close (recommended)", group=gDir)

gWhat  = "② Direction definition (bar-by-bar bias)"
useStruct = input.bool(true,  "Use market structure (BOS/CHoCH)", group=gWhat)
useEMA    = input.bool(false, "Also require EMA stack agreement", group=gWhat)
biasLen   = input.int(50, "EMA length (if EMA stack on)", minval=5, group=gWhat)
pivLen    = input.int(5,  "Swing pivot strength", minval=1, group=gWhat)

gEntry = "③ Entry-TF Alignment (15m / 5m / 2m)"
reqAlign   = input.bool(true, "Require structure alignment 2m+5m+15m", group=gEntry)
req5mCross = input.bool(true, "Require 5m 9/20 EMA cross", group=gEntry)
recentOnly = input.bool(true, "5m cross must be recent", group=gEntry)
recentBars = input.int(15, "…within N (2m) bars", minval=1, group=gEntry)

gCandle = "④ Candle Trigger (2m, follow-through)"
reqCandle = input.bool(true,  "Require confirmed candle trigger", group=gCandle)
useEngulf = input.bool(true,  "Engulfing", group=gCandle)
usePin    = input.bool(true,  "Pin / hammer / shooting star", group=gCandle)
useDojiR  = input.bool(true,  "Doji rejection (gravestone/dragonfly)", group=gCandle)
bodySmall = input.float(0.35, "Small-body max (× range)", step=0.05, group=gCandle)
wickLong  = input.float(0.55, "Long-wick min (× range)", step=0.05, group=gCandle)
dojiMax   = input.float(0.12, "Doji body max (× range)", step=0.02, group=gCandle)

gClus  = "⑤ 2m Cluster (200 EMA + VWAP)"
useCluster = input.bool(true, "Require 2m cluster + close beyond", group=gClus)
clusEmaLen = input.int(200, "Cluster EMA length", minval=1, group=gClus)
tolMode    = input.string("ATR", "Cluster tightness", options=["ATR","Points"], group=gClus)
tolAtr     = input.float(0.6, "…ATR multiple", step=0.1, group=gClus)
tolPts     = input.float(8.0, "…or fixed points", step=0.5, group=gClus)

gSess  = "⑥ Session Opens"
showLines       = input.bool(true, "Mark session opens (NYO / Globex / London)", group=gSess)
sessKeepDays    = input.int(2, "Erase each open after N days", minval=1, maxval=10, group=gSess)
showLevelLabels = input.bool(true, "Show price labels on opens", group=gSess)

gRisk  = "⑦ Stop & Targets"
stopLB     = input.int(10, "Stop swing lookback (to wick)", minval=1, group=gRisk)
stopBufAtr = input.float(0.1, "Stop buffer (ATR mult)", step=0.05, group=gRisk)

gReg   = "⑧ Regime"
skipChop    = input.bool(true,  "Skip signals when regime = Chop", group=gReg)
regimeWin   = input.int(20, "Structural-event recency (bars)", minval=1, group=gReg)
chopAtrMult = input.float(1.5, "Chop range threshold (× ATR)", step=0.1, group=gReg)

gTrig  = "⑨ 2m Trigger Line (200 EMA + VWAP blend)"
showTrigLine     = input.bool(true,  "Show 2m trigger line (green/red/grey)", group=gTrig)
trigWeight       = input.float(0.5,  "Blend weight: EMA vs VWAP (1=all EMA, 0=all VWAP)", minval=0.0, maxval=1.0, step=0.1, group=gTrig)
markEmaVwapCross = input.bool(true,  "Dot where 200 EMA & VWAP cross", group=gTrig)
show5mTrigger    = input.bool(true,  "Mark 5m 9/20 cross on this chart", group=gTrig)
show5mSignal     = input.bool(true,  "Mirror full 5m A+ signal onto this chart (square marker)", group=gTrig)

gUX    = "⑩ Display"
showDash    = input.bool(true,  "Show dashboard", group=gUX)
dashPos     = input.string("top_right", "Dashboard position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=gUX)
showPlots   = input.bool(false, "Plot 200 EMA + VWAP (off if you already have them)", group=gUX)
showLvlInfo = input.bool(true,  "Signal label + drawn SL/TP", group=gUX)
verify      = input.bool(false, "Verification mode (plot 9/20/200 + values)", group=gUX)

// ----------------------------- STRUCTURE ENGINE (bar-by-bar bias) -----------
f_struct() =>
    ph = ta.pivothigh(pivLen, pivLen)
    pl = ta.pivotlow(pivLen, pivLen)
    var float swH = na
    var float swL = na
    var int   d = 0
    if not na(ph)
        swH := ph
    if not na(pl)
        swL := pl
    if not na(swH) and close > swH
        d := 1
    if not na(swL) and close < swL
        d := -1
    eb = not useEMA or close > ta.ema(close, biasLen)
    es = not useEMA or close < ta.ema(close, biasLen)
    o = 0
    if useStruct and d == 1 and eb
        o := 1
    if useStruct and d == -1 and es
        o := -1
    if not useStruct
        e9 = ta.ema(close, 9)
        e20 = ta.ema(close, 20)
        o := e9 > e20 and close > e9 ? 1 : e9 < e20 and close < e9 ? -1 : 0
    o

f5() =>
    s   = f_struct()
    e9  = ta.ema(close, 9)
    e20 = ta.ema(close, 20)
    bull = e9 > e20
    cu  = ta.crossover(e9, e20)
    cd  = ta.crossunder(e9, e20)
    ec  = ta.ema(close, clusEmaLen)
    vw  = ta.vwap
    a   = ta.atr(14)
    [s, bull, cu, cd, ec, vw, a, close]

f15() =>
    s   = f_struct()
    ec  = ta.ema(close, clusEmaLen)
    vw  = ta.vwap
    a   = ta.atr(14)
    [s, ec, vw, a, close]

// 5m-context pieces of the A+ signal, evaluated ON the 5m series so the mirror
// matches what the indicator would print if it were running on a 5m chart.
// (HTF/15m are shared and combined at chart level — they can't live in here.)
f5sig() =>
    // --- 5m candle trigger (same rules as the 2m candle, on 5m bars) ---
    rngc  = math.max(high[1] - low[1], syminfo.mintick)
    bodyc = math.abs(close[1] - open[1])
    upWkc = high[1] - math.max(close[1], open[1])
    loWkc = math.min(close[1], open[1]) - low[1]
    smallc = bodyc <= bodySmall * rngc
    dojic  = bodyc <= dojiMax * rngc
    bEng = close[1] > open[1] and close[2] < open[2] and close[1] >= open[2] and open[1] <= close[2]
    bPin = smallc and loWkc >= wickLong * rngc and upWkc <= bodyc
    bDjr = dojic and loWkc >= wickLong * rngc
    bSig = (useEngulf and bEng) or (usePin and bPin) or (useDojiR and bDjr)
    sEng = close[1] < open[1] and close[2] > open[2] and close[1] <= open[2] and open[1] >= close[2]
    sPin = smallc and upWkc >= wickLong * rngc and loWkc <= bodyc
    sDjr = dojic and upWkc >= wickLong * rngc
    sSig = (useEngulf and sEng) or (usePin and sPin) or (useDojiR and sDjr)
    cBull = not reqCandle or (bSig and close > high[1])
    cBear = not reqCandle or (sSig and close < low[1])
    // --- 5m 9/20 cross recency (in 5m bars) ---
    e9c  = ta.ema(close, 9)
    e20c = ta.ema(close, 20)
    bsCU = ta.barssince(ta.crossover(e9c, e20c))
    bsCD = ta.barssince(ta.crossunder(e9c, e20c))
    rBull = not recentOnly or (not na(bsCU) and bsCU <= recentBars)
    rBear = not recentOnly or (not na(bsCD) and bsCD <= recentBars)
    // --- 5m regime (same logic as 2m regime, on 5m bars) ---
    phc = ta.pivothigh(pivLen, pivLen)
    plc = ta.pivotlow(pivLen, pivLen)
    var float swHc = na
    var float swLc = na
    var int   drc = 0
    var int   evtBc = na
    if not na(phc)
        swHc := phc
    if not na(plc)
        swLc := plc
    a14c = ta.atr(14)
    buc = not na(swHc) and close > swHc and close[1] <= swHc
    bdc = not na(swLc) and close < swLc and close[1] >= swLc
    if buc
        drc := 1
        evtBc := bar_index
    if bdc
        drc := -1
        evtBc := bar_index
    bsec = na(evtBc) ? na : bar_index - evtBc
    swRc = not na(swHc) and not na(swLc) ? math.abs(swHc - swLc) : na
    chopc = na(bsec) or bsec > regimeWin or (not na(swRc) and swRc < chopAtrMult * a14c)
    regOKc = not skipChop or not chopc
    // --- 5m volume + stop levels ---
    vOK = volume > ta.sma(volume, 20)
    stopL = ta.lowest(low, stopLB)  - stopBufAtr * a14c
    stopS = ta.highest(high, stopLB) + stopBufAtr * a14c
    [cBull, cBear, rBull, rBear, regOKc, vOK, stopL, stopS]

f_tierStr(r) => r == 3 ? "S+" : r == 2 ? "S" : "A+"
f_biasStr(b) => b == 1 ? "Bull" : b == -1 ? "Bear" : "—"
f_biasCol(b) => b == 1 ? color.lime : b == -1 ? color.red : color.gray
f_arrow(b)   => b == 1 ? "▲" : b == -1 ? "▼" : "–"
f_money(pts) =>
    str.tostring(pts, "#.##") + " pts / " + str.tostring(pts / syminfo.mintick, "#") + " ticks / $" + str.tostring(pts * syminfo.pointvalue, "#.##")
f_pos(s) =>
    s == "top_left" ? position.top_left : s == "bottom_right" ? position.bottom_right : s == "bottom_left" ? position.bottom_left : s == "middle_right" ? position.middle_right : s == "middle_left" ? position.middle_left : position.top_right

// ----------------------------- CANDLE TRIGGER (2m) --------------------------
rng1  = math.max(high[1] - low[1], syminfo.mintick)
body1 = math.abs(close[1] - open[1])
upWk1 = high[1] - math.max(close[1], open[1])
loWk1 = math.min(close[1], open[1]) - low[1]
smallBody = body1 <= bodySmall * rng1
isDoji    = body1 <= dojiMax * rng1
bullEngulf = close[1] > open[1] and close[2] < open[2] and close[1] >= open[2] and open[1] <= close[2]
bullPin    = smallBody and loWk1 >= wickLong * rng1 and upWk1 <= body1
bullDojiR  = isDoji and loWk1 >= wickLong * rng1
bullSig    = (useEngulf and bullEngulf) or (usePin and bullPin) or (useDojiR and bullDojiR)
bullFollow = close > high[1]
bearEngulf = close[1] < open[1] and close[2] > open[2] and close[1] <= open[2] and open[1] >= close[2]
bearPin    = smallBody and upWk1 >= wickLong * rng1 and loWk1 <= body1
bearDojiR  = isDoji and upWk1 >= wickLong * rng1
bearSig    = (useEngulf and bearEngulf) or (usePin and bearPin) or (useDojiR and bearDojiR)
bearFollow = close < low[1]
candleBull = not reqCandle or (bullSig and bullFollow)
candleBear = not reqCandle or (bearSig and bearFollow)
candleName = bullEngulf or bearEngulf ? "Engulf" : bullPin or bearPin ? "Pin" : bullDojiR or bearDojiR ? "Doji-rej" : "—"

// ----------------------------- HTF & ENTRY DATA -----------------------------
b1 = request.security(sym, "60",  f_struct(), lookahead=barmerge.lookahead_off)
b4 = request.security(sym, "240", f_struct(), lookahead=barmerge.lookahead_off)
bd = request.security(sym, "D",   f_struct(), lookahead=barmerge.lookahead_off)
[s5, bull5, cu5, cd5, ec5, vwap5, atr5, c5] = request.security(sym, "5",  f5(),  lookahead=barmerge.lookahead_off)
[s15, ec15, vwap15, atr15, c15]             = request.security(sym, "15", f15(), lookahead=barmerge.lookahead_off)
[c5Bull, c5Bear, r5Bull, r5Bear, reg5OK, vol5OK, stopL5, stopS5] = request.security(sym, "5", f5sig(), lookahead=barmerge.lookahead_off)

htfBull = b1 == 1 and b4 == 1 and bd == 1
htfBear = b1 == -1 and b4 == -1 and bd == -1
htfBullMaj = (b1 == 1 ? 1 : 0) + (b4 == 1 ? 1 : 0) + (bd == 1 ? 1 : 0) >= 2
htfBearMaj = (b1 == -1 ? 1 : 0) + (b4 == -1 ? 1 : 0) + (bd == -1 ? 1 : 0) >= 2

// ----------------------------- 2m CLUSTER (200 EMA + VWAP) ------------------
e9_2   = ta.ema(close, 9)
e20_2  = ta.ema(close, 20)
e200_2 = ta.ema(close, 200)
emaClu = ta.ema(close, clusEmaLen)
vwap2  = ta.vwap
atr2   = ta.atr(14)
dir2   = f_struct()
tol2 = tolMode == "ATR" ? tolAtr * atr2 : tolPts
hi2  = math.max(emaClu, vwap2)
lo2  = math.min(emaClu, vwap2)
clustered2  = (hi2 - lo2) <= tol2
clusterBull = not useCluster or (clustered2 and close > hi2)
clusterBear = not useCluster or (clustered2 and close < lo2)

tol5  = tolAtr * atr5
tol15 = tolAtr * atr15
hi5  = math.max(ec5, vwap5)
lo5  = math.min(ec5, vwap5)
hi15 = math.max(ec15, vwap15)
lo15 = math.min(ec15, vwap15)
clu5Bull  = (hi5 - lo5) <= tol5 and c5 > hi5
clu15Bull = (hi15 - lo15) <= tol15 and c15 > hi15
clu5Bear  = (hi5 - lo5) <= tol5 and c5 < lo5
clu15Bear = (hi15 - lo15) <= tol15 and c15 < lo15
multiCluBull = clustered2 and close > hi2 and clu5Bull and clu15Bull
multiCluBear = clustered2 and close < lo2 and clu5Bear and clu15Bear

// ----------------------------- 2m TRIGGER LINE (200 EMA + VWAP blend) -------
// Blend the 200 EMA and VWAP into one "trigger line" (weight adjustable, like the
// FF idea). Its color is the live 2m read: GREEN when price is above both lines
// (bullish), RED when below both (bearish), GREY when price sits between them
// (chop). The bar where the 200 EMA and VWAP actually cross gets a dot in that
// color. Plus the 5m 9/20 cross is flagged right here on the 2m chart.
trig2    = trigWeight * emaClu + (1.0 - trigWeight) * vwap2
trigBull = close > math.max(emaClu, vwap2)
trigBear = close < math.min(emaClu, vwap2)
trigState = trigBull ? "Bull" : trigBear ? "Bear" : "Chop"
trigCol   = trigBull ? color.lime : trigBear ? color.red : color.gray
emaVwapCross = ta.cross(emaClu, vwap2)
// 5m 9/20 cross, mapped to a single 2m bar (cu5/cd5 already pulled from the 5m TF)
bull5cross = cu5 and not cu5[1]
bear5cross = cd5 and not cd5[1]

// ----------------------------- REGIME (2m) ----------------------------------
phc = ta.pivothigh(pivLen, pivLen)
plc = ta.pivotlow(pivLen, pivLen)
var float cSwH = na
var float cSwL = na
var int   cDir = 0
var string lastEvt = "none"
var int   evtBar = na
if not na(phc)
    cSwH := phc
if not na(plc)
    cSwL := plc
brkU = not na(cSwH) and close > cSwH and close[1] <= cSwH
brkD = not na(cSwL) and close < cSwL and close[1] >= cSwL
if brkU
    lastEvt := cDir == 1 ? "BOS" : "CHoCH"
    cDir := 1
    evtBar := bar_index
if brkD
    lastEvt := cDir == -1 ? "BOS" : "CHoCH"
    cDir := -1
    evtBar := bar_index
barsSinceEvt = na(evtBar) ? na : bar_index - evtBar
swRange = not na(cSwH) and not na(cSwL) ? math.abs(cSwH - cSwL) : na
isChop = na(barsSinceEvt) or barsSinceEvt > regimeWin or (not na(swRange) and swRange < chopAtrMult * atr2)
regime = isChop ? "Chop" : lastEvt == "CHoCH" ? "Reversal" : "Continuation"
regimeCol = regime == "Continuation" ? color.lime : regime == "Reversal" ? color.orange : color.gray
regimeOK = not skipChop or regime != "Chop"

// ----------------------------- SESSION OPENS (auto-erase after N days) ------
tz = "America/Los_Angeles"
hr = hour(time, tz)
mn = minute(time, tz)
tmin = hr * 60 + mn
inNY = tmin >= 390 and tmin < 780
inLondon = tmin >= 0 and tmin < 390
inAsia = tmin >= 900
sessName = inNY ? "NY" : inLondon ? "London" : inAsia ? "Asia/Globex" : "Off-session"
sessMax  = inNY ? 60.0 : inLondon ? 40.0 : inAsia ? 30.0 : 20.0
sessMin  = inNY ? 30.0 : inLondon ? 15.0 : inAsia ? 10.0 : 8.0

var arrSessLine = array.new_line()
var arrSessLab  = array.new_label()
var arrSessTime = array.new_int()
f_addSess(_px, _txt, _col, _txtcol) =>
    ln = line.new(bar_index - 1, _px, bar_index, _px, extend=extend.right, color=color.new(_col, 0), width=2)
    lb = showLevelLabels ? label.new(bar_index, _px, _txt, style=label.style_label_left, color=color.new(_col, 0), textcolor=_txtcol, size=size.tiny) : na
    array.push(arrSessLine, ln)
    array.push(arrSessLab, lb)
    array.push(arrSessTime, time)

if showLines and hr == 6 and mn == 30
    f_addSess(open, "NYO " + str.tostring(open, format.mintick), color.lime, color.black)
if showLines and hr == 15 and mn == 0
    f_addSess(open, "GLOBEX " + str.tostring(open, format.mintick), color.purple, color.white)
if showLines and hr == 0 and mn == 0
    f_addSess(open, "LONDON " + str.tostring(open, format.mintick), color.blue, color.white)

// erase opens older than N days
maxAgeMs = sessKeepDays * 24 * 60 * 60 * 1000
if array.size(arrSessTime) > 0
    k = 0
    while k < array.size(arrSessTime)
        if time - array.get(arrSessTime, k) > maxAgeMs
            ln = array.get(arrSessLine, k)
            lb = array.get(arrSessLab, k)
            if not na(ln)
                line.delete(ln)
            if not na(lb)
                label.delete(lb)
            array.remove(arrSessLine, k)
            array.remove(arrSessLab, k)
            array.remove(arrSessTime, k)
        else
            k += 1

// ----------------------------- ENTRY LOGIC / TIERS --------------------------
barsSinceCU = ta.barssince(cu5)
barsSinceCD = ta.barssince(cd5)
recentBull5 = not recentOnly or (not na(barsSinceCU) and barsSinceCU <= recentBars)
recentBear5 = not recentOnly or (not na(barsSinceCD) and barsSinceCD <= recentBars)
core5Bull = not req5mCross or (bull5 and recentBull5)
core5Bear = not req5mCross or (not bull5 and recentBear5)
alignBull = not reqAlign or (dir2 == 1 and s5 == 1 and s15 == 1)
alignBear = not reqAlign or (dir2 == -1 and s5 == -1 and s15 == -1)
volConfirm = volume > ta.sma(volume, 20)

baseLong  = allowLongs  and htfBullMaj and s15 == 1  and alignBull and core5Bull and clusterBull and candleBull and regimeOK
baseShort = allowShorts and htfBearMaj and s15 == -1 and alignBear and core5Bear and clusterBear and candleBear and regimeOK
sLong  = baseLong  and htfBull and volConfirm
sShort = baseShort and htfBear and volConfirm
spLong  = sLong  and multiCluBull
spShort = sShort and multiCluBear
tierLong  = spLong  ? 3 : sLong  ? 2 : baseLong  ? 1 : 0
tierShort = spShort ? 3 : sShort ? 2 : baseShort ? 1 : 0
minRank   = minTier == "S+" ? 3 : minTier == "S" ? 2 : 1
confirmed = not confirmClose or barstate.isconfirmed
longSig  = confirmed and tierLong  >= minRank
shortSig = confirmed and tierShort >= minRank
longFirst  = longSig  and not longSig[1]
shortFirst = shortSig and not shortSig[1]

longBlk  = not htfBullMaj ? "HTF bias" : s15 != 1 ? "15m struct" : not alignBull ? "2/5/15 align" : not core5Bull ? "5m 9/20 cross" : not clusterBull ? "2m cluster" : not candleBull ? "2m candle" : not regimeOK ? "regime=chop" : "READY"
shortBlk = not htfBearMaj ? "HTF bias" : s15 != -1 ? "15m struct" : not alignBear ? "2/5/15 align" : not core5Bear ? "5m 9/20 cross" : not clusterBear ? "2m cluster" : not candleBear ? "2m candle" : not regimeOK ? "regime=chop" : "READY"
blocker = htfBullMaj ? longBlk : htfBearMaj ? shortBlk : "HTF bias"

// ----------------------------- MIRRORED 5m A+ SIGNAL ------------------------
// Same pipeline as the 2m signal, but using the 5m-context pieces (f5sig) plus
// the shared HTF/15m read. On a 5m chart dir2==s5, so 2/5/15 alignment reduces
// to s5==s15. Fires on the bar the 5m read confirms.
align5Bull = s5 == 1 and s15 == 1
align5Bear = s5 == -1 and s15 == -1
core5BullM = not req5mCross or (bull5 and r5Bull)
core5BearM = not req5mCross or (not bull5 and r5Bear)
cluster5Bull = not useCluster or clu5Bull
cluster5Bear = not useCluster or clu5Bear
base5Long  = allowLongs  and htfBullMaj and s15 == 1  and align5Bull and core5BullM and cluster5Bull and c5Bull and reg5OK
base5Short = allowShorts and htfBearMaj and s15 == -1 and align5Bear and core5BearM and cluster5Bear and c5Bear and reg5OK
s5LongM  = base5Long  and htfBull and vol5OK
s5ShortM = base5Short and htfBear and vol5OK
sp5LongM  = s5LongM  and clu5Bull and clu15Bull
sp5ShortM = s5ShortM and clu5Bear and clu15Bear
tier5Long  = sp5LongM  ? 3 : s5LongM  ? 2 : base5Long  ? 1 : 0
tier5Short = sp5ShortM ? 3 : s5ShortM ? 2 : base5Short ? 1 : 0
sig5Long  = (not confirmClose or barstate.isconfirmed) and tier5Long  >= minRank
sig5Short = (not confirmClose or barstate.isconfirmed) and tier5Short >= minRank
sig5LongFirst  = sig5Long  and not sig5Long[1]
sig5ShortFirst = sig5Short and not sig5Short[1]
risk5Long  = c5 - stopL5
risk5Short = stopS5 - c5

// ----------------------------- STOP & TARGETS -------------------------------
// Targets are session-points based now (no levels): TP1 = 1R, Runner = session max points.
buf = stopBufAtr * atr2
entry = close
longStop  = ta.lowest(low, stopLB)  - buf
shortStop = ta.highest(high, stopLB) + buf
riskL = entry - longStop
riskS = shortStop - entry
t1L = entry + riskL
t1S = entry - riskS
runnerL = entry + sessMax
runnerS = entry - sessMax
rMultL = riskL <= 0 ? na : sessMax / riskL
rMultS = riskS <= 0 ? na : sessMax / riskS
dirBias = htfBullMaj ? 1 : htfBearMaj ? -1 : 1
prevRisk = dirBias == -1 ? riskS : riskL
prevRunR = dirBias == -1 ? rMultS : rMultL

crossTxt = na(barsSinceCU) and na(barsSinceCD) ? "No cross" : bull5 ? ("Bull " + (not na(barsSinceCU) and barsSinceCU <= recentBars ? "(recent)" : "(old)")) : ("Bear " + (not na(barsSinceCD) and barsSinceCD <= recentBars ? "(recent)" : "(old)"))
crossCol = bull5 ? color.lime : color.red

// ----------------------------- DRAWN POSITION (latest signal) ---------------
var line lnE = na
var line lnS = na
var line lnT = na
var line lnR = na
var box  bxRisk = na
var box  bxRwd  = na
if showLvlInfo and (longFirst or shortFirst)
    if not na(lnE)
        line.delete(lnE)
    if not na(lnS)
        line.delete(lnS)
    if not na(lnT)
        line.delete(lnT)
    if not na(lnR)
        line.delete(lnR)
    if not na(bxRisk)
        box.delete(bxRisk)
    if not na(bxRwd)
        box.delete(bxRwd)
    e = entry
    sp = longFirst ? longStop : shortStop
    tp1 = longFirst ? t1L : t1S
    rn = longFirst ? runnerL : runnerS
    lnE := line.new(bar_index - 1, e,   bar_index, e,   extend=extend.right, color=color.new(color.gray, 0),  width=1, style=line.style_dashed)
    lnS := line.new(bar_index - 1, sp,  bar_index, sp,  extend=extend.right, color=color.new(color.red, 0),   width=2)
    lnT := line.new(bar_index - 1, tp1, bar_index, tp1, extend=extend.right, color=color.new(color.green, 0), width=2)
    lnR := line.new(bar_index - 1, rn,  bar_index, rn,  extend=extend.right, color=color.new(color.aqua, 0),  width=1, style=line.style_dotted)
    rTop = math.max(e, sp)
    rBot = math.min(e, sp)
    bxRisk := box.new(left=bar_index - 1, top=rTop, right=bar_index, bottom=rBot, extend=extend.right, bgcolor=color.new(color.red, 86), border_color=color.new(color.red, 60), border_width=1)
    wTop = math.max(e, tp1)
    wBot = math.min(e, tp1)
    bxRwd := box.new(left=bar_index - 1, top=wTop, right=bar_index, bottom=wBot, extend=extend.right, bgcolor=color.new(color.green, 86), border_color=color.new(color.green, 60), border_width=1)

// ----------------------------- PLOTS ----------------------------------------
plot(showPlots ? emaClu : na, "200 EMA (cluster)", color=color.new(color.orange, 0), linewidth=2)
plot(showPlots ? vwap2 : na,  "VWAP",              color=color.new(color.yellow, 0))
plot(verify ? e9_2 : na,   "9 EMA",   color=color.new(color.aqua, 0))
plot(verify ? e20_2 : na,  "20 EMA",  color=color.new(color.fuchsia, 0))
plot(verify ? e200_2 : na, "200 EMA", color=color.new(color.orange, 40))

// 2m trigger line: blended EMA+VWAP, colored by live read (green/red/grey)
plot(showTrigLine ? trig2 : na, "2m Trigger", color=trigCol, linewidth=3)
// dot on the bar where 200 EMA and VWAP actually cross
plot(showTrigLine and markEmaVwapCross and emaVwapCross ? trig2 : na, "EMA/VWAP cross", color=trigCol, style=plot.style_circles, linewidth=5)
// 5m 9/20 cross flagged on this 2m chart (green = 9 over 20, red = 9 under 20)
plotshape(show5mTrigger and bull5cross, "5m cross up",   shape.diamond, location.belowbar, color.new(color.lime, 0), size=size.tiny)
plotshape(show5mTrigger and bear5cross, "5m cross down", shape.diamond, location.abovebar, color.new(color.red, 0),  size=size.tiny)

bgcolor(longFirst ? color.new(color.green, 88) : shortFirst ? color.new(color.red, 88) : na)
plotshape(longFirst,  "Long Signal",  shape.triangleup,   location.belowbar, color.new(color.lime, 0), size=size.small)
plotshape(shortFirst, "Short Signal", shape.triangledown, location.abovebar, color.new(color.red, 0),  size=size.small)

if showLvlInfo and longFirst
    txt = "▲ " + f_tierStr(tierLong) + " LONG · " + regime + " [" + candleName + "]\nEntry " + str.tostring(entry, format.mintick) + "\nStop " + str.tostring(longStop, format.mintick) + "\n   " + f_money(riskL) + "\nTP1 1R " + str.tostring(t1L, format.mintick) + "\nRunner " + str.tostring(runnerL, format.mintick) + " (" + str.tostring(rMultL, "#.#") + "R · " + f_money(runnerL - entry) + ")\n" + sessName + " " + str.tostring(sessMin, "#") + "-" + str.tostring(sessMax, "#") + "p"
    label.new(bar_index, low, txt, style=label.style_label_up, color=color.new(color.green, 15), textcolor=color.white, size=size.small)
if showLvlInfo and shortFirst
    txt = "▼ " + f_tierStr(tierShort) + " SHORT · " + regime + " [" + candleName + "]\nEntry " + str.tostring(entry, format.mintick) + "\nStop " + str.tostring(shortStop, format.mintick) + "\n   " + f_money(riskS) + "\nTP1 1R " + str.tostring(t1S, format.mintick) + "\nRunner " + str.tostring(runnerS, format.mintick) + " (" + str.tostring(rMultS, "#.#") + "R · " + f_money(entry - runnerS) + ")\n" + sessName + " " + str.tostring(sessMin, "#") + "-" + str.tostring(sessMax, "#") + "p"
    label.new(bar_index, high, txt, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.small)

// mirrored 5m A+ signal — distinct SQUARE marker (green=long, red=short) so you
// can tell it apart from the 2m triangles, plus a compact label with 5m levels.
plotshape(show5mSignal and sig5LongFirst,  "5m Long",  shape.square, location.belowbar, color.new(color.lime, 0), size=size.small)
plotshape(show5mSignal and sig5ShortFirst, "5m Short", shape.square, location.abovebar, color.new(color.red, 0),  size=size.small)
if show5mSignal and sig5LongFirst
    txt5 = "■ 5m " + f_tierStr(tier5Long) + " LONG\nEntry " + str.tostring(c5, format.mintick) + "\nStop " + str.tostring(stopL5, format.mintick) + "\n   " + f_money(risk5Long)
    label.new(bar_index, low, txt5, style=label.style_label_up, color=color.new(color.teal, 10), textcolor=color.white, size=size.small)
if show5mSignal and sig5ShortFirst
    txt5 = "■ 5m " + f_tierStr(tier5Short) + " SHORT\nEntry " + str.tostring(c5, format.mintick) + "\nStop " + str.tostring(stopS5, format.mintick) + "\n   " + f_money(risk5Short)
    label.new(bar_index, high, txt5, style=label.style_label_down, color=color.new(color.maroon, 10), textcolor=color.white, size=size.small)

// ----------------------------- DASHBOARD ------------------------------------
var table dash = table.new(f_pos(dashPos), 2, 21, border_width=1)
if showDash and barstate.islast
    verdict = longSig ? ("TAKE LONG " + f_tierStr(tierLong)) : shortSig ? ("TAKE SHORT " + f_tierStr(tierShort)) : "WAIT"
    vCol = longSig ? color.lime : shortSig ? color.red : color.gray
    verdict5 = tier5Long >= minRank ? ("5m LONG " + f_tierStr(tier5Long)) : tier5Short >= minRank ? ("5m SHORT " + f_tierStr(tier5Short)) : "WAIT"
    v5Col = tier5Long >= minRank ? color.lime : tier5Short >= minRank ? color.red : color.gray
    aBull = dir2 == 1 and s5 == 1 and s15 == 1
    aBear = dir2 == -1 and s5 == -1 and s15 == -1
    kbg = color.new(color.gray, 70)
    vbg = color.new(color.black, 50)
    table.cell(dash, 0, 0,  "VERDICT",       text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 0,  verdict,          text_color=vCol,        text_size=size.small, bgcolor=vbg)
    table.cell(dash, 0, 1,  "Waiting on",     text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 1,  (longSig or shortSig) ? "—" : blocker, text_color=color.yellow, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 2,  "Regime",         text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 2,  regime,           text_color=regimeCol,   text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 3,  "1H struct",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 3,  f_biasStr(b1),    text_color=f_biasCol(b1), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 4,  "4H struct",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 4,  f_biasStr(b4),    text_color=f_biasCol(b4), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 5,  "Daily struct",   text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 5,  f_biasStr(bd),    text_color=f_biasCol(bd), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 6,  "15m struct",     text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 6,  f_biasStr(s15),   text_color=f_biasCol(s15), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 7,  "5m struct",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 7,  f_biasStr(s5),    text_color=f_biasCol(s5), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 8,  "2m struct",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 8,  f_biasStr(dir2),  text_color=f_biasCol(dir2), text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 9,  "Align 2/5/15",   text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 9,  aBull ? "Bull" : aBear ? "Bear" : "Mixed", text_color=aBull ? color.lime : aBear ? color.red : color.gray, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 10, "5m 9/20 cross",  text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 10, crossTxt,         text_color=crossCol,    text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 11, "2m candle",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 11, (bullSig and bullFollow) ? ("Bull " + candleName) : (bearSig and bearFollow) ? ("Bear " + candleName) : "—", text_color=(bullSig and bullFollow) ? color.lime : (bearSig and bearFollow) ? color.red : color.gray, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 12, "2m cluster",     text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 12, (clustered2 and close > hi2) ? "Above" : (clustered2 and close < lo2) ? "Below" : "None", text_color=(clustered2 and close > hi2) ? color.lime : (clustered2 and close < lo2) ? color.red : color.gray, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 13, "2m trigger",     text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 13, trigState,        text_color=trigCol,     text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 14, "Session",        text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 14, sessName + " " + str.tostring(sessMin, "#") + "-" + str.tostring(sessMax, "#") + "p", text_color=color.aqua, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 15, "Est 1R / run",   text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 15, f_money(prevRisk) + (na(prevRunR) ? "" : "  ·  " + str.tostring(prevRunR, "#.#") + "R"), text_color=color.orange, text_size=size.tiny, bgcolor=vbg)
    table.cell(dash, 0, 16, "5m signal",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
    table.cell(dash, 1, 16, verdict5,         text_color=v5Col,       text_size=size.tiny, bgcolor=vbg)
    if verify
        table.cell(dash, 0, 17, "200 EMA",    text_color=color.white, text_size=size.tiny, bgcolor=kbg)
        table.cell(dash, 1, 17, str.tostring(e200_2, format.mintick), text_color=color.orange,  text_size=size.tiny, bgcolor=vbg)
        table.cell(dash, 0, 18, "9 EMA",       text_color=color.white, text_size=size.tiny, bgcolor=kbg)
        table.cell(dash, 1, 18, str.tostring(e9_2, format.mintick),  text_color=color.aqua,    text_size=size.tiny, bgcolor=vbg)
        table.cell(dash, 0, 19, "20 EMA",      text_color=color.white, text_size=size.tiny, bgcolor=kbg)
        table.cell(dash, 1, 19, str.tostring(e20_2, format.mintick), text_color=color.fuchsia, text_size=size.tiny, bgcolor=vbg)
        table.cell(dash, 0, 20, "VWAP",        text_color=color.white, text_size=size.tiny, bgcolor=kbg)
        table.cell(dash, 1, 20, str.tostring(vwap2, format.mintick), text_color=color.yellow,  text_size=size.tiny, bgcolor=vbg)

// ----------------------------- ALERTS ---------------------------------------
alertcondition(longFirst,  "AZT Long",  "AZT LONG setup")
alertcondition(shortFirst, "AZT Short", "AZT SHORT setup")
if longFirst
    alert("AZT " + f_tierStr(tierLong) + " LONG " + regime + " " + candleName + " | entry " + str.tostring(entry, format.mintick) + " | stop " + str.tostring(longStop, format.mintick) + " | risk " + f_money(riskL), alert.freq_once_per_bar_close)
if shortFirst
    alert("AZT " + f_tierStr(tierShort) + " SHORT " + regime + " " + candleName + " | entry " + str.tostring(entry, format.mintick) + " | stop " + str.tostring(shortStop, format.mintick) + " | risk " + f_money(riskS), alert.freq_once_per_bar_close)
alertcondition(sig5LongFirst,  "AZT 5m Long",  "AZT 5m LONG setup (mirrored)")
alertcondition(sig5ShortFirst, "AZT 5m Short", "AZT 5m SHORT setup (mirrored)")
if sig5LongFirst
    alert("AZT 5m " + f_tierStr(tier5Long) + " LONG | entry " + str.tostring(c5, format.mintick) + " | stop " + str.tostring(stopL5, format.mintick) + " | risk " + f_money(risk5Long), alert.freq_once_per_bar_close)
if sig5ShortFirst
    alert("AZT 5m " + f_tierStr(tier5Short) + " SHORT | entry " + str.tostring(c5, format.mintick) + " | stop " + str.tostring(stopS5, format.mintick) + " | risk " + f_money(risk5Short), alert.freq_once_per_bar_close)
````
