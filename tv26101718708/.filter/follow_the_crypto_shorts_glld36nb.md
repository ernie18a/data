# Follow the Crypto Shorts

- url: https://www.tradingview.com/script/gllD36NB-Follow-the-Crypto-Shorts/
- type: strategy
- pine_id: PUB;41791303586d4e48886207abdaa65f87
- version: 2.0

## Description

This script allows to test the impact of variations in the number of BTCUSD Shorts Positions on its price. In particular, it compares the number of short positions with its moving average to decide if shorts are being liquidated. In case the number of short positions crosses below its moving average, it will generate a Long Position, which will be closed if shorts crosses above its moving average.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xtradernet

//@version=4

// This script allows to backtest the impact of variations in the number of BTCUSD Shorts Positions on its price.  

strategy("Follow the Crypto Shorts", shorttitle="FollowBTCShorts", overlay=true)

length = input(50, type=input.integer, title="BTC Shorts SMA Length")

expr = sma(close, length)
BTCShorts = security("BTCUSDSHORTS", "D", close)
BTCShortsMA = security("BTCUSDSHORTS", "D", expr)

if crossunder(BTCShorts, BTCShortsMA)
    strategy.entry("Long", strategy.long, comment="Shorts Out")

strategy.close("Long", when=crossover(BTCShorts, BTCShortsMA), comment="Shorts In")
````
