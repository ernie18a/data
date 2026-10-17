# Trend Bounce [racer8]

- url: https://www.tradingview.com/script/xV3t2X7R-Trend-Bounce-racer8/
- type: strategy
- pine_id: PUB;07994c29c87540e29ce0c7db6d2bfa2e
- version: 2.0

## Description

I discovered this mechanical trading system titled "This Algo Strategy Has Only 3 rules and 62% Win Rate". 

I coded the trading system on Tradingview...and now I am introducing it to you guys.
I modified the system so that it has both buy & sell signals.
I've tested it repeatedly in different markets on TV including stocks, currency pairs, bitcoin, and commodities...and it works!

A buy signal is generated whenever the current close is below the previous 7-day low and the current close is above the 200 period moving average.
A sell signal is generated whenever the current close is above the previous 7-day high and the current close is below the 200 period moving average.

The system also has a 2-ATR stop loss which I coded.

This system is unique in that it has both trend-following and reversal elements in it. 
The system trades short-term reversals while obeying the long-term trend.
Essentially, you are buying the dips of bullish trends! & selling at the peaks of bearish trends!

Enjoy ♡

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © racer8
//@version=4
// This Algo Strategy Has Only 3 rules and 62% Win Rate (Youtube) 

strategy("Trend Bounce", overlay=true)

nn = input(7,"Channel Length")
hi = highest(high,nn)
lo = lowest(low,nn)
n2 = input(200,"Ma Length")
ma = sma(close,n2)

if close>ma and close<lo[1]
    strategy.entry("Buy",strategy.long)
if close>hi[1]
    strategy.close("Buy") 
    
if close<ma and close>hi[1]
    strategy.entry("Sell",strategy.short)
if close<lo[1]
    strategy.close("Sell")


plot(hi,"high",color=color.aqua)
plot(lo,"low",color=color.aqua)
plot(ma,"sma",color=color.yellow)       

//-----------------------------------------Stop Loss------------------------------------------------------

atr = sma(tr,10)[1]
bought = strategy.position_size[0] > strategy.position_size[1]
sold = strategy.position_size[0] < strategy.position_size[1]
slm = input(2.0,"ATR Stop Loss",minval=0)
StopPrice_Long  = strategy.position_avg_price - slm*atr              // determines stop loss's price 
StopPrice_Short  = strategy.position_avg_price + slm*atr              // determines stop loss's price 
FixedStopPrice_Long = valuewhen(bought,StopPrice_Long,0)                  // stores original StopPrice  
FixedStopPrice_Short = valuewhen(sold,StopPrice_Short,0)                  // stores original StopPrice  
plot(FixedStopPrice_Long,"ATR Stop Loss Long",color=color.blue,linewidth=1,style=plot.style_cross)
plot(FixedStopPrice_Short,"ATR Stop Loss Short",color=color.red,linewidth=1,style=plot.style_cross)
if strategy.position_size > 0
    strategy.exit(id="Stop", stop=FixedStopPrice_Long)    // commands stop loss order to exit!
if strategy.position_size < 0
    strategy.exit(id="Stop", stop=FixedStopPrice_Short)    // commands stop loss order to exit!
````
