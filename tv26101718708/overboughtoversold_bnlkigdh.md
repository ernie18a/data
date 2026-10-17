# Overbought/Oversold

- url: https://www.tradingview.com/script/BNlkIGDH-Overbought-Oversold/
- type: indicator
- pine_id: PUB;BNbl2IXhdMpiB8tzxkVTG7tWEXO3q3CO
- version: 1.0

## Description

Simple Overbought/Oversold indicator

 WARNING:
  This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 22/09/2017
// Simple Overbought/Oversold indicator
//
// WARNING:
//  This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Overbought/Oversold", shorttitle="OB/OS")
Length = input(10, minval=1)
SMALength = input(12, minval=1)
BuyBand = input(0.92, step = 0.01)
SellBand = input(0.5, step = 0.01)
hline(BuyBand, color=green, linestyle=line)
hline(SellBand, color=red, linestyle=line)
xOBOS = stoch(close, high, low, Length)
nRes = iff(close > close[Length], xOBOS / 100, (100 - xOBOS) / 100)
pos = iff(nRes < SellBand, -1,
	   iff(nRes > BuyBand, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(nRes, color=blue, title="OB/OS")
````
