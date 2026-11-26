# SixShooter

- url: https://www.tradingview.com/script/LWIX2nMb-SixShooter/
- type: indicator
- pine_id: PUB;1f441e14d59541d68c23c99d05b77d3f
- version: 1.0

## Description

SixShooter (6SHOT)

A multi-timeframe POC compression and breakout engine for TradingView.
SixShooter combines anchored VWAPs, rolling volume-profile POCs, compression analytics, trend-regime filters, and breakout acceleration logic into a single institutional-style framework.

Built to detect:

Coiled breakout setups before expansion
Trend continuation acceleration (“THRUST”)
Structural rollover tops
Multi-timeframe support/resistance stacking
Regime transitions between accumulation and distribution
Core Concept

6SHOT tracks six major market structure levels simultaneously:

Rank	Level	Description
1	dPOC	Current day anchored VWAP
2	pdPOC	Prior day VWAP
3	wPOC	Current week volume-profile POC
4	pwPOC	Prior week POC
5	mPOC	Current month POC
6	pmPOC	Prior month POC

These levels form a live structural “stack”.

When the stack compresses tightly and directional alignment emerges, the indicator searches for:

breakout conditions,
trend acceleration,
or rollover failure structures.
What Makes SixShooter Different

Unlike traditional indicators that only react to price:

6SHOT measures market structure compression directly.
Uses multi-timeframe POC migration as the primary signal source.
Detects “energy loading” before expansion.
Separates trend continuation from true structural reversals.
Uses higher-timeframe regime filters to reduce noise.

The result is fewer but significantly higher-quality signals.

Price Pane Features
Multi-Timeframe POC Levels

The indicator draws six persistent horizontal support/resistance levels:

Daily VWAP structures
Weekly volume-profile structures
Monthly volume-profile structures

Each level:

extends across the chart,
updates only at current values,
and includes right-edge ranked labels.

The ranking system lets traders instantly visualize:

shallow vs deep support,
stacked bullish structure,
or stacked bearish structure.
Stack Score

6SHOT continuously scores the ordering of all six POCs.

Bullish Stack

Perfect bullish alignment:

dPOC > pdPOC > wPOC > pwPOC > mPOC > pmPOC
Bearish Stack

Perfect bearish alignment:

pmPOC > mPOC > pwPOC > wPOC > pdPOC > dPOC

The score ranges from:

+1.0 → fully bullish structure
0.0 → mixed / transitional
-1.0 → fully bearish structure

A live color-coded readout displays:

BULL
MIXED
BEAR

directly above the POC stack.

Lower Pane Analytics
Compression Engine

6SHOT measures:

(max POC − min POC) / ATR

Then percentile-ranks it over time.

This creates a normalized compression score:

100 = tightest structural compression
0 = widest structural dispersion

Compression alone is not enough for signals.
The indicator additionally requires:

directional alignment,
price coiling,
trend validation,
and regime confirmation.
Signal Types
1. POP Signals

Primary breakout engine.

POP UP

Triggers when:

compression is extreme,
POCs align upward,
price is tightly coiled,
higher-timeframe regime agrees,
and chop filters are cleared.

Designed to detect:

explosive upside expansions,
trend initiations,
and continuation launches.
POP DOWN

Two mechanisms:

Coil Breakdown

Symmetric bearish version of POP UP.

Rollover Breakdown

Independent structural-top detector using:

failed swing highs,
lower highs,
lower lows,
ATR-based drawdown,
and down-sloping structure.

Rollover logic is one-shot and re-arms only after a new swing high.

2. THRUST Signals

Trend acceleration engine.

Designed for:

continuation moves after the original breakout,
momentum expansion,
volatility expansion,
and runaway trends.

Requirements include:

ATR expansion,
decisive candle closes,
directional POC agreement,
and multi-bar momentum thrust.

Useful for catching:

late-stage trend acceleration,
squeeze continuations,
and momentum cascades.
3. PRE-READY Signals

Early-warning compression detector.

Appears before full READY conditions when:

compression is rapidly tightening,
but hasn’t yet reached breakout thresholds.

Useful for:

stalking setups,
preparing alerts,
or anticipating imminent POP conditions.

Disabled by default.

4. Strict Canonical Pattern

The highest-conviction bullish structure in the system.

Requires:

all POCs stacked beneath price,
ideal monthly/weekly/daily ordering,
price glued tightly to dPOC,
and sufficient structural support depth.

When active:

the chart receives a lime structural tint,
and breakout confirmation fires on expansion above prior highs.

This is designed to identify:

loaded continuation structures,
institutional support stacking,
and pre-expansion equilibrium zones.
Regime & Noise Filters
Higher-Timeframe PSAR Filter

Automatically steps one timeframe higher than the current chart.

Examples:

5m → 1H regime
1H → Daily regime
Daily → Weekly regime

Used to suppress:

countertrend coil signals,
weak reversals,
and noisy breakdowns.
PSAR Proximity Gate

Suppresses signals when price is too close to PSAR flip zones.

Purpose:

avoid signals during unstable trend transitions,
reduce chop noise,
and prevent one-bar fakeouts.
Chop Detection

Measures net movement relative to ATR.

If price is oscillating without meaningful progress:

POP signals are blocked,
unless a true range breakout occurs.
Strong Trend Lockout

Prevents countertrend fires in clear macro trends.

Example:

suppress bearish signals during strong long-term uptrends,
suppress bullish signals during strong downtrends.

Built specifically to eliminate:

repeated fake reversals inside runaway trends.
Recency-Weighted POC Engine

Optional decay weighting allows newer volume activity to dominate POC calculations.

ON

More adaptive and predictive.

OFF

Traditional full-period volume-profile behavior.

This creates a balance between:

responsive modern structure tracking,
and classic static POC analysis.
Best Use Cases

6SHOT performs best on:

equities,
crypto,
futures,
and momentum-driven instruments.

Particularly effective for:

swing breakouts,
volatility expansions,
trend continuation,
squeeze detection,
and structural reversals.
Designed Philosophy

Quality over quantity.

6SHOT intentionally filters aggressively:

higher thresholds,
cooldown systems,
anti-flip protection,
trend lockouts,
and regime filters

all exist to suppress low-quality noise.

The goal is not maximum signal frequency.

The goal is:

structurally meaningful signals,
cleaner trend participation,
and earlier recognition of expansion regimes.
Included Features
Multi-timeframe POC stacking
Anchored VWAP integration
Weekly & monthly rolling volume profiles
Compression percentile analytics
Trend acceleration detection
Structural rollover detection
Regime-aware breakout filtering
Anti-whipsaw cooldown engine
Higher-timeframe PSAR confirmation
Dynamic support/resistance labeling
Canonical stacked-support detection
Real-time structural score readout
Recommended Workflow

Many traders use 6SHOT as:

Trend Structure Layer

Use POCs + stack score to understand market positioning.

Setup Detection Layer

Use PRE-READY + READY compression states to stalk opportunities.

Execution Layer

Use POP / THRUST fires for entries.

Risk Layer

Use stacked POCs as dynamic support/resistance zones.

Important Notes

6SHOT is not a standalone trading system.

It is a structural-analysis framework designed to:

identify high-energy market conditions,
classify trend regimes,
and surface asymmetric breakout opportunities.

Best results come when combined with:

market context,
volume analysis,
macro structure,
and disciplined risk management.

## Source Code

````pine
// © Stephen Bae · MIT
//
// Six-Panel POC — single indicator with price-pane levels + lower-pane signals.
// Companion to docs/research/poc-six-panel-findings.md and the Python pipeline
// in scripts/analysis/build_poc_six_panel.py.
//
// PRICE PANE (force_overlay=true):
//   dPOC  / pdPOC   — current day's anchored VWAP / prior day's full-day VWAP
//   wPOC  / pwPOC   — current week's uniform-spread POC / prior full week's POC
//   mPOC  / pmPOC   — current month's POC / prior full month's POC
//   Each POC renders as a single straight horizontal level (no per-bar trail).
//   Right-edge labels carry a static timeframe rank 1=dPOC … 6=pmPOC; when
//     labels would collide they're nudged up by `label_gap_atr × ATR` so the
//     stack stays readable. In the canonical stacked-support setup (T-5 pre
//     pop-up) the timeframe order coincides with shallowest-to-deepest support;
//     in other regimes it doesn't — read the actual price-relative order.
//   Optional lime tint when the strict canonical rule fires (rare).
//
// LOWER PANE:
//   Compression %ile (0–100) of cluster_width_atr — area+line, modern palette.
//     Line color encodes direction-score regime (uses trigger_min_dir):
//       cyan strong  = score ≥ +trigger_min_dir            (POP UP regime)
//       teal soft    = score ≥ +1  (mild up bias)
//       slate        = no directional commitment
//       rose soft    = score ≤ -1  (mild down bias)
//       rose strong  = score ≤ -trigger_min_dir            (POP DOWN regime)
//   Triangles fire on rising-edge POP UP / POP DOWN, gated by cooldown.
//   Optional yellow circle = PRE-READY (compression rising fast, not yet at
//     READY) — off by default.
//
// SIGNAL LOGIC (after quality tightening):
//   READY        = compression ≥ ready_thresh
//   POP UP       = READY AND direction_score ≥ +N AND price_tight
//                          AND weekly-PSAR not down
//   POP DOWN     = ( coil-down OR rollover-down ) AND weekly-PSAR not up
//     coil-down  = READY AND direction_score ≤ -N AND price_tight
//     rollover   = armed by a fresh swing high + lower-high + lower-low +
//                  ≥X ATR drop + down-slope; one-shot per swing high (re-arms
//                  only when a new higher high prints)
//   PRE-READY    = compression rising fast AND already above preready_thresh
//   Strict canonical POP (price pane) = canon_ready rising-edge + close>high[1]

//@version=5
indicator("SixShooter", shorttitle="6SHOT", overlay=true,
     max_bars_back=2000, max_lines_count=20, max_labels_count=40)

// Quality-over-quantity defaults: raised thresholds + cooldown gate keep the
// lower pane quiet until the setup is genuinely loaded. Pre-ready dots are off
// by default — toggle in inputs if you want the earlier whisper.

// ─── INPUTS (simplified — ~22 user-facing knobs) ─────────────────────────
g_grid = "POC profile"
n_bins         = input.int(120, "Bins per profile", minval=30, maxval=400, group=g_grid)
range_atr_w    = input.float(20.0, "Weekly grid half-range (ATR)",  minval=5,  maxval=60,  group=g_grid)
range_atr_m    = input.float(40.0, "Monthly grid half-range (ATR)", minval=10, maxval=120, group=g_grid)
recency_enable = input.bool(true, "Recency-weight (favor fresh activity)", group=g_grid,
     tooltip="ON = recent bars dominate the POC; closer to TV Auto Key Levels and more predictive. OFF = traditional full-period max-volume POC (matches the Python pipeline).")
recency_halflife_w = input.int(20, "Recency half-life (bars)",
     minval=1, maxval=200, group=g_grid,
     tooltip="Bars at which a contribution decays to 50%. Monthly half-life auto-derives as 4× this. Only used when recency-weight is ON.")

g_show = "POC lines + labels"
show_d   = input.bool(true, "Daily",   inline="d", group=g_show)
show_pd  = input.bool(true, "Prev d",  inline="d", group=g_show)
show_w   = input.bool(true, "Weekly",  inline="w", group=g_show)
show_pw  = input.bool(true, "Prev w",  inline="w", group=g_show)
show_m   = input.bool(true, "Monthly", inline="m", group=g_show)
show_pm  = input.bool(true, "Prev m",  inline="m", group=g_show)
show_lbl          = input.bool(true, "Right-edge labels (rank-prefixed, anti-overlap)", group=g_show)
label_offset_bars = input.int(10, "Label offset right (bars past current)", minval=0, maxval=50, group=g_show,
     tooltip="Push the right-edge POC labels this many bars to the right of the last printed bar, so they don't overlap the most recent price action.")
show_score_readout   = input.bool(true, "Stack-score readout above labels", group=g_show,
     tooltip="Print BULL/BEAR/MIXED + numeric stack score (e.g., 'BULL +0.78') as a small label above the topmost POC label. Lets you see when the stack is transitioning between regimes, not just locked at extremes.")

g_sig = "Signal sensitivity"
ready_thresh       = input.float(80, "READY compression threshold (%)",
     minval=30, maxval=99, step=5, group=g_sig,
     tooltip="POC compression %ile required for a POP. Higher = fewer, higher-conviction signals.")
trigger_min_dir    = input.int(4, "Min POC direction agreement (of 6)",
     minval=1, maxval=6, group=g_sig,
     tooltip="How many POCs (of 6) must trend the same direction for a POP. Higher = cleaner stacked alignment required.")
price_tight_thresh = input.float(60, "Min price-tightness for POP (%ile)",
     minval=0, maxval=100, step=5, group=g_sig,
     tooltip="POPs additionally require the recent 20-bar high-low / ATR to be in this tightness percentile. POC compression alone isn't enough — price must also be coiling.")
cooldown_bars      = input.int(12, "POP cooldown (bars)",
     minval=0, maxval=100, group=g_sig,
     tooltip="Bars before another POP in the SAME direction can fire.")
anti_flip_bars     = input.int(10, "Anti-flip lockout (bars)",
     minval=0, maxval=100, group=g_sig,
     tooltip="After a POP fires, the OPPOSITE direction is blocked this many bars. Kills the POP UP → POP DOWN whipsaw inside chop zones.")
chop_net_min       = input.float(2.0, "Min trend strength (net ATR over 20 bars)",
     minval=0.5, maxval=10, step=0.25, group=g_sig,
     tooltip="If |close − close[20]| / ATR is below this, the tape is judged chop and POPs are suppressed (unless the current bar prints a true new 20-bar range high/low — those are real breakouts).")

g_extras = "Extra signals"
rollover_enable       = input.bool(true,  "Rollover POP DOWN",      inline="r", group=g_extras,
     tooltip="One-shot rolling-top POP DOWN, independent of POC compression. Re-arms only when a new swing high prints.")
rollover_min_drop_atr = input.float(2.5,  "drop ATR", minval=0.5, maxval=10, step=0.1, inline="r", group=g_extras)
thrust_enable         = input.bool(true,  "THRUST (acceleration)",  inline="t", group=g_extras,
     tooltip="Price-pane arrow when a regime-aligned trend visibly accelerates: ATR expanding + decisive close + ≥1-ATR thrust in 5 bars. Catches continuation that POP rules miss.")
thrust_atr_mult       = input.float(1.0,  "thrust ATR", minval=0.3, maxval=5.0, step=0.1, inline="t", group=g_extras)
psar_filter_enable    = input.bool(true,  "Higher-TF PSAR regime filter", group=g_extras,
     tooltip="Auto-stepped one TF higher than the chart (1m/5m chart → 1h, 15m/30m → 4h, 1h/4h → 1d, 1d → 1w, 1w → 1M). Suppresses COIL POP DOWN when regime is up and COIL POP UP when regime is down. Rollover bypasses this filter — structural turns often pre-empt the higher-TF flip.")
psar_proximity_enable = input.bool(true,  "PSAR-flip proximity gate", inline="psarp", group=g_extras,
     tooltip="Suppress fires when price is within `min ATR` of the chart-TF PSAR. Near the flip line the SAR is one bar away from inverting — any directional signal there is unreliable. Tighter ATR = stricter gate, fewer signals.")
psar_proximity_atr    = input.float(1.0,  "min ATR", inline="psarp", minval=0.0, maxval=10.0, step=0.1, group=g_extras)
trend_lockout_enable  = input.bool(true,  "Strong-trend counter-lockout", inline="tl", group=g_extras,
     tooltip="Suppresses counter-trend fires when the ticker is in unambiguous trend mode. BEAR signals locked out when close > SMA(200) AND close is within `near %` of the 200-bar high AND ≥5 of 6 POCs trend up. BULL signals locked out symmetrically in downtrends. Kills the bear-orb-in-a-clear-uptrend noise.")
trend_lockout_pct     = input.float(0.10, "near %", inline="tl", minval=0.0, maxval=0.5, step=0.01, group=g_extras)
show_pre_ready        = input.bool(false, "Show PRE-READY dots (early whisper)", group=g_extras)
show_canon            = input.bool(true,  "Show strict canonical POP (price-pane lime)", group=g_extras,
     tooltip="Lime tint + POP arrow on the price pane when the 5-condition stacked-support canonical rule fires.")

// ─── INTERNAL CONSTANTS (not exposed in UI; tweak in source if needed) ───
preready_thresh    = 55.0    // PRE-READY compression %ile
traj_lb            = 5       // bars to look back for POC slope / direction
compress_lb        = 50      // percentile-rank window for cluster-width
label_gap_atr      = 0.55    // min vertical separation between right-edge labels (ATR)
show_rank          = true    // prepend "1 …6 " rank to right-edge labels
price_tight_lb     = 20      // bars for high-low / ATR price-tightness measure
rollover_lb        = 20      // rolling-high lookback for rollover detector
rollover_slope_lb  = 5       // close < close[N] for rollover down-slope
rollover_min_age   = 5       // min bars between swing high and rollover fire
chop_lb            = 20      // net-move lookback for chop detection
recency_halflife_m = recency_halflife_w * 4   // monthly decay derived from weekly knob
thrust_close_pct   = 0.65    // close in top/bottom 35% of bar range
thrust_atr_expand  = 1.10    // ATR(14) ≥ this × ATR(20) for "expanding"
thrust_cooldown    = 8       // bars between THRUST fires
psar_start         = 0.02
psar_inc           = 0.02
psar_max           = 0.20
min_pm_atr         = 0.35    // strict canonical: min pmPOC depth (ATR)
glued_atr          = 0.10    // strict canonical: max |close − dPOC| (ATR)

// ─── COMMON ──────────────────────────────────────────────────────────────
atr14 = ta.atr(14)
atr_eff = na(atr14) or atr14 <= 0 ? close * 0.005 : atr14

is_new_day   = ta.change(time("D"))  != 0
is_new_week  = ta.change(time("W"))  != 0
is_new_month = ta.change(time("M"))  != 0

// Per-bar decay multipliers. decay = 0.5 ^ (1 / halflife) → halflife bars to
// reach 50% weight. 1.0 means no decay (traditional full-period POC).
w_decay = recency_enable ? math.pow(0.5, 1.0 / recency_halflife_w) : 1.0
m_decay = recency_enable ? math.pow(0.5, 1.0 / recency_halflife_m) : 1.0

// ─── DAILY VWAP ─────────────────────────────────────────────────────────
daily_vwap = ta.vwap(hlc3, is_new_day)

var float prev_daily_vwap = na
if is_new_day
    prev_daily_vwap := daily_vwap[1]

// ─── WEEKLY POC ─────────────────────────────────────────────────────────
var float[] w_bins = array.new_float(n_bins, 0.0)
var float w_lo            = na
var float w_step          = na
var float weekly_poc      = na
var float prev_weekly_poc = na

if is_new_week
    prev_weekly_poc := weekly_poc
    weekly_poc      := na
    for i = 0 to n_bins - 1
        array.set(w_bins, i, 0.0)
    half = range_atr_w * atr_eff
    w_lo   := close - half
    w_step := (2 * half) / n_bins
else if recency_enable
    // Age existing bin weights one bar before adding the new bar's volume.
    for i = 0 to n_bins - 1
        array.set(w_bins, i, array.get(w_bins, i) * w_decay)

if not na(w_lo) and not na(w_step) and w_step > 0 and not na(volume) and volume > 0
    lo_i = math.max(0, math.floor((low  - w_lo) / w_step))
    hi_i = math.min(n_bins - 1, math.floor((high - w_lo) / w_step))
    if hi_i >= lo_i
        span = hi_i - lo_i + 1
        vpb  = volume / span
        for i = lo_i to hi_i
            array.set(w_bins, i, array.get(w_bins, i) + vpb)
    max_v = array.max(w_bins)
    if max_v > 0
        idx = array.indexof(w_bins, max_v)
        weekly_poc := w_lo + (idx + 0.5) * w_step

// ─── MONTHLY POC ────────────────────────────────────────────────────────
var float[] m_bins = array.new_float(n_bins, 0.0)
var float m_lo             = na
var float m_step           = na
var float monthly_poc      = na
var float prev_monthly_poc = na

if is_new_month
    prev_monthly_poc := monthly_poc
    monthly_poc      := na
    for i = 0 to n_bins - 1
        array.set(m_bins, i, 0.0)
    half_m = range_atr_m * atr_eff
    m_lo   := close - half_m
    m_step := (2 * half_m) / n_bins
else if recency_enable
    for i = 0 to n_bins - 1
        array.set(m_bins, i, array.get(m_bins, i) * m_decay)

if not na(m_lo) and not na(m_step) and m_step > 0 and not na(volume) and volume > 0
    lo_i = math.max(0, math.floor((low  - m_lo) / m_step))
    hi_i = math.min(n_bins - 1, math.floor((high - m_lo) / m_step))
    if hi_i >= lo_i
        span = hi_i - lo_i + 1
        vpb  = volume / span
        for i = lo_i to hi_i
            array.set(m_bins, i, array.get(m_bins, i) + vpb)
    max_v = array.max(m_bins)
    if max_v > 0
        idx = array.indexof(m_bins, max_v)
        monthly_poc := m_lo + (idx + 0.5) * m_step

// ─── COLORS ──────────────────────────────────────────────────────────────
c_d  = color.new(#3498db, 0)
c_pd = color.new(#3498db, 40)
c_w  = color.new(#e67e22, 0)
c_pw = color.new(#e67e22, 40)
c_m  = color.new(#c0392b, 0)
c_pm = color.new(#c0392b, 40)

// ─── PRICE-PANE LEVELS — STRAIGHT HORIZONTAL LINES ───────────────────────
// Each POC renders as a single horizontal level at its CURRENT value, redrawn
// only on the last bar. No stair-step trail. extend.both makes them act like
// true S/R levels across the visible chart. Status-line plots keep the live
// value visible in the data window without leaving a per-bar squiggle.
plot(daily_vwap,       "dPOC",  color=c_d,  display=display.status_line + display.data_window)
plot(prev_daily_vwap,  "pdPOC", color=c_pd, display=display.status_line + display.data_window)
plot(weekly_poc,       "wPOC",  color=c_w,  display=display.status_line + display.data_window)
plot(prev_weekly_poc,  "pwPOC", color=c_pw, display=display.status_line + display.data_window)
plot(monthly_poc,      "mPOC",  color=c_m,  display=display.status_line + display.data_window)
plot(prev_monthly_poc, "pmPOC", color=c_pm, display=display.status_line + display.data_window)

draw_level(_existing, _val, _col, _width, _style, _show) =>
    line out = _existing
    if barstate.islast
        if not na(out)
            line.delete(out)
            out := na
        if _show and not na(_val)
            out := line.new(bar_index, _val, bar_index + 1, _val,
                 extend=extend.both, color=_col, width=_width, style=_style,
                 force_overlay=true)
    out

var line ln_d  = na
var line ln_pd = na
var line ln_w  = na
var line ln_pw = na
var line ln_m  = na
var line ln_pm = na

ln_d  := draw_level(ln_d,  daily_vwap,       c_d,  2, line.style_solid,  show_d)
ln_pd := draw_level(ln_pd, prev_daily_vwap,  c_pd, 1, line.style_dotted, show_pd)
ln_w  := draw_level(ln_w,  weekly_poc,       c_w,  2, line.style_solid,  show_w)
ln_pw := draw_level(ln_pw, prev_weekly_poc,  c_pw, 1, line.style_dotted, show_pw)
ln_m  := draw_level(ln_m,  monthly_poc,      c_m,  2, line.style_solid,  show_m)
ln_pm := draw_level(ln_pm, prev_monthly_poc, c_pm, 1, line.style_dotted, show_pm)

// ─── STACK-WIDE SCORE (every bar) ────────────────────────────────────────
// stack_score in [-1, +1]:
//   +1 = canonical BULL (top→bottom 1,2,3,4,5,6)
//    0 = scrambled (mixed)
//   -1 = canonical BEAR (top→bottom 6,5,4,3,2,1)
// Drives the BULL/BEAR/MIXED readout label color above the POC stack.
all_pocs_present = not na(daily_vwap) and not na(prev_daily_vwap) and not na(weekly_poc) and not na(prev_weekly_poc) and not na(monthly_poc) and not na(prev_monthly_poc)

float stack_score = na
if all_pocs_present
    sv_live = array.from(daily_vwap, prev_daily_vwap, weekly_poc, prev_weekly_poc, monthly_poc, prev_monthly_poc)
    so_live = array.from(0, 1, 2, 3, 4, 5)
    for i = 0 to 4
        for j = i + 1 to 5
            vi = array.get(sv_live, array.get(so_live, i))
            vj = array.get(sv_live, array.get(so_live, j))
            if vj < vi
                t = array.get(so_live, i)
                array.set(so_live, i, array.get(so_live, j))
                array.set(so_live, j, t)
    int bt  = 0
    int bbt = 0
    for k = 0 to 5
        rk = array.get(so_live, k) + 1
        bt  := bt  + math.abs(rk - (6 - k))
        bbt := bbt + math.abs(rk - (k + 1))
    stack_score := (bbt - bt) / 18.0

stack_color = na(stack_score) ? color.new(color.gray, 0)
     : stack_score >= 0
         ? color.from_gradient(stack_score,  0, 1, color.new(#facc15, 0), color.new(#22c55e, 0))
         : color.from_gradient(stack_score, -1, 0, color.new(#ef4444, 0), color.new(#facc15, 0))

// ─── RIGHT-EDGE LABELS — TIMEFRAME COLORS + SCORE READOUT ───────────────
// On the last bar only: one label per POC in its timeframe color, with
// anti-overlap vertical nudging. A BULL/BEAR/MIXED score-readout badge
// (colored by stack_score) sits above the topmost POC label.
var label lbl_d  = na
var label lbl_pd = na
var label lbl_w  = na
var label lbl_pw = na
var label lbl_m  = na
var label lbl_pm = na
var label score_lbl = na

if barstate.islast
    // Tear down all labels from the previous frame.
    label.delete(lbl_d)
    label.delete(lbl_pd)
    label.delete(lbl_w)
    label.delete(lbl_pw)
    label.delete(lbl_m)
    label.delete(lbl_pm)
    lbl_d  := na
    lbl_pd := na
    lbl_w  := na
    lbl_pw := na
    lbl_m  := na
    lbl_pm := na
    if not na(score_lbl)
        label.delete(score_lbl)
        score_lbl := na

    vals  = array.from(daily_vwap, prev_daily_vwap, weekly_poc, prev_weekly_poc, monthly_poc, prev_monthly_poc)
    txts  = array.from((show_rank ? "1 " : "") + "dPOC",
                       (show_rank ? "2 " : "") + "pdPOC",
                       (show_rank ? "3 " : "") + "wPOC",
                       (show_rank ? "4 " : "") + "pwPOC",
                       (show_rank ? "5 " : "") + "mPOC",
                       (show_rank ? "6 " : "") + "pmPOC")
    cols  = array.from(c_d, c_pd, c_w, c_pw, c_m, c_pm)
    shws  = array.from(show_lbl and show_d,
                       show_lbl and show_pd,
                       show_lbl and show_w,
                       show_lbl and show_pw,
                       show_lbl and show_m,
                       show_lbl and show_pm)

    // Sort indices by value ascending (na sinks last).
    order = array.from(0, 1, 2, 3, 4, 5)
    for i = 0 to 4
        for j = i + 1 to 5
            vi = array.get(vals, array.get(order, i))
            vj = array.get(vals, array.get(order, j))
            swap = (na(vi) and not na(vj)) or (not na(vi) and not na(vj) and vj < vi)
            if swap
                t = array.get(order, i)
                array.set(order, i, array.get(order, j))
                array.set(order, j, t)

    min_gap = label_gap_atr * atr_eff
    float last_y = na
    for k = 0 to 5
        idx = array.get(order, k)
        v   = array.get(vals, idx)
        if not na(v) and array.get(shws, idx)
            display_y = na(last_y) or min_gap <= 0 ? v : math.max(v, last_y + min_gap)
            last_y := display_y

            lbl_text = array.get(txts, idx)
            lbl_col  = array.get(cols, idx)

            // One label per POC in its timeframe color.
            lbl = label.new(bar_index + label_offset_bars, display_y, lbl_text,
                 style=label.style_label_left, color=lbl_col,
                 textcolor=color.white, size=size.normal, force_overlay=true)
            if idx == 0
                lbl_d  := lbl
            else if idx == 1
                lbl_pd := lbl
            else if idx == 2
                lbl_w  := lbl
            else if idx == 3
                lbl_pw := lbl
            else if idx == 4
                lbl_m  := lbl
            else
                lbl_pm := lbl

    // Stack-score readout above the topmost POC label.
    if show_score_readout and not na(last_y) and not na(stack_score)
        score_text = stack_score >=  0.33 ? "▲ BULL "  + str.tostring(stack_score, "+0.00")
             :       stack_score <= -0.33 ? "▼ BEAR "  + str.tostring(stack_score, "+0.00")
             :                              "■ MIXED " + str.tostring(stack_score, "+0.00")
        score_y = last_y + math.max(label_gap_atr, 0.6) * atr_eff
        score_lbl := label.new(bar_index + label_offset_bars, score_y, score_text,
             style=label.style_label_left, color=stack_color,
             textcolor=color.white, size=size.normal, force_overlay=true)

// ─── FEATURES ────────────────────────────────────────────────────────────
all_set = not na(daily_vwap)      and not na(prev_daily_vwap)
     and  not na(weekly_poc)       and not na(prev_weekly_poc)
     and  not na(monthly_poc)      and not na(prev_monthly_poc)
     and  not na(atr14) and atr14 > 0

max_poc = math.max(daily_vwap, prev_daily_vwap, weekly_poc, prev_weekly_poc, monthly_poc, prev_monthly_poc)
min_poc = math.min(daily_vwap, prev_daily_vwap, weekly_poc, prev_weekly_poc, monthly_poc, prev_monthly_poc)
cluster_width_atr = all_set ? (max_poc - min_poc) / atr14 : na

// Compression: 100 = tightest in lookback window, 0 = loosest.
// percentrank must be called every bar for consistency — hoist out of ternary.
cluster_width_for_rank = nz(cluster_width_atr)
pr_raw                 = ta.percentrank(cluster_width_for_rank, compress_lb)
compression_score      = na(cluster_width_atr) ? na : 100 - pr_raw

// Direction: signed count of POC slopes over traj_lb bars (-6 to +6)
slope_sign(_p) =>
    na(_p) or na(_p[traj_lb]) ? 0 : _p > _p[traj_lb] ? 1 : _p < _p[traj_lb] ? -1 : 0

direction_score = slope_sign(daily_vwap)  + slope_sign(prev_daily_vwap)  + slope_sign(weekly_poc) + slope_sign(prev_weekly_poc) + slope_sign(monthly_poc) + slope_sign(prev_monthly_poc)

// Tightening rate: positive when cluster_width is shrinking
compression_rate = na(cluster_width_atr) or na(cluster_width_atr[traj_lb]) ? na
     : cluster_width_atr[traj_lb] - cluster_width_atr

// ─── PRICE-ACTION GATES ──────────────────────────────────────────────────
// Price tightness — percentile rank of (range / ATR). 100 = tightest in
// lookback window. POP UP requires both POC compression AND price coiling.
price_range_raw      = ta.highest(high, price_tight_lb) - ta.lowest(low, price_tight_lb)
price_range_atr      = atr14 > 0 ? price_range_raw / atr14 : na
price_range_for_rank = nz(price_range_atr)
price_tight_pr       = ta.percentrank(price_range_for_rank, compress_lb)
price_tight_score    = na(price_range_atr) ? na : 100 - price_tight_pr
price_tight          = not na(price_tight_score) and price_tight_score >= price_tight_thresh

// Rollover — price has rounded over from a recent high. Independent of POC
// compression. One-shot per swing high: armed when a true new high prints
// (current high > prior bar's rolling 20-bar high), disarmed after firing.
// Stays disarmed through the rest of the downtrend until a NEW swing high
// rearms. Combined with lower-high AND lower-low + ATR-drop + down-slope.
bars_since_high   = -ta.highestbars(high, rollover_lb)
recent_high       = ta.highest(high, rollover_lb)
rollover_drop_atr = atr14 > 0 ? (recent_high - close) / atr14 : na
prior_recent_high = ta.highest(high, rollover_lb)[1]
new_swing_high    = not na(prior_recent_high) and high > prior_recent_high

var bool rollover_armed = false
if new_swing_high
    rollover_armed := true

rollover_down = rollover_enable and rollover_armed
     and bars_since_high >= rollover_min_age
     and not na(rollover_drop_atr) and rollover_drop_atr >= rollover_min_drop_atr
     and not na(close[rollover_slope_lb]) and close < close[rollover_slope_lb]
     and high < high[1]
     and low  < low[1]

// NOTE: disarm moved below — see "Rollover disarm" after bear_fire is
// computed. Disarming here on rollover_down alone caused the bug where
// regime-blocked bars silently disarmed the state machine.

// ─── CHOP DETECTOR ───────────────────────────────────────────────────────
// Net move over the lookback / ATR. Low = oscillating without progress.
// Range-edge breakouts override chop suppression: a true new range-high or
// range-low (vs prior bar's window) is the ONE signal type we still trust
// inside a chop zone — it IS the chop ending.
net_move_atr     = atr14 > 0 and not na(close[chop_lb]) ? math.abs(close - close[chop_lb]) / atr14 : na
in_chop          = not na(net_move_atr) and net_move_atr < chop_net_min
range_high_prior = ta.highest(high, chop_lb)[1]
range_low_prior  = ta.lowest(low,  chop_lb)[1]
break_up         = not na(range_high_prior) and high > range_high_prior
break_down       = not na(range_low_prior)  and low  < range_low_prior
chop_ok_up       = not in_chop or break_up
chop_ok_down     = not in_chop or break_down

// ─── THRUST (acceleration) ───────────────────────────────────────────────
// Independent from POP. Catches trend continuation after the initial coil-pop
// has played out — exactly the SMH $400 → $580 run that fires no POPs.
// ATR baseline = 50-bar (was 20-bar). Longer baseline keeps the expansion
// ratio meaningful deep into a sustained trend — atr14/atr20 flattens after
// ~20 bars of high vol, atr14/atr50 stays elevated through the whole leg.
atr_baseline  = ta.atr(50)
bar_range     = high - low
close_pos     = bar_range > 0 ? (close - low) / bar_range : 0.5
mom_5bar      = not na(close[5]) ? close - close[5] : na
atr_expanding = not na(atr14) and not na(atr_baseline) and atr14 >= thrust_atr_expand * atr_baseline

// Regime alignment + range-expansion + decisive close + momentum thrust.
// Coil-state is irrelevant — these can fire deep in an established trend.
thrust_up   = thrust_enable and atr_expanding
     and close_pos >= thrust_close_pct
     and not na(mom_5bar) and mom_5bar >=  thrust_atr_mult * atr14
     and direction_score >= 1

thrust_down = thrust_enable and atr_expanding
     and close_pos <= (1 - thrust_close_pct)
     and not na(mom_5bar) and mom_5bar <= -thrust_atr_mult * atr14
     and direction_score <= -1

// ─── HIGHER-TF PSAR REGIME ───────────────────────────────────────────────
// Auto-stepped one TF higher than the chart. Daily chart → weekly regime,
// 4h → daily, 1h → 4h, 15m/30m → 4h, intraday → 1h. PSAR below price on the
// higher TF = uptrend regime (blocks COIL POP DOWN); above = downtrend
// (blocks COIL POP UP). Rollover bypasses this — structural turns are
// allowed to fire ahead of the higher-TF flip.
regime_tf = switch timeframe.period
    "1"   => "60"
    "2"   => "60"
    "3"   => "60"
    "5"   => "60"
    "10"  => "60"
    "15"  => "240"
    "30"  => "240"
    "45"  => "240"
    "60"  => "D"
    "120" => "D"
    "180" => "D"
    "240" => "D"
    "D"   => "W"
    "W"   => "M"
    =>       "W"

psar_htf      = request.security(syminfo.tickerid, regime_tf, ta.sar(psar_start, psar_inc, psar_max), barmerge.gaps_off, barmerge.lookahead_off)
close_htf     = request.security(syminfo.tickerid, regime_tf, close, barmerge.gaps_off, barmerge.lookahead_off)
psar_htf_up   = not na(psar_htf) and not na(close_htf) and psar_htf < close_htf
psar_htf_down = not na(psar_htf) and not na(close_htf) and psar_htf > close_htf

// Chart-TF PSAR — used purely for the PROXIMITY gate. When |close − psar|
// is small (< proximity_atr × ATR), the SAR is about to flip and any fire
// is borderline noise. Visible to the user as the dotted PSAR overlay.
psar_chart    = ta.sar(psar_start, psar_inc, psar_max)
psar_dist_atr = atr14 > 0 and not na(psar_chart) ? math.abs(close - psar_chart) / atr14 : na
psar_clear    = not psar_proximity_enable or (not na(psar_dist_atr) and psar_dist_atr >= psar_proximity_atr)

// ─── STRONG-TREND COUNTER-LOCKOUT ────────────────────────────────────────
// Detects unambiguous trend mode and suppresses counter-trend fires. The
// MU case in 2024-26 is the motivating example: 8× uptrend with bear orbs
// scattered through it — every one was a routine pullback that briefly
// flipped direction_score. This gate blocks those when structural evidence
// says we're clearly in one regime.
sma200       = ta.sma(close, 200)
hh200        = ta.highest(high, 200)
ll200        = ta.lowest(low,  200)
dist_from_hh = not na(hh200) and hh200 > 0 ? (hh200 - close) / hh200 : na
dist_from_ll = not na(ll200) and ll200 > 0 ? (close - ll200) / ll200 : na
strong_bull  = trend_lockout_enable
     and not na(sma200) and close > sma200
     and not na(dist_from_hh) and dist_from_hh <= trend_lockout_pct
     and direction_score >= 5
strong_bear  = trend_lockout_enable
     and not na(sma200) and close < sma200
     and not na(dist_from_ll) and dist_from_ll <= trend_lockout_pct
     and direction_score <= -5

// ─── SIGNALS ─────────────────────────────────────────────────────────────
ready          = not na(compression_score) and compression_score >= ready_thresh
regime_ok_up   = not psar_filter_enable or not psar_htf_down
regime_ok_down = not psar_filter_enable or not psar_htf_up
trigger_up     = ready and direction_score >=  trigger_min_dir and price_tight and regime_ok_up and chop_ok_up
// Coil-based POP DOWN now requires price tightness too (symmetric with UP).
// Coil respects regime; rollover bypasses regime because structural tops
// usually print BEFORE the higher-TF PSAR flips down. Both still respect
// chop suppression so we don't fire inside a range.
coil_down      = ready and direction_score <= -trigger_min_dir and price_tight
trigger_down   = ((coil_down and regime_ok_down) or rollover_down) and chop_ok_down

// PRE-READY: earlier signal — not yet at READY, but compression rising fast
pre_ready = not ready
     and not na(compression_score) and compression_score >= preready_thresh
     and not na(compression_rate)  and compression_rate  > 0

// EARLY POP — same gates as trigger_up/coil_down but accepts PRE-READY
// compression instead of full READY. Fires 2-4 bars before the main trigger
// when the coil is loading fast and direction/price are already aligned.
early_compress = not na(compression_score) and compression_score >= preready_thresh
     and not na(compression_rate) and compression_rate > 0
early_up   = early_compress and direction_score >=  trigger_min_dir and price_tight and regime_ok_up   and chop_ok_up
early_down = early_compress and direction_score <= -trigger_min_dir and price_tight and regime_ok_down and chop_ok_down

// Strict canonical READY rule (from findings doc) — price-pane tint
canon_ready = all_set
     and daily_vwap         <= close
     and prev_daily_vwap    <= close
     and weekly_poc         <= close
     and prev_weekly_poc    <= close
     and monthly_poc        <= close
     and prev_monthly_poc   <= close
     and monthly_poc        <  weekly_poc
     and weekly_poc         <= daily_vwap
     and prev_monthly_poc   <  monthly_poc
     and (close - daily_vwap)       <  glued_atr  * atr14
     and (close - prev_monthly_poc) >= min_pm_atr * atr14

// Break-up confirmation: fire on the rising edge of canon_ready, confirmed
// by close taking out the prior bar's high. Old rule (prev_daily_vwap > close[1])
// only fired at new-day rollovers and never matched the findings-doc intent.
canon_trigger = canon_ready and not canon_ready[1] and close > high[1]

// Rising-edge gates — fire a marker once when the state turns on, not on every
// bar it stays on. The histogram below stays per-bar; only the shapes debounce.
// Cooldown counter: bars since the last fire of the same direction. Keeps a
// long ready run from spitting a fresh triangle every time direction_score
// dips one notch and re-crosses.
// UNIFIED FIRE — POP, THRUST, and strict canonical all funnel into ONE
// marker per direction. Shared cooldown + anti-flip counter so a THRUST
// can't fire on top of a POP, and the opposite direction is locked out
// for `anti_flip_bars` after any fire. One language, less visual noise.
var int bars_since_up   = na
var int bars_since_down = na
bars_since_up   := na(bars_since_up)   ? 999 : bars_since_up + 1
bars_since_down := na(bars_since_down) ? 999 : bars_since_down + 1

bull_raw = (early_up     and not early_up[1])
     or    (trigger_up   and not trigger_up[1])
     or    (thrust_up    and not thrust_up[1])
     or    canon_trigger
bear_raw = (early_down   and not early_down[1])
     or    (trigger_down and not trigger_down[1])
     or    (thrust_down  and not thrust_down[1])

// strong_bull suppresses bears (we're in clear uptrend, no shorting), and
// strong_bear suppresses bulls (clear downtrend, no buying).
bull_fire = bull_raw and bars_since_up   >= cooldown_bars and bars_since_down >= anti_flip_bars and psar_clear and not strong_bear
bear_fire = bear_raw and bars_since_down >= cooldown_bars and bars_since_up   >= anti_flip_bars and psar_clear and not strong_bull

if bull_fire
    bars_since_up := 0
if bear_fire
    bars_since_down := 0

// Rollover disarm — only on actual bear fire. Disarming on rollover_down
// alone silently killed re-arming whenever regime/chop blocked the trigger
// (the BTC case where weekly PSAR was still up at the $124k top).
if bear_fire and rollover_down
    rollover_armed := false

// PRE-READY whisper — kept as its own thing (lower-pane dot only). Cooldown
// gated so a long compression run doesn't sprinkle repeated dots.
var int bars_since_pre = na
bars_since_pre := na(bars_since_pre) ? 999 : bars_since_pre + 1
pre_ready_raw  = pre_ready and not pre_ready[1]
pre_ready_e    = pre_ready_raw and bars_since_pre >= cooldown_bars
if pre_ready_e
    bars_since_pre := 0

// ─── FIRE-MARKER COLORS ──────────────────────────────────────────────────
// Modern fintech palette retained for the bull/bear orbs.
col_up_strong   = #22d3ee  // cyan-400
col_down_strong = #f43f5e  // rose-500

// ─── PRICE-PANE: UNIFIED FIRE MARKERS ────────────────────────────────────
// ONE triangle per direction — fires from POP, THRUST, or strict canonical
// (whichever rule trips first wins the cooldown slot). The lime bar tint
// when canon_ready is the only path-specific visual: "strict stacked-support
// pattern is active" — when you see lime + cyan triangle together, that's
// the highest-conviction bull setup.
bgcolor(show_canon and canon_ready ? color.new(color.lime, 88) : na,
     title="Strict canonical pattern active", force_overlay=true)

// Halo-dot fire markers — one soft glowing disc per direction.
plotshape(bull_fire, "BULL", style=shape.circle, location=location.belowbar, color=color.new(col_up_strong,   65), size=size.normal, force_overlay=true)
plotshape(bear_fire, "BEAR", style=shape.circle, location=location.abovebar, color=color.new(col_down_strong, 65), size=size.normal, force_overlay=true)

// PRE-READY whisper on the price pane — tiny yellow dot below the bar.
// Same `show_pre_ready` toggle controls both the lower-pane and price-pane dot.
plotshape(show_pre_ready and pre_ready_e, "PRE-READY (price)",
     style=shape.circle, location=location.belowbar,
     color=color.new(#fbbf24, 0), size=size.tiny, force_overlay=true)

// ─── ALERTS ──────────────────────────────────────────────────────────────
alertcondition(bull_fire,     title="6SHOT BULL fire",
     message="{{ticker}} {{interval}}: BULL signal — POP / THRUST / canonical @ {{close}}")
alertcondition(bear_fire,     title="6SHOT BEAR fire",
     message="{{ticker}} {{interval}}: BEAR signal — POP / THRUST / rollover @ {{close}}")
alertcondition(ready,         title="6SHOT READY (coil loaded)",
     message="{{ticker}} {{interval}}: POC compression at READY threshold @ {{close}}")
alertcondition(pre_ready_e,   title="6SHOT PRE-READY (early whisper)",
     message="{{ticker}} {{interval}}: POC compression rising fast @ {{close}}")
alertcondition(canon_ready,   title="6SHOT Strict canonical active",
     message="{{ticker}} {{interval}}: Strict 5-condition stacked-support pattern active @ {{close}}")
````
