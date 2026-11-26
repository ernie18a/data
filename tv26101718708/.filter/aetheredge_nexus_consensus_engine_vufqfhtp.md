# AetherEdge - NEXUS Consensus Engine

- url: https://www.tradingview.com/script/vUFqFhTp/
- type: indicator
- pine_id: PUB;57ace954ee354e8eb3630d23c898518b
- version: 1.0

## Description

🖊️ Overview

NEXUS is a consensus-driven signal engine in which six independent analytical mechanisms each cast a directional vote, firing BUY/SELL only when sufficient agreement is reached and statistical gates grant approval. Unlike conventional indicators where a single metric can misfire, no mechanism in NEXUS can trigger a signal on its own — a deliberate architecture engineered to structurally suppress false fires. Distribution-free prediction gates and a market-chaos meter continuously screen every vote through one lens: whether the current conditions justify trusting it at all.

🔶 Key Features

Six-mechanism weighted consensus: three directional voters, two statistical screening gates, and a fusion scoring engine
Multi-Scale Decomposition (M1): separates price into fast, mid, and slow frequency bands and measures cross-scale directional alignment
CUSUM Change-Point Detection (M2): a cumulative-sum control chart that captures the ignition of trend reversals with minimal lag
Conformal Prediction Gate (M3): distribution-free, statistically grounded screening that flags moves as in-distribution or anomalous to veto unreliable signals
Permutation-Entropy Meter (M4): Bandt–Pompe predictability measurement that suppresses signals when the market is too chaotic
Adaptive Momentum Core (M5): an RSI-style oscillator with volatility-adaptive overbought/oversold bounds
Optional higher-timeframe confirmation leveraging the v6 dynamic request engine
Cyberpunk visual core: neon glow, circuit traces, glitch HUD, pulsing signal nodes, and four selectable neon palettes
High-visibility markers: glowing labels offset away from price plus vertical neon ignition lines through the firing bar

🧠 Technical Architecture

At the core of NEXUS lies a two-tier separation between directional voting and statistical gating. Three mechanisms cast signed votes (−1 to +1). M1 normalizes the slopes of three exponential filters by ATR, then multiplies cross-band sign agreement by slope magnitude to produce a cross-scale alignment score. M2 standardizes log returns and runs a two-sided CUSUM control chart, detecting a structural break the moment cumulative deviation overcomes slack k and reaches threshold h, then resetting its accumulators to re-arm. M5 pairs RSI-style momentum with adaptive overbought/oversold bounds that expand and contract with realized volatility.
Above these directional votes, two statistical gates act as conviction modulators. M3 conformal prediction accumulates the residuals of a naive one-step forecast within a calibration window, adopts their empirical quantile as a "conformal radius," and dampens conviction whenever the current residual exceeds that radius — a statistically principled anomaly screen. M4 encodes each window of price action into an ordinal pattern (the rank ordering of its values), then computes the Shannon entropy of the pattern histogram normalized by log(d!). When entropy is high — meaning low order and poor predictability — the gate closes and signals are suppressed.
The consensus engine (M6) normalizes the weighted directional votes into a net vote, then modulates it by conformal in-distribution confidence and entropy-based predictability. A final fire demands the simultaneous satisfaction of every condition: the net vote magnitude must exceed the consensus threshold, a minimum number of mechanisms must agree on direction, the entropy gate must be open, the higher timeframe must concur (when enabled), and the cooldown must have elapsed. A signal is born only when multiple independent lines of evidence converge on a single point.

⚙️ Recommended Settings & Tuning Guide

NEXUS is tuned for crypto intraday trading on minute-to-hour timeframes. On liquid instruments like BTC and ETH, the defaults (Consensus Threshold 0.42, Minimum Agreeing Mechanisms 2, Chaos Gate 0.92) are a balanced starting point. On higher-volatility names such as SOL and XRP, lowering the Chaos Gate toward 0.85 narrows signals to more orderly conditions and stabilizes precision.
In strong trending regimes, raise the Consensus Threshold to 0.48–0.52 to capture only high-conviction signals; in ranging markets, where the M5 momentum contribution grows, lowering it toward 0.38 sharpens responsiveness. The M4 Entropy Window defaults to 60, but on very short timeframes a value near 40 balances computational load against responsiveness. If signals are too frequent, raise the Threshold and Cooldown; if too sparse, ease the Threshold and Chaos Gate.

💡 How to Use in Practice

The most reliable signals occur when the HUD shows AGREEMENT at 3/5 or higher with a strongly one-sided NET VOTE bar — multiple mechanisms independently endorsing the same direction. The standalone CUSUM "▴▾" ignition ticks serve as early warnings ahead of full consensus; when other mechanisms begin to follow, it is a cue to prepare. Signals arising while the HUD "chaos idx" is low (orderly) carry the highest confidence, whereas a "SHUT" gate is best respected by standing aside.
For multi-timeframe trading, enabling higher-timeframe confirmation to accept only signals aligned with the dominant trend sharply reduces counter-trend traps. In live use, treat NEXUS signals not as standalone triggers but as confirmation overlaid on volume profile and key support/resistance — prioritizing signals that fire at structural levels. When NEXUS lights up in the same direction as a support/resistance flip, the confluence is powerful.

⚠️ Important Notes

The M3 conformal gate and M4 entropy meter are not fully operational until their calibration and entropy windows have accumulated sufficient data; expect reduced reliability for the first several dozen to a hundred bars near the chart's left edge or on data-sparse instruments. By design, stacking five gates makes signals inherently selective — over-tightening the settings can produce extended silence. Because M4 permutation entropy performs iterative computation each bar, excessively large Entropy Window and Embedding Dimension values may approach the runtime limit. Fires on closed bars do not repaint history, but signal displays update on the in-progress bar.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk; please use this tool with sound risk management and your own independent verification.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Adaptive Systems — NEXUS // Cyberpunk Consensus Signal Engine
//@version=6

indicator("AetherEdge - NEXUS Consensus Engine", "AE-NEXUS", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  NEXUS — A 6-MECHANISM CONSENSUS BUY/SELL ENGINE                           ║
// ║                                                                            ║
// ║  Six independent analytical mechanisms each cast a directional vote.       ║
// ║  A weighted consensus engine fires BUY/SELL only when enough mechanisms    ║
// ║  agree AND statistical/entropy gates permit. No single mechanism can       ║
// ║  trigger a signal alone — this is deliberate, to suppress false fires.     ║
// ║                                                                            ║
// ║  M1  Multi-Scale Decomposition  — trend vs noise across frequency bands    ║
// ║  M2  CUSUM Change-Point Detector — structural break / turn ignition        ║
// ║  M3  Conformal Prediction Gate   — distribution-free anomaly screening     ║
// ║  M4  Permutation-Entropy Meter   — market predictability (order vs chaos)  ║
// ║  M5  Adaptive Momentum Core      — regime-scaled directional momentum      ║
// ║  M6  Consensus Scoring Engine    — weighted vote fusion + gating           ║
// ║                                                                            ║
// ║  AESTHETIC: cyberpunk / dark-hacker — neon glow, circuit traces, glitch    ║
// ║  HUD, pulsing signal nodes, scanline ambiance.                             ║
// ╚══════════════════════════════════════════════════════════════════════════╝


// ============================================================================
//  ░░ INPUT GROUPS ░░
// ============================================================================

// ─── GROUP A — CORE ─────────────────────────────────────────────────────────
gA = "▓ CORE ▓"
srcInput   = input.source(close, "Signal Source", group = gA,
     tooltip = "Primary price series fed into all six mechanisms.")
useHTFInput= input.bool(false, "Higher-Timeframe Confirmation", group = gA,
     tooltip = "Require the higher timeframe trend to agree before a signal fires.")
htfInput   = input.timeframe("60", "Confirmation Timeframe", group = gA)

// ─── GROUP B — M1 MULTI-SCALE DECOMPOSITION ─────────────────────────────────
gB = "▓ M1 · MULTI-SCALE ▓"
ms_fastInput  = input.int(8,  "Fast Band Length",  minval = 2, maxval = 100, group = gB,
     tooltip = "Highest-frequency band. Captures short-term oscillation.")
ms_midInput   = input.int(21, "Mid Band Length",   minval = 3, maxval = 200, group = gB)
ms_slowInput  = input.int(55, "Slow Band Length",  minval = 5, maxval = 400, group = gB,
     tooltip = "Lowest-frequency band. Captures the dominant trend.")
ms_weightInput= input.float(1.0, "M1 Vote Weight", minval = 0.0, maxval = 3.0, step = 0.1, group = gB)

// ─── GROUP C — M2 CUSUM CHANGE-POINT ────────────────────────────────────────
gC = "▓ M2 · CUSUM ▓"
cu_driftInput = input.float(0.5, "Drift Sensitivity (k)", minval = 0.05, maxval = 5.0, step = 0.05, group = gC,
     tooltip = "Slack parameter. LOWER = more sensitive to small shifts (more signals). HIGHER = only large structural breaks register.")
cu_thrInput   = input.float(5.0, "Detection Threshold (h)", minval = 0.5, maxval = 50.0, step = 0.5, group = gC,
     tooltip = "Cumulative sum must exceed this to declare a change-point. HIGHER = fewer, more confident detections.")
cu_winInput   = input.int(50, "CUSUM Baseline Window", minval = 10, maxval = 300, group = gC,
     tooltip = "Window used to estimate the in-control mean/σ that CUSUM monitors deviations from.")
cu_weightInput= input.float(1.2, "M2 Vote Weight", minval = 0.0, maxval = 3.0, step = 0.1, group = gC)

// ─── GROUP D — M3 CONFORMAL PREDICTION GATE ─────────────────────────────────
gD = "▓ M3 · CONFORMAL ▓"
cf_winInput   = input.int(100, "Calibration Window", minval = 20, maxval = 500, group = gD,
     tooltip = "Window of past residuals used to build the nonconformity distribution.")
cf_alphaInput = input.float(0.1, "Miscoverage α", minval = 0.01, maxval = 0.5, step = 0.01, group = gD,
     tooltip = "Target error rate. α=0.1 ⇒ 90% prediction interval. Moves are flagged anomalous if they fall outside this conformal band.")
cf_weightInput= input.float(1.0, "M3 Gate Strength", minval = 0.0, maxval = 3.0, step = 0.1, group = gD,
     tooltip = "How strongly conformal anomaly screening can veto/boost the consensus.")

// ─── GROUP E — M4 PERMUTATION ENTROPY ───────────────────────────────────────
gE = "▓ M4 · ENTROPY ▓"
en_winInput   = input.int(60, "Entropy Window", minval = 20, maxval = 300, group = gE,
     tooltip = "Window over which permutation entropy (predictability) is measured.")
en_dimInput   = input.int(3, "Embedding Dimension", minval = 3, maxval = 5, group = gE,
     tooltip = "Ordinal pattern length. 3 = 6 patterns, 4 = 24 patterns. Higher needs more data.")
en_gateInput  = input.float(0.92, "Chaos Gate", minval = 0.3, maxval = 1.0, step = 0.01, group = gE,
     tooltip = "Normalized entropy above this ⇒ market too chaotic ⇒ signals suppressed. LOWER = stricter (only very orderly markets pass).")
en_weightInput= input.float(0.8, "M4 Gate Strength", minval = 0.0, maxval = 3.0, step = 0.1, group = gE)

// ─── GROUP F — M5 ADAPTIVE MOMENTUM ─────────────────────────────────────────
gF = "▓ M5 · MOMENTUM ▓"
mo_lenInput   = input.int(14, "Momentum Length", minval = 2, maxval = 100, group = gF)
mo_smoothInput= input.int(3, "Momentum Smoothing", minval = 1, maxval = 20, group = gF)
mo_adaptInput = input.bool(true, "Adaptive Thresholds", group = gF,
     tooltip = "Let overbought/oversold bounds breathe with volatility instead of fixed 70/30.")
mo_weightInput= input.float(1.1, "M5 Vote Weight", minval = 0.0, maxval = 3.0, step = 0.1, group = gF)

// ─── GROUP G — M6 CONSENSUS ENGINE ──────────────────────────────────────────
gG = "▓ M6 · CONSENSUS ▓"
co_thrInput   = input.float(0.42, "Consensus Threshold", minval = 0.3, maxval = 0.95, step = 0.01, group = gG,
     tooltip = "Net weighted vote (−1..+1) magnitude required to fire. HIGHER = rarer, higher-conviction signals.")
co_minVotesInp= input.int(2, "Minimum Agreeing Mechanisms", minval = 2, maxval = 5, group = gG,
     tooltip = "At least this many voting mechanisms must point the same way.")
co_coolInput  = input.int(3, "Signal Cooldown (bars)", minval = 0, maxval = 100, group = gG,
     tooltip = "Bars to wait after a signal before another can fire. Prevents clustering.")

// ─── GROUP H — VISUALS / CYBERPUNK ──────────────────────────────────────────
gH = "▓ VISUAL CORE ▓"
vi_themeInput   = input.string("Ice Blue/Orange", "Neon Palette",
     options = ["Neon Cyan/Magenta", "Acid Green/Red", "Synthwave Purple/Pink", "Ice Blue/Orange"], group = gH)
vi_glowInput    = input.bool(true, "Neon Glow (multi-stroke)", group = gH,
     tooltip = "Render lines with layered translucent strokes to simulate emission glow.")
vi_traceInput   = input.bool(true, "Circuit Trace Signal Lines", group = gH)
vi_scanInput    = input.bool(true, "Scanline Ambiance", group = gH,
     tooltip = "Subtle alternating background bands for a CRT/terminal feel.")
vi_pulseInput   = input.bool(true, "Pulsing Signal Nodes", group = gH)
vi_gridInput    = input.bool(true, "Holographic Conviction Grid", group = gH)

// ─── GROUP I — HUD ──────────────────────────────────────────────────────────
gI = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gI)
hud_posInput  = input.string("Top Right", "HUD Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gI)
hud_sizeInput = input.string("Normal", "HUD Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gI)
hud_glitchInput= input.bool(true, "Glitch Header Animation", group = gI)


// ============================================================================
//  ░░ CYBERPUNK PALETTE ░░
//  Each palette = [bullNeon, bearNeon, accent, dim, gridGlow]
// ============================================================================
var color cBull = na
var color cBear = na
var color cAccent = na
var color cDim  = na
var color cGrid = na
var color cPanel= #07090f
var color cPanelHd = #0d1320
var color cTxt  = #c8f4ff
var color cTxtDim = #4a6273

setPalette() =>
    [b, s, a, d, g] = switch vi_themeInput
        "Neon Cyan/Magenta"     => [#00f0ff, #ff2d78, #b14dff, #1a2730, #00f0ff]
        "Acid Green/Red"        => [#39ff14, #ff1744, #f5ff00, #14241a, #39ff14]
        "Synthwave Purple/Pink" => [#b14dff, #ff3caa, #00e5ff, #1e1730, #ff3caa]
        => [#5bc8ff, #ff8c42, #00ffd0, #16222e, #5bc8ff]   // Ice Blue/Orange
    [b, s, a, d, g]
[pB, pS, pA, pD, pG] = setPalette()
cBull   := pB
cBear   := pS
cAccent := pA
cDim    := pD
cGrid   := pG


// ============================================================================
//  ░░ SHARED MATH HELPERS ░░
// ============================================================================

// Safe division.
sdiv(a, b) =>
    b != 0 ? a / b : 0.0

// Clamp to [lo, hi].
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Map x in [a,b] to [0,1].
norm01(x, a, b) =>
    b != a ? clamp((x - a) / (b - a), 0.0, 1.0) : 0.5

// Sign as -1/0/+1.
sgn(x) =>
    x > 0 ? 1 : x < 0 ? -1 : 0


// ============================================================================
//  ░░ M1 — MULTI-SCALE DECOMPOSITION ░░
//  Decompose price into fast/mid/slow bands (a cascaded EMA filter bank, the
//  Pine-feasible cousin of a wavelet decomposition). The band SLOPES indicate
//  directional agreement across timescales; alignment = strong trend vote.
// ============================================================================
ms_decompose(src, lf, lm, ls) =>
    bandFast = ta.ema(src, lf)
    bandMid  = ta.ema(src, lm)
    bandSlow = ta.ema(src, ls)
    // Detail coefficients (band differences) — the "wavelet detail" analogues.
    detailHi = bandFast - bandMid       // high-frequency detail
    detailLo = bandMid  - bandSlow      // low-frequency detail
    // Slopes normalized by ATR to be scale-free.
    atr = ta.atr(14)
    slopeFast = sdiv(ta.change(bandFast), atr)
    slopeMid  = sdiv(ta.change(bandMid),  atr)
    slopeSlow = sdiv(ta.change(bandSlow), atr)
    // Cross-scale alignment score in [-1, +1]: how unanimously bands point same way.
    align = (sgn(slopeFast) + sgn(slopeMid) + sgn(slopeSlow)) / 3.0
    // Magnitude weighting: stronger slopes => more conviction.
    mag = clamp((math.abs(slopeFast) + math.abs(slopeMid) + math.abs(slopeSlow)) / 3.0, 0.0, 1.0)
    vote = align * mag
    [vote, bandFast, bandMid, bandSlow, detailHi, detailLo, align]

[m1_vote, m1_fast, m1_mid, m1_slow, m1_dHi, m1_dLo, m1_align] = ms_decompose(srcInput, ms_fastInput, ms_midInput, ms_slowInput)


// ============================================================================
//  ░░ M2 — CUSUM CHANGE-POINT DETECTION ░░
//  Two-sided cumulative sum control chart on standardized returns. Detects
//  the IGNITION of a directional shift earlier than smoothed indicators.
//  S⁺ accumulates upward drift, S⁻ downward; crossing h ⇒ change-point.
// ============================================================================
var float cusumPos = 0.0
var float cusumNeg = 0.0

// Helper computes the standardized return deviation (pure, no state mutation).
cusum_zscore(src, win) =>
    ret = ta.change(math.log(src))
    mu  = ta.sma(ret, win)
    sd  = ta.stdev(ret, win)
    sdiv(ret - mu, sd)

// CUSUM recursion runs at GLOBAL scope — Pine forbids mutating global `var`
// variables from inside a function, so the control-chart state lives here.
zc = cusum_zscore(srcInput, cu_winInput)
cusumPos := math.max(0.0, nz(cusumPos) + zc - cu_driftInput)
cusumNeg := math.min(0.0, nz(cusumNeg) + zc + cu_driftInput)

m2_fireUp = cusumPos > cu_thrInput
m2_fireDn = cusumNeg < -cu_thrInput

// Vote scaled by how far past threshold (saturating), computed BEFORE reset.
m2_rawVote = m2_fireUp ? clamp(cusumPos / (cu_thrInput * 2.0), 0.0, 1.0) : m2_fireDn ? -clamp(-cusumNeg / (cu_thrInput * 2.0), 0.0, 1.0) : 0.0

// Reset the accumulators after a detection so the chart re-arms.
if m2_fireUp
    cusumPos := 0.0
if m2_fireDn
    cusumNeg := 0.0

m2_sPos = cusumPos
m2_sNeg = cusumNeg

// Decaying memory of the latest change-point vote (so M2 contributes for a few bars).
var float m2_vote = 0.0
m2_vote := m2_fireUp ? 1.0 : m2_fireDn ? -1.0 : nz(m2_vote) * 0.80
m2_vote := clamp(m2_vote, -1.0, 1.0)


// ============================================================================
//  ░░ M3 — CONFORMAL PREDICTION GATE ░░
//  Distribution-free screening. Build a naive 1-step forecast (random-walk +
//  drift), collect absolute residuals over a calibration window, take the
//  (1-α) empirical quantile as the conformal radius. If the latest move's
//  nonconformity exceeds the radius, it is statistically anomalous.
//  Output: (a) a gate in [0,1] = how "in-distribution" current action is,
//          (b) a directional hint from the signed residual.
// ============================================================================
// Maintain a rolling buffer of absolute residuals.
var float[] cf_resid = array.new<float>(0)

conformal_step(src, win, alpha) =>
    // Naive predictor: yesterday's value + recent drift.
    drift = ta.sma(ta.change(src), 10)
    pred  = nz(src[1]) + nz(drift)
    resid = src - pred
    absR  = math.abs(resid)
    // Push current absolute residual; cap buffer to window.
    array.push(cf_resid, absR)
    if array.size(cf_resid) > win
        array.shift(cf_resid)
    // Empirical (1-α) quantile = conformal radius.
    float radius = na
    if array.size(cf_resid) >= 20
        sorted = array.copy(cf_resid)
        array.sort(sorted, order.ascending)
        idx = math.floor((1.0 - alpha) * (array.size(sorted) - 1))
        radius := array.get(sorted, idx)
    // Nonconformity ratio: |resid| / radius. >1 ⇒ outside conformal band.
    ratio = na(radius) or radius == 0 ? 0.0 : absR / radius
    inDist = clamp(1.0 - (ratio - 1.0), 0.0, 1.0)   // 1 when well inside, →0 when anomalous
    // Anomalous moves carry directional information (breakout direction).
    anomDir = ratio > 1.0 ? sgn(resid) : 0
    [inDist, ratio, anomDir, radius]

[m3_inDist, m3_ratio, m3_anomDir, m3_radius] = conformal_step(srcInput, cf_winInput, cf_alphaInput)


// ============================================================================
//  ░░ M4 — PERMUTATION ENTROPY METER ░░
//  Bandt–Pompe permutation entropy: encode each length-d window of the series
//  by the ordinal rank pattern of its values, build the pattern histogram over
//  the entropy window, compute Shannon entropy, normalize by log(d!).
//  Low entropy ⇒ ordered/predictable ⇒ trust signals. High ⇒ chaos ⇒ suppress.
// ============================================================================
// Factorial for small d.
fact(n) =>
    r = 1
    for i = 2 to n
        r *= i
    r

// Encode the ordinal pattern of d consecutive values into an integer code via
// Lehmer-like ranking. Returns a code in [0, d!-1].
ordinal_code(src, d, offset) =>
    // Gather d values.
    vals = array.new<float>(d, 0.0)
    for i = 0 to d - 1
        array.set(vals, i, nz(src[offset + (d - 1 - i)]))
    // Compute permutation rank by counting inversions (stable for small d).
    // NOTE: Pine's `for a to b` executes once even when a > b, so we must
    // explicitly guard the inner loop to avoid reading vals[d] (out of bounds).
    code = 0
    mult = 1
    for i = 0 to d - 1
        // Count how many later elements are smaller (rank position).
        cnt = 0
        if i + 1 <= d - 1
            for j = i + 1 to d - 1
                if array.get(vals, j) < array.get(vals, i)
                    cnt += 1
        code += cnt * mult
        mult *= (d - i)
    code

permutation_entropy(src, win, d) =>
    nPat = fact(d)
    hist = array.new<float>(nPat, 0.0)
    total = 0.0
    // Slide over the entropy window, tallying ordinal patterns.
    for off = 0 to win - 1
        c = ordinal_code(src, d, off)
        if c >= 0 and c < nPat
            array.set(hist, c, array.get(hist, c) + 1.0)
            total += 1.0
    // Shannon entropy of the pattern distribution.
    H = 0.0
    if total > 0
        for p = 0 to nPat - 1
            prob = array.get(hist, p) / total
            if prob > 0
                H -= prob * math.log(prob)
    // Normalize by maximum possible entropy log(d!).
    Hmax = math.log(nPat)
    normH = Hmax > 0 ? H / Hmax : 1.0
    normH

m4_entropy = permutation_entropy(srcInput, en_winInput, en_dimInput)
// Predictability = 1 - normalized entropy. Gate passes when entropy below chaos gate.
m4_predict = clamp(1.0 - m4_entropy, 0.0, 1.0)
m4_gateOpen = m4_entropy <= en_gateInput


// ============================================================================
//  ░░ M5 — ADAPTIVE MOMENTUM CORE ░░
//  RSI-style momentum with volatility-adaptive overbought/oversold bounds.
//  In calm markets the bounds tighten; in volatile markets they widen, so the
//  same indicator stays meaningful across regimes.
// ============================================================================
mom_core(src, len, smooth, adapt) =>
    rsi = ta.rsi(src, len)
    rsiS = ta.ema(rsi, smooth)
    // Adaptive bounds: widen with normalized volatility.
    vol = ta.stdev(ta.change(src), len) 
    volRef = ta.sma(vol, len * 4)
    spread = adapt ? clamp(sdiv(vol, volRef), 0.5, 2.0) : 1.0
    ob = 50.0 + 20.0 * spread
    os = 50.0 - 20.0 * spread
    ob := clamp(ob, 55.0, 90.0)
    os := clamp(os, 10.0, 45.0)
    // Vote: continuous, centered at 50, signed toward extremes.
    centered = (rsiS - 50.0) / 50.0     // -1..+1
    // Cross signals add ignition.
    crossUp = ta.crossover(rsiS, os)
    crossDn = ta.crossunder(rsiS, ob)
    vote = clamp(centered * 1.5, -1.0, 1.0)
    [vote, rsiS, ob, os, crossUp, crossDn]

[m5_vote, m5_rsi, m5_ob, m5_os, m5_crossUp, m5_crossDn] = mom_core(srcInput, mo_lenInput, mo_smoothInput, mo_adaptInput)


// ============================================================================
//  ░░ HIGHER-TIMEFRAME CONFIRMATION (optional) ░░
//  Uses v6 dynamic request capability to pull HTF trend direction.
// ============================================================================
htfTrendDir() =>
    e1 = ta.ema(close, 20)
    e2 = ta.ema(close, 50)
    sgn(e1 - e2)
htfDir = useHTFInput ? request.security(syminfo.tickerid, htfInput, htfTrendDir(), lookahead = barmerge.lookahead_off) : 0


// ============================================================================
//  ░░ M6 — CONSENSUS SCORING ENGINE ░░
//  Fuse the directional votes (M1, M2, M5) under the screening gates
//  (M3 conformal in-distribution, M4 entropy predictability). The gates do
//  not vote on direction; they MODULATE conviction. M3 anomaly direction can
//  add a breakout tilt. Final fire requires:
//    • |net weighted vote| ≥ consensus threshold
//    • ≥ minimum number of directional mechanisms agreeing
//    • entropy gate open (market not too chaotic)
//    • optional HTF agreement
//    • cooldown elapsed
// ============================================================================

// Collect directional votes with their weights.
voteM1 = m1_vote * ms_weightInput
voteM2 = m2_vote * cu_weightInput
voteM5 = m5_vote * mo_weightInput
// M3 anomaly direction acts as a conditional extra voter (breakout confirmation).
voteM3 = m3_anomDir * cf_weightInput * 0.5

// Sum of absolute weights present (for normalization).
wSum = ms_weightInput + cu_weightInput + mo_weightInput + (cf_weightInput * 0.5)
rawNet = sdiv(voteM1 + voteM2 + voteM5 + voteM3, wSum)   // -1..+1

// Gate modulation: scale conviction by conformal in-distribution and entropy predictability.
// Floors raised so the gates dampen conviction without fully crushing it.
gateMod = clamp(m3_inDist, 0.35, 1.0) * clamp(0.6 + 0.4 * m4_predict, 0.5, 1.0)
// If entropy gate is closed (too chaotic), damp (but not to near-zero).
gateMod := m4_gateOpen ? gateMod : gateMod * 0.5

netVote = clamp(rawNet * (0.85 + 0.3 * en_weightInput) * gateMod, -1.0, 1.0)

// Count agreeing directional mechanisms (sign agreement with netVote).
dirSign = sgn(netVote)
agree = 0
agree += sgn(voteM1) == dirSign and dirSign != 0 ? 1 : 0
agree += sgn(voteM2) == dirSign and dirSign != 0 ? 1 : 0
agree += sgn(voteM5) == dirSign and dirSign != 0 ? 1 : 0
agree += sgn(voteM3) == dirSign and dirSign != 0 ? 1 : 0
agree += m1_align != 0 and sgn(m1_align) == dirSign ? 1 : 0   // alignment counts as corroboration

// HTF agreement check.
htfOk = not useHTFInput or htfDir == 0 or sgn(htfDir) == dirSign

// Cooldown bookkeeping.
var int lastSignalBar = -100000
cooldownOk = (bar_index - lastSignalBar) >= co_coolInput

// Final fire conditions.
convictionOk = math.abs(netVote) >= co_thrInput
votesOk = agree >= co_minVotesInp

buySignal  = convictionOk and votesOk and dirSign > 0 and m4_gateOpen and htfOk and cooldownOk
sellSignal = convictionOk and votesOk and dirSign < 0 and m4_gateOpen and htfOk and cooldownOk

if buySignal or sellSignal
    lastSignalBar := bar_index

// Conviction percentage for display.
convPct = math.round(math.abs(netVote) * 100)


// ============================================================================
//  ░░ VISUALS — CYBERPUNK RENDERING ░░
// ============================================================================

// ─── Scanline ambiance: alternating faint background bands (CRT feel) ───
scanOn = vi_scanInput and bar_index % 2 == 0
bgcolor(scanOn ? color.new(cDim, 92) : na, title = "Scanline")

// ─── Conviction-tinted background: subtle wash in signal direction ───
convBg = math.abs(netVote) > 0.2 ? (dirSign > 0 ? cBull : cBear) : na
bgcolor(vi_gridInput and not na(convBg) ? color.new(convBg, 96 - math.round(math.abs(netVote) * 6)) : na, title = "Conviction Wash")

// ─── Multi-scale bands with neon glow (layered translucent strokes) ───
// Glow is simulated by plotting the same line multiple times at increasing
// width and transparency — the Pine analogue of a CSS box-shadow bloom.
// NOTE: plot() cannot live inside a function in Pine, so glow layers are
// expanded directly at global scope here.
slowCol = m1_slow > m1_slow[1] ? cBull : cBear
slowGlowCol = color.new(slowCol, 20)
// Outer glow layers (only when glow enabled).
plot(vi_glowInput ? m1_slow : na, "M1 Slow glow2", color = color.new(slowGlowCol, 90), linewidth = 6, editable = false)
plot(vi_glowInput ? m1_slow : na, "M1 Slow glow1", color = color.new(slowGlowCol, 78), linewidth = 4, editable = false)
// Core slow band line.
plot(m1_slow, "M1 Slow Band", color = slowGlowCol, linewidth = 2, editable = false)

midCol = m1_mid > m1_mid[1] ? color.new(cBull, 35) : color.new(cBear, 35)
plot(m1_mid, "M1 Mid Band", color = midCol, linewidth = 1, editable = false)

// ─── Circuit-trace signal line: the consensus net vote mapped near price ───
// Drawn as a thin accented line riding just under price, like a data bus.
atrLocal = ta.atr(14)
traceLevel = ta.ema(srcInput, 3) - atrLocal * (1.5 - netVote)   // shifts with conviction
traceCol = dirSign > 0 ? cBull : dirSign < 0 ? cBear : cAccent
plot(vi_traceInput ? traceLevel : na, "Circuit Trace", color = color.new(traceCol, 30), linewidth = 1, style = plot.style_stepline, editable = false)


// ─── HIGH-VISIBILITY SIGNAL MARKERS ───
// Markers are drawn with label.new + line.new instead of plotshape, so they
// can be offset clearly away from price (never overlapping candles), rendered
// large and legible, and accompanied by a vertical neon "ignition" line that
// makes the firing bar unmistakable at a glance.
atrMark = ta.atr(14)

// Pulse only near the most recent bars so confirmed historical signals stay
// solid and readable (the old per-bar parity flicker made old markers faint).
isRecent = (bar_index > last_bar_index - 3)
pulseNow = vi_pulseInput and isRecent and (bar_index % 2 == 0)

// --- BUY marker ---
if buySignal
    yOff = low - atrMark * 1.2
    // Vertical neon ignition line through the firing bar.
    if vi_traceInput
        line.new(bar_index, yOff, bar_index, low - atrMark * 0.2,
             color = color.new(cBull, 35), width = 2, style = line.style_solid)
    // Outer glow halo (large, faint) — layered for emission feel.
    if vi_glowInput
        label.new(bar_index, yOff, "▲", yloc = yloc.price, color = color.new(cBull, 80),
             textcolor = color.new(cBull, 30), style = label.style_label_up, size = size.huge)
    // Core BUY bubble — bold, dark text on neon fill, high contrast.
    label.new(bar_index, yOff, "BUY", yloc = yloc.price,
         color = color.new(cBull, pulseNow ? 15 : 0),
         textcolor = #00121a, style = label.style_label_up, size = size.normal,
         tooltip = "Consensus BUY · conviction " + str.tostring(convPct) + "%")

// --- SELL marker ---
if sellSignal
    yOff = high + atrMark * 1.2
    if vi_traceInput
        line.new(bar_index, high + atrMark * 0.2, bar_index, yOff,
             color = color.new(cBear, 35), width = 2, style = line.style_solid)
    if vi_glowInput
        label.new(bar_index, yOff, "▼", yloc = yloc.price, color = color.new(cBear, 80),
             textcolor = color.new(cBear, 30), style = label.style_label_down, size = size.huge)
    label.new(bar_index, yOff, "SELL", yloc = yloc.price,
         color = color.new(cBear, pulseNow ? 15 : 0),
         textcolor = #1a0008, style = label.style_label_down, size = size.normal,
         tooltip = "Consensus SELL · conviction " + str.tostring(convPct) + "%")

// CUSUM ignition ticks (small markers where change-points fire, even pre-consensus).
plotchar(m2_fireUp and not buySignal,  "CUSUM↑", "▴", location.belowbar, color.new(cBull, 55), size = size.tiny, editable = false)
plotchar(m2_fireDn and not sellSignal, "CUSUM↓", "▾", location.abovebar, color.new(cBear, 55), size = size.tiny, editable = false)

// Bar coloring by net conviction direction (subtle).
barcolor(math.abs(netVote) > co_thrInput * 0.6 ? (dirSign > 0 ? color.new(cBull, 40) : color.new(cBear, 40)) : na, editable = false)


// ============================================================================
//  ░░ HUD — GLITCH TERMINAL DASHBOARD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right
hudSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

// Mechanism status bar (8 cells) from a signed vote in [-1,1].
voteBar(v) =>
    int n = 8
    int mid = 4
    int filled = math.round(math.abs(clamp(v, -1.0, 1.0)) * mid)
    string s = ""
    if v >= 0
        // Right-fill from center.
        for i = 0 to n - 1
            s += (i >= mid and i < mid + filled) ? "█" : (i == mid - 1 ? "┃" : "░")
    else
        for i = 0 to n - 1
            s += (i < mid and i >= mid - filled) ? "█" : (i == mid ? "┃" : "░")
    s

// Gate indicator glyph.
gateGlyph(open) =>
    open ? "◉ OPEN" : "○ SHUT"

// Glitch header: swap glyphs by bar parity for a flicker effect.
glitchTitle() =>
    base = "N E X U S ⟐ CONSENSUS"
    alt  = "N3XU5 ⟐ C0NS3NSUS"
    hud_glitchInput and (bar_index % 3 == 0) ? alt : base

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 3, 14,
         bgcolor = cPanel, border_color = color.new(cAccent, 70), border_width = 1,
         frame_color = color.new(cAccent, 40), frame_width = 2)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    sigState = buySignal ? "▲ BUY FIRED" : sellSignal ? "▼ SELL FIRED" : math.abs(netVote) >= co_thrInput * 0.7 ? "◆ ARMING" : "· STANDBY"
    sigCol = buySignal ? cBull : sellSignal ? cBear : dirSign > 0 ? color.new(cBull, 30) : dirSign < 0 ? color.new(cBear, 30) : cTxtDim

    // ── Title row (glitch) ──
    table.cell(hud, 0, 0, glitchTitle(), text_color = cAccent, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "", bgcolor = cPanelHd)
    table.cell(hud, 2, 0, "v6", text_color = cTxtDim, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    // ── Signal state ──
    table.cell(hud, 0, 1, "STATE", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, sigState, text_color = sigCol, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 1, str.tostring(convPct) + "%", text_color = sigCol, text_size = sz, text_halign = text.align_right)

    // ── Net vote bar ──
    table.cell(hud, 0, 2, "NET VOTE", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, voteBar(netVote), text_color = dirSign > 0 ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 2, str.tostring(netVote, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── Agreement count ──
    table.cell(hud, 0, 3, "AGREEMENT", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, str.tostring(agree) + " / 5", text_color = agree >= co_minVotesInp ? cBull : cTxtDim, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 3, votesOk ? "PASS" : "WAIT", text_color = votesOk ? cBull : cTxtDim, text_size = sz, text_halign = text.align_right)

    // ── Divider ──
    table.cell(hud, 0, 4, "▔▔▔ MECHANISMS ▔▔▔", text_color = cAccent, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 4, "", bgcolor = cPanelHd)
    table.cell(hud, 2, 4, "", bgcolor = cPanelHd)

    // ── M1 ──
    table.cell(hud, 0, 5, "M1 SCALE", text_color = cTxt, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, voteBar(m1_vote), text_color = m1_vote > 0 ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 5, str.tostring(m1_vote, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── M2 ──
    table.cell(hud, 0, 6, "M2 CUSUM", text_color = cTxt, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, voteBar(m2_vote), text_color = m2_vote > 0 ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 6, (m2_fireUp ? "▲FIRE" : m2_fireDn ? "▼FIRE" : str.tostring(m2_vote, "#.00")), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── M3 conformal gate ──
    table.cell(hud, 0, 7, "M3 CONFORM", text_color = cTxt, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, voteBar(m3_inDist * 2.0 - 1.0), text_color = m3_inDist > 0.5 ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 7, m3_ratio > 1.0 ? "ANOM" : "OK", text_color = m3_ratio > 1.0 ? cBear : cBull, text_size = sz, text_halign = text.align_right)

    // ── M4 entropy gate ──
    table.cell(hud, 0, 8, "M4 ENTROPY", text_color = cTxt, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, voteBar(m4_predict * 2.0 - 1.0), text_color = m4_gateOpen ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 8, gateGlyph(m4_gateOpen), text_color = m4_gateOpen ? cBull : cBear, text_size = sz, text_halign = text.align_right)

    // ── M5 momentum ──
    table.cell(hud, 0, 9, "M5 MOMENTUM", text_color = cTxt, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, voteBar(m5_vote), text_color = m5_vote > 0 ? cBull : cBear, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 9, str.tostring(m5_rsi, "#"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── Divider ──
    table.cell(hud, 0, 10, "▔▔▔ TELEMETRY ▔▔▔", text_color = cAccent, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 10, "", bgcolor = cPanelHd)
    table.cell(hud, 2, 10, "", bgcolor = cPanelHd)

    // ── Entropy value ──
    table.cell(hud, 0, 11, "chaos idx", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 11, voteBar(1.0 - m4_entropy * 2.0), text_color = cAccent, text_size = sz, text_halign = text.align_center)
    table.cell(hud, 2, 11, str.tostring(m4_entropy, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── Conformal radius ──
    table.cell(hud, 0, 12, "conf radius", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 12, "", text_size = sz)
    table.cell(hud, 2, 12, na(m3_radius) ? "—" : str.tostring(m3_radius, format.mintick), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    // ── HTF ──
    table.cell(hud, 0, 13, "HTF trend", text_color = cTxtDim, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 13, "", text_size = sz)
    table.cell(hud, 2, 13, not useHTFInput ? "off" : htfDir > 0 ? "▲ up" : htfDir < 0 ? "▼ dn" : "flat", text_color = htfDir > 0 ? cBull : htfDir < 0 ? cBear : cTxtDim, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(buySignal,  "NEXUS BUY",  "NEXUS consensus BUY fired")
alertcondition(sellSignal, "NEXUS SELL", "NEXUS consensus SELL fired")
alertcondition(m2_fireUp,  "CUSUM Up Break",   "M2 change-point: upward structural shift")
alertcondition(m2_fireDn,  "CUSUM Down Break", "M2 change-point: downward structural shift")
alertcondition(not m4_gateOpen, "Chaos Gate Closed", "M4 entropy: market too chaotic, signals suppressed")
````
