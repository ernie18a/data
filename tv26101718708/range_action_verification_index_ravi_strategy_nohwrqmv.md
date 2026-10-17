# Range Action Verification Index (RAVI) Strategy

- url: https://www.tradingview.com/script/noHWRQMv-Range-Action-Verification-Index-RAVI-Strategy/
- type: indicator
- pine_id: PUB;eU6wQtE4bWefbvHMYeOYgdNy8UUpOQzw
- version: 1.0

## Description

The indicator represents the relative convergence/divergence of the moving 
 averages of the financial asset, increased a hundred times. It is based on 
 a different principle than the ADX. Chande suggests a 13-week SMA as the 
 basis for the indicator. It represents the quarterly (3 months = 65 working days) 
 sentiments of the market participants concerning prices. The short moving average 
 comprises 10% of the one and is rounded to seven.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 12/10/2017
// The indicator represents the relative convergence/divergence of the moving 
// averages of the financial asset, increased a hundred times. It is based on 
// a different principle than the ADX. Chande suggests a 13-week SMA as the 
// basis for the indicator. It represents the quarterly (3 months = 65 working days) 
// sentiments of the market participants concerning prices. The short moving average 
// comprises 10% of the one and is rounded to seven.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Range Action Verification Index (RAVI)", shorttitle="RAVI")
LengthMAFast = input(title="Length MA Fast", defval=7)
LengthMASlow = input(title="Length MA Slow", defval=65)
TradeLine = input(0.14, step=0.01)
hline(TradeLine, color=blue, linestyle=line)
xMAF = sma(close, LengthMAFast)
xMAS = sma(close, LengthMASlow)
xRAVI = ((xMAF - xMAS) / xMAS) * 100
pos = iff(xRAVI > TradeLine, 1,
	   iff(xRAVI < TradeLine, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xRAVI, color=green, title="RAVI")
````
