# DNB RADAR CRUCES

- url: https://www.tradingview.com/script/YpoGWOTk/
- type: indicator
- pine_id: PUB;837acea9af0d4da880db6ee3664c66fb
- version: 1.0

## Description

Indicador que permite crear alertas sobre curces de medias móviles

## Source Code

````pine
//@version=6
indicator("DNB RADAR CRUCES", overlay=true, max_labels_count=500)

// Inputs
vmaLen = input.int(9, "VMA_LB Length", minval=1)
smaLen = input.int(200, "SMA Length", minval=1)
src = input.source(close, "Source")
showMarks = input.bool(true, "Mostrar triángulos")

// VMA_LB LazyBear style
k = 1.0 / vmaLen

pdm = math.max(src - src[1], 0)
mdm = math.max(src[1] - src, 0)

var float pdmS = na
var float mdmS = na
pdmS := (1 - k) * nz(pdmS[1]) + k * pdm
mdmS := (1 - k) * nz(mdmS[1]) + k * mdm

s = pdmS + mdmS
pdi = s != 0 ? pdmS / s : 0
mdi = s != 0 ? mdmS / s : 0

var float pdiS = na
var float mdiS = na
pdiS := (1 - k) * nz(pdiS[1]) + k * pdi
mdiS := (1 - k) * nz(mdiS[1]) + k * mdi

d = math.abs(pdiS - mdiS)
s1 = pdiS + mdiS
iS = s1 != 0 ? d / s1 : 0

hhv = ta.highest(iS, vmaLen)
llv = ta.lowest(iS, vmaLen)
d1 = hhv - llv
vI = d1 != 0 ? (iS - llv) / d1 : 0

var float vma = na
vma := (1 - k * vI) * nz(vma[1]) + k * vI * src

// SMA 200
sma200 = ta.sma(src, smaLen)

// Cruces
bullCross = ta.crossover(vma, sma200)
bearCross = ta.crossunder(vma, sma200)

// Triángulos
plotshape(
     showMarks and bullCross ? sma200 : na,
     title="Cruce alcista",
     style=shape.triangleup,
     location=location.absolute,
     color=color.lime,
     size=size.tiny)

plotshape(
     showMarks and bearCross ? sma200 : na,
     title="Cruce bajista",
     style=shape.triangledown,
     location=location.absolute,
     color=color.red,
     size=size.tiny)

// Alerta única para cualquier cruce
if bullCross or bearCross
    alert("Cruce detectado en " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)

// Alertcondition de respaldo
alertcondition(
     bullCross or bearCross,
     title="Cruce detectado",
     message="Cruce detectado en {{ticker}} {{interval}}")
````
