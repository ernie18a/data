# Bull Power Strategy

- url: https://www.tradingview.com/script/VCnTrRoS-Bull-Power-Strategy/
- type: indicator
- pine_id: PUB;3e0nkojckceS89cWOPiPBR7Li7h44zyR
- version: 1.0

## Description

Bull Power Indicator
  To get more information please see "Bull And Bear Balance Indicator" 
  by Vadim Gimelfarb.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 27/01/2017
//  Bull Power Indicator
//  To get more information please see "Bull And Bear Balance Indicator" 
//  by Vadim Gimelfarb. 
////////////////////////////////////////////////////////////
study(title = "Bull Power Strategy")
SellLevel = input(40, step=0.01)
BuyLevel = input(3, step=0.01)
hline(SellLevel, color=red, linestyle=line)
hline(BuyLevel, color=green, linestyle=line)
value = iff (close < open ,  
         iff (close[1] < open ,  max(high - close[1], close - low), max(high - open, close - low)),
          iff (close > open, 
           iff(close[1] > open,  high - low, max(open - close[1], high - low)), 
             iff(high - close > close - low, 
              iff (close[1] < open, max(high - close[1], close - low), high - open), 
               iff (high - close < close - low, 
                 iff(close[1] > open,  high - low, max(open - close, high - low)), 
                  iff (close[1] > open, max(high - open, close - low),
                   iff(close[1] < open, max(open - close, high - low), high - low))))))
pos = iff(value > SellLevel, -1,
	     iff(value <= BuyLevel, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(value, style=line, linewidth=2, color=blue)
````
