# Trend Efficiency Exhaustion  Regime-Gated & Calibrated

- url: https://www.tradingview.com/script/GKGLNSQB-Trend-Efficiency-Exhaustion-Regime-Gated-Calibrated/
- type: indicator
- pine_id: PUB;478dd82817e44935b6237d0d1d8c05f7
- version: 2.0

## Description

Trend Efficiency Exhaustion — Regime-Gated & Calibrated

What it is

A single-pane oscillator that measures when a trend is losing efficiency and turns that into graded, forward-calibrated exhaustion and ignition signals. It is built around one question — "is this efficiency-exhaustion event actually worth acting on?" — and every component in the script exists to answer that one question rather than to add an independent signal.

It plots, in one pane: an efficiency-gap histogram, a fast efficiency line, event markers, a regime "weather-strip" ribbon, and an information table that states the read in plain language. It is symbol- and timeframe-agnostic; defaults are tuned for NIFTY / BANKNIFTY but a Source input and a VIX-symbol input let you use it on any instrument in any market.

The core idea — efficiency, not a magic multiplier

The Efficiency Ratio is the net move divided by the total path travelled over a window: ER = |close − close[n]| / Σ|close − close[1]|, bounded 0–1. A value near 1 means price moved in a straight, efficient line (trend); near 0 means it wandered (chop).

Reading efficiency at two horizons gives the central signal:

Efficiency Gap = ER_fast − ER_slow. When the fast read rolls over while the slow read is still elevated, the trend is losing efficiency under an otherwise intact trend — the classic exhaustion tell.
Displacement percentile ranks the current leg's travel against recent completed legs on this symbol and timeframe, so "stretched" is defined by the instrument's own recent behaviour rather than a fixed price > k·ATR multiplier.

Exhaustion = a stretched leg with fast efficiency rolling over, under a genuine trend. Ignition = fast efficiency surging from a young leg (continuation).

Why these components belong in ONE script (how the mashup works together)

This is a mashup by design, but it is not a stack of indicators each drawing its own signal. Every layer is a gate or a grade on the same event, feeding one decision pipeline:

Efficiency (dual-horizon Efficiency Ratio) — detects the candidate event (exhaustion / ignition).
Regime engine (Efficiency + ADX + a self-exciting volatility-cluster intensity) — decides when the event is even allowed to fire. Exhaustion is only meaningful inside a real trend; it is suppressed in chaotic, news-driven volatility. The regime is rendered as a continuous 5-state read (strong-trend / trend / neutral / reversion / chaos).
Variance ratio (Lo-MacKinlay) — a second, short-window-reliable lens that confirms a real trend existed to exhaust (VR > 1 = trending, < 1 = mean-reverting, ≈ 1 = random walk), with a significance z-statistic.
Ornstein-Uhlenbeck half-life — quality gate: if the estimated mean-reversion half-life is longer than the evaluation horizon, the expected reversion is too slow to pay off in time, so the exhaustion call is rejected.
Implied-volatility (VIX) state — quality gate: exhaustion is more reliable when implied volatility is elevated but stable (fear present, not spiking). The gate blocks exhaustion during a volatility spike.
Divergence quality — grades each exhaustion on the price↔efficiency divergence at the extreme: the slope of the efficiency drop between successive same-side pivots, how developed the swing is, and whether volume waned into the extreme. Weak-divergence setups are filtered out.
Forward calibration — the scorekeeper. Each fired event is logged as a hypothesis and resolved a fixed number of bars later against an ATR-scaled move, then summarised as a realised hit-rate versus an unconditional base rate.


Take any single layer away and the remaining pipeline still describes the same one event — they are complementary measurements of a single hypothesis (a trend running out of efficiency), which is precisely why they belong together rather than as separate scripts. The regime, variance-ratio, OU and VIX layers never plot their own buy/sell calls; they only decide whether the efficiency-exhaustion event is trustworthy.

The part most scripts skip — forward calibration

Most indicators emit a score and never check whether that score was right. Here, every event is queued and resolved N bars later against moveATR × ATR, in R-multiples. The information table reports, per class (Exhaustion / Ignition):


n — resolved sample size
Hit% with a Wilson 95% interval (so you see how stable the rate is)
Base% — the unconditional same-horizon move rate (the honest benchmark)
Edge = Hit% − Base%, marked * when a z-test clears 95%
MFE / MAE in R (how far it ran for you vs against you)
a recency-weighted hit-rate and a regime-conditional hit-rate for the current regime


If Edge is not positive, the signal is not adding information over chance on your chart — and the script tells you so instead of hiding it.

How to use it

Ribbon = context. Don't fade a strong trend; stand aside in chaos.
Histogram rolling over + a marker = the trigger.
Verdict line = the plain-language call (e.g. "TREND · watch for exhaustion", "EXHAUSTION ↓ · fade the up-move (edge +12%*)", "CHAOS · stand aside"), with the calibrated edge appended when the live class is calibrated.
Chart View: Clean (default) shows only the decision elements; Full adds the slow-ER line, displacement %, all reference levels and the divergence glow for analysis.
Information Table: Compact (default) is the key-info panel — verdict, efficiency/displacement/regime, variance-ratio/OU/VIX, best calibrated edge. Pro adds the full per-class calibration table with confidence intervals, recency and regime-conditional rows.

Treat it as a context-and-confirmation overlay on your own process, not an autotrading signal. Paper-trade first and confirm the Edge column is positive on your symbol and timeframe before relying on a class.

Originality

The novelty is not any single formula — those are credited below — but the closed loop: a self-referential displacement percentile (no fixed multiplier), a regime engine and four independent quality gates that all condition one event, and a forward-calibration layer that scores that event against its own base rate with confidence intervals, recency weighting and regime conditioning. Everything is original Pine; no third-party script code is reused.

Inputs, data & markets

Source (group 1) sets the raw series the whole engine reads — change it to use any instrument in any market.
Defaults are tuned for NIFTY / BANKNIFTY; the VIX Symbol defaults to NSE:INDIAVIX. For other markets, change the Source, the ER horizons and the VIX symbol (e.g. CBOE:VIX). A missing VIX symbol auto-disables that gate.
Inputs are organised institutionally: Source & Efficiency · Regime & Variance-Ratio · Displacement · Events · Quality Gates · Calibration · Display · Theme · Exports. The table colour scheme adapts automatically to a light or dark chart background.

Non-repaint

Efficiency is read on confirmed closes, legs are taken from confirmed pivots, events fire on barstate.isconfirmed, and there are no dynamic-length ta.* calls. Forward statistics are in-sample, close-to-close, with no costs, slippage or stops — a study aid, not a backtest.

Concept credits (original Pine re-derivations)

Efficiency Ratio — Perry Kaufman
Variance-ratio test — Andrew Lo & Craig MacKinlay (1988)
ADX / Directional Movement — J. Welles Wilder
Self-exciting (Hawkes) intensity — Alan G. Hawkes (1971)
Mean-reversion half-life — Ornstein & Uhlenbeck process
Score confidence interval — Edwin B. Wilson (1927)
Dominant-cycle homodyne discriminator — John F. Ehlers

Disclaimer

For education and information only. Not financial advice and not a recommendation to buy or sell anything. Past performance does not guarantee future results. The forward statistics are in-sample and idealised (close-to-close, no costs/slippage/stops). Always do your own analysis and manage your own risk; paper-trade before risking real money.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ══════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                  MPL-2.0
//  Trend Efficiency Exhaustion — Regime-Gated & Calibrated                    v3.0
// ──────────────────────────────────────────────────────────────────────────────
//  v3.0 — WHAT'S NEW
//    • REGIME★ backbone — optionally consume EXP_Regime from the Market Regime
//      Classifier (the suite's shared regime engine). When linked, the external
//      trend/revert state drives the event gate, so this tool stops re-deriving a
//      regime the classifier already computes; the internal ER/ADX/VR/Hawkes engine
//      stays as the standalone fallback and still supplies the CHAOS state.
//    • HARNESS+ — the calibration adds a uniqueness-weighted EFFECTIVE sample size
//      (overlapping forward windows aren't independent), an IN-SAMPLE / OUT-OF-
//      SAMPLE split (the OOS edge is the one to trust), and a multiple-testing
//      DEFLATED significance bar on the per-class edge.
//    • Added the MPL licence header; resolved a conditional stateful ta.* call.
//  WHAT IT PLOTS
//    A single oscillator pane that turns a trend's loss of EFFICIENCY into graded,
//    forward-calibrated exhaustion and ignition signals — with a regime ribbon for
//    context and an information table for the read at a glance.
//
//  THE CORE IDEA — EFFICIENCY, NOT A MAGIC MULTIPLIER
//    Efficiency Ratio: ER = |net move| / |path length| ∈ [0,1]. High = efficient
//    (trending), low = choppy. Read at two horizons:
//      • EFFICIENCY GAP = ER_fast − ER_slow. When the fast read rolls over while
//        the slow read is still elevated, the trend is losing efficiency under an
//        intact trend — the exhaustion tell.
//      • DISPLACEMENT PERCENTILE ranks the current leg's travel against recent
//        completed legs on THIS symbol/timeframe. No fixed "price > k·ATR".
//    EXHAUSTION = stretched leg + fast efficiency rolling over, under a real trend.
//    IGNITION   = fast efficiency surging from a young leg (continuation).
//
//  WHY THESE PIECES ARE ONE TOOL (not a stack of indicators)
//    Everything below feeds ONE decision — "is this efficiency-exhaustion event
//    worth acting on?" — in a single pipeline:
//      1 EFFICIENCY (Kaufman ER, dual horizon)            → detects the event
//      2 REGIME ENGINE (ER + ADX + Hawkes vol-cluster)    → gates WHEN it may fire
//      3 VARIANCE RATIO (Lo-MacKinlay)                    → confirms a real trend
//      4 OU HALF-LIFE                                     → reversion fast enough?
//      5 IMPLIED-VOL (VIX) STATE                          → fear present, not spiking
//      6 DIVERGENCE QUALITY                               → grades the setup
//      7 FORWARD CALIBRATION                              → measures realised edge
//    The regime/VR/OU/VIX/divergence layers are GATES and GRADES on the same event,
//    not independent signals; the calibration layer is the scorekeeper. Remove any
//    one and the remaining pipeline still describes the same single event — they
//    are complementary views of one hypothesis, which is the point of the mashup.
//
//  THE PART NOBODY SHIPS — FORWARD CALIBRATION
//    Each event is a hypothesis (EXH → reversal, IGN → continuation), queued and
//    resolved N bars later vs moveATR·ATR, in R-multiples. The table shows per
//    class:  n · Hit%±Wilson95 · Base% · Edge(Hit−Base, *=95% z) · MFE/MAE(R),
//    plus a recency-weighted and a regime-conditional hit-rate. Base% = the
//    unconditional same-horizon move rate. No naked win-rates.
//
//  REGIME, GATES & ADAPTIVE HORIZONS
//    • 5-state regime blend: strong-trend / trend / neutral / reversion / chaos.
//    • Variance ratio (homoskedastic z) as a second, short-window-reliable lens.
//    • OU half-life and VIX (elevated-but-stable) gate the exhaustion call.
//    • Divergence-quality gate grades each exhaustion (ER-drop slope, swing
//      development, volume waning) and rejects weak setups.
//    • Optional Ehlers homodyne dominant-cycle sets the ER horizons adaptively.
//
//  HOW TO USE
//    Ribbon = context (don't fade a strong trend; stand aside in chaos). Gap
//    histogram rolling over + a marker = the trigger. The table's verdict line is
//    the plain-language call, and the Edge column tells you whether the calibration
//    record actually backs that class. Clean view shows only the decision elements;
//    Full view adds the analyst layers.
//
//  DATA & MARKETS
//    Symbol-agnostic: set the data Source in settings (default close) to use any
//    instrument in any market. Defaults are tuned for NIFTY/BANKNIFTY; the VIX gate
//    defaults to NSE:INDIAVIX — change the Source and VIX Symbol for other assets
//    (e.g. CBOE:VIX). Missing VIX symbol auto-disables that gate.
//
//  CONCEPT CREDITS (original Pine re-derivations; no third-party code reused)
//    Efficiency Ratio — Perry Kaufman · Variance ratio — Lo & MacKinlay (1988)
//    ADX / DMI — J. Welles Wilder · Self-exciting intensity — A. G. Hawkes (1971)
//    Mean-reversion half-life — Ornstein & Uhlenbeck · Score interval — E. B. Wilson (1927)
//    Dominant cycle (homodyne discriminator) — John F. Ehlers · Sample-uniqueness
//    weighting & out-of-sample evaluation — Marcos López de Prado (2018)
//
//  EXPORTS (Data Window, Exports toggle) — consume via input.source():
//    EXP_ERfast · EXP_ERslow · EXP_EffGap · EXP_DispPct · EXP_Event · EXP_Edge ·
//    EXP_Regime · EXP_VR · EXP_OUHalfLife · EXP_VIXpct · EXP_DomCycle · EXP_DivQual ·
//    EXP_EdgeOOS · EXP_EffN
//
//  NON-REPAINT
//    Efficiency on confirmed closes; legs from CONFIRMED pivots; events on
//    barstate.isconfirmed; no dynamic-length ta().
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice. Past performance does
//    not guarantee future results. Forward stats are in-sample, close-to-close, with
//    no costs/slippage/stops — a study aid, not a backtest. Always do your own
//    analysis and manage risk; paper-trade before risking real money.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Trend Efficiency Exhaustion — Regime-Gated & Calibrated", "Efficiency Exhaustion",
     overlay          = false,
     max_labels_count = 500,
     max_bars_back    = 5000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 1 — INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
g1 = "1 · Source & Efficiency"
gR = "2 · Regime & Variance-Ratio"
g2 = "3 · Displacement"
g3 = "4 · Events"
gQ = "5 · Quality Gates (OU · VIX)"
g4 = "6 · Calibration"
g5 = "7 · Display"
gT = "8 · Theme"
gE = "9 · Exports"

src      = input.source(close, "Source", group = g1, tooltip = "Raw data series the whole engine reads. Default close. Change it to use any instrument in any market (e.g. hlc3, another series, or a different symbol via the chart). Defaults throughout are tuned for NIFTY/BANKNIFTY — adjust horizons and the VIX symbol for other assets.")
erFastL  = input.int(10, "ER Fast Horizon",  minval = 3,  maxval = 60,  group = g1, tooltip = "Short Kaufman Efficiency Ratio window — the reactive efficiency read. Used as-is when adaptive horizons are OFF; the manual floor otherwise.")
erSlowL  = input.int(30, "ER Slow Horizon",  minval = 10, maxval = 200, group = g1, tooltip = "Long Efficiency Ratio window — the background trend efficiency.")
useAdaptiveER = input.bool(true, "Adaptive Horizons (Ehlers cycle)", group = g1, tooltip = "Set both ER horizons from the live dominant cycle (Ehlers homodyne discriminator) instead of the fixed values above — the windows track the market's actual rhythm. OFF reverts to the fixed horizons.")
erFastFrac = input.float(0.5, "Fast = cycle ×", minval = 0.2, maxval = 1.0, step = 0.05, group = g1, tooltip = "Adaptive fast horizon = this fraction of the dominant cycle.")
erSlowFrac = input.float(1.5, "Slow = cycle ×", minval = 1.0, maxval = 3.0, step = 0.1, group = g1, tooltip = "Adaptive slow horizon = this multiple of the dominant cycle.")
cycMin   = input.int(6,  "Cycle Min", minval = 4,  maxval = 20,  group = g1)
cycMax   = input.int(50, "Cycle Max", minval = 20, maxval = 120, group = g1)
rollL    = input.int(3,  "Efficiency Rollover Lookback", minval = 1, maxval = 20, group = g1, tooltip = "Fast efficiency is 'rolling over' when it is below its value this many bars ago.")
slowFloor= input.float(0.30, "Trend Floor (slow ER)", minval = 0.05, maxval = 0.90, step = 0.05, group = g1, tooltip = "Exhaustion only counts when slow ER is at least this — i.e. there was a real trend to exhaust.")

// ── regime engine: ER + ADX + Hawkes vol-cluster blended into 5 states ──
adxLen   = input.int(14, "ADX / DMI Length", minval = 5, maxval = 50, group = gR, tooltip = "Directional-movement length; ADX measures trend STRENGTH (not direction).")
strongThr= input.float(0.62, "Strong-Trend score", minval = 0.4, maxval = 0.95, step = 0.02, group = gR, tooltip = "Blended trend score (½·ER + ½·ADX) above this = STRONG TREND.")
trendThr = input.float(0.42, "Trend score", minval = 0.2, maxval = 0.8, step = 0.02, group = gR, tooltip = "Blended trend score above this = TREND.")
hvLen    = input.int(20, "Vol-Cluster TR-MA", minval = 5, maxval = 100, group = gR, tooltip = "Baseline for the volatility shock test (true range vs its average).")
hvShock  = input.float(1.6, "Vol shock (×TR-MA)", minval = 1.1, maxval = 4.0, step = 0.1, group = gR, tooltip = "A bar is a volatility EVENT when its true range exceeds this multiple of the TR average.")
hvAlpha  = input.float(1.0, "Vol-cluster jump (α)", minval = 0.2, maxval = 3.0, step = 0.1, group = gR)
hvBeta   = input.float(0.15, "Vol-cluster decay (β)", minval = 0.02, maxval = 1.0, step = 0.01, group = gR, tooltip = "Per-bar decay of the self-exciting vol intensity. Lower = longer memory.")
chaosPct = input.float(80, "Chaos percentile", minval = 50, maxval = 99, step = 1, group = gR, tooltip = "Vol-cluster intensity above this percentile = CHAOS regime (signals suppressed).")
vrLen    = input.int(120, "Variance-Ratio window", minval = 30, maxval = 400, group = gR, tooltip = "Lo-MacKinlay variance-ratio estimation window. A cheap, short-window-reliable trend-vs-reversion test — replaces noisy local Hurst.")
vrQ      = input.int(4, "Variance-Ratio period q", minval = 2, maxval = 16, group = gR, tooltip = "Aggregation horizon q. VR>1 = trending (positive serial corr); VR<1 = mean-reverting; ≈1 = random walk. A homoskedastic z-stat tests VR≠1.")
useVR    = input.bool(true, "Use VR in regime & gate", group = gR)
vrTrendMin = input.float(1.0, "VR trend floor for EXH", minval = 0.7, maxval = 1.5, step = 0.05, group = gR, tooltip = "Exhaustion requires the variance ratio to confirm a real trend existed (VR ≥ this).")
useRegime = input.bool(false, "Consume external regime (REGIME★)", group = gR, tooltip = "Link the source below to the Market Regime Classifier's EXP_Regime (−2…+2). When on, the external trend/revert state drives the trend gate instead of this tool's own ER/ADX/VR blend — the shared regime backbone. The internal engine still supplies the CHAOS state and the ribbon.")
regSrc    = input.source(close, "Regime source (link to EXP_Regime)", group = gR)

pivotLen = input.int(5,  "Leg Pivot Length", minval = 2, maxval = 30, group = g2, tooltip = "Fractal pivot half-width that bounds a price leg. Larger = bigger legs, more lag.")
legLook  = input.int(60, "Leg Memory (count)", minval = 10, maxval = 300, group = g2, tooltip = "How many recent completed legs form the displacement distribution.")
dispHi   = input.float(0.80, "Stretched Percentile", minval = 0.5, maxval = 0.99, step = 0.01, group = g2, tooltip = "A leg is 'stretched' when its displacement exceeds this fraction of recent legs.")
dispLo   = input.float(0.35, "Ignition Percentile (max)", minval = 0.05, maxval = 0.6, step = 0.05, group = g2, tooltip = "Ignition requires the leg to still be young — displacement below this percentile.")

ignThr   = input.float(0.55, "Ignition ER Threshold", minval = 0.2, maxval = 0.9, step = 0.05, group = g3, tooltip = "Fast ER must cross up through this to flag ignition.")
useIgn   = input.bool(true, "Detect Ignition", group = g3)
minGap   = input.int(6, "Min Bars Between Events", minval = 1, maxval = 60, group = g3, tooltip = "Per-direction cooldown so events don't repeat every bar.")
useVeto  = input.bool(true, "Regime Veto", group = g3, tooltip = "ON: exhaustion requires a TREND/STRONG-TREND regime; ignition requires non-CHAOS.")
useDivGate = input.bool(true, "Divergence-Quality Gate", group = g3, tooltip = "Grade each exhaustion by the quality of the price↔efficiency divergence at the extreme: ER drop between successive same-side pivots (slope), how developed the swing is (bar span), and whether volume waned into the extreme. Weak-divergence exhaustions are rejected.")
divQualMin = input.float(0.35, "Min Divergence Quality", minval = 0.0, maxval = 0.9, step = 0.05, group = g3, tooltip = "Composite 0–1 quality floor for an exhaustion to fire (0.5·slope + 0.3·span + 0.2·volume-waning).")

// ── exhaustion quality gates ──
useOU    = input.bool(true, "OU Half-Life Gate", group = gQ, tooltip = "Reject exhaustion when the Ornstein-Uhlenbeck reversion half-life is longer than the evaluation horizon — i.e. price reverts too slowly to pay off in time. Half-life from the AR(1) coefficient of Δprice on lagged price.")
ouLen    = input.int(60, "OU Window", minval = 20, maxval = 300, group = gQ, tooltip = "Window for the AR(1) regression behind the half-life.")
ouGate   = input.float(1.5, "Reject EXH if half-life > (×horizon)", minval = 0.5, maxval = 4.0, step = 0.1, group = gQ, tooltip = "Half-life ceiling as a multiple of the eval horizon. 1.0 = strictly faster than the horizon.")
useVix   = input.bool(true, "VIX Regime Gate", group = gQ, tooltip = "Exhaustion is more reliable when implied volatility is ELEVATED but STABLE (fear present, not spiking). This gate blocks exhaustion during a volatility spike and flags whether VIX is elevated.")
vixSym   = input.symbol("NSE:INDIAVIX", "VIX Symbol", group = gQ, tooltip = "Implied-volatility index for the gate. Default India VIX for NIFTY/BANKNIFTY; swap to your market's vol index (e.g. CBOE:VIX) for other assets. Missing symbol = gate auto-disables.")
vixLen   = input.int(60, "VIX Percentile Window", minval = 20, maxval = 300, group = gQ)
vixElevPct = input.float(40, "Elevated VIX percentile", minval = 0, maxval = 90, step = 5, group = gQ)
vixSpikeLk = input.int(3, "VIX Spike Lookback", minval = 1, maxval = 20, group = gQ)
vixSpikeThr= input.float(0.15, "VIX Spike Threshold (Δ frac)", minval = 0.03, maxval = 0.6, step = 0.01, group = gQ, tooltip = "VIX rising more than this fraction over the lookback counts as a spike → exhaustion blocked.")

horizon  = input.int(12,  "Eval Horizon (bars)", minval = 3, maxval = 60, group = g4)
moveATR  = input.float(1.0, "Win Threshold (×ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = g4)
atrLen   = input.int(14,  "ATR Length (R unit)", minval = 5, maxval = 50, group = g4)
recencyHL= input.int(50, "Recency Half-Life (events)", minval = 5, maxval = 500, group = g4, tooltip = "The recency-weighted hit-rate weights newer resolutions more: each new event decays the running count toward this half-life (in events). Surfaces regime drift the all-time rate hides.")
harTrainN= input.int(40, "HARNESS+ in-sample events (then OOS)", minval = 10, group = g4, tooltip = "The first N resolved events train (in-sample); every later one is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests   = input.int(2, "Edge significance · N tests (deflation)", minval = 1, maxval = 10, group = g4, tooltip = "Raise the per-class significance bar for the number of classes tested (Bonferroni-style z). 2 classes → z ≈ 2.24.")

viewMode = input.string("Clean", "Chart View", ["Clean", "Full"], group = g5, tooltip = "CLEAN (default): only the decision-relevant elements — efficiency-gap histogram, the fast efficiency line, event markers, regime ribbon, and the event tint. FULL: adds the slow-ER line, displacement %, all reference levels, and the divergence glow for analysis.")
showER   = input.bool(true, "Show ER Lines", group = g5)
showGap  = input.bool(true, "Show Efficiency Gap", group = g5)
showDisp = input.bool(true, "Show Displacement %", group = g5)
showMark = input.bool(true, "Show Event Markers", group = g5)
showOverlay = input.bool(true, "Overlay signals on price (triangles)", group = g5, tooltip = "Plot each exhaustion / ignition event on the PRICE chart as a tiny directional triangle — green up = expect up, red down = expect down.")
showRibbon = input.bool(true, "Regime Weather-Strip", group = g5, tooltip = "A colored ribbon along the pane top showing the regime state bar-by-bar (strong-trend / trend / neutral / reversion / chaos).")
showGlow = input.bool(true, "Transition Glow", group = g5, tooltip = "Full view only — background glow that intensifies as the efficiency gap (fast−slow ER) diverges.")
showVerdict = input.bool(true, "Plain-Language Verdict", group = g5, tooltip = "A one-line read at the top of the dashboard: regime + whether a setup is live + what it implies + the calibrated edge.")
showDash = input.bool(true, "Show Dashboard", group = g5)
dashMode = input.string("Compact", "Information Table", ["Compact", "Pro"], group = g5)
dashPos  = input.string("Top Right", "Dashboard Position", ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)

themeMode = input.string("Auto", "Theme", ["Auto", "Dark", "Light"], group = gT)
upColI    = input.color(#21D7AC, "Bull / Up",  group = gT)
dnColI    = input.color(#F2547B, "Bear / Down", group = gT)
neuColI   = input.color(#58A6FF, "Accent",     group = gT)

showEXP  = input.bool(true, "Emit EXP_* exports", group = gE)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 2 — THEME, HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_bg     = chart.bg_color
_bgLum  = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
isLight = themeMode == "Light" or (themeMode == "Auto" and _bgLum > 140)

darken(color c, float f) => color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f, color.t(c))

cBull = isLight ? darken(upColI, 0.80) : upColI
cBear = isLight ? darken(dnColI, 0.80) : dnColI
cAcc  = isLight ? darken(neuColI, 0.80) : neuColI
cNeu  = isLight ? #57606A : #8B949E
cTxt  = isLight ? #0A0A0A : #E6EDF3
cDim  = isLight ? #9AA4B2 : #484F58
cPanel= isLight ? #F2F4F8 : #0D1117
cHead = isLight ? #E2E6ED : #161B22
cGrid = isLight ? #C4CAD4 : #21262D

f_dashPos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 3 — EFFICIENCY RATIO (dual horizon) + ATR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_er(float s, int len) =>
    float net  = math.abs(s - s[len])
    float path = 0.0
    for i = 0 to len - 1
        path += math.abs(s[i] - s[i + 1])
    path > 0 ? net / path : 0.0

// Lo-MacKinlay variance ratio: VR(q) = Var(q-period return) / (q · Var(1-period
// return)). Random walk → VR≈1; VR>1 trending (positive serial correlation);
// VR<1 mean-reverting. Cheap and reliable on short windows — the second regime
// lens, in place of noisy local Hurst. Returns [VR, homoskedastic z-stat].
f_vr(float s, int q, int N) =>
    float vr = na
    float z  = na
    if N > q + 2
        float mu = 0.0
        for i = 0 to N - 1
            mu += s[i] - s[i + 1]
        mu := mu / N
        float sa = 0.0
        for i = 0 to N - 1
            float d = (s[i] - s[i + 1]) - mu
            sa += d * d
        sa := sa / (N - 1)
        float sc = 0.0
        for t = 0 to N - q
            float R = 0.0
            for j = 0 to q - 1
                R += s[t + j] - s[t + j + 1]
            float d = R - q * mu
            sc += d * d
        float m = q * (N - q + 1) * (1.0 - q / float(N))
        if m > 0 and sa > 0
            sc := sc / m
            vr := sc / (q * sa)
            float phi = 2.0 * (2.0 * q - 1.0) * (q - 1.0) / (3.0 * q)
            z := phi > 0 ? math.sqrt(float(N)) * (vr - 1.0) / math.sqrt(phi) : na
    [vr, z]

// Ehlers Homodyne Discriminator — measures the dominant cycle period from the
// analytic signal (Hilbert-transform In-phase/Quadrature, smoothed, phase change
// per bar). All state is recursive, so it lives at global scope. The cycle then
// sets the ER horizons adaptively, so "fast" and "slow" track the market's rhythm
// instead of fixed 10/30.
float cyPrice = hl2
var float ehSm    = 0.0
var float ehDt    = 0.0
var float ehI1    = 0.0
var float ehQ1    = 0.0
var float ehJI    = 0.0
var float ehJQ    = 0.0
var float ehI2    = 0.0
var float ehQ2    = 0.0
var float ehRe    = 0.0
var float ehIm    = 0.0
var float ehPer   = 0.0
var float ehSmPer = 0.0
if bar_index > 6
    float a = 0.075 * nz(ehPer[1]) + 0.54
    ehSm := (4.0 * cyPrice + 3.0 * cyPrice[1] + 2.0 * cyPrice[2] + cyPrice[3]) / 10.0
    ehDt := (0.0962 * ehSm + 0.5769 * nz(ehSm[2]) - 0.5769 * nz(ehSm[4]) - 0.0962 * nz(ehSm[6])) * a
    ehQ1 := (0.0962 * ehDt + 0.5769 * nz(ehDt[2]) - 0.5769 * nz(ehDt[4]) - 0.0962 * nz(ehDt[6])) * a
    ehI1 := nz(ehDt[3])
    ehJI := (0.0962 * ehI1 + 0.5769 * nz(ehI1[2]) - 0.5769 * nz(ehI1[4]) - 0.0962 * nz(ehI1[6])) * a
    ehJQ := (0.0962 * ehQ1 + 0.5769 * nz(ehQ1[2]) - 0.5769 * nz(ehQ1[4]) - 0.0962 * nz(ehQ1[6])) * a
    float i2t = ehI1 - ehJQ
    float q2t = ehQ1 + ehJI
    ehI2 := 0.2 * i2t + 0.8 * nz(ehI2[1])
    ehQ2 := 0.2 * q2t + 0.8 * nz(ehQ2[1])
    float ret = ehI2 * nz(ehI2[1]) + ehQ2 * nz(ehQ2[1])
    float imt = ehI2 * nz(ehQ2[1]) - ehQ2 * nz(ehI2[1])
    ehRe := 0.2 * ret + 0.8 * nz(ehRe[1])
    ehIm := 0.2 * imt + 0.8 * nz(ehIm[1])
    float per = nz(ehPer[1])
    if ehIm != 0.0 and ehRe != 0.0
        per := 2.0 * math.pi / math.atan(ehIm / ehRe)
    float pp = nz(ehPer[1])
    if pp > 0.0
        per := math.min(per, 1.5 * pp)
        per := math.max(per, 0.67 * pp)
    per := math.max(float(cycMin), math.min(float(cycMax), per))
    ehPer   := 0.2 * per + 0.8 * nz(ehPer[1])
    ehSmPer := 0.33 * ehPer + 0.67 * nz(ehSmPer[1])
float domCycle = bar_index > 6 and ehSmPer > 0.0 ? ehSmPer : na

int erFastLen = useAdaptiveER and not na(domCycle) ? math.max(3,  math.min(60,  int(math.round(domCycle * erFastFrac)))) : erFastL
int erSlowLen = useAdaptiveER and not na(domCycle) ? math.max(10, math.min(200, int(math.round(domCycle * erSlowFrac)))) : erSlowL

float erFast = f_er(src, erFastLen)
float erSlow = f_er(src, erSlowLen)
float gap    = erFast - erSlow
bool  fastFall = erFast < erFast[rollL]
float atr    = ta.atr(atrLen)

// ── ADX (trend strength) ──
[diPlus, diMinus, adxV] = ta.dmi(adxLen, adxLen)

// ── Hawkes self-exciting volatility-cluster intensity ──
float trv  = ta.tr(true)
float trMA = ta.sma(trv, hvLen)
bool  volShock = not na(trMA) and trMA > 0 and trv > trMA * hvShock
var float hawkVol = 0.0
if barstate.isconfirmed
    hawkVol := hawkVol * math.exp(-hvBeta) + (volShock ? hvAlpha : 0.0)
float hawkPct = ta.percentrank(hawkVol, 200)

// ── Lo-MacKinlay variance ratio (second regime lens) ──
[vr, vrZ] = f_vr(src, vrQ, vrLen)
string vrTxt = na(vr) ? "—" : vr > 1.0 ? "trend" : vr < 1.0 ? "revert" : "rw"
bool   vrSig = not na(vrZ) and math.abs(vrZ) >= 1.96

// ── OU mean-reversion half-life (AR(1) on Δprice vs lagged price) ──
float dP    = src - src[1]
float pLag  = src[1]
float ouCor = ta.correlation(dP, pLag, ouLen)
float ouSdY = ta.stdev(dP, ouLen)
float ouSdX = ta.stdev(pLag, ouLen)
float ouB   = (not na(ouCor) and ouSdX > 0) ? ouCor * ouSdY / ouSdX : na
float halfLife = (not na(ouB) and ouB < 0 and (1.0 + ouB) > 0) ? -math.log(2.0) / math.log(1.0 + ouB) : na

// ── implied-volatility (VIX) context ──
float vixRaw = request.security(vixSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float vixPctRaw = ta.percentrank(vixRaw, vixLen)          // hoisted to top level (stateful ta.* must not sit behind a ternary)
float vixPct = (not na(vixRaw)) ? vixPctRaw : na
bool  vixSpike = (not na(vixRaw) and not na(vixRaw[vixSpikeLk]) and vixRaw[vixSpikeLk] > 0) ? (vixRaw / vixRaw[vixSpikeLk] - 1.0) > vixSpikeThr : false
bool  vixStable   = not useVix or na(vixRaw) or not vixSpike
bool  vixElevated = not na(vixPct) and vixPct >= vixElevPct

// ── 5-state regime blend: 1 STRONG-TREND · 2 TREND · 3 NEUTRAL · 4 REVERSION · 5 CHAOS ──
float erN   = math.min(1.0, erSlow / 0.80)
float adxN  = math.min(1.0, nz(adxV) / 40.0)
float trendScore = 0.5 * erN + 0.5 * adxN
bool  chaosNow   = not na(hawkPct) and hawkPct >= chaosPct
bool  revertNow  = (not useVR or na(vr) or vr < 1.0) and erSlow < slowFloor
int   regID = 3
if chaosNow
    regID := 5
else if trendScore >= strongThr
    regID := 1
else if trendScore >= trendThr
    regID := 2
else if revertNow
    regID := 4
else
    regID := 3
f_regName(int id) => id == 1 ? "STRONG TREND" : id == 2 ? "TREND" : id == 3 ? "NEUTRAL" : id == 4 ? "REVERSION" : "CHAOS"
f_regCol(int id) => id == 1 ? darken(cBull, isLight ? 0.7 : 1.0) : id == 2 ? cBull : id == 3 ? cNeu : id == 4 ? cAcc : cBear
string regimeTxt = f_regName(regID)
color  regimeCol = f_regCol(regID)
// REGIME★ — when an external regime is linked and valid, its trend/revert state drives the
// trend gate (shared backbone); else fall back to the internal blend. Chaos stays internal.
int    regExt    = (useRegime and not na(regSrc) and math.abs(regSrc) <= 2.5) ? int(math.round(regSrc)) : na
bool   regTrend  = not na(regExt) ? regExt >= 1 : (regID == 1 or regID == 2)
bool   regChaos  = regID == 5

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 4 — LEGS + SELF-CALIBRATING DISPLACEMENT PERCENTILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float ph = ta.pivothigh(pivotLen, pivotLen)
float pl = ta.pivotlow(pivotLen, pivotLen)

var float[] dispArr = array.new<float>()
var float lastPH = na
var float lastPL = na
var int   legDir = 0          // +1 up-leg in progress, -1 down-leg
var float anchor = na         // price where the current leg began (opposite pivot)

// divergence-quality state: previous same-side pivot price, ER, volume, bar
var float prevPHp   = na
var float prevPHer  = na
var float prevPHvol = na
var int   prevPHbar = na
var float prevPLp   = na
var float prevPLer  = na
var float prevPLvol = na
var int   prevPLbar = na
var float divQualH = na       // bearish-divergence quality at the last swing high
var float divQualL = na       // bullish-divergence quality at the last swing low

f_divQual(bool extreme, float erDrop, int span, bool volWane) =>
    float q1 = (extreme and erDrop > 0.0) ? math.min(1.0, erDrop / 0.30) : 0.0
    float q2 = math.min(1.0, span / float(legLook))
    float q3 = volWane ? 1.0 : 0.0
    0.5 * q1 + 0.3 * q2 + 0.2 * q3

f_pushDisp(float d) =>
    if not na(d) and d > 0
        dispArr.push(d)
        while dispArr.size() > legLook
            dispArr.shift()

if not na(ph)
    // an up-leg just completed: from last pivot low to this high
    if not na(lastPL)
        f_pushDisp(ph - lastPL)
    // divergence quality at this high vs the previous high (ER read at the pivot)
    float erAtPiv  = erFast[pivotLen]
    float volAtPiv = volume[pivotLen]
    if not na(prevPHp) and not na(prevPHer) and not na(erAtPiv)
        divQualH := f_divQual(ph > prevPHp, prevPHer - erAtPiv, bar_index - prevPHbar, not na(prevPHvol) and not na(volAtPiv) and volAtPiv < prevPHvol)
    prevPHp   := ph
    prevPHer  := erAtPiv
    prevPHvol := volAtPiv
    prevPHbar := bar_index
    lastPH := ph
    legDir := -1               // now a down-leg begins from this high
    anchor := ph
if not na(pl)
    if not na(lastPH)
        f_pushDisp(lastPH - pl)
    float erAtPivL  = erFast[pivotLen]
    float volAtPivL = volume[pivotLen]
    if not na(prevPLp) and not na(prevPLer) and not na(erAtPivL)
        divQualL := f_divQual(pl < prevPLp, prevPLer - erAtPivL, bar_index - prevPLbar, not na(prevPLvol) and not na(volAtPivL) and volAtPivL < prevPLvol)
    prevPLp   := pl
    prevPLer  := erAtPivL
    prevPLvol := volAtPivL
    prevPLbar := bar_index
    lastPL := pl
    legDir := 1                // up-leg begins from this low
    anchor := pl

// candidate divergence quality for the leg currently in progress
float divCand = legDir > 0 ? divQualH : legDir < 0 ? divQualL : na

// in-progress leg displacement and its percentile vs recent completed legs
float curDisp = na
if legDir != 0 and not na(anchor)
    curDisp := legDir > 0 ? src - anchor : anchor - src

f_pct(float x) =>
    float r = na
    int n = dispArr.size()
    if n >= 5 and not na(x)
        int c = 0
        for i = 0 to n - 1
            if dispArr.get(i) <= x
                c += 1
        r := c / float(n)
    r

float dispPct = f_pct(curDisp)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5 — CALIBRATION STATE  (per-class forward resolution)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// classes: 1 EXH (reversal) · 2 IGN (continuation)    regimes: 1..5 (see f_regName)
int NCLS = 2
int NREG = 5
f_clsName(int id) => id == 1 ? "EXH" : id == 2 ? "IGN" : "—"
f_clsLong(int id) => id == 1 ? "Exhaustion" : id == 2 ? "Ignition" : "—"
f_regShort(int id) => id == 1 ? "ST" : id == 2 ? "TR" : id == 3 ? "NE" : id == 4 ? "RV" : id == 5 ? "CH" : "—"

type Pend
    int   cls
    int   dir
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    bool  done
    int   reg
    float uniq

type Base
    float entry
    float atr0
    int   bidx

var array<Pend> pend = array.new<Pend>()
var array<Base> bq   = array.new<Base>()

var int[]   clsN   = array.new<int>(NCLS + 1, 0)
var int[]   clsW   = array.new<int>(NCLS + 1, 0)
var float[] clsMFE = array.new<float>(NCLS + 1, 0.0)
var float[] clsMAE = array.new<float>(NCLS + 1, 0.0)
var bool[]  clsSig = array.new<bool>(NCLS + 1, false)

// recency-weighted (exponentially-decayed) counts per class
var float[] clsNd  = array.new<float>(NCLS + 1, 0.0)
var float[] clsWd  = array.new<float>(NCLS + 1, 0.0)
float recDecay = math.pow(0.5, 1.0 / recencyHL)

// regime-conditional counts, flattened idx = (cls-1)*NREG + (reg-1)
var int[] clsNrg = array.new<int>(NCLS * NREG, 0)
var int[] clsWrg = array.new<int>(NCLS * NREG, 0)

var int baseN = 0
var int baseW = 0

// HARNESS+ — uniqueness-weighted effective-N + in-sample / out-of-sample overall edge
var float harTotW = 0.0
var float harHitW = 0.0
var int   harIsTot = 0
var int   harIsHit = 0
var int   harOosTot = 0
var int   harOosHit = 0
var int   harResolved = 0

var int lastExhBar = -100000
var int lastIgnBar = -100000

f_z(int w, int n, float p0) =>
    float r = na
    if n > 0 and not na(p0) and p0 > 0.0 and p0 < 1.0
        float ph2 = w / float(n)
        float se = math.sqrt(p0 * (1.0 - p0) / n)
        r := se > 0 ? (ph2 - p0) / se : na
    r

// Wilson score interval half-width (95%) — honest stability of the hit-rate.
f_wilsonHalf(int w, int n) =>
    float r = na
    if n > 0
        float zc = 1.96
        float p  = w / float(n)
        float den = 1.0 + zc * zc / n
        float marg = zc * math.sqrt(p * (1.0 - p) / n + zc * zc / (4.0 * n * n))
        r := marg / den
    r

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 6 — EVENT DETECTION  (confirmed bars only — non-repaint)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int   evtCls = 0
int   evtDir = 0
bool  igCross = ta.crossover(erFast, ignThr)

if barstate.isconfirmed
    // exhaustion gates: a real trend to exhaust (regime + VR), reversion fast
    // enough to pay off (OU half-life), and IV elevated-but-stable (VIX)
    bool gTrend = (not useVeto or regTrend)
    bool gVR    = (not useVR or na(vr) or vr >= vrTrendMin)
    bool gOU    = (not useOU or (not na(halfLife) and halfLife <= horizon * ouGate))
    bool gVix   = vixStable
    bool gDiv   = (not useDivGate or (not na(divCand) and divCand >= divQualMin))
    bool exhValid = gTrend and gVR and gOU and gVix and gDiv
    bool notChop  = not regChaos

    // EXHAUSTION — stretched leg + fast efficiency rolling over, gated
    if legDir != 0 and not na(dispPct) and dispPct >= dispHi and fastFall and exhValid
        if legDir > 0 and (bar_index - lastExhBar) >= minGap
            evtCls := 1
            evtDir := -1                 // up-leg exhausting → expect down
            lastExhBar := bar_index
        else if legDir < 0 and (bar_index - lastExhBar) >= minGap
            evtCls := 1
            evtDir := 1
            lastExhBar := bar_index

    // IGNITION — fast efficiency surges from a young leg (continuation)
    if useIgn and evtCls == 0 and igCross and not na(dispPct) and dispPct <= dispLo and legDir != 0 and (not useVeto or notChop)
        if (bar_index - lastIgnBar) >= minGap
            evtCls := 2
            evtDir := legDir             // continue the leg
            lastIgnBar := bar_index

    if evtCls != 0
        float uw = 1.0 / (1.0 + pend.size())
        pend.push(Pend.new(evtCls, evtDir, src, atr, bar_index, 0.0, 0.0, false, regID, uw))

// resolve pending events
if barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Pend p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            p.mfe := math.max(p.mfe, favor   / p.atr0)
            p.mae := math.max(p.mae, adverse / p.atr0)
            if bar_index - p.bidx >= horizon
                p.done := true
                float fwd = p.dir > 0 ? (close - p.entry) : (p.entry - close)
                bool  win = fwd >= moveATR * p.atr0
                // HARNESS+ overall: uniqueness-weighted effective-N + in-sample / out-of-sample split
                harTotW += p.uniq
                harHitW := win ? harHitW + p.uniq : harHitW
                if harResolved < harTrainN
                    harIsTot += 1
                    harIsHit := win ? harIsHit + 1 : harIsHit
                else
                    harOosTot += 1
                    harOosHit := win ? harOosHit + 1 : harOosHit
                harResolved += 1
                clsN.set(p.cls, clsN.get(p.cls) + 1)
                if win
                    clsW.set(p.cls, clsW.get(p.cls) + 1)
                clsMFE.set(p.cls, clsMFE.get(p.cls) + p.mfe)
                clsMAE.set(p.cls, clsMAE.get(p.cls) + p.mae)
                // recency-weighted (decay existing, add this)
                clsNd.set(p.cls, clsNd.get(p.cls) * recDecay + 1.0)
                clsWd.set(p.cls, clsWd.get(p.cls) * recDecay + (win ? 1.0 : 0.0))
                // regime-conditional bucket
                if p.reg >= 1 and p.reg <= NREG
                    int ix = (p.cls - 1) * NREG + (p.reg - 1)
                    clsNrg.set(ix, clsNrg.get(ix) + 1)
                    if win
                        clsWrg.set(ix, clsWrg.get(ix) + 1)
                pend.remove(i)

// base-rate sampling (symmetric: did a moveATR move occur either way within horizon)
if barstate.isconfirmed
    bq.push(Base.new(src, atr, bar_index))
    if bq.size() > 0
        for i = bq.size() - 1 to 0
            Base b = bq.get(i)
            if bar_index - b.bidx >= horizon
                bool any = math.max(high - b.entry, b.entry - low) >= moveATR * b.atr0
                baseN += 1
                if any
                    baseW += 1
                bq.remove(i)

float baseP = baseN > 0 ? baseW / float(baseN) : na

// HARNESS+ overall metrics — effective sample size, in-sample and out-of-sample edge
float harEffN    = harTotW
float harIsHitP  = harIsTot  > 0 ? harIsHit  / float(harIsTot)  * 100.0 : na
float harOosHitP = harOosTot > 0 ? harOosHit / float(harOosTot) * 100.0 : na
float harOosEdge = (not na(harOosHitP) and not na(baseP)) ? harOosHitP - baseP * 100.0 : na
float harOosCi   = f_wilsonHalf(harOosHit, harOosTot) * 100.0
bool  harOosStar = harOosTot >= 10 and not na(harOosHitP) and not na(baseP) and (harOosHitP - harOosCi) > baseP * 100.0
// multiple-testing deflated significance bar
float zDefl = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58

int sigCls = 0
if barstate.isconfirmed
    for id = 1 to NCLS
        if clsN.get(id) >= 5 and not clsSig.get(id)
            float z = f_z(clsW.get(id), clsN.get(id), baseP)
            float hit = clsW.get(id) / float(clsN.get(id))
            if not na(z) and z > zDefl and not na(baseP) and hit > baseP
                clsSig.set(id, true)
                sigCls := id

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 7 — PLOTS  (oscillator pane)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool fullView = viewMode == "Full"

// CLEAN view keeps only what a decision needs: the efficiency-gap histogram (momentum
// building vs fading), the fast efficiency line, event markers, the regime ribbon
// and the event tint. FULL view adds the slow-ER line, displacement %, every
// reference level and the divergence glow.

// efficiency gap column (fast − slow) — GREEN while momentum is building, RED as
// efficiency fades (the exhaustion tell). Brightness scales with the gap size, so a
// tall green bank rolling over into red reads at a glance.
color gapCol = gap >= 0 ? color.from_gradient(math.min(gap, 0.5), 0.0, 0.5, color.new(cBull, 74), color.new(cBull, 14)) : color.from_gradient(math.max(gap, -0.5), -0.5, 0.0, color.new(cBear, 14), color.new(cBear, 74))
plot(showGap ? gap : na, "Efficiency Gap", color = gapCol, style = plot.style_columns, histbase = 0.0)

// fast efficiency line with a soft glow for prominence; slow line (Full only)
plot(showER ? erFast : na, "ER Fast glow", color = color.new(cBull, 82), linewidth = 6, display = display.pane)
plot(showER ? erFast : na, "ER Fast",      color = color.new(cBull, 0),  linewidth = 2, display = display.pane)
plot(showER and fullView ? erSlow : na, "ER Slow", color = color.new(cAcc, 0), linewidth = 1)

// displacement percentile — Full only
plot(showDisp and fullView ? dispPct : na, "Displacement %", color = color.new(cBear, 20), linewidth = 1, style = plot.style_stepline)

// reference levels — Stretched (the exhaustion threshold) always; the rest Full only
hline(dispHi, "Stretched", color = color.new(dnColI, 70), linestyle = hline.style_dotted)
plot(fullView ? slowFloor : na, "Trend Floor", color = color.new(neuColI, 60), style = plot.style_linebr)
plot(fullView ? ignThr    : na, "Ignition Lvl", color = color.new(upColI, 75), style = plot.style_linebr)

// event markers (pane) — coloured by EXPECTED direction. Triangles = exhaustion
// (reversal), diamonds = ignition (continuation); green = expect up, red = expect down.
plotshape(showMark and evtCls == 1 and evtDir > 0 ? erFast : na, "Exh up",   shape.triangleup,   location.bottom, color = cBull, size = size.small)
plotshape(showMark and evtCls == 1 and evtDir < 0 ? erFast : na, "Exh down", shape.triangledown, location.top,    color = cBear, size = size.small)
plotshape(showMark and evtCls == 2 and evtDir > 0 ? erFast : na, "Ign up",   shape.diamond, location.bottom, color = color.new(cBull, 0), size = size.tiny)
plotshape(showMark and evtCls == 2 and evtDir < 0 ? erFast : na, "Ign down", shape.diamond, location.top,    color = color.new(cBear, 0), size = size.tiny)

// PRICE overlay signals — tiny directional triangles (green up = expect up, red down = expect down)
bool sigUpO = evtCls != 0 and evtDir > 0
bool sigDnO = evtCls != 0 and evtDir < 0
plotshape(showOverlay and sigUpO, "Signal up (overlay)",   shape.triangleup,   location.belowbar, color = cBull, size = size.tiny, force_overlay = true)
plotshape(showOverlay and sigDnO, "Signal down (overlay)", shape.triangledown, location.abovebar, color = cBear, size = size.tiny, force_overlay = true)

// regime WEATHER-STRIP — a colored ribbon along the top of the pane, recolored
// each bar by the 5-state regime (strong-trend / trend / neutral / reversion / chaos)
rbTop = plot(showRibbon ? 1.10 : na, "rib top", color = na, display = display.none)
rbBot = plot(showRibbon ? 1.04 : na, "rib bot", color = na, display = display.none)
fill(rbTop, rbBot, color = showRibbon ? color.new(regimeCol, 20) : na, title = "Regime Weather-Strip")

// event TINT (both views) — highlights the decision bar; transition GLOW Full only
float gapMag = math.abs(gap)
color glowC  = showGlow and fullView ? color.new(gap >= 0 ? cBull : cBear, int(math.max(70.0, 94.0 - gapMag * 60.0))) : na
color exhTint= evtCls == 1 ? color.new(evtDir < 0 ? cBear : cBull, 78) : (evtCls == 2 ? color.new(cAcc, 86) : na)
bgcolor(not na(exhTint) ? exhTint : glowC, title = "Event tint")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8 — DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_dashPos(dashPos), 7, NCLS + 8, frame_color = cGrid, frame_width = 1, border_color = cGrid, border_width = 1)

f_cell(int c, int r, string txt, color tc, color bg, string sz) =>
    table.cell(dash, c, r, txt, text_color = tc, bgcolor = bg, text_size = sz, text_halign = text.align_center)

f_regHit(int cls, int reg) =>
    float r = na
    if cls >= 1 and cls <= NCLS and reg >= 1 and reg <= NREG
        int ix = (cls - 1) * NREG + (reg - 1)
        int n = clsNrg.get(ix)
        if n > 0
            r := clsWrg.get(ix) / float(n)
    r

if showDash and barstate.islast
    string sz = "small"
    table.clear(dash, 0, 0, 6, NCLS + 7)

    // header becomes a plain-language VERDICT — regime + live setup + what it implies
    string vTxt = "EFFICIENCY EXHAUSTION"
    color  vFg  = cTxt
    if showVerdict
        if regChaos
            vTxt := "CHAOS · stand aside"
            vFg := cBear
        else if evtCls == 1
            vTxt := evtDir < 0 ? "EXHAUSTION ↓ · fade the up-move" : "EXHAUSTION ↑ · fade the down-move"
            vFg := evtDir < 0 ? cBear : cBull
        else if evtCls == 2
            vTxt := evtDir > 0 ? "IGNITION ↑ · go with the trend" : "IGNITION ↓ · go with the trend"
            vFg := evtDir > 0 ? cBull : cBear
        else
            vTxt := regimeTxt + (regTrend ? " · watch for exhaustion" : regID == 4 ? " · reversion bias" : " · no setup")
            vFg := regimeCol
        if evtCls != 0 and clsN.get(evtCls) >= 5 and not na(baseP)
            float ed = clsW.get(evtCls) / float(clsN.get(evtCls)) - baseP
            float vz = f_z(clsW.get(evtCls), clsN.get(evtCls), baseP)
            vTxt := vTxt + "  (edge " + (ed >= 0 ? "+" : "") + str.tostring(ed * 100, "0") + "%" + (not na(vz) and vz > 1.96 ? "*" : "") + ")"
    f_cell(0, 0, vTxt, vFg, cHead, "normal")
    table.merge_cells(dash, 0, 0, 6, 0)

    // live row — ER · displacement · regime
    f_cell(0, 1, "ER " + str.tostring(erFast, "0.00") + "/" + str.tostring(erSlow, "0.00") + (useAdaptiveER ? " ⟳" + str.tostring(erFastLen) + "/" + str.tostring(erSlowLen) : ""), cTxt, cPanel, sz)
    table.merge_cells(dash, 0, 1, 2, 1)
    f_cell(3, 1, "Disp " + (na(dispPct) ? "·" : str.tostring(dispPct * 100, "0") + "%"), na(dispPct) ? cDim : dispPct >= dispHi ? cBear : cNeu, cPanel, sz)
    table.merge_cells(dash, 3, 1, 4, 1)
    f_cell(5, 1, regimeTxt, regimeCol, cPanel, sz)
    table.merge_cells(dash, 5, 1, 6, 1)

    // regime-detail row — variance ratio · OU half-life · VIX
    string vrCell = na(vr) ? "VR —" : "VR " + str.tostring(vr, "0.00") + " " + vrTxt + (vrSig ? "*" : "")
    color  vrCol  = na(vr) ? cDim : vr > 1.0 ? cBull : cAcc
    f_cell(0, 2, vrCell, vrCol, cPanel, sz)
    table.merge_cells(dash, 0, 2, 2, 2)
    string ouCell = na(halfLife) ? "HL —" : "HL " + str.tostring(halfLife, "0.0") + "b"
    color  ouCol  = na(halfLife) ? cDim : halfLife <= horizon * ouGate ? cBull : cNeu
    f_cell(3, 2, ouCell, ouCol, cPanel, sz)
    table.merge_cells(dash, 3, 2, 4, 2)
    string vxCell = na(vixRaw) ? "VIX —" : "VIX " + (na(vixPct) ? "·" : str.tostring(vixPct, "0") + "%") + (vixSpike ? " spike" : vixElevated ? " elev" : "")
    color  vxCol  = na(vixRaw) ? cDim : vixSpike ? cBear : (vixElevated ? cBull : cNeu)
    f_cell(5, 2, vxCell, vxCol, cPanel, sz)
    table.merge_cells(dash, 5, 2, 6, 2)

    if dashMode == "Pro"
        f_cell(0, 3, "CLASS", cNeu, cHead, sz)
        f_cell(1, 3, "n",     cNeu, cHead, sz)
        f_cell(2, 3, "Hit%",  cNeu, cHead, sz)
        f_cell(3, 3, "Base%", cNeu, cHead, sz)
        f_cell(4, 3, "Edge",  cNeu, cHead, sz)
        f_cell(5, 3, "MFE",   cNeu, cHead, sz)
        f_cell(6, 3, "MAE",   cNeu, cHead, sz)
        for id = 1 to NCLS
            int n = clsN.get(id)
            int r = 3 + id
            if n < 5
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cNeu, cPanel, sz)
                f_cell(2, r, "·", cDim, cPanel, sz)
                f_cell(3, r, "·", cDim, cPanel, sz)
                f_cell(4, r, "warm", cDim, cPanel, sz)
                f_cell(5, r, "·", cDim, cPanel, sz)
                f_cell(6, r, "·", cDim, cPanel, sz)
            else
                float hit  = clsW.get(id) / float(n)
                float edge = na(baseP) ? na : hit - baseP
                float z    = f_z(clsW.get(id), n, baseP)
                float ciH  = f_wilsonHalf(clsW.get(id), n)
                bool  star = not na(z) and z > 1.96
                color ec   = na(edge) ? cNeu : edge > 0 ? cBull : cBear
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cTxt, cPanel, sz)
                f_cell(2, r, str.tostring(hit * 100, "0") + (na(ciH) ? "" : "±" + str.tostring(ciH * 100, "0")), cTxt, cPanel, sz)
                f_cell(3, r, na(baseP) ? "·" : str.tostring(baseP * 100, "0") + "%", cNeu, cPanel, sz)
                f_cell(4, r, (na(edge) ? "·" : (edge >= 0 ? "+" : "") + str.tostring(edge * 100, "0") + "%") + (star ? "*" : ""), ec, cPanel, sz)
                f_cell(5, r, str.tostring(clsMFE.get(id) / n, "0.0") + "R", cBull, cPanel, sz)
                f_cell(6, r, str.tostring(clsMAE.get(id) / n, "0.0") + "R", cBear, cPanel, sz)
        // recency-weighted hit-rates
        string recTxt = "Recent · "
        for id = 1 to NCLS
            float nd = clsNd.get(id)
            recTxt := recTxt + f_clsName(id) + " " + (nd >= 1.0 ? str.tostring(clsWd.get(id) / nd * 100, "0") + "%" : "·") + (id < NCLS ? " · " : "")
        f_cell(0, NCLS + 4, recTxt, cAcc, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 4, 6, NCLS + 4)
        // regime-conditional hit-rates for the CURRENT regime
        string rcTxt = "In " + f_regShort(regID) + " · "
        for id = 1 to NCLS
            float rh = f_regHit(id, regID)
            int   rn = clsNrg.get((id - 1) * NREG + (regID - 1))
            rcTxt := rcTxt + f_clsName(id) + " " + (na(rh) ? "·" : str.tostring(rh * 100, "0") + "%(" + str.tostring(rn) + ")") + (id < NCLS ? " · " : "")
        f_cell(0, NCLS + 5, rcTxt, regimeCol, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 5, 6, NCLS + 5)
        f_cell(0, NCLS + 6, "cyc " + (na(domCycle) ? "·" : str.tostring(domCycle, "0")) + "  ·  DivQ " + (na(divCand) ? "·" : str.tostring(divCand * 100, "0") + "%") + "  ·  base n=" + str.tostring(baseN) + "  ·  legs " + str.tostring(dispArr.size()), cDim, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 6, 6, NCLS + 6)
        string harTxt = "HARNESS+ · eff-N " + str.tostring(harEffN, "0.0") + "  ·  OOS " + (na(harOosEdge) ? "warming" : (harOosStar ? "★ " : "") + (harOosEdge >= 0 ? "+" : "") + str.tostring(harOosEdge, "0") + "%") + "  ·  IS " + (na(harIsHitP) ? "·" : str.tostring(harIsHitP, "0") + "%") + " (" + str.tostring(harIsTot) + "/" + str.tostring(harOosTot) + ")" + (useRegime and not na(regExt) ? "  ·  REGIME★ " + str.tostring(regExt) : "")
        f_cell(0, NCLS + 7, harTxt, cAcc, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 7, 6, NCLS + 7)
    else
        int bestId = 0
        float bestEdge = -1e9
        for id = 1 to NCLS
            if clsN.get(id) >= 5 and not na(baseP)
                float e = clsW.get(id) / float(clsN.get(id)) - baseP
                if e > bestEdge
                    bestEdge := e
                    bestId := id
        if bestId == 0
            f_cell(0, 3, "calibrating…", cDim, cPanel, sz)
            table.merge_cells(dash, 0, 3, 6, 3)
        else
            f_cell(0, 3, "Best · " + f_clsLong(bestId), cTxt, cPanel, sz)
            table.merge_cells(dash, 0, 3, 3, 3)
            f_cell(4, 3, (bestEdge >= 0 ? "+" : "") + str.tostring(bestEdge * 100, "0") + "%", bestEdge > 0 ? cBull : cBear, cPanel, sz)
            table.merge_cells(dash, 4, 3, 6, 3)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 9 — ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(evtCls == 1, "Exhaustion", "Efficiency Exhaustion: trend exhaustion on {{ticker}} ({{interval}})")
alertcondition(evtCls == 2, "Ignition",   "Efficiency Exhaustion: ignition on {{ticker}} ({{interval}})")
alertcondition(sigCls != 0, "Significant Edge", "Efficiency Exhaustion: a class reached significant positive edge on {{ticker}}")
alertcondition(regChaos and not regChaos[1], "Chaos Regime", "Efficiency Exhaustion: entered CHAOS regime on {{ticker}} ({{interval}}) — signals suppressed")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 10 — EXPORTS (Data Window)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float expEvent = evtCls == 0 ? 0.0 : float(evtCls) * evtDir   // ±1 EXH, ±2 IGN
float expEdge  = na
if not na(baseP) and evtCls != 0 and clsN.get(evtCls) >= 5
    expEdge := (clsW.get(evtCls) / float(clsN.get(evtCls)) - baseP) * 100.0

plot(showEXP ? erFast : na,   "EXP_ERfast",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? erSlow : na,   "EXP_ERslow",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? gap : na,      "EXP_EffGap", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? dispPct : na,  "EXP_DispPct",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expEvent : na, "EXP_Event",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expEdge : na,  "EXP_Edge",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(regID) : na, "EXP_Regime", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vr : na,       "EXP_VR",       color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? halfLife : na, "EXP_OUHalfLife", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? vixPct : na,   "EXP_VIXpct",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? domCycle : na, "EXP_DomCycle", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? divCand : na,  "EXP_DivQual",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harOosEdge : na, "EXP_EdgeOOS", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harEffN : na,    "EXP_EffN",    color = color.new(color.gray, 100), display = display.data_window)
````
