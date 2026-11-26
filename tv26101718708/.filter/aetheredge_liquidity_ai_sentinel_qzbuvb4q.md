# AetherEdge Liquidity AI Sentinel

- url: https://www.tradingview.com/script/qZBuVb4Q/
- type: indicator
- pine_id: PUB;246910e4d43c4089bfc183c40542ebc4
- version: 1.0

## Description

AetherEdge Liquidity AI Sentinel [AetherEdge]

🖊️ Overview
AetherEdge Liquidity AI Sentinel fuses liquidity sweep detection (stop hunts) with KNN (K-Nearest Neighbors) machine learning to deliver a self-learning reversal AI. By memorizing past sweep patterns and comparing real-time feature vectors against historical analogs, it computes a probabilistic reversal score and alerts only on high-conviction setups — a true market sentinel that tracks the footprints of smart money.

🔶 Key Features

Automatic Liquidity Sweep Detection: Captures stop hunts beyond swing H/L with wick rejection
KNN Machine Learning Engine: Predicts reversal probability from historical analogs
3D Feature Space: Z-score normalized RSI, relative volume, and relative ATR
Self-Learning Memory: Stores up to 2000 sweep patterns
Auto-Outcome Labeling: 10-bar forward evaluation tags success/failure
Probability Threshold Filter: Only fires above minProb conviction
Minimalist Visuals: Tiny ghost arrows preserve chart clarity
🧠 Technical Architecture
The engine merges liquidity theory with a KNN self-learning core.

Sweep Detection Layer: Identifies price action that exceeds pivot H/L, closes back inside, and produces a wick larger than ATR × sweepBuffer — the classic stop-hunt signature.
Feature Engineering: RSI, volume/volMA ratio, and ATR/close ratio are Z-score normalized, producing a regime-agnostic 3D feature vector.
Pattern Memory: Each sweep stores features, direction, and bar index in a FIFO buffer auto-pruned at historyLen.
Automatic Outcome Labeling: After 10 bars, each record is auto-evaluated as success (1) or failure (0) based on whether an ATR-magnitude reversal occurred.
KNN Probability Inference: On new sweeps, K nearest same-direction historical cases are sampled, and their success rate becomes the live reversal probability.
Two-Stage Filter: Arrows fire only when both sweep detection AND probability threshold are satisfied — strict elite-only output.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (1H–4H): Swing Length=10, K=8, Min Prob=0.65
SOL/XRP (15M–1H): Swing Length=7, K=5, Min Prob=0.7 (noise-resistant)
Scalping (5M): Swing Length=5, Sweep Buffer=0.1, Min Prob=0.7
Swing (1D): Swing Length=15, History=1000, Min Prob=0.6
Tuning Tips:

Insufficient learning data: Lower Min Prob to 0.55 to allow early signals
Too many false sweeps: Raise Sweep Buffer to 0.1–0.2 for cleaner wicks
K Neighbors: Few (3–5) = sensitive, many (10–20) = robust
Pattern Memory: Longer = more statistical stability, but slower learning
💡 How to Use in Practice

Long Setup: Sweep below recent swing low → close back inside → Bullish arrow → counter-trend long
Short Setup: Sweep above recent swing high → close back inside → Bearish arrow → counter-trend short
Multi-Timeframe: Confirm bias on HTF (4H) sweeps → enter precisely on LTF (15M) sweeps
AetherEdge Combinations: Sweeps at S/R Grid major lines offer extreme conviction
Stop Placement: Classic edge — place stops just beyond the sweep wick extreme
⚠️ Important Notes

Initial ~100 bars are a learning warm-up phase with reduced accuracy
Pivot confirmation introduces a swingLen-bar delay (confirmation lag, not repaint)
Strong trends may continue beyond sweeps — strict risk management is essential
Outcome evaluation is fixed at 10 bars; consider adjusting for extreme short/long-term regimes
🚨 Disclaimer
This indicator is provided for educational and research purposes only and does not constitute financial advice. All trading decisions are made at your own risk and should be accompanied by proper risk management. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("AetherEdge Liquidity AI Sentinel", shorttitle="AE-Sentinel", overlay=true)

// ============================================================
// INPUTS
// ============================================================
swingLen    = input.int(10, "Swing Pivot Strength", minval=3, maxval=30)
sweepBuffer = input.float(0.05, "Sweep Wick Ratio", minval=0.0, maxval=0.5, step=0.01)

kNeighbors  = input.int(8, "K Neighbors", minval=3, maxval=20)
featureLen  = input.int(20, "Feature Window", minval=10, maxval=50)
historyLen  = input.int(500, "Pattern Memory", minval=100, maxval=2000)
minProb     = input.float(0.65, "Min Reversal Probability", minval=0.5, maxval=0.95, step=0.05)

colBull     = input.color(color.teal, "Bullish Color")
colBear     = input.color(color.maroon, "Bearish Color")
showArrow   = input.bool(true, "Show Arrows")

// ============================================================
// CORE
// ============================================================
atr   = ta.atr(14)
volMA = ta.sma(volume, 20)
rsi   = ta.rsi(close, 14)

// ============================================================
// SWINGS
// ============================================================
swingH = ta.pivothigh(high, swingLen, swingLen)
swingL = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingH = na
var float lastSwingL = na

if not na(swingH)
    lastSwingH := high[swingLen]

if not na(swingL)
    lastSwingL := low[swingLen]

// ============================================================
// SWEEPS
// ============================================================
buySweep  = not na(lastSwingH) and high > lastSwingH and close < lastSwingH and (high - lastSwingH) > sweepBuffer * atr
sellSweep = not na(lastSwingL) and low  < lastSwingL and close > lastSwingL and (lastSwingL - low) > sweepBuffer * atr

// ============================================================
// FEATURES
// ============================================================
zscore(src) =>
    m = ta.sma(src, featureLen)
    s = ta.stdev(src, featureLen)
    s > 0 ? (src - m) / s : 0.0

f_rsi = zscore(rsi)
f_vol = zscore(volume / math.max(volMA, 1))
f_atr = zscore(atr / math.max(close, 0.0001))

// ============================================================
// MEMORY
// ============================================================
var mem_rsi = array.new_float()
var mem_vol = array.new_float()
var mem_atr = array.new_float()
var mem_dir = array.new_int()
var mem_bar = array.new_int()
var mem_out = array.new_int()

evalBars = 10

recordSweep(dir) =>
    array.push(mem_rsi, f_rsi)
    array.push(mem_vol, f_vol)
    array.push(mem_atr, f_atr)
    array.push(mem_dir, dir)
    array.push(mem_bar, bar_index)
    array.push(mem_out, -1)

    if array.size(mem_rsi) > historyLen
        array.shift(mem_rsi)
        array.shift(mem_vol)
        array.shift(mem_atr)
        array.shift(mem_dir)
        array.shift(mem_bar)
        array.shift(mem_out)

if buySweep
    recordSweep(1)

if sellSweep
    recordSweep(-1)

// ============================================================
// UPDATE OUTCOMES（←安全版）
// ============================================================
if array.size(mem_out) > 0
    for i = 0 to array.size(mem_out) - 1
        if array.get(mem_out, i) == -1
            recBar = array.get(mem_bar, i)
            offset = bar_index - recBar

            if offset >= evalBars and offset < bar_index
                dir = array.get(mem_dir, i)
                pricePast = close[offset]
                outcome = 0

                if dir == 1 and close < pricePast - atr
                    outcome := 1

                if dir == -1 and close > pricePast + atr
                    outcome := 1

                array.set(mem_out, i, outcome)

// ============================================================
// KNN（安全版）
// ============================================================
knnProb(dir) =>
    float prob = 0.0

    if array.size(mem_rsi) >= kNeighbors
        count = 0
        for i = 0 to array.size(mem_rsi) - 1
            if array.get(mem_dir, i) == dir and array.get(mem_out, i) != -1
                prob += array.get(mem_out, i)
                count += 1
                if count >= kNeighbors
                    break

        prob := count > 0 ? prob / count : 0.0

    prob

probBear = buySweep  ? knnProb(1)  : 0.0
probBull = sellSweep ? knnProb(-1) : 0.0

// ============================================================
// SIGNALS
// ============================================================
arrowBull = sellSweep and probBull >= minProb and showArrow
arrowBear = buySweep  and probBear >= minProb and showArrow

plotshape(arrowBull, style=shape.triangleup, location=location.belowbar, color=colBull, size=size.tiny)
plotshape(arrowBear, style=shape.triangledown, location=location.abovebar, color=colBear, size=size.tiny)

alertcondition(arrowBull, title="Bullish Reversal")
alertcondition(arrowBear, title="Bearish Reversal")
````
