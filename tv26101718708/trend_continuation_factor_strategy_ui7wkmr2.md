# Trend continuation factor Strategy

- url: https://www.tradingview.com/script/uI7WKmR2-Trend-continuation-factor-Strategy/
- type: indicator
- pine_id: PUB;y2aRqlA8GNngpOJ4NNyBg53BrnvVVzRj
- version: 1.0

## Description

Trend continuation factor, by M.H. Pee 
    The related article is copyrighted material from Stocks & Commodities.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 03/01/2017
//    Trend continuation factor, by M.H. Pee 
//    The related article is copyrighted material from Stocks & Commodities.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Trend continuation factor")
Length = input(35, minval=1)
hline(0, color=green, linestyle=line)
xChange = mom(close, 1)
xPlusChange = iff(xChange > 0, xChange, 0)
xMinusChange = iff(xChange < 0, (xChange * -1), 0)
xPlusCF = iff(xPlusChange == 0, 0, xPlusChange + nz(xPlusCF[1], 1))
xMinusCF = iff(xMinusChange == 0, 0, xMinusChange + nz(xMinusCF[1], 1))
xPlus = xPlusChange - xMinusCF
xMinus = xMinusChange - xPlusCF
xPlusTCF =  sum(xPlus, Length)
xMinusTCF = sum(xMinus, Length)
pos = iff(xPlusTCF > xMinusTCF, 1,
       iff(xPlusTCF < xMinusTCF, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xPlusTCF, color=blue, title="Plus TCF")
plot(xMinusTCF, color=red, title="Minus TCF")
````
