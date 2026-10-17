# AetherEdge RL Signal Optimizer

- url: https://www.tradingview.com/script/fC9rkMGH/
- type: indicator
- pine_id: PUB;c51ff6bafca24c73b573a363f82882bd
- version: 1.0

## Description

🖊️ Overview
AetherEdge RL Signal Optimizer is a truly self-optimizing signal engine powered by a complete Q-Learning (TD-learning) implementation. It discretizes the market into 18 states, explores Long/Short/Skip actions through trial-and-error, updates Q-values via the Bellman equation, and dynamically balances exploration vs exploitation through ε-greedy decay. Combined with statistical TP/SL learning from MFE/MAE tracking, it is a living reinforcement-learning system where both policy and risk-management evolve with every trade.

🔶 Key Features

Full Q-Learning Implementation (TD(0)): 18 states × 3 actions Q-table
ε-Greedy Exploration: Auto-decay from 30% → 5%, solving the exploration/exploitation dilemma
State Discretization: Trend(3) × RSI(3) × Volatility(2) = 18 states
Reward Function: n-step ATR-normalized return + skip penalty
MFE/MAE Learning: Statistical TP/SL estimation from up to 200 trades
Dynamic TP/SL: Quantile-based optimal levels (TP=70%, SL=85% confidence)
Q-Spread Confidence: Best vs second-best Q gap as conviction proxy
Q-Table Heatmap: All 18 states visualized with color-graded Q-values
Learning Progress Bar: EXPLORING → MIXING → EXPLOITING phases
Performance Tracking: Win rate, avg reward, recent 50-reward MA
Current-State Highlight: On-chart directional box

🧠 Technical Architecture

This indicator is a complete reinforcement-learning agent running natively on TradingView.

State Space (18 states):
Trend Index: EMA20-50 spread (Bear/Flat/Bull)
RSI Index: Low/Mid/High
Volatility Index: ATR short/long ratio (Low/High)
Combined: state = trend×6 + rsi×2 + vol
Action Space (3 actions): 0=Long, 1=Short, 2=Skip
Q-Update (Bellman Equation):
Q(s,a) ← Q(s,a) + α × [r + γ·max Q(s',a') - Q(s,a)]
Reward Function:
Long → r = (close - close[n]) / ATR[n]
Short → r = -(close - close[n]) / ATR[n]
Skip → r = skipPenalty (-0.05)
ε-Greedy Policy:
With probability ε: random exploration; else greedy
Linear decay: epsStart → epsEnd over epsDecayLen
Pseudo-random: sin(seed×12.9898 + 78.233) for reproducibility
TP/SL Learning Engine:
Track MFE/MAE for trackBars after each signal
Separate Long/Short buffers, max 200 trades each
TP = 70th percentile of MFE; SL = 85th percentile of MAE
Safe defaults when data insufficient (TP=2.0×, SL=1.5×ATR)
Q-Spread Confidence: Signal fires only if best - second_best ≥ minConfidence
State Coverage Tracking: Percentage of (state, action) cells visited

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): α=0.15, γ=0.90, epsDecay=500 (standard)
ETH (1H): α=0.20, γ=0.85, epsDecay=300 (fast-learn)
SOL (high-vol): α=0.10, γ=0.92, epsDecay=800 (careful)
XRP (short-term): α=0.25, epsDecay=200, rewardLook=2
Q-Learning Hyperparameters:

α (Learning Rate):
0.05–0.10: conservative, noise-resilient
0.15: standard
0.25–0.40: fast adaptation, unstable risk
γ (Discount):
0.80: short-term view, immediate reward
0.90: standard
0.95–0.99: long-term strategy, delayed reward
ε Decay:
200: rapid learning, low data
500: standard
1000+: thorough exploration, HTF use
TP/SL Optimization:

tpConfidence=0.5: conservative TP (early profit)
tpConfidence=0.7: standard
tpConfidence=0.9: greedy TP (miss risk)
slConfidence=0.85: standard (tolerate 85% drawdowns)
Min Q-Spread:

0.05: many signals, noise included
0.15: standard
0.30: ultra-curated, fewer opportunities

💡 How to Use in Practice

EXPLOITING phase (ε≤0.08): Maximum signal trust, live trading
EXPLORING phase (ε>0.20): Learning, signals are reference only
MIXING phase: Transitional, observe carefully
CONFIDENT + LONG/SHORT: Sufficient Q-spread, entry candidate
UNCERTAIN: Ambiguous state, skip recommended
Q-Table Observation:
All-green rows: bullish bias learned
High Visits = high cell reliability
"—" displayed: unvisited cells, insufficient data
Trade Scenarios:
Bull · RSI↓ · LoVol with max Q[Long]: Pullback-buy pattern learned
Bear · RSI↑ · HiVol with max Q[Short]: Bounce-sell pattern learned
Learned TP/SL with 1:2.5 R:R: Trade only after statistical edge confirmed
AetherEdge Synergy:
SMC AI Confidence Engine: A+ zone + RL Long = double rationale
NeuraNet Predictor: Direction match + RL CONFIDENT = high probability
Self-Evolving S/R Grid: Strong line touch + RL signal = supreme alignment
All-in-One Dashboard: HIGH-CONVICTION + RL EXPLOITING = ultimate confluence

⚠️ Important Notes

Learning Reset Issue: Q-table resets on chart reload or timeframe change—relearning required
Initial Learning Period: Run at least epsDecayLen × 1.5 bars before live use
State Coverage: <50% means many unvisited states; 80%+ recommended for stability
Overfitting Risk: High α over-fits to recent noise; HTF requires lower α
MFE/MAE Buffer: At least 20+ trades needed for reliable TP/SL
Pseudo-Random: bar_index-based, so same moment yields same exploration
Signal Latency: Operates on barstate.isconfirmed; signals confirm after bar close

🚨 Disclaimer

This indicator is a reinforcement-learning demonstration for educational and research purposes only and does not constitute financial advice. Q-Learning is a stochastic optimization method and does not guarantee future profits. Learning outcomes depend strongly on environment and data; past performance does not predict future results. Use with thorough validation and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge RL Signal Optimizer", "AE-RL-OPT",
     overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpRL = "🧠 Q-Learning Hyperparameters"
alpha0       = input.float(0.15, "Learning Rate (α)", minval=0.01, maxval=1.0, step=0.01, group=grpRL,
     tooltip="How much new experience overrides prior Q-values.")
gamma        = input.float(0.90, "Discount Factor (γ)", minval=0.0, maxval=0.999, step=0.01, group=grpRL,
     tooltip="Weight of future rewards vs immediate reward.")
epsStart     = input.float(0.30, "ε Start (exploration)", minval=0.0, maxval=1.0, step=0.01, group=grpRL)
epsEnd       = input.float(0.05, "ε End (exploitation)", minval=0.0, maxval=1.0, step=0.01, group=grpRL)
epsDecayLen  = input.int(500, "ε Decay Episodes", minval=50, maxval=5000, group=grpRL)
rewardLook   = input.int(1, "Reward Lookback (bars)", minval=1, maxval=10, group=grpRL,
     tooltip="How many bars ahead to measure reward (n-step return).")
skipPenalty  = input.float(-0.05, "Skip Penalty", minval=-1.0, maxval=1.0, step=0.01, group=grpRL,
     tooltip="Small negative reward for skipping to encourage action when profitable.")

grpS = "🎯 State Discretization"
rsiLen       = input.int(14, "RSI Length", minval=2, group=grpS)
emaFast      = input.int(20, "EMA Fast", minval=2, group=grpS)
emaSlow      = input.int(50, "EMA Slow", minval=2, group=grpS)
atrLen       = input.int(14, "ATR Length", minval=2, group=grpS)
atrLong      = input.int(50, "ATR Long", minval=2, group=grpS)
rsiLow       = input.int(35, "RSI Low Zone", minval=10, maxval=50, group=grpS)
rsiHigh      = input.int(65, "RSI High Zone", minval=50, maxval=90, group=grpS)
volThresh    = input.float(1.1, "Volatility Threshold", minval=0.5, maxval=3.0, step=0.05, group=grpS,
     tooltip="ATR ratio above this = high-vol regime.")

grpT = "📊 TP/SL Optimization"
trackBars      = input.int(10, "Trade Tracking Window", minval=3, maxval=50, group=grpT,
     tooltip="Bars after entry to track MFE/MAE for TP/SL learning.")
tpConfidence   = input.float(0.7, "TP Confidence Quantile", minval=0.3, maxval=0.95, step=0.05, group=grpT)
slConfidence   = input.float(0.85, "SL Confidence Quantile", minval=0.3, maxval=0.99, step=0.01, group=grpT)
minConfidence  = input.float(0.15, "Min Q-Spread to Signal", minval=0.0, maxval=1.0, step=0.01, group=grpT,
     tooltip="Minimum gap between best and second-best Q-value to emit signal.")

grpD = "🎨 Display"
darkMode      = input.bool(true,  "Dark Mode", group=grpD)
showSignals   = input.bool(true,  "Show Policy Signals", group=grpD)
showTPSL      = input.bool(true,  "Show Current TP/SL Lines", group=grpD)
showDashboard = input.bool(true,  "Show Dashboard", group=grpD)
showQTable    = input.bool(true,  "Show Q-Table Heatmap", group=grpD)
showStateBox  = input.bool(true,  "Show Current State Highlight", group=grpD)
dashPos       = input.string("Top Right", "Dashboard",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)
qTablePos     = input.string("Middle Left", "Q-Table",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)

f_posHelper(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt   = darkMode ? color.new(#111a2e, 10) : color.new(#ffffff, 0)
cBgRow   = darkMode ? color.new(#0f172a, 0)  : color.new(#f8fafc, 0)
cBgHi    = darkMode ? color.new(#1a2744, 0)  : color.new(#eff6ff, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)
cBull    = color.new(#00d4a0, 0)
cBear    = color.new(#ff5577, 0)
cWarn    = color.new(#ffa500, 0)
cPurple  = color.new(#c084fc, 0)
cGold    = color.new(#fde047, 0)
cBlue    = color.new(#60a5fa, 0)

// ═══════════════════════════════════════════════════════════════
//  TOP-LEVEL HELPER FUNCTIONS
//  (Pine v5: functions MUST be defined at top level, NOT inside if/for blocks)
// ═══════════════════════════════════════════════════════════════

// Heatmap color for Q-value (scaled to range [-1, 1])
f_qColor(q, maxAbs) =>
    n = maxAbs > 0 ? q / maxAbs : 0.0
    n := math.max(-1.0, math.min(1.0, n))
    col = color.new(#00d4a0, 50)
    if n > 0
        transp = int(80 - n * 50)
        col := color.new(#00d4a0, math.max(30, transp))
    else
        transp = int(80 - math.abs(n) * 50)
        col := color.new(#ff5577, math.max(30, transp))
    col

// ── FIX: moved from inside if-block to top level ──
f_qBar(q, maxQ) =>
    n = math.min(5, math.round(math.abs(q) / maxQ * 5))
    s = ""
    for b = 0 to 4
        s := s + (b < n ? "▰" : "▱")
    s

// ═══════════════════════════════════════════════════════════════
//  FEATURES & STATE DISCRETIZATION
// ═══════════════════════════════════════════════════════════════
rsiV   = ta.rsi(close, rsiLen)
emaF   = ta.ema(close, emaFast)
emaS   = ta.ema(close, emaSlow)
atrV   = ta.atr(atrLen)
atrL   = ta.atr(atrLong)
volR   = atrV / (atrL + 1e-9)

// Trend index: 0=bear, 1=neutral, 2=bull
emaDiff  = (emaF - emaS) / (emaS + 1e-9)
trendIdx = emaDiff > 0.002 ? 2 : emaDiff < -0.002 ? 0 : 1

// RSI index: 0=low, 1=mid, 2=high
rsiIdx = rsiV < rsiLow ? 0 : rsiV > rsiHigh ? 2 : 1

// Volatility index: 0=low, 1=high
volIdx = volR > volThresh ? 1 : 0

// Combined state: 0..17
curState = trendIdx * 6 + rsiIdx * 2 + volIdx

f_stateName(s) =>
    t = math.floor(s / 6)
    rest = s % 6
    r = math.floor(rest / 2)
    v = rest % 2
    tStr = t == 0 ? "Bear" : t == 1 ? "Flat" : "Bull"
    rStr = r == 0 ? "RSI↓" : r == 1 ? "RSI·" : "RSI↑"
    vStr = v == 0 ? "LoVol" : "HiVol"
    tStr + " · " + rStr + " · " + vStr

// ═══════════════════════════════════════════════════════════════
//  Q-TABLE: 18 states × 3 actions
// ═══════════════════════════════════════════════════════════════
// Action: 0=Long, 1=Short, 2=Skip
NS = 18
NA = 3

var array<float> Q     = array.new<float>(NS * NA, 0.0)
var array<int>   Nvis  = array.new<int>(NS * NA, 0)
var int totalEpisodes  = 0
var int totalUpdates   = 0
var float totalReward  = 0.0
var int totalLong      = 0
var int totalShort     = 0
var int totalSkip      = 0
var int totalWins      = 0
var int totalLosses    = 0

// Store previous state/action for TD update
var int   prevState  = -1
var int   prevAction = -1

// Track recent rewards
var array<float> recentRewards = array.new<float>(0)
REWARD_WINDOW = 50

// MFE/MAE arrays for TP/SL estimation
var array<float> mfeLong  = array.new<float>(0)
var array<float> maeLong  = array.new<float>(0)
var array<float> mfeShort = array.new<float>(0)
var array<float> maeShort = array.new<float>(0)
MAX_TRADES = 200

// ═══════════════════════════════════════════════════════════════
//  EPSILON (exploration) SCHEDULE
// ─ FIX: cast to float to avoid int/int = 0 when totalEpisodes < epsDecayLen ─
// ═══════════════════════════════════════════════════════════════
decayFrac = math.min(1.0, float(totalEpisodes) / float(math.max(1, epsDecayLen)))
epsCur = math.max(epsEnd, epsStart - (epsStart - epsEnd) * decayFrac)
alphaCur = alpha0

// ═══════════════════════════════════════════════════════════════
//  Q-TABLE HELPERS
// ═══════════════════════════════════════════════════════════════
f_qGet(s, a) => array.get(Q, s * NA + a)
f_qSet(s, a, v) => array.set(Q, s * NA + a, v)
f_nGet(s, a) => array.get(Nvis, s * NA + a)
f_nInc(s, a) => array.set(Nvis, s * NA + a, array.get(Nvis, s * NA + a) + 1)

f_maxQ(s) =>
    q0 = f_qGet(s, 0)
    q1 = f_qGet(s, 1)
    q2 = f_qGet(s, 2)
    math.max(q0, math.max(q1, q2))

f_argmax(s) =>
    q0 = f_qGet(s, 0)
    q1 = f_qGet(s, 1)
    q2 = f_qGet(s, 2)
    best = 0
    bv = q0
    if q1 > bv
        bv := q1
        best := 1
    if q2 > bv
        bv := q2
        best := 2
    best

// Q-spread = best - second best (confidence proxy)
f_qSpread(s) =>
    q0 = f_qGet(s, 0)
    q1 = f_qGet(s, 1)
    q2 = f_qGet(s, 2)
    arr = array.from(q0, q1, q2)
    array.sort(arr, order.descending)
    array.get(arr, 0) - array.get(arr, 1)

// ═══════════════════════════════════════════════════════════════
//  EPSILON-GREEDY POLICY
// ═══════════════════════════════════════════════════════════════
// Deterministic "random" using bar_index * seed for reproducibility of exploration
f_pseudoRand(seed) =>
    x = math.sin(seed * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)

f_chooseAction(s, eps, seed) =>
    r = f_pseudoRand(seed)
    act = 0
    if r < eps
        r2 = f_pseudoRand(seed + 7.13)
        act := r2 < 0.333 ? 0 : r2 < 0.666 ? 1 : 2
    else
        act := f_argmax(s)
    act

// ═══════════════════════════════════════════════════════════════
//  REWARD CALCULATION
// ═══════════════════════════════════════════════════════════════
f_computeReward(action) =>
    rew = 0.0
    if bar_index >= rewardLook + 1
        atrRef = atrV[rewardLook] + 1e-9
        ret = (close - close[rewardLook]) / atrRef
        if action == 0
            rew := ret
        else if action == 1
            rew := -ret
        else
            rew := skipPenalty
    rew

// ═══════════════════════════════════════════════════════════════
//  LEARNING STEP (on confirmed bars)
// ═══════════════════════════════════════════════════════════════
// TD(0) update using (s_prev, a_prev, r, s_curr)
if barstate.isconfirmed and prevState >= 0 and prevAction >= 0
    r = f_computeReward(prevAction)
    qOld = f_qGet(prevState, prevAction)
    qNext = f_maxQ(curState)
    tdTarget = r + gamma * qNext
    tdError = tdTarget - qOld
    qNew = qOld + alphaCur * tdError
    f_qSet(prevState, prevAction, qNew)
    f_nInc(prevState, prevAction)
    totalUpdates += 1
    totalReward += r

    if prevAction == 0 or prevAction == 1
        if r > 0
            totalWins += 1
        else if r < 0
            totalLosses += 1

    array.push(recentRewards, r)
    while array.size(recentRewards) > REWARD_WINDOW
        array.shift(recentRewards)

// ═══════════════════════════════════════════════════════════════
//  ACTION SELECTION (current bar)
// ═══════════════════════════════════════════════════════════════
curAction = f_chooseAction(curState, epsCur, bar_index)
curQSpread = f_qSpread(curState)
isConfident = curQSpread >= minConfidence

emitLong  = isConfident and curAction == 0 and epsCur <= 0.15
emitShort = isConfident and curAction == 1 and epsCur <= 0.15

if barstate.isconfirmed
    prevState  := curState
    prevAction := curAction
    if curAction == 0
        totalLong += 1
    else if curAction == 1
        totalShort += 1
    else
        totalSkip += 1
    totalEpisodes += 1

// ═══════════════════════════════════════════════════════════════
//  TP/SL LEARNING VIA MFE / MAE TRACKING
// ═══════════════════════════════════════════════════════════════
var int   pendingAction = -1
var int   pendingBar    = -1
var float pendingEntry  = na
var float pendingAtr    = na
var float pendingMFE    = 0.0
var float pendingMAE    = 0.0

if barstate.isconfirmed
    if pendingAction >= 0
        mv = (close - pendingEntry) / pendingAtr
        if pendingAction == 0
            if mv > pendingMFE
                pendingMFE := mv
            if -mv > pendingMAE
                pendingMAE := -mv
        else if pendingAction == 1
            if -mv > pendingMFE
                pendingMFE := -mv
            if mv > pendingMAE
                pendingMAE := mv

        if bar_index - pendingBar >= trackBars
            if pendingAction == 0
                array.push(mfeLong, pendingMFE)
                array.push(maeLong, pendingMAE)
                while array.size(mfeLong) > MAX_TRADES
                    array.shift(mfeLong)
                while array.size(maeLong) > MAX_TRADES
                    array.shift(maeLong)
            else
                array.push(mfeShort, pendingMFE)
                array.push(maeShort, pendingMAE)
                while array.size(mfeShort) > MAX_TRADES
                    array.shift(mfeShort)
                while array.size(maeShort) > MAX_TRADES
                    array.shift(maeShort)
            pendingAction := -1

    if pendingAction < 0 and (curAction == 0 or curAction == 1)
        pendingAction := curAction
        pendingBar    := bar_index
        pendingEntry  := close
        pendingAtr    := atrV
        pendingMFE    := 0.0
        pendingMAE    := 0.0

// Compute quantile of sorted array
f_quantile(arr, q) =>
    n = array.size(arr)
    res = 1.0
    if n >= 3
        sorted = array.copy(arr)
        array.sort(sorted, order.ascending)
        idx = int(math.floor((n - 1) * q))
        res := array.get(sorted, idx)
    res

f_mean(arr) =>
    n = array.size(arr)
    m = 0.0
    if n > 0
        s = 0.0
        for i = 0 to n - 1
            s += array.get(arr, i)
        m := s / n
    m

tpLongATR  = f_quantile(mfeLong, tpConfidence)
slLongATR  = f_quantile(maeLong, slConfidence)
tpShortATR = f_quantile(mfeShort, tpConfidence)
slShortATR = f_quantile(maeShort, slConfidence)

// Reasonable defaults if insufficient data
tpLongATR  := tpLongATR  > 0.5 ? tpLongATR  : 2.0
slLongATR  := slLongATR  > 0.3 ? slLongATR  : 1.5
tpShortATR := tpShortATR > 0.5 ? tpShortATR : 2.0
slShortATR := slShortATR > 0.3 ? slShortATR : 1.5

tpLongPrice  = close + tpLongATR  * atrV
slLongPrice  = close - slLongATR  * atrV
tpShortPrice = close - tpShortATR * atrV
slShortPrice = close + slShortATR * atrV

rrLong  = tpLongATR  / math.max(slLongATR, 0.01)
rrShort = tpShortATR / math.max(slShortATR, 0.01)

// ═══════════════════════════════════════════════════════════════
//  SIGNAL PLOTS & TP/SL LINES
// ═══════════════════════════════════════════════════════════════
plotshape(showSignals and emitLong,  "RL Long",  shape.triangleup,   location.belowbar,
     color=cBull, size=size.normal, text="L", textcolor=color.white)
plotshape(showSignals and emitShort, "RL Short", shape.triangledown, location.abovebar,
     color=cBear, size=size.normal, text="S", textcolor=color.white)

var line tpLine = na
var line slLine = na
var line entryLine = na

if showTPSL and barstate.islast
    line.delete(tpLine)
    line.delete(slLine)
    line.delete(entryLine)

    bestAct = f_argmax(curState)
    if bestAct == 0 and isConfident
        tpLine    := line.new(bar_index - 10, tpLongPrice, bar_index + 20, tpLongPrice,
                     color=cBull, width=2, style=line.style_dashed)
        slLine    := line.new(bar_index - 10, slLongPrice, bar_index + 20, slLongPrice,
                     color=cBear, width=2, style=line.style_dashed)
        entryLine := line.new(bar_index - 10, close, bar_index + 20, close,
                     color=cAccent, width=1, style=line.style_dotted)
    else if bestAct == 1 and isConfident
        tpLine    := line.new(bar_index - 10, tpShortPrice, bar_index + 20, tpShortPrice,
                     color=cBull, width=2, style=line.style_dashed)
        slLine    := line.new(bar_index - 10, slShortPrice, bar_index + 20, slShortPrice,
                     color=cBear, width=2, style=line.style_dashed)
        entryLine := line.new(bar_index - 10, close, bar_index + 20, close,
                     color=cAccent, width=1, style=line.style_dotted)

// ═══════════════════════════════════════════════════════════════
//  STATISTICS
// ─ FIX: cast to float for correct percentage computation ─
// ═══════════════════════════════════════════════════════════════
totalTrades = totalWins + totalLosses
winRate = totalTrades > 0 ? float(totalWins) / float(totalTrades) * 100.0 : 0.0
avgReward = totalUpdates > 0 ? totalReward / totalUpdates : 0.0

recentAvg = array.size(recentRewards) > 0 ? f_mean(recentRewards) : 0.0
learningProgress = math.min(100.0, float(totalEpisodes) / float(math.max(1, epsDecayLen)) * 100.0)

// State coverage = # of state-action cells visited at least once
statesVisited = 0
for i = 0 to NS * NA - 1
    if array.get(Nvis, i) > 0
        statesVisited += 1
stateCoverage = float(statesVisited) / float(NS * NA) * 100.0

// Max |Q| for heatmap scaling
maxAbsQ = 0.0
for i = 0 to NS * NA - 1
    v = math.abs(array.get(Q, i))
    if v > maxAbsQ
        maxAbsQ := v

// Current state Q-values
qL = f_qGet(curState, 0)
qS = f_qGet(curState, 1)
qK = f_qGet(curState, 2)
bestActCur = f_argmax(curState)
bestActName = bestActCur == 0 ? "▲ LONG" : bestActCur == 1 ? "▼ SHORT" : "◆ SKIP"
bestActCol  = bestActCur == 0 ? cBull  : bestActCur == 1 ? cBear  : cMute

// ═══════════════════════════════════════════════════════════════
//  CURRENT STATE BOX (on price chart)
// ═══════════════════════════════════════════════════════════════
var box stBox = na
if showStateBox and barstate.islast
    box.delete(stBox)
    if isConfident and (bestActCur == 0 or bestActCur == 1)
        bCol = bestActCur == 0 ? cBull : cBear
        stBox := box.new(bar_index - 3, high + atrV * 0.5, bar_index + 3, low - atrV * 0.5,
             bgcolor=color.new(bCol, 85), border_color=color.new(bCol, 30), border_width=2)

// ═══════════════════════════════════════════════════════════════
//  MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
if barstate.islast and showDashboard
    dash := table.new(f_posHelper(dashPos), 6, 32,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    // ─── HEADER ───
    table.cell(dash, 0, 0, "◆  AETHEREDGE · RL SIGNAL OPTIMIZER  ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 5, 0)

    table.cell(dash, 0, 1,
         syminfo.ticker + "  ·  " + timeframe.period +
         "  ·  Q-Learning TD(0)  ·  " + str.tostring(NS) + "×" + str.tostring(NA) + " Q-Table",
         text_color=cMute, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 5, 1)

    // ─── LEARNING PROGRESS ───
    table.cell(dash, 0, 2, "◢  LEARNING PROGRESS  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 5, 2)

    nBlocks = math.min(10, math.round(learningProgress / 10.0))
    progBar = ""
    for b = 0 to 9
        progBar := progBar + (b < nBlocks ? "▰" : "▱")

    table.cell(dash, 0, 3, "Training Progress",
         text_color=cMute, bgcolor=cBgRow, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 3, progBar,
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_left, text_size=size.large)
    table.cell(dash, 2, 3, str.tostring(learningProgress, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_halign=text.align_center, text_size=size.large)
    table.merge_cells(dash, 1, 3, 2, 3)

    phaseLabel = epsCur > 0.20 ? "◆ EXPLORING" : epsCur > 0.08 ? "◆ MIXING" : "◆ EXPLOITING"
    phaseCol   = epsCur > 0.20 ? cWarn : epsCur > 0.08 ? cBlue : cBull
    table.cell(dash, 3, 3, "Phase", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 4, 3, phaseLabel,
         text_color=color.white, bgcolor=color.new(phaseCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 4, 3, 5, 3)

    table.cell(dash, 0, 4, "Episodes", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 4, str.tostring(totalEpisodes),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 4, "Q-Updates", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 4, str.tostring(totalUpdates),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 4, "Coverage", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 4, str.tostring(stateCoverage, "#.#") + "%",
         text_color=stateCoverage > 80 ? cBull : stateCoverage > 50 ? cWarn : cBear,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 5, "ε (exploration)", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 5, str.tostring(epsCur, "#.###"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 5, "α (learn rate)", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 5, str.tostring(alphaCur, "#.###"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 5, "γ (discount)", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 5, str.tostring(gamma, "#.##"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // ─── CURRENT STATE ───
    table.cell(dash, 0, 6, "◢  CURRENT STATE · POLICY  ◣",
         text_color=color.white, bgcolor=color.new(cPurple, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 6, 5, 6)

    table.cell(dash, 0, 7, "State ID", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 7, "S" + str.tostring(curState),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 7, "Features", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 7, f_stateName(curState),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 3, 7, 5, 7)

    table.cell(dash, 0, 8, "RSI(" + str.tostring(rsiLen) + ")", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 8, str.tostring(rsiV, "#.#"),
         text_color=rsiV > 70 ? cBear : rsiV < 30 ? cBull : cText,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 8, "EMA Diff", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 8, str.tostring(emaDiff * 100, "+#.##;-#.##") + "%",
         text_color=emaDiff > 0 ? cBull : cBear,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 8, "Vol Ratio", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 8, str.tostring(volR, "#.##") + "×",
         text_color=volR > volThresh ? cWarn : cMute,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // Q-values for current state with visual bars
    maxQCur = math.max(math.abs(qL), math.max(math.abs(qS), math.abs(qK)))
    maxQCur := maxQCur < 1e-6 ? 1.0 : maxQCur

    table.cell(dash, 0, 9, "Q[Long]",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 9, str.tostring(qL, "+0.000;-0.000"),
         text_color=color.white, bgcolor=color.new(qL > 0 ? cBull : cBear, 40),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 9, f_qBar(qL, maxQCur),
         text_color=qL > 0 ? cBull : cBear, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=size.normal)
    table.cell(dash, 3, 9, "Visits", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 4, 9, str.tostring(f_nGet(curState, 0)),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 4, 9, 5, 9)

    table.cell(dash, 0, 10, "Q[Short]",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 10, str.tostring(qS, "+0.000;-0.000"),
         text_color=color.white, bgcolor=color.new(qS > 0 ? cBull : cBear, 40),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 10, f_qBar(qS, maxQCur),
         text_color=qS > 0 ? cBull : cBear, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=size.normal)
    table.cell(dash, 3, 10, "Visits", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 4, 10, str.tostring(f_nGet(curState, 1)),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 4, 10, 5, 10)

    table.cell(dash, 0, 11, "Q[Skip]",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 11, str.tostring(qK, "+0.000;-0.000"),
         text_color=color.white, bgcolor=color.new(qK > 0 ? cBull : cBear, 50),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 11, f_qBar(qK, maxQCur),
         text_color=qK > 0 ? cBull : cBear, bgcolor=cBgRow,
         text_halign=text.align_left, text_size=size.normal)
    table.cell(dash, 3, 11, "Visits", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 4, 11, str.tostring(f_nGet(curState, 2)),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 4, 11, 5, 11)

    // Policy recommendation
    confLabel = isConfident ? "✓ CONFIDENT" : "◎ UNCERTAIN"
    confCol   = isConfident ? cBull : cWarn
    table.cell(dash, 0, 12, "POLICY",
         text_color=color.white, bgcolor=cBgAlt, text_halign=text.align_right, text_size=size.large)
    table.cell(dash, 1, 12, bestActName,
         text_color=color.white, bgcolor=color.new(bestActCol, 10),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 12, "Q-Spread", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 12, str.tostring(curQSpread, "0.000"),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 12, confLabel,
         text_color=color.white, bgcolor=color.new(confCol, 20),
         text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 4, 12, 5, 12)

    // ─── PERFORMANCE ───
    table.cell(dash, 0, 13, "◢  PERFORMANCE METRICS  ◣",
         text_color=color.white, bgcolor=color.new(cGold, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 13, 5, 13)

    table.cell(dash, 0, 14, "Total Trades", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 14, str.tostring(totalTrades),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 14, "Wins", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 14, str.tostring(totalWins),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 14, "Losses", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 14, str.tostring(totalLosses),
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)

    wrCol = winRate >= 60 ? cBull : winRate >= 45 ? cWarn : cBear
    table.cell(dash, 0, 15, "Win Rate", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 15, str.tostring(winRate, "#.#") + "%",
         text_color=color.white, bgcolor=color.new(wrCol, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 15, "Avg Reward", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 15, str.tostring(avgReward, "+0.0000;-0.0000"),
         text_color=avgReward > 0 ? cBull : cBear,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 15, "Recent(" + str.tostring(REWARD_WINDOW) + ")",
         text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 15, str.tostring(recentAvg, "+0.0000;-0.0000"),
         text_color=recentAvg > 0 ? cBull : cBear,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 16, "Actions Taken",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 16, "L: " + str.tostring(totalLong),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 16, "S: " + str.tostring(totalShort),
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 16, "K: " + str.tostring(totalSkip),
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    ratio = totalEpisodes > 0 ? float(totalLong + totalShort) / float(totalEpisodes) * 100.0 : 0.0
    table.cell(dash, 4, 16, "Active %",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, 16, str.tostring(ratio, "#.#") + "%",
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // ─── OPTIMIZED TP/SL ───
    table.cell(dash, 0, 17, "◢  OPTIMIZED TP/SL · LEARNED FROM MFE/MAE  ◣",
         text_color=color.white, bgcolor=color.new(cBull, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 17, 5, 17)

    table.cell(dash, 0, 18, "Direction", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, 18, "TP (ATR×)", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 18, "SL (ATR×)", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 18, "TP Price", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 18, "SL Price", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 18, "R:R", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.normal)

    nLong = array.size(mfeLong)
    rrLongCol = rrLong >= 2.0 ? cBull : rrLong >= 1.5 ? cWarn : cBear
    table.cell(dash, 0, 19, "▲ LONG (n=" + str.tostring(nLong) + ")",
         text_color=color.white, bgcolor=color.new(cBull, 30),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, 19, str.tostring(tpLongATR, "#.##") + "×",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 19, str.tostring(slLongATR, "#.##") + "×",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 19, str.tostring(tpLongPrice, format.mintick),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 19, str.tostring(slLongPrice, format.mintick),
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 19, "1:" + str.tostring(rrLong, "#.##"),
         text_color=color.white, bgcolor=color.new(rrLongCol, 20),
         text_halign=text.align_center, text_size=size.normal)

    nShort = array.size(mfeShort)
    rrShortCol = rrShort >= 2.0 ? cBull : rrShort >= 1.5 ? cWarn : cBear
    table.cell(dash, 0, 20, "▼ SHORT (n=" + str.tostring(nShort) + ")",
         text_color=color.white, bgcolor=color.new(cBear, 30),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, 20, str.tostring(tpShortATR, "#.##") + "×",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 20, str.tostring(slShortATR, "#.##") + "×",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 20, str.tostring(tpShortPrice, format.mintick),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 20, str.tostring(slShortPrice, format.mintick),
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 20, "1:" + str.tostring(rrShort, "#.##"),
         text_color=color.white, bgcolor=color.new(rrShortCol, 20),
         text_halign=text.align_center, text_size=size.normal)

    // Trade stats expansion
    table.cell(dash, 0, 21, "Avg MFE", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 21, str.tostring(f_mean(mfeLong), "#.##") + "×",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 21, str.tostring(f_mean(mfeShort), "#.##") + "×",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 21, "Avg MAE", text_color=cMute, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 4, 21, str.tostring(f_mean(maeLong), "#.##") + "×",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 21, str.tostring(f_mean(maeShort), "#.##") + "×",
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

// ═══════════════════════════════════════════════════════════════
//  Q-TABLE HEATMAP (separate panel)
// ═══════════════════════════════════════════════════════════════
var table qtbl = na
if barstate.islast and showQTable
    qtbl := table.new(f_posHelper(qTablePos), 5, NS + 3,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cPurple, frame_width=1)

    table.cell(qtbl, 0, 0, "◆  Q-TABLE HEATMAP  ◆",
         text_color=cPurple, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(qtbl, 0, 0, 4, 0)

    table.cell(qtbl, 0, 1, "State", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(qtbl, 1, 1, "Features", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(qtbl, 2, 1, "Q[L]", text_color=cBull, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(qtbl, 3, 1, "Q[S]", text_color=cBear, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(qtbl, 4, 1, "Q[K]", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)

    for s = 0 to NS - 1
        rowColor = s == curState ? cBgHi : (s % 2 == 0 ? cBgRow : cBgAlt)
        stateLbl = "S" + str.tostring(s) + (s == curState ? " ◀" : "")
        table.cell(qtbl, 0, s + 2, stateLbl,
             text_color=s == curState ? cAccent : cText,
             bgcolor=rowColor, text_halign=text.align_center, text_size=size.normal)
        table.cell(qtbl, 1, s + 2, f_stateName(s),
             text_color=cText, bgcolor=rowColor, text_halign=text.align_left, text_size=size.normal)

        qlv = f_qGet(s, 0)
        qsv = f_qGet(s, 1)
        qkv = f_qGet(s, 2)

        table.cell(qtbl, 2, s + 2, f_nGet(s, 0) == 0 ? "—" : str.tostring(qlv, "+0.00;-0.00"),
             text_color=color.white, bgcolor=f_qColor(qlv, maxAbsQ),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(qtbl, 3, s + 2, f_nGet(s, 1) == 0 ? "—" : str.tostring(qsv, "+0.00;-0.00"),
             text_color=color.white, bgcolor=f_qColor(qsv, maxAbsQ),
             text_halign=text.align_center, text_size=size.normal)
        table.cell(qtbl, 4, s + 2, f_nGet(s, 2) == 0 ? "—" : str.tostring(qkv, "+0.00;-0.00"),
             text_color=color.white, bgcolor=f_qColor(qkv, maxAbsQ),
             text_halign=text.align_center, text_size=size.normal)

    // Footer
    table.cell(qtbl, 0, NS + 2, "● Current State   ◆ max|Q| = " + str.tostring(maxAbsQ, "#.###"),
         text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(qtbl, 0, NS + 2, 4, NS + 2)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(emitLong,  "RL Long Signal",  "AE-RL: Long signal on {{ticker}} @ {{close}}")
alertcondition(emitShort, "RL Short Signal", "AE-RL: Short signal on {{ticker}} @ {{close}}")

// Hidden plots for payload
plot(qL, "Q Long", display=display.none)
plot(qS, "Q Short", display=display.none)
plot(qK, "Q Skip", display=display.none)
plot(epsCur, "Epsilon", display=display.none)
plot(winRate, "Win Rate", display=display.none)
````
