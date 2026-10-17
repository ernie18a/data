# Combo Strategy 123 Reversal & Extracting The Trend

- url: https://www.tradingview.com/script/NdfSHPPJ-Combo-Strategy-123-Reversal-Extracting-The-Trend/
- type: indicator
- pine_id: PUB;jiQqeLybPtUm8d5SEw4H4q5niejAFL1P
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
 Extracting The Trend
 The related article is copyrighted material from Stocks & Commodities Mar 2010

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 31/07/2020
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
// Extracting The Trend
// The related article is copyrighted material from Stocks & Commodities Mar 2010
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


ETT(Length,Delta,Trigger) =>
    pos = 0
    xBandpassFilter = 0.0
    xPrice = hl2
    beta = cos(3.1415 * (360 / Length) / 180)
    gamma = 1 / cos(3.1415 * (720 * Delta / Length) / 180)
    alpha = gamma - sqrt(gamma * gamma - 1)
    xBandpassFilter := 0.5 * (1 - alpha) * (xPrice - xPrice[2]) + beta * (1 + alpha) * nz(xBandpassFilter[1]) - alpha * nz(xBandpassFilter[2])
    xMean = sma(xBandpassFilter, 2 * Length)
    pos :=iff(xMean > Trigger, 1,
	       iff(xMean < Trigger, -1, nz(pos[1], 0)))     
    pos

study(title="Combo Strategy 123 Reversal & Extracting The Trend", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthETT = input(20, minval=1)
Delta = input(0.5)
Trigger = input(0)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posETT = ETT(LengthETT,Delta,Trigger)
pos = iff(posReversal123 == 1 and posETT == 1 , 1,
	   iff(posReversal123 == -1 and posETT == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
