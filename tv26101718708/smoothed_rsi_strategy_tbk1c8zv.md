# Smoothed RSI Strategy

- url: https://www.tradingview.com/script/TBk1C8zv-Smoothed-RSI-Strategy/
- type: indicator
- pine_id: PUB;QMcE7fLyBVJgezadxpDUsZDETuFE7W4j
- version: 1.0

## Description

This is new version of RSI oscillator indicator, developed by John Ehlers. 
 The main advantage of his way of enhancing the RSI indicator is smoothing 
 with minimum of lag penalty. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 15/11/2017
// This is new version of RSI oscillator indicator, developed by John Ehlers. 
// The main advantage of his way of enhancing the RSI indicator is smoothing 
// with minimum of lag penalty. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Smoothed RSI")
Length = input(10, minval=1)
xValue = (close + 2 * close[1] + 2 * close[2] + close[3] ) / 6
CU23 = sum(iff(xValue > xValue[1], xValue - xValue[1], 0), Length)
CD23 = sum(iff(xValue < xValue[1], xValue[1] - xValue, 0), Length)
nRes = iff(CU23 + CD23 != 0, CU23/(CU23 + CD23), 0)
pos = iff(nRes == 0, -1,
	    iff(nRes == 1, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="Smoothed RSI")
````
