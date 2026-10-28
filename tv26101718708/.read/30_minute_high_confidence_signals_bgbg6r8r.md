# 30 minute High Confidence Signals

- url: https://www.tradingview.com/script/bgbG6R8R-30-minute-High-Confidence-Signals/
- type: indicator
- pine_id: PUB;4fd25a0acf8844d7bd402d57f496773f
- version: 1.0

## Description

High Confidence 30m Signals (by Onewayflight)

[image]https://www.tradingview.com/x/TS4oTR3o/[/image]

[b]What the script does[/b]
High Confidence 30m Signals is a confirmation-based market signal indicator designed to identify higher-confidence BUY and SELL opportunities on the 30-minute timeframe.
Instead of relying on a single technical indicator, the script evaluates multiple aspects of market behavior and looks for confluence between trend, momentum, strength, volume, higher-timeframe direction and price action.

The primary signal engine evaluates:
- Trend direction
- EMA structure
- RSI momentum
- MACD momentum
- ADX/DMI trend strength
- Relative volume
- Higher-timeframe confirmation
- Candle strength

A primary signal is generated only when the required conditions are sufficiently aligned and the 30-minute candle is confirmed.  
The indicator also includes a separate Flash Engine, designed to identify unusually strong live market movements using volatility, range expansion, volume and momentum conditions.    

[b]How it works[/b]

[i]Trend confirmation[/i]
The indicator uses Supertrend to determine the current directional trend and identify recent bullish or bearish trend changes.    

[i]EMA structure[/i]
The system evaluates the relationship between the 50 EMA and 200 EMA, together with their direction.
Bullish conditions require price to be above the 200 EMA, the 50 EMA to be above the 200 EMA, and the 50 EMA to be rising.
Bearish conditions use the opposite structure.   

[i]RSI momentum[/i]
RSI is used to determine whether momentum supports the current direction. The system considers both RSI level and whether RSI is rising or falling.    

[i]MACD confirmation[/i]
MACD provides additional momentum confirmation. Bullish and bearish conditions require both directional MACD structure and corresponding histogram behavior.    

[i]ADX/DMI[/i]
ADX/DMI is used to evaluate directional strength. The system requires the ADX to reach a minimum level while the appropriate directional indicator is dominant.    

[i]Relative volume[/i]
Current volume is compared with its moving average to determine whether there is sufficient market participation behind the move.    

[i]Higher-timeframe confirmation[/i]
The default higher timeframe is 2 hours.
The script evaluates higher-timeframe price and 200 EMA structure to determine whether the broader trend supports the 30-minute direction.    

[i]Candle strength[/i]
The system also evaluates the size of the candle body relative to its total range, allowing strong directional candles to contribute to the confirmation score.    

[i]High Confidence Score[/i]
The primary signal engine combines 7 confirmation factors:
1. EMA structure
2. RSI
3. MACD
4. ADX/DMI
5. Volume
6. Higher-timeframe confirmation
7. Candle strength
The default minimum score is 5 out of 7.
The score is then combined with Supertrend direction and the recent Supertrend confirmation window before a primary BUY or SELL can be generated.   
The goal is simple:
More agreement = stronger confirmation.

[i]Breakout & Continuation Engine[/i]
High Confidence 30m Signals also contains a dedicated breakout and continuation engine.
The system identifies when price breaks above a previous high or below a previous low and then evaluates additional confirmation from:
- EMA structure
- Momentum RSI
- MACD
- ADX/DMI
- Higher-timeframe direction
- Candle strength
- Volume
This allows the indicator to identify potential breakout and continuation opportunities in addition to its primary trend signals.

[b]Flash Engine[/b] 
The Flash Engine is designed specifically for unusually aggressive live market movements.
It evaluates:
- Price movement relative to ATR
- Candle range relative to ATR
- Relative volume
- Breakout conditions
- RSI momentum
- MACD momentum
- DMI direction
- Candle strength

The default configuration requires a significant volatility-adjusted move, expanded candle range, abnormal volume and sufficient momentum confirmation.

Flash signals are visually separated from the normal confirmed signals because they serve a different purpose: identifying exceptional live market movement rather than waiting for the normal confirmation process.   

[b]How to use it[/b]
High Confidence 30m Signals is designed specifically for the 30-minute timeframe.
The indicator will generate an error if it is used on another timeframe.   

[i]BUY[/i]
A bullish market structure has developed and enough confirmation factors agree.
[i]SELL[/i]
A bearish market structure has developed and enough confirmation factors agree.

[i]FLASH BUY / FLASH SELL[/i]
An unusually strong live move is occurring and satisfies the Flash Engine's volatility, volume and momentum requirements.
The signals should be used as decision-support tools, not as automatic instructions to enter or exit a position.
Users should consider broader market conditions, support and resistance, news, liquidity and their own risk-management rules.

[i]What makes it original ?[/i]
The central concept behind High Confidence 30m Signals is confluence rather than prediction.
The indicator does not depend on one indicator producing a crossover or threshold signal.
Instead, it asks whether multiple independent market conditions are agreeing in the same direction.

The system combines:
Trend + Momentum + Strength + Volume + Higher-Timeframe Direction + Price Action
into a single confirmation framework.
It also separates different types of market behavior into dedicated engines:
- Primary High-Confidence Signals
- Breakout / Continuation Signals
- Flash Signals
The indicator also prevents repeated signals in the same direction, helping keep the chart cleaner and preventing a series of duplicate BUY or SELL labels during the same directional move.    

[i]Relevant concepts[/i]
Confluence
Confluence occurs when multiple independent technical conditions support the same market direction.

[i]Confirmation[/i]
The system is designed to confirm existing market behavior rather than attempt to predict every future price movement.

[i]Trend[/i]
Trend conditions describe the broader directional structure of the market.

[i]Momentum[/i]
Momentum measures whether price movement is gaining or losing directional strength.

[i]Breakout[/i]
A breakout occurs when price moves beyond a previously established high or low and receives additional confirmation.

[i]Volatility expansion[/i]
The Flash Engine specifically looks for unusually large price movement relative to normal volatility.

[b]Limitations[/b]
No technical indicator can predict future price movements with certainty.
High Confidence 30m Signals is based on technical market data available to the Pine Script environment. It does not directly access proprietary institutional order flow, full exchange order books, liquidation feeds or external derivatives data.

Signals can fail, particularly during:
- Sideways/choppy markets
- Sudden reversals
- News-driven movements
- Low-liquidity conditions
- Abnormal market conditions

[i]Flash signals[/i] are designed to detect exceptional live movements and should not be interpreted as guaranteed continuation signals.
Past performance does not guarantee future results.
Users should conduct their own analysis and use appropriate risk management.

## Source Code

````pine
//@version=6
//====================================================
// 30 minute high confidence signals (by Onewayflight)
//====================================================

indicator(
     "30 minute high confidence signals (by Onewayflight)",
     shorttitle="30M HC Signals+",
     overlay=true,
     max_labels_count=500)

//====================================================
// 30-MINUTE ONLY
//====================================================

if timeframe.in_seconds() != 30 * 60
    runtime.error("Use this indicator on the 30-minute chart.")

//====================================================
// SETTINGS
//====================================================

stATRLength = input.int(10, "Supertrend ATR Length", minval=2, display=display.none)
stFactor = input.float(3.0, "Supertrend Factor", minval=0.5, step=0.1, display=display.none)

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

higherTimeframe = input.timeframe("120", "Higher Timeframe", display=display.none)

confirmationWindow = input.int(6, "Confirmation Window", minval=1, maxval=12, display=display.none)

minimumScore = input.int(5, "Minimum Score", minval=3, maxval=7, display=display.none)

breakoutLookback = input.int(40, "Breakout Lookback", minval=5, display=display.none)
breakoutVolumeMultiplier = input.float(1.10, "Breakout Volume", display=display.none)
breakoutMinimumScore = input.int(4, "Breakout Minimum Score", minval=2, maxval=6, display=display.none)

showSupertrend = input.bool(false, "Show Supertrend", display=display.none)

//====================================================
// FLASH SETTINGS
//====================================================

flashATRLength = input.int(14, "Flash ATR Length", minval=2, display=display.none)

flashATRMultiplier = input.float(
     0.75,
     "Flash Minimum Move ATR",
     minval=0.1,
     step=0.05,
     display=display.none)

flashRangeMultiplier = input.float(
     1.00,
     "Flash Range ATR",
     minval=0.5,
     step=0.05,
     display=display.none)

flashVolumeMultiplier = input.float(
     1.50,
     "Flash Volume Surge",
     minval=1.0,
     step=0.05,
     display=display.none)

flashBreakoutLookback = input.int(
     20,
     "Flash Breakout Lookback",
     minval=5,
     display=display.none)

flashBullRSI = input.float(
     60.0,
     "Flash Bull RSI",
     display=display.none)

flashBearRSI = input.float(
     40.0,
     "Flash Bear RSI",
     display=display.none)

flashMinimumScore = input.int(
     4,
     "Flash Momentum Score",
     minval=2,
     maxval=5,
     display=display.none)

//====================================================
// SUPERTREND
//====================================================

[supertrend, stDirection] = ta.supertrend(
     stFactor,
     stATRLength)

bullishTrend = stDirection < 0
bearishTrend = stDirection > 0

bullishFlip =
     bullishTrend and
     stDirection[1] > 0

bearishFlip =
     bearishTrend and
     stDirection[1] < 0

barsSinceBullFlip = ta.barssince(bullishFlip)
barsSinceBearFlip = ta.barssince(bearishFlip)

bullWindow =
     not na(barsSinceBullFlip) and
     barsSinceBullFlip <= confirmationWindow

bearWindow =
     not na(barsSinceBearFlip) and
     barsSinceBearFlip <= confirmationWindow

//====================================================
// EMA
//====================================================

ema50 = ta.ema(
     close,
     fastEMALength)

ema200 = ta.ema(
     close,
     slowEMALength)

bullishEMA =
     close > ema200 and
     ema50 > ema200 and
     ema50 > ema50[1]

bearishEMA =
     close < ema200 and
     ema50 < ema200 and
     ema50 < ema50[1]

//====================================================
// RSI
//====================================================

rsi = ta.rsi(
     close,
     rsiLength)

rsiRising =
     rsi > rsi[1]

rsiFalling =
     rsi < rsi[1]

bullishRSI =
     rsi >= rsiBullMin and
     rsi <= rsiBullMax and
     rsiRising

bearishRSI =
     rsi >= rsiBearMin and
     rsi <= rsiBearMax and
     rsiFalling

// Flash momentum RSI deliberately has
// NO upper/lower ceiling.

bullishMomentumRSI =
     rsi > flashBullRSI and
     rsiRising

bearishMomentumRSI =
     rsi < flashBearRSI and
     rsiFalling

//====================================================
// MACD
//====================================================

[macdLine, macdSignalLine, macdHistogram] = ta.macd(
     close,
     macdFast,
     macdSlow,
     macdSignal)

bullishMACD =
     macdLine > macdSignalLine and
     macdHistogram > 0 and
     macdHistogram >= macdHistogram[1]

bearishMACD =
     macdLine < macdSignalLine and
     macdHistogram < 0 and
     macdHistogram <= macdHistogram[1]

//====================================================
// ADX / DMI
//====================================================

[diPlus, diMinus, adx] = ta.dmi(
     adxLength,
     adxSmoothing)

bullishADX =
     adx >= adxMinimum and
     diPlus > diMinus

bearishADX =
     adx >= adxMinimum and
     diMinus > diPlus

//====================================================
// VOLUME
//====================================================

averageVolume = ta.sma(
     volume,
     volumeLength)

relativeVolume =
     averageVolume > 0 ?
     volume / averageVolume :
     0.0

volumeConfirmed =
     relativeVolume >= volumeMultiplier

breakoutVolumeConfirmed =
     relativeVolume >= breakoutVolumeMultiplier

//====================================================
// 2-HOUR HIGHER-TIMEFRAME CONFIRMATION
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

bullishHTF =
     htfClose > htfEMA and
     htfEMA > htfEMAPrevious

bearishHTF =
     htfClose < htfEMA and
     htfEMA < htfEMAPrevious

//====================================================
// CANDLE STRENGTH
//====================================================

candleRange =
     high - low

candleBody =
     math.abs(close - open)

bodyPercentage =
     candleRange > 0 ?
     candleBody / candleRange :
     0.0

bullishCandle =
     close > open and
     bodyPercentage >= 0.45

bearishCandle =
     close < open and
     bodyPercentage >= 0.45

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
// PRIMARY 30M SIGNAL
//====================================================

primaryBuy =
     bullWindow and
     bullishTrend and
     buyScore >= minimumScore and
     barstate.isconfirmed

primarySell =
     bearWindow and
     bearishTrend and
     sellScore >= minimumScore and
     barstate.isconfirmed

//====================================================
// BREAKOUT / CONTINUATION ENGINE
//====================================================

previousHighest = ta.highest(
     high[1],
     breakoutLookback)

previousLowest = ta.lowest(
     low[1],
     breakoutLookback)

bullishBreakout =
     close > previousHighest

bearishBreakout =
     close < previousLowest

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
// CONFIRMED BREAKOUT
//====================================================

breakoutBuy =
     bullishBreakout and
     breakoutVolumeConfirmed and
     breakoutBuyScore >= breakoutMinimumScore and
     barstate.isconfirmed

breakoutSell =
     bearishBreakout and
     breakoutVolumeConfirmed and
     breakoutSellScore >= breakoutMinimumScore and
     barstate.isconfirmed

//====================================================
// COMBINED CONFIRMED SIGNAL
//====================================================

buySignal =
     primaryBuy or
     breakoutBuy

sellSignal =
     primarySell or
     breakoutSell

//====================================================
// ONE CONFIRMED SIGNAL PER DIRECTION
//====================================================

var int lastDirection = 0

newBuy =
     buySignal and
     lastDirection != 1

newSell =
     sellSignal and
     lastDirection != -1

if newBuy
    lastDirection := 1

if newSell
    lastDirection := -1

//====================================================
// FLASH ENGINE
//====================================================

// ATR based on completed history.
// This gives the current candle a volatility-adjusted
// definition of "massive".

flashATR = ta.atr(
     flashATRLength)

// Current move from the 30M candle open.

currentMove =
     math.abs(close - open)

currentMoveATR =
     flashATR > 0 ?
     currentMove / flashATR :
     0.0

currentRangeATR =
     flashATR > 0 ?
     candleRange / flashATR :
     0.0

flashMoveStrong =
     currentMoveATR >= flashATRMultiplier

flashRangeStrong =
     currentRangeATR >= flashRangeMultiplier

flashVolumeStrong =
     relativeVolume >= flashVolumeMultiplier

//====================================================
// FLASH BREAKOUT
//====================================================

flashPreviousHighest = ta.highest(
     high[1],
     flashBreakoutLookback)

flashPreviousLowest = ta.lowest(
     low[1],
     flashBreakoutLookback)

flashBullishBreakout =
     close > flashPreviousHighest

flashBearishBreakout =
     close < flashPreviousLowest

//====================================================
// FLASH MOMENTUM SCORE
//====================================================

// Five fast momentum checks:
//
// 1. Breakout
// 2. RSI momentum
// 3. MACD momentum
// 4. DMI direction
// 5. Strong candle

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
// FLASH CONDITIONS
//====================================================

// We deliberately require:
// - live candle
// - large volatility-adjusted move
// - expanded candle range
// - abnormal volume
// - strong momentum score
//
// This is designed to catch violent moves,
// not ordinary candle movement.

flashBuyCondition =
     barstate.isrealtime and
     not barstate.isconfirmed and
     close > open and
     flashMoveStrong and
     flashRangeStrong and
     flashVolumeStrong and
     flashBuyScore >= flashMinimumScore

flashSellCondition =
     barstate.isrealtime and
     not barstate.isconfirmed and
     close < open and
     flashMoveStrong and
     flashRangeStrong and
     flashVolumeStrong and
     flashSellScore >= flashMinimumScore

//====================================================
// ONE FLASH PER 30M CANDLE
//====================================================

varip bool flashFired = false
varip int flashBarIndex = na

if na(flashBarIndex) or bar_index != flashBarIndex
    flashBarIndex := bar_index
    flashFired := false

flashBuyEvent =
     flashBuyCondition and
     not flashFired

flashSellEvent =
     flashSellCondition and
     not flashFired

if flashBuyEvent or flashSellEvent
    flashFired := true

//====================================================
// NORMAL BUY / SELL MARKERS
//====================================================

plotshape(
     newBuy,
     title="30M BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     force_overlay=true)

plotshape(
     newSell,
     title="30M SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small,
     force_overlay=true)

//====================================================
// FLASH MARKERS
//====================================================

// These are intentionally visually different from
// the confirmed signals.

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
// OPTIONAL SUPERTREND
//====================================================

plot(
     showSupertrend ? supertrend : na,
     title="Supertrend",
     color=bullishTrend ? color.green : color.red,
     linewidth=2,
     force_overlay=true)

//====================================================
// CONFIRMED ALERTS
//====================================================

alertcondition(
     newBuy,
     title="30M HIGH CONFIDENCE BUY",
     message="30M HIGH CONFIDENCE BUY — {{ticker}} — Price: {{close}} — Onewayflight")

alertcondition(
     newSell,
     title="30M HIGH CONFIDENCE SELL",
     message="30M HIGH CONFIDENCE SELL — {{ticker}} — Price: {{close}} — Onewayflight")

//====================================================
// FLASH ALERTS
//====================================================

alertcondition(
     flashBuyEvent,
     title="30M FLASH BUY",
     message="⚡ 30M FLASH BUY — MASSIVE LIVE MOVE — {{ticker}} — Price: {{close}} — Onewayflight")

alertcondition(
     flashSellEvent,
     title="30M FLASH SELL",
     message="⚡ 30M FLASH SELL — MASSIVE LIVE MOVE — {{ticker}} — Price: {{close}} — Onewayflight")
````
