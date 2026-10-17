# Combo Strategy 123 Reversal & Finite Volume Elements (FVE)

- url: https://www.tradingview.com/script/qBd6TeV0-Combo-Strategy-123-Reversal-Finite-Volume-Elements-FVE/
- type: indicator
- pine_id: PUB;fKTHIRegTSeN3b5X4y9eBOr6URHZAq3J
- version: 1.0

## Description

This is combo strategies for get a cumulative signal. 

 First strategy
 This System was created from the Book "How I Tripled My Money In The 
 Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
 The strategy buys at market, if close price is higher than the previous close 
 during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
 The strategy sells at market, if close price is lower than the previous close price 
 during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.

 Second strategy
 The FVE is a pure volume indicator. Unlike most of the other indicators 
 (except OBV), price change doesn`t come into the equation for the FVE (price 
 is not multiplied by volume), but is only used to determine whether money is 
 flowing in or out of the stock. This is contrary to the current trend in the 
 design of modern money flow indicators. The author decided against a price-volume 
 indicator for the following reasons:
 - A pure volume indicator has more power to contradict.
 - The number of buyers or sellers (which is assessed by volume) will be the same, 
     regardless of the price fluctuation.
 - Price-volume indicators tend to spike excessively at breakouts or breakdowns.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 18/08/2020
// This is combo strategies for get a cumulative signal. 
//
// First strategy
// This System was created from the Book "How I Tripled My Money In The 
// Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
// The strategy buys at market, if close price is higher than the previous close 
// during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
// The strategy sells at market, if close price is lower than the previous close price 
// during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.
//
// Second strategy
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
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
Reversal123(Length, KSmoothing, DLength, Level) =>
    vFast = sma(stoch(close, high, low, Length), KSmoothing) 
    vSlow = sma(vFast, DLength)
    pos = 0.0
    pos := iff(close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > Level, 1,
	         iff(close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < Level, -1, nz(pos[1], 0))) 
	pos


FVE(Period,Factor) =>
    pos = 0
    nRes = 0.0
    xhl2 = hl2
    xhlc3 = hlc3
    xClose = close
    xVolume = volume
    xSMAV = sma(xVolume, Period)
    nMF = xClose - xhl2 + xhlc3 - xhlc3[1]
    nVlm = iff(nMF > Factor * xClose / 100,  xVolume, 
             iff(nMF < -Factor * xClose / 100, -xVolume, 0))
    nRes := nz(nRes[1],0) + ((nVlm / xSMAV) / Period) * 100
    pos := iff(nRes > nRes[1] and nRes > nRes[2], 1,
             iff(nRes < nRes[1] and nRes < nRes[2], -1, nz(pos[1], 0)))   
    pos

study(title="Combo Strategy 123 Reversal & Finite Volume Elements (FVE)", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
Period = input(22, minval=1)
Factor = input(0.3, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posFVE = FVE(Period,Factor)
pos = iff(posReversal123 == 1 and posFVE == 1 , 1,
	   iff(posReversal123 == -1 and posFVE == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
