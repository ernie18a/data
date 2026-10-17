# AetherEdge - Hierarchical Temporal Memory Inspired

- url: https://www.tradingview.com/script/sBoZwZa4/
- type: indicator
- pine_id: PUB;e4bc69a2b1684f85b183c904b793a259
- version: 1.0

## Description

🖊️ Overview

A sequence-memory engine inspired by HTM (Hierarchical Temporal Memory), a model of how the neocortex learns sequences. Fundamentally different from KNN similarity-search or LSTM weighted regression, HTM stores knowledge as a sparse columnar memory and learns which column tends to follow which. Each bar's market state is encoded into a Sparse Distributed Representation (SDR) where only a few of many columns activate. A transition memory (permanence weights between columns) learns the sequence "column A → column B," and every new bar the engine predicts which columns should activate next. When an unpredicted column fires instead, that is an anomalous transition — a break in the learned temporal pattern. The mismatch is the anomaly score, and its inverse is sequence stability. Visualization: a faint vertical line only on high-anomaly bars, plus a single Sequence Stability indicator.

🔶 Key Features

HTM-style sequence memory — brain-inspired columnar memory learns temporal patterns (fundamentally unlike KNN/LSTM)
SDR (sparse distributed representation) — encodes each bar into a few active columns
Transition learning — Hebbian strengthening/decay of inter-column permanence stores sequences
Predictive cells — predicts next-bar columns from learned transitions (higher-order capable)
Anomalous-transition detection — scores the firing of unpredicted columns as anomaly
Anomaly-bar emphasis — a faint vertical line only on bars whose anomaly clears the gate (noise excluded)
Sequence Stability — a single lower-pane stability readout (green stable → red anomalous gradient)
Intelligence panel — anomaly score, stability, an active-SDR visualization, predicted/hit counts, and learned-link count

🧠 Technical Architecture

The engine encodes the market state into four features (momentum, RSI deviation, volatility, position-within-range, all normalized) and turns them into an SDR. Each column has a fixed random receptive field (a spatial-pooler proxy); the top activeCols columns by overlap with the current state win and fire (k-winners-take-all). Similar states thus activate similar column sets, different states different ones.
The transition memory is a permanence matrix perm[a→b]. Learning follows the Hebbian rule: if column A fired and B fired on the next bar, the link A→B is strengthened (permanence +permInc); links whose predictions failed decay (−permDec). Only links above the connection threshold can predict.
For prediction, from the recently-fired columns (both t-1 and t-2 for higher order) the engine follows connected links to build the set of columns expected to fire next. Of the columns that actually fire next bar, the predicted fraction is hits/active, and the anomaly score = 1 − hits/active (the share of unpredicted firings). As learning matures and patterns stay stable, predictions land and anomaly is low; when patterns break, predictions miss and anomaly spikes.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Columns 16, Active Columns 3, Permanence Inc 0.10 / Dec 0.04, Prediction Order 2, Anomaly Threshold 0.55. Standard settings fit well
ETH (1H–4H): As BTC (HTM learns sequences self-supervised, no outcome window needed)
SOL (15m–1H): High volatility favors Anomaly Smoothing 5–6 to smooth the score, Anomaly Threshold 0.6 to suppress false anomalies
XRP (1H–4H): Spike-prone; Columns 20 for more capacity, Prediction Order 1 to weight recent transitions
Columns / Active Columns: more columns add capacity but slow learning; sparsity (Active/Columns) is the heart of HTM — lower is more HTM-like
Permanence Inc/Dec: higher Inc learns faster, higher Dec forgets old memory faster — tune to how fast the market changes
Prediction Order: higher considers longer context (higher-order sequences); lower uses only recent transitions
Anomaly Threshold: higher makes vertical lines rare (only large anomalies); lower more frequent

💡 How to Use in Practice

Reacting to anomaly lines: a vertical line marks a bar where the learned temporal pattern broke — often the onset of a trend change, breakout, or regime shift; a basis for caution or reversal
Reading Sequence Stability: high (green) = the market follows learned patterns (predictable); low (red) = patterns broke, unpredictable. A sudden drop signals an environment change
Interpreting anomalies: sustained anomalies = a regime change in progress; a one-off = a transient shock — stability recovery means adaptation to a new pattern is done
Watching the active SDR: the panel's SDR view (▰▱) shows which columns fire now; recurring SDRs = known patterns, novel SDRs = unfamiliar conditions
Using predicted/hit counts: hits near predicted = stable sequence; a gap = anomaly — also a gauge of learning maturity
Multi-timeframe usage: confirm the big-picture sequence stability on the higher timeframe (4H), then time turns on anomaly lines on the lower one (15m–1H)

⚠️ Important Notes

Initial learning period: right after launch the transition memory is empty and everything looks "anomalous"; treat anomaly as elevated until enough transitions are learned (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the column receptive fields, transition memory, and SDR history, restarting learning from zero
Anomaly ≠ trade signal: an anomalous transition marks a "pattern break," not a direction (buy/sell); use it as a caution signal of possible change and pair direction calls with other analysis
Sparsity constraint: to fit Pine's compute budget, this is a lightweight build with fewer columns than a true HTM — not as sparse as HTM's ~2%
Adaptive-system nature: historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation within Pine's compute budget; it scans a columns × columns transition matrix, so very large column counts affect performance

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The HTM-style sequence memory, SDR encoding, transition learning, anomaly score, and sequence stability are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Anomaly detection can produce false positives. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Hierarchical Temporal Memory Inspired
//   AI Drawing Power Series
//
//   A sequence-memory engine inspired by HTM (Hierarchical Temporal Memory) — a model of how the
//   neocortex learns sequences. Fundamentally different from KNN similarity-search or LSTM weighted
//   regression, HTM stores knowledge as a SPARSE columnar memory and learns WHICH column tends to
//   follow which. Each bar's market state is encoded into a Sparse Distributed Representation (SDR):
//   only a few of many columns activate. A transition memory (permanence weights between columns)
//   learns the sequence "column A → column B". On every new bar the engine PREDICTS which columns
//   should activate next; when an unpredicted column fires instead, that is an ANOMALOUS TRANSITION —
//   a break in the learned temporal pattern. The mismatch between prediction and reality is the
//   anomaly score, and its inverse is sequence stability.
//
//   Visualization: a faint vertical line only on high-anomaly bars, plus a single Sequence Stability
//   indicator. A genuinely different time-series memory approach.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Hierarchical Temporal Memory Inspired", "AE-HTM SM", overlay = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_ENC   = "◆  SDR ENCODER"
var string GRP_HTM   = "◆  HTM SEQUENCE MEMORY"
var string GRP_ANOM  = "◆  ANOMALY DETECTION"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — SDR Encoder —
nColumns     = input.int(16,   "Columns",        minval = 6, maxval = 32, group = GRP_ENC, tooltip = "Total number of columns in the sparse representation. Each encodes a region of market-state space.")
activeCols   = input.int(3,    "Active Columns (sparsity)", minval = 1, maxval = 8, group = GRP_ENC, tooltip = "How many columns activate per bar. Low = sparse (HTM-like). Typically ~2% but kept higher here for a compact build.")
fastLen      = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_ENC)
slowLen      = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_ENC)
rsiLen       = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_ENC)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_ENC)

// — HTM Sequence Memory —
permInc      = input.float(0.10,"Permanence Increment", minval = 0.01, maxval = 0.5, step = 0.01, group = GRP_HTM, tooltip = "How much a column→column link strengthens when its prediction proves correct (Hebbian-style).")
permDec      = input.float(0.04,"Permanence Decrement", minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_HTM, tooltip = "How much an incorrect / unused link decays.")
permThresh   = input.float(0.40,"Connection Threshold", minval = 0.1, maxval = 0.9, step = 0.05, group = GRP_HTM, tooltip = "A link is 'connected' (capable of predicting) once its permanence exceeds this.")
predictDepth = input.int(2,    "Prediction Order", minval = 1, maxval = 4, group = GRP_HTM, tooltip = "How many prior bars' active columns vote into the next-bar prediction (temporal order).")

// — Anomaly Detection —
anomSmooth   = input.int(4,    "Anomaly Smoothing", minval = 1, maxval = 30, group = GRP_ANOM)
anomGate     = input.float(0.55,"Anomaly Line Threshold", minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_ANOM, tooltip = "Vertical lines are drawn only on bars whose anomaly score exceeds this.")
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_ANOM)

// — Aesthetics —
colStable    = input.color(#21d3a3, "Stable Tone",  group = GRP_STYLE, inline = "c1")
colAnomaly   = input.color(#ff5d73, "Anomaly Tone", group = GRP_STYLE, inline = "c1")
colMid       = input.color(#5ce1ff, "Stability Line", group = GRP_STYLE)
lineWidth    = input.int(1,    "Anomaly Line Width", minval = 1, maxval = 4, group = GRP_STYLE)
showStab     = input.bool(true, "Sequence Stability (lower pane)", group = GRP_STYLE)
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)

// — Intelligence Panel —
showPanel    = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize    = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0a0d15, 8)
var color THEME_GRID = color.new(#222b40, 38)
var color THEME_TXT  = #d2dae8
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff
var color THEME_GOLD = #f4c25b

var int MAXCOL = 32

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  STATE FEATURES  → SDR ENCODING
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(14)
hh      = ta.highest(high, slowLen)
ll      = ta.lowest(low, slowLen)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

rawMom = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawRsi = (rsi - 50.0) / 50.0
rawVol = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen)) - 1.0
rawPos = (hh - ll) == 0 ? 0.0 : (close - ll) / (hh - ll) * 2.0 - 1.0

fMom = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
fRsi = rawRsi
fVol = f_znorm(rawVol, ta.sma(rawVol, normLen), ta.stdev(rawVol, normLen))
fPos = rawPos

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SDR ENCODER  — map the continuous state to a sparse set of active columns.
//  Each column has a random "receptive field" (a weight vector over the 4 features). The columns
//  with the strongest overlap to the current state win (k-winners-take-all) and become active.
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

var int N_FEAT = 4

// column receptive fields [nColumns x N_FEAT], fixed at init (spatial pooler proxy)
var array<float> colRF = na
// transition permanence matrix [MAXCOL x MAXCOL]: perm[a*MAXCOL+b] = strength of "a predicts b"
var array<float> perm = na
var bool htmInit = false

if not htmInit
    colRF := array.new_float(MAXCOL * N_FEAT, 0.0)
    int sd = 9176
    for i = 0 to MAXCOL * N_FEAT - 1
        sd := sd + 2654435761
        array.set(colRF, i, (f_rand(sd) - 0.5) * 2.0)
    perm := array.new_float(MAXCOL * MAXCOL, 0.0)
    htmInit := true

// compute overlap of current state with each column, then pick top-`activeCols` as the active SDR.
// returns an array of active column indices (size activeCols).
f_encodeSDR(float a0, float a1, float a2, float a3) =>
    overlaps = array.new_float(nColumns, 0.0)
    for c = 0 to nColumns - 1
        float ov = 0.0
        ov += array.get(colRF, c * N_FEAT + 0) * a0
        ov += array.get(colRF, c * N_FEAT + 1) * a1
        ov += array.get(colRF, c * N_FEAT + 2) * a2
        ov += array.get(colRF, c * N_FEAT + 3) * a3
        array.set(overlaps, c, ov)
    // k-winners-take-all: select activeCols highest overlaps
    active = array.new_int()
    tmp = array.copy(overlaps)
    int kk = math.min(activeCols, nColumns)
    for w = 0 to kk - 1
        float mx = array.max(tmp)
        int mi = array.indexof(tmp, mx)
        array.push(active, mi)
        array.set(tmp, mi, -1e18)
    active

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  HTM SEQUENCE MEMORY  — learn column→column transitions; predict next active columns; score anomaly
// ════════════════════════════════════════════════════════════════════════════════════════════════

// rolling memory of recent active-column sets (for higher-order prediction)
var array<int> prevActive1 = array.new_int()   // active columns at t-1
var array<int> prevActive2 = array.new_int()   // active columns at t-2

// predicted columns for the CURRENT bar (computed at the end of the previous bar)
var array<int> predicted = array.new_int()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float anomalyRaw = na
var float anomalyEma = na
var float stability = na
var int   liveActiveN = 0
var int   livePredN = 0
var int   liveHitN = 0

// helper: is column c in array arr?
f_contains(array<int> arr, int c) =>
    bool found = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if array.get(arr, i) == c
                found := true
    found

// build prediction for next bar: for each connected link from a recently-active column a → b,
// column b becomes predicted. Higher-order: both t-1 and t-2 active sets vote (depth).
f_predictNext(array<int> act1, array<int> act2) =>
    predSet = array.new_int()
    // first-order: from t-1 active columns
    if array.size(act1) > 0
        for i = 0 to array.size(act1) - 1
            int a = array.get(act1, i)
            for b = 0 to nColumns - 1
                if array.get(perm, a * MAXCOL + b) >= permThresh and not f_contains(predSet, b)
                    array.push(predSet, b)
    // higher-order: from t-2 active columns (if depth >= 2), weaker contribution but same set
    if predictDepth >= 2 and array.size(act2) > 0
        for i = 0 to array.size(act2) - 1
            int a = array.get(act2, i)
            for b = 0 to nColumns - 1
                if array.get(perm, a * MAXCOL + b) >= permThresh * 1.2 and not f_contains(predSet, b)
                    array.push(predSet, b)
    predSet

// learning: strengthen links from previously-active columns to the columns that ACTUALLY activated;
// decay links that predicted activation that did NOT occur.
f_learn(array<int> prevAct, array<int> nowAct) =>
    if array.size(prevAct) > 0
        for i = 0 to array.size(prevAct) - 1
            int a = array.get(prevAct, i)
            for b = 0 to nColumns - 1
                int idx = a * MAXCOL + b
                float p = array.get(perm, idx)
                if f_contains(nowAct, b)
                    // a was active and b followed → strengthen (Hebbian)
                    array.set(perm, idx, math.min(1.0, p + permInc))
                else if p > 0.0
                    // link predicted b but it didn't fire → decay
                    array.set(perm, idx, math.max(0.0, p - permDec))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<int> liveActive = array.new_int()

if inHorizon and barstate.isconfirmed
    // 1) encode current bar into an SDR (active columns)
    nowActive = f_encodeSDR(fMom, fRsi, fVol, fPos)

    // 2) anomaly = fraction of currently-active columns that were NOT predicted
    int hits = 0
    if array.size(nowActive) > 0
        for i = 0 to array.size(nowActive) - 1
            if f_contains(predicted, array.get(nowActive, i))
                hits += 1
    int actN = array.size(nowActive)
    anomalyRaw := actN == 0 ? 0.0 : 1.0 - (hits / actN)

    liveActiveN := actN
    livePredN := array.size(predicted)
    liveHitN := hits

    anomalyEma := na(anomalyEma) ? anomalyRaw : (anomalyRaw * (2.0 / (anomSmooth + 1)) + anomalyEma * (1.0 - 2.0 / (anomSmooth + 1)))
    stability := 1.0 - (na(anomalyEma) ? 0.0 : anomalyEma)

    // 3) learn transitions: previous active → now active
    f_learn(prevActive1, nowActive)

    // 4) shift temporal memory and build next-bar prediction
    // copy nowActive into liveActive (for panel) and rotate prev buffers
    array.clear(liveActive)
    if array.size(nowActive) > 0
        for i = 0 to array.size(nowActive) - 1
            array.push(liveActive, array.get(nowActive, i))

    // rotate: prevActive2 ← prevActive1 ← nowActive
    array.clear(prevActive2)
    if array.size(prevActive1) > 0
        for i = 0 to array.size(prevActive1) - 1
            array.push(prevActive2, array.get(prevActive1, i))
    array.clear(prevActive1)
    if array.size(nowActive) > 0
        for i = 0 to array.size(nowActive) - 1
            array.push(prevActive1, array.get(nowActive, i))

    // 5) predict the columns expected to activate on the NEXT bar
    nextPred = f_predictNext(prevActive1, prevActive2)
    array.clear(predicted)
    if array.size(nextPred) > 0
        for i = 0 to array.size(nextPred) - 1
            array.push(predicted, array.get(nextPred, i))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — faint vertical line on high-anomaly bars + Sequence Stability (lower pane)
// ════════════════════════════════════════════════════════════════════════════════════════════════

float anom = na(anomalyEma) ? 0.0 : anomalyEma
float stab = na(stability) ? 1.0 : stability
bool anomalyBar = inHorizon and barstate.isconfirmed and anom >= anomGate

// faint vertical line drawn only on anomalous bars (via a thin box spanning the visible range)
// We use line.new vertical (same x, top to bottom) anchored at extremes.
var array<line> anomLines = array.new<line>()

if anomalyBar
    float topY = high + atr * 0.5
    float botY = low - atr * 0.5
    // opacity scales with how far past the gate the anomaly is
    float over = math.min(1.0, (anom - anomGate) / math.max(0.01, 1.0 - anomGate))
    int tr = int(math.max(20, 78 - over * 50))
    line vl = line.new(bar_index, botY, bar_index, topY, xloc = xloc.bar_index, color = color.new(colAnomaly, tr), width = lineWidth, style = line.style_solid, force_overlay = true)
    array.push(anomLines, vl)
    // keep the line list bounded
    if array.size(anomLines) > 400
        line.delete(array.shift(anomLines))

// glow accent atop strong-anomaly bars
plotshape(glowFx and anomalyBar and anom > anomGate * 1.2, title = "Anomaly Mark", style = shape.xcross, location = location.abovebar, color = color.new(colAnomaly, 25), size = size.tiny, force_overlay = true)

// --- Sequence Stability indicator (this pane, since overlay=false) ---
// stability ∈ [0,1]; colored from anomaly tone (low) to stable tone (high).
color stabCol = color.from_gradient(stab, 0.0, 1.0, colAnomaly, colStable)
plot(showStab and inHorizon ? stab * 100.0 : na, "Sequence Stability", color = stabCol, linewidth = 2, style = plot.style_area)
plot(showStab and inHorizon ? stab * 100.0 : na, "Stability Line", color = color.new(stabCol, 0), linewidth = 2)
hline(50, "Mid", color = color.gray, linestyle = hline.style_dotted)
hline((1.0 - anomGate) * 100.0, "Anomaly Level", color = color.red, linestyle = hline.style_dashed)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_panelPos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_panelSize() =>
    switch panelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_bar(float v01) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * 12))
    string s = ""
    for i = 1 to 12
        s := s + (i <= filled ? "█" : "░")
    s

// build a compact SDR visualization string: ▰ = active column, ▱ = inactive
f_sdrString() =>
    string s = ""
    for c = 0 to nColumns - 1
        s := s + (f_contains(liveActive, c) ? "▰" : "▱")
    s

// count connected links in the permanence matrix (memory richness readout)
f_connCount() =>
    int cnt = 0
    for a = 0 to nColumns - 1
        for b = 0 to nColumns - 1
            if array.get(perm, a * MAXCOL + b) >= permThresh
                cnt += 1
    cnt

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 2, 9, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string state = anom >= anomGate ? "ANOMALY" : anom >= anomGate * 0.6 ? "ELEVATED" : "STABLE"
    color stateCol = anom >= anomGate ? colAnomaly : anom >= anomGate * 0.6 ? THEME_GOLD : colStable

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "HTM", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  SEQUENCE: " + state, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = stateCol)
    table.merge_cells(panel, 0, 1, 1, 1)

    table.cell(panel, 0, 2, "Anomaly Score", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, str.tostring(math.round(anom * 100)) + "%", text_color = anom >= anomGate ? colAnomaly : THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Sequence Stability", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(math.round(stab * 100)) + "%", text_color = stab >= 0.5 ? colStable : colAnomaly, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Stability Meter", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_bar(stab), text_color = color.from_gradient(stab, 0.0, 1.0, colAnomaly, colStable), text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "Active SDR", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 5, f_sdrString(), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 6, "Predicted / Hit", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(livePredN) + " / " + str.tostring(liveHitN), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "Learned Links", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(f_connCount()), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Columns / Sparsity", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, str.tostring(nColumns) + " / " + str.tostring(activeCols), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(anomalyBar, "HTM ▸ Anomalous Transition", "AetherEdge HTM: anomalous sequence transition detected.")
alertcondition(not na(stability) and stability < (1.0 - anomGate) and (na(stability[1]) or stability[1] >= (1.0 - anomGate)), "HTM ▸ Stability Breakdown", "AetherEdge HTM: sequence stability broke down.")
````
