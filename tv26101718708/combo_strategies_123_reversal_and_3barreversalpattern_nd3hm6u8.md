# Combo Strategies 123 Reversal and 3-Bar-Reversal-Pattern

- url: https://www.tradingview.com/script/nD3hM6U8-Combo-Strategies-123-Reversal-and-3-Bar-Reversal-Pattern/
- type: indicator
- pine_id: PUB;7rkxXbqQGneT7sdELj2RhD98D2C5r9Ca
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

 Secon strategy
 This startegy based on 3-day pattern reversal described in "Are Three-Bar 
 Patterns Reliable For Stocks" article by Thomas Bulkowski, presented in 
 January,2000 issue of Stocks&Commodities magazine.
 That pattern conforms to the following rules:
 - It uses daily prices, not intraday or weekly prices;
 - The middle day of the three-day pattern has the lowest low of the three days, with no ties allowed;
 - The last day must have a close above the prior day's high, with no ties allowed;
 - Each day must have a nonzero trading range. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 16/04/2019
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
// This startegy based on 3-day pattern reversal described in "Are Three-Bar 
// Patterns Reliable For Stocks" article by Thomas Bulkowski, presented in 
// January,2000 issue of Stocks&Commodities magazine.
// That pattern conforms to the following rules:
// - It uses daily prices, not intraday or weekly prices;
// - The middle day of the three-day pattern has the lowest low of the three days, with no ties allowed;
// - The last day must have a close above the prior day's high, with no ties allowed;
// - Each day must have a nonzero trading range. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
Reversal123(Length, KSmoothing, DLength, Level) =>
    vFast = sma(stoch(close, high, low, Length), KSmoothing) 
    vSlow = sma(vFast, DLength)
    pos = 0.0
    pos := iff(close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > Level, 1,
	         iff(close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < Level, -1, nz(pos[1], 0))) 
	pos

BarReversalPattern() =>
    pos = 0.0
    pos := iff(open[2] > close[2] and high[1] < high[2] and low[1] < low[2] and low[0] > low[1] and high[0] > high[1], 1,
	         iff(open[2] < close[2] and high[1] > high[2] and low[1] > low[2] and high[0] < high[1] and low[0] < low[1], -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategies 123 Reversal and 3-Bar-Reversal-Pattern", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
pos3BarReversalPattern = BarReversalPattern()
pos = iff(posReversal123 == 1 and pos3BarReversalPattern == 1 , 1,
	   iff(posReversal123 == -1 and pos3BarReversalPattern == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
