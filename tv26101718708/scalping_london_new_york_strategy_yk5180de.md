# Scalping London New York Strategy

- url: https://www.tradingview.com/script/yK5180DE/
- type: strategy
- pine_id: PUB;9983f69c46c142a6b69bfcf6827f9837
- version: 1.0

## Description

Scalping London New York SMA Nanpin Strategy is a short-term forex backtesting strategy based on moving average trend direction, candle direction, session filtering, and averaging-down entries.

The strategy uses a fast and slow Simple Moving Average to determine the market direction. A long entry is generated when the previous confirmed candle is bullish and the fast SMA is above the slow SMA. A short entry is generated when the previous confirmed candle is bearish and the fast SMA is below the slow SMA.

The strategy includes a time filter, optional long-only mode, optional short-side averaging, fixed stop loss and take profit distances, and up to 10 pyramiding entries to approximate the original averaging-down logic. On a 5-minute chart, the moving average periods are automatically adjusted to approximate the original lower-timeframe settings.

Default settings:
Fast SMA: 60
Slow SMA: 280
Max Positions: 10
Stop Loss Request: 4.0
Take Profit Request: 5.0
Nanpin Step Request: 0.2
Time Filter: Enabled
Start Hour: 7
End Hour: 17
Only Long: Disabled
Short Nanpin: Enabled
Pyramiding: 10
Recommended timeframes: M1 and M5
Recommended market: Forex, especially JPY pairs such as USDJPY

The strategy closes an opposite position when an opposite signal appears. If a position is already open and price moves against the latest entry by the configured nanpin step, the strategy can add another entry up to the maximum position limit.

Because TradingView’s broker emulator differs from MT4/MT5 execution, backtest results may not match EA results or live broker execution exactly. Averaging-down strategies can increase risk significantly, especially during strong one-directional trends.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasayanFX

//@version=6
strategy("Scalping London New York Strategy", overlay=true, fill_orders_on_standard_ohlc=true, pyramiding=10)

// Inputs
maPeriodFastInput = input.int(60, "Fast SMA Period", minval=1)
maPeriodSlowInput = input.int(280, "Slow SMA Period", minval=1)
maxPositions = input.int(10, "Max Positions", minval=1, maxval=10)
stopLossRequest = input.float(4.0, "Stop Loss Request", minval=0.1)
takeProfitRequest = input.float(5.0, "Take Profit Request", minval=0.1)
nanpinStepRequest = input.float(0.2, "Nanpin Step Request", minval=0.01)
onlyLong = input.bool(false, "Only Long")
shortNanpin = input.bool(true, "Short Nanpin")
useTimeFilter = input.bool(true, "Use Time Filter")
startHour = input.int(7, "Start Hour", minval=0, maxval=23)
endHour = input.int(17, "End Hour", minval=0, maxval=23)
showBackground = input.bool(true, "Show Trend Background")
showSignals = input.bool(false, "Show Additional Signals")

// Colors
longMAColor = color.rgb(255, 190, 60)
shortMAColor = color.rgb(0, 220, 255)
buyColor = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)
upBgColor = color.new(color.rgb(0, 120, 255), 94)
downBgColor = color.new(color.rgb(255, 70, 90), 94)

// Indicator Calculations
isM5 = timeframe.isminutes and timeframe.multiplier == 5
fastPeriod = isM5 ? math.max(1, int(maPeriodFastInput / 5)) : maPeriodFastInput
slowPeriod = isM5 ? math.max(1, int(maPeriodSlowInput / 5)) : maPeriodSlowInput

fastMA = ta.sma(close, fastPeriod)
slowMA = ta.sma(close, slowPeriod)

currentHour = hour(time)
timeAllowed = not useTimeFilter ? true : startHour <= endHour ? currentHour >= startHour and currentHour <= endHour : currentHour >= startHour or currentHour <= endHour

isJpy = str.contains(syminfo.ticker, "JPY")
pips = isJpy ? 1.0 : 0.01

// Entry Logic
longSignal = barstate.isconfirmed and timeAllowed and open[1] < close[1] and fastMA[1] > slowMA[1]
shortSignal = barstate.isconfirmed and timeAllowed and open[1] > close[1] and fastMA[1] < slowMA[1] and not onlyLong

var float lastLongEntryPrice = na
var float lastShortEntryPrice = na
var int longEntryCount = 0
var int shortEntryCount = 0

flat = strategy.position_size == 0
inLong = strategy.position_size > 0
inShort = strategy.position_size < 0

if flat
    longEntryCount := 0
    shortEntryCount := 0
    lastLongEntryPrice := na
    lastShortEntryPrice := na

// Exit Logic
if longSignal and inShort
    strategy.close("Short")
    shortEntryCount := 0
    lastShortEntryPrice := na

if shortSignal and inLong
    strategy.close("Long")
    longEntryCount := 0
    lastLongEntryPrice := na

// Orders
if longSignal and flat
    strategy.entry("Long", strategy.long)
    lastLongEntryPrice := close
    longEntryCount := 1

if shortSignal and flat
    strategy.entry("Short", strategy.short)
    lastShortEntryPrice := close
    shortEntryCount := 1

longNanpin = inLong and longEntryCount < maxPositions and not na(lastLongEntryPrice) and close <= lastLongEntryPrice - pips * nanpinStepRequest
shortNanpinCondition = inShort and shortEntryCount < maxPositions and shortNanpin and not onlyLong and not na(lastShortEntryPrice) and close >= lastShortEntryPrice + pips * nanpinStepRequest

if longNanpin
    strategy.entry("Long", strategy.long)
    lastLongEntryPrice := close
    longEntryCount += 1

if shortNanpinCondition
    strategy.entry("Short", strategy.short)
    lastShortEntryPrice := close
    shortEntryCount += 1

longStop = strategy.position_avg_price - pips * stopLossRequest
longLimit = strategy.position_avg_price + pips * takeProfitRequest
shortStop = strategy.position_avg_price + pips * stopLossRequest
shortLimit = strategy.position_avg_price - pips * takeProfitRequest

if inLong
    strategy.exit("Long Exit", from_entry="Long", stop=longStop, limit=longLimit)

if inShort
    strategy.exit("Short Exit", from_entry="Short", stop=shortStop, limit=shortLimit)

// Plot Lines
plot(fastMA, "Fast SMA", color=shortMAColor, linewidth=2)
plot(slowMA, "Slow SMA", color=longMAColor, linewidth=2)

// Background
trendUp = fastMA > slowMA
trendDown = fastMA < slowMA
bgcolor(showBackground ? trendUp ? upBgColor : trendDown ? downBgColor : na : na)

// Optional Signals
plotshape(showSignals and longSignal, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.tiny)
plotshape(showSignals and shortSignal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.tiny)
````
