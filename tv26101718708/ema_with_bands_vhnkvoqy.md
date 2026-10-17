# EMA with %-Bands

- url: https://www.tradingview.com/script/vhnkvoqY/
- type: indicator
- pine_id: PUB;da3fc47bbe13430a8ed862f3a56d5095
- version: 1.0

## Description

EMA with %-Bands for individual TP and SL.

TP wenn der Preis sich prozentual zu weit weg von der EMA entfernt hat.
SL wenn der Preis sich prozentual zu weit weg von der EMA entfernt hat.

## Source Code

````pine
//@version=5
//Copyright-2026-Murat Cambaz
indicator("EMA mit %", overlay=true)
len = input.int(200, title="EMA Länge")
percent = input.float(1.0, title="Prozent Offset", step=0.1)
src = close

emaVal = ta.ema(src, len)
upperBand = emaVal * (1 + percent / 100)
lowerBand = emaVal * (1 - percent / 100)

plot(emaVal, color=color.blue, title="EMA")
plot(upperBand, color=color.red, title="Oberes Band")
plot(lowerBand, color=color.green, title="Unteres Band")
````
