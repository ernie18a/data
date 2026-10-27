# Volatility Finite Volume Elements Strategy

- url: https://www.tradingview.com/script/uk8953F3-Volatility-Finite-Volume-Elements-Strategy/
- type: indicator
- pine_id: PUB;iYvpbrJctn3yUMqscIHXDYHRK0WU7DNc
- version: 1.0

## Description

The FVE is a pure volume indicator. Unlike most of the other indicators 
 (except OBV), price change doesn?t come into the equation for the FVE 
 (price is not multiplied by volume), but is only used to determine whether 
 money is flowing in or out of the stock. This is contrary to the current trend 
 in the design of modern money flow indicators. The author decided against a 
 price-volume indicator for the following reasons:
 - A pure volume indicator has more power to contradict.
 - The number of buyers or sellers (which is assessed by volume) will be the same, 
 regardless of the price fluctuation.
 - Price-volume indicators tend to spike excessively at breakouts or breakdowns.
 This study is an addition to FVE indicator. Indicator plots different-coloured volume 
 bars depending on volatility.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 22/08/2017
// The FVE is a pure volume indicator. Unlike most of the other indicators 
// (except OBV), price change doesn?t come into the equation for the FVE 
// (price is not multiplied by volume), but is only used to determine whether 
// money is flowing in or out of the stock. This is contrary to the current trend 
// in the design of modern money flow indicators. The author decided against a 
// price-volume indicator for the following reasons:
// - A pure volume indicator has more power to contradict.
// - The number of buyers or sellers (which is assessed by volume) will be the same, 
// regardless of the price fluctuation.
// - Price-volume indicators tend to spike excessively at breakouts or breakdowns.
// This study is an addition to FVE indicator. Indicator plots different-coloured volume 
// bars depending on volatility.
////////////////////////////////////////////////////////////
study(title="Volatility Finite Volume Elements Strategy", shorttitle="FVI")
Samples = input(22, minval=1)
AvgLength = input(50, minval=1)
AlertPct = input(70, minval=1)
Cintra = input(0.1)
Cinter = input(0.1)
xVolume = volume
xClose = close
xhl2 = hl2
xhlc3 = hlc3
xMA = sma(xVolume, AvgLength)
xIntra = log(high) - log(low)
xInter = log(xhlc3) - log(xhlc3[1])
xStDevIntra = stdev(xIntra, Samples)
xStDevInter = stdev(xInter, Samples)
TP = xhlc3
TP1 = xhlc3[1]
Intra = xIntra
Vintra = xStDevIntra
Inter = xInter
Vinter = xStDevInter
CutOff = Cintra * Vintra + Cinter * Vinter
MF = xClose - xhl2 + TP - TP1
clr = iff(MF > CutOff * xClose, green, 
             iff(MF < -1 * CutOff * xClose, red,  blue))
pos =	iff(MF > CutOff * xClose, 1,
	    iff(MF < -1 * CutOff * xClose, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)             
plot(xVolume, color=clr, title="VBF")
plot(xMA, color=blue, title="VBF EMA")
````
