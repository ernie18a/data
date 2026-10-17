# Europon Reversal FX Rush Ver2 Indicator

- url: https://www.tradingview.com/script/zbETDwj5/
- type: indicator
- pine_id: PUB;727b5c507ad84c71805f90f0b3d36016
- version: 1.0

## Description

Europon Reversal FX Rush Ver2 Indicator is an RSI-based reversal signal indicator designed primarily for EURGBP on the 1-hour chart.

The indicator uses a short-period RSI to identify potential reversal opportunities. It references the RSI value from two bars ago to reduce signal fluctuations caused by the latest developing candles.

A buy signal appears when the shifted RSI falls below the lower threshold. A sell signal appears when the shifted RSI rises above the upper threshold.

The indicator also displays optional averaging-entry candidates. Long averaging candidates require progressively lower RSI values and a bullish previous candle. Short averaging candidates require progressively higher RSI values and a bearish previous candle.

Default settings:

Recommended market: EURGBP

Recommended timeframe: H1

RSI Period: 3

RSI Signal Shift: 2

RSI High Level: 60

RSI Low Level: 40

Trading Hours: 01:00 to 09:00 server time

Long Nanpin: Enabled

Short Nanpin: Enabled

Maximum intended positions: 3

The averaging markers indicate possible additional-entry conditions only. They do not track actual open positions in the indicator version.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright MasayanFX
//@version=6
indicator("Europon Reversal FX Rush Ver2 Indicator", overlay=true)
// Inputs
rsiPeriod = input.int(3, "RSI Period", minval=1)
rsiShift = input.int(2, "RSI Signal Shift", minval=0)
rsiHigh = input.float(60.0, "RSI High Level", minval=50.0, maxval=100.0)
rsiLow = input.float(40.0, "RSI Low Level", minval=0.0, maxval=50.0)
nanpin = input.bool(true, "Enable Nanpin")
shortNanpin = input.bool(true, "Enable Short Nanpin")
useTradeHourFilter = input.bool(true, "Use Trade Hour Filter")
serverTimeZone = input.string("Europe/Nicosia", "MT4/MT5 Server Time Zone", options=["Europe/Nicosia", "Etc/GMT-2", "Etc/GMT-3", "Asia/Tokyo", "UTC"])
startHour = input.int(1, "Start Hour", minval=0, maxval=23)
endHour = input.int(9, "End Hour", minval=0, maxval=23)
showBackground = input.bool(true, "Show Background")
showNanpinSignals = input.bool(true, "Show Nanpin Signals")
showText = input.bool(false, "Show BUY/SELL Text")
// Colors
buyColor = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)
nanpinBuyColor = color.rgb(0, 180, 255)
nanpinSellColor = color.rgb(255, 170, 50)
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
// Signal Logic
buySignal = tradeAllowed and rsiValue < rsiLow
sellSignal = tradeAllowed and rsiValue > rsiHigh
longNanpin2 = tradeAllowed and nanpin and previousBull and rsiValue < longNanpinLevel2
longNanpin3 = tradeAllowed and nanpin and previousBull and rsiValue < longNanpinLevel3
shortNanpin2 = tradeAllowed and nanpin and shortNanpin and previousBear and rsiValue > shortNanpinLevel2
shortNanpin3 = tradeAllowed and nanpin and shortNanpin and previousBear and rsiValue > shortNanpinLevel3
longNanpinSignal = longNanpin2 or longNanpin3
shortNanpinSignal = shortNanpin2 or shortNanpin3
// Background
bgColor = buySignal ? color.new(color.rgb(0, 120, 255), 94) : sellSignal ? color.new(color.rgb(255, 70, 90), 94) : na
bgcolor(showBackground ? bgColor : na)
// Primary Signals
plotshape(buySignal and not showText, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small)
plotshape(sellSignal and not showText, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small)
plotshape(buySignal and showText, title="Buy Signal Text", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small, text="BUY")
plotshape(sellSignal and showText, title="Sell Signal Text", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small, text="SELL")
// Nanpin Candidates
plotshape(showNanpinSignals and longNanpinSignal, title="Long Nanpin Candidate", style=shape.circle, location=location.belowbar, color=nanpinBuyColor, size=size.tiny)
plotshape(showNanpinSignals and shortNanpinSignal, title="Short Nanpin Candidate", style=shape.circle, location=location.abovebar, color=nanpinSellColor, size=size.tiny)
// Data Window
plot(rsiValue, "RSI Signal Value", display=display.data_window)
plot(longNanpinLevel2, "Long Nanpin Level 2", display=display.data_window)
plot(longNanpinLevel3, "Long Nanpin Level 3", display=display.data_window)
plot(shortNanpinLevel2, "Short Nanpin Level 2", display=display.data_window)
plot(shortNanpinLevel3, "Short Nanpin Level 3", display=display.data_window)
// Alerts
alertcondition(buySignal, title="Buy Alert", message="Europon Reversal FX Rush Ver2 Buy Signal")
alertcondition(sellSignal, title="Sell Alert", message="Europon Reversal FX Rush Ver2 Sell Signal")
alertcondition(longNanpinSignal, title="Long Nanpin Alert", message="Europon Reversal FX Rush Ver2 Long Nanpin Candidate")
alertcondition(shortNanpinSignal, title="Short Nanpin Alert", message="Europon Reversal FX Rush Ver2 Short Nanpin Candidate")
````
