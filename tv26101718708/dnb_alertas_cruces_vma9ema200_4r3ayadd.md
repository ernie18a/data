# DNB ALERTAS CRUCES VMA9-EMA200

- url: https://www.tradingview.com/script/4R3ayAdd-DNB-ALERTAS-CRUCES-VMA9-EMA200/
- type: indicator
- pine_id: PUB;4a9cac2d82524aad89ee8560688a6661
- version: 2.0

## Description

indicador que permite crear alertas sobre cruces ema y vma

## Source Code

````pine
//@version=6
indicator("DNB ALERTAS CRUCES VMA9-EMA200", overlay=true)

src = close
l   = 9
k   = 1.0 / l

pdm = math.max(src - src[1], 0)
mdm = math.max(src[1] - src, 0)

var float pdmS = na
var float mdmS = na
var float pdiS = na
var float mdiS = na
var float iS   = na
var float vma  = na

pdmS := nz(pdmS[1]) * (1 - k) + k * pdm
mdmS := nz(mdmS[1]) * (1 - k) + k * mdm

s    = pdmS + mdmS
pdi  = s != 0 ? pdmS / s : 0.0
mdi  = s != 0 ? mdmS / s : 0.0

pdiS := nz(pdiS[1]) * (1 - k) + k * pdi
mdiS := nz(mdiS[1]) * (1 - k) + k * mdi

d    = math.abs(pdiS - mdiS)
s1   = pdiS + mdiS
iS   := nz(iS[1]) * (1 - k) + k * (s1 != 0 ? d / s1 : 0.0)

hhv  = ta.highest(iS, l)
llv  = ta.lowest(iS, l)
d1   = hhv - llv
vI   = d1 != 0 ? (iS - llv) / d1 : 0.0
vma  := na(vma[1]) ? src : nz(vma[1]) * (1 - k * vI) + k * vI * src

ema200 = ta.ema(close, 200)

bullCross = ta.crossover(vma, ema200)
bearCross = ta.crossunder(vma, ema200)

plotshape(bullCross ? ema200 : na,
     style    = shape.triangleup,
     location = location.absolute,
     color    = color.lime,
     size     = size.tiny,
     title    = "Cruce Alcista")

plotshape(bearCross ? ema200 : na,
     style    = shape.triangledown,
     location = location.absolute,
     color    = color.red,
     size     = size.tiny,
     title    = "Cruce Bajista")

if bullCross
    alert("🟢 " + syminfo.ticker + " " + timeframe.period + " - VMA9 cruza por ENCIMA de EMA200", alert.freq_once_per_bar)

if bearCross
    alert("🔴 " + syminfo.ticker + " " + timeframe.period + " - VMA9 cruza por DEBAJO de EMA200", alert.freq_once_per_bar)
````
