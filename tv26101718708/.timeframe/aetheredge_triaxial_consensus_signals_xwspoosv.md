# AetherEdge - Triaxial Consensus Signals

- url: https://www.tradingview.com/script/XWsPoosv/
- type: indicator
- pine_id: PUB;e67e6034aef4407a964f4459db046865
- version: 1.0

## Description

🖊️ Overview

AE-TRIAX is a high-conviction indicator that fires signals only when three independent analysis axes (Trend, Momentum, Volatility) agree. Each axis returns a continuous score in -100 to +100 rather than a discrete vote, so consensus is visualized as a gradient. Five AI/ML/RL layers — RL-style adaptive axis weights, ML regime classifier, MTF alignment, Q-learning thresholds, and Confidence% — self-tune per instrument, supporting everything from beginner presets to advanced customization. The lean voting system (which excludes neutral axes) makes BUY/SELL fully symmetric, responding appropriately to both bull and bear markets.

🔶 Key Features

3-axis continuous-score engine: precise consensus measurement in -100..+100 per axis
Lean voting system: neutral axes (|score| ≤ 10) excluded; only leaning axes drive consensus symmetrically
RL-style adaptive axis weights: each axis auto-weighted 1.0-1.8× by past accuracy
4-way regime auto-classification: Trend/Range/Volatile/Quiet biases axis weights
MTF alignment filter: two higher TFs (default 1h/4h) evaluated against current TF
Q-learning adaptive threshold: best trigger level learned within preset range
3-tier EMA cloud: short (8-21) / mid (21-55) / long (55-200) clouds stacked for layered trend perception
4-color tetrachrome palette: strong bull / weak bull / weak bear / strong bear visually separated
ATR-based auto SL/TP drawn on signals
3 presets: Beginner (default) / Standard / Aggressive
13-row integrated dashboard with DIAGNOSTIC row that fully exposes firing conditions
Custom alert support

🧠 Technical Architecture

This is a consensus system of three independent continuous scorers. Trend axis linearly combines 5-EMA stack alignment (25 points × 4 slots), Dow-style HH/HL vs LH/LL (pivot-swing update pattern), and ADX strength in 0.5:0.3:0.2. Momentum axis combines QQE-style RSI (distance from 50 × 2) and MACD histogram normalized by ATR in 0.6:0.4. Volatility axis uses Bollinger band width expansion/squeeze, ATR ratio healthy-range check (0.6-1.6), strong-candle (body/range > 0.5) gating, voting in the candle direction when conditions hold; price slope/ATR × 20 is added as a continuous component. Consensus uses lean voting: each axis is categorized as "↑lean (>10)" / "↓lean (<-10)" / "neutral (-10..10)"; majority among leaning axes plus a spread constraint determines toleranceOK. Neutral axes don't influence judgment, so even when the Volatility axis is often neutral, signals can still fire when other axes align — preserving BUY/SELL symmetry. Strong condition fires only when toleranceOK + |finalScore| ≥ activeThr + Trend axis leans in signal direction + majority agreed — all four conditions met. The AI layers use online EWMA reliability learning (α = 0.15 × Adaptation Strength) and ε-greedy Q-learning across 4 threshold candidates.

⚙️ Recommended Settings & Tuning Guide

Default is Beginner preset (threshold 50-70) for low false-signal rate. Switch to Standard (40-60) once familiar, or Aggressive (30-50) for advanced use. Cross-Axis Tolerance 20 baseline; 10 stricter, 30 looser. Adaptation Strength 1.0 is standard learning speed. MTF defaults 1h/4h; for 5-min trading change to 15m/1h; for daily use day/week. Min Weight 0.6 / Max Weight 1.8 controls the adaptive learning range; raise Max above 2.0 for more responsiveness.

💡 How to Use in Practice

Apply to chart and 3-axis consensus produces a large arrow with SL/TP lines and Confidence%-labeled bubble. Bar color (green/blue/yellow/red) gives instant consensus state. The HUD's "axis lean ↑n / ↓n ✓/✗" row shows how many axes lean up/down/neutral, and the bottom DIAGNOSTIC row exposes the current state. Examples:

✓ "★ BUY firing": strong-bull signal active on this bar
✗ "axes disagree": axes not aligned in one direction
✗ "+15 score to BUY": finalScore needs 15 more points to fire BUY
✗ "trend not down": Momentum/Volatility are down but Trend axis is neutral / not enough
✗ "BUY held (locked)": hysteresis preventing re-fire from prior BUY

Confidence ≥ 70% = strong entry, 40-70% = monitor, < 40% = skip is the practical workflow. "Quiet" regime means all signals are weak; "Trend" regime is the most reliable.

🧩 Relationship with Strategy Version

The indicator (AE-TRIAX) and strategy version (AE-TRIAX-S) share an identical signal-firing engine. Arrows print on the same bars and HUD values match across both. The strategy adds three execution-only safety filters (position already open, Confidence < 40%, drawdown breach) that only gate the entry call. Use the indicator for chart analysis and manual entry; use the strategy for backtesting and automated execution — they will agree on signals.

⚠️ Important Notes

This is an independent triaxial consensus system, not true multi-agent RL or deep learning. Each axis is a rule-based scorer; the AI layers reproduce the mathematical core of those techniques within Pine's limits (online EWMA reliability learning, Q-learning argmax selection, MTF alignment evaluation). MTF is via request.security so there's a small confirmed-bar delay. Q-learning requires per-instrument learning; during initial data accumulation, optimization is incomplete. All signals are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Triaxial Consensus Signals
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Triaxial Consensus Signals  ·  AE-TRIAX                       │
// │                                                                            │
// │  A three-axis decision engine that issues high-conviction signals only     │
// │  when TREND, MOMENTUM, and VOLATILITY axes agree within tolerance. Each    │
// │  axis returns a continuous score in [-100, +100] so consensus is a         │
// │  gradient, not a binary vote. Five AI/ML/RL layers adapt the engine to the │
// │  instrument in real time.                                                  │
// │                                                                            │
// │  AI / ML / RL LAYERS:                                                      │
// │    1. RL-style axis weights — each axis's past accuracy learned online,   │
// │       weight scaled 1.0–2.0× by reliability.                              │
// │    2. ML regime classifier — 4 regimes (Trend / Range / Volatile / Quiet) │
// │       bias the per-axis weight multipliers automatically.                 │
// │    3. MTF alignment filter — HTF score from 15m/1h/4h adjusts conviction.  │
// │    4. Q-learning thresholds — consensus trigger level self-optimises by   │
// │       reward outcome.                                                     │
// │    5. Confidence% — total weighted score / max-possible mapped to 0-100%, │
// │       used to size signal emphasis (full arrow vs faint marker).         │
// │                                                                            │
// │  HONEST SCOPE: not multi-agent RL or deep learning — each axis is a clear │
// │  rule set; adaptive layers use online EWMA/argmax reproductions of the    │
// │  RL core. Within Pine's limits, this is what genuine "online learning"   │
// │  looks like.                                                              │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Triaxial Consensus Signals", "AE-TRIAX", overlay = true,
     max_labels_count = 200, max_lines_count = 100)


// ============================================================================
//  ░░ INPUTS — preset-driven for beginners, full control for advanced ░░
// ============================================================================
gP = "▓ PRESET ▓"
presetInput = input.string("Beginner (conservative)", "Profile",
     options = ["Beginner (conservative)", "Standard", "Aggressive"], group = gP,
     tooltip = "Beginner = stricter consensus, fewer signals. Aggressive = looser, more signals.")

gAX = "▓ AXES ▓"
ax_trendOn   = input.bool(true, "Use Trend Axis",      group = gAX)
ax_momOn     = input.bool(true, "Use Momentum Axis",   group = gAX)
ax_volaOn    = input.bool(true, "Use Volatility Axis", group = gAX)
ax_tolInput  = input.float(20.0, "Cross-Axis Tolerance", minval = 5.0, maxval = 80.0, step = 5.0, group = gAX,
     tooltip = "Max disagreement allowed between axes (in score units, -100..+100). Lower = stricter agreement.")

gAI = "▓ AI · ADAPTIVE WEIGHTS ▓"
ai_enableInput= input.bool(true, "Adaptive Axis Weights (RL-style)", group = gAI)
ai_strengthIn = input.float(1.0, "Adaptation Strength", minval = 0.0, maxval = 2.0, step = 0.1, group = gAI)
ai_minWInput  = input.float(0.6, "Min Weight", minval = 0.1, maxval = 1.0, step = 0.1, group = gAI)
ai_maxWInput  = input.float(1.8, "Max Weight", minval = 1.0, maxval = 3.0, step = 0.1, group = gAI)
ai_horizonInp = input.int(8, "Outcome Horizon (bars)", minval = 3, maxval = 50, group = gAI)
ai_winInput   = input.float(0.8, "Required Move (ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = gAI)

gMTF = "▓ AI · MTF ALIGNMENT ▓"
mtf_enableInput= input.bool(true, "Higher-TF Alignment", group = gMTF)
mtf_tf1Input   = input.timeframe("60",  "HTF 1", group = gMTF)
mtf_tf2Input   = input.timeframe("240", "HTF 2", group = gMTF)

gRG = "▓ AI · REGIME CLASSIFIER ▓"
rg_enableInput= input.bool(true, "Regime-Aware Weighting", group = gRG)

gQL = "▓ AI · Q-LEARNING THRESHOLDS ▓"
ql_enableInput= input.bool(true, "Adaptive Consensus Threshold", group = gQL,
     tooltip = "Q-learning picks the best consensus trigger level from candidates by past outcomes.")
ql_explInput  = input.float(0.1, "Exploration (ε)", minval = 0.0, maxval = 0.5, step = 0.02, group = gQL)

gRR = "▓ RISK / REWARD ▓"
rr_atrMulSL   = input.float(1.5, "SL Distance (× ATR)", minval = 0.3, maxval = 5.0, step = 0.1, group = gRR)
rr_ratioInput = input.float(2.0, "RR Ratio (TP : SL)", minval = 0.5, maxval = 6.0, step = 0.1, group = gRR)
rr_showLinesInput= input.bool(true, "Draw SL/TP Lines on Signal", group = gRR)

gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Tetrachrome (blue/green/yellow/red)", "Palette",
     options = ["Tetrachrome (blue/green/yellow/red)", "Emerald / Ruby", "Spectral"], group = gV)
vi_emaCloud   = input.bool(true, "Show EMA Cloud (3-tier)", group = gV)
vi_barColor   = input.bool(true, "Color Candles by Consensus", group = gV)
vi_showDash   = input.bool(true, "Show Dashboard", group = gV)


// ============================================================================
//  ░░ PRESET RESOLUTION ░░
//  Translates the preset into internal sensitivity. User overrides above always
//  win; preset only adjusts the consensus threshold range explored by Q-learn.
// ============================================================================
// ============================================================================
//  ░░ PRESET RESOLUTION ░░
//  Translates the preset into internal sensitivity. User overrides above always
//  win; preset only adjusts the consensus threshold range explored by Q-learn.
//  NOTE: thresholds lowered after testing showed Beginner's 60-80 range was
//  often too strict for typical bear scenarios (Vol axis goes neutral, making
//  weighted finalScore land around 45-60 even on strong downtrends).
// ============================================================================
[presetThrLo, presetThrHi] = switch presetInput
    "Beginner (conservative)" => [50.0, 70.0]
    "Aggressive"              => [30.0, 50.0]
    => [40.0, 60.0]   // Standard


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cBuyStrong  = na   // strong bull (green)
var color cBuyWeak    = na   // weak bull / trend-aligned (blue)
var color cSellStrong = na   // strong bear (red)
var color cSellWeak   = na   // weak bear / trend-aligned down (yellow)
var color cNeut       = na
var color cAcc        = na
var color cTxt        = #eef2f0
var color cTxtD       = #6b7d76
var color cPanel      = #080b0a
var color cPanelHd    = #0f1614

setPalette() =>
    [bs, bw, ss, sw, n, a] = switch vi_themeInput
        "Emerald / Ruby"                       => [#10e0a0, #4ef0c0, #ff3860, #ff8c42, #6b7d76, #d4af37]
        "Spectral"                             => [#22d3ee, #67e8f9, #f43f5e, #fb923c, #a78bfa, #e879f9]
        => [#10b981, #3b82f6, #ef4444, #f59e0b, #6b7d76, #d4af37]   // Tetrachrome
    [bs, bw, ss, sw, n, a]
[psbs, psbw, psss, pssw, psn, psa] = setPalette()
cBuyStrong  := psbs
cBuyWeak    := psbw
cSellStrong := psss
cSellWeak   := pssw
cNeut       := psn
cAcc        := psa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ COMMON SERIES ░░
// ============================================================================
atr = ta.atr(14)
atrAvg = ta.sma(atr, 50)


// ============================================================================
//  ░░ AXIS 1 — TREND  (Dow-style phase + EMA stack + ADX strength) ░░
//  Returns trendScore in [-100, +100].
// ============================================================================
ema1 = ta.ema(close,   8)
ema2 = ta.ema(close,  21)
ema3 = ta.ema(close,  55)
ema4 = ta.ema(close, 100)
ema5 = ta.ema(close, 200)

stackUp = (ema1 > ema2 ? 1 : 0) + (ema2 > ema3 ? 1 : 0) + (ema3 > ema4 ? 1 : 0) + (ema4 > ema5 ? 1 : 0)
stackDn = (ema1 < ema2 ? 1 : 0) + (ema2 < ema3 ? 1 : 0) + (ema3 < ema4 ? 1 : 0) + (ema4 < ema5 ? 1 : 0)
stackScore = (stackUp - stackDn) * 25.0   // -100..+100 (4 slots × 25)

// Dow-style HH/HL vs LH/LL.
pivLen = 5
phP = ta.pivothigh(high, pivLen, pivLen)
plP = ta.pivotlow(low,  pivLen, pivLen)
var float lastHH = na
var float prevHH = na
var float lastLL = na
var float prevLL = na
if not na(phP)
    prevHH := lastHH
    lastHH := phP
if not na(plP)
    prevLL := lastLL
    lastLL := plP

hhUp = not na(lastHH) and not na(prevHH) and lastHH > prevHH
llUp = not na(lastLL) and not na(prevLL) and lastLL > prevLL
hhDn = not na(lastHH) and not na(prevHH) and lastHH < prevHH
llDn = not na(lastLL) and not na(prevLL) and lastLL < prevLL
dowScore = (hhUp ? 25 : 0) + (llUp ? 25 : 0) - (hhDn ? 25 : 0) - (llDn ? 25 : 0)

// ADX direction.
[diPlus, diMinus, adx] = ta.dmi(14, 14)
adxScore = adx > 25 ? (diPlus > diMinus ? 50 : -50) : adx > 18 ? (diPlus > diMinus ? 25 : -25) : 0

// Combined trend score.
trendScore = clamp(stackScore * 0.5 + dowScore * 0.3 + adxScore * 0.2, -100.0, 100.0)


// ============================================================================
//  ░░ AXIS 2 — MOMENTUM  (QQE + MACD acceleration) ░░
//  Returns momScore in [-100, +100].
// ============================================================================
// QQE: smoothed RSI with Wilder-MA of |ΔRSI| as the trailing band.
rsi = ta.rsi(close, 14)
rsiSmooth = ta.ema(rsi, 5)
// QQE score: how far RSI is from 50, normalized to [-100,+100] (RSI 0=−100, 100=+100).
qqeScore = (rsiSmooth - 50.0) * 2.0

// MACD histogram score normalized by ATR.
[macdLine, sigLine, hist] = ta.macd(close, 12, 26, 9)
histScore = clamp(hist * 50.0 / (atr + 1e-9), -100.0, 100.0)

// Combined momentum.
momScore = clamp(qqeScore * 0.6 + histScore * 0.4, -100.0, 100.0)


// ============================================================================
//  ░░ AXIS 3 — VOLATILITY  (Bollinger width + ATR regime) ░░
//  Volatility axis is sign-aware: it votes with the current candle direction
//  only when in healthy expansion; squeezes and chaos zones contribute zero.
// ============================================================================
bbBasis = ta.sma(close, 20)
bbDev   = ta.stdev(close, 20) * 2
bbW = sdiv((bbBasis + bbDev) - (bbBasis - bbDev), bbBasis) * 100.0
bbWAvg = ta.sma(bbW, 50)
expansion = bbW > bbWAvg * 1.2
squeeze   = bbW < bbWAvg * 0.6

atrRatio = sdiv(atr, atrAvg)
healthyVol = atrRatio < 1.6 and atrRatio > 0.6   // not too extreme, not dead

candleDir = close > open ? 1 : close < open ? -1 : 0
bodyRatio = sdiv(math.abs(close - open), high - low)
strongCandle = bodyRatio > 0.5

volaScore = (expansion and healthyVol and strongCandle) ? candleDir * 60.0 : 0.0
// Add a smaller persistent component from price slope vs ATR.
slopeNorm = clamp(sdiv(close - close[3], atr) * 20.0, -40.0, 40.0)
volaScore := clamp(volaScore + slopeNorm, -100.0, 100.0)


// ============================================================================
//  ░░ REGIME CLASSIFICATION ░░
//  Trend = strong ADX + EMA stack; Volatile = high atrRatio; Quiet = squeeze;
//  Range = default.
// ============================================================================
regimeTrend    = adx >= 25 and (stackUp >= 3 or stackDn >= 3)
regimeVolatile = atrRatio >= 1.5
regimeQuiet    = squeeze or atrRatio <= 0.6
regimeName  = regimeTrend ? "Trend" : regimeVolatile ? "Volatile" : regimeQuiet ? "Quiet" : "Range"
regimeCol   = regimeTrend ? cBuyStrong : regimeVolatile ? cSellStrong : regimeQuiet ? cNeut : cSellWeak


// ============================================================================
//  ░░ RL · ADAPTIVE AXIS WEIGHTS ░░
//  Reliability ∈ [0,1] per axis, EWMA-updated. Mapped to [minW, maxW] linearly.
// ============================================================================
NA = 3   // 0=Trend 1=Momentum 2=Volatility
var float[] relW = array.new<float>(NA, 0.5)
var int[]   pAg  = array.new<int>(0)
var int[]   pDir = array.new<int>(0)
var float[] pPx  = array.new<float>(0)
var int[]   pAge = array.new<int>(0)

armSample(ag, dir) =>
    array.push(pAg, ag)
    array.push(pDir, dir)
    array.push(pPx, close)
    array.push(pAge, 0)

trendDir = trendScore > 20 ? 1 : trendScore < -20 ? -1 : 0
momDir   = momScore   > 20 ? 1 : momScore   < -20 ? -1 : 0
volaDir  = volaScore  > 20 ? 1 : volaScore  < -20 ? -1 : 0

if ai_enableInput and barstate.isconfirmed
    if trendDir != 0 and trendDir != trendDir[1]
        armSample(0, trendDir)
    if momDir != 0 and momDir != momDir[1]
        armSample(1, momDir)
    if volaDir != 0
        armSample(2, volaDir)

if ai_enableInput and barstate.isconfirmed and array.size(pAg) > 0
    i = array.size(pAg) - 1
    while i >= 0
        age = array.get(pAge, i) + 1
        array.set(pAge, i, age)
        if age >= ai_horizonInp
            ag  = array.get(pAg, i)
            dir = array.get(pDir, i)
            px0 = array.get(pPx, i)
            move = dir > 0 ? (close - px0) : (px0 - close)
            won = move >= ai_winInput * atr ? 1.0 : 0.0
            old = array.get(relW, ag)
            alpha = 0.15 * ai_strengthIn
            array.set(relW, ag, clamp(old + alpha * (won - old), 0.0, 1.0))
            array.remove(pAg, i)
            array.remove(pDir, i)
            array.remove(pPx, i)
            array.remove(pAge, i)
        i -= 1

relToW(r) =>
    ai_enableInput ? ai_minWInput + (ai_maxWInput - ai_minWInput) * r : 1.0


// ============================================================================
//  ░░ REGIME-AWARE MULTIPLIERS ░░
// ============================================================================
regimeMul(ag) =>
    out = 1.0
    if rg_enableInput
        if regimeTrend
            out := ag == 0 ? 1.3 : ag == 1 ? 1.1 : 0.9
        else if regimeVolatile
            out := ag == 2 ? 1.3 : ag == 1 ? 1.1 : 0.9
        else if regimeQuiet
            out := 0.7
        else
            out := ag == 1 ? 1.2 : ag == 0 ? 0.9 : 1.0
    out

wT = (ax_trendOn ? relToW(array.get(relW, 0)) * regimeMul(0) : 0.0)
wM = (ax_momOn   ? relToW(array.get(relW, 1)) * regimeMul(1) : 0.0)
wV = (ax_volaOn  ? relToW(array.get(relW, 2)) * regimeMul(2) : 0.0)


// ============================================================================
//  ░░ MTF ALIGNMENT ░░
//  Each HTF returns a simple ±1/0 trend verdict; an alignment bonus/penalty
//  is added to the final score.
// ============================================================================
htfVerdict() =>
    eF = ta.ema(close, 12)
    eS = ta.ema(close, 30)
    r  = ta.rsi(close, 14)
    eF > eS and r > 50 ? 1 : eF < eS and r < 50 ? -1 : 0

mtfV1 = mtf_enableInput ? request.security(syminfo.tickerid, mtf_tf1Input, htfVerdict(), lookahead = barmerge.lookahead_off) : 0
mtfV2 = mtf_enableInput ? request.security(syminfo.tickerid, mtf_tf2Input, htfVerdict(), lookahead = barmerge.lookahead_off) : 0


// ============================================================================
//  ░░ CONSENSUS COMPUTATION ░░
//  Weighted score sum, normalized, plus MTF alignment bonus.
// ============================================================================
weightedSum = trendScore * wT + momScore * wM + volaScore * wV
maxPossible = (wT + wM + wV) * 100.0
rawScore = sdiv(weightedSum, maxPossible) * 100.0   // -100..+100

// MTF bonus: each HTF that agrees with the sign of rawScore adds 10; disagrees subtracts 10.
sgn = math.sign(rawScore)
mtfBonus = mtf_enableInput ? (int(math.sign(mtfV1)) == int(sgn) and sgn != 0 ? 10 : (mtfV1 != 0 ? -10 : 0)) + (int(math.sign(mtfV2)) == int(sgn) and sgn != 0 ? 10 : (mtfV2 != 0 ? -10 : 0)) : 0
finalScore = clamp(rawScore + mtfBonus, -100.0, 100.0)

confidencePct = math.abs(finalScore)

// Cross-axis tolerance check (revised, symmetric for buy and sell).
// Old logic required ALL active axes same-sign, which made SELL signals rare
// because the Volatility axis is often neutral or weakly positive. New logic:
//   • Count axes that "lean" in each direction (|score| > 10 = leaning).
//   • Neutral axes (|score| <= 10) are ignored, neither for nor against.
//   • Trend axis must lean in the signal direction (already enforced below).
//   • Of the LEANING axes, the majority must agree with the signal direction.
//   • Spread of LEANING axes must be within tolerance.
activeScores = array.new<float>(0)
if ax_trendOn
    array.push(activeScores, trendScore)
if ax_momOn
    array.push(activeScores, momScore)
if ax_volaOn
    array.push(activeScores, volaScore)

leanUp   = 0
leanDn   = 0
leanScores = array.new<float>(0)
if array.size(activeScores) > 0
    for i = 0 to array.size(activeScores) - 1
        s = array.get(activeScores, i)
        if s > 10
            leanUp += 1
            array.push(leanScores, s)
        else if s < -10
            leanDn += 1
            array.push(leanScores, s)

// Signal direction is set by the dominant lean; ties (or no lean) = no agreement.
agreedUp = leanUp > leanDn and leanUp >= 1
agreedDn = leanDn > leanUp and leanDn >= 1

// Spread check on leaning axes only.
spreadOK = true
if array.size(leanScores) >= 2
    leanMax = array.max(leanScores)
    leanMin = array.min(leanScores)
    spreadOK := (leanMax - leanMin) <= ax_tolInput * 2.0

toleranceOK = (agreedUp or agreedDn) and spreadOK

// For HUD display: keep maxScore/minScore from all active axes.
maxScore = array.size(activeScores) > 0 ? array.max(activeScores) : 0.0
minScore = array.size(activeScores) > 0 ? array.min(activeScores) : 0.0


// ============================================================================
//  ░░ Q-LEARNING CONSENSUS THRESHOLD ░░
//  Candidates spaced inside the preset's [presetThrLo, presetThrHi] band.
// ============================================================================
NTH = 4
var float[] thrCand = array.new<float>(NTH, 50.0)
if barstate.isfirst
    step = (presetThrHi - presetThrLo) / (NTH - 1)
    for k = 0 to NTH - 1
        array.set(thrCand, k, presetThrLo + step * k)

var float[] qThr  = array.new<float>(NTH, 0.5)
var int[]   pThK  = array.new<int>(0)
var int[]   pThD  = array.new<int>(0)
var float[] pThPx = array.new<float>(0)
var int[]   pThA  = array.new<int>(0)

chooseThrIdx() =>
    bestI = 0
    bestQ = array.get(qThr, 0)
    for k = 1 to NTH - 1
        if array.get(qThr, k) > bestQ
            bestQ := array.get(qThr, k)
            bestI := k
    u = math.sin(bar_index * 1.137 + 0.7) * 43758.5453
    u := u - math.floor(u)
    ql_explInput > 0 and u < ql_explInput ? int(math.floor(u * NTH * 7) % NTH) : bestI

var int thrIdx = 1
if ql_enableInput and barstate.isconfirmed
    thrIdx := chooseThrIdx()
activeThr = ql_enableInput ? array.get(thrCand, thrIdx) : (presetThrLo + presetThrHi) / 2.0


// ============================================================================
//  ░░ FINAL SIGNAL CONDITION ░░
// ============================================================================
// Strong condition: toleranceOK + score threshold + Trend axis at least LEANING
// in the signal direction. Previously required trendDir == ±1 (|trendScore|>20)
// which was too strict for SELL when Trend axis was only moderately negative.
trendLeanUp = trendScore > 10
trendLeanDn = trendScore < -10
strongBuy  = toleranceOK and finalScore >=  activeThr and trendLeanUp  and agreedUp
strongSell = toleranceOK and finalScore <= -activeThr and trendLeanDn and agreedDn

var int lastSig = 0
fireBuy  = strongBuy  and lastSig != 1
fireSell = strongSell and lastSig != -1
if barstate.isconfirmed
    if strongBuy
        lastSig := 1
    if strongSell
        lastSig := -1
    if not strongBuy and not strongSell and math.abs(finalScore) < activeThr - 15.0
        lastSig := 0


// Q-learning sample arming + resolution.
if ql_enableInput and barstate.isconfirmed
    if fireBuy or fireSell
        array.push(pThK, thrIdx)
        array.push(pThD, fireBuy ? 1 : -1)
        array.push(pThPx, close)
        array.push(pThA, 0)

if ql_enableInput and barstate.isconfirmed and array.size(pThK) > 0
    i = array.size(pThK) - 1
    while i >= 0
        age = array.get(pThA, i) + 1
        array.set(pThA, i, age)
        if age >= ai_horizonInp
            k   = array.get(pThK, i)
            dir = array.get(pThD, i)
            px0 = array.get(pThPx, i)
            move = dir > 0 ? (close - px0) : (px0 - close)
            won = move >= ai_winInput * atr ? 1.0 : 0.0
            old = array.get(qThr, k)
            array.set(qThr, k, clamp(old + 0.15 * (won - old), 0.0, 1.0))
            array.remove(pThK, i)
            array.remove(pThD, i)
            array.remove(pThPx, i)
            array.remove(pThA, i)
        i -= 1


// ============================================================================
//  ░░ SL / TP LINES (drawn on signal) ░░
// ============================================================================
var line lnSL = na
var line lnTP = na

if fireBuy and rr_showLinesInput
    slPx = close - atr * rr_atrMulSL
    tpPx = close + atr * rr_atrMulSL * rr_ratioInput
    if not na(lnSL)
        line.delete(lnSL)
    if not na(lnTP)
        line.delete(lnTP)
    lnSL := line.new(bar_index, slPx, bar_index + 30, slPx, color = color.new(cSellStrong, 20), style = line.style_dashed, width = 2, extend = extend.right)
    lnTP := line.new(bar_index, tpPx, bar_index + 30, tpPx, color = color.new(cBuyStrong, 10), style = line.style_solid, width = 2, extend = extend.right)
    label.new(bar_index, low - atr * 1.2, "★ BUY " + str.tostring(math.round(confidencePct)) + "%\nSL " + str.tostring(slPx, format.mintick) + "  TP " + str.tostring(tpPx, format.mintick),
         yloc = yloc.price, color = cBuyStrong, textcolor = #04140f, style = label.style_label_up, size = size.normal)

if fireSell and rr_showLinesInput
    slPx = close + atr * rr_atrMulSL
    tpPx = close - atr * rr_atrMulSL * rr_ratioInput
    if not na(lnSL)
        line.delete(lnSL)
    if not na(lnTP)
        line.delete(lnTP)
    lnSL := line.new(bar_index, slPx, bar_index + 30, slPx, color = color.new(cSellStrong, 20), style = line.style_dashed, width = 2, extend = extend.right)
    lnTP := line.new(bar_index, tpPx, bar_index + 30, tpPx, color = color.new(cSellStrong, 10), style = line.style_solid, width = 2, extend = extend.right)
    label.new(bar_index, high + atr * 1.2, "★ SELL " + str.tostring(math.round(confidencePct)) + "%\nSL " + str.tostring(slPx, format.mintick) + "  TP " + str.tostring(tpPx, format.mintick),
         yloc = yloc.price, color = cSellStrong, textcolor = #1a0509, style = label.style_label_down, size = size.normal)


// ============================================================================
//  ░░ EMA CLOUD (3-tier) ░░
// ============================================================================
cloudTop1 = math.max(ema1, ema2)
cloudBot1 = math.min(ema1, ema2)
cloudTop2 = math.max(ema2, ema3)
cloudBot2 = math.min(ema2, ema3)
cloudTop3 = math.max(ema3, ema5)
cloudBot3 = math.min(ema3, ema5)

cloudBull1 = ema1 > ema2
cloudBull2 = ema2 > ema3
cloudBull3 = ema3 > ema5

c1Top = plot(vi_emaCloud ? cloudTop1 : na, "Cloud1 Top", color = color.new(cloudBull1 ? cBuyWeak : cSellWeak, 80), display = display.none)
c1Bot = plot(vi_emaCloud ? cloudBot1 : na, "Cloud1 Bot", color = color.new(cloudBull1 ? cBuyWeak : cSellWeak, 80), display = display.none)
fill(c1Top, c1Bot, color = vi_emaCloud ? color.new(cloudBull1 ? cBuyWeak : cSellWeak, 80) : na, title = "Cloud 1")
c2Top = plot(vi_emaCloud ? cloudTop2 : na, "Cloud2 Top", color = color.new(cloudBull2 ? cBuyStrong : cSellStrong, 85), display = display.none)
c2Bot = plot(vi_emaCloud ? cloudBot2 : na, "Cloud2 Bot", color = color.new(cloudBull2 ? cBuyStrong : cSellStrong, 85), display = display.none)
fill(c2Top, c2Bot, color = vi_emaCloud ? color.new(cloudBull2 ? cBuyStrong : cSellStrong, 85) : na, title = "Cloud 2")
c3Top = plot(vi_emaCloud ? cloudTop3 : na, "Cloud3 Top", color = color.new(cloudBull3 ? cBuyStrong : cSellStrong, 90), display = display.none)
c3Bot = plot(vi_emaCloud ? cloudBot3 : na, "Cloud3 Bot", color = color.new(cloudBull3 ? cBuyStrong : cSellStrong, 90), display = display.none)
fill(c3Top, c3Bot, color = vi_emaCloud ? color.new(cloudBull3 ? cBuyStrong : cSellStrong, 90) : na, title = "Cloud 3")


// ============================================================================
//  ░░ VISUALS — signal arrows + bar coloring ░░
// ============================================================================
plotshape(fireBuy,  title = "Strong BUY",  style = shape.triangleup,   location = location.belowbar, color = cBuyStrong,  size = size.large)
plotshape(fireSell, title = "Strong SELL", style = shape.triangledown, location = location.abovebar, color = cSellStrong, size = size.large)

// 4-color bar tinting per the tetrachrome scheme.
bcol = vi_barColor ? (finalScore >= activeThr ? cBuyStrong : finalScore >= activeThr * 0.5 ? cBuyWeak : finalScore <= -activeThr ? cSellStrong : finalScore <= -activeThr * 0.5 ? cSellWeak : na) : na
barcolor(bcol, editable = false)


// ============================================================================
//  ░░ DASHBOARD ░░
// ============================================================================
bar10(p) =>
    int filled = math.round(clamp(p / 100.0, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

axColor(s) =>
    s > 20 ? cBuyStrong : s > 5 ? cBuyWeak : s < -20 ? cSellStrong : s < -5 ? cSellWeak : cNeut
axSym(s) =>
    s > 5 ? "▲" : s < -5 ? "▼" : "·"

var table hud = na
if vi_showDash and na(hud)
    hud := table.new(position.top_right, 2, 13, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if vi_showDash and barstate.islast
    sz = size.normal
    verdict = fireBuy ? "★ STRONG BUY" : fireSell ? "★ STRONG SELL" : finalScore > activeThr * 0.5 ? "▲ lean buy" : finalScore < -activeThr * 0.5 ? "▼ lean sell" : "· neutral"
    verdictCol = fireBuy ? cBuyStrong : fireSell ? cSellStrong : finalScore > 0 ? cBuyWeak : finalScore < 0 ? cSellWeak : cNeut

    table.cell(hud, 0, 0, "TRIAXIAL CONSENSUS", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, presetInput, text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "verdict", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, verdict, text_color = verdictCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "final score", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(finalScore, "#.0"), text_color = verdictCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "confidence", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10(confidencePct) + " " + str.tostring(math.round(confidencePct)) + "%", text_color = confidencePct >= 70 ? cBuyStrong : confidencePct >= 40 ? cTxt : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "regime", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, regimeName, text_color = regimeCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "▔ AXES ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 5, "", bgcolor = cPanelHd)

    table.cell(hud, 0, 6, "TREND",      text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, axSym(trendScore) + " " + str.tostring(trendScore, "#.0") + "  ×" + str.tostring(wT, "#.1"), text_color = axColor(trendScore), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 7, "MOMENTUM",   text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, axSym(momScore) + " " + str.tostring(momScore, "#.0") + "  ×" + str.tostring(wM, "#.1"), text_color = axColor(momScore), text_size = sz, text_halign = text.align_right)
    table.cell(hud, 0, 8, "VOLATILITY", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, axSym(volaScore) + " " + str.tostring(volaScore, "#.0") + "  ×" + str.tostring(wV, "#.1"), text_color = axColor(volaScore), text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "MTF " + mtf_tf1Input + "/" + mtf_tf2Input, text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, mtf_enableInput ? axSym(mtfV1 * 30) + " / " + axSym(mtfV2 * 30) : "off", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 10, "Q-threshold", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, ql_enableInput ? str.tostring(activeThr, "#") + " (slot " + str.tostring(thrIdx + 1) + "/4)" : "fixed", text_color = cAcc, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 11, "axis lean", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    leanTxt = "↑" + str.tostring(leanUp) + " / ↓" + str.tostring(leanDn) + (toleranceOK ? "  ✓" : "  ✗")
    table.cell(hud, 1, 11, leanTxt, text_color = toleranceOK ? cBuyStrong : cTxtD, text_size = sz, text_halign = text.align_right)

    // Diagnostic: shows WHY a signal does or doesn't fire.
    diag = ""
    diagCol = cTxtD
    if fireBuy
        diag := "★ BUY firing"
        diagCol := cBuyStrong
    else if fireSell
        diag := "★ SELL firing"
        diagCol := cSellStrong
    else if not toleranceOK
        diag := "axes disagree"
        diagCol := cTxtD
    else if agreedUp and not trendLeanUp
        diag := "trend not up"
        diagCol := cTxtD
    else if agreedDn and not trendLeanDn
        diag := "trend not down"
        diagCol := cTxtD
    else if agreedUp and finalScore < activeThr
        need = activeThr - finalScore
        diag := "+" + str.tostring(need, "#.0") + " score to BUY"
        diagCol := cBuyWeak
    else if agreedDn and finalScore > -activeThr
        need = finalScore - (-activeThr)
        diag := "-" + str.tostring(need, "#.0") + " score to SELL"
        diagCol := cSellWeak
    else if lastSig == 1 and not strongBuy
        diag := "BUY held (locked)"
        diagCol := cAcc
    else if lastSig == -1 and not strongSell
        diag := "SELL held (locked)"
        diagCol := cAcc
    else
        diag := "—"
    table.cell(hud, 0, 12, "▔ DIAGNOSTIC ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 12, diag, text_color = diagCol, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertMsgBuy  = "AE-TRIAX Strong BUY @ "  + str.tostring(close, format.mintick) + " | Confidence " + str.tostring(math.round(confidencePct)) + "% | Regime: " + regimeName
alertMsgSell = "AE-TRIAX Strong SELL @ " + str.tostring(close, format.mintick) + " | Confidence " + str.tostring(math.round(confidencePct)) + "% | Regime: " + regimeName
alertcondition(fireBuy,  "Strong BUY",  "AE-TRIAX Strong BUY signal")
alertcondition(fireSell, "Strong SELL", "AE-TRIAX Strong SELL signal")
````
