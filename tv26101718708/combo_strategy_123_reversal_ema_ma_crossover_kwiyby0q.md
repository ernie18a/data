# Combo Strategy 123 Reversal & EMA & MA Crossover

- url: https://www.tradingview.com/script/KWIYbY0Q-Combo-Strategy-123-Reversal-EMA-MA-Crossover/
- type: indicator
- pine_id: PUB;sNoy7A8p5Ny0hI4dqj9yxpnr3HTAkTiE
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
 The Moving Average Crossover trading strategy is possibly the most popular
 trading strategy in the world of trading. First of them were written in the
 middle of XX century, when commodities trading strategies became popular.
 This strategy is a good example of so-called traditional strategies. 
 Traditional strategies are always long or short. That means they are never 
 out of the market. The concept of having a strategy that is always long or 
 short may be scary, particularly in today’s market where you don’t know what 
 is going to happen as far as risk on any one market. But a lot of traders 
 believe that the concept is still valid, especially for those of traders who 
 do their own research or their own discretionary trading. 
 This version uses crossover of moving average and its exponential moving average.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 16/06/2020
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
// The Moving Average Crossover trading strategy is possibly the most popular
// trading strategy in the world of trading. First of them were written in the
// middle of XX century, when commodities trading strategies became popular.
// This strategy is a good example of so-called traditional strategies. 
// Traditional strategies are always long or short. That means they are never 
// out of the market. The concept of having a strategy that is always long or 
// short may be scary, particularly in today’s market where you don’t know what 
// is going to happen as far as risk on any one market. But a lot of traders 
// believe that the concept is still valid, especially for those of traders who 
// do their own research or their own discretionary trading. 
// This version uses crossover of moving average and its exponential moving average.
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

MACross(LengthMA,LengthEMA) =>
    pos = 0
    xMA = sma(close, LengthMA)
    xEMA = ema(xMA, LengthEMA)
    pos := iff(xEMA < xMA , 1,
	       iff(xEMA > xMA, -1, nz(pos[1], 0))) 
    pos

study(title="Combo Strategy 123 Reversal & EMA & MA Crossover", shorttitle="Combo", overlay = true)
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
//-------------------------
LengthMA = input(10, minval=1)
LengthEMA = input(10,minval=1)
posReversal123 = Reversal123(Length, KSmoothing, DLength, Level)
posMACross = MACross(LengthMA,LengthEMA)
pos = iff(posReversal123 == 1 and posMACross == 1 , 1,
	   iff(posReversal123 == -1 and posMACross == -1, -1, 0)) 
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
