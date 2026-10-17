# Bear Power Strategy

- url: https://www.tradingview.com/script/UB5H1a7Q-Bear-Power-Strategy/
- type: indicator
- pine_id: PUB;hNTDoFxA7d20NfrqLXTHQD19sSn0nBb1
- version: 1.0

## Description

Bear Power Strategy
  To get more information please see "Bull And Bear Balance Indicator" 
  by Vadim Gimelfarb.

## Source Code

````pine
//@verion=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 24/01/2017
//  Bear Power Strategy
//  To get more information please see "Bull And Bear Balance Indicator" 
//  by Vadim Gimelfarb. 
///////////////////////////////////////////////////////////
study(title = "Bear Power Strategy")
SellLevel = input(30)
BuyLevel = input(3)
hline(SellLevel, color=red, linestyle=line)
hline(BuyLevel, color=green, linestyle=line)
value = iff (close < open , //then 
            iff (close[1] > open ,  max(close - open, high - low), high - low), // else
            iff (close > open, //then
                iff(close[1] > open, max(close[1] - low, high - close), max(open - low, high - close)), //else
                iff(high - close > close - low, //then
                    iff (close[1] > open, max(close[1] - open, high - low), high - low), //else
                    iff (high - close < close - low, //then
                        iff(close > open, max(close - low, high - close),open - low), //else
                        iff (close > open, max(close[1] - open, high - close),//else
                            iff(close[1] < open, max(open - low, high - close), high - low))))))
pos = iff(value > SellLevel, -1,
	    iff(value <= BuyLevel, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(value, style=line, linewidth=2, color=blue)
````
