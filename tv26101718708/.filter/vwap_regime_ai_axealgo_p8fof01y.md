# VWAP Regime AI [AxeAlgo]

- url: https://www.tradingview.com/script/p8FoF01y-VWAP-Regime-AI-AxeAlgo/
- type: indicator
- pine_id: PUB;a506631c95c0430d841a8c3aabdc8733
- version: 2.0

## Description

[b]OVERVIEW[/b]

VWAP Regime AI is an anchored VWAP (Volume-Weighted Average Price) with
standard-deviation bands, enhanced by a native, from-scratch k-means
clustering engine that classifies recent market volatility into three
regimes — Low, Medium, and High — and adapts the indicator's behavior
based on which regime is currently active.

At its foundation this is the same tool institutional desks use every
day: a running volume-weighted average price with bands around it, used
to judge where "fair value" sits and how far price has stretched away
from it. What this script adds on top is a genuine unsupervised machine
learning step that reads the market's own volatility and lets that
reading drive three things: how wide the bands are, which signal logic
is active, and how much the indicator should trust its own regime call
before acting on it.

This script is free and open-source. All calculations happen natively in
Pine Script on your own chart data.

============================================================
[b]FULL TRANSPARENCY ABOUT THE "AI" IN THIS SCRIPT[/b]
============================================================

Pine Script cannot call an LLM, a remote model, or any external AI
service — TradingView does not allow outbound network requests from
indicators, and this script makes none. There is no hidden API call,
no "black box," and nothing running outside of what you can read in the
source code.

What "AI" means here specifically: this script implements k-means
clustering — a well-established unsupervised machine learning algorithm
— entirely in native Pine Script math and arrays. It groups a rolling
window of recent ATR (volatility) readings into three clusters by
repeatedly assigning each reading to its nearest cluster center and then
recomputing each center as the mean of everything assigned to it. This
publication states plainly what is and is not happening so nobody
mistakes this for predictive AI, sentiment analysis, or anything that
consults external data or forecasts the future. It classifies what has
already happened; it does not predict what will happen next.

============================================================
[b]HOW IT WORKS[/b]
============================================================

VWAP & Standard Deviation Bands
--------------------------------
The core VWAP resets at the start of each new anchor period (Session,
Week, Month, Quarter, or Year — configurable) and accumulates a running
volume-weighted average from there. Standard deviation is calculated
using the same volume-weighted variance formula TradingView's own
built-in VWAP-with-bands tool. Up to three bands can be shown,
each set at a configurable standard-deviation distance from VWAP.

AI Volatility Clustering (K-Means)
------------------------------------
A rolling window of recent ATR readings (length and window size are both
configurable) is periodically re-clustered into three groups — Low,
Medium, High — using k-means. Reclustering happens every N bars rather
than every single bar, purely for performance; the live classification
of the current bar still updates continuously between reclusters.
Alongside the classification, the script computes a Confidence score
(0-100%): how much closer the current reading sits to its nearest
cluster than to its second-nearest one. A reading sitting right on a
cluster's center scores near 100%; a reading sitting on the boundary
between two regimes — an effectively ambiguous call — scores near 0%.
A "Minimum Regime Confidence" input lets you require a minimum score
before the regime is allowed to influence anything else in the script,
so an unconfident, boundary-line classification doesn't silently drive
behavior.

Adaptive Band Width
----------------------
When enabled, the standard-deviation band multipliers are scaled by a
per-regime factor: tighter in Low volatility, wider in High volatility,
instead of one fixed multiplier that's too tight in some conditions and
too loose in others. This only engages once the AI is both ready
(its lookback window has filled and it has run at least once) and
confident, per the Minimum Regime Confidence setting above.

Signal Logic — Mean Reversion, Breakout, or Auto
----------------------------------------------------
Two independent signal styles are built in, both measured off Band 2:
Mean Reversion looks for price crossing back inside the band from
outside (betting an extreme move snaps back toward VWAP); Breakout looks
for price crossing outside the band (betting the move has momentum to
keep running). "Auto" mode lets the detected volatility regime decide
which logic applies bar by bar — Low/Medium volatility defaults to Mean
Reversion, High volatility defaults to Breakout — falling back to Mean
Reversion whenever the AI isn't ready or confident enough to trust.

Three independent, stackable filters reduce noise on top of the raw
band cross:
- Bar-Close Confirmation: a cross only counts once the bar has fully
  closed, filtering out intrabar wicks that reverse before the close.
- Signal Cooldown: blocks a new signal, in either direction, for a
  configurable number of bars after the last one — aimed directly at
  whipsaw (price crossing back and forth across a band repeatedly).
- Band Cross Buffer (hysteresis): requires price to clear a band by a
  small extra distance, in standard deviations, rather than an exact
  touch, so noise sitting right on the line doesn't keep re-triggering
  crosses back and forth.

AI Volume Confirmation Filter
---------------------------------
The same k-means engine used for volatility is optionally reused on raw
volume, classifying each bar's volume as Low, Normal, or High. When
enabled, signals are only allowed on Normal-or-above volume, filtering
out low-conviction moves.

Secondary VWAP
-----------------
An optional second VWAP anchored to a different (typically higher)
period can be plotted alongside the primary one — for example a Weekly
VWAP behind a Session VWAP — for confluence, since multiple VWAP anchors
are commonly watched together rather than trusting a single one in
isolation. It is a reference line only; no bands are drawn for it.

Signal Track Record
-----------------------
An on-chart scorecard tracks, in a simple and fully model-free way, how
the signals have actually performed: each signal opens a virtual
position at that bar's close, and the next opposite-direction signal
closes it out, scored as a win or a loss purely on which way price
moved in between. No target or stop-loss assumption is built into this
score — see the Limitations section below for exactly what this number
does and does not tell you.

Status Table
---------------
An optional on-chart table shows the current regime and its confidence,
the active band scale, the current VWAP value, a "Stretch Score" (see
below), and the Signal Track Record numbers, all in one place.

Stretch Score
----------------
A signed z-score of how many standard deviations price currently sits
from VWAP. Because it's measured in the same standard deviations the
bands are drawn in, it stays consistent with whatever the adaptive band
width currently has in effect — a reading of +2.00 always means "sitting
on Band 2," whether that band is currently tight or wide.

============================================================
[b]HOW TO USE THIS INDICATOR[/b]
============================================================

1. Start with the default settings and watch the status table for a
   while before changing anything. Let the AI Volatility Clustering
   lookback window fill (the table will show "Calibrating..." until it
   has enough data) so the regime classification is meaningful.
2. Decide whether you want Mean Reversion, Breakout, or Auto signal
   logic. Auto is a reasonable starting point since it adapts to
   detected conditions automatically.
3. Watch the Confidence score alongside the regime label. If confidence
   is frequently low on your instrument/timeframe, consider raising the
   Minimum Regime Confidence input so the indicator falls back to
   neutral behavior more readily instead of acting on ambiguous calls.
4. Use the Stretch Score to judge how extended price currently is
   relative to VWAP in a way that stays consistent even as band width
   adapts.
5. Treat the Signal Track Record as a rough, ongoing sanity check on
   signal quality — not a backtest and not a promise (see Limitations).
6. This is a visual/analytical tool, not an auto-trading system. It
   does not place trades. Any alerts it can generate are notifications
   only.

============================================================
[b]INPUT GROUPS (SUMMARY)[/b]
============================================================

VWAP Settings
- Anchor Period (Session / Week / Month / Quarter / Year)
- Source price used for the VWAP calculation

Secondary VWAP (Confluence)
- Show/hide toggle, its own anchor period, and its own color

Standard Deviation Bands
- Independent show/hide and distance (in standard deviations) for
  three bands, plus a toggle for the gradient fill shading around them

AI Volatility Clustering (K-Means)
- Enable/disable the clustering engine
- ATR length used as the raw volatility reading that gets clustered
- Clustering lookback window (bars) and reclustering frequency
- Number of k-means refinement iterations per reclustering
- Adaptive band width toggle and the three per-regime scale factors
- Minimum Regime Confidence threshold

Signals
- Show/hide signal markers
- Signal Mode (Mean Reversion / Breakout / Auto)
- Volume confirmation filter toggle
- Bar-close confirmation toggle
- Signal cooldown (bars)
- Band cross buffer (hysteresis, in standard deviations)

Visuals
- Regime background highlight toggle
- Status table toggle and Signal Track Record toggle
- Colors for VWAP, each band, each regime, and each signal direction

============================================================
[b]REPAINTING & REAL-TIME BEHAVIOR[/b]
============================================================

This script does not use any higher-timeframe security() calls and does
not look ahead — every value at every historical bar is a function of
data available up to and including that bar. Once a historical bar is
confirmed, its VWAP, bands, regime classification, and signals do not
change on subsequent chart loads or reloads.

Like any real-time indicator, values on the currently forming (unclosed)
bar update as new price/volume ticks arrive, and will settle once that
bar closes — this is standard behavior for any live indicator, not
repainting of historical data. If you want signal markers to appear only
after a bar has fully closed rather than updating intrabar, keep the
"Require Bar Close Confirmation" input enabled (it is on by default).

============================================================
[b]LIMITATIONS — PLEASE READ[/b]
============================================================

- The Signal Track Record is a simplified, model-free heuristic, not a
  backtest. It ignores commissions, spread, slippage, position sizing,
  and any stop-loss/take-profit logic, and it scores a "trade" purely by
  whether price was above or below the entry price when the next
  opposite signal fired. It exists to give a rough, ongoing sense of
  signal direction quality — it is not a performance guarantee and
  should not be relied on as one.
- K-means clustering, like any clustering method, can produce a
  misleadingly high confidence score if recent volatility (or volume)
  readings happen to be nearly constant for an extended window — a rare
  condition, more likely on thinly-traded instruments, but worth being
  aware of.
- Regime classification and adaptive behavior depend on the Clustering
  Lookback window filling with data first; expect "Calibrating..." on a
  freshly loaded chart or a short history until then.
- This is a discretionary analysis tool intended to support your own
  judgment, not a mechanical, guaranteed-signal system. No combination
  of settings eliminates false signals entirely, which is why several
  independent, adjustable filters (bar-close confirmation, cooldown,
  hysteresis buffer, volume confirmation, regime confidence threshold)
  are provided rather than relied on individually.

============================================================
[b]RISK DISCLAIMER[/b]
============================================================

This script is provided for educational and informational purposes
only. It is not financial advice, and it is not a recommendation to buy
or sell any security or instrument. Trading and investing involve
substantial risk of loss and are not suitable for every investor. Past
performance — whether real, simulated, or shown via the on-chart Signal
Track Record — is not indicative of future results. Always do your own
research and consider consulting a licensed financial advisor before
making trading decisions. Use this indicator, and any alerts it
generates, entirely at your own risk.

## Source Code

````pine
//@version=6
// © AxeAlgo

// ═══════════════════════════════════════════════════════════════════════
//  VWAP REGIME AI — ADAPTIVE VOLATILITY CLUSTERING
// ═══════════════════════════════════════════════════════════════════════
//  WHAT THIS INDICATOR DOES
//  ------------------------
//  At its core this is an ANCHORED VWAP (Volume-Weighted Average Price)
//  with standard-deviation bands — the same tool institutional desks use
//  to see the "fair value" price for the current session/week/month and
//  how far price has stretched away from it.
//
//  What makes it "AI powered": a genuine, native K-MEANS CLUSTERING
//  algorithm (unsupervised machine learning — no external API, no
//  internet access, all math run right here in Pine) continuously groups
//  recent volatility readings into three regimes — LOW / MEDIUM / HIGH —
//  and the indicator adapts itself based on which regime the market is
//  currently in:
//
//    1. BAND WIDTH adapts to the regime: tighter bands in calm (low-vol)
//       markets, wider bands in turbulent (high-vol) ones, instead of a
//       single fixed multiplier that's too tight in some conditions and
//       too loose in others.
//
//    2. SIGNAL LOGIC can switch strategy entirely based on regime: in
//       Low/Medium volatility, price extremes tend to snap back toward
//       VWAP (mean reversion). In High volatility, price extremes tend to
//       keep running (breakout/momentum). "Auto" mode picks whichever
//       logic fits the current regime instead of using one blindly.
//
//    3. A CONFIDENCE SCORE (0-100%, shown in the status table) rates how
//       sure the AI is of the current regime — how much closer the
//       reading is to its nearest cluster than to its second-nearest one.
//       A reading sitting right on a cluster's center scores near 100%; a
//       reading sitting right on the boundary between two regimes — an
//       essentially ambiguous classification — scores near 0%. The
//       "Minimum Regime Confidence" input can require a minimum score
//       before adaptive band width, Auto signal switching, or the
//       background highlight are allowed to act on the regime at all,
//       so the indicator doesn't confidently act on an unconfident guess.
//
//  The SAME k-means engine also gets reused for a VOLUME CONFIRMATION
//  FILTER: it clusters recent volume into Low/Normal/High exactly like it
//  clusters volatility, and — when enabled — only allows Normal-or-above
//  volume bars to fire signals, filtering out low-conviction moves.
//
//  A dedicated REGIME-CHANGE ALERT fires the moment the volatility regime
//  flips (e.g. Low -> High), independent of any buy/sell signal, for
//  anyone who just wants a heads-up that conditions shifted.
//
//  A SECONDARY VWAP can be plotted alongside the primary one, anchored to
//  a different (typically higher) period — e.g. a Weekly VWAP behind a
//  Session VWAP — since institutional desks watch confluence between
//  multiple VWAP anchors rather than trusting a single one in isolation.
//
//  A STRETCH SCORE (shown in the status table) is a signed z-score of how
//  many standard deviations price currently sits from VWAP. Because it's
//  measured in the same standard deviations the bands are drawn in, it
//  stays consistent with whatever the AI's adaptive band width currently
//  has in effect — a reading of +2.00 always means "sitting on Band 2",
//  whether that band is currently tight or wide.
//
//  Important honesty note: Pine Script cannot call an LLM or any external
//  AI service — there's no network access. The "AI" here is real,
//  legitimate unsupervised machine learning (k-means clustering) running
//  natively, the same technique used under the hood by many published
//  "adaptive"/"machine learning" indicators on TradingView.
// ═══════════════════════════════════════════════════════════════════════

indicator("VWAP Regime AI [AxeAlgo]", overlay = true)

// ───────────────────────── Inputs ─────────────────────────

vwapGroup = "VWAP Settings"
anchorPeriod = input.string("Session", "Anchor Period", options = ["Session", "Week", "Month", "Quarter", "Year"], group = vwapGroup,
     tooltip = "How often the VWAP calculation resets and starts accumulating fresh. 'Session' resets daily.")
vwapSource = input.source(hlc3, "Source", group = vwapGroup,
     tooltip = "The price value VWAP is weighted around. hlc3 (average of high/low/close) is the conventional choice.")

secVwapGroup = "Secondary VWAP (Confluence)"
showSecondaryVwap = input.bool(false, "Show Secondary VWAP", group = secVwapGroup,
     tooltip = "Plots a second VWAP anchored to a different period alongside the primary one (e.g. Weekly VWAP behind a Session VWAP), so you can see where the two agree — the way institutional desks actually watch multiple VWAP anchors at once instead of trusting a single one in isolation. No bands, just the reference line.")
secondaryAnchorPeriod = input.string("Week", "Secondary Anchor Period", options = ["Session", "Week", "Month", "Quarter", "Year"], group = secVwapGroup)
secondaryVwapColor = input.color(color.new(#EC4899, 0), "Secondary VWAP Color", group = secVwapGroup)

bandGroup = "Standard Deviation Bands"
showBand1 = input.bool(true, "Show Band 1", inline = "b1", group = bandGroup)
mult1     = input.float(1.0, "", inline = "b1", minval = 0.1, step = 0.1, group = bandGroup, tooltip = "Band 1 distance, in standard deviations from VWAP.")
showBand2 = input.bool(true, "Show Band 2", inline = "b2", group = bandGroup)
mult2     = input.float(2.0, "", inline = "b2", minval = 0.1, step = 0.1, group = bandGroup, tooltip = "Band 2 distance, in standard deviations from VWAP.")
showBand3 = input.bool(false, "Show Band 3", inline = "b3", group = bandGroup)
mult3     = input.float(3.0, "", inline = "b3", minval = 0.1, step = 0.1, group = bandGroup, tooltip = "Band 3 distance, in standard deviations from VWAP.")
showBandFill = input.bool(true, "Fill Between Band 1", group = bandGroup)

aiGroup = "AI Volatility Clustering (K-Means)"
useAiClustering = input.bool(true, "Enable AI Volatility Clustering", group = aiGroup,
     tooltip = "Runs a native k-means clustering algorithm on recent volatility to classify the market into Low/Medium/High regimes.")
clusterVolLength = input.int(14, "Volatility Measure Length (ATR)", minval = 1, group = aiGroup,
     tooltip = "ATR length used as the raw 'volatility reading' that gets clustered.")
clusterLookback = input.int(150, "Clustering Lookback (bars)", minval = 30, group = aiGroup,
     tooltip = "How many recent volatility readings the k-means algorithm learns its 3 clusters from. Needs to fill up once before the AI is 'ready'.")
clusterIterations = input.int(10, "K-Means Iterations", minval = 1, maxval = 50, group = aiGroup,
     tooltip = "How many refinement passes k-means runs each time it recalculates. More = more converged clusters, at a small performance cost.")
clusterRecalcEvery = input.int(20, "Recalculate Every N Bars", minval = 1, group = aiGroup,
     tooltip = "Performance control: re-runs the clustering algorithm every N bars instead of every single bar. Regime classification between recalculations still updates live.")
adaptBandWidth = input.bool(true, "Adapt Band Width To Regime", group = aiGroup,
     tooltip = "When enabled, the standard-deviation band multipliers above are scaled by the values below depending on the current regime.")
lowVolBandScale  = input.float(0.7, "Low-Volatility Band Scale", minval = 0.1, step = 0.1, group = aiGroup)
medVolBandScale  = input.float(1.0, "Medium-Volatility Band Scale", minval = 0.1, step = 0.1, group = aiGroup)
highVolBandScale = input.float(1.5, "High-Volatility Band Scale", minval = 0.1, step = 0.1, group = aiGroup)
minRegimeConfidence = input.float(40.0, "Minimum Regime Confidence (%)", minval = 0.0, maxval = 100.0, step = 5.0, group = aiGroup,
     tooltip = "How sure the AI must be of the current regime (see the Confidence score in the status table) before adaptive band width, regime-based signal switching, and the background highlight are allowed to act on it. Below this threshold the indicator falls back to neutral/default behavior instead of trusting an ambiguous, near-boundary classification. Raised from 0 by default — an unconfident, near-boundary regime call was letting Auto mode silently swap between Mean Reversion and Breakout logic mid-chop, one source of false signals. 0 = always trust it.")

signalGroup = "Signals"
showSignals = input.bool(true, "Show Buy/Sell Signals", group = signalGroup)
signalMode  = input.string("Auto (Regime-Based)", "Signal Mode", options = ["Mean Reversion", "Breakout", "Auto (Regime-Based)"], group = signalGroup,
     tooltip = "Mean Reversion = fade band extremes (price snapping back to VWAP). Breakout = follow price breaking through a band. Auto uses the AI regime to pick between the two bar by bar.")
useVolumeFilter = input.bool(true, "Require Volume Confirmation (AI)", group = signalGroup,
     tooltip = "Reuses the same k-means clustering engine — applied to volume instead of ATR — to classify each bar's volume as Low/Normal/High. When enabled, signals are only allowed on Normal-or-above volume, filtering out low-conviction moves. Uses the same lookback/iterations/recalc settings as the volatility clustering above.")
requireBarClose = input.bool(true, "Require Bar Close Confirmation", group = signalGroup,
     tooltip = "Only counts a band cross once the bar has fully closed, instead of on every intrabar tick — filters out crosses that reverse before the candle actually closes.")
signalCooldownBars = input.int(5, "Signal Cooldown (bars)", minval = 0, group = signalGroup,
     tooltip = "Minimum bars required after any signal before the next one is allowed to fire, in either direction. Directly targets whipsaw — price crossing back and forth across a band repeatedly. 0 = off.")
hysteresisFrac = input.float(0.15, "Band Cross Buffer (x StdDev)", minval = 0.0, step = 0.05, group = signalGroup,
     tooltip = "Extra distance (in standard deviations) price must clear past a band before a cross counts, in the stricter direction for each signal type. Filters out noise sitting right on the band line from re-triggering crosses back and forth. 0 = off (exact touch triggers).")

visualGroup = "Visuals"
showRegimeBackground = input.bool(false, "Highlight Regime Background", group = visualGroup)
showStatusTable       = input.bool(true, "Show Status Table", group = visualGroup)
showTrackRecord       = false//input.bool(true, "Show Signal Track Record", group = visualGroup,
vwapColor   = input.color(color.new(#D4AF37, 0), "VWAP Color", group = visualGroup)
band1Color  = input.color(color.new(#5B8DEF, 0), "Band 1 Color", group = visualGroup)
band2Color  = input.color(color.new(#8B5CF6, 0), "Band 2 Color", group = visualGroup)
band3Color  = input.color(color.new(#787B86, 0), "Band 3 Color", group = visualGroup)
lowVolColor  = input.color(color.new(#10B981, 78), "Low-Volatility Regime Color", group = visualGroup)
medVolColor  = input.color(color.new(#5B8DEF, 80), "Medium-Volatility Regime Color", group = visualGroup)
highVolColor = input.color(color.new(#DC2626, 78), "High-Volatility Regime Color", group = visualGroup)
buySignalColor  = input.color(color.new(#10B981, 0), "Buy Signal Color", group = visualGroup)
sellSignalColor = input.color(color.new(#DC2626, 0), "Sell Signal Color", group = visualGroup)


// ───────────────────────── Helpers ─────────────────────────
// Maps the "Anchor Period" dropdown text to the timeframe string
// timeframe.change() expects.
f_anchorTimeframe(periodText) =>
    switch periodText
        "Session" => "D"
        "Week"    => "W"
        "Month"   => "M"
        "Quarter" => "3M"
        "Year"    => "12M"
        => "D"


// ───────────────────────── VWAP & Standard Deviation Calculation ─────────────────────────
// Anchored VWAP is a running (cumulative) volume-weighted average that
// resets to zero at the start of each new period (session/week/month/...).
// timeframe.change() fires true on the first bar of a new higher timeframe
// bar, which is exactly the reset signal needed here.
newPeriod = timeframe.change(f_anchorTimeframe(anchorPeriod))

var float cumPV  = 0.0   // running sum of price * volume
var float cumVol = 0.0   // running sum of volume
var float cumPV2 = 0.0   // running sum of volume * price^2 (needed for volume-weighted variance)

if newPeriod
    cumPV  := 0.0
    cumVol := 0.0
    cumPV2 := 0.0

cumPV  += vwapSource * volume
cumVol += volume
cumPV2 += volume * math.pow(vwapSource, 2)

vwapValue = cumVol > 0 ? cumPV / cumVol : na

// Volume-weighted variance: E[X^2] - E[X]^2, weighted by volume instead of
// a plain bar count. This is the same formula TradingView's own built-in
// VWAP-with-bands indicator uses.
vwapVariance = cumVol > 0 ? (cumPV2 / cumVol) - math.pow(vwapValue, 2) : na
vwapStdev    = vwapVariance > 0 ? math.sqrt(vwapVariance) : 0.0

// -- Secondary VWAP (confluence reference) ------------------------------
// A second, independent set of running totals anchored to its own period
// (typically higher than the primary, e.g. Weekly over Session), using
// the exact same math as the primary VWAP above — just no stdev bands,
// since its only job is to sit on the chart as a second reference line.
newPeriodSecondary = timeframe.change(f_anchorTimeframe(secondaryAnchorPeriod))

var float cumPVSecondary  = 0.0
var float cumVolSecondary = 0.0

if newPeriodSecondary
    cumPVSecondary  := 0.0
    cumVolSecondary := 0.0

cumPVSecondary  += vwapSource * volume
cumVolSecondary += volume

vwapValueSecondary = cumVolSecondary > 0 ? cumPVSecondary / cumVolSecondary : na


// ───────────────────────── AI Volatility Clustering (K-Means) ─────────────────────────
// This is the "AI" engine: a from-scratch, native k-means clustering
// implementation. It groups a rolling window of volatility readings
// (ATR values) into exactly 3 clusters — Low / Medium / High — by
// repeatedly assigning each reading to its nearest cluster center, then
// recomputing each center as the mean of everything assigned to it.
// Fixed at 3 clusters on purpose: it keeps the regimes human-interpretable
// (Low/Medium/High) instead of needing a variable, harder-to-label count.
//
// Both functions below are self-contained (pure math + Pine arrays, no
// ta.* calls inside), so they're safe to call conditionally — e.g. only
// every `clusterRecalcEvery` bars, which is exactly what section does
// further down for performance — and safe to copy-paste into another
// script wholesale.

// Runs k-means clustering on a 1-D array of values.
//   data           -> the values to cluster (e.g. recent ATR readings)
//   k              -> number of clusters to find
//   maxIterations  -> refinement passes; more = better converged, costs more
// Returns an array of k centroid values. Centroids are seeded evenly
// spaced between the data's min and max, and because 1-D k-means clusters
// never "cross over" each other during convergence, the returned array
// stays sorted ascending — index 0 is always the lowest-value cluster.
f_kmeans1D(array<float> data, int k, int maxIterations) =>
    n = array.size(data)
    dataMin = array.min(data)
    dataMax = array.max(data)

    centroids = array.new_float(k)
    for i = 0 to k - 1
        array.set(centroids, i, dataMin + i * (dataMax - dataMin) / (k - 1))

    for iteration = 1 to maxIterations
        sums   = array.new_float(k, 0.0)
        counts = array.new_int(k, 0)

        // Assignment step: give each data point to its nearest centroid.
        for i = 0 to n - 1
            val = array.get(data, i)
            bestCluster = 0
            bestDist = math.abs(val - array.get(centroids, 0))
            for c = 1 to k - 1
                d = math.abs(val - array.get(centroids, c))
                if d < bestDist
                    bestDist := d
                    bestCluster := c
            array.set(sums, bestCluster, array.get(sums, bestCluster) + val)
            array.set(counts, bestCluster, array.get(counts, bestCluster) + 1)

        // Update step: move each centroid to the mean of its assigned points.
        // A cluster with zero points assigned just keeps its previous
        // position rather than collapsing to na/zero.
        for c = 0 to k - 1
            cnt = array.get(counts, c)
            if cnt > 0
                array.set(centroids, c, array.get(sums, c) / cnt)

    centroids

// Classifies a single value against a set of centroids AND scores how
// confident that classification is, in one pass.
//   value     -> the reading to classify (e.g. the current bar's ATR)
//   centroids -> centroids from f_kmeans1D()
// Returns a tuple [clusterIndex, confidencePercent]:
//   clusterIndex     -> 0 for the lowest-value cluster up to (size-1) for
//                        the highest
//   confidencePercent -> 0-100. Compares the distance to the NEAREST
//                        centroid against the distance to the SECOND-
//                        nearest one. Sitting right on top of a centroid
//                        (far from every other cluster) scores close to
//                        100; sitting exactly on the boundary between two
//                        equally-close clusters — the classification is
//                        basically a coin flip — scores close to 0.
f_classifyRegime(float value, array<float> centroids) =>
    k = array.size(centroids)
    bigNumber = 1e15
    bestIdx = 0
    bestDist = bigNumber
    secondBestDist = bigNumber
    for i = 0 to k - 1
        d = math.abs(value - array.get(centroids, i))
        if d < bestDist
            secondBestDist := bestDist
            bestDist := d
            bestIdx := i
        else if d < secondBestDist
            secondBestDist := d
    confidence = secondBestDist > 0 ? (1 - bestDist / secondBestDist) * 100 : 100.0
    [bestIdx, confidence]

// -- Wiring the AI engine into live data --------------------------------
// ta.atr() must be called unconditionally every bar (like any ta.*
// function), so the raw volatility reading is always computed here...
atrValue = ta.atr(clusterVolLength)

// ...and pushed into a rolling window (plain array ops have no such
// restriction, so maintaining this buffer every bar is fine).
var float[] volHistory = array.new_float(0)
array.push(volHistory, atrValue)
if array.size(volHistory) > clusterLookback
    array.shift(volHistory)

// The clustering itself only re-runs periodically (every clusterRecalcEvery
// bars) once the window is full — recalculating 3 cluster centers from a
// 150-reading window on every single bar would be needless repeated work
// for a value that only needs to adapt slowly.
var float[] centroids = array.new_float(3, na)
clusterWindowFull = array.size(volHistory) >= clusterLookback
if useAiClustering and clusterWindowFull and bar_index % clusterRecalcEvery == 0
    centroids := f_kmeans1D(volHistory, 3, clusterIterations)

// clusterReady is false until the window has filled AND at least one
// clustering pass has actually run (centroids still hold `na` before that).
clusterReady = useAiClustering and clusterWindowFull and not na(array.get(centroids, 0))

// f_classifyRegime() is pure math, so it's safe to call unconditionally
// every bar even before clusterReady is true (it just classifies against
// still-na centroids, harmlessly defaulting to index 0 / 0% confidence —
// every downstream use below is gated on clusterReady/confidentRegime
// anyway, so that default is never actually shown or acted on).
[regime, regimeConfidence] = f_classifyRegime(atrValue, centroids)   // regime: 0 = Low, 1 = Medium, 2 = High

// True only once the AI is both ready AND sure enough of its answer (see
// the "Minimum Regime Confidence" input) to be trusted by the adaptive
// band width, regime-based signals, and background highlight below.
confidentRegime = clusterReady and regimeConfidence >= minRegimeConfidence


// ───────────────────────── Adaptive Band Width ─────────────────────────
// Picks the band-width scale for the current regime, and falls back to a
// neutral 1.0 (no scaling) whenever the AI isn't enabled/ready or the user
// has turned adaptive width off — the bands then behave like a plain,
// fixed-multiplier VWAP.
regimeBandScale = regime == 0 ? lowVolBandScale : regime == 1 ? medVolBandScale : regime == 2 ? highVolBandScale : 1.0
bandScale = (adaptBandWidth and confidentRegime) ? regimeBandScale : 1.0

effectiveMult1 = mult1 * bandScale
effectiveMult2 = mult2 * bandScale
effectiveMult3 = mult3 * bandScale

upperBand1 = vwapValue + vwapStdev * effectiveMult1
lowerBand1 = vwapValue - vwapStdev * effectiveMult1
upperBand2 = vwapValue + vwapStdev * effectiveMult2
lowerBand2 = vwapValue - vwapStdev * effectiveMult2
upperBand3 = vwapValue + vwapStdev * effectiveMult3
lowerBand3 = vwapValue - vwapStdev * effectiveMult3

// -- Stretch Score --------------------------------------------------------
// A normalized reading of how many standard deviations price currently
// sits from VWAP (a z-score) — signed, so positive means above VWAP,
// negative means below. Since it's measured in the same standard
// deviations the bands are drawn in, it's automatically consistent with
// whatever the AI's adaptive band width currently has in effect: a +2.00
// reading always means "sitting right on Band 2", tight regime or wide.
stretchScore = vwapStdev > 0 ? (close - vwapValue) / vwapStdev : 0.0
stretchAbs   = math.abs(stretchScore)
stretchColor = stretchAbs < effectiveMult1 ? color.gray : stretchAbs < effectiveMult2 ? color.new(#F59E0B, 0) : color.new(#DC2626, 0)


// ───────────────────────── AI Volume Confirmation Filter ─────────────────────────
// Same idea as the volatility clustering above, aimed at a different
// dataset: instead of clustering ATR into Low/Medium/High, this clusters
// raw `volume` into Low/Normal/High using the exact same f_kmeans1D() and
// f_classifyRegime() functions from the AI section — no new algorithm,
// just a second rolling window fed through the same reusable engine.
var float[] volumeHistory = array.new_float(0)
array.push(volumeHistory, volume)
if array.size(volumeHistory) > clusterLookback
    array.shift(volumeHistory)

var float[] volumeCentroids = array.new_float(3, na)
volumeWindowFull = array.size(volumeHistory) >= clusterLookback
if useVolumeFilter and volumeWindowFull and bar_index % clusterRecalcEvery == 0
    volumeCentroids := f_kmeans1D(volumeHistory, 3, clusterIterations)

volumeClusterReady = useVolumeFilter and volumeWindowFull and not na(array.get(volumeCentroids, 0))
[volumeRegime, volumeConfidence] = f_classifyRegime(volume, volumeCentroids)   // 0 = Low, 1 = Normal, 2 = High volume

// Passes through untouched whenever the filter is off or still
// calibrating — it only actively blocks signals once it has a real
// classification to block them with. regime >= 1 means Normal or High.
volumeOk = not useVolumeFilter or not volumeClusterReady or volumeRegime >= 1


// ───────────────────────── Signal Logic ─────────────────────────
// Two independent signal styles, both measured off Band 2:
//   Mean Reversion -> price crossing back INSIDE the band from outside,
//                     betting the extreme move snaps back toward VWAP.
//   Breakout       -> price crossing OUTSIDE the band, betting the move
//                     has enough momentum to keep running.
// "Auto" lets the AI regime decide which style fits the current market:
// Low/Medium volatility favors mean reversion (ranging conditions), High
// volatility favors breakout (trending/momentum conditions).
// Hysteresis buffer: shifts each signal's trigger level in the stricter
// direction (mean reversion must clear further back inside; breakout must
// clear further outside), so price sitting right on the band line doesn't
// keep re-triggering crosses back and forth. 0 = exact touch, same as before.
hysteresisBuffer = vwapStdev * hysteresisFrac

meanRevBull = ta.crossover(close, lowerBand2 + hysteresisBuffer)
meanRevBear = ta.crossunder(close, upperBand2 - hysteresisBuffer)
breakoutBull = ta.crossover(close, upperBand2 + hysteresisBuffer)
breakoutBear = ta.crossunder(close, lowerBand2 - hysteresisBuffer)

// Small dispatcher: picks which pair of signals is "live" this bar.
f_resolveSignals(string mode, int regimeValue, bool mrBull, bool mrBear, bool boBull, bool boBear) =>
    if mode == "Mean Reversion"
        [mrBull, mrBear]
    else if mode == "Breakout"
        [boBull, boBear]
    else
        useBreakout = regimeValue == 2
        [useBreakout ? boBull : mrBull, useBreakout ? boBear : mrBear]

// Only lets the "Auto" mode actually use the AI's regime when it's a
// confident reading — otherwise it defaults to 0 (Low), which makes the
// dispatcher fall back to Mean Reversion, the same safe default used
// whenever the AI is disabled entirely.
[rawBullSignal, rawBearSignal] = f_resolveSignals(signalMode, confidentRegime ? regime : 0, meanRevBull, meanRevBear, breakoutBull, breakoutBear)

// Bar-close confirmation: only accept a cross once this bar has fully
// closed, so a wick that pokes through a level and reverses intrabar
// never counts — a no-op when the input is off.
barCloseOk = not requireBarClose or barstate.isconfirmed

// Cooldown: blocks any new signal (either direction) for N bars after the
// last one — the direct fix for whipsaw firing repeated signals off what's
// really the same back-and-forth move across a band.
var int lastSignalBar = na
cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldownBars

// Final signals additionally require volume confirmation (see the AI
// Volume Confirmation Filter section above) — a no-op when that filter
// is disabled, since volumeOk is always true in that case.
bullSignal = rawBullSignal and volumeOk and barCloseOk and cooldownOk
bearSignal = rawBearSignal and volumeOk and barCloseOk and cooldownOk

if bullSignal or bearSignal
    lastSignalBar := bar_index


// ───────────────────────── Signal Track Record ─────────────────────────
// A simple, model-free scorecard: every signal opens a virtual position at
// that bar's close; the next opposite-direction signal closes it out and
// scores it a win/loss purely on which way price actually moved in between.
// No target/stop assumptions baked in — that keeps it meaningful across
// every signal mode (Mean Reversion, Breakout, Auto) and any instrument,
// since it's just asking "did this signal call the right direction before
// the system reversed itself."
var int   trackDir     = 0    // 1 = virtual long open, -1 = virtual short open, 0 = none yet
var float trackEntry   = na
var int   totalSignals = 0
var int   winSignals   = 0
var float sumReturnPct = 0.0

// Guarded against both firing the same bar (a same-bar sweep through both
// Band 2 levels) so a phantom zero-length trade never gets recorded.
if bullSignal and not bearSignal
    if trackDir == -1
        tradeReturnPct = (trackEntry - close) / trackEntry * 100
        totalSignals += 1
        sumReturnPct += tradeReturnPct
        if tradeReturnPct > 0
            winSignals += 1
    trackDir   := 1
    trackEntry := close

if bearSignal and not bullSignal
    if trackDir == 1
        tradeReturnPct = (close - trackEntry) / trackEntry * 100
        totalSignals += 1
        sumReturnPct += tradeReturnPct
        if tradeReturnPct > 0
            winSignals += 1
    trackDir   := -1
    trackEntry := close

winRatePct   = totalSignals > 0 ? winSignals / totalSignals * 100 : na
avgReturnPct = totalSignals > 0 ? sumReturnPct / totalSignals : na


// ───────────────────────── Plot VWAP & Bands ─────────────────────────
// Neon "glow" technique (same trick used for the time-zone lines in
// FibLines2): every line is drawn TWICE — a wide, heavily transparent
// halo first, then a slim, more saturated core on top of it. That soft
// halo is what keeps a bright hue from reading as one hard, flat "brick"
// stroke — same colors as before, just layered instead of solid.
// VWAP is the one bold line (the signature); every band line is
// progressively fainter going outward so the eye reads "distance from
// fair value" as a gradient instead of three equally-loud lines.
// VWAP gets a 4-layer bloom instead of the old 2-layer glow (a wide flat
// halo dropping straight to a thin solid core, which read as more of a
// highlight than an actual glow) — three widening, increasingly faint
// halos underneath the solid core give it a soft, smoothly-falling-off
// neon look, and make VWAP the unmistakable focal point against the
// comparatively quieter bands.
plot(vwapValue, title = "VWAP Glow 3", color = color.new(vwapColor, 88), linewidth = 9)
plot(vwapValue, title = "VWAP Glow 2", color = color.new(vwapColor, 78), linewidth = 6)
plot(vwapValue, title = "VWAP Glow 1", color = color.new(vwapColor, 60), linewidth = 3)
plot(vwapValue, title = "VWAP", color = vwapColor, linewidth = 2)

plot(showSecondaryVwap ? vwapValueSecondary : na, title = "Secondary VWAP Glow 2", color = color.new(secondaryVwapColor, 88), linewidth = 7)
plot(showSecondaryVwap ? vwapValueSecondary : na, title = "Secondary VWAP Glow 1", color = color.new(secondaryVwapColor, 72), linewidth = 4)
plot(showSecondaryVwap ? vwapValueSecondary : na, title = "Secondary VWAP", color = secondaryVwapColor, linewidth = 2)

plot(showBand1 ? upperBand1 : na, title = "Upper Band 1 Glow", color = color.new(band1Color, 80), linewidth = 4)
plot(showBand1 ? lowerBand1 : na, title = "Lower Band 1 Glow", color = color.new(band1Color, 80), linewidth = 4)
upperBand1Plot = plot(showBand1 ? upperBand1 : na, title = "Upper Band 1", color = color.new(band1Color, 15), linewidth = 1)
lowerBand1Plot = plot(showBand1 ? lowerBand1 : na, title = "Lower Band 1", color = color.new(band1Color, 15), linewidth = 1)

plot(showBand2 ? upperBand2 : na, title = "Upper Band 2 Glow", color = color.new(band2Color, 82), linewidth = 4)
plot(showBand2 ? lowerBand2 : na, title = "Lower Band 2 Glow", color = color.new(band2Color, 82), linewidth = 4)
upperBand2Plot = plot(showBand2 ? upperBand2 : na, title = "Upper Band 2", color = color.new(band2Color, 20), linewidth = 1)
lowerBand2Plot = plot(showBand2 ? lowerBand2 : na, title = "Lower Band 2", color = color.new(band2Color, 20), linewidth = 1)

plot(showBand3 ? upperBand3 : na, title = "Upper Band 3 Glow", color = color.new(band3Color, 85), linewidth = 4)
plot(showBand3 ? lowerBand3 : na, title = "Lower Band 3 Glow", color = color.new(band3Color, 85), linewidth = 4)
upperBand3Plot = plot(showBand3 ? upperBand3 : na, title = "Upper Band 3", color = color.new(band3Color, 45), linewidth = 1)
lowerBand3Plot = plot(showBand3 ? lowerBand3 : na, title = "Lower Band 3", color = color.new(band3Color, 45), linewidth = 1)

// Graduated "halo" fill: three concentric rings of increasing
// transparency around VWAP, each using its own band's color, so the
// whole zone reads as one smooth gradient cloud rather than a flat block.
fill(upperBand1Plot, lowerBand1Plot, color = showBandFill and showBand1 ? color.new(band1Color, 92) : na, title = "Inner Band Fill")
fill(upperBand2Plot, upperBand1Plot, color = showBandFill and showBand2 ? color.new(band2Color, 94) : na, title = "Upper Mid Band Fill")
fill(lowerBand1Plot, lowerBand2Plot, color = showBandFill and showBand2 ? color.new(band2Color, 94) : na, title = "Lower Mid Band Fill")
fill(upperBand3Plot, upperBand2Plot, color = showBandFill and showBand3 ? color.new(band3Color, 97) : na, title = "Upper Outer Band Fill")
fill(lowerBand2Plot, lowerBand3Plot, color = showBandFill and showBand3 ? color.new(band3Color, 97) : na, title = "Lower Outer Band Fill")


// ───────────────────────── Regime Background & Status Table ─────────────────────────
// bgcolor() paints one flat wash per bar — it can't be layered into a
// halo the way a line can — so its equivalent of the "glow" treatment is
// simply tuning the transparency down a bit from a near-invisible tint to
// a soft-but-present neon wash, without ever becoming a solid block.
regimeBgColor = regime == 0 ? lowVolColor : regime == 1 ? medVolColor : regime == 2 ? highVolColor : na
bgcolor(showRegimeBackground and confidentRegime ? regimeBgColor : na, title = "Volatility Regime")

// Small, quiet monospace-feeling table: a one-line gold header banner
// (merged across both columns) over four compact data rows. size.tiny
// throughout keeps it a corner detail instead of something competing
// with the chart for attention.
var table statusTable = na
if showStatusTable and barstate.islast
    if na(statusTable)
        statusTable := table.new(position.top_right, 2, 10, bgcolor = color.new(#131722, 10), border_color = color.new(color.gray, 60), border_width = 1)
        // table.merge_cells(statusTable, 0, 0, 1, 0)
        // table.merge_cells(statusTable, 0, 6, 1, 6)

    regimeText  = not clusterReady ? "Calibrating..." : regime == 0 ? "Low ●" : regime == 1 ? "Medium ●" : "High ●"
    regimeColor = not clusterReady ? color.gray : regime == 0 ? color.new(#10B981, 0) : regime == 1 ? color.new(#5B8DEF, 0) : color.new(#DC2626, 0)
    // Confidence text turns amber when the AI is ready but below the
    // Minimum Regime Confidence threshold, so a glance at the table
    // explains why adaptive width/signals/background might be sitting
    // out despite a regime being shown above.
    confidenceText  = not clusterReady ? "—" : str.tostring(regimeConfidence, "0") + "%"
    confidenceColor = not clusterReady ? color.gray : confidentRegime ? color.silver : color.new(#F59E0B, 0)

    winRateText    = totalSignals > 0 ? str.tostring(winRatePct, "0") + "%" : "—"
    winRateColor   = totalSignals == 0 ? color.gray : winRatePct >= 50 ? color.new(#10B981, 0) : color.new(#DC2626, 0)
    avgReturnText  = totalSignals > 0 ? (avgReturnPct >= 0 ? "+" : "") + str.tostring(avgReturnPct, "0.00") + "%" : "—"
    avgReturnColor = totalSignals == 0 ? color.gray : avgReturnPct >= 0 ? color.new(#10B981, 0) : color.new(#DC2626, 0)

    table.cell(statusTable, 0, 0, "VWAP REGIME AI", text_color = vwapColor, text_size = size.tiny, text_halign = text.align_center)
    table.cell(statusTable, 0, 1, "Regime", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(statusTable, 1, 1, regimeText, text_color = regimeColor, text_size = size.tiny, text_halign = text.align_right)
    table.cell(statusTable, 0, 2, "Confidence", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(statusTable, 1, 2, confidenceText, text_color = confidenceColor, text_size = size.tiny, text_halign = text.align_right)
    table.cell(statusTable, 0, 3, "Band Scale", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(statusTable, 1, 3, str.tostring(bandScale, "0.00") + "x", text_color = color.silver, text_size = size.tiny, text_halign = text.align_right)
    table.cell(statusTable, 0, 4, "VWAP", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(statusTable, 1, 4, str.tostring(vwapValue, format.mintick), text_color = color.silver, text_size = size.tiny, text_halign = text.align_right)
    table.cell(statusTable, 0, 5, "Stretch", text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
    table.cell(statusTable, 1, 5, (stretchScore >= 0 ? "+" : "") + str.tostring(stretchScore, "0.00") + "σ", text_color = stretchColor, text_size = size.tiny, text_halign = text.align_right)

// ───────────────────────── Buy / Sell Markers ─────────────────────────
// No BUY/SELL text on the markers on purpose — the shape, position
// (below/above the bar) and color already say everything the text would,
// so the text is pure clutter. A small, quiet triangle reads as more
// premium than a loud, labeled one. The glow now uses the SAME triangle
// shape one size step up (instead of a circle), so it hugs the marker as
// a tight halo rather than reading as a separate round blob sitting
// behind an unrelated shape — more minimal silhouette, same soft-glow polish.
plotshape(showSignals and bullSignal, title = "Buy Signal Glow",
     style = shape.triangleup, location = location.belowbar,
     color = color.new(buySignalColor, 70), size = size.small)
plotshape(showSignals and bullSignal, title = "Buy Signal",
     style = shape.triangleup, location = location.belowbar,
     color = buySignalColor, size = size.tiny)

plotshape(showSignals and bearSignal, title = "Sell Signal Glow",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(sellSignalColor, 70), size = size.small)
plotshape(showSignals and bearSignal, title = "Sell Signal",
     style = shape.triangledown, location = location.abovebar,
     color = sellSignalColor, size = size.tiny)


// ───────────────────────── Alerts ─────────────────────────
alertcondition(bullSignal, title = "VWAP Regime AI Bullish Signal",
     message = "VWAP Regime AI: bullish signal on {{ticker}} ({{interval}}).")

alertcondition(bearSignal, title = "VWAP Regime AI Bearish Signal",
     message = "VWAP Regime AI: bearish signal on {{ticker}} ({{interval}}).")

// Fires the moment the AI's volatility regime flips (e.g. Low -> High),
// independent of any buy/sell signal — useful on its own as a heads-up
// that conditions just changed. Requires both this bar AND the previous
// bar to have been confident classifications, so the very first
// classification after calibration isn't mistaken for a "change".
regimeChanged = confidentRegime and confidentRegime[1] and regime != regime[1]
regimeName = regime == 0 ? "Low" : regime == 1 ? "Medium" : "High"

if regimeChanged
    alert("VWAP Regime AI: volatility regime changed to " + regimeName + " on " + syminfo.ticker, alert.freq_once_per_bar_close)

alertcondition(regimeChanged, title = "VWAP Regime AI Regime Change",
     message = "VWAP Regime AI: volatility regime changed on {{ticker}} ({{interval}}).")


wm_theme     = input.string('Light', 'Watermark Theme', group=' A X E A L G O ', options=['Dark', 'Light'])

if true//barstate.islast
    dark        = wm_theme == 'Dark'
    wm_bg       = dark ? color.new(#0d1117, 0)  : color.new(#f0f2f5, 0)
    wm_dot_col  = dark ? color.new(#26a69a, 25) : color.new(#26a69a, 10)
    wm_txt_col  = dark ? color.new(#4d5566, 0)  : color.new(#6b7280, 0)
    wm_frm_col  = dark ? color.new(#2a2e39, 0)  : color.new(#c8cdd6, 0)

    wm = table.new(position.bottom_center, 2, 1,
                   frame_color=wm_frm_col,
                   frame_width=1,
                   border_width=0)
    table.cell(wm, 0, 0, ' ◆ ',
               bgcolor=wm_bg,
               text_color=wm_dot_col,
               text_size=size.small,
               text_halign=text.align_center,
               text_valign=text.align_center)
    table.cell(wm, 1, 0, ' 𝙰 ꊼ 𝙴 𝙰 𝙻 𝙶 𝙾',
               bgcolor=wm_bg,
               text_color=wm_txt_col,
               text_size=size.normal,
               text_halign=text.align_left,
               text_valign=text.align_center)
````
