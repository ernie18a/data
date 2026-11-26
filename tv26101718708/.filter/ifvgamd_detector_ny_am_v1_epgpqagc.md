# IFVG/AMD Detector - NY AM (v1)

- url: https://www.tradingview.com/script/epgPqAGc-IFVG-AMD-Detector-NY-AM-v1/
- type: indicator
- pine_id: PUB;a26e66cc30b140f2a746d726dc6f0d79
- version: 1.0

## Description

Semi-automated signal tool for the 9:30–11:00 ET session on ES/NQ. You set the session bias from your 1D/4H read, and it watches for an FVG that inverts (IFVG) in that direction after a manipulation leg. The validity gate only fires the signal if the manipulation reached an unmitigated higher-timeframe gap (15m/1h/4h/1d) — suppressing the premature setups where price stalled short of its draw. Confirms on bar close (non-repainting), fires alerts, and tracks forward-test stats in-chart. You place and manage every trade manually.

## Source Code

````pine
//@version=6
indicator("IFVG·AMD Detector — NY AM (v1)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ===========================================================================
//  IFVG / AMD DETECTOR  —  NY AM session  (v1, forward-test build)
//  --------------------------------------------------------------------------
//  Semi-automated SIGNAL tool. The trigger confirms on BAR CLOSE (non-repaint)
//  and fires an alert. You set the session bias each morning from your 1D/4H
//  read, and you place + manage every trade manually (Alpha-compliant).
//
//  Flow:  in NY AM window  ->  an FVG forms (manipulation leg)  ->  price
//         closes back through it (inversion = IFVG)  ->  validity gate: the
//         manipulation must NOT have stalled short of an unmitigated HTF gap.
//
//  v1 SCOPE NOTE: the validity gate currently reasons off HTF *gaps* only.
//  It suppresses the exact failure you flagged (manipulation stops just shy
//  of a 15m+ gap that is still unmitigated above). Equal-highs/lows and
//  news-data wicks as draws are NOT yet auto-detected — those stay your manual
//  read for now and are the planned v2 layer.
// ===========================================================================

// ------------------------------- ① Session & bias --------------------------
gS = "① Session & Bias"
biasInput = input.string("Short", "Session bias", options = ["Long", "Short", "Off"], group = gS, tooltip = "Set each morning from your 1D/4H narrative. The detector only hunts inversions in this direction. 'Off' pauses it.")
sessWin   = input.session("0930-1100", "NY AM window", group = gS)
sessTz    = input.string("America/New_York", "Timezone", group = gS)

// ------------------------------- ② FVG / IFVG ------------------------------
gF = "② FVG / IFVG"
bodyClose = input.bool(true, "Require body close to invert", group = gF, tooltip = "ON = inversion only counts when a candle BODY closes beyond the gap (stricter, fewer fakeouts). OFF = a wick through counts.")
drawBoxes = input.bool(true, "Draw FVG / IFVG boxes", group = gF)

// ------------------------------- ③ HTF validity gate -----------------------
gH = "③ HTF draw — validity gate"
useHTF  = input.bool(true, "Require manipulation to reach the HTF gap", group = gH, tooltip = "Core rule. If an UNMITIGATED HTF gap still sits beyond the manipulation extreme, the signal is suppressed (draw not yet satisfied). Turn OFF to log every inversion — useful for comparing valid-only vs all during the forward test.")
tfA = input.timeframe("15",  "HTF gap A", group = gH)
tfB = input.timeframe("60",  "HTF gap B", group = gH)
tfC = input.timeframe("240", "HTF gap C", group = gH)
tfD = input.timeframe("D",   "HTF gap D", group = gH)
maxGaps = input.int(8, "Max gaps tracked / TF", minval = 1, maxval = 30, group = gH)

// ------------------------------- ④ Forward-test stats ----------------------
gT = "④ Forward-test stats"
showStats = input.bool(true, "Show stats table", group = gT)
rMult     = input.float(2.0, "Target R for auto win/loss", minval = 0.5, step = 0.5, group = gT, tooltip = "YARDSTICK ONLY. entry = inversion close, stop = manipulation extreme, target = R x risk. Measures raw SIGNAL quality, NOT your discretionary exits (BE+1, trailing, etc.).")

// ===========================================================================
//  SESSION
// ===========================================================================
inSess  = not na(time(timeframe.period, sessWin + ":23456", sessTz))
newSess = inSess and not inSess[1]

// ===========================================================================
//  HTF GAP TRACKING
// ===========================================================================
type Gap
    float top
    float bot
    bool  bull
    bool  mit

var array<Gap> gaps = array.new<Gap>()

// pull the gap defined by the 3 most recently CLOSED HTF bars (offsets 1..3)
f_htf(tf) =>
    [h1, l1, h3, l3, bt] = request.security(syminfo.tickerid, tf, [high[1], low[1], high[3], low[3], time[1]], lookahead = barmerge.lookahead_off)
    bull   = l1 > h3
    bear   = h1 < l3
    exists = bull or bear
    gtop   = bull ? l1 : h1
    gbot   = bull ? h3 : l3
    [exists, bull, gtop, gbot, bt]

f_intake(tf) =>
    [ex, bull, gtop, gbot, bt] = f_htf(tf)
    isNew = ta.change(bt) != 0
    if ex and isNew and not na(gtop) and not na(gbot)
        array.unshift(gaps, Gap.new(gtop, gbot, bull, false))
        if array.size(gaps) > maxGaps * 4
            array.pop(gaps)

// called unconditionally (request.security must stay in consistent scope)
f_intake(tfA)
f_intake(tfB)
f_intake(tfC)
f_intake(tfD)

// mitigation: a gap is "tagged" once price trades into its zone
if array.size(gaps) > 0
    for i = 0 to array.size(gaps) - 1
        g = array.get(gaps, i)
        if not g.mit and high >= g.bot and low <= g.top
            g.mit := true
            array.set(gaps, i, g)

// is there an unmitigated gap still ABOVE the manipulation high? (short premature)
f_gapAbove(manipHi) =>
    found = false
    if array.size(gaps) > 0
        for i = 0 to array.size(gaps) - 1
            g = array.get(gaps, i)
            if (not g.mit) and g.bot > manipHi
                found := true
    found

// is there an unmitigated gap still BELOW the manipulation low? (long premature)
f_gapBelow(manipLo) =>
    found = false
    if array.size(gaps) > 0
        for i = 0 to array.size(gaps) - 1
            g = array.get(gaps, i)
            if (not g.mit) and g.top < manipLo
                found := true
    found

// ===========================================================================
//  CHART-TF FVG  +  MANIPULATION EXTREME  (reset each session)
// ===========================================================================
bullFVG = low  > high[2]   // up-manipulation -> watched for SHORT inversion
bearFVG = high < low[2]    // down-manipulation -> watched for LONG inversion

var float sBot   = na      // bullish FVG bottom (short side)
var float sManip = na      // manipulation high since that FVG
var float lTop   = na      // bearish FVG top (long side)
var float lManip = na      // manipulation low since that FVG

if newSess
    sBot   := na
    sManip := na
    lTop   := na
    lManip := na

if inSess and bullFVG
    sBot   := high[2]
    sManip := high
if inSess and not na(sBot)
    sManip := math.max(nz(sManip, high), high)

if inSess and bearFVG
    lTop   := low[2]
    lManip := low
if inSess and not na(lTop)
    lManip := math.min(nz(lManip, low), low)

// ===========================================================================
//  INVERSION + VALIDITY  ->  SIGNAL  (confirmed on close)
// ===========================================================================
sRef = bodyClose ? close : low
lRef = bodyClose ? close : high

shortInv = not na(sBot) and sRef < sBot and close[1] >= sBot
longInv  = not na(lTop) and lRef > lTop and close[1] <= lTop

validShort = not (useHTF and f_gapAbove(sManip))
validLong  = not (useHTF and f_gapBelow(lManip))

shortSig = biasInput == "Short" and inSess and barstate.isconfirmed and shortInv and validShort
longSig  = biasInput == "Long"  and inSess and barstate.isconfirmed and longInv  and validLong

// ===========================================================================
//  FORWARD-TEST STATS  (R yardstick — signal quality only)
// ===========================================================================
var int   total   = 0
var int   wins    = 0
var int   losses  = 0
var bool  inTrade = false
var bool  tShort  = false
var float tEntry  = na
var float tStop   = na
var float tTgt    = na

f_open(isShort, entry, stop) =>
    risk = math.abs(stop - entry)
    tgt  = isShort ? entry - rMult * risk : entry + rMult * risk
    [entry, stop, tgt, risk]

if (shortSig or longSig) and not inTrade
    isS = shortSig
    stp = isS ? sManip : lManip
    [e, s, t, r] = f_open(isS, close, stp)
    if r > 0
        inTrade := true
        tShort  := isS
        tEntry  := e
        tStop   := s
        tTgt    := t
        total   := total + 1
    // clear the used FVG so it can't re-fire on the same gap
    sBot := na
    lTop := na

if inTrade
    if tShort
        if high >= tStop
            losses  := losses + 1
            inTrade := false
        else if low <= tTgt
            wins    := wins + 1
            inTrade := false
    else
        if low <= tStop
            losses  := losses + 1
            inTrade := false
        else if high >= tTgt
            wins    := wins + 1
            inTrade := false

// ===========================================================================
//  VISUALS
// ===========================================================================
plotshape(shortSig, title = "Short signal", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.small)
plotshape(longSig,  title = "Long signal",  style = shape.triangleup,   location = location.belowbar, color = color.new(color.blue, 0), size = size.small)

if drawBoxes and shortSig
    box.new(bar_index - 1, sManip, bar_index + 12, nz(sBot, close), border_color = color.new(color.red, 40), bgcolor = color.new(color.red, 88))
if drawBoxes and longSig
    box.new(bar_index - 1, nz(lTop, close), bar_index + 12, lManip, border_color = color.new(color.blue, 40), bgcolor = color.new(color.blue, 88))

bgcolor(inSess ? color.new(color.teal, 92) : na, title = "NY AM window")

if showStats and barstate.islast
    wr = total > 0 ? (wins / total) * 100 : 0.0
    var table tbl = table.new(position.top_right, 2, 6, border_width = 1)
    table.cell(tbl, 0, 0, "IFVG·AMD — fwd test", text_color = color.white, bgcolor = color.new(color.gray, 0), text_size = size.small)
    table.cell(tbl, 1, 0, biasInput, text_color = color.white, bgcolor = color.new(color.gray, 0), text_size = size.small)
    table.cell(tbl, 0, 1, "Signals", text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(total), text_size = size.small)
    table.cell(tbl, 0, 2, "Wins (" + str.tostring(rMult, "#.#") + "R)", text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(wins), text_size = size.small)
    table.cell(tbl, 0, 3, "Losses", text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(losses), text_size = size.small)
    table.cell(tbl, 0, 4, "Resolved win%", text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(wr, "#.#") + "%", text_size = size.small)
    table.cell(tbl, 0, 5, "Open trade", text_size = size.small)
    table.cell(tbl, 1, 5, inTrade ? (tShort ? "short" : "long") : "—", text_size = size.small)

// ===========================================================================
//  ALERTS
// ===========================================================================
alertcondition(shortSig, title = "IFVG short (NY AM)", message = "IFVG SHORT signal — NY AM — {{ticker}} {{interval}} @ {{close}}")
alertcondition(longSig,  title = "IFVG long (NY AM)",  message = "IFVG LONG signal — NY AM — {{ticker}} {{interval}} @ {{close}}")
if shortSig
    alert("IFVG SHORT signal — NY AM", alert.freq_once_per_bar_close)
if longSig
    alert("IFVG LONG signal — NY AM", alert.freq_once_per_bar_close)
````
