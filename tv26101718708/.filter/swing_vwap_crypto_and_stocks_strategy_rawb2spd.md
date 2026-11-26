# Swing VWAP Crypto and Stocks Strategy

- url: https://www.tradingview.com/script/rAwb2sPd-Swing-VWAP-Crypto-and-Stocks-Strategy/
- type: strategy
- pine_id: PUB;67c5d3edec2f475d8eb8617fcec79961
- version: 1.0

## Description

This is a strategy designed for swing trading on markets such as crypto and stocks.

Its components are:
VWAP
Time Management
Risk management


Rules for entry:
We entry only on Monday, if our close of the candle crossed above VWAP


Rules for exit
We exit always on Sunday or if we either hit the TP/SL levels.


If you have any questions let me know

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=5
strategy('VWAP strategy ', overlay=true, initial_capital=100, default_qty_type=strategy.percent_of_equity, default_qty_value=100, calc_on_every_tick=true, commission_type=strategy.commission.percent, commission_value=0.03)


long = close> ta.vwap and close[1] < ta.vwap

stopPer = input.float(10.0, title='LONG Stop Loss % ', group='Fixed Risk Management') / 100
takePer = input.float(29.0, title='LONG Take Profit %', group='Fixed Risk Management') / 100


longStop = strategy.position_avg_price * (1 - stopPer)
longTake = strategy.position_avg_price * (1 + takePer)



strategy.entry("long",strategy.long,when=long and dayofweek==dayofweek.monday)
strategy.exit('LONG EXIT', "long", limit=longTake, stop=longStop)


strategy.close_all(when=dayofweek==dayofweek.sunday)
````
