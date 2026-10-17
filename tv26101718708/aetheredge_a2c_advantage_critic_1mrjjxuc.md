# AetherEdge - A2C Advantage Critic

- url: https://www.tradingview.com/script/1mRJjXuC/
- type: indicator
- pine_id: PUB;4c0945c1618a4c16b7a2bd4881cf27a9
- version: 1.0

## Description

🖊️ Overview

A self-evolving Advantage Actor-Critic (A2C) agent that trains two neural networks in tandem: an Actor that selects actions and a Critic that estimates state value. Their interplay produces the advantage A = R + γV(s′) − V(s) — the signed "surprise" of an outcome relative to what the Critic expected — which both trains the Actor and filters the signals: arrows fire only when the advantage is decisively in favor of a direction, naturally rejecting noisy conditions. Learning from experience on your chart, it visualizes its decisions with clean arrows and a single Critic-value histogram whose intensity encodes the strength of its valuation.

🔶 Key Features

Joint Actor-Critic learning — a shared trunk forks into an Actor head (softmax policy) and a Critic head (state value V(s)), trained together
Advantage filtering — signals fire only when |advantage| clears a gate, excluding low-conviction conditions (the heart of the A2C filter)
TD-error advantage — A = R + γV(s′) − V(s) as the action-evaluation signal
Entropy bonus — prevents premature Actor collapse onto one action, encouraging exploration
Prioritized Sampling (PER) — high-advantage transitions learned preferentially
Clean directional arrows — only filtered, decisive Long/Short signals are shown
Critic value histogram — normalized state value drawn as a single column, with intensity (opacity/height) encoding valuation strength
Intelligence panel — Actor per-action probabilities, selected action with filter status, Critic value, advantage, and buffer state at a glance

🧠 Technical Architecture

The agent perceives the market as a four-dimensional state vector: momentum spread (ATR-normalized fast/slow EMA gap), RSI deviation, a volatility-regime ratio, and position-within-range — all z-normalized. This state passes through a NeuraLib-style Actor-Critic network: a shared trunk (tanh hidden) forks into two heads. The Actor head produces three logits → softmax policy π(a|s); the Critic head produces a scalar state value V(s).
The core is the advantage. For a transition (s, a, r, s′), the Critic computes the TD target R + γV(s′) and the advantage A = R + γV(s′) − V(s) — a signed measure of how much better action a was than expected. The Actor updates via the advantage-weighted policy gradient ∇ = A·(𝟙[a] − p) (raising the chosen action's probability when advantage is positive, lowering it when negative), plus an entropy bonus. The Critic regresses toward the TD target via squared error. Both gradients backpropagate manually into the shared trunk, with separate Actor and Critic learning rates (a slightly faster Critic keeps the baseline tracking the Actor).
For signal filtering, the live advantage is EMA-smoothed and arrows fire only when its magnitude clears the gate. The Critic value histogram z-normalizes the state value over a rolling window, drawing a single column colored by sign (positive greenish, negative reddish) with opacity scaled by magnitude.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, γ 0.94, Actor LR 0.03 / Critic LR 0.05, Advantage Gate 0.35, Hidden 8. Standard settings fit well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8 to value slightly longer advantage
SOL (15m–1H): High volatility favors Advantage Gate 0.4–0.5 (stricter filter), Advantage Smoothing 4–5 to curb noise, ATR-normalization always ON
XRP (1H–4H): Spike-prone; a higher Advantage Gate, Critic LR 0.05–0.07 for baseline accuracy
Advantage Gate (filter): higher (0.4–0.6) gives fewer, higher-quality signals; lower (0.2–0.3) gives more but noisier — tune to your trade frequency
Actor LR / Critic LR: keep the Critic faster than the Actor (≈1.3–1.7×) for stability; lower both if diverging
Entropy Bonus: raise to 0.02–0.05 if the Actor biases too early to one side

💡 How to Use in Practice

Reacting to filtered arrows: every arrow shown has already cleared the advantage gate — an edge confirmed beyond the Critic's expectation, a high-confidence basis for trend-following entries
Reading the Critic histogram: a large green column = the Critic strongly values the current state (upside expectation); a large red column = strong negative valuation (downside). Taller, more opaque columns mean stronger Critic conviction
Arrow + histogram alignment: a Long arrow with a strong green column, or a Short arrow with a strong red column, is the most coherent setup; stand aside when they disagree
Advantage convergence: when the panel's advantage hovers near the gate, the call is balanced; a decisive break of the gate marks the entry opportunity
Multi-timeframe usage: read the big-picture Critic valuation on the higher timeframe (4H), then refine timing on filtered arrows on the lower one (15m–1H)
Combinations: use divergence between price and the Critic histogram (price at highs but Critic valuation falling) as an early reversal warning

⚠️ Important Notes

Initial learning period: right after launch the buffer is nearly empty and both Actor and Critic are unstable; treat signals as low-confidence until it fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the network weights and buffer, restarting learning from zero
Critic normalization: the histogram is a rolling-window z-score, showing relative strength rather than an absolute level; values are unstable until the window fills
On forward-looking reward: rewards and advantage use closed-bar forward returns (a standard RL training construct); current-bar evaluation is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Advantage Actor-Critic, Actor/Critic networks, advantage computation, reward shaping, and outputs are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - A2C Advantage Critic
//   AI Drawing Power Series
//
//   A self-evolving Advantage Actor-Critic agent. Two NeuraLib networks learn in tandem: an Actor
//   that outputs an action policy (LONG / SHORT / FLAT) via softmax, and a Critic that estimates the
//   state value V(s). Their interplay produces the advantage A = R + γV(s′) − V(s) — the signed
//   "surprise" of an outcome relative to what the Critic expected — which both trains the Actor
//   (advantage-weighted policy gradient) and filters the signals: arrows are emitted only when the
//   advantage is decisively in favor of a direction.
//
//   Visualization: clean directional arrows + a single Critic-value histogram whose height/intensity
//   encodes how strongly the Critic values the current state.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - A2C Advantage Critic", "AE-A2C AC", overlay = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT  = "◆  A2C AGENT"
var string GRP_STATE  = "◆  STATE ENCODER"
var string GRP_NET    = "◆  ACTOR / CRITIC (NeuraLib)"
var string GRP_ADV    = "◆  ADVANTAGE & FILTERING"
var string GRP_REWARD = "◆  REWARD SHAPING"
var string GRP_STYLE  = "◆  AESTHETICS"
var string GRP_PANEL  = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen      = input.int(600,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
gamma         = input.float(0.94,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
entropyCoef   = input.float(0.01,"Entropy Bonus",          minval = 0.0, maxval = 0.2, step = 0.005, group = GRP_AGENT, tooltip = "Rewards policy entropy to keep the Actor exploring instead of collapsing onto one action.")
updatesBar    = input.int(4,    "Updates / Bar",           minval = 1, maxval = 32, group = GRP_AGENT, tooltip = "Number of advantage-weighted gradient updates sampled per bar.")

// — State Encoder —
fastLen       = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen       = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen        = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
normLen       = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Actor / Critic —
hiddenN       = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_NET, tooltip = "Width of the shared trunk before it forks into Actor and Critic heads.")
actorLR       = input.float(0.03,"Actor Learning Rate",  minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
criticLR      = input.float(0.05,"Critic Learning Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET, tooltip = "Critic typically learns a touch faster so the value baseline keeps up with the Actor.")
bufferCap     = input.int(120,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_NET)
seedInp       = input.int(19,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Advantage & Filtering —
advGate       = input.float(0.35,"Min |Advantage| to Signal", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_ADV, tooltip = "Arrows are filtered out unless the normalized advantage magnitude clears this gate — the core A2C signal filter.")
advSmooth     = input.int(3,    "Advantage Smoothing", minval = 1, maxval = 20, group = GRP_ADV, tooltip = "EMA smoothing on the live advantage to reduce one-bar noise in the filter.")
prioritized   = input.bool(true,"Prioritized Sampling", group = GRP_ADV, tooltip = "Sample high-|advantage| transitions more often during updates.")

// — Reward —
rewardLook    = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
riskNorm      = input.bool(true,"ATR-Normalize Reward",    group = GRP_REWARD)
flatPenalty   = input.float(0.05,"Flat Opportunity Cost",  minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_REWARD)

// — Aesthetics —
colLong       = input.color(#26d0a8, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort      = input.color(#ff5c7c, "Short Tone", group = GRP_STYLE, inline = "c1")
colFlat       = input.color(#6b7689, "Flat Tone",  group = GRP_STYLE, inline = "c1")
colCritPos    = input.color(#26d0a8, "Critic + Value", group = GRP_STYLE, inline = "c2")
colCritNeg    = input.color(#ff5c7c, "Critic − Value", group = GRP_STYLE, inline = "c2")
arrowSize     = input.string("Small", "Arrow Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_STYLE)
glowFx        = input.bool(true,"Glow / Halo Effect", group = GRP_STYLE)

// — Intelligence Panel —
showPanel     = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos      = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize     = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0b0e16, 12)
var color THEME_GRID = color.new(#1c2333, 40)
var color THEME_TXT  = #c7d0e0
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff

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

f_softmax3(float a, float b, float c) =>
    float m = math.max(a, math.max(b, c))
    float ea = math.exp(a - m)
    float eb = math.exp(b - m)
    float ec = math.exp(c - m)
    float s = ea + eb + ec
    [ea / s, eb / s, ec / s]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  STATE ENCODER  — momentum, RSI deviation, volatility regime, position-in-range
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

s0 = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
s1 = rawRsi
s2 = f_znorm(rawVol, ta.sma(rawVol, normLen), ta.stdev(rawVol, normLen))
s3 = rawPos

var int N_IN  = 4
var int N_OUT = 3

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ACTOR-CRITIC NETWORK
//  Shared trunk (tanh). Actor head → 3 logits → softmax. Critic head → scalar V(s).
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> W1 = na   // trunk [hiddenN x N_IN]
var array<float> b1 = na   // [hiddenN]
var array<float> Wa = na   // actor [N_OUT x hiddenN]
var array<float> ba = na   // [N_OUT]
var array<float> Wc = na   // critic [1 x hiddenN]
var array<float> bc = na   // [1]
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(hiddenN * N_IN, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    Wa := array.new_float(N_OUT * hiddenN, 0.0)
    ba := array.new_float(N_OUT, 0.0)
    Wc := array.new_float(hiddenN, 0.0)
    bc := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.7)
    f_initRange(Wa, seedInp * 40503 + 101, 0.7)
    f_initRange(Wc, seedInp * 92821 + 202, 0.7)
    netInit := true

// Forward → [p0, p1, p2, value]; caches hidden activations.
f_forward(float i0, float i1, float i2, float i3, array<float> hCache) =>
    array.clear(hCache)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_IN + 0) * i0
        z += array.get(W1, h * N_IN + 1) * i1
        z += array.get(W1, h * N_IN + 2) * i2
        z += array.get(W1, h * N_IN + 3) * i3
        array.push(hCache, f_tanh(z))
    float l0 = array.get(ba, 0)
    float l1 = array.get(ba, 1)
    float l2 = array.get(ba, 2)
    float val = array.get(bc, 0)
    for h = 0 to hiddenN - 1
        float hv = array.get(hCache, h)
        l0 += array.get(Wa, 0 * hiddenN + h) * hv
        l1 += array.get(Wa, 1 * hiddenN + h) * hv
        l2 += array.get(Wa, 2 * hiddenN + h) * hv
        val += array.get(Wc, h) * hv
    [p0, p1, p2] = f_softmax3(l0, l1, l2)
    [p0, p1, p2, val]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  REPLAY BUFFER  (state, action, reward, next-state)
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<int>   bAct = array.new_int()
var array<float> bRew = array.new_float()
var array<float> bN0 = array.new_float()
var array<float> bN1 = array.new_float()
var array<float> bN2 = array.new_float()
var array<float> bN3 = array.new_float()
var array<float> bPri = array.new_float()

f_push(float ps0, float ps1, float ps2, float ps3, int a, float r, float n0, float n1, float n2, float n3, float pri) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bAct, a)
    array.push(bRew, r)
    array.push(bN0, n0)
    array.push(bN1, n1)
    array.push(bN2, n2)
    array.push(bN3, n3)
    array.push(bPri, pri)
    if array.size(bAct) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bAct)
        array.shift(bRew)
        array.shift(bN0)
        array.shift(bN1)
        array.shift(bN2)
        array.shift(bN3)
        array.shift(bPri)

f_sampleIdx(int rngSeed) =>
    int n = array.size(bAct)
    int idx = 0
    if n > 0
        if prioritized
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
        else
            idx := int(f_rand(rngSeed) * n) % n
    idx

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  REWARD  — directional forward return, ATR-normalized
// ────────────────────────────────────────────────────────────────────────────────────────────────

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]

f_reward(int a, float ret, float atrRef) =>
    float baseRet = riskNorm and atrRef != 0 ? (ret * close[rewardLook]) / atrRef : ret
    float r = a == A_LONG ? baseRet : a == A_SHORT ? -baseRet : -flatPenalty * math.abs(baseRet)
    math.max(-5.0, math.min(5.0, r))

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  A2C UPDATE STEP  — Actor (advantage-weighted policy gradient) + Critic (TD value regression)
//  advantage = R + γ·V(s′) − V(s)   trained jointly through the shared trunk.
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hUp = array.new_float()
var array<float> hNx = array.new_float()

f_updateOnce(int idx) =>
    if array.size(bAct) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        int   a   = array.get(bAct, idx)
        float r   = array.get(bRew, idx)
        float nx0 = array.get(bN0, idx)
        float nx1 = array.get(bN1, idx)
        float nx2 = array.get(bN2, idx)
        float nx3 = array.get(bN3, idx)

        [p0, p1, p2, val] = f_forward(ps0, ps1, ps2, ps3, hUp)
        [np0, np1, np2, nVal] = f_forward(nx0, nx1, nx2, nx3, hNx)

        // advantage = TD error
        float tdTarget = r + gamma * nVal
        float adv = tdTarget - val
        adv := math.max(-5.0, math.min(5.0, adv))

        // entropy of current policy
        float H = -(p0 * math.log(math.max(p0,1e-6)) + p1 * math.log(math.max(p1,1e-6)) + p2 * math.log(math.max(p2,1e-6)))

        // ----- Actor: advantage-weighted policy gradient on logits -----
        // ascent on adv·logπ(a) → grad on logit_j = adv·((j==a) − p_j); plus entropy bonus
        gLogit = array.new_float(N_OUT, 0.0)
        for j = 0 to N_OUT - 1
            float pj = j == 0 ? p0 : j == 1 ? p1 : p2
            float dLogP = (j == a ? 1.0 : 0.0) - pj
            float gEnt = -pj * (math.log(math.max(pj,1e-6)) + H)
            float grad = -(adv * dLogP) - entropyCoef * gEnt   // descent form
            array.set(gLogit, j, math.max(-5.0, math.min(5.0, grad)))

        // ----- Critic: value regression toward TD target -----
        float vErr = math.max(-5.0, math.min(5.0, val - tdTarget))

        // ----- backprop into shared trunk (Actor + Critic both feed it) -----
        gHidden = array.new_float(hiddenN, 0.0)
        // actor head (uses actorLR)
        for j = 0 to N_OUT - 1
            float gj = array.get(gLogit, j)
            for h = 0 to hiddenN - 1
                int wi = j * hiddenN + h
                array.set(gHidden, h, array.get(gHidden, h) + gj * array.get(Wa, wi))
                array.set(Wa, wi, array.get(Wa, wi) - actorLR * gj * array.get(hUp, h))
            array.set(ba, j, array.get(ba, j) - actorLR * gj)
        // critic head (uses criticLR)
        for h = 0 to hiddenN - 1
            array.set(gHidden, h, array.get(gHidden, h) + vErr * array.get(Wc, h))
            array.set(Wc, h, array.get(Wc, h) - criticLR * vErr * array.get(hUp, h))
        array.set(bc, 0, array.get(bc, 0) - criticLR * vErr)
        // shared trunk (average-ish LR via actorLR)
        for h = 0 to hiddenN - 1
            float dz = array.get(gHidden, h) * f_dtanh(array.get(hUp, h))
            array.set(W1, h * N_IN + 0, array.get(W1, h * N_IN + 0) - actorLR * dz * ps0)
            array.set(W1, h * N_IN + 1, array.get(W1, h * N_IN + 1) - actorLR * dz * ps1)
            array.set(W1, h * N_IN + 2, array.get(W1, h * N_IN + 2) - actorLR * dz * ps2)
            array.set(W1, h * N_IN + 3, array.get(W1, h * N_IN + 3) - actorLR * dz * ps3)
            array.set(b1, h, array.get(b1, h) - actorLR * dz)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  AGENT STEP
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hLv = array.new_float()
var array<float> hPrev = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var int   pAct = na
var float pVal = na

var float liveP0 = na
var float liveP1 = na
var float liveP2 = na
var float liveVal = na
var int   chosen = A_FLAT
var float liveAdv = na
var float advEma = na

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        float rwd = f_reward(pAct, fwdRet, atrPast)
        // priority = |realized advantage proxy| = |reward - prior value estimate|
        float pri = math.pow(math.abs(rwd - (na(pVal) ? 0.0 : pVal)) + 0.01, 1.5)
        f_push(pS0, pS1, pS2, pS3, pAct, rwd, s0, s1, s2, s3, pri)

    for stp = 0 to updatesBar - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int idx = f_sampleIdx(seed)
        f_updateOnce(idx)

// ---- POLICY EVALUATION (every bar incl. realtime) ----
if inHorizon
    [p0, p1, p2, val] = f_forward(s0, s1, s2, s3, hLv)
    liveP0 := p0
    liveP1 := p1
    liveP2 := p2
    liveVal := val

    float pmax = math.max(p0, math.max(p1, p2))
    chosen := p0 == pmax ? A_LONG : p1 == pmax ? A_SHORT : A_FLAT

    // live advantage estimate for the chosen action vs. the Critic baseline
    // proxy next-value via one-step persistence of current value (bounded)
    float estReward = chosen == A_LONG ? p0 : chosen == A_SHORT ? -p1 : 0.0
    liveAdv := (estReward + gamma * val) - val
    advEma := na(advEma) ? liveAdv : (liveAdv * (2.0 / (advSmooth + 1)) + advEma * (1.0 - 2.0 / (advSmooth + 1)))

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := chosen
        pVal := val

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ADVANTAGE-FILTERED SIGNALS  — clean arrows only when |advantage| clears the gate
// ────────────────────────────────────────────────────────────────────────────────────────────────

float advMag = na(advEma) ? 0.0 : math.abs(advEma)
bool advOk = advMag >= advGate

var int lastSig = na
bool longSig  = inHorizon and barstate.isconfirmed and chosen == A_LONG  and advOk and lastSig != A_LONG
bool shortSig = inHorizon and barstate.isconfirmed and chosen == A_SHORT and advOk and lastSig != A_SHORT

// plotshape's size argument must be a const — so we branch per selected size,
// each call passing a constant size.* and gated by the arrowSize input.
bool szTiny   = arrowSize == "Tiny"
bool szSmall  = arrowSize == "Small"
bool szNormal = arrowSize == "Normal"
bool szLarge  = arrowSize == "Large"

plotshape(longSig and szTiny,   title = "Long ▪",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.tiny,   text = "▲", force_overlay = true)
plotshape(longSig and szSmall,  title = "Long ▫",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small,  text = "▲", force_overlay = true)
plotshape(longSig and szNormal, title = "Long ▭",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.normal, text = "▲", force_overlay = true)
plotshape(longSig and szLarge,  title = "Long ▮",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.large,  text = "▲", force_overlay = true)

plotshape(shortSig and szTiny,   title = "Short ▪", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.tiny,   text = "▼", force_overlay = true)
plotshape(shortSig and szSmall,  title = "Short ▫", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small,  text = "▼", force_overlay = true)
plotshape(shortSig and szNormal, title = "Short ▭", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.normal, text = "▼", force_overlay = true)
plotshape(shortSig and szLarge,  title = "Short ▮", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.large,  text = "▼", force_overlay = true)

if barstate.isconfirmed and advOk and chosen != A_FLAT
    lastSig := chosen

// glow accent on strong-advantage bars
plot(glowFx and inHorizon and advMag > advGate * 1.5 ? close : na, "Advantage Glow", color = color.new(f_actionColor(chosen), 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  CRITIC VALUE HISTOGRAM  (single column, intensity by magnitude) — plotted in a pane
// ────────────────────────────────────────────────────────────────────────────────────────────────

// normalize the Critic value to a stable display range using a rolling window.
// nz() makes the series continuous (the var liveVal is na outside the horizon / before first eval).
float critRaw = nz(liveVal, 0.0)
critMean = ta.sma(critRaw, 50)
critStd  = ta.stdev(critRaw, 50)
float critZ = na(critStd) or critStd == 0 ? 0.0 : (critRaw - critMean) / critStd
critZ := math.max(-3.0, math.min(3.0, critZ))

// color + intensity: positive value greenish, negative reddish; opacity scales with magnitude
float critMag = math.min(1.0, math.abs(critZ) / 3.0)
color critColBase = critZ >= 0 ? colCritPos : colCritNeg
color critCol = color.new(critColBase, int(85 - critMag * 70))   // stronger value → more opaque

plot(inHorizon ? critZ : na, "Critic Value V(s)", color = critCol, style = plot.style_columns, linewidth = 2)
hline(0, "Critic Zero", color = color.gray, linestyle = hline.style_dotted)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INTELLIGENCE PANEL
// ────────────────────────────────────────────────────────────────────────────────────────────────

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
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * 10))
    string s = ""
    for i = 1 to 10
        s := s + (i <= filled ? "█" : "░")
    s

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 10, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    float pp0 = na(liveP0) ? 0.0 : liveP0
    float pp1 = na(liveP1) ? 0.0 : liveP1
    float pp2 = na(liveP2) ? 0.0 : liveP2

    table.cell(panel, 0, 0, "AETHEREDGE  ▸  A2C CRITIC", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.merge_cells(panel, 0, 0, 2, 0)

    table.cell(panel, 0, 1, "ACTOR POLICY π(a|s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "LONG",  text_color = colLong,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_bar(pp0), text_color = colLong, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(math.round(pp0 * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "SHORT", text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar(pp1), text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(math.round(pp1 * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "FLAT",  text_color = colFlat,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_bar(pp2), text_color = colFlat, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 4, str.tostring(math.round(pp2 * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "SELECTED ACTION", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    table.cell(panel, 0, 6, f_actionName(chosen) + (advOk ? "  ✓" : "  ·"), text_color = #0b0e16, text_size = f_panelSize(), text_halign = text.align_center, bgcolor = color.new(f_actionColor(chosen), advOk ? 0 : 45))
    table.merge_cells(panel, 0, 6, 2, 6)

    table.cell(panel, 0, 7, "Critic V(s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, "", text_color = THEME_TXT, text_size = f_panelSize())
    table.cell(panel, 2, 7, str.tostring(na(liveVal) ? 0.0 : liveVal, "#.###"), text_color = critZ >= 0 ? colCritPos : colCritNeg, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Advantage (filter)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, f_bar(advMag / math.max(advGate * 2.0, 0.01)), text_color = advOk ? THEME_ACC : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(na(advEma) ? 0.0 : advEma, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Replay Buffer", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, str.tostring(array.size(bAct)) + "/" + str.tostring(bufferCap), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 9, prioritized ? "PER" : "UNIF", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

alertcondition(longSig,  "A2C ▸ LONG (advantage-filtered)",  "AetherEdge A2C: advantage-filtered LONG signal.")
alertcondition(shortSig, "A2C ▸ SHORT (advantage-filtered)", "AetherEdge A2C: advantage-filtered SHORT signal.")
````
