# Buying Dip Strategy With Take Profit And Stop Loss [racer8]

- url: https://www.tradingview.com/script/AHxkEMXm-Buying-Dip-Strategy-With-Take-Profit-And-Stop-Loss-racer8/
- type: strategy
- pine_id: PUB;I0DYr3Z2ypaYEdQn3y825NUldXYkrvRd
- version: 2.0

## Description

"Buy low, sell high."
This system buys the dip and takes profit for a high win rate.
It uses an ATR take profit and ATR stop loss.
It buys the dip when the close is below the previous 7 day low.
Daily timeframe is best.
Enjoy ♡

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © racer8
//@version=4
strategy("BuyTheDip", overlay=true)

atn = input(10, "ATR Length")
atr = sma(tr,atn)[1]
bought = strategy.position_size[0] > strategy.position_size[1]

tpm = input(2.0,"ATR Take Profit",minval=0)
TakePrice  = strategy.position_avg_price + tpm*atr              // determines Take Profit's price 
FixedTakePrice = valuewhen(bought,TakePrice,0)                  // stores original TakePrice  
plot(FixedTakePrice,"ATR Take Profit",color=color.blue,linewidth=1,style=plot.style_cross)

slm = input(2.0,"ATR Stop Loss",minval=0)
StopPrice  = strategy.position_avg_price - slm*atr              // determines stop loss's price 
FixedStopPrice = valuewhen(bought,StopPrice,0)                  // stores original StopPrice  
plot(FixedStopPrice,"ATR Stop Loss",color=color.yellow,linewidth=1,style=plot.style_cross)

n = input(7,"Dip Length")
Dip = lowest(low,n)

if close<Dip[1]
    strategy.entry("Buy",strategy.long)
if strategy.position_size > 0
    strategy.exit(id="Stop", stop=FixedStopPrice, limit=FixedTakePrice)    // commands stop loss order to exit!
    
plot(Dip,"Dip Line",color=color.aqua,linewidth=2)    
// ♡♡♡
````
