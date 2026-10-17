# ADX + EMA Cross Signal

- url: https://www.tradingview.com/script/M1Srmrwo/
- type: indicator
- pine_id: PUB;0879d92a50c64bdab48d2e46a85b28c6
- version: 2.0

## Description

adx 20 alti 10 ema 20 emayi yukari keserse al
adx 50 ustu 20 ema 10 emayi asagi keserse sat

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
ema5 = ta.ema(close, 5)
ema8 = ta.ema(close, 8)

buySignal = ta.crossover(ema5, ema8) and (rsi < 40 or adx < 20)
sellSignal = ta.crossunder(ema5, ema8) and (rsi > 60 or adx > 30)

plot(ema5, color=color.green, linewidth=2)
plot(ema8, color=color.orange, linewidth=2)

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
