# Vertex EMA Strategy

- url: https://www.tradingview.com/script/hi9Psduw-Vertex-EMA-Strategy/
- type: indicator
- pine_id: PUB;86a1e269297040f7b0af2be0dd5a5623
- version: 2.0

## Description

Recently found an article sharing an EMA strategy written by Vertex. I copied a majority of the Long conditions into code here with some visual aid.

Essentially, watch for a the 8 EMA to be greater than the 21 EMA, and all the EMA's to be spread apart. Then get your trigger bar from a retracement from the 8 bar EMA. Stop on the lowest low of the past 5 bars, or on EMA 8 crossunder EMA 21.
[b]This is intended to only be used on a 1h chart.[\b]

This was made for a friend.

[b]Disclaimer[\b]: Please do your own research before making any decisions financially. I am not your financial advisor.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OztheWoz

//@version=5
indicator("Vertex EMA Strategy", overlay=true)


// 1h Conditions

barclronf = input(true, "Bar Color On/Off")
triggeronf = input(true, "Trigger Signal On/off")
emasrc  = input(close, "EMA Source")
h1emasrc = request.security(syminfo.tickerid, "60", emasrc)
ema1len = input(8,  "EMA 1 Length")
ema3len = input(21, "EMA 2 Length")
ema2len = input(13, "EMA 3 Length")
h1perc = input(0.01, "1h EMA Apart Percentage")
h4perc = input(0.382, "4h EMA Apart Percentage")
dperc  = input(0.382, "1D EMA Apart Percentage")

h1ema1 = ta.ema(h1emasrc, ema1len)
h1ema2 = ta.ema(h1emasrc, ema2len)
h1ema3 = ta.ema(h1emasrc, ema3len)

plot(h1ema1, color=color.red)
plot(h1ema2, color=color.orange)
plot(h1ema3, color=color.aqua)

h1far = h1ema2 > (h1ema3 + (h1ema3 * h1perc/100))
h1above = h1ema1 > h1ema3
h1touch = (close[1] > h1ema1) and (open > (h1ema1 - (h1ema1 * 0.182/100)))
h1crossdn = ta.crossunder(h1ema1, h1ema3)

h1long = h1far and h1above


// 4h Conditions
h4emasrc = request.security(syminfo.tickerid, "240", emasrc)
h4ema1 = ta.ema(h4emasrc, ema1len)
h4ema2 = ta.ema(h4emasrc, ema2len)
h4ema3 = ta.ema(h4emasrc, ema3len)

h4far = h4ema2 > (h4ema3 + (h4ema3 * h4perc/100))
h4above = h4ema1 > h4ema3

h4long = h4far and h4above


// 1d Conditions
demasrc = request.security(syminfo.tickerid, "1D", emasrc)
dema1 = ta.ema(demasrc, ema1len)
dema2 = ta.ema(demasrc, ema2len)
dema3 = ta.ema(demasrc, ema3len)

dfar = dema2 > (dema3 + (dema3 * dperc/100))
dabove = dema1 > dema3

dlong = dfar and dabove

trigger = h1long and h4long and dlong and h1touch
hold = h1long and h4long and dlong
barcolor(barclronf ? ((hold) ? #0003D8 : #AFC400) : na)

plotshape(triggeronf ? (((trigger[1] == false)) ? trigger : na) : na, color=na, text="🚀")


stoploss = ta.lowest(low, 5)[3]
plot(stoploss, color=color.gray)
plotshape((close < stoploss), style=shape.xcross, location=location.belowbar, color=color.gray)
// plotshape(crossdn, text="Sell", textcolor=color.white, style=shape.labeldown, location=location.abovebar, color=color.red)
````
