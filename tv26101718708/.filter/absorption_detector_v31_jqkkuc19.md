# Absorption Detector v3.1

- url: https://www.tradingview.com/script/jqKkUC19-Absorption-Detector-v3-1/
- type: indicator
- pine_id: PUB;85acdf8fb09e4d848735380776135bed
- version: 1.0

## Description

absorption volume calculator price action detector

## Source Code

````pine
//@version=5
// Absorption Detector v3 — trend filter + cooldown + cluster warning
indicator("Absorption Detector v3", overlay=false, format=format.volume)

// ─── INPUTS ───
lengthNorm    = input.int(50,    "Normalization Lookback",   minval=10, maxval=200)
trendLen      = input.int(5,     "Trend Context Length",     minval=2,  maxval=20)
absThreshold  = input.float(2.0, "Absorption Threshold (σ)", minval=0.5, step=0.25)
smoothLen     = input.int(3,     "Smoothing Length",         minval=1, maxval=10)
showBg        = input.bool(true, "Highlight Absorption Zones")

// Trend filter
useTrendFilter = input.bool(true, "Enable Trend Filter",     group="Trend Filter")
emaFast        = input.int(9,    "Fast EMA",                 group="Trend Filter", minval=3, maxval=50)
emaSlow        = input.int(21,   "Slow EMA",                 group="Trend Filter", minval=10, maxval=100)

// Cooldown
cooldownBars   = input.int(5,    "Cooldown (bars between signals)", minval=0, maxval=20)

// ─── CORE: ABSORPTION RATIO ───
candleRange  = high - low
safeRange    = math.max(candleRange, syminfo.mintick)
rawAbsRatio  = volume / safeRange
absMean      = ta.sma(rawAbsRatio, lengthNorm)
absStd       = ta.stdev(rawAbsRatio, lengthNorm)
safeStd      = math.max(absStd, 0.0001)
absZScore    = (rawAbsRatio - absMean) / safeStd
absSmoothed  = ta.sma(absZScore, smoothLen)

// ─── CONTEXT-AWARE DELTA ───
priceChange  = close - close[trendLen]
trendSma     = ta.sma(close, trendLen)
incomingSell = close < trendSma and priceChange < 0
incomingBuy  = close > trendSma and priceChange > 0

delta = incomingSell ? 1.0 : incomingBuy ? -1.0 : 0.0

// ─── TREND FILTER ───
// Strong uptrend = don't trust sell absorption (freight train)
// Strong downtrend = don't trust buy absorption
emaF = ta.ema(close, emaFast)
emaS = ta.ema(close, emaSlow)

strongUptrend   = emaF > emaS and close > emaF
strongDowntrend = emaF < emaS and close < emaF

// ─── RAW ABSORPTION DETECTION ───
isAbsorptionRaw     = absSmoothed > absThreshold
isBuyAbsorptionRaw  = isAbsorptionRaw and incomingSell
isSellAbsorptionRaw = isAbsorptionRaw and incomingBuy

// ─── TREND-FILTERED SIGNALS ───
// With-trend signals = STRONG (high confidence)
// Counter-trend signals = WEAK (likely to fail / freight train)
isBuyStrong  = isBuyAbsorptionRaw and (not useTrendFilter or not strongDowntrend)
isBuyWeak    = isBuyAbsorptionRaw and useTrendFilter and strongDowntrend
isSellStrong = isSellAbsorptionRaw and (not useTrendFilter or not strongUptrend)
isSellWeak   = isSellAbsorptionRaw and useTrendFilter and strongUptrend

// ─── COOLDOWN ───
var int lastBuyBar  = 0
var int lastSellBar = 0

buyReady  = bar_index - lastBuyBar  >= cooldownBars
sellReady = bar_index - lastSellBar >= cooldownBars

isBuySignal      = isBuyStrong and buyReady
isBuyWeakSignal  = isBuyWeak and buyReady
isSellSignal     = isSellStrong and sellReady
isSellWeakSignal = isSellWeak and sellReady

if isBuySignal or isBuyWeakSignal
    lastBuyBar := bar_index
if isSellSignal or isSellWeakSignal
    lastSellBar := bar_index

// ─── PLOTTING: INDICATOR PANEL ───
absColor = isBuySignal ? color.new(#00C853, 0) : isSellSignal ? color.new(#FF1744, 0) : isBuyWeakSignal ? color.new(#00C853, 60) : isSellWeakSignal ? color.new(#FF1744, 60) : color.new(#9E9E9E, 40)
plot(absSmoothed, "Absorption Ratio (z)", color=absColor, linewidth=2)

hline(absThreshold, "Threshold", color=color.new(#FF9800, 50), linestyle=hline.style_dashed)
hline(0, "Zero", color=color.new(#616161, 70))

// Strong signals — solid markers
plotshape(isBuySignal  ? absSmoothed : na, "Buy Absorption (Strong)",  shape.triangleup,   location.absolute, color.new(#00C853, 0), size=size.small)
plotshape(isSellSignal ? absSmoothed : na, "Sell Absorption (Strong)", shape.triangledown, location.absolute, color.new(#FF1744, 0), size=size.small)

// Weak / counter-trend signals — faded X markers (freight train warning)
plotshape(isBuyWeakSignal  ? absSmoothed : na, "Buy Absorption (Weak)",  shape.xcross, location.absolute, color.new(#00C853, 50), size=size.tiny)
plotshape(isSellWeakSignal ? absSmoothed : na, "Sell Absorption (Weak)", shape.xcross, location.absolute, color.new(#FF1744, 50), size=size.tiny)

// Background
bgcolor(showBg and isBuySignal  ? color.new(#00C853, 88) : na)
bgcolor(showBg and isSellSignal ? color.new(#FF1744, 88) : na)

// Weighted delta histogram
weightedDelta = absSmoothed * delta
plot(weightedDelta, "Weighted Delta", style=plot.style_columns, color=weightedDelta > 0 ? color.new(#00C853, 50) : color.new(#FF1744, 50))

// ─── ALERTS ───
alertcondition(isBuySignal,      "Buy Absorption (Strong)",  "🟢 Strong buy absorption — trend-aligned support")
alertcondition(isSellSignal,     "Sell Absorption (Strong)", "🔴 Strong sell absorption — trend-aligned resistance")
alertcondition(isBuyWeakSignal,  "Buy Absorption (Weak)",    "⚠️ Weak buy absorption — counter-trend, likely freight train")
alertcondition(isSellWeakSignal, "Sell Absorption (Weak)",   "⚠️ Weak sell absorption — counter-trend, likely freight train")
````
