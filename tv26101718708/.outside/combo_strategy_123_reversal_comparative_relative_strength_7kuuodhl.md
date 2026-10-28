# Combo Strategy 123 Reversal & Comparative Relative Strength

- url: https://www.tradingview.com/script/7kUuOdHl-Combo-Strategy-123-Reversal-Comparative-Relative-Strength/
- type: indicator
- pine_id: PUB;g6hod0yC6bQAej6lvzvj5JMWDcMquGtz
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
 Comparative Relative Strength Strategy for ES

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 29/10/2019
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
// Comparative Relative Strength Strategy for ES
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

fADX(Len) =>
    up = change(high)
    down = -change(low)
    trur = rma(tr, Len)
    plus = fixnan(100 * rma(up > down and up > 0 ? up : 0, Len) / trur)
    minus = fixnan(100 * rma(down > up and down > 0 ? down : 0, Len) / trur)
    sum = plus + minus 
    100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), Len)

CRS(a, b, len, BuyBand, SellBand, CloseBand) =>
    pos = 0.0
    as = security(a, timeframe.period, close) 
    bs = security(b, timeframe.period, close) 
    nRes = sma(as/bs, len)
    pos := iff(nRes > BuyBand, 1,
	         iff(nRes < SellBand, -1,
	          iff(pos[1] == 1 and nRes < CloseBand, 0,
    	       iff(pos[1] == -1 and nRes > CloseBand, 0, nz(pos[1], 0)))))
    pos

study(title="Combo Strategy 123 Reversal & Comparative Relative Strength", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
a = syminfo.tickerid 
b = input("SPX500", type=input.symbol) 
LengthCRS = input(10) 
BuyBand = input(0.9988, step = 0.0001)
SellBand = input(0.9960, step = 0.0001)
CloseBand = input(0.9975, step = 0.0001)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posCRS = CRS(a, b, LengthCRS, BuyBand, SellBand, CloseBand)
pos = iff(posReversal123 == 1 and posCRS == 1 , 1,
	   iff(posReversal123 == -1 and posCRS == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
