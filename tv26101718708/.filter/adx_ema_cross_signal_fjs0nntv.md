# ADX + EMA Cross Signal

- url: https://www.tradingview.com/script/fjs0NnTV/
- type: indicator
- pine_id: PUB;327d0fac605747248e54446841c91c63
- version: 1.0

## Description

adx yukarida ise 20 den ve 10 ema 20 emayi kesiyorsa al

## Source Code

````pine
//@version=6
indicator("ADX + EMA Cross Signal", overlay=true)

// === INPUTS ===
adxLength   = input.int(14, title="ADX Length")
adxLevel    = input.float(20.0, title="ADX Level")

emaLength   = input.int(20, title="EMA Length")

// === MULTI-TIMEFRAME EMAs ===
ema10m = request.security(syminfo.tickerid, "10", ta.ema(close, emaLength))
ema20m = request.security(syminfo.tickerid, "20", ta.ema(close, emaLength))

// === ADX ===
[diplus, diminus, adxValue] = ta.dmi(adxLength, adxLength)

// === CONDITIONS ===
// ADX crossing above 20 OR staying above 20
adxCondition = ta.crossover(adxValue, adxLevel) or adxValue > adxLevel

// EMA Cross Conditions
bullishCross = ta.crossover(ema10m, ema20m)
bearishCross = ta.crossunder(ema20m, ema10m)

// Final Signals
buySignal  = adxCondition and bullishCross
sellSignal = adxCondition and bearishCross

// === PLOTS ===
plot(ema10m, color=color.blue, title="10-Min EMA")
plot(ema20m, color=color.orange, title="20-Min EMA")

plotshape(buySignal, 
     title="BUY", 
     location=location.belowbar, 
     color=color.green, 
     style=shape.labelup, 
     text="BUY")

plotshape(sellSignal, 
     title="SELL", 
     location=location.abovebar, 
     color=color.red, 
     style=shape.labeldown, 
     text="SELL")

// === ALERTS ===
alertcondition(buySignal, title="Buy Alert", message="ADX > 20 and 10m EMA crossed ABOVE 20m EMA")

alertcondition(sellSignal, title="Sell Alert", message="ADX < 20 and 20m EMA crossed BELOW 10m EMA")
````
