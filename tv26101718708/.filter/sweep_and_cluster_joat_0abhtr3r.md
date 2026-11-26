# Sweep and Cluster [JOAT]

- url: https://www.tradingview.com/script/0aBHtr3r-Sweep-and-Cluster-JOAT/
- type: indicator
- pine_id: PUB;07a1e00bfdf245b886717147768ed379
- version: 1.0

## Description

[b]SWEEP AND CLUSTER [JOAT][/b]

A two-stage liquidity-sweep engine. Most public "sweep" indicators print a label on every wick that pokes past a recent high or low — which is mostly noise. Sweep and Cluster requires [b]two[/b] separate events to register a tradeable signal: first a strict 5-condition sweep, then a confirming cluster of price action in the rejection direction. The label that actually appears on the chart is the rare intersection — the moments where institutional stop-running is followed by genuine commitment in the opposite direction.

[image]https://www.tradingview.com/x/2AFLHKVC/[/image]

[b]Stage 1 — Strict 5-condition sweep detection[/b]

A sweep is registered only when [b]all[/b] of these are true on the same bar:

[list]
[*] [b]Real pivot reference[/b] — the swept level is an actual minor pivot (ta.pivothigh / ta.pivotlow) from the rolling cache, not a rolling max/min. A scan-depth input controls how far back to look; a minimum-age gate prevents self-reference.
[*] [b]Wick magnitude[/b] — the wick that exceeds the pivot must be at least [b]Wick ATR Multiplier × ATR(14)[/b] (default 0.8 ATR). The KB-published strict threshold.
[*] [b]Wick dominance[/b] — wick length must be at least [b]Wick/Range Ratio[/b] of the candle's total range (default 35%). The wick must dominate the bar's shape, not be a side-effect of a large body.
[*] [b]Closing direction[/b] — close must be back inside the swept level. A clean wick that closed beyond the pivot is a breakout, not a sweep — and is filtered out by construction.
[*] [b]Cooldown[/b] — at least N bars (default 8) since the last same-side sweep. Prevents one stop-run from being counted as multiple sweeps when the wick prints over several bars.
[/list]

If all five conditions are met a [b]pending[/b] marker is placed (optional). Pending markers represent "a sweep happened" but not yet "the sweep was meaningful" — until the cluster confirms, the sweep is not actionable.

[b]Stage 2 — Cluster confirmation[/b]

After a sweep fires, the next [b]N[/b] bars (cluster window, default 5) are monitored for confirming follow-through. The cluster confirms only when:

[list]
[*] At least M bars (default 1) close [b]against[/b] the swept direction inside the window.
[*] Average body/range across the qualifying cluster bars exceeds the [b]Min Body Ratio[/b] (default 0.25) — the rejection candles must be impulsive, not micro-bodies.
[*] Cumulative volume across the cluster window is at least [b]Volume Multiplier × Average Volume[/b] (default 0.8×). Without volume the cluster is not commitment.
[/list]

When all three confirm, the script fires the [b]SAC[/b] (Sweep And Cluster) label — the actionable signal. A [b]cluster strength badge[/b] (body sum / ATR) is rendered next to the label so you can rank one SAC vs another at a glance.

A [b]failed sweep[/b] marker (toggleable, off by default) tracks sweeps that expired without confirming — useful for auditing the false-positive rate visually and for choosing thresholds.

[b]Visual system[/b]

[list]
[*] [b]Sweep wick highlight[/b] — a thin coloured line at the swept reference price, extended right by a configurable number of bars. Makes the rejection unmistakable.
[*] [b]Reference level triangle[/b] — small glyph at the actual pivot level that was swept.
[*] [b]Cluster candle override[/b] — when SAC fires, the confirming cluster candles are repainted in the active-side theme colour via plotcandle so the move stands out from background.
[*] [b]Optional background tint[/b] — fading directional bgcolor for a few bars after a confirmed SAC.
[*] [b]Optional bar paint by active bias[/b] — every bar painted bull/bear based on the most recent SAC. Off by default to preserve chart neutrality.
[/list]

A locked Quantum palette (cyan-quantum bull / pink-quantum bear on a deep void) gives the chart a distinctive sweep-and-reverse identity.

[image]https://www.tradingview.com/x/6vg9fazf/[/image]

[b]Dashboard + rolling statistics[/b]

A monospaced table, positionable to any of nine corners, with vertical row-fade for premium feel. Surfaces:

[list]
[*] Total sweeps and total SACs since the last session/day/week reset (configurable reset frame).
[*] Rolling [b]Confirmation Rate[/b] (% of recent sweeps that became SACs) over a configurable window (default 50). The script's own success metric.
[*] Pending sweep status with bars-remaining-in-cluster-window.
[*] Last SAC direction with strength badge and bars-ago.
[*] Last failed sweep tag (when failed markers are enabled).
[/list]

Confirmation Rate is the headline read — it lets you see whether the current threshold settings are producing meaningful or sparse signals on the instrument you are trading.

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Pending Sweep (Stage 1 fires)
[*] SAC Confirmed (Stage 2 confirms)
[*] SAC Failed (Stage 2 expires without confirming) — off by default
[/list]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]SAC Confirmed alert with a high strength badge[/b] — the script's intended signal. Liquidity was swept, a real rejection followed inside the window, and the rejection had body and volume. This is the actionable read.
[*] [b]Pending Sweep at a known structural level (S/R, supply/demand)[/b] — useful as a "watch for the cluster" warning. If the cluster confirms, you have a high-conviction reversal at a structural location.
[/list]

In persistent trends the failed-sweep rate climbs — that is the script telling you the regime does not currently favour sweep-and-reverse setups; stand aside or use the script in the trend direction only.

[b]Suggested settings[/b]

Defaults (pivot lookback 8, wick ATR 0.8, body ratio 0.35, cluster window 5) are tuned for 15m–1H on liquid markets. For scalping (1m–5m), drop pivot lookback to 4 and cluster window to 3. For HTF macro reads (4H+), raise pivot lookback to 12–20 and cluster window to 8. The strict-threshold wick filters (0.8 ATR + 35%) are intentionally institutional — loosen for less liquid instruments.

[b]Originality[/b]

The implementation — the five-condition strict sweep gate, the rolling minor-pivot cache with age and scan-depth filters, the three-condition cluster confirmation, the cluster-strength badge calculation, the pending → confirmed → failed state machine, the wick-level highlight render, the plotcandle override for confirming bars, the rolling confirmation-rate metric, and the session-reset counter — is JOAT-original. No third-party code reused. The "sweep + reaction" pattern is well-known to professional tape readers; the strict double-gate implementation is built specifically for chart-based Pine data.

[b]Limitations[/b]

A confirmed SAC requires the cluster window to elapse — by definition the signal carries the [i]cluster window[/i] bars of lag relative to the sweep. This is intentional; the cluster is what makes the signal meaningful. Failed sweeps are expected — the confirmation rate metric is there for you to see and tune accordingly. The script is structure-aware (uses real pivots) but does not know about HTF structure; combine with a higher-timeframe S/R indicator for best fit.

—

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Sweep and Cluster [JOAT]", shorttitle="SAC [JOAT]",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500,
     max_bars_back     = 5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================
//  Every functional subsystem owns one input group, headed by a box-drawing
//  string so the user can find related controls together in the settings
//  panel.  Tooltips explain WHY each value matters, not just what it is.
// -----------------------------------------------------------------------------

// ---- Group strings ----------------------------------------------------------
g_sweep     = "Sweep Detection (5-Condition Strict)"
g_cluster   = "Cluster Confirmation Window"
g_signals   = "Signal Engine"
g_visuals   = "Visuals"
g_dash      = "Dashboard"
g_stats     = "Statistics Window"
g_alerts    = "Alerts"

// ---- Sweep detection --------------------------------------------------------
pivotLen    = input.int(8, "Minor Pivot Lookback", minval = 2, maxval = 60, group = g_sweep,
     tooltip = "Bars on each side required to confirm a minor pivot via ta.pivothigh / ta.pivotlow. Default 8 balances responsiveness and noise on 15m to 4H charts. Use 4-6 for scalping and 12-20 for higher timeframes.")
pivotKeep   = input.int(60, "Minor Pivots Kept", minval = 10, maxval = 300, group = g_sweep,
     tooltip = "Maximum number of minor pivots tracked. Pivots older than this are dropped from the rolling cache to keep memory bounded.")
wickAtrMult = input.float(0.8, "Wick / ATR Multiplier", minval = 0.1, maxval = 5.0, step = 0.05, group = g_sweep,
     tooltip = "Sweep wick must be at least this multiple of ATR(14). Default 0.8 from KB section 3.12 is the published strict threshold.  Raise to 1.0+ for only the most violent sweeps.")
wickRatio   = input.float(0.35, "Wick / Range Ratio", minval = 0.05, maxval = 1.0, step = 0.01, group = g_sweep,
     tooltip = "Sweep wick must be at least this fraction of the candle's total range. Default 0.35 (35%) makes sure the wick dominates the bar's shape rather than being a side-effect of a long body.")
sweepCool   = input.int(8, "Sweep Cooldown (bars)", minval = 1, maxval = 50, group = g_sweep,
     tooltip = "Minimum bars between same-direction sweeps. Prevents one stop-run from being counted multiple times when the wick prints over several bars.")
pivScanDepth = input.int(12, "Pivot Reference Scan Depth", minval = 3, maxval = 30, group = g_sweep,
     tooltip = "How many of the most recent minor pivots to scan when looking for a reference high / low. Larger values let stale liquidity remain a valid sweep target.")
pivAgeBars  = input.int(2, "Pivot Min Age (bars)", minval = 1, maxval = 20, group = g_sweep,
     tooltip = "Reference pivot must be at least this many bars old. Filters self-reference where the current bar's wick would otherwise be compared against itself.")

// ---- Cluster confirmation ---------------------------------------------------
clusterWindow = input.int(5, "Cluster Window (bars)", minval = 2, maxval = 30, group = g_cluster,
     tooltip = "After a sweep fires, the indicator monitors this many subsequent bars for confirming follow-through. Default 5 captures the immediate reaction without letting the signal stale.")
minClustBars  = input.int(1, "Min Cluster Bars", minval = 1, maxval = 20, group = g_cluster,
     tooltip = "Minimum number of bars inside the window that must close AGAINST the swept direction.")
minBodyRatio  = input.float(0.25, "Min Average Body / Range", minval = 0.05, maxval = 1.0, step = 0.05, group = g_cluster,
     tooltip = "Average body-to-range across the qualifying cluster candles must be at least this.")
minCumVolMult = input.float(0.8, "Min Cumulative Volume / Avg Volume", minval = 0.1, maxval = 10.0, step = 0.1, group = g_cluster,
     tooltip = "Sum of volume across the cluster window must be at least this multiple of the rolling average volume.")
volAvgLen     = input.int(20, "Volume Average Length", minval = 5, maxval = 200, group = g_cluster,
     tooltip = "Bars used for the rolling volume baseline. Default 20 matches the public-domain norm.")
strengthAtrLen = input.int(14, "Strength ATR Window", minval = 5, maxval = 100, group = g_cluster,
     tooltip = "ATR period used in the cluster strength denominator: cluster_strength = body_sum / ATR(N). Default 14 matches the wick ATR so the two metrics live on the same scale.")
allowOverlap  = input.bool(false, "Allow Sweeps to Overlap Pending Cluster", group = g_cluster,
     tooltip = "When off (default), a second sweep in the same direction cannot start a new pending cluster while one is still being monitored. When on, both pending clusters run simultaneously -- usually too noisy.")

// ---- Signal engine ----------------------------------------------------------
showPending   = input.bool(true, "Show Pending Sweep Markers", group = g_signals,
     tooltip = "When on, a preliminary X label is drawn at sweep time even before the cluster confirms.")
showFailed    = input.bool(false, "Show Failed Sweep Markers", group = g_signals,
     tooltip = "When on, sweeps that expire without cluster confirmation get a small grey marker so you can audit the false-positive rate visually.")
showSAC       = input.bool(true, "Show SAC Confirmation Labels", group = g_signals,
     tooltip = "Master toggle for the large SAC label that fires once the cluster is confirmed.")
showStrength  = input.bool(true, "Show Cluster Strength Badge", group = g_signals,
     tooltip = "Adds a numeric strength badge next to each SAC label (body sum divided by ATR).")
labelSize     = input.string("Normal", "Signal Label Size", options = ["Tiny","Small","Normal","Large","Huge"], group = g_signals)

// ---- Visuals ----------------------------------------------------------------
hiSweepWick   = input.bool(true,  "Highlight Sweep Wick (line at swept level)", group = g_visuals,
     tooltip = "Draws a thin coloured line at the swept reference price so the rejection is obvious on the chart.")
sweepWickExt  = input.int(8, "Sweep Wick Highlight Extension (bars)", minval = 1, maxval = 80, group = g_visuals,
     tooltip = "How many bars to extend the sweep level line to the right of the sweep bar.")
hiClusterCdls = input.bool(true,  "Highlight Cluster Candles (plotcandle override)", group = g_visuals,
     tooltip = "When SAC fires, repaint the confirming cluster candles in a brighter theme colour so the move stands out from background candles.")
showSweepLevels = input.bool(true, "Show Sweep Reference Level Marker", group = g_visuals,
     tooltip = "Adds a small triangle at the actual swept pivot level so you can see what liquidity was swept.")
useThemeBg    = input.bool(false, "Tint Background After SAC (decay)", group = g_visuals,
     tooltip = "Applies a fading directional background tint for a few bars after a confirmed SAC.")
bgDecayBars   = input.int(6, "Background Tint Decay (bars)", minval = 1, maxval = 40, group = g_visuals)
paintBars     = input.bool(false, "Paint All Bars by Active Bias", group = g_visuals,
     tooltip = "When on, every bar is painted bull or bear based on the most recent SAC direction (off by default to preserve chart neutrality).")

// ---- Dashboard --------------------------------------------------------------
showDash      = input.bool(true, "Show Dashboard", group = g_dash)
dashPos       = input.string("Top Right", "Dashboard Position",
     options = ["Top Right","Top Left","Top Center",
                "Middle Right","Middle Left","Middle Center",
                "Bottom Right","Bottom Left","Bottom Center"],
     group = g_dash)
dashSize      = input.string("Small", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"], group = g_dash)
dashTrans     = input.int(15, "Background Transparency", minval = 0, maxval = 100, group = g_dash,
     tooltip = "Higher values make the dashboard more transparent.")
dashRowFade   = input.bool(true, "Row Gradient Fade", group = g_dash,
     tooltip = "Subtle vertical transparency gradient down the dashboard for a premium feel.")

// ---- Statistics window ------------------------------------------------------
confRateWin   = input.int(50, "Confirmation Rate Window", minval = 5, maxval = 500, group = g_stats,
     tooltip = "Rolling window over which the confirmation rate (% of sweeps that became SACs) is computed. Default 50 gives a stable reading without being too slow to react.")
sessionResetTf = input.string("Day", "Session Reset Frame",
     options = ["None","Day","Week","Month"], group = g_stats,
     tooltip = "How often the Total Sweeps and Total SACs counters reset.")

// ---- Alerts -----------------------------------------------------------------
alertOnPending = input.bool(true, "Alert on Pending Sweep", group = g_alerts)
alertOnSAC     = input.bool(true, "Alert on SAC Confirmed",  group = g_alerts)
alertOnFail    = input.bool(false, "Alert on SAC Failed",    group = g_alerts)

// =============================================================================
//  SECTION 2 - PALETTE  (Quantum - curated, single palette)
// =============================================================================
//   C_BULL  -> cyan-quantum  (sweep-then-reverse bull side)
//   C_BEAR  -> pink-quantum  (sweep-then-reverse bear side)
//   C_NEUT  -> neutral / pending glow
//   C_BG    -> deep quantum background
//   C_FRAME -> dark violet frame
//   SAC confirmation glow stacks identical active-side hue with transparency.
const color C_BULL = #00FFE0
const color C_BEAR = #FF00C8
const color C_NEUT = #80FFE0
const color C_BG   = #02011A
color C_FRAME  = color.new(#1A0F33, 60)
color C_HDR    = color.new(C_BG,  dashTrans)
color C_TXT    = color.new(#FFFFFF, 0)
color C_TXT_M  = color.new(#A8B0BD, 10)
color C_GHOST  = color.new(#888888, 30)
color C_GLOW   = color.new(C_NEUT, 40)
color C_BULL_GLOW = color.new(C_BULL, 65)
color C_BEAR_GLOW = color.new(C_BEAR, 65)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================
//  Library helpers reused across the JOAT suite.  Each is small enough to
//  read in one screen and has no side effects.
// -----------------------------------------------------------------------------

// 3.1 Linear RGB gradient between two colors ----------------------------------
f_colorGradient(float r, color a, color b) =>
    rA = color.r(a), gA = color.g(a), bA = color.b(a)
    rB = color.r(b), gB = color.g(b), bB = color.b(b)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

// 3.2 Clamp a value to a [lo, hi] range ---------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(x, hi))

// 3.3 Position string resolver ------------------------------------------------
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// 3.4 Size string resolver ----------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// 3.5 Row gradient ------------------------------------------------------------
f_grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? float(minT) : float(minT) + float(maxT - minT) * (float(row) / float(rows - 1))
    color.new(base, int(t))

// 3.6 Compact volume formatter ------------------------------------------------
f_fmtVol(float v) =>
    v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.##")

// 3.7 Percent formatter ------------------------------------------------------
f_fmtPct(float v) => str.tostring(v, "#.#") + "%"

// 3.8 Two-decimal numeric formatter ------------------------------------------
f_fmtNum(float v) => str.tostring(v, "#.##")

// 3.9 Price formatter that adapts precision to magnitude ---------------------
f_fmtPrice(float p) =>
    p > 1000 ? str.tostring(p, "#.##") : p > 1 ? str.tostring(p, "#.####") : str.tostring(p, "#.######")

// 3.10 Star rating from ratio -------------------------------------------------
f_stars(float s, float maxS) =>
    ratio = maxS > 0 ? s / maxS : 0.0
    ratio >= 0.85 ? "***" : ratio >= 0.55 ? "**" : "*"

// 3.11 Direction word --------------------------------------------------------
f_dirWord(int dir) => dir == 1 ? "BULL" : dir == -1 ? "BEAR" : "NONE"

// 3.12 Safe positive value (avoids div-by-zero) ------------------------------
f_safePos(float v) => v > 0 ? v : 0.0001

// 3.13 Dashboard row background helper (uses dashRowFade input) --------------
//      Declared at script scope because Pine v6 disallows defining user
//      functions inside conditional blocks.  The two transparency stops
//      (80 / 95) produce a subtle top-down fade.
f_rowBg(int r) =>
    dashRowFade ? f_grad(C_BG, r, 9, 80, 95) : color.new(C_BG, 88)

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS  (sweep detection inputs)
// =============================================================================
//  Per-bar quantities needed by the sweep test and by cluster scoring.
// -----------------------------------------------------------------------------
float atrFast     = ta.atr(14)
float atrStrength = ta.atr(strengthAtrLen)
float volAvg      = ta.sma(volume, volAvgLen)

float topWick     = high - math.max(open, close)
float botWick     = math.min(open, close) - low
float bodySize    = math.abs(close - open)
float candleRng   = high - low
float bodyRatio   = candleRng > 0 ? bodySize / candleRng : 0.0
bool  isBullCdl   = close >= open
bool  isBearCdl   = close <  open

// =============================================================================
//  SECTION 5 - STATE  (UDTs + var arrays)
// =============================================================================
//  All state crossing the bar boundary lives here.  Two-stage confirmation
//  needs to remember a sweep until either (a) the cluster fires, or (b)
//  the cluster window expires.  We use a SweepEvent UDT instead of three
//  parallel arrays.
// -----------------------------------------------------------------------------

// 5.1 Minor pivot (price + bar + kind) ----------------------------------------
type MinorPivot
    int    bar
    float  price
    int    kind            // +1 high, -1 low

// 5.2 Pending sweep event being monitored for cluster confirmation ------------
type SweepEvent
    int    barIdx          // bar on which the sweep printed
    int    dir             // direction of the EXPECTED reversal (+1 bull / -1 bear)
    float  sweptLevel      // the pivot price that was swept
    float  wickLen         // length of the wick at sweep time
    int    barsAwaited     // bars elapsed inside the cluster window
    int    qualifyingBars  // count of bars closing the expected way
    float  bodySum         // sum of |close - open| across qualifying bars
    float  rangeSum        // sum of (high - low) across qualifying bars
    float  cumVol          // cumulative volume across the window
    float  volBaseline     // volAvg captured at sweep time (used for the ratio)
    bool   resolved        // true after the window has been closed out

// 5.3 Confirmed SAC event used to feed strength averages + history ------------
type SacEvent
    int    barIdx
    int    dir
    float  strength
    float  sweptLevel

// 5.4 Persistent state --------------------------------------------------------
var array<MinorPivot> minorPivots = array.new<MinorPivot>()
var array<SweepEvent> pending     = array.new<SweepEvent>()
var array<SacEvent>   sacHistory  = array.new<SacEvent>()

// Rolling sweep-confirmation outcomes for confirmation-rate %
var array<bool>       sweepOutcomes = array.new<bool>()

// Drawing handles so we can trim
var array<line>       sweepLines   = array.new<line>()
var array<label>      pendLabels   = array.new<label>()
var array<label>      sacLabels    = array.new<label>()
var array<label>      failLabels   = array.new<label>()
var array<label>      lvlMarkers   = array.new<label>()

// Cluster-candle override paint buffer (parallel arrays of bar index + color)
var array<int>        clusterBars  = array.new<int>()
var array<color>      clusterCols  = array.new<color>()

// Cooldown tracking per direction (sweep direction = direction of the wick)
var int lastBullSweepBar = -10000   // last bullish sweep (LOW pierced)
var int lastBearSweepBar = -10000   // last bearish sweep (HIGH pierced)

// Session counters
var int sessSweepsTotal = 0
var int sessSacsTotal   = 0
var int lifeSweepsTotal = 0
var int lifeSacsTotal   = 0

// Most recent SAC (for dashboard "Last SAC" row)
var int   lastSacBar  = na
var int   lastSacDir  = 0
var float lastSacStr  = na

// Bias state derived from the most recent SAC (used for optional bar paint)
var int   activeBias  = 0
var int   lastSacBgBar = -10000     // for fading background tint

// =============================================================================
//  SECTION 5b - SESSION RESETS
// =============================================================================
//  Whenever the chosen session frame rolls over, reset the per-session
//  counters.  Lifetime totals continue to accumulate.
// -----------------------------------------------------------------------------
sessionRollover = sessionResetTf == "Day" ? ta.change(time("D")) != 0 : sessionResetTf == "Week" ? ta.change(time("W")) != 0 : sessionResetTf == "Month" ? ta.change(time("M")) != 0 : false

if sessionRollover
    sessSweepsTotal := 0
    sessSacsTotal   := 0

// =============================================================================
//  SECTION 6 - SWEEP DETECTION  (5-condition strict test)
// =============================================================================
//  ALL of:
//    (1) Wick pokes through a recent MINOR pivot
//    (2) Close returns inside the pivot
//    (3) Wick length >= wickAtrMult * ATR(14)
//    (4) Wick ratio >= wickRatio of the candle's range
//    (5) Cooldown of sweepCool bars since last same-direction sweep
// -----------------------------------------------------------------------------

// 6.1 Push new minor pivots when they confirm ---------------------------------
microPh = ta.pivothigh(pivotLen, pivotLen)
microPl = ta.pivotlow(pivotLen, pivotLen)
if not na(microPh)
    array.push(minorPivots, MinorPivot.new(bar_index - pivotLen, microPh,  1))
if not na(microPl)
    array.push(minorPivots, MinorPivot.new(bar_index - pivotLen, microPl, -1))

// 6.2 Bound memory ------------------------------------------------------------
while array.size(minorPivots) > pivotKeep
    array.shift(minorPivots)

// 6.3 Scan most recent pivots for nearest high + low reference --------------
//     The pivot must be at least pivAgeBars older than the current bar so the
//     current wick is not compared against itself.
float refHi = na
float refLo = na
int   refHiBar = na
int   refLoBar = na
sz = array.size(minorPivots)
if sz > 0
    maxScan = math.max(sz - pivScanDepth, 0)
    for i = sz - 1 to maxScan
        p = array.get(minorPivots, i)
        if na(refHi) and p.kind == 1 and (bar_index - p.bar) >= pivAgeBars
            refHi    := p.price
            refHiBar := p.bar
        if na(refLo) and p.kind == -1 and (bar_index - p.bar) >= pivAgeBars
            refLo    := p.price
            refLoBar := p.bar
        if not na(refHi) and not na(refLo)
            break

// 6.4 The five-condition test -------------------------------------------------
//     Bearish-side sweep:  high pierces refHi, close falls back inside.
//     Direction of the EXPECTED reversal is bearish (-1).
//     Bullish-side sweep:  low pierces refLo,  close climbs back inside.
//     Direction of the EXPECTED reversal is bullish (+1).
bool bearSweepSig = not na(refHi)
     and high > refHi
     and close < refHi
     and topWick >= atrFast * wickAtrMult
     and topWick / math.max(candleRng, 0.0001) >= wickRatio
     and (bar_index - lastBearSweepBar) > sweepCool

bool bullSweepSig = not na(refLo)
     and low < refLo
     and close > refLo
     and botWick >= atrFast * wickAtrMult
     and botWick / math.max(candleRng, 0.0001) >= wickRatio
     and (bar_index - lastBullSweepBar) > sweepCool

// 6.5 Guard: if allowOverlap is off, suppress a new pending sweep when an
//     unresolved one of the same direction is already in flight.
bool hasPendingBull = false
bool hasPendingBear = false
if array.size(pending) > 0
    for j = 0 to array.size(pending) - 1
        ev = array.get(pending, j)
        if not ev.resolved
            if ev.dir == 1
                hasPendingBull := true
            if ev.dir == -1
                hasPendingBear := true

if not allowOverlap
    if hasPendingBull
        bullSweepSig := false
    if hasPendingBear
        bearSweepSig := false

// 6.6 Commit cooldown timestamps and counters --------------------------------
if bearSweepSig
    lastBearSweepBar := bar_index
    sessSweepsTotal  += 1
    lifeSweepsTotal  += 1
if bullSweepSig
    lastBullSweepBar := bar_index
    sessSweepsTotal  += 1
    lifeSweepsTotal  += 1

// 6.7 Open a new pending SweepEvent on confirmed sweep ----------------------
if bearSweepSig
    SweepEvent ev = SweepEvent.new(
         barIdx         = bar_index,
         dir            = -1,
         sweptLevel     = nz(refHi, high),
         wickLen        = topWick,
         barsAwaited    = 0,
         qualifyingBars = 0,
         bodySum        = 0.0,
         rangeSum       = 0.0,
         cumVol         = 0.0,
         volBaseline    = nz(volAvg, volume),
         resolved       = false)
    array.push(pending, ev)
if bullSweepSig
    SweepEvent ev = SweepEvent.new(
         barIdx         = bar_index,
         dir            = 1,
         sweptLevel     = nz(refLo, low),
         wickLen        = botWick,
         barsAwaited    = 0,
         qualifyingBars = 0,
         bodySum        = 0.0,
         rangeSum       = 0.0,
         cumVol         = 0.0,
         volBaseline    = nz(volAvg, volume),
         resolved       = false)
    array.push(pending, ev)

// =============================================================================
//  SECTION 7 - CLUSTER MONITORING + CONFIRMATION LOGIC
// =============================================================================
//  After a sweep prints, the next clusterWindow bars are inspected.  A bar
//  "qualifies" if it closes in the expected reversal direction.  The cluster
//  is confirmed when ALL of:
//    (a) qualifyingBars >= minClustBars
//    (b) avg(body / range) across qualifying bars >= minBodyRatio
//    (c) cumulative window volume >= minCumVolMult * volume baseline
//
//  Strength is computed once at confirmation as body_sum / ATR(strengthAtrLen).
// -----------------------------------------------------------------------------
bool   sacConfirmedThisBar = false
int    sacDirThisBar       = 0
float  sacStrengthThisBar  = na
float  sacLevelThisBar     = na

bool   sacFailedThisBar    = false
int    sacFailDirThisBar   = 0

if array.size(pending) > 0
    // walk newest-to-oldest so we can remove resolved events without index drift
    for k = array.size(pending) - 1 to 0
        ev = array.get(pending, k)
        if ev.resolved
            continue
        // Skip the sweep bar itself -- monitoring starts on the next bar.
        if bar_index == ev.barIdx
            continue
        ev.barsAwaited += 1
        ev.cumVol      += volume
        bool qualifies = (ev.dir == 1 and isBullCdl) or (ev.dir == -1 and isBearCdl)
        if qualifies
            ev.qualifyingBars += 1
            ev.bodySum        += bodySize
            ev.rangeSum       += candleRng
        // Cache mutated event back into the array
        array.set(pending, k, ev)
        // Evaluate confirmation only if we have enough qualifying bars.
        if ev.qualifyingBars >= minClustBars
            avgBodyR    = ev.rangeSum > 0 ? ev.bodySum / ev.rangeSum : 0.0
            volRatio    = ev.volBaseline > 0 ? ev.cumVol / (ev.volBaseline * float(ev.barsAwaited)) : 0.0
            bodyOk      = avgBodyR >= minBodyRatio
            volOk       = volRatio >= minCumVolMult
            if bodyOk and volOk
                strength = ev.bodySum / f_safePos(atrStrength)
                sacConfirmedThisBar := true
                sacDirThisBar       := ev.dir
                sacStrengthThisBar  := strength
                sacLevelThisBar     := ev.sweptLevel
                // Persist for history
                array.push(sacHistory, SacEvent.new(bar_index, ev.dir, strength, ev.sweptLevel))
                array.push(sweepOutcomes, true)
                sessSacsTotal += 1
                lifeSacsTotal += 1
                lastSacBar    := bar_index
                lastSacDir    := ev.dir
                lastSacStr    := strength
                activeBias    := ev.dir
                lastSacBgBar  := bar_index
                ev.resolved   := true
                array.set(pending, k, ev)
                continue
        // Window expired without confirmation?
        if ev.barsAwaited >= clusterWindow and not ev.resolved
            sacFailedThisBar  := true
            sacFailDirThisBar := ev.dir
            ev.resolved       := true
            array.set(pending, k, ev)
            array.push(sweepOutcomes, false)
            continue

// Trim sweepOutcomes to the configured window
while array.size(sweepOutcomes) > confRateWin
    array.shift(sweepOutcomes)

// Cap SAC history (rolling)
while array.size(sacHistory) > 200
    array.shift(sacHistory)

// Remove fully-resolved pending entries to keep the array short
if array.size(pending) > 0
    int idx = array.size(pending) - 1
    while idx >= 0
        if idx >= array.size(pending)
            idx -= 1
            continue
        ev = array.get(pending, idx)
        if ev.resolved
            array.remove(pending, idx)
        idx -= 1

// Compute pending count after pruning
int pendingCount = 0
if array.size(pending) > 0
    for j = 0 to array.size(pending) - 1
        ev = array.get(pending, j)
        if not ev.resolved
            pendingCount += 1

// Confirmation rate over the rolling window
float confRatePct = na
if array.size(sweepOutcomes) > 0
    int hits = 0
    for j = 0 to array.size(sweepOutcomes) - 1
        if array.get(sweepOutcomes, j)
            hits += 1
    confRatePct := float(hits) / float(array.size(sweepOutcomes)) * 100.0

// Average SAC strength (rolling history)
float avgSacStrength = na
if array.size(sacHistory) > 0
    float ssum = 0.0
    for j = 0 to array.size(sacHistory) - 1
        ssum += array.get(sacHistory, j).strength
    avgSacStrength := ssum / float(array.size(sacHistory))

// Maximum SAC strength so far -- used for the star-rating badge
float maxSacStrength = 0.0
if array.size(sacHistory) > 0
    for j = 0 to array.size(sacHistory) - 1
        s = array.get(sacHistory, j).strength
        if s > maxSacStrength
            maxSacStrength := s

// =============================================================================
//  SECTION 8 - PLOTS  (sweep wick highlight + cluster candle override)
// =============================================================================
//  Two visual layers:
//   (a) A short coloured line at the swept pivot level extending right of
//       the sweep bar, so the trader sees the liquidity that got grabbed.
//   (b) A bright cluster-candle repaint when SAC confirms.  We override
//       open/high/low/close with the actual values but recolor the body.
// -----------------------------------------------------------------------------

// 8.1 Sweep-wick highlight ---------------------------------------------------
if hiSweepWick and (bearSweepSig or bullSweepSig)
    int    sBar  = bar_index
    float  sLvl  = bearSweepSig ? nz(refHi, high) : nz(refLo, low)
    color  sCol  = bearSweepSig ? C_BEAR : C_BULL
    line   wln   = line.new(sBar, sLvl, sBar + sweepWickExt, sLvl,
         color = color.new(sCol, 25), style = line.style_solid, width = 2)
    array.push(sweepLines, wln)
    while array.size(sweepLines) > 60
        line.delete(array.shift(sweepLines))

// 8.2 Sweep reference marker (small triangle at the swept pivot price) -------
if showSweepLevels and (bearSweepSig or bullSweepSig)
    color sCol = bearSweepSig ? C_BEAR : C_BULL
    float lvl  = bearSweepSig ? nz(refHi, high) : nz(refLo, low)
    label mkr  = label.new(bar_index, lvl,
         text       = bearSweepSig ? "v" : "^",
         color      = color.new(sCol, 70),
         textcolor  = sCol,
         style      = bearSweepSig ? label.style_label_down : label.style_label_up,
         size       = size.tiny)
    array.push(lvlMarkers, mkr)
    while array.size(lvlMarkers) > 60
        label.delete(array.shift(lvlMarkers))

// 8.3 Track cluster-candle override (paint cluster bars when SAC fires) -----
//     We append the SAC confirmation bar and the previous (clusterWindow-1)
//     bars to a recoloring buffer.  Pine's plotcandle below consumes it.
if hiClusterCdls and sacConfirmedThisBar
    color cCol = sacDirThisBar == 1 ? C_BULL : C_BEAR
    int lookN  = math.min(clusterWindow, 30)
    for k = 0 to lookN - 1
        array.push(clusterBars, bar_index - k)
        array.push(clusterCols, cCol)
    while array.size(clusterBars) > 250
        array.shift(clusterBars)
        array.shift(clusterCols)

// 8.4 Resolve per-bar override colour (na = leave default) -------------------
color overrideCol = na
if hiClusterCdls and array.size(clusterBars) > 0
    for k = array.size(clusterBars) - 1 to 0
        if array.get(clusterBars, k) == bar_index
            overrideCol := array.get(clusterCols, k)
            break
plotcandle(open, high, low, close, title = "Cluster Override",
     color       = overrideCol,
     wickcolor   = overrideCol,
     bordercolor = overrideCol,
     display     = display.all)

// 8.5 Painted bars by active bias (off by default) ---------------------------
color barTint = paintBars and activeBias != 0 ? (activeBias == 1 ? C_BULL : C_BEAR) : na
barcolor(barTint, title = "Bias Bar Color")

// 8.6 Fading background tint after a SAC -------------------------------------
int  bgAge = bar_index - lastSacBgBar
color bgC = na
if useThemeBg and bgAge >= 0 and bgAge <= bgDecayBars and activeBias != 0
    float ratio = 1.0 - (float(bgAge) / float(bgDecayBars))
    int alpha   = int(85.0 + (1.0 - ratio) * 15.0)   // 85 -> 100
    color base  = activeBias == 1 ? C_BULL : C_BEAR
    bgC := color.new(base, alpha)
bgcolor(bgC, title = "SAC Decay Background")

// =============================================================================
//  SECTION 9 - LABELS  (preliminary X for sweep, glow lightning for SAC)
// =============================================================================

// 9.1 Pending sweep marker (small X above/below) -----------------------------
if showPending and bearSweepSig
    label lbl = label.new(bar_index, high + atrFast * 0.3, "X",
         color      = color.new(C_BEAR, 30),
         textcolor  = color.white,
         style      = label.style_label_down,
         size       = strToSize(labelSize) == size.huge ? size.large : strToSize(labelSize) == size.large ? size.normal : size.small)
    array.push(pendLabels, lbl)
    while array.size(pendLabels) > 80
        label.delete(array.shift(pendLabels))
if showPending and bullSweepSig
    label lbl = label.new(bar_index, low - atrFast * 0.3, "X",
         color      = color.new(C_BULL, 30),
         textcolor  = color.white,
         style      = label.style_label_up,
         size       = strToSize(labelSize) == size.huge ? size.large : strToSize(labelSize) == size.large ? size.normal : size.small)
    array.push(pendLabels, lbl)
    while array.size(pendLabels) > 80
        label.delete(array.shift(pendLabels))

// 9.2 Failed sweep markers (small grey dot) ----------------------------------
if showFailed and sacFailedThisBar
    float yLoc = sacFailDirThisBar == 1 ? low - atrFast * 0.5 : high + atrFast * 0.5
    label lbl = label.new(bar_index, yLoc, "o",
         color      = color.new(C_GHOST, 70),
         textcolor  = C_GHOST,
         style      = sacFailDirThisBar == 1 ? label.style_label_up : label.style_label_down,
         size       = size.tiny)
    array.push(failLabels, lbl)
    while array.size(failLabels) > 50
        label.delete(array.shift(failLabels))

// 9.3 SAC confirmation label (large + optional strength badge) ---------------
if showSAC and sacConfirmedThisBar
    color  sCol   = sacDirThisBar == 1 ? C_BULL : C_BEAR
    color  glowC  = sacDirThisBar == 1 ? C_BULL_GLOW : C_BEAR_GLOW
    float  yLoc   = sacDirThisBar == 1 ? low  - atrFast * 0.9 : high + atrFast * 0.9
    string stars  = f_stars(sacStrengthThisBar, math.max(maxSacStrength, 0.5))
    string txt    = "SAC " + (sacDirThisBar == 1 ? "BULL" : "BEAR")
    if showStrength
        txt += "  " + f_fmtNum(sacStrengthThisBar) + "x  " + stars
    label lbl = label.new(bar_index, yLoc, txt,
         color      = color.new(glowC, 25),
         textcolor  = color.white,
         style      = sacDirThisBar == 1 ? label.style_label_up : label.style_label_down,
         size       = strToSize(labelSize))
    array.push(sacLabels, lbl)
    while array.size(sacLabels) > 40
        label.delete(array.shift(sacLabels))

// =============================================================================
//  SECTION 10 - DASHBOARD  (8 rows + header)
// =============================================================================
//  Layout:
//    Row 0: HEADER (spans both columns)
//    Row 1: Pending Sweeps
//    Row 2: Last SAC (direction + bars ago + strength)
//    Row 3: Confirmation Rate
//    Row 4: Total Sweeps (session)
//    Row 5: Total SACs (session)
//    Row 6: Cluster Window setting
//    Row 7: Min Cluster Bars setting
//    Row 8: Avg SAC Strength
// -----------------------------------------------------------------------------
var table tbl = table.new(strToPos(dashPos), 2, 9,
     bgcolor      = na,
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 65),
     border_width = 1)

// Colour for the status dot in the header (mirrors active bias)
color hdrDot = activeBias == 1 ? C_BULL : activeBias == -1 ? C_BEAR : C_GHOST

if showDash and barstate.islast
    // Header --------------------------------------------------------------
    table.cell(tbl, 0, 0, "SWEEP AND CLUSTER  o  v1.0",
         text_color = C_TXT, bgcolor = C_HDR,
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 0, str.tostring(activeBias == 1 ? "BULL" : activeBias == -1 ? "BEAR" : "FLAT"),
         text_color = hdrDot, bgcolor = C_HDR,
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 1: Pending Sweeps ---------------------------------------------
    string pendStr = str.tostring(pendingCount)
    if pendingCount > 0
        pendStr += "  (" + (hasPendingBull ? "B" : "") + (hasPendingBear ? "S" : "") + ")"
    table.cell(tbl, 0, 1, "Pending Sweeps",
         text_color = C_TXT_M, bgcolor = f_rowBg(1),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, pendStr,
         text_color = pendingCount > 0 ? C_NEUT : C_TXT, bgcolor = f_rowBg(1),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 2: Last SAC (direction + bars ago + strength) ----------------
    //  Use locally scoped names that do NOT collide with var declarations at
    //  the top of the script (var lastSacBar / lastSacDir / lastSacStr).
    string lsStr = "(none yet)"
    color  lsC   = C_TXT_M
    if not na(lastSacBar)
        int    barsAgo = bar_index - lastSacBar
        string sDir    = lastSacDir == 1 ? "BULL" : "BEAR"
        float  sStr    = nz(lastSacStr, 0.0)
        lsStr := sDir + "  " + str.tostring(barsAgo) + "b  " + f_fmtNum(sStr) + "x"
        lsC   := lastSacDir == 1 ? C_BULL : C_BEAR
    table.cell(tbl, 0, 2, "Last SAC",
         text_color = C_TXT_M, bgcolor = f_rowBg(2),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 2, lsStr,
         text_color = lsC, bgcolor = f_rowBg(2),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 3: Confirmation Rate ------------------------------------------
    string crStr = na(confRatePct) ? "--" : f_fmtPct(confRatePct)
    crC   = na(confRatePct) ? C_TXT_M : confRatePct >= 60.0 ? C_BULL : confRatePct >= 35.0 ? C_NEUT : C_BEAR
    table.cell(tbl, 0, 3, "Confirmation Rate",
         text_color = C_TXT_M, bgcolor = f_rowBg(3),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 3, crStr + "  (n=" + str.tostring(array.size(sweepOutcomes)) + ")",
         text_color = crC, bgcolor = f_rowBg(3),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 4: Session Sweeps ---------------------------------------------
    table.cell(tbl, 0, 4, "Sweeps (session)",
         text_color = C_TXT_M, bgcolor = f_rowBg(4),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 4, str.tostring(sessSweepsTotal) + " / " + str.tostring(lifeSweepsTotal),
         text_color = C_TXT, bgcolor = f_rowBg(4),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 5: Session SACs -----------------------------------------------
    table.cell(tbl, 0, 5, "SACs (session)",
         text_color = C_TXT_M, bgcolor = f_rowBg(5),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 5, str.tostring(sessSacsTotal) + " / " + str.tostring(lifeSacsTotal),
         text_color = C_NEUT, bgcolor = f_rowBg(5),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 6: Cluster Window setting -------------------------------------
    table.cell(tbl, 0, 6, "Cluster Window",
         text_color = C_TXT_M, bgcolor = f_rowBg(6),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 6, str.tostring(clusterWindow) + " bars",
         text_color = C_TXT, bgcolor = f_rowBg(6),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 7: Min Cluster Bars setting -----------------------------------
    table.cell(tbl, 0, 7, "Min Cluster Bars",
         text_color = C_TXT_M, bgcolor = f_rowBg(7),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 7, str.tostring(minClustBars),
         text_color = C_TXT, bgcolor = f_rowBg(7),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 8: Avg SAC Strength -------------------------------------------
    string asStr = na(avgSacStrength) ? "--" : f_fmtNum(avgSacStrength) + "x"
    color  asC   = na(avgSacStrength) ? C_TXT_M : C_NEUT
    table.cell(tbl, 0, 8, "Avg SAC Strength",
         text_color = C_TXT_M, bgcolor = f_rowBg(8),
         text_size  = strToSize(dashSize),
         text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 8, asStr,
         text_color = asC, bgcolor = f_rowBg(8),
         text_size  = strToSize(dashSize),
         text_halign = text.align_right,
         text_font_family = font.family_monospace)

// =============================================================================
//  SECTION 11 - ALERTS
// =============================================================================
//  Three event-level alerts.  Each fires once per bar at most.
// -----------------------------------------------------------------------------
if alertOnPending and (bullSweepSig or bearSweepSig)
    string dirTxt = bullSweepSig ? "BULL (low pierced)" : "BEAR (high pierced)"
    alert("SAC | Pending Sweep | " + dirTxt + " | " + syminfo.tickerid + " " + timeframe.period, alert.freq_once_per_bar_close)
if alertOnSAC and sacConfirmedThisBar
    string dirTxt = sacDirThisBar == 1 ? "BULL" : "BEAR"
    alert("SAC | CONFIRMED | " + dirTxt + " | strength=" + f_fmtNum(sacStrengthThisBar) + " | " + syminfo.tickerid + " " + timeframe.period, alert.freq_once_per_bar_close)
if alertOnFail and sacFailedThisBar
    string dirTxt = sacFailDirThisBar == 1 ? "BULL" : "BEAR"
    alert("SAC | Sweep Failed | " + dirTxt + " | " + syminfo.tickerid + " " + timeframe.period, alert.freq_once_per_bar_close)

// Standard alertcondition triggers (so the user can wire either path)
alertcondition(bullSweepSig or bearSweepSig, "Pending Sweep",  "SAC pending sweep")
alertcondition(sacConfirmedThisBar,          "SAC Confirmed",  "Sweep-and-Cluster confirmed")
alertcondition(sacFailedThisBar,             "SAC Failed",     "Sweep without confirming cluster")

// =============================================================================
//  END OF FILE
// =============================================================================
````
