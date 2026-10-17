# Gauge Smart Signals

- url: https://www.tradingview.com/script/TQ6lfy2R-Gauge-Smart-Signals/
- type: indicator
- pine_id: PUB;3c29f407ed424a3d89241392b9fcfb34
- version: 1.0

## Description

Gauge Smart Signals is a trend-following indicator for Bitcoin that combines a Supertrend trailing stop, dual EMA filter, and RSI confirmation to generate high-probability buy and sell signals.

Features:
- Green BUY label when trend flips bullish and RSI is above 50
- Red SELL label when trend flips bearish and RSI is below 50
- Trailing stop line that turns green in uptrends and red in downtrends
- Bar coloring to show trend direction at a glance
- Built-in alerts for automated signal delivery

Best used on the 4H timeframe for BTC/USDT.

This indicator is part of the Gauge signal service. Visit gauge.io for live trade signals with entry, TP1, TP2 and stop loss levels delivered in real time.

## Source Code

````pine
//@version=6
indicator("Gauge — Smart Signals", overlay=true)

atrLen  = input.int(14,    "ATR Length",     group="Settings")
atrMult = input.float(2.0, "ATR Multiplier", step=0.1, group="Settings")
emaFast = input.int(9,     "Fast EMA",       group="Settings")
emaSlow = input.int(21,    "Slow EMA",       group="Settings")
rsiLen  = input.int(14,    "RSI Length",     group="Settings")

atr  = ta.atr(atrLen)
rsi  = ta.rsi(close, rsiLen)
emaF = ta.ema(close, emaFast)
emaS = ta.ema(close, emaSlow)

var float prevLower = na
var float prevUpper = na
var int   trend     = 0

upperBand = hl2 + atrMult * atr
lowerBand = hl2 - atrMult * atr

lowerBand2 = (lowerBand > nz(prevLower) or close[1] < nz(prevLower)) ? lowerBand : nz(prevLower)
upperBand2 = (upperBand < nz(prevUpper) or close[1] > nz(prevUpper)) ? upperBand : nz(prevUpper)

prevLower := lowerBand2
prevUpper := upperBand2

trend := close > nz(upperBand2[1]) ? 1 : close < nz(lowerBand2[1]) ? -1 : nz(trend, 1)

trail = trend == 1 ? lowerBand2 : upperBand2

buySignal  = trend == 1  and trend[1] == -1 and rsi > 50
sellSignal = trend == -1 and trend[1] == 1  and rsi < 50

bullTrend = trend == 1  and emaF > emaS
bearTrend = trend == -1 and emaF < emaS

plot(trail, "Trail Stop", color=trend == 1 ? color.new(color.lime, 20) : color.new(color.red, 20), linewidth=2)
plot(emaF,  "EMA Fast",   color=color.new(color.white, 60), linewidth=1)
plot(emaS,  "EMA Slow",   color=color.new(color.gray,  60), linewidth=1)

barcolor(bullTrend ? color.new(color.lime, 70) : bearTrend ? color.new(color.red, 70) : na)

if buySignal
    label.new(bar_index, low - atr * 0.5, "▲ BUY", style=label.style_label_up, color=color.new(#00c853, 0), textcolor=color.white, size=size.normal)

if sellSignal
    label.new(bar_index, high + atr * 0.5, "▼ SELL", style=label.style_label_down, color=color.new(#ff1744, 0), textcolor=color.white, size=size.normal)

alertcondition(buySignal,  "GAUGE BUY",  '{"direction":"LONG","entry":{{close}},"pair":"BTCUSDT"}')
alertcondition(sellSignal, "GAUGE SELL", '{"direction":"SHORT","entry":{{close}},"pair":"BTCUSDT"}')
````
