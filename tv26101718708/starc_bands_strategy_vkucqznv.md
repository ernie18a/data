# STARC Bands Strategy

- url: https://www.tradingview.com/script/VKUCQZnV-STARC-Bands-Strategy/
- type: indicator
- pine_id: PUB;X5kRZMdLF6pSoGlJE5L06Pfi5tGnBlQa
- version: 1.0

## Description

A type of technical indicator that is created by plotting two bands around 
 a short-term simple moving average (SMA) of an underlying asset's price. 
 The upper band is created by adding a value of the average true range 
 (ATR) - a popular indicator used by technical traders - to the moving average. 
 The lower band is created by subtracting a value of the ATR from the SMA.
 STARC is an acronym for Stoller Average Range Channels. The indicator is 
 named after its creator, Manning Stoller.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 20/04/2018
// A type of technical indicator that is created by plotting two bands around 
// a short-term simple moving average (SMA) of an underlying asset's price. 
// The upper band is created by adding a value of the average true range 
// (ATR) - a popular indicator used by technical traders - to the moving average. 
// The lower band is created by subtracting a value of the ATR from the SMA.
// STARC is an acronym for Stoller Average Range Channels. The indicator is 
// named after its creator, Manning Stoller.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="STARC Bands Strategy", overlay = true)
LengthMA = input(5, minval=1)
LengthATR = input(15, minval=1)
K = input(1.33, minval=0.01, step = 0.01)
xMA = sma(close, LengthMA)
xATR = atr(LengthATR)
xSTARCBandUp = xMA + xATR * K
xSTARCBandDn = xMA - xATR * K
pos = iff(close > xSTARCBandUp, 1,
       iff(close < xSTARCBandDn, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xMA, color=blue, title="MA")
plot(xSTARCBandUp, color = green, title="UpBand")
plot(xSTARCBandDn, color=red, title="DnBand")
````
