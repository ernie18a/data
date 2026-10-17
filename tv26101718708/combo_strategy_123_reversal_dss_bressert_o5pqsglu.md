# Combo Strategy 123 Reversal & DSS Bressert

- url: https://www.tradingview.com/script/O5pqSglu-Combo-Strategy-123-Reversal-DSS-Bressert/
- type: indicator
- pine_id: PUB;4ZwiNmrhK1qSFd9MTiKXezQl6x3Of8ji
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
 Double Smoothed Stochastics (DSS) is designed by William Blaw. 
 It attempts to combine moving average methods with oscillator principles. 

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 11/03/2020
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
// Double Smoothed Stochastics (DSS) is designed by William Blaw. 
// It attempts to combine moving average methods with oscillator principles. 
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

DSSB(PDS, EMAlen,TriggerLen,Overbought,Oversold) =>
    pos = 0
    xPreCalc = ema(stoch(close, high, low, PDS), EMAlen)
    xDSS = ema(stoch(xPreCalc, xPreCalc, xPreCalc, PDS), EMAlen)
    xTrigger = ema(xDSS, TriggerLen)
    pos := iff(xTrigger < xDSS and xTrigger < Oversold, -1,
	         iff(xTrigger > xDSS and xTrigger > Overbought, 1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & DSS Bressert", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
PDS = input(10, minval=1)
EMAlen = input(9, minval=1)
TriggerLen = input(5, minval=1)
Overbought = input(80, minval=1)
Oversold = input(20, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posDSS = DSSB(PDS, EMAlen,TriggerLen,Overbought,Oversold)
pos = iff(posReversal123 == 1 and posDSS == 1 , 1,
	   iff(posReversal123 == -1 and posDSS == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
