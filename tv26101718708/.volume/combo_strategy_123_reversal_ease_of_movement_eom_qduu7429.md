# Combo Strategy 123 Reversal & Ease of Movement (EOM)

- url: https://www.tradingview.com/script/qdUU7429-Combo-Strategy-123-Reversal-Ease-of-Movement-EOM/
- type: indicator
- pine_id: PUB;kAVNGyfpsBAvmi7hmcyPc3xlpFoe5nDY
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
 This indicator gauges the magnitude of price and volume movement. 
 The indicator returns both positive and negative values where a 
 positive value means the market has moved up from yesterday's value 
 and a negative value means the market has moved down. A large positive 
 or large negative value indicates a large move in price and/or lighter 
 volume. A small positive or small negative value indicates a small move 
 in price and/or heavier volume.
 A positive or negative numeric value. A positive value means the market 
 has moved up from yesterday's value, whereas, a negative value means the 
 market has moved down. 

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/04/2020
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
// This indicator gauges the magnitude of price and volume movement. 
// The indicator returns both positive and negative values where a 
// positive value means the market has moved up from yesterday's value 
// and a negative value means the market has moved down. A large positive 
// or large negative value indicates a large move in price and/or lighter 
// volume. A small positive or small negative value indicates a small move 
// in price and/or heavier volume.
// A positive or negative numeric value. A positive value means the market 
// has moved up from yesterday's value, whereas, a negative value means the 
// market has moved down. 
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

EOM(BuyZone, SellZone) =>
    pos = 0
    xHigh = high
    xLow = low
    xVolume = volume
    xHalfRange = (xHigh - xLow) * 0.5
    xMidpointMove = mom(xHalfRange, 1)
    xBoxRatio = iff((xHigh - xLow) != 0, xVolume / (xHigh - xLow), 0)
    nRes = iff(xBoxRatio != 0, 1000000 * ((xMidpointMove - xMidpointMove[1]) / xBoxRatio), 0)
    pos := iff(nRes > BuyZone, 1,
             iff(nRes < SellZone, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Ease of Movement (EOM)", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
BuyZone = input(4000, minval=1)
SellZone = input(-4000)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posEOM = EOM(BuyZone, SellZone)
pos = iff(posReversal123 == 1 and posEOM == 1 , 1,
	   iff(posReversal123 == -1 and posEOM == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
