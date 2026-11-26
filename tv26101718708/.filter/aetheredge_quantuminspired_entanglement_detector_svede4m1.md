# AetherEdge - Quantum-Inspired Entanglement Detector

- url: https://www.tradingview.com/script/SVede4m1/
- type: indicator
- pine_id: PUB;ad3b26bd245841f9815eafa66b9c3a03
- version: 1.0

## Description

🖊️ Overview

A detector built on a "quantum entanglement" analogy. In entanglement, the states of several particles are so correlated that measuring one instantly informs the others. This engine transposes that onto markets: it measures the synchrony (entanglement strength) among several market variables — price, volume, and one or two correlated assets / global indices — and watches for decoherence, the moment that synchrony breaks down (a decoupling). A NeuraLib map weighs the pairwise couplings into a single Entanglement score, while a self-learning baseline distinguishes "normal" coupling from genuine breaks. Decoupling events — when the system falls out of its entangled state — are flagged as opportunity (divergence, regime shift). Visualization: a circular radar of Entanglement strength radiating from a center node to each variable, with alerts when synchrony collapses.

🔶 Key Features

Quantum-entanglement analogy — quantifies multi-variable synchrony as "entanglement strength"
Pairwise coupling detection — measures four links: price×volume, price×alt, price×index, alt×index
NeuraLib entanglement map — nonlinearly weights the couplings into a unified Entanglement score
Self-learning baseline — learns the "normal" synchrony level to judge genuine collapses by deviation
Decoherence detection — flags decoupling (opportunity) when entanglement drops sharply below baseline
Coherence/decoherence state — distinguishes synchronized (coherent) from collapsed (decoherent)
Circular entanglement radar — radial spokes from a center node to each coupling (length/color by strength) plus concentric rings
Intelligence panel — entanglement, baseline, decoupling magnitude, and each coupling strength at a glance

🧠 Technical Architecture

The engine pulls in a correlated asset and a global index via request.security and forms the "states" of four variables (price return, volume anomaly, alt return, index return).
As pairwise couplings, it computes the absolute rolling correlation |corr|∈[0,1] over four pairs (PX·VOL, PX·ALT, PX·IDX, ALT·IDX) — the strength of each "entanglement link." When all links are strong, the system is synchronized (high entanglement).
The NeuraLib entanglement map (couplings(4) → hidden(tanh) → entanglement strength(1, squashed to [0,1])) nonlinearly weights the couplings into a unified score. The target is the system-wide mean coupling (a self-supervised synchrony measure), and the network learns a smoothed, weighted estimate generalizing the raw mean.
For decoherence, it measures the drop from entanglement's self-learning baseline (a slow EMA tracking the "normal" level): baseline − current. When this clears the threshold, it flags decoupling. The key is catching deviation from the synchrony the system usually holds — not just low correlation.
The circular radar computes coordinates via math.cos/math.sin, drawing spokes from the center node to each coupling link with length proportional to coupling strength. Spoke color shifts with strength (red = collapse → cyan = sync), and concentric rings (25/50/75/100%) mark the scale.

⚙️ Recommended Settings & Tuning Guide

BTC (main) + ETH + TOTAL (1H–4H): Entanglement Window 40, Coherence 0.65, Decoherence 0.35 — a crypto setup
ETH (main) + BTC + TOTAL (1H–4H): BTC as the alt, the broad crypto market as the index
Stock (main) + peer + SPX/index: for single-stock coupling and decoupling detection
SOL (15m–1H): High volatility favors Entanglement Smoothing 5–6 to smooth, Decoherence Threshold 0.4 to be strict
Entanglement Window: longer is a steadier synchrony estimate; shorter is nimbler — ~40 is practical
Coherence Level: above this is "strong sync" — set to the group's typical correlation
Decoherence Threshold: a drop below baseline beyond this is decoupling; smaller is more sensitive (earlier warning)
Choice of alt/index: pick economically coupled assets/indices for detection accuracy

💡 How to Use in Practice

Reacting to decoupling alerts: a ⚡DECOUPLING marker is the moment usually-synced variables break apart — an opportunity for divergence trades or regime shifts; the broken variable may be "leading"
Reading the circular radar: a long, bright (cyan) spoke = strong coupling (synced); short, red = weak (collapsed). All spokes long = system-wide high entanglement; some short = partial decoupling
Using the coherence state: in COHERENT conditions the market moves as one (risk-on/off) and trends propagate; in DECOHERENT conditions idiosyncratic factors dominate, favoring selection and pair trades
Comparing to baseline: when panel entanglement is far below baseline, that's an abnormal break — judge deviation against the usual synchrony
Which coupling broke: the per-coupling rows (PX·VOL, etc.) identify which pair's sync broke (e.g. a broken PX·IDX means the symbol decoupled from the broad market)
Multi-timeframe usage: read the big-picture coherence state on the higher timeframe (4H), then catch opportunities on decoupling alerts on the lower one (15m–1H)

⚠️ Important Notes

Alt/index must be set: this requires proper correlated-asset/index symbols; unrelated variables break synchrony detection
On the quantum analogy: "entanglement" and "coherence" are metaphors from quantum mechanics, not actual quantum effects; the essence is detecting statistical synchrony among variables
Initial learning period: right after launch the network buffer and baseline are immature; treat entanglement estimates as low-confidence until it learns (several hundred bars)
Decoupling ≠ direction: a break signals an opportunity exists, not a direction (buy/sell); which variable leads needs separate analysis
request.security constraints: alt/index are fetched on the same timeframe; liquidity or timeframe mismatch can make synchrony estimates inaccurate
Adaptive-system nature: historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The entanglement detection, coupling analysis, decoherence judgment, and circular radar are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Synchrony-break detection can produce false positives. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Quantum-Inspired Entanglement Detector
//   AI Drawing Power Series
//
//   A detector built on a "quantum entanglement" analogy. In entanglement, the states of several
//   particles are so strongly correlated that measuring one instantly informs the others. This engine
//   transposes that idea onto markets: it measures the SYNCHRONY (entanglement strength) among several
//   market variables — price, volume, and one or two correlated assets / global indices — and watches
//   for DECOHERENCE, the moment that synchrony breaks down (a decoupling). A NeuraLib map weighs the
//   pairwise couplings into a single Entanglement score, while a self-learning baseline distinguishes
//   "normal" coupling from genuine breaks. Decoupling events — when the system falls out of its
//   entangled state — are flagged as opportunity (divergence, regime shift).
//
//   Visualization: a circular radar of Entanglement strength radiating from a center node out to each
//   variable, with alerts when synchrony collapses. Coherent (entangled) vs. decoherent (decoupled).
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Quantum-Inspired Entanglement Detector", "AE-QE D", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_VARS  = "◆  ENTANGLED VARIABLES"
var string GRP_ENT   = "◆  ENTANGLEMENT ENGINE"
var string GRP_DEC   = "◆  DECOHERENCE DETECTION"
var string GRP_RADAR = "◆  ENTANGLEMENT RADAR"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Entangled Variables —
asset1Sym    = input.symbol("BINANCE:ETHUSDT", "Correlated Asset", group = GRP_VARS, tooltip = "A correlated asset to entangle with the main symbol (e.g. ETH vs BTC).")
indexSym     = input.symbol("CRYPTOCAP:TOTAL", "Global Index", group = GRP_VARS, tooltip = "A broad index representing the systemic state (e.g. total crypto cap, SPX).")
useIndex     = input.bool(true, "Use Global Index", group = GRP_VARS)
entWin       = input.int(40,   "Entanglement Window", minval = 5, maxval = 200, group = GRP_VARS, tooltip = "Rolling window over which pairwise synchrony (correlation) is measured.")

// — Entanglement Engine —
hiddenN      = input.int(6,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_ENT)
learnRate    = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_ENT)
trainSteps   = input.int(3,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_ENT)
bufferCap    = input.int(150,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_ENT)
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_ENT)
seedInp      = input.int(71,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_ENT)

// — Decoherence Detection —
entSmooth    = input.int(4,    "Entanglement Smoothing", minval = 1, maxval = 30, group = GRP_DEC)
decohGate    = input.float(0.35,"Decoherence Threshold", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_DEC, tooltip = "When entanglement drops this far below its baseline, flag a decoupling event.")
cohGate      = input.float(0.65,"Coherence Level", minval = 0.3, maxval = 1.0, step = 0.05, group = GRP_DEC, tooltip = "Entanglement above this is a strongly coherent (synchronized) regime.")

// — Entanglement Radar —
showRadar    = input.bool(true, "Show Entanglement Radar", group = GRP_RADAR)
radarPos     = input.string("Bottom Right", "Radar Anchor", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group = GRP_RADAR)
radarSize    = input.float(2.5, "Radar Size (ATR x)", minval = 0.5, maxval = 10.0, step = 0.5, group = GRP_RADAR, tooltip = "Radius of the radar in ATR multiples (price-axis scaling).")
radarBarsW   = input.int(12,   "Radar Width (bars)", minval = 4, maxval = 50, group = GRP_RADAR, tooltip = "Horizontal span of the radar in bars (time-axis scaling).")

// — Aesthetics —
colCoherent  = input.color(#5ce1ff, "Coherent (entangled)", group = GRP_STYLE, inline = "c1")
colDecoher   = input.color(#ff5d73, "Decoherent (decoupled)", group = GRP_STYLE, inline = "c1")
colNode      = input.color(#f4c25b, "Node", group = GRP_STYLE)
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
//  ENTANGLED VARIABLES  — the system whose synchrony we measure
// ────────────────────────────────────────────────────────────────────────────────────────────────

atr = ta.atr(14)

a1Close  = request.security(asset1Sym, timeframe.period, close)
idxClose = request.security(indexSym, timeframe.period, close)

// per-variable normalized returns (the "states" we test for entanglement)
priceRet = (close - close[1]) / (close[1] == 0 ? 1.0 : close[1])
volSig   = (volume - ta.sma(volume, entWin)) / (ta.stdev(volume, entWin) == 0 ? 1.0 : ta.stdev(volume, entWin))
a1Ret    = (a1Close - a1Close[1]) / (a1Close[1] == 0 ? 1.0 : a1Close[1])
idxRet   = (idxClose - idxClose[1]) / (idxClose[1] == 0 ? 1.0 : idxClose[1])

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  PAIRWISE COUPLINGS  — rolling correlations among the variables (the entanglement "links")
//  Pairs: price–volume, price–asset1, price–index, asset1–index. Each |corr| ∈ [0,1] is a coupling.
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_absCorr(float a, float b) =>
    float c = ta.correlation(a, b, entWin)
    na(c) ? 0.0 : math.abs(c)

coupPV = f_absCorr(priceRet, volSig)        // price ↔ volume
coupPA = f_absCorr(priceRet, a1Ret)         // price ↔ asset1
coupPI = useIndex ? f_absCorr(priceRet, idxRet) : 0.0  // price ↔ index
coupAI = useIndex ? f_absCorr(a1Ret, idxRet) : 0.0     // asset1 ↔ index

var int N_LINK = 4

f_linkName(int i) =>
    i == 0 ? "PX·VOL" : i == 1 ? "PX·ALT" : i == 2 ? "PX·IDX" : "ALT·IDX"

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  NEURALIB ENTANGLEMENT MAP  — couplings → hidden(tanh) → entanglement strength(1, sigmoid-ish)
//  Trained so entanglement tracks the *system-wide* synchrony (mean coupling) but with learned,
//  nonlinear weighting that emphasizes the couplings most informative of joint movement.
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
    W1 := array.new_float(hiddenN * N_LINK, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    W2 := array.new_float(hiddenN, 0.0)
    b2 := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.6)
    f_initRange(W2, seedInp * 40503 + 101, 0.6)
    netInit := true

f_entangle(float c0, float c1, float c2, float c3, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_LINK + 0) * c0
        z += array.get(W1, h * N_LINK + 1) * c1
        z += array.get(W1, h * N_LINK + 2) * c2
        z += array.get(W1, h * N_LINK + 3) * c3
        array.push(hC, f_tanh(z))
    float o = array.get(b2, 0)
    for h = 0 to hiddenN - 1
        o += array.get(W2, h) * array.get(hC, h)
    // squash to [0,1]
    (f_tanh(o) + 1.0) / 2.0

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER + TRAINING
//  Target = system-wide mean coupling (a self-supervised synchrony measure); the net learns a
//  smoothed, weighted entanglement estimate that generalizes the raw mean.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bC0 = array.new_float()
var array<float> bC1 = array.new_float()
var array<float> bC2 = array.new_float()
var array<float> bC3 = array.new_float()
var array<float> bTgt = array.new_float()

f_push(float c0, float c1, float c2, float c3, float tgt) =>
    array.push(bC0, c0)
    array.push(bC1, c1)
    array.push(bC2, c2)
    array.push(bC3, c3)
    array.push(bTgt, tgt)
    if array.size(bTgt) > bufferCap
        array.shift(bC0)
        array.shift(bC1)
        array.shift(bC2)
        array.shift(bC3)
        array.shift(bTgt)

meanCoupling = (coupPV + coupPA + coupPI + coupAI) / (useIndex ? 4.0 : 2.0)

var array<float> hTr = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bTgt) > 0
        float c0 = array.get(bC0, idx)
        float c1 = array.get(bC1, idx)
        float c2 = array.get(bC2, idx)
        float c3 = array.get(bC3, idx)
        float tgt = array.get(bTgt, idx)

        float pred = f_entangle(c0, c1, c2, c3, hTr)
        // derivative through (tanh+1)/2 : d/do = 0.5*(1 - tanh^2) ; pred = (t+1)/2 → tanhVal = 2*pred-1
        float tanhVal = 2.0 * pred - 1.0
        float err = math.max(-3.0, math.min(3.0, pred - tgt)) * 0.5 * (1.0 - tanhVal * tanhVal)

        gH = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            array.set(gH, h, err * array.get(W2, h))
            array.set(W2, h, array.get(W2, h) - learnRate * err * array.get(hTr, h))
        array.set(b2, 0, array.get(b2, 0) - learnRate * err)
        for h = 0 to hiddenN - 1
            float dz = array.get(gH, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_LINK + 0, array.get(W1, h * N_LINK + 0) - learnRate * dz * c0)
            array.set(W1, h * N_LINK + 1, array.get(W1, h * N_LINK + 1) - learnRate * dz * c1)
            array.set(W1, h * N_LINK + 2, array.get(W1, h * N_LINK + 2) - learnRate * dz * c2)
            array.set(W1, h * N_LINK + 3, array.get(W1, h * N_LINK + 3) - learnRate * dz * c3)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pC0 = na
var float pC1 = na
var float pC2 = na
var float pC3 = na

var float liveEnt = na      // entanglement strength [0,1]
var float entEma  = na      // smoothed entanglement
var float entBaseline = na  // self-learning baseline (slow EMA) of entanglement

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pC0)
        f_push(pC0, pC1, pC2, pC3, meanCoupling)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bTgt)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)

    pC0 := coupPV
    pC1 := coupPA
    pC2 := coupPI
    pC3 := coupAI

// ---- ENTANGLEMENT EVALUATION (every bar) ----
if inHorizon
    float ent = f_entangle(coupPV, coupPA, coupPI, coupAI, hLv)
    liveEnt := ent
    entEma := na(entEma) ? ent : (ent * (2.0 / (entSmooth + 1)) + entEma * (1.0 - 2.0 / (entSmooth + 1)))
    // slow baseline (the "normal" entanglement level the system tends to sit at)
    entBaseline := na(entBaseline) ? ent : (ent * 0.02 + entBaseline * 0.98)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  COHERENCE / DECOHERENCE STATE
// ════════════════════════════════════════════════════════════════════════════════════════════════

float ent = na(entEma) ? 0.0 : entEma
float baseline = na(entBaseline) ? 0.0 : entBaseline
float dropFromBase = baseline - ent     // how far below baseline (decoupling magnitude)

bool coherent   = ent >= cohGate
bool decoherent = dropFromBase >= decohGate     // synchrony collapsed relative to its norm

// decoherence event: the moment it transitions into decoupling
bool decohEvent = inHorizon and barstate.isconfirmed and decoherent and not (na(entEma[1]) ? false : (baseline - entEma[1] >= decohGate))
// re-coherence: snapping back into a synchronized state
bool recohEvent = inHorizon and barstate.isconfirmed and coherent and (na(entEma[1]) ? false : entEma[1] < cohGate)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ENTANGLEMENT RADAR  — circular radar radiating from a center node to each variable link
// ════════════════════════════════════════════════════════════════════════════════════════════════

// radar anchor coordinates (price-axis & time-axis), placed near the last bar
f_radarCenterX() =>
    switch radarPos
        "Bottom Right" => last_bar_index + radarBarsW + 4
        "Top Right"    => last_bar_index + radarBarsW + 4
        "Bottom Left"  => last_bar_index - radarBarsW * 3
        "Top Left"     => last_bar_index - radarBarsW * 3
        => last_bar_index + radarBarsW + 4

f_radarCenterY() =>
    switch radarPos
        "Bottom Right" => low - atr * radarSize * 1.2
        "Bottom Left"  => low - atr * radarSize * 1.2
        "Top Right"    => high + atr * radarSize * 1.2
        "Top Left"     => high + atr * radarSize * 1.2
        => low - atr * radarSize * 1.2

var array<line>  radarSpokes = array.new<line>()
var array<label> radarLabels = array.new<label>()
var array<line>  radarRings  = array.new<line>()

// approximate a ring as a polygon of line segments
f_drawRing(float cx, float cy, float rTime, float rPrice, float frac, color col, int trans) =>
    int segs = 16
    float prevX = cx + rTime * frac
    float prevY = cy
    for k = 1 to segs
        float ang = k / segs * 2.0 * 3.14159265
        float px = cx + rTime * frac * math.cos(ang)
        float py = cy + rPrice * frac * math.sin(ang)
        line seg = line.new(int(prevX), prevY, int(px), py, xloc = xloc.bar_index, color = color.new(col, trans), width = 1, force_overlay = true)
        array.push(radarRings, seg)
        prevX := px
        prevY := py

if showRadar and inHorizon and barstate.islast
    // clear previous radar
    if array.size(radarSpokes) > 0
        for i = 0 to array.size(radarSpokes) - 1
            line.delete(array.get(radarSpokes, i))
        array.clear(radarSpokes)
    if array.size(radarLabels) > 0
        for i = 0 to array.size(radarLabels) - 1
            label.delete(array.get(radarLabels, i))
        array.clear(radarLabels)
    if array.size(radarRings) > 0
        for i = 0 to array.size(radarRings) - 1
            line.delete(array.get(radarRings, i))
        array.clear(radarRings)

    float cx = f_radarCenterX()
    float cy = f_radarCenterY()
    float rTime = radarBarsW         // radius along time axis (bars)
    float rPrice = atr * radarSize   // radius along price axis

    // overall radar color reflects coherence state
    color radarCol = coherent ? colCoherent : decoherent ? colDecoher : color.from_gradient(ent, 0.0, 1.0, colDecoher, colCoherent)

    // concentric reference rings (25/50/75/100%)
    f_drawRing(cx, cy, rTime, rPrice, 0.25, THEME_GRID, 55)
    f_drawRing(cx, cy, rTime, rPrice, 0.50, THEME_GRID, 50)
    f_drawRing(cx, cy, rTime, rPrice, 0.75, THEME_GRID, 45)
    f_drawRing(cx, cy, rTime, rPrice, 1.00, radarCol, 30)

    // spokes: one per coupling link, length ∝ coupling strength
    int nLinks = useIndex ? 4 : 2
    for i = 0 to nLinks - 1
        float coup = i == 0 ? coupPV : i == 1 ? coupPA : i == 2 ? coupPI : coupAI
        float ang = i / nLinks * 2.0 * 3.14159265 - 1.5708   // start at top
        float ex = cx + rTime * coup * math.cos(ang)
        float ey = cy + rPrice * coup * math.sin(ang)
        color spokeCol = color.from_gradient(coup, 0.0, 1.0, colDecoher, colCoherent)
        // glow spoke
        if glowFx
            line g = line.new(int(cx), cy, int(ex), ey, xloc = xloc.bar_index, color = color.new(spokeCol, 60), width = 4, force_overlay = true)
            array.push(radarSpokes, g)
        line sp = line.new(int(cx), cy, int(ex), ey, xloc = xloc.bar_index, color = color.new(spokeCol, 0), width = 2, force_overlay = true)
        array.push(radarSpokes, sp)
        // node at the tip
        label tip = label.new(int(ex), ey, f_linkName(i), xloc = xloc.bar_index, style = label.style_label_center, color = color.new(spokeCol, 20), textcolor = #0a0d15, size = size.tiny, force_overlay = true)
        array.push(radarLabels, tip)

    // center node
    label core = label.new(int(cx), cy, "◉", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(colNode, 0), textcolor = #0a0d15, size = size.small, force_overlay = true)
    array.push(radarLabels, core)
    // entanglement readout under the radar
    label rd = label.new(int(cx), cy - rPrice * 1.25, "ENTANGLE " + str.tostring(math.round(ent * 100)) + "%", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(THEME_BG, 10), textcolor = radarCol, size = size.small, force_overlay = true)
    array.push(radarLabels, rd)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  CHART MARKERS  — decoupling alerts on the price
// ════════════════════════════════════════════════════════════════════════════════════════════════

plotshape(decohEvent and glowFx, title = "Decouple Glow", style = shape.diamond, location = location.abovebar, color = color.new(colDecoher, 60), size = size.normal, force_overlay = true)
plotshape(decohEvent, title = "Decoupling", style = shape.diamond, location = location.abovebar, color = color.new(colDecoher, 0), size = size.small, force_overlay = true)
if decohEvent
    label.new(bar_index, high, "⚡ DECOUPLING", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colDecoher, 12), textcolor = #0a0d15, size = size.small, force_overlay = true)

plotshape(recohEvent, title = "Re-Coherence", style = shape.circle, location = location.belowbar, color = color.new(colCoherent, 10), size = size.tiny, force_overlay = true)

// subtle background: decoherence tint
bgcolor(inHorizon and decoherent ? color.new(colDecoher, 92) : na, title = "Decoherence Tint")

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

// global helper for link rows
f_linkRow(table tbl, int rowY, int i, float coup) =>
    color cc = color.from_gradient(coup, 0.0, 1.0, colDecoher, colCoherent)
    table.cell(tbl, 0, rowY, f_linkName(i), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 1, rowY, f_bar(coup), text_color = cc, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(tbl, 2, rowY, str.tostring(coup, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string state = decoherent ? "DECOHERENT" : coherent ? "COHERENT" : "PARTIAL"
    color stateCol = decoherent ? colDecoher : coherent ? colCoherent : THEME_GOLD

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "ENTANGLEMENT", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + state, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = stateCol)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Entanglement", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_bar(ent), text_color = stateCol, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(math.round(ent * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Baseline", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar(baseline), text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(math.round(baseline * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Decoupling Δ", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, "", text_size = f_panelSize())
    table.cell(panel, 2, 4, str.tostring(dropFromBase, "+#.##;-#.##"), text_color = dropFromBase >= decohGate ? colDecoher : THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "COUPLING LINKS", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    f_linkRow(panel, 6, 0, coupPV)
    f_linkRow(panel, 7, 1, coupPA)
    if useIndex
        f_linkRow(panel, 8, 2, coupPI)
        f_linkRow(panel, 9, 3, coupAI)
    else
        table.cell(panel, 0, 8, "PX·IDX", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 1, 8, "—", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 2, 8, "off", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_right)
        table.cell(panel, 0, 9, "ALT·IDX", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 1, 9, "—", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 2, 9, "off", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Window / Buffer", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(entWin), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, str.tostring(array.size(bTgt)) + "/" + str.tostring(bufferCap), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(decohEvent, "Entanglement ▸ DECOUPLING", "AetherEdge Quantum: entanglement collapsed — variables decoupling (opportunity).")
alertcondition(recohEvent, "Entanglement ▸ RE-COHERENCE", "AetherEdge Quantum: system snapped back into a synchronized (coherent) state.")
alertcondition(inHorizon and decoherent and not decoherent[1], "Entanglement ▸ Decoherent Regime", "AetherEdge Quantum: entered a decoherent (decoupled) regime.")
````
