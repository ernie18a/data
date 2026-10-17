# Envelope with Offset

- url: https://www.tradingview.com/script/5HYDObAc-Envelope-with-Offset/
- type: indicator
- pine_id: PUB;c842822a53104a73b52a54ad06011fa1
- version: 1.0

## Description

Envelope with Offset 
to be used with cycles
you can use offset function same as in SMA

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ahmed_Zakaria_M
//@version=6
indicator(title="Envelope with Offset", shorttitle="Env Offset", overlay=true)

// Inputs
length = input.int(20, title="Length", minval=1)
percent = input.float(10.0, title="Percent")
source = input(close, title="Source")
useEMA = input.bool(false, title="Use EMA")

// Offset input (same behavior as SMA)
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500)

// Moving Average
basis = useEMA ? ta.ema(source, length) : ta.sma(source, length)

// Envelope Calculation
k = percent / 100.0
upper = basis * (1 + k)
lower = basis * (1 - k)

// Plot with offset
plot(basis, title="Basis", color=#FF6D00, offset=offset)
u = plot(upper, title="Upper", color=#2962FF, offset=offset)
l = plot(lower, title="Lower", color=#2962FF, offset=offset)

// Fill between bands
fill(u, l, color=color.rgb(33, 150, 243, 95), title="Background")
//@version=6

plot(close)
````
