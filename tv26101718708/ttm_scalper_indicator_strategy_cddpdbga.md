# TTM scalper indicator Strategy

- url: https://www.tradingview.com/script/CddpDBGA-TTM-scalper-indicator-Strategy/
- type: indicator
- pine_id: PUB;ebIe0dthXWCVAlpIKJRyaJAqyOH8fUcO
- version: 1.0

## Description

TTM scalper indicator of John Carter’s Scalper Buys and Sells. The methodology 
 is a close approximation of the one described in his book Mastering the Trade. 
 The book is highly recommended. Note the squares are not real-time but will 
 show up once the third bar has confirmed a reversal. 

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v2.0 05/01/2017
// TTM scalper indicator of John Carter’s Scalper Buys and Sells. The methodology 
// is a close approximation of the one described in his book Mastering the Trade. 
// The book is highly recommended. Note the squares are not real-time but will 
// show up once the third bar has confirmed a reversal. 
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="TTM scalper indicator", overlay = true)
width = input(14, minval=1)
triggerSell = iff(iff(close[1] < close,1,0) and (close[2] < close[1] or close[3] <close[1]),1,0)
triggerBuy = iff(iff(close[1] > close,1,0) and (close[2] > close[1] or close[3] > close[1]),1,0)
buySellSwitch = iff(triggerSell, 1, iff(triggerBuy, 0, nz(buySellSwitch[1])))
SBS = iff(triggerSell and buySellSwitch[1] == false, high, iff(triggerBuy and buySellSwitch[1], low, nz(SBS[1])))
clr_s = iff(triggerSell and buySellSwitch[1] == false, 1, iff(triggerBuy and buySellSwitch[1], 0, nz(clr_s[1])))
clr = iff(clr_s == 0 , red , green)
pos = iff(clr == green, 1,
       iff(clr == red, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(SBS, color=clr, title="TTM", style = circles, linewidth = 2)
````
