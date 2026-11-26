# Dynamic Pivot Point Strategy

- url: https://www.tradingview.com/script/DLl9oDPB-Dynamic-Pivot-Point-Strategy/
- type: indicator
- pine_id: PUB;1cIIBlNpCa7hl60A9IIRo6V8hSPG9hST
- version: 2.0

## Description

This Pivot points is calculated on the current day.
 Pivot points simply took the high, low, and closing price from the previous period and 
 divided by 3 to find the pivot. From this pivot, traders would then base their 
 calculations for three support, and three resistance levels. The calculation for the most 
 basic flavor of pivot points, known as ‘floor-trader pivots’, along with their support and 
 resistance levels.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 14/06/2018
// This Pivot points is calculated on the current day.
// Pivot points simply took the high, low, and closing price from the previous period and 
// divided by 3 to find the pivot. From this pivot, traders would then base their 
// calculations for three support, and three resistance levels. The calculation for the most 
// basic flavor of pivot points, known as ‘floor-trader pivots’, along with their support and 
// resistance levels.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Dynamic Pivot Point Strategy", shorttitle="Dynamic Pivot Point", overlay = true)
width = input(2, minval=1)
xHigh  = security(tickerid,"D", high[1])
xLow   = security(tickerid,"D", low[1])
xClose = security(tickerid,"D", close[1])
vPP = (xHigh+xLow+xClose) / 3
vR1 = vPP+(vPP-xLow)
vS1 = vPP-(xHigh - vPP)
pos = iff(close > vR1, 1,
       iff(close < vS1, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
