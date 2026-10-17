# AetherEdge - RainbowDQN Multi-Component

- url: https://www.tradingview.com/script/deHznKCB/
- type: indicator
- pine_id: PUB;91e5f6ab8a114afe81955cdec99ecf83
- version: 1.0

## Description

🖊️ Overview

A self-evolving multi-component agent that fuses the core pillars of Rainbow DQN into one policy: Double (overestimation control), Dueling (separating state value from action advantage), and Prioritized Replay (re-learning in proportion to surprise / TD error). It learns from a composite reward — risk-adjusted return, drawdown avoidance, and volatility scaling — so it generalizes across trending, ranging, and high-volatility regimes alike. The internals are multi-headed, but their complex valuation is distilled into a single refined unified-signal arrow, rendered with layered glow and a premium intelligence panel.

🔶 Key Features

Three Rainbow components fused — Double + Dueling + Prioritized Replay in one policy
Composite-reward learning — risk-adjusted return + drawdown avoidance + volatility scaling, weighted
Multi-regime adaptability — volatility scaling and drawdown penalty generalize across trend / range / high-vol
Overestimation control (Double) — online net selects, target net evaluates
V/A separation (Dueling) — state value V(s) and advantage A(s,a) on separate streams
Prioritized replay + importance sampling — high-TD-error transitions learned first, with IS bias correction
Unified signal arrow only — multi-head internals distilled into one clean arrow (Layered Glow / Minimal / Labeled styles)
Refined visuals — multi-layer glow arrows, conviction ribbon, signal pulse, and a sectioned premium panel

🧠 Technical Architecture

The agent perceives the market as a five-dimensional state vector: momentum spread, RSI deviation, ADX trend strength, a volatility-regime ratio, and position-within-range — all z-normalized. Two networks exist (online + target), each with a Dueling structure — a shared trunk (tanh) forks into a Value stream V(s) and an Advantage stream A(s,a), recombined as Q = V + (A − mean A).
As Double-DQN, next-state action selection uses the online net's argmax while its valuation uses the target net, curbing overestimation; weights hard-sync every Target Net Sync bars. The composite reward fuses three heads: (1) risk-adjusted return (forward return normalized by ATR), (2) drawdown avoidance (penalizing adverse excursion within the lookahead window), and (3) volatility scaling (shrinking rewards earned under abnormally high volatility).
For prioritized replay, each transition's TD error δ = pred − target is turned into a priority |δ|^α, skewing sampling toward surprising experiences, while an importance-sampling (β) weight corrects the resulting bias. Gradients flow through the dueling aggregation (dQ/dV = 1, dQ/dA = 𝟙[a] − 1/3) into each stream and the shared trunk via manual backpropagation. Finally, a unified conviction blending Q-spread and advantage-spread is computed, and a single arrow is drawn only when it clears the gate.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, γ 0.94, Target Net Sync 25, reward weights Ret 1.0 / DD 0.6 / Vol 0.4. The balanced defaults fit well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8 to value trend persistence
SOL (15m–1H): High volatility favors Vol weight 0.6–0.8 to strengthen scaling, Conviction Gate 0.45–0.55 to be selective
XRP (1H–4H): Spike-prone; DD weight ≈ 0.8 to penalize adverse excursion harder, Priority Exponent ≈ 2.0
Composite weights: raise Ret for trend-seeking, DD for steadier operation, Vol for choppy markets — allocate by market character and style
Conviction Gate: higher (0.5–0.6) gives fewer, higher-quality arrows; lower (0.3–0.4) gives more — tune to your trade frequency
Target Net Sync (τ): short (10–15) adapts fast but less stable; long (40–60) is stable — match to market stability

💡 How to Use in Practice

Reacting to the unified arrow: every arrow shown is the "final verdict" — past the multi-head valuation, composite reward, and conviction gate — a high-confidence core basis for trend-following entries
Using the conviction ribbon: the more saturated the under-price ribbon, the stronger the directional conviction; arrow plus matching ribbon color (teal bullish, coral bearish) is the most coherent setup
Across regimes: follow arrows directly in trends; in ranges the drawdown-avoidance head reduces forced signals; in high-vol the volatility head tempers overreaction
Signal pulse: the pulse dot on the firing bar improves entry-timing visibility
Multi-timeframe usage: confirm the big-picture unified direction on the higher timeframe (4H), then refine timing on aligned arrows on the lower one (15m–1H)
Combinations: pair with volume or key S/R, filtering for high-conviction arrows to lift precision further

⚠️ Important Notes

Initial learning period: right after launch the replay buffer is nearly empty and both networks are unstable; treat signals as low-confidence until it fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes all network weights and the buffer, restarting learning from zero
Target-sync effect: calls may briefly shift right after a sync — this is normal Double-DQN behavior
On forward-looking reward: rewards and drawdown use closed-bar forward data (a standard RL training construct); current-bar evaluation is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Rainbow DQN (Double/Dueling/Prioritized Replay), composite reward, networks, and signal outputs are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - RainbowDQN Multi-Component
//   AI Drawing Power Series
//
//   A self-evolving multi-component agent fusing three pillars of the Rainbow-DQN family:
//     • DOUBLE   — twin online/target networks decouple action selection from evaluation, curbing
//                  Q-value overestimation.
//     • DUELING  — each network forks into a Value stream V(s) and an Advantage stream A(s,a),
//                  recombined as Q = V + (A − mean A).
//     • PRIORITIZED REPLAY — transitions are re-learned in proportion to their surprise (TD error),
//                  with importance-sampling correction.
//   Learning is driven by a COMPOSITE reward — risk-adjusted return, drawdown avoidance, and
//   volatility scaling — so the agent adapts across trending, ranging, and high-volatility regimes.
//
//   Visualization: a single refined unified-signal arrow (the multi-headed internals distilled into
//   one clean decision), rendered with layered gradient glow, a conviction ribbon, and a premium panel.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - RainbowDQN Multi-Component", "AE-RDQN MC", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT  = "◆  RAINBOW AGENT"
var string GRP_STATE  = "◆  STATE ENCODER"
var string GRP_NET    = "◆  DUELING Q-NETWORKS (NeuraLib)"
var string GRP_REPLAY = "◆  PRIORITIZED REPLAY"
var string GRP_REWARD = "◆  COMPOSITE REWARD"
var string GRP_SIG    = "◆  UNIFIED SIGNAL"
var string GRP_STYLE  = "◆  AESTHETICS"
var string GRP_PANEL  = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen      = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
epsilon       = input.float(0.05,"Exploration ε",          minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_AGENT)
gamma         = input.float(0.94,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
tauSync       = input.int(25,   "Target Net Sync (bars)",  minval = 1, maxval = 500, group = GRP_AGENT, tooltip = "How often the target network copies the online network (the Double-DQN term).")

// — State Encoder —
fastLen       = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen       = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen        = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
adxLen        = input.int(14,   "ADX Length",     minval = 2, maxval = 100, group = GRP_STATE)
normLen       = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Dueling Q-Networks —
hiddenN       = input.int(8,    "Shared Hidden Units", minval = 2, maxval = 16, group = GRP_NET)
streamN       = input.int(4,    "Stream Hidden Units", minval = 2, maxval = 12, group = GRP_NET)
learnRate     = input.float(0.04,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
trainSteps    = input.int(5,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_NET)
seedInp       = input.int(23,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Prioritized Replay —
bufferCap     = input.int(160,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_REPLAY)
priorityExp   = input.float(1.5,"Priority Exponent (α)", minval = 0.0, maxval = 4.0, step = 0.1, group = GRP_REPLAY, tooltip = "How strongly sampling skews toward high-TD-error (surprising) transitions.")
isWeight      = input.float(0.5,"Importance Sampling (β)", minval = 0.0, maxval = 1.0, step = 0.1, group = GRP_REPLAY, tooltip = "Importance-sampling correction strength to offset the bias from prioritized sampling.")

// — Composite Reward —
rewardLook    = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
wReturn       = input.float(1.0, "Weight ▸ Risk-Adj Return", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_REWARD)
wDrawdown     = input.float(0.6, "Weight ▸ Drawdown Avoidance", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_REWARD, tooltip = "Penalizes actions exposed to adverse excursion within the lookahead window.")
wVol          = input.float(0.4, "Weight ▸ Volatility Scaling", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_REWARD, tooltip = "Down-weights rewards earned in abnormally high volatility.")
flatPenalty   = input.float(0.05,"Flat Opportunity Cost",  minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_REWARD)

// — Unified Signal —
sigGate       = input.float(0.40,"Min Conviction to Signal", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_SIG, tooltip = "Unified arrows fire only when conviction (Q-spread blended with advantage) clears this gate.")
sigSmooth     = input.int(2,    "Conviction Smoothing", minval = 1, maxval = 20, group = GRP_SIG)
oncePerMove   = input.bool(true,"One Arrow per Directional Shift", group = GRP_SIG, tooltip = "Suppresses repeated arrows until the direction changes.")

// — Aesthetics —
colLong       = input.color(#21d3a3, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort      = input.color(#ff5d73, "Short Tone", group = GRP_STYLE, inline = "c1")
colFlat       = input.color(#7d88a0, "Flat Tone",  group = GRP_STYLE, inline = "c1")
arrowStyle    = input.string("Layered Glow", "Arrow Style", options = ["Layered Glow", "Minimal", "Labeled"], group = GRP_STYLE, tooltip = "Layered Glow = premium multi-layer halo; Minimal = clean triangle; Labeled = arrow + conviction tag.")
showRibbon    = input.bool(true, "Conviction Ribbon", group = GRP_STYLE, tooltip = "A subtle color-graded ribbon under price encoding directional conviction.")
showPulse     = input.bool(true, "Signal Pulse Marker", group = GRP_STYLE)

// — Intelligence Panel —
showPanel     = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos      = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize     = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE  — refined dark-mode tokens
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG    = color.new(#0a0d15, 8)
var color THEME_GRID  = color.new(#222b40, 38)
var color THEME_TXT   = #d2dae8
var color THEME_DIM   = #6b7689
var color THEME_ACC   = #5ce1ff
var color THEME_GOLD  = #f4c25b

var int A_LONG  = 0
var int A_SHORT = 1
var int A_FLAT  = 2

f_actionColor(int a) =>
    a == A_LONG ? colLong : a == A_SHORT ? colShort : colFlat

f_actionName(int a) =>
    a == A_LONG ? "LONG" : a == A_SHORT ? "SHORT" : "FLAT"

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ACTIVATIONS / PRNG  (NeuraLib primitives — no bitwise ops in Pine)
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
//  STATE ENCODER  — momentum, RSI deviation, ADX trend strength, volatility regime, range position
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(14)
[diP, diM, adxVal] = ta.dmi(adxLen, adxLen)
hh      = ta.highest(high, slowLen)
ll      = ta.lowest(low, slowLen)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

rawMom = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawRsi = (rsi - 50.0) / 50.0
rawAdx = (adxVal - 25.0) / 25.0
rawVol = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen)) - 1.0
rawPos = (hh - ll) == 0 ? 0.0 : (close - ll) / (hh - ll) * 2.0 - 1.0

// 5-dim state vector
s0 = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
s1 = rawRsi
s2 = rawAdx
s3 = f_znorm(rawVol, ta.sma(rawVol, normLen), ta.stdev(rawVol, normLen))
s4 = rawPos

var int N_IN  = 5
var int N_OUT = 3

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  DUELING Q-NETWORK (×2: online + target)
//  Shared trunk(tanh) → Value stream(tanh→scalar) + Advantage stream(tanh→3) → Q = V + (A − meanA)
//  Parameters held as flat arrays; the two nets share an identical layout.
// ────────────────────────────────────────────────────────────────────────────────────────────────

// Online net
var array<float> Wt  = na   // trunk [hiddenN x N_IN]
var array<float> bt  = na
var array<float> Wv1 = na   // value hidden [streamN x hiddenN]
var array<float> bv1 = na
var array<float> Wv2 = na   // value out [streamN]
var array<float> bv2 = na   // [1]
var array<float> Wa1 = na   // adv hidden [streamN x hiddenN]
var array<float> ba1 = na
var array<float> Wa2 = na   // adv out [N_OUT x streamN]
var array<float> ba2 = na
// Target net (mirror)
var array<float> tWt  = na
var array<float> tbt  = na
var array<float> tWv1 = na
var array<float> tbv1 = na
var array<float> tWv2 = na
var array<float> tbv2 = na
var array<float> tWa1 = na
var array<float> tba1 = na
var array<float> tWa2 = na
var array<float> tba2 = na
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    Wt  := array.new_float(hiddenN * N_IN, 0.0)
    bt  := array.new_float(hiddenN, 0.0)
    Wv1 := array.new_float(streamN * hiddenN, 0.0)
    bv1 := array.new_float(streamN, 0.0)
    Wv2 := array.new_float(streamN, 0.0)
    bv2 := array.new_float(1, 0.0)
    Wa1 := array.new_float(streamN * hiddenN, 0.0)
    ba1 := array.new_float(streamN, 0.0)
    Wa2 := array.new_float(N_OUT * streamN, 0.0)
    ba2 := array.new_float(N_OUT, 0.0)
    f_initRange(Wt,  seedInp * 2654435761,  0.7)
    f_initRange(Wv1, seedInp * 40503 + 101, 0.7)
    f_initRange(Wv2, seedInp * 92821 + 202, 0.7)
    f_initRange(Wa1, seedInp * 12345 + 303, 0.7)
    f_initRange(Wa2, seedInp * 27644 + 404, 0.7)
    // target = copy of online
    tWt  := array.copy(Wt)
    tbt  := array.copy(bt)
    tWv1 := array.copy(Wv1)
    tbv1 := array.copy(bv1)
    tWv2 := array.copy(Wv2)
    tbv2 := array.copy(bv2)
    tWa1 := array.copy(Wa1)
    tba1 := array.copy(ba1)
    tWa2 := array.copy(Wa2)
    tba2 := array.copy(ba2)
    netInit := true

// Forward pass with a supplied parameter set. Returns [q0,q1,q2,V,A0,A1,A2].
f_forwardWith(float i0, float i1, float i2, float i3, float i4, array<float> wt, array<float> bbt, array<float> wv1, array<float> bbv1, array<float> wv2, array<float> bbv2, array<float> wa1, array<float> bba1, array<float> wa2, array<float> bba2, array<float> hC, array<float> vC, array<float> aC) =>
    array.clear(hC)
    array.clear(vC)
    array.clear(aC)
    for h = 0 to hiddenN - 1
        float z = array.get(bbt, h)
        z += array.get(wt, h * N_IN + 0) * i0
        z += array.get(wt, h * N_IN + 1) * i1
        z += array.get(wt, h * N_IN + 2) * i2
        z += array.get(wt, h * N_IN + 3) * i3
        z += array.get(wt, h * N_IN + 4) * i4
        array.push(hC, f_tanh(z))
    // value stream
    for v = 0 to streamN - 1
        float z = array.get(bbv1, v)
        for h = 0 to hiddenN - 1
            z += array.get(wv1, v * hiddenN + h) * array.get(hC, h)
        array.push(vC, f_tanh(z))
    float V = array.get(bbv2, 0)
    for v = 0 to streamN - 1
        V += array.get(wv2, v) * array.get(vC, v)
    // advantage stream
    for a = 0 to streamN - 1
        float z = array.get(bba1, a)
        for h = 0 to hiddenN - 1
            z += array.get(wa1, a * hiddenN + h) * array.get(hC, h)
        array.push(aC, f_tanh(z))
    float A0 = array.get(bba2, 0)
    float A1 = array.get(bba2, 1)
    float A2 = array.get(bba2, 2)
    for a = 0 to streamN - 1
        float av = array.get(aC, a)
        A0 += array.get(wa2, 0 * streamN + a) * av
        A1 += array.get(wa2, 1 * streamN + a) * av
        A2 += array.get(wa2, 2 * streamN + a) * av
    float aMean = (A0 + A1 + A2) / 3.0
    float q0 = V + (A0 - aMean)
    float q1 = V + (A1 - aMean)
    float q2 = V + (A2 - aMean)
    [q0, q1, q2, V, A0, A1, A2]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  PRIORITIZED REPLAY BUFFER
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<float> bS4 = array.new_float()
var array<int>   bAct = array.new_int()
var array<float> bRew = array.new_float()
var array<float> bN0 = array.new_float()
var array<float> bN1 = array.new_float()
var array<float> bN2 = array.new_float()
var array<float> bN3 = array.new_float()
var array<float> bN4 = array.new_float()
var array<float> bPri = array.new_float()

f_push(float ps0, float ps1, float ps2, float ps3, float ps4, int a, float r, float n0, float n1, float n2, float n3, float n4, float pri) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bS4, ps4)
    array.push(bAct, a)
    array.push(bRew, r)
    array.push(bN0, n0)
    array.push(bN1, n1)
    array.push(bN2, n2)
    array.push(bN3, n3)
    array.push(bN4, n4)
    array.push(bPri, pri)
    if array.size(bAct) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bS4)
        array.shift(bAct)
        array.shift(bRew)
        array.shift(bN0)
        array.shift(bN1)
        array.shift(bN2)
        array.shift(bN3)
        array.shift(bN4)
        array.shift(bPri)

f_sampleIdx(int rngSeed) =>
    int n = array.size(bAct)
    int idx = 0
    if n > 0
        float total = array.sum(bPri)
        float pick = f_rand(rngSeed) * total
        float run = 0.0
        int found = n - 1
        bool done = false
        for i = 0 to n - 1
            if not done
                run += array.get(bPri, i)
                if run >= pick
                    found := i
                    done := true
        idx := found
    idx

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  COMPOSITE REWARD  — risk-adjusted return + drawdown avoidance + volatility scaling
// ────────────────────────────────────────────────────────────────────────────────────────────────

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]
// adverse excursion within the lookahead window (drawdown proxy)
fwdLow  = ta.lowest(low, rewardLook)
fwdHigh = ta.highest(high, rewardLook)
volRatio = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen))

f_reward(int a, float ret, float atrRef, float ddLong, float ddShort, float vr) =>
    float baseRet = atrRef != 0 ? (ret * close[rewardLook]) / atrRef : ret
    float dirRet = a == A_LONG ? baseRet : a == A_SHORT ? -baseRet : -flatPenalty * math.abs(baseRet)
    // drawdown avoidance: penalize adverse excursion the action was exposed to
    float dd = a == A_LONG ? ddLong : a == A_SHORT ? ddShort : 0.0
    float ddTerm = -wDrawdown * dd
    // volatility scaling: shrink reward magnitude when vol is abnormally high
    float volScale = 1.0 / (1.0 + math.max(0.0, vr - 1.0))
    float r = (wReturn * dirRet + ddTerm) * (wVol > 0 ? (1.0 - wVol + wVol * volScale) : 1.0)
    math.max(-5.0, math.min(5.0, r))

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  TRAINING STEP  — Double-DQN target through the dueling architecture, prioritized + IS-weighted
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hTr = array.new_float()
var array<float> vTr = array.new_float()
var array<float> aTr = array.new_float()
var array<float> hSel = array.new_float()
var array<float> vSel = array.new_float()
var array<float> aSel = array.new_float()
var array<float> hEv = array.new_float()
var array<float> vEv = array.new_float()
var array<float> aEv = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bAct) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        float ps4 = array.get(bS4, idx)
        int   a   = array.get(bAct, idx)
        float r   = array.get(bRew, idx)
        float nx0 = array.get(bN0, idx)
        float nx1 = array.get(bN1, idx)
        float nx2 = array.get(bN2, idx)
        float nx3 = array.get(bN3, idx)
        float nx4 = array.get(bN4, idx)

        // online Q at current state
        [q0, q1, q2, V, A0, A1, A2] = f_forwardWith(ps0, ps1, ps2, ps3, ps4, Wt, bt, Wv1, bv1, Wv2, bv2, Wa1, ba1, Wa2, ba2, hTr, vTr, aTr)

        // DOUBLE-DQN: select aStar with online net, evaluate with target net
        [oq0, oq1, oq2, oV, oA0, oA1, oA2] = f_forwardWith(nx0, nx1, nx2, nx3, nx4, Wt, bt, Wv1, bv1, Wv2, bv2, Wa1, ba1, Wa2, ba2, hSel, vSel, aSel)
        float omax = math.max(oq0, math.max(oq1, oq2))
        int aStar = oq0 == omax ? 0 : oq1 == omax ? 1 : 2
        [tq0, tq1, tq2, tV, tA0, tA1, tA2] = f_forwardWith(nx0, nx1, nx2, nx3, nx4, tWt, tbt, tWv1, tbv1, tWv2, tbv2, tWa1, tba1, tWa2, tba2, hEv, vEv, aEv)
        float evalNext = aStar == 0 ? tq0 : aStar == 1 ? tq1 : tq2

        float target = r + gamma * evalNext
        float pred   = a == 0 ? q0 : a == 1 ? q1 : q2
        float tdErr  = pred - target

        // update this transition's priority by |TD error| (prioritized replay)
        array.set(bPri, idx, math.pow(math.abs(tdErr) + 0.01, priorityExp))

        // importance-sampling weight (β): down-weight high-priority samples to reduce bias
        int n = array.size(bAct)
        float prob = array.get(bPri, idx) / math.max(array.sum(bPri), 1e-6)
        float isw = math.pow(1.0 / math.max(n * prob, 1e-6), isWeight)
        isw := math.min(isw, 4.0)

        float err = math.max(-5.0, math.min(5.0, tdErr * isw))

        // ----- dueling gradients: dQ/dV = 1 ; dQ/dA(j) = (j==a) − 1/3 -----
        float gV = err
        gA = array.new_float(N_OUT, 0.0)
        for j = 0 to N_OUT - 1
            array.set(gA, j, err * ((j == a ? 1.0 : 0.0) - 1.0 / 3.0))

        gTrunk = array.new_float(hiddenN, 0.0)
        // value stream backprop
        gVH = array.new_float(streamN, 0.0)
        for v = 0 to streamN - 1
            array.set(gVH, v, gV * array.get(Wv2, v))
            array.set(Wv2, v, array.get(Wv2, v) - learnRate * gV * array.get(vTr, v))
        array.set(bv2, 0, array.get(bv2, 0) - learnRate * gV)
        for v = 0 to streamN - 1
            float dz = array.get(gVH, v) * f_dtanh(array.get(vTr, v))
            for h = 0 to hiddenN - 1
                int wi = v * hiddenN + h
                array.set(gTrunk, h, array.get(gTrunk, h) + dz * array.get(Wv1, wi))
                array.set(Wv1, wi, array.get(Wv1, wi) - learnRate * dz * array.get(hTr, h))
            array.set(bv1, v, array.get(bv1, v) - learnRate * dz)
        // advantage stream backprop
        gAH = array.new_float(streamN, 0.0)
        for j = 0 to N_OUT - 1
            float gj = array.get(gA, j)
            for a2 = 0 to streamN - 1
                int wi = j * streamN + a2
                array.set(gAH, a2, array.get(gAH, a2) + gj * array.get(Wa2, wi))
                array.set(Wa2, wi, array.get(Wa2, wi) - learnRate * gj * array.get(aTr, a2))
            array.set(ba2, j, array.get(ba2, j) - learnRate * gj)
        for a2 = 0 to streamN - 1
            float dz = array.get(gAH, a2) * f_dtanh(array.get(aTr, a2))
            for h = 0 to hiddenN - 1
                int wi = a2 * hiddenN + h
                array.set(gTrunk, h, array.get(gTrunk, h) + dz * array.get(Wa1, wi))
                array.set(Wa1, wi, array.get(Wa1, wi) - learnRate * dz * array.get(hTr, h))
            array.set(ba1, a2, array.get(ba1, a2) - learnRate * dz)
        // shared trunk backprop
        for h = 0 to hiddenN - 1
            float dz = array.get(gTrunk, h) * f_dtanh(array.get(hTr, h))
            array.set(Wt, h * N_IN + 0, array.get(Wt, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(Wt, h * N_IN + 1, array.get(Wt, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(Wt, h * N_IN + 2, array.get(Wt, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(Wt, h * N_IN + 3, array.get(Wt, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(Wt, h * N_IN + 4, array.get(Wt, h * N_IN + 4) - learnRate * dz * ps4)
            array.set(bt, h, array.get(bt, h) - learnRate * dz)

f_syncTarget() =>
    for i = 0 to array.size(Wt) - 1
        array.set(tWt, i, array.get(Wt, i))
    for i = 0 to array.size(bt) - 1
        array.set(tbt, i, array.get(bt, i))
    for i = 0 to array.size(Wv1) - 1
        array.set(tWv1, i, array.get(Wv1, i))
    for i = 0 to array.size(bv1) - 1
        array.set(tbv1, i, array.get(bv1, i))
    for i = 0 to array.size(Wv2) - 1
        array.set(tWv2, i, array.get(Wv2, i))
    array.set(tbv2, 0, array.get(bv2, 0))
    for i = 0 to array.size(Wa1) - 1
        array.set(tWa1, i, array.get(Wa1, i))
    for i = 0 to array.size(ba1) - 1
        array.set(tba1, i, array.get(ba1, i))
    for i = 0 to array.size(Wa2) - 1
        array.set(tWa2, i, array.get(Wa2, i))
    for i = 0 to array.size(ba2) - 1
        array.set(tba2, i, array.get(ba2, i))

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  AGENT STEP
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hLv = array.new_float()
var array<float> vLv = array.new_float()
var array<float> aLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var float pS4 = na
var int   pAct = na
var float pVal = na

var float liveQ0 = na
var float liveQ1 = na
var float liveQ2 = na
var float liveV  = na
var int   chosen = A_FLAT
var float conviction = 0.0
var float convEma = na

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        // composite reward components
        float ddLong  = atrPast != 0 ? math.max(0.0, (close[rewardLook] - fwdLow))  / atrPast : 0.0
        float ddShort = atrPast != 0 ? math.max(0.0, (fwdHigh - close[rewardLook])) / atrPast : 0.0
        float rwd = f_reward(pAct, fwdRet, atrPast, ddLong, ddShort, volRatio[rewardLook])
        float pri = math.pow(math.abs(rwd - (na(pVal) ? 0.0 : pVal)) + 0.01, priorityExp)
        f_push(pS0, pS1, pS2, pS3, pS4, pAct, rwd, s0, s1, s2, s3, s4, pri)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int idx = f_sampleIdx(seed)
        f_trainOnce(idx)

    if bar_index % tauSync == 0
        f_syncTarget()

// ---- POLICY EVALUATION (every bar incl. realtime) ----
if inHorizon
    [q0, q1, q2, V, A0, A1, A2] = f_forwardWith(s0, s1, s2, s3, s4, Wt, bt, Wv1, bv1, Wv2, bv2, Wa1, ba1, Wa2, ba2, hLv, vLv, aLv)
    liveQ0 := q0
    liveQ1 := q1
    liveQ2 := q2
    liveV  := V

    float qmax = math.max(q0, math.max(q1, q2))
    chosen := q0 == qmax ? A_LONG : q1 == qmax ? A_SHORT : A_FLAT

    if barstate.isconfirmed
        int eseed = (bar_index * 2246822519 + seedInp) % 2147483647
        if f_rand(eseed) < epsilon
            int rseed = (bar_index * 3266489917 + 11) % 2147483647
            chosen := int(f_rand(rseed) * 3) % 3

    // conviction = blend of normalized Q-spread and advantage spread (unified multi-head signal)
    float qhi = qmax
    float qlo = math.min(q0, math.min(q1, q2))
    float qmid = (q0 + q1 + q2) - qhi - qlo
    float qSpread = (qhi - qlo) == 0 ? 0.0 : (qhi - qmid) / (qhi - qlo)
    float aHi = math.max(A0, math.max(A1, A2))
    float aLo = math.min(A0, math.min(A1, A2))
    float aMid2 = (A0 + A1 + A2) - aHi - aLo
    float aSpread = (aHi - aLo) == 0 ? 0.0 : (aHi - aMid2) / (aHi - aLo)
    conviction := 0.6 * qSpread + 0.4 * aSpread

    convEma := na(convEma) ? conviction : (conviction * (2.0 / (sigSmooth + 1)) + convEma * (1.0 - 2.0 / (sigSmooth + 1)))

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pS4 := s4
        pAct := chosen
        pVal := V

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — refined, layered, professional
// ════════════════════════════════════════════════════════════════════════════════════════════════

float convDisp = na(convEma) ? 0.0 : convEma
bool gateOk = convDisp >= sigGate
color sigCol = f_actionColor(chosen)

var int lastSig = na
bool dirChanged = chosen != lastSig
bool fireBase = inHorizon and barstate.isconfirmed and chosen != A_FLAT and gateOk
bool fire = oncePerMove ? (fireBase and dirChanged) : fireBase
bool fireLong  = fire and chosen == A_LONG
bool fireShort = fire and chosen == A_SHORT

if barstate.isconfirmed and gateOk and chosen != A_FLAT
    lastSig := chosen

// ---- Conviction Ribbon: a soft, color-graded EMA pair filled by directional conviction ----
ribFast = ta.ema(close, fastLen)
ribSlow = ta.ema(close, slowLen)
// directional tint: long-leaning teal, short-leaning coral, intensity by conviction
float tilt = na(liveQ0) ? 0.0 : (liveQ0 - liveQ1)
color ribCol = color.from_gradient(tilt, -1.0, 1.0, color.new(colShort, 70), color.new(colLong, 70))
float ribTransp = 92 - convDisp * 30   // stronger conviction → more visible ribbon
pFast = plot(showRibbon and inHorizon ? ribFast : na, "Ribbon Fast", color = color.new(ribCol, 100), display = display.none)
pSlow = plot(showRibbon and inHorizon ? ribSlow : na, "Ribbon Slow", color = color.new(ribCol, 100), display = display.none)
fill(pFast, pSlow, color = showRibbon and inHorizon ? color.new(ribCol, int(math.max(60, math.min(96, ribTransp)))) : na, title = "Conviction Ribbon")

// ---- Layered glow arrows ----
// We render multiple stacked plotshapes per signal: a wide faint halo, a mid glow, and a crisp core.
// Each layer is const-styled and gated by the arrow style choice.
bool styleGlow  = arrowStyle == "Layered Glow"
bool styleMin   = arrowStyle == "Minimal"
bool styleLabel = arrowStyle == "Labeled"

// halo (large, very faint)
plotshape(fireLong and styleGlow,  title = "Long Halo",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 80),  size = size.large,  force_overlay = true)
plotshape(fireShort and styleGlow, title = "Short Halo", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 80), size = size.large,  force_overlay = true)
// mid glow
plotshape(fireLong and styleGlow,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 55),  size = size.normal, force_overlay = true)
plotshape(fireShort and styleGlow, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 55), size = size.normal, force_overlay = true)
// crisp core
plotshape(fireLong and styleGlow,  title = "Long Core",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),   size = size.small,  force_overlay = true)
plotshape(fireShort and styleGlow, title = "Short Core", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0),  size = size.small,  force_overlay = true)

// minimal style: single clean triangle
plotshape(fireLong and styleMin,  title = "Long Min",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small, force_overlay = true)
plotshape(fireShort and styleMin, title = "Short Min", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small, force_overlay = true)

// labeled style: arrow with conviction tag
if styleLabel and (fireLong or fireShort)
    color lc = fireLong ? colLong : colShort
    label.new(bar_index, fireLong ? low : high,
         (fireLong ? "▲ " : "▼ ") + str.tostring(math.round(convDisp * 100)) + "%",
         xloc = xloc.bar_index,
         yloc = fireLong ? yloc.belowbar : yloc.abovebar,
         style = fireLong ? label.style_label_up : label.style_label_down,
         color = color.new(lc, 12), textcolor = #0a0d15, size = size.small,
         force_overlay = true)

// ---- soft pulse marker at the signal bar (directional, bar-relative) ----
plotshape(showPulse and fireLong,  title = "Long Pulse",  style = shape.circle, location = location.belowbar,
     color = color.new(colLong, 35), size = size.tiny, force_overlay = true)
plotshape(showPulse and fireShort, title = "Short Pulse", style = shape.circle, location = location.abovebar,
     color = color.new(colShort, 35), size = size.tiny, force_overlay = true)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL  — premium, sectioned
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

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 12, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    float qa = na(liveQ0) ? 0.0 : liveQ0
    float qb = na(liveQ1) ? 0.0 : liveQ1
    float qc = na(liveQ2) ? 0.0 : liveQ2
    float qMin = math.min(qa, math.min(qb, qc))
    float qMax = math.max(qa, math.max(qb, qc))
    float rng  = (qMax - qMin) == 0 ? 1.0 : (qMax - qMin)

    // header
    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "RAINBOW", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    // unified verdict band
    table.cell(panel, 0, 1, "  " + f_actionName(chosen), text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(sigCol, gateOk ? 0 : 50))
    table.cell(panel, 1, 1, "", bgcolor = color.new(sigCol, gateOk ? 0 : 50))
    table.cell(panel, 2, 1, (gateOk ? "● SIGNAL  " : "○ watch  "), text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(sigCol, gateOk ? 0 : 50))

    table.cell(panel, 0, 2, "Q-VALUES", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 2, 2, 2)

    table.cell(panel, 0, 3, "LONG",  text_color = colLong,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar((qa - qMin) / rng), text_color = colLong, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(qa, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "SHORT", text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_bar((qb - qMin) / rng), text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 4, str.tostring(qb, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "FLAT",  text_color = colFlat,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 5, f_bar((qc - qMin) / rng), text_color = colFlat, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 5, str.tostring(qc, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 6, "Conviction", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, f_bar(convDisp), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 6, str.tostring(math.round(convDisp * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "State Value V(s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, "", text_size = f_panelSize())
    table.cell(panel, 2, 7, str.tostring(na(liveV) ? 0.0 : liveV, "#.###"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "COMPONENTS", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 8, 2, 8)

    table.cell(panel, 0, 9, "Double · Dueling · PER", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, "", text_size = f_panelSize())
    table.cell(panel, 2, 9, "✓✓✓", text_color = colLong, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Reward Heads", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, "", text_size = f_panelSize())
    table.cell(panel, 2, 10, "Ret+DD+Vol", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 11, "Replay / Sync", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 11, str.tostring(array.size(bAct)) + "/" + str.tostring(bufferCap), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 11, "τ" + str.tostring(tauSync), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

alertcondition(fireLong,  "Rainbow ▸ LONG",  "AetherEdge RainbowDQN: unified LONG signal.")
alertcondition(fireShort, "Rainbow ▸ SHORT", "AetherEdge RainbowDQN: unified SHORT signal.")
````
