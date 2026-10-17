# TFS: MBO Strategy

- url: https://www.tradingview.com/script/gLkLmYah-TFS-MBO-Strategy/
- type: indicator
- pine_id: PUB;wb87KBfOs8kDEOT8Pcigzq7BkWGr5e4V
- version: 1.0

## Description

MBO indicator is the third component of TFS trading system. This indicator
 was developed by Bryan Strain and Mark Whitley.
 The idea of MBO is similar to moving average convergence/divergence (MACD)
 indicator. It is calculated by subtracting the 200-day moving average from
 the 25-day moving average.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/08/2018
// MBO indicator is the third component of TFS trading system. This indicator
// was developed by Bryan Strain and Mark Whitley.
// The idea of MBO is similar to moving average convergence/divergence (MACD)
// indicator. It is calculated by subtracting the 200-day moving average from
// the 25-day moving average.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="TFS: MBO Strategy", shorttitle="TFS: MBO indicator")
Fastavg = input(25, minval=1)
Slowavg = input(200, minval=1)
Length = input(18, minval=1)
hline(0, color=blue, linestyle=line)
xFastAvg = sma(close, Fastavg)
xSlowAvg = sma(close, Slowavg)        
nMBO = xFastAvg - xSlowAvg
xSMAMBO = sma(nMBO, Length)
pos = iff(nMBO > xSMAMBO, 1,
       iff(nMBO < xSMAMBO, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nMBO, color=red, style = histogram, title="TFS: MBO indicator")
plot(xSMAMBO, color=blue, title="SMA")
````
