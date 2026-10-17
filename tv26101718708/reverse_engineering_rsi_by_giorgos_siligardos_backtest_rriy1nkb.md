# Reverse Engineering RSI, by Giorgos Siligardos Backtest

- url: https://www.tradingview.com/script/RrIy1nkb-Reverse-Engineering-RSI-by-Giorgos-Siligardos-Backtest/
- type: strategy
- pine_id: PUB;kncN62zjpDuuGmO4wzmmld9bDlu5qvXV
- version: 1.0

## Description

The related article is copyrighted material from
 Stocks & Commodities.

 You can change long to short in the Input Settings
 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 25/10/2017
// The related article is copyrighted material from
// Stocks & Commodities.
//
// You can change long to short in the Input Settings
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title="Reverse Engineering RSI, by Giorgos Siligardos", overlay = true)
Value = input(50, minval=1)
WildPer = input(14,minval=1)
reverse = input(false, title="Trade reverse")
ExpPer = 2 * WildPer - 1
K = 2 / (ExpPer + 1)
AUC = iff(close > close[1], K * (close - close[1]) + (1 - K) * nz(AUC[1], 1), (1-K) * nz(AUC[1], 1))
ADC = iff(close > close[1], (1-K) * nz(ADC[1], 1), K * (close[1] - close) + (1 - K) * nz(ADC[1], 1))
nVal = (WildPer - 1) * (ADC * Value / (100 - Value) - AUC)
nRes = iff(nVal >= 0, close + nVal, close + nVal * (100 - Value) / Value)
pos = iff(nRes > close, -1,
	   iff(nRes < close, 1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue ) 
plot(nRes, color=blue, title="Reverse Engineering RSI")
````
