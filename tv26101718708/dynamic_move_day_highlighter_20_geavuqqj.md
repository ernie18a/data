# Dynamic Move Day Highlighter 2.0

- url: https://www.tradingview.com/script/geAVUqQj-Dynamic-Move-Day-Highlighter-2-0/
- type: indicator
- pine_id: PUB;0957156fbf7149cc8b18f63e42a6e615
- version: 1.0

## Description

a simple chart highlighter you input a + or - % it shows you all the candles on whatever time frame your using that the stock up or down by that %

## Source Code

````pine
//@version=6
indicator("Dynamic Move Day Highlighter", overlay=true)

// Adds a setting option in the UI (supports positive or negative inputs)
targetPct = input.float(10.0, title="Target Percentage Change (%)")

// Calculate percentage change from previous close
pctChange = (close - close[1]) / close[1] * 100

// FIX: If target is positive, look for moves above it. If negative, look for moves below it.
isBigDay = targetPct >= 0 ? (pctChange >= targetPct) : (pctChange <= targetPct)

// Dynamic styling variables based on whether the target is a pump (+) or a dump (-)
isPositive = targetPct >= 0
bgCol      = isBigDay ? (isPositive ? color.new(color.green, 85) : color.new(color.red, 85)) : na
sigShape   = isPositive ? shape.triangleup : shape.triangledown
sigLoc     = isPositive ? location.belowbar : location.abovebar
sigCol     = isPositive ? color.green : color.red

// Highlight the background and plot the correct arrow directional indicator
bgcolor(bgCol)
plotshape(isBigDay, style=sigShape, location=sigLoc, color=sigCol, size=size.small, title="Target Met")
````
