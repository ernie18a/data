# AetherEdge - Self-Evolving RL Dashboard Lite

- url: https://www.tradingview.com/script/lqSuqj6n/
- type: indicator
- pine_id: PUB;e3524ef29ec14c0fb911a094189368e8
- version: 1.0

## Description

🖊️ Overview

A streamlined self-evolving agent built on a lightweight Actor-Critic core with prioritized experience, learning by pitting multiple specialist RL heads against each other. Internally, three heads — TREND-FOLLOWING, MEAN-REVERSION, and BREAKOUT — each propose a directional view from their own lens, while a meta-selector tracks each head's recent reward performance and re-allocates trust toward whichever is working now. As the market's character shifts, the agent automatically moves its weight toward the style that's paying off. Visualization is intentionally minimal: one main signal arrow, one prediction line, a small composite score, and a "Learning Progress" label that makes the evolution visible.

🔶 Key Features

Competing RL heads — trend / mean-reversion / breakout specialists run in parallel; the best drives the unified call
Dynamic trust re-allocation — softmax trust weights adapt to each head's reward-performance score
Lightweight Actor-Critic — each head has an Actor (policy) and Critic (state value), learning via advantage
Prioritized experience replay — high-reward transitions re-learned preferentially
Style-specific reward shaping — each head is rewarded more in its specialty regime, differentiating behavior
Ultra-minimal visuals — just one main arrow + one prediction line + a small composite score
Learning Progress label — visualizes agent maturity (bars trained, buffer fill, trust concentration) as a bar
Exploration vs. exploitation — ε-greedy exploration

🧠 Technical Architecture

The agent perceives the market as a four-dimensional state vector (momentum spread, RSI deviation, Bollinger position, position-within-range — all z-normalized). The core is three independent Actor-Critic heads, each producing Actor logits (3 actions → softmax policy) and a Critic value from a compact shared trunk (tanh).
Heads differentiate via style-specific reward shaping. From a common directional return (ATR-normalized), the trend head amplifies reward in strong trends (large |momentum|), the mean-reversion head when stretched from the mean (large |BB position|), and the breakout head near range edges. The three thus learn distinct behaviors from the same price data.
Learning is standard Actor-Critic. Each head's Critic computes the TD target r + γV(s′), the advantage A = TD target − V(s) drives the Actor's advantage-weighted policy gradient, and the Critic regresses via squared error — all from a prioritized replay buffer (|reward|^exponent). In meta-selection, each head's performance score is EMA-smoothed and turned into trust weights via softmax. The final policy blends the three heads' policies by trust and picks the max-value action. The composite score is the decisiveness of the blended policy; learning progress combines training maturity, buffer fill, and trust concentration.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, γ 0.93, Head Trust Adapt 0.05, Min Score 0.35. Standard settings fit well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8
SOL (15m–1H): High volatility favors Head Trust Adapt ≈ 0.08 to switch styles quickly, Min Score 0.4 to be selective
XRP (1H–4H): Spike-prone; Priority Exponent ≈ 2.0 to learn hard from big experiences, shorter Prediction Length
Head Trust Adapt Rate: higher switches to the winning style faster but less stably; lower is stable but slower
Head Score Smoothing: higher (0.9–0.95) smooths performance assessment; lower is sensitive to recent results
Min Score to Signal: higher makes arrows more selective — tune to your trade frequency
Prediction Length: the projection distance of the line; a higher score steepens its slope

💡 How to Use in Practice

Reacting to the main arrow: an arrow is the "final verdict" where the trust-weighted consensus of all three heads clears the score gate — a core basis for trend-following entries
Using the prediction line: one line whose slope scales with score; steeper means a more confident directional view
Reading the composite score: a higher score % in the small label means clearer cross-head consensus; low means a balanced call (stand aside)
Using the Learning Progress label: as the "LEARNING" bar fills and the best head stabilizes, the policy is maturing; treat signals as indicative while progress is low
Watching the best head: the current leading head (TREND / MEAN-REV / BREAKOUT) in the progress label reveals how the agent reads the present market
Multi-timeframe usage: confirm the best head and direction on the higher timeframe (4H), then refine timing on arrows on the lower one (15m–1H)

⚠️ Important Notes

Initial learning period: right after launch the buffer is nearly empty and the heads are immature; treat signals as low-confidence until the Learning Progress bar fills (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes all head weights, trust weights, and the buffer, restarting learning from zero
Nature of the Lite build: this distills the multi-head internals into ultra-simple output, omitting detailed internal-state visualization
On forward-looking reward: rewards use closed-bar forward returns (a standard RL training construct); current-bar decisions are on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Actor-Critic, competing RL heads, prioritized experience replay, reward shaping, composite score, and prediction are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Self-Evolving RL Dashboard Lite
//   AI Drawing Power Series
//
//   A streamlined self-evolving agent built on a lightweight Actor-Critic core with prioritized
//   experience. Internally it runs THREE competing RL heads — TREND-FOLLOWING, MEAN-REVERSION, and
//   BREAKOUT — each proposing a directional view from its own specialist lens. A meta-selector tracks
//   each head's recent reward-weighted performance and lets the strongest head drive the unified
//   decision, so the agent continuously re-allocates trust toward whichever style is working now.
//
//   Visualization is intentionally minimal: one main signal arrow, one forward prediction line, a
//   small composite score, and a "Learning Progress" label that makes the agent's evolution visible.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Self-Evolving RL Dashboard Lite", "AE-SE RL", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT = "◆  RL AGENT"
var string GRP_HEADS = "◆  COMPETING RL HEADS"
var string GRP_STATE = "◆  STATE ENCODER"
var string GRP_REWARD= "◆  PRIORITIZED LEARNING"
var string GRP_SIG   = "◆  SIGNAL & PREDICTION"
var string GRP_STYLE = "◆  AESTHETICS"

// — Agent —
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
gamma        = input.float(0.93,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
learnRate    = input.float(0.04,"Learning Rate α",        minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_AGENT)
epsilon      = input.float(0.06,"Exploration ε",          minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_AGENT)

// — Competing Heads —
headAdapt    = input.float(0.05,"Head Trust Adapt Rate",  minval = 0.005, maxval = 0.5, step = 0.005, group = GRP_HEADS, tooltip = "How fast trust is re-allocated toward the best-performing head.")
headMomentum = input.float(0.9, "Head Score Smoothing",   minval = 0.5, maxval = 0.99, step = 0.01, group = GRP_HEADS, tooltip = "EMA smoothing of each head's running performance score.")

// — State Encoder —
fastLen      = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen      = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen       = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
bbLen        = input.int(20,   "Range Length",   minval = 2, maxval = 100, group = GRP_STATE)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Prioritized Learning —
bufferCap    = input.int(140,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_REWARD)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_REWARD)
priorityExp  = input.float(1.5,"Priority Exponent", minval = 0.0, maxval = 4.0, step = 0.1, group = GRP_REWARD)
rewardLook   = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_REWARD)
seedInp      = input.int(37,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_REWARD)

// — Signal & Prediction —
sigGate      = input.float(0.35,"Min Score to Signal", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_SIG, tooltip = "The main arrow fires only when the composite score clears this gate.")
predLook     = input.int(8,    "Prediction Length (bars)", minval = 1, maxval = 40, group = GRP_SIG, tooltip = "How far forward the single prediction line projects.")
oncePerMove  = input.bool(true,"One Arrow per Directional Shift", group = GRP_SIG)

// — Aesthetics —
colLong      = input.color(#21d3a3, "Long Tone",  group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Short Tone", group = GRP_STYLE, inline = "c1")
colNeutral   = input.color(#7d88a0, "Neutral Tone", group = GRP_STYLE, inline = "c1")
showPred     = input.bool(true, "Prediction Line", group = GRP_STYLE)
showScore    = input.bool(true, "Composite Score Label", group = GRP_STYLE)
showProgress = input.bool(true, "Learning Progress Label", group = GRP_STYLE)
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0a0d15, 8)
var color THEME_TXT  = #d2dae8
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff
var color THEME_GOLD = #f4c25b

var int A_LONG  = 0
var int A_SHORT = 1
var int A_FLAT  = 2

// head indices
var int H_TREND = 0
var int H_MR    = 1
var int H_BRK   = 2
var int N_HEAD  = 3

f_actColor(int a) =>
    a == A_LONG ? colLong : a == A_SHORT ? colShort : colNeutral

f_actName(int a) =>
    a == A_LONG ? "LONG" : a == A_SHORT ? "SHORT" : "FLAT"

f_headName(int h) =>
    h == H_TREND ? "TREND" : h == H_MR ? "MEAN-REV" : "BREAKOUT"

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

f_softmax3(float a, float b, float c) =>
    float m = math.max(a, math.max(b, c))
    float ea = math.exp(a - m)
    float eb = math.exp(b - m)
    float ec = math.exp(c - m)
    float s = ea + eb + ec
    [ea / s, eb / s, ec / s]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  STATE ENCODER
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(14)
basis   = ta.sma(close, bbLen)
dev     = ta.stdev(close, bbLen)
hh      = ta.highest(high, bbLen)
ll      = ta.lowest(low, bbLen)

f_znorm(float v, float meanV, float stdV) =>
    stdV == 0 ? 0.0 : math.max(-3.0, math.min(3.0, (v - meanV) / stdV))

rawMom = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawRsi = (rsi - 50.0) / 50.0
rawBb  = dev == 0 ? 0.0 : (close - basis) / (2.0 * dev)
rawPos = (hh - ll) == 0 ? 0.0 : (close - ll) / (hh - ll) * 2.0 - 1.0

s0 = f_znorm(rawMom, ta.sma(rawMom, normLen), ta.stdev(rawMom, normLen))
s1 = rawRsi
s2 = math.max(-3.0, math.min(3.0, rawBb))
s3 = rawPos

var int N_IN  = 4
var int N_OUT = 3

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  THREE COMPETING ACTOR-CRITIC HEADS
//  Each head = shared-style trunk(tanh) → actor logits(3) + critic value(1). Distinct weights so
//  each specializes. We bias each head's *reward* toward its style so they diverge in behavior.
//  Stored as one big flat array per matrix, indexed by head.
// ════════════════════════════════════════════════════════════════════════════════════════════════

// per head: W1[hiddenN x N_IN], b1[hiddenN], Wp[N_OUT x hiddenN], bp[N_OUT], Wv[hiddenN], bv[1]
var int HID = 6   // fixed compact hidden width for the Lite build

var array<float> W1 = na
var array<float> b1 = na
var array<float> Wp = na
var array<float> bp = na
var array<float> Wv = na
var array<float> bv = na
var array<float> headScore = na   // running performance score per head
var array<float> headTrust = na   // softmax-ish trust weight per head
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(N_HEAD * HID * N_IN, 0.0)
    b1 := array.new_float(N_HEAD * HID, 0.0)
    Wp := array.new_float(N_HEAD * N_OUT * HID, 0.0)
    bp := array.new_float(N_HEAD * N_OUT, 0.0)
    Wv := array.new_float(N_HEAD * HID, 0.0)
    bv := array.new_float(N_HEAD, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.7)
    f_initRange(Wp, seedInp * 40503 + 101, 0.7)
    f_initRange(Wv, seedInp * 92821 + 202, 0.7)
    headScore := array.new_float(N_HEAD, 0.0)
    headTrust := array.new_float(N_HEAD, 1.0 / N_HEAD)
    netInit := true

// forward pass for a given head → [p0,p1,p2, value]; caches hidden in hC
f_head(int head, float i0, float i1, float i2, float i3, array<float> hC) =>
    array.clear(hC)
    int w1Base = head * HID * N_IN
    int b1Base = head * HID
    for h = 0 to HID - 1
        float z = array.get(b1, b1Base + h)
        z += array.get(W1, w1Base + h * N_IN + 0) * i0
        z += array.get(W1, w1Base + h * N_IN + 1) * i1
        z += array.get(W1, w1Base + h * N_IN + 2) * i2
        z += array.get(W1, w1Base + h * N_IN + 3) * i3
        array.push(hC, f_tanh(z))
    int wpBase = head * N_OUT * HID
    int bpBase = head * N_OUT
    int wvBase = head * HID
    float l0 = array.get(bp, bpBase + 0)
    float l1 = array.get(bp, bpBase + 1)
    float l2 = array.get(bp, bpBase + 2)
    float val = array.get(bv, head)
    for h = 0 to HID - 1
        float hv = array.get(hC, h)
        l0 += array.get(Wp, wpBase + 0 * HID + h) * hv
        l1 += array.get(Wp, wpBase + 1 * HID + h) * hv
        l2 += array.get(Wp, wpBase + 2 * HID + h) * hv
        val += array.get(Wv, wvBase + h) * hv
    [p0, p1, p2] = f_softmax3(l0, l1, l2)
    [p0, p1, p2, val]

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  PRIORITIZED REPLAY BUFFER
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> bS0 = array.new_float()
var array<float> bS1 = array.new_float()
var array<float> bS2 = array.new_float()
var array<float> bS3 = array.new_float()
var array<int>   bAct = array.new_int()
var array<float> bN0 = array.new_float()
var array<float> bN1 = array.new_float()
var array<float> bN2 = array.new_float()
var array<float> bN3 = array.new_float()
var array<float> bR0 = array.new_float()   // reward for head 0 (trend)
var array<float> bR1 = array.new_float()   // reward for head 1 (mean-rev)
var array<float> bR2 = array.new_float()   // reward for head 2 (breakout)
var array<float> bPri = array.new_float()

f_push(float ps0, float ps1, float ps2, float ps3, int a, float n0, float n1, float n2, float n3, float r0, float r1, float r2, float pri) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bAct, a)
    array.push(bN0, n0)
    array.push(bN1, n1)
    array.push(bN2, n2)
    array.push(bN3, n3)
    array.push(bR0, r0)
    array.push(bR1, r1)
    array.push(bR2, r2)
    array.push(bPri, pri)
    if array.size(bAct) > bufferCap
        array.shift(bS0)
        array.shift(bS1)
        array.shift(bS2)
        array.shift(bS3)
        array.shift(bAct)
        array.shift(bN0)
        array.shift(bN1)
        array.shift(bN2)
        array.shift(bN3)
        array.shift(bR0)
        array.shift(bR1)
        array.shift(bR2)
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

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  STYLE-SPECIFIC REWARDS  — each head is rewarded for the behavior it specializes in
// ════════════════════════════════════════════════════════════════════════════════════════════════

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]
// regime cues sampled at the decision bar
trendStrength = math.abs(rawMom)            // strong = trend regime
stretch = math.abs(rawBb)                   // far from mean = mean-reversion opportunity
nearEdge = (math.max(hh - close, close - ll)) / (atr == 0 ? 1.0 : atr)   // near range edge = breakout setup

// base directional reward given an action
f_baseReward(int a, float ret, float atrRef) =>
    float baseRet = atrRef != 0 ? (ret * close[rewardLook]) / atrRef : ret
    a == A_LONG ? baseRet : a == A_SHORT ? -baseRet : 0.0

// per-head reward shaping: amplify the reward in the regime each head specializes in
f_headReward(int head, int a, float baseR, float tStr, float stre, float edge) =>
    float mult = 1.0
    if head == H_TREND
        mult := 1.0 + 0.6 * math.min(2.0, tStr)        // rewarded more in strong trends
    else if head == H_MR
        mult := 1.0 + 0.6 * math.min(2.0, stre)        // rewarded more when stretched from mean
    else
        mult := 1.0 + 0.6 * math.max(0.0, 1.5 - edge)  // rewarded more near range edges (breakout zone)
    math.max(-5.0, math.min(5.0, baseR * mult))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRAINING STEP  — advantage-weighted policy gradient + critic regression, per head
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()
var array<float> hNx = array.new_float()

f_trainHead(int head, int idx, float headR) =>
    if array.size(bAct) > 0
        float ps0 = array.get(bS0, idx)
        float ps1 = array.get(bS1, idx)
        float ps2 = array.get(bS2, idx)
        float ps3 = array.get(bS3, idx)
        int   a   = array.get(bAct, idx)
        float nx0 = array.get(bN0, idx)
        float nx1 = array.get(bN1, idx)
        float nx2 = array.get(bN2, idx)
        float nx3 = array.get(bN3, idx)

        [p0, p1, p2, val] = f_head(head, ps0, ps1, ps2, ps3, hTr)
        [np0, np1, np2, nVal] = f_head(head, nx0, nx1, nx2, nx3, hNx)
        float adv = math.max(-5.0, math.min(5.0, (headR + gamma * nVal) - val))
        float H = -(p0*math.log(math.max(p0,1e-6)) + p1*math.log(math.max(p1,1e-6)) + p2*math.log(math.max(p2,1e-6)))

        int w1Base = head * HID * N_IN
        int b1Base = head * HID
        int wpBase = head * N_OUT * HID
        int bpBase = head * N_OUT
        int wvBase = head * HID

        // actor logit gradients
        gLog = array.new_float(N_OUT, 0.0)
        for j = 0 to N_OUT - 1
            float pj = j == 0 ? p0 : j == 1 ? p1 : p2
            float dLogP = (j == a ? 1.0 : 0.0) - pj
            float gEnt = -pj * (math.log(math.max(pj,1e-6)) + H)
            array.set(gLog, j, math.max(-5.0, math.min(5.0, -(adv * dLogP) - 0.01 * gEnt)))

        float vErr = math.max(-5.0, math.min(5.0, val - (headR + gamma * nVal)))

        gHidden = array.new_float(HID, 0.0)
        for j = 0 to N_OUT - 1
            float gj = array.get(gLog, j)
            for h = 0 to HID - 1
                int wi = wpBase + j * HID + h
                array.set(gHidden, h, array.get(gHidden, h) + gj * array.get(Wp, wi))
                array.set(Wp, wi, array.get(Wp, wi) - learnRate * gj * array.get(hTr, h))
            array.set(bp, bpBase + j, array.get(bp, bpBase + j) - learnRate * gj)
        for h = 0 to HID - 1
            array.set(gHidden, h, array.get(gHidden, h) + vErr * array.get(Wv, wvBase + h))
            array.set(Wv, wvBase + h, array.get(Wv, wvBase + h) - learnRate * vErr * array.get(hTr, h))
        array.set(bv, head, array.get(bv, head) - learnRate * vErr)
        for h = 0 to HID - 1
            float dz = array.get(gHidden, h) * f_dtanh(array.get(hTr, h))
            array.set(W1, w1Base + h * N_IN + 0, array.get(W1, w1Base + h * N_IN + 0) - learnRate * dz * ps0)
            array.set(W1, w1Base + h * N_IN + 1, array.get(W1, w1Base + h * N_IN + 1) - learnRate * dz * ps1)
            array.set(W1, w1Base + h * N_IN + 2, array.get(W1, w1Base + h * N_IN + 2) - learnRate * dz * ps2)
            array.set(W1, w1Base + h * N_IN + 3, array.get(W1, w1Base + h * N_IN + 3) - learnRate * dz * ps3)
            array.set(b1, b1Base + h, array.get(b1, b1Base + h) - learnRate * dz)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT STEP
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hT = array.new_float()
var array<float> hM = array.new_float()
var array<float> hB = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var int   pAct = na
var float pTStr = na
var float pStre = na
var float pEdge = na

var int   chosen = A_FLAT
var int   bestHead = H_TREND
var float compScore = 0.0
var float scoreEma = na
var int   trainedBars = 0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    trainedBars := trainedBars + 1

    if not na(pAct)
        float baseR = f_baseReward(pAct, fwdRet, atrPast)
        float r0 = f_headReward(H_TREND, pAct, baseR, pTStr, pStre, pEdge)
        float r1 = f_headReward(H_MR,    pAct, baseR, pTStr, pStre, pEdge)
        float r2 = f_headReward(H_BRK,   pAct, baseR, pTStr, pStre, pEdge)
        float pri = math.pow(math.abs(baseR) + 0.01, priorityExp)
        f_push(pS0, pS1, pS2, pS3, pAct, s0, s1, s2, s3, r0, r1, r2, pri)

        // update each head's running performance score (reward-weighted), then re-allocate trust
        array.set(headScore, H_TREND, headMomentum * array.get(headScore, H_TREND) + (1.0 - headMomentum) * r0)
        array.set(headScore, H_MR,    headMomentum * array.get(headScore, H_MR)    + (1.0 - headMomentum) * r1)
        array.set(headScore, H_BRK,   headMomentum * array.get(headScore, H_BRK)   + (1.0 - headMomentum) * r2)
        // trust via softmax over scores (sharpened by headAdapt as temperature)
        [w0, w1c, w2] = f_softmax3(array.get(headScore,H_TREND)/math.max(headAdapt,0.01), array.get(headScore,H_MR)/math.max(headAdapt,0.01), array.get(headScore,H_BRK)/math.max(headAdapt,0.01))
        array.set(headTrust, H_TREND, w0)
        array.set(headTrust, H_MR, w1c)
        array.set(headTrust, H_BRK, w2)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int idx = f_sampleIdx(seed)
        if array.size(bAct) > 0
            f_trainHead(H_TREND, idx, array.get(bR0, idx))
            f_trainHead(H_MR,    idx, array.get(bR1, idx))
            f_trainHead(H_BRK,   idx, array.get(bR2, idx))

// ---- DECISION (every bar incl. realtime): heads compete, trust-weighted vote ----
if inHorizon
    [t0, t1, t2, tVal] = f_head(H_TREND, s0, s1, s2, s3, hT)
    [m0, m1, m2, mVal] = f_head(H_MR,    s0, s1, s2, s3, hM)
    [k0, k1, k2, kVal] = f_head(H_BRK,   s0, s1, s2, s3, hB)

    float wt = array.get(headTrust, H_TREND)
    float wm = array.get(headTrust, H_MR)
    float wk = array.get(headTrust, H_BRK)

    // trust-weighted blended policy
    float pLong  = wt * t0 + wm * m0 + wk * k0
    float pShort = wt * t1 + wm * m1 + wk * k1
    float pFlat  = wt * t2 + wm * m2 + wk * k2

    float pmax = math.max(pLong, math.max(pShort, pFlat))
    chosen := pLong == pmax ? A_LONG : pShort == pmax ? A_SHORT : A_FLAT

    // which head is currently most trusted
    float tmax = math.max(wt, math.max(wm, wk))
    bestHead := wt == tmax ? H_TREND : wm == tmax ? H_MR : H_BRK

    if barstate.isconfirmed
        int eseed = (bar_index * 2246822519 + seedInp) % 2147483647
        if f_rand(eseed) < epsilon
            int rseed = (bar_index * 3266489917 + 11) % 2147483647
            chosen := int(f_rand(rseed) * 3) % 3

    // composite score = decisiveness of the blended policy
    float phi = pmax
    float plo = math.min(pLong, math.min(pShort, pFlat))
    float pmid = (pLong + pShort + pFlat) - phi - plo
    compScore := (phi - plo) == 0 ? 0.0 : (phi - pmid) / (phi - plo)
    scoreEma := na(scoreEma) ? compScore : (compScore * 0.4 + scoreEma * 0.6)

    if barstate.isconfirmed
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := chosen
        pTStr := trendStrength
        pStre := stretch
        pEdge := nearEdge

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — intentionally minimal
// ════════════════════════════════════════════════════════════════════════════════════════════════

float score = na(scoreEma) ? 0.0 : scoreEma
bool gateOk = score >= sigGate
color sigCol = f_actColor(chosen)

var int lastSig = na
bool sigChanged = na(lastSig) or chosen != lastSig
bool fireBase = inHorizon and barstate.isconfirmed and chosen != A_FLAT and gateOk
bool fire = oncePerMove ? (fireBase and sigChanged) : fireBase
bool fireLong  = fire and chosen == A_LONG
bool fireShort = fire and chosen == A_SHORT

if inHorizon and barstate.isconfirmed and chosen != A_FLAT and gateOk
    lastSig := chosen

// --- one main signal arrow (with optional glow) ---
plotshape(fireLong and glowFx,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 72),  size = size.normal, force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 72), size = size.normal, force_overlay = true)
plotshape(fireLong,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.small, force_overlay = true)
plotshape(fireShort, title = "Short", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.small, force_overlay = true)

// --- one forward prediction line: projects price by score-scaled directional drift ---
var line predLine = na
if showPred and inHorizon and barstate.islast
    if not na(predLine)
        line.delete(predLine)
    float dirSign = chosen == A_LONG ? 1.0 : chosen == A_SHORT ? -1.0 : 0.0
    float drift = dirSign * score * atr * (predLook / 2.0)
    float yEnd = close + drift
    predLine := line.new(bar_index, close, bar_index + predLook, yEnd, xloc = xloc.bar_index, color = color.new(sigCol, 10), width = 2, style = line.style_arrow_right)

// --- small composite score label ---
var label scoreLbl = na
if showScore and inHorizon and barstate.islast
    if not na(scoreLbl)
        label.delete(scoreLbl)
    scoreLbl := label.new(bar_index, close, "  " + f_actName(chosen) + "  ·  " + str.tostring(math.round(score * 100)) + "%  ",
         xloc = xloc.bar_index, yloc = yloc.price,
         style = label.style_label_left, color = color.new(sigCol, 8), textcolor = #0a0d15, size = size.normal)

// --- "Learning Progress" label: visualizes the agent's evolution ---
var label progLbl = na
if showProgress and barstate.islast
    if not na(progLbl)
        label.delete(progLbl)
    // progress proxy: training maturity (bars seen) + buffer fill + decisiveness of best head's trust
    float maturity = math.min(1.0, trainedBars / math.max(1.0, trainLen * 0.5))
    float bufFill = math.min(1.0, array.size(bAct) / math.max(1.0, bufferCap))
    float trustTop = array.max(headTrust)
    float decisive = (trustTop - 1.0 / N_HEAD) / (1.0 - 1.0 / N_HEAD)
    float progress = math.min(1.0, 0.4 * maturity + 0.3 * bufFill + 0.3 * decisive)
    int pct = int(math.round(progress * 100))
    // build a compact progress bar string
    int filled = int(math.round(progress * 10))
    string barStr = ""
    for i = 1 to 10
        barStr := barStr + (i <= filled ? "█" : "░")
    color pc = progress >= 0.66 ? colLong : progress >= 0.33 ? THEME_GOLD : THEME_DIM
    string txt = "◆ LEARNING  " + barStr + "  " + str.tostring(pct) + "%   ▸ best head: " + f_headName(bestHead)
    progLbl := label.new(bar_index, high, txt,
         xloc = xloc.bar_index, yloc = yloc.abovebar,
         style = label.style_label_down, color = color.new(THEME_BG, 0), textcolor = pc, size = size.normal,
         force_overlay = true)

// glow accent on strong-score bars
plot(glowFx and inHorizon and score > sigGate * 1.4 ? close : na, "Score Glow", color = color.new(sigCol, 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(fireLong,  "RL ▸ LONG",  "AetherEdge Self-Evolving RL: composite LONG signal.")
alertcondition(fireShort, "RL ▸ SHORT", "AetherEdge Self-Evolving RL: composite SHORT signal.")
````
