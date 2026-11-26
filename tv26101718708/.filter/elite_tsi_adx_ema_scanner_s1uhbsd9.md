# Elite TSI + ADX + EMA Scanner

- url: https://www.tradingview.com/script/S1uHBSd9-Elite-TSI-ADX-EMA-Scanner/
- type: indicator
- pine_id: PUB;79a8588bc41742dc96db36f9b8e0a450
- version: 1.0

## Description

This indicator is designed to identify high-probability trend continuation setups by combining momentum, trend strength, moving average alignment, and higher timeframe confirmation.

The script filters out low-quality signals by requiring multiple conditions to align before generating a buy or sell signal.

## Source Code

````pine
//@version=6
indicator("Elite TSI + ADX + EMA Scanner", overlay=true)

// Inputs
tsiShort = input.int(13, "TSI Short")
tsiLong  = input.int(25, "TSI Long")
adxLen   = input.int(14, "ADX Length")
adxMin   = input.float(24, "Minimum ADX")

emaFastLen  = input.int(8, "Fast EMA")
emaSlowLen  = input.int(21, "Slow EMA")
emaTrendLen = input.int(50, "Trend EMA")

higherTF = input.timeframe("240", "Higher Timeframe Trend")
volLen   = input.int(20, "Volume Average Length")
atrLen   = input.int(14, "ATR Length")
atrMult  = input.float(1.5, "ATR Stop Multiplier")
riskR    = input.float(2.0, "Target R Multiple")

// Current timeframe calculations
tsi = ta.tsi(close, tsiShort, tsiLong)
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)

emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
emaTrend = ta.ema(close, emaTrendLen)

volAvg = ta.sma(volume, volLen)
atr = ta.atr(atrLen)

// Higher timeframe trend
htfClose = request.security(syminfo.tickerid, higherTF, close)
htfEma50 = request.security(syminfo.tickerid, higherTF, ta.ema(close, emaTrendLen))

htfBull = htfClose > htfEma50
htfBear = htfClose < htfEma50

// Filters
tsiBull = tsi > 0
tsiBear = tsi < 0

adxStrong = adx > adxMin

emaBull = emaFast > emaSlow and close > emaTrend
emaBear = emaFast < emaSlow and close < emaTrend

volConfirm = volume > volAvg

// Final signals
bullSignal = tsiBull and adxStrong and emaBull and htfBull and volConfirm
bearSignal = tsiBear and adxStrong and emaBear and htfBear and volConfirm

// Fresh signal only when condition first turns true
bullEntry = bullSignal and not bullSignal[1]
bearEntry = bearSignal and not bearSignal[1]

// Stop and target levels
bullStop = close - atr * atrMult
bullTarget = close + (close - bullStop) * riskR

bearStop = close + atr * atrMult
bearTarget = close - (bearStop - close) * riskR

// Plot EMAs
plot(emaFast, title="EMA 8", color=color.blue)
plot(emaSlow, title="EMA 21", color=color.orange)
plot(emaTrend, title="EMA 50", color=color.white)

// Buy/Sell labels
plotshape(bullEntry, title="ELITE BUY", location=location.belowbar, style=shape.labelup, color=color.green, text="BUY")
plotshape(bearEntry, title="ELITE SELL", location=location.abovebar, style=shape.labeldown, color=color.red, text="SELL")

// Stop/target plots
plot(bullEntry ? bullStop : na, title="Bull Stop", color=color.red, style=plot.style_linebr)
plot(bullEntry ? bullTarget : na, title="Bull Target", color=color.green, style=plot.style_linebr)

plot(bearEntry ? bearStop : na, title="Bear Stop", color=color.red, style=plot.style_linebr)
plot(bearEntry ? bearTarget : na, title="Bear Target", color=color.green, style=plot.style_linebr)

// Alerts
alertcondition(bullEntry, title="Elite Bullish Signal", message="Elite BUY: TSI bullish, ADX strong, EMA aligned, above 4H trend, volume confirmed.")
alertcondition(bearEntry, title="Elite Bearish Signal", message="Elite SELL: TSI bearish, ADX strong, EMA aligned, below 4H trend, volume confirmed.")
````
