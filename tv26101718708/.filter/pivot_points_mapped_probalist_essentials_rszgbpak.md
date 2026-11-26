# Pivot Points Mapped [Probalist Essentials]

- url: https://www.tradingview.com/script/rSZgBpAK-Pivot-Points-Mapped-Probalist-Essentials/
- type: indicator
- pine_id: PUB;d1d0fe0be8034d8f825444f28ee8cf2a
- version: 1.0

## Description

Pivot Points Mapped turns the standard pivot grid into a measured one. Pick your formula (Classic, Fibonacci, Camarilla, Woodie) and the grid timeframe follows your chart (intraday→Daily, daily→Weekly, weekly→Monthly). Every level is labelled with its empirical reach rate on this chart — R1 at 68% is a real target, R3 at 9% is a long shot — and weighted by reach, proximity and higher-TF confluence, so the chart shows a few meaningful zones instead of seven equal lines.

🟡 WHY THIS VERSION

Most pivot tools draw the same lines on every chart without telling you which ones price ever reaches. This one counts it: reach rate per level, hold rate per touch with a Wilson lower bound, first-touch decay, and ✦ when the higher timeframe's grid agrees — all measured on the loaded chart. The CPR band adds the classic narrow-means-trend tell as a percentile of this chart's own history. Alerts have history-backed variants that only fire when the evidence clears the bar. It counts instead of guessing.

🟡 HOW IT WORKS

Levels come from the prior period's confirmed HLC (no lookahead) in the formula you pick; the same formula builds the higher-TF set, so confluence compares like with like. Each live period, per-level booleans track whether price tagged each level; at period close they roll into the reach history. Touch-reactions are judged on the bar after a zone entry — hold or break — and feed per-level hold arrays with Wilson lower bounds. First-touch decay splits the hold rate by 1st/2nd/3rd test of the period. Visual weight (width, brightness, glow) blends reach × proximity × confluence. The CPR band (BC to TC) is washed behind the levels; its width is ranked against this chart's recent periods — narrow percentiles classically precede trending periods. A corner table shows the state, the bull/bear reach-hold stats, a plain-language Read, and an edge clock stamping the last history-backed bounce/rejection.

🟡 KEY FEATURES
[list]
[*]Reach Map: every level labelled with its empirical reach rate — e.g. 'R1 68% ✓'
[*]Four pivot methods (Classic / Fibonacci / Camarilla / Woodie), one selector — the stats work for all
[*]Auto grid timeframe: intraday→D, daily→W, weekly→M, with manual override; stats count per period
[*]CPR band with width-percentile read (narrow/mid/wide vs this chart's own history)
[*]Hold rate per level with Wilson lower bound + first-touch decay (1st/2nd/3rd test) in tooltips
[*]✦ confluence: levels aligned with the grid one rung up, same formula, weighted brighter
[*]Self-decluttering: far/low-reach levels fade, high-evidence levels glow
[*]Corner stats table + edge clock (last history-backed bounce/rejection)
[*]Touch-reaction dots with density control (All / Medium+ / Backed)
[*]Evidence-gated alert variants; everything non-repainting (confirmed prior-period data)
[/list]

🟡 HOW TO USE
[list]
[*]Read the reach % first: 70%+ is a credible target, <15% a stretch. Set targets by evidence, not formula.
[*]✦ levels are where two timeframes agree — treat them as the higher-conviction zones.
[*]✓ = already tagged this period; focus shifts to the next untagged level in the direction of travel.
[*]Hover a level for hold rate, Wilson lower bound and first-touch decay — a level that holds its 1st test but folds on the 3rd is for first-touch fades only.
[*]CPR narrow (low percentile) classically precedes trending periods — favour breakout targets; wide favours fades. The percentile is measured, the interpretation is theory.
[*]Use the history-backed alerts for signals worth acting on; standard alerts for awareness.
[*]Costs honesty: median touch-reactions on low timeframes are small — check hold rate and n against your round-trip costs. This tool filters levels, not entries.
[/list]

🟡 PAIRS WELL WITH

Pair with a trend or momentum read (MA slope, MACD) to know which side of P has the directional edge — pivots are neutral by formula. Volume profile confirms whether a pivot sits at a real high-volume node. For intraday, an opening-range tool tells you the likely direction into the day's levels. Pivots are reference structure, not entries.

Not seven equal lines but a measured terrain: the most-reached levels stand out, confluence is computed instead of eyeballed, and every reaction has a counted history. Evidence from this chart only — description, not prediction.

[i]Open source under MPL-2.0. The probability layer describes past signals on your chart — it is a measurement, not a prediction, and nothing here is financial advice.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// ██████╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗████████╗
// ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██║██╔════╝╚══██╔══╝
// ██████╔╝██████╔╝██║   ██║██████╔╝███████║██║     ██║███████╗   ██║
// ██╔═══╝ ██╔══██╗██║   ██║██╔══██╗██╔══██║██║     ██║╚════██║   ██║
// ██║     ██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║███████║   ██║
// ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝

// What it shows: Pivot points (Classic / Fibonacci / Camarilla / Woodie, on an auto or manual D/W/M grid)
//         weighted by empirical reach-rate and higher-TF confluence, plus the CPR band with a width-percentile read.
// Method: Prior-period HLC pivots via request.security; per-period reach rates from rolling history;
//         touch-reaction hold/break tracking with Wilson lower bounds; optional period-travel projection cone.
// How to use:
//   • Bold/bright levels = high reach-rate or confluence — the ones that actually matter.
//   • ✦ = this level aligns with a higher-TF pivot (multi-TF agreement).
//   • ✓ = already tagged this session — remaining un-checked levels are the live targets.
//   • Hover any level label to see full reach%, hold%, touch-count decay.
//   • Optional projection cone = how far price typically travels from P per session (16–84th %).

//@version=6
indicator("Pivot Points Mapped [Probalist Essentials]", shorttitle="PP [P]", overlay=true, max_lines_count=200, max_labels_count=500, max_boxes_count=300)

// ─────────────────────────────────────────────
// § INPUTS
// ─────────────────────────────────────────────
GRP_CALC  = "■ Calculation"
GRP_CONF  = "■ Confluence"
GRP_PROB  = "■ Probability Read"
GRP_THEME = "■ Probalist Theme"
GRP_ALERT = "■ Alerts"
GRP_HTF   = "■ Higher Timeframe"

i_method     = input.string("Classic", "Pivot method",     options=["Classic","Fibonacci","Camarilla","Woodie"], group=GRP_CALC, tooltip="The pivot formula. Classic = floor-trader (H+L+C)/3 levels. Fibonacci = P ± 0.382/0.618/1.0 of the range. Camarilla = close ± 1.1/12, 1.1/6, 1.1/4 of the range (tight intraday reversal levels). Woodie = close-weighted pivot (H+L+2C)/4. The reach-map statistics work identically for every method — pick the grid you trade, the evidence layer follows.", display=display.none)
i_pivAuto    = input.bool(true,  "Auto pivot timeframe",   group=GRP_CALC, tooltip="ON: the pivot grid derives from the chart — intraday charts get DAILY pivots, daily charts get WEEKLY, weekly charts get MONTHLY. OFF: use the manual timeframe below.", display=display.none)
i_pivTf      = input.timeframe("D", "Pivot timeframe (manual)", group=GRP_CALC, tooltip="Used only when Auto is OFF. The session the pivots are computed from (D / W / M). All reach and hold statistics count per pivot period.", display=display.none)
i_cprOn      = input.bool(true,  "Show CPR band (TC/BC)",  group=GRP_CALC, tooltip="Central Pivot Range: the band between BC=(H+L)/2 and TC=2P−BC around the pivot. Its WIDTH is the classic read — a narrow CPR often precedes a trending session, a wide one a rotational session. The label shows where today's width sits in this chart's own history (percentile), not a prediction.", display=display.none)
i_showS3R3   = input.bool(true,  "Show S3 / R3",           group=GRP_CALC, tooltip="Include the outermost support/resistance levels. On most sessions they are rarely reached — turning them off declutters the chart.", display=display.none)
i_hideFarPct = input.float(4.0,  "Hide levels further than % from price", group=GRP_CALC, minval=0.5, maxval=20.0, step=0.5, tooltip="Levels beyond this % distance from current close are drawn faint and suppressed from the main visual. Keeps the chart focused on actionable zones.", display=display.none)
i_reachN     = input.int(20,     "Reach history (sessions)", group=GRP_CALC, minval=5, maxval=100, tooltip="Number of completed sessions used to compute reach-rate. More sessions = more stable estimate; fewer = more recent.", display=display.none)
i_touchDecay = input.bool(true,  "Show first-touch decay",  group=GRP_CALC, tooltip="Track 1st / 2nd / 3rd touch hold-rate per level within a session. Shows in level tooltips. Markets tend to break through on repeated tests.", display=display.none)

i_confTol    = input.float(0.35, "Confluence tolerance (× ATR)", group=GRP_CONF, minval=0.1, maxval=2.0, step=0.05, tooltip="How close (in ATR units) a higher-TF pivot must be to a chart-TF level to count as confluence. Tighter = stricter agreement.", display=display.none)
i_confAuto   = input.bool(true,  "Auto-derive confluence TF", group=GRP_CONF, tooltip="Automatically selects the rung above the PIVOT timeframe (D-grid checks the W-pivots, W-grid checks M). On a Monthly grid there is no higher rung — confluence disables. Turn off to set it manually.", display=display.none)
i_confManual = input.timeframe("D", "Confluence TF (manual)", group=GRP_CONF, tooltip="Used only when Auto-derive is OFF. Pick the higher timeframe whose pivots must line up for a level to count as confluence.", display=display.none)

i_probOn     = input.bool(true,  "Probability Read (master)", group=GRP_PROB, tooltip="Master switch: enables reach-rate counting, touch-reaction tracking, the projection cone, and the stats readout. Turn off for a lean overlay with just the levels.", display=display.none)
i_probCone   = input.bool(false,  "↳ Projection Cone",        group=GRP_PROB, tooltip="Draw a shaded cone from P showing the 16th–84th percentile of session travel distances.", display=display.none)
i_probRead   = input.bool(true,  "↳ Readout panel",          group=GRP_PROB, tooltip="Compact stats table (current pivot state, reach stats, hold stats, and the evidence Read) pinned to a chart corner.", display=display.none)
i_readPos    = input.string("Top right", "↳ Readout corner", options=["Top right","Top left","Bottom right","Bottom left","Middle right"], group=GRP_PROB, tooltip="Which chart corner the readout table is pinned to. Pixel-anchored — never overlaps the price levels.", display=display.none)
i_sigDensity = input.string("Medium+", "↳ Signal density", options=["All","Medium+","Backed"], group=GRP_PROB, tooltip="How many touch-reaction dots to plot. All = every confirmed touch; Medium+ = only the stronger reactions (hold-rate ≥55%, the large/huge tiers); Backed = only touches whose history clears the Wilson 50% bar (the high-conviction ones).", display=display.none)
i_minSamp    = input.int(10,     "Min samples to show stats", group=GRP_PROB, minval=3, maxval=50, tooltip="Minimum completed-session samples before showing reach-rate percentages. Below this prints 'gathering'.", display=display.none)
i_wilsonZ    = input.string("80%", "Evidence strictness (Wilson)", options=["80%","90%","95%"], group=GRP_PROB, tooltip="Confidence level for the Wilson-score lower bound used to decide if hold-rate is 'backed'. Higher = stricter evidence required.", display=display.none)

i_glow       = input.bool(true,  "Glow effect",             group=GRP_THEME, tooltip="Layered neon halo around high-weight levels, and band fill between price and P. Off = clean line-only mode.", display=display.none)
i_waveStyle  = input.string("Block to pivot", "Heat wave style", options=["Block to pivot","Ribbon"], group=GRP_THEME, tooltip="Block to pivot = fill the whole price↔P gap — a per-session band that steps with the daily pivot. Ribbon = a heat band in the gap between price and a short EMA (organic AVWAP-style wave). Both coloured by where price sits on the pivot ladder.", display=display.none)
i_ribSmooth  = input.int(8,      "↳ Ribbon smoothing (EMA)", minval=2, maxval=50, group=GRP_THEME, tooltip="Length of the EMA the ribbon fills to (Ribbon style only). Longer = a wider, wavier band that sits clear of the candles; shorter = tighter to price.", display=display.none)
i_col_hot    = input.color(color.rgb(253,186,116),  "Wave hot (bullish end)",  group=GRP_THEME, tooltip="Heat colour for price well above P. Light amber so the wave stays airy, not a dark block.", display=display.none)
i_col_cold   = input.color(color.rgb(125,185,250),  "Wave cold (bearish end)", group=GRP_THEME, tooltip="Heat colour for price well below P. Light sky-blue so the wave stays airy, not a dark block.", display=display.none)
i_dist_gold  = input.color(color.rgb(224,168,0),   "Gold accent (bullish)",   group=GRP_THEME, tooltip="Colour for bullish accents: resistance-side labels, bullish dots, distribution warm end.", display=display.none)
i_dist_cold  = input.color(color.rgb(50,160,255),  "Blue accent (bearish)",   group=GRP_THEME, tooltip="Colour for bearish accents: support-side labels, bearish dots, distribution cool end.", display=display.none)

i_htfOn      = input.bool(false, "Show HTF pivot readout",  group=GRP_HTF, tooltip="Display an additional faint line for the HTF central pivot (P only) as context. Display-only — does not gate or score the signals.", display=display.none)


// ─────────────────────────────────────────────
// § PROBALIST HEAT
// ─────────────────────────────────────────────
normScore(float score) =>
    (math.max(-100.0, math.min(100.0, score)) + 100.0) / 200.0

heatCol(float pos, float transp, color col_hot, color col_cold) =>
    color col = na
    if pos >= 0.80
        col := color.from_gradient(pos, 0.80, 1.0, color.rgb(245,158,11), col_hot)
    else if pos >= 0.62
        col := color.from_gradient(pos, 0.62, 0.80, color.rgb(251,191,36), color.rgb(245,158,11))
    else if pos >= 0.50
        col := color.from_gradient(pos, 0.50, 0.62, color.rgb(167,243,208), color.rgb(251,191,36))
    else if pos >= 0.40
        col := color.from_gradient(pos, 0.40, 0.50, color.rgb(56,189,248), color.rgb(167,243,208))
    else if pos >= 0.22
        col := color.from_gradient(pos, 0.22, 0.40, color.rgb(103,232,249), color.rgb(56,189,248))
    else
        col := color.from_gradient(pos, 0.0, 0.22, col_cold, color.rgb(103,232,249))
    color.new(col, transp)

// ─────────────────────────────────────────────
// § TIMEFRAME HELPERS
// ─────────────────────────────────────────────
chartSec = timeframe.in_seconds(timeframe.period)

// Confluence TF: one rung up
// Pivot grid timeframe: auto = the rung above the chart that pivot traders actually use
// (intraday → Daily pivots, daily → Weekly, weekly → Monthly), else the manual picker.
pivTf = i_pivAuto ? (chartSec < 86400 ? "D" : chartSec < 604800 ? "W" : "M") : i_pivTf
pivSec = timeframe.in_seconds(pivTf)

// Confluence / HTF-display ladder sits ONE rung above the PIVOT timeframe (not the chart):
// D-grid checks the W-pivots, W-grid checks M. At the M-grid there is no higher rung — confluence disables.
effConfTf = pivSec < 604800 ? "W" : "M"
confTf = i_confAuto ? effConfTf : i_confManual
bool confUsable = timeframe.in_seconds(confTf) > pivSec
effHtfTf = effConfTf

// ─────────────────────────────────────────────
// § PIVOT CALCULATION
// ─────────────────────────────────────────────
// Method switch: one helper computes the full level set from a period's HLC — used for BOTH the
// chart grid and the confluence set, so ✦ always compares like with like.
pivotSet(float h_, float l_, float c_) =>
    float rng = h_ - l_
    float p_  = i_method == "Woodie" ? (h_ + l_ + 2.0*c_) / 4.0 : (h_ + l_ + c_) / 3.0
    float r1_ = na
    float s1_ = na
    float r2_ = na
    float s2_ = na
    float r3_ = na
    float s3_ = na
    if i_method == "Fibonacci"
        r1_ := p_ + 0.382 * rng
        s1_ := p_ - 0.382 * rng
        r2_ := p_ + 0.618 * rng
        s2_ := p_ - 0.618 * rng
        r3_ := p_ + 1.000 * rng
        s3_ := p_ - 1.000 * rng
    else if i_method == "Camarilla"
        r1_ := c_ + rng * 1.1 / 12.0
        s1_ := c_ - rng * 1.1 / 12.0
        r2_ := c_ + rng * 1.1 / 6.0
        s2_ := c_ - rng * 1.1 / 6.0
        r3_ := c_ + rng * 1.1 / 4.0
        s3_ := c_ - rng * 1.1 / 4.0
    else
        // Classic and Woodie share the level shape — only the pivot differs
        r1_ := 2.0*p_ - l_
        s1_ := 2.0*p_ - h_
        r2_ := p_ + rng
        s2_ := p_ - rng
        r3_ := h_ + 2.0*(p_ - l_)
        s3_ := l_ - 2.0*(h_ - p_)
    [p_, r1_, s1_, r2_, s2_, r3_, s3_]

// Request prior-period confirmed HLC (lookahead OFF — uses [1] confirmed close)
[dH, dL, dC] = request.security(syminfo.tickerid, pivTf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)
[pP, pR1, pS1, pR2, pS2, pR3, pS3] = pivotSet(dH, dL, dC)

// CPR band (always classic geometry: BC = (H+L)/2, TC mirrored around the classic P)
float cprP  = (dH + dL + dC) / 3.0
float cprBC = (dH + dL) / 2.0
float cprTC = 2.0 * cprP - cprBC

// Confluence TF pivots (confirmed prior bar, no lookahead) — same method via pivotSet
[cH, cL, cC] = request.security(syminfo.tickerid, confTf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_off)
[cP, cR1, cS1, cR2, cS2, cR3, cS3] = pivotSet(cH, cL, cC)

// HTF display pivot
float hP = cP

// ATR for scaling
float atrVal = nz(ta.atr(14), 0.001)
// Hoisted global range (ta.* must run at global scope, never inside islast/if blocks → na coords)
float rngHi50 = ta.highest(50)
float rngLo50 = ta.lowest(50)

// ─────────────────────────────────────────────
// § SESSION TRACKING
// ─────────────────────────────────────────────
bool newSession = ta.change(time(pivTf)) != 0
var int sessStartBar = na
if newSession
    sessStartBar := bar_index

// Per-level "was it tagged this session" flags
var bool tagP  = false
var bool tagR1 = false
var bool tagR2 = false
var bool tagR3 = false
var bool tagS1 = false
var bool tagS2 = false
var bool tagS3 = false

// Reach-rate rolling arrays (one bool per completed session)
var array<float> reachP  = array.new<float>(0)
var array<float> reachR1 = array.new<float>(0)
var array<float> reachR2 = array.new<float>(0)
var array<float> reachR3 = array.new<float>(0)
var array<float> reachS1 = array.new<float>(0)
var array<float> reachS2 = array.new<float>(0)
var array<float> reachS3 = array.new<float>(0)

// Touch-reaction tracking: per level hold/break arrays
var array<float> holdR1 = array.new<float>(0)
var array<float> holdR2 = array.new<float>(0)
var array<float> holdR3 = array.new<float>(0)
var array<float> holdS1 = array.new<float>(0)
var array<float> holdS2 = array.new<float>(0)
var array<float> holdS3 = array.new<float>(0)

// Touch counts within session (for decay)
var int tcR1 = 0
var int tcR2 = 0
var int tcR3 = 0
var int tcS1 = 0
var int tcS2 = 0
var int tcS3 = 0

// Touch-decay arrays: store [touch_number, held_bool] as separate arrays per level
var array<float> decayR1tc = array.new<float>(0)
var array<float> decayR1hd = array.new<float>(0)
var array<float> decayS1tc = array.new<float>(0)
var array<float> decayS1hd = array.new<float>(0)

// Session range tracking for the projection cone
var array<float> sessRangePct = array.new<float>(0)
var array<float> cprWHist     = array.new<float>(0)

// Percentile rank of the current CPR width within its own history (na below 5 samples)
cprRank(float w) =>
    int n_ = array.size(cprWHist)
    float r_ = na
    if n_ >= 5
        int cnt_ = 0
        for ci = 0 to n_ - 1
            if array.get(cprWHist, ci) < w
                cnt_ += 1
        r_ := cnt_ / n_ * 100.0
    r_
var float sessOpen = na
var float sessHi   = na
var float sessLo   = na

// Pending touch flags (detect on this bar, confirm on next)
var bool ptR1 = false
var bool ptR2 = false
var bool ptR3 = false
var bool ptS1 = false
var bool ptS2 = false
var bool ptS3 = false


// Session open
if newSession
    sessOpen := open
    sessHi   := high
    sessLo   := low

if not na(sessOpen)
    sessHi := math.max(sessHi, high)
    sessLo := math.min(sessLo, low)

// At new session: push completed session reach bools, reset
if newSession and barstate.isconfirmed
    // Push reach (1 = tagged, 0 = not tagged)
    array.push(reachP,  tagP  ? 1.0 : 0.0)
    array.push(reachR1, tagR1 ? 1.0 : 0.0)
    array.push(reachR2, tagR2 ? 1.0 : 0.0)
    array.push(reachR3, tagR3 ? 1.0 : 0.0)
    array.push(reachS1, tagS1 ? 1.0 : 0.0)
    array.push(reachS2, tagS2 ? 1.0 : 0.0)
    array.push(reachS3, tagS3 ? 1.0 : 0.0)
    // Cap arrays at i_reachN
    if array.size(reachP)  > i_reachN
        array.shift(reachP)
    if array.size(reachR1) > i_reachN
        array.shift(reachR1)
    if array.size(reachR2) > i_reachN
        array.shift(reachR2)
    if array.size(reachR3) > i_reachN
        array.shift(reachR3)
    if array.size(reachS1) > i_reachN
        array.shift(reachS1)
    if array.size(reachS2) > i_reachN
        array.shift(reachS2)
    if array.size(reachS3) > i_reachN
        array.shift(reachS3)
    // Push session range %
    if not na(sessOpen) and sessOpen != 0
        float rng = (sessHi - sessLo) / sessOpen * 100.0
        array.push(sessRangePct, rng)
        if array.size(sessRangePct) > i_reachN
            array.shift(sessRangePct)
    // Push this (new) session's CPR width — fixed for the whole period, known at its open
    if pP != 0
        array.push(cprWHist, math.abs(cprTC - cprBC) / pP * 100.0)
        if array.size(cprWHist) > i_reachN
            array.shift(cprWHist)
    // Reset session tags
    tagP  := false
    tagR1 := false
    tagR2 := false
    tagR3 := false
    tagS1 := false
    tagS2 := false
    tagS3 := false
    // Reset touch counts
    tcR1 := 0
    tcR2 := 0
    tcR3 := 0
    tcS1 := 0
    tcS2 := 0
    tcS3 := 0
    // Reset session tracking
    sessOpen := open
    sessHi   := high
    sessLo   := low
    // Drop pending touch-reactions across the boundary — the levels just changed, so a touch on
    // the last bar of the old session must not be judged against the NEW session's levels.
    ptR1 := false
    ptR2 := false
    ptR3 := false
    ptS1 := false
    ptS2 := false
    ptS3 := false

// Tag detection: price bar touches a level (high >= level and low <= level)
float tol = atrVal * 0.15
bool htP  = high >= pP  - tol and low <= pP  + tol
bool htR1 = high >= pR1 - tol
bool htR2 = high >= pR2 - tol
bool htR3 = high >= pR3 - tol and i_showS3R3
bool htS1 = low  <= pS1 + tol
bool htS2 = low  <= pS2 + tol
bool htS3 = low  <= pS3 + tol and i_showS3R3

if htP
    tagP := true
if htR1
    tagR1 := true
if htR2
    tagR2 := true
if htR3
    tagR3 := true
if htS1
    tagS1 := true
if htS2
    tagS2 := true
if htS3
    tagS3 := true

// Touch-reaction: detect when price enters a level zone (not already tagged this touch)
// We use a simpler approach: track entry into zone vs exit
var bool inZoneR1 = false
var bool inZoneR2 = false
var bool inZoneR3 = false
var bool inZoneS1 = false
var bool inZoneS2 = false
var bool inZoneS3 = false

float zTol = atrVal * 0.25

bool touchedR1 = false
bool touchedR2 = false
bool touchedR3 = false
bool touchedS1 = false
bool touchedS2 = false
bool touchedS3 = false

// Detect fresh touch (first entry into zone)
if high >= pR1 - zTol and not inZoneR1
    inZoneR1  := true
    touchedR1 := true
    tcR1      := tcR1 + 1
if high < pR1 - zTol
    inZoneR1 := false

if high >= pR2 - zTol and not inZoneR2
    inZoneR2  := true
    touchedR2 := true
    tcR2      := tcR2 + 1
if high < pR2 - zTol
    inZoneR2 := false

if i_showS3R3 and high >= pR3 - zTol and not inZoneR3
    inZoneR3  := true
    touchedR3 := true
    tcR3      := tcR3 + 1
if high < pR3 - zTol
    inZoneR3 := false

if low <= pS1 + zTol and not inZoneS1
    inZoneS1  := true
    touchedS1 := true
    tcS1      := tcS1 + 1
if low > pS1 + zTol
    inZoneS1 := false

if low <= pS2 + zTol and not inZoneS2
    inZoneS2  := true
    touchedS2 := true
    tcS2      := tcS2 + 1
if low > pS2 + zTol
    inZoneS2 := false

if i_showS3R3 and low <= pS3 + zTol and not inZoneS3
    inZoneS3  := true
    touchedS3 := true
    tcS3      := tcS3 + 1
if low > pS3 + zTol
    inZoneS3 := false

// Reaction detection: the bar AFTER a touch — did it hold or break?
// Hold = close back away from level; Break = close through
bool reactR1 = ptR1 and barstate.isconfirmed
bool reactR2 = ptR2 and barstate.isconfirmed
bool reactR3 = ptR3 and barstate.isconfirmed
bool reactS1 = ptS1 and barstate.isconfirmed
bool reactS2 = ptS2 and barstate.isconfirmed
bool reactS3 = ptS3 and barstate.isconfirmed

// Resistance hold = close < level (rejected); break = close > level
bool holdR1val = close < pR1
bool holdR2val = close < pR2
bool holdR3val = close < pR3
// Support hold = close > level (bounced); break = close < level
bool holdS1val = close > pS1
bool holdS2val = close > pS2
bool holdS3val = close > pS3

if reactR1
    array.push(holdR1, holdR1val ? 1.0 : 0.0)
    if array.size(holdR1) > i_reachN * 3
        array.shift(holdR1)
if reactR2
    array.push(holdR2, holdR2val ? 1.0 : 0.0)
    if array.size(holdR2) > i_reachN * 3
        array.shift(holdR2)
if reactR3
    array.push(holdR3, holdR3val ? 1.0 : 0.0)
    if array.size(holdR3) > i_reachN * 3
        array.shift(holdR3)
if reactS1
    array.push(holdS1, holdS1val ? 1.0 : 0.0)
    if array.size(holdS1) > i_reachN * 3
        array.shift(holdS1)
if reactS2
    array.push(holdS2, holdS2val ? 1.0 : 0.0)
    if array.size(holdS2) > i_reachN * 3
        array.shift(holdS2)
if reactS3
    array.push(holdS3, holdS3val ? 1.0 : 0.0)
    if array.size(holdS3) > i_reachN * 3
        array.shift(holdS3)

// Decay tracking (first-touch data for R1/S1)
if reactR1 and i_touchDecay
    array.push(decayR1tc, math.min(tcR1, 3.0))
    array.push(decayR1hd, holdR1val ? 1.0 : 0.0)
    if array.size(decayR1tc) > i_reachN * 5
        array.shift(decayR1tc)
        array.shift(decayR1hd)
if reactS1 and i_touchDecay
    array.push(decayS1tc, math.min(tcS1, 3.0))
    array.push(decayS1hd, holdS1val ? 1.0 : 0.0)
    if array.size(decayS1tc) > i_reachN * 5
        array.shift(decayS1tc)
        array.shift(decayS1hd)

// Set pending flags for NEXT bar reaction check
ptR1 := touchedR1
ptR2 := touchedR2
ptR3 := touchedR3
ptS1 := touchedS1
ptS2 := touchedS2
ptS3 := touchedS3

// ─────────────────────────────────────────────
// § STATISTICS HELPERS
// ─────────────────────────────────────────────
// Reach rate from array
reachRate(array<float> arr) =>
    int n = array.size(arr)
    n == 0 ? na : array.sum(arr) / n * 100.0

// Hold rate + wilson lower bound
holdStats(array<float> arr, float z) =>
    int n = array.size(arr)
    if n == 0
        [na, na, n]
    else
        float p = array.sum(arr) / n
        float denom = 1.0 + z*z/n
        float centre = (p + z*z/(2.0*n)) / denom
        float margin = z * math.sqrt(p*(1.0-p)/n + z*z/(4.0*n*n)) / denom
        float lb = math.max(0.0, centre - margin)
        [p * 100.0, lb * 100.0, n]

// Wilson z value
float wilsonZ = i_wilsonZ == "95%" ? 1.960 : i_wilsonZ == "90%" ? 1.645 : 1.282

// Hold stats per level
[hrR1, lbR1, nR1] = holdStats(holdR1, wilsonZ)
[hrR2, lbR2, nR2] = holdStats(holdR2, wilsonZ)
[hrR3, lbR3, nR3] = holdStats(holdR3, wilsonZ)
[hrS1, lbS1, nS1] = holdStats(holdS1, wilsonZ)
[hrS2, lbS2, nS2] = holdStats(holdS2, wilsonZ)
[hrS3, lbS3, nS3] = holdStats(holdS3, wilsonZ)

float rrR1 = reachRate(reachR1)
float rrR2 = reachRate(reachR2)
float rrR3 = reachRate(reachR3)
float rrS1 = reachRate(reachS1)
float rrS2 = reachRate(reachS2)
float rrS3 = reachRate(reachS3)
float rrP  = reachRate(reachP)

bool hasReachData = array.size(reachR1) >= i_minSamp

// Touch-decay readout (R1 example)
float decR1t1 = na
float decR1t2 = na
float decR1t3 = na
float decS1t1 = na
float decS1t2 = na
float decS1t3 = na

if i_touchDecay and array.size(decayR1tc) > 0
    float s1 = 0.0
    float n1 = 0.0
    float s2 = 0.0
    float n2 = 0.0
    float s3 = 0.0
    float n3 = 0.0
    int dsz = array.size(decayR1tc)
    for i = 0 to dsz - 1
        float tc_ = array.get(decayR1tc, i)
        float hd_ = array.get(decayR1hd, i)
        if tc_ <= 1.0
            s1 := s1 + hd_
            n1 := n1 + 1.0
        else if tc_ <= 2.0
            s2 := s2 + hd_
            n2 := n2 + 1.0
        else
            s3 := s3 + hd_
            n3 := n3 + 1.0
    decR1t1 := n1 > 0 ? s1/n1*100.0 : na
    decR1t2 := n2 > 0 ? s2/n2*100.0 : na
    decR1t3 := n3 > 0 ? s3/n3*100.0 : na

if i_touchDecay and array.size(decayS1tc) > 0
    float s1 = 0.0
    float n1 = 0.0
    float s2 = 0.0
    float n2 = 0.0
    float s3 = 0.0
    float n3 = 0.0
    int dsz2 = array.size(decayS1tc)
    for i = 0 to dsz2 - 1
        float tc_ = array.get(decayS1tc, i)
        float hd_ = array.get(decayS1hd, i)
        if tc_ <= 1.0
            s1 := s1 + hd_
            n1 := n1 + 1.0
        else if tc_ <= 2.0
            s2 := s2 + hd_
            n2 := n2 + 1.0
        else
            s3 := s3 + hd_
            n3 := n3 + 1.0
    decS1t1 := n1 > 0 ? s1/n1*100.0 : na
    decS1t2 := n2 > 0 ? s2/n2*100.0 : na
    decS1t3 := n3 > 0 ? s3/n3*100.0 : na

// ─────────────────────────────────────────────
// § CONFLUENCE CHECK
// ─────────────────────────────────────────────
// Returns true if any HTF confluence level is within tolerance
float confTolAbs = atrVal * i_confTol

withinTol(float chartLvl, float htfLvl) =>
    confUsable and math.abs(chartLvl - htfLvl) <= confTolAbs

bool confP  = withinTol(pP,  cP)  or withinTol(pP,  cR1) or withinTol(pP,  cS1) or withinTol(pP,  cR2) or withinTol(pP,  cS2)
bool confR1 = withinTol(pR1, cP)  or withinTol(pR1, cR1) or withinTol(pR1, cS1) or withinTol(pR1, cR2) or withinTol(pR1, cS2) or (i_showS3R3 and (withinTol(pR1, cR3) or withinTol(pR1, cS3)))
bool confR2 = withinTol(pR2, cP)  or withinTol(pR2, cR1) or withinTol(pR2, cS1) or withinTol(pR2, cR2) or withinTol(pR2, cS2) or (i_showS3R3 and (withinTol(pR2, cR3) or withinTol(pR2, cS3)))
bool confR3 = withinTol(pR3, cP)  or withinTol(pR3, cR1) or withinTol(pR3, cS1) or withinTol(pR3, cR2) or withinTol(pR3, cS2) or (i_showS3R3 and (withinTol(pR3, cR3) or withinTol(pR3, cS3)))
bool confS1 = withinTol(pS1, cP)  or withinTol(pS1, cR1) or withinTol(pS1, cS1) or withinTol(pS1, cR2) or withinTol(pS1, cS2) or (i_showS3R3 and (withinTol(pS1, cR3) or withinTol(pS1, cS3)))
bool confS2 = withinTol(pS2, cP)  or withinTol(pS2, cR1) or withinTol(pS2, cS1) or withinTol(pS2, cR2) or withinTol(pS2, cS2) or (i_showS3R3 and (withinTol(pS2, cR3) or withinTol(pS2, cS3)))
bool confS3 = withinTol(pS3, cP)  or withinTol(pS3, cR1) or withinTol(pS3, cS1) or withinTol(pS3, cR2) or withinTol(pS3, cS2) or (i_showS3R3 and (withinTol(pS3, cR3) or withinTol(pS3, cS3)))

// ─────────────────────────────────────────────
// § WEIGHT + DISPLAY LOGIC
// ─────────────────────────────────────────────
// Level weight: 0..1; drives line width, brightness, glow
levelWeight(float lvl, float rr, bool conf) =>
    float distPct = math.abs(close - lvl) / close * 100.0
    float proxScore  = math.max(0.0, 1.0 - distPct / i_hideFarPct)
    float reachScore = na(rr) ? 0.5 : rr / 100.0
    float confBonus  = conf ? 0.25 : 0.0
    math.min(1.0, proxScore * 0.5 + reachScore * 0.35 + confBonus)

float wP  = levelWeight(pP,  rrP,  confP)
float wR1 = levelWeight(pR1, rrR1, confR1)
float wR2 = levelWeight(pR2, rrR2, confR2)
float wR3 = levelWeight(pR3, rrR3, confR3)
float wS1 = levelWeight(pS1, rrS1, confS1)
float wS2 = levelWeight(pS2, rrS2, confS2)
float wS3 = levelWeight(pS3, rrS3, confS3)

// Visibility: fade if too far from price
farP  = math.abs(close - pP)  / close * 100.0 > i_hideFarPct
farR1 = math.abs(close - pR1) / close * 100.0 > i_hideFarPct
farR2 = math.abs(close - pR2) / close * 100.0 > i_hideFarPct
farR3 = math.abs(close - pR3) / close * 100.0 > i_hideFarPct
farS1 = math.abs(close - pS1) / close * 100.0 > i_hideFarPct
farS2 = math.abs(close - pS2) / close * 100.0 > i_hideFarPct
farS3 = math.abs(close - pS3) / close * 100.0 > i_hideFarPct

// Colour per level type
float pRangeUp = math.max(pR3 - pP, atrVal)
float pRangeDn = math.max(pP - pS3, atrVal)
float pScore = (close >= pP ? (close - pP) / pRangeUp : (close - pP) / pRangeDn) * 100.0
color cMain  = heatCol(normScore(pScore), 0, i_col_hot, i_col_cold)
// Lift the wave colour toward white so the BIG price↔P fill stays a light, airy tint —
// even if an existing chart instance still carries the old (darker) colour inputs (TV keeps
// stored input values across script updates; only a fresh add / reset picks up new defaults).
color cMainLite = color.from_gradient(0.32, 0.0, 1.0, cMain, color.white)

color cPivot = color.new(color.white, 30)
color cR1c   = color.new(i_dist_gold, farR1 ? 75 : (confR1 ? 10 : 30))
color cR2c   = color.new(i_dist_gold, farR2 ? 75 : (confR2 ? 10 : 45))
color cR3c   = color.new(i_dist_gold, farR3 ? 75 : (confR3 ? 10 : 60))
color cS1c   = color.new(i_dist_cold, farS1 ? 75 : (confS1 ? 10 : 30))
color cS2c   = color.new(i_dist_cold, farS2 ? 75 : (confS2 ? 10 : 45))
color cS3c   = color.new(i_dist_cold, farS3 ? 75 : (confS3 ? 10 : 60))

// Label text helper
fmtPct(float v) =>
    na(v) ? "?" : str.tostring(math.round(v), "0") + "%"

lvlTag(string name, float rr, bool conf, bool tagged) =>
    string tag = name
    tag := tag + "  " + fmtPct(rr)
    if conf
        tag := tag + " ✦"
    if tagged
        tag := tag + " ✓"
    tag

// Build per-level tooltips
buildTooltip(string name, float rr, float hr, float lb, int n_, float t1, float t2, float t3, bool conf, bool tagged, float lvl) =>
    string tt = name + " @ " + str.tostring(lvl, "0.00000")
    tt := tt + "\nReach (" + str.tostring(array.size(reachR1), "0") + " sessions): " + fmtPct(rr)
    if not na(hr)
        tt := tt + "\nHold rate: " + fmtPct(hr) + "  (Wilson lb: " + fmtPct(lb) + ", n=" + str.tostring(n_, "0") + ")"
    if i_touchDecay and not na(t1)
        tt := tt + "\n1st touch held: " + fmtPct(t1)
    if i_touchDecay and not na(t2)
        tt := tt + "  2nd: " + fmtPct(t2)
    if i_touchDecay and not na(t3)
        tt := tt + "  3rd: " + fmtPct(t3)
    if conf
        tt := tt + "\n✦ Confluence with " + confTf + " pivot"
    if tagged
        tt := tt + "\n✓ Already tagged this session"
    tt

// ─────────────────────────────────────────────
// § LINE + LABEL DRAWING
// ─────────────────────────────────────────────
// Store line/label handles
var line lnP  = na
var line lnR1 = na
var line lnR2 = na
var line lnR3 = na
var line lnS1 = na
var line lnS2 = na
var line lnS3 = na

var label lblP  = na
var label lblR1 = na
var label lblR2 = na
var label lblR3 = na
var label lblS1 = na
var label lblS2 = na
var label lblS3 = na

// Glow lines
var line glR1a = na
var line glR1b = na
var line glS1a = na
var line glS1b = na
var line glPa  = na
var line glPb  = na

// HTF display line
var line lnHtf = na
var label lblHtf = na

// CPR band objects
var line     cprTcLn   = na
var line     cprBcLn   = na
var linefill cprFillLf = na
var label    cprLbl    = na

int x1_ = nz(sessStartBar, bar_index - 1)
int x2_ = bar_index + 8

// Helper: line width from weight
lwFromWeight(float w) =>
    w >= 0.75 ? 3 : w >= 0.45 ? 2 : 1

// Draw/update lines each bar (extend right a few bars)
if barstate.islast
    // Delete old
    line.delete(lnP)
    line.delete(lnR1)
    line.delete(lnR2)
    line.delete(lnR3)
    line.delete(lnS1)
    line.delete(lnS2)
    line.delete(lnS3)
    label.delete(lblP)
    label.delete(lblR1)
    label.delete(lblR2)
    label.delete(lblR3)
    label.delete(lblS1)
    label.delete(lblS2)
    label.delete(lblS3)
    line.delete(glR1a)
    line.delete(glR1b)
    line.delete(glS1a)
    line.delete(glS1b)
    line.delete(glPa)
    line.delete(glPb)
    line.delete(lnHtf)
    label.delete(lblHtf)
    line.delete(cprTcLn)
    line.delete(cprBcLn)
    linefill.delete(cprFillLf)
    label.delete(cprLbl)
    // CPR band (drawn first so the levels render on top of the wash)
    if i_cprOn
        float cprW   = pP != 0 ? math.abs(cprTC - cprBC) / pP * 100.0 : 0.0
        float cprRk  = cprRank(cprW)
        string rkTag = na(cprRk) ? "" : cprRk <= 33 ? "narrow · p" + str.tostring(cprRk, "0") : cprRk >= 67 ? "wide · p" + str.tostring(cprRk, "0") : "mid · p" + str.tostring(cprRk, "0")
        cprTcLn   := line.new(x1_, cprTC, x2_, cprTC, color=color.new(color.silver, 55), width=1, style=line.style_dotted, extend=extend.right)
        cprBcLn   := line.new(x1_, cprBC, x2_, cprBC, color=color.new(color.silver, 55), width=1, style=line.style_dotted, extend=extend.right)
        cprFillLf := linefill.new(cprTcLn, cprBcLn, color.new(color.silver, 90))
        // Label sits a few bars RIGHT of the level tags — TC is usually near P, same-x labels overlap
        cprLbl    := label.new(x2_ + 6, cprTC, "CPR" + (rkTag != "" ? "  " + rkTag : ""), style=label.style_label_left, color=color.new(color.black, 20), textcolor=color.new(color.silver, 25), size=size.tiny, tooltip="Central Pivot Range — BC=(H+L)/2 to TC=2P−BC of the prior " + pivTf + " period.\nWidth: " + str.tostring(cprW, "0.00") + "% of price" + (na(cprRk) ? " (gathering)" : " — p" + str.tostring(cprRk, "0") + " of the last " + str.tostring(array.size(cprWHist), "0") + " periods on this chart") + ".\nClassic read: a NARROW range often precedes a trending period, a WIDE one a rotational period — shown as this chart's own percentile, not a prediction.")
    // Draw P
    lnP  := line.new(x1_, pP, x2_, pP, color=cPivot, width=2, style=line.style_solid, extend=extend.right)
    lblP := label.new(x2_, pP, "P  " + (hasReachData ? fmtPct(rrP) : "—") + (confP ? " ✦" : "") + (tagP ? " ✓" : ""), style=label.style_label_left, color=color.new(color.black, 20), textcolor=color.new(color.white, 20), size=size.small)
    // Glow on P if high weight
    if i_glow and wP >= 0.5
        glPa := line.new(x1_, pP, x2_, pP, color=color.new(color.white, 72), width=6, style=line.style_solid, extend=extend.right)
        glPb := line.new(x1_, pP, x2_, pP, color=color.new(color.white, 88), width=10, style=line.style_solid, extend=extend.right)
    // R1
    lnR1 := line.new(x1_, pR1, x2_, pR1, color=cR1c, width=lwFromWeight(wR1), style=line.style_solid, extend=extend.right)
    lblR1 := label.new(x2_, pR1, lvlTag("R1", rrR1, confR1, tagR1), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cR1c, size=size.small, tooltip=buildTooltip("R1", rrR1, hrR1, lbR1, nR1, decR1t1, decR1t2, decR1t3, confR1, tagR1, pR1))
    if i_glow and wR1 >= 0.5
        glR1a := line.new(x1_, pR1, x2_, pR1, color=color.new(i_dist_gold, 72), width=lwFromWeight(wR1)+4, style=line.style_solid, extend=extend.right)
        glR1b := line.new(x1_, pR1, x2_, pR1, color=color.new(i_dist_gold, 88), width=lwFromWeight(wR1)+8, style=line.style_solid, extend=extend.right)
    // R2
    lnR2 := line.new(x1_, pR2, x2_, pR2, color=cR2c, width=lwFromWeight(wR2), style=line.style_solid, extend=extend.right)
    lblR2 := label.new(x2_, pR2, lvlTag("R2", rrR2, confR2, tagR2), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cR2c, size=size.small, tooltip=buildTooltip("R2", rrR2, hrR2, lbR2, nR2, na, na, na, confR2, tagR2, pR2))
    // R3
    if i_showS3R3
        lnR3 := line.new(x1_, pR3, x2_, pR3, color=cR3c, width=lwFromWeight(wR3), style=line.style_solid, extend=extend.right)
        lblR3 := label.new(x2_, pR3, lvlTag("R3", rrR3, confR3, tagR3), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cR3c, size=size.small, tooltip=buildTooltip("R3", rrR3, hrR3, lbR3, nR3, na, na, na, confR3, tagR3, pR3))
    // S1
    lnS1 := line.new(x1_, pS1, x2_, pS1, color=cS1c, width=lwFromWeight(wS1), style=line.style_solid, extend=extend.right)
    lblS1 := label.new(x2_, pS1, lvlTag("S1", rrS1, confS1, tagS1), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cS1c, size=size.small, tooltip=buildTooltip("S1", rrS1, hrS1, lbS1, nS1, decS1t1, decS1t2, decS1t3, confS1, tagS1, pS1))
    if i_glow and wS1 >= 0.5
        glS1a := line.new(x1_, pS1, x2_, pS1, color=color.new(i_dist_cold, 72), width=lwFromWeight(wS1)+4, style=line.style_solid, extend=extend.right)
        glS1b := line.new(x1_, pS1, x2_, pS1, color=color.new(i_dist_cold, 88), width=lwFromWeight(wS1)+8, style=line.style_solid, extend=extend.right)
    // S2
    lnS2 := line.new(x1_, pS2, x2_, pS2, color=cS2c, width=lwFromWeight(wS2), style=line.style_solid, extend=extend.right)
    lblS2 := label.new(x2_, pS2, lvlTag("S2", rrS2, confS2, tagS2), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cS2c, size=size.small, tooltip=buildTooltip("S2", rrS2, hrS2, lbS2, nS2, na, na, na, confS2, tagS2, pS2))
    // S3
    if i_showS3R3
        lnS3 := line.new(x1_, pS3, x2_, pS3, color=cS3c, width=lwFromWeight(wS3), style=line.style_solid, extend=extend.right)
        lblS3 := label.new(x2_, pS3, lvlTag("S3", rrS3, confS3, tagS3), style=label.style_label_left, color=color.new(color.black, 20), textcolor=cS3c, size=size.small, tooltip=buildTooltip("S3", rrS3, hrS3, lbS3, nS3, na, na, na, confS3, tagS3, pS3))
    // HTF display (skip when there is no usable higher rung — M-grid: hP would duplicate the grid P)
    if i_htfOn and confUsable
        lnHtf := line.new(x1_, hP, x2_+4, hP, color=color.new(color.white, 75), width=1, style=line.style_dashed)
        lblHtf := label.new(x2_+5, hP, effHtfTf + " P", style=label.style_label_left, color=color.new(color.black, 20), textcolor=color.new(color.white, 55), size=size.tiny)

// ─────────────────────────────────────────────
// § HEAT FILL (price vs P)
// ─────────────────────────────────────────────
// Two wave styles (i_waveStyle), both coloured by cMainLite (hot above P / cold below):
//  • Ribbon (default) — AVWAP-style: a gradient fill in the GAP between price and a short EMA.
//    Smooth (the EMA edge never streaks), sits CLEAR of the candle bodies (visible, not hidden
//    behind price like a close-centred band), and breathes — wide in moves, thin in chop.
//  • Block to pivot — the older look: one fill across the whole price↔P gap. Because P is a flat
//    DAILY level, that band is rectangular and steps at each new session (by design, but busy).
// On a DARK chart MORE transparency = DARKER (more black shows through), so the dense top edge
// stays fairly opaque to let the light pastel colour read; only the far edge fades out.
float ribEma  = ta.ema(close, i_ribSmooth)
bool  ribbon  = i_waveStyle == "Ribbon"
pPricePlot  = plot(close,   "Price", color=na, editable=false, display=display.none)
pPivotPlot  = plot(pP,      "Pivot", color=na, editable=false, display=display.none)
pRibEmaPlot = plot(ribEma,  "RibbonEMA", color=na, editable=false, display=display.none)
// Block-to-pivot fill (option)
fill(pPricePlot, pPivotPlot,  top_value=math.max(close, pP),     bottom_value=math.min(close, pP),     top_color=ribbon ? na : color.new(cMainLite, i_glow ? 32 : 44), bottom_color=ribbon ? na : color.new(cMainLite, 84))
// Ribbon fill (default): the price↔EMA gap, dense at the top edge, fading to the lower edge
fill(pPricePlot, pRibEmaPlot, top_value=math.max(close, ribEma), bottom_value=math.min(close, ribEma), top_color=ribbon ? color.new(cMainLite, i_glow ? 18 : 30) : na, bottom_color=ribbon ? color.new(cMainLite, 88) : na)


// ─────────────────────────────────────────────
// § SIGNAL DOTS — touch reactions
// ─────────────────────────────────────────────
var array<label> dotLabels = array.new<label>(0)

// Evidence tiers for dots
bool backedR1 = not na(lbR1) and lbR1 > 50.0
bool backedS1 = not na(lbS1) and lbS1 > 50.0

// Dot glyph based on backing
dotGlyph(float lb, int n_) =>
    n_ < i_minSamp ? "○" : lb > 50.0 ? "●" : lb > 40.0 ? "◐" : "○"

// Strength tier for sizing
dotSize(int nHold, float hr) =>
    nr = nHold
    string sz = size.normal
    if nr >= 10
        sz := hr >= 65.0 ? size.huge : hr >= 55.0 ? size.large : size.normal
    sz

// Density gate: which touch dots actually plot (i_sigDensity)
showDot(int n_, float hr_, bool backed_) =>
    i_sigDensity == "All" ? true : i_sigDensity == "Backed" ? backed_ : (n_ >= 10 and hr_ >= 55.0)

// Hold at resistance = rejection (the bearish signal); hold at support = bounce (the bullish one).
// (The old fireR1bear was wired to the BREAK — the dot and alerts fired on the wrong event.)
bool fireR1rej  = reactR1 and holdR1val and barstate.isconfirmed
bool fireS1bull = reactS1 and holdS1val and barstate.isconfirmed
bool fireR2rej  = reactR2 and holdR2val and barstate.isconfirmed
bool fireS2bull = reactS2 and holdS2val and barstate.isconfirmed

// Build tooltip for touch dot
touchDotTip(string lvl, string dir, float hr_, float lb_, int n_, bool backed) =>
    string t = lvl + " touch — " + dir
    t := t + "\nHold rate: " + (n_ < i_minSamp ? "gathering (n=" + str.tostring(n_, "0") + ")" : fmtPct(hr_) + "  lb: " + fmtPct(lb_) + "  n=" + str.tostring(n_, "0"))
    t := t + "\n" + (backed ? "History here backed hold" : n_ < i_minSamp ? "Not enough data yet" : "History here mixed or no edge")
    t

// Fire dots
if fireR1rej and showDot(nR1, nz(hrR1, 0.0), backedR1)
    string glyph = dotGlyph(nz(lbR1, 0.0), nR1)
    string sz    = dotSize(nR1, nz(hrR1, 0.0))
    string tip   = touchDotTip("R1", "resistance rejection", nz(hrR1,0.0), nz(lbR1,0.0), nR1, backedR1)
    label dl = label.new(bar_index - 1, pR1 + atrVal*1.5, glyph, style=label.style_none, color=color.new(color.black,100), textcolor=color.new(i_dist_gold, 0), size=sz, tooltip=tip)
    array.push(dotLabels, dl)
    if array.size(dotLabels) > 400
        label.delete(array.shift(dotLabels))

if fireS1bull and showDot(nS1, nz(hrS1, 0.0), backedS1)
    string glyph = dotGlyph(nz(lbS1, 0.0), nS1)
    string sz    = dotSize(nS1, nz(hrS1, 0.0))
    string tip   = touchDotTip("S1", "support bounce", nz(hrS1,0.0), nz(lbS1,0.0), nS1, backedS1)
    label dl = label.new(bar_index - 1, pS1 - atrVal*1.5, glyph, style=label.style_none, color=color.new(color.black,100), textcolor=color.new(i_dist_cold, 0), size=sz, tooltip=tip)
    array.push(dotLabels, dl)
    if array.size(dotLabels) > 400
        label.delete(array.shift(dotLabels))

if fireR2rej and showDot(nR2, nz(hrR2, 0.0), not na(lbR2) and lbR2 > 50.0)
    string glyph = dotGlyph(nz(lbR2, 0.0), nR2)
    string sz    = dotSize(nR2, nz(hrR2, 0.0))
    string tip   = touchDotTip("R2", "resistance rejection", nz(hrR2,0.0), nz(lbR2,0.0), nR2, not na(lbR2) and lbR2 > 50.0)
    label dl = label.new(bar_index - 1, pR2 + atrVal*1.5, glyph, style=label.style_none, color=color.new(color.black,100), textcolor=color.new(i_dist_gold, 20), size=sz, tooltip=tip)
    array.push(dotLabels, dl)
    if array.size(dotLabels) > 400
        label.delete(array.shift(dotLabels))

if fireS2bull and showDot(nS2, nz(hrS2, 0.0), not na(lbS2) and lbS2 > 50.0)
    string glyph = dotGlyph(nz(lbS2, 0.0), nS2)
    string sz    = dotSize(nS2, nz(hrS2, 0.0))
    string tip   = touchDotTip("S2", "support bounce", nz(hrS2,0.0), nz(lbS2,0.0), nS2, not na(lbS2) and lbS2 > 50.0)
    label dl = label.new(bar_index - 1, pS2 - atrVal*1.5, glyph, style=label.style_none, color=color.new(color.black,100), textcolor=color.new(i_dist_cold, 20), size=sz, tooltip=tip)
    array.push(dotLabels, dl)
    if array.size(dotLabels) > 400
        label.delete(array.shift(dotLabels))

// ─────────────────────────────────────────────
// § PROJECTION CONE
// ─────────────────────────────────────────────
var box    coneBox    = na
var line   coneMedLn  = na
var label  coneMedLbl = na

if i_probOn and i_probCone and barstate.islast
    box.delete(coneBox)
    line.delete(coneMedLn)
    label.delete(coneMedLbl)
    int n_samp = array.size(sessRangePct)
    if n_samp >= i_minSamp
        float sampMed = array.median(sessRangePct)
        float samp84  = array.percentile_nearest_rank(sessRangePct, 84)
        // A session RANGE has no direction — projecting it all ABOVE the open overstated the upside.
        // Honest envelope: the open ± half the range percentile (outer box = p84, dashed line = +med/2).
        float anchor  = nz(sessOpen, pP)
        float coneTop = anchor * (1.0 + samp84 / 200.0)
        float coneBot = anchor * (1.0 - samp84 / 200.0)
        float coneMed = anchor * (1.0 + sampMed / 200.0)
        int   cx1     = bar_index
        int   cx2     = bar_index + 10
        coneBox   := box.new(cx1, coneTop, cx2, coneBot, border_color=color.new(i_dist_gold, 50), bgcolor=color.new(i_dist_gold, 88))
        coneMedLn  := line.new(cx1, coneMed, cx2, coneMed, color=color.rgb(224,168,0), style=line.style_dashed, width=1)
        coneMedLbl := label.new(cx2, coneMed, "range med ±" + str.tostring(sampMed / 2.0, "0.00") + "% · p84 ±" + str.tostring(samp84 / 2.0, "0.00") + "%", style=label.style_label_left, color=color.new(color.black,100), textcolor=color.rgb(224,168,0), size=size.tiny)

// ─────────────────────────────────────────────
// § MINI-READOUT
// ─────────────────────────────────────────────
var table readTbl = table.new(i_readPos == "Top left" ? position.top_left : i_readPos == "Bottom right" ? position.bottom_right : i_readPos == "Bottom left" ? position.bottom_left : i_readPos == "Middle right" ? position.middle_right : position.top_right, 1, 7, bgcolor=color.new(color.black, 16), frame_color=color.new(color.gray, 65), frame_width=1, border_width=0)

// Edge clock
var int edgeBullBacked = na  // bar_index of last Wilson-backed
var int edgeBullLean   = na
var int edgeBearBacked = na
var int edgeBearLean   = na

// Stamp the clocks on REACTION EVENTS, not on the slow-moving array stat — the stat stays true
// for long stretches once backed, which made every clock read "now" permanently and say nothing.
// ● = an S1-bounce / R1-rejection actually fired while its hold-history was Wilson-backed;
// ◐ = one fired while the history at least leaned (hold-rate ≥ 55%).
bool bullBacked = hasReachData and not na(lbS1) and lbS1 > 50.0
bool bearBacked = hasReachData and not na(lbR1) and lbR1 > 50.0
bool bullLean   = hasReachData and not na(hrS1) and hrS1 >= 55.0
bool bearLean   = hasReachData and not na(hrR1) and hrR1 >= 55.0

if fireS1bull and bullBacked
    edgeBullBacked := bar_index
if fireS1bull and bullLean
    edgeBullLean := bar_index
if fireR1rej and bearBacked
    edgeBearBacked := bar_index
if fireR1rej and bearLean
    edgeBearLean := bar_index

fmtClock(int bi) =>
    if na(bi)
        "—"
    else
        int bars_ago = bar_index - bi
        int secs_ago = bars_ago * timeframe.in_seconds(timeframe.period)
        secs_ago < 3600 ? "now" : secs_ago < 172800 ? str.tostring(math.floor(secs_ago / 3600), "0") + "h" : str.tostring(math.floor(secs_ago / 86400), "0") + "d"

// Read verdict for primary levels
readVerdictR1() =>
    if not hasReachData
        "R1: gathering data"
    else if not na(lbR1) and lbR1 > 50.0
        "R1 rejection: history backed hold (lb>50%)"
    else if not na(hrR1) and hrR1 >= 55.0
        "R1: history leans toward hold — building"
    else if not na(hrR1)
        "R1: history mixed on hold vs break"
    else
        "R1: insufficient reaction data"

readVerdictS1() =>
    if not hasReachData
        "S1: gathering data"
    else if not na(lbS1) and lbS1 > 50.0
        "S1 bounce: history backed hold (lb>50%)"
    else if not na(hrS1) and hrS1 >= 55.0
        "S1: history leans toward bounce — building"
    else if not na(hrS1)
        "S1: history mixed on bounce vs break"
    else
        "S1: insufficient reaction data"

if barstate.islast
    if i_probOn and i_probRead
        // Corner-pinned stats table (pixel-anchored, never overlaps the levels).
        string r1dir   = close > pR1 ? "above R1" : close > pP ? "above P" : close > pS1 ? "between P–S1" : "below S1"
        string methTag = i_method == "Classic" ? "PP" : i_method == "Fibonacci" ? "Fib PP" : i_method == "Camarilla" ? "Cama PP" : "Woodie PP"
        string row0txt = methTag + " " + pivTf + " · " + str.tostring(pP, "0.00") + " · " + r1dir
        float  roCprW  = pP != 0 ? math.abs(cprTC - cprBC) / pP * 100.0 : 0.0
        float  roCprRk = cprRank(roCprW)
        string cprTag  = not i_cprOn or na(roCprRk) ? "" : roCprRk <= 33 ? "  ·  CPR narrow" : roCprRk >= 67 ? "  ·  CPR wide" : "  ·  CPR mid"
        string row1txt = "R1 " + str.tostring(pR1, "0.00") + "  ·  S1 " + str.tostring(pS1, "0.00") + (confR1 or confS1 ? "  ✦conf" : "") + cprTag
        string row2txt = hasReachData ? "S1 reach " + fmtPct(rrS1) + (not na(hrS1) ? "  hold " + fmtPct(hrS1) + " (n=" + str.tostring(nS1,"0") + ")" : "  hold: n/a") : "S1: gathering — n=" + str.tostring(array.size(reachS1),"0")
        string row3txt = hasReachData ? "R1 reach " + fmtPct(rrR1) + (not na(hrR1) ? "  hold " + fmtPct(hrR1) + " (n=" + str.tostring(nR1,"0") + ")" : "  hold: n/a") : "R1: gathering — n=" + str.tostring(array.size(reachR1),"0")
        string readStr  = close > pP ? "Read: " + readVerdictR1() : "Read: " + readVerdictS1()
        color  readCol  = close > pP ? color.new(i_dist_gold, 0) : color.new(i_dist_cold, 0)
        string clockStr = "Edge last: bull ●" + fmtClock(edgeBullBacked) + " ◐" + fmtClock(edgeBullLean) + "  bear ●" + fmtClock(edgeBearBacked) + " ◐" + fmtClock(edgeBearLean)
        table.cell(readTbl, 0, 0, row0txt,  text_color=color.new(color.white, 5),  text_size=size.normal, text_halign=text.align_left)
        table.cell(readTbl, 0, 1, row1txt,  text_color=color.new(color.white, 25), text_size=size.small,  text_halign=text.align_left)
        table.cell(readTbl, 0, 2, row2txt,  text_color=color.new(i_dist_gold, 5),  text_size=size.small,  text_halign=text.align_left)
        table.cell(readTbl, 0, 3, row3txt,  text_color=color.new(i_dist_cold, 5),  text_size=size.small,  text_halign=text.align_left)
        table.cell(readTbl, 0, 4, readStr,  text_color=readCol,                    text_size=size.small,  text_halign=text.align_left)
        table.cell(readTbl, 0, 5, clockStr, text_color=color.new(color.gray, 20),  text_size=size.tiny,   text_halign=text.align_left)
        table.cell(readTbl, 0, 6, "Essentials · history of this chart", text_color=color.new(color.gray, 40), text_size=size.tiny, text_halign=text.align_left)
    else
        table.clear(readTbl, 0, 0, 0, 6)

// ─────────────────────────────────────────────
// § ALERTS
// ─────────────────────────────────────────────
// Primary touch-reaction alerts
alertcondition(fireR1rej, "PP: R1 Rejection",   "Pivot Points Mapped: R1 resistance rejection. Description of past signals, not a prediction.")
alertcondition(fireS1bull, "PP: S1 Bounce",      "Pivot Points Mapped: S1 support bounce. Description of past signals, not a prediction.")
alertcondition(reactR2 and holdR2val and barstate.isconfirmed, "PP: R2 Rejection", "Pivot Points Mapped: R2 resistance rejection. Description of past signals, not a prediction.")
alertcondition(reactS2 and holdS2val and barstate.isconfirmed, "PP: S2 Bounce",    "Pivot Points Mapped: S2 support bounce. Description of past signals, not a prediction.")
alertcondition(i_showS3R3 and reactR3 and holdR3val and barstate.isconfirmed, "PP: R3 Rejection", "Pivot Points Mapped: R3 resistance rejection. Description of past signals, not a prediction.")
alertcondition(i_showS3R3 and reactS3 and holdS3val and barstate.isconfirmed, "PP: S3 Bounce",    "Pivot Points Mapped: S3 support bounce. Description of past signals, not a prediction.")
// Confluence alerts
alertcondition(fireR1rej and confR1, "PP: R1 Rejection — Confluence ✦", "Pivot Points Mapped: R1 rejection at a confluence level (HTF agreement). Description of past signals, not a prediction.")
alertcondition(fireS1bull and confS1, "PP: S1 Bounce — Confluence ✦",   "Pivot Points Mapped: S1 bounce at a confluence level (HTF agreement). Description of past signals, not a prediction.")
// Evidence-gated (Wilson-backed hold rate)
alertcondition(fireR1rej and backedR1, "PP: R1 Rejection — History Backed", "Pivot Points Mapped: R1 rejection — Wilson lower bound clears 50%. History backed hold. Description of past signals, not a prediction.")
alertcondition(fireS1bull and backedS1, "PP: S1 Bounce — History Backed",   "Pivot Points Mapped: S1 bounce — Wilson lower bound clears 50%. History backed hold. Description of past signals, not a prediction.")
// New session
alertcondition(newSession, "PP: New Session — Pivots Updated", "Pivot Points Mapped: New session started, pivot levels recalculated from prior session HLC. Description of past signals, not a prediction.")
````
