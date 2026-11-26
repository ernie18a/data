# HiLo Extension 

- url: https://www.tradingview.com/script/rsbViwZX-HiLo-Extension/
- type: strategy
- pine_id: PUB;LtDxjeN35b6liz5E9ygUYG9Yvb1A1RI6
- version: 1.0

## Description

This Strategy is finding high and low breaks of the day and enter into the trader based on RSI value and time value 

1) This strategy is created for Indian Index like Nifty, Bank Nifty and so... 
2) Trades are initiate only after 10:15 AM and before 3:10PM 
3) High and Low of the day break will be check during the above time frame
4) RSI value will be check (RSI 50)
5) and trade will be initiate
6) Stop loss set as vwma 20... 

Note: This Script will work fine in Index future chart not index spot chart... 


This is just my idea only... Please back test yourselve, before using it.. 

Your comments are welcome!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Saravanan_Ragavan


// This Strategy is finding high or low breaks of the day and enter into the trader based on RSI value and time value 

//@version=4
strategy(title="HiLoExtn", shorttitle="HiLoExtn", overlay=true)


T1 = time(timeframe.period, "0915-0916")
Y = bar_index
Z1 = valuewhen(T1, bar_index, 0)
L = Y-Z1 + 1

tim = time(timeframe.period, "1015-1510")
exitt= time(timeframe.period, "1511-1530")

//VWMA 20
plot(vwma(close,20), color=color.blue)


length = L
lower = lowest(length)
upper = highest(length)
u = plot(upper, "Upper", color=color.green)
l = plot(lower, "Lower", color=color.red)


//**** RSI
len = 14
src = close
up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))




// Buy above Buy Line
if ( (upper==high) and rsi>50 and   tim and close>open )
    strategy.entry("Buy", strategy.long, comment="Buy")
    
// Exit Long Below Vwap
strategy.close("Buy", when = close < vwma(close,20) or exitt) 

// Sell above Buy Line
if ((lower==low) and rsi<50 and   tim  and close<open)
    strategy.entry("Sell", strategy.short, comment="Sell")
    
// Exit Short above Vwap    
strategy.close("Sell", when = close > vwma(close,20) or exitt)
````
