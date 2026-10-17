# Europon Reversal FX Rush Ver2 Strategy

- url: https://www.tradingview.com/script/8LSSyeLc/
- type: strategy
- pine_id: PUB;ef41a85dfeda4cc987c11512ed5f7111
- version: 1.0

## Description

Europon Reversal FX Rush Ver2 Strategy is an RSI reversal and averaging-entry strategy designed primarily for EURGBP on the 1-hour chart.

The strategy uses a 3-period RSI value from two bars ago. A long position is opened when the shifted RSI falls below 40. A short position is opened when the shifted RSI rises above 60.

When averaging entries are enabled, the strategy can add positions as RSI moves further into the reversal zone. Long additions require progressively lower RSI values and a bullish previous candle. Short additions require progressively higher RSI values and a bearish previous candle.

The strategy supports up to three entries in the same direction. An opposite signal closes the current position and can initiate a position in the opposite direction.

Default settings:

Recommended market: EURGBP

Recommended timeframe: H1

RSI Period: 3

RSI Signal Shift: 2

RSI High Level: 60

RSI Low Level: 40

Trading Hours: 01:00 to 09:00 server time

Maximum Positions: 3

Long Nanpin: Enabled

Short Nanpin: Enabled

Stop Loss Request: 4.0

Take Profit Request: 4.0

Price Unit: 0.01

Because TradingView’s broker emulator differs from MT4/MT5 execution, strategy results may not match EA backtests or live broker execution. Averaging-entry strategies can significantly increase risk during strong directional markets.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright MasayanFX
//@version=6
strategy("Europon Reversal FX Rush Ver2 Strategy", overlay=true, fill_orders_on_standard_ohlc=true, pyramiding=3)
// Inputs
rsiPeriod = input.int(3, "RSI Period", minval=1)
rsiShift = input.int(2, "RSI Signal Shift", minval=0)
rsiHigh = input.float(60.0, "RSI High Level", minval=50.0, maxval=100.0)
rsiLow = input.float(40.0, "RSI Low Level", minval=0.0, maxval=50.0)
nanpin = input.bool(true, "Enable Nanpin")
shortNanpin = input.bool(true, "Enable Short Nanpin")
maxPositions = input.int(3, "Max Positions", minval=1, maxval=3)
useTradeHourFilter = input.bool(true, "Use Trade Hour Filter")
serverTimeZone = input.string("Europe/Nicosia", "MT4/MT5 Server Time Zone", options=["Europe/Nicosia", "Etc/GMT-2", "Etc/GMT-3", "Asia/Tokyo", "UTC"])
startHour = input.int(1, "Start Hour", minval=0, maxval=23)
endHour = input.int(9, "End Hour", minval=0, maxval=23)
priceUnit = input.float(0.01, "Price Unit", minval=0.00001, step=0.001)
stopLossRequest = input.float(4.0, "Stop Loss Request", minval=0.1)
takeProfitRequest = input.float(4.0, "Take Profit Request", minval=0.1)
showBackground = input.bool(true, "Show Background")
showSignals = input.bool(false, "Show Additional Signals")
// Colors
buyColor = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)
// Calculations
rsiRaw = ta.rsi(close, rsiPeriod)
rsiValue = rsiRaw[rsiShift]
serverHour = hour(time, serverTimeZone)
isTradeHour = not useTradeHourFilter or (startHour <= endHour ? serverHour >= startHour and serverHour <= endHour : serverHour >= startHour or serverHour <= endHour)
isH1 = timeframe.isminutes and timeframe.multiplier == 60
tradeAllowed = isH1 and isTradeHour
longNanpinLevel2 = rsiLow - rsiLow / 4.0
longNanpinLevel3 = rsiLow - rsiLow / 2.0
shortNanpinLevel2 = rsiHigh + (100.0 - rsiHigh) / 4.0
shortNanpinLevel3 = rsiHigh + (100.0 - rsiHigh) / 2.0
previousBull = open[1] < close[1]
previousBear = open[1] > close[1]
// Entry Logic
buySignal = tradeAllowed and rsiValue < rsiLow
sellSignal = tradeAllowed and rsiValue > rsiHigh
longNanpin2 = tradeAllowed and nanpin and previousBull and rsiValue < longNanpinLevel2
longNanpin3 = tradeAllowed and nanpin and previousBull and rsiValue < longNanpinLevel3
shortNanpin2 = tradeAllowed and nanpin and shortNanpin and previousBear and rsiValue > shortNanpinLevel2
shortNanpin3 = tradeAllowed and nanpin and shortNanpin and previousBear and rsiValue > shortNanpinLevel3
flat = strategy.position_size == 0
inLong = strategy.position_size > 0
inShort = strategy.position_size < 0
positionCount = strategy.opentrades
// Orders
if buySignal and inShort
    strategy.close("Short")
    strategy.entry("Long", strategy.long)
else if buySignal and flat
    strategy.entry("Long", strategy.long)
if sellSignal and inLong
    strategy.close("Long")
    strategy.entry("Short", strategy.short)
else if sellSignal and flat
    strategy.entry("Short", strategy.short)
if inLong and positionCount < maxPositions
    if positionCount == 1 and longNanpin2
        strategy.entry("Long", strategy.long)
    else if positionCount == 2 and longNanpin3
        strategy.entry("Long", strategy.long)
if inShort and shortNanpin and positionCount < maxPositions
    if positionCount == 1 and shortNanpin2
        strategy.entry("Short", strategy.short)
    else if positionCount == 2 and shortNanpin3
        strategy.entry("Short", strategy.short)
// Exit Logic
stopDistance = priceUnit * stopLossRequest
takeDistance = priceUnit * takeProfitRequest
if inLong
    strategy.exit("Long Exit", from_entry="Long", stop=strategy.position_avg_price - stopDistance, limit=strategy.position_avg_price + takeDistance)
if inShort
    strategy.exit("Short Exit", from_entry="Short", stop=strategy.position_avg_price + stopDistance, limit=strategy.position_avg_price - takeDistance)
// Background
bgColor = buySignal ? color.new(color.rgb(0, 120, 255), 94) : sellSignal ? color.new(color.rgb(255, 70, 90), 94) : na
bgcolor(showBackground ? bgColor : na)
// Optional Signals
plotshape(showSignals and buySignal, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.tiny)
plotshape(showSignals and sellSignal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.tiny)
// Data Window
plot(rsiValue, "RSI Signal Value", display=display.data_window)
plot(positionCount, "Open Position Count", display=display.data_window)
````
