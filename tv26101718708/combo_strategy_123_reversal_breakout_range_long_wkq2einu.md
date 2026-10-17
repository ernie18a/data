# Combo Strategy 123 Reversal & Breakout Range Long

- url: https://www.tradingview.com/script/WKQ2eINu-Combo-Strategy-123-Reversal-Breakout-Range-Long/
- type: indicator
- pine_id: PUB;MmWAFH20z0ivdgf22EIkLm3zS64Cwtmr
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
    Breakout Range Long Strategy

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 25/06/2019
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
//    Breakout Range Long Strategy
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

BreakoutRangeLong(look_bak) =>
    pos = 0
    xHighest = highest(high, look_bak)
    pos := iff(high > xHighest[1], 1, 0) 
    pos

study(title="Combo Strategy 123 Reversal & Breakout Range Long", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
look_bak = input(4, minval=1, title="Look Bak")
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBreakoutRangeLong = BreakoutRangeLong(look_bak)
pos = iff(posReversal123 == 1 and posBreakoutRangeLong == 1 , 1,
	   iff(posReversal123 == -1 and posBreakoutRangeLong == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
