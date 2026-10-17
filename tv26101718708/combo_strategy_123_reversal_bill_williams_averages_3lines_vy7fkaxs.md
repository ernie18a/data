# Combo Strategy 123 Reversal & Bill Williams Averages. 3Lines

- url: https://www.tradingview.com/script/vy7fkAxS-Combo-Strategy-123-Reversal-Bill-Williams-Averages-3Lines/
- type: indicator
- pine_id: PUB;7jwLVFrMo23h17PijrH2daSPzLi4NZwg
- version: 1.0

## Description

This is combo strategies for get 
 a cumulative signal. Result signal will return 1 if two strategies 
 is long, -1 if all strategies is short and 0 if signals of strategies is not equal.

 First strategy
 This System was created from the Book "How I Tripled My Money In The 
 Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
 The strategy buys at market, if close price is higher than the previous close 
 during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
 The strategy sells at market, if close price is lower than the previous close price 
 during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.

 Second strategy
 This indicator calculates 3 Moving Averages for default values of
 13, 8 and 5 days, with displacement 8, 5 and 3 days: Median Price (High+Low/2).
 The most popular method of interpreting a moving average is to compare 
 the relationship between a moving average of the security's price with 
 the security's price itself (or between several moving averages).

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 17/06/2019
// This is combo strategies for get 
// a cumulative signal. Result signal will return 1 if two strategies 
// is long, -1 if all strategies is short and 0 if signals of strategies is not equal.
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
// This indicator calculates 3 Moving Averages for default values of
// 13, 8 and 5 days, with displacement 8, 5 and 3 days: Median Price (High+Low/2).
// The most popular method of interpreting a moving average is to compare 
// the relationship between a moving average of the security's price with 
// the security's price itself (or between several moving averages).
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

BillWilliamsAverages(LLength, MLength,SLength, LOffset,MOffset, SOffset ) =>
    xLSma = sma(hl2, LLength)[LOffset]
    xMSma = sma(hl2, MLength)[MOffset]
    xSSma = sma(hl2, SLength)[SOffset]
    pos = 0
    pos := iff(close < xSSma and xSSma < xMSma and xMSma < xLSma, -1,
    	   iff(close > xSSma and xSSma > xMSma and xMSma > xLSma, 1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Bill Williams Averages. 3Lines", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LLength = input(13, minval=1)
MLength = input(8,minval=1)
SLength = input(5,minval=1)
LOffset = input(8,minval=1)
MOffset = input(5,minval=1)
SOffset = input(3,minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBillWilliamsAverages = BillWilliamsAverages(LLength, MLength,SLength, LOffset, MOffset, SOffset)
pos = iff(posReversal123 == 1 and posBillWilliamsAverages == 1 , 1,
	   iff(posReversal123 == -1 and posBillWilliamsAverages == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
