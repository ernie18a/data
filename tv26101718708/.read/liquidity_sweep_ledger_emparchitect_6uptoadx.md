# Liquidity Sweep Ledger [EmpArchitect]

- url: https://www.tradingview.com/script/6uptOaDX-Liquidity-Sweep-Ledger-EmpArchitect/
- type: indicator
- pine_id: PUB;ff205b4d6a5c4eb48da94a98e9b55324
- version: 1.0

## Description

█ OVERVIEW

Liquidity Sweep Ledger [EmpArchitect] maps buy-side and sell-side liquidity levels, then tracks what happened after those levels were swept.

Most liquidity tools mark the sweep and stop there.

This script keeps a simple ledger:

• Liquidity level active
• BSL / SSL swept
• Reclaimed or not reclaimed
• Displacement after sweep
• Structure shift after sweep
• No follow-through
• Dual sweep / ambiguous sweep

It is a structure-context tool. It does not provide entries, stop losses, targets, risk/reward, probability scores, or trade signals.

█ WHAT IT MAPS

Buy-side liquidity — BSL:

A level above price formed from confirmed swing highs, equal-high clusters, previous day high, or previous week high.

Sell-side liquidity — SSL:

A level below price formed from confirmed swing lows, equal-low clusters, previous day low, or previous week low.

When price sweeps one or more levels, the script records the sweep and tracks its lifecycle.

█ HOW IT WORKS

The script uses confirmed pivots only. A swing high or swing low becomes an active liquidity level only after the pivot is confirmed.

Sweep detection uses an ATR-scaled penetration buffer. Price must trade beyond the liquidity level by the selected minimum threshold before the level is marked as swept.

If several same-side levels are swept on one candle, the script aggregates them into one event, such as BSL swept x2 or SSL swept x3.

After a sweep, the script tracks whether price reclaims the level within the selected reclaim window.

For post-sweep response, the script checks for directional displacement using body size relative to ATR and body size relative to candle range.

For structure shift, the script freezes the latest confirmed opposite-side internal pivot at the time of the sweep and then checks whether price closes beyond that reference later.

Same-candle or sequential two-sided sweeps are marked as dual / ambiguous instead of being treated as directional events.

█ SWEEP LIFECYCLE

The script separates the sweep from the response.

A sweep can become:

• Pending reclaim
• Reclaimed
• Taken / no reclaim
• Displaced
• Structure shifted
• No follow-through
• Dual sweep / ambiguous

This matters because not every liquidity sweep produces the same response. Some levels are swept and reclaimed. Some are taken without reclaim. Some lead to displacement. Some produce no follow-through.

The script records the state instead of forcing a directional interpretation.

█ LIQUIDITY SOURCES

Included sources:

• Swing high / swing low liquidity
• Equal-high / equal-low clustering
• Previous day high / previous day low
• Previous week high / previous week low

Default source settings:

• Swing liquidity: ON
• Equal-high / equal-low clustering: ON
• Previous day high/low: ON
• Previous week high/low: OFF

Previous week high/low is included but disabled by default. Review it on your market/timeframe before enabling it.

█ DASHBOARD AND LEDGER

The dashboard shows the current liquidity-sweep ledger:

• Last sweep
• Source
• Reclaim state
• Response state
• Age
• Active BSL count
• Active SSL count
• Compact last-sweeps ledger

The ledger is the main feature. It helps review what happened after liquidity was taken.

Response detail is recorded in the ledger and dashboard. On-chart response labels are optional and are off by default to keep the chart clean.

█ ALERTS

Included context alerts:

• BSL swept
• SSL swept
• Dual sweep
• Reclaimed
• Displaced
• Structure shift
• Taken / no reclaim
• No follow-through

Alerts are structure-context alerts only. They are not trade signals.

█ TESTING NOTES

Tested during development on BTCUSDT 1H and XAUUSD 1H.

Other markets and timeframes may require adjustment of pivot length, ATR penetration, reclaim window, and response settings.

█ PAIRS WITH

Smart Liquidity Map [EmpArchitect] — broader liquidity map: EQH/EQL zones, PDH/PDL, and PWH/PWL reference levels.

Liquidity Sweep Ledger focuses on the next step: once liquidity is swept, did price reclaim, displace, shift structure, or fail to follow through?


█ IMPORTANT LIMITATIONS

• A liquidity sweep is not a trade entry.
• A reclaim is not a trade signal.
• Displacement does not guarantee continuation.
• Structure shift is a mapped event, not a recommendation.
• Results depend on pivot length, ATR settings, market, and timeframe.
• The script is designed for chart review, not automated trading.

█ NOTES

• Pine Script v6
• Public and open-source
• Built by EmpArchitect
• Educational structure-context tool only
• Not financial advice
• Not a signal service

█ CORE IDEA

Liquidity Sweep Ledger maps liquidity sweeps and tracks whether price reclaimed, displaced, shifted structure, or produced no follow-through.

It gives the map.
The trader makes the decision.

## Source Code

````pine
// =============================================================================
// Liquidity Sweep Ledger [EmpArchitect]  v1.3
// Public / open-source / free
// Structure-context tool. NOT a signal service.
// Maps BSL/SSL liquidity sweeps and tracks post-sweep lifecycle:
//   swept -> reclaimed/taken -> displacement -> structure shift -> no follow-through
// No entries, no SL/TP, no R:R, no probability, no buy/sell language.
// =============================================================================
//@version=6
indicator("Liquidity Sweep Ledger [EmpArchitect]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 0)

// ---------------------------------------------------------------------------
// CONSTANTS
// ---------------------------------------------------------------------------
int SIDE_BSL = 1
int SIDE_SSL = -1

int SRC_SWING = 1
int SRC_PDH   = 2
int SRC_PDL   = 3
int SRC_PWH   = 4
int SRC_PWL   = 5

int LVL_ACTIVE  = 1
int LVL_SWEPT   = 2
int LVL_EXPIRED = 3

int EV_PENDING_RECLAIM   = 1
int EV_RECLAIMED         = 2
int EV_TAKEN_NO_RECLAIM  = 3
int EV_DISPLACED         = 4
int EV_STRUCTURE_SHIFTED = 5
int EV_NO_FOLLOW_THROUGH = 6
int EV_DUAL              = 7

// ---------------------------------------------------------------------------
// INPUTS — Liquidity Sources
// ---------------------------------------------------------------------------
string gSrc = "Liquidity Sources"
bool showSwing   = input.bool(true,  "Show swing liquidity",          group = gSrc)
bool clusterEq   = input.bool(true,  "Cluster equal highs/lows",      group = gSrc)
bool showPD      = input.bool(true,  "Show previous day high/low",    group = gSrc)
bool showPW      = input.bool(false, "Show previous week high/low",   group = gSrc)

// INPUTS — Detection
string gDet = "Detection"
int   pivotLen     = input.int(3,    "Pivot length",                  minval = 1, group = gDet)
int   atrLen       = input.int(14,   "ATR length",                    minval = 1, group = gDet)
float clusterTolAtr= input.float(0.10,"Cluster tolerance (ATR)",      minval = 0, step = 0.01, group = gDet)
float minSweepAtr  = input.float(0.05,"Minimum sweep penetration (ATR)",minval = 0, step = 0.01, group = gDet)
int   minTicks     = input.int(1,    "Minimum penetration (ticks)",   minval = 0, group = gDet)
int   reclaimWin   = input.int(2,    "Reclaim window (bars)",         minval = 1, group = gDet)

// INPUTS — Response
string gResp = "Response"
int   respWin      = input.int(20,   "Response window (bars)",        minval = 1, group = gResp)
float minDispAtr   = input.float(0.50,"Minimum displacement body / ATR",minval = 0, step = 0.05, group = gResp)
float minBodyRatio = input.float(0.50,"Minimum body / range",         minval = 0, maxval = 1, step = 0.05, group = gResp)
int   structPivLen = input.int(3,    "Structure pivot length",        minval = 1, group = gResp)

// INPUTS — Retention
string gRet = "Retention"
int   maxBSL    = input.int(5,   "Max active BSL levels",   minval = 1, group = gRet)
int   maxSSL    = input.int(5,   "Max active SSL levels",   minval = 1, group = gRet)
int   lvlExpiry = input.int(300, "Level expiry (bars)",     minval = 1, group = gRet)
int   ledgerLen = input.int(5,   "Ledger history (sweeps)", minval = 1, maxval = 20, group = gRet)

// INPUTS — Display
string gDis = "Display"
bool showLines   = input.bool(true, "Show active liquidity lines", group = gDis)
bool showSweepLb = input.bool(true, "Show sweep labels",           group = gDis)
bool showRespLb  = input.bool(false, "Show response labels",        group = gDis)
bool showDash    = input.bool(true, "Show dashboard",              group = gDis)
bool showLedger  = input.bool(true, "Show compact ledger",         group = gDis)

// Colors
color colBSL  = input.color(color.new(#ef5350, 0),  "BSL color",  group = gDis)
color colSSL  = input.color(color.new(#26a69a, 0),  "SSL color",  group = gDis)
color colFade = input.color(color.new(color.gray, 60), "Swept (faded)", group = gDis)

// ---------------------------------------------------------------------------
// TYPES
// ---------------------------------------------------------------------------
type LiqLevel
    float price
    int   side
    int   source
    int   activeFromBar
    int   touches
    int   state
    line  ln
    label lb

type SweepEvent
    float levelPrice
    int   side
    int   source
    int   sweepBar
    int   sweptCount
    float sweepHigh
    float sweepLow
    float shiftRef
    int   state
    int   age
    bool  hasShiftRef
    int   alertedState
    label lb

// ---------------------------------------------------------------------------
// STATE
// ---------------------------------------------------------------------------
var array<LiqLevel>   bslLevels = array.new<LiqLevel>()
var array<LiqLevel>   sslLevels = array.new<LiqLevel>()
var array<SweepEvent> events    = array.new<SweepEvent>()

float atr = ta.atr(atrLen)

// penetration buffer per spec
float penBuffer = math.max(syminfo.mintick * minTicks, nz(atr) * minSweepAtr)
float clusterTol = nz(atr) * clusterTolAtr

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------
srcStr(int s) =>
    s == SRC_SWING ? "Swing" : s == SRC_PDH ? "PDH" : s == SRC_PDL ? "PDL" : s == SRC_PWH ? "PWH" : s == SRC_PWL ? "PWL" : "?"

sideStr(int s) =>
    s == SIDE_BSL ? "BSL" : s == SIDE_SSL ? "SSL" : "Dual"

evStr(int st) =>
    switch st
        EV_PENDING_RECLAIM   => "Pending reclaim"
        EV_RECLAIMED         => "Reclaimed"
        EV_TAKEN_NO_RECLAIM  => "Taken/no reclaim"
        EV_DISPLACED         => "Displaced"
        EV_STRUCTURE_SHIFTED => "Shifted"
        EV_NO_FOLLOW_THROUGH => "No follow-through"
        EV_DUAL              => "Ambiguous"
        => "?"

// ---------------------------------------------------------------------------
// CONFIRMED PIVOTS (non-repaint: confirmed pivotLen bars ago)
// ---------------------------------------------------------------------------
float ph = ta.pivothigh(pivotLen, pivotLen)
float pl = ta.pivotlow(pivotLen, pivotLen)

// Structure pivots (separate length) for shift reference
float sph = ta.pivothigh(structPivLen, structPivLen)
float spl = ta.pivotlow(structPivLen, structPivLen)
var float lastConfPivotHigh = na
var float lastConfPivotLow  = na
if not na(sph)
    lastConfPivotHigh := sph
if not na(spl)
    lastConfPivotLow := spl

// ---------------------------------------------------------------------------
// LEVEL CREATION + CLUSTERING
// ---------------------------------------------------------------------------
addOrCluster(array<LiqLevel> arr, float price, int side, int source, int maxN) =>
    bool merged = false
    if clusterEq and source == SRC_SWING and array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            LiqLevel lv = array.get(arr, i)
            if lv.state == LVL_ACTIVE and lv.source == SRC_SWING and math.abs(price - lv.price) <= clusterTol
                lv.price := side == SIDE_BSL ? math.max(lv.price, price) : math.min(lv.price, price)
                lv.touches += 1
                merged := true
                break
    if not merged
        LiqLevel nl = LiqLevel.new(price, side, source, bar_index, 1, LVL_ACTIVE, na, na)
        array.push(arr, nl)
        // enforce cap: drop oldest active
        if array.size(arr) > maxN
            LiqLevel old = array.shift(arr)
            if not na(old.ln)
                line.delete(old.ln)
            if not na(old.lb)
                label.delete(old.lb)

// add swing levels on confirmation
if showSwing and not na(ph)
    addOrCluster(bslLevels, ph, SIDE_BSL, SRC_SWING, maxBSL)
if showSwing and not na(pl)
    addOrCluster(sslLevels, pl, SIDE_SSL, SRC_SWING, maxSSL)

// PDH/PDL — confirmed previous day, appears after new day starts
float dHigh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
float dLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
bool newDay = timeframe.change("D")
if showPD and newDay and not na(dHigh) and not na(dLow)
    array.push(bslLevels, LiqLevel.new(dHigh, SIDE_BSL, SRC_PDH, bar_index, 1, LVL_ACTIVE, na, na))
    array.push(sslLevels, LiqLevel.new(dLow,  SIDE_SSL, SRC_PDL, bar_index, 1, LVL_ACTIVE, na, na))
    if array.size(bslLevels) > maxBSL
        LiqLevel o = array.shift(bslLevels)
        if not na(o.ln)
            line.delete(o.ln)
        if not na(o.lb)
            label.delete(o.lb)
    if array.size(sslLevels) > maxSSL
        LiqLevel o = array.shift(sslLevels)
        if not na(o.ln)
            line.delete(o.ln)
        if not na(o.lb)
            label.delete(o.lb)

// PWH/PWL — confirmed previous week, appears after new week starts
float wHigh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
float wLow  = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)
bool newWeek = timeframe.change("W")
if showPW and newWeek and not na(wHigh) and not na(wLow)
    array.push(bslLevels, LiqLevel.new(wHigh, SIDE_BSL, SRC_PWH, bar_index, 1, LVL_ACTIVE, na, na))
    array.push(sslLevels, LiqLevel.new(wLow,  SIDE_SSL, SRC_PWL, bar_index, 1, LVL_ACTIVE, na, na))
    if array.size(bslLevels) > maxBSL
        LiqLevel o = array.shift(bslLevels)
        if not na(o.ln)
            line.delete(o.ln)
        if not na(o.lb)
            label.delete(o.lb)
    if array.size(sslLevels) > maxSSL
        LiqLevel o = array.shift(sslLevels)
        if not na(o.ln)
            line.delete(o.ln)
        if not na(o.lb)
            label.delete(o.lb)

// ---------------------------------------------------------------------------
// EXPIRY
// ---------------------------------------------------------------------------
expireLevels(array<LiqLevel> arr) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            LiqLevel lv = array.get(arr, i)
            if lv.state == LVL_ACTIVE and (bar_index - lv.activeFromBar) > lvlExpiry
                lv.state := LVL_EXPIRED
                if not na(lv.ln)
                    line.delete(lv.ln)
                    lv.ln := na
                if not na(lv.lb)
                    label.delete(lv.lb)
                    lv.lb := na
expireLevels(bslLevels)
expireLevels(sslLevels)

// ---------------------------------------------------------------------------
// SWEEP DETECTION (confirmed bars, aggregate same-side, dual detection)
// ---------------------------------------------------------------------------
// Per-bar transition flags. Declared here so both sweep detection and the
// lifecycle block can set them at the exact bar a transition occurs.
var bool fBSLsweep = false
var bool fSSLsweep = false
var bool fDual     = false
var bool fReclaim  = false
var bool fDisplace = false
var bool fShift    = false
var bool fTaken    = false
var bool fNoFollow = false
fBSLsweep := false
fSSLsweep := false
fDual := false
fReclaim := false
fDisplace := false
fShift := false
fTaken := false
fNoFollow := false

// Opposite-side sweep before response confirmation → ambiguous.
// Marks any in-flight opposite event as dual AND returns true so the caller
// suppresses a new directional event (logs an ambiguous dual instead).
markOppositeInFlight(int newSide) =>
    bool marked = false
    if array.size(events) > 0
        for i = 0 to array.size(events) - 1
            SweepEvent pe = array.get(events, i)
            bool inFlight = pe.state == EV_PENDING_RECLAIM or pe.state == EV_RECLAIMED
            if inFlight and pe.side != 0 and pe.side != newSide
                pe.state := EV_DUAL
                pe.alertedState := 0
                marked := true
                if not na(pe.lb)
                    label.set_text(pe.lb, "Dual sweep")
                    label.set_color(pe.lb, color.new(color.gray, 20))
    marked

if barstate.isconfirmed
    // --- BSL side: aggregate all swept BSL levels this bar
    float bestBSL = na
    int   bslSweptCnt = 0
    int   bslSource = SRC_SWING
    if array.size(bslLevels) > 0
        for i = 0 to array.size(bslLevels) - 1
            LiqLevel lv = array.get(bslLevels, i)
            if lv.state == LVL_ACTIVE and lv.activeFromBar < bar_index and high > lv.price + penBuffer
                bslSweptCnt += 1
                if na(bestBSL) or lv.price > bestBSL
                    bestBSL := lv.price
                    bslSource := lv.source
                lv.state := LVL_SWEPT

    // --- SSL side: aggregate all swept SSL levels this bar
    float bestSSL = na
    int   sslSweptCnt = 0
    int   sslSource = SRC_SWING
    if array.size(sslLevels) > 0
        for i = 0 to array.size(sslLevels) - 1
            LiqLevel lv = array.get(sslLevels, i)
            if lv.state == LVL_ACTIVE and lv.activeFromBar < bar_index and low < lv.price - penBuffer
                sslSweptCnt += 1
                if na(bestSSL) or lv.price < bestSSL
                    bestSSL := lv.price
                    sslSource := lv.source
                lv.state := LVL_SWEPT

    bool sweptBSL = bslSweptCnt > 0
    bool sweptSSL = sslSweptCnt > 0

    if sweptBSL and sweptSSL
        // Dual sweep — same candle both sides, no directional response
        SweepEvent ev = SweepEvent.new(na, 0, SRC_SWING, bar_index, bslSweptCnt + sslSweptCnt, high, low, na, EV_DUAL, 0, false, 0, na)
        array.push(events, ev)
        fDual := true
        if showSweepLb
            ev.lb := label.new(bar_index, high, "Dual sweep", style = label.style_label_down, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)
    else if sweptBSL
        bool seqDual = markOppositeInFlight(SIDE_BSL)
        if seqDual
            SweepEvent ev = SweepEvent.new(na, 0, SRC_SWING, bar_index, bslSweptCnt, high, low, na, EV_DUAL, 0, false, 0, na)
            array.push(events, ev)
            fDual := true
            if showSweepLb
                ev.lb := label.new(bar_index, high, "Dual sweep", style = label.style_label_down, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)
        else
            SweepEvent ev = SweepEvent.new(bestBSL, SIDE_BSL, bslSource, bar_index, bslSweptCnt, high, low, lastConfPivotLow, EV_PENDING_RECLAIM, 0, not na(lastConfPivotLow), 0, na)
            array.push(events, ev)
            fBSLsweep := true
            if showSweepLb
                string t = "BSL swept" + (bslSweptCnt > 1 ? " x" + str.tostring(bslSweptCnt) : "")
                ev.lb := label.new(bar_index, high, t, style = label.style_label_down, color = color.new(colBSL, 20), textcolor = color.white, size = size.small)
    else if sweptSSL
        bool seqDual = markOppositeInFlight(SIDE_SSL)
        if seqDual
            SweepEvent ev = SweepEvent.new(na, 0, SRC_SWING, bar_index, sslSweptCnt, high, low, na, EV_DUAL, 0, false, 0, na)
            array.push(events, ev)
            fDual := true
            if showSweepLb
                ev.lb := label.new(bar_index, low, "Dual sweep", style = label.style_label_up, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)
        else
            SweepEvent ev = SweepEvent.new(bestSSL, SIDE_SSL, sslSource, bar_index, sslSweptCnt, high, low, lastConfPivotHigh, EV_PENDING_RECLAIM, 0, not na(lastConfPivotHigh), 0, na)
            array.push(events, ev)
            fSSLsweep := true
            if showSweepLb
                string t = "SSL swept" + (sslSweptCnt > 1 ? " x" + str.tostring(sslSweptCnt) : "")
                ev.lb := label.new(bar_index, low, t, style = label.style_label_up, color = color.new(colSSL, 20), textcolor = color.white, size = size.small)

// ---------------------------------------------------------------------------
// EVENT LIFECYCLE PROCESSING (reclaim, displacement, structure shift, timeout)
// ---------------------------------------------------------------------------
if barstate.isconfirmed and array.size(events) > 0
    for i = 0 to array.size(events) - 1
        SweepEvent ev = array.get(events, i)
        ev.age := bar_index - ev.sweepBar

        // Terminal states: dual, taken/no-reclaim, no-follow-through, shifted.
        // Displaced is NOT terminal — a structure shift can still upgrade it.
        if ev.state != EV_DUAL and ev.state != EV_TAKEN_NO_RECLAIM and ev.state != EV_NO_FOLLOW_THROUGH and ev.state != EV_STRUCTURE_SHIFTED
            int barsSince = bar_index - ev.sweepBar

            // ----- Pending reclaim window -----
            if ev.state == EV_PENDING_RECLAIM
                bool reclaimed = ev.side == SIDE_BSL ? close < ev.levelPrice : close > ev.levelPrice
                if reclaimed and barsSince <= reclaimWin
                    ev.state := EV_RECLAIMED
                    fReclaim := true
                    if showRespLb
                        label.new(bar_index, ev.side == SIDE_BSL ? high : low, "Reclaimed", style = ev.side == SIDE_BSL ? label.style_label_down : label.style_label_up, color = color.new(color.orange, 30), textcolor = color.white, size = size.tiny)
                else if barsSince > reclaimWin
                    ev.state := EV_TAKEN_NO_RECLAIM
                    fTaken := true
                    if showRespLb
                        label.new(bar_index, ev.side == SIDE_BSL ? high : low, "Taken/no reclaim", style = ev.side == SIDE_BSL ? label.style_label_down : label.style_label_up, color = color.new(color.gray, 40), textcolor = color.white, size = size.tiny)

            // ----- After reclaim: track displacement & structure shift -----
            if ev.state == EV_RECLAIMED or ev.state == EV_DISPLACED
                bool inWindow = barsSince <= respWin
                float body = math.abs(close - open)
                float rng  = high - low
                bool bodyOk = rng > 0 and (body / rng) >= minBodyRatio
                bool atrOk  = nz(atr) > 0 and (body / atr) >= minDispAtr
                // displacement (only from reclaimed, only on bars after sweep bar)
                if ev.state == EV_RECLAIMED and inWindow and bar_index > ev.sweepBar
                    if ev.side == SIDE_BSL and close < open and bodyOk and atrOk and close < ev.sweepLow
                        ev.state := EV_DISPLACED
                        fDisplace := true
                        if showRespLb
                            label.new(bar_index, high, "Displaced", style = label.style_label_down, color = color.new(colBSL, 10), textcolor = color.white, size = size.tiny)
                    else if ev.side == SIDE_SSL and close > open and bodyOk and atrOk and close > ev.sweepHigh
                        ev.state := EV_DISPLACED
                        fDisplace := true
                        if showRespLb
                            label.new(bar_index, low, "Displaced", style = label.style_label_up, color = color.new(colSSL, 10), textcolor = color.white, size = size.tiny)
                // structure shift — can upgrade from reclaimed OR displaced (only if frozen ref exists)
                if (ev.state == EV_RECLAIMED or ev.state == EV_DISPLACED) and inWindow and ev.hasShiftRef and bar_index > ev.sweepBar
                    if ev.side == SIDE_BSL and close < ev.shiftRef
                        ev.state := EV_STRUCTURE_SHIFTED
                        fShift := true
                        if showRespLb
                            label.new(bar_index, high, "Shifted", style = label.style_label_down, color = color.new(colBSL, 0), textcolor = color.white, size = size.tiny)
                    else if ev.side == SIDE_SSL and close > ev.shiftRef
                        ev.state := EV_STRUCTURE_SHIFTED
                        fShift := true
                        if showRespLb
                            label.new(bar_index, low, "Shifted", style = label.style_label_up, color = color.new(colSSL, 0), textcolor = color.white, size = size.tiny)
                // no follow-through timeout — applies to reclaimed or displaced still in flight
                if (ev.state == EV_RECLAIMED or ev.state == EV_DISPLACED) and not inWindow
                    ev.state := EV_NO_FOLLOW_THROUGH
                    fNoFollow := true
                    if showRespLb
                        label.new(bar_index, ev.side == SIDE_BSL ? high : low, "No follow-through", style = ev.side == SIDE_BSL ? label.style_label_down : label.style_label_up, color = color.new(color.gray, 50), textcolor = color.white, size = size.tiny)

// trim events array to ledger length (keep most recent)
if array.size(events) > math.max(ledgerLen, 10)
    SweepEvent old = array.shift(events)
    if not na(old.lb)
        label.delete(old.lb)

// ---------------------------------------------------------------------------
// DRAW / EXTEND ACTIVE LINES
// ---------------------------------------------------------------------------
drawLevels(array<LiqLevel> arr, color baseCol) =>
    if showLines and array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            LiqLevel lv = array.get(arr, i)
            if lv.state == LVL_ACTIVE
                if na(lv.ln)
                    string lt = (lv.source == SRC_SWING ? sideStr(lv.side) + (lv.touches > 1 ? " x" + str.tostring(lv.touches) : "") : srcStr(lv.source))
                    lv.ln := line.new(lv.activeFromBar, lv.price, bar_index, lv.price, color = baseCol, width = 1)
                    lv.lb := label.new(bar_index, lv.price, lt, style = label.style_none, textcolor = baseCol, size = size.tiny)
                else
                    line.set_x2(lv.ln, bar_index)
                    line.set_y1(lv.ln, lv.price)
                    line.set_y2(lv.ln, lv.price)
                    if not na(lv.lb)
                        label.set_x(lv.lb, bar_index)
                        label.set_y(lv.lb, lv.price)
            else if lv.state == LVL_SWEPT and not na(lv.ln)
                line.set_color(lv.ln, colFade)
                if not na(lv.lb)
                    label.delete(lv.lb)
                    lv.lb := na
    true

drawLevels(bslLevels, colBSL)
drawLevels(sslLevels, colSSL)

// ---------------------------------------------------------------------------
// DASHBOARD / LEDGER
// ---------------------------------------------------------------------------
countActive(array<LiqLevel> arr) =>
    int c = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if array.get(arr, i).state == LVL_ACTIVE
                c += 1
    c

f_cellPair(table t, int row, string k, string v) =>
    table.cell(t, 0, row, k, text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(t, 0, row, 1, row)
    table.cell(t, 2, row, v, text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(t, 2, row, 4, row)

if barstate.islast and showDash
    var table dash = table.new(position.top_right, 5, 30, border_width = 1)
    table.clear(dash, 0, 0, 4, 29)

    table.cell(dash, 0, 0, "LIQUIDITY SWEEP LEDGER", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small, text_halign = text.align_left)
    table.merge_cells(dash, 0, 0, 4, 0)

    // latest event
    SweepEvent last = array.size(events) > 0 ? array.get(events, array.size(events) - 1) : na
    string lastSide = na(last) ? "None" : sideStr(last.side)
    string lastSrc  = na(last) ? "-" : last.state == EV_DUAL ? "Mixed" : srcStr(last.source)
    string reclaim  = na(last) ? "-" : last.state == EV_DUAL ? "Ambiguous" : last.state == EV_PENDING_RECLAIM ? "Pending" : last.state == EV_TAKEN_NO_RECLAIM ? "No" : "Yes"
    string response = na(last) ? "-" : (last.state == EV_DISPLACED ? "Displacement" : last.state == EV_STRUCTURE_SHIFTED ? "Structure shift" : last.state == EV_NO_FOLLOW_THROUGH ? "No follow-through" : last.state == EV_DUAL ? "Ambiguous" : "None")
    string ageStr   = na(last) ? "-" : str.tostring(last.age) + " bars"

    f_cellPair(dash, 1, "Last sweep", lastSide)
    f_cellPair(dash, 2, "Source", lastSrc)
    f_cellPair(dash, 3, "Reclaim", reclaim)
    f_cellPair(dash, 4, "Response", response)
    f_cellPair(dash, 5, "Age", ageStr)
    f_cellPair(dash, 6, "Active BSL", str.tostring(countActive(bslLevels)))
    f_cellPair(dash, 7, "Active SSL", str.tostring(countActive(sslLevels)))

    if showLedger and array.size(events) > 0
        int header = 8
        table.cell(dash, 0, header, "#", text_color = color.gray, text_size = size.tiny)
        table.cell(dash, 1, header, "Side", text_color = color.gray, text_size = size.tiny)
        table.cell(dash, 2, header, "Source", text_color = color.gray, text_size = size.tiny)
        table.cell(dash, 3, header, "State", text_color = color.gray, text_size = size.tiny)
        table.cell(dash, 4, header, "Age", text_color = color.gray, text_size = size.tiny)
        int shown = math.min(ledgerLen, array.size(events))
        for j = 0 to shown - 1
            SweepEvent e = array.get(events, array.size(events) - 1 - j)
            int rr = header + 1 + j
            table.cell(dash, 0, rr, str.tostring(j + 1), text_color = color.silver, text_size = size.tiny)
            table.cell(dash, 1, rr, sideStr(e.side), text_color = color.silver, text_size = size.tiny)
            table.cell(dash, 2, rr, e.state == EV_DUAL ? "Mixed" : srcStr(e.source), text_color = color.silver, text_size = size.tiny)
            table.cell(dash, 3, rr, evStr(e.state), text_color = color.silver, text_size = size.tiny)
            table.cell(dash, 4, rr, str.tostring(e.age), text_color = color.silver, text_size = size.tiny)

// ---------------------------------------------------------------------------
// ALERTS (context only)
// ---------------------------------------------------------------------------
// Flags are set inline at the exact bar each transition occurs (see sweep
// detection and lifecycle blocks above), so each fires once per event change.
alertcondition(fBSLsweep, "BSL swept",        "Buy-side liquidity swept. Structure context only. Not a trade signal.")
alertcondition(fSSLsweep, "SSL swept",        "Sell-side liquidity swept. Structure context only. Not a trade signal.")
alertcondition(fDual,     "Dual sweep",       "Dual liquidity sweep. Structure context only. Not a trade signal.")
alertcondition(fReclaim,  "Reclaimed",        "Swept level reclaimed. Structure context only. Not a trade signal.")
alertcondition(fDisplace, "Displaced",        "Displacement after sweep. Structure context only. Not a trade signal.")
alertcondition(fShift,    "Structure shift",  "Structure shift after sweep. Structure context only. Not a trade signal.")
alertcondition(fTaken,    "Taken/no reclaim", "Liquidity taken without reclaim. Structure context only. Not a trade signal.")
alertcondition(fNoFollow, "No follow-through","No follow-through after reclaim. Structure context only. Not a trade signal.")
````
