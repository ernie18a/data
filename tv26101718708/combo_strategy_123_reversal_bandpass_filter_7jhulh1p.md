# Combo Strategy 123 Reversal & Bandpass Filter

- url: https://www.tradingview.com/script/7jhulH1P-Combo-Strategy-123-Reversal-Bandpass-Filter/
- type: indicator
- pine_id: PUB;ALoNeQuGeEOttVsm34Aqk3If0RfGKsr8
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
 The related article is copyrighted material from
 Stocks & Commodities Mar 2010
 You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 20/05/2019
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
// Secon strategy
// The related article is copyrighted material from
// Stocks & Commodities Mar 2010
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


Bandpass_Filter(Length, Delta, TriggerLevel) =>
    xPrice = hl2
    beta = cos(3.14 * (360 / Length) / 180)
    gamma = 1 / cos(3.14 * (720 * Delta / Length) / 180)
    alpha = gamma - sqrt(gamma * gamma - 1)
    BP = 0.0
    pos = 0.0
    BP := 0.5 * (1 - alpha) * (xPrice - xPrice[2]) + beta * (1 + alpha) * nz(BP[1]) - alpha * nz(BP[2])
    pos := iff(BP > TriggerLevel, 1,
	       iff(BP <= TriggerLevel, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Bandpass Filter", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthBF = input(20, minval=1)
Delta = input(0.5)
TriggerLevel = input(0)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBandpass_Filter = Bandpass_Filter(LengthBF, Delta, TriggerLevel)
pos = iff(posReversal123 == 1 and posBandpass_Filter == 1 , 1,
	   iff(posReversal123 == -1 and posBandpass_Filter == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
