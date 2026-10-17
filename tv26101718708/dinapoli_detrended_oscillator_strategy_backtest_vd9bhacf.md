# DiNapoli Detrended Oscillator Strategy Backtest

- url: https://www.tradingview.com/script/Vd9BHacF-DiNapoli-Detrended-Oscillator-Strategy-Backtest/
- type: strategy
- pine_id: PUB;Scs7GNYqkU4KIXa4aK74PHjrKa9zZ5z3
- version: 1.0

## Description

DiNapoli Detrended Oscillator Strategy
 You can change long to short in the Input Settings
 Please, use it only for learning or paper trading. Do not for real trading.

## Source Code

````pine
//@version = 2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 05/12/2016
// DiNapoli Detrended Oscillator Strategy
// You can change long to short in the Input Settings
// Please, use it only for learning or paper trading. Do not for real trading.
////////////////////////////////////////////////////////////
strategy(title="DiNapoli Detrended Oscillator Strategy Backtest")
Length = input(14, minval=1)
Trigger = input(0)
reverse = input(true, title="Trade reverse")
hline(Trigger, color=gray, linestyle=line)
xSMA = sma(close, Length)
nRes = close - xSMA
pos = iff(nRes > Trigger, 1,
	   iff(nRes <= Trigger, -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
         iff(reverse and pos == -1, 1, pos))	   
if (possig == 1) 
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)	   	    
plot(nRes, color=blue, title="DiNapoli")
barcolor(possig == -1 ? red: possig == 1 ? green : blue )
````
