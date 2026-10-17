# v13protrend

- url: https://www.tradingview.com/script/SnLhQwgw/
- type: indicator
- pine_id: PUB;7f484d0083534725873d82bb27da8113
- version: 1.0

## Description

seguidor de tendencia mostrando direcao do mercado

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © andersonoliveira

//@version=6
indicator("v13protrend")
SMIL = input.int(5, 'Stochastic Momentum length', minval=1)
wmalength = input(9, title='Smoothing length')
IEMA = input.int(3, 'Inner EMA length', minval=1)
OEMA = input.int(3, 'Outer EMA length', minval=1)
// SM calculation
LLow = ta.lowest(low, SMIL)
HHigh = ta.highest(high, SMIL)
SM = close - 0.5 * (HHigh + LLow)
// SMI calculations
avgsm = ta.ema(ta.ema(SM, IEMA), OEMA)
diff = HHigh - LLow
avgdiff = ta.ema(ta.ema(diff, IEMA), OEMA)
SMI = avgdiff != 0 ? 100 * (avgsm / (0.5 * avgdiff)) : 0
v1 = 0.1 * SMI
v2 = ta.wma(v1, wmalength)
INV = (math.exp(2 * v2) - 1) / (math.exp(2 * v2) + 1)
plot(INV, color=color.new(color.black, 0), linewidth=2)
hline(0.5, color=color.red)
hline(-0.5, color=color.green)
````
