# Gap + 2 Candle Confirmation (Fixed)

- url: https://www.tradingview.com/script/uDOdeyKB-Gap-2-Candle-Confirmation-Fixed/
- type: indicator
- pine_id: PUB;64e10c14b96e421d8ffc0d7c14b926ae
- version: 1.0

## Description

Gap + 2 Candle Confirmation (Fixed) Gap + 2 Candle Confirmation (Fixed) Gap + 2 Candle Confirmation (Fixed) Gap + 2 Candle Confirmation (Fixed) Gap + 2 Candle Confirmation (Fixed)

## Source Code

````pine
//@version=5
indicator("Gap + 2 Candle Confirmation (Fixed)", overlay=true)

// ===== INPUT =====
minGap = input.float(0.1, "Minimum Gap Size", step=0.1)

// ===== CANDLE COLOR =====
isBull = close > open
isBear = close < open

prevBull = close[1] > open[1]
prevBear = close[1] < open[1]

// ===== GAP LOGIC (IMPROVED) =====
// Gap Up = open sekarang di atas close sebelumnya
gapUp = open > close[1] and (open - close[1]) >= minGap

// Gap Down = open sekarang di bawah close sebelumnya
gapDown = open < close[1] and (close[1] - open) >= minGap

// ===== FINAL CONDITION =====
validGapUp = gapUp and isBull and prevBull
validGapDown = gapDown and isBear and prevBear

// ===== PLOT =====
plotshape(validGapUp, title="Gap Up", location=location.belowbar,
     style=shape.triangleup, size=size.small, color=color.green)

plotshape(validGapDown, title="Gap Down", location=location.abovebar,
     style=shape.triangledown, size=size.small, color=color.red)
````
