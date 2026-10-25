# Combining Exponential And Volume Weighting Backtest

- url: https://www.tradingview.com/script/iIXISsgV-Combining-Exponential-And-Volume-Weighting-Backtest/
- type: strategy
- pine_id: PUB;r3bZvFC967i8CdA2mBCao4u4w8YlLKPZ
- version: 1.0

## Description

The related article is copyrighted material from Stocks & Commodities 2009 Oct 

 You can change long to short in the Input Settings
 Please, use it only for learning or paper trading. Do not for real trading.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/03/2017
// The related article is copyrighted material from Stocks & Commodities 2009 Oct 
//
// You can change long to short in the Input Settings
// Please, use it only for learning or paper trading. Do not for real trading.
////////////////////////////////////////////////////////////
strategy(title="Combining Exponential And Volume Weighting", overlay=true)
length = input(22, minval=1)
reverse = input(false, title="Trade reverse")
xMAVolPrice = ema(volume * close, length)
xMAVol = ema(volume, length)
nRes = xMAVolPrice / xMAVol
pos = iff(nRes < close[1], 1,
	     iff(nRes > close[1], -1, nz(pos[1], 0))) 
possig = iff(reverse and pos == 1, -1,
          iff(reverse and pos == -1, 1, pos))	   
if (possig == 1 )
    strategy.entry("Long", strategy.long)
if (possig == -1 )
    strategy.entry("Short", strategy.short)	   	    
barcolor(possig == -1 ? red: possig == 1 ? green : blue )
plot(nRes, color=blue)
````
