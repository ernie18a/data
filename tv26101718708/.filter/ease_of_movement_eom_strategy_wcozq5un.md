# Ease of Movement (EOM) Strategy

- url: https://www.tradingview.com/script/wCOZq5Un-Ease-of-Movement-EOM-Strategy/
- type: indicator
- pine_id: PUB;TMcRTxU2hvpu3xPFz35j3dgcCpDFJgsW
- version: 1.0

## Description

This indicator gauges the magnitude of price and volume movement. 
 The indicator returns both positive and negative values where a 
 positive value means the market has moved up from yesterday's value 
 and a negative value means the market has moved down. A large positive 
 or large negative value indicates a large move in price and/or lighter 
 volume. A small positive or small negative value indicates a small move 
 in price and/or heavier volume.
 A positive or negative numeric value. A positive value means the market 
 has moved up from yesterday's value, whereas, a negative value means the 
 market has moved down. 

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/06/2018
// This indicator gauges the magnitude of price and volume movement. 
// The indicator returns both positive and negative values where a 
// positive value means the market has moved up from yesterday's value 
// and a negative value means the market has moved down. A large positive 
// or large negative value indicates a large move in price and/or lighter 
// volume. A small positive or small negative value indicates a small move 
// in price and/or heavier volume.
// A positive or negative numeric value. A positive value means the market 
// has moved up from yesterday's value, whereas, a negative value means the 
// market has moved down. 
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Ease of Movement (EOM) Strategy", shorttitle="EOM")
BuyZone = input(4000, minval=1)
SellZone = input(-4000, minval=1)
hline(0, color=blue, linestyle=line)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
xHigh = high
xLow = low
xVolume = volume
xHalfRange = (xHigh - xLow) * 0.5
xMidpointMove = mom(xHalfRange, 1)
xBoxRatio = iff((xHigh - xLow) != 0, xVolume / (xHigh - xLow), 0)
nRes = iff(xBoxRatio != 0, 1000000 * ((xMidpointMove - xMidpointMove[1]) / xBoxRatio), 0)
pos = iff(nRes > BuyZone, 1,
       iff(nRes < SellZone, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="EOM", style=histogram, linewidth=2)
````
