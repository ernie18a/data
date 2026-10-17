# Modified Price-Volume Trend Backtest

- url: https://www.tradingview.com/script/JwJnr9q3-Modified-Price-Volume-Trend-Backtest/
- type: strategy
- pine_id: PUB;cao3w2OsefjD2DwWse9DA9wqOKqfDuJB
- version: 1.0

## Description

The related article is copyrighted material from
  Stocks & Commodities.
  Strategy by HPotter.

 You can change long to short in the Input Settings
 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 20/07/2018
//  The related article is copyrighted material from
//  Stocks & Commodities.
//  Strategy by HPotter.
//
// You can change long to short in the Input Settings
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="Modified Price-Volume Trend Backtest", shorttitle="MPVT")
Level = input(0)
Scale = input(1)
Length = input(23)
reverse = input(false, title="Trade reverse")
xOHLC4 = ohlc4
xV = volume
rV = xV / 50000
xCumPVT = nz(xCumPVT[1]) + (rV * (xOHLC4 - xOHLC4[1]) / xOHLC4[1])
nRes = Level + Scale * xCumPVT
xMARes = sma(nRes, Length)
pos = iff(nRes > xMARes, 1,
       iff(nRes < xMARes, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(nRes, color=red, title="MPVT", linewidth = 2)
plot(xMARes, color=blue, title="MPVT", linewidth = 2)
````
