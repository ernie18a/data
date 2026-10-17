# ATR Trailing Stoploss Strategy

- url: https://www.tradingview.com/script/NsD6sRKu/
- type: strategy
- pine_id: PUB;oayb1wVXkZiM6fDd5Klqn27PN0GwfdcC
- version: 2.0

## Description

I am sharing the strategy version of the indicator used before. It is very simple to use.
https://tr.tradingview.com/script/sLXhpDO8/


These are the settings I use, you can change, test and use as you wish.
Atr Period 5
Highest High Period 10
Multiplier 2.5


It can generate more signals in shorter time frames.
The success rate will be higher in longer time frames.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

//@version=4
strategy("ATR Trailing Stoploss Strategy ",overlay=true)

Atr=input(defval=5,title="Atr Period",minval=1,maxval=500)
Hhv=input(defval=10,title="HHV Period",minval=1,maxval=500)
Mult=input(defval=2.5,title="Multiplier",minval=0.1)
Barcolor=input(true,title="Barcolor")

Prev = highest(high-Mult*atr(Atr),Hhv),barssince(close>highest(high-Mult*atr(Atr),Hhv) and close>close[1])
TS = iff(cum(1)<16 ,close,iff( close > highest(high-Mult*atr(Atr),Hhv) and close>close[1],highest(high-Mult*atr(Atr),Hhv),Prev))

Color=iff(close>TS,color.green,iff(close<TS,color.red,color.black))
barcolor(Barcolor? Color:na)
plot(TS,color=Color,linewidth=3,title="ATR Trailing Stoploss")

Buy  = crossover(close,TS)
Sell = crossunder(close,TS)

if Buy
    strategy.entry("Buy", strategy.long, comment="Buy")
    
if Sell
    strategy.entry("Sell", strategy.short, comment="Sell")
````
