# SMC: Sweep + BOS + Retest (PRO)

- url: https://www.tradingview.com/script/kGdMD7dV/
- type: indicator
- pine_id: PUB;045c53607bcb42ca8e8cea7a85bd5c93
- version: 1.0

## Description

Tepe ve dip noktaları bulma indikatörü. mum son tepe noktası üstünde kapanışlarda pozisyon alınır.

## Source Code

````pine
//@version=5
indicator("SMC: Sweep + BOS + Retest (PRO)", overlay=true)

// === INPUT
left  = input.int(3, "Pivot Left")
right = input.int(3, "Pivot Right")

useRSI = input.bool(true, "RSI Filtre")
rsiLen = input.int(14)
rsiMin = input.int(50)

// === RSI
rsi = ta.rsi(close, rsiLen)

// === PIVOTLAR
ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

// === SON DEĞERLER
var float lastHigh = na
var float prevHigh = na
var float lastLow  = na
var float prevLow  = na

if not na(ph)
    prevHigh := lastHigh
    lastHigh := ph

if not na(pl)
    prevLow := lastLow
    lastLow := pl

// === DÜŞÜŞ TRENDİ (LOWER HIGH)
lowerHigh = not na(lastHigh) and not na(prevHigh) and lastHigh < prevHigh

// === DİRENÇ
var float resistance = na
if lowerHigh
    resistance := lastHigh

// === LİKİDİTE SWEEP (STOP AVI)
sweep = not na(lastLow) and low < lastLow and close > lastLow

// === BREAK OF STRUCTURE (BOS)
bos = not na(resistance) and close > resistance

// === RETEST
retest = bos and low <= resistance

// === GÜÇLÜ MUM
strong = close > open and (close - open) > (high - low) * 0.5

// === FİNAL AL SİNYALİ
buySignal = sweep and bos and retest and strong and (not useRSI or rsi > rsiMin)

// === TEK SİNYAL
var bool triggered = false

if buySignal and not triggered
    triggered := true
else if close < resistance
    triggered := false

finalBuy = buySignal and not triggered[1]

// === ÇİZİMLER
plot(resistance, "Direnç (Son Tepe)", color=color.red, linewidth=2)
plot(lastLow, "Likidite (Dip)", color=color.blue, linewidth=1)

// === SİNYAL
plotshape(finalBuy,
     title="SMART AL",
     location=location.belowbar,
     color=color.lime,
     style=shape.labelup,
     text="AL")

// === GÖRSEL
plotshape(sweep, title="Sweep", location=location.belowbar, color=color.blue, style=shape.circle, size=size.tiny)
plotshape(bos, title="BOS", location=location.abovebar, color=color.orange, style=shape.triangleup, size=size.tiny)
````
