# Volatility Strategy

- url: https://www.tradingview.com/script/Vap7z6yL-Volatility-Strategy/
- type: indicator
- pine_id: PUB;pXL6hw8BkcAvHiNVWWbhT6gKTRHEg2Im
- version: 1.0

## Description

The Volatility function measures the market volatility by plotting a 
 smoothed average of the True Range. It returns an average of the TrueRange 
 over a specific number of bars, giving higher weight to the TrueRange of 
 the most recent bar.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/08/2018
// The Volatility function measures the market volatility by plotting a 
// smoothed average of the True Range. It returns an average of the TrueRange 
// over a specific number of bars, giving higher weight to the TrueRange of 
// the most recent bar.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Volatility Strategy", shorttitle="Volatility")
Length = input(10, minval=1)
LengthMA = input(26, minval=1)
xATR = atr(Length)
nRes = ((Length - 1) * nz(nRes[1], 0) + xATR) / Length
xMARes = sma(nRes, LengthMA)
pos = iff(nRes < xMARes, 1,
       iff(nRes > xMARes, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=blue, title="Volatility")
plot(xMARes, color=red, title="MA")
````
