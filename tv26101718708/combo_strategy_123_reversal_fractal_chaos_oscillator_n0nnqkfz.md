# Combo Strategy 123 Reversal & Fractal Chaos Oscillator

- url: https://www.tradingview.com/script/n0NnQKfz-Combo-Strategy-123-Reversal-Fractal-Chaos-Oscillator/
- type: indicator
- pine_id: PUB;cqh790skpblQZilVqCiN9qMDCwkXjDHj
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
   The value of Fractal Chaos Oscillator is calculated as the difference between 
 the most subtle movements of the market. In general, its value moves between 
 -1.000 and 1.000. The higher the value of the Fractal Chaos Oscillator, the 
 more one can say that it follows a certain trend – an increase in prices trend, 
 or a decrease in prices trend.

   Being an indicator expressed in a numeric value, traders say that this is an 
 indicator that puts a value on the trendiness of the markets. When the FCO reaches 
 a high value, they initiate the “buy” operation, contrarily when the FCO reaches a 
 low value, they signal the “sell” action. This is an excellent indicator to use in 
 intra-day trading.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/10/2020
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
//   The value of Fractal Chaos Oscillator is calculated as the difference between 
// the most subtle movements of the market. In general, its value moves between 
// -1.000 and 1.000. The higher the value of the Fractal Chaos Oscillator, the 
// more one can say that it follows a certain trend – an increase in prices trend, 
// or a decrease in prices trend.
//
//   Being an indicator expressed in a numeric value, traders say that this is an 
// indicator that puts a value on the trendiness of the markets. When the FCO reaches 
// a high value, they initiate the “buy” operation, contrarily when the FCO reaches a 
// low value, they signal the “sell” action. This is an excellent indicator to use in 
// intra-day trading.
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

fractalUp(pattern) =>
    p = high[pattern+1]
    okl = 1
    okr = 1
    res = 0.0
	for i = pattern to 1
		okl := iff(high[i] < high[i+1] and okl == 1 , 1, 0)
	for i = pattern+2 to pattern*2+1
		okr := iff(high[i] < high[i-1] and okr == 1, 1, 0)
	res := iff(okl == 1 and okr == 1, p, res[1])
    res

fractalDn(pattern) =>
    p = low[pattern+1]
    okl = 1
    okr = 1
    res = 0.0
	for i = pattern to 1
		okl := iff(low[i] > low[i+1] and okl == 1 , 1, 0)
	for i = pattern+2 to pattern*2+1
		okr := iff(low[i] > low[i-1] and okr == 1, 1, 0)
	res := iff(okl == 1 and okr == 1, p, res[1])
    res

FCO(Pattern) =>
    pos = 0.0
    xUpper = fractalUp(Pattern) 
    xLower = fractalDn(Pattern)
    xRes = iff(xUpper != xUpper[1], 1, 
             iff(xLower != xLower[1], -1, 0))
    pos := iff(xRes == 1, 1,
             iff(xRes == -1, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & Fractal Chaos Oscillator", shorttitle="Combo", overlay = true)
Length = input(15, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
Pattern = input(1, minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posFCO = FCO(Pattern)
pos = iff(posReversal123 == 1 and posFCO == 1 , 1,
	   iff(posReversal123 == -1 and posFCO == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
