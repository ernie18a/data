# Finite Volume Elements (FVE) Strategy

- url: https://www.tradingview.com/script/DWEa0qFz-Finite-Volume-Elements-FVE-Strategy/
- type: indicator
- pine_id: PUB;62dfYKOFwRuq3kkHfDcqC4ss4hY4L3tQ
- version: 1.0

## Description

The FVE is a pure volume indicator. Unlike most of the other indicators 
 (except OBV), price change doesn?t come into the equation for the FVE (price 
 is not multiplied by volume), but is only used to determine whether money is 
 flowing in or out of the stock. This is contrary to the current trend in the 
 design of modern money flow indicators. The author decided against a price-volume 
 indicator for the following reasons:
 - A pure volume indicator has more power to contradict.
 - The number of buyers or sellers (which is assessed by volume) will be the same, 
     regardless of the price fluctuation.
 - Price-volume indicators tend to spike excessively at breakouts or breakdowns.

 WARNING:
  - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 22/05/2014
// The FVE is a pure volume indicator. Unlike most of the other indicators 
// (except OBV), price change doesn?t come into the equation for the FVE (price 
// is not multiplied by volume), but is only used to determine whether money is 
// flowing in or out of the stock. This is contrary to the current trend in the 
// design of modern money flow indicators. The author decided against a price-volume 
// indicator for the following reasons:
// - A pure volume indicator has more power to contradict.
// - The number of buyers or sellers (which is assessed by volume) will be the same, 
//     regardless of the price fluctuation.
// - Price-volume indicators tend to spike excessively at breakouts or breakdowns.
//
// WARNING:
//  - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Finite Volume Elements (FVE) Strategy", shorttitle="FVE")
Period = input(22, minval=1)
Factor = input(0.3, minval=1)
xhl2 = hl2
xhlc3 = hlc3
xClose = close
xVolume = volume
xSMAV = sma(xVolume, Period)
nMF = xClose - xhl2 + xhlc3 - xhlc3[1]
nVlm = iff(nMF > Factor * xClose / 100,  xVolume, 
         iff(nMF < -Factor * xClose / 100, -xVolume, 0))
nRes = nz(nRes[1],0) + ((nVlm / xSMAV) / Period) * 100
pos = iff(nRes > nRes[1] and nRes > nRes[2], 1,
         iff(nRes < nRes[1] and nRes < nRes[2], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="FVE")
````
