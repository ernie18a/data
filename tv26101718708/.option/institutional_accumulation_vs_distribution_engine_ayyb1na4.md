# Institutional Accumulation vs Distribution Engine

- url: https://www.tradingview.com/script/ayYb1Na4-Institutional-Accumulation-vs-Distribution-Engine/
- type: indicator
- pine_id: PUB;c870f1a6c7d74a92905bba5796629a04
- version: 1.0

## Description

The Institutional Accumulation vs Distribution Engine is a professional-grade TradingView Pine v6 indicator built to detect whether a stock is being quietly accumulated by institutions or distributed after a rally.

It combines price action, volume behavior, relative strength, volatility structure, and smart-money flow into a single weighted institutional score.

🔍 What the Indicator Detects
✅ Accumulation Signals
Higher highs & higher lows
Tight volatility contraction before breakout
Rising smart-money absorption near VWAP/support
Low-volume pullbacks during uptrends
Relative outperformance vs Nifty and sector
Breakouts with expanding volume
❌ Distribution Signals
Failed breakouts and heavy-volume reversals
Gap-up exhaustion candles
Weak relative strength
Breakdown after volume spikes
Repeated rejection near resistance
📊 Weighted Institutional Model
Price–Volume Structure → 20%
Smart Money / Delivery Proxy → 20%
Institutional Activity Proxy → 15%
Fundamental Momentum → 15%
Relative Strength → 10%
Technical Structure → 10%
Volatility Compression → 5%
Market Cycle Positioning → 5%
📈 Outputs
Institutional Score (0–100)
Accumulation / Distribution Phase
Confidence Level
Smoothed Trend Strength

The indicator uses Accumulation/Distribution (A/D) concepts widely used in institutional trading to analyze underlying supply-demand dynamics.

## Source Code

````pine
//@version=6
indicator("Institutional Accumulation vs Distribution Engine", overlay=false)

// =====================
// INPUTS
// =====================
niftySymbol = input.symbol("NSE:NIFTY", "Nifty Benchmark")
sectorSymbol = input.symbol("NSE:NIFTY", "Sector Benchmark")
smoothLen = input.int(9, "Smoothing Length", minval=1)

// =====================
// BENCHMARK DATA
// =====================
niftyClose = request.security(niftySymbol, timeframe.period, close)
sectorClose = request.security(sectorSymbol, timeframe.period, close)

// =====================
// CORE INDICATORS
// =====================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

rsi14 = ta.rsi(close, 14)

atr14 = ta.atr(14)
atrAvg = ta.sma(atr14, 50)

volAvg20 = ta.sma(volume, 20)
volAvg50 = ta.sma(volume, 50)

vwapValue = ta.vwap(close)

// =====================
// RELATIVE STRENGTH
// =====================
rsNifty = close / niftyClose
rsSector = close / sectorClose

rsNiftyMA = ta.sma(rsNifty, 50)
rsSectorMA = ta.sma(rsSector, 50)

rsStrong = rsNifty > rsNiftyMA and rsSector > rsSectorMA
rsWeak = rsNifty < rsNiftyMA and rsSector < rsSectorMA

// =====================
// PRICE STRUCTURE
// =====================
higherHigh = high > high[1]
higherLow = low > low[1]

upVolume = close > open and volume > volAvg20

lowVolPullback = close < close[1] and volume < volAvg20

heavySell = close < open and volume > volAvg50 * 1.5

// =====================
// SMART MONEY
// =====================
priceRange = math.max(high - low, 0.01)

mfm = ((close - low) - (high - close)) / priceRange

adl = ta.cum(mfm * volume)

adlBull = adl > ta.sma(adl, 20)

nearVWAP = math.abs(close - vwapValue) / close < 0.01

smartAbsorption = nearVWAP and volume > volAvg20 and math.abs(close - open) / close < 0.01

// =====================
// VOLATILITY
// =====================
compression = atr14 < atrAvg
expansion = atr14 > atrAvg * 1.2

// =====================
// BREAKOUT / DISTRIBUTION
// =====================
breakout = close > ta.highest(high, 20)[1] and volume > volAvg20

failedBreakout = high > ta.highest(high, 20)[1] and close < open

resistanceReject = high >= ta.highest(high, 30)[1] and close < open

breakdown = close < ta.lowest(low, 20)[1] and volume > volAvg20

// =====================
// INSTITUTIONAL PROXY
// =====================
instAccumulation = rsStrong and close > ema50 and adlBull

instDistribution = rsWeak and close < ema50

// =====================
// FUNDAMENTAL MOMENTUM
// =====================
fundBull = close > ema50 and rsi14 > 55 and rsi14 < 75

fundBear = close < ema50 and rsi14 < 45

// =====================
// SCORES
// =====================
float pvScore = 0.0

pvScore += higherHigh ? 2 : 0
pvScore += higherLow ? 2 : 0
pvScore += upVolume ? 1 : 0
pvScore -= heavySell ? 3 : 0
pvScore -= failedBreakout ? 2 : 0

pvScore := math.max(math.min(pvScore, 5), -5)

float smartScore = 0.0

smartScore += adlBull ? 2 : 0
smartScore += smartAbsorption ? 2 : 0
smartScore += lowVolPullback ? 1 : 0
smartScore -= breakdown ? 3 : 0

smartScore := math.max(math.min(smartScore, 5), -5)

float instScore = 0.0

instScore += instAccumulation ? 3 : 0
instScore += rsStrong ? 2 : 0
instScore -= instDistribution ? 3 : 0

instScore := math.max(math.min(instScore, 5), -5)

float fundScore = 0.0

fundScore += fundBull ? 3 : 0
fundScore += close > ema200 ? 2 : 0
fundScore -= fundBear ? 3 : 0

fundScore := math.max(math.min(fundScore, 5), -5)

float rsScore = 0.0

rsScore += rsStrong ? 4 : 0
rsScore += ta.roc(close, 20) > 0 ? 1 : 0
rsScore -= rsWeak ? 3 : 0

rsScore := math.max(math.min(rsScore, 5), -5)

float techScore = 0.0

techScore += breakout ? 3 : 0
techScore += ema20 > ema50 ? 1 : 0
techScore += ema50 > ema200 ? 1 : 0
techScore -= resistanceReject ? 2 : 0

techScore := math.max(math.min(techScore, 5), -5)

float volScore = 0.0

volScore += compression ? 3 : 0
volScore -= expansion and close < ema50 ? 2 : 0

volScore := math.max(math.min(volScore, 5), -5)

float cycleScore = 0.0

cycleScore += close > ema200 ? 3 : 0
cycleScore += rsStrong ? 2 : 0
cycleScore -= rsWeak ? 3 : 0

cycleScore := math.max(math.min(cycleScore, 5), -5)

// =====================
// FINAL SCORE
// =====================
totalScore = (
    pvScore * 20 +
    smartScore * 20 +
    instScore * 15 +
    fundScore * 15 +
    rsScore * 10 +
    techScore * 10 +
    volScore * 5 +
    cycleScore * 5
)

normalizedScore = (totalScore + 500) / 10

smoothedScore = ta.sma(normalizedScore, smoothLen)

// =====================
// PHASE
// =====================
phase = smoothedScore >= 70 ? "ACCUMULATION" : smoothedScore <= 40 ? "DISTRIBUTION" : "NEUTRAL"

confidence = smoothedScore >= 80 or smoothedScore <= 25 ? "HIGH" : smoothedScore >= 65 or smoothedScore <= 40 ? "MEDIUM" : "LOW"

// =====================
// OUTPUT
// =====================
plot(
    smoothedScore,
    title="Institutional Score",
    color=smoothedScore >= 70 ? color.lime : smoothedScore <= 40 ? color.red : color.orange,
    linewidth=3
)

hline(70, "Accumulation", color=color.green)
hline(40, "Distribution", color=color.red)

if barstate.islast
    label.new(
        bar_index,
        smoothedScore,
        "Score: " + str.tostring(math.round(smoothedScore)) +
        "\nPhase: " + phase +
        "\nConfidence: " + confidence,
        style=label.style_label_up
    )
````
