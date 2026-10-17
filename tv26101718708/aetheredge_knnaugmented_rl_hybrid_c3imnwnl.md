# AetherEdge - KNN-Augmented RL Hybrid

- url: https://www.tradingview.com/script/c3iMNWNl/
- type: indicator
- pine_id: PUB;8dd002e11aab4e0a85b6da64fcd6021e
- version: 1.0

## Description

🖊️ Overview

A self-evolving hybrid that fuses episodic memory with a learned value network. Each bar's state and its realized outcome are stored in an experience memory bank; to value the present, the agent runs a k-Nearest-Neighbors search over that bank — retrieving the most similar historical states and distance-weighting their outcomes — then blends that memory estimate with a NeuraLib NN/Q estimate. The fusion combines the generalization of gradient learning with the instant recall of episodic memory. A reward-driven update adapts the per-feature similarity weights, so the agent learns which dimensions of "similarity" actually matter for prediction. Visualization: auto breakout-zone boxes where high-similarity memory predicts a decisive move, plus directional arrows on the fused signal.

🔶 Key Features

kNN×RL hybrid — episodic-memory kNN retrieval fused with a NeuraLib value network
Episodic memory augmentation — instant distance-weighted recall of similar past outcomes
Memory ↔ network blend — continuously adjustable from pure memory (kNN) to pure network (NN/Q)
Reward-driven similarity-weight learning — learns which feature dimensions define "similar"
High-similarity breakout zones — zones spawn only when memory retrieval is confident; opacity tracks similarity
Fused signal arrows — the integrated kNN+NN verdict shown as directional arrows (with glow)
Exploration vs. exploitation — ε-greedy exploration
Premium panel — NN-vs-kNN breakdown, fused value, memory similarity, conviction, similarity weights, memory/zone counts

🧠 Technical Architecture

The agent perceives the market as a four-dimensional state vector (momentum spread, RSI deviation, a volatility-regime ratio, position-within-range — all z-normalized). The architecture fuses two value-estimation paths.
Episodic memory (kNN) path: each bar stores state, action taken, and realized value (reward) in a memory bank. To value the present, a weighted Euclidean distance — using adaptive per-feature weights — is computed against all memories, and the k nearest are retrieved. Each neighbor's distance is turned into similarity via a Gaussian-style kernel sim = exp(−sharpness × distance), and a per-action similarity-weighted average yields the kNN memory value.
Value network (NeuraLib) path: a single hidden-layer (tanh) network maps state to per-action Q-values, trained by a DQN-style update.
Fusion: per direction, fused = (1−blend)·Q_network + blend·Q_knn, and the action with the largest fused value is selected. The signature element is similarity-weight adaptation: on each reward, weights of feature dimensions consistent with the profitable outcome are raised and irrelevant ones lowered (w ← clip(w + lr·(|feature|·|reward| − baseline))). The very definition of "similar" thus evolves from reward. Zone spawning fires only when both memory similarity and conviction clear their gates, with box opacity tracking similarity.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, Neighbors k 6, Memory Depth 300, Blend 0.5, γ 0.93. A 50/50 memory-network fusion as standard
ETH (1H–4H): As BTC, with Reward Lookahead 5–8
SOL (15m–1H): High volatility favors Similarity Sharpness 2.5–3.0 to weight only close neighbors, Min Similarity 0.7 to be selective on zones
XRP (1H–4H): Spike-prone; Blend ≈ 0.6 to lean on memory (recalling past sharp moves), k ≈ 8
Memory ↔ Network Blend: toward 0 favors generalization (robust to novel states); toward 1 favors memory (replays known patterns) — tune to market repetitiveness
Neighbors (k): small (3–5) is sharp but noisy; large (8–15) is smooth but less responsive
Similarity Weight LR: higher adapts feature weights faster but less stably; 0.01–0.03 is the stable zone
Memory Bank Depth: deeper retains more diverse memory but mixes in older regimes — balance against Training Horizon

💡 How to Use in Practice

Reacting to fused arrows: an arrow means both kNN memory and NN value back the direction and conviction cleared the gate — the integrated verdict, a core basis for trend-following entries
Using high-similarity zones: zones mark areas where memory shows a decisive move occurred in similar past conditions; watch breaks/bounces at zone edges
Reading memory similarity: higher panel similarity means the present closely matches a clear past pattern — higher prediction confidence; be cautious when low (novel conditions)
NN vs. kNN agreement: when both (e.g. the "NN / kNN" in the LONG row) are high together, confidence is highest; stand aside when they disagree
Watching similarity weights: the panel's Sim Weights (M·R·V·P = momentum, RSI, volatility, position) reveal which features the agent currently weights for similarity
Multi-timeframe usage: map high-similarity zones on the higher timeframe (4H), then refine timing on fused arrows on the lower one (15m–1H)
Combinations: filter for high-similarity, high-conviction arrows to focus on memory-backed, high-quality entries

⚠️ Important Notes

Initial learning period: right after launch the memory bank is nearly empty and kNN retrieval is non-functional; treat signals and zones as low-confidence until memory accumulates (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the memory bank, network weights, similarity weights, and zones, restarting learning from zero
Memory bias: the bank is built from recent states, so when the regime shifts substantially, past memory fits the present less well — low Memory Similarity is the tell
On forward-looking reward: rewards and memory values use closed-bar forward returns (a standard RL training construct); current-bar evaluation is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget; kNN search scales with memory depth × neighbors, so extreme settings affect performance

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The kNN search, value network, reward shaping, similarity-weight adaptation, breakout zones, and fused signal are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - KNN-Augmented RL Hybrid
//   AI Drawing Power Series
//
//   A self-evolving hybrid that fuses episodic memory with a learned value network. Each bar's state
//   is stored, alongside its realized outcome, in an experience memory bank. To value the present,
//   the agent runs a k-Nearest-Neighbors search over that bank — retrieving the most similar historical
//   states and distance-weighting their outcomes — then BLENDS that memory estimate with a NeuraLib
//   NN/Q estimate. The blend gives the network the generalization of gradient learning and the instant
//   recall of episodic memory. A reward-driven update adapts the per-feature similarity weights, so the
//   agent learns WHICH dimensions of "similarity" actually matter for prediction.
//
//   Visualization: auto breakout-zone boxes spawned where high-similarity memory predicts a decisive
//   move, plus directional arrows on the fused signal.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - KNN-Augmented RL Hybrid", "AE-KNN RL", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT = "◆  HYBRID AGENT"
var string GRP_STATE = "◆  STATE ENCODER"
var string GRP_KNN   = "◆  EPISODIC MEMORY (kNN)"
var string GRP_NET   = "◆  VALUE NETWORK (NeuraLib)"
var string GRP_REWARD= "◆  REWARD & SIMILARITY"
var string GRP_ZONE  = "◆  BREAKOUT ZONES"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
gamma        = input.float(0.93,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
blendKnn     = input.float(0.5, "Memory ↔ Network Blend",  minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_AGENT, tooltip = "0 = pure NeuraLib network value, 1 = pure kNN episodic memory value. The hybrid sits in between.")
epsilon      = input.float(0.05,"Exploration ε",          minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_AGENT)

// — State Encoder —
fastLen      = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen      = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen       = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Episodic Memory (kNN) —
knnK         = input.int(6,    "Neighbors (k)",  minval = 1, maxval = 30, group = GRP_KNN, tooltip = "Number of nearest historical states retrieved when valuing the present.")
memDepth     = input.int(300,  "Memory Bank Depth (bars)", minval = 30, maxval = 1500, group = GRP_KNN, tooltip = "How many recent states are retained in the episodic memory bank.")
simSharp     = input.float(2.0, "Similarity Sharpness", minval = 0.1, maxval = 8.0, step = 0.1, group = GRP_KNN, tooltip = "Higher = distance-weighting decays faster, so only very close neighbors dominate.")

// — Value Network —
hiddenN      = input.int(8,    "Hidden Units",   minval = 2, maxval = 16, group = GRP_NET)
learnRate    = input.float(0.03,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_NET)
seedInp      = input.int(31,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Reward & Similarity —
rewardLook   = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
riskNorm     = input.bool(true,"ATR-Normalize Reward",    group = GRP_REWARD)
simAdapt     = input.float(0.02,"Similarity Weight LR",   minval = 0.0, maxval = 0.5, step = 0.005, group = GRP_REWARD, tooltip = "Reward-driven learning rate for the per-feature similarity weights — the agent learns which features matter.")

// — Breakout Zones —
zoneSim      = input.float(0.50,"Min Similarity to Spawn", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_ZONE, tooltip = "A zone is drawn only when memory retrieval is this confident (avg neighbor similarity).")
zoneConv     = input.float(0.25,"Min Conviction to Spawn", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_ZONE)
zoneBuffer   = input.float(0.5, "Zone Height (ATR x)", minval = 0.1, maxval = 3.0, step = 0.05, group = GRP_ZONE)
maxBoxes     = input.int(6,    "Max Visible Zones", minval = 1, maxval = 30, group = GRP_ZONE)
boxLife      = input.int(140,  "Zone Lifespan (bars)", minval = 10, maxval = 1000, group = GRP_ZONE)

// — Aesthetics —
colLong      = input.color(#21d3a3, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Short Tone", group = GRP_STYLE, inline = "c1")
colNeutral   = input.color(#7d88a0, "Neutral Tone", group = GRP_STYLE, inline = "c1")
zoneTransp   = input.int(85,   "Zone Fill Transparency", minval = 70, maxval = 99, group = GRP_STYLE)
glowFx       = input.bool(true,"Glow / Halo Effect", group = GRP_STYLE)
showArrows   = input.bool(true,"Fused Signal Arrows", group = GRP_STYLE)

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

var int A_LONG  = 0
var int A_SHORT = 1
var int A_FLAT  = 2

f_actColor(int a) =>
    a == A_LONG ? colLong : a == A_SHORT ? colShort : colNeutral

f_actName(int a) =>
    a == A_LONG ? "LONG" : a == A_SHORT ? "SHORT" : "FLAT"

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
//  STATE ENCODER  — momentum, RSI deviation, volatility regime, range position
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

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  EPISODIC MEMORY BANK  — stores past states + realized outcome (value) per stored action
//  Parallel arrays; the kNN search runs over this bank using adaptive per-feature weights.
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> mS0 = array.new_float()
var array<float> mS1 = array.new_float()
var array<float> mS2 = array.new_float()
var array<float> mS3 = array.new_float()
var array<int>   mAct = array.new_int()      // action taken at that state
var array<float> mVal = array.new_float()    // realized discounted value (return-based)

// adaptive per-feature similarity weights (which features define "similar")
var array<float> simW = na
var bool simInit = false
if not simInit
    simW := array.new_float(N_IN, 1.0)
    simInit := true

f_pushMemory(float ps0, float ps1, float ps2, float ps3, int a, float val) =>
    array.push(mS0, ps0)
    array.push(mS1, ps1)
    array.push(mS2, ps2)
    array.push(mS3, ps3)
    array.push(mAct, a)
    array.push(mVal, val)
    if array.size(mAct) > memDepth
        array.shift(mS0)
        array.shift(mS1)
        array.shift(mS2)
        array.shift(mS3)
        array.shift(mAct)
        array.shift(mVal)

// weighted Euclidean distance between current state and memory entry i
f_dist(int i, float c0, float c1, float c2, float c3) =>
    float w0 = array.get(simW, 0)
    float w1 = array.get(simW, 1)
    float w2 = array.get(simW, 2)
    float w3 = array.get(simW, 3)
    float d0 = (c0 - array.get(mS0, i)) * w0
    float d1 = (c1 - array.get(mS1, i)) * w1
    float d2 = (c2 - array.get(mS2, i)) * w2
    float d3 = (c3 - array.get(mS3, i)) * w3
    math.sqrt(d0 * d0 + d1 * d1 + d2 * d2 + d3 * d3)

// kNN retrieval → returns [knnValueLong, knnValueShort, avgSimilarity, neighborsFound]
// per-action memory value = distance-weighted average of stored values for neighbors of that action.
f_knnValue(float c0, float c1, float c2, float c3) =>
    int n = array.size(mAct)
    float vLong = 0.0
    float vShort = 0.0
    float wLong = 0.0
    float wShort = 0.0
    float simSum = 0.0
    int found = 0
    if n >= 1
        // collect distances, then pick k smallest via repeated min-scan (k is small)
        dists = array.new_float()
        for i = 0 to n - 1
            array.push(dists, f_dist(i, c0, c1, c2, c3))
        tmp = array.copy(dists)
        int kk = math.min(knnK, n)
        for _k = 0 to kk - 1
            if array.size(tmp) > 0
                float dmin = array.min(tmp)
                int mi = array.indexof(tmp, dmin)
                // similarity from distance (Gaussian-style kernel)
                float sim = math.exp(-simSharp * dmin)
                int a = array.get(mAct, mi)
                float val = array.get(mVal, mi)
                if a == A_LONG
                    vLong += sim * val
                    wLong += sim
                else if a == A_SHORT
                    vShort += sim * val
                    wShort += sim
                simSum += sim
                found += 1
                array.set(tmp, mi, 1e18)   // exclude from next pick
    float knnLong  = wLong  > 0 ? vLong / wLong : 0.0
    float knnShort = wShort > 0 ? vShort / wShort : 0.0
    float avgSim = found > 0 ? simSum / found : 0.0
    [knnLong, knnShort, avgSim, found]

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VALUE NETWORK (NeuraLib)  — state → hidden(tanh) → Q[3]   (the gradient-learning complement)
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
    f_initRange(W1, seedInp * 2654435761,  0.7)
    f_initRange(W2, seedInp * 40503 + 101, 0.7)
    netInit := true

f_net(float i0, float i1, float i2, float i3, array<float> hC) =>
    array.clear(hC)
    for h = 0 to hiddenN - 1
        float z = array.get(b1, h)
        z += array.get(W1, h * N_IN + 0) * i0
        z += array.get(W1, h * N_IN + 1) * i1
        z += array.get(W1, h * N_IN + 2) * i2
        z += array.get(W1, h * N_IN + 3) * i3
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
//  REPLAY BUFFER  (for network training)
// ════════════════════════════════════════════════════════════════════════════════════════════════

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

f_pushBuf(float ps0, float ps1, float ps2, float ps3, int a, float r, float n0, float n1, float n2, float n3) =>
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
    if array.size(bAct) > memDepth
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

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REWARD
// ════════════════════════════════════════════════════════════════════════════════════════════════

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]

f_reward(int a, float ret, float atrRef) =>
    float baseRet = riskNorm and atrRef != 0 ? (ret * close[rewardLook]) / atrRef : ret
    float r = a == A_LONG ? baseRet : a == A_SHORT ? -baseRet : 0.0
    math.max(-5.0, math.min(5.0, r))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  NETWORK TRAINING STEP  (DQN-style, on the gradient-learning head)
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()
var array<float> hNx = array.new_float()

f_trainOnce(int idx) =>
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

        [q0, q1, q2] = f_net(ps0, ps1, ps2, ps3, hTr)
        [nq0, nq1, nq2] = f_net(nx0, nx1, nx2, nx3, hNx)
        float maxNext = math.max(nq0, math.max(nq1, nq2))
        float target  = r + gamma * maxNext
        float pred    = a == A_LONG ? q0 : a == A_SHORT ? q1 : q2
        float err     = math.max(-5.0, math.min(5.0, pred - target))

        gHidden = array.new_float(hiddenN, 0.0)
        for h = 0 to hiddenN - 1
            float hv = array.get(hTr, h)
            int wi = a * hiddenN + h
            array.set(gHidden, h, err * array.get(W2, wi))
            array.set(W2, wi, array.get(W2, wi) - learnRate * err * hv)
        array.set(b2, a, array.get(b2, a) - learnRate * err)
        for h = 0 to hiddenN - 1
            float dz = array.get(gHidden, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, h * N_IN + 0, array.get(W1, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(W1, h * N_IN + 1, array.get(W1, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(W1, h * N_IN + 2, array.get(W1, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(W1, h * N_IN + 3, array.get(W1, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(b1, h, array.get(b1, h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  BREAKOUT ZONE OBJECT MODEL
// ════════════════════════════════════════════════════════════════════════════════════════════════

type Zone
    box  bx
    int  bornBar
    bool isLong
    float sim

var array<Zone> zones = array.new<Zone>()

f_spawnZone(bool isLong, float lvl, float sim) =>
    float half = atr * zoneBuffer
    color bc = isLong ? colLong : colShort
    // stronger similarity → more opaque fill & border
    int fillT = int(math.max(70, zoneTransp - sim * 18))
    box bx = box.new(bar_index, lvl + half, bar_index + 1, lvl - half,
         xloc = xloc.bar_index,
         border_color = color.new(bc, 20),
         border_width = 1,
         bgcolor = color.new(bc, fillT),
         extend = extend.right)
    Zone z = Zone.new(bx, bar_index, isLong, sim)
    array.push(zones, z)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hLv = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var int   pAct = na

var float liveQ0 = na
var float liveQ1 = na
var float liveQ2 = na
var float liveKnnL = na
var float liveKnnS = na
var float liveSim = 0.0
var int   chosen = A_FLAT
var float conviction = 0.0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        float rwd = f_reward(pAct, fwdRet, atrPast)
        // store into BOTH the network replay buffer and the episodic memory bank
        f_pushBuf(pS0, pS1, pS2, pS3, pAct, rwd, s0, s1, s2, s3)
        f_pushMemory(pS0, pS1, pS2, pS3, pAct, rwd)

        // ---- reward-driven similarity-weight adaptation ----
        // features that were consistent with a profitable directional outcome get up-weighted.
        // signal = sign(reward) ; align each feature's contribution toward predicting it.
        float sgn = rwd > 0 ? 1.0 : rwd < 0 ? -1.0 : 0.0
        if sgn != 0
            // feature relevance proxy: |feature| correlated with |reward|
            float mag = math.min(3.0, math.abs(rwd))
            array.set(simW, 0, math.max(0.1, math.min(3.0, array.get(simW, 0) + simAdapt * (math.abs(pS0) * mag - 0.5))))
            array.set(simW, 1, math.max(0.1, math.min(3.0, array.get(simW, 1) + simAdapt * (math.abs(pS1) * mag - 0.5))))
            array.set(simW, 2, math.max(0.1, math.min(3.0, array.get(simW, 2) + simAdapt * (math.abs(pS2) * mag - 0.5))))
            array.set(simW, 3, math.max(0.1, math.min(3.0, array.get(simW, 3) + simAdapt * (math.abs(pS3) * mag - 0.5))))

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bAct)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            f_trainOnce(idx)

// ---- EVALUATION (every bar incl. realtime) — fuse kNN memory + NN value ----
if inHorizon
    [q0, q1, q2] = f_net(s0, s1, s2, s3, hLv)
    liveQ0 := q0
    liveQ1 := q1
    liveQ2 := q2

    [kL, kS, aSim, kFound] = f_knnValue(s0, s1, s2, s3)
    liveKnnL := kL
    liveKnnS := kS
    liveSim := aSim

    // FUSED value per direction: blend NN Q with kNN memory value
    float fLong  = (1.0 - blendKnn) * q0 + blendKnn * kL
    float fShort = (1.0 - blendKnn) * q1 + blendKnn * kS
    float fFlat  = (1.0 - blendKnn) * q2 + blendKnn * 0.0

    float fmax = math.max(fLong, math.max(fShort, fFlat))
    chosen := fLong == fmax ? A_LONG : fShort == fmax ? A_SHORT : A_FLAT

    if barstate.isconfirmed
        int eseed = (bar_index * 2246822519 + seedInp) % 2147483647
        if f_rand(eseed) < epsilon
            int rseed = (bar_index * 3266489917 + 11) % 2147483647
            chosen := int(f_rand(rseed) * 3) % 3

    // conviction = normalized spread of fused values
    float fhi = fmax
    float flo = math.min(fLong, math.min(fShort, fFlat))
    float fmid = (fLong + fShort + fFlat) - fhi - flo
    conviction := (fhi - flo) == 0 ? 0.0 : (fhi - fmid) / (fhi - flo)

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := chosen

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ZONE SPAWNING + LIFECYCLE  — high-similarity breakout zones
// ════════════════════════════════════════════════════════════════════════════════════════════════

var int lastSig = na
// na-safe direction-change test: treat the first valid direction as a change
bool sigChanged = na(lastSig) or chosen != lastSig
bool highSimSignal = inHorizon and barstate.isconfirmed and chosen != A_FLAT and liveSim >= zoneSim and conviction >= zoneConv

if highSimSignal and sigChanged
    bool isLong = chosen == A_LONG
    // anchor zone at the level the agent expects to break (recent extreme in trade direction)
    float lvl = isLong ? ta.highest(high, slowLen) : ta.lowest(low, slowLen)
    f_spawnZone(isLong, lvl, liveSim)

// extend + retire zones
if inHorizon and barstate.isconfirmed and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        if bar_index - z.bornBar > boxLife
            box.delete(z.bx)
            array.remove(zones, i)
        else
            box.set_right(z.bx, bar_index + 1)

while array.size(zones) > maxBoxes
    Zone z0 = array.get(zones, 0)
    box.delete(z0.bx)
    array.remove(zones, 0)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  FUSED SIGNAL ARROWS  — layered glow, fired on a high-similarity directional shift
// ════════════════════════════════════════════════════════════════════════════════════════════════

bool fire = inHorizon and barstate.isconfirmed and chosen != A_FLAT and conviction >= zoneConv and sigChanged
bool fireLong  = showArrows and fire and chosen == A_LONG
bool fireShort = showArrows and fire and chosen == A_SHORT

// commit the current direction so the next bar measures change against it
if inHorizon and barstate.isconfirmed and chosen != A_FLAT and conviction >= zoneConv
    lastSig := chosen

// halo + core
plotshape(fireLong and glowFx,  title = "Long Halo",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 78),  size = size.normal, force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Halo", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 78), size = size.normal, force_overlay = true)
plotshape(fireLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small, force_overlay = true)
plotshape(fireShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small, force_overlay = true)

// glow accent on high-similarity bars
plot(glowFx and inHorizon and liveSim > zoneSim ? close : na, "Similarity Glow", color = color.new(f_actColor(chosen), 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

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

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    color sigCol = f_actColor(chosen)

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "KNN×RL", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + f_actName(chosen), text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(sigCol, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "FUSED VALUE  (NN ⊕ kNN)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 2, 2, 2)

    float fl = (1.0 - blendKnn) * (na(liveQ0) ? 0.0 : liveQ0) + blendKnn * (na(liveKnnL) ? 0.0 : liveKnnL)
    float fs = (1.0 - blendKnn) * (na(liveQ1) ? 0.0 : liveQ1) + blendKnn * (na(liveKnnS) ? 0.0 : liveKnnS)
    table.cell(panel, 0, 3, "LONG",  text_color = colLong,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(na(liveQ0) ? 0.0 : liveQ0, "#.##") + " / " + str.tostring(na(liveKnnL) ? 0.0 : liveKnnL, "#.##"), text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(fl, "#.##"), text_color = colLong, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "SHORT", text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, str.tostring(na(liveQ1) ? 0.0 : liveQ1, "#.##") + " / " + str.tostring(na(liveKnnS) ? 0.0 : liveKnnS, "#.##"), text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 4, str.tostring(fs, "#.##"), text_color = colShort, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "Memory Similarity", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 5, f_bar(liveSim), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 5, str.tostring(math.round(liveSim * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 6, "Conviction", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, f_bar(conviction), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 6, str.tostring(math.round(conviction * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "Memory ↔ Net Blend", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, f_bar(blendKnn), text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 7, str.tostring(math.round(blendKnn * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Sim Weights (M·R·V·P)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 8, 2, 8)
    table.cell(panel, 0, 9, str.tostring(array.get(simW,0), "#.#") + " · " + str.tostring(array.get(simW,1), "#.#") + " · " + str.tostring(array.get(simW,2), "#.#") + " · " + str.tostring(array.get(simW,3), "#.#"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 9, 1, 9)
    table.cell(panel, 2, 9, "k=" + str.tostring(knnK), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Memory / Zones", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(array.size(mAct)) + "/" + str.tostring(memDepth), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, str.tostring(array.size(zones)) + " zones", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(fireLong,  "KNN-RL ▸ LONG",  "AetherEdge KNN-RL: high-similarity LONG signal.")
alertcondition(fireShort, "KNN-RL ▸ SHORT", "AetherEdge KNN-RL: high-similarity SHORT signal.")
````
