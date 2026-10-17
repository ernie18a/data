# Bill Williams Averages. 3Lines Strategy

- url: https://www.tradingview.com/script/z4idR1Sy-Bill-Williams-Averages-3Lines-Strategy/
- type: indicator
- pine_id: PUB;ZnijdG0bsFKzRGiDESym12mnOFpYaBxm
- version: 1.0

## Description

This indicator calculates 3 Moving Averages for default values of
 13, 8 and 5 days, with displacement 8, 5 and 3 days: Median Price (High+Low/2).
 The most popular method of interpreting a moving average is to compare 
 the relationship between a moving average of the security's price with 
 the security's price itself (or between several moving averages).

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 31/01/2017
// This indicator calculates 3 Moving Averages for default values of
// 13, 8 and 5 days, with displacement 8, 5 and 3 days: Median Price (High+Low/2).
// The most popular method of interpreting a moving average is to compare 
// the relationship between a moving average of the security's price with 
// the security's price itself (or between several moving averages).
////////////////////////////////////////////////////////////
study(title="Bill Williams Averages. 3Lines", shorttitle="3 Lines", overlay = true)
LLength = input(13, minval=1)
MLength = input(8,minval=1)
SLength = input(5,minval=1)
LOffset = input(8,minval=1)
MOffset = input(5,minval=1)
SOffset = input(3,minval=1)
xLSma = sma(hl2, LLength)[LOffset]
xMSma = sma(hl2, MLength)[MOffset]
xSSma = sma(hl2, SLength)[SOffset]
pos = iff(close < xSSma and xSSma < xMSma and xMSma < xLSma, -1,
	   iff(close > xSSma and xSSma > xMSma and xMSma > xLSma, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xLSma, color=blue, title="MA")
plot(xMSma, color=red, title="EMA")
plot(xSSma, color=green, title="EMA")
````
