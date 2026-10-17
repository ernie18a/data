# Relative Volatility Index Strategy

- url: https://www.tradingview.com/script/X0aHvwMr-Relative-Volatility-Index-Strategy/
- type: indicator
- pine_id: PUB;LNAaQjWfby9qek0ALBUtyMhITZAQjrB2
- version: 1.0

## Description

The RVI is a modified form of the relative strength index (RSI). 
 The original RSI calculation separates one-day net changes into 
 positive closes and negative closes, then smoothes the data and 
 normalizes the ratio on a scale of zero to 100 as the basis for the 
 formula. The RVI uses the same basic formula but substitutes the 
 10-day standard deviation of the closing prices for either the up 
 close or the down close. The goal is to create an indicator that 
 measures the general direction of volatility. The volatility is 
 being measured by the 10-days standard deviation of the closing prices. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 20/10/2017
// The RVI is a modified form of the relative strength index (RSI). 
// The original RSI calculation separates one-day net changes into 
// positive closes and negative closes, then smoothes the data and 
// normalizes the ratio on a scale of zero to 100 as the basis for the 
// formula. The RVI uses the same basic formula but substitutes the 
// 10-day standard deviation of the closing prices for either the up 
// close or the down close. The goal is to create an indicator that 
// measures the general direction of volatility. The volatility is 
// being measured by the 10-days standard deviation of the closing prices. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Relative Volatility Index", shorttitle="RVI")
Period = input(10, minval=1)
BuyZone = input(30, minval=1)
SellZone = input(70, minval=1)
hline(0, color=purple, linestyle=dashed)
hline(BuyZone, color=red, linestyle=line)
hline(SellZone, color=green, linestyle=line)
xPrice = close
StdDev = stdev(xPrice, Period)
d = iff(close > close[1], 0, StdDev)
u = iff(close > close[1], StdDev, 0)
nU = (13 * nz(nU[1],0) + u) / 14
nD = (13 * nz(nD[1],0) + d) / 14
nRes = 100 * nU / (nU + nD)
pos = iff(nRes < BuyZone, -1,
	    iff(nRes > SellZone, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="RVI")
````
