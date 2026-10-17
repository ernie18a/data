# DAPD - Strategy

- url: https://www.tradingview.com/script/kg5ryuR1-DAPD-Strategy/
- type: indicator
- pine_id: PUB;174
- version: -1.0

## Description

It will be buy when high above previos DAPD high and sell if low below previos DAPD low
 This indicator is similar to Bollinger Bands. It based on DAPD - Daily
 Average Price Delta. DAPD is based upon a summation for each of the
 highs (hod) for the 21 days prior to today minus the summation for
 each of the lows (lod) for the last 21 days prior to today. The result
 of this calculation would then be divided by 21.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 04/07/2014
// This indicator is similar to Bollinger Bands. It based on DAPD - Daily
// Average Price Delta. DAPD is based upon a summation for each of the
// highs (hod) for the 21 days prior to today minus the summation for
// each of the lows (lod) for the last 21 days prior to today. The result
// of this calculation would then be divided by 21.
// It will be buy when high above previos DAPD high and sell if low below previos DAPD low
////////////////////////////////////////////////////////////
study(title="DAPD - Strategy", shorttitle="DAPD - Strategy", overlay = true)
Length = input(21, minval=1)
xHighSMA = sma(high, Length)
xLowSMA = sma(low, Length)        
nDAPD = xHighSMA - xLowSMA
nTop = high + nDAPD
nBottom = low - nDAPD
pos = iff(high > nTop[1], 1,
	    iff(low < nBottom[1], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(nTop, color=blue, title="Top DAPD")
plot(nBottom, color=blue, title="Bottom DAPD")
````
