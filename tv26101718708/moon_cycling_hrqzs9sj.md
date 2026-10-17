# Moon Cycling

- url: https://www.tradingview.com/script/HrqzS9sj-Moon-Cycling/
- type: indicator
- pine_id: PUB;2bb20e55a19040f5948bee1e23083e0a
- version: 1.0

## Description

A indicator showing vol and best ote lvls #VVSpaid #9PAID #22PAID #GEZXPAID

## Source Code

````pine
//@version=6
// =============================================================
//  MOON CYCLING
//  Timeframe-locked session volatility (0-100 percentile) ->
//  the OTE level your framework allows for that session, plus a
//  stop sized to live volatility. Corner table only.
//
//  History window is now a CALENDAR lookback (days) so you can
//  adapt it to the current regime. All math runs on the
//  reference timeframe, so the chart timeframe can't change it.
//  Keep chart TF <= reference TF, and make sure the chart loads
//  enough history to fill your chosen lookback (see notes).
// =============================================================
indicator("Moon Cycling", overlay = true)

// --- Measurement (timeframe-locked) --------------------------
grpM = "Measurement"
refTF        = input.timeframe("5", "Reference Timeframe", group = grpM, tooltip = "Volatility is measured here, not on your chart. Keep your chart at or below this.")
atrLen       = input.int(14, "ATR Length", minval = 1, group = grpM)
lookbackDays = input.int(60, "Lookback (calendar days)", minval = 3, group = grpM, tooltip = "The 0-100 scale is built from this many days of each session's history. 60 ~ 2 months. Longer = needs more loaded chart history; on low timeframes that may not be available (see notes).")
minSamples   = input.int(20, "Min Samples Before Scoring", minval = 5, group = grpM)

// --- Moon levels ---------------------------------------------
grpO = "Moon Levels"
oteLow  = input.float(0.786,  "Low",     group = grpO)
oteMain = input.float(0.86,   "Main",    group = grpO)
oteHigh = input.float(0.886,  "High",    group = grpO)
oteExt  = input.float(0.91,   "Extreme", group = grpO)
oteMax  = input.float(0.9416, "Max",     group = grpO)

// --- Volatility bands (0-100) --------------------------------
grpB = "Volatility Bands (0-100)"
lowCut  = input.int(40, "Low band below",  minval = 1, maxval = 99, group = grpB)
highCut = input.int(85, "High band above", minval = 1, maxval = 99, group = grpB)

// --- Sessions (times in chosen timezone) ---------------------
grpS = "Sessions"
tz          = input.string("America/New_York", "Timezone", group = grpS)
preAsiaSess = input.session("1800-2000", "Pre-Asia",   group = grpS)
asiaSess    = input.session("2000-0000", "Asia",       group = grpS)
preLonSess  = input.session("0000-0200", "Pre-London", group = grpS)
lonSess     = input.session("0200-0500", "London",     group = grpS)
preMktSess  = input.session("0500-0930", "Pre-market", group = grpS)
opnSess     = input.session("0930-1000", "9:30 Open",  group = grpS)
tenSess     = input.session("1000-1100", "10 AM",      group = grpS)
preNyPmSess = input.session("1100-1330", "Pre-NY PM",  group = grpS)
nyPmSess    = input.session("1330-1600", "NY PM",      group = grpS)

// --- Stops (points; min..max scaled by volatility) -----------
grpStp = "Stops (points)"
quietMin = input.float(3, "Quiet min (pre/Asia/London)", group = grpStp), quietMax = input.float(5,  "Quiet max", group = grpStp)
openMin  = input.float(5, "Open min (9:30/10AM)",        group = grpStp), openMax  = input.float(20, "Open max",  group = grpStp)
pmMin    = input.float(5, "NY PM min",                   group = grpStp), pmMax    = input.float(10, "NY PM max", group = grpStp)
tickOver = input.float(0.0, "Tick Size (0 = auto)", minval = 0, step = 0.01, group = grpStp, tooltip = "0 = use the instrument's real tick (NQ 0.25, GC 0.10). Set manually only for spot/CFD feeds with unusual ticks. Stops always snap to this grid.")

// --- Display -------------------------------------------------
posStr = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Display")

lbMs = lookbackDays * 86400000

// Per-session percentile over a rolling CALENDAR window.
// Runs one refTF bar at a time inside the security call below.
sessPct(bool inSess, float v, int tBar, int windowMs, int minN) =>
    var vArr = array.new_float()
    var tArr = array.new_int()
    var float last = na
    if inSess and not na(v)
        while array.size(tArr) > 0
            if (tBar - array.get(tArr, 0)) > windowMs
                array.shift(tArr)
                array.shift(vArr)
            else
                break
        sz = array.size(vArr)
        if sz >= minN
            int below = 0
            for i = 0 to sz - 1
                below := below + (array.get(vArr, i) < v ? 1 : 0)
            last := below / sz * 100.0
        array.push(vArr, v)
        array.push(tArr, tBar)
        if array.size(vArr) > 10000
            array.shift(vArr)
            array.shift(tArr)
    [last, array.size(vArr)]

// EVERYTHING here executes on the reference timeframe.
calc() =>
    v = ta.atr(atrLen)
    t = time
    iPA = not na(time(timeframe.period, preAsiaSess, tz))
    iAS = not na(time(timeframe.period, asiaSess,    tz))
    iPL = not na(time(timeframe.period, preLonSess,  tz))
    iLO = not na(time(timeframe.period, lonSess,     tz))
    iP9 = not na(time(timeframe.period, preMktSess,  tz))
    iOP = not na(time(timeframe.period, opnSess,     tz))
    iTA = not na(time(timeframe.period, tenSess,     tz))
    iPN = not na(time(timeframe.period, preNyPmSess, tz))
    iNP = not na(time(timeframe.period, nyPmSess,    tz))
    [sPA, cPA] = sessPct(iPA, v, t, lbMs, minSamples)
    [sAS, cAS] = sessPct(iAS, v, t, lbMs, minSamples)
    [sPL, cPL] = sessPct(iPL, v, t, lbMs, minSamples)
    [sLO, cLO] = sessPct(iLO, v, t, lbMs, minSamples)
    [sP9, cP9] = sessPct(iP9, v, t, lbMs, minSamples)
    [sOP, cOP] = sessPct(iOP, v, t, lbMs, minSamples)
    [sTA, cTA] = sessPct(iTA, v, t, lbMs, minSamples)
    [sPN, cPN] = sessPct(iPN, v, t, lbMs, minSamples)
    [sNP, cNP] = sessPct(iNP, v, t, lbMs, minSamples)
    // priority: 9:30 > 10AM > NY PM > London > Asia > pre-windows
    id = iOP ? 6 : iTA ? 7 : iNP ? 9 : iLO ? 4 : iAS ? 2 : iPN ? 8 : iP9 ? 5 : iPL ? 3 : iPA ? 1 : 0
    sc = id == 6 ? sOP : id == 7 ? sTA : id == 9 ? sNP : id == 4 ? sLO : id == 2 ? sAS : id == 8 ? sPN : id == 5 ? sP9 : id == 3 ? sPL : id == 1 ? sPA : float(na)
    cn = id == 6 ? cOP : id == 7 ? cTA : id == 9 ? cNP : id == 4 ? cLO : id == 2 ? cAS : id == 8 ? cPN : id == 5 ? cP9 : id == 3 ? cPL : id == 1 ? cPA : 0
    [sc, id, cn]

[pScore, sid, pN] = request.security(syminfo.tickerid, refTF, calc(), lookahead = barmerge.lookahead_off)

// Hold last valid reading for off-session display
var float  heldScore = na
var int    heldSid   = 0
var int    heldN     = 0
if sid != 0 and not na(pScore)
    heldScore := pScore
    heldSid   := sid
    heldN     := pN

isOff  = sid == 0
useSid = isOff ? heldSid : sid
dScore = isOff ? heldScore : pScore
dN     = isOff ? heldN : pN
score  = na(dScore) ? na : math.round(dScore)
band   = na(score) ? -1 : score < lowCut ? 0 : score < highCut ? 1 : 2

sessName(int id) =>
    id == 1 ? "Pre-Asia" : id == 2 ? "Asia" : id == 3 ? "Pre-London" : id == 4 ? "London" : id == 5 ? "Pre-market" : id == 6 ? "9:30 Open" : id == 7 ? "10 AM" : id == 8 ? "Pre-NY PM" : id == 9 ? "NY PM" : "Off-session"

dSessTxt = isOff ? "Off-session" : sessName(useSid)

// Session groups
isOpen   = useSid == 6 or useSid == 7
isPM     = useSid == 9
isLowGrp = useSid == 1 or useSid == 2 or useSid == 3 or useSid == 4 or useSid == 5 or useSid == 8

// Per-session level menu (framework, hard-capped per session)
bestLvl = isOff or na(score) ? na :
   isOpen   ? (band == 0 ? oteMain : band == 1 ? oteExt  : oteMax ) :
   isPM     ? (band == 0 ? oteMain : band == 1 ? oteMain : oteHigh) :
   isLowGrp ? (band == 0 ? oteLow  : oteMain) : na

lvlLbl = na(bestLvl) ? "-" :
   bestLvl >= oteMax  ? "MAX" :
   bestLvl >= oteExt  ? "EXTREME" :
   bestLvl >= oteHigh ? "HIGH" :
   bestLvl >= oteMain ? "MAIN" : "LOW"

lvlCol = na(bestLvl) ? color.gray :
   bestLvl >= oteExt  ? #EF5350 :
   bestLvl >= oteHigh ? #FB8C00 :
   bestLvl >= oteMain ? #26A69A : #2962FF

// Stop sized to live volatility, snapped to the instrument's tick grid
sMin = isOpen ? openMin : isPM ? pmMin : isLowGrp ? quietMin : na
sMax = isOpen ? openMax : isPM ? pmMax : isLowGrp ? quietMax : na
tickSz   = tickOver > 0 ? tickOver : syminfo.mintick
stopRaw  = sMin + (sMax - sMin) * score / 100
stopSugg = isOff or na(score) or na(sMin) ? na : math.round(stopRaw / tickSz) * tickSz
stopTk   = na(stopSugg) ? na : math.round(stopSugg / tickSz)

// --- Table ---------------------------------------------------
tpos = posStr == "Top Left" ? position.top_left : posStr == "Bottom Right" ? position.bottom_right : posStr == "Bottom Left" ? position.bottom_left : position.top_right

if barstate.islast
    var t = table.new(tpos, 2, 6, border_width = 1, frame_width = 1, frame_color = color.gray, bgcolor = color.new(color.black, 12))

    table.cell(t, 0, 0, "MOON CYCLING", text_color = color.white, bgcolor = color.new(#3949AB, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, refTF + " TF | " + str.tostring(lookbackDays) + "d", text_color = color.silver, bgcolor = color.new(#3949AB, 0), text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 1, "Session", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 1, dSessTxt, text_color = color.white, text_size = size.small, text_halign = text.align_right)

    volTxt = na(score) ? "building " + str.tostring(dN) + "/" + str.tostring(minSamples) : str.tostring(score) + " / 100"
    table.cell(t, 0, 2, "Volatility", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 2, volTxt, text_color = isOff ? color.gray : color.white, text_size = size.normal, text_halign = text.align_right)

    table.cell(t, 0, 3, "Best OTE", text_color = color.white, bgcolor = lvlCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 3, na(bestLvl) ? "-" : str.tostring(bestLvl, "#.####") + "  " + lvlLbl, text_color = color.white, bgcolor = lvlCol, text_size = size.normal, text_halign = text.align_right)

    stopTxt = na(stopSugg) ? "-" : str.tostring(stopSugg, "#.##") + " pt / " + str.tostring(stopTk) + "t"
    table.cell(t, 0, 4, "Stop", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 4, stopTxt, text_color = isOff ? color.gray : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(t, 0, 5, "samples", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, 5, str.tostring(dN), text_color = color.gray, text_size = size.tiny, text_halign = text.align_right)
````
