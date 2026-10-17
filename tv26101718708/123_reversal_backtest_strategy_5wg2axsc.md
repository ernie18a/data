# 1-2-3 Reversal Backtest Strategy

- url: https://www.tradingview.com/script/5WG2Axsc-1-2-3-Reversal-Backtest-Strategy/
- type: strategy
- pine_id: PUB;0IjKNlAnRPEmhaJGyo730Q0fLSMtZhQl
- version: 1.0

## Description

This is backtesting script. 
This System was created from the Book "How I Tripled My Money In The 
Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
The strategy buys at market, if close price is higher than the previous close 
during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
The strategy sells at market, if close price is lower than the previous close price 
during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 23/06/2014
// This System was created from the Book "How I Tripled My Money In The 
// Futures Market" by Ulf Jensen, Page 183. This is reverse type of strategies.
// The strategy buys at market, if close price is higher than the previous close 
// during 2 days and the meaning of 9-days Stochastic Slow Oscillator is lower than 50. 
// The strategy sells at market, if close price is lower than the previous close price 
// during 2 days and the meaning of 9-days Stochastic Fast Oscillator is higher than 50.
////////////////////////////////////////////////////////////
strategy(title="1-2-3 Reversal Backtest Strategy", shorttitle="1-2-3 Reversal Strategy")
Length = input(14, minval=1)
KSmoothing = input(1, minval=1)
DLength = input(3, minval=1)
Level = input(50, minval=1)
vFast = sma(stoch(close, high, low, Length), KSmoothing) // stoch(close, high, low, Length)
vSlow = sma(vFast, DLength)
pos = iff(close[2] < close[1] and close > close[1] and vFast < vSlow and vFast > Level, 1,
	  iff(close[2] > close[1] and close < close[1] and vFast > vSlow and vFast < Level, -1, nz(pos[1], 0))) 
if (pos == 1) 
    strategy.entry("Long", strategy.long)
if (pos == -1)
    strategy.entry("Short", strategy.short)
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(vFast, color=red, title="stochK")
plot(vSlow, color=blue, title="stochD")
````
