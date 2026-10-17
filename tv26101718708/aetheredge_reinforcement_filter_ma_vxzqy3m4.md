# AetherEdge Reinforcement Filter MA

- url: https://www.tradingview.com/script/VXZQY3M4/
- type: indicator
- pine_id: PUB;eefabc692ec241caa3f9af6a4d701e24
- version: 1.0

## Description

🖊️ Overview
AetherEdge Reinforcement Filter MA is a self-evolving moving average powered by a genuine Q-learning algorithm. By dynamically learning across 9 market states and 5 smoothing actions, it autonomously selects the optimal reaction speed for current conditions — a true "thinking MA" that transcends the limitations of fixed-parameter legacy averages.

🔶 Key Features

Full Q-Learning Engine: 9 states × 5 actions = 45-cell Q-table
State Discretization: 2D regime classification via volatility × trend strength
5-Tier Action Space: Auto-selects from ultra-fast to ultra-slow smoothing
Dual-Objective Reward: Balances tracking error and jitter suppression
ε-greedy Strategy: Governs the exploration-exploitation tradeoff
5-Level Slope Coloring: Intuitive trend strength visualization
Adaptive α Display: Mini label showing current learned smoothing
Momentum Reversal Alerts: Real-time directional shift notifications

🧠 Technical Architecture

This indicator faithfully implements the canonical reinforcement learning framework.

State Space: ATR%-Z-score discretizes volatility into 3 tiers (low/mid/high), ATR-normalized momentum classifies trend into 3 tiers (down/range/up), forming a 3×3=9 state space.
Action Space: 5 smoothing coefficients ranging from a=0 (α≈0.40, ultra-fast) to a=4 (α≈0.04, ultra-slow), allowing the MA to switch reaction speeds based on regime.
Reward Function: reward = −(trackErr × wTrack + smoothErr × wSmooth). Dynamic weighting prioritizes tracking in trends and smoothness in chop, resolving the classic lag-vs-noise dilemma.
Q-Learning Update: Q(s,a) ← Q(s,a) + α[r + γ·max Q(s',a') − Q(s,a)] — the standard Bellman update executes on every bar.
ε-greedy Selection: Explores randomly with probability ε, exploits the best known action otherwise — preserving adaptability to new regimes.
Parallel MA Computation: All 5 action-MAs are computed each bar; the selected one becomes the final output, enabling simultaneous evaluation and selection.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (4H–1D): BaseLen=20, α=0.15, γ=0.85, ε=0.10
SOL/XRP (1H): BaseLen=14, α=0.20, γ=0.80, ε=0.15 (high volatility)
Scalping (5M–15M): BaseLen=10, α=0.25, ε=0.05 (trust the learning)
Long Swing (1D–1W): BaseLen=50, α=0.10, γ=0.95 (deep discount)
Parameter Tuning:

Slow learning: Raise α to 0.20–0.30 for accelerated convergence
Excess noise: Lift γ to 0.90+ to prioritize long-term reward
New market/symbol: Increase ε to 0.20 for active exploration
Stable learning: Reduce ε to 0.03–0.05 to favor exploitation

💡 How to Use in Practice

Trend Following: Enter on Strong Up/Down color + price above/below RFMA
Exit Logic: Reduce on Flat slope, exit on opposite color emergence
Multi-Timeframe: 4H RFMA bias → 15M for precise entries
AetherEdge Combinations: Cluster Probability Line direction + RFMA slope alignment = elite conviction
Dynamic S/R: RFMA itself serves as a learning-based adaptive support/resistance

⚠️ Important Notes

Q-table initializes to zero — recommend a 200-bar warmup learning period
Learning resets on indicator reload (var variable behavior)
Excessive ε amplifies exploration noise; too low slows adaptation to new regimes
math.random() usage may cause minor recalculation drift on the same bar

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. All trading decisions are made at your own risk and should be accompanied by proper risk management. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("AetherEdge Reinforcement Filter MA", shorttitle="AE-RFMA", overlay=true, max_lines_count=10)

// ============================================================
// ▼ INPUTS
// ============================================================
grpRL    = "🧠 Reinforcement Learning"
baseLen  = input.int(20,   "Base MA Length",       minval=5,    maxval=200, group=grpRL, tooltip="基準となるMA長")
lookback = input.int(50,   "Reward Lookback",      minval=10,   maxval=200, group=grpRL, tooltip="報酬計算のルックバック")
learnRate= input.float(0.15,"Learning Rate (α)",   minval=0.01, maxval=0.50, step=0.01, group=grpRL, tooltip="Q値の更新速度")
discount = input.float(0.85,"Discount Factor (γ)", minval=0.50, maxval=0.99, step=0.01, group=grpRL, tooltip="将来報酬の割引率")
epsilon  = input.float(0.10,"Exploration (ε)",     minval=0.00, maxval=0.30, step=0.01, group=grpRL, tooltip="探索率（低いほど学習結果を信頼）")

grpVis   = "🎨 Visual"
lineWid  = input.int(4, "Line Width", minval=2, maxval=8, group=grpVis)
colStrUp = input.color(color.rgb(0, 230, 180),    "Strong Up",   group=grpVis)
colWkUp  = input.color(color.rgb(120, 200, 160),  "Weak Up",     group=grpVis)
colFlat  = input.color(color.rgb(150, 150, 170),  "Flat",        group=grpVis)
colWkDn  = input.color(color.rgb(200, 140, 140),  "Weak Down",   group=grpVis)
colStrDn = input.color(color.rgb(230, 60, 90),    "Strong Down", group=grpVis)
showInfo = input.bool(false, "Show Tiny Adaptive α", group=grpVis)

// ============================================================
// ▼ STATE DISCRETIZATION
// ============================================================
// State = (volatility regime, trend regime), 3x3 = 9 states
atrLen   = baseLen
atr      = ta.atr(atrLen)
atrPct   = atr / close
atrZ     = (atrPct - ta.sma(atrPct, lookback)) / math.max(ta.stdev(atrPct, lookback), 1e-10)

momoRaw  = ta.change(close, atrLen) / math.max(atr * atrLen, 1e-10)

stateVol = atrZ < -0.5 ? 0 : atrZ > 0.5 ? 2 : 1     // 0=low, 1=mid, 2=high vol
stateTrn = momoRaw < -0.3 ? 0 : momoRaw > 0.3 ? 2 : 1 // 0=down, 1=range, 2=up
stateIdx = stateVol * 3 + stateTrn   // 0..8

// ============================================================
// ▼ ACTIONS = 5 candidate smoothing factors
// ============================================================
// Action a → smoothing factor α_a
// We define 5 actions covering very-fast to very-slow MA behavior
nActions = 5
getAlpha(int a) =>
    // Map action 0..4 → alpha values mapping to effective length factors
    // a=0 → fastest (α≈0.40), a=4 → slowest (α≈0.04)
    base = 2.0 / (baseLen + 1)
    factor = a == 0 ? 4.0 : a == 1 ? 2.0 : a == 2 ? 1.0 : a == 3 ? 0.5 : 0.25
    math.min(0.95, math.max(0.01, base * factor))

// ============================================================
// ▼ Q-TABLE  (9 states × 5 actions = 45 cells)
// ============================================================
var array<float> Q = array.new<float>(45, 0.0)

getQ(int s, int a) => array.get(Q, s * nActions + a)
setQ(int s, int a, float v) => array.set(Q, s * nActions + a, v)

// ε-greedy action selection
selectAction(int s) =>
    int chosen = 0
    if math.random() < epsilon
        chosen := math.floor(math.random() * nActions)
    else
        float bestVal = -1e18
        for a = 0 to nActions - 1
            qv = getQ(s, a)
            if qv > bestVal
                bestVal := qv
                chosen := a
    chosen

bestAction(int s) =>
    int best = 0
    float bestVal = -1e18
    for a = 0 to nActions - 1
        qv = getQ(s, a)
        if qv > bestVal
            bestVal := qv
            best := a
    best

// ============================================================
// ▼ EXECUTE & LEARN
// ============================================================
var int   prevState  = 4   // start at mid-vol/range
var int   prevAction = 2   // start at neutral smoothing
var float rfma       = na

// Compute MA outputs for ALL actions on every bar so we can evaluate them
var array<float> maAll = array.new<float>(nActions, na)
for a = 0 to nActions - 1
    alphaA = getAlpha(a)
    prev = nz(array.get(maAll, a), close)
    cur  = alphaA * close + (1.0 - alphaA) * prev
    array.set(maAll, a, cur)

// REWARD: how well did prevAction's MA track recent price?
// We reward low tracking-error AND smoothness (low jitter) — classic adaptive trade-off.
prevMA   = array.get(maAll, prevAction)
trackErr = math.abs(close - prevMA) / math.max(atr, 1e-10)        // tracking error normalized
smoothErr= math.abs(prevMA - prevMA[1]) / math.max(atr, 1e-10)    // jitter
// Reward favors balance: penalize lag in trends, penalize jitter in chop
trendStrength = math.abs(momoRaw)
weightTrack   = 0.4 + trendStrength * 0.4    // when trending, tracking matters more
weightSmooth  = 1.0 - weightTrack
reward = -(trackErr * weightTrack + smoothErr * weightSmooth)

// Q-LEARNING UPDATE:  Q(s,a) ← Q(s,a) + α [r + γ·max Q(s',a') − Q(s,a)]
maxNext = -1e18
for a = 0 to nActions - 1
    qv = getQ(stateIdx, a)
    if qv > maxNext
        maxNext := qv
oldQ  = getQ(prevState, prevAction)
newQ  = oldQ + learnRate * (reward + discount * maxNext - oldQ)
setQ(prevState, prevAction, newQ)

// SELECT next action
curAction = selectAction(stateIdx)
curAlpha  = getAlpha(curAction)

// Final RFMA = the chosen action's MA
rfma := array.get(maAll, curAction)

// Save state for next bar
prevState  := stateIdx
prevAction := curAction

// ============================================================
// ▼ MOMENTUM-BASED COLOR
// ============================================================
slope    = (rfma - rfma[3]) / math.max(atr, 1e-10)
slopeAbs = math.abs(slope)

lineColor = colFlat
if slope > 0.6
    lineColor := colStrUp
else if slope > 0.15
    lineColor := colWkUp
else if slope < -0.6
    lineColor := colStrDn
else if slope < -0.15
    lineColor := colWkDn

// ============================================================
// ▼ PLOT — single bold line
// ============================================================
plot(rfma, "RF-MA", color=lineColor, linewidth=lineWid)

// Optional micro label showing current adaptive alpha (no clutter)
var label infoLbl = na
if showInfo and barstate.islast
    label.delete(infoLbl)
    txt = "α=" + str.tostring(curAlpha, "#.##")
    infoLbl := label.new(bar_index, rfma, txt, style=label.style_none, textcolor=lineColor, size=size.tiny, textalign=text.align_left)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(slope > 0.6 and slope[1] <= 0.6, title="RFMA Strong Up", message="AE-RFMA: Strong upward momentum")
alertcondition(slope < -0.6 and slope[1] >= -0.6, title="RFMA Strong Down", message="AE-RFMA: Strong downward momentum")
````
