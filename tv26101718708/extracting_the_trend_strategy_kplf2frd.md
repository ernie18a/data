# Extracting The Trend Strategy

- url: https://www.tradingview.com/script/kplf2fRD-Extracting-The-Trend-Strategy/
- type: indicator
- pine_id: PUB;622
- version: -1.0

## Description

The related article is copyrighted material from Stocks & Commodities Mar 2010
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 16/10/2014
// The related article is copyrighted material from Stocks & Commodities Mar 2010
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="Extracting The Trend Strategy")
Length = input(20, minval=1)
Delta = input(0.5)
Trigger = input(0)
hline(Trigger, color=blue, linestyle=line)
xPrice = hl2
beta = cos(3.1415 * (360 / Length) / 180)
gamma = 1 / cos(3.1415 * (720 * Delta / Length) / 180)
alpha = gamma - sqrt(gamma * gamma - 1)
xBandpassFilter = 0.5 * (1 - alpha) * (xPrice - xPrice[2]) + beta * (1 + alpha) * nz(xBandpassFilter[1]) - alpha * nz(xBandpassFilter[2])
xMean = sma(xBandpassFilter, 2 * Length)
pos =	iff(xMean > Trigger, 1,
	    iff(xMean < Trigger, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xMean, color=red, title="ExTrend")
````
