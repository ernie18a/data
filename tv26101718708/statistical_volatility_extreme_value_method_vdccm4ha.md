# Statistical Volatility - Extreme Value Method 

- url: https://www.tradingview.com/script/vdcCM4Ha-Statistical-Volatility-Extreme-Value-Method/
- type: indicator
- pine_id: PUB;6J5wt0je3BclRYchH7vLY9ZwWWhxSaEC
- version: 1.0

## Description

This indicator used to calculate the statistical volatility, sometime 
 called historical volatility, based on the Extreme Value Method.
 Please use this link to get more information about Volatility.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 21/11/2014
// This indicator used to calculate the statistical volatility, sometime 
// called historical volatility, based on the Extreme Value Method.
// Please use this link to get more information about Volatility. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Statistical Volatility - Extreme Value Method ", shorttitle="Statistical Volatility Strategy")
Length = input(30, minval=1)
TopBand = input(0.005, step=0.001)
LowBand = input(0.0016, step=0.001)
hline(TopBand, color=red, linestyle=line)
hline(LowBand, color=green, linestyle=line)
xMaxC = highest(close, Length)
xMaxH = highest(high, Length)
xMinC = lowest(close, Length)
xMinL = lowest(low, Length)
SqrTime = sqrt(253 / Length)
Vol = ((0.6 * log(xMaxC / xMinC) * SqrTime) + (0.6 * log(xMaxH / xMinL) * SqrTime)) * 0.5
nRes = iff(Vol < 0,  0, iff(Vol > 2.99, 2.99, Vol))
pos = iff(nRes > TopBand, 1,
	   iff(nRes < LowBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="Statistical Volatility")
````
