# Multi-Timeframe High Confidence Signals 

- url: https://www.tradingview.com/script/b3fhlJGY-Multi-Timeframe-High-Confidence-Signals/
- type: indicator
- pine_id: PUB;9937f8eafbb84a6aa8ee4d5b4792cdb3
- version: 1.0

## Description

[image]https://www.tradingview.com/x/5prLZGMe/[/image]

Multi-Timeframe High Confidence Signals is a technical analysis indicator designed to identify potential trading opportunities by combining trend direction, momentum, volume, breakout activity, and higher-timeframe confirmation into a single, easy-to-read chart tool.

The indicator is designed for 15-minute, 1-hour, and 4-hour charts, making it suitable for traders who want to analyse price action across multiple trading horizons while maintaining a consistent set of signal rules.

How It Works

The indicator combines several technical analysis components to evaluate market conditions:

Supertrend: Identifies the prevailing trend direction and helps determine when a potential trend reversal has occurred. Primary BUY and SELL signals require the appropriate Supertrend direction and a recent trend flip.

EMA 50 and EMA 200: Help assess the broader trend structure and directional bias. The 50 EMA is displayed in a muted golden-yellow colour for easy reference.

RSI: Evaluates momentum and whether price movement supports a potential bullish or bearish signal.

MACD: Measures momentum and looks for alignment between the MACD line, signal line, and histogram.

ADX and DMI: Assess trend strength and directional pressure.

Volume confirmation: Compares current volume with its moving average to help identify increased market participation.

Daily trend confirmation: Uses completed daily candles and the daily EMA 200 to provide higher-timeframe context.

Candle strength: Evaluates the candle body relative to its overall range to help identify directional conviction.

The primary signal engine scores seven conditions and requires a minimum score of five, together with the Supertrend confirmation rules. This multi-factor approach is intended to reduce reliance on any single indicator.

Confirmed BUY and SELL Signals

Green BUY and red SELL labels identify confirmed signals after a candle closes and the programmed conditions are satisfied. The indicator also includes a breakout engine that looks for price breaking above or below the previous 40-bar range, supported by volume and a momentum score.

To avoid repeatedly printing the same directional signal, the indicator limits consecutive confirmed signals in the same direction until an opposite-direction signal occurs.

FLASH BUY and FLASH SELL

The separate FLASH engine is designed to highlight unusually strong momentum while a candle is still forming.

It evaluates price movement relative to ATR, candle range, a significant volume surge, and a momentum score. FLASH BUY labels appear in aqua, while FLASH SELL labels appear in orange.

Unlike confirmed signals, FLASH signals are intrabar events. Market conditions can change before the candle closes, so these signals should be treated as early warnings of strong price movement rather than confirmed entries.

Support and Resistance

The indicator can automatically display major support and resistance levels using confirmed pivot lows and pivot highs. Support lines are lime green, while resistance lines are red. Both use 50% transparency to keep the chart readable.

The number of displayed levels, pivot confirmation settings, and line width can be adjusted through the indicator settings.

What Makes It Different?

The main feature of Multi-Timeframe High Confidence Signals is the combination of multiple technical conditions in one chart-based system. Rather than relying exclusively on a moving-average crossover, an RSI threshold, or a single breakout, it combines trend, momentum, volume, candle structure, and higher-timeframe context.

It also separates confirmed signals from rapid momentum events, allowing traders to distinguish between signals that meet the confirmed-candle rules and potential sudden moves that are still developing. Support and resistance levels and the 50 EMA provide additional visual context without requiring a separate collection of indicators.

The goal is to provide a clear, structured view of market conditions while keeping the chart focused on price action.

How to Use It

Apply the indicator to a 15-minute, 1-hour, or 4-hour chart.

Observe the BUY and SELL labels alongside the 50 EMA and the support and resistance levels.

Use the broader daily trend and surrounding price structure to evaluate the context of a signal.

Treat FLASH signals as developing momentum events and wait for candle confirmation when appropriate.

Apply independent risk management, including position sizing and predefined invalidation levels.

Important Disclaimer

This indicator is a technical analysis tool, not an automated trading strategy or a guarantee of profitable results. It does not execute trades, eliminate false signals, or predict every market movement. Signals may perform differently across assets and market conditions. Always test the indicator on historical data and in real-time conditions before relying on it for trading decisions.

Created by Onewayflight.

## Source Code

````pine

//@version=6
//====================================================
// Multi-Timeframe High Confidence Signals (by Onewayflight)
//====================================================

indicator(
     "Multi-Timeframe High Confidence Signals (by Onewayflight)",
     shorttitle="MTF HC Signals+",
     overlay=true,
     max_labels_count=500,
     max_lines_count=50)

//====================================================
// SUPPORTED TIMEFRAMES: 15M, 1H, 4H
//====================================================

allowedTimeframe = timeframe.in_seconds() == 15 * 60 or timeframe.in_seconds() == 60 * 60 or timeframe.in_seconds() == 4 * 60 * 60

if not allowedTimeframe
    runtime.error("Use this indicator on the 15-minute, 1-hour, or 4-hour chart.")

//====================================================
// SUPERTREND SETTINGS
//====================================================

stATRLength = input.int(10, "Supertrend ATR Length", minval=2, display=display.none)
stFactor = input.float(3.0, "Supertrend Factor", minval=0.5, step=0.1, display=display.none)
confirmationWindow = input.int(6, "Confirmation Window", minval=1, maxval=12, display=display.none)
showSupertrend = input.bool(false, "Show Supertrend Line", display=display.none)

//====================================================
// OTHER SETTINGS
//====================================================

fastEMALength = input.int(50, "Fast EMA", minval=2, display=display.none)
slowEMALength = input.int(200, "Slow EMA", minval=10, display=display.none)

rsiLength = input.int(14, "RSI Length", minval=2, display=display.none)
rsiBullMin = input.float(50.0, "BUY RSI Minimum", display=display.none)
rsiBullMax = input.float(72.0, "BUY RSI Maximum", display=display.none)
rsiBearMin = input.float(28.0, "SELL RSI Minimum", display=display.none)
rsiBearMax = input.float(50.0, "SELL RSI Maximum", display=display.none)

macdFast = input.int(12, "MACD Fast", minval=2, display=display.none)
macdSlow = input.int(26, "MACD Slow", minval=3, display=display.none)
macdSignal = input.int(9, "MACD Signal", minval=2, display=display.none)

adxLength = input.int(14, "ADX DI Length", minval=2, display=display.none)
adxSmoothing = input.int(14, "ADX Smoothing", minval=2, display=display.none)
adxMinimum = input.float(20.0, "Minimum ADX", display=display.none)

volumeLength = input.int(20, "Volume Average", minval=2, display=display.none)
volumeMultiplier = input.float(1.05, "Relative Volume Minimum", display=display.none)

higherTimeframe = input.timeframe("D", "Higher Timeframe", display=display.none)

minimumScore = input.int(5, "Minimum Score", minval=3, maxval=7, display=display.none)

breakoutLookback = input.int(40, "Breakout Lookback", minval=5, display=display.none)
breakoutVolumeMultiplier = input.float(1.10, "Breakout Volume", display=display.none)
breakoutMinimumScore = input.int(4, "Breakout Minimum Score", minval=2, maxval=6, display=display.none)

//====================================================
// SUPPORT / RESISTANCE SETTINGS
//====================================================

showSR = input.bool(true, "Show Major Support / Resistance")
srPivotLeft = input.int(8, "S/R Pivot Left Bars", minval=2, maxval=50)
srPivotRight = input.int(8, "S/R Pivot Confirmation Bars", minval=2, maxval=50)
srKeepLevels = input.int(3, "Number of Support / Resistance Levels", minval=1, maxval=10)
srLineWidth = input.int(2, "S/R Line Width", minval=1, maxval=4)

//====================================================
// FLASH SETTINGS
//====================================================

flashATRLength = input.int(14, "Flash ATR Length", minval=2, display=display.none)
flashATRMultiplier = input.float(0.75, "Flash Minimum Move ATR", minval=0.1, step=0.05, display=display.none)
flashRangeMultiplier = input.float(1.00, "Flash Range ATR", minval=0.5, step=0.05, display=display.none)
flashVolumeMultiplier = input.float(1.50, "Flash Volume Surge", minval=1.0, step=0.05, display=display.none)
flashBreakoutLookback = input.int(20, "Flash Breakout Lookback", minval=5, display=display.none)
flashBullRSI = input.float(60.0, "Flash Bull RSI", display=display.none)
flashBearRSI = input.float(40.0, "Flash Bear RSI", display=display.none)
flashMinimumScore = input.int(4, "Flash Momentum Score", minval=2, maxval=5, display=display.none)

//====================================================
// SUPERTREND ENGINE
//====================================================

[supertrend, stDirection] = ta.supertrend(stFactor, stATRLength)

bullishTrend = stDirection < 0
bearishTrend = stDirection > 0

bullishFlip = bullishTrend and stDirection[1] > 0
bearishFlip = bearishTrend and stDirection[1] < 0

barsSinceBullFlip = ta.barssince(bullishFlip)
barsSinceBearFlip = ta.barssince(bearishFlip)

bullWindow = not na(barsSinceBullFlip) and barsSinceBullFlip <= confirmationWindow
bearWindow = not na(barsSinceBearFlip) and barsSinceBearFlip <= confirmationWindow

//====================================================
// EMA CALCULATIONS
//====================================================

ema50 = ta.ema(close, fastEMALength)
ema200 = ta.ema(close, slowEMALength)

//====================================================
// 50 EMA — MUTED YELLOW
//====================================================

plot(
     ema50,
     title="50 EMA",
     color=color.rgb(210, 190, 90),
     linewidth=2,
     force_overlay=true)

//====================================================
// EMA TREND FILTERS
//====================================================

bullishEMA = close > ema200 and ema50 > ema200 and ema50 > ema50[1]
bearishEMA = close < ema200 and ema50 < ema200 and ema50 < ema50[1]

//====================================================
// RSI
//====================================================

rsi = ta.rsi(close, rsiLength)

rsiRising = rsi > rsi[1]
rsiFalling = rsi < rsi[1]

bullishRSI = rsi >= rsiBullMin and rsi <= rsiBullMax and rsiRising
bearishRSI = rsi >= rsiBearMin and rsi <= rsiBearMax and rsiFalling

bullishMomentumRSI = rsi > flashBullRSI and rsiRising
bearishMomentumRSI = rsi < flashBearRSI and rsiFalling

//====================================================
// MACD
//====================================================

[macdLine, macdSignalLine, macdHistogram] = ta.macd(close, macdFast, macdSlow, macdSignal)

bullishMACD = macdLine > macdSignalLine and macdHistogram > 0 and macdHistogram >= macdHistogram[1]
bearishMACD = macdLine < macdSignalLine and macdHistogram < 0 and macdHistogram <= macdHistogram[1]

//====================================================
// ADX / DMI
//====================================================

[diPlus, diMinus, adx] = ta.dmi(adxLength, adxSmoothing)

bullishADX = adx >= adxMinimum and diPlus > diMinus
bearishADX = adx >= adxMinimum and diMinus > diPlus

//====================================================
// VOLUME
//====================================================

averageVolume = ta.sma(volume, volumeLength)
relativeVolume = averageVolume > 0 ? volume / averageVolume : 0.0

volumeConfirmed = relativeVolume >= volumeMultiplier
breakoutVolumeConfirmed = relativeVolume >= breakoutVolumeMultiplier

//====================================================
// DAILY HIGHER-TIMEFRAME CONFIRMATION
//====================================================

htfClose = request.security(
     syminfo.tickerid,
     higherTimeframe,
     close[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

htfEMA = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, slowEMALength)[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

htfEMAPrevious = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, slowEMALength)[2],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

bullishHTF = htfClose > htfEMA and htfEMA > htfEMAPrevious
bearishHTF = htfClose < htfEMA and htfEMA < htfEMAPrevious

//====================================================
// CANDLE STRENGTH
//====================================================

candleRange = high - low
candleBody = math.abs(close - open)
bodyPercentage = candleRange > 0 ? candleBody / candleRange : 0.0

bullishCandle = close > open and bodyPercentage >= 0.45
bearishCandle = close < open and bodyPercentage >= 0.45

//====================================================
// PRIMARY BUY SCORE
//====================================================

int buyScore = 0

if bullishEMA
    buyScore += 1
if bullishRSI
    buyScore += 1
if bullishMACD
    buyScore += 1
if bullishADX
    buyScore += 1
if volumeConfirmed
    buyScore += 1
if bullishHTF
    buyScore += 1
if bullishCandle
    buyScore += 1

//====================================================
// PRIMARY SELL SCORE
//====================================================

int sellScore = 0

if bearishEMA
    sellScore += 1
if bearishRSI
    sellScore += 1
if bearishMACD
    sellScore += 1
if bearishADX
    sellScore += 1
if volumeConfirmed
    sellScore += 1
if bearishHTF
    sellScore += 1
if bearishCandle
    sellScore += 1

//====================================================
// PRIMARY SIGNALS
//====================================================

primaryBuy = bullWindow and bullishTrend and buyScore >= minimumScore and barstate.isconfirmed
primarySell = bearWindow and bearishTrend and sellScore >= minimumScore and barstate.isconfirmed

//====================================================
// BREAKOUT / CONTINUATION ENGINE
//====================================================

previousHighest = ta.highest(high[1], breakoutLookback)
previousLowest = ta.lowest(low[1], breakoutLookback)

bullishBreakout = close > previousHighest
bearishBreakout = close < previousLowest

//====================================================
// BREAKOUT BUY SCORE
//====================================================

int breakoutBuyScore = 0

if bullishEMA
    breakoutBuyScore += 1
if bullishMomentumRSI
    breakoutBuyScore += 1
if bullishMACD
    breakoutBuyScore += 1
if bullishADX
    breakoutBuyScore += 1
if bullishHTF
    breakoutBuyScore += 1
if bullishCandle
    breakoutBuyScore += 1

//====================================================
// BREAKOUT SELL SCORE
//====================================================

int breakoutSellScore = 0

if bearishEMA
    breakoutSellScore += 1
if bearishMomentumRSI
    breakoutSellScore += 1
if bearishMACD
    breakoutSellScore += 1
if bearishADX
    breakoutSellScore += 1
if bearishHTF
    breakoutSellScore += 1
if bearishCandle
    breakoutSellScore += 1

//====================================================
// CONFIRMED BREAKOUTS
//====================================================

breakoutBuy = bullishBreakout and breakoutVolumeConfirmed and breakoutBuyScore >= breakoutMinimumScore and barstate.isconfirmed
breakoutSell = bearishBreakout and breakoutVolumeConfirmed and breakoutSellScore >= breakoutMinimumScore and barstate.isconfirmed

//====================================================
// COMBINED CONFIRMED SIGNALS
//====================================================

buySignal = primaryBuy or breakoutBuy
sellSignal = primarySell or breakoutSell

//====================================================
// ONE CONFIRMED SIGNAL PER DIRECTION
//====================================================

var int lastDirection = 0

newBuy = buySignal and lastDirection != 1
newSell = sellSignal and lastDirection != -1

if newBuy
    lastDirection := 1

if newSell
    lastDirection := -1

//====================================================
// FLASH ENGINE
//====================================================

flashATR = ta.atr(flashATRLength)

currentMove = math.abs(close - open)
currentMoveATR = flashATR > 0 ? currentMove / flashATR : 0.0
currentRangeATR = flashATR > 0 ? candleRange / flashATR : 0.0

flashMoveStrong = currentMoveATR >= flashATRMultiplier
flashRangeStrong = currentRangeATR >= flashRangeMultiplier
flashVolumeStrong = relativeVolume >= flashVolumeMultiplier

//====================================================
// FLASH BREAKOUT
//====================================================

flashPreviousHighest = ta.highest(high[1], flashBreakoutLookback)
flashPreviousLowest = ta.lowest(low[1], flashBreakoutLookback)

flashBullishBreakout = close > flashPreviousHighest
flashBearishBreakout = close < flashPreviousLowest

//====================================================
// FLASH MOMENTUM SCORE
//====================================================

int flashBuyScore = 0

if flashBullishBreakout
    flashBuyScore += 1
if bullishMomentumRSI
    flashBuyScore += 1
if bullishMACD
    flashBuyScore += 1
if diPlus > diMinus
    flashBuyScore += 1
if bullishCandle
    flashBuyScore += 1

int flashSellScore = 0

if flashBearishBreakout
    flashSellScore += 1
if bearishMomentumRSI
    flashSellScore += 1
if bearishMACD
    flashSellScore += 1
if diMinus > diPlus
    flashSellScore += 1
if bearishCandle
    flashSellScore += 1

//====================================================
// FLASH CONDITIONS — LIVE CANDLE
//====================================================

flashBuyCondition = barstate.isrealtime and not barstate.isconfirmed and close > open and flashMoveStrong and flashRangeStrong and flashVolumeStrong and flashBuyScore >= flashMinimumScore

flashSellCondition = barstate.isrealtime and not barstate.isconfirmed and close < open and flashMoveStrong and flashRangeStrong and flashVolumeStrong and flashSellScore >= flashMinimumScore

//====================================================
// ONE FLASH PER CANDLE
//====================================================

varip bool flashFired = false
varip int flashBarIndex = na

if na(flashBarIndex) or bar_index != flashBarIndex
    flashBarIndex := bar_index
    flashFired := false

flashBuyEvent = flashBuyCondition and not flashFired
flashSellEvent = flashSellCondition and not flashFired

if flashBuyEvent or flashSellEvent
    flashFired := true

//====================================================
// BUY / SELL MARKERS — FULLY VISIBLE
//====================================================

plotshape(
     newBuy,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     force_overlay=true)

plotshape(
     newSell,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small,
     force_overlay=true)

//====================================================
// FLASH MARKERS — UNCHANGED
//====================================================

plotshape(
     flashBuyEvent,
     title="FLASH BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.aqua,
     text="FLASH BUY",
     textcolor=color.black,
     size=size.small,
     force_overlay=true)

plotshape(
     flashSellEvent,
     title="FLASH SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.orange,
     text="FLASH SELL",
     textcolor=color.black,
     size=size.small,
     force_overlay=true)

//====================================================
// OPTIONAL SUPERTREND LINE — HIDDEN BY DEFAULT
//====================================================

plot(
     showSupertrend ? supertrend : na,
     title="Supertrend",
     color=bullishTrend ? color.green : color.red,
     linewidth=2,
     force_overlay=true)

//====================================================
// ALERTS
//====================================================

alertcondition(
     newBuy,
     title="HIGH CONFIDENCE BUY",
     message="HIGH CONFIDENCE BUY — {{ticker}} — Timeframe: {{interval}} — Price: {{close}} — Onewayflight")

alertcondition(
     newSell,
     title="HIGH CONFIDENCE SELL",
     message="HIGH CONFIDENCE SELL — {{ticker}} — Timeframe: {{interval}} — Price: {{close}} — Onewayflight")

alertcondition(
     flashBuyEvent,
     title="FLASH BUY",
     message="⚡ FLASH BUY — MASSIVE LIVE MOVE — {{ticker}} — Timeframe: {{interval}} — Price: {{close}} — Onewayflight")

alertcondition(
     flashSellEvent,
     title="FLASH SELL",
     message="⚡ FLASH SELL — MASSIVE LIVE MOVE — {{ticker}} — Timeframe: {{interval}} — Price: {{close}} — Onewayflight")

//====================================================
// MAJOR SUPPORT / RESISTANCE
// Support: lime green, 50% transparent
// Resistance: red, 50% transparent
//====================================================

var array<line> supportLines = array.new_line()
var array<line> resistanceLines = array.new_line()

pivotSupport = ta.pivotlow(low, srPivotLeft, srPivotRight)
pivotResistance = ta.pivothigh(high, srPivotLeft, srPivotRight)

if showSR and not na(pivotSupport)
    supportLine = line.new(
         x1=bar_index - srPivotRight,
         y1=pivotSupport,
         x2=bar_index,
         y2=pivotSupport,
         xloc=xloc.bar_index,
         extend=extend.right,
         color=color.new(color.lime, 50),
         width=srLineWidth)
    array.push(supportLines, supportLine)
    if array.size(supportLines) > srKeepLevels
        oldSupport = array.shift(supportLines)
        line.delete(oldSupport)

if showSR and not na(pivotResistance)
    resistanceLine = line.new(
         x1=bar_index - srPivotRight,
         y1=pivotResistance,
         x2=bar_index,
         y2=pivotResistance,
         xloc=xloc.bar_index,
         extend=extend.right,
         color=color.new(color.red, 50),
         width=srLineWidth)
    array.push(resistanceLines, resistanceLine)
    if array.size(resistanceLines) > srKeepLevels
        oldResistance = array.shift(resistanceLines)
        line.delete(oldResistance)

if not showSR
    while array.size(supportLines) > 0
        line.delete(array.pop(supportLines))
    while array.size(resistanceLines) > 0
        line.delete(array.pop(resistanceLines))
````
