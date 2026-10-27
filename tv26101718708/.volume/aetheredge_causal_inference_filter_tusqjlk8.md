# AetherEdge - Causal Inference Filter

- url: https://www.tradingview.com/script/TuSQjlk8/
- type: indicator
- pine_id: PUB;214f3b8f92194df3a31f4acca41e5502
- version: 1.0

## Description

🖊️ Overview

A causality-driven filter that asks not "what pattern is on the chart" but "what is actually driving price right now." Where SMC / Order-Block tools read price structure, this engine applies a scientific, causal lens. First, Granger-style causality — for each candidate driver (momentum, volatility, volume, range expansion), it measures whether the driver's past values help predict future returns beyond what past returns alone explain. That is predictive precedence, not mere correlation. Second, NeuraLib feature importance — a small network learns to forecast forward returns, and an ablation-style importance score reveals which driver the model actually relies on. The two combine into a causal confidence: signals fire only when a true driver is clearly identified; in noisy, causally-ambiguous regimes the filter stays silent. Visualization: soft rectangular boxes only over high-causal-confidence zones, plus simple arrows.

🔶 Key Features

Granger-style predictive power — measures whether a driver's past precedes future returns (not mere correlation), correlation-based
NeuraLib feature importance — an ablation-style score identifies the driver the model truly relies on
True-driver identification — extracts the dominant driver from four candidates (momentum/volatility/volume/range-exp)
Causal confidence — a causal-clarity score blending Granger lift and importance concentration
Noise rejection — signals only when causality is clear; suppressed when ambiguous
Causal zones — soft rectangular boxes only in high-confidence conditions (opacity by confidence)
Simple arrows — causally-confirmed directional signals shown with minimal arrows
Intelligence panel — causal confidence, the true driver, each driver's importance and Granger lift, and the forecast at a glance

🧠 Technical Architecture

The engine tests the causal influence of four candidate drivers (momentum, volatility, volume anomaly, range expansion — all normalized).
Granger causality: for each driver d, it computes the rolling correlation between the driver lagged by grangerLag and the current return. If the driver's past predicts today's move, that is predictive precedence (Granger-like). The return's own autocorrelation (how past returns explain the future) is subtracted as a baseline, isolating the causal lift the driver adds — distinguishing "merely correlated" from "predictively precedent."
Feature importance: the NeuraLib network (drivers(4) → hidden(tanh) → forward-return forecast(1)) learns to forecast forward returns by supervision. Each driver's importance is the change in forecast when that driver is "ablated" (set to 0): |full forecast − ablated forecast| — a method inspired by permutation importance.
Causal confidence is a [0,1] blend of the dominant driver's Granger lift and the importance concentration (the top driver's share of total importance = causal clarity). Only when it clears the gate do arrows and causal zones fire. Zones are drawn with width and opacity scaled by confidence, extend right via extend.right, and retire past their lifespan.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Causal Lag 5, Causality Window 60, Min Causal Lift 0.15, Min Causal Confidence 0.50. Standard settings fit well
ETH (1H–4H): As BTC, with Forward Outcome 5–8
SOL (15m–1H): High volatility favors Confidence Smoothing 4–5 to smooth confidence, Min Confidence 0.55 to reject noise more strictly
XRP (1H–4H): Spike-prone; Causal Lag 3 for shorter precedence, Causality Window 50 to weight recent causality
Causal Lag: the assumed bars by which a driver precedes price — tune to the market's reaction speed
Causality Window: longer is a steadier causal estimate; shorter is nimbler — ~60 is practical
Min Causal Lift: the minimum predictive power for a driver to count as causal — higher is stricter
Min Causal Confidence: the firing threshold for signals/zones — higher narrows to only the clearest causality

💡 How to Use in Practice

Reacting to causal arrows: an arrow marks where a clear causal driver is identified and a direction predicted — a low-false-signal entry basis grounded in statistical causality, not structure patterns
Reading causal zones: a soft box is a price band of high causal confidence; within it causality is clear and price tends to respect the zone — a causal take on support/resistance
Confirming the true driver: the panel's "True Driver" shows whether momentum, volatility, volume, or range is moving price now (e.g. a dominant VOLUME means a volume-led market)
Avoiding ambiguous regimes: low-confidence (AMBIGUOUS) conditions mean the driver is unclear — a noisy market; the absence of a signal is itself a "wait" signal
Checking driver lift: the panel's per-driver Granger lift shows which drivers predictively precede; those above the lift threshold lead
Multi-timeframe usage: confirm the dominant driver and causal direction on the higher timeframe (4H), then time on causal zones and arrows on the lower one (15m–1H)

⚠️ Important Notes

Approximate causal inference: the Granger causality here is a lightweight correlation-based approximation fit to Pine's compute budget — not a rigorous Granger test (VAR regression / F-test), but a heuristic indicator of predictive precedence
Correlation ≠ causation limit: statistical causal inference is powerful but cannot fully exclude hidden common factors (confounders); "causal" means statistical predictive power, not proof of true economic causation
Initial learning period: right after launch the network's buffer is nearly empty and importance estimates are unstable; treat causal confidence as low-confidence until it learns (several hundred bars)
Learning resets: changing parameters, symbol/timeframe, or recompiling reinitializes the network weights and buffer
On look-ahead: the importance target uses closed-bar realized returns (a standard training construct); as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Granger causality, feature importance, causal confidence, causal zones, and signals are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Even statistical causal inference can misidentify. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Causal Inference Filter
//   AI Drawing Power Series
//
//   A causality-driven filter that asks not "what pattern is on the chart" but "what is actually
//   DRIVING price right now." Where SMC / Order-Block tools read price structure, this engine applies
//   a scientific, causal lens:
//     • GRANGER-STYLE CAUSALITY — for each candidate driver (volume, volatility, momentum, range
//       expansion), it measures whether the driver's PAST values help predict future returns beyond
//       what past returns alone explain. That is predictive precedence — not mere correlation.
//     • NEURALIB FEATURE IMPORTANCE — a small network learns to forecast forward returns; a
//       permutation-style importance score reveals which driver the model actually relies on.
//   The two combine into a CAUSAL CONFIDENCE. Signals fire only when a true driver is clearly
//   identified; in noisy, causally-ambiguous regimes the filter stays silent.
//
//   Visualization: soft rectangular boxes only over high-causal-confidence zones, plus simple arrows.
//   A more scientific, causality-based alternative to structure-only tools.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Causal Inference Filter", "AE-CI F", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_DRIVE = "◆  CANDIDATE DRIVERS"
var string GRP_GRANGER="◆  GRANGER CAUSALITY"
var string GRP_NET   = "◆  FEATURE IMPORTANCE (NeuraLib)"
var string GRP_SIG   = "◆  CAUSAL SIGNAL"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Candidate Drivers —
momLen       = input.int(14,   "Momentum Driver Length", minval = 2, maxval = 100, group = GRP_DRIVE)
volaLen      = input.int(14,   "Volatility Driver Length", minval = 2, maxval = 100, group = GRP_DRIVE)
volLen       = input.int(20,   "Volume Driver Length", minval = 2, maxval = 100, group = GRP_DRIVE)
rngLen       = input.int(14,   "Range-Expansion Length", minval = 2, maxval = 100, group = GRP_DRIVE)
normLen      = input.int(120,  "Driver Norm Window", minval = 20, maxval = 1000, group = GRP_DRIVE)

// — Granger Causality —
grangerLag   = input.int(5,    "Causal Lag (bars)", minval = 1, maxval = 20, group = GRP_GRANGER, tooltip = "How far back a driver's past must precede the predicted move — the predictive-precedence horizon.")
grangerWin   = input.int(60,   "Causality Window", minval = 20, maxval = 400, group = GRP_GRANGER, tooltip = "Rolling window over which Granger-style predictive power is estimated.")
grangerGate  = input.float(0.15,"Min Causal Lift", minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_GRANGER, tooltip = "Minimum improvement a driver must add to forward-return prediction (vs. returns alone) to count as causal.")

// — Feature Importance —
hiddenN      = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_NET)
learnRate    = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_NET)
bufferCap    = input.int(150,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_NET)
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_NET)
predLook     = input.int(5,    "Forward Outcome (bars)", minval = 1, maxval = 20, group = GRP_NET)
seedInp      = input.int(61,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Causal Signal —
confGate     = input.float(0.50,"Min Causal Confidence", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_SIG, tooltip = "Signals & zones appear only when causal confidence (Granger ⊕ importance) clears this gate.")
confSmooth   = input.int(3,    "Confidence Smoothing", minval = 1, maxval = 20, group = GRP_SIG)
oncePerMove  = input.bool(true,"One Arrow per Directional Shift", group = GRP_SIG)

// — Aesthetics —
colLong      = input.color(#21d3a3, "Bullish Tone", group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Bearish Tone", group = GRP_STYLE, inline = "c1")
colZone      = input.color(#5ce1ff, "Causal Zone", group = GRP_STYLE)
zoneTransp   = input.int(86,   "Zone Transparency", minval = 70, maxval = 96, group = GRP_STYLE)
maxZones     = input.int(6,    "Max Visible Zones", minval = 1, maxval = 20, group = GRP_STYLE)
zoneLife     = input.int(120,  "Zone Lifespan (bars)", minval = 10, maxval = 1000, group = GRP_STYLE)
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

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ACTIVATIONS / PRNG
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_tanh(float x) =>
    float xc = math.max(-20.0, math.min(20.0, x))
    float e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

f_dtanh(float y) =>
    1.0 - y * y

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  CANDIDATE DRIVERS  — the variables whose causal influence we test
// ────────────────────────────────────────────────────────────────────────────────────────────────

atr = ta.atr(14)

ret1 = (close - close[1]) / (close[1] == 0 ? 1.0 : close[1])

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

// driver 0: momentum
drvMomRaw = (ta.ema(close, momLen) - ta.ema(close, momLen * 2)) / (atr == 0 ? 1.0 : atr)
drvMom = f_znorm(drvMomRaw, ta.sma(drvMomRaw, normLen), ta.stdev(drvMomRaw, normLen))
// driver 1: volatility
drvVolaRaw = ta.atr(volaLen) / (ta.sma(ta.atr(volaLen), normLen) == 0 ? 1.0 : ta.sma(ta.atr(volaLen), normLen)) - 1.0
drvVola = f_znorm(drvVolaRaw, ta.sma(drvVolaRaw, normLen), ta.stdev(drvVolaRaw, normLen))
// driver 2: volume
drvVolRaw = volume / (ta.sma(volume, volLen) == 0 ? 1.0 : ta.sma(volume, volLen)) - 1.0
drvVol = f_znorm(drvVolRaw, ta.sma(drvVolRaw, normLen), ta.stdev(drvVolRaw, normLen))
// driver 3: range expansion
drvRngRaw = (high - low) / (ta.sma(high - low, rngLen) == 0 ? 1.0 : ta.sma(high - low, rngLen)) - 1.0
drvRng = f_znorm(drvRngRaw, ta.sma(drvRngRaw, normLen), ta.stdev(drvRngRaw, normLen))

var int N_DRV = 4

f_driverName(int d) =>
    d == 0 ? "MOMENTUM" : d == 1 ? "VOLATILITY" : d == 2 ? "VOLUME" : "RANGE-EXP"

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  GRANGER-STYLE CAUSALITY
//  For each driver d, compare two rolling predictors of the forward return:
//    (A) baseline: forward return predicted by PAST RETURNS only (autoregressive)
//    (B) augmented: forward return predicted by past returns + driver's PAST value (lagged)
//  Granger "causal lift" = reduction in prediction error (A_err − B_err) / A_err, clamped to [0,1].
//  We approximate via rolling correlation of the LAGGED driver with the forward return, net of the
//  forward return's own autocorrelation (a lightweight Granger proxy suited to Pine).
// ════════════════════════════════════════════════════════════════════════════════════════════════

// forward return target (realized) and the lagged driver values
fwdRet = (close[0] - close[grangerLag]) / (close[grangerLag] == 0 ? 1.0 : close[grangerLag])

// rolling correlation between a driver lagged by grangerLag and the current return:
// if driver[lag] predicts today's move, that's predictive precedence (Granger-like).
f_causalLift(float drvLagged, float retNow) =>
    float c = ta.correlation(drvLagged, retNow, grangerWin)
    na(c) ? 0.0 : math.abs(c)

// baseline: autocorrelation of returns (what returns predict about themselves)
retAuto = ta.correlation(ret1[grangerLag], ret1, grangerWin)
retAuto := na(retAuto) ? 0.0 : math.abs(retAuto)

// per-driver causal lift = |corr(driver[lag], ret)| minus the autoregressive baseline, floored at 0
lift0 = math.max(0.0, f_causalLift(drvMom[grangerLag], ret1) - retAuto * 0.5)
lift1 = math.max(0.0, f_causalLift(drvVola[grangerLag], ret1) - retAuto * 0.5)
lift2 = math.max(0.0, f_causalLift(drvVol[grangerLag], ret1) - retAuto * 0.5)
lift3 = math.max(0.0, f_causalLift(drvRng[grangerLag], ret1) - retAuto * 0.5)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  NEURALIB FORECAST NET + FEATURE IMPORTANCE
//  Net: drivers(4) → hidden(tanh) → forward-return forecast(1, tanh).
//  Importance(d) ≈ how much the output changes when driver d is "ablated" (set to 0) vs. full input
//  (a permutation/ablation-style importance), measured on the current bar.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> W1 = na
var array<float> b1 = na
var array<float> W2 = na
var array<float> b2 = na
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(hiddenN * N_DRV, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    W2 := array.new_float(hiddenN, 0.0)
    b2 := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.6)
    f_initRange(W2, seedInp * 40503 + 101, 0.6)
    netInit := true

f_forecast(float d0, float d1, float d2, float d3, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_DRV + 0) * d0
        z += array.get(W1, h * N_DRV + 1) * d1
        z += array.get(W1, h * N_DRV + 2) * d2
        z += array.get(W1, h * N_DRV + 3) * d3
        array.push(hC, f_tanh(z))
    float o = array.get(b2, 0)
    for h = 0 to hiddenN - 1
        o += array.get(W2, h) * array.get(hC, h)
    f_tanh(o)

// ablation-style importance: |full forecast − forecast with driver d zeroed|
var array<float> hAbl = array.new_float()
f_importance(int d, float d0, float d1, float d2, float d3, float fullOut) =>
    float a0 = d == 0 ? 0.0 : d0
    float a1 = d == 1 ? 0.0 : d1
    float a2 = d == 2 ? 0.0 : d2
    float a3 = d == 3 ? 0.0 : d3
    float ablOut = f_forecast(a0, a1, a2, a3, hAbl)
    math.abs(fullOut - ablOut)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER + TRAINING (supervised forecast of forward return)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bD0 = array.new_float()
var array<float> bD1 = array.new_float()
var array<float> bD2 = array.new_float()
var array<float> bD3 = array.new_float()
var array<float> bTgt = array.new_float()

f_push(float d0, float d1, float d2, float d3, float tgt) =>
    array.push(bD0, d0)
    array.push(bD1, d1)
    array.push(bD2, d2)
    array.push(bD3, d3)
    array.push(bTgt, tgt)
    if array.size(bTgt) > bufferCap
        array.shift(bD0)
        array.shift(bD1)
        array.shift(bD2)
        array.shift(bD3)
        array.shift(bTgt)

fwdTarget = math.max(-1.0, math.min(1.0, (close - close[predLook]) / (atr == 0 ? 1.0 : atr)))

var array<float> hTr = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bTgt) > 0
        float d0 = array.get(bD0, idx)
        float d1 = array.get(bD1, idx)
        float d2 = array.get(bD2, idx)
        float d3 = array.get(bD3, idx)
        float tgt = array.get(bTgt, idx)

        float pred = f_forecast(d0, d1, d2, d3, hTr)
        float err = math.max(-3.0, math.min(3.0, pred - tgt)) * f_dtanh(pred)

        gH = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            array.set(gH, h, err * array.get(W2, h))
            array.set(W2, h, array.get(W2, h) - learnRate * err * array.get(hTr, h))
        array.set(b2, 0, array.get(b2, 0) - learnRate * err)
        for h = 0 to hiddenN - 1
            float dz = array.get(gH, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_DRV + 0, array.get(W1, h * N_DRV + 0) - learnRate * dz * d0)
            array.set(W1, h * N_DRV + 1, array.get(W1, h * N_DRV + 1) - learnRate * dz * d1)
            array.set(W1, h * N_DRV + 2, array.get(W1, h * N_DRV + 2) - learnRate * dz * d2)
            array.set(W1, h * N_DRV + 3, array.get(W1, h * N_DRV + 3) - learnRate * dz * d3)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  CAUSAL ZONE OBJECT
// ════════════════════════════════════════════════════════════════════════════════════════════════

type CZone
    box  bx
    int  bornBar
    bool isLong

var array<CZone> zones = array.new<CZone>()

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pD0 = na
var float pD1 = na
var float pD2 = na
var float pD3 = na

var float liveForecast = na
var float liveConf = 0.0
var float confEma = na
var int   topDriver = 0
var float imp0 = 0.0
var float imp1 = 0.0
var float imp2 = 0.0
var float imp3 = 0.0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pD0)
        f_push(pD0, pD1, pD2, pD3, fwdTarget)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bTgt)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)

    pD0 := drvMom
    pD1 := drvVola
    pD2 := drvVol
    pD3 := drvRng

// ---- CAUSAL EVALUATION (every bar incl. realtime) ----
if inHorizon
    float fc = f_forecast(drvMom, drvVola, drvVol, drvRng, hLv)
    liveForecast := fc

    // feature importances (ablation)
    imp0 := f_importance(0, drvMom, drvVola, drvVol, drvRng, fc)
    imp1 := f_importance(1, drvMom, drvVola, drvVol, drvRng, fc)
    imp2 := f_importance(2, drvMom, drvVola, drvVol, drvRng, fc)
    imp3 := f_importance(3, drvMom, drvVola, drvVol, drvRng, fc)
    float impSum = imp0 + imp1 + imp2 + imp3

    // identify the dominant driver
    float impMax = math.max(imp0, math.max(imp1, math.max(imp2, imp3)))
    topDriver := imp0 == impMax ? 0 : imp1 == impMax ? 1 : imp2 == impMax ? 2 : 3

    // align importance with the matching Granger lift for the top driver
    float topLift = topDriver == 0 ? lift0 : topDriver == 1 ? lift1 : topDriver == 2 ? lift2 : lift3
    // importance concentration: how dominant is the top driver (causal clarity)
    float concentration = impSum == 0 ? 0.0 : impMax / impSum
    // causal confidence = blend of Granger lift (predictive precedence) and importance concentration
    liveConf := math.min(1.0, 0.5 * math.min(1.0, topLift / math.max(0.01, grangerGate * 2.0)) + 0.5 * math.min(1.0, (concentration - 0.25) / 0.5))
    liveConf := math.max(0.0, liveConf)

    confEma := na(confEma) ? liveConf : (liveConf * (2.0 / (confSmooth + 1)) + confEma * (1.0 - 2.0 / (confSmooth + 1)))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  CAUSAL SIGNAL + ZONES
// ════════════════════════════════════════════════════════════════════════════════════════════════

float conf = na(confEma) ? 0.0 : confEma
float forecast = na(liveForecast) ? 0.0 : liveForecast
bool causalOk = conf >= confGate
int dir = forecast > 0.05 ? 1 : forecast < -0.05 ? -1 : 0
color dirCol = dir >= 0 ? colLong : colShort

var int lastSig = na
bool sigChanged = na(lastSig) or dir != lastSig
bool fireBase = inHorizon and barstate.isconfirmed and dir != 0 and causalOk
bool fire = oncePerMove ? (fireBase and sigChanged) : fireBase
bool fireLong  = fire and dir == 1
bool fireShort = fire and dir == -1

if inHorizon and barstate.isconfirmed and dir != 0 and causalOk
    lastSig := dir

// --- causal zone: a soft box spawned when confidence first clears the gate on a directional shift ---
f_spawnZone(bool isLong) =>
    float half = atr * (0.8 + conf * 0.8)
    float mid = close
    color zc = isLong ? colLong : colShort
    int tr = int(math.max(72, zoneTransp - conf * 14))
    box bx = box.new(bar_index, mid + half, bar_index + 1, mid - half, xloc = xloc.bar_index,
         border_color = color.new(colZone, 35), border_width = 1, bgcolor = color.new(zc, tr), extend = extend.right)
    CZone z = CZone.new(bx, bar_index, isLong)
    array.push(zones, z)

if fire and (fireLong or fireShort)
    f_spawnZone(fireLong)

// extend + retire zones
if inHorizon and barstate.isconfirmed and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        CZone z = array.get(zones, i)
        if bar_index - z.bornBar > zoneLife
            box.delete(z.bx)
            array.remove(zones, i)
        else
            box.set_right(z.bx, bar_index + 1)

while array.size(zones) > maxZones
    CZone z0 = array.get(zones, 0)
    box.delete(z0.bx)
    array.remove(zones, 0)

// --- simple arrows ---
plotshape(fireLong and glowFx,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 70),  size = size.normal, force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 70), size = size.normal, force_overlay = true)
plotshape(fireLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small, force_overlay = true)
plotshape(fireShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small, force_overlay = true)

// glow accent on high-confidence bars
plot(glowFx and inHorizon and conf > confGate * 1.2 ? close : na, "Causal Glow", color = color.new(dirCol, 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

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

// global helper for proxy/driver rows
f_driverRow(table tbl, int rowY, int d, float imp, float lift, float impSum) =>
    float share = impSum == 0 ? 0.0 : imp / impSum
    bool isTop = d == topDriver
    color rc = isTop ? THEME_GOLD : THEME_TXT
    table.cell(tbl, 0, rowY, f_driverName(d), text_color = isTop ? THEME_GOLD : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 1, rowY, f_bar(share), text_color = rc, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 2, rowY, str.tostring(lift, "#.##"), text_color = lift >= grangerGate ? colLong : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_right)

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    float impSum = imp0 + imp1 + imp2 + imp3
    string state = causalOk ? (dir == 1 ? "CAUSAL LONG" : dir == -1 ? "CAUSAL SHORT" : "CAUSAL") : "AMBIGUOUS"
    color stateCol = causalOk ? (dir >= 0 ? colLong : colShort) : THEME_DIM

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "CAUSAL", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + state, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = stateCol)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Causal Confidence", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_bar(conf), text_color = causalOk ? THEME_ACC : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(math.round(conf * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "True Driver", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, "", text_size = f_panelSize())
    table.cell(panel, 2, 3, f_driverName(topDriver), text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "DRIVERS  (importance · lift)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 4, 2, 4)

    f_driverRow(panel, 5, 0, imp0, lift0, impSum)
    f_driverRow(panel, 6, 1, imp1, lift1, impSum)
    f_driverRow(panel, 7, 2, imp2, lift2, impSum)
    f_driverRow(panel, 8, 3, imp3, lift3, impSum)

    table.cell(panel, 0, 9, "Forecast", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, "", text_size = f_panelSize())
    table.cell(panel, 2, 9, str.tostring(forecast, "+#.##;-#.##") + " ATR", text_color = dir >= 0 ? colLong : colShort, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Granger Lag / Win", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(grangerLag), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, str.tostring(grangerWin) + " bars", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(fireLong,  "Causal ▸ LONG",  "AetherEdge Causal: causally-confirmed bullish signal.")
alertcondition(fireShort, "Causal ▸ SHORT", "AetherEdge Causal: causally-confirmed bearish signal.")
````
