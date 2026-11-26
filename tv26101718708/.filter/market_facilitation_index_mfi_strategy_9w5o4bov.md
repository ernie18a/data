# Market Facilitation Index (MFI) Strategy

- url: https://www.tradingview.com/script/9w5O4BOV-Market-Facilitation-Index-MFI-Strategy/
- type: indicator
- pine_id: PUB;WDZ9eSSdc5UrWjMvFAm7xvXkBmml9Z8n
- version: 1.0

## Description

The Market Facilitation Index is an indicator that relates price range to 
 volume and measures the efficency of price movement. Use the indicator to 
 determine if the market is trending. If the Market Facilitation Index increased, 
 then the market is facilitating trade and is more efficient, implying that the 
 market is trending. If the Market Facilitation Index decreased, then the market 
 is becoming less efficient, which may indicate a trading range is developing that 
 may be a trend reversal.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 11/09/2018
// The Market Facilitation Index is an indicator that relates price range to 
// volume and measures the efficency of price movement. Use the indicator to 
// determine if the market is trending. If the Market Facilitation Index increased, 
// then the market is facilitating trade and is more efficient, implying that the 
// market is trending. If the Market Facilitation Index decreased, then the market 
// is becoming less efficient, which may indicate a trading range is developing that 
// may be a trend reversal.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Market Facilitation Index (MFI) Strategy", shorttitle="MFI")
SellZone = input(6.2, minval=0.01, step = 0.01)
BuyZone = input(1, minval=0.01, step = 0.01)
hline(BuyZone, color=green, linestyle=line)
hline(SellZone, color=red, linestyle=line)
xmyVol = volume
xmyhigh = high
xmylow = low
nRes = (xmyhigh - xmylow) / xmyVol * 10000
pos = iff(nRes > BuyZone, 1,
       iff(nRes < SellZone, -1, nz(pos[1], 0)))
barcolor(pos == -1 ? red: pos == 1 ? green : blue )        
plot(nRes, color=green, title="MFI", style = histogram)
````
