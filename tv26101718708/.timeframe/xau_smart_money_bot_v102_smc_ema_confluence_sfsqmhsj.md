# XAU Smart Money Bot V10.2 [SMC + EMA Confluence]

- url: https://www.tradingview.com/script/sfSQmHSj-XAU-Smart-Money-Bot-V10-2-SMC-EMA-Confluence/
- type: indicator
- pine_id: PUB;0c5c9fd94628428aa386f0d9e7a376c5
- version: 1.0

## Description

XAU Smart Money Bot V10.2

XAU Smart Money Bot V10.1 is a Smart Money Concepts (SMC) based trading indicator designed specifically for Gold (XAUUSD).

The indicator combines multiple market structure and momentum concepts into a single confluence-based system to identify high-probability BUY and SELL opportunities.

Core Components

The script combines:

• 9 EMA / 21 EMA trend analysis
• Higher Timeframe Bias filtering
• Fair Value Gaps (FVG)
• Order Blocks (OB)
• Liquidity Sweeps
• Market Structure Shifts (BOS / CHoCH)
• Premium and Discount Zones
• Displacement Candles
• Volume Confirmation using OBV
• ATR Volatility Filter

The purpose of combining these concepts is to filter out weak setups and only generate signals when trend, liquidity, momentum and market structure align in the same direction.

Signals are generated only when several conditions align simultaneously, reducing low-quality entries and helping traders focus on stronger setups.

Signal Logic

The indicator evaluates multiple bullish and bearish factors and creates a score-based confirmation model.

A signal is generated when:

Trend direction agrees with higher timeframe bias
Market structure supports the trade direction
Momentum and displacement are present
Liquidity conditions are favorable
Volatility requirements are met
Entry System

Instead of using market execution, the indicator calculates a Smart Money style entry zone based on recent price action.

For every signal the script automatically plots:

• Entry Level
• Stop Loss Level
• Take Profit Level

The entry is designed to provide better risk-to-reward opportunities compared to chasing price after a signal appears.

Visual Features

The indicator displays:

BUY / SELL labels
Entry levels
Stop Loss levels
Take Profit levels
EMA trend structure

This allows traders to quickly evaluate potential setups directly on the chart.

Recommended Markets

Designed primarily for:

XAUUSD (Gold)
Recommended Timeframes
15 Minute
30 Minute
1 Hour
Risk Disclaimer

This indicator is intended for educational and analytical purposes only.

No indicator can predict market movements with certainty. Always use proper risk management and perform your own analysis before entering any trade.

## Source Code

````pine
//@version=5
indicator("XAU Smart Money Bot V10.2", overlay=true)

// =====================================================
// HIGHER TIMEFRAME TREND (1H)
// =====================================================

htfEma9 = request.security(syminfo.tickerid, "60", ta.ema(close, 9))
htfEma21 = request.security(syminfo.tickerid, "60", ta.ema(close, 21))

htfBull = htfEma9 > htfEma21
htfBear = htfEma9 < htfEma21

// =====================================================
// CURRENT TF EMA
// =====================================================

ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

bullTrend = ema9 > ema21
bearTrend = ema9 < ema21

plot(ema9, color=color.green)
plot(ema21, color=color.red)

emaRejectSell = high >= ema9 and close < ema9
emaRejectBuy = low <= ema9 and close > ema9

// MARKET STRUCTURE

hh = high > high[1] and high[1] > high[2]
ll = low < low[1] and low[1] < low[2]

bullStructure = hh and close > ema21
bearStructure = ll and close < ema21

// EQUAL HIGHS / LOWS

equalHighs = math.abs(high - high[1]) < 1.5
equalLows = math.abs(low - low[1]) < 1.5

liquiditySell = equalHighs and close < high
liquidityBuy = equalLows and close > low

// PREMIUM / DISCOUNT

rangeHigh = ta.highest(high, 50)
rangeLow = ta.lowest(low, 50)

eq = (rangeHigh + rangeLow) / 2

premium = close > eq
discount = close < eq

// DISPLACEMENT

bullDisplacement =
 close > open and
 (close - open) > ta.atr(14) * 0.7

bearDisplacement =
 close < open and
 (open - close) > ta.atr(14) * 0.7

// HTF TREND

htfTrendEma9 = request.security(syminfo.tickerid, "15", ta.ema(close, 9))

htfTrendEma21 = request.security(syminfo.tickerid, "15", ta.ema(close, 21))

htfBullBias = htfTrendEma9 > htfTrendEma21
htfBearBias = htfTrendEma9 < htfTrendEma21

// =====================================================
// ATR / MOMENTUM
// =====================================================

atr = ta.atr(14)

strongBullCandle =
 close > open and
 (close - open) > atr * 1.0

strongBearCandle =
 close < open and
 (open - close) > atr * 1.0
 // VOLATILITY FILTER

highVolatility =
 atr > ta.sma(atr, 20)
// OBV

obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
obvBull = obv > obv[1]
obvBear = obv < obv[1]
// HTF FVG

bullishSequence =
 close > open and
 close[1] > open[1] and
 close[2] > open[2]

bearishSequence =
 close < open and
 close[1] < open[1] and
 close[2] < open[2]

htfBullFVG =
 request.security(
     syminfo.tickerid,
     "60",
     bullishSequence and low > high[2]
 )

htfBearFVG =
 request.security(
     syminfo.tickerid,
     "60",
     bearishSequence and high < low[2]
 )
 // HTF ORDER BLOCK

bullOB =
 close[1] < open[1] and
 close > high[1]

bearOB =
 close[1] > open[1] and
 close < low[1]

htfBullOB =
 request.security(
     syminfo.tickerid,
     "60",
     bullOB
 )

htfBearOB =
 request.security(
     syminfo.tickerid,
     "60",
     bearOB
 )
// =====================================================
// LIQUIDITY SWEEPS
// =====================================================

bullSweep =low < ta.lowest(low, 10)[1] and close > low + (high - low) * 0.5

bearSweep =high > ta.highest(high, 10)[1] and close < high - (high - low) * 0.5
// =====================================================
// MARKET STRUCTURE
// =====================================================

higherHigh = high > high[1]
higherLow = low > low[1]

lowerHigh = high < high[1]
lowerLow = low < low[1]

// =====================================================
// BOS (BREAK OF STRUCTURE)
// =====================================================

bullBOS = close > ta.highest(high, 10)[1]
bearBOS = close < ta.lowest(low, 10)[1]

// =====================================================
// RANGE FILTER
// =====================================================

emaDistance = math.abs(ema9 - ema21)

trendingMarket = emaDistance > atr * 0.15

// =====================================================
// RETEST
// =====================================================

bullRetest = low <= ema9
bearRetest = high >= ema9

// =====================================================
// SESSION FILTER
// =====================================================

currentHour = hour(time, "Europe/Budapest")

asiaSession =
 hour >= 0 and currentHour < 6

sessionAllowed =
 not asiaSession

emaBull = ema9 > ema21
emaBear = ema9 < ema21

// =====================================
// FIBONACCI
// =====================================

swingHigh = ta.highest(high, 20)
swingLow = ta.lowest(low, 20)

fibBuy618 = swingHigh - (swingHigh - swingLow) * 0.618
fibSell618 = swingLow + (swingHigh - swingLow) * 0.618

nearFibBuy = math.abs(close - fibBuy618) < 5
nearFibSell = math.abs(close - fibSell618) < 5

// PREMIUM / DISCOUNT

eqLevel = (swingHigh + swingLow) / 2

discountZone = close < eqLevel
premiumZone = close > eqLevel

// BUY SCORE

buyScore = 0

buyScore := emaBull ? buyScore + 1 : buyScore
buyScore := bullSweep ? buyScore + 1 : buyScore
buyScore := strongBullCandle ? buyScore + 1 : buyScore
buyScore := htfBullFVG ? buyScore + 1 : buyScore
buyScore := htfBullOB ? buyScore + 1 : buyScore
buyScore := obvBull ? buyScore + 1 : buyScore
buyScore := highVolatility ? buyScore + 1 : buyScore
buyScore := nearFibBuy ? buyScore + 1 : buyScore
buyScore := emaRejectBuy ? buyScore + 1 : buyScore
buyScore := bullStructure ? buyScore + 1 : buyScore
buyScore := liquidityBuy ? buyScore + 1 : buyScore
buyScore := discount ? buyScore + 1 : buyScore
buyScore := bullDisplacement ? buyScore + 1 : buyScore

// SELL SCORE

sellScore = 0

sellScore := emaBear ? sellScore + 1 : sellScore
sellScore := bearSweep ? sellScore + 1 : sellScore
sellScore := strongBearCandle ? sellScore + 1 : sellScore
sellScore := htfBearFVG ? sellScore + 1 : sellScore
sellScore := htfBearOB ? sellScore + 1 : sellScore
sellScore := obvBear ? sellScore + 1 : sellScore
sellScore := highVolatility ? sellScore + 1 : sellScore
sellScore := nearFibSell ? sellScore + 1 : sellScore
sellScore := emaRejectSell ? sellScore + 1 : sellScore
sellScore := bearStructure ? sellScore + 1 : sellScore
sellScore := liquiditySell ? sellScore + 1 : sellScore
sellScore := premium ? sellScore + 1 : sellScore
sellScore := bearDisplacement ? sellScore + 1 : sellScore

// =====================================================
// BUY SIGNAL
// =====================================================

buySignalRaw =
 buyScore >= 8 and
 sessionAllowed and
 htfBullBias
buySignal = buySignalRaw and not buySignalRaw[1]

// SELL SIGNAL
// =====================================================

sellSignalRaw =
 sellScore >= 8 and
 sessionAllowed and
 htfBearBias
sellSignal = sellSignalRaw and not sellSignalRaw[1]

confirmedBuy = buySignal
confirmedSell = sellSignal
// =====================================================
// SL / TP
// =====================================================
// ENTRY PRICE FROM SIGNAL CANDLE

// ========================================
// SMART MONEY ENTRY
// ========================================

// LAST BEARISH CANDLE BEFORE BUY

lastBearHigh =
 close[1] < open[1]
 ? high[1]
 : high[2]

lastBearLow =
 close[1] < open[1]
 ? low[1]
 : low[2]

// LAST BULLISH CANDLE BEFORE SELL

lastBullHigh =
 close[1] > open[1]
 ? high[1]
 : high[2]

lastBullLow =
 close[1] > open[1]
 ? low[1]
 : low[2]

// MIDPOINT ENTRIES

buyEntry =
 (lastBearHigh + lastBearLow) / 2

sellEntry =
 (lastBullHigh + lastBullLow) / 2

// FIXED RR

slPips = 10.0
tpPips = 30.0

// BUY

buySL = buyEntry - slPips
buyTP = buyEntry + tpPips

// SELL

sellSL = sellEntry + slPips
sellTP = sellEntry - tpPips

// SIGNAL REASONS

buyReasons = ""
sellReasons = ""

if emaBull
    buyReasons += "✓ EMA Bull\n"

if bullSweep
    buyReasons += "✓ Liquidity Sweep\n"

if bullDisplacement
    buyReasons += "✓ Bullish Displacement\n"

if htfBullFVG
    buyReasons += "✓ HTF FVG\n"

if discountZone
    buyReasons += "✓ Discount Zone\n"

if bullOB
    buyReasons += "✓ Bullish OB\n"

if emaBear
    sellReasons += "✓ EMA Bear\n"

if bearSweep
    sellReasons += "✓ Liquidity Sweep\n"

if bearDisplacement
    sellReasons += "✓ Bearish Displacement\n"

if htfBearFVG
    sellReasons += "✓ HTF FVG\n"

if premiumZone
    sellReasons += "✓ Premium Zone\n"

if bearOB
    sellReasons += "✓ Bearish OB\n"

// =====================================================
// SIGNALS
// =====================================================

// 15M SIGNALS

buy15m = timeframe.period == "15" and buySignal

sell15m = timeframe.period == "15" and sellSignal

// 1H SIGNALS

buy1h = timeframe.period == "60" and buySignal

sell1h = timeframe.period == "60" and sellSignal

plotshape(series=buySignal, title="BUY", location=location.belowbar, color=color.lime, style=shape.labelup, text="BUY")

plotshape(series=sellSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// =====================================================
// TP / SL VISUALS
// =====================================================
// BUY VISUALS

if buySignal

    line.new(
     bar_index,
     buyEntry,
     bar_index + 15,
     buyEntry,
     color=color.blue,
     width=3
     )

    line.new(
     bar_index,
     buySL,
     bar_index + 15,
     buySL,
     color=color.red,
     width=4
     )

    line.new(
     bar_index,
     buyTP,
     bar_index + 15,
     buyTP,
     color=color.lime,
     width=4
     )

// SELL VISUALS

if sellSignal

    line.new(
     bar_index,
     sellEntry,
     bar_index + 15,
     sellEntry,
     color=color.blue,
     width=3
     )

    line.new(
     bar_index,
     sellSL,
     bar_index + 15,
     sellSL,
     color=color.red,
     width=4
     )

    line.new(
     bar_index,
     sellTP,
     bar_index + 15,
     sellTP,
     color=color.lime,
     width=4
     )
// =====================================================
// ALERTS
// =====================================================

if confirmedBuy
    alert( "🟢 BUY LIMIT XAUUSD\n\n" + "Entry: " + str.tostring(buyEntry) + "\n" + "SL: " + str.tostring(buySL) + "\n" + "TP: " + str.tostring(buyTP) + "\n\n" + "Triggered By:\n" + buyReasons, alert.freq_once_per_bar)

if confirmedSell
    alert( "🔻 SELL LIMIT XAUUSD\n\n" + "Entry: " + str.tostring(sellEntry) + "\n" + "SL: " + str.tostring(sellSL) + "\n" + "TP: " + str.tostring(sellTP) + "\n\n" + "Triggered By:\n" + sellReasons, alert.freq_once_per_bar)

if buy15m
    alert("⚡ 15M BUY LIMIT XAUUSD", alert.freq_once_per_bar)

if sell15m
    alert("⚡ 15M SELL LIMIT XAUUSD", alert.freq_once_per_bar)

if buy1h
    alert("🔥 1H BUY LIMIT XAUUSD", alert.freq_once_per_bar)

if sell1h
    alert("🔥 1H SELL LIMIT XAUUSD", alert.freq_once_per_bar)

if buy1h
    alert("9050936115413,buy,XAUUSD,risk=0.03,sl=100,tp=300", alert.freq_once_per_bar)

if sell1h
    alert("9050936115413,sell,XAUUSD,risk=0.03,sl=100,tp=300", alert.freq_once_per_bar)
````
