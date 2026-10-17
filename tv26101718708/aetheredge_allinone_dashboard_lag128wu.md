# AetherEdge - All-in-One Dashboard

- url: https://www.tradingview.com/script/laG128wU/
- type: indicator
- pine_id: PUB;3047bdf2788a4ce5a92216eca8a8c933
- version: 1.0

## Description

🖊️ Overview
AetherEdge All-in-One Dashboard is the ultimate professional command center that unifies four core analytical pillars—Trend, Momentum, Volatility, and Volume—with a sophisticated Signal Probability Engine. Each module independently computes scores, then weighted aggregation combined with an "Alignment Score" and pseudo live Win-Rate tracking delivers final verdicts—revealing multi-dimensional market truths that no single indicator can capture. A 25-row professional dashboard plus AI-powered VERDICT instantly supports every trading decision.

🔶 Key Features

4-Module Integrated Analysis: Trend / Momentum / Volatility / Volume
Signal Probability Engine: Quantifies Bull/Bear probability in %
Alignment Score: Auto-adjusts confidence via inter-module dispersion
Weighted Scoring System: Fully customizable module weights
Pseudo Live Win-Rate Tracking: Auto-tallies 5-bar prediction accuracy
AI VERDICT: 4-tier recommendations (HIGH-CONVICTION / Consider / Await / No Edge)
Squeeze Detection & Background Highlight: BBW percentile pre-explosion alerts
Volatility Regime Classification: 5 tiers (EXTREME HIGH → SQUEEZE)
Money Flow Analysis: OBV + CMF + MFI composite scoring
Multi-Indicator Coverage: EMA/MACD/RSI/Stoch/ADX/ATR/BB all unified
5-Tier Signal Strength: ULTRA / STRONG / MODERATE / WEAK / NONE
3 Sizes × 6 Positions: Fully flexible dashboard layout
7 Alert Types: Signal / Squeeze / Volume / Trend cross coverage

🧠 Technical Architecture

This indicator is a high-end decision-support system built on a multi-axis score integration engine with alignment-based confidence correction.

Trend Module:
EMA Stack (21/50/200) alignment score (±100)
Price vs EMAs positional score
ADX × DMI directional score
Weighted blend (EMA 0.4 / Price 0.3 / ADX 0.3)
Momentum Module:
RSI normalized (-100 to +100)
MACD histogram % scaling
Stochastic %K/%D cross detection
Weighted blend (RSI 0.35 / MACD 0.4 / Stoch 0.25)
Volatility Module:
ATR% percentile rank within volRegLen window
BB Width Percentile for Squeeze detection
Squeeze grants +30 bonus score (expansion imminent)
Volume Module:
OBV vs EMA slope analysis
CMF (Chaikin Money Flow) ×200 scaled
MFI normalized score
Weighted blend (OBV 0.35 / CMF 0.3 / MFI 0.35)
Signal Probability Engine:
Weighted composite = Σ(module × weight) / total weight
Bull Prob = 50 + composite × 0.5
Alignment Score = 100 - σ(modules)
Final Prob = (max × Alignment/100 × 0.7) + (max × 0.3)
Win-Rate Tracking: Pending array logs signal → 5-bar outcome auto-aggregation, displaying cumulative Win-Rate and trade count
AI VERDICT: Integrates probability, direction, and Squeeze state to generate 4-tier action recommendations

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (1H–4H): Standard defaults (EMA 21/50/200, sigMinProb=70)
ETH (15M–1H): emaFast=13, sigMinProb=72 for precision
SOL (high-vol): volRegLen=150, wVol=1.0 for explosion detection
XRP (range): wMom=1.5, wTrend=1.0 for momentum focus
Weight Strategies:

Trend Follower: wTrend=2.0, wMom=1.0
Reversal Trader: wMom=1.5, wVol=1.2 (leverage Squeeze bonus)
Volume-Centric: wVolume=1.5, wTrend=1.0
Balanced: Default (wTrend=1.5, wMom=1.2, wVol=0.8, wVolume=1.0)
Signal Quality:

Ultra-Selective: sigMinProb=80, ULTRA/STRONG only (max Win-Rate)
Standard: sigMinProb=70 (recommended)
Frequency-Focused: sigMinProb=60, MODERATE+
Dashboard Sizes:

Compact: Multi-chart layouts
Normal: Standard use
Large: Deep analysis / streaming (recommended)

💡 How to Use in Practice

VERDICT = HIGH-CONVICTION: Strongest signal, consider full position
Squeeze ACTIVE: Confirm direction, then enter on breakout (Await Breakout displayed)
Alignment > 70%: High confidence, technicals unified—win-rate boost
Alignment < 40%: Caution, market chaos—stand aside
Win-Rate > 60% + Bull Prob > 75%: System on hot streak, trade aggressively
Volume INFLOW + Trend STRONG BULL: Maximum continuation confidence
ATR EXTREME HIGH: Reduce position size, tighten risk management
MACD Bull Cross + RSI 30–60 + ADX > 25: Ideal long setup
AetherEdge Synergy:
Liquidity Sweep Detector Bullish Sweep + AIO HIGH-CONVICTION LONG = institutional sync
Self-Evolving S/R Grid strong support + ULTRA Long = perfect dip-buy
WaveTrend Enhanced Bull Cross + all modules aligned = textbook bottom
Multi-TF Strategy: 4H for trend → 1H for signal wait → 15M for precision entry

⚠️ Important Notes

Win-Rate Metric: Cumulative since chart load; treat <20 samples as preliminary
Low Alignment: Auto-discounts signal confidence
Squeeze Bonus: Volatility precursor, not directional—confirm separately
Weak ADX (< 25): Trend score reliability degraded
Avoid Over-Optimization: Tune 2-3 params at a time
Signal Trigger: Requires both Composite=0 cross AND probability threshold

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Signal probabilities, win-rates, and VERDICTs are statistical estimates based on historical data and do not guarantee future profits. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - All-in-One Dashboard", "AE-AIO",
     overlay=true,
     max_lines_count=100,
     max_labels_count=100,
     max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpT = "① Trend Module"
useTrend    = input.bool(true, "Enable Trend Analysis", group=grpT)
emaFast     = input.int(21,  "EMA Fast",   minval=1, group=grpT)
emaMid      = input.int(50,  "EMA Mid",    minval=1, group=grpT)
emaSlow     = input.int(200, "EMA Slow",   minval=1, group=grpT)
adxLen      = input.int(14,  "ADX Length", minval=1, group=grpT)
adxStrong   = input.int(25,  "ADX Strong Threshold", minval=1, group=grpT)

grpM = "② Momentum Module"
useMom      = input.bool(true, "Enable Momentum Analysis", group=grpM)
rsiLen      = input.int(14, "RSI Length", minval=1, group=grpM)
macdFast    = input.int(12, "MACD Fast",  minval=1, group=grpM)
macdSlow    = input.int(26, "MACD Slow",  minval=1, group=grpM)
macdSig     = input.int(9,  "MACD Signal",minval=1, group=grpM)
stochLen    = input.int(14, "Stoch Length", minval=1, group=grpM)
stochSmooth = input.int(3,  "Stoch Smooth", minval=1, group=grpM)

grpV = "③ Volatility Module"
useVol      = input.bool(true, "Enable Volatility Analysis", group=grpV)
atrLen      = input.int(14, "ATR Length", minval=1, group=grpV)
bbLen       = input.int(20, "BB Length", minval=1, group=grpV)
bbMult      = input.float(2.0, "BB Multiplier", minval=0.1, step=0.1, group=grpV)
volRegLen   = input.int(100, "Volatility Regime Lookback", minval=20, group=grpV)

grpU = "④ Volume Module"
useVolume   = input.bool(true, "Enable Volume Analysis", group=grpU)
volMaLen    = input.int(20, "Volume MA Length", minval=1, group=grpU)
cmfLen      = input.int(20, "CMF Length", minval=1, group=grpU)
mfiLen      = input.int(14, "MFI Length", minval=1, group=grpU)

grpS = "⑤ Signal Probability Engine"
useSignal   = input.bool(true, "Enable Signal Engine", group=grpS)
wTrend      = input.float(1.5, "Trend Weight",     minval=0, step=0.1, group=grpS)
wMom        = input.float(1.2, "Momentum Weight",  minval=0, step=0.1, group=grpS)
wVol        = input.float(0.8, "Volatility Weight",minval=0, step=0.1, group=grpS)
wVolume     = input.float(1.0, "Volume Weight",    minval=0, step=0.1, group=grpS)
sigMinProb  = input.float(70, "Min Signal Probability (%)", minval=50, maxval=95, group=grpS)

grpD = "🎨 Display"
darkMode    = input.bool(true, "Dark Mode", group=grpD)
dashSize    = input.string("Large", "Dashboard Size",
               options=["Compact","Normal","Large"], group=grpD)
dashPos     = input.string("Top Right", "Dashboard Position",
               options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)
showSignals = input.bool(true, "Plot Signal Arrows", group=grpD)
showEMAs    = input.bool(true, "Plot EMAs", group=grpD)
showBB      = input.bool(false, "Plot Bollinger Bands", group=grpD)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg      = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt   = darkMode ? color.new(#111a2e, 10) : color.new(#ffffff, 0)
cBgRow   = darkMode ? color.new(#0d1424, 15) : color.new(#fafbfc, 0)
cBorder  = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText    = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute    = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent  = color.new(#00d4ff, 0)
cBull    = color.new(#00d4a0, 0)
cBear    = color.new(#ff5577, 0)
cNeutral = color.new(#ffa500, 0)
cPurple  = color.new(#c084fc, 0)

txtSize = dashSize == "Compact" ? size.tiny : dashSize == "Normal" ? size.small : size.normal
hdrSize = dashSize == "Compact" ? size.small : dashSize == "Normal" ? size.normal : size.large

// ═══════════════════════════════════════════════════════════════
//  ① TREND MODULE
// ═══════════════════════════════════════════════════════════════
eFast = ta.ema(close, emaFast)
eMid  = ta.ema(close, emaMid)
eSlow = ta.ema(close, emaSlow)

// EMA alignment score: +100 (perfect bull) to -100 (perfect bear)
emaBull = eFast > eMid and eMid > eSlow
emaBear = eFast < eMid and eMid < eSlow
emaScore = emaBull ? 100 : emaBear ? -100 : (eFast > eMid ? 33 : eFast < eMid ? -33 : 0) + (eMid > eSlow ? 33 : eMid < eSlow ? -33 : 0)

// Price vs EMAs
priceAboveAll = close > eFast and close > eMid and close > eSlow
priceBelowAll = close < eFast and close < eMid and close < eSlow
priceScore = priceAboveAll ? 100 : priceBelowAll ? -100 : close > eMid ? 50 : close < eMid ? -50 : 0

// ADX
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxStrong_ = adx > adxStrong
adxDir = diPlus > diMinus ? 1 : -1
adxScore = math.min(100, adx / adxStrong * 50) * adxDir

// Combined trend score [-100, +100]
trendScore = useTrend ? (emaScore * 0.4 + priceScore * 0.3 + adxScore * 0.3) : 0
trendLabel = trendScore > 60 ? "STRONG BULL" : trendScore > 20 ? "BULL" : trendScore > -20 ? "NEUTRAL" : trendScore > -60 ? "BEAR" : "STRONG BEAR"
trendCol = trendScore > 60 ? cBull : trendScore > 20 ? color.new(cBull, 40) : trendScore > -20 ? cNeutral : trendScore > -60 ? color.new(cBear, 40) : cBear

// ═══════════════════════════════════════════════════════════════
//  ② MOMENTUM MODULE
// ═══════════════════════════════════════════════════════════════
rsi = ta.rsi(close, rsiLen)
rsiScore = (rsi - 50) * 2  // [-100, +100]

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBull = macdLine > signalLine and histLine > 0
macdBear = macdLine < signalLine and histLine < 0
// Normalize histogram as % of price for scoring
histNorm = histLine / close * 10000
macdScore = math.max(-100, math.min(100, histNorm * 20)) * (macdBull ? 1 : macdBear ? 1 : 0.5) * (macdBull ? 1 : macdBear ? -1 : histLine > 0 ? 0.5 : -0.5)

k = ta.stoch(close, high, low, stochLen)
d = ta.sma(k, stochSmooth)
stochScore = (k - 50) * 2
stochCross = ta.crossover(k, d) ? 1 : ta.crossunder(k, d) ? -1 : 0

// Combined momentum score
momScore = useMom ? (rsiScore * 0.35 + macdScore * 0.4 + stochScore * 0.25) : 0
momLabel = momScore > 60 ? "OVERBOUGHT↑" : momScore > 20 ? "BULLISH" : momScore > -20 ? "NEUTRAL" : momScore > -60 ? "BEARISH" : "OVERSOLD↓"
momCol = momScore > 60 ? cBear : momScore > 20 ? cBull : momScore > -20 ? cNeutral : momScore > -60 ? cBear : cBull

// ═══════════════════════════════════════════════════════════════
//  ③ VOLATILITY MODULE
// ═══════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)
atrPct = atr / close * 100

basis = ta.sma(close, bbLen)
dev = bbMult * ta.stdev(close, bbLen)
bbUpper = basis + dev
bbLower = basis - dev
bbWidth = (bbUpper - bbLower) / basis * 100
bbPos = (close - bbLower) / (bbUpper - bbLower) * 100

// Volatility regime: compare current ATR% to its historical range
atrHi = ta.highest(atrPct, volRegLen)
atrLo = ta.lowest(atrPct, volRegLen)
volPercentile = (atrPct - atrLo) / (atrHi - atrLo) * 100

// BB squeeze detection
bbwHi = ta.highest(bbWidth, volRegLen)
bbwLo = ta.lowest(bbWidth, volRegLen)
bbwPercentile = (bbWidth - bbwLo) / (bbwHi - bbwLo) * 100
squeezeActive = bbwPercentile < 20

volLabel = volPercentile > 80 ? "EXTREME HIGH" : volPercentile > 60 ? "HIGH" : volPercentile > 40 ? "NORMAL" : volPercentile > 20 ? "LOW" : "SQUEEZE"
volCol   = volPercentile > 80 ? cBear : volPercentile > 60 ? cNeutral : volPercentile > 40 ? cAccent : volPercentile > 20 ? cBull : cPurple

// Volatility contribution to signal: squeeze = bonus (expansion pending)
volBonus = useVol ? (squeezeActive ? 30 : volPercentile > 80 ? -20 : volPercentile > 40 ? 10 : 20) : 0

// ═══════════════════════════════════════════════════════════════
//  ④ VOLUME MODULE
// ═══════════════════════════════════════════════════════════════
volMa = ta.sma(volume, volMaLen)
volRatio = volume / volMa
volSpike = volRatio > 2.0
volDry = volRatio < 0.5

// OBV slope
obv = ta.cum(math.sign(ta.change(close)) * volume)
obvEma = ta.ema(obv, 20)
obvRising = obv > obvEma
obvScore = obvRising ? 50 : -50

// CMF
mfm = ((close - low) - (high - close)) / (high - low)
mfv = mfm * volume
cmf = ta.sma(mfv, cmfLen) / ta.sma(volume, cmfLen)
cmfScore = cmf * 200  // approx scaled

// MFI
mfi = ta.mfi(hlc3, mfiLen)
mfiScore = (mfi - 50) * 2

// Combined volume score
volumeScore = useVolume ? (obvScore * 0.35 + cmfScore * 0.3 + mfiScore * 0.35) : 0
volumeScore := math.max(-100, math.min(100, volumeScore))

volumeLabel = volSpike ? "SPIKE ↑" : volDry ? "DRY ↓" : volRatio > 1.2 ? "ABOVE AVG" : volRatio < 0.8 ? "BELOW AVG" : "NORMAL"
volumeCol = volSpike ? cAccent : volDry ? cMute : volRatio > 1.2 ? cBull : volRatio < 0.8 ? cNeutral : cMute

flowLabel = volumeScore > 40 ? "INFLOW ↑↑" : volumeScore > 10 ? "Inflow ↑" : volumeScore > -10 ? "Balanced" : volumeScore > -40 ? "Outflow ↓" : "OUTFLOW ↓↓"
flowCol = volumeScore > 40 ? cBull : volumeScore > 10 ? color.new(cBull, 40) : volumeScore > -10 ? cNeutral : volumeScore > -40 ? color.new(cBear, 40) : cBear

// ═══════════════════════════════════════════════════════════════
//  ⑤ SIGNAL PROBABILITY ENGINE
// ═══════════════════════════════════════════════════════════════
totalWeight = (useTrend ? wTrend : 0) + (useMom ? wMom : 0) + (useVol ? wVol : 0) + (useVolume ? wVolume : 0)

rawComposite = ((useTrend ? trendScore * wTrend : 0) +(useMom ? momScore * wMom : 0) +(useVol ? volBonus * wVol : 0) +(useVolume ? volumeScore * wVolume : 0)) / (totalWeight > 0 ? totalWeight : 1)

// Convert composite score [-100,+100] into directional probability
bullProb = math.max(0, math.min(100, 50 + rawComposite * 0.5))
bearProb = 100 - bullProb

// Signal quality: how aligned are the modules? (dispersion check)
scores = array.from(
     useTrend  ? trendScore  : na,
     useMom    ? momScore    : na,
     useVolume ? volumeScore : na)

f_stdev(a) =>
    n = 0
    sum = 0.0
    for i = 0 to array.size(a) - 1
        v = array.get(a, i)
        if not na(v)
            sum += v
            n += 1
    mean = n > 0 ? sum / n : 0.0
    sq = 0.0
    for i = 0 to array.size(a) - 1
        v = array.get(a, i)
        if not na(v)
            sq += math.pow(v - mean, 2)
    n > 1 ? math.sqrt(sq / n) : 0.0

dispersion = f_stdev(scores)
alignment = math.max(0, 100 - dispersion)  // 100 = perfect alignment

// Final signal probability combines directional strength + alignment
signalProb = math.max(bullProb, bearProb) * (alignment / 100) * 0.7 + math.max(bullProb, bearProb) * 0.3

signalDir = rawComposite > 0 ? 1 : rawComposite < 0 ? -1 : 0
signalStrength = signalProb > 85 ? "ULTRA" : signalProb > 75 ? "STRONG" : signalProb > 65 ? "MODERATE" : signalProb > 55 ? "WEAK" : "NONE"
signalCol = signalDir > 0 ? (signalProb > 75 ? cBull : color.new(cBull, 40)) : signalDir < 0 ? (signalProb > 75 ? cBear : color.new(cBear, 40)) : cNeutral

// Signal triggers
longSignal  = signalDir > 0 and signalProb >= sigMinProb and ta.crossover(rawComposite, 0)
shortSignal = signalDir < 0 and signalProb >= sigMinProb and ta.crossunder(rawComposite, 0)

// Simple pseudo win-rate estimate (based on past 100 bars vs future 5 bars)
var int tradesCount = 0
var int winsCount = 0
var array<int>   pendingDir = array.new<int>()
var array<int>   pendingBar = array.new<int>()
var array<float> pendingPx  = array.new<float>()

if longSignal
    array.push(pendingDir, 1)
    array.push(pendingBar, bar_index)
    array.push(pendingPx, close)
if shortSignal
    array.push(pendingDir, -1)
    array.push(pendingBar, bar_index)
    array.push(pendingPx, close)

if array.size(pendingBar) > 0
    i = 0
    while i < array.size(pendingBar)
        barsElapsed = bar_index - array.get(pendingBar, i)
        if barsElapsed >= 5
            d_ = array.get(pendingDir, i)
            p_ = array.get(pendingPx, i)
            won = d_ > 0 ? close > p_ : close < p_
            tradesCount += 1
            if won
                winsCount += 1
            array.remove(pendingDir, i)
            array.remove(pendingBar, i)
            array.remove(pendingPx, i)
        else
            i += 1

winRate = tradesCount > 0 ? winsCount / tradesCount * 100 : 0.0

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
plot(showEMAs ? eFast : na, "EMA Fast", color=color.new(cAccent, 30), linewidth=1)
plot(showEMAs ? eMid  : na, "EMA Mid",  color=color.new(cPurple, 30), linewidth=1)
plot(showEMAs ? eSlow : na, "EMA Slow", color=color.new(cNeutral, 30), linewidth=2)

pU = plot(showBB ? bbUpper : na, "BB Upper", color=color.new(cMute, 60))
pL = plot(showBB ? bbLower : na, "BB Lower", color=color.new(cMute, 60))
fill(pU, pL, color=color.new(cPurple, 95))

plotshape(showSignals and longSignal  ? low  : na, "Long Signal",  shape.labelup,
     location.belowbar, color=cBull, textcolor=color.white, text="▲", size=size.small)
plotshape(showSignals and shortSignal ? high : na, "Short Signal", shape.labeldown,
     location.abovebar, color=cBear, textcolor=color.white, text="▼", size=size.small)

// Background tint for squeeze
bgcolor(squeezeActive ? color.new(cPurple, 93) : na, title="Squeeze Background")

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// Bar visualization helper: -100..+100 score into a 10-char bar
f_bar(score) =>
    s = math.max(-100, math.min(100, score))
    filled = math.round(math.abs(s) / 20)
    bar = ""
    if s >= 0
        bar := "▕▏▏▏▏▏"
        b = ""
        for i = 0 to 4
            b := b + (i < filled ? "█" : "░")
        bar := "     " + b
    else
        b = ""
        for i = 0 to 4
            idx = 4 - i
            b := b + (idx < filled ? "█" : "░")
        bar := b + "     "
    bar

f_pct(v) =>
    str.tostring(math.round(v * 10) / 10, "#.#") + "%"

var table dash = na
if barstate.islast
    dash := table.new(f_pos(dashPos), 4, 26,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    // ═══ HEADER ═══
    table.cell(dash, 0, 0, "◆ AETHEREDGE ALL-IN-ONE ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=hdrSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 3, 0)

    table.cell(dash, 0, 1, syminfo.ticker + " · " + timeframe.period,
         text_color=cText, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 3, 1)

    // ═══ SIGNAL ENGINE (TOP - MOST IMPORTANT) ═══
    table.cell(dash, 0, 2, "⚡ SIGNAL PROBABILITY ENGINE ⚡",
         text_color=color.white, bgcolor=color.new(cAccent, 40), text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 3, 2)

    sigIcon = signalDir > 0 ? "▲ LONG" : signalDir < 0 ? "▼ SHORT" : "─ WAIT"
    table.cell(dash, 0, 3, "Direction", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 3, sigIcon, text_color=color.white, bgcolor=color.new(signalCol, 20),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 3, "Strength", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 3, signalStrength, text_color=color.white, bgcolor=color.new(signalCol, 20),
         text_halign=text.align_center, text_size=txtSize)

    table.cell(dash, 0, 4, "Bull Prob", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 4, f_pct(bullProb), text_color=color.white, bgcolor=color.new(cBull, 30 + math.round(50 - bullProb * 0.3)),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 4, "Bear Prob", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 4, f_pct(bearProb), text_color=color.white, bgcolor=color.new(cBear, 30 + math.round(50 - bearProb * 0.3)),
         text_halign=text.align_center, text_size=txtSize)

    table.cell(dash, 0, 5, "Composite", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 5, str.tostring(math.round(rawComposite)), text_color=color.white,
         bgcolor=color.new(signalCol, 40), text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 5, "Alignment", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    alignCol = alignment > 70 ? cBull : alignment > 40 ? cNeutral : cBear
    table.cell(dash, 3, 5, f_pct(alignment), text_color=color.white, bgcolor=color.new(alignCol, 40),
         text_halign=text.align_center, text_size=txtSize)

    // ═══ TREND MODULE ═══
    table.cell(dash, 0, 6, "① TREND MODULE",
         text_color=cAccent, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_left)
    table.merge_cells(dash, 0, 6, 3, 6)

    table.cell(dash, 0, 7, "State", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 7, trendLabel, text_color=color.white, bgcolor=color.new(trendCol, 30),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 7, "Score", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 7, str.tostring(math.round(trendScore)), text_color=color.white,
         bgcolor=color.new(trendCol, 40), text_halign=text.align_center, text_size=txtSize)

    emaAlign = emaBull ? "▲▲▲ Bull Stack" : emaBear ? "▼▼▼ Bear Stack" : "◆ Mixed"
    table.cell(dash, 0, 8, "EMAs", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 8, emaAlign, text_color=color.white,
         bgcolor=color.new(emaBull ? cBull : emaBear ? cBear : cNeutral, 40),
         text_halign=text.align_center, text_size=txtSize)
    adxTxt = "ADX " + str.tostring(math.round(adx)) + (adxStrong_ ? (adxDir > 0 ? " ▲" : " ▼") : " ─")
    table.cell(dash, 2, 8, "ADX", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 8, adxTxt, text_color=color.white,
         bgcolor=color.new(adxStrong_ ? (adxDir > 0 ? cBull : cBear) : cNeutral, 40),
         text_halign=text.align_center, text_size=txtSize)

    // ═══ MOMENTUM MODULE ═══
    table.cell(dash, 0, 9, "② MOMENTUM MODULE",
         text_color=cAccent, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_left)
    table.merge_cells(dash, 0, 9, 3, 9)

    table.cell(dash, 0, 10, "State", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 10, momLabel, text_color=color.white, bgcolor=color.new(momCol, 30),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 10, "Score", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 10, str.tostring(math.round(momScore)), text_color=color.white,
         bgcolor=color.new(momCol, 40), text_halign=text.align_center, text_size=txtSize)

    rsiCol = rsi > 70 ? cBear : rsi < 30 ? cBull : cNeutral
    table.cell(dash, 0, 11, "RSI", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 11, str.tostring(math.round(rsi)), text_color=color.white,
         bgcolor=color.new(rsiCol, 40), text_halign=text.align_center, text_size=txtSize)
    macdTxt = macdBull ? "▲ Bull Cross" : macdBear ? "▼ Bear Cross" : "◆ Flat"
    table.cell(dash, 2, 11, "MACD", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 11, macdTxt, text_color=color.white,
         bgcolor=color.new(macdBull ? cBull : macdBear ? cBear : cNeutral, 40),
         text_halign=text.align_center, text_size=txtSize)

    stochTxt = str.tostring(math.round(k)) + "/" + str.tostring(math.round(d)) + (stochCross > 0 ? " ▲" : stochCross < 0 ? " ▼" : "")
    stochCol = k > 80 ? cBear : k < 20 ? cBull : cNeutral
    table.cell(dash, 0, 12, "Stoch", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 12, stochTxt, text_color=color.white, bgcolor=color.new(stochCol, 40),
         text_halign=text.align_center, text_size=txtSize)
    histTxt = (histLine > 0 ? "+" : "") + str.tostring(histLine, format.mintick)
    table.cell(dash, 2, 12, "Hist", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 12, histTxt, text_color=color.white,
         bgcolor=color.new(histLine > 0 ? cBull : cBear, 50),
         text_halign=text.align_center, text_size=txtSize)

    // ═══ VOLATILITY MODULE ═══
    table.cell(dash, 0, 13, "③ VOLATILITY MODULE",
         text_color=cAccent, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_left)
    table.merge_cells(dash, 0, 13, 3, 13)

    table.cell(dash, 0, 14, "Regime", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 14, volLabel, text_color=color.white, bgcolor=color.new(volCol, 30),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 14, "Percentile", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 14, f_pct(volPercentile), text_color=color.white,
         bgcolor=color.new(volCol, 40), text_halign=text.align_center, text_size=txtSize)

    table.cell(dash, 0, 15, "ATR%", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 15, f_pct(atrPct), text_color=cText, bgcolor=cBg,
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 15, "BB Pos", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    bbPosCol = bbPos > 80 ? cBear : bbPos < 20 ? cBull : cNeutral
    table.cell(dash, 3, 15, f_pct(bbPos), text_color=color.white,
         bgcolor=color.new(bbPosCol, 50), text_halign=text.align_center, text_size=txtSize)

    squeezeTxt = squeezeActive ? "◆ ACTIVE (Expansion Pending!)" : "Inactive"
    table.cell(dash, 0, 16, "Squeeze", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 16, squeezeTxt, text_color=color.white,
         bgcolor=color.new(squeezeActive ? cPurple : cMute, 40),
         text_halign=text.align_center, text_size=txtSize)
    table.merge_cells(dash, 1, 16, 3, 16)

    // ═══ VOLUME MODULE ═══
    table.cell(dash, 0, 17, "④ VOLUME MODULE",
         text_color=cAccent, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_left)
    table.merge_cells(dash, 0, 17, 3, 17)

    table.cell(dash, 0, 18, "Flow", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 18, flowLabel, text_color=color.white, bgcolor=color.new(flowCol, 30),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 18, "Score", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 18, str.tostring(math.round(volumeScore)), text_color=color.white,
         bgcolor=color.new(flowCol, 40), text_halign=text.align_center, text_size=txtSize)

    table.cell(dash, 0, 19, "Volume", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 19, volumeLabel + " (" + str.tostring(volRatio, "#.##") + "x)",
         text_color=color.white, bgcolor=color.new(volumeCol, 40),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 19, "MFI", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=txtSize)
    mfiCol = mfi > 80 ? cBear : mfi < 20 ? cBull : cNeutral
    table.cell(dash, 3, 19, str.tostring(math.round(mfi)), text_color=color.white,
         bgcolor=color.new(mfiCol, 40), text_halign=text.align_center, text_size=txtSize)

    cmfCol = cmf > 0.1 ? cBull : cmf < -0.1 ? cBear : cNeutral
    table.cell(dash, 0, 20, "CMF", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 20, str.tostring(cmf, "#.###"), text_color=color.white,
         bgcolor=color.new(cmfCol, 40), text_halign=text.align_center, text_size=txtSize)
    obvTxt = obvRising ? "▲ Rising" : "▼ Falling"
    table.cell(dash, 2, 20, "OBV Trend", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 20, obvTxt, text_color=color.white,
         bgcolor=color.new(obvRising ? cBull : cBear, 40),
         text_halign=text.align_center, text_size=txtSize)

    // ═══ PERFORMANCE FOOTER ═══
    table.cell(dash, 0, 21, "⚡ LIVE PERFORMANCE",
         text_color=cAccent, bgcolor=cBgAlt, text_size=txtSize, text_halign=text.align_left)
    table.merge_cells(dash, 0, 21, 3, 21)

    wrCol = winRate > 60 ? cBull : winRate > 45 ? cNeutral : cBear
    table.cell(dash, 0, 22, "Win Rate (5-bar)", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 1, 22, tradesCount > 0 ? f_pct(winRate) : "—",
         text_color=color.white, bgcolor=color.new(wrCol, 40),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 2, 22, "Signals", text_color=cMute, bgcolor=cBgRow, text_halign=text.align_left, text_size=txtSize)
    table.cell(dash, 3, 22, str.tostring(winsCount) + "/" + str.tostring(tradesCount),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=txtSize)

    // ═══ RECOMMENDATION ═══
    rec = signalProb >= 85 and signalDir != 0 ? (signalDir > 0 ? "⚡ HIGH-CONVICTION LONG" : "⚡ HIGH-CONVICTION SHORT") :
          signalProb >= 70 and signalDir != 0 ? (signalDir > 0 ? "▲ Consider Long" : "▼ Consider Short") :
          squeezeActive ? "◆ Await Breakout" :
          "─ No Clear Edge"
    recCol = signalProb >= 85 and signalDir != 0 ? (signalDir > 0 ? cBull : cBear) :
             signalProb >= 70 and signalDir != 0 ? color.new(signalDir > 0 ? cBull : cBear, 40) :
             cNeutral
    table.cell(dash, 0, 23, "VERDICT", text_color=color.white, bgcolor=color.new(cAccent, 40),
         text_halign=text.align_center, text_size=txtSize)
    table.cell(dash, 1, 23, rec, text_color=color.white, bgcolor=color.new(recCol, 20),
         text_halign=text.align_center, text_size=txtSize)
    table.merge_cells(dash, 1, 23, 3, 23)

    // Final prob meter
    probTxt = "Signal Probability: " + f_pct(signalProb)
    table.cell(dash, 0, 24, probTxt, text_color=color.white, bgcolor=color.new(signalCol, 30),
         text_halign=text.align_center, text_size=txtSize)
    table.merge_cells(dash, 0, 24, 3, 24)

    table.cell(dash, 0, 25, "AetherEdge v1.0 · " + str.format_time(timenow, "yyyy-MM-dd HH:mm"),
         text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_center, text_size=size.tiny)
    table.merge_cells(dash, 0, 25, 3, 25)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSignal,  "High-Probability Long",
     "AE-AIO: Long signal @ {{ticker}} · Probability confirmed across modules")
alertcondition(shortSignal, "High-Probability Short",
     "AE-AIO: Short signal @ {{ticker}} · Probability confirmed across modules")
alertcondition(squeezeActive and not squeezeActive[1], "Squeeze Activated",
     "AE-AIO: Volatility squeeze started - expansion imminent")
alertcondition(not squeezeActive and squeezeActive[1], "Squeeze Released",
     "AE-AIO: Squeeze released - directional move starting")
alertcondition(volSpike, "Volume Spike", "AE-AIO: Unusual volume detected")
alertcondition(ta.crossover(trendScore, 20),  "Trend Turned Bullish",  "AE-AIO: Trend score crossed into bullish zone")
alertcondition(ta.crossunder(trendScore, -20), "Trend Turned Bearish", "AE-AIO: Trend score crossed into bearish zone")
````
