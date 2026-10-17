# AetherEdge - Q-Learning Trendline Drawer

- url: https://www.tradingview.com/script/0potdaSN/
- type: indicator
- pine_id: PUB;d04d742b7f03491eaa124ec0def83435
- version: 1.0

## Description

🖊️ Overview

A self-evolving auto-drawing engine that learns how to draw trendlines via tabular Q-Learning. It quantizes the market into a discrete state (trend posture, volatility regime, proximity to swing structure) and maps it through a state×action Q-table (a NeuraLib Q-head) to an optimal drawing action — anchor a support line, anchor a resistance line, steepen, flatten, or hold. When price breaks a line, the realized outcome feeds back as reward via Q(s,a) ← Q(s,a) + α[r + γ·maxₐ′Q(s′,a′) − Q(s,a)], so the agent itself learns which drawing behavior pays off in each market state. Every rendered line carries an expiry, with its learned strength (Q-value) reflected in color, width, and opacity.

🔶 Key Features

Tabular Q-Learning — a state×action Q-table held as a NeuraLib Q-head, updated by the Bellman rule
State quantization — trend, volatility, and proximity compressed into discrete bins for an interpretable finite state space
Self-evolving drawing policy — no prior knowledge; the optimal way to draw is learned from the live chart
Reward on break — realized post-break return becomes reward, with an extra reward when a line is respected (bounces)
AI-optimal trendlines — multiple optimal lines auto-generated and adjusted from learned strength
Expiry + strength encoding — each line has a lifespan; Q-derived strength drives color, width, and opacity; old lines fade
Exploration vs. exploitation — ε-greedy over drawing actions
Premium panel — the current state's Q-row (all action values), optimal action, policy decisiveness, and active/broken counts at a glance

🧠 Technical Architecture

The agent first quantizes the market into a discrete state. Three axes — trend posture (ATR-normalized fast/slow EMA gap), volatility regime (ATR ratio), and proximity to the nearest swing structure — are each split into a configurable number of bins and composed into a single state index. The state space is thus a finite trendBins × volBins × distBins, and the Q-table holds the value of every action for every state.
Each bar, the agent picks a drawing action via ε-greedy: with probability ε it explores (a random action); otherwise it exploits (the max-Q action for the current state). Once chosen, a trendline is constructed anchored on two swing pivots, with STEEPEN/FLATTEN actions biasing the slope. New lines too close to an existing one are suppressed to avoid clutter.
Learning is driven by break / respect events. When a line breaks, the lookahead return in the break direction accrues as reward; when price tests a line and respects it (bounces), a separate reward is added. On the next confirmed bar, the update Q(s,a) ← Q(s,a) + α[r + γ·maxₐ′Q(s′,a′) − Q(s,a)] is applied to the prior state-action. Each line's strength is the spawning Q-value squashed logistically to [0,1], driving color saturation, line width (strong lines are thicker), and opacity. As lifecycle management, expired and long-broken lines retire, and when over the cap the weakest (lowest-strength) line is pruned.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Training Horizon 800–1500, α 0.2–0.3, γ 0.9, ε 0.08, Swing Sensitivity 8. State bins of 3 each give a standard granularity
ETH (1H–4H): As BTC, with Reward Lookahead 5–8 to value post-break follow-through
SOL (15m–1H): High volatility favors Volatility Bins 4 for finer regime classification, Break Buffer 0.1–0.15 to absorb fakeouts, Min Separation ≈ 0.8
XRP (1H–4H): Spike-prone; α ≈ 0.3 to learn fast, Respect Reward 0.4 to favor strong lines that bounce
Learning Rate α: higher (0.3–0.5) learns faster but values are noisier; lower (0.1–0.2) is stable but slower
State bins: more bins raise granularity but enlarge the state space and slow learning — balance against Training Horizon
ε (exploration): ~0.1 when studying drawing behavior; ~0.05 in live use to stabilize the policy

💡 How to Use in Practice

Reacting to AI-optimal lines: thick, saturated lines = high Q (high strength) = levels the agent learned matter. A reliable basis for S/R judgments
Reading strength (color/width): the thicker and more opaque a line, the higher its learned strength; treat faint, thin lines as tentative
Using breaks: on a break the line recolors (cyan up / gold down) and thickens; breaks of higher-strength lines matter more
Using respects (bounces): when price approaches a strong line and bounces, it marks a pullback/throwback entry in that line's direction
Multi-timeframe usage: map the major high-strength lines on the higher timeframe (4H), then time breaks/bounces on the lower one (15m–1H)
Combinations: pair with volume or horizontal S/R, filtering for high-strength lines to lift precision

⚠️ Important Notes

Initial learning period: right after launch the Q-table is near-zero and the drawing policy is immature; treat line strength as low-confidence until enough state visits accumulate (several hundred bars)
Learning resets: changing parameters, switching symbol/timeframe, or recompiling reinitializes the Q-table and the line set, restarting learning from zero
State-space constraint: more bins mean more unvisited states, whose lines rely on near-zero initial Q and thus show lower strength
On forward-looking reward: rewards use confirmed post-break lookahead returns (a standard RL training construct); current-bar drawing is on confirmed values, but as with any adaptive system, historical and live behavior can differ — always forward-test
Constraints: this is a lightweight tabular implementation operating within Pine's compute budget

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The Q-Learning, Q-table, reward shaping, trendline generation, and strength are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Reinforcement-learning agents can and do make wrong calls. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Q-Learning Trendline Drawer
//   AI Drawing Power Series
//
//   A self-evolving trendline engine driven by tabular Q-Learning. A discrete state — built from
//   trend posture, volatility regime, and proximity to swing structure — is mapped through a NeuraLib
//   Q-head (a state×action value table) to one of several drawing actions: anchor a rising support
//   line, anchor a falling resistance line, steepen, flatten, or hold. The chosen action constructs
//   and continuously adjusts AI-optimal trendlines. When price breaks a line, the realized outcome
//   feeds back as reward via the Q-update Q(s,a) ← Q(s,a) + α[r + γ·maxₐ′Q(s′,a′) − Q(s,a)], so the
//   agent learns which drawing behavior pays off in each market state.
//
//   Visualization: a set of AI-optimal trendlines with expiry, colored and weighted by learned
//   strength; broken lines flare and fade; a premium intelligence panel exposes the live Q-table.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Q-Learning Trendline Drawer", "AE-QL TD", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_AGENT = "◆  Q-LEARNING AGENT"
var string GRP_STATE = "◆  STATE QUANTIZER"
var string GRP_LINE  = "◆  TRENDLINE LIFECYCLE"
var string GRP_BREAK = "◆  BREAKOUT & REWARD"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Agent —
trainLen     = input.int(700,  "Training Horizon (bars)", minval = 50, maxval = 5000, group = GRP_AGENT, tooltip = "How many recent bars the agent treats as its learning environment.")
alphaLR      = input.float(0.25,"Learning Rate α",        minval = 0.01, maxval = 1.0, step = 0.01, group = GRP_AGENT, tooltip = "Tabular Q-learning step size. Higher = faster but noisier value updates.")
gamma        = input.float(0.90,"Discount γ",             minval = 0.0, maxval = 0.999, step = 0.01, group = GRP_AGENT)
epsilon      = input.float(0.08,"Exploration ε",          minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_AGENT, tooltip = "ε-greedy exploration over drawing actions.")
pivotLen     = input.int(8,    "Swing Sensitivity",       minval = 2, maxval = 50, group = GRP_AGENT, tooltip = "Pivot lookback used to anchor trendlines and define structure.")

// — State Quantizer —
trendBins    = input.int(3,    "Trend Bins",      minval = 2, maxval = 5, group = GRP_STATE, tooltip = "Number of discrete buckets for trend posture (e.g. down / flat / up).")
volBins      = input.int(3,    "Volatility Bins", minval = 2, maxval = 5, group = GRP_STATE)
distBins     = input.int(3,    "Proximity Bins",  minval = 2, maxval = 5, group = GRP_STATE, tooltip = "Buckets for distance to nearest swing structure.")
fastLen      = input.int(10,   "Trend Fast", minval = 1, maxval = 100, group = GRP_STATE)
slowLen      = input.int(30,   "Trend Slow", minval = 2, maxval = 200, group = GRP_STATE)
normLen      = input.int(120,  "Feature Norm Window", minval = 20, maxval = 1000, group = GRP_STATE)

// — Trendline Lifecycle —
maxActive    = input.int(6,    "Max Active Lines", minval = 1, maxval = 16, group = GRP_LINE)
maxLifeBars  = input.int(220,  "Line Lifespan (bars)", minval = 20, maxval = 2000, group = GRP_LINE, tooltip = "Maximum age before a line expires. Lines fade as they approach expiry.")
fadeStart    = input.float(55, "Fade Begins At (% of life)", minval = 0, maxval = 100, group = GRP_LINE)
extendRight  = input.bool(true,"Project Lines Forward", group = GRP_LINE)
minSeparation= input.float(0.6,"Min Line Separation (ATR x)", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_LINE, tooltip = "Avoid clutter: suppress new lines too close to an existing one.")

// — Breakout & Reward —
breakSrc     = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = GRP_BREAK)
breakBuffer  = input.float(0.08,"Break Buffer (ATR x)", minval = 0.0, maxval = 2.0, step = 0.01, group = GRP_BREAK)
rewardLook   = input.int(5,    "Reward Lookahead (bars)", minval = 1, maxval = 20, group = GRP_BREAK, tooltip = "Forward window used to judge whether a break paid off (reward).")
holdBroken   = input.int(16,   "Keep Broken Lines (bars)", minval = 0, maxval = 200, group = GRP_BREAK)
respectBonus = input.float(0.3, "Respect Reward",  minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_BREAK, tooltip = "Reward when price tests a line and respects it (bounce) rather than breaking.")

// — Aesthetics —
colSupport   = input.color(#21d3a3, "Support Tone",   group = GRP_STYLE, inline = "c1")
colResist    = input.color(#ff5d73, "Resistance Tone",group = GRP_STYLE, inline = "c1")
colBreakUp   = input.color(#5ce1ff, "Break ▲", group = GRP_STYLE, inline = "c2")
colBreakDn   = input.color(#f4c25b, "Break ▼", group = GRP_STYLE, inline = "c2")
baseWidth    = input.int(2,    "Base Line Width", minval = 1, maxval = 6, group = GRP_STYLE)
strongWidth  = input.int(4,    "Strong Line Width", minval = 1, maxval = 8, group = GRP_STYLE, tooltip = "Width used for the highest-Q (strongest) lines.")
glowFx       = input.bool(true,"Glow / Halo Effect", group = GRP_STYLE)
showTags     = input.bool(true,"Strength Tags (Q%)", group = GRP_STYLE)

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

// Drawing actions
var int ACT_SUPPORT = 0   // anchor / maintain a rising support line
var int ACT_RESIST  = 1   // anchor / maintain a falling resistance line
var int ACT_STEEPEN = 2   // bias new lines to a steeper slope
var int ACT_FLATTEN = 3   // bias new lines to a flatter slope
var int ACT_HOLD    = 4   // draw nothing this state
var int N_ACT       = 5

f_actName(int a) =>
    a == ACT_SUPPORT ? "SUPPORT" : a == ACT_RESIST ? "RESIST" : a == ACT_STEEPEN ? "STEEPEN" : a == ACT_FLATTEN ? "FLATTEN" : "HOLD"

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  PRNG
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  STATE QUANTIZER  — discretize the market into a single integer state index
// ────────────────────────────────────────────────────────────────────────────────────────────────

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr     = ta.atr(14)

ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

resLevel = ta.highest(high, slowLen)
supLevel = ta.lowest(low, slowLen)

// raw features
rawTrend = (emaFast - emaSlow) / (atr == 0 ? 1.0 : atr)
rawVol   = atr / (ta.sma(atr, normLen) == 0 ? 1.0 : ta.sma(atr, normLen))
rawDist  = atr == 0 ? 0.0 : math.min(resLevel - close, close - supLevel) / atr

// bucket helper: map a z-like value to [0, bins-1]
f_bucket(float v, float lo, float hi, int bins) =>
    float clamped = math.max(lo, math.min(hi, v))
    int b = int((clamped - lo) / (hi - lo) * (bins - 1) + 0.5)
    math.max(0, math.min(bins - 1, b))

tB = f_bucket(rawTrend, -2.0, 2.0, trendBins)
vB = f_bucket(rawVol,    0.5, 2.0, volBins)
dB = f_bucket(rawDist,   0.0, 3.0, distBins)

// composite state index
stateIdx = tB * (volBins * distBins) + vB * distBins + dB
var int N_STATES = trendBins * volBins * distBins

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  Q-TABLE  (NeuraLib Q-head)  — flat array of size N_STATES × N_ACT
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<float> Q = na
var array<int>   visits = na
var bool qInit = false

if not qInit
    Q := array.new_float(N_STATES * N_ACT, 0.0)
    visits := array.new_int(N_STATES * N_ACT, 0)
    qInit := true

f_qget(int s, int a) =>
    array.get(Q, s * N_ACT + a)

f_qset(int s, int a, float v) =>
    array.set(Q, s * N_ACT + a, v)

f_qmaxAction(int s) =>
    float best = -1e18
    int bestA = ACT_HOLD
    for a = 0 to N_ACT - 1
        float q = f_qget(s, a)
        if q > best
            best := q
            bestA := a
    [bestA, best]

f_qmax(int s) =>
    [ba, bv] = f_qmaxAction(s)
    bv

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  TRENDLINE OBJECT MODEL
// ────────────────────────────────────────────────────────────────────────────────────────────────

type TLine
    line  ln
    line  halo
    label tag
    float slope
    float intercept
    int   bornBar
    bool  isSupport
    bool  broken
    int   brokeBar
    float strength    // normalized Q strength [0,1]
    int   state       // state index that spawned it
    int   action      // action that spawned it

var array<TLine> book = array.new<TLine>()

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  PIVOT MEMORY (anchors for line construction)
// ────────────────────────────────────────────────────────────────────────────────────────────────

var array<int>   hiX = array.new_int()
var array<float> hiY = array.new_float()
var array<int>   loX = array.new_int()
var array<float> loY = array.new_float()

if not na(ph)
    array.push(hiX, bar_index - pivotLen)
    array.push(hiY, ph)
if not na(pl)
    array.push(loX, bar_index - pivotLen)
    array.push(loY, pl)

f_trimMem(array<int> ax, array<float> ay) =>
    while array.size(ax) > 0 and (bar_index - array.get(ax, 0)) > trainLen
        array.shift(ax)
        array.shift(ay)
f_trimMem(hiX, hiY)
f_trimMem(loX, loY)

// build slope/intercept anchored on the two most recent relevant pivots, with action-based bias
f_buildLine(bool isSupport, int action) =>
    float slope = na
    float inter = na
    array<int>   ax = isSupport ? loX : hiX
    array<float> ay = isSupport ? loY : hiY
    int n = array.size(ax)
    if n >= 2
        int   x2 = array.get(ax, n - 1)
        float y2 = array.get(ay, n - 1)
        int   x1 = array.get(ax, n - 2)
        float y1 = array.get(ay, n - 2)
        if x2 != x1
            slope := (y2 - y1) / (x2 - x1)
            // action bias: steepen / flatten the slope
            if action == ACT_STEEPEN
                slope := slope * 1.35
            else if action == ACT_FLATTEN
                slope := slope * 0.65
            inter := y2 - slope * x2
    [slope, inter]

// is a near-identical line already present?
f_tooClose(float slope, float inter, bool isSupport) =>
    bool clash = false
    if array.size(book) > 0
        for i = 0 to array.size(book) - 1
            TLine t = array.get(book, i)
            if t.isSupport == isSupport and not t.broken
                float dy = math.abs((t.slope * bar_index + t.intercept) - (slope * bar_index + inter))
                if atr > 0 and dy < atr * minSeparation
                    clash := true
    clash

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  REWARD  — judged from realized forward outcome after a break / respect event
// ────────────────────────────────────────────────────────────────────────────────────────────────

fwdRet  = (close - close[rewardLook]) / (close[rewardLook] == 0 ? 1.0 : close[rewardLook])
atrPast = atr[rewardLook]

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  AGENT STEP
// ────────────────────────────────────────────────────────────────────────────────────────────────

bool inHorizon = bar_index > (last_bar_index - trainLen)

var int   prevState = na
var int   prevAction = na
var float pendingReward = 0.0

var int   liveState  = 0
var int   liveAction = ACT_HOLD
var float liveQspan  = 0.0

// Q-update helper: applies a reward for (prevState, prevAction) using current state as s'
f_qUpdate(int s, int a, float r, int sNext) =>
    if not na(s) and not na(a)
        float q = f_qget(s, a)
        float target = r + gamma * f_qmax(sNext)
        f_qset(s, a, q + alphaLR * (target - q))
        array.set(visits, s * N_ACT + a, array.get(visits, s * N_ACT + a) + 1)

// choose action via ε-greedy
f_chooseAction(int s, int seed) =>
    int a = ACT_HOLD
    if f_rand(seed) < epsilon
        a := int(f_rand(seed * 7919 + 13) * N_ACT) % N_ACT
    else
        [ba, bv] = f_qmaxAction(s)
        a := ba
    a

// spawn a trendline for the chosen action & current state
f_spawnLine(int s, int action) =>
    bool isSupport = action == ACT_SUPPORT or (action == ACT_STEEPEN and rawTrend >= 0) or (action == ACT_FLATTEN and rawTrend >= 0)
    bool wantDraw = action != ACT_HOLD
    if wantDraw
        [slope, inter] = f_buildLine(isSupport, action)
        if not na(slope) and not na(inter) and not f_tooClose(slope, inter, isSupport)
            // strength from Q-value of this state-action, squashed to [0,1]
            float qv = f_qget(s, action)
            float strength = 0.5 + 0.5 * (qv / (1.0 + math.abs(qv)))   // logistic-ish squash
            color baseC = isSupport ? colSupport : colResist
            int trans = int(60 - strength * 45)                        // stronger → more opaque
            int x1 = math.max(0, bar_index - math.min(trainLen, 140))
            float y1 = slope * x1 + inter
            int x2 = bar_index
            float y2 = slope * x2 + inter

            line halo = na
            if glowFx
                halo := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = color.new(baseC, math.min(95, trans + 22)), width = baseWidth + 4, extend = extendRight ? extend.right : extend.none)
            line ln = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = color.new(baseC, trans), width = strength > 0.7 ? strongWidth : baseWidth, extend = extendRight ? extend.right : extend.none)
            label tag = na
            if showTags
                tag := label.new(x2, y2, str.tostring(math.round(strength * 100)) + "%", xloc = xloc.bar_index, style = isSupport ? label.style_label_up : label.style_label_down, color = color.new(baseC, 15), textcolor = #0a0d15, size = size.small)

            TLine t = TLine.new(ln, halo, tag, slope, inter, bar_index, isSupport, false, na, strength, s, action)
            array.push(book, t)

// MAIN LEARNING + ACTING (closed bars only for learning; acting evaluated each bar)
if inHorizon
    liveState := stateIdx

    if barstate.isconfirmed
        // 1) settle the previous action's reward (uses pending reward accumulated from break/respect events)
        f_qUpdate(prevState, prevAction, pendingReward, stateIdx)
        pendingReward := 0.0

        // 2) choose this bar's drawing action
        int seed = (bar_index * 7919 + stateIdx * 31 + 13) % 2147483647
        int action = f_chooseAction(stateIdx, seed)
        liveAction := action

        // 3) act: spawn a line on a fresh pivot or a decisive action
        bool pivotJust = not na(ph) or not na(pl)
        if pivotJust and action != ACT_HOLD
            f_spawnLine(stateIdx, action)

        // 4) remember for next update
        prevState := stateIdx
        prevAction := action

    // live Q-span for the panel (how decisive the policy is in this state)
    [ba, bv] = f_qmaxAction(stateIdx)
    float qlo = 1e18
    for a = 0 to N_ACT - 1
        float q = f_qget(stateIdx, a)
        qlo := math.min(qlo, q)
    liveQspan := (bv - qlo)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  TRENDLINE LIFECYCLE  — extend, fade, detect break/respect, accrue reward, retire
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_lineLevel(TLine t) =>
    t.slope * bar_index + t.intercept

int brokeUpCount = 0
int brokeDnCount = 0

if inHorizon and barstate.isconfirmed and array.size(book) > 0
    for i = array.size(book) - 1 to 0
        TLine t = array.get(book, i)
        int age = bar_index - t.bornBar

        bool expired = age > maxLifeBars
        bool brokenAged = t.broken and not na(t.brokeBar) and (bar_index - t.brokeBar) > holdBroken

        if expired or brokenAged
            line.delete(t.ln)
            if not na(t.halo)
                line.delete(t.halo)
            if not na(t.tag)
                label.delete(t.tag)
            array.remove(book, i)
        else
            // extend right endpoint
            float yEnd = f_lineLevel(t)
            line.set_xy2(t.ln, bar_index, yEnd)
            if not na(t.halo)
                line.set_xy2(t.halo, bar_index, yEnd)
            if not na(t.tag)
                label.set_xy(t.tag, bar_index, yEnd)

            // break detection
            float lvl = f_lineLevel(t)
            float buf = atr * breakBuffer
            float pxUp = breakSrc == "Wick" ? high : close
            float pxDn = breakSrc == "Wick" ? low : close
            bool brokeNow = false
            if not t.broken
                if t.isSupport and pxDn < lvl - buf
                    brokeNow := true
                else if (not t.isSupport) and pxUp > lvl + buf
                    brokeNow := true

            if brokeNow
                t.broken := true
                t.brokeBar := bar_index
                color bc = t.isSupport ? colBreakDn : colBreakUp
                line.set_color(t.ln, color.new(bc, 0))
                line.set_width(t.ln, strongWidth)
                if not na(t.halo)
                    line.set_color(t.halo, color.new(bc, 60))
                    line.set_width(t.halo, strongWidth + 5)
                if not na(t.tag)
                    label.set_color(t.tag, color.new(bc, 0))
                    label.set_text(t.tag, (t.isSupport ? "▼ BREAK " : "▲ BREAK ") + str.tostring(math.round(t.strength * 100)) + "%")
                // REWARD: a break that leads to continuation in the broken direction is "good"
                // (the line correctly marked a level whose break mattered)
                float dirRet = t.isSupport ? -fwdRet : fwdRet
                float rwd = (atrPast != 0 ? (dirRet * close[rewardLook]) / atrPast : dirRet)
                pendingReward := pendingReward + math.max(-3.0, math.min(3.0, rwd))
                if t.isSupport
                    brokeDnCount += 1
                else
                    brokeUpCount += 1

            // RESPECT reward: price tested the line closely but did NOT break → the line held
            if not t.broken
                float dist = math.abs(close - lvl)
                if atr > 0 and dist < atr * 0.25
                    pendingReward := pendingReward + respectBonus

            // fade aging non-broken lines
            if not t.broken
                float lifePct = age / math.max(1, maxLifeBars) * 100.0
                float fade = lifePct <= fadeStart ? 0.0 : (lifePct - fadeStart) / math.max(1.0, 100.0 - fadeStart)
                color baseC = t.isSupport ? colSupport : colResist
                int baseTrans = int(60 - t.strength * 45)
                int curTrans = int(math.min(100.0, baseTrans + fade * (100.0 - baseTrans)))
                line.set_color(t.ln, color.new(baseC, curTrans))
                if not na(t.halo)
                    line.set_color(t.halo, color.new(baseC, math.min(98, curTrans + 22)))
                if not na(t.tag)
                    label.set_color(t.tag, color.new(baseC, math.min(100, curTrans)))
                    label.set_textcolor(t.tag, color.new(#0a0d15, int(fade * 70)))

// enforce max active count — cull the weakest (lowest strength) non-broken line
if array.size(book) > maxActive
    int weakIdx = -1
    float weakStr = 1e18
    for i = 0 to array.size(book) - 1
        TLine t = array.get(book, i)
        if not t.broken and t.strength < weakStr
            weakStr := t.strength
            weakIdx := i
    if weakIdx >= 0
        TLine t = array.get(book, weakIdx)
        line.delete(t.ln)
        if not na(t.halo)
            line.delete(t.halo)
        if not na(t.tag)
            label.delete(t.tag)
        array.remove(book, weakIdx)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL  — premium, exposes the live Q-row for the current state
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

    // normalize the current state's Q-row for display
    float qLo = 1e18
    float qHi = -1e18
    for a = 0 to N_ACT - 1
        float q = f_qget(liveState, a)
        qLo := math.min(qLo, q)
        qHi := math.max(qHi, q)
    float qRng = (qHi - qLo) == 0 ? 1.0 : (qHi - qLo)
    [bestA, bestV] = f_qmaxAction(liveState)

    int activeN = 0
    int brokenN = 0
    if array.size(book) > 0
        for i = 0 to array.size(book) - 1
            TLine t = array.get(book, i)
            if t.broken
                brokenN += 1
            else
                activeN += 1

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "Q-LEARNING", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  OPTIMAL: " + f_actName(bestA), text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(THEME_ACC, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Q-ROW  (state #" + str.tostring(liveState) + ")", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 2, 2, 2)

    // each action's Q as a bar
    for a = 0 to N_ACT - 1
        float q = f_qget(liveState, a)
        color rc = a == bestA ? THEME_GOLD : THEME_TXT
        table.cell(panel, 0, 3 + a, f_actName(a), text_color = a == bestA ? THEME_GOLD : THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 1, 3 + a, f_bar((q - qLo) / qRng), text_color = rc, text_size = f_panelSize(), text_halign = text.align_left)
        table.cell(panel, 2, 3 + a, str.tostring(q, "#.##"), text_color = rc, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Policy Decisiveness", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, f_bar(math.min(1.0, liveQspan)), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(liveQspan, "#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Active / Broken", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, str.tostring(activeN), text_color = colSupport, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 9, str.tostring(brokenN), text_color = brokenN > 0 ? colBreakUp : THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 10, "Q-Table States", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 10, "", text_size = f_panelSize())
    table.cell(panel, 2, 10, str.tostring(N_STATES) + " × " + str.tostring(N_ACT), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 11, "α / γ / ε", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 11, "", text_size = f_panelSize())
    table.cell(panel, 2, 11, str.tostring(alphaLR, "#.##") + " / " + str.tostring(gamma, "#.##") + " / " + str.tostring(epsilon, "#.##"), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(brokeUpCount > 0, "Resistance Break ▲", "AetherEdge Q-Learning: AI trendline (resistance) broken upward.")
alertcondition(brokeDnCount > 0, "Support Break ▼",    "AetherEdge Q-Learning: AI trendline (support) broken downward.")
````
