# Omotola TUX Signal Validator

- url: https://www.tradingview.com/script/gJPqjhs0-Omotola-TUX-Signal-Validator/
- type: indicator
- pine_id: PUB;09cf3f18e4d64138bff08af4795c959e
- version: 1.0

## Description

This is my refined strategy to make the signal 88% profitable on M15, 30 and 1H

## Source Code

````pine
//@version=6
indicator("TUX Signal Validator", overlay = true)

ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

plot(ema20, color=color.blue)
plot(ema50, color=color.orange)

// ADX
[diplus, diminus, adxValue] = ta.dmi(14, 14)

// Original TUX logic
crossSignal = ta.cross(close, ema20)

buySignal = crossSignal and close > close[1]
sellSignal = crossSignal and close < close[1]

// Trend filter
buyTrendOk = adxValue > 20 and ema50 > ema50[1]
sellTrendOk = adxValue > 20 and ema50 < ema50[1]

// Valid signals
validBuy = buySignal and buyTrendOk
validSell = sellSignal and sellTrendOk

plotshape(validBuy,
     title="Buy",
     location=location.belowbar,
     style=shape.labelup,
     text="BUY")

plotshape(validSell,
     title="Sell",
     location=location.abovebar,
     style=shape.labeldown,
     text="SELL")
````
