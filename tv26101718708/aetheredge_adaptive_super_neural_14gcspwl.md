# AetherEdge Adaptive Super Neural

- url: https://www.tradingview.com/script/14gCSPwL/
- type: indicator
- pine_id: PUB;7affeba45b9e4cce9768c26c1fe0c4f1
- version: 1.0

## Description

🖊️ Overview
AetherEdge Adaptive Super Neural shatters the limitations of fixed-parameter SuperTrend with a self-evolving, trend-following engine. It computes 9 parameter combinations in parallel, dynamically selecting the best-performing configuration based on rolling reward scores, while an ε-greedy exploration mechanism elegantly resolves the classic exploitation-vs-exploration dilemma. The result: a next-generation smart SuperTrend that continuously adapts to shifting market regimes in real time.

🔶 Key Features

9-Parameter Parallel Engine: Simultaneously computes a 3×3 grid of ATR period × multiplier candidates
Self-Evolving Selection: Dynamically picks the optimal configuration based on recent N-bar returns
ε-Greedy Exploration: Reinforcement-learning-style logic prevents local-optimum traps
Argmax Decision Layer: Real-time selection of the highest-scoring parameter set
Trend Flip Alerts: Instant notifications for bullish/bearish reversals
Directional Coloring: Intuitive visualization of trend state
Clean Overlay Plot: Lightweight, reliable on-chart rendering
🧠 Technical Architecture
The core innovation lies in parallel candidate evaluation combined with RL-style selection logic.

Parameter Grid Generation: ATR period (periodMin–periodMax) and multiplier (multMin–multMax) are each split into 3 levels, producing 9 candidate SuperTrend lines computed in parallel.
Reward Function: For each candidate, instantaneous PnL is calculated as prevDir × barReturn, then summed over learnWindow bars — effectively a virtual backtest score.
Argmax Selection: Each bar, the candidate with the highest cumulative reward is chosen as finalST.
ε-Greedy Exploration: With probability explorationRate, every 50 bars the algorithm randomly samples an alternative configuration. This prevents over-fitting to past regimes and ensures responsiveness to structural shifts — a direct implementation of the exploitation-exploration trade-off.
State-Isolated SuperTrend: Each candidate maintains independent upper/lower bands and direction state, ensuring safe parallel computation without cross-contamination.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (1H–4H): Learning Window=100, Adaptation Speed=0.15, Exploration Rate=0.10
SOL/XRP (15M–1H): Learning Window=80, Exploration Rate=0.15 (higher volatility)
Swing (1D): Learning Window=150, periodMax=30, multMax=5.0
Tuning Tips:

Trending Markets: Lower Exploration Rate to 0.05 to exploit the winning config
Range / Transition: Raise Exploration Rate to 0.20 to actively probe new parameters
Noisy Assets: Set multMin ≥ 2.0 to filter false flips
Learning Window: Too short → over-reactive; too long → laggy adaptation. ~100 is the sweet spot.
💡 How to Use in Practice

Flip Entries: Use finalDir reversals as primary trade triggers
Trailing Stop: Anchor dynamic SL to the finalST line
Multi-Timeframe: Confirm bias on higher TF, execute flips on lower TF
Combinations: Pair with AetherEdge Self-Evolving S/R Grid — flips occurring at strong S/R levels yield high-conviction signals
Regime Detection: Frequent parameter switching itself signals an unstable / transitioning market
⚠️ Important Notes

The first learnWindow bars represent a learning warm-up period — signal reliability stabilizes afterwards
ε-greedy exploration may occasionally select unexpected configurations by design
Optimization is based on recent history; abrupt regime shifts cause brief adaptation lag
9 parallel calculations may increase rendering load on lower-spec environments
🚨 Disclaimer
This indicator is provided for educational and research purposes only and does not constitute financial advice. All trading decisions are made at your own risk and should be accompanied by proper risk management. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("AetherEdge Adaptive Super Neural", shorttitle="AE-AdaptiveST", overlay=true)

// ============================================================
// ▼ INPUTS
// ============================================================
grpNL       = "🧠 NeuraLib Engine"
learnWindow = input.int(100, "Learning Window", minval=30, maxval=300, group=grpNL)
adaptSpeed  = input.float(0.15,"Adaptation Speed", minval=0.01,maxval=0.5, step=0.01, group=grpNL)
explorationRate = input.float(0.10,"Exploration Rate", minval=0.0, maxval=0.5, step=0.01, group=grpNL)

grpST       = "⚙️ SuperTrend Search Space"
periodMin   = input.int(7,   "ATR Period Min", minval=3,  maxval=30, group=grpST)
periodMax   = input.int(21,  "ATR Period Max", minval=5,  maxval=50, group=grpST)
multMin     = input.float(1.5,"Multiplier Min", minval=0.5,maxval=5.0,step=0.1, group=grpST)
multMax     = input.float(4.5,"Multiplier Max", minval=1.0,maxval=8.0,step=0.1, group=grpST)

grpVis      = "🎨 Visual"
colBull     = input.color(color.new(#00c853, 0), "Uptrend Color", group=grpVis)
colBear     = input.color(color.new(#ff1744, 0), "Downtrend Color", group=grpVis)
lineWidth   = input.int(2, "Line Width", minval=1, maxval=5, group=grpVis)

// ============================================================
// ▼ PARAMETER GRID (3x3)
// ============================================================
periodStep = (periodMax - periodMin) / 2
multStep   = (multMax - multMin) / 2

p1 = periodMin
p2 = periodMin + periodStep
p3 = periodMax

m1 = multMin
m2 = multMin + multStep
m3 = multMax

// ============================================================
// ▼ SUPERTREND FUNCTION（状態共有しない安全版）
// ============================================================
calcST(int len, float mult) =>
    atr = ta.atr(len)
    src = (high + low) / 2

    upperBasic = src + mult * atr
    lowerBasic = src - mult * atr

    var float upperBand = na
    var float lowerBand = na
    var int dir = na

    upperBand := na(upperBand[1]) ? upperBasic :
         (upperBasic < upperBand[1] or close[1] > upperBand[1]) ? upperBasic : upperBand[1]

    lowerBand := na(lowerBand[1]) ? lowerBasic :
         (lowerBasic > lowerBand[1] or close[1] < lowerBand[1]) ? lowerBasic : lowerBand[1]

    dir := na(dir[1]) ? 1 :
         dir[1] == -1 and close > upperBand[1] ? 1 :
         dir[1] == 1 and close < lowerBand[1] ? -1 :
         dir[1]

    st = dir == 1 ? lowerBand : upperBand
    [st, dir]

// ============================================================
// ▼ COMPUTE 9 CANDIDATES
// ============================================================
[st_11, dir_11] = calcST(p1, m1)
[st_12, dir_12] = calcST(p1, m2)
[st_13, dir_13] = calcST(p1, m3)

[st_21, dir_21] = calcST(p2, m1)
[st_22, dir_22] = calcST(p2, m2)
[st_23, dir_23] = calcST(p2, m3)

[st_31, dir_31] = calcST(p3, m1)
[st_32, dir_32] = calcST(p3, m2)
[st_33, dir_33] = calcST(p3, m3)

// ============================================================
// ▼ PERFORMANCE TRACKING
// ============================================================
barReturn = (close - close[1]) / close[1]

trackPerf(int prevDir) =>
    nz(prevDir) * barReturn

pnl_11 = trackPerf(dir_11[1])
pnl_12 = trackPerf(dir_12[1])
pnl_13 = trackPerf(dir_13[1])
pnl_21 = trackPerf(dir_21[1])
pnl_22 = trackPerf(dir_22[1])
pnl_23 = trackPerf(dir_23[1])
pnl_31 = trackPerf(dir_31[1])
pnl_32 = trackPerf(dir_32[1])
pnl_33 = trackPerf(dir_33[1])

perf_11 = math.sum(pnl_11, learnWindow)
perf_12 = math.sum(pnl_12, learnWindow)
perf_13 = math.sum(pnl_13, learnWindow)
perf_21 = math.sum(pnl_21, learnWindow)
perf_22 = math.sum(pnl_22, learnWindow)
perf_23 = math.sum(pnl_23, learnWindow)
perf_31 = math.sum(pnl_31, learnWindow)
perf_32 = math.sum(pnl_32, learnWindow)
perf_33 = math.sum(pnl_33, learnWindow)

// ============================================================
// ▼ ARGMAX SELECTION
// ============================================================
bestScore = perf_11
bestIdx = 1

if perf_12 > bestScore
    bestScore := perf_12
    bestIdx := 2
if perf_13 > bestScore
    bestScore := perf_13
    bestIdx := 3
if perf_21 > bestScore
    bestScore := perf_21
    bestIdx := 4
if perf_22 > bestScore
    bestScore := perf_22
    bestIdx := 5
if perf_23 > bestScore
    bestScore := perf_23
    bestIdx := 6
if perf_31 > bestScore
    bestScore := perf_31
    bestIdx := 7
if perf_32 > bestScore
    bestScore := perf_32
    bestIdx := 8
if perf_33 > bestScore
    bestScore := perf_33
    bestIdx := 9

// ε-greedy exploration
randSeed = (bar_index * 9301 + 49297) % 233280 / 233280.0
if randSeed < explorationRate and bar_index % 50 == 0
    bestIdx := 1 + int(randSeed * 100) % 9

// ============================================================
// ▼ FINAL SELECTION
// ============================================================
finalST =
     bestIdx == 1 ? st_11 :
     bestIdx == 2 ? st_12 :
     bestIdx == 3 ? st_13 :
     bestIdx == 4 ? st_21 :
     bestIdx == 5 ? st_22 :
     bestIdx == 6 ? st_23 :
     bestIdx == 7 ? st_31 :
     bestIdx == 8 ? st_32 : st_33

finalDir =
     bestIdx == 1 ? dir_11 :
     bestIdx == 2 ? dir_12 :
     bestIdx == 3 ? dir_13 :
     bestIdx == 4 ? dir_21 :
     bestIdx == 5 ? dir_22 :
     bestIdx == 6 ? dir_23 :
     bestIdx == 7 ? dir_31 :
     bestIdx == 8 ? dir_32 : dir_33

// ============================================================
// ▼ PLOT（確実に表示される版）
// ============================================================
lineCol = finalDir == 1 ? colBull : colBear
plot(finalST, title="Adaptive SuperTrend", color=lineCol, linewidth=lineWidth)

// ============================================================
// ▼ ALERTS
// ============================================================
flipBull = finalDir == 1 and finalDir[1] == -1
flipBear = finalDir == -1 and finalDir[1] == 1

alertcondition(flipBull, title="Adaptive ST Flip Bullish", message="AE-AdaptiveST: Trend flipped BULLISH")
alertcondition(flipBear, title="Adaptive ST Flip Bearish", message="AE-AdaptiveST: Trend flipped BEARISH")
````
