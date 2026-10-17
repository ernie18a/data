# Trend Analysis Index Strategy

- url: https://www.tradingview.com/script/IvGwWGnL-Trend-Analysis-Index-Strategy/
- type: indicator
- pine_id: PUB;yRXKW1fQsS4p7TeI2idtAUEMMMmQQhJB
- version: 1.0

## Description

In essence, it is simply the standard deviation of the last x bars of a 
 y-bar moving average. Thus, the TAI is a simple trend indicator when prices 
 trend with authority, the slope of the moving average increases, and when 
 prices meander in a trendless range, the slope of the moving average decreases.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/12/2017
// In essence, it is simply the standard deviation of the last x bars of a 
// y-bar moving average. Thus, the TAI is a simple trend indicator when prices 
// trend with authority, the slope of the moving average increases, and when 
// prices meander in a trendless range, the slope of the moving average decreases.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Trend Analysis Index", shorttitle="TAI")
AvgLen = input(28, minval=1)
TAILen = input(5, minval=1)
TopBand = input(0.11, step=0.01)
LowBand = input(0.02, step=0.01)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xPrice = close
xSMA = sma(xPrice, AvgLen)
xHH = highest(xSMA, TAILen)
xLL = lowest(xSMA, TAILen)
nRes = (xHH - xLL) * 100 / xPrice
pos = iff(nRes > TopBand, 1,
       iff(nRes < LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="TAI")
````
