# Comparative Relative Strength Strategy

- url: https://www.tradingview.com/script/fM9PNW2Y-Comparative-Relative-Strength-Strategy/
- type: indicator
- pine_id: PUB;bAu6G0kP8EbAZEg2UPkp15RVetAhtQxE
- version: 1.0

## Description

Comparative Relative Strength Strategy for ES

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/02/2017
// Comparative Relative Strength Strategy for ES
////////////////////////////////////////////////////////////
study("Comparative Relative Strength Strategy", shorttitle="CRS")
a = tickerid 
b = input("SPX500", type=symbol) 
len = input(10) 
BuyBand = input(0.9988, step = 0.0001)
SellBand = input(0.9960, step = 0.0001)
CloseBand = input(0.9975, step = 0.0001)
hline(CloseBand, color=blue, linestyle=dashed)
hline(SellBand, color=red, linestyle=line)
hline(BuyBand, color=green, linestyle=line)
as = security(a, period, close) 
bs = security(b, period, close) 
nRes = sma(as/bs, len)
pos = iff(nRes > BuyBand, 1,
	     iff(nRes < SellBand, -1,
	      iff(pos[1] == 1 and nRes < CloseBand, 0,
	       iff(pos[1] == -1 and nRes > CloseBand, 0, nz(pos[1], 0)))))
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(as/bs, title="CRS", color=gray) 
plot(nRes, color=navy)
````
