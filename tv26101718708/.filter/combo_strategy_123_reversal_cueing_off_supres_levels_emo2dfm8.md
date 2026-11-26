# Combo Strategy 123 Reversal & Cueing Off Sup/Res Levels

- url: https://www.tradingview.com/script/emO2dFm8-Combo-Strategy-123-Reversal-Cueing-Off-Sup-Res-Levels/
- type: indicator
- pine_id: PUB;kCHBYggUkQ6byWmI0CAYRDnzNfam47KT
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
 Cueing Off Support And Resistance Levels, by Thom Hartle 
 modified by HPotter for trade signals.
 The related article is copyrighted material from Stocks & Commodities.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 12/11/2019
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
// Cueing Off Support And Resistance Levels, by Thom Hartle 
// modified by HPotter for trade signals.
// The related article is copyrighted material from Stocks & Commodities.
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

COSRL(SigVal) =>
    pos = 0.0
    xLow = low
    xHigh = high
    xHighD = security(syminfo.tickerid,"W", high[1])
    xLowD  = security(syminfo.tickerid,"W", low[1])
    sigpre1 = iff(xHigh <= xLowD, -1,
                 iff(xLow >= xHighD, 1, nz(pos[1], 0))) 
    sigpre2 = iff( xHigh <= xHighD, -1,
                 iff(xLow >= xLowD, 1, nz(pos[1], 0))) 
    pos := SigVal ? sigpre1 : sigpre2
    pos

study(title="Combo Strategy 123 Reversal & Cueing Off Support And Resistance Levels", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
SigVal = input(true, title="To Line \ From Line")
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posCOSRL = COSRL(SigVal)
pos = iff(posReversal123 == 1 and posCOSRL == 1 , 1,
	   iff(posReversal123 == -1 and posCOSRL == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
