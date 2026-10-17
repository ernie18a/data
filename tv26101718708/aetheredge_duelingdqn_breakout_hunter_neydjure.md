# AetherEdge - DuelingDQN Breakout Hunter

- url: https://www.tradingview.com/script/NeydJUre/
- type: indicator
- pine_id: PUB;5bc08740df2a45678a84d0964a164b22
- version: 1.0

## Description

🖊️ Overview

A self-evolving breakout agent built on a Dueling Deep-Q-Network that learns to hunt breakouts on its own. Its defining trait is a forked network: a Value stream V(s) that learns "how promising is this state at all", and an Advantage stream A(s,a) that learns "which action is relatively better here", recombined as Q(s,a) = V(s) + (A(s,a) − mean A). This separation lets the agent value the breakout context independently of the directional decision, sharpening action selection exactly where it counts — inside detected breakout zones. Learning from experience on your chart, it visualizes its hunt with auto support/resistance boxes and faint probability arrows.

🔶 Key Features

Dueling DQN architecture — shared trunk → Value and Advantage streams → recombined via the dueling aggregation; state quality and action advantage learned separately
Self-evolving breakout learning — no pre-training; breakout context learned continuously from the live chart
Breakout reward bonus — extra reward for correct actions in breakout context, focusing learning on breakouts
Auto S/R zones — boxes spawn on rolling S/R breaks, with full lifecycle management
Faint probability arrows — drawn with subtle opacity scaled to softmax action probabilities derived from advantages
Prioritized Experience Replay (PER) — high-reward transitions re-learned preferentially
Exploration vs. exploitation — ε-greedy exploration avoids ossifying in local optima
Intelligence panel — V(s), per-action A(s,a), selected action, advantage spread, breakout context, and zone count at a glance

🧠 Technical Architecture

The agent perceives the market as a four-dimensional state vector: momentum spread (ATR-normalized fast/slow EMA gap), relative position within Bollinger Bands, ATR distance to the nearest S/R, and a volatility-regime ratio — all z-normalized.
The core is the Dueling structure. Input passes through a shared trunk (tanh hidden), then forks. The Value stream runs through its hidden layer to a scalar V(s); the Advantage stream runs through its hidden layer to three per-action values A(s,a). They aggregate as Q(s,a) = V(s) + (A(s,a) − mean_a A(s,a)), the mean-subtraction ensuring identifiability between Value and Advantage. Learning is done by manual backpropagation through this aggregation: gradients are correctly distributed to the advantage outputs (dQ/dA = 𝟙[a] − 1/3) and the value output (dQ/dV = 1), then propagated back through each stream's hidden layer and into the shared trunk.
The reward function is a directional, ATR-normalized forward return, plus a bonus for success in breakout context. Transitions (s, a, r, s′) enter the experience replay buffer, sampled by |reward|^exponent. As the zone lifecycle, boxes spawn on rolling S/R breaks and are pruned oldest-first on lifespan or cap overflow. Probability arrows vary in opacity by softmax advantage probability and are drawn only when the advantage spread clears the gate. The statistics panel makes the internal Value and Advantage readable.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, γ 0.92–0.95, Shared Hidden 8 / Stream Hidden 4, S/R Lookback 20, Breakout Bonus 0.5. Standard settings fit well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8 to value post-break follow-through
SOL (15m–1H): High volatility favors Zone Width 0.3–0.5 (wider boxes absorb fakeouts), ε 0.05–0.08, Breakout Bonus 0.6–0.8 to strengthen breakout learning
XRP (1H–4H): Spike-prone; Priority Exponent ≈ 2.0, longer S/R Lookback (25–30) to focus on major levels
Learning Rate α: 0.02–0.04 in trending markets; 0.04–0.08 in choppy ones
Stream Hidden Units: widen to 6–8 for richer advantage representation on instruments with diverse breakout types
maxBoxes / Zone Lifespan: maxBoxes 4–6 to see only key levels; extend Lifespan to retain zones longer

💡 How to Use in Practice

Reacting to high-advantage actions: when one action's advantage dominates with a high spread, the agent sees a clear edge in the break direction — a basis for trend-following entries
Using S/R boxes: auto-spawned zones mark post-break retest (return-move) levels; watch reactions at zone edges
S/R flips: capture the classic pattern where a broken resistance zone flips to support, via the box plus the advantage shift
Arrow opacity: darker arrows mean higher action probability and stronger conviction; treat faint arrows as wait-and-see
Multi-timeframe usage: read the big-picture break and zones on the higher timeframe (4H), then refine timing on aligned high-advantage actions on the lower one (15m–1H)
Combinations: filter for breaks accompanied by volume surges to reject fakeouts and elevate signal quality

⚠️ Important Notes

Initial learning period: right after launch the replay buffer is nearly empty and both Value and Advantage are unstable; treat signals as low-confidence until it fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes all network weights, the buffer, and zones, restarting learning from zero
Nature of zones: boxes are structural markers from rolling S/R breaks, not signals in themselves; judge alongside the agent's advantage
On forward-looking reward: rewards use closed-bar forward return (a standard RL training construct); current-bar action selection is made on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Dueling Deep-Q-Network, experience replay, reward shaping, breakout-zone detection, and action probabilities are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - DuelingDQN Breakout Hunter
//   AI Drawing Power Series
//
//   A self-evolving breakout agent built on a Dueling Deep-Q-Network. The network forks into two
//   streams — a Value stream V(s) that learns "how good is this state at all", and an Advantage
//   stream A(s,a) that learns "which action is relatively better here" — recombined as
//   Q(s,a) = V(s) + (A(s,a) − mean_a A(s,a)). This separation lets the agent value the breakout
//   context independently of the directional decision, sharpening action selection precisely where
//   it matters: inside detected breakout zones.
//
//   Visualization: auto support/resistance breakout boxes + faint probability arrows scaled to the
//   agent's advantage-derived action probabilities.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - DuelingDQN Breakout Hunter", "AE-DDQN BHD", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT  = "◆  DUELING-DQN AGENT"
var string GRP_STATE  = "◆  STATE ENCODER"
var string GRP_NET    = "◆  DUELING Q-NETWORK (NeuraLib)"
var string GRP_REPLAY = "◆  EXPERIENCE REPLAY"
var string GRP_REWARD = "◆  REWARD SHAPING"
var string GRP_ZONE   = "◆  BREAKOUT ZONES"
var string GRP_STYLE  = "◆  AESTHETICS"
var string GRP_PANEL  = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen      = input.int(600,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
epsilon       = input.float(0.05,"Exploration ε",          minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_AGENT)
gamma         = input.float(0.93,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
zoneGate      = input.float(0.0, "Min Advantage to Act",   minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_AGENT, tooltip = "Minimum normalized advantage spread before a probability arrow is drawn.")

// — State Encoder —
fastLen       = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen       = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
bbLen         = input.int(20,   "Volatility (BB) Length", minval = 2, maxval = 100, group = GRP_STATE)
rangeLen      = input.int(20,   "S/R Lookback",   minval = 3, maxval = 200, group = GRP_STATE, tooltip = "Lookback used to define the rolling support/resistance band.")
normLen       = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Dueling Q-Network —
hiddenN       = input.int(8,    "Shared Hidden Units", minval = 2, maxval = 16, group = GRP_NET, tooltip = "Width of the shared trunk before it forks into Value and Advantage streams.")
streamN       = input.int(4,    "Stream Hidden Units", minval = 2, maxval = 12, group = GRP_NET, tooltip = "Width of each (Value / Advantage) stream's hidden layer.")
learnRate     = input.float(0.04,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_NET)
trainSteps    = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_NET)
seedInp       = input.int(13,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_NET)

// — Experience Replay —
bufferCap     = input.int(150,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_REPLAY)
prioritized   = input.bool(true,"Prioritized Sampling", group = GRP_REPLAY)
priorityExp   = input.float(1.5,"Priority Exponent", minval = 0.0, maxval = 4.0, step = 0.1, group = GRP_REPLAY)

// — Reward —
rewardLook    = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
riskNorm      = input.bool(true,"ATR-Normalize Reward",    group = GRP_REWARD)
flatPenalty   = input.float(0.05,"Flat Opportunity Cost",  minval = 0.0, maxval = 1.0, step = 0.01, group = GRP_REWARD)
breakBonus    = input.float(0.5, "Breakout Reward Bonus",  minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_REWARD, tooltip = "Extra reward when a directional action is taken inside a breakout zone and pays off — focuses learning on breakouts.")

// — Breakout Zones —
zoneBuffer    = input.float(0.25,"Zone Width (ATR x)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_ZONE, tooltip = "Half-height of the S/R box, in ATR multiples.")
breakConfirm  = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = GRP_ZONE)
maxBoxes      = input.int(6,    "Max Visible Zones", minval = 1, maxval = 30, group = GRP_ZONE)
boxLife       = input.int(120,  "Zone Lifespan (bars)", minval = 10, maxval = 1000, group = GRP_ZONE)

// — Aesthetics —
colLong       = input.color(#26d0a8, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort      = input.color(#ff5c7c, "Short Tone", group = GRP_STYLE, inline = "c1")
colFlat       = input.color(#6b7689, "Flat Tone",  group = GRP_STYLE, inline = "c1")
colZoneRes    = input.color(#ff5c7c, "Resistance Zone", group = GRP_STYLE, inline = "c2")
colZoneSup    = input.color(#26d0a8, "Support Zone",    group = GRP_STYLE, inline = "c2")
arrowTransp   = input.int(62,   "Arrow Transparency", minval = 20, maxval = 90, group = GRP_STYLE, tooltip = "Probability arrows are intentionally faint; higher = more transparent.")
zoneTransp    = input.int(86,   "Zone Fill Transparency", minval = 70, maxval = 99, group = GRP_STYLE)
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

// softmax over 3 values → probabilities (for the faint probability arrows)
f_softmax3(float a, float b, float c) =>
    float m = math.max(a, math.max(b, c))
    float ea = math.exp(a - m)
    float eb = math.exp(b - m)
    float ec = math.exp(c - m)
    float s = ea + eb + ec
    [ea / s, eb / s, ec / s]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  STATE ENCODER  — momentum, BB %position, distance-to-S/R, volatility regime
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr     = ta.atr(14)
basis   = ta.sma(close, bbLen)
dev     = ta.stdev(close, bbLen)
bbUpper = basis + 2.0 * dev
bbLower = basis - 2.0 * dev

resLevel = ta.highest(high, rangeLen)
supLevel = ta.lowest(low, rangeLen)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

rawMom  = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawBb   = (bbUpper - bbLower) == 0 ? 0.0 : (close - basis) / (bbUpper - bbLower) * 2.0  // position within bands
rawDist = atr == 0 ? 0.0 : (math.min(resLevel - close, close - supLevel)) / atr        // proximity to nearest S/R
rawVol  = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen)) - 1.0

s0 = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
s1 = math.max(-3.0, math.min(3.0, rawBb))
s2 = f_znorm(rawDist, ta.sma(rawDist, normLen), ta.stdev(rawDist, normLen))
s3 = f_znorm(rawVol, ta.sma(rawVol, normLen), ta.stdev(rawVol, normLen))

var int N_IN  = 4
var int N_OUT = 3

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  DUELING Q-NETWORK
//  Shared trunk:   IN → hidden(tanh)  [hiddenN]
//  Value stream:   hidden → vHidden(tanh)[streamN] → V (scalar)
//  Advantage stream: hidden → aHidden(tanh)[streamN] → A[3]
//  Combine:        Q(a) = V + (A(a) − mean(A))
// ────────────────────────────────────────────────────────────────────────────────────────────────

// Shared trunk
var array<float> Wt = na   // [hiddenN x N_IN]
var array<float> bt = na   // [hiddenN]
// Value stream
var array<float> Wv1 = na  // [streamN x hiddenN]
var array<float> bv1 = na  // [streamN]
var array<float> Wv2 = na  // [1 x streamN]
var array<float> bv2 = na  // [1] — 1-element array so it can be mutated inside f_trainOnce
// Advantage stream
var array<float> Wa1 = na  // [streamN x hiddenN]
var array<float> ba1 = na  // [streamN]
var array<float> Wa2 = na  // [N_OUT x streamN]
var array<float> ba2 = na  // [N_OUT]
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
    f_initRange(Wt,  seedInp * 2654435761,        0.8)
    f_initRange(Wv1, seedInp * 40503 + 101,       0.8)
    f_initRange(Wv2, seedInp * 92821 + 202,       0.8)
    f_initRange(Wa1, seedInp * 12345 + 303,       0.8)
    f_initRange(Wa2, seedInp * 27644 + 404,       0.8)
    netInit := true

// Forward pass. Caches: trunk activations (hCache), value-hidden (vCache), adv-hidden (aCache).
// Returns [q0, q1, q2, V, A0, A1, A2].
f_forward(float i0, float i1, float i2, float i3, array<float> hCache, array<float> vCache, array<float> aCache) =>
    array.clear(hCache)
    array.clear(vCache)
    array.clear(aCache)
    // shared trunk
    for h = 0 to hiddenN - 1
        float z = array.get(bt, h)
        z += array.get(Wt, h * N_IN + 0) * i0
        z += array.get(Wt, h * N_IN + 1) * i1
        z += array.get(Wt, h * N_IN + 2) * i2
        z += array.get(Wt, h * N_IN + 3) * i3
        array.push(hCache, f_tanh(z))
    // value stream hidden
    for v = 0 to streamN - 1
        float z = array.get(bv1, v)
        for h = 0 to hiddenN - 1
            z += array.get(Wv1, v * hiddenN + h) * array.get(hCache, h)
        array.push(vCache, f_tanh(z))
    // value scalar
    float V = array.get(bv2, 0)
    for v = 0 to streamN - 1
        V += array.get(Wv2, v) * array.get(vCache, v)
    // advantage stream hidden
    for a = 0 to streamN - 1
        float z = array.get(ba1, a)
        for h = 0 to hiddenN - 1
            z += array.get(Wa1, a * hiddenN + h) * array.get(hCache, h)
        array.push(aCache, f_tanh(z))
    // advantage outputs
    float A0 = array.get(ba2, 0)
    float A1 = array.get(ba2, 1)
    float A2 = array.get(ba2, 2)
    for a = 0 to streamN - 1
        float av = array.get(aCache, a)
        A0 += array.get(Wa2, 0 * streamN + a) * av
        A1 += array.get(Wa2, 1 * streamN + a) * av
        A2 += array.get(Wa2, 2 * streamN + a) * av
    // dueling aggregation: Q = V + (A − mean A)
    float aMean = (A0 + A1 + A2) / 3.0
    float q0 = V + (A0 - aMean)
    float q1 = V + (A1 - aMean)
    float q2 = V + (A2 - aMean)
    [q0, q1, q2, V, A0, A1, A2]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  EXPERIENCE REPLAY BUFFER
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> bufS0 = array.new_float()
var array<float> bufS1 = array.new_float()
var array<float> bufS2 = array.new_float()
var array<float> bufS3 = array.new_float()
var array<int>   bufA  = array.new_int()
var array<float> bufR  = array.new_float()
var array<float> bufN0 = array.new_float()
var array<float> bufN1 = array.new_float()
var array<float> bufN2 = array.new_float()
var array<float> bufN3 = array.new_float()
var array<float> bufP  = array.new_float()

f_pushTransition(float ps0, float ps1, float ps2, float ps3, int a, float r, float n0, float n1, float n2, float n3) =>
    array.push(bufS0, ps0)
    array.push(bufS1, ps1)
    array.push(bufS2, ps2)
    array.push(bufS3, ps3)
    array.push(bufA, a)
    array.push(bufR, r)
    array.push(bufN0, n0)
    array.push(bufN1, n1)
    array.push(bufN2, n2)
    array.push(bufN3, n3)
    array.push(bufP, math.pow(math.abs(r) + 0.01, priorityExp))
    if array.size(bufA) > bufferCap
        array.shift(bufS0)
        array.shift(bufS1)
        array.shift(bufS2)
        array.shift(bufS3)
        array.shift(bufA)
        array.shift(bufR)
        array.shift(bufN0)
        array.shift(bufN1)
        array.shift(bufN2)
        array.shift(bufN3)
        array.shift(bufP)

f_sampleIdx(int rngSeed) =>
    int n = array.size(bufA)
    int idx = 0
    if n > 0
        if prioritized
            float total = array.sum(bufP)
            float pick = f_rand(rngSeed) * total
            float run = 0.0
            int found = n - 1
            bool done = false
            for i = 0 to n - 1
                if not done
                    run += array.get(bufP, i)
                    if run >= pick
                        found := i
                        done := true
            idx := found
        else
            idx := int(f_rand(rngSeed) * n) % n
    idx

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  BREAKOUT ZONE DETECTION
//  A new zone is born when price breaks the rolling S/R band. The box marks the broken level.
// ────────────────────────────────────────────────────────────────────────────────────────────────

resPrev = resLevel[1]
supPrev = supLevel[1]

float brkPx = breakConfirm == "Wick" ? high : close
float brkPxL = breakConfirm == "Wick" ? low : close

bool brokeUp   = brkPx > resPrev and close[1] <= resPrev
bool brokeDown = brkPxL < supPrev and close[1] >= supPrev

type Zone
    box  bx
    int  bornBar
    bool isRes

var array<Zone> zones = array.new<Zone>()

f_spawnZone(bool isRes, float lvl) =>
    float half = atr * zoneBuffer
    color bc = isRes ? colZoneRes : colZoneSup
    box bx = box.new(bar_index, lvl + half, bar_index + 1, lvl - half,
         xloc = xloc.bar_index,
         border_color = color.new(bc, 25),
         border_width = 1,
         bgcolor = color.new(bc, zoneTransp),
         extend = extend.right)
    Zone z = Zone.new(bx, bar_index, isRes)
    array.push(zones, z)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  REWARD  — directional forward return, ATR-normalized, with breakout-zone bonus
// ────────────────────────────────────────────────────────────────────────────────────────────────

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]

// was the action taken while inside/just at a breakout? (proxy: strong band position at decision time)
inBreakout = math.abs(rawBb) > 1.0

f_reward(int a, float ret, float atrRef, bool wasBreakout) =>
    float baseRet = riskNorm and atrRef != 0 ? (ret * close[rewardLook]) / atrRef : ret
    float r = a == A_LONG ? baseRet : a == A_SHORT ? -baseRet : -flatPenalty * math.abs(baseRet)
    // breakout focus: reward directional actions that work out in breakout context
    if wasBreakout and a != A_FLAT and r > 0
        r := r * (1.0 + breakBonus)
    math.max(-5.0, math.min(5.0, r))

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  TRAINING STEP  — DQN target + manual backprop through the dueling architecture
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> hTr = array.new_float()
var array<float> vTr = array.new_float()
var array<float> aTr = array.new_float()
var array<float> hNx = array.new_float()
var array<float> vNx = array.new_float()
var array<float> aNx = array.new_float()

f_trainOnce(int idx) =>
    if array.size(bufA) > 0
        float ps0 = array.get(bufS0, idx)
        float ps1 = array.get(bufS1, idx)
        float ps2 = array.get(bufS2, idx)
        float ps3 = array.get(bufS3, idx)
        int   a   = array.get(bufA, idx)
        float r   = array.get(bufR, idx)
        float nx0 = array.get(bufN0, idx)
        float nx1 = array.get(bufN1, idx)
        float nx2 = array.get(bufN2, idx)
        float nx3 = array.get(bufN3, idx)

        [q0, q1, q2, V, A0, A1, A2] = f_forward(ps0, ps1, ps2, ps3, hTr, vTr, aTr)
        [nq0, nq1, nq2, nV, nA0, nA1, nA2] = f_forward(nx0, nx1, nx2, nx3, hNx, vNx, aNx)
        float maxNext = math.max(nq0, math.max(nq1, nq2))
        float target  = r + gamma * maxNext
        float pred    = a == A_LONG ? q0 : a == A_SHORT ? q1 : q2
        float err     = math.max(-5.0, math.min(5.0, pred - target))

        // ----- gradient of Q(a) wrt V and A -----
        // Q(a) = V + A(a) - mean(A). dQ(a)/dV = 1 ; dQ(a)/dA(j) = (j==a) - 1/3
        // value-stream output gradient
        float gV = err * 1.0
        // advantage output gradients (3-vector)
        gA = array.new_float(N_OUT, 0.0)
        for j = 0 to N_OUT - 1
            float indicatorAj = (j == a ? 1.0 : 0.0) - (1.0 / 3.0)
            array.set(gA, j, err * indicatorAj)

        // ----- backprop VALUE stream: Wv2, bv2, then Wv1/bv1, accumulate into trunk -----
        gTrunk = array.new_float(hiddenN, 0.0)
        // Wv2 (streamN), bv2
        gVHidden = array.new_float(streamN, 0.0)
        for v = 0 to streamN - 1
            float vv = array.get(vTr, v)
            array.set(gVHidden, v, gV * array.get(Wv2, v))
            array.set(Wv2, v, array.get(Wv2, v) - learnRate * gV * vv)
        array.set(bv2, 0, array.get(bv2, 0) - learnRate * gV)
        // Wv1/bv1
        for v = 0 to streamN - 1
            float dz = array.get(gVHidden, v) * f_dtanh(array.get(vTr, v))
            for h = 0 to hiddenN - 1
                int wi = v * hiddenN + h
                array.set(gTrunk, h, array.get(gTrunk, h) + dz * array.get(Wv1, wi))
                array.set(Wv1, wi, array.get(Wv1, wi) - learnRate * dz * array.get(hTr, h))
            array.set(bv1, v, array.get(bv1, v) - learnRate * dz)

        // ----- backprop ADVANTAGE stream: Wa2/ba2, then Wa1/ba1, accumulate into trunk -----
        gAHidden = array.new_float(streamN, 0.0)
        for j = 0 to N_OUT - 1
            float gj = array.get(gA, j)
            for a2 = 0 to streamN - 1
                int wi = j * streamN + a2
                array.set(gAHidden, a2, array.get(gAHidden, a2) + gj * array.get(Wa2, wi))
                array.set(Wa2, wi, array.get(Wa2, wi) - learnRate * gj * array.get(aTr, a2))
            array.set(ba2, j, array.get(ba2, j) - learnRate * gj)
        for a2 = 0 to streamN - 1
            float dz = array.get(gAHidden, a2) * f_dtanh(array.get(aTr, a2))
            for h = 0 to hiddenN - 1
                int wi = a2 * hiddenN + h
                array.set(gTrunk, h, array.get(gTrunk, h) + dz * array.get(Wa1, wi))
                array.set(Wa1, wi, array.get(Wa1, wi) - learnRate * dz * array.get(hTr, h))
            array.set(ba1, a2, array.get(ba1, a2) - learnRate * dz)

        // ----- backprop SHARED trunk -----
        for h = 0 to hiddenN - 1
            float dz = array.get(gTrunk, h) * f_dtanh(array.get(hTr, h))
            array.set(Wt, h * N_IN + 0, array.get(Wt, h * N_IN + 0) - learnRate * dz * ps0)
            array.set(Wt, h * N_IN + 1, array.get(Wt, h * N_IN + 1) - learnRate * dz * ps1)
            array.set(Wt, h * N_IN + 2, array.get(Wt, h * N_IN + 2) - learnRate * dz * ps2)
            array.set(Wt, h * N_IN + 3, array.get(Wt, h * N_IN + 3) - learnRate * dz * ps3)
            array.set(bt, h, array.get(bt, h) - learnRate * dz)

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
var int   pAct = na

var float liveQ0 = na
var float liveQ1 = na
var float liveQ2 = na
var float liveV  = na
var float liveA0 = na
var float liveA1 = na
var float liveA2 = na
var int   chosen = A_FLAT
var float advSpread = 0.0
var float prL = 0.0
var float prS = 0.0
var float prF = 0.0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        bool wasBrk = inBreakout[rewardLook]
        float rwd = f_reward(pAct, fwdRet, atrPast, wasBrk)
        f_pushTransition(pS0, pS1, pS2, pS3, pAct, rwd, s0, s1, s2, s3)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int idx = f_sampleIdx(seed)
        f_trainOnce(idx)

// ---- ACTION SELECTION (every bar incl. realtime) ----
if inHorizon
    [q0, q1, q2, V, A0, A1, A2] = f_forward(s0, s1, s2, s3, hLv, vLv, aLv)
    liveQ0 := q0
    liveQ1 := q1
    liveQ2 := q2
    liveV  := V
    liveA0 := A0
    liveA1 := A1
    liveA2 := A2

    float qmax = math.max(q0, math.max(q1, q2))
    chosen := q0 == qmax ? A_LONG : q1 == qmax ? A_SHORT : A_FLAT

    if barstate.isconfirmed
        int eseed = (bar_index * 2246822519 + seedInp) % 2147483647
        if f_rand(eseed) < epsilon
            int rseed = (bar_index * 3266489917 + 11) % 2147483647
            chosen := int(f_rand(rseed) * 3) % 3

    // advantage spread (how much the best action stands out) — the dueling signal
    float aMax = math.max(A0, math.max(A1, A2))
    float aMin = math.min(A0, math.min(A1, A2))
    float aMid = (A0 + A1 + A2) - aMax - aMin
    advSpread := (aMax - aMin) == 0 ? 0.0 : (aMax - aMid) / (aMax - aMin)

    // action probabilities via softmax over advantages → faint arrow intensity
    [p0, p1, p2] = f_softmax3(A0, A1, A2)
    prL := p0
    prS := p1
    prF := p2

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := chosen

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ZONE LIFECYCLE  — spawn on break, extend, retire old/over-cap
// ────────────────────────────────────────────────────────────────────────────────────────────────

if inHorizon and barstate.isconfirmed
    if brokeUp
        f_spawnZone(true, resPrev)
    if brokeDown
        f_spawnZone(false, supPrev)

    // extend & retire
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            Zone z = array.get(zones, i)
            if bar_index - z.bornBar > boxLife
                box.delete(z.bx)
                array.remove(zones, i)
            else
                box.set_right(z.bx, bar_index + 1)

    // enforce cap (remove oldest)
    while array.size(zones) > maxBoxes
        Zone z0 = array.get(zones, 0)
        box.delete(z0.bx)
        array.remove(zones, 0)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  VISUALIZATION — faint probability arrows
//  Arrow opacity scales with action probability; drawn only when advantage clears the gate.
// ────────────────────────────────────────────────────────────────────────────────────────────────

bool gateOk = advSpread >= zoneGate
var int lastAct = na
bool actChanged = chosen != lastAct

// transparency: faint, but a touch stronger when probability is high
f_arrowTransp(float p) =>
    int t = int(arrowTransp - p * 30)
    math.max(15, math.min(95, t))

plotshape(inHorizon and barstate.isconfirmed and chosen == A_LONG and gateOk and actChanged,
     title = "Long (faint)", style = shape.triangleup, location = location.belowbar,
     color = color.new(colLong, f_arrowTransp(prL)), size = size.small)
plotshape(inHorizon and barstate.isconfirmed and chosen == A_SHORT and gateOk and actChanged,
     title = "Short (faint)", style = shape.triangledown, location = location.abovebar,
     color = color.new(colShort, f_arrowTransp(prS)), size = size.small)

if barstate.isconfirmed
    lastAct := chosen

// glow accent on high-advantage bars
plot(glowFx and inHorizon and advSpread > 0.6 ? close : na, "Advantage Glow", color = color.new(f_actionColor(chosen), 60), linewidth = 3, style = plot.style_circles)

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
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    table.cell(panel, 0, 0, "AETHEREDGE  ▸  BREAKOUT HUNTER", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.merge_cells(panel, 0, 0, 2, 0)

    // Value stream readout
    table.cell(panel, 0, 1, "STATE VALUE  V(s)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 1, "", text_color = THEME_TXT, text_size = f_panelSize())
    table.cell(panel, 2, 1, str.tostring(na(liveV) ? 0.0 : liveV, "#.###"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 2, "ADVANTAGE  A(s,a)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 2, 2, 2)

    table.cell(panel, 0, 3, "LONG",  text_color = colLong,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar(prL), text_color = colLong, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(na(liveA0) ? 0.0 : liveA0, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "SHORT", text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_bar(prS), text_color = colShort, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 4, str.tostring(na(liveA1) ? 0.0 : liveA1, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "FLAT",  text_color = colFlat,  text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 5, f_bar(prF), text_color = colFlat, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 5, str.tostring(na(liveA2) ? 0.0 : liveA2, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 6, "SELECTED ACTION", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 6, 2, 6)

    table.cell(panel, 0, 7, f_actionName(chosen), text_color = #0b0e16, text_size = f_panelSize(), text_halign = text.align_center, bgcolor = color.new(f_actionColor(chosen), 0))
    table.merge_cells(panel, 0, 7, 2, 7)

    table.cell(panel, 0, 8, "Advantage Spread", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, f_bar(advSpread), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(math.round(advSpread * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Breakout Context", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, inBreakout ? "● ACTIVE" : "○ idle", text_color = inBreakout ? colLong : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 9, str.tostring(array.size(zones)) + " zones", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Replay Buffer", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, str.tostring(array.size(bufA)) + " / " + str.tostring(bufferCap), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 10, prioritized ? "PER" : "UNIF", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

alertcondition(brokeUp,   "Breakout ▲ (Resistance)", "AetherEdge: price broke resistance — new breakout zone.")
alertcondition(brokeDown, "Breakout ▼ (Support)",    "AetherEdge: price broke support — new breakout zone.")
alertcondition(chosen == A_LONG  and lastAct != A_LONG,  "DDQN ▸ LONG",  "AetherEdge Dueling-DQN selected LONG.")
alertcondition(chosen == A_SHORT and lastAct != A_SHORT, "DDQN ▸ SHORT", "AetherEdge Dueling-DQN selected SHORT.")
````
