# Psychological line Strategy

- url: https://www.tradingview.com/script/y78gT6Gm-Psychological-line-Strategy/
- type: indicator
- pine_id: PUB;RrzoflLFR9eh6EKTZhGVd6nWHfnpfG3g
- version: 1.0

## Description

Psychological line (PSY), as an indicator, is the ratio of the number of 
 rising periods over the total number of periods. It reflects the buying 
 power in relation to the selling power.

 If PSY is above 50%, it indicates that buyers are in control. Likewise, 
 if it is below 50%, it indicates the sellers are in control. If the PSY 
 moves along the 50% area, it indicates balance between the buyers and 
 sellers and therefore there is no direction movement for the market.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 09/04/2018
// Psychological line (PSY), as an indicator, is the ratio of the number of 
// rising periods over the total number of periods. It reflects the buying 
// power in relation to the selling power.
//
// If PSY is above 50%, it indicates that buyers are in control. Likewise, 
// if it is below 50%, it indicates the sellers are in control. If the PSY 
// moves along the 50% area, it indicates balance between the buyers and 
// sellers and therefore there is no direction movement for the market.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Psychological line Strategy")
Length = input(20, minval=1)
xPSY = sum(close > close[1],Length) / Length * 100
clr = iff(xPSY >= 50, green, red)
pos = iff(xPSY > 50, 1,
       iff(xPSY < 50, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
p1 = plot(50, color=black, title="0")
p2 = plot(xPSY, color=blue, title="PSY")
fill(p1, p2, color=clr)
````
