# Combo Strategy 123 Reversal & CMO & WMA

- url: https://www.tradingview.com/script/vbkdIH2t-Combo-Strategy-123-Reversal-CMO-WMA/
- type: indicator
- pine_id: PUB;RXEufkiWL8FGIGvufD1jOHQtUSS09j0c
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
    This indicator plots Chandre Momentum Oscillator and its WMA on the 
    same chart. This indicator plots the absolute value of CMO.
    The CMO is closely related to, yet unique from, other momentum oriented 
    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
    etc. It is most closely related to Welles Wilder?s RSI, yet it differs 
    in several ways:
    - It uses data for both up days and down days in the numerator, thereby 
        directly measuring momentum;
    - The calculations are applied on unsmoothed data. Therefore, short-term 
        extreme movements in price are not hidden. Once calculated, smoothing 
        can be applied to the CMO, if desired;
    - The scale is bounded between +100 and -100, thereby allowing you to clearly 
        see changes in net momentum using the 0 level. The bounded scale also allows 
        you to conveniently compare values across different securities.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 19/08/2019
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
//    This indicator plots Chandre Momentum Oscillator and its WMA on the 
//    same chart. This indicator plots the absolute value of CMO.
//    The CMO is closely related to, yet unique from, other momentum oriented 
//    indicators such as Relative Strength Index, Stochastic, Rate-of-Change, 
//    etc. It is most closely related to Welles Wilder?s RSI, yet it differs 
//    in several ways:
//    - It uses data for both up days and down days in the numerator, thereby 
//        directly measuring momentum;
//    - The calculations are applied on unsmoothed data. Therefore, short-term 
//        extreme movements in price are not hidden. Once calculated, smoothing 
//        can be applied to the CMO, if desired;
//    - The scale is bounded between +100 and -100, thereby allowing you to clearly 
//        see changes in net momentum using the 0 level. The bounded scale also allows 
//        you to conveniently compare values across different securities.
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

CMOWMA(Length, LengthWMA) =>
    pos = 0
    xMom = abs(close - close[1])
    xSMA_mom = sma(xMom, Length)
    xMomLength = close - close[Length]
    nRes = 100 * (xMomLength / (xSMA_mom * Length))
    xWMACMO = wma(nRes, LengthWMA)
    pos := iff(nRes > xWMACMO, 1,
    	   iff(nRes <= xWMACMO, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & CMO & WMA", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthCMO = input(9, minval=1)
LengthWMA = input(9, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posCMOWMA = CMOWMA(LengthCMO, LengthWMA)
pos = iff(posReversal123 == 1 and posCMOWMA == 1 , 1,
	   iff(posReversal123 == -1 and posCMOWMA == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
