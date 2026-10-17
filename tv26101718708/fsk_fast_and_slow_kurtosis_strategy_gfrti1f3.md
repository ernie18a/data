# FSK (Fast and Slow Kurtosis) Strategy

- url: https://www.tradingview.com/script/gFRTI1F3-FSK-Fast-and-Slow-Kurtosis-Strategy/
- type: indicator
- pine_id: PUB;155
- version: -1.0

## Description

This indicator plots the Fast & Slow Kurtosis. The Kurtosis is a market
    sentiment indicator. The Kurtosis is constructed from three different parts.
    The Kurtosis, the Fast Kurtosis(FK), and the Fast/Slow Kurtosis(FSK).

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 26/06/2014
// This indicator plots the Fast & Slow Kurtosis. The Kurtosis is a market
// sentiment indicator. The Kurtosis is constructed from three different parts.
// The Kurtosis, the Fast Kurtosis(FK), and the Fast/Slow Kurtosis(FSK).
////////////////////////////////////////////////////////////
study(title="FSK (Fast and Slow Kurtosis)", shorttitle="FSK (Fast and Slow Kurtosis)")
BuyZone = input(0)
hline(BuyZone, color=green, linestyle=line)
xMOM_R = mom(mom(close, 3), 1)
xMOM_RAvr = ema(xMOM_R, 65)
xMOM_RWAvr = wma(xMOM_RAvr, 3)
pos =	iff(xMOM_RAvr > BuyZone and xMOM_RWAvr > BuyZone, 1,-1) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xMOM_RAvr, color=blue, title="FK")
plot(xMOM_RWAvr, color=red, title="FSK")
````
