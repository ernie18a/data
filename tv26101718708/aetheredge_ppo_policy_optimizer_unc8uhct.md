# AetherEdge - PPO Policy Optimizer

- url: https://www.tradingview.com/script/unc8uhcT/
- type: indicator
- pine_id: PUB;0bb3fb57cd634ab0ba7cb2a3e89a5290
- version: 1.0

## Description

🖊️ Overview

A self-evolving policy-gradient agent built on Proximal Policy Optimization (PPO) that optimizes its trading policy itself. A NeuraLib policy network outputs a softmax probability distribution over LONG / SHORT / FLAT, improved through a PPO-style clipped objective — the probability ratio between the new and old policy is clipped to [1−ε, 1+ε], so a single update can never shove the policy too far, the key to PPO's stability. Updates are driven by a virtual advantage estimate (GAE-style) computed against a learned value baseline. Learning from experience on your chart, it visualizes its evolving conviction with a policy-probability line (LONG %) and a trend line that recolors with the policy's tilt.

🔶 Key Features

PPO clipping — the probability ratio is clipped to [1−ε, 1+ε], structurally preventing oversized policy updates (the heart of PPO stability)
Actor-Critic architecture — a shared trunk forks into an Actor head (softmax policy) and a Critic head (value baseline)
Virtual advantage (GAE-style) — forward-return-minus-baseline smoothed over time for a low-bias, low-variance advantage signal
Entropy bonus — prevents premature collapse to a single action, encouraging exploration
Multi-epoch optimization — each collected minibatch is reused several times per bar (PPO's data efficiency)
Policy LONG % line — the policy's LONG probability plotted 0–100 (best on its own scale)
Color-shifting trend line — nudged up/down by policy tilt, recolored by dominant action and confidence
Intelligence panel — per-action probabilities, dominant action, value baseline, policy entropy, and rollout state at a glance

🧠 Technical Architecture

The agent perceives the market as a four-dimensional state vector: momentum spread (ATR-normalized fast/slow EMA gap), RSI deviation, a volatility-regime ratio, and position-within-range — all z-normalized. This state passes through a NeuraLib-style Actor-Critic network: a shared trunk (tanh hidden) forks into an Actor head producing three logits → softmax policy π(a|s), and a Critic head producing a scalar value V(s).
The virtual advantage follows GAE (Generalized Advantage Estimation). Iterating backward through the rollout, the TD residual δ = r + γV(s′) − V(s) is smoothed by γλ into Â = δ + γλ·Â_next, then normalized to zero mean and unit variance (standard PPO practice).
The heart of the PPO update is the clipped objective. With the ratio r(θ) = π_new(a|s)/π_old(a|s), the objective is min(r·Â, clip(r, 1−ε, 1+ε)·Â). Outside the trust region — advantage positive with r above 1+ε, or negative with r below 1−ε — the gradient is zeroed, structurally bounding each update step. This combines with the policy gradient ∂logπ(a)/∂logit = 𝟙[a] − p, an entropy bonus, and the Critic's squared-error value regression (weighted by vfCoef), all backpropagated manually into the shared trunk. The collected rollout is re-optimized over several epochs and minibatches.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, Clip ε 0.2, GAE λ 0.95, γ 0.94, Epochs 3, Hidden 8. Standard PPO settings fit well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8 to capture slightly longer advantage
SOL (15m–1H): High volatility favors Clip ε 0.15–0.2 (more conservative updates), Entropy ≈ 0.02 to strengthen exploration, ATR-normalization always ON
XRP (1H–4H): Spike-prone; GAE λ ≈ 0.9 to curb variance, Value Loss Weight 0.5–0.7 for baseline accuracy
Clip ε: smaller (0.1–0.15) is more conservative and stable; larger (0.25–0.3) learns faster but less stably — match to market stability
Learning Rate α: 0.02–0.04 is the stable zone; lower it if diverging, raise Epochs if convergence is slow
Entropy Bonus: raise to 0.02–0.05 if the policy biases too early to one side

💡 How to Use in Practice

Reacting to the LONG % line: 50% is neutral. A cross above 60% is a clearly bullish policy; below 40% is bearish. Drag it to its own scale to watch threshold breaks
Using the color-shifting trend line: when the line turns the LONG color and sits above price, it acts as a bullish-bias support line; the SHORT color makes it a bearish-bias resistance line
Policy tilt (flips): the moment the dominant action flips LONG↔SHORT, the trend line's color change is your directional-shift signal
Reading entropy: low panel entropy = the policy is confident; high = undecided. Low entropy plus a strong probability line marks the highest-confidence conditions
Multi-timeframe usage: confirm the big-picture policy bias on the higher timeframe (4H), then refine timing on aligned lower-timeframe (15m–1H) LONG %
Combinations: use divergence between price and the LONG % line as an early reversal warning

⚠️ Important Notes

Initial learning period: right after launch the rollout is nearly empty and both policy and value are unstable; treat signals as low-confidence until it fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the network weights and rollout, restarting learning from zero
On-policy nature: PPO is on-policy, so actions are sampled stochastically from the policy; selection can vary even in similar conditions — this is normal exploration
On forward-looking reward: rewards and advantages use closed-bar forward returns (a standard RL training construct); current-bar policy evaluation is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Proximal Policy Optimization, policy network, virtual advantage computation, reward shaping, and probability outputs are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - PPO Policy Optimizer
//   AI Drawing Power Series
//
//   A self-evolving policy-gradient agent built on Proximal Policy Optimization. A NeuraLib policy
//   network outputs a probability distribution over actions (LONG / SHORT / FLAT) via softmax. The
//   agent improves that policy with a PPO-style clipped surrogate objective: the probability ratio
//   between the new and old policy is clipped to [1−ε, 1+ε], so a single update can never shove the
//   policy too far — the key to PPO's renowned training stability. Updates are driven by a virtual
//   advantage estimate (GAE-style) computed from realized forward returns against a learned baseline.
//
//   Visualization: a policy-probability line (LONG %) plus a color-shifting trend line that recolors
//   as the agent's policy tilts bullish, bearish, or neutral.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - PPO Policy Optimizer", "AE-PPO PO", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT  = "◆  PPO AGENT"
var string GRP_STATE  = "◆  STATE ENCODER"
var string GRP_NET    = "◆  POLICY NETWORK (NeuraLib)"
var string GRP_PPO    = "◆  PPO CLIPPING & ADVANTAGE"
var string GRP_REWARD = "◆  REWARD SHAPING"
var string GRP_LINE   = "◆  ADAPTIVE TREND LINE"
var string GRP_STYLE  = "◆  AESTHETICS"
var string GRP_PANEL  = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen      = input.int(600,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
gamma         = input.float(0.94,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
entropyCoef   = input.float(0.01,"Entropy Bonus",          minval = 0.0, maxval = 0.2, step = 0.005, group = GRP_AGENT, tooltip = "Encourages exploration by rewarding policy entropy — prevents premature collapse to a single action.")

// — State Encoder —
fastLen       = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen       = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen        = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
normLen       = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Policy Network —
hiddenN       = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_NET)
learnRate     = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
epochs        = input.int(3,    "PPO Epochs / Bar", minval = 1, maxval = 16, group = GRP_NET, tooltip = "How many times each collected minibatch is re-optimized per bar (PPO reuses data over several epochs).")
batchN        = input.int(8,    "Minibatch Size", minval = 2, maxval = 64, group = GRP_NET)
seedInp       = input.int(17,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — PPO Clipping & Advantage —
clipEps       = input.float(0.2, "Clip ε",          minval = 0.05, maxval = 0.5, step = 0.01, group = GRP_PPO, tooltip = "PPO clip range. The probability ratio is constrained to [1−ε, 1+ε]. 0.1–0.3 is typical.")
lambdaGae     = input.float(0.95,"GAE λ",           minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_PPO, tooltip = "Generalized Advantage Estimation smoothing. Trades bias vs. variance in the advantage signal.")
vfCoef        = input.float(0.5, "Value Loss Weight", minval = 0.0, maxval = 2.0, step = 0.1, group = GRP_PPO, tooltip = "Weight of the value-baseline regression that powers advantage estimation.")
bufferCap     = input.int(120,  "Rollout Capacity", minval = 16, maxval = 500, group = GRP_PPO, tooltip = "Length of the on-policy rollout buffer collected before updates.")

// — Reward —
rewardLook    = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
riskNorm      = input.bool(true,"ATR-Normalize Reward",    group = GRP_REWARD)
flatPenalty   = input.float(0.05,"Flat Opportunity Cost",  minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_REWARD)

// — Adaptive Trend Line —
trendLen      = input.int(20,   "Trend Line Length", minval = 2, maxval = 200, group = GRP_LINE, tooltip = "Base EMA length for the color-shifting trend line.")
biasPull      = input.float(0.4, "Policy Bias Pull",  minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_LINE, tooltip = "How strongly the LONG/SHORT policy tilt nudges the trend line up or down (in ATR units).")

// — Aesthetics —
colLong       = input.color(#26d0a8, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort      = input.color(#ff5c7c, "Short Tone", group = GRP_STYLE, inline = "c1")
colFlat       = input.color(#6b7689, "Flat Tone",  group = GRP_STYLE, inline = "c1")
probLineCol   = input.color(#5ce1ff, "Long % Line", group = GRP_STYLE)
showProbPane  = input.bool(true, "Plot LONG % Line (separate scale)", group = GRP_STYLE, tooltip = "Plots the policy's LONG probability as a 0–100 line. Best viewed by dragging it to its own scale.")
trendWidth    = input.int(3,    "Trend Line Width", minval = 1, maxval = 6, group = GRP_STYLE)
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

// numerically-stable softmax over 3 logits → probabilities
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
//  Shared hidden trunk (tanh). Actor head → 3 logits → softmax policy. Critic head → scalar value.
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> W1 = na   // trunk [hiddenN x N_IN]
var array<float> b1 = na   // [hiddenN]
var array<float> Wp = na   // actor [N_OUT x hiddenN]
var array<float> bp = na   // [N_OUT]
var array<float> Wv = na   // critic [1 x hiddenN]
var array<float> bv = na   // [1]
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(hiddenN * N_IN, 0.0)
    b1 := array.new_float(hiddenN, 0.0)
    Wp := array.new_float(N_OUT * hiddenN, 0.0)
    bp := array.new_float(N_OUT, 0.0)
    Wv := array.new_float(hiddenN, 0.0)
    bv := array.new_float(1, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.7)
    f_initRange(Wp, seedInp * 40503 + 101, 0.7)
    f_initRange(Wv, seedInp * 92821 + 202, 0.7)
    netInit := true

// Forward pass → [p0, p1, p2, value, logit0, logit1, logit2]; caches hidden activations.
f_forward(float i0, float i1, float i2, float i3, array<float> hCache) =>
    array.clear(hCache)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_IN + 0) * i0
        z += array.get(W1, h * N_IN + 1) * i1
        z += array.get(W1, h * N_IN + 2) * i2
        z += array.get(W1, h * N_IN + 3) * i3
        array.push(hCache, f_tanh(z))
    float l0 = array.get(bp, 0)
    float l1 = array.get(bp, 1)
    float l2 = array.get(bp, 2)
    float val = array.get(bv, 0)
    for h = 0 to hiddenN - 1
        float hv = array.get(hCache, h)
        l0 += array.get(Wp, 0 * hiddenN + h) * hv
        l1 += array.get(Wp, 1 * hiddenN + h) * hv
        l2 += array.get(Wp, 2 * hiddenN + h) * hv
        val += array.get(Wv, h) * hv
    [p0, p1, p2] = f_softmax3(l0, l1, l2)
    [p0, p1, p2, val, l0, l1, l2]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ON-POLICY ROLLOUT BUFFER
//  Stores state, taken action, old policy prob of that action, reward, value estimate, advantage.
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<int>   bAct = array.new_int()
var array<float> bOldP = array.new_float()   // π_old(a|s)
var array<float> bRew = array.new_float()
var array<float> bVal = array.new_float()
var array<float> bAdv = array.new_float()
var array<float> bRet = array.new_float()     // value target (advantage + value)

f_pushRollout(float ps0, float ps1, float ps2, float ps3, int a, float oldp, float rew, float val) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bAct, a)
    array.push(bOldP, oldp)
    array.push(bRew, rew)
    array.push(bVal, val)
    array.push(bAdv, 0.0)
    array.push(bRet, 0.0)
    if array.size(bAct) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bAct)
        array.shift(bOldP)
        array.shift(bRew)
        array.shift(bVal)
        array.shift(bAdv)
        array.shift(bRet)

// Compute GAE-style advantages over the rollout (virtual advantage calculation).
f_computeAdvantages() =>
    int n = array.size(bAct)
    if n > 1
        float gae = 0.0
        // iterate backward through the rollout
        for i = n - 1 to 0
            float vNext = i == n - 1 ? array.get(bVal, i) : array.get(bVal, i + 1)
            float delta = array.get(bRew, i) + gamma * vNext - array.get(bVal, i)
            gae := delta + gamma * lambdaGae * gae
            array.set(bAdv, i, gae)
            array.set(bRet, i, gae + array.get(bVal, i))
        // normalize advantages (standard PPO practice)
        float mean = array.avg(bAdv)
        float sd = array.stdev(bAdv)
        if sd > 0
            for i = 0 to n - 1
                array.set(bAdv, i, (array.get(bAdv, i) - mean) / sd)

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
//  PPO UPDATE  — clipped surrogate objective + value regression + entropy bonus
//  Loss = -min(r·A, clip(r,1±ε)·A)  +  vfCoef·(V−Ret)²  −  entropyCoef·H(π)
//  Implemented via manual policy-gradient on the actor logits and MSE on the critic.
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hUp = array.new_float()

f_ppoUpdateOne(int idx) =>
    if array.size(bAct) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        int   a   = array.get(bAct, idx)
        float oldP = array.get(bOldP, idx)
        float adv = array.get(bAdv, idx)
        float ret = array.get(bRet, idx)

        [p0, p1, p2, val, l0, l1, l2] = f_forward(ps0, ps1, ps2, ps3, hUp)
        float newP = a == A_LONG ? p0 : a == A_SHORT ? p1 : p2
        newP := math.max(newP, 1e-6)

        // PPO probability ratio and clipped surrogate
        float ratio = newP / math.max(oldP, 1e-6)
        bool clipped = (adv >= 0 and ratio > 1.0 + clipEps) or (adv < 0 and ratio < 1.0 - clipEps)
        // gradient of clipped surrogate wrt logits is zero when clipped (the PPO trust region)
        float policyScale = clipped ? 0.0 : adv

        // ----- policy-gradient on logits -----
        // dLogP(a)/dlogit_j = (j==a) - p_j ; surrogate grad ≈ policyScale * dLogP
        // we also add entropy gradient: dH/dlogit_j = -p_j*(log p_j + H)  (encourages spread)
        gLogit = array.new_float(N_OUT, 0.0)
        // entropy of current policy
        float H = -(p0 * math.log(math.max(p0,1e-6)) + p1 * math.log(math.max(p1,1e-6)) + p2 * math.log(math.max(p2,1e-6)))
        for j = 0 to N_OUT - 1
            float pj = j == 0 ? p0 : j == 1 ? p1 : p2
            float dLogP = (j == a ? 1.0 : 0.0) - pj
            // ascent on surrogate → descent on -surrogate; include entropy bonus (ascent)
            float gEnt = -pj * (math.log(math.max(pj,1e-6)) + H)
            float grad = -(policyScale * dLogP) - entropyCoef * gEnt
            array.set(gLogit, j, math.max(-5.0, math.min(5.0, grad)))

        // ----- critic gradient (value regression) -----
        float vErr = vfCoef * (val - ret)     // dMSE/dval
        vErr := math.max(-5.0, math.min(5.0, vErr))

        // ----- backprop into hidden trunk -----
        gHidden = array.new_float(hiddenN, 0.0)
        // actor head
        for j = 0 to N_OUT - 1
            float gj = array.get(gLogit, j)
            for h = 0 to hiddenN - 1
                int wi = j * hiddenN + h
                array.set(gHidden, h, array.get(gHidden, h) + gj * array.get(Wp, wi))
                array.set(Wp, wi, array.get(Wp, wi) - learnRate * gj * array.get(hUp, h))
            array.set(bp, j, array.get(bp, j) - learnRate * gj)
        // critic head
        for h = 0 to hiddenN - 1
            array.set(gHidden, h, array.get(gHidden, h) + vErr * array.get(Wv, h))
            array.set(Wv, h, array.get(Wv, h) - learnRate * vErr * array.get(hUp, h))
        array.set(bv, 0, array.get(bv, 0) - learnRate * vErr)
        // trunk
        for h = 0 to hiddenN - 1
            float dz = array.get(gHidden, h) * f_dtanh(array.get(hUp, h))
            array.set(W1, h * N_IN + 0, array.get(W1, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(W1, h * N_IN + 1, array.get(W1, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(W1, h * N_IN + 2, array.get(W1, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(W1, h * N_IN + 3, array.get(W1, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  AGENT STEP
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var int   pAct = na
var float pOldP = na
var float pVal = na

var float liveP0 = na
var float liveP1 = na
var float liveP2 = na
var float liveVal = na
var int   chosen = A_FLAT
var float policyEntropy = 0.0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    // 1) finalize the PREVIOUS step's transition with its realized reward
    if not na(pAct)
        float rwd = f_reward(pAct, fwdRet, atrPast)
        f_pushRollout(pS0, pS1, pS2, pS3, pAct, pOldP, rwd, pVal)

    // 2) recompute virtual advantages over the rollout
    f_computeAdvantages()

    // 3) PPO optimization: several epochs over sampled minibatches
    int n = array.size(bAct)
    if n > 1
        for ep = 0 to epochs - 1
            for bi = 0 to batchN - 1
                int seed = (bar_index * 7919 + ep * 104729 + bi * 1299709 + seedInp) % 2147483647
                int idx = int(f_rand(seed) * n) % n
                f_ppoUpdateOne(idx)

// ---- POLICY EVALUATION (every bar incl. realtime) ----
if inHorizon
    [p0, p1, p2, val, l0, l1, l2] = f_forward(s0, s1, s2, s3, hLv)
    liveP0 := p0
    liveP1 := p1
    liveP2 := p2
    liveVal := val

    float pmax = math.max(p0, math.max(p1, p2))
    chosen := p0 == pmax ? A_LONG : p1 == pmax ? A_SHORT : A_FLAT

    policyEntropy := -(p0 * math.log(math.max(p0,1e-6)) + p1 * math.log(math.max(p1,1e-6)) + p2 * math.log(math.max(p2,1e-6)))

    // store as previous (sample the action stochastically from the policy = on-policy)
    if barstate.isconfirmed
        int aseed = (bar_index * 2246822519 + seedInp) % 2147483647
        float u = f_rand(aseed)
        int sampled = u < p0 ? A_LONG : u < p0 + p1 ? A_SHORT : A_FLAT
        float sampledP = sampled == A_LONG ? p0 : sampled == A_SHORT ? p1 : p2
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := sampled
        pOldP := sampledP
        pVal := val

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ADAPTIVE TREND LINE  — EMA pulled by the policy's directional tilt; recolors by dominant action
// ────────────────────────────────────────────────────────────────────────────────────────────────

baseTrend = ta.ema(close, trendLen)
// policy tilt in [-1, 1]: +1 fully long, -1 fully short
float tilt = na(liveP0) ? 0.0 : (liveP0 - liveP1)
float trendLine = baseTrend + tilt * biasPull * atr

// color by dominant policy action with intensity by confidence
color trendColRaw = f_actionColor(chosen)
float conf = na(liveP0) ? 0.0 : math.max(liveP0, math.max(liveP1, liveP2))
color trendCol = color.from_gradient(conf, 0.33, 1.0, color.new(trendColRaw, 55), color.new(trendColRaw, 0))

plot(glowFx and inHorizon ? trendLine : na, "Trend Glow", color = color.new(trendColRaw, 65), linewidth = trendWidth + 4)
plot(inHorizon ? trendLine : na, "Adaptive Trend Line", color = inHorizon ? trendCol : na, linewidth = trendWidth)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  POLICY PROBABILITY LINE  (LONG %)  — plotted 0..100, ideally on its own scale
// ────────────────────────────────────────────────────────────────────────────────────────────────

float longPct = na(liveP0) ? na : liveP0 * 100.0
plot(showProbPane and inHorizon ? longPct : na, "Policy LONG %", color = color.new(probLineCol, 0), linewidth = 2, display = display.pane)
hline(50, "Neutral 50%", color = color.gray, linestyle = hline.style_dotted)

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

    table.cell(panel, 0, 0, "AETHEREDGE  ▸  PPO OPTIMIZER", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.merge_cells(panel, 0, 0, 2, 0)

    table.cell(panel, 0, 1, "POLICY π(a|s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
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

    table.cell(panel, 0, 5, "DOMINANT ACTION", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    table.cell(panel, 0, 6, f_actionName(chosen), text_color = #0b0e16, text_size = f_panelSize(), text_halign = text.align_center, bgcolor = color.new(f_actionColor(chosen), 0))
    table.merge_cells(panel, 0, 6, 2, 6)

    table.cell(panel, 0, 7, "Value Baseline V(s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, "", text_color = THEME_TXT, text_size = f_panelSize())
    table.cell(panel, 2, 7, str.tostring(na(liveVal) ? 0.0 : liveVal, "#.###"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Policy Entropy", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, f_bar(policyEntropy / 1.0986), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(policyEntropy, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Rollout / Clip ε", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, str.tostring(array.size(bAct)) + "/" + str.tostring(bufferCap), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 9, str.tostring(clipEps, "#.##"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var int lastDom = na
alertcondition(chosen == A_LONG  and lastDom != A_LONG,  "Policy ▸ LONG bias",  "AetherEdge PPO: policy tilted LONG.")
alertcondition(chosen == A_SHORT and lastDom != A_SHORT, "Policy ▸ SHORT bias", "AetherEdge PPO: policy tilted SHORT.")
alertcondition(not na(liveP0) and liveP0 >= 0.6, "LONG % ≥ 60", "AetherEdge PPO: LONG probability reached 60%.")
alertcondition(not na(liveP1) and liveP1 >= 0.6, "SHORT % ≥ 60", "AetherEdge PPO: SHORT probability reached 60%.")
if barstate.isconfirmed
    lastDom := chosen
````
