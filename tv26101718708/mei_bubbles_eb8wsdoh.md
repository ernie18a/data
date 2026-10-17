# Mei - Bubbles

- url: https://www.tradingview.com/script/Eb8wSDOH-Mei-Bubbles/
- type: indicator
- pine_id: PUB;afc9db52a36043c397168f5b3349c295
- version: 1.0

## Description

This indicator visualizes absorption events by plotting bubbles on candle wicks where volume activity suggests one side of the market is absorbing the other’s pressure. Instead of raw volume, the script normalizes activity against a rolling standard deviation defined by the Lookback Period. Bubbles appear on upper or lower wicks depending on whether buyers or sellers are absorbing pressure. The goal is to highlight whether aggressive orders are being accepted or absorbed at key price points.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © profitprotrading

//@version=6
indicator("Mei - Bubbles", overlay = true)

// === Input Settings ===
showDots     = input.bool(true, "Show Bubbles?", group = "Absorption Bubbles")
limitFactor  = input.float(0.1, "Absorption Threshold", step = 0.1, minval = 0.1, group = "Absorption Bubbles")
lookbackperiod = input(100, "Lookback Period", group = "Absorption Bubbles")
colUp   = color.green
colDown = color.red

// === Core Calculations ===
volData   = volume
midPrice  = (high + low) / 2
scaledVol = volData / ta.stdev(volData, lookbackperiod)

gradUp = color.from_gradient(
    scaledVol, 0, 8,
    chart.bg_color == color.white ? color.new(colUp, 100) : color.rgb(35, 73, 35, 15),
    color.rgb(0, 217, 0, 70)
)

gradDn = color.from_gradient(
    scaledVol, 0, 8,
    chart.bg_color == color.white ? color.new(colDown, 100) : color.rgb(77, 34, 34, 15),
    color.rgb(219, 0, 0, 70)
)

condA = showDots and scaledVol >= limitFactor and scaledVol < (limitFactor + 1)
condB = showDots and scaledVol >= (limitFactor + 1) and scaledVol < (limitFactor + 2)
condC = showDots and scaledVol >= (limitFactor + 2) and scaledVol < (limitFactor + 3)
condD = showDots and scaledVol >= (limitFactor + 3) and scaledVol < (limitFactor + 6)
condE = showDots and scaledVol >= (limitFactor + 6)

bullBar = close > open
bearBar = close < open

// Wick zones
topWick    = high
topBody    = math.max(open, close)
lowBody    = math.min(open, close)
bottomWick = low

upperZone = midPrice >= topBody and midPrice <= topWick
lowerZone = midPrice <= lowBody and midPrice >= bottomWick

validUp = upperZone
validDn = lowerZone


// === Bubble Plots ===
plotshape(condA and validUp ? midPrice : na, "", shape.circle, location.absolute, gradUp, size = size.tiny)
plotshape(condB and validUp ? midPrice : na, "", shape.circle, location.absolute, gradUp, size = size.small)
plotshape(condC and validUp ? midPrice : na, "", shape.circle, location.absolute, gradUp, size = size.normal)
plotshape(condD and validUp ? midPrice : na, "", shape.circle, location.absolute, gradUp, size = size.large)
plotshape(condE and validUp ? midPrice : na, "", shape.circle, location.absolute, gradUp, size = size.huge)

plotshape(condA and validDn ? midPrice : na, "", shape.circle, location.absolute, gradDn, size = size.tiny)
plotshape(condB and validDn ? midPrice : na, "", shape.circle, location.absolute, gradDn, size = size.small)
plotshape(condC and validDn ? midPrice : na, "", shape.circle, location.absolute, gradDn, size = size.normal)
plotshape(condD and validDn ? midPrice : na, "", shape.circle, location.absolute, gradDn, size = size.large)
plotshape(condE and validDn ? midPrice : na, "", shape.circle, location.absolute, gradDn, size = size.huge)

// === Bar Coloring ===
insideBody   = midPrice > lowBody and midPrice < topBody
heavyVolBody = scaledVol > (limitFactor + 2)

barcolor(insideBody and heavyVolBody and bullBar ? color.rgb(0, 255, 0) : na)
barcolor(insideBody and heavyVolBody and bearBar ? color.rgb(255, 132, 132) : na)

//Alerts
alertcondition((condA or condB or condC or condD or condE) and validDn and barstate.isconfirmed, 
     title = "Buying Absorption", 
     message = "Absorption detected: Buyers absorbed selling pressure")

// Selling absorption: green bubble on upper wick
alertcondition((condA or condB or condC or condD or condE) and validUp and barstate.isconfirmed, 
     title = "Selling Absorption", 
     message = "Absorption detected: Sellers absorbed buying pressure")

// Any absorption: either buying or selling
alertcondition((condA or condB or condC or condD or condE) and (validUp or validDn) and barstate.isconfirmed, 
     title = "Absorption (Any)", 
     message = "Absorption detected: Buying or Selling absorption event")
````
