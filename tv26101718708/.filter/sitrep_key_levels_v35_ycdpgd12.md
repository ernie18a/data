# SITREP Key Levels v3.5

- url: https://www.tradingview.com/script/yCdPgD12-SITREP-Key-Levels-v3-5/
- type: indicator
- pine_id: PUB;3fc34716acac4b00807c633c9522749f
- version: 10.0

## Description

SITREP Key Levels
Plots the four key levels that define each day's structure: Previous Day High/Low (PDH/PDL) and Pre-Market High/Low (PMH/PML), with optional 15-min structure pivots.
Levels are origin-anchored to the candle that created them. Pre-market levels track dynamically from 1:00–6:30 AM PT, then freeze at the open. At the open, the nearest level above and below price are marked gold as the day's gates; they turn cyan at EOD if they survive unbroken.
A level is broken when a 15-min candle body closes through it (2-min closes never count). Broken levels stay as reference through the session, then clear at EOD. Levels that survive untested gain a day-count tag (D1, D2…) and a wick-rejection count (w1, w2…) — so a level's age and how many times it's held are visible at a glance.
All computation runs on 15-min data, so levels render identically on any chart timeframe. Toggle "Current day only" to show just today's four key levels — ideal for a clean 2-min execution chart.

## Source Code

````pine
//@version=6
// =============================================================================
// SITREP KEY LEVELS v5.3
//
// LEVELS (draw your own zones):
//   PDH / PDL  gold   - prior NYSE session high/low, WICK extremes
//   PMH / PML  cyan   - pre-market high/low, BODY extremes, 15m basis
//   PWH / PWL  orange - previous futures week high/low (1h basis), default OFF
//   200 EMA    red    - default ON, drawn and in the legend. NOT in the RIDE/CUT
//                       math: it differs by chart timeframe, so counting it made
//                       two charts disagree. Verdict uses PDH/PDL/PMH/PML only
//                       (plus PWH/PWL when shown), identical on every chart.
//
// LEGEND (top right, pinned to the pane, sorted by price):
//   level rows, then ONE row:
//     NY ATR = 20-day average NY AM range (09:30-12:00 ET), today excluded.
//              This is the number leading INTO the open. Log this one.
//
// ATR REACH LINES (purple):
//   Two short lines at price + NY ATR and price - NY ATR.
//   They track price from 09:00 to 09:30 ET (6:00-6:30 PT), then freeze,
//   anchored to the 09:30 open. Outer bounds of an average session.
//
// On-chart session labels (optional) still show range · avg, and the NY label
// carries the RIDE / CUT read.
// =============================================================================

indicator("SITREP Key Levels v5", shorttitle="SITREP·KL", overlay=true,
     max_lines_count=20, max_labels_count=25)

// ============================================================================
// INPUTS
// ============================================================================
gLvl   = "Levels"
gSess  = "Session Ranges"
gAtr   = "ATR Reach Lines"
gCalc  = "Reach Logic"
gMA    = "200 EMA"
gStyle = "Style"

showPD   = input.bool(true,  "Show PDH / PDL", group=gLvl)
showPM   = input.bool(true,  "Show PMH / PML", group=gLvl)
showPW   = input.bool(false, "Show PWH / PWL", group=gLvl)
showLbls = input.bool(true,  "Show level legend", group=gLvl)
lgdPos   = input.string("Top right", "Legend position", group=gLvl,
     options=["Top right", "Middle right", "Bottom right"])
lgdPts   = input.int(11, "Legend text size (points)", minval=6, maxval=24,
     group=gLvl, tooltip="14 is TradingView's normal table text. 11 is about 20% smaller.")
showAxisTags = input.bool(false, "Show axis price boxes", group=gLvl)
pmBasisTF = input.timeframe("15", "PM body-basis timeframe", group=gLvl)

showLgdAtr = input.bool(true, "Show NY ATR (20-day avg) in legend", group=gSess,
     tooltip="Average NY AM range over the lookback, today excluded. Holds still through the session.")
showAsia   = input.bool(true, "Show Asia range label",   group=gSess)
showLondon = input.bool(true, "Show London range label", group=gSess)
showNY     = input.bool(true, "Show NY AM range label",  group=gSess)
showInline = input.bool(true, "Show inline session labels on chart", group=gSess)
avgDays    = input.int(20, "Session average lookback (days)", minval=5,
     maxval=60, group=gSess)
lblSize    = input.string("normal", "Inline label size", group=gSess,
     options=["tiny", "small", "normal", "large"])

showAtrLn = input.bool(true, "Show ATR reach lines", group=gAtr,
     tooltip="Price + NY ATR and price - NY ATR. Tracks price during the window below, then freezes at the open.")
atrSess   = input.session("0900-0930", "Tracking window (ET)", group=gAtr)
atrLnMins = input.int(60, "Line length (minutes)", minval=10, maxval=390, group=gAtr)

reachMult = input.float(1.5, "ATR budget needed per unit distance to level",
     minval=0.5, maxval=3.0, step=0.1, group=gCalc)

show200   = input.bool(true, "Show 200 EMA", group=gMA)
ma200Type = input.string("EMA", "MA type", options=["SMA", "EMA"], group=gMA)
ma200Len  = input.int(200, "MA length", minval=1, group=gMA)
ma200TF   = input.timeframe("", "MA timeframe (blank = chart)", group=gMA)

colGold  = input.color(#FFD700, "PDH / PDL", group=gStyle)
colCyan  = input.color(#00FFFF, "PMH / PML", group=gStyle)
colPW    = input.color(#FF9100, "PWH / PWL", group=gStyle)
col200   = input.color(#FF1744, "200 EMA",   group=gStyle)
colAtr   = input.color(#CFD8DC, "NY ATR row", group=gStyle)
colAtrLn = input.color(#B388FF, "ATR reach lines", group=gStyle)
colAsia  = input.color(#7E8FA6, "Asia",   group=gStyle)
colLon   = input.color(#4DB6AC, "London", group=gStyle)
colGreen = input.color(#00E676, "RIDE",  group=gStyle)
colRed   = input.color(#FF5252, "CUT",   group=gStyle)
colNone  = input.color(#9E9E9E, "No level ahead", group=gStyle)
lineW    = input.int(2, "Line width", minval=1, maxval=4, group=gStyle)

tz = "America/New_York"
asiaSess = input.session("1800-0300", "Asia session",   group=gSess)
lonSess  = input.session("0300-0930", "London session", group=gSess)
nySess   = input.session("0930-1200", "NY AM session",  group=gSess)
pmSess   = input.session("0400-0930", "Pre-market window", group=gSess)
rthSess  = input.session("0930-1600", "NYSE session",   group=gSess)

f_size(string s) =>
    r = size.normal
    if s == "tiny"
        r := size.tiny
    else if s == "small"
        r := size.small
    else if s == "large"
        r := size.large
    r

lsz = f_size(lblSize)

f_group(float px) =>
    neg = px < 0
    ap  = math.abs(px)
    s   = str.tostring(ap, format.mintick)
    dotPos  = str.pos(s, ".")
    intPart = na(dotPos) ? s : str.substring(s, 0, dotPos)
    frac    = na(dotPos) ? "" : str.substring(s, dotPos, str.length(s))
    n = str.length(intPart)
    out = ""
    i = 0
    while i < n
        ch  = str.substring(intPart, i, i + 1)
        out := out + ch
        rem = n - i - 1
        if rem > 0 and rem % 3 == 0
            out := out + ","
        i := i + 1
    (neg ? "-" : "") + out + frac

f_num(float x) =>
    na(x) ? "—" : str.tostring(x, format.mintick)

// ============================================================================
// SESSION STATE
// ============================================================================
inRth    = not na(time(timeframe.period, rthSess,  tz))
inPm     = not na(time(timeframe.period, pmSess,   tz))
inAsia   = not na(time(timeframe.period, asiaSess, tz))
inLon    = not na(time(timeframe.period, lonSess,  tz))
inNY     = not na(time(timeframe.period, nySess,   tz))
inAtrWin = not na(time(timeframe.period, atrSess,  tz))

rthClose = not inRth and inRth[1]

// ============================================================================
// 200 EMA
// ============================================================================
f_ma200() =>
    ma200Type == "EMA" ? ta.ema(close, ma200Len) : ta.sma(close, ma200Len)

ma200 = ma200TF == "" ? f_ma200() : request.security(syminfo.tickerid, ma200TF,
     f_ma200(), lookahead=barmerge.lookahead_off)

// ============================================================================
// PDH / PDL — wick extremes of the NYSE session that just closed
// ============================================================================
var float sHigh  = na
var float sLow   = na
var int   sHighT = na
var int   sLowT  = na
var float pdhVal = na
var float pdlVal = na
var int   pdhT   = na
var int   pdlT   = na

if inRth
    if not inRth[1]
        sHigh  := high
        sLow   := low
        sHighT := time
        sLowT  := time
    else
        if high > sHigh
            sHigh  := high
            sHighT := time
        if low < sLow
            sLow  := low
            sLowT := time

if rthClose and not na(sHigh)
    pdhVal := sHigh
    pdlVal := sLow
    pdhT   := sHighT
    pdlT   := sLowT

// ============================================================================
// PMH / PML — BODY extremes on the 15m basis
// ============================================================================
f_pmBody() =>
    inS = not na(time(timeframe.period, pmSess, tz))
    st  = inS and not inS[1]
    bt = math.max(open, close)
    bb = math.min(open, close)
    var float bHi  = na
    var float bLo  = na
    var int   bHiT = na
    var int   bLoT = na
    if st
        bHi  := bt
        bLo  := bb
        bHiT := time
        bLoT := time
    else if inS
        if bt > bHi
            bHi  := bt
            bHiT := time
        if bb < bLo
            bLo  := bb
            bLoT := time
    [bHi, bLo, bHiT, bLoT]

[pmHi, pmLo, pmHiT, pmLoT] = request.security(syminfo.tickerid, pmBasisTF,
     f_pmBody(), lookahead=barmerge.lookahead_off)

// ============================================================================
// PWH / PWL — previous futures week (Sun 18:00 ET open -> Fri close), 1h basis
// ============================================================================
f_week() =>
    et    = "America/New_York"
    wk    = weekofyear(time + 21600000, et)
    newWk = na(wk[1]) ? false : wk != wk[1]
    var float cHi = na
    var float cLo = na
    var int   cSt = na
    var float pHi = na
    var float pLo = na
    var int   pSt = na
    if newWk
        pHi := cHi
        pLo := cLo
        pSt := cSt
        cHi := high
        cLo := low
        cSt := time
    else
        cHi := math.max(nz(cHi, high), high)
        cLo := math.min(nz(cLo, low), low)
        cSt := nz(cSt, time)
    [pHi, pLo, pSt]

[pwHi, pwLo, pwStartT] = request.security(syminfo.tickerid, "60", f_week(),
     lookahead=barmerge.lookahead_off)

// ============================================================================
// SESSION RANGE TRACKING
// ============================================================================
f_track(bool inS, float curHi, float curLo, int curStart) =>
    float hi = curHi
    float lo = curLo
    int   st = curStart
    if inS and not inS[1]
        hi := high
        lo := low
        st := time
    else if inS
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low), low)
    [hi, lo, st]

var float aHi = na
var float aLo = na
var int   aSt = na
[aHi2, aLo2, aSt2] = f_track(inAsia, aHi, aLo, aSt)
aHi := aHi2
aLo := aLo2
aSt := aSt2

var float lHi = na
var float lLo = na
var int   lSt = na
[lHi2, lLo2, lSt2] = f_track(inLon, lHi, lLo, lSt)
lHi := lHi2
lLo := lLo2
lSt := lSt2

var float nHi = na
var float nLo = na
var int   nSt = na
[nHi2, nLo2, nSt2] = f_track(inNY, nHi, nLo, nSt)
nHi := nHi2
nLo := nLo2
nSt := nSt2

// clear yesterday's NY AM range when a new trading day begins
newDay = (inAsia and not inAsia[1]) or (inPm and not inPm[1])
if newDay and not inNY
    nHi := na
    nLo := na
    nSt := na

aRange = (na(aHi) or na(aLo)) ? na : aHi - aLo
lRange = (na(lHi) or na(lLo)) ? na : lHi - lLo
nRange = (na(nHi) or na(nLo)) ? na : nHi - nLo

// ============================================================================
// SESSION 20-DAY AVERAGES — 30m basis so bar history holds on a 2m chart.
// A session is added to the average only AFTER it ends, so nAvg is the
// average leading into today's open and does not move during the session.
// ============================================================================
f_sessAvg(string sess, int nDays) =>
    inS = not na(time(timeframe.period, sess, tz))
    var float hi = na
    var float lo = na
    var array<float> hist = array.new_float()
    if inS and not inS[1]
        hi := high
        lo := low
    else if inS
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low), low)
    if not inS and inS[1] and not na(hi) and not na(lo)
        array.push(hist, hi - lo)
        if array.size(hist) > nDays
            array.shift(hist)
    array.size(hist) > 0 ? array.avg(hist) : na

aAvg = request.security(syminfo.tickerid, "30", f_sessAvg(asiaSess, avgDays),
     lookahead=barmerge.lookahead_off)
lAvg = request.security(syminfo.tickerid, "30", f_sessAvg(lonSess, avgDays),
     lookahead=barmerge.lookahead_off)
nAvg = request.security(syminfo.tickerid, "30", f_sessAvg(nySess, avgDays),
     lookahead=barmerge.lookahead_off)

// ============================================================================
// ATR REACH ANCHOR — follows price inside the tracking window, then freezes
// at the open of the first bar after it (the 09:30 ET open).
// ============================================================================
var float atrAnchor  = na
var int   atrAnchorT = na
var float atrDist    = na

if newDay and not inAtrWin
    atrAnchor  := na
    atrAnchorT := na
    atrDist    := na

if inAtrWin
    atrAnchor  := close
    atrAnchorT := time
    atrDist    := nAvg
else if inAtrWin[1]
    atrAnchor  := open
    atrAnchorT := time
    atrDist    := nAvg

// ============================================================================
// REACH LOGIC (feeds the on-chart NY label only)
// ============================================================================
f_nearest(array<float> lv, float px, bool above) =>
    float r = na
    for v in lv
        if not na(v)
            if above and v > px
                r := na(r) ? v : math.min(r, v)
            if not above and v < px
                r := na(r) ? v : math.max(r, v)
    r

float pwHiR = showPW ? pwHi : na
float pwLoR = showPW ? pwLo : na
float maR   = na   // v5.3: 200 is out of the verdict until one timeframe is chosen for it
lvls = array.from(pdhVal, pdlVal, pmHi, pmLo, pwHiR, pwLoR, maR)

lvUp   = f_nearest(lvls, close, true)
lvDn   = f_nearest(lvls, close, false)
distUp = na(lvUp) ? na : lvUp - close
distDn = na(lvDn) ? na : close - lvDn

nyLive = not na(nRange)
nyMid  = nyLive ? (nHi + nLo) / 2 : na
leanUp = nyLive and close >= nyMid

float reachDist = na
if nyLive
    reachDist := leanUp ? distUp : distDn
else
    reachDist := na(distUp) ? distDn : (na(distDn) ? distUp : math.min(distUp, distDn))

nyUsed   = nz(nRange, 0)
nyLeft   = na(nAvg) ? na : math.max(0, nAvg - nyUsed)
needed   = na(reachDist) ? na : reachDist * reachMult
hasRead  = not na(nyLeft) and not na(needed)
budgetOK = hasRead and nyLeft >= needed

verdictTxt = hasRead ? (budgetOK ? "RIDE to level" : "CUT at swing") : "no level ahead"
verdictCol = hasRead ? (budgetOK ? colGreen : colRed) : colNone

// ============================================================================
// 200 EMA curve + optional axis price boxes
// ============================================================================
plot(show200 ? ma200 : na, "200 EMA", color=col200, linewidth=lineW)

plot(showAxisTags and showPD and not na(pdhVal) ? pdhVal : na, "PDH price",
     color=colGold, display=display.price_scale, editable=false)
plot(showAxisTags and showPD and not na(pdlVal) ? pdlVal : na, "PDL price",
     color=colGold, display=display.price_scale, editable=false)
plot(showAxisTags and showPM and not na(pmHi) ? pmHi : na, "PMH price",
     color=colCyan, display=display.price_scale, editable=false)
plot(showAxisTags and showPM and not na(pmLo) ? pmLo : na, "PML price",
     color=colCyan, display=display.price_scale, editable=false)
plot(showAxisTags and showPW and not na(pwHi) ? pwHi : na, "PWH price",
     color=colPW, display=display.price_scale, editable=false)
plot(showAxisTags and showPW and not na(pwLo) ? pwLo : na, "PWL price",
     color=colPW, display=display.price_scale, editable=false)

// ============================================================================
// LEVEL LINES + ATR REACH LINES
// ============================================================================
var line pdhLn = na
var line pdlLn = na
var line pmhLn = na
var line pmlLn = na
var line pwhLn = na
var line pwlLn = na
var line  atrUpLn = na
var line  atrDnLn = na
var label atrUpLb = na
var label atrDnLb = na

if barstate.islast
    line.delete(pdhLn)
    line.delete(pdlLn)
    line.delete(pmhLn)
    line.delete(pmlLn)
    line.delete(pwhLn)
    line.delete(pwlLn)
    line.delete(atrUpLn)
    line.delete(atrDnLn)
    label.delete(atrUpLb)
    label.delete(atrDnLb)
    pdhLn := na
    pdlLn := na
    pmhLn := na
    pmlLn := na
    pwhLn := na
    pwlLn := na
    atrUpLn := na
    atrDnLn := na
    atrUpLb := na
    atrDnLb := na
    if showPD and not na(pdhVal) and not na(pdhT)
        pdhLn := line.new(pdhT, pdhVal, pdhT + 3600000, pdhVal, xloc.bar_time,
             extend.right, colGold, width=lineW)
        pdlLn := line.new(pdlT, pdlVal, pdlT + 3600000, pdlVal, xloc.bar_time,
             extend.right, colGold, width=lineW)
    if showPM and not na(pmHi) and not na(pmHiT)
        pmhLn := line.new(pmHiT, pmHi, pmHiT + 3600000, pmHi, xloc.bar_time,
             extend.right, colCyan, width=lineW)
        pmlLn := line.new(pmLoT, pmLo, pmLoT + 3600000, pmLo, xloc.bar_time,
             extend.right, colCyan, width=lineW)
    if showPW and not na(pwHi) and not na(pwLo)
        pwAnchor = na(pwStartT) ? time - 432000000 : pwStartT
        pwhLn := line.new(pwAnchor, pwHi, pwAnchor + 3600000, pwHi,
             xloc.bar_time, extend.right, colPW, width=lineW)
        pwlLn := line.new(pwAnchor, pwLo, pwAnchor + 3600000, pwLo,
             xloc.bar_time, extend.right, colPW, width=lineW)
    if showAtrLn and not na(atrAnchor) and not na(atrDist) and not na(atrAnchorT)
        atrX2 = atrAnchorT + atrLnMins * 60000
        atrUp = atrAnchor + atrDist
        atrDn = atrAnchor - atrDist
        atrUpLn := line.new(atrAnchorT, atrUp, atrX2, atrUp, xloc.bar_time,
             extend.none, colAtrLn, width=lineW)
        atrDnLn := line.new(atrAnchorT, atrDn, atrX2, atrDn, xloc.bar_time,
             extend.none, colAtrLn, width=lineW)
        atrUpLb := label.new(atrX2, atrUp, "+ATR " + f_group(atrUp),
             xloc.bar_time, yloc.price, color.new(color.black, 100),
             label.style_label_left, colAtrLn, size.small)
        atrDnLb := label.new(atrX2, atrDn, "-ATR " + f_group(atrDn),
             xloc.bar_time, yloc.price, color.new(color.black, 100),
             label.style_label_left, colAtrLn, size.small)

// ============================================================================
// LEGEND — levels sorted by price, then the NY ATR row
// ============================================================================
f_addLvl(array<float> pA, array<string> nA, array<color> cA, string nm,
     float px, color col) =>
    if not na(px)
        idx = 0
        n = array.size(pA)
        while idx < n and array.get(pA, idx) > px
            idx += 1
        array.insert(pA, idx, px)
        array.insert(nA, idx, nm)
        array.insert(cA, idx, col)

f_row(table t, int r, string nm, string val, color bg) =>
    table.cell(t, 0, r, " " + nm + " ", bgcolor=bg, text_color=color.black,
         text_size=lgdPts, text_halign=text.align_left)
    table.cell(t, 1, r, val + " ", bgcolor=bg, text_color=color.black,
         text_size=lgdPts, text_halign=text.align_right)

var table lgd = table.new(lgdPos == "Top right" ? position.top_right : lgdPos == "Bottom right" ? position.bottom_right : position.middle_right, 2, 12)

if barstate.islast
    table.clear(lgd, 0, 0, 1, 11)
    int row = 0
    if showLbls
        pA = array.new_float()
        nA = array.new_string()
        cA = array.new_color()
        if showPD
            f_addLvl(pA, nA, cA, "PDH", pdhVal, colGold)
            f_addLvl(pA, nA, cA, "PDL", pdlVal, colGold)
        if showPM
            f_addLvl(pA, nA, cA, "PMH", pmHi, colCyan)
            f_addLvl(pA, nA, cA, "PML", pmLo, colCyan)
        if showPW
            f_addLvl(pA, nA, cA, "PWH", pwHi, colPW)
            f_addLvl(pA, nA, cA, "PWL", pwLo, colPW)
        if show200
            f_addLvl(pA, nA, cA, "200", ma200, col200)
        cnt = array.size(pA)
        if cnt > 0
            for i = 0 to cnt - 1
                f_row(lgd, row, array.get(nA, i), f_group(array.get(pA, i)), array.get(cA, i))
                row += 1
    if showLgdAtr
        f_row(lgd, row, "NY ATR", f_num(nAvg), colAtr)
        row += 1

// ============================================================================
// INLINE SESSION LABELS — optional, under each session's low
// ============================================================================
var label aLb = na
var label lLb = na
var label nLb = na

f_sessTxt(string tag, float rng, float avg) =>
    tag + " " + f_num(rng) + "  · avg " + f_num(avg)

if barstate.islast
    label.delete(aLb)
    label.delete(lLb)
    label.delete(nLb)
    aLb := na
    lLb := na
    nLb := na

    if showInline and showAsia and not na(aRange) and not na(aSt)
        aMid = aSt + (9 * 60 * 60 * 1000) / 2
        aLb := label.new(aMid, aLo, f_sessTxt("ASIA", aRange, aAvg),
             xloc.bar_time, yloc.price, color.new(color.black, 100),
             label.style_label_up, colAsia, lsz)

    if showInline and showLondon and not na(lRange) and not na(lSt)
        lMid = lSt + (6 * 60 * 60 * 1000 + 30 * 60 * 1000) / 2
        lLb := label.new(lMid, lLo, f_sessTxt("LONDON", lRange, lAvg),
             xloc.bar_time, yloc.price, color.new(color.black, 100),
             label.style_label_up, colLon, lsz)

    if showInline and showNY and nyLive and not na(nSt)
        nMid = nSt + (2 * 60 * 60 * 1000 + 30 * 60 * 1000) / 2
        nLb := label.new(nMid, nLo, f_sessTxt("NY AM", nRange, nAvg) + "\n" + verdictTxt,
             xloc.bar_time, yloc.price, color.new(color.black, 100),
             label.style_label_up, verdictCol, lsz)

// ============================================================================
// END — SITREP KEY LEVELS v5.3
// ============================================================================
````
