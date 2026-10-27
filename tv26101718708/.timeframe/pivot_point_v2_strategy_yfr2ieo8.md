# Pivot Point V2 Strategy

- url: https://www.tradingview.com/script/yFr2ieO8-Pivot-Point-V2-Strategy/
- type: indicator
- pine_id: PUB;fyFUYSVesttpOvmKLod2Wgq9n8VYkhhP
- version: 1.0

## Description

Pivot points simply took the high, low, and closing price from the previous period and 
 divided by 3 to find the pivot. From this pivot, traders would then base their 
 calculations for three support, and three resistance levels. The calculation for the most 
 basic flavor of pivot points, known as ‘floor-trader pivots’, along with their support and 
 resistance levels.

 WARNING:
  - For purpose educate only
  - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 29/05/2020
// Pivot points simply took the high, low, and closing price from the previous period and 
// divided by 3 to find the pivot. From this pivot, traders would then base their 
// calculations for three support, and three resistance levels. The calculation for the most 
// basic flavor of pivot points, known as ‘floor-trader pivots’, along with their support and 
// resistance levels.
//
// WARNING:
//  - For purpose educate only
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Pivot Point V2", shorttitle="Pivot Point V2", overlay = true)
res = input(title="Resolution", type=input.resolution, defval="D")
SellFrom = input(title="Sell from ", defval="R1", options=["R1", "R2", "R3"])
BuyFrom = input(title="Buy from ", defval="S1", options=["S1", "S2", "S3"])
width = input(1, minval=1)
xHigh  = security(syminfo.tickerid,res, high)
xLow   = security(syminfo.tickerid,res, low)
xClose = security(syminfo.tickerid,res, close)
vPP = (xHigh+xLow+xClose) / 3
vS1 = 2*vPP - xHigh 
vR1 = 2*vPP-xLow
vS2 = vPP - (vR1 - vS1)
vR2 = vPP + (vR1 - vS1)
vS3 = xLow - 2 * (xHigh - vPP)
vR3 = xHigh + 2 * (vPP - xLow) 
pos = 0
S = iff(BuyFrom == "S1", vS1, 
      iff(BuyFrom == "S2", vS2,
         iff(BuyFrom == "S3", vS3,0)))
B = iff(SellFrom == "R1", vR1, 
      iff(SellFrom == "R2", vR2,
         iff(SellFrom == "R3", vR3,0)))
pos := iff(close > B, 1,
       iff(close < S, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? color.red: pos == 1 ? color.green : color.blue )
````
