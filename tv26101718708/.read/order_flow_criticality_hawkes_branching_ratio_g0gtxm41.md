# Order Flow Criticality  Hawkes Branching Ratio

- url: https://www.tradingview.com/script/G0gTxm41-Order-Flow-Criticality-Hawkes-Branching-Ratio/
- type: indicator
- pine_id: PUB;a6a7cabfd91a4f88afc09271cc5ec7ab
- version: 3.0

## Description

Order-Flow Criticality — Hawkes Branching Ratio


What it is

Most order-flow tools ask how strong flow is. This one asks how fragile it is — how close the tape is to a self-sustaining cascade, where each burst of aggressive flow tends to trigger the next. That property is the branching ratio (n) of a self-exciting (Hawkes) process: n ≈ 0 means bursts are independent and the tape is stable (exogenous); n → 1 means flow is nearly self-sustaining — endogenous, reflexive, fragile. The output is a state read that says size down as criticality rises. It never issues a buy or sell.

How it works (and why this method)


Event — a bar whose absolute signed volume-delta is unusually large for its time of day. Delta is built from finest-available lower-timeframe signed volume, with an automatic bar-shape fallback.
Branching ratio — fitting a Hawkes kernel by maximum likelihood is heavy and fragile, so this uses the model-independent moment estimator of Hardiman & Bouchaud (2014): for a self-exciting process the variance-to-mean ratio of the event count (the Fano factor) grows as 1/(1−n)², so n ≈ 1 − √(mean_count / var_count) over recent non-overlapping counting bins. Only a mean and a variance of counts are needed. A random (Poisson) tape gives n ≈ 0; a clustered tape gives n → 1.
De-seasonalization (the key honesty step) — this estimator is known to be biased upward by intraday seasonality: opens and closes have naturally higher flow, which can masquerade as criticality (a Poisson process with a changing rate can show a spurious n ≈ 1). So an event is judged against the typical flow for its hour, removing the daily rhythm so what remains is genuine self-excitation.
Output — a background tint that intensifies as n rises, ● event marks, a SIZE-DOWN tag on crossing the critical zone, and a dashboard stating STABLE / ELEVATED / CRITICAL with a suggested size factor (1 − n).


Everything advances only on confirmed bars; the lower-timeframe delta is read on closed bars. No hindsight.

The stability & multi-timeframe layer


States are dwell-filtered (standard anti-chattering): a new STABLE/ELEVATED/CRITICAL is announced only after surviving a set number of confirmed bars. STABILITY shows how settled the read is; PENDING shows a forming state with a countdown. Cost: a few bars of lag — stated and adjustable.
The criticality lane — a thin strip at the pane bottom — gives the glance-read: green = stable, amber = elevated, red = critical. Risk colors (safe/danger), never direction.
The HTF STACK row shows the raw criticality state on three higher timeframes derived as multiples of the chart (defaults 3×, 5×, 15×). Honesty notes: the HTF slots use the bar-shape delta proxy (lower-timeframe data cannot be nested inside a higher-timeframe request) and the global flow baseline instead of the hourly profile (an HTF bar spans multiple hours, so per-hour bucketing is ill-defined there). ✓ = every timeframe agrees; ⚠ = a higher timeframe is CRITICAL while the chart is not — fragility above your resolution.


Seeing the cascades


Every flow burst prints a dot below its own bar: blue = isolated (arrived independently), warm = chained (within a few bars of the previous burst — likely triggered by it). This is the branching ratio made visible: as the tape approaches critical you can watch chains lengthen at the price action itself.
The EVENTS row shows the recent % chained — the plain-language twin of n — and the branching-ratio row carries a fill gauge so the number reads like a fuel gauge.


How to use it


Add to any liquid symbol/timeframe; defaults suit index futures — change the volume source and lower-timeframe for other markets.
Read the dashboard headline: STABLE / ELEVATED / CRITICAL. As it rises toward CRITICAL, the branching ratio is telling you the tape is increasingly self-referential and prone to cascades.
Use it as a risk overlay on top of your directional tools: when criticality is high, cut size, widen stops, or stand aside — regardless of which way you lean. When it's low and stable, normal sizing is more justified.
Keep de-seasonalization on (default). Turning it off will make opens and closes look critical when they may just be busy.


What makes it original

Retail order-flow tools measure intensity and call it strength. This measures endogeneity — the degree to which flow is feeding on itself — using a published market-reflexivity statistic, computed by a moment estimator that is feasible on a chart, and de-seasonalized so it isn't fooled by the daily rhythm (the exact bias the literature warns about). Reframing order flow from "how strong" to "how fragile," as an explicit size-down gauge, is the contribution.

Concept credits

Self-exciting point processes — A. G. Hawkes (1971). Reflexivity / branching ratio as market endogeneity and flash-crash analysis — V. Filimonov & D. Sornette. Moment (mean/variance) branching-ratio estimator — S. Hardiman & J.-P. Bouchaud (2014). Hawkes models of order flow — E. Bacry, J.-F. Muzy and co-authors. Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. The branching ratio is a descriptive statistic and a proxy — not a certainty and not a direction. High criticality does not predict which way price will move, only that flow is fragile. Validate independently and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  ORDER-FLOW CRITICALITY                                                   v1.2
//  Endogenous fragility of the tape via the Hawkes branching ratio.
// -----------------------------------------------------------------------------
//  v1.2 — Fragility velocity (additive; the estimator is unchanged):
//    • New read: is criticality BUILDING or EASING? nVel is the change in the
//      smoothed branching ratio over a short window. A rising n while ELEVATED is
//      an early warning that the tape is heading toward critical — visible BEFORE
//      the critical line is crossed, not after.
//    • FRAGILITY TREND row on the dashboard: ▲ building / ▼ easing / • steady.
//    • New export EXP_CriticalityVelocity and a "Fragility accelerating" alert
//      (fires once when n starts rising fast while elevated but not yet critical).
//    • The branching-ratio maths, de-seasonalization, dwell debounce and every
//      other read-out are unchanged from v1.1.
//  v1.1 — House-standard pass (no engine change):
//    • Added the MPL-2.0 licence header and an EXP_ Data-Window export bus.
//    • No correctness fix needed — no conditional ta.* in this script.
//    • No cost model: this is a descriptive fragility monitor, not a directional signal tool.
// -----------------------------------------------------------------------------
//  THE IDEA (fragility, not direction)
//    Most order-flow tools ask "how STRONG is flow?". This one asks "how
//    FRAGILE is it?" — how close the tape is to a self-sustaining cascade, where
//    each burst of aggressive flow tends to trigger the next. That is the
//    branching ratio n of a self-exciting (Hawkes) process: n≈0 means bursts are
//    independent (exogenous, stable); n→1 means the flow is nearly self-
//    sustaining (endogenous, critical, fragile). The output is a state read that
//    says SIZE DOWN as criticality rises — never a buy or sell.
//
//  HOW n IS ESTIMATED (and why this way)
//    Fitting a Hawkes kernel by maximum likelihood is heavy and fragile. Instead
//    this uses the model-independent MOMENT estimator of Hardiman & Bouchaud
//    (2014): for a self-exciting process the ratio of the variance to the mean of
//    the event COUNT (the Fano factor) grows as 1/(1−n)^2, so
//         n ≈ 1 − sqrt( mean_count / var_count )
//    computed over recent, non-overlapping counting bins. Only a mean and a
//    variance of counts are needed — readily obtained on a chart. n is clamped to
//    [0,1): a pure-random (Poisson) tape gives n≈0, a clustered tape gives n→1.
//
//  THE HONESTY STEP — DE-SEASONALIZATION
//    Research shows this estimator is biased UP by intraday seasonality: opens
//    and closes have naturally higher flow, which can masquerade as criticality
//    (a Poisson process with a changing rate can show a spurious n≈1). So an
//    "event" here is flow that is large RELATIVE TO ITS TIME OF DAY: the burst
//    threshold is normalized by a per-hour profile of recent flow. This removes
//    the daily rhythm so what remains is genuine self-excitation. (Toggle.)
//
//  WHAT AN EVENT IS
//    A bar whose absolute signed volume-delta exceeds its de-seasonalized typical
//    level. Delta is built from finest-available lower-timeframe signed volume,
//    with an automatic bar-shape fallback where intrabar data is unavailable.
//
//  HOW TO READ IT (price overlay)
//    Background tint intensifies as criticality rises; ● marks flow-burst events;
//    a SIZE-DOWN tag prints when the tape crosses into the critical zone. The
//    dashboard states STABLE / ELEVATED / CRITICAL, the branching ratio, and a
//    suggested size factor (1 − n). Fragility scales risk; it does not pick side.
//
//  NON-REPAINT
//    Events, counting bins and the estimator advance only on CONFIRMED bars; the
//    lower-timeframe delta is read on closed bars. The live bar is provisional.
//
//  USE ON ANY MARKET
//    Volume source and the lower-timeframe are selectable; every threshold is
//    relative. Defaults suit liquid index futures — change sources for others.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Self-exciting point processes — A. G. Hawkes (1971).
//    • Reflexivity / branching ratio as market endogeneity, flash-crash analysis
//      — V. Filimonov & D. Sornette.
//    • Moment (mean/variance) branching-ratio estimator — S. Hardiman &
//      J.-P. Bouchaud (2014).
//    • Hawkes models of order flow — E. Bacry, J.-F. Muzy, and co-authors.
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. The branching ratio is a descriptive
//    statistic of past flow on this chart and a proxy, not a certainty; it does
//    not predict direction. Validate independently and manage your own risk.
// =============================================================================
indicator("Order-Flow Criticality — Hawkes Branching Ratio", "OF Criticality",
     overlay = true, max_labels_count = 200, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE (any market) ════════════════════
g0 = "00 · Data source"
volSrc = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume series used to build signed order-flow delta. Point at an alternative feed where needed.")
useLtf = input.bool(true, "Delta from lower-timeframe volume", group = g0,
     tooltip = "ON = build signed delta from finer intrabar candles (truer order flow). Falls back to bar-shape automatically if intrabar data is unavailable on your plan/symbol.")
ltfPick = input.string("Auto (finest)", "Lower timeframe for delta",
     options = ["Auto (finest)", "1 second", "5 seconds", "1 minute"], group = g0,
     tooltip = "Auto uses the finest intrabar resolution available (1s where allowed, else 1m).")

// ═════════════════════════ 01 · EVENT DEFINITION ════════════════════════════
g1 = "01 · Event definition"
evThresh = input.float(2.0, "Burst threshold (× typical flow)", minval = 1.1, maxval = 6.0, step = 0.1, group = g1,
     tooltip = "A bar is a flow-burst 'event' when its absolute delta exceeds this multiple of the typical delta for its time of day. Higher = fewer, larger events.")
seasLen  = input.int(200, "Typical-flow lookback", minval = 20, maxval = 1000, group = g1,
     tooltip = "Baseline window for 'typical' flow when de-seasonalization is off.")
chainWin = input.int(3, "Chained if within (bars)", minval = 1, maxval = 20, group = g1,
     tooltip = "An event this close to the previous event is drawn as CHAINED (warm) — likely triggered by it, the self-excitation the branching ratio measures. Farther apart = ISOLATED (blue).")

// ═════════════════════════ 02 · BRANCHING RATIO ═════════════════════════════
g2 = "02 · Branching ratio (Hawkes)"
binLen  = input.int(5, "Counting-bin length (bars)", minval = 1, maxval = 50, group = g2,
     tooltip = "Events are counted in non-overlapping bins of this many bars; the mean and variance of those counts drive the estimator.")
nBins   = input.int(60, "Bins in the estimate", minval = 10, maxval = 500, group = g2,
     tooltip = "How many recent bins form the mean/variance. More = smoother, slower.")
nSmoothA= input.float(0.30, "Reading smoothing", minval = 0.02, maxval = 1.0, step = 0.02, group = g2,
     tooltip = "EMA smoothing of the branching-ratio reading between bin updates. Lower = smoother.")

// ═════════════════════════ 03 · DE-SEASONALIZATION ══════════════════════════
g3 = "03 · De-seasonalization"
deseasonOn = input.bool(true, "De-seasonalize by time of day", group = g3,
     tooltip = "ON (recommended) = judge a burst against typical flow for its HOUR, so opens/closes don't manufacture false criticality. This is the key honesty step for this estimator.")
seasAlpha  = input.float(0.05, "Session-profile adaptation", minval = 0.005, maxval = 0.5, step = 0.005, group = g3,
     tooltip = "How fast the per-hour typical-flow profile adapts. Lower = steadier profile.")

// ═════════════════════════ 04 · FRAGILITY OUTPUT ════════════════════════════
g4 = "04 · Fragility output"
warnLevel = input.float(0.60, "Elevated level", minval = 0.30, maxval = 0.95, step = 0.05, group = g4,
     tooltip = "Branching ratio at which the tape is flagged ELEVATED (tint begins).")
critLevel = input.float(0.80, "Critical level (size-down)", minval = 0.50, maxval = 0.99, step = 0.01, group = g4,
     tooltip = "Branching ratio at which the tape is flagged CRITICAL and a SIZE-DOWN tag prints.")
minDwell = input.int(5, "Confirm state after (bars)", minval = 1, maxval = 50, group = g4,
     tooltip = "Minimum-dwell debounce (standard anti-chattering design): a new STABLE/ELEVATED/CRITICAL state is ANNOUNCED only after it survives this many confirmed bars. Removes flicker at the cost of this many bars of lag — both stated.")
velLen   = input.int(10, "Fragility-trend window (bars)", minval = 2, maxval = 100, group = g4,
     tooltip = "Bars over which the change in the branching ratio is measured for the FRAGILITY TREND read and the 'Fragility accelerating' alert. Shorter = more reactive; longer = steadier trend.")
showLane = input.bool(true, "Criticality lane (strip at pane bottom)", group = g4,
     tooltip = "A thin colored strip along the bottom: green = stable, amber = elevated, red = critical. Risk colors (safe/danger), never direction.")
showTint  = input.bool(true, "Background fragility tint", group = g4)
showWarn  = input.bool(true, "SIZE-DOWN tag on crossing critical", group = g4)
showEvents= input.bool(true, "Mark flow-burst events", group = g4)

// ═════════════════════════ 05 · DASHBOARD ═══════════════════════════════════
g5 = "05 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g5)
compactTbl= input.bool(false, "Compact dashboard", group = g5)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g5)

// ═════════════════════════ 06 · MULTI-TIMEFRAME ═════════════════════════════
g6m = "06 · Multi-timeframe stack"
mtfOn = input.bool(true, "Show higher-timeframe criticality", group = g6m,
     tooltip = "Computes the RAW criticality state (no dwell — higher timeframes are inherently slower) on three higher timeframes derived as MULTIPLES of the chart. Stated approximations on HTF: bar-shape delta (lower-timeframe data cannot be nested inside a higher-timeframe request) and the global flow baseline instead of the hourly profile (an HTF bar spans multiple hours, so per-hour bucketing is ill-defined there). Standard HTF requests — every plan and symbol.")
mtfM1 = input.int(3,  "HTF multiple 1 (× chart)", minval = 2, maxval = 100, group = g6m)
mtfM2 = input.int(5,  "HTF multiple 2 (× chart)", minval = 2, maxval = 200, group = g6m)
mtfM3 = input.int(15, "HTF multiple 3 (× chart)", minval = 2, maxval = 500, group = g6m)

// ═════════════════════════ 07 · STYLE ═══════════════════════════════════════
g6 = "07 · Style"
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g6)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_BULL = #2ebd85
var color COL_BEAR = #f6465d
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cBear  = isDark ? #ff6b6b : #d32f2f
color cWarn  = isDark ? #ffa94d : #b56a00
color cMute  = isDark ? #6b7480 : #98a0ab
color zebraA = isDark ? color.new(#141a26, 0) : color.new(#eef1f6, 0)
color zebraB = isDark ? color.new(#0e131d, 0) : color.new(#f8fafc, 0)
color frameCl = tBord

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// ───────────────────────── HELPERS ──────────────────────────────────────────
// manual sample variance (portable across Pine builds)
f_arrVar(float[] a) =>
    int n = array.size(a)
    float v = na
    if n >= 2
        float m = array.avg(a)
        float ss = 0.0
        for i = 0 to n - 1
            float d = array.get(a, i) - m
            ss += d * d
        v := ss / (n - 1)
    v

// ───────────────────────── MTF RAW CRITICALITY (higher timeframes) ──────────
// Same moment estimator in a higher-timeframe context. Stated approximations:
// bar-shape delta and global baseline (see tooltip). Raw, no dwell. Returns
// -1 warming, 0 stable, 1 elevated, 2 critical.
f_critStateMTF() =>
    float bs = (high - low) > 0 ? nz(volSrc, 0.0) * ((close - low) - (high - close)) / (high - low) : 0.0
    float ad = math.abs(bs)
    float ref = ta.ema(ad, seasLen)
    float ds = ref > 0 ? ad / ref : na
    bool ev = not na(ds) and ds >= evThresh
    var int bAcc = 0
    var float[] bn = array.new_float(0)
    if barstate.isconfirmed
        if ev
            bAcc += 1
        if bar_index % binLen == 0
            array.push(bn, bAcc)
            if array.size(bn) > nBins
                array.shift(bn)
            bAcc := 0
    float mC = array.size(bn) >= 5 ? array.avg(bn) : na
    float vC = f_arrVar(bn)
    float nR = (not na(vC) and vC > 0.0 and not na(mC)) ? 1.0 - math.sqrt(math.max(mC / vC, 0.0)) : na
    float nB = na(nR) ? na : math.max(0.0, math.min(0.999, nR))
    var float nS = na
    if not na(nB)
        nS := na(nS) ? nB : nS + nSmoothA * (nB - nS)
    bool rdy = not na(nS) and array.size(bn) >= 10
    int st = not rdy ? -1 : nS >= critLevel ? 2 : nS >= warnLevel ? 1 : 0
    st

f_tfFromMult(int m) =>
    int secs = timeframe.in_seconds() * m
    secs % 604800 == 0 ? str.tostring(secs / 604800) + "W" : secs % 86400 == 0 ? str.tostring(secs / 86400) + "D" : secs % 60 == 0 ? str.tostring(secs / 60) : str.tostring(secs) + "S"
string htfTf1 = f_tfFromMult(mtfM1)
string htfTf2 = f_tfFromMult(mtfM2)
string htfTf3 = f_tfFromMult(mtfM3)
int htfCrit1 = request.security(syminfo.tickerid, htfTf1, f_critStateMTF(), lookahead = barmerge.lookahead_off)
int htfCrit2 = request.security(syminfo.tickerid, htfTf2, f_critStateMTF(), lookahead = barmerge.lookahead_off)
int htfCrit3 = request.security(syminfo.tickerid, htfTf3, f_critStateMTF(), lookahead = barmerge.lookahead_off)
f_crShort(int r) =>
    r == 2 ? "CRIT" : r == 1 ? "ELEV" : r == 0 ? "STAB" : "—"

// ───────────────────────── ORDER-FLOW DELTA (finest LTF, fallback) ──────────
f_ltfSel() =>
    switch ltfPick
        "1 second"  => "1S"
        "5 seconds" => "5S"
        "1 minute"  => "1"
        => "1S"
string ltfTf = f_ltfSel()
f_signedVol() => math.sign(close - close[1]) * volume
float[] ltfArr = request.security_lower_tf(syminfo.tickerid, ltfTf, f_signedVol())
float ltfSum = 0.0
if array.size(ltfArr) > 0
    for v in ltfArr
        ltfSum += nz(v)
bool ltfOk = useLtf and array.size(ltfArr) > 0
float barShape = (high - low) > 0 ? volSrc * ((close - low) - (high - close)) / (high - low) : 0.0
float delta = ltfOk ? ltfSum : barShape
float absDelta = math.abs(delta)
string deltaMode = ltfOk ? ("LTF " + ltfTf) : "bar-shape"

// ───────────────────────── DE-SEASONALIZED EVENT DETECTION ──────────────────
var float[] seas = array.new_float(24, na)
int hb = hour
float bucketRef = (hb >= 0 and hb < 24) ? array.get(seas, hb) : na
float globalRef = ta.ema(absDelta, seasLen)
if barstate.isconfirmed and hb >= 0 and hb < 24
    float prev = array.get(seas, hb)
    array.set(seas, hb, na(prev) ? absDelta : prev + seasAlpha * (absDelta - prev))
float refUse = deseasonOn ? nz(bucketRef, globalRef) : globalRef
float deseasoned = (not na(refUse) and refUse > 0) ? absDelta / refUse : na
bool isEvent = not na(deseasoned) and deseasoned >= evThresh

// cascade chains: an event arriving within chainWin bars of the previous one is
// drawn as CHAINED — endogeneity made visible (gap computed before updating)
var int lastEvBar = na
int evGap = na(lastEvBar) ? 999999 : bar_index - lastEvBar
bool chained = isEvent and evGap <= chainWin
if barstate.isconfirmed and isEvent
    lastEvBar := bar_index
var float chainFrac = na
if barstate.isconfirmed and isEvent
    chainFrac := na(chainFrac) ? (chained ? 1.0 : 0.0) : chainFrac + 0.05 * ((chained ? 1.0 : 0.0) - chainFrac)

// ───────────────────────── BRANCHING RATIO (moment estimator) ───────────────
var int binAcc = 0
var float[] bins = array.new_float(0)
if barstate.isconfirmed
    if isEvent
        binAcc += 1
    if bar_index % binLen == 0
        array.push(bins, binAcc)
        if array.size(bins) > nBins
            array.shift(bins)
        binAcc := 0

float meanC = array.size(bins) >= 5 ? array.avg(bins) : na
float varC  = array.size(bins) >= 5 ? f_arrVar(bins) : na
float fano  = (not na(varC) and not na(meanC) and meanC > 0.0) ? varC / meanC : na
float nRaw  = (not na(varC) and varC > 0.0 and not na(meanC)) ? 1.0 - math.sqrt(math.max(meanC / varC, 0.0)) : na
float nBranch = na(nRaw) ? na : math.max(0.0, math.min(0.999, nRaw))

var float nSmooth = na
if not na(nBranch)
    nSmooth := na(nSmooth) ? nBranch : nSmooth + nSmoothA * (nBranch - nSmooth)

bool readyR = not na(nSmooth) and array.size(bins) >= 10
int rawState = not readyR ? -1 : nSmooth >= critLevel ? 2 : nSmooth >= warnLevel ? 1 : 0
// minimum-dwell debounce: a new state is announced only after it survives
// minDwell confirmed bars (anti-chattering; lag = dwell bars, stated)
var int cstate = -1
var int ccand  = -1
var int ccAge  = 0
if barstate.isconfirmed
    if rawState == cstate
        ccand := cstate
        ccAge := 0
    else
        if rawState == ccand
            ccAge += 1
        else
            ccand := rawState
            ccAge := 1
        if ccAge >= minDwell or cstate == -1
            cstate := rawState
            ccand := rawState
            ccAge := 0
bool ready = cstate != -1
bool critical = cstate == 2
bool elevated = cstate >= 1
int stabWin = 50
int stabSame = 0
for k = 0 to stabWin - 1
    if nz(cstate[k], -9) == cstate
        stabSame += 1
float stabPct = ready ? stabSame * 100.0 / stabWin : na
float sizeMult = ready ? math.max(0.0, 1.0 - nSmooth) : na
string stateTxt = not ready ? "WARMING" : critical ? "CRITICAL" : elevated ? "ELEVATED" : "STABLE"

// event rate (events per bin, recent) for context
float evRate = not na(meanC) ? meanC : na

// ── FRAGILITY VELOCITY (v1.2): is criticality building or easing? ────────────
// nVel = change in the smoothed branching ratio over velLen bars. A rising n
// while ELEVATED is an early warning — fragility heading toward critical BEFORE
// the line is crossed. velThr is the "steady" dead-band (branching-ratio points).
float velThr = 0.02
float nVel   = (not na(nSmooth) and not na(nSmooth[velLen])) ? nSmooth - nSmooth[velLen] : na
bool  fragBuilding = ready and not na(nVel) and nVel >  velThr
bool  fragEasing   = ready and not na(nVel) and nVel < -velThr
// "accelerating" = building while elevated but not yet critical (the actionable warning).
// Edge via a var tracker (no nz() on a bool), evaluated on confirmed bars.
bool  fragAccel = elevated and not critical and fragBuilding
var bool fragAccelPrev = false
bool  fragAccelNew = barstate.isconfirmed and fragAccel and not fragAccelPrev
if barstate.isconfirmed
    fragAccelPrev := fragAccel

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
// fragility tint: intensifies as the branching ratio rises past 'elevated'
// subtle tint: the lane and tags carry the state; tint is context only (90–95 band)
int tintTransp = ready ? int(math.max(90.0, 96.0 - nSmooth * 5.0)) : 100
color tintC = not elevated ? na : critical ? color.new(COL_BEAR, tintTransp) : color.new(COL_MID, tintTransp)
bgcolor(showTint ? tintC : na, title = "Fragility tint")

// criticality lane: thin colored strip at the pane bottom (risk glance-read)
color laneC = critical ? color.new(COL_BEAR, 0) : elevated ? color.new(COL_MID, 0) : color.new(COL_BULL, 40)
plotshape(showLane and ready, "Criticality lane", style = shape.square, location = location.bottom, color = laneC, size = size.tiny)

plotshape(showEvents and isEvent and not chained, "Flow burst (isolated)", style = shape.circle, location = location.belowbar, color = color.new(COL_INFO, 20), size = size.tiny)
plotshape(showEvents and chained, "Flow burst (chained)", style = shape.circle, location = location.belowbar, color = color.new(COL_BEAR, 10), size = size.tiny)

// SIZE-DOWN tag when crossing into critical
var label[] warnLabels = array.new<label>()
bool critNew = barstate.isconfirmed and critical and nz(cstate[1], -2) != 2
if showWarn and critNew
    lb = label.new(bar_index, high, "SIZE DOWN", style = label.style_label_down, color = color.new(COL_BEAR, 10), textcolor = color.white, size = size.small)
    array.push(warnLabels, lb)
    if array.size(warnLabels) > 50
        label.delete(array.shift(warnLabels))

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_gauge(float x) =>
    int fill = int(math.round(math.max(0.0, math.min(1.0, x)) * 8))
    string g = ""
    for i = 0 to 7
        g += i < fill ? "█" : "░"
    g

f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

var table dash = na
if showDash and barstate.islast
    color stBg = not ready ? color.new(cMute, 0) : critical ? color.new(cBear, 0) : elevated ? color.new(cWarn, 0) : color.new(cBull, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 12, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " ORDER-FLOW CRITICALITY", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Branching ratio n of aggressive flow. n≈0 = independent bursts (stable); n→1 = self-sustaining (fragile). A descriptive proxy of past flow, not a prediction and not a direction.")
    table.cell(dash, 1, 0, stateTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    string nTxt = not ready ? "warming" : f_gauge(nSmooth) + "  " + str.tostring(nSmooth, "0.00")
    color  nCol = not ready ? cMute : critical ? cBear : elevated ? cWarn : cBull
    f_setRow(dash, 1, "BRANCHING RATIO n", nTxt, nCol, tLbl, zebraA)
    f_setRow(dash, 2, "SUGGESTED SIZE", na(sizeMult) ? "-" : "× " + str.tostring(sizeMult, "0.00"), na(sizeMult) ? cMute : sizeMult >= 0.5 ? cBull : cWarn, tLbl, zebraB)
    string fragTrTxt = na(nVel) ? "—" : fragBuilding ? "▲ building  " + str.tostring(nVel, "+0.00") : fragEasing ? "▼ easing  " + str.tostring(nVel, "+0.00") : "• steady"
    color  fragTrCol = na(nVel) ? cMute : fragBuilding ? cBear : fragEasing ? cBull : tVal
    if compactTbl
        f_setRow(dash, 3, "FLOW / bin", na(evRate) ? "-" : str.tostring(evRate, "0.0") + " · " + deltaMode, tVal, tLbl, zebraA)
    else
        f_setRow(dash, 3, "FRAGILITY TREND", fragTrTxt, fragTrCol, tLbl, zebraA)
        f_setRow(dash, 4, "STABILITY", na(stabPct) ? "-" : str.tostring(math.round(stabPct)) + "% of last " + str.tostring(stabWin), na(stabPct) ? cMute : stabPct >= 80 ? cBull : stabPct >= 50 ? tVal : cWarn, tLbl, zebraB)
        string pendTxt = ready and ccand != cstate and ccAge > 0 ? f_crShort(ccand) + " in " + str.tostring(minDwell - ccAge) + " bars" : "none"
        f_setRow(dash, 5, "PENDING", pendTxt, pendTxt == "none" ? cMute : cWarn, tLbl, zebraA)
        f_setRow(dash, 6, "FANO (var/mean)", na(fano) ? "-" : str.tostring(fano, "0.00"), na(fano) ? cMute : fano > 1.0 ? cWarn : tVal, tLbl, zebraB)
        f_setRow(dash, 7, "EVENTS / bin", na(evRate) ? "-" : str.tostring(evRate, "0.0") + (na(chainFrac) ? "" : " · " + str.tostring(math.round(chainFrac * 100)) + "% chained"), tVal, tLbl, zebraA)
        f_setRow(dash, 8, "DELTA SOURCE", deltaMode, ltfOk ? cBull : cWarn, tLbl, zebraB)
        f_setRow(dash, 9, "DE-SEASON", deseasonOn ? "on (by hour)" : "off", deseasonOn ? cBull : cMute, tLbl, zebraA)
        if mtfOn
            bool mtfAgree = htfCrit1 == cstate and htfCrit2 == cstate and htfCrit3 == cstate and ready
            bool mtfWarnHi = ready and cstate != 2 and (htfCrit1 == 2 or htfCrit2 == 2 or htfCrit3 == 2)
            string mtfTxt = str.tostring(mtfM1) + "× " + f_crShort(htfCrit1) + " · " + str.tostring(mtfM2) + "× " + f_crShort(htfCrit2) + " · " + str.tostring(mtfM3) + "× " + f_crShort(htfCrit3) + (mtfAgree ? "  ✓" : mtfWarnHi ? "  ⚠" : "")
            f_setRow(dash, 10, "HTF STACK", mtfTxt, mtfAgree ? cBull : mtfWarnHi ? cWarn : tVal, tLbl, zebraB)
        else
            f_setRow(dash, 10, "HTF STACK", "off", cMute, tLbl, zebraB)
        f_setRow(dash, 11, "BINS", str.tostring(array.size(bins)) + " / " + str.tostring(nBins) + " · dwell " + str.tostring(minDwell), tVal, tLbl, zebraA)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "OF Criticality  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(nSmooth,  "EXP_BranchingRatio",   display = display.data_window)
plot(fano,     "EXP_FanoFactor",       display = display.data_window)
plot(evRate,   "EXP_EventsPerBin",     display = display.data_window)
plot(sizeMult, "EXP_SuggestedSize",    display = display.data_window)
plot(delta,    "EXP_SignedDelta",      display = display.data_window)
plot(chainFrac, "EXP_ChainedFraction", display = display.data_window)
plot(ready ? cstate : na, "EXP_FragilityState", display = display.data_window)
plot(stabPct, "EXP_CriticalityStability", display = display.data_window)
plot(mtfOn ? htfCrit1 : na, "EXP_CriticalityHTF1", display = display.data_window)
plot(mtfOn ? htfCrit2 : na, "EXP_CriticalityHTF2", display = display.data_window)
plot(mtfOn ? htfCrit3 : na, "EXP_CriticalityHTF3", display = display.data_window)
plot(nVel, "EXP_CriticalityVelocity", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(critNew, "Flow turned critical", "Order-Flow Criticality: branching ratio crossed into the critical zone — consider sizing down")
alertcondition(barstate.isconfirmed and elevated and nz(cstate[1], -2) < 1, "Flow turned elevated", "Order-Flow Criticality: endogeneity rising")
alertcondition(fragAccelNew, "Fragility accelerating", "Order-Flow Criticality: branching ratio rising fast while elevated — fragility building toward critical (early warning).")
````
