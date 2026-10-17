# Combo Strategy 123 Reversal & Breakout Range Short

- url: https://www.tradingview.com/script/4hRL84sg-Combo-Strategy-123-Reversal-Breakout-Range-Short/
- type: indicator
- pine_id: PUB;oZY329hGTstq1oHGMfcnelXjxUMTbll3
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
    Breakout Range Short Strategy

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 28/06/2019
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
//    Breakout Range Short Strategy
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

BreakoutRangeShort(look_bak) =>
    pos = 0
    xLowest = lowest(low, look_bak)
    pos :=	iff(low < xLowest[1], -1, 0) 
    pos

study(title="Combo Strategy 123 Reversal & Breakout Range Short", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
look_bak = input(4, minval=1, title="Look Bak")
reverse = input(false, title="Trade reverse")
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBreakoutRangeShort = BreakoutRangeShort(look_bak)
pos = iff(posReversal123 == 1 and posBreakoutRangeShort == 1 , 1,
	   iff(posReversal123 == -1 and posBreakoutRangeShort == -1, -1, 0)) 
barcolor(pos == -1 ? color.red: pos == 1 ? color.green : color.blue )
````
