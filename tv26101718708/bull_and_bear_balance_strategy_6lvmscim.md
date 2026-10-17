# Bull And Bear Balance Strategy

- url: https://www.tradingview.com/script/6LvmsCIM-Bull-And-Bear-Balance-Strategy/
- type: indicator
- pine_id: PUB;AiDbBM7cIukCZ6umWmwjLU2nxgojt7No
- version: 1.0

## Description

This new indicator analyzes the balance between bullish and
    bearish sentiment.
    One can cay that it is an improved analogue of Elder Ray indicator.
    To get more information please see "Bull And Bear Balance Indicator" 
    by Vadim Gimelfarb.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 02/02/2017
//    This new indicator analyzes the balance between bullish and
//    bearish sentiment.
//    One can cay that it is an improved analogue of Elder Ray indicator.
//    To get more information please see "Bull And Bear Balance Indicator" 
//    by Vadim Gimelfarb. 
////////////////////////////////////////////////////////////
study(title = "Bull And Bear Balance Strategy")
SellLevel = input(-15, step=0.01)
BuyLevel = input(15, step=0.01)
hline(SellLevel, color=red, linestyle=line)
hline(BuyLevel, color=green, linestyle=line)
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

value2 = iff (close < open , 
          iff (close[1] < open ,  max(high - close[1], close - low), max(high - open, close - low)), 
           iff (close > open, 
             iff(close[1] > open,  high - low, max(open - close[1], high - low)), 
              iff(high - close > close - low, 
               iff (close[1] < open, max(high - close[1], close - low), high - open), 
                 iff (high - close < close - low, 
                  iff(close[1] > open,  high - low, max(open - close, high - low)), 
                   iff (close[1] > open, max(high - open, close - low),
                     iff(close[1] < open, max(open - close, high - low), high - low))))))
nBBB = value2 - value
nBBBc = nBBB < 0 ? red : green
pos = iff(nBBB < SellLevel, -1,
	   iff(nBBB >= BuyLevel, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nBBB, style=line, linewidth=1, color=nBBBc)
plot(nBBB, style=histogram, linewidth=1, color=gray)
````
