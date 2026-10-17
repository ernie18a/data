# Combo Strategy 123 Reversal & Bear Power

- url: https://www.tradingview.com/script/LsjPvhu8-Combo-Strategy-123-Reversal-Bear-Power/
- type: indicator
- pine_id: PUB;bUkiSai8GYfJ7TLMoP45XFiu2AJqfTLr
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
  Bear Power Indicator
  To get more information please see "Bull And Bear Balance Indicator" 
  by Vadim Gimelfarb. 

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/05/2019
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
//  Bear Power Indicator
//  To get more information please see "Bull And Bear Balance Indicator" 
//  by Vadim Gimelfarb. 
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

BearPower(SellLevel, BuyLevel) =>
    value =  iff (close < open ,  
              iff (close[1] > open ,  max(close - open, high - low), high - low), 
               iff (close > open, 
                 iff(close[1] > open, max(close[1] - low, high - close), max(open - low, high - close)), 
                  iff(high - close > close - low, 
                   iff (close[1] > open, max(close[1] - open, high - low), high - low), 
                     iff (high - close < close - low, 
                      iff(close > open, max(close - low, high - close),open - low), 
                       iff (close > open, max(close[1] - open, high - close),
                         iff(close[1] < open, max(open - low, high - close), high - low))))))
    pos = 0.0
    pos := iff(value > SellLevel, -1,
	   iff(value <= BuyLevel, 1, nz(pos[1], 0))) 

    pos

study(title="Combo Strategy 123 Reversal & Bear Power", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
SellLevel = input(30)
BuyLevel = input(3)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posBearPower = BearPower(SellLevel, BuyLevel)
pos = iff(posReversal123 == 1 and posBearPower == 1 , 1,
	   iff(posReversal123 == -1 and posBearPower == -1, -1, 0)) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
````
