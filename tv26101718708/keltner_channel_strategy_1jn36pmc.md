# Keltner Channel Strategy

- url: https://www.tradingview.com/script/1jn36PmC-Keltner-Channel-Strategy/
- type: indicator
- pine_id: PUB;wIJuGvBRRDg0uXJ0r8y4pFc0LJahqxTM
- version: 1.0

## Description

The Keltner Channel, a classic indicator 
 of technical analysis developed by Chester Keltner in 1960. 
 The indicator is a bit like Bollinger Bands and Envelopes.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 28/08/2018
// The Keltner Channel, a classic indicator 
// of technical analysis developed by Chester Keltner in 1960. 
// The indicator is a bit like Bollinger Bands and Envelopes.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Keltner Channel Strategy", overlay = true)
nPeriod = input(title="Period", type=integer, defval=10, minval=1)
xPrice = sma(hlc3, nPeriod)
xMove = sma(high - low, nPeriod)
xUpper = xPrice + xMove
xLower = xPrice - xMove
pos = iff(close < xLower, -1,
       iff(close > xUpper, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xPrice, color=blue, title="KSmid")
plot(xUpper, color=red, title="KSup")
plot(xLower, color=green, title="KSdn")
````
