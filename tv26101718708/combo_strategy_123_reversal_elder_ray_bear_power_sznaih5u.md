# Combo Strategy 123 Reversal & Elder Ray (Bear Power) 

- url: https://www.tradingview.com/script/szNAIh5U-Combo-Strategy-123-Reversal-Elder-Ray-Bear-Power/
- type: indicator
- pine_id: PUB;huIz6H1BCzhSFnWHtb0BGyWyYYAUHRd3
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
 Developed by Dr Alexander Elder, the Elder-ray indicator measures buying 
 and selling pressure in the market. The Elder-ray is often used as part 
 of the Triple Screen trading system but may also be used on its own.
 Dr Elder uses a 13-day exponential moving average (EMA) to indicate the 
 market consensus of value. Bull Power measures the ability of buyers to 
 drive prices above the consensus of value. Bear Power reflects the ability 
 of sellers to drive prices below the average consensus of value.
 Bull Power is calculated by subtracting the 13-day EMA from the day's High. 
 Bear power subtracts the 13-day EMA from the day's Low.
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/04/2020
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
// Developed by Dr Alexander Elder, the Elder-ray indicator measures buying 
// and selling pressure in the market. The Elder-ray is often used as part 
// of the Triple Screen trading system but may also be used on its own.
// Dr Elder uses a 13-day exponential moving average (EMA) to indicate the 
// market consensus of value. Bull Power measures the ability of buyers to 
// drive prices above the consensus of value. Bear Power reflects the ability 
// of sellers to drive prices below the average consensus of value.
// Bull Power is calculated by subtracting the 13-day EMA from the day's High. 
// Bear power subtracts the 13-day EMA from the day's Low.
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
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

BP(Trigger,Length) =>
    pos = 0
    DayHigh = 0.0
    xPrice = close
    xMA = ema(xPrice,Length)
    DayHigh := iff(dayofmonth != dayofmonth[1], high, max(high, nz(DayHigh[1])))
    nRes = DayHigh - xMA
    pos := iff(nRes > Trigger, 1,
    	     iff(nRes < Trigger, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Elder Ray (Bear Power) ", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthBP = input(13, minval=1)
Trigger = input(0)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBP = BP(Trigger,LengthBP)
pos = iff(posReversal123 == 1 and posBP == 1 , 1,
	   iff(posReversal123 == -1 and posBP == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
