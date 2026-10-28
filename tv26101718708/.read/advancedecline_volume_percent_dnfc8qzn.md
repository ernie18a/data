# Advance-Decline Volume Percent

- url: https://www.tradingview.com/script/dNfc8qZn-Advance-Decline-Volume-Percent/
- type: indicator
- pine_id: PUB;1stGKCHOYOveHAOCZq6rWEUy5whsfyQ5
- version: 1.0

## Description

Advance-Decline Volume Percent (AD Volume Percent) is a breadth indicator 
 that measures the percentage of Net Advancing Volume for a particular group
 of stocks, such as an index or ETF. Net Advancing Volume equals the volume 
 of advances less the volume of declines. AD Volume Percent equals Net Advancing 
 Volume divided by total volume for the group. AD Volume Percent fluctuates 
 between -100% and +100%.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/06/2017
// Advance-Decline Volume Percent (AD Volume Percent) is a breadth indicator 
// that measures the percentage of Net Advancing Volume for a particular group
// of stocks, such as an index or ETF. Net Advancing Volume equals the volume 
// of advances less the volume of declines. AD Volume Percent equals Net Advancing 
// Volume divided by total volume for the group. AD Volume Percent fluctuates 
// between -100% and +100%. 
////////////////////////////////////////////////////////////
study(title="Advance-Decline Volume Percent", shorttitle="ADV Percent")
AdvSymbolVolume = input(title="Advancing Volume Symbol", type=symbol, defval="USI:UVOL")
DecSymbolVolume = input(title="Declining Volume Symbol", type=symbol, defval="USI:DVOL")
Resolutin = input(title="Resolution", type=resolution, defval="D")
BuyBand = input(100)
SellBand = input(-100, minval=1)
hline(SellBand, color=red, linestyle=line)
hline(BuyBand, color=green, linestyle=line)
xASVValue = security(AdvSymbolVolume, Resolutin, close)
xDSVValue = security(DecSymbolVolume, Resolutin, close)
xADV = xASVValue - xDSVValue
nRes = (xADV - nz(xADV[1], 0)) * 100 / (xASVValue + xDSVValue)
pos = iff(nRes > BuyBand, 1,
	     iff(nRes < SellBand, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=green, title="ADV Percent", style=line)
````
