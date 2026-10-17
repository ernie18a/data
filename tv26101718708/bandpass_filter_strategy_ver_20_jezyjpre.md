# Bandpass Filter Strategy ver 2.0

- url: https://www.tradingview.com/script/JEzYJPRE-Bandpass-Filter-Strategy-ver-2-0/
- type: indicator
- pine_id: PUB;Rf5hHG6cBlXNo9FvyDWWEKuxXsqYV1pH
- version: 1.0

## Description

The related article is copyrighted material from
 Stocks & Commodities Mar 2010
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/09/2018
// The related article is copyrighted material from
// Stocks & Commodities Mar 2010
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Bandpass Filter Strategy Strategy ver 2.0")
Length = input(20, minval=1)
Delta = input(0.5)
SellZone = input(5, step = 0.01)
BuyZone = input(-5, step = 0.01)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
xPrice = hl2
hline(0, color=blue, linestyle=line)
beta = cos(3.14 * (360 / Length) / 180)
gamma = 1 / cos(3.14 * (720 * Delta / Length) / 180)
alpha = gamma - sqrt(gamma * gamma - 1)
BP = 0.5 * (1 - alpha) * (xPrice - xPrice[2]) + beta * (1 + alpha) * nz(BP[1]) - alpha * nz(BP[2])
pos =	iff(BP > SellZone, 1,
	    iff(BP <= BuyZone, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(BP, color=red, title="Bandpass Filter Strategy")
````
