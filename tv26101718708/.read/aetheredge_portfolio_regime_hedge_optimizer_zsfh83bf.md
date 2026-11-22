# AetherEdge - Portfolio Regime Hedge Optimizer

- url: https://www.tradingview.com/script/zsfH83bf/
- type: indicator
- pine_id: PUB;acfaa5da88764fa2a0934b965a6ef8d6
- version: 1.0

## Description

🖊️ Overview

A multi-asset engine for the portfolio era. Rather than reading one symbol in isolation, it pulls in up to two correlated assets (e.g. ETH and DXY alongside BTC, or a stock and an FX pair) and learns their relative regime with a NeuraLib network — relative strength, rolling correlation, and the correlation regime itself (risk-on coupling vs. decoupling). From that, the agent issues hedge signals — when the main asset's downside is best offset by a correlated instrument — and diversification guidance when correlations decouple. A reward based on whether a hedge call actually reduced realized drawdown lets the regime model self-evolve. Visualization: "Hedge Alert" arrows on the main asset plus up to two relative-strength comparison lines.

🔶 Key Features

Multi-asset relative-regime learning — AI learns the main + two correlated assets' relationship (beyond single-symbol analysis)
Correlation-regime classification — labels coupling (COUPLED) / decoupling (DECOUPLED) / inverse (INVERSE) from rolling correlation
Hedge signals — recommends hedging with a correlated asset when correlation rises amid downside pressure
Diversification guidance — flags when low correlation makes spreading exposure favorable
Self-evolving reward — learns from post-hedge drawdown reduction (accounting for hedging cost)
Hedge Alert arrows — warning arrows and labels on the main asset chart
Relative-strength lines — each correlated asset's main-relative performance, rebased onto price, up to two lines
Intelligence panel — hedge conviction, hedge/diversify/hold regime values, each correlation, relative strength, and main drawdown at a glance

🧠 Technical Architecture

The engine pulls in two correlated assets via request.security on the same timeframe as the main chart. The state vector comprises six relative-regime features: (1)(2) main-vs-each-asset rolling correlation, (3)(4) main-vs-each relative strength (relative performance gap), (5) the main asset's drawdown pressure from its recent high, and (6) the main asset's volatility regime — all clamp-normalized.
This feeds a NeuraLib regime network (state(6) → hidden(tanh) → Q[3]) estimating the value of three actions — HEDGE / DIVERSIFY / HOLD. The reward design is the core: HEDGE is rewarded when the main subsequently fell (protection was valuable) and lightly penalized (cost) when it rose; DIVERSIFY is rewarded when correlation is low and the alt outperformed; HOLD is rewarded when the main held up (avoiding needless hedge cost). The model thus learns when to hedge from a drawdown-reduction standpoint. Training is DQN-style (target = r + γ·max Q(s′)) from uniform replay.
Hedge conviction is the normalized dominance of the HEDGE value over the others; after smoothing, when it clears the gate amid main downside pressure, a "Hedge Alert" fires. The relative-strength lines rebase each correlated asset's main-relative performance onto the main close, overlaying them on the price chart for a visual strength comparison.

⚙️ Recommended Settings & Tuning Guide

BTC (main) + ETH + DXY (1H–4H): Correlation 40, Relative 30, High-Corr 0.6, Decoupling 0.2, Hedge Gate 0.45 — a crypto + risk-off-proxy setup
ETH (main) + BTC + Total (1H–4H): BTC as asset 1, the broad crypto market as asset 2
Stock (main) + Index + VIX/DXY: index and a volatility proxy as correlated assets for single-stock hedging
FX (main) + DXY + related pair: for currency relative-regime and hedging
Correlation Window: longer is a steadier correlation regime; shorter is nimbler — ~40 is practical
High-Correlation / Decoupling Level: the coupling/decoupling thresholds — set to the pair's typical correlation
Hedge Gate: higher makes hedge alerts rare and high-confidence; lower more frequent — tune to risk tolerance
Choice of correlated assets: pick economically meaningful pairs (same sector, risk-on/off relationship)

💡 How to Use in Practice

Reacting to Hedge Alert arrows: an arrow marks where the model judges the main's downside can be offset by a correlated asset — a basis to consider hedging (shorting the correlate, options, trimming size)
Reading relative-strength lines: versus the main close (anchor), a correlate line above = that asset outperforms the main (main weaker); below = main leads — useful for rotation calls
Using the correlation regime: COUPLED = risk resonates and hedging is effective; DECOUPLED = diversification works; INVERSE = a natural hedge exists
Using diversification flags: DIVERSIFY markers mark decoupled conditions where spreading risk across the assets may lower portfolio volatility
Pairing with drawdown pressure: deep main drawdown plus high hedge conviction is the most caution-worthy risk-off setup
Multi-timeframe usage: read the big-picture correlation regime on the higher timeframe (4H), then time on Hedge Alerts on the lower one (1H)

⚠️ Important Notes

Correlated assets must be set: this requires proper correlated-asset symbols; unrelated assets break correlation learning — choose economically related ones
request.security constraints: correlated data is fetched on the same timeframe; illiquid symbols or timeframe mismatches can make correlation inaccurate
Initial learning period: right after launch the buffer is nearly empty and the regime model is immature; treat hedge conviction as low-confidence until it learns (several hundred bars)
Learning resets: changing parameters, symbol/timeframe, correlated assets, or recompiling reinitializes the network weights and buffer
Hedging isn't infallible: correlations shift over time, and in crises normally-uncorrelated assets can move together (correlation convergence) — hedge recommendations do not guarantee protection
On forward-looking reward: rewards use closed-bar forward returns (a standard RL training construct); as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The relative-regime learning, correlation analysis, hedge signals, diversification guidance, and relative-strength lines are quantitative heuristics computed on-chart from price data — they are not financial advice, trade/hedge signals, or any guarantee of future performance. Make portfolio hedging and diversification decisions on your own responsibility, including consulting a professional. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Portfolio Regime Hedge Optimizer
//   AI Drawing Power Series
//
//   A multi-asset engine for the portfolio era. Rather than reading one symbol in isolation, it pulls
//   in up to two correlated assets (e.g. ETH and DXY alongside BTC, or a stock and an FX pair) and
//   learns their RELATIVE REGIME with a NeuraLib network: relative strength, rolling correlation, and
//   the correlation regime itself (risk-on coupling vs. decoupling). From that, the agent issues HEDGE
//   signals — when the main asset's downside risk is best offset by a correlated instrument — and
//   DIVERSIFICATION guidance, when correlations decouple and spreading exposure pays. A reward based
//   on whether a hedge call actually reduced realized drawdown lets the regime model self-evolve.
//
//   Visualization: "Hedge Alert" arrows on the main asset plus up to two relative-strength comparison
//   lines. A fresh lens for trading in a correlated, multi-asset world.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Portfolio Regime Hedge Optimizer", "AE-PR HO", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_ASSET = "◆  PORTFOLIO ASSETS"
var string GRP_REGIME= "◆  RELATIVE REGIME (NeuraLib)"
var string GRP_HEDGE = "◆  HEDGE & DIVERSIFICATION"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Portfolio Assets —
asset1Sym    = input.symbol("BINANCE:ETHUSDT", "Correlated Asset 1", group = GRP_ASSET, tooltip = "First correlated asset to compare against the main chart symbol.")
asset2Sym    = input.symbol("TVC:DXY", "Correlated Asset 2", group = GRP_ASSET, tooltip = "Second correlated asset (e.g. a risk-off proxy like DXY). Set to a related instrument.")
useAsset2    = input.bool(true, "Use Asset 2", group = GRP_ASSET)
corrLen      = input.int(40,   "Correlation Window", minval = 5, maxval = 200, group = GRP_ASSET)
relLen       = input.int(30,   "Relative Strength Window", minval = 2, maxval = 200, group = GRP_ASSET)

// — Relative Regime —
hiddenN      = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_REGIME)
learnRate    = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_REGIME)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_REGIME)
bufferCap    = input.int(150,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_REGIME)
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_REGIME)
rewardLook   = input.int(5,    "Outcome Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REGIME)
seedInp      = input.int(59,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_REGIME)

// — Hedge & Diversification —
hedgeGate    = input.float(0.45,"Min Hedge Conviction", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_HEDGE, tooltip = "A Hedge Alert fires only when the model's hedge conviction clears this gate.")
hedgeSmooth  = input.int(3,    "Signal Smoothing", minval = 1, maxval = 20, group = GRP_HEDGE)
corrHighGate = input.float(0.6, "High-Correlation Level", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_HEDGE, tooltip = "Above this rolling correlation, assets are 'coupled' (risk-on/off together) — hedge regime.")
corrLowGate  = input.float(0.2, "Decoupling Level", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_HEDGE, tooltip = "Below this, assets decouple — diversification regime.")

// — Aesthetics —
colMain      = input.color(#5ce1ff, "Main Asset", group = GRP_STYLE)
colA1        = input.color(#21d3a3, "Asset 1 Rel-Strength", group = GRP_STYLE, inline = "c1")
colA2        = input.color(#f4c25b, "Asset 2 Rel-Strength", group = GRP_STYLE, inline = "c1")
colHedge     = input.color(#ff5d73, "Hedge Alert", group = GRP_STYLE, inline = "c2")
colDiv       = input.color(#a78bfa, "Diversify", group = GRP_STYLE, inline = "c2")
showRelLines = input.bool(true, "Relative-Strength Lines", group = GRP_STYLE)
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

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  MULTI-ASSET DATA  — pull correlated assets via request.security
// ════════════════════════════════════════════════════════════════════════════════════════════════

a1Close = request.security(asset1Sym, timeframe.period, close)
a2Close = request.security(asset2Sym, timeframe.period, close)

atr = ta.atr(14)

// returns
mainRet = (close - close[1]) / (close[1] == 0 ? 1.0 : close[1])
a1Ret   = (a1Close - a1Close[1]) / (a1Close[1] == 0 ? 1.0 : a1Close[1])
a2Ret   = (a2Close - a2Close[1]) / (a2Close[1] == 0 ? 1.0 : a2Close[1])

// rolling correlations (main vs each asset)
corr1 = ta.correlation(close, a1Close, corrLen)
corr2 = ta.correlation(close, a2Close, corrLen)
corr1 := na(corr1) ? 0.0 : corr1
corr2 := na(corr2) ? 0.0 : corr2

// relative strength: main vs asset, as the ratio of normalized performance over relLen
mainPerf = (close - close[relLen]) / (close[relLen] == 0 ? 1.0 : close[relLen])
a1Perf   = (a1Close - a1Close[relLen]) / (a1Close[relLen] == 0 ? 1.0 : a1Close[relLen])
a2Perf   = (a2Close - a2Close[relLen]) / (a2Close[relLen] == 0 ? 1.0 : a2Close[relLen])
relStr1  = mainPerf - a1Perf    // >0 main outperforming asset1
relStr2  = mainPerf - a2Perf

// main-asset risk state
mainVol = ta.stdev(mainRet, corrLen)
mainDown = math.min(0.0, (close - ta.highest(close, relLen)) / (atr == 0 ? 1.0 : atr))   // drawdown from recent high, ≤0

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  STATE ENCODER  — relative-regime features
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_clamp(float v) =>
    math.max(-3.0, math.min(3.0, v))

s0 = f_clamp(corr1 * 3.0)                 // correlation regime vs asset1
s1 = f_clamp(useAsset2 ? corr2 * 3.0 : 0.0) // correlation regime vs asset2
s2 = f_clamp(relStr1 * 10.0)              // relative strength vs asset1
s3 = f_clamp(useAsset2 ? relStr2 * 10.0 : 0.0)
s4 = f_clamp(mainDown)                     // main drawdown pressure
s5 = f_clamp((mainVol / (ta.sma(mainVol, 120) == 0 ? 1.0 : ta.sma(mainVol, 120)) - 1.0) * 2.0)  // main vol regime

var int N_IN  = 6
var int N_OUT = 3   // actions: 0 = HEDGE, 1 = DIVERSIFY, 2 = HOLD (no action)

var int ACT_HEDGE = 0
var int ACT_DIV   = 1
var int ACT_HOLD  = 2

f_actName(int a) =>
    a == ACT_HEDGE ? "HEDGE" : a == ACT_DIV ? "DIVERSIFY" : "HOLD"

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  NEURALIB REGIME NETWORK  — state → hidden(tanh) → Q[3] (hedge / diversify / hold values)
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
    W1 := array.new_float(hiddenN * N_IN, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    W2 := array.new_float(N_OUT * hiddenN, 0.0)
    b2 := array.new_float(N_OUT, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.6)
    f_initRange(W2, seedInp * 40503 + 101, 0.6)
    netInit := true

f_net(float i0, float i1, float i2, float i3, float i4, float i5, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_IN + 0) * i0
        z += array.get(W1, h * N_IN + 1) * i1
        z += array.get(W1, h * N_IN + 2) * i2
        z += array.get(W1, h * N_IN + 3) * i3
        z += array.get(W1, h * N_IN + 4) * i4
        z += array.get(W1, h * N_IN + 5) * i5
        array.push(hC, f_tanh(z))
    float q0 = array.get(b2, 0)
    float q1 = array.get(b2, 1)
    float q2 = array.get(b2, 2)
    for h = 0 to hiddenN - 1
        float hv = array.get(hC, h)
        q0 += array.get(W2, 0 * hiddenN + h) * hv
        q1 += array.get(W2, 1 * hiddenN + h) * hv
        q2 += array.get(W2, 2 * hiddenN + h) * hv
    [q0, q1, q2]

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<float> bS4 = array.new_float()
var array<float> bS5 = array.new_float()
var array<int>   bAct = array.new_int()
var array<float> bRew = array.new_float()
var array<float> bN0 = array.new_float()
var array<float> bN1 = array.new_float()
var array<float> bN2 = array.new_float()
var array<float> bN3 = array.new_float()
var array<float> bN4 = array.new_float()
var array<float> bN5 = array.new_float()

f_push(float ps0, float ps1, float ps2, float ps3, float ps4, float ps5, int a, float r, float n0, float n1, float n2, float n3, float n4, float n5) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bS4, ps4)
    array.push(bS5, ps5)
    array.push(bAct, a)
    array.push(bRew, r)
    array.push(bN0, n0)
    array.push(bN1, n1)
    array.push(bN2, n2)
    array.push(bN3, n3)
    array.push(bN4, n4)
    array.push(bN5, n5)
    if array.size(bAct) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bS4)
        array.shift(bS5)
        array.shift(bAct)
        array.shift(bRew)
        array.shift(bN0)
        array.shift(bN1)
        array.shift(bN2)
        array.shift(bN3)
        array.shift(bN4)
        array.shift(bN5)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REWARD  — did the chosen action reduce realized portfolio risk over the lookahead?
//    HEDGE pays off when the main asset subsequently fell (a hedge would have protected).
//    DIVERSIFY pays off when correlations stayed low / the alt outperformed.
//    HOLD pays off when nothing bad happened (avoids needless hedging cost).
// ════════════════════════════════════════════════════════════════════════════════════════════════

fwdMainRet = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
fwdA1Ret   = (a1Close - a1Close[rewardLook]) / (a1Close[rewardLook] == 0 ? 1.0 : a1Close[rewardLook])

f_reward(int a, float fMain, float fA1, float corr) =>
    float r = 0.0
    if a == ACT_HEDGE
        // hedge rewarded if main fell (protection valuable); penalized (cost) if main rose
        r := -fMain * 8.0 - 0.05
    else if a == ACT_DIV
        // diversify rewarded when the alt diverged favorably (low corr + alt didn't crash with main)
        r := (1.0 - math.abs(corr)) * 2.0 + (fA1 - fMain) * 4.0
    else
        // hold rewarded if main held up (no need to hedge)
        r := fMain * 4.0
    math.max(-5.0, math.min(5.0, r))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRAINING  (DQN-style)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()
var array<float> hNx = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bAct) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        float ps4 = array.get(bS4, idx)
        float ps5 = array.get(bS5, idx)
        int   a   = array.get(bAct, idx)
        float r   = array.get(bRew, idx)
        float nx0 = array.get(bN0, idx)
        float nx1 = array.get(bN1, idx)
        float nx2 = array.get(bN2, idx)
        float nx3 = array.get(bN3, idx)
        float nx4 = array.get(bN4, idx)
        float nx5 = array.get(bN5, idx)

        [q0, q1, q2] = f_net(ps0, ps1, ps2, ps3, ps4, ps5, hTr)
        [nq0, nq1, nq2] = f_net(nx0, nx1, nx2, nx3, nx4, nx5, hNx)
        float maxNext = math.max(nq0, math.max(nq1, nq2))
        float target = r + 0.92 * maxNext
        float pred = a == 0 ? q0 : a == 1 ? q1 : q2
        float err = math.max(-5.0, math.min(5.0, pred - target))

        gH = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            int wi = a * hiddenN + h
            array.set(gH, h, err * array.get(W2, wi))
            array.set(W2, wi, array.get(W2, wi) - learnRate * err * array.get(hTr, h))
        array.set(b2, a, array.get(b2, a) - learnRate * err)
        for h = 0 to hiddenN - 1
            float dz = array.get(gH, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_IN + 0, array.get(W1, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(W1, h * N_IN + 1, array.get(W1, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(W1, h * N_IN + 2, array.get(W1, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(W1, h * N_IN + 3, array.get(W1, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(W1, h * N_IN + 4, array.get(W1, h * N_IN + 4) - learnRate * dz * ps4)
            array.set(W1, h * N_IN + 5, array.get(W1, h * N_IN + 5) - learnRate * dz * ps5)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var float pS4 = na
var float pS5 = na
var int   pAct = na
var float pCorr = na

var float liveQ0 = na
var float liveQ1 = na
var float liveQ2 = na
var int   chosen = ACT_HOLD
var float hedgeConv = 0.0
var float convEma = na

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        float rwd = f_reward(pAct, fwdMainRet, fwdA1Ret, na(pCorr) ? 0.0 : pCorr)
        f_push(pS0, pS1, pS2, pS3, pS4, pS5, pAct, rwd, s0, s1, s2, s3, s4, s5)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bAct)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)

// ---- DECISION (every bar incl. realtime) ----
if inHorizon
    [q0, q1, q2] = f_net(s0, s1, s2, s3, s4, s5, hLv)
    liveQ0 := q0
    liveQ1 := q1
    liveQ2 := q2

    float qmax = math.max(q0, math.max(q1, q2))
    chosen := q0 == qmax ? ACT_HEDGE : q1 == qmax ? ACT_DIV : ACT_HOLD

    // hedge conviction = normalized dominance of the hedge value relative to the spread
    float qmin = math.min(q0, math.min(q1, q2))
    float rng = (qmax - qmin) == 0 ? 1.0 : (qmax - qmin)
    hedgeConv := (q0 - qmin) / rng    // how strongly HEDGE stands out

    convEma := na(convEma) ? hedgeConv : (hedgeConv * (2.0 / (hedgeSmooth + 1)) + convEma * (1.0 - 2.0 / (hedgeSmooth + 1)))

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pS4 := s4
        pS5 := s5
        pAct := chosen
        pCorr := corr1

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  CORRELATION REGIME CLASSIFICATION
// ════════════════════════════════════════════════════════════════════════════════════════════════

float avgCorr = useAsset2 ? (corr1 + corr2) / 2.0 : corr1
bool coupled    = avgCorr >= corrHighGate     // risk-on/off coupling → hedge regime
bool decoupled  = avgCorr <= corrLowGate      // decoupling → diversification regime

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — Hedge Alert arrows + relative-strength comparison lines
// ════════════════════════════════════════════════════════════════════════════════════════════════

float conv = na(convEma) ? 0.0 : convEma

// HEDGE alert: model chose HEDGE, conviction clears the gate, and assets are coupled with downside risk
var int lastAct = na
bool actChanged = na(lastAct) or chosen != lastAct
bool hedgeAlert = inHorizon and barstate.isconfirmed and chosen == ACT_HEDGE and conv >= hedgeGate and mainDown < 0.0
bool divAlert   = inHorizon and barstate.isconfirmed and chosen == ACT_DIV and decoupled and actChanged

if inHorizon and barstate.isconfirmed and chosen != ACT_HOLD
    lastAct := chosen

// Hedge Alert arrows (down-pointing warning over price)
plotshape(hedgeAlert and actChanged and glowFx, title = "Hedge Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colHedge, 72), size = size.large, force_overlay = true)
plotshape(hedgeAlert and actChanged, title = "Hedge Alert", style = shape.triangledown, location = location.abovebar, color = color.new(colHedge, 0), size = size.normal, force_overlay = true)
if hedgeAlert and actChanged
    label.new(bar_index, high, "⚠ HEDGE", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colHedge, 12), textcolor = #0a0d15, size = size.small, force_overlay = true)

// Diversify markers
plotshape(divAlert, title = "Diversify", style = shape.diamond, location = location.belowbar, color = color.new(colDiv, 10), size = size.small, force_overlay = true)
if divAlert
    label.new(bar_index, low, "⊕ DIVERSIFY", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colDiv, 12), textcolor = #0a0d15, size = size.small, force_overlay = true)

// --- relative-strength comparison lines (up to 2) ---
// projected onto the price pane: anchor at current close, scaled so they sit near price as a comparison.
// We render them as price-overlaid lines representing each asset's performance rebased to the main close.
reb1 = close * (1.0 + (a1Perf - mainPerf))   // asset1 rebased relative to main
reb2 = close * (1.0 + (a2Perf - mainPerf))

plot(showRelLines and inHorizon ? reb1 : na, "Asset 1 Rel-Strength", color = color.new(colA1, 0), linewidth = 2, force_overlay = true)
plot(showRelLines and useAsset2 and inHorizon ? reb2 : na, "Asset 2 Rel-Strength", color = color.new(colA2, 0), linewidth = 2, force_overlay = true)

// glow under main close to anchor the comparison
plot(glowFx and inHorizon ? close : na, "Main Anchor", color = color.new(colMain, 70), linewidth = 1, force_overlay = true)

// hedge-regime background tint (subtle)
bgcolor(inHorizon and coupled and conv >= hedgeGate ? color.new(colHedge, 92) : na, title = "Hedge Regime Tint")

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

f_signedBar(float b) =>
    int half = 6
    int mag = int(math.round(math.min(1.0, math.abs(b)) * half))
    string s = ""
    for i = 1 to half
        s := s + (b < 0 and i > half - mag ? "█" : "░")
    s := s + "│"
    for i = 1 to half
        s := s + (b > 0 and i <= mag ? "█" : "░")
    s

f_corrName(float c) =>
    c >= corrHighGate ? "COUPLED" : c <= corrLowGate ? "DECOUPLED" : c < 0 ? "INVERSE" : "MIXED"

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    string rec = chosen == ACT_HEDGE and conv >= hedgeGate ? "HEDGE NOW" : chosen == ACT_DIV ? "DIVERSIFY" : "HOLD"
    color recCol = chosen == ACT_HEDGE and conv >= hedgeGate ? colHedge : chosen == ACT_DIV ? colDiv : THEME_DIM

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "PORTFOLIO", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + rec, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = recCol)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Hedge Conviction", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_bar(conv), text_color = conv >= hedgeGate ? colHedge : THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(math.round(conv * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "REGIME VALUES", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 3, 2, 3)

    table.cell(panel, 0, 4, "Hedge / Div / Hold", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 4, 1, 4)
    table.cell(panel, 2, 4, str.tostring(na(liveQ0) ? 0.0 : liveQ0, "#.#") + " / " + str.tostring(na(liveQ1) ? 0.0 : liveQ1, "#.#") + " / " + str.tostring(na(liveQ2) ? 0.0 : liveQ2, "#.#"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "CORRELATIONS", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    table.cell(panel, 0, 6, "Corr Asset 1", text_color = colA1, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, f_signedBar(corr1), text_color = corr1 >= 0 ? colA1 : colHedge, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 6, str.tostring(corr1, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "Corr Asset 2", text_color = colA2, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, useAsset2 ? f_signedBar(corr2) : "—", text_color = corr2 >= 0 ? colA2 : colHedge, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 7, useAsset2 ? str.tostring(corr2, "#.##") : "off", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Corr Regime", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, "", text_size = f_panelSize())
    table.cell(panel, 2, 8, f_corrName(avgCorr), text_color = coupled ? colHedge : decoupled ? colDiv : THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Rel-Strength (A1/A2)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 9, 1, 9)
    table.cell(panel, 2, 9, str.tostring(relStr1 * 100, "+#.#;-#.#") + "% / " + (useAsset2 ? str.tostring(relStr2 * 100, "+#.#;-#.#") + "%" : "—"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Main Drawdown", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, "", text_size = f_panelSize())
    table.cell(panel, 2, 10, str.tostring(mainDown, "#.##") + " ATR", text_color = mainDown < -0.5 ? colHedge : THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(hedgeAlert and actChanged, "Portfolio ▸ HEDGE ALERT", "AetherEdge Portfolio: hedge recommended — correlated downside risk detected.")
alertcondition(divAlert, "Portfolio ▸ DIVERSIFY", "AetherEdge Portfolio: diversification favorable — assets decoupling.")
````
