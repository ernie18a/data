# Rajiv AI Trend Finder

- url: https://www.tradingview.com/script/8lB1OuIm-Rajiv-AI-Trend-Finder/
- type: indicator
- pine_id: PUB;7290dfadd2564becb5c6a71d500d7cd7
- version: 1.0

## Description

Rajiv AI Trend Finder — Script Description
Overview

Rajiv AI Trend Finder is an advanced multi-indicator AI-based trend analysis indicator for TradingView designed to identify:

Bullish trends
Bearish trends
Sideways markets
Trend strength
Trend quality
Buy/Sell opportunities

The script combines several professional trading indicators into a single AI scoring system to provide highly confirmed market direction analysis.

Indicators Used
1. EMA (Exponential Moving Average)

Used for trend direction and momentum.

Fast EMA above Slow EMA → Bullish
Fast EMA below Slow EMA → Bearish
Narrow EMA distance → Sideways
2. VWAP (Volume Weighted Average Price)

Institutional trend confirmation.

Price above VWAP → Bullish
Price below VWAP → Bearish
Price near VWAP → Sideways
3. RSI (Relative Strength Index)

Measures momentum strength.

RSI above 60 → Bullish momentum
RSI below 40 → Bearish momentum
RSI between 45–55 → Sideways
4. ADX + DMI

Measures trend strength.

ADX above 25 → Strong trend
+DI above -DI → Bullish
-DI above +DI → Bearish
ADX below 20 → Sideways
5. MACD

Momentum and trend confirmation.

MACD above Signal Line → Bullish
MACD below Signal Line → Bearish
Flat histogram → Sideways
6. Supertrend

Trend-following confirmation.

Green Supertrend → Bullish
Red Supertrend → Bearish
Price near Supertrend → Sideways
7. Volume Confirmation

Checks institutional participation.

High bullish volume → Bullish confirmation
High bearish volume → Bearish confirmation
Low volume → Sideways probability
AI Scoring System

The script uses an internal AI-style scoring model.

Each indicator contributes bullish, bearish, or sideways points.

The system compares:

Bullish score
Bearish score
Sideways score

The strongest score determines market condition.

## Source Code

````pine
//@version=5
indicator("Rajiv AI Trend Finder", overlay=true, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================

// EMA
useEMA           = input.bool(true, "Use EMA")
emaFastLen       = input.int(20, "Fast EMA")
emaSlowLen       = input.int(50, "Slow EMA")

// ADX
useADX           = input.bool(true, "Use ADX")
adxLen           = input.int(14, "ADX Length")

// RSI
useRSI           = input.bool(true, "Use RSI")
rsiLen           = input.int(14, "RSI Length")

// MACD
useMACD          = input.bool(true, "Use MACD")
macdFastLen      = input.int(12, "MACD Fast Length")
macdSlowLen      = input.int(26, "MACD Slow Length")
macdSignalLen    = input.int(9, "MACD Signal Length")

// Supertrend
useSupertrend    = input.bool(true, "Use Supertrend")
supertrendATR    = input.int(10, "Supertrend ATR")
supertrendFactor = input.float(3.0, "Supertrend Factor")

// VWAP
useVWAP          = input.bool(true, "Use VWAP")

// Volume
useVolume        = input.bool(true, "Use Volume Confirmation")

// Signals
showSignals      = input.bool(true, "Show Buy/Sell Signals")

// =====================================================
// LABEL SETTINGS
// =====================================================
labelTextColor   = input.color(color.white, "Label Text Color")
bullLabelColor   = input.color(color.green, "Bullish Label Color")
bearLabelColor   = input.color(color.red, "Bearish Label Color")
sidewaysColor    = input.color(color.gray, "Sideways Label Color")

labelSizeInput = input.string(
     "large",
     "Label Size",
     options=["tiny", "small", "normal", "large", "huge"]
     )

// =====================================================
// LABEL SIZE
// =====================================================
labelSize =
     labelSizeInput == "tiny" ? size.tiny :
     labelSizeInput == "small" ? size.small :
     labelSizeInput == "normal" ? size.normal :
     labelSizeInput == "large" ? size.large :
     size.huge

// =====================================================
// INDICATORS
// =====================================================

// EMA
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// RSI
rsiValue = ta.rsi(close, rsiLen)

// ADX
[diplus, diminus, adxValue] = ta.dmi(adxLen, adxLen)

// Supertrend
[supertrend, direction] = ta.supertrend(supertrendFactor, supertrendATR)

// VWAP
vwapValue = ta.vwap(close)

// Volume
avgVolume = ta.sma(volume, 20)

// ATR
atrValue = ta.atr(14)

// MACD
[macdLine, signalLine, histLine] = ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)

// =====================================================
// AI SCORE
// =====================================================
bullScore = 0
bearScore = 0
sidewaysScore = 0

// =====================================================
// EMA ANALYSIS
// =====================================================
if useEMA

    emaDistance = math.abs(emaFast - emaSlow)

    if emaFast > emaSlow and emaDistance > atrValue * 0.2
        bullScore += 20

    if emaFast < emaSlow and emaDistance > atrValue * 0.2
        bearScore += 20

    if emaDistance <= atrValue * 0.2
        sidewaysScore += 20

// =====================================================
// VWAP ANALYSIS
// =====================================================
if useVWAP

    if close > vwapValue
        bullScore += 15

    if close < vwapValue
        bearScore += 15

    if math.abs(close - vwapValue) < atrValue * 0.2
        sidewaysScore += 15

// =====================================================
// RSI ANALYSIS
// =====================================================
if useRSI

    if rsiValue > 60
        bullScore += 15

    if rsiValue < 40
        bearScore += 15

    if rsiValue >= 45 and rsiValue <= 55
        sidewaysScore += 15

// =====================================================
// ADX ANALYSIS
// =====================================================
if useADX

    if adxValue > 25 and diplus > diminus
        bullScore += 20

    if adxValue > 25 and diminus > diplus
        bearScore += 20

    if adxValue < 20
        sidewaysScore += 20

// =====================================================
// MACD ANALYSIS
// =====================================================
if useMACD

    if macdLine > signalLine and histLine > 0
        bullScore += 20

    if macdLine < signalLine and histLine < 0
        bearScore += 20

    if math.abs(histLine) < 0.05
        sidewaysScore += 15

// =====================================================
// SUPERTREND ANALYSIS
// =====================================================
if useSupertrend

    if direction > 0
        bullScore += 15

    if direction < 0
        bearScore += 15

    if math.abs(close - supertrend) < atrValue * 0.2
        sidewaysScore += 15

// =====================================================
// VOLUME ANALYSIS
// =====================================================
if useVolume

    if volume > avgVolume

        if close > open
            bullScore += 15

        if close < open
            bearScore += 15

    if volume < avgVolume
        sidewaysScore += 10

// =====================================================
// FINAL TREND DETECTION
// =====================================================
trendScore = math.max(bullScore, math.max(bearScore, sidewaysScore))

bullTrend = bullScore > bearScore and bullScore > sidewaysScore
bearTrend = bearScore > bullScore and bearScore > sidewaysScore
sideways  = sidewaysScore >= bullScore and sidewaysScore >= bearScore

// =====================================================
// STAR RANKING
// =====================================================
starRank =
     trendScore >= 110 ? "★★★★★" :
     trendScore >= 90 ? "★★★★" :
     trendScore >= 70 ? "★★★" :
     trendScore >= 50 ? "★★" :
     "★"

// =====================================================
// TREND QUALITY
// =====================================================
trendQuality =
     trendScore >= 110 ? "VERY STRONG" :
     trendScore >= 90 ? "STRONG" :
     trendScore >= 70 ? "GOOD" :
     trendScore >= 50 ? "MODERATE" :
     "WEAK"

// =====================================================
// TREND COLOR
// =====================================================
trendColor =
     bullTrend ? bullLabelColor :
     bearTrend ? bearLabelColor :
     sidewaysColor

// =====================================================
// BUY SELL SIGNALS
// =====================================================
buySignal =
     bullTrend and
     ta.crossover(emaFast, emaSlow)

sellSignal =
     bearTrend and
     ta.crossunder(emaFast, emaSlow)

// =====================================================
// SIGNALS
// =====================================================
plotshape(
     showSignals and buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
     )

plotshape(
     showSignals and sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
     )

// =====================================================
// TREND LABEL
// =====================================================
var label trendLabel = na

if barstate.islast

    label.delete(trendLabel)

    trendDirection =
         bullTrend ? "BULLISH" :
         bearTrend ? "BEARISH" :
         "SIDEWAYS"

    trendText =
         "Rajiv AI Trend Finder" +
         "\n" +
         trendDirection +
         "\n" +
         starRank +
         "\n" +
         trendQuality +
         "\nScore : " +
         str.tostring(trendScore)

    trendLabel := label.new(
         bar_index,
         high,
         trendText,
         style=label.style_label_down,
         color=trendColor,
         textcolor=labelTextColor,
         size=labelSize
         )

// =====================================================
// OPTIONAL PLOTS
// =====================================================
plot(useEMA ? emaFast : na, color=color.green, linewidth=2, title="Fast EMA")

plot(useEMA ? emaSlow : na, color=color.red, linewidth=2, title="Slow EMA")

plot(useVWAP ? vwapValue : na, color=color.blue, linewidth=2, title="VWAP")

plot(useSupertrend ? supertrend : na, color=color.purple, linewidth=2, title="Supertrend")
````
