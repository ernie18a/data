# Impulse Waves & Reversal Zones [MQLSoftware]

- url: https://www.tradingview.com/script/dBagpRyd-Impulse-Waves-Reversal-Zones-MQLSoftware/
- type: indicator
- pine_id: PUB;87b1e984704d44c28c2d9bb60c8f981f
- version: 3.0

## Description

Impulse Waves & Reversal Zones is a structural overlay that reads price as a chain of impulse and correction legs, then projects the zone where the dominant trend is expected to resume. Instead of auto-drawing a Fibonacci grid on the latest swing, it first decides whether a leg is a genuine impulse, frames the counter-trend pullback against it, and builds a managed reversal zone with targets, a stop, and a live status that retires the setup once it plays out. A compact right-side panel adds higher-timeframe bias, trend-conviction strength, an alignment score, and a plain-language plan.

This is a visual analytical tool intended for chart reading and structure mapping. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]
[list]
[*]Impulse legs qualified by a self-calibrating quality score and drawn as bold trend channels; weaker legs stay as a faint wave skeleton
[*]Active correction framed as an amber box labelled with its retracement depth versus the impulse it is correcting (an overrun beyond 100% is flagged as a deep retrace / structure break, not a clean correction)
[*]Reversal zone built on the 0.382-0.618 retracement of the qualified impulse, with TP1 (x1.272) and TP2 (x1.618) extension targets and a stop with its R:R
[*]Live setup status that moves through wait, in-zone, target hit, and stopped, and greys the zone out once it is resolved so a played-out setup never lingers as a live opportunity
[*]Multi-timeframe panel: bias plus trend-conviction (ADX) strength for the chart and the next higher timeframes, an alignment score, and a plain-language plan
[*]Higher timeframes selected automatically from the standard timeframe ladder based on the chart, with fewer rows near the top of the ladder (Daily, Weekly)
[*]A plan that softens to "low conviction" when the bias is backed only by ranging higher timeframes, with the active setup flagged the same way so the panel never states two opposite things at once
[/list]

[b]Core Concept[/b]
Most reversal-zone and Fibonacci tools on TradingView take one of two approaches. They either auto-draw a retracement grid on the most recent swing pair (no quality filter, and the grid jumps every time the latest swing redraws), or they label market structure (swings, breaks of structure) without projecting a managed, self-invalidating trade zone. Both leave the reader to decide by hand whether the leg even mattered and where the level should sit.

This indicator builds on a different base: classify structure first, then project a zone only from legs that qualify, and track that zone until it resolves. It adds three specific algorithmic elements on top of that base.

[b]1. Protected-Swing Structure Classification.[/b] Trend direction is tracked by a change-of-character state machine with protected swings: the trend only flips when price breaks the swing low or high that launched the prior impulse. Shallow pullbacks therefore stay classified as corrections instead of constantly flipping the trend, which is the common failure mode of naive zigzag and two-pivot tools.

[b]2. Self-Calibrating Impulse Quality Score.[/b] Every leg is scored 0-100 as one half Efficiency Ratio (net move divided by the path travelled, i.e. how straight the leg is) and one half Displacement Percentile (the leg's size in ATR units, ranked against the recent distribution of legs). A leg is drawn as an impulse only if it is with-trend and clears the score threshold. Because the size component is ranked against recent legs rather than compared to a fixed pip or point value, the filter self-calibrates across instruments and timeframes with no magic numbers.

[b]3. Conviction-Aware Bias and Reversal Zone.[/b] The reversal zone is anchored to the dominant-direction qualified impulse and managed with targets, a stop, and a live state. Higher-timeframe context uses ADX strength rather than a path-efficiency ratio, so a strong trend still reads as strong mid-pullback. When the bias is supported only by ranging higher timeframes, the panel reports the bias but softens the plan to "low conviction" and marks any active setup the same way, so the structural read and the suggested action stay consistent.

[b]Anatomy of the Display[/b]
[b]Trend channels[/b] are bold green or coral channels drawn only for legs that qualify as impulses. [b]The wave skeleton[/b] is a faint thin backbone drawn under every leg, so the raw swing structure stays visible; where a leg qualifies as an impulse, the bold channel sits on top of it.

[b]The correction box[/b] is an amber dashed outline on the active counter-trend pullback, labelled with the retracement depth as a percentage of the impulse it is correcting. A retracement beyond 100% is relabelled as a deep retrace because the structure that the zone relied on is now at risk.

[b]The reversal (entry) zone[/b] is the filled box spanning the 0.382-0.618 retracement of the qualified impulse, with a dotted mid-line and a label carrying the R:R of the resulting setup. [b]TP1 and TP2[/b] are the 1.272 and 1.618 extensions; [b]the stop[/b] sits beyond the impulse origin.

[b]The status chip[/b] reads the live state of the setup: waiting for the zone, in the zone, target hit, or stopped. Once the zone is hit or the setup is stopped, the zone and its levels grey out and the chip says so, so a resolved setup is visually retired rather than left looking active.

[b]The right-side panel[/b] lists, per row, the timeframe, its bias (Bull / Bear / Flat), and a trend-conviction strength bar. The chart's own row is marked "pullback" when its direction opposes the trading bias, so a green chart row inside a bearish plan reads as the rally you are selling, not as a long signal. Below the rows: an ALIGN score (filled dots for how many higher timeframes vote each way, with the side that has no votes greyed), a verdict (ALIGNED, BULLISH/BEARISH BIAS, or MIXED), and the plan line.

[b]Multi-Timeframe Panel[/b]
The higher-timeframe rows are selected automatically from the standard timeframe ladder based on the chart timeframe. For example, a 5m chart reads 15m / 30m / 1H; a 1H chart reads 4H / 1D / 1W; a 4H chart reads 1D / 1W / 1M. Near the top of the ladder fewer than three higher timeframes exist, so the panel simply shows fewer rows (a Daily chart shows Weekly and Monthly; a Weekly chart shows Monthly only). A manual mode lets you pin three timeframes of your choice instead. Higher-timeframe values are read with `lookahead=barmerge.lookahead_off` and a one-bar offset, which is the standard non-repainting pattern for higher-timeframe context.

[b]Notes on Repainting[/b]
[list]
[*][b]Historical impulses and corrections[/b] do not repaint. They are built from confirmed pivots (`ta.pivothigh` and `ta.pivotlow` with a right-bars parameter), so once a leg is committed it stays anchored in place.
[*][b]The active forming leg[/b] is explicitly labelled "forming" and updates as new bars print; the reversal zone itself is anchored to the confirmed pivots of the qualified impulse.
[*][b]The setup state is latched.[/b] Once price tags the stop or a target, that resolution is recorded against the setup's anchor and does not revert if price later trades back into the zone. A stopped or completed setup cannot revive itself.
[*][b]Pivot detection has an inherent delay[/b] equal to the right-bars parameter (default 3 bars). A pivot becomes visible only after that many bars close past it. This is a property of all pivot-based indicators, not specific to this script.
[*][b]Multi-timeframe panel data[/b] uses `lookahead=barmerge.lookahead_off` with a one-bar offset, the canonical non-repainting pattern for higher-timeframe context.
[*][b]Alerts[/b] are gated by `barstate.isconfirmed` and fire once per closed bar, never intra-bar.
[/list]

[b]Typical Analysis Workflow[/b]
A common analytical workflow may include:
[list=1]
[*]Reading the panel verdict and plan line to anchor an overall directional view, and noting the conviction (a "low conviction" plan means the bias is real but the higher timeframes are only ranging)
[*]Checking the ALIGN row and the per-timeframe rows to see whether higher timeframes agree or conflict
[*]Waiting for the status chip to read in-zone in the direction of the plan (sell rallies into the zone in a down-bias, buy pullbacks in an up-bias)
[*]Reading the zone label R:R and the TP1 / TP2 / stop levels to frame the trade, then managing it with other forms of analysis and risk management
[*]Treating the deep-retrace flag and the greyed-out (stopped / target-hit) state as structural context that a setup has changed or ended
[/list]

[b]Configuration[/b]
[b]ATR Length[/b] - lookback for the ATR used in the swing filter, channel width, and stop placement.
[b]Swing Filter (ATR)[/b] - the main noise lever. Higher values keep fewer, larger swings; lower values keep more, smaller swings.
[b]Pivot Left Bars / Pivot Right Bars[/b] - the pivot lookback. Right Bars also sets the confirmation delay (a pivot is confirmed this many bars after it forms).
[b]Impulse Strength Min[/b] - the minimum quality score (0-100) a with-trend leg must reach to be drawn as an impulse rather than skeleton.
[b]Channel Width (ATR)[/b] - the half-width of the impulse channels, in ATR.
[b]Visuals[/b] - colors for impulse up/down, correction, entry zone, targets, and stop; toggles for the wave skeleton, entry zone, targets, stop / R:R, and labels.
[b]Multi-Timeframe HUD[/b] - show / hide the panel; Auto (next higher timeframes) versus Manual (three chosen timeframes); the three manual timeframes; and panel position (any corner).

[b]Markets and Timeframes[/b]
The indicator can be applied across multiple markets and timeframes:
[list]
[*]Forex
[*]Stocks and Indices
[*]Commodities
[*]Cryptocurrencies
[/list]
Because the swing filter, channel width, and impulse-size ranking are all ATR-based, the visual behavior stays consistent across instruments and timeframes. The Swing Filter and pivot settings can be tuned per chart for the cleanest read on a given symbol and timeframe.

[b]Alerts[/b]
[list]
[*]Price entered entry zone - fires when price first closes inside the reversal zone
[*]New Swing High - fires when a high pivot is confirmed
[*]New Swing Low - fires when a low pivot is confirmed
[*]All higher TFs bullish - fires when every higher-timeframe row is bullish
[*]All higher TFs bearish - fires when every higher-timeframe row is bearish
[/list]
All alerts evaluate on confirmed bars to avoid intra-bar oscillation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//
// Impulse Waves & Reversal Zones [MQLSoftware]
// ─────────────────────────────────────────────────────────────────────────────
// WHAT IT DOES (read this from the thumbnail in 3 seconds):
//   • TREND      — bold channels, drawn ONLY for qualified impulse legs.
//   • CORRECTION — amber pullback against the trend; the active one is boxed
//                  with its retracement depth vs the impulse it is correcting.
//   • REVERSAL   — the zone where the correction is expected to end and the
//                  trend resume: the 0.382–0.618 retracement of the last impulse,
//                  with live status (wait → in-zone → target / stopped), targets
//                  (TP1/TP2) and a stop (SL + R:R).
//   • MTF HUD    — bias and trend-conviction (ADX) strength across three higher
//                  timeframes, an alignment score, and a plain-language plan that
//                  softens to "low conviction" when the higher TFs are only ranging.
//
// THE MODEL (Adaptive Impulse Engine — the core, not a zigzag wrapper):
//   1. Structure is tracked by a CHoCH state machine with PROTECTED swings:
//      the trend only flips when price breaks the swing low/high that launched
//      the prior impulse — so shallow pullbacks stay classified as corrections
//      instead of constantly flipping the trend (the usual zigzag failure).
//   2. Every leg gets an IMPULSE QUALITY SCORE (0–100) =
//         0.5 · Efficiency Ratio  +  0.5 · Displacement Percentile
//      Efficiency = |net move| / path travelled (how straight the leg is).
//      Displacement Percentile = how large the leg is, in ATR units, ranked
//      against the recent distribution of legs (self-calibrating, no magic numbers).
//   3. A leg becomes an IMPULSE only if it is WITH-TREND and Score ≥ threshold.
//      Counter-trend legs are CORRECTIONS; weak with-trend legs stay as skeleton.
//   The reversal zone & targets use Fibonacci levels of the qualified impulse.
//
// NON-REPAINT NOTE: the latest swing confirms `Pivot Right Bars` after it prints,
// so the most recent structure can refine until then (standard for pivot tools).
// MTF rows are non-repainting (prior-bar higher-TF values).

//@version=6
indicator("Impulse Waves & Reversal Zones [MQLSoftware]", shorttitle="IWRZ", overlay=true, max_lines_count=500, max_labels_count=300, max_boxes_count=100)

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
int   MAX_PIVOTS = 30
float FIB_382    = 0.382
float FIB_500    = 0.500
float FIB_618    = 0.618
float FIB_EXT_1  = 0.272   // 1.272 extension
float FIB_EXT_2  = 0.618   // 1.618 extension
int   HUD_BG     = 8
float EPS        = 1e-9
int   ADX_LEN    = 14      // DI/ADX length for trend-conviction strength
float ADX_FLOOR  = 10.0    // ADX at/below this reads as empty bar
float ADX_CEIL   = 50.0    // ADX at/above this reads as a full bar
float PLAN_STR_FLOOR = 20.0 // aggregate MTF strength below this → PLAN softens to "low conviction" (set 0 to disable)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
var GRP_ALGO = "Adaptive Impulse Engine"
atrLen     = input.int(14,    "ATR Length",            minval=5,   maxval=50,  group=GRP_ALGO)
atrMult    = input.float(0.7, "Swing Filter (ATR)",    minval=0.1, maxval=3.0, step=0.1, group=GRP_ALGO, tooltip="Higher = fewer, larger swings. Main lever for noise.")
pivLeft    = input.int(8,     "Pivot Left Bars",       minval=3,   maxval=30,  group=GRP_ALGO)
pivRight   = input.int(3,     "Pivot Right Bars",      minval=1,   maxval=10,  group=GRP_ALGO)
impThresh  = input.int(55,    "Impulse Strength Min",  minval=0,   maxval=100, group=GRP_ALGO, tooltip="A with-trend leg must score at least this to be drawn as an impulse.")
chanWidth  = input.float(0.4, "Channel Width (ATR)",   minval=0.1, maxval=2.0, step=0.1, group=GRP_ALGO)

var GRP_VIS = "Visuals"
colUp     = input.color(#00E5CC, "Impulse Up",   group=GRP_VIS, inline="i")
colDn     = input.color(#FF3B5C, "Impulse Down", group=GRP_VIS, inline="i")
colRetr   = input.color(#F5A623, "Correction",   group=GRP_VIS, inline="r")
colZone   = input.color(#F5C542, "Entry Zone",   group=GRP_VIS, inline="r")
colTgt    = input.color(#A78BFA, "Targets",      group=GRP_VIS, inline="t")
colSL     = input.color(#E05260, "Stop",         group=GRP_VIS, inline="t")
showSkel    = input.bool(true, "Wave Skeleton", group=GRP_VIS, inline="s1")
showZone    = input.bool(true, "Entry Zone",    group=GRP_VIS, inline="s1")
showTargets = input.bool(true, "Targets",       group=GRP_VIS, inline="s2")
showSL      = input.bool(true, "Stop / R:R",    group=GRP_VIS, inline="s2")
showLabels  = input.bool(true, "Labels",        group=GRP_VIS, inline="s3")
showResolved = input.bool(true, "Keep Resolved Setup", group=GRP_VIS, inline="s4")
showForming = input.bool(true, "Forming Leg", group=GRP_VIS, inline="s5", tooltip="Show the dotted, still-unconfirmed leg and its forming label. Turning this off changes visuals only; confirmed structure, setup state, and alerts are unchanged.")

var GRP_TF = "Multi-Timeframe HUD"
showHud = input.bool(true,        "Show HUD",  group=GRP_TF)
autoTf  = input.bool(true, "Auto: 3 higher TFs", group=GRP_TF, tooltip="On: HUD rows track the next standard timeframes above the chart (e.g. 5m → 15/30/60). Near the top (D, W) it shows fewer rows. Off: use the three manual timeframes below.")
tf1     = input.timeframe("240",  "TF 1 (manual)", group=GRP_TF)
tf2     = input.timeframe("1D",   "TF 2 (manual)", group=GRP_TF)
tf3     = input.timeframe("1W",   "TF 3 (manual)", group=GRP_TF)
hudPos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_TF)

// ─── HELPERS ───────────────────────────────────────────────────────────────
posMap(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>               position.bottom_left

biasCol(int d) => d > 0 ? colUp : d < 0 ? colDn : color.new(#8888AA, 0)
biasTxt(int d) => d > 0 ? "▲ Bull" : d < 0 ? "▼ Bear" : "— Flat"

// Trend conviction → 0..100 bar. ADX (smoothed directional movement) stays high
// through a strong impulse even on a pullback, unlike a path-efficiency ratio
// which collapses to ~0 on V-shaped legs. Same metric on the chart row and every
// MTF row so the HUD speaks one language.
adxStr(float a) => na(a) ? 0.0 : math.min(100.0, math.max(0.0, (a - ADX_FLOOR) / (ADX_CEIL - ADX_FLOOR) * 100.0))

// ADX (trend conviction), computed directly so only the single value is returned —
// avoids ta.dmi's 3-tuple and its two unused elements (keeps the compile log clean).
// Same math as the built-in DMI/ADX with diLength = adxSmoothing = len.
adxVal(int len) =>
    float up      = ta.change(high)
    float down    = -ta.change(low)
    float plusDM  = na(up)   ? 0.0 : (up > down and up > 0 ? up : 0.0)
    float minusDM = na(down) ? 0.0 : (down > up and down > 0 ? down : 0.0)
    float trur    = ta.rma(ta.tr, len)
    float plusRma = ta.rma(plusDM, len)
    float minusRma = ta.rma(minusDM, len)
    float plus    = trur == 0 ? 0.0 : 100.0 * plusRma / trur
    float minus   = trur == 0 ? 0.0 : 100.0 * minusRma / trur
    float sum     = plus + minus
    100.0 * ta.rma(math.abs(plus - minus) / (sum == 0.0 ? 1.0 : sum), len)

// CHoCH state machine + conviction strength — used for every MTF row.
htfState() =>
    var int   t  = 0
    var float lh = na
    var float ll = na
    var float pH = na
    var float pL = na
    float h = ta.pivothigh(high, pivLeft, pivRight)
    float l = ta.pivotlow(low,   pivLeft, pivRight)
    if not na(h)
        if t == 1
            if na(lh) or h > lh
                pL := ll
        else
            float ref = t < 0 ? pH : lh
            if not na(ref) and h > ref
                t  := 1
                pL := ll
        lh := h
    if not na(l)
        if t == -1
            if na(ll) or l < ll
                pH := lh
        else
            float ref2 = t > 0 ? pL : ll
            if not na(ref2) and l < ref2
                t  := -1
                pH := lh
        ll := l
    float a = adxVal(ADX_LEN)
    [t[1], adxStr(a[1])]

// ─── PATH LENGTH (for efficiency ratio) ──────────────────────────────────────
float pathCum = ta.cum(math.abs(nz(close - close[1])))

// ─── ATR + PIVOTS ─────────────────────────────────────────────────────────────
float atr = ta.atr(atrLen)
ph = ta.pivothigh(high, pivLeft, pivRight)
pl = ta.pivotlow(low,   pivLeft, pivRight)

var float[] pvPrice = array.new_float(0)
var int[]   pvBar   = array.new_int(0)
var bool[]  pvHigh  = array.new_bool(0)
var float[] pvCum   = array.new_float(0)
var float[] pvAtr   = array.new_float(0)

int cBar = bar_index - pivRight

pushPivot(float p, bool isHigh) =>
    array.push(pvPrice, p)
    array.push(pvBar,   cBar)
    array.push(pvHigh,  isHigh)
    array.push(pvCum,   pathCum)
    array.push(pvAtr,   atr)

if not na(ph)
    int  li       = array.size(pvPrice) - 1
    bool lastIsHi = array.size(pvHigh) > 0 and array.get(pvHigh, li)
    if not lastIsHi
        if array.size(pvPrice) == 0 or math.abs(ph - array.get(pvPrice, li)) >= atr * atrMult
            pushPivot(ph, true)
    else if ph > array.get(pvPrice, li)
        array.set(pvPrice, li, ph)
        array.set(pvBar,   li, cBar)
        array.set(pvCum,   li, pathCum)

if not na(pl)
    int  li       = array.size(pvPrice) - 1
    bool lastIsLo = array.size(pvHigh) > 0 and not array.get(pvHigh, li)
    if not lastIsLo
        if array.size(pvPrice) == 0 or math.abs(pl - array.get(pvPrice, li)) >= atr * atrMult
            pushPivot(pl, false)
    else if pl < array.get(pvPrice, li)
        array.set(pvPrice, li, pl)
        array.set(pvBar,   li, cBar)
        array.set(pvCum,   li, pathCum)

while array.size(pvPrice) > MAX_PIVOTS
    array.shift(pvPrice)
    array.shift(pvBar)
    array.shift(pvHigh)
    array.shift(pvCum)
    array.shift(pvAtr)

// ─── DRAWING POOLS ───────────────────────────────────────────────────────────
var line[]     allLines  = array.new_line()
var label[]    allLabels = array.new_label()
var box[]      allBoxes  = array.new_box()
var linefill[] allFills  = array.new_linefill()

clearAll() =>
    for l in allLines
        line.delete(l)
    for lb in allLabels
        label.delete(lb)
    for b in allBoxes
        box.delete(b)
    for lf in allFills
        linefill.delete(lf)
    array.clear(allLines)
    array.clear(allLabels)
    array.clear(allBoxes)
    array.clear(allFills)

// ─── PERSISTENT STATE ─────────────────────────────────────────────────────────
var int   curTrend = 0
var float zHi      = na
var float zLo      = na
var int   zoneSide = 0
var float rrVal    = na
var float zT1      = na   // TP1 level (for setup-state tracking)
var float zSL      = na   // stop level (for setup-state tracking)
var int   zState   = 0    // 0 wait · 1 in-zone · 2 target hit · 3 stopped
var int   setupAnchor = -1 // ib2 of the setup whose terminal state is latched (#2)
var int   latchState  = 0  // latched terminal state: 0 none · 2 target · 3 stopped (#2)

// ─── MTF TIMEFRAME SELECTION ──────────────────────────────────────────────────
// Auto mode: pick the next (up to) 3 standard timeframes strictly higher than the
// chart. Near the top (D → W, M) fewer than 3 exist, so the HUD shows fewer rows.
// Manual mode uses the three inputs. NOTE: request.security needs a *simple* string
// timeframe, so this is built from string literals + simple ints (no arrays, which
// would make the value series-qualified and fail to compile).
// Ladder seconds: 5m=300 · 15m=900 · 30m=1800 · 1H=3600 · 4H=14400 · 1D=86400 · 1W=604800 · 1M=2592000
int chartSec0 = timeframe.in_seconds()
string mtf1 = autoTf ? (chartSec0 < 300 ? "5" : chartSec0 < 900 ? "15" : chartSec0 < 1800 ? "30" : chartSec0 < 3600 ? "60" : chartSec0 < 14400 ? "240" : chartSec0 < 86400 ? "1D" : chartSec0 < 604800 ? "1W" : chartSec0 < 2592000 ? "1M" : na) : tf1
string mtf2 = autoTf ? (chartSec0 < 300 ? "15" : chartSec0 < 900 ? "30" : chartSec0 < 1800 ? "60" : chartSec0 < 3600 ? "240" : chartSec0 < 14400 ? "1D" : chartSec0 < 86400 ? "1W" : chartSec0 < 604800 ? "1M" : na) : tf2
string mtf3 = autoTf ? (chartSec0 < 300 ? "30" : chartSec0 < 900 ? "60" : chartSec0 < 1800 ? "240" : chartSec0 < 3600 ? "1D" : chartSec0 < 14400 ? "1W" : chartSec0 < 86400 ? "1M" : na) : tf3

bool ok1 = not na(mtf1)
bool ok2 = not na(mtf2)
bool ok3 = not na(mtf3)
// request.security must run unconditionally with a valid TF — use the chart TF as a
// harmless placeholder for empty slots, then null the result via the ok* flags.
string q1 = ok1 ? mtf1 : timeframe.period
string q2 = ok2 ? mtf2 : timeframe.period
string q3 = ok3 ? mtf3 : timeframe.period

// ─── MTF BIAS (structural, non-repainting) ───────────────────────────────────
[b1r, s1r] = request.security(syminfo.tickerid, q1, htfState(), lookahead=barmerge.lookahead_off)
[b2r, s2r] = request.security(syminfo.tickerid, q2, htfState(), lookahead=barmerge.lookahead_off)
[b3r, s3r] = request.security(syminfo.tickerid, q3, htfState(), lookahead=barmerge.lookahead_off)
int   b1 = ok1 ? b1r : 0
int   b2 = ok2 ? b2r : 0
int   b3 = ok3 ? b3r : 0
float s1 = ok1 ? s1r : 0.0
float s2 = ok2 ? s2r : 0.0
float s3 = ok3 ? s3r : 0.0

int mtfN    = (ok1 ? 1 : 0) + (ok2 ? 1 : 0) + (ok3 ? 1 : 0)
int mtfBull = (b1 > 0 ? 1 : 0) + (b2 > 0 ? 1 : 0) + (b3 > 0 ? 1 : 0)
int mtfBear = (b1 < 0 ? 1 : 0) + (b2 < 0 ? 1 : 0) + (b3 < 0 ? 1 : 0)
int biasDir = mtfBull > mtfBear ? 1 : mtfBear > mtfBull ? -1 : 0   // majority of the valid higher TFs

// Conviction = average ADX strength of the higher TFs that vote for the bias.
// Hoisted here (used by both the chip and the HUD plan).
float biasStrSum = 0.0
int   biasStrN   = 0
if biasDir != 0
    if (biasDir > 0 ? b1 > 0 : b1 < 0)
        biasStrSum += s1
        biasStrN   += 1
    if (biasDir > 0 ? b2 > 0 : b2 < 0)
        biasStrSum += s2
        biasStrN   += 1
    if (biasDir > 0 ? b3 > 0 : b3 < 0)
        biasStrSum += s3
        biasStrN   += 1
float biasStr = biasStrN > 0 ? biasStrSum / biasStrN : 0.0
bool  lowConv = biasDir != 0 and PLAN_STR_FLOOR > 0 and biasStr < PLAN_STR_FLOOR

// Chart strength — same conviction metric (ADX) as the MTF rows (one language).
float chartStr = adxStr(adxVal(ADX_LEN))

// ─── HUD-COLLISION AVOIDANCE ──────────────────────────────────────────────────
// The live chip / zone / projection labels sit at the chart's right edge (current
// bar). A right-corner HUD covers that edge for the vertical band it occupies, so
// when price is in that band the labels render UNDER the table and vanish. We can't
// read pixels in Pine, so approximate the visible price extent over a window and,
// when price is in the same-side HUD band, relocate the affected labels OUT of it:
// the floating chip drops below/above the band; price-anchored level labels move to
// the left end of their own line (keeping their true price). Labels never flip onto
// the candles. ta.highest/lowest are called unconditionally (must not be gated).
int   HUD_WIN  = 150
float winHi    = ta.highest(high, HUD_WIN)
float winLo    = ta.lowest(low,   HUD_WIN)
bool  hudRight = hudPos == "Top Right" or hudPos == "Bottom Right"
bool  hudTop   = hudPos == "Top Right" or hudPos == "Top Left"
float hudFrac  = winHi - winLo > EPS ? (close - winLo) / (winHi - winLo) : 0.5
bool  nearHud  = showHud and hudRight and ((hudTop and hudFrac > 0.62) or (not hudTop and hudFrac < 0.38))

// ─── MAIN DRAW ───────────────────────────────────────────────────────────────
bool newPivot   = not na(ph) or not na(pl)
bool shouldDraw = (newPivot or barstate.islast) and array.size(pvPrice) >= 3

if shouldDraw
    clearAll()
    zoneSide := 0
    zState   := 0
    int   n     = array.size(pvPrice)
    float halfW = atr * chanWidth

    // 1) CHoCH trend with protected swings (per pivot)
    int[]   trendAt = array.new_int(n, 0)
    int     trend = 0
    float   lh = na
    float   ll = na
    float   pH = na
    float   pL = na
    for i = 0 to n - 1
        bool  isH = array.get(pvHigh, i)
        float pr  = array.get(pvPrice, i)
        if isH
            if trend == 1
                if na(lh) or pr > lh
                    pL := ll
            else
                float ref = trend < 0 ? pH : lh
                if not na(ref) and pr > ref
                    trend := 1
                    pL := ll
            lh := pr
        else
            if trend == -1
                if na(ll) or pr < ll
                    pH := lh
            else
                float ref2 = trend > 0 ? pL : ll
                if not na(ref2) and pr < ref2
                    trend := -1
                    pH := lh
            ll := pr
        array.set(trendAt, i, trend)
    curTrend := trend

    // 2) Per-leg Impulse Quality Score (Efficiency + Displacement percentile)
    int     legN  = n - 1
    float[] disp  = array.new_float(0)
    float[] effs  = array.new_float(0)
    for i = 0 to legN - 1
        float p1   = array.get(pvPrice, i)
        float p2   = array.get(pvPrice, i + 1)
        float sz   = math.abs(p2 - p1)
        float aref = math.max((array.get(pvAtr, i) + array.get(pvAtr, i + 1)) / 2.0, EPS)
        array.push(disp, sz / aref)
        float pathLen = array.get(pvCum, i + 1) - array.get(pvCum, i)
        array.push(effs, pathLen > EPS ? math.min(sz / pathLen, 1.0) : 1.0)

    float[] score = array.new_float(0)
    for i = 0 to legN - 1
        int   below = 0
        for j = 0 to legN - 1
            if array.get(disp, j) < array.get(disp, i)
                below += 1
        float pct = legN > 1 ? below / float(legN - 1) : 0.5
        float sc  = 100.0 * (0.5 * array.get(effs, i) + 0.5 * pct)
        array.push(score, math.min(100.0, math.max(0.0, sc)))

    // 3) Classify legs: 1 = impulse, 2 = correction, 0 = weak (skeleton only)
    int[] cls = array.new_int(0)
    for i = 0 to legN - 1
        bool up    = array.get(pvPrice, i + 1) > array.get(pvPrice, i)
        int  trv   = array.get(trendAt, i + 1)
        bool counter = (trv == 1 and not up) or (trv == -1 and up)
        int  c = 0
        if counter
            c := 2
        else if array.get(score, i) >= impThresh
            c := 1
        array.push(cls, c)

    // 4) Last impulse / correction
    int lastImpIdx = -1
    int lastRetIdx = -1
    for i = 0 to legN - 1
        int c = array.get(cls, i)
        if c == 1
            lastImpIdx := i
        else if c == 2
            lastRetIdx := i

    // 5) Dominant trade direction → pick the impulse to trade
    int tradeDir = biasDir != 0 ? biasDir : curTrend
    int tradeImpIdx = -1
    for i = 0 to legN - 1
        if array.get(cls, i) == 1
            bool up2 = array.get(pvPrice, i + 1) > array.get(pvPrice, i)
            if tradeDir == 0 or (tradeDir > 0 and up2) or (tradeDir < 0 and not up2)
                tradeImpIdx := i
    if tradeImpIdx == -1 and tradeDir == 0
        tradeImpIdx := lastImpIdx

    // 6) Skeleton (faint wave backbone for every leg)
    if showSkel
        for i = 0 to legN - 1
            line sk = line.new(array.get(pvBar, i), array.get(pvPrice, i), array.get(pvBar, i + 1), array.get(pvPrice, i + 1), color=color.new(#9090A8, 80), width=1)
            array.push(allLines, sk)

    // 7) Draw impulses & corrections
    for i = 0 to legN - 1
        float p1 = array.get(pvPrice, i)
        float p2 = array.get(pvPrice, i + 1)
        int   bx1 = array.get(pvBar,   i)
        int   bx2 = array.get(pvBar,   i + 1)
        bool  up = p2 > p1
        int   c  = array.get(cls, i)

        if c == 1
            color col   = up ? colUp : colDn
            bool  focus = i == tradeImpIdx
            if focus
                line g1 = line.new(bx1, p1 + halfW * 1.8, bx2, p2 + halfW * 1.8, color=color.new(col, 88), width=1)
                line g2 = line.new(bx1, p1 - halfW * 1.8, bx2, p2 - halfW * 1.8, color=color.new(col, 88), width=1)
                linefill gf = linefill.new(g1, g2, color=color.new(col, 92))
                array.push(allLines, g1)
                array.push(allLines, g2)
                array.push(allFills, gf)
            line midL = line.new(bx1, p1, bx2, p2, color=color.new(col, 0), width=focus ? 4 : 3)
            line upL  = line.new(bx1, p1 + halfW, bx2, p2 + halfW, color=color.new(col, 30), width=1)
            line loL  = line.new(bx1, p1 - halfW, bx2, p2 - halfW, color=color.new(col, 30), width=1)
            linefill ff = linefill.new(upL, loL, color=color.new(col, focus ? 76 : 84))
            array.push(allLines, midL)
            array.push(allLines, upL)
            array.push(allLines, loL)
            array.push(allFills, ff)
            label d = label.new(bx2, p2, "◆", color=color.new(#000000, 100), textcolor=col, style=label.style_none, size=size.small)
            array.push(allLabels, d)
        else if c == 2
            line rl = line.new(bx1, p1, bx2, p2, color=color.new(colRetr, 5), width=2, style=line.style_dashed)
            array.push(allLines, rl)
            label rd = label.new(bx2, p2, "●", color=color.new(#000000, 100), textcolor=color.new(colRetr, 10), style=label.style_none, size=size.tiny)
            array.push(allLabels, rd)

    // 8) Entry zone + targets + stop, anchored to the dominant-direction impulse
    if tradeImpIdx >= 0
        float ip1  = array.get(pvPrice, tradeImpIdx)
        float ip2  = array.get(pvPrice, tradeImpIdx + 1)
        int   ib2  = array.get(pvBar,   tradeImpIdx + 1)
        bool  iUp  = ip2 > ip1
        float rng  = math.abs(ip2 - ip1)
        int   extR = bar_index + 8
        float z382 = iUp ? ip2 - rng * FIB_382 : ip2 + rng * FIB_382
        float z500 = iUp ? ip2 - rng * FIB_500 : ip2 + rng * FIB_500
        float z618 = iUp ? ip2 - rng * FIB_618 : ip2 + rng * FIB_618
        float t1   = iUp ? ip2 + rng * FIB_EXT_1 : ip2 - rng * FIB_EXT_1
        float t2   = iUp ? ip2 + rng * FIB_EXT_2 : ip2 - rng * FIB_EXT_2
        float sl   = iUp ? ip1 - atr * 0.2 : ip1 + atr * 0.2

        zoneSide  := iUp ? 1 : -1
        zHi       := math.max(z382, z618)
        zLo       := math.min(z382, z618)
        zT1       := t1
        zSL       := sl
        float risk = math.abs(z500 - sl)
        rrVal := risk > EPS ? math.abs(z500 - t1) / risk : na

        // Setup state. Terminal states (stopped / target hit) LATCH to the setup's
        // anchor (ib2): once the stop or target is tagged, the setup stays resolved
        // even if price wanders back into the zone. The latch clears only when a new
        // setup is anchored (anchor change below) — a blown stop can't "revive".
        if setupAnchor != ib2
            setupAnchor := ib2
            latchState  := 0
        bool hitSL  = iUp ? low <= sl : high >= sl
        bool hitTP  = iUp ? high >= t1 : low <= t1
        if latchState == 0
            latchState := hitSL ? 3 : hitTP ? 2 : 0
        bool inZn   = close <= zHi and close >= zLo
        zState := latchState != 0 ? latchState : (inZn ? 1 : 0)
        bool stale  = zState >= 2   // setup resolved — mute it visually
        bool renderSetup = not stale or showResolved

        if showZone and renderSetup
            int zFade = stale ? 92 : 78
            box bx = box.new(ib2, zHi, extR, zLo, border_color=color.new(stale ? #6A6A80 : colZone, stale ? 60 : 35), bgcolor=color.new(stale ? #6A6A80 : colZone, zFade), border_width=1)
            line ml = line.new(ib2, z500, extR, z500, color=color.new(stale ? #6A6A80 : colZone, stale ? 60 : 10), width=1, style=line.style_dotted)
            array.push(allBoxes, bx)
            array.push(allLines, ml)
            if showLabels and not stale
                string side = iUp ? "BUY" : "SELL"
                string rr   = na(rrVal) ? "" : "  ·  R:R " + str.tostring(rrVal, "#.#")
                label zl = label.new(nearHud ? ib2 + 1 : math.round((ib2 + extR) / 2), zHi, "⬡ " + side + " ZONE 0.382–0.618" + rr, color=color.new(colZone, 5), textcolor=#1A1200, style=label.style_label_down, size=size.small)
                array.push(allLabels, zl)

        int rightX = bar_index + 30

        if showTargets and renderSetup
            int tFade = stale ? 70 : 25
            line tl1 = line.new(ib2, t1, rightX, t1, color=color.new(stale ? #6A6A80 : colTgt, tFade), width=1, style=line.style_dashed)
            line tl2 = line.new(ib2, t2, rightX, t2, color=color.new(stale ? #6A6A80 : colTgt, stale ? 70 : 5),  width=2, style=line.style_dashed)
            array.push(allLines, tl1)
            array.push(allLines, tl2)
            if showLabels and not stale
                int projX = nearHud ? ib2 : rightX
                label ll1 = label.new(projX, t1, "  TP1  ×1.272  ", color=color.new(colTgt, 12), textcolor=color.white, style=label.style_label_left, size=size.small)
                label ll2 = label.new(projX, t2, "  TP2  ×1.618  ", color=color.new(colTgt, 5),  textcolor=color.white, style=label.style_label_left, size=size.small)
                array.push(allLabels, ll1)
                array.push(allLabels, ll2)

        if showSL and renderSetup
            line sll = line.new(ib2, sl, rightX, sl, color=color.new(colSL, stale ? 70 : 0), width=2, style=line.style_dashed)
            array.push(allLines, sll)
            if showLabels and not stale
                label slb = label.new(nearHud ? ib2 : rightX, sl, "  ✕ STOP  ", color=color.new(colSL, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
                array.push(allLabels, slb)

    // 8b) Correction depth box — drawn AFTER the setup state is known so it can be
    // muted once the active setup is resolved (#3): avoids a stale "% of impulse"
    // reading sitting next to a STOPPED/TARGET chip that belongs to a different leg.
    if showLabels and lastRetIdx >= 0 and zState < 2
        int   rbi1 = array.get(pvBar,   lastRetIdx)
        int   rbi2 = array.get(pvBar,   lastRetIdx + 1)
        float rp1  = array.get(pvPrice, lastRetIdx)
        float rp2  = array.get(pvPrice, lastRetIdx + 1)
        float rhi  = math.max(rp1, rp2)
        float rlo  = math.min(rp1, rp2)
        box rb = box.new(rbi1, rhi, rbi2, rlo, border_color=color.new(colRetr, 30), bgcolor=color.new(colRetr, 100), border_width=1, border_style=line.style_dashed)
        array.push(allBoxes, rb)
        int impJ = -1
        if lastRetIdx > 0
            for k = 0 to lastRetIdx - 1
                if array.get(cls, k) == 1
                    impJ := k
        float impSz = impJ >= 0 ? math.abs(array.get(pvPrice, impJ + 1) - array.get(pvPrice, impJ)) : na
        float dep   = not na(impSz) and impSz > 0 ? math.abs(rp2 - rp1) / impSz * 100.0 : na
        // #1: a retrace > 100% has overrun the impulse — that's a structure break,
        // not a correction. Relabel instead of printing a broken "122% of impulse".
        string dtxt = na(dep) ? "↩ CORRECTION" : dep > 100.0 ? "⚠ DEEP RETRACE — structure break" : "↩ CORRECTION  " + str.tostring(dep, "#") + "% of impulse"
        label rdl = label.new(math.round((rbi1 + rbi2) / 2), rlo, dtxt, color=color.new(colRetr, 5), textcolor=#1A1200, style=label.style_label_up, size=size.small)
        array.push(allLabels, rdl)

    // 9) Status chip — reads the live setup state, not just in/out of zone
    if barstate.islast and showLabels
        bool   actionable = zoneSide != 0 and zState < 2          // wait / in-zone
        string sideTxt = zoneSide > 0 ? "BUY" : "SELL"
        string baseTxt = zoneSide == 0 ? "→ Trend — no setup" : zState == 3 ? "✕ STOPPED — setup void" : zState == 2 ? "✓ TARGET HIT — done" : zState == 1 ? "● IN " + sideTxt + " ZONE" : "○ WAIT FOR " + sideTxt + " ZONE"
        // #2: if HTF conviction is weak, the active setup and the "low conviction"
        //     plan would otherwise contradict each other — flag it on the chip too.
        string chipTxt = baseTxt + (actionable and lowConv ? "  · low conf" : "")
        color  chipCol = zoneSide == 0 ? color.new(#8888AA, 0) : zState == 3 ? colSL : zState == 2 ? colTgt : actionable and lowConv ? color.new(#8888AA, 0) : zState == 1 ? colZone : (zoneSide > 0 ? colUp : colDn)
        // Keep the chip to the RIGHT of price (into empty space) so it can never
        // cover candles. If price sits inside a same-side HUD's vertical band, drop
        // the chip below (top HUD) / above (bottom HUD) that band — a vertical clash
        // gets a vertical fix. #1: the drop is bounded to a few ATR so the chip stays
        // near the bar instead of running to mid-screen on wide-range windows.
        bool  zoneLabelUp = zoneSide != 0 and zState < 2
        int   chipX       = zoneLabelUp ? bar_index + 10 : bar_index + 4
        float bandDrop    = math.min(math.max((winHi - winLo) * 0.22, atr * 5.0), atr * 14.0)
        float chipY       = nearHud ? (hudTop ? close - bandDrop : close + bandDrop) : close
        label chip = label.new(chipX, chipY, chipTxt, color=color.new(chipCol, 10), textcolor=#0A0A0A, style=label.style_label_left, size=size.small)
        array.push(allLabels, chip)

// ─── PER-BAR SETUP-STATE LATCH ────────────────────────────────────────────────
// shouldDraw only re-evaluates on new pivots and the live bar, so a stop or target
// tagged on an in-between bar would otherwise be missed. Accumulate the terminal
// latch on EVERY bar against the persisted setup levels; cleared only on a new
// anchor (inside the draw block) or when no setup is active.
if zoneSide != 0 and not na(zSL) and not na(zT1)
    if latchState == 0
        bool bSL = zoneSide > 0 ? low <= zSL : high >= zSL
        bool bTP = zoneSide > 0 ? high >= zT1 : low <= zT1
        latchState := bSL ? 3 : bTP ? 2 : 0
else
    latchState := 0

// ─── LIVE / FORMING LEG ──────────────────────────────────────────────────────
var line  liveLine  = na
var label liveLabel = na
line.delete(liveLine)
label.delete(liveLabel)
if showForming and array.size(pvPrice) > 0
    float lp = array.get(pvPrice, array.size(pvPrice) - 1)
    int   lb = array.get(pvBar,   array.size(pvBar) - 1)
    color lc = close > lp ? colUp : colDn
    liveLine := line.new(lb, lp, bar_index, close, color=color.new(lc, 45), width=1, style=line.style_dotted)
    if barstate.islast and showLabels
        liveLabel := label.new(math.round((lb + bar_index) / 2), (lp + close) / 2.0, "◌ forming", color=color.new(#000000, 100), textcolor=color.new(lc, 18), style=label.style_label_center, size=size.tiny)

// ─── HUD ─────────────────────────────────────────────────────────────────────
var table hud = table.new(posMap(hudPos), 3, 9, bgcolor=color.new(#0B0B18, HUD_BG), frame_width=1, frame_color=color.new(#2C2C52, 25), border_width=0)

strBar(float v) =>
    int f = na(v) ? 0 : int(math.round(math.min(100.0, math.max(0.0, v)) / 20.0))
    string s = ""
    for k = 1 to 5
        s := s + (k <= f ? "▰" : "▱")
    s

if showHud and barstate.islast
    color cBase  = color.new(#0B0B18, HUD_BG)
    color cZebra = color.new(#15152E, HUD_BG)
    color cHead  = color.new(#14142C, 0)
    color cTitle = color.new(#21214A, 0)
    color tHead  = #6E6E9A
    color tTf    = #B8B8DA

    string verdict = mtfN == 0 ? "NO HIGHER TF" : mtfBull == mtfN ? "ALIGNED ▲ LONGS" : mtfBear == mtfN ? "ALIGNED ▼ SHORTS" : mtfBull > mtfBear ? "▲ BULLISH BIAS" : mtfBear > mtfBull ? "▼ BEARISH BIAS" : "MIXED — NO EDGE"
    color  vCol    = biasDir > 0 ? colUp : biasDir < 0 ? colDn : color.new(#8888AA, 0)
    string chartTf = timeframe.period
    string bullDots = ""
    string bearDots = ""
    for k = 1 to math.max(mtfN, 1)
        bullDots := bullDots + (k <= mtfBull ? "●" : "○")
        bearDots := bearDots + (k <= mtfBear ? "●" : "○")
    string plan = biasDir == 0 ? "↳ PLAN:  stand aside" : lowConv ? "↳ PLAN:  low conviction — wait" : biasDir > 0 ? "↳ PLAN:  BUY pullbacks" : "↳ PLAN:  SELL rallies"

    table.cell(hud, 0, 0, "◆  MULTI-TF STRUCTURE", text_color=#D8D8FF, text_size=size.small, bgcolor=cTitle, text_halign=text.align_left)
    table.cell(hud, 1, 0, "", bgcolor=cTitle)
    table.cell(hud, 2, 0, "", bgcolor=cTitle)

    table.cell(hud, 0, 1, " TF",        text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_left)
    table.cell(hud, 1, 1, "BIAS",       text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
    table.cell(hud, 2, 1, "STRENGTH ",  text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)

    // Build display rows: chart row first, then each valid higher-TF row. In manual
    // mode a row equal to the chart TF is skipped (prevents a duplicate "240" row).
    string[] rLbl = array.new_string()
    int[]    rBia = array.new_int()
    float[]  rStr = array.new_float()
    int chartSec = timeframe.in_seconds(chartTf)
    array.push(rLbl, chartTf), array.push(rBia, curTrend), array.push(rStr, chartStr)
    if ok1 and timeframe.in_seconds(q1) != chartSec
        array.push(rLbl, mtf1), array.push(rBia, b1), array.push(rStr, s1)
    if ok2 and timeframe.in_seconds(q2) != chartSec
        array.push(rLbl, mtf2), array.push(rBia, b2), array.push(rStr, s2)
    if ok3 and timeframe.in_seconds(q3) != chartSec
        array.push(rLbl, mtf3), array.push(rBia, b3), array.push(rStr, s3)

    int nRows = array.size(rLbl)
    for i = 0 to nRows - 1
        int    rowY = i + 2
        int    bv   = array.get(rBia, i)
        color  rowB = i % 2 == 0 ? cBase : cZebra
        bool   isChart  = i == 0
        bool   counter  = isChart and biasDir != 0 and bv * biasDir < 0
        string mark     = isChart ? (counter ? "  ▸ pullback" : "  ▸") : ""
        table.cell(hud, 0, rowY, " " + array.get(rLbl, i) + mark, text_color=counter ? colRetr : tTf, text_size=size.small, bgcolor=rowB, text_halign=text.align_left)
        table.cell(hud, 1, rowY, " " + biasTxt(bv) + " ", text_color=#FFFFFF, text_size=size.small, bgcolor=color.new(biasCol(bv), 45), text_halign=text.align_center)
        table.cell(hud, 2, rowY, strBar(array.get(rStr, i)) + " ", text_color=biasCol(bv), text_size=size.small, bgcolor=rowB, text_halign=text.align_center)

    int alignY = nRows + 2
    color dimMk = color.new(#55556E, 0)   // muted marker when a side has no votes
    table.cell(hud, 0, alignY, " ALIGN", text_color=tHead, text_size=size.small, bgcolor=cHead, text_halign=text.align_left)
    table.cell(hud, 1, alignY, bullDots + " ▲", text_color=mtfBull > 0 ? colUp : dimMk, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
    table.cell(hud, 2, alignY, bearDots + " ▼", text_color=mtfBear > 0 ? colDn : dimMk, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)

    int vY = alignY + 1
    table.cell(hud, 0, vY, "  " + verdict + "  ", text_color=#0A0A0A, text_size=size.small, bgcolor=vCol, text_halign=text.align_center)
    table.cell(hud, 1, vY, "", bgcolor=vCol)
    table.cell(hud, 2, vY, "", bgcolor=vCol)

    int pY = vY + 1
    table.cell(hud, 0, pY, " " + plan + " ", text_color=tTf, text_size=size.small, bgcolor=cHead, text_halign=text.align_left)
    table.cell(hud, 1, pY, "", bgcolor=cHead)
    table.cell(hud, 2, pY, "", bgcolor=cHead)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
bool priceInZone = zoneSide != 0 and not na(zHi) and close <= zHi and close >= zLo
alertcondition(barstate.isconfirmed and priceInZone and not priceInZone[1], "Price entered entry zone", "IWRZ: price entered the entry zone")
alertcondition(barstate.isconfirmed and not na(ph), "New Swing High", "IWRZ: swing high confirmed")
alertcondition(barstate.isconfirmed and not na(pl), "New Swing Low",  "IWRZ: swing low confirmed")
alertcondition(barstate.isconfirmed and mtfN > 0 and mtfBull == mtfN, "All higher TFs bullish", "IWRZ: all higher timeframes bullish")
alertcondition(barstate.isconfirmed and mtfN > 0 and mtfBear == mtfN, "All higher TFs bearish", "IWRZ: all higher timeframes bearish")
````
