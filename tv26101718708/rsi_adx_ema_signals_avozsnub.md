# RSI + ADX + EMA Signals

- url: https://www.tradingview.com/script/avOZsnUb-RSI-ADX-EMA-Signals/
- type: indicator
- pine_id: PUB;d9491cf5cc1149e99d023d5457dda787
- version: 1.0

## Description

This indicator follows 7ema and 21 ema crosses both sell and buy signal with controlling RSI and ADX strength gives trade signals

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mustafaseker75

//@version=6
indicator("RSI + ADX + EMA Signals", overlay=true)

rsiLength = input.int(14, "RSI Length")
adxLength = input.int(14, "ADX Length")

rsi = ta.rsi(close, rsiLength)

// DMI / ADX
[diplus, diminus, adx] = ta.dmi(adxLength, adxLength)

// EMAs
ema7 = ta.ema(close, 7)
ema21 = ta.ema(close, 21)

buySignal = ta.crossover(ema7, ema21) and (rsi < 60 or adx < 30)
sellSignal = ta.crossunder(ema7, ema21) and (rsi > 60 or adx <30 )


plot(ema7, color=color.green, linewidth=2)
plot(ema21, color=color.orange, linewidth=2)

plotshape(buySignal,
     title="BUY",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.large,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.large,
     text="SELL")



alertcondition(buySignal, "BUY Alert", "BUY Signal")
alertcondition(sellSignal, "SELL Alert", "SELL Signal")
````
