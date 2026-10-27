# Polaris VWAP Mesh [JOAT]

- url: https://www.tradingview.com/script/pturKbM1-Polaris-VWAP-Mesh-JOAT/
- type: indicator
- pine_id: PUB;38e7ee7a4bba49bda40bb5adef6c7a44
- version: 1.0

## Description

[b]Polaris VWAP Mesh [JOAT][/b]

Polaris VWAP Mesh tracks four anchored VWAPs simultaneously — Session, Swing-High pivot, Swing-Low pivot, and Previous-Day-Open — and detects pairwise confluence whenever two or more of them are within an ATR-scaled proximity of each other. Each VWAP carries a plus-or-minus 1-sigma deviation band. Confluence zones become full-chart-width persistent bands. A multi-anchor bias score counts how many VWAPs price is currently above.

[image]https://www.tradingview.com/x/0F5w2pwr/[/image]

[b]What makes it different[/b]
[list]
[*] Most VWAP scripts plot a single anchor (session or daily). Polaris simultaneously runs four independent anchored-VWAP engines and surfaces their interactions as confluence zones.
[*] Confluence detection uses an ATR-scaled proximity threshold rather than a fixed percentage, so it adapts to the instrument's volatility automatically.
[*] A multi-anchor bias counter aggregates the four VWAPs into a single 0-to-4 score. Full-chart-width tints apply when three or more VWAPs are above (or below) the close.
[*] Swing-anchored VWAPs reset at confirmed pivot points and start fresh from the moment of pivot confirmation (forward-only, non-repainting). The Previous-Day-Open VWAP is anchored to the open of the prior daily bar so it captures yesterday's reference.
[*] A pairwise distance matrix is displayed in plain text at the right edge — six pair distances, with the two tightest pairs highlighted.
[/list]

[b]How it works[/b]
[list=1]
[*] An anchored VWAP function maintains three cumulators per anchor — price-times-volume, volume, and price-squared-times-volume — to deliver both the VWAP and its rolling standard deviation since the anchor.
[*] Anchor reset conditions: Session start of the user-defined session window. Swing-High on confirmed ta.pivothigh. Swing-Low on confirmed ta.pivotlow. Previous-Day-Open on ta.change(time("D")), capturing the open of the new day, then locking after a day passes.
[*] Pairwise distance check: for each of the six possible pairs, if the absolute distance between VWAPs is less than proximityThreshATR times ATR(14), an active confluence is flagged. The mid-price between the two VWAPs becomes the confluence level.
[*] Multi-anchor bias counts how many of the four VWAPs the close is above.
[/list]

[b]Reading the chart[/b]
[list]
[*] Four VWAP lines, each in its own color (session blue, swing-high red, swing-low mint, prev-day-open purple, all user-configurable).
[*] Plus-or-minus 1-sigma deviation band shading per VWAP.
[*] Full-chart-width confluence zones (persistent bordered boxes) at each active confluence level, with right-edge labels naming the contributing pair.
[*] Anchor reset markers: small vertical lines per anchor at the bar of reset (capped at 20 per anchor type).
[*] A multi-anchor bull / bear bgcolor tint (very faint) when three or more VWAPs are on one side of the close.
[*] Iridescent candle recolor by bull-count.
[*] Right-edge VWAP labels with plus-or-minus sigma deviation tags.
[*] Pairwise distance matrix label cluster.
[*] Anchor-age label cluster.
[*] Bias-flip timeline labels and VWAP-cross event labels.
[/list]

[b]Signals[/b]
[list]
[*] Bull / bear VWAP cross (any anchor)
[*] Session VWAP bull / bear cross (dedicated alerts)
[*] Previous-Day-Open VWAP bull / bear cross (dedicated alerts)
[*] Confluence touch (price entered an active confluence zone)
[*] Multi-anchor bull / bear bias activation
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references.

[b]Inputs[/b]
[list]
[*] [b]Anchors[/b]: session window string, swing pivot length.
[*] [b]Bands[/b]: standard deviation multiplier, band shading toggle.
[*] [b]Confluence[/b]: proximity threshold in ATR units, confluence zones toggle.
[*] [b]Visuals[/b]: bullish / bearish colors, per-anchor color overrides, per-anchor visibility toggles, candles, labels.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Confluence trading[/b]: confluence zones are price magnets. Reactions to them (touches with rejections) are tradable. Clean breaks through with volume can be trend signals.
[*] [b]Multi-anchor bias[/b]: when three or four of the four VWAPs are on the same side of price, the trend is well supported across multiple anchors. Counter-trend trades in this regime are lower probability.
[*] [b]VWAP rotation[/b]: the previous-day-open VWAP is a frequently respected institutional reference. Crosses of it often coincide with bias shifts.
[*] [b]Plus-or-minus 1-sigma bands[/b]: extensions to plus-or-minus 1 sigma from a fast-moving anchor often coincide with short-term mean-reversion zones.
[/list]

[b]Limitations[/b]
[list]
[*] Swing-anchored VWAPs begin tracking only after pivot confirmation, so they lack history before that pivot was confirmed. This is by design (non-repainting), not a bug.
[*] The session VWAP requires the user to set a session window matching the instrument's primary trading window.
[*] The pairwise confluence test is O(1) per bar (six pairs). Confluence zones extend across the chart and use persistent box objects. They are capped at six active zones (the maximum number of pair combinations).
[*] Confluence is a price-coincidence test, not a flow-direction test. Use other tools to gauge directional bias once confluence is identified.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (overlay). Any symbol with volume data. Designed for sessions in America/New_York by default. Change the session window for other markets. No request.security calls.

[b]Defaults[/b]
0930-1600 EST session window, 10-bar pivot length, 0.5x ATR proximity threshold, mint / red brand colors plus blue / red / mint / purple anchor accents, top-right medium dashboard.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Polaris VWAP Mesh [JOAT]", "PVM [JOAT]",
     overlay              = true,
     behind_chart         = false,
     explicit_plot_zorder = true,
     max_lines_count      = 500,
     max_labels_count     = 500,
     max_boxes_count      = 500)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_anchor = "Anchors"
g_band   = "Bands"
g_conf   = "Confluence"
g_vis    = "Visuals"
g_marks  = "Markers & Zones"
g_dash   = "Dashboard"

sessionStr   = input.session("0930-1600", "Session VWAP Window (EST)", group=g_anchor,
     tooltip="Session window for the session-anchored VWAP. The session-anchored cumulators reset at the start of each window in America/New_York time.")
pivLen       = input.int(10, "Swing Pivot Length", minval=2, maxval=100, group=g_anchor,
     tooltip="Lookback for ta.pivothigh / ta.pivotlow confirmation. Smaller values yield more frequent swing-anchor resets; larger values isolate dominant structural pivots.")

stdevMult    = input.float(1.0, "Standard Deviation Multiplier", minval=0.1, maxval=3.0, step=0.1, group=g_band,
     tooltip="Width of the per-anchor ±σ deviation bands. 1.0 yields the classic 1-sigma envelope; 2.0 widens to a 2-sigma channel.")
showBands    = input.bool(true, "Show Deviation Band Shading", group=g_band,
     tooltip="Toggle the per-anchor ±σ deviation band fill shading. Lines are always plotted.")

proximityATR = input.float(0.5, "Proximity Threshold (× ATR)", minval=0.1, maxval=3.0, step=0.1, group=g_conf,
     tooltip="Two VWAPs are considered in confluence when their absolute distance is less than this multiple of ATR(14). Smaller values yield rarer, tighter confluences.")
showConfluence = input.bool(true, "Show Confluence Mesh Bands", group=g_conf,
     tooltip="Toggle the persistent horizontal mesh bands drawn at every active pairwise confluence level.")
showFullConfluenceZones = input.bool(true, "Show Full-Width Confluence Zones", group=g_conf,
     tooltip="Draw persistent full-chart-width horizontal zones at each active confluence price level, with right-edge price labels. Up to 6 simultaneous zones (one per pair).")

bullColor    = input.color(#00ffbb, "Bullish", inline="cBull",                 group=g_vis,
     tooltip="Primary bullish color — JOAT brand mint. Applied to iridescent candles, bull-bias tints, and gradient endpoints.")
bearColor    = input.color(#ff1100, "Bearish", inline="cBull",                 group=g_vis,
     tooltip="Primary bearish color — JOAT brand red. Applied to iridescent candles, bear-bias tints, and gradient endpoints.")
sessionColor = input.color(#4da6ff, "Session VWAP Color",                      group=g_vis,
     tooltip="Color of the session-anchored VWAP line and its ±σ band shading.")
shColor      = input.color(#ff4d6d, "Swing-High VWAP Color",                   group=g_vis,
     tooltip="Color of the swing-high-anchored VWAP line and its ±σ band shading.")
slColor      = input.color(#00c88a, "Swing-Low VWAP Color",                    group=g_vis,
     tooltip="Color of the swing-low-anchored VWAP line and its ±σ band shading.")
pdoColor     = input.color(#bb00ff, "PrevDay-Open VWAP Color",                 group=g_vis,
     tooltip="Color of the previous-day-open-anchored VWAP line and its ±σ band shading.")
showSession  = input.bool(true, "Show Session VWAP",                           group=g_vis,
     tooltip="Toggle the session-anchored VWAP line and bands.")
showSH       = input.bool(true, "Show Swing-High VWAP",                        group=g_vis,
     tooltip="Toggle the swing-high-anchored VWAP line and bands.")
showSL       = input.bool(true, "Show Swing-Low VWAP",                         group=g_vis,
     tooltip="Toggle the swing-low-anchored VWAP line and bands.")
showPDO      = input.bool(true, "Show PrevDay-Open VWAP",                      group=g_vis,
     tooltip="Toggle the previous-day-open-anchored VWAP line and bands.")
showCandles  = input.bool(true, "Iridescent Candles",                          group=g_vis,
     tooltip="Recolor the price candles via a bull-vs-bear gradient driven by the multi-anchor bull count (0..4).")
showLabels   = input.bool(true, "Right-Edge VWAP Labels",                      group=g_vis,
     tooltip="Toggle plain-text right-edge labels showing the current price of each active VWAP anchor, with the deviation indicator (±σ).")
showBiasPulse= input.bool(true, "Bias Transition Background Pulse",            group=g_vis,
     tooltip="Toggle a single-bar low-alpha background pulse on multi-anchor bias transitions (NEUTRAL to BULL or BEAR).")

showAnchorMarkers       = input.bool(true, "Show Anchor Reset Markers",   group=g_marks,
     tooltip="On each anchor reset event (session start, confirmed swing-high pivot, confirmed swing-low pivot, new day), drop a persistent dotted vertical line at the anchor bar spanning that bar's low to high, color-matched to its VWAP. FIFO 20 per anchor.")
showBiasZones           = input.bool(true, "Show Multi-Anchor Bias Zones", group=g_marks,
     tooltip="Tint the chart background with low-alpha mint while the multi-anchor BULL regime is sustained (3+ VWAPs above price), and with low-alpha red while BEAR is sustained (1- VWAPs above price).")
showDistanceMatrix      = input.bool(true, "Show Pairwise Distance Matrix", group=g_marks,
     tooltip="Two right-edge labels listing the 6 pairwise absolute VWAP distances. The two smallest distances (closest pairs) are colored mint to highlight confluence proximity.")
showAnchorAges          = input.bool(true, "Show Anchor Age Labels",       group=g_marks,
     tooltip="Four small right-edge labels listing the number of bars since each anchor (Session, Swing-High, Swing-Low, PrevDay-Open) was last reset.")
showBiasTimeline        = input.bool(true, "Show Bias-Flip Timeline",      group=g_marks,
     tooltip="On each bias-flip event (NEUTRAL -> BULL or NEUTRAL -> BEAR), drop a persistent label at the flip bar showing the bias and bull-count. FIFO capped at 12.")
showCrossLabels         = input.bool(true, "Show VWAP Cross Labels",       group=g_marks,
     tooltip="On every VWAP cross (any of the 4 anchors, both directions), drop a small persistent label color-matched to the crossed VWAP. FIFO capped at 25.")
showStateBlock          = input.bool(true, "Show Right-Edge State Block",  group=g_marks,
     tooltip="Consolidated 4-line right-edge label summarizing mesh bias, active confluence count, closest pair, and pair distance.")

showDash     = input.bool(true,  "Show Dashboard",                              group=g_dash,
     tooltip="Toggle the institutional dashboard panel.")
dashPos      = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize     = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Standard deviation from running cumulators: σ = sqrt(E[x²] − μ²)
vwapStdev(float pv_cum, float v_cum, float sq_cum) =>
    float v   = math.max(v_cum, 1e-12)
    float mu  = pv_cum / v
    float variance = (sq_cum / v) - mu * mu
    math.sqrt(math.max(variance, 0.0))

// Safe divide guard
sdiv(float a, float b) =>
    math.abs(b) < 1e-12 ? na : a / b

// FIFO trim for line arrays
trimLines(array<line> a, int cap) =>
    while array.size(a) > cap
        line ll = array.shift(a)
        line.delete(ll)

// FIFO trim for label arrays
trimLabels(array<label> a, int cap) =>
    while array.size(a) > cap
        label lb = array.shift(a)
        label.delete(lb)

// Pair-mask -> short pair label
maskLabel(int m) =>
    m == 3 ? "S-SH" : m == 5 ? "S-SL" : m == 9 ? "S-PDO" : m == 6 ? "SH-SL" : m == 10 ? "SH-PDO" : m == 12 ? "SL-PDO" : "?"

// ════════════════════════════════════════════════════════════════════
// CORE SERIES
// ════════════════════════════════════════════════════════════════════
float tp           = (high + low + close) / 3.0
float pv           = tp * volume
float pv_sq        = tp * tp * volume
float atr14        = ta.atr(14)
bool  confirmedBar = barstate.isconfirmed or barstate.ishistory

// ════════════════════════════════════════════════════════════════════
// ANCHOR 1 — SESSION VWAP (resets at start of session window)
// ════════════════════════════════════════════════════════════════════
int  inSessionTime = time(timeframe.period, sessionStr, "America/New_York")
bool inSession     = not na(inSessionTime)
bool newSession    = inSession and not (inSession[1])

var float sess_pv_cum  = 0.0
var float sess_v_cum   = 0.0
var float sess_sq_cum  = 0.0
var int   sess_anchor  = na

if newSession
    sess_pv_cum := pv
    sess_v_cum  := volume
    sess_sq_cum := pv_sq
    sess_anchor := bar_index
else if inSession
    sess_pv_cum := sess_pv_cum + pv
    sess_v_cum  := sess_v_cum  + volume
    sess_sq_cum := sess_sq_cum + pv_sq

float sessionVwap = inSession ? sdiv(sess_pv_cum, sess_v_cum) : na
float sessionSd   = inSession ? vwapStdev(sess_pv_cum, sess_v_cum, sess_sq_cum) : na
float sessionHi   = na(sessionVwap) ? na : sessionVwap + stdevMult * sessionSd
float sessionLo   = na(sessionVwap) ? na : sessionVwap - stdevMult * sessionSd

// ════════════════════════════════════════════════════════════════════
// ANCHOR 2 — SWING-HIGH VWAP (resets on confirmed pivot high)
// ════════════════════════════════════════════════════════════════════
float ph = ta.pivothigh(pivLen, pivLen)

var float sh_pv_cum   = 0.0
var float sh_v_cum    = 0.0
var float sh_sq_cum   = 0.0
var int   sh_anchor   = na
var bool  sh_active   = false

if not na(ph)
    sh_pv_cum   := pv
    sh_v_cum    := volume
    sh_sq_cum   := pv_sq
    sh_anchor   := bar_index
    sh_active   := true
else if sh_active
    sh_pv_cum := sh_pv_cum + pv
    sh_v_cum  := sh_v_cum  + volume
    sh_sq_cum := sh_sq_cum + pv_sq

float shVwap = sh_active ? sdiv(sh_pv_cum, sh_v_cum) : na
float shSd   = sh_active ? vwapStdev(sh_pv_cum, sh_v_cum, sh_sq_cum) : na
float shHi   = na(shVwap) ? na : shVwap + stdevMult * shSd
float shLo   = na(shVwap) ? na : shVwap - stdevMult * shSd

// ════════════════════════════════════════════════════════════════════
// ANCHOR 3 — SWING-LOW VWAP (resets on confirmed pivot low)
// ════════════════════════════════════════════════════════════════════
float pl = ta.pivotlow(pivLen, pivLen)

var float sl_pv_cum   = 0.0
var float sl_v_cum    = 0.0
var float sl_sq_cum   = 0.0
var int   sl_anchor   = na
var bool  sl_active   = false

if not na(pl)
    sl_pv_cum   := pv
    sl_v_cum    := volume
    sl_sq_cum   := pv_sq
    sl_anchor   := bar_index
    sl_active   := true
else if sl_active
    sl_pv_cum := sl_pv_cum + pv
    sl_v_cum  := sl_v_cum  + volume
    sl_sq_cum := sl_sq_cum + pv_sq

float slVwap = sl_active ? sdiv(sl_pv_cum, sl_v_cum) : na
float slSd   = sl_active ? vwapStdev(sl_pv_cum, sl_v_cum, sl_sq_cum) : na
float slHi   = na(slVwap) ? na : slVwap + stdevMult * slSd
float slLo   = na(slVwap) ? na : slVwap - stdevMult * slSd

// ════════════════════════════════════════════════════════════════════
// ANCHOR 4 — PREVIOUS-DAY-OPEN VWAP
// ════════════════════════════════════════════════════════════════════
bool isNewDay = ta.change(time("D")) != 0

var float dayOpenAnchor      = na
var int   dayOpenAnchorBar   = na
var float prevDayOpenAnchor  = na
var int   prevDayOpenBar     = na

var float pdo_pv_cum = 0.0
var float pdo_v_cum  = 0.0
var float pdo_sq_cum = 0.0
var bool  pdo_active = false
var int   pdo_anchor = na

if isNewDay
    prevDayOpenAnchor := dayOpenAnchor
    prevDayOpenBar    := dayOpenAnchorBar
    dayOpenAnchor     := open
    dayOpenAnchorBar  := bar_index
    if not na(prevDayOpenAnchor) and not na(prevDayOpenBar)
        pdo_pv_cum := pv
        pdo_v_cum  := volume
        pdo_sq_cum := pv_sq
        pdo_active := true
        pdo_anchor := bar_index
else if pdo_active
    pdo_pv_cum := pdo_pv_cum + pv
    pdo_v_cum  := pdo_v_cum  + volume
    pdo_sq_cum := pdo_sq_cum + pv_sq

float pdoVwap = pdo_active ? sdiv(pdo_pv_cum, pdo_v_cum) : na
float pdoSd   = pdo_active ? vwapStdev(pdo_pv_cum, pdo_v_cum, pdo_sq_cum) : na
float pdoHi   = na(pdoVwap) ? na : pdoVwap + stdevMult * pdoSd
float pdoLo   = na(pdoVwap) ? na : pdoVwap - stdevMult * pdoSd

// ════════════════════════════════════════════════════════════════════
// MULTI-ANCHOR BIAS — count of active VWAPs price is trading above
// ════════════════════════════════════════════════════════════════════
int activeAnchors = (na(sessionVwap) ? 0 : 1) + (na(shVwap) ? 0 : 1) + (na(slVwap) ? 0 : 1) + (na(pdoVwap) ? 0 : 1)
int bullCount = (not na(sessionVwap) and close > sessionVwap ? 1 : 0) + (not na(shVwap) and close > shVwap ? 1 : 0) + (not na(slVwap) and close > slVwap ? 1 : 0) + (not na(pdoVwap) and close > pdoVwap ? 1 : 0)

string bias = activeAnchors == 0 ? "NEUTRAL" : bullCount >= 3 ? "BULL" : bullCount <= 1 and activeAnchors >= 3 ? "BEAR" : "NEUTRAL"

// ════════════════════════════════════════════════════════════════════
// CONFLUENCE DETECTION — C(4,2) = 6 pairwise tests
// ════════════════════════════════════════════════════════════════════
float pTol = proximityATR * nz(atr14)

// Parallel arrays — one entry per active confluence level
var array<float> conf_levels = array.new_float()
var array<int>   conf_left   = array.new_int()       // pair-bitmask of contributing anchors
array.clear(conf_levels)
array.clear(conf_left)

testPair(float a, float b, int mask) =>
    bool active = not na(a) and not na(b) and pTol > 0 and math.abs(a - b) < pTol
    if active
        array.push(conf_levels, (a + b) / 2.0)
        array.push(conf_left,   mask)

testPair(sessionVwap, shVwap,  3)   // bits: SESSION | SH
testPair(sessionVwap, slVwap,  5)   // bits: SESSION | SL
testPair(sessionVwap, pdoVwap, 9)   // bits: SESSION | PDO
testPair(shVwap,      slVwap,  6)   // bits: SH      | SL
testPair(shVwap,      pdoVwap, 10)  // bits: SH      | PDO
testPair(slVwap,      pdoVwap, 12)  // bits: SL      | PDO

int   confluenceCount = array.size(conf_levels)
float closestConf     = na
float closestDist     = na
int   closestMask     = na

if confluenceCount > 0
    for i = 0 to confluenceCount - 1
        float lvl = array.get(conf_levels, i)
        int   msk = array.get(conf_left,   i)
        float d   = math.abs(close - lvl)
        if na(closestDist) or d < closestDist
            closestDist := d
            closestConf := lvl
            closestMask := msk

bool confluenceTouch = false
if confluenceCount > 0 and confirmedBar
    for i = 0 to confluenceCount - 1
        float lvl = array.get(conf_levels, i)
        if high >= lvl and low <= lvl
            confluenceTouch := true
            break

// ════════════════════════════════════════════════════════════════════
// PAIRWISE DISTANCE MATRIX — 6 absolute distances
// ════════════════════════════════════════════════════════════════════
float d_s_sh   = (not na(sessionVwap) and not na(shVwap))  ? math.abs(sessionVwap - shVwap)  : na
float d_s_sl   = (not na(sessionVwap) and not na(slVwap))  ? math.abs(sessionVwap - slVwap)  : na
float d_s_pdo  = (not na(sessionVwap) and not na(pdoVwap)) ? math.abs(sessionVwap - pdoVwap) : na
float d_sh_sl  = (not na(shVwap)      and not na(slVwap))  ? math.abs(shVwap      - slVwap)  : na
float d_sh_pdo = (not na(shVwap)      and not na(pdoVwap)) ? math.abs(shVwap      - pdoVwap) : na
float d_sl_pdo = (not na(slVwap)      and not na(pdoVwap)) ? math.abs(slVwap      - pdoVwap) : na

// Find the two smallest non-na distances for highlight
float dArr0 = nz(d_s_sh,   1e20)
float dArr1 = nz(d_s_sl,   1e20)
float dArr2 = nz(d_s_pdo,  1e20)
float dArr3 = nz(d_sh_sl,  1e20)
float dArr4 = nz(d_sh_pdo, 1e20)
float dArr5 = nz(d_sl_pdo, 1e20)
var array<float> distArr = array.new_float(6)
array.set(distArr, 0, dArr0)
array.set(distArr, 1, dArr1)
array.set(distArr, 2, dArr2)
array.set(distArr, 3, dArr3)
array.set(distArr, 4, dArr4)
array.set(distArr, 5, dArr5)
// Find 1st and 2nd smallest indices
int idx1st = na
int idx2nd = na
float min1 = 1e20
float min2 = 1e20
for i = 0 to 5
    float v = array.get(distArr, i)
    if v < min1
        min2   := min1
        idx2nd := idx1st
        min1   := v
        idx1st := i
    else if v < min2
        min2   := v
        idx2nd := i

// ════════════════════════════════════════════════════════════════════
// DEVIATION POSITION — (close - vwap) / stdev per anchor
// ════════════════════════════════════════════════════════════════════
float devPos_sess = (not na(sessionVwap) and not na(sessionSd) and sessionSd > 1e-12) ? (close - sessionVwap) / sessionSd : na
float devPos_sh   = (not na(shVwap)      and not na(shSd)      and shSd      > 1e-12) ? (close - shVwap)      / shSd      : na
float devPos_sl   = (not na(slVwap)      and not na(slSd)      and slSd      > 1e-12) ? (close - slVwap)      / slSd      : na
float devPos_pdo  = (not na(pdoVwap)     and not na(pdoSd)     and pdoSd     > 1e-12) ? (close - pdoVwap)     / pdoSd     : na

devPosStr(float v) =>
    na(v) ? "—" : (v >= 0 ? "ABOVE +" + str.tostring(v, "#.##") + "σ" : "BELOW " + str.tostring(v, "#.##") + "σ")

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
bool bullCross_session = not na(sessionVwap) and ta.crossover (close, sessionVwap) and confirmedBar
bool bearCross_session = not na(sessionVwap) and ta.crossunder(close, sessionVwap) and confirmedBar
bool bullCross_sh      = not na(shVwap)      and ta.crossover (close, shVwap)      and confirmedBar
bool bearCross_sh      = not na(shVwap)      and ta.crossunder(close, shVwap)      and confirmedBar
bool bullCross_sl      = not na(slVwap)      and ta.crossover (close, slVwap)      and confirmedBar
bool bearCross_sl      = not na(slVwap)      and ta.crossunder(close, slVwap)      and confirmedBar
bool bullCross_pdo     = not na(pdoVwap)     and ta.crossover (close, pdoVwap)     and confirmedBar
bool bearCross_pdo     = not na(pdoVwap)     and ta.crossunder(close, pdoVwap)     and confirmedBar

bool anyBullCross = bullCross_session or bullCross_sh or bullCross_sl or bullCross_pdo
bool anyBearCross = bearCross_session or bearCross_sh or bearCross_sl or bearCross_pdo

bool multiAnchorBull = bias == "BULL"    and bias[1] != "BULL"    and confirmedBar
bool multiAnchorBear = bias == "BEAR"    and bias[1] != "BEAR"    and confirmedBar
bool multiAnchorNeut = bias == "NEUTRAL" and bias[1] != "NEUTRAL" and confirmedBar

// ════════════════════════════════════════════════════════════════════
// PLOTS — VWAP LINES + BANDS
// ════════════════════════════════════════════════════════════════════
color sessLineColor = showSession ? sessionColor : na
color shLineColor   = showSH      ? shColor      : na
color slLineColor   = showSL      ? slColor      : na
color pdoLineColor  = showPDO     ? pdoColor     : na

color sessFillColor = showSession and showBands ? color.new(sessionColor, 88) : na
color shFillColor   = showSH      and showBands ? color.new(shColor,      88) : na
color slFillColor   = showSL      and showBands ? color.new(slColor,      88) : na
color pdoFillColor  = showPDO     and showBands ? color.new(pdoColor,     88) : na

plot_sess   = plot(sessionVwap, "Session VWAP",       color=sessLineColor, linewidth=2)
plot_sessHi = plot(sessionHi,   "Session +σ",         color=color.new(sessLineColor, 70), linewidth=1, display=display.none)
plot_sessLo = plot(sessionLo,   "Session −σ",         color=color.new(sessLineColor, 70), linewidth=1, display=display.none)
fill(plot_sessHi, plot_sessLo, color=sessFillColor, title="Session ±σ Fill")

plot_sh     = plot(shVwap,      "Swing-High VWAP",    color=shLineColor,   linewidth=2)
plot_shHi   = plot(shHi,        "Swing-High +σ",      color=color.new(shLineColor,   70), linewidth=1, display=display.none)
plot_shLo   = plot(shLo,        "Swing-High −σ",      color=color.new(shLineColor,   70), linewidth=1, display=display.none)
fill(plot_shHi, plot_shLo, color=shFillColor, title="Swing-High ±σ Fill")

plot_sl     = plot(slVwap,      "Swing-Low VWAP",     color=slLineColor,   linewidth=2)
plot_slHi   = plot(slHi,        "Swing-Low +σ",       color=color.new(slLineColor,   70), linewidth=1, display=display.none)
plot_slLo   = plot(slLo,        "Swing-Low −σ",       color=color.new(slLineColor,   70), linewidth=1, display=display.none)
fill(plot_slHi, plot_slLo, color=slFillColor, title="Swing-Low ±σ Fill")

plot_pdo    = plot(pdoVwap,     "PrevDay-Open VWAP",  color=pdoLineColor,  linewidth=2)
plot_pdoHi  = plot(pdoHi,       "PrevDay-Open +σ",    color=color.new(pdoLineColor,  70), linewidth=1, display=display.none)
plot_pdoLo  = plot(pdoLo,       "PrevDay-Open −σ",    color=color.new(pdoLineColor,  70), linewidth=1, display=display.none)
fill(plot_pdoHi, plot_pdoLo, color=pdoFillColor, title="PrevDay-Open ±σ Fill")

// ════════════════════════════════════════════════════════════════════
// IRIDESCENT CANDLE RECOLOR (close-vs-mesh gradient via bullCount)
// ════════════════════════════════════════════════════════════════════
color candleCol = activeAnchors > 0 ? color.from_gradient(bullCount, 0, activeAnchors, bearColor, bullColor) : na
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na,
     title    = "Iridescent Candles",
     color    = candleCol,
     wickcolor= candleCol,
     bordercolor = candleCol)

// ════════════════════════════════════════════════════════════════════
// BIAS TRANSITION PULSE + SUSTAINED BIAS ZONES
// ════════════════════════════════════════════════════════════════════
bgcolor(showBiasPulse and multiAnchorBull ? color.new(bullColor, 86) : na, title="Multi-Anchor Bull Pulse")
bgcolor(showBiasPulse and multiAnchorBear ? color.new(bearColor, 86) : na, title="Multi-Anchor Bear Pulse")
bgcolor(showBiasPulse and multiAnchorNeut ? color.new(chart.fg_color, 92) : na, title="Multi-Anchor Neutral Pulse")

// Sustained zone tint while bias regime is held
bgcolor(showBiasZones and activeAnchors >= 3 and bullCount >= 3 ? color.new(bullColor, 96) : showBiasZones and activeAnchors >= 3 and bullCount <= 1 ? color.new(bearColor, 96) : na, title="Multi-Anchor Bias Zone Tint")

// ════════════════════════════════════════════════════════════════════
// ANCHOR RESET MARKERS — vertical dotted lines at each anchor bar
// ════════════════════════════════════════════════════════════════════
var array<line> sessionAnchorLines = array.new<line>()
var array<line> shAnchorLines      = array.new<line>()
var array<line> slAnchorLines      = array.new<line>()
var array<line> pdoAnchorLines     = array.new<line>()

if showAnchorMarkers and confirmedBar and newSession
    line ln = line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.none,
         color=color.new(sessionColor, 70), style=line.style_dotted, width=1)
    array.push(sessionAnchorLines, ln)
    trimLines(sessionAnchorLines, 20)

if showAnchorMarkers and confirmedBar and not na(ph)
    // anchor bar is the pivot bar (pivLen bars back)
    int ax = bar_index - pivLen
    line ln = line.new(ax, low[pivLen], ax, high[pivLen], xloc=xloc.bar_index, extend=extend.none,
         color=color.new(shColor, 70), style=line.style_dotted, width=1)
    array.push(shAnchorLines, ln)
    trimLines(shAnchorLines, 20)

if showAnchorMarkers and confirmedBar and not na(pl)
    int ax = bar_index - pivLen
    line ln = line.new(ax, low[pivLen], ax, high[pivLen], xloc=xloc.bar_index, extend=extend.none,
         color=color.new(slColor, 70), style=line.style_dotted, width=1)
    array.push(slAnchorLines, ln)
    trimLines(slAnchorLines, 20)

if showAnchorMarkers and confirmedBar and isNewDay
    line ln = line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.none,
         color=color.new(pdoColor, 70), style=line.style_dotted, width=1)
    array.push(pdoAnchorLines, ln)
    trimLines(pdoAnchorLines, 20)

// ════════════════════════════════════════════════════════════════════
// FULL-WIDTH CONFLUENCE ZONES — persistent neutral boxes + price labels
// ════════════════════════════════════════════════════════════════════
type FullConfZone
    box   b
    label lbl
    int   mask
    int   lastSeen

var array<FullConfZone> fullConfZones = array.new<FullConfZone>()

if barstate.islast and showFullConfluenceZones and confluenceCount > 0
    float halfWidthFull = math.max(syminfo.mintick * 4.0, pTol * 0.10)
    int   leftXFull     = bar_index - 500
    int   rightXFull    = bar_index + 30

    for i = 0 to confluenceCount - 1
        float lvl = array.get(conf_levels, i)
        int   msk = array.get(conf_left,   i)
        bool  hit = false
        if array.size(fullConfZones) > 0
            for j = 0 to array.size(fullConfZones) - 1
                FullConfZone fz = array.get(fullConfZones, j)
                if fz.mask == msk
                    box.set_lefttop    (fz.b, leftXFull,  lvl + halfWidthFull)
                    box.set_rightbottom(fz.b, rightXFull, lvl - halfWidthFull)
                    label.set_xy(fz.lbl, rightXFull, lvl)
                    label.set_text(fz.lbl, "Conf " + maskLabel(msk) + " " + str.tostring(lvl, format.mintick) + "  pair " + str.tostring(msk))
                    fz.lastSeen := bar_index
                    hit := true
                    break
        if not hit
            color zBg = color.new(chart.fg_color, 88)
            color zBd = color.new(chart.fg_color, 60)
            box nb = box.new(leftXFull, lvl + halfWidthFull, rightXFull, lvl - halfWidthFull,
                 border_color = zBd, border_width = 1, bgcolor = zBg, extend = extend.none)
            label nl = label.new(x=rightXFull, y=lvl,
                 text="Conf " + maskLabel(msk) + " " + str.tostring(lvl, format.mintick) + "  pair " + str.tostring(msk),
                 color=na, textcolor=chart.fg_color, style=label.style_label_left, size=size.small)
            FullConfZone nfz = FullConfZone.new(nb, nl, msk, bar_index)
            array.push(fullConfZones, nfz)

    // GC stale full zones
    if array.size(fullConfZones) > 0
        for j = array.size(fullConfZones) - 1 to 0
            FullConfZone fz = array.get(fullConfZones, j)
            if fz.lastSeen != bar_index
                box.delete(fz.b)
                label.delete(fz.lbl)
                array.remove(fullConfZones, j)
    // Cap to 6
    while array.size(fullConfZones) > 6
        FullConfZone fz = array.shift(fullConfZones)
        box.delete(fz.b)
        label.delete(fz.lbl)

// Clean up if full-zone rendering toggled off mid-session
if barstate.islast and (not showFullConfluenceZones or confluenceCount == 0)
    if array.size(fullConfZones) > 0
        for j = array.size(fullConfZones) - 1 to 0
            FullConfZone fz = array.get(fullConfZones, j)
            box.delete(fz.b)
            label.delete(fz.lbl)
            array.remove(fullConfZones, j)

// ════════════════════════════════════════════════════════════════════
// CONFLUENCE MESH BAND DRAWING — persistent boxes by pair-mask
// ════════════════════════════════════════════════════════════════════
type ConfBox
    box   b
    int   mask
    int   lastSeen

var array<ConfBox> confBoxes = array.new<ConfBox>()

if barstate.islast and showConfluence and confluenceCount > 0
    float bandHalfWidth = math.max(syminfo.mintick * 4.0, pTol * 0.12)
    int   leftX         = bar_index - 250
    int   rightX        = bar_index + 25

    // Update existing or create new band per active mask
    for i = 0 to confluenceCount - 1
        float lvl = array.get(conf_levels, i)
        int   msk = array.get(conf_left,   i)
        bool  hit = false
        if array.size(confBoxes) > 0
            for j = 0 to array.size(confBoxes) - 1
                ConfBox cb = array.get(confBoxes, j)
                if cb.mask == msk
                    box.set_lefttop    (cb.b, leftX,  lvl + bandHalfWidth)
                    box.set_rightbottom(cb.b, rightX, lvl - bandHalfWidth)
                    cb.lastSeen := bar_index
                    hit := true
                    break
        if not hit
            color baseC  = chart.fg_color
            if      msk == 3
                baseC := color.new(color.from_gradient(0.5, 0, 1, sessionColor, shColor),  82)
            else if msk == 5
                baseC := color.new(color.from_gradient(0.5, 0, 1, sessionColor, slColor),  82)
            else if msk == 9
                baseC := color.new(color.from_gradient(0.5, 0, 1, sessionColor, pdoColor), 82)
            else if msk == 6
                baseC := color.new(color.from_gradient(0.5, 0, 1, shColor,      slColor),  82)
            else if msk == 10
                baseC := color.new(color.from_gradient(0.5, 0, 1, shColor,      pdoColor), 82)
            else if msk == 12
                baseC := color.new(color.from_gradient(0.5, 0, 1, slColor,      pdoColor), 82)
            color borderC = color.new(baseC, 50)
            box nb = box.new(leftX, lvl + bandHalfWidth, rightX, lvl - bandHalfWidth,
                 border_color = borderC, border_width = 1, bgcolor = baseC, extend = extend.none)
            ConfBox ncb = ConfBox.new(nb, msk, bar_index)
            array.push(confBoxes, ncb)

    // GC stale bands — confluence broken when not refreshed this bar
    if array.size(confBoxes) > 0
        for j = array.size(confBoxes) - 1 to 0
            ConfBox cb = array.get(confBoxes, j)
            if cb.lastSeen != bar_index
                box.delete(cb.b)
                array.remove(confBoxes, j)

// Clean up if confluence rendering toggled off mid-session
if barstate.islast and (not showConfluence or confluenceCount == 0)
    if array.size(confBoxes) > 0
        for j = array.size(confBoxes) - 1 to 0
            ConfBox cb = array.get(confBoxes, j)
            box.delete(cb.b)
            array.remove(confBoxes, j)

// ════════════════════════════════════════════════════════════════════
// BIAS-FLIP TIMELINE — persistent labels at each flip event
// ════════════════════════════════════════════════════════════════════
var array<label> biasFlipLabels = array.new<label>()

if showBiasTimeline and confirmedBar and (multiAnchorBull or multiAnchorBear)
    string flipTxt = (multiAnchorBull ? "BIAS BULL " : "BIAS BEAR ") + str.tostring(close, format.mintick) + " (" + str.tostring(bullCount) + "/" + str.tostring(activeAnchors) + ")"
    color  flipBg  = multiAnchorBull ? color.new(bullColor, 70) : color.new(bearColor, 70)
    color  flipTc  = multiAnchorBull ? bullColor : bearColor
    label lb = label.new(x=bar_index, y=close, text=flipTxt,
         color=flipBg, textcolor=flipTc,
         style=multiAnchorBull ? label.style_label_up : label.style_label_down,
         size=size.small)
    array.push(biasFlipLabels, lb)
    trimLabels(biasFlipLabels, 12)

// ════════════════════════════════════════════════════════════════════
// VWAP CROSS EVENT LABELS
// ════════════════════════════════════════════════════════════════════
var array<label> crossLabels = array.new<label>()

emitCrossLabel(bool isBull, bool isBear, string tag, color c) =>
    if showCrossLabels and confirmedBar and (isBull or isBear)
        string ct = (isBull ? "Bull cross " : "Bear cross ") + tag + " " + str.tostring(close, format.mintick)
        label lb = label.new(x=bar_index, y=isBull ? low : high, text=ct,
             color=color.new(c, 75), textcolor=c,
             style=isBull ? label.style_label_up : label.style_label_down,
             size=size.tiny)
        array.push(crossLabels, lb)
        trimLabels(crossLabels, 25)

emitCrossLabel(bullCross_session, bearCross_session, "S",   sessionColor)
emitCrossLabel(bullCross_sh,      bearCross_sh,      "SH",  shColor)
emitCrossLabel(bullCross_sl,      bearCross_sl,      "SL",  slColor)
emitCrossLabel(bullCross_pdo,     bearCross_pdo,     "PDO", pdoColor)

// ════════════════════════════════════════════════════════════════════
// RIGHT-EDGE LABELS — VWAP price + deviation indicator
// ════════════════════════════════════════════════════════════════════
var label lbl_sess = na
var label lbl_sh   = na
var label lbl_sl   = na
var label lbl_pdo  = na

if barstate.islast and showLabels
    int rx = bar_index + 3
    label.delete(lbl_sess)
    label.delete(lbl_sh)
    label.delete(lbl_sl)
    label.delete(lbl_pdo)
    if showSession and not na(sessionVwap)
        lbl_sess := label.new(x=rx, y=sessionVwap,
             text="Session " + str.tostring(sessionVwap, format.mintick) + "  " + devPosStr(devPos_sess),
             color=na, textcolor=sessionColor, style=label.style_label_left, size=size.small)
    if showSH and not na(shVwap)
        lbl_sh := label.new(x=rx, y=shVwap,
             text="SwingHi " + str.tostring(shVwap, format.mintick) + "  " + devPosStr(devPos_sh),
             color=na, textcolor=shColor, style=label.style_label_left, size=size.small)
    if showSL and not na(slVwap)
        lbl_sl := label.new(x=rx, y=slVwap,
             text="SwingLo " + str.tostring(slVwap, format.mintick) + "  " + devPosStr(devPos_sl),
             color=na, textcolor=slColor, style=label.style_label_left, size=size.small)
    if showPDO and not na(pdoVwap)
        lbl_pdo := label.new(x=rx, y=pdoVwap,
             text="PrevDay " + str.tostring(pdoVwap, format.mintick) + "  " + devPosStr(devPos_pdo),
             color=na, textcolor=pdoColor, style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// PAIRWISE DISTANCE MATRIX LABELS (2-line cluster)
// ════════════════════════════════════════════════════════════════════
var label lbl_dist_row1 = na
var label lbl_dist_row2 = na

distFmt(float v) =>
    na(v) ? "—" : str.tostring(v, "#.##")

if barstate.islast and showDistanceMatrix
    label.delete(lbl_dist_row1)
    label.delete(lbl_dist_row2)
    int rxd = bar_index + 35
    float anchY = nz(close, 0.0)
    float atrAdj = nz(atr14, syminfo.mintick * 10.0)
    string r1 = "S-SH " + distFmt(d_s_sh) + "   " + "S-SL " + distFmt(d_s_sl) + "   " + "S-PDO " + distFmt(d_s_pdo)
    string r2 = "SH-SL " + distFmt(d_sh_sl) + "   " + "SH-PDO " + distFmt(d_sh_pdo) + "   " + "SL-PDO " + distFmt(d_sl_pdo)
    // Color of row reflects whether either of the two closest pairs lives in that row
    bool r1HasClosest = (idx1st == 0 or idx1st == 1 or idx1st == 2 or idx2nd == 0 or idx2nd == 1 or idx2nd == 2)
    bool r2HasClosest = (idx1st == 3 or idx1st == 4 or idx1st == 5 or idx2nd == 3 or idx2nd == 4 or idx2nd == 5)
    color r1Tc = r1HasClosest ? bullColor : color.new(chart.fg_color, 20)
    color r2Tc = r2HasClosest ? bullColor : color.new(chart.fg_color, 20)
    lbl_dist_row1 := label.new(x=rxd, y=anchY + atrAdj, text=r1,
         color=color.new(chart.bg_color, 50), textcolor=r1Tc,
         style=label.style_label_left, size=size.small)
    lbl_dist_row2 := label.new(x=rxd, y=anchY - atrAdj, text=r2,
         color=color.new(chart.bg_color, 50), textcolor=r2Tc,
         style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// ANCHOR AGE LABEL CLUSTER
// ════════════════════════════════════════════════════════════════════
var label lbl_age_s   = na
var label lbl_age_sh  = na
var label lbl_age_sl  = na
var label lbl_age_pdo = na

if barstate.islast and showAnchorAges
    label.delete(lbl_age_s)
    label.delete(lbl_age_sh)
    label.delete(lbl_age_sl)
    label.delete(lbl_age_pdo)
    int rxa = bar_index + 55
    float atrAge = nz(atr14, syminfo.mintick * 10.0)
    float baseY  = nz(close, 0.0)
    string s_age   = na(sess_anchor)  ? "—" : str.tostring(bar_index - sess_anchor)  + " bars"
    string sh_age  = na(sh_anchor)    ? "—" : str.tostring(bar_index - sh_anchor)    + " bars"
    string sl_age  = na(sl_anchor)    ? "—" : str.tostring(bar_index - sl_anchor)    + " bars"
    string pdo_age = na(pdo_anchor)   ? "—" : str.tostring(bar_index - pdo_anchor)   + " bars"
    lbl_age_s   := label.new(x=rxa, y=baseY + atrAge * 1.8, text="S anchor: "   + s_age,
         color=color.new(chart.bg_color, 50), textcolor=sessionColor, style=label.style_label_left, size=size.small)
    lbl_age_sh  := label.new(x=rxa, y=baseY + atrAge * 0.6, text="SH anchor: "  + sh_age,
         color=color.new(chart.bg_color, 50), textcolor=shColor,      style=label.style_label_left, size=size.small)
    lbl_age_sl  := label.new(x=rxa, y=baseY - atrAge * 0.6, text="SL anchor: "  + sl_age,
         color=color.new(chart.bg_color, 50), textcolor=slColor,      style=label.style_label_left, size=size.small)
    lbl_age_pdo := label.new(x=rxa, y=baseY - atrAge * 1.8, text="PDO anchor: " + pdo_age,
         color=color.new(chart.bg_color, 50), textcolor=pdoColor,     style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// RIGHT-EDGE STATE BLOCK — consolidated 4-row summary label
// ════════════════════════════════════════════════════════════════════
var label lbl_state_bias  = na
var label lbl_state_conf  = na
var label lbl_state_pair  = na
var label lbl_state_dist  = na

distTier(float d) =>
    float a = nz(atr14, syminfo.mintick * 10.0)
    a < 1e-12 ? "n/a" : d / a < 0.25 ? "tight" : d / a < 0.6 ? "close" : "wide"

if barstate.islast and showStateBlock
    label.delete(lbl_state_bias)
    label.delete(lbl_state_conf)
    label.delete(lbl_state_pair)
    label.delete(lbl_state_dist)
    int rxs = bar_index + 35
    float atrSt = nz(atr14, syminfo.mintick * 10.0)
    float baseS = nz(close, 0.0)
    color biasTc = bias == "BULL" ? bullColor : bias == "BEAR" ? bearColor : color.new(chart.fg_color, 30)
    color biasBg = bias == "BULL" ? color.new(bullColor, 60) : bias == "BEAR" ? color.new(bearColor, 60) : color.new(chart.fg_color, 75)
    string pairTxt = na(closestMask) ? "Closest pair: —" : "Closest pair: " + maskLabel(closestMask)
    string distTxt = na(closestDist) ? "Distance: —" : "Distance: " + str.tostring(closestDist, "#.##") + " (" + distTier(closestDist) + ")"
    lbl_state_bias := label.new(x=rxs, y=baseS + atrSt * 3.6,
         text="Mesh: " + bias,
         color=biasBg, textcolor=biasTc, style=label.style_label_left, size=size.small)
    lbl_state_conf := label.new(x=rxs, y=baseS + atrSt * 2.8,
         text="Confluences: " + str.tostring(confluenceCount) + " active",
         color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, style=label.style_label_left, size=size.small)
    lbl_state_pair := label.new(x=rxs, y=baseS + atrSt * 2.0,
         text=pairTxt,
         color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, style=label.style_label_left, size=size.small)
    lbl_state_dist := label.new(x=rxs, y=baseS + atrSt * 1.2,
         text=distTxt,
         color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, style=label.style_label_left, size=size.small)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
f_aboveBelow(float v) =>
    na(v) ? "—" : (close > v ? "ABOVE" : close < v ? "BELOW" : "AT")

f_aboveBelowBg(float v) =>
    na(v) ? color.new(chart.fg_color, 80) : (close > v ? color.new(bullColor, 65) : close < v ? color.new(bearColor, 65) : color.new(chart.fg_color, 80))

f_biasBg(string b) =>
    b == "BULL" ? color.new(bullColor, 40) : b == "BEAR" ? color.new(bearColor, 40) : color.new(chart.fg_color, 80)

var table dash = table.new(position.top_right, 2, 11,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 11,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    table.clear(dash, 0, 0, 1, 10)
    txtSize = sizeFromString(dashSize)

    // Row 0 — Header (merged)
    table.cell(dash, 0, 0, "Polaris VWAP Mesh [JOAT]", text_color=color.white, bgcolor=color.new(sessionColor, 30), text_size=txtSize)
    table.cell(dash, 1, 0, "",                         text_color=color.white, bgcolor=color.new(sessionColor, 30), text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1 — Session VWAP
    string sessTxt = na(sessionVwap) ? "—" : str.tostring(sessionVwap, format.mintick) + "  " + f_aboveBelow(sessionVwap)
    table.cell(dash, 0, 1, "Session VWAP",   text_color=sessionColor,    bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 1, sessTxt,          text_color=color.white,     bgcolor=f_aboveBelowBg(sessionVwap), text_size=txtSize)

    // Row 2 — Swing-High VWAP
    string shTxt = na(shVwap) ? "—" : str.tostring(shVwap, format.mintick) + "  " + f_aboveBelow(shVwap)
    table.cell(dash, 0, 2, "Swing-High VWAP",text_color=shColor,         bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, shTxt,            text_color=color.white,     bgcolor=f_aboveBelowBg(shVwap), text_size=txtSize)

    // Row 3 — Swing-Low VWAP
    string slTxt = na(slVwap) ? "—" : str.tostring(slVwap, format.mintick) + "  " + f_aboveBelow(slVwap)
    table.cell(dash, 0, 3, "Swing-Low VWAP", text_color=slColor,         bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, slTxt,            text_color=color.white,     bgcolor=f_aboveBelowBg(slVwap), text_size=txtSize)

    // Row 4 — PrevDay-Open VWAP
    string pdoTxt = na(pdoVwap) ? "—" : str.tostring(pdoVwap, format.mintick) + "  " + f_aboveBelow(pdoVwap)
    table.cell(dash, 0, 4, "PrevDay-Open VWAP", text_color=pdoColor,     bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, pdoTxt,              text_color=color.white,  bgcolor=f_aboveBelowBg(pdoVwap), text_size=txtSize)

    // Row 5 — Bull Count
    string bcTxt   = str.tostring(bullCount) + " / " + str.tostring(activeAnchors)
    color  bcBg    = activeAnchors == 0 ? color.new(chart.fg_color, 80) : color.new(color.from_gradient(bullCount, 0, math.max(activeAnchors, 1), bearColor, bullColor), 50)
    table.cell(dash, 0, 5, "Bull Count",    text_color=chart.fg_color,  bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 5, bcTxt,           text_color=color.white,     bgcolor=bcBg, text_size=txtSize)

    // Row 6 — Multi-Anchor Bias
    table.cell(dash, 0, 6, "Multi-Anchor Bias", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, bias,                text_color=color.white,    bgcolor=f_biasBg(bias), text_size=txtSize)

    // Row 7 — Active Confluences
    color cnfBg = confluenceCount >= 2 ? color.new(bullColor, 45) : confluenceCount == 1 ? color.new(sessionColor, 55) : color.new(chart.fg_color, 80)
    table.cell(dash, 0, 7, "Active Confluences", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, str.tostring(confluenceCount), text_color=color.white, bgcolor=cnfBg, text_size=txtSize)

    // Row 8 — Closest Confluence Level
    string cnfLvlTxt = na(closestConf) ? "—" : str.tostring(closestConf, format.mintick)
    table.cell(dash, 0, 8, "Confluence Level", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, cnfLvlTxt,          text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 9 — Bars Since Session Anchor
    string anchorAge = na(sess_anchor) ? "—" : str.tostring(bar_index - sess_anchor) + " bars"
    table.cell(dash, 0, 9, "Session Anchor Age", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, anchorAge,            text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    // Row 10 — Watermark (muted, merged)
    table.cell(dash, 0, 10, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 10, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 10, 1, 10)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(anyBullCross,    title="PVM Bull Cross",        message="Polaris VWAP Mesh [JOAT] — Bullish VWAP cross (any anchor)")
alertcondition(anyBearCross,    title="PVM Bear Cross",        message="Polaris VWAP Mesh [JOAT] — Bearish VWAP cross (any anchor)")
alertcondition(confluenceTouch, title="PVM Confluence Touch",  message="Polaris VWAP Mesh [JOAT] — Price touched a confluence zone")
alertcondition(multiAnchorBull, title="PVM Multi-Anchor Bull", message="Polaris VWAP Mesh [JOAT] — Multi-anchor bullish bias activated")
alertcondition(multiAnchorBear, title="PVM Multi-Anchor Bear", message="Polaris VWAP Mesh [JOAT] — Multi-anchor bearish bias activated")
alertcondition(bullCross_session, title="PVM Session Bull",    message="Polaris VWAP Mesh [JOAT] — Bullish cross of Session VWAP")
alertcondition(bearCross_session, title="PVM Session Bear",    message="Polaris VWAP Mesh [JOAT] — Bearish cross of Session VWAP")
alertcondition(bullCross_pdo,     title="PVM PrevDay Bull",    message="Polaris VWAP Mesh [JOAT] — Bullish cross of PrevDay-Open VWAP")
alertcondition(bearCross_pdo,     title="PVM PrevDay Bear",    message="Polaris VWAP Mesh [JOAT] — Bearish cross of PrevDay-Open VWAP")
````
