# OBV Divergence Finder - Jeff 2026

- url: https://www.tradingview.com/script/paz68Avj-OBV-Divergence-Finder-Jeff-2026/
- type: indicator
- pine_id: PUB;c2d477beabeb46feb93dc25aaf704440
- version: 1.0

## Description

OBV Divergence Finder 
This shit finds divergences better than Hitler could find Jews

## Source Code

````pine
//@version=6
indicator("OBV Divergence Finder (Triangles)", overlay=true)

look = input.int(5, "Pivot Lookback", options=[1, 2, 3, 5, 10])

// OBV
obv = ta.cum(close > close[1] ? volume :
     close < close[1] ? -volume : 0)

// PRICE pivots only
priceHigh = ta.pivothigh(close, look, look)
priceLow  = ta.pivotlow(close, look, look)

// Previous stored pivots
var float prevPriceHigh = na
var float prevObvHigh   = na

var float prevPriceLow  = na
var float prevObvLow    = na

// ======================
// BEARISH DIVERGENCE
// ======================
bearDiv = false

if not na(priceHigh)
    obvAtPivot = obv[look]

    bearDiv := not na(prevPriceHigh) and priceHigh > prevPriceHigh and obvAtPivot < prevObvHigh

    prevPriceHigh := priceHigh
    prevObvHigh := obvAtPivot

// ======================
// BULLISH DIVERGENCE
// ======================
bullDiv = false

if not na(priceLow)
    obvAtPivot = obv[look]

    bullDiv := not na(prevPriceLow) and priceLow < prevPriceLow and obvAtPivot > prevObvLow

    prevPriceLow := priceLow
    prevObvLow := obvAtPivot

// ======================
// PLOT SHAPES
// ======================

plotshape(bearDiv,
     title="Bearish Divergence",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     offset=-look)

plotshape(bullDiv,
     title="Bullish Divergence",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.tiny,
     offset=-look)
````
