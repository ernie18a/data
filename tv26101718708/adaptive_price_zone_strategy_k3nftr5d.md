# Adaptive Price Zone Strategy

- url: https://www.tradingview.com/script/k3NFtr5d-Adaptive-Price-Zone-Strategy/
- type: indicator
- pine_id: PUB;dp3wnVT6UyyoBPEK7Z8lTX2TQDhNGvtG
- version: 1.0

## Description

The adaptive price zone (APZ) is a volatility-based technical indicator that helps investors 
 identify possible market turning points, which can be especially useful in a sideways-moving 
 market. It was created by technical analyst Lee Leibfarth in the article “Identify the 
 Turning Point: Trading With An Adaptive Price Zone,” which appeared in the September 2006 issue 
 of the journal Technical Analysis of Stocks and Commodities.
 This indicator attempts to signal significant price movements by using a set of bands based on 
 short-term, double-smoothed exponential moving averages that lag only slightly behind price changes. 
 It can help short-term investors and day traders profit in volatile markets by signaling price 
 reversal points, which can indicate potentially lucrative times to buy or sell. The APZ can be 
 implemented as part of an automated trading system and can be applied to the charts of all tradeable assets.

 Green color is long.
 Red color is short.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 14/01/2020
//
// The adaptive price zone (APZ) is a volatility-based technical indicator that helps investors 
// identify possible market turning points, which can be especially useful in a sideways-moving 
// market. It was created by technical analyst Lee Leibfarth in the article “Identify the 
// Turning Point: Trading With An Adaptive Price Zone,” which appeared in the September 2006 issue 
// of the journal Technical Analysis of Stocks and Commodities.
// This indicator attempts to signal significant price movements by using a set of bands based on 
// short-term, double-smoothed exponential moving averages that lag only slightly behind price changes. 
// It can help short-term investors and day traders profit in volatile markets by signaling price 
// reversal points, which can indicate potentially lucrative times to buy or sell. The APZ can be 
// implemented as part of an automated trading system and can be applied to the charts of all tradeable assets.
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////

study(title="Adaptive Price Zone Strategy", shorttitle="APZ", overlay = true)
nPeriods = input(20, minval=1)
nBandPct = input(2, minval=0)
xHL = high - low
nP = ceil(sqrt(nPeriods))
xVal1 = ema(ema(close,nP), nP)
xVal2 = ema(ema(xHL,nP), nP)
UpBand = nBandPct * xVal2 + xVal1
DnBand = xVal1 - nBandPct * xVal2
pos = 0
pos := iff(low < DnBand , 1,
	   iff(high > UpBand, -1, pos[1])) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
