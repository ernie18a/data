# I11L - Reversal Trading Ideas by Larry Connors

- url: https://www.tradingview.com/script/qvbGDFKf/
- type: strategy
- pine_id: PUB;a21447af03e846cfa56f1ef3d8be8fd7
- version: 2.0

## Description

This is my own Twist on Larry Connors Simple Tradingideas. 
It Combines the RSI, Averaging In and the Lowest Bars in a Single System.
The current Configuration is designed for the Daily Timeframe.
Feel free to play with the Parameters and keep in mind that Larry Intended to buy fear and sell the greed!

The Rules are the following:

---Buy---
Buy, if the lowest Bar of your Configuration has been hit (default is set to 7).

---Average Down--
Buy, if the lowest Bar of your Configuration * Your open trades has been hit AND only if the buyin is atleast 1% cheaper.

---Close---
Close, if the RSI closes above a certain level (default is set to 70).

---TP---
There is no TP

---SL---
There is no SL, so be cautions of your tail Risk!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © I11L

//@version=5
strategy("I11L - Reversal Trading Ideas by Larry Connors", overlay=false, pyramiding=3, default_qty_value=10000, initial_capital=10000, default_qty_type=strategy.cash,process_orders_on_close=true, calc_on_every_tick=false)

lowestPointBars = input.int(7)
rsiLength = input.int(2)
sellBarrier = input.int(70, step=55)
onlyBuyWhenAbove55Average = input.bool(false)

isLowest = ta.lowest(close,lowestPointBars*(strategy.opentrades+1)) == close
isHighest = ta.rsi(close,rsiLength) > sellBarrier

isBuy = isLowest and (strategy.position_avg_price * (1-0.01*strategy.opentrades) > close or strategy.opentrades == 0) and (close > ta.sma(close, 55) or not(onlyBuyWhenAbove55Average))
isClose = isHighest

plot(ta.rsi(close,rsiLength), color=isBuy ? color.green : isLowest ? color.yellow : color.white)
plot(sellBarrier, color=color.red)

if(isBuy)
    strategy.entry("Buy"+str.tostring(strategy.opentrades+1),strategy.long, comment="#"+str.tostring(strategy.opentrades+1))

if(isClose)
    strategy.exit("Close",limit=close)
````
