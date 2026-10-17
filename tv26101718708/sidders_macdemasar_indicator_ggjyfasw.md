# [Sidders] MACDEMASAR Indicator

- url: https://www.tradingview.com/script/GGjYFAsW-Sidders-MACDEMASAR-Indicator/
- type: indicator
- pine_id: PUB;ZpbCCjgqBV322xGNKRJhYu6nabG5FkFu
- version: 1.0

## Description

Came across a cool idea for a strategy that couldn't find in the indicator database, so decided to code it up myself for your pleasure.

Indicators consists of 3 indicators: EMA(200) to determine the overall trend, and the MACD & Parabolic SAR to determine entries (and exits).

Long entry contains 4 conditions and is generated when price is above the 200EMA (1), the MACD crosses above the signal line (2), while they are both below 0 line (3) and when the parabolic SAR is below the closing price of the bar (4).

Short entry is build up the same but in reverse: price is below the 200EMA(1), signal line crosses below the MACD line (2), while they are both above the 0 line (3) and when the parabolic SAR is above the closing price of the bar (4).

Place the stoploss on the parabolic SAR dot below/above the candle that created the signal. Profit target 1:1 risk:reward ratio, but can ofcourse be changed according to your risk apetite. Might add automatically drawn SL/TPs in a later update.

Concept behind the strategy should work on all timeframes, but will require proper backtesting. I think with additional filters the strategy can also be way more finetuned and profitable, personally haven't had the time yet to dive into that.

Have also added alerts for your convenience. 

Enjoy!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sidders

//@version=4
study("[Sidders] MACDEMASAR Indicator", overlay=true)

fast_length = input(title="Fast Length", type=input.integer, defval=12,group="MACD Settings")
slow_length = input(title="Slow Length", type=input.integer, defval=26,group="MACD Settings")
src = input(title="Source", type=input.source, defval=close,group="MACD Settings")
signal_length = input(title="Signal Smoothing", type=input.integer, minval = 1, maxval = 50, defval = 9,group="MACD Settings")
sma_source = input(title="Simple MA (Oscillator)", type=input.bool, defval=false,group="MACD Settings")
sma_signal = input(title="Simple MA (Signal Line)", type=input.bool, defval=false,group="MACD Settings")
// Calculating
fast_ma = sma_source ? sma(src, fast_length) : ema(src, fast_length)
slow_ma = sma_source ? sma(src, slow_length) : ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal ? sma(macd, signal_length) : ema(macd, signal_length)
hist = macd - signal

//EMA
emaSRC = input(type=input.source, title="EMA Source", group="EMA Settings", defval=close)
emaLength = input(type=input.integer, title="EMA Length", group="EMA Settings", defval=200)
ema1 = ema(emaSRC,emaLength)

//PARABOLIC SAR
start_sar = input(0.02, title="SAR start value", type=input.float,group="SAR Settings")
increment_sar = input(0.02, title="SAR increment", type=input.float,group="SAR Settings")
maximum_sar = input(0.2, "SAR Max. Value", type=input.float,group="SAR Settings")
out_sar = sar(start_sar, increment_sar, maximum_sar)
plot(out_sar, "ParabolicSAR", style=plot.style_cross, color=color.yellow)

//Long
longEntry = close > ema1 and crossover(macd,signal) and out_sar < close and signal < 0 and macd < 0
longCol = longEntry ? color.green : na
bgcolor(longCol)
plotshape(longEntry, style=shape.triangleup, size = size.auto, color = color.green, location=location.belowbar, text = "Long", title="Long entry")

//Short
shortEntry = close < ema1 and crossunder(macd,signal) and out_sar > close and signal > 0 and macd > 0
shortCol = shortEntry ? color.red : na
bgcolor(shortCol)
plotshape(shortEntry, style=shape.triangledown, size = size.auto, color = color.red, location=location.abovebar, text = "Short", title="Short entry")

plot(ema1, color=color.red, linewidth=2, title="EMA")

//ALERTS
alertcondition(longEntry, title="Long entry", message="Long entry triggered")
alertcondition(shortEntry, title="Short entry", message="Short entry triggered")
````
