# Mayer Multiple Strategy

- url: https://www.tradingview.com/script/TlNlaIid-Mayer-Multiple-Strategy/
- type: strategy
- pine_id: PUB;714abc4e0e5d4e04997f9431a2dbda29
- version: 1.0

## Description

Created by Trace Mayer, the Mayer Multiple is calculated dividing the current price of Bitcoin by its 200-day moving average. This simple script allows to backtest strategies based on Mayer Multiple levels, which can be easily adjusted. It can be tested on any chart and any timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xtradernet
//@version=4

// Quick script to backtest a strategy based on Mayer Multiple

strategy("Mayer Multiple Strategy", shorttitle="Mayer_Crypto", overlay=true)

length = input(200, type=input.integer, title="Price SMA Length")
threshold = input(1.48, step=.1, type=input.float, title="Threshold")
exit = input(1.70, step=.1, type=input.float, title="Exit Level")

// Bitcoin price / 200 day moving average value = Mayer Multiple

ma = sma(close, length)
multiple = close / ma

if (crossunder(threshold,multiple))
    strategy.entry("Long", strategy.long, comment="MayerLong")

strategy.close("Long", when=crossover(multiple,exit), comment="MayerClose")
````
