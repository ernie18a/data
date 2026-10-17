# Percent difference between price and MA Strategy

- url: https://www.tradingview.com/script/XngjJnVo-Percent-difference-between-price-and-MA-Strategy/
- type: indicator
- pine_id: PUB;iEjpKVB3FfWIio2p7YHwtrdAVfI17aOI
- version: 1.0

## Description

Percent difference between price and MA Strategy

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 30/07/2018
// Percent difference between price and MA
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Percent difference between price and MA Strategy")
Length = input(14, minval=1)
SellZone = input(0.54, minval=0.01, step = 0.01)
BuyZone = input(0.03, minval=0.01, step = 0.01)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
xSMA = sma(close, Length)
nRes = abs(close - xSMA) * 100 / close
pos = iff(nRes < BuyZone, 1,
       iff(nRes > SellZone, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="PD MA")
````
