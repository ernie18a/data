# Ichimoku Strategy

- url: https://www.tradingview.com/script/rGWFkAEP-Ichimoku-Strategy/
- type: indicator
- pine_id: PUB;3DfS11MotkOIWgMrdRqEL08qySgdP4qs
- version: 1.0

## Description

Ichimoku Strategy

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 25/09/2018
//  Ichimoku Strategy
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
middleDonchian(Length) =>
    lower = lowest(Length)
    upper = highest(Length)
    avg(upper, lower)

study(title="Ichimoku2c Strategy", shorttitle="Ichimoku2c", overlay = true)
conversionPeriods = input(9, minval=1),
basePeriods = input(26, minval=1)
laggingSpan2Periods = input(52, minval=1),
displacement = input(26, minval=1)
Tenkan = middleDonchian(conversionPeriods)
Kijun =  middleDonchian(basePeriods)
xChikou = close
SenkouA = middleDonchian(laggingSpan2Periods)
SenkouB = (Tenkan[basePeriods] + Kijun[basePeriods]) / 2
A = plot(SenkouA[displacement], color=purple, title="SenkouA")
B = plot(SenkouB, color=green, title="SenkouB")
pos = iff(close < SenkouA[displacement], -1,
       iff(close > SenkouB, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
fill(A, B, color=green)
````
