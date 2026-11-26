# Sniper Bot PRO 

- url: https://www.tradingview.com/script/ZXuUjuMM-Sniper-Bot-PRO/
- type: indicator
- pine_id: PUB;834e90645f594049abc483b8f9c6df6a
- version: 1.0

## Description

A good sniper bot that cleans up mistakes. Sends alerts, triggers buy, sell, and counter buys. you can edit to your liking but these settings are pretty valid trying to make a decision.

## Source Code

````pine
//@version=6
indicator("Sniper Bot PRO (Clean View)", overlay=true)

// === INPUTS ===
modeScalp = input.bool(true, "Enable Scalp (15m)")
modeSwing = input.bool(true, "Enable Swing")
modeCounter = input.bool(false, "Enable Counter Trend")

emaFastLen = input.int(20, "Fast EMA")
emaSlowLen = input.int(50, "Slow EMA")

htfTF = input.timeframe("60", "HTF Bias (1H)")
swingTF = input.timeframe("240", "Swing TF (4H)")

rr = input.float(2.0, "Risk Reward", step=0.1)
atrMult = input.float(1.5, "ATR Multiplier")

// === EMAs ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// === HTF BIAS ===
htfClose = request.security(syminfo.tickerid, htfTF, close)
htfEMA = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50))

bullBias = htfClose > htfEMA
bearBias = htfClose < htfEMA

// === SWING BIAS ===
swingClose = request.security(syminfo.tickerid, swingTF, close)
swingEMA = request.security(syminfo.tickerid, swingTF, ta.ema(close, 50))

swingBull = swingClose > swingEMA
swingBear = swingClose < swingEMA

// === STRUCTURE ===
highBreak = ta.highest(high, 5)[1]
lowBreak = ta.lowest(low, 5)[1]

bosLong = close > highBreak
bosShort = close < lowBreak

// === OVEREXTENSION ===
atr = ta.atr(14)
overbought = close > emaFast + atr * 2
oversold = close < emaFast - atr * 2

// === CONDITIONS ===
scalpLong = modeScalp and bosLong and emaFast > emaSlow and bullBias
scalpShort = modeScalp and bosShort and emaFast < emaSlow and bearBias

swingLong = modeSwing and bosLong and swingBull
swingShort = modeSwing and bosShort and swingBear

counterLong = modeCounter and oversold and bosLong
counterShort = modeCounter and overbought and bosShort

longSignal = scalpLong or swingLong or counterLong
shortSignal = scalpShort or swingShort or counterShort

// === REFERENCE SL/TP ===
longSL = close - atr * atrMult
longTP = close + (close - longSL) * rr
shortSL = close + atr * atrMult
shortTP = close - (shortSL - close) * rr

var float activeLongSL = float(na)
var float activeLongTP = float(na)
var float activeShortSL = float(na)
var float activeShortTP = float(na)

if longSignal
    activeLongSL:= longSL
    activeLongTP := longTP
    activeShortSL := na
    activeShortTP := na

if shortSignal
    activeShortSL := shortSL
    activeShortTP := shortTP
    activeLongSL := na
    activeLongTP := na

// === VISUALS ===
plot(emaFast, color=color.green, title="Fast EMA")
plot(emaSlow, color=color.red, title="Slow EMA")

bgcolor(swingLong ? color.new(color.green, 90) : na, title="Swing Long Zone")
bgcolor(swingShort ? color.new(color.red, 90) : na, title="Swing Short Zone")

plotshape(scalpLong, title="Scalp Buy", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.tiny)
plotshape(scalpShort, title="Scalp Sell", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.tiny)

plotshape(counterLong, title="Counter Buy", location=location.belowbar, color=color.yellow, style=shape.circle, size=size.tiny)
plotshape(counterShort, title="Counter Sell", location=location.abovebar, color=color.yellow, style=shape.circle, size=size.tiny)

plotshape(swingLong, title="Swing Buy", location=location.belowbar, color=color.lime, style=shape.labelup, size=size.tiny, text="L")
plotshape(swingShort, title="Swing Sell", location=location.abovebar, color=color.orange, style=shape.labeldown, size=size.tiny, text="S")

plot(activeLongSL, title="Long SL", color=color.new(color.red, 20), style=plot.style_linebr)
plot(activeLongTP, title="Long TP", color=color.new(color.green, 20), style=plot.style_linebr)
plot(activeShortSL, title="Short SL", color=color.new(color.red, 20), style=plot.style_linebr)
plot(activeShortTP, title="Short TP", color=color.new(color.green, 20), style=plot.style_linebr)

// === ALERTS ===
alertcondition(scalpLong, "Scalp Long", "SCALP LONG")
alertcondition(scalpShort, "Scalp Short", "SCALP SHORT")
alertcondition(swingLong, "Swing Long", "SWING LONG")
alertcondition(swingShort, "Swing Short", "SWING SHORT")
alertcondition(counterLong, "Counter Long", "COUNTER LONG")
alertcondition(counterShort, "Counter Short", "COUNTER SHORT")
alertcondition(longSignal, "Any Long", "LONG SIGNAL")
alertcondition(shortSignal, "Any Short", "SHORT SIGNAL")
````
