# High - EMA Strategy

- url: https://www.tradingview.com/script/YKg21h2X-High-EMA-Strategy/
- type: indicator
- pine_id: PUB;168
- version: -1.0

## Description

This indicator plots the difference between the High (of the previous period)
 and an exponential moving average (13 period) of the Close (of the previous period).
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
 It buy if indicator above 0 and sell if below.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/07/2014
// This indicator plots the difference between the High (of the previous period)
// and an exponential moving average (13 period) of the Close (of the previous period).
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
// It buy if indicator above 0 and sell if below.
////////////////////////////////////////////////////////////
study(title="High - EMA Strategy", shorttitle="High - EMA Strategy")
Length = input(13, minval=1)
xPrice = close  // You can use any series
hline(0, color=red, linestyle=line)
xEMA = ema(xPrice, Length)
nRes = high[1] - nz(xEMA[1])
pos =	iff(nRes > 0, 1,
	    iff(nRes < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="High - EMA")
````
