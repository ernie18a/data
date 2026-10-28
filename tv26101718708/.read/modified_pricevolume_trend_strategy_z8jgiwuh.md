# Modified Price-Volume Trend Strategy

- url: https://www.tradingview.com/script/Z8JgiwuH-Modified-Price-Volume-Trend-Strategy/
- type: indicator
- pine_id: PUB;eYvGHLW33IRZ278D1bkprANEYFgRtlh2
- version: 1.0

## Description

The related article is copyrighted material from
  Stocks & Commodities.
  Strategy by HPotter.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/07/2018
//  The related article is copyrighted material from
//  Stocks & Commodities.
//  Strategy by HPotter.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Modified Price-Volume Trend Strategy", shorttitle="MPVT")
Level = input(0)
Scale = input(1)
Length = input(23)
xOHLC4 = ohlc4
xV = volume
rV = xV / 50000
xCumPVT = nz(xCumPVT[1]) + (rV * (xOHLC4 - xOHLC4[1]) / xOHLC4[1])
nRes = Level + Scale * xCumPVT
xMARes = sma(nRes, Length)
pos = iff(nRes > xMARes, 1,
       iff(nRes < xMARes, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="MPVT", linewidth = 2)
plot(xMARes, color=blue, title="MPVT", linewidth = 2)
````
