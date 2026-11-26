# AetherEdge AI Divergence Ghost

- url: https://www.tradingview.com/script/E0nv7SCB/
- type: indicator
- pine_id: PUB;e272efbd9a8b4b4baaefeecae6d03187
- version: 1.0

## Description

🖊️ Overview
AetherEdge AI Divergence Ghost is a next-generation divergence detector that neurally fuses five oscillators and self-evolves their weights based on real-time correlation with future price action. By eliminating single-oscillator noise and filtering through a multi-layer confidence score, it plots only elite-grade signals as ultra-minimal ghost arrows — a silent sniper indicator built for clarity and conviction.

🔶 Key Features

Multi-Oscillator Neural Fusion: RSI, MACD, Stochastic, MFI, and CCI normalized via Z-score
Adaptive Weight Learning: Softmax weights derived from each oscillator's correlation with forward returns
4-Type Divergence Detection: Regular Bull/Bear & Hidden Bull/Bear
Confidence Scoring: Combines divergence magnitude with multi-oscillator agreement
Pivot Distance Filter: minBars / maxBars eliminate low-quality setups
Cooldown Mechanism: Prevents arrow clustering
Ghost Arrow Visuals: Tiny, transparency-adjustable triangles keep charts pristine
🧠 Technical Architecture
The engine combines a self-evolving neural oscillator with multi-layer validation.

Normalization Layer: All five oscillators are converted to a 50-period Z-score (x-μ)/σ, ensuring scale-uniform fusion.
Adaptive Weight Learning: A 100-bar correlation between each oscillator (lagged 5 bars) and forward return is computed. Only positive correlations contribute, normalized softmax-style — so oscillators that actually work in the current regime gain influence automatically.
Neural Composite Oscillator: neuralOsc = Σ(w_i × n_i) produces a regime-optimal signal.
Dual-Layer Pivot Detection: Pivots are tracked on both price and the neural oscillator, evaluating all four divergence types logically.
Confidence Scoring: Combines price/oscillator delta magnitude with an agreement bonus (how many of 5 raw oscillators confirm the divergence direction) into a final composite score.
Cooldown & Threshold Filter: Signals fire only when score ≥ minScore AND cooldown bars have elapsed — strict elite-only output.
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC/ETH (1H–4H): Lookback=50, Pivot Strength=5, Min Score=0.6
SOL/XRP (15M–1H): Pivot Strength=3, Min Score=0.65 (noise-resistant)
Swing (4H–1D): Lookback=80, maxBars=100, Min Score=0.55
Tuning Tips:

Too few signals: Lower Min Score to 0.5, or disable Adaptive Weight Learning
Too many signals: Raise Min Score to 0.7+, Pivot Strength to 7+
Trending regime: Show Hidden only (disable Regular)
Ranging regime: Show Regular only (disable Hidden)
💡 How to Use in Practice

Regular Bull/Bear: Counter-trend reversal entries
Hidden Bull/Bear: Trend-continuation pullback/rally entries
Multi-Timeframe: Use HTF Regular divergences for bias, LTF Hidden divergences for precision entries
Combinations: Pair with AetherEdge Adaptive Super Neural — Ghost signals coinciding with trend flips offer extreme conviction
S/R Confluence: Ghost arrows at major S/R zones dramatically boost reversal probability
⚠️ Important Notes

Pivots confirm pivotLen bars after formation — signals plot historically (confirmation delay, not repaint)
The first ~100 bars serve as a learning warm-up; Adaptive Weight accuracy improves thereafter
After abrupt volatility shifts, normalization needs several bars to restabilize
Divergence offers probabilistic edge — always combine with confluence and risk management
🚨 Disclaimer
This indicator is provided for educational and research purposes only and does not constitute financial advice. All trading decisions are made at your own risk and should be accompanied by proper risk management. Past performance is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("AetherEdge AI Divergence Ghost", shorttitle="AE-Ghost", overlay=true, max_labels_count=500)

// ============================================================
// ▼ INPUTS
// ============================================================
grpNN       = "🧠 Neural Oscillator"
lookback    = input.int(50,  "Divergence Lookback",   minval=10, maxval=200, group=grpNN, tooltip="ピボット検索範囲")
pivotLen    = input.int(5,   "Pivot Strength",        minval=2,  maxval=15,  group=grpNN, tooltip="ピボット確定バー数")
minBars     = input.int(5,   "Min Bars Between Pivots",minval=3, maxval=30,  group=grpNN)
maxBars     = input.int(60,  "Max Bars Between Pivots",minval=20,maxval=200, group=grpNN)

grpFilter   = "🎯 Quality Filter"
minScore    = input.float(0.6,"Min Confidence Score", minval=0.3,maxval=1.0,step=0.05, group=grpFilter, tooltip="高いほど少数精鋭")
adaptive    = input.bool(true,"Adaptive Weight Learning", group=grpFilter)

grpVis      = "👻 Ghost Visual"
arrowOpacity= input.int(60,  "Arrow Transparency",    minval=0,  maxval=90,  group=grpVis, tooltip="高いほど薄い")
colBull     = input.color(color.green, "Bullish Arrow", group=grpVis)
colBear     = input.color(color.red,   "Bearish Arrow", group=grpVis)
showHidden  = input.bool(true, "Show Hidden Divergence", group=grpVis)
showRegular = input.bool(true, "Show Regular Divergence",group=grpVis)

// ============================================================
// ▼ MULTI-OSCILLATOR FEATURES
// ============================================================
rsiV   = ta.rsi(close, 14)
[macdL,_,_] = ta.macd(close, 12, 26, 9)
stochV = ta.stoch(close, high, low, 14)
mfiV   = ta.mfi(hlc3, 14)
cciV   = ta.cci(close, 20)

// Normalize each to comparable scale (z-score-ish)
norm(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0

n_rsi   = norm(rsiV,   50)
n_macd  = norm(macdL,  50)
n_stoch = norm(stochV, 50)
n_mfi   = norm(mfiV,   50)
n_cci   = norm(cciV,   50)

// ============================================================
// ▼ NEURAL WEIGHTING (adaptive performance learning)
// ============================================================
// Each oscillator's weight ∝ recent correlation with future price moves.
// Lightweight implementation: rolling correlation with forward return.

futRet = (close - close[5]) / close[5]  // 5-bar forward ref (uses past)

corrLen = 100
c_rsi   = ta.correlation(n_rsi[5],   futRet, corrLen)
c_macd  = ta.correlation(n_macd[5],  futRet, corrLen)
c_stoch = ta.correlation(n_stoch[5], futRet, corrLen)
c_mfi   = ta.correlation(n_mfi[5],   futRet, corrLen)
c_cci   = ta.correlation(n_cci[5],   futRet, corrLen)

// Convert correlations to softmax weights (only positive contributors)
ac_rsi   = math.max(0, nz(c_rsi))
ac_macd  = math.max(0, nz(c_macd))
ac_stoch = math.max(0, nz(c_stoch))
ac_mfi   = math.max(0, nz(c_mfi))
ac_cci   = math.max(0, nz(c_cci))

wSum_raw = ac_rsi + ac_macd + ac_stoch + ac_mfi + ac_cci

w_rsi   = adaptive and wSum_raw > 0 ? ac_rsi   / wSum_raw : 0.20
w_macd  = adaptive and wSum_raw > 0 ? ac_macd  / wSum_raw : 0.20
w_stoch = adaptive and wSum_raw > 0 ? ac_stoch / wSum_raw : 0.20
w_mfi   = adaptive and wSum_raw > 0 ? ac_mfi   / wSum_raw : 0.20
w_cci   = adaptive and wSum_raw > 0 ? ac_cci   / wSum_raw : 0.20

// Composite neural oscillator
neuralOsc = w_rsi*n_rsi + w_macd*n_macd + w_stoch*n_stoch + w_mfi*n_mfi + w_cci*n_cci

// ============================================================
// ▼ PIVOT DETECTION (on price + neural oscillator)
// ============================================================
pH_price = ta.pivothigh(high, pivotLen, pivotLen)
pL_price = ta.pivotlow(low,   pivotLen, pivotLen)
pH_osc   = ta.pivothigh(neuralOsc, pivotLen, pivotLen)
pL_osc   = ta.pivotlow(neuralOsc,  pivotLen, pivotLen)

// Track last two pivots for price and oscillator
var float prevPH_p = na, var int prevPH_p_bar = na
var float lastPH_p = na, var int lastPH_p_bar = na
var float prevPL_p = na, var int prevPL_p_bar = na
var float lastPL_p = na, var int lastPL_p_bar = na

var float prevPH_o = na, var float lastPH_o = na
var float prevPL_o = na, var float lastPL_o = na

if not na(pH_price)
    prevPH_p := lastPH_p
    prevPH_p_bar := lastPH_p_bar
    lastPH_p := high[pivotLen]
    lastPH_p_bar := bar_index - pivotLen

if not na(pL_price)
    prevPL_p := lastPL_p
    prevPL_p_bar := lastPL_p_bar
    lastPL_p := low[pivotLen]
    lastPL_p_bar := bar_index - pivotLen

if not na(pH_osc)
    prevPH_o := lastPH_o
    lastPH_o := neuralOsc[pivotLen]

if not na(pL_osc)
    prevPL_o := lastPL_o
    lastPL_o := neuralOsc[pivotLen]

// ============================================================
// ▼ DIVERGENCE LOGIC
// ============================================================
// Regular Bullish:  price LL, osc HL  → reversal up
// Regular Bearish:  price HH, osc LH  → reversal down
// Hidden Bullish:   price HL, osc LL  → trend continuation up
// Hidden Bearish:   price LH, osc HH  → trend continuation down

barsBetweenL = na(prevPL_p_bar) ? 0 : lastPL_p_bar - prevPL_p_bar
barsBetweenH = na(prevPH_p_bar) ? 0 : lastPH_p_bar - prevPH_p_bar

validRangeL = barsBetweenL >= minBars and barsBetweenL <= maxBars
validRangeH = barsBetweenH >= minBars and barsBetweenH <= maxBars

regBull = not na(pL_price) and not na(prevPL_p) and not na(lastPL_o) and not na(prevPL_o) and validRangeL and lastPL_p < prevPL_p and lastPL_o > prevPL_o
regBear = not na(pH_price) and not na(prevPH_p) and not na(lastPH_o) and not na(prevPH_o) and validRangeH and lastPH_p > prevPH_p and lastPH_o < prevPH_o
hidBull = not na(pL_price) and not na(prevPL_p) and not na(lastPL_o) and not na(prevPL_o) and validRangeL and lastPL_p > prevPL_p and lastPL_o < prevPL_o
hidBear = not na(pH_price) and not na(prevPH_p) and not na(lastPH_o) and not na(prevPH_o) and validRangeH and lastPH_p < prevPH_p and lastPH_o > prevPH_o

// ============================================================
// ▼ CONFIDENCE SCORING
// ============================================================
// Score = magnitude of divergence × oscillator agreement
calcScore(float p1, float p2, float o1, float o2) =>
    pDelta = math.abs(p2 - p1) / math.max(p1, 0.0001)
    oDelta = math.abs(o2 - o1)
    rawScore = math.min(1.0, pDelta * 50 + oDelta * 0.5)
    rawScore

scoreL = regBull or hidBull ? calcScore(prevPL_p, lastPL_p, prevPL_o, lastPL_o) : 0.0
scoreH = regBear or hidBear ? calcScore(prevPH_p, lastPH_p, prevPH_o, lastPH_o) : 0.0

// Multi-oscillator agreement bonus: if 3+ raw oscillators show same divergence
oscAgreeBull = (n_rsi[pivotLen] > n_rsi[pivotLen + barsBetweenL] ? 1 : 0) + (n_macd[pivotLen] > n_macd[pivotLen + barsBetweenL] ? 1 : 0) + (n_stoch[pivotLen] > n_stoch[pivotLen + barsBetweenL] ? 1 : 0) + (n_mfi[pivotLen] > n_mfi[pivotLen + barsBetweenL] ? 1 : 0) + (n_cci[pivotLen] > n_cci[pivotLen + barsBetweenL] ? 1 : 0)

oscAgreeBear = (n_rsi[pivotLen] < n_rsi[pivotLen + barsBetweenH] ? 1 : 0) + (n_macd[pivotLen] < n_macd[pivotLen + barsBetweenH] ? 1 : 0) + (n_stoch[pivotLen] < n_stoch[pivotLen + barsBetweenH] ? 1 : 0) + (n_mfi[pivotLen] < n_mfi[pivotLen + barsBetweenH] ? 1 : 0) + (n_cci[pivotLen] < n_cci[pivotLen + barsBetweenH] ? 1 : 0)

agreeBonusBull = oscAgreeBull / 5.0
agreeBonusBear = oscAgreeBear / 5.0

finalScoreBull = scoreL * 0.5 + agreeBonusBull * 0.5
finalScoreBear = scoreH * 0.5 + agreeBonusBear * 0.5

// ============================================================
// ▼ FILTER & DEDUPE
// ============================================================
showRegBull = regBull and showRegular and finalScoreBull >= minScore
showRegBear = regBear and showRegular and finalScoreBear >= minScore
showHidBull = hidBull and showHidden  and finalScoreBull >= minScore
showHidBear = hidBear and showHidden  and finalScoreBear >= minScore

bullSignal = showRegBull or showHidBull
bearSignal = showRegBear or showHidBear

// Cooldown to avoid arrow clusters
var int lastBullBar = na
var int lastBearBar = na
cooldown = 8

bullOK = bullSignal and (na(lastBullBar) or bar_index - lastBullBar > cooldown)
bearOK = bearSignal and (na(lastBearBar) or bar_index - lastBearBar > cooldown)

if bullOK
    lastBullBar := bar_index
if bearOK
    lastBearBar := bar_index

// ============================================================
// ▼ PLOT — TINY GHOST ARROWS ONLY
// ============================================================
arrowColBull = color.new(colBull, arrowOpacity)
arrowColBear = color.new(colBear, arrowOpacity)

plotshape(bullOK, title="Bullish Ghost", style=shape.triangleup, location=location.belowbar, color=arrowColBull, size=size.tiny, offset=-pivotLen)

plotshape(bearOK, title="Bearish Ghost", style=shape.triangledown, location=location.abovebar, color=arrowColBear, size=size.tiny, offset=-pivotLen)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(bullOK, title="Ghost Bullish Divergence", message="AE-Ghost: Bullish divergence detected")
alertcondition(bearOK, title="Ghost Bearish Divergence", message="AE-Ghost: Bearish divergence detected")
````
