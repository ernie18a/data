# Inertia Indicator

- url: https://www.tradingview.com/script/7LWh28O7-Inertia-Indicator/
- type: indicator
- pine_id: PUB;BZZnGDc7YWNKjfnP5BRaWgIbZIbPC35B
- version: 1.0

## Description

The inertia indicator measures the market, stock or currency pair momentum and 
 trend by measuring the security smoothed RVI (Relative Volatility Index). 
 The RVI is a technical indicator that estimates the general direction of the 
 volatility of an asset.
 The inertia indicator returns a value that is comprised between 0 and 100. 
 Positive inertia occurs when the indicator value is higher than 50. As long as 
 the inertia value is above 50, the long-term trend of the security is up. The inertia 
 is negative when its value is lower than 50, in this case the long-term trend is 
 down and should stay down if the inertia stays below 50.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 23/05/2017
// The inertia indicator measures the market, stock or currency pair momentum and 
// trend by measuring the security smoothed RVI (Relative Volatility Index). 
// The RVI is a technical indicator that estimates the general direction of the 
// volatility of an asset.
// The inertia indicator returns a value that is comprised between 0 and 100. 
// Positive inertia occurs when the indicator value is higher than 50. As long as 
// the inertia value is above 50, the long-term trend of the security is up. The inertia 
// is negative when its value is lower than 50, in this case the long-term trend is 
// down and should stay down if the inertia stays below 50.
////////////////////////////////////////////////////////////
study(title="Inertia Indicator", shorttitle="Inertia")
Period = input(10, minval=1)
Smooth = input(14, minval=1)
hline(50, color=green, linestyle=line)
xPrice = close
StdDev = stdev(xPrice, Period)
d = iff(close > close[1], 0, StdDev)
u = iff(close > close[1], StdDev, 0)
nU = (13 * nz(nU[1],0) + u) / 14
nD = (13 * nz(nD[1],0) + d) / 14
nRVI = 100 * nU / (nU + nD)
nRes = ema(nRVI, Smooth)
pos = iff(nRes > 50, 1,
	     iff(nRes < 50, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue ) 
plot(nRes, color=red, title="Inertia")
````
