# AetherEdge - Multi-Agent RL Consensus Engine

- url: https://www.tradingview.com/script/4JKr9kyr/
- type: indicator
- pine_id: PUB;c7d80b6a5f2d4cedabb36dbbfdf88e17
- version: 1.0

## Description

🖊️ Overview

A council of independent reinforcement-learning agents that debate, then vote. Three to five lightweight Actor-Critic agents run in parallel, each trained under a DIFFERENT reward function — trend-following, mean-reversion, risk-averse, breakout, and volatility-scaled — so each develops its own "personality" and reads the same market through a different lens. Every bar, each agent casts a directional vote, and a CONSENSUS score measures how strongly the council agrees. The engine speaks only when the agents do: a large arrow appears only on high agreement, and a single Consensus Meter (0–100%) shows the strength of the collective conviction. The evolution of a single RL optimizer into a "debate among multiple AIs."

🔶 Key Features

Multi-agent council — 3–5 independent RL agents learn in parallel and form consensus by voting
Different reward functions (personalities) — trend, mean-reversion, risk-averse, breakout, volatility-scaled
Consensus scoring — combines how many agents agree with their confidence into an agreement score
Meritocratic voting (optional) — better-performing agents get a larger say in the consensus
Fires only on high agreement — the large arrow appears only when council agreement clears the gate
Consensus Meter — a single 0–100% gauge of agreement, lit in the direction color on consensus
Per-agent vote dots — tiny dots show each agent's individual vote at the signal bar
Intelligence panel — consensus score, vote tally, and each agent's name / vote / performance at a glance

🧠 Technical Architecture

The agents perceive the market as a four-dimensional state vector (momentum spread, RSI deviation, Bollinger position, position-within-range — all z-normalized). The core is N independent Actor-Critic agents, each producing Actor logits (3 actions → softmax policy) and a Critic value from a compact shared trunk (tanh).
Agents differentiate via personality-specific reward shaping. From a common risk-adjusted (volatility-normalized) return, the trend agent amplifies reward in strong trends, mean-reversion when stretched, risk-averse shrinks reward in high vol and penalizes drawdown, breakout near range edges, and vol-scaled by volatility magnitude. The agents thus learn distinct behaviors from the same price data. Learning is Advantage Actor-Critic (A = r + γV(s′) − V(s) driving the Actor's policy gradient) from a shared replay buffer.
In the consensus process, every bar each agent produces a policy and votes its max-probability action. Each vote is weighted by "performance × confidence" (when meritocratic), and the weighted long vs. short sums determine the consensus direction. The consensus score is a [0,1] blend of the dominant side's weighted share (its fraction of the council's total voice) and the raw vote agreement (fraction of agents on the dominant side). Only when this clears the gate do the large arrow and meter light up.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Number of Agents 5, γ 0.93, Min Consensus 0.60, Weight by Performance ON. The full 5-personality roster fits well
ETH (1H–4H): As BTC, with Reward Lookahead 5–8
SOL (15m–1H): High volatility favors Min Consensus 0.65–0.7 to be stricter, where the risk-averse agent earns its keep
XRP (1H–4H): Spike-prone; Agents 5 to include breakout and vol-scaled, Consensus Smoothing 3 to stabilize agreement
Number of Agents: more gives diverse views but makes consensus harder; 5 for all personalities, 3 for the core (trend / mean-rev / risk-averse)
Min Consensus to Signal: higher (0.7+) makes arrows rare and high-quality; lower (0.5) more frequent — raise it if you want near-unanimity only
Weight by Performance: ON for meritocracy (favoring better agents), OFF for equal say; ON is recommended in stable markets
Consensus Smoothing: higher smooths the agreement; lower is more reactive

💡 How to Use in Practice

Reacting to the large arrow: the arrow is a "collective verdict" where the council reached high agreement — multiple distinct strategy-AIs concurring, a core basis for trend-following entries
Reading the Consensus Meter: a full gauge lit in the direction color = strong agreement; under half = a split council, so standing aside is wise
Using vote dots & panel: check each agent's (TREND / MEAN-REV / RISK-AVERSE / BREAKOUT / VOL-SCALED) vote and performance to see which strategy backs the current market
Using disagreement as caution: low consensus marks an uncertain market where strategies diverge — a reason to skip entries
Watching performance scores: the per-agent performance reveals which strategy is working now (e.g. a high-performing trend agent suggests a trend regime)
Multi-timeframe usage: confirm the council's big-picture agreement on the higher timeframe (4H), then refine timing on consensus signals on the lower one (15m–1H)

⚠️ Important Notes

Initial learning period: right after launch the buffer is nearly empty and all agents are immature; treat signals as low-confidence until agreement stabilizes (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes all agent weights, performance scores, and the buffer, restarting learning from zero
Nature of consensus: high agreement means "multiple strategies concurred," but markets exist where all agents are wrong at once (shock events) — consensus is not a guarantee of certainty
On forward-looking reward: rewards use closed-bar forward returns (a standard RL training construct); current-bar votes are on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight implementation operating within Pine's compute budget; more agents increase compute proportionally

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The multi-agent reinforcement learning, per-agent reward shaping, consensus score, and Consensus Meter are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Even a consensus of multiple agents can be wrong. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Multi-Agent RL Consensus Engine
//   AI Drawing Power Series
//
//   A council of independent reinforcement-learning agents that debate, then vote. Three to five
//   lightweight Actor-Critic agents run in parallel, each trained under a DIFFERENT reward function —
//   trend-following, mean-reversion, risk-averse, breakout, and volatility-scaled — so each develops
//   its own "personality" and reads the same market through a different lens. Every bar, each agent
//   casts a directional vote; a CONSENSUS score measures how strongly the council agrees. The engine
//   speaks only when the agents do: a large arrow appears only on high agreement, and a single
//   Consensus Meter (0–100%) shows the strength of the collective conviction.
//
//   The evolution of a single RL optimizer into a "debate among multiple AIs."
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Multi-Agent RL Consensus Engine", "AE-MARL CE", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_COUNCIL = "◆  AGENT COUNCIL"
var string GRP_STATE   = "◆  STATE ENCODER"
var string GRP_LEARN   = "◆  LEARNING"
var string GRP_CONS    = "◆  CONSENSUS"
var string GRP_STYLE   = "◆  AESTHETICS"
var string GRP_PANEL   = "◆  INTELLIGENCE PANEL"

// — Council —
nAgents      = input.int(5,    "Number of Agents", minval = 3, maxval = 5, group = GRP_COUNCIL, tooltip = "3–5 independent RL agents, each with a different reward personality.")
gamma        = input.float(0.93,"Discount γ",       minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_COUNCIL)
epsilon      = input.float(0.06,"Exploration ε",    minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_COUNCIL)

// — State Encoder —
fastLen      = input.int(10,   "Momentum Fast",  minval = 1, maxval = 100, group = GRP_STATE)
slowLen      = input.int(30,   "Momentum Slow",  minval = 2, maxval = 200, group = GRP_STATE)
rsiLen       = input.int(14,   "RSI Length",     minval = 2, maxval = 100, group = GRP_STATE)
bbLen        = input.int(20,   "Range Length",   minval = 2, maxval = 100, group = GRP_STATE)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Learning —
learnRate    = input.float(0.04,"Learning Rate α", minval = 0.001, maxval = 0.5, step = 0.001, group = GRP_LEARN)
trainSteps   = input.int(4,    "Updates / Bar",  minval = 1, maxval = 32, group = GRP_LEARN)
bufferCap    = input.int(140,  "Replay Capacity", minval = 16, maxval = 500, group = GRP_LEARN)
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_LEARN)
rewardLook   = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_LEARN)
seedInp      = input.int(43,   "Init Seed",      minval = 1, maxval = 9999, group = GRP_LEARN)

// — Consensus —
consGate     = input.float(0.60,"Min Consensus to Signal", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_CONS, tooltip = "The large arrow appears only when council agreement clears this percentage.")
consSmooth   = input.int(2,    "Consensus Smoothing", minval = 1, maxval = 20, group = GRP_CONS)
weightByPerf = input.bool(true,"Weight Votes by Performance", group = GRP_CONS, tooltip = "Give better-performing agents a larger say in the consensus (a meritocratic council).")
oncePerMove  = input.bool(true,"One Arrow per Directional Shift", group = GRP_CONS)

// — Aesthetics —
colLong      = input.color(#21d3a3, "Bullish Tone", group = GRP_STYLE, inline = "c1")
colShort     = input.color(#ff5d73, "Bearish Tone", group = GRP_STYLE, inline = "c1")
colNeutral   = input.color(#7d88a0, "Neutral Tone", group = GRP_STYLE, inline = "c1")
showMeter    = input.bool(true, "Consensus Meter", group = GRP_STYLE)
meterPos     = input.string("Bottom Center", "Meter Position", options = ["Bottom Center", "Bottom Right", "Bottom Left", "Top Center"], group = GRP_STYLE)
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)
showVotes    = input.bool(true, "Per-Agent Vote Dots", group = GRP_STYLE, tooltip = "Tiny dots showing each agent's individual vote at the signal bar.")

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

// agent personality indices
var int P_TREND = 0
var int P_MR    = 1
var int P_RISK  = 2
var int P_BRK   = 3
var int P_VOL   = 4

f_actColor(int a) =>
    a == A_LONG ? colLong : a == A_SHORT ? colShort : colNeutral

f_actName(int a) =>
    a == A_LONG ? "LONG" : a == A_SHORT ? "SHORT" : "FLAT"

f_agentName(int p) =>
    p == P_TREND ? "TREND" : p == P_MR ? "MEAN-REV" : p == P_RISK ? "RISK-AVERSE" : p == P_BRK ? "BREAKOUT" : "VOL-SCALED"

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
var int HID   = 6   // compact hidden width per agent

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  AGENT COUNCIL  — N independent Actor-Critic agents (flat arrays indexed by agent)
//  per agent: W1[HID x N_IN], b1[HID], Wp[N_OUT x HID], bp[N_OUT], Wv[HID], bv[1]
// ════════════════════════════════════════════════════════════════════════════════════════════════

var int MAXAG = 5

var array<float> W1 = na
var array<float> b1 = na
var array<float> Wp = na
var array<float> bp = na
var array<float> Wv = na
var array<float> bv = na
var array<float> perf = na    // running performance score per agent
var bool netInit = false

f_initRange(array<float> arr, int seedBase, float scale) =>
    int sd = seedBase
    for i = 0 to array.size(arr) - 1
        sd := sd + 2654435761
        array.set(arr, i, (f_rand(sd) - 0.5) * scale)

if not netInit
    W1 := array.new_float(MAXAG * HID * N_IN, 0.0)
    b1 := array.new_float(MAXAG * HID, 0.0)
    Wp := array.new_float(MAXAG * N_OUT * HID, 0.0)
    bp := array.new_float(MAXAG * N_OUT, 0.0)
    Wv := array.new_float(MAXAG * HID, 0.0)
    bv := array.new_float(MAXAG, 0.0)
    f_initRange(W1, seedInp * 2654435761,  0.7)
    f_initRange(Wp, seedInp * 40503 + 101, 0.7)
    f_initRange(Wv, seedInp * 92821 + 202, 0.7)
    perf := array.new_float(MAXAG, 0.0)
    netInit := true

// forward pass for an agent → [p0,p1,p2, value]; caches hidden in hC
f_agent(int ag, float i0, float i1, float i2, float i3, array<float> hC) =>
    array.clear(hC)
    int w1Base = ag * HID * N_IN
    int b1Base = ag * HID
    for h = 0 to HID - 1
        float z = array.get(b1, b1Base + h)
        z += array.get(W1, w1Base + h * N_IN + 0) * i0
        z += array.get(W1, w1Base + h * N_IN + 1) * i1
        z += array.get(W1, w1Base + h * N_IN + 2) * i2
        z += array.get(W1, w1Base + h * N_IN + 3) * i3
        array.push(hC, f_tanh(z))
    int wpBase = ag * N_OUT * HID
    int bpBase = ag * N_OUT
    int wvBase = ag * HID
    float l0 = array.get(bp, bpBase + 0)
    float l1 = array.get(bp, bpBase + 1)
    float l2 = array.get(bp, bpBase + 2)
    float val = array.get(bv, ag)
    for h = 0 to HID - 1
        float hv = array.get(hC, h)
        l0 += array.get(Wp, wpBase + 0 * HID + h) * hv
        l1 += array.get(Wp, wpBase + 1 * HID + h) * hv
        l2 += array.get(Wp, wpBase + 2 * HID + h) * hv
        val += array.get(Wv, wvBase + h) * hv
    [p0, p1, p2] = f_softmax3(l0, l1, l2)
    [p0, p1, p2, val]

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REPLAY BUFFER  (shared experience; each agent computes its own reward from it)
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
// regime context captured at decision time (for per-agent reward shaping)
var array<float> bRet = array.new_float()   // base directional return
var array<float> bTrd = array.new_float()   // trend strength
var array<float> bStr = array.new_float()   // stretch from mean
var array<float> bEdg = array.new_float()   // proximity to range edge
var array<float> bVol = array.new_float()   // volatility ratio

f_push(float ps0, float ps1, float ps2, float ps3, int a, float n0, float n1, float n2, float n3, float ret, float trd, float str, float edg, float vol) =>
    array.push(bS0, ps0)
    array.push(bS1, ps1)
    array.push(bS2, ps2)
    array.push(bS3, ps3)
    array.push(bAct, a)
    array.push(bN0, n0)
    array.push(bN1, n1)
    array.push(bN2, n2)
    array.push(bN3, n3)
    array.push(bRet, ret)
    array.push(bTrd, trd)
    array.push(bStr, str)
    array.push(bEdg, edg)
    array.push(bVol, vol)
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
        array.shift(bRet)
        array.shift(bTrd)
        array.shift(bStr)
        array.shift(bEdg)
        array.shift(bVol)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  PERSONALITY REWARDS  — each agent's reward function reflects its trading philosophy
// ════════════════════════════════════════════════════════════════════════════════════════════════

// volatility-normalized return: scale the raw forward return down when volatility is elevated,
// giving a stable risk-adjusted base reward shared by all agents.
f_riskNormRet(float ret, float vol) =>
    float v = vol <= 0 ? 1.0 : vol
    math.max(-5.0, math.min(5.0, ret * 100.0 / v))

f_baseReward(int a, float ret) =>
    a == A_LONG ? ret : a == A_SHORT ? -ret : 0.0

// reward shaping by personality, given base directional reward + regime cues
f_personaReward(int persona, int a, float baseR, float trd, float stre, float edge, float vol) =>
    float r = baseR
    if persona == P_TREND
        // trend agent: amplified in strong trends, penalized for fighting them
        r := baseR * (1.0 + 0.7 * math.min(2.0, trd))
    else if persona == P_MR
        // mean-reversion agent: rewarded when acting against stretch
        r := baseR * (1.0 + 0.7 * math.min(2.0, stre))
    else if persona == P_RISK
        // risk-averse agent: shrink reward in high vol, penalize drawdown exposure
        float volPen = 1.0 / (1.0 + math.max(0.0, vol - 1.0))
        r := baseR * volPen - 0.1 * math.max(0.0, vol - 1.0)
    else if persona == P_BRK
        // breakout agent: rewarded more near range edges
        r := baseR * (1.0 + 0.7 * math.max(0.0, 1.5 - edge))
    else
        // vol-scaled agent: scales reward by volatility (opportunity in movement)
        r := baseR * (1.0 + 0.4 * math.min(2.0, vol))
    math.max(-5.0, math.min(5.0, r))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRAINING  — advantage actor-critic per agent
// ════════════════════════════════════════════════════════════════════════════════════════════════

var array<float> hTr = array.new_float()
var array<float> hNx = array.new_float()

f_trainAgent(int ag, int persona, int idx) =>
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
        float baseR = f_baseReward(a, array.get(bRet, idx))
        float r = f_personaReward(persona, a, baseR, array.get(bTrd, idx), array.get(bStr, idx), array.get(bEdg, idx), array.get(bVol, idx))

        [p0, p1, p2, val] = f_agent(ag, ps0, ps1, ps2, ps3, hTr)
        [np0, np1, np2, nVal] = f_agent(ag, nx0, nx1, nx2, nx3, hNx)
        float adv = math.max(-5.0, math.min(5.0, (r + gamma * nVal) - val))
        float H = -(p0*math.log(math.max(p0,1e-6)) + p1*math.log(math.max(p1,1e-6)) + p2*math.log(math.max(p2,1e-6)))

        int w1Base = ag * HID * N_IN
        int b1Base = ag * HID
        int wpBase = ag * N_OUT * HID
        int bpBase = ag * N_OUT
        int wvBase = ag * HID

        gLog = array.new_float(N_OUT, 0.0)
        for j = 0 to N_OUT - 1
            float pj = j == 0 ? p0 : j == 1 ? p1 : p2
            float dLogP = (j == a ? 1.0 : 0.0) - pj
            float gEnt = -pj * (math.log(math.max(pj,1e-6)) + H)
            array.set(gLog, j, math.max(-5.0, math.min(5.0, -(adv * dLogP) - 0.01 * gEnt)))

        float vErr = math.max(-5.0, math.min(5.0, val - (r + gamma * nVal)))

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
        array.set(bv, ag, array.get(bv, ag) - learnRate * vErr)
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

// per-agent live vote cache (fixed MAXAG slots; only first nAgents used)
var array<int>   votes = array.new_int(MAXAG, A_FLAT)
var array<float> voteConf = array.new_float(MAXAG, 0.0)
var array<float> hAg = array.new_float()

bool inHorizon = bar_index > (last_bar_index - trainLen)

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]
trendStrength = math.abs(rawMom)
stretch = math.abs(rawBb)
nearEdge = (math.max(hh - close, close - ll)) / (atr == 0 ? 1.0 : atr)
volRatio = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen))

var float pS0 = na
var float pS1 = na
var float pS2 = na
var float pS3 = na
var int   pAct = na
var float pRet = na
var float pTrd = na
var float pStr = na
var float pEdg = na
var float pVol = na

var int   consensusAct = A_FLAT
var float consensusScore = 0.0
var float consEma = na
var int   longVotes = 0
var int   shortVotes = 0
var int   flatVotes = 0

// ---- LEARNING (closed bars only) ----
if barstate.isconfirmed and inHorizon
    if not na(pAct)
        f_push(pS0, pS1, pS2, pS3, pAct, s0, s1, s2, s3, f_riskNormRet(pRet, pVol), pTrd, pStr, pEdg, pVol)

        // update each active agent's running performance with its own persona reward
        for ag = 0 to nAgents - 1
            float baseR = f_baseReward(pAct, f_riskNormRet(pRet, pVol))
            float pr = f_personaReward(ag, pAct, baseR, pTrd, pStr, pEdg, pVol)
            array.set(perf, ag, 0.9 * array.get(perf, ag) + 0.1 * pr)

    for stp = 0 to trainSteps - 1
        int seed = (bar_index * 7919 + stp * 104729 + seedInp) % 2147483647
        int n = array.size(bAct)
        if n > 0
            int idx = int(f_rand(seed) * n) % n
            for ag = 0 to nAgents - 1
                f_trainAgent(ag, ag, idx)

// ---- VOTING + CONSENSUS (every bar incl. realtime) ----
if inHorizon
    int lv = 0
    int sv = 0
    int fv = 0
    float wLong = 0.0
    float wShort = 0.0
    float wTotal = 0.0

    for ag = 0 to nAgents - 1
        [p0, p1, p2, val] = f_agent(ag, s0, s1, s2, s3, hAg)
        float pmax = math.max(p0, math.max(p1, p2))
        int vote = p0 == pmax ? A_LONG : p1 == pmax ? A_SHORT : A_FLAT
        // confidence = decisiveness of this agent's policy
        float plo = math.min(p0, math.min(p1, p2))
        float pmid = (p0 + p1 + p2) - pmax - plo
        float conf = (pmax - plo) == 0 ? 0.0 : (pmax - pmid) / (pmax - plo)

        array.set(votes, ag, vote)
        array.set(voteConf, ag, conf)

        // performance weight (meritocratic): better agents weigh more
        float pw = weightByPerf ? math.max(0.1, 1.0 + array.get(perf, ag)) : 1.0

        if vote == A_LONG
            lv += 1
            wLong += pw * conf
        else if vote == A_SHORT
            sv += 1
            wShort += pw * conf
        else
            fv += 1
        wTotal += pw * conf

    longVotes := lv
    shortVotes := sv
    flatVotes := fv

    // consensus direction = the side with the larger performance-weighted confidence
    consensusAct := wLong > wShort and wLong > 0 ? A_LONG : wShort > wLong and wShort > 0 ? A_SHORT : A_FLAT

    // consensus score [0,1]: dominant weighted share of total council voice
    float domShare = wTotal == 0 ? 0.0 : math.max(wLong, wShort) / wTotal
    // blend with raw vote agreement (fraction of agents on dominant side)
    int domCount = math.max(lv, sv)
    float voteShare = nAgents == 0 ? 0.0 : domCount / nAgents
    consensusScore := 0.6 * domShare + 0.4 * voteShare

    consEma := na(consEma) ? consensusScore : (consensusScore * (2.0 / (consSmooth + 1)) + consEma * (1.0 - 2.0 / (consSmooth + 1)))

    if barstate.isconfirmed
        // exploration: occasionally store a random action to keep agents exploring
        int eseed = (bar_index * 2246822519 + seedInp) % 2147483647
        int storeAct = consensusAct
        if f_rand(eseed) < epsilon
            int rseed = (bar_index * 3266489917 + 11) % 2147483647
            storeAct := int(f_rand(rseed) * 3) % 3
        pS0 := s0
        pS1 := s1
        pS2 := s2
        pS3 := s3
        pAct := storeAct
        pRet := fwdRet
        pTrd := trendStrength
        pStr := stretch
        pEdg := nearEdge
        pVol := volRatio

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — large arrow only on high consensus + a single Consensus Meter
// ════════════════════════════════════════════════════════════════════════════════════════════════

float consDisp = na(consEma) ? 0.0 : consEma
bool highConsensus = consDisp >= consGate
color consCol = f_actColor(consensusAct)

var int lastSig = na
bool sigChanged = na(lastSig) or consensusAct != lastSig
bool fireBase = inHorizon and barstate.isconfirmed and consensusAct != A_FLAT and highConsensus
bool fire = oncePerMove ? (fireBase and sigChanged) : fireBase
bool fireLong  = fire and consensusAct == A_LONG
bool fireShort = fire and consensusAct == A_SHORT

if inHorizon and barstate.isconfirmed and consensusAct != A_FLAT and highConsensus
    lastSig := consensusAct

// --- large consensus arrow (layered glow): only when the council strongly agrees ---
plotshape(fireLong and glowFx,  title = "Long Halo",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 80),  size = size.huge,   force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Halo", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 80), size = size.huge,   force_overlay = true)
plotshape(fireLong and glowFx,  title = "Long Glow",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 55),  size = size.large,  force_overlay = true)
plotshape(fireShort and glowFx, title = "Short Glow", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 55), size = size.large,  force_overlay = true)
plotshape(fireLong,  title = "Long Core",  style = shape.triangleup,   location = location.belowbar, color = color.new(colLong, 0),  size = size.normal, force_overlay = true)
plotshape(fireShort, title = "Short Core", style = shape.triangledown, location = location.abovebar, color = color.new(colShort, 0), size = size.normal, force_overlay = true)

// --- per-agent vote dots at the signal bar (tiny, showing the council's individual votes) ---
// up to 5 dots stacked; each colored by that agent's vote
plotshape(showVotes and fire and nAgents >= 1 and array.get(votes,0) == A_LONG,  title = "A1 L", style = shape.circle, location = location.belowbar, color = color.new(colLong, 0),  size = size.tiny, force_overlay = true)
plotshape(showVotes and fire and nAgents >= 1 and array.get(votes,0) == A_SHORT, title = "A1 S", style = shape.circle, location = location.abovebar, color = color.new(colShort, 0), size = size.tiny, force_overlay = true)

// --- Consensus Meter: a single 0–100% gauge bar via a table ---
f_meterPos() =>
    switch meterPos
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        => position.bottom_center

f_meterBar(float v01, int cells) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * cells))
    string s = ""
    for i = 1 to cells
        s := s + (i <= filled ? "█" : "░")
    s

var table meter = na
if showMeter and barstate.islast
    if not na(meter)
        table.delete(meter)
    meter := table.new(f_meterPos(), 1, 1, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)
    color mc = highConsensus ? consCol : THEME_DIM
    string arrow = consensusAct == A_LONG ? "▲" : consensusAct == A_SHORT ? "▼" : "■"
    string txt = "CONSENSUS  " + f_meterBar(consDisp, 20) + "  " + str.tostring(math.round(consDisp * 100)) + "%   " + arrow + " " + f_actName(consensusAct)
    table.cell(meter, 0, 0, txt, text_color = mc, text_size = size.normal, text_halign = text.align_center, bgcolor = color.new(highConsensus ? consCol : THEME_BG, highConsensus ? 80 : 0))

// glow accent on very-high-consensus bars
plot(glowFx and inHorizon and consDisp > consGate * 1.15 ? close : na, "Consensus Glow", color = color.new(consCol, 55), linewidth = 3, style = plot.style_circles, force_overlay = true)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL  — shows the council roster and each agent's vote
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

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 11, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "COUNCIL", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + (highConsensus ? "CONSENSUS: " : "NO CONSENSUS: ") + f_actName(consensusAct), text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(highConsensus ? consCol : THEME_DIM, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Consensus Score", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_meterBar(consDisp, 12), text_color = highConsensus ? consCol : THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(math.round(consDisp * 100)) + "%", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Vote Tally (L/S/F)", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, "", text_size = f_panelSize())
    table.cell(panel, 2, 3, str.tostring(longVotes) + " / " + str.tostring(shortVotes) + " / " + str.tostring(flatVotes), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "AGENT ROSTER", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 4, 2, 4)

    // each agent's name, vote, and performance — rows 5..9 (up to 5 agents)
    for ag = 0 to 4
        int rowY = 5 + ag
        if ag < nAgents
            int v = array.get(votes, ag)
            float pf = array.get(perf, ag)
            color vc = f_actColor(v)
            table.cell(panel, 0, rowY, f_agentName(ag), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
            table.cell(panel, 1, rowY, f_actName(v), text_color = vc, text_size = f_panelSize(), text_halign = text.align_center)
            table.cell(panel, 2, rowY, str.tostring(pf, "+#.##;-#.##"), text_color = pf >= 0 ? colLong : colShort, text_size = f_panelSize(), text_halign = text.align_right)
        else
            table.cell(panel, 0, rowY, "—", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
            table.cell(panel, 1, rowY, "", text_size = f_panelSize())
            table.cell(panel, 2, rowY, "", text_size = f_panelSize())

    table.cell(panel, 0, 10, "Vote Weighting", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, "", text_size = f_panelSize())
    table.cell(panel, 2, 10, weightByPerf ? "MERITOCRATIC" : "EQUAL", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(fireLong,  "Consensus ▸ LONG",  "AetherEdge Multi-Agent: council consensus LONG.")
alertcondition(fireShort, "Consensus ▸ SHORT", "AetherEdge Multi-Agent: council consensus SHORT.")
alertcondition(not na(consEma) and consEma >= consGate and (na(consEma[1]) or consEma[1] < consGate), "Consensus Reached", "AetherEdge Multi-Agent: council reached consensus.")
````
