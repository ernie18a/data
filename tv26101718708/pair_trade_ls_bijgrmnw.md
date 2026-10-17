# Pair Trade L/S

- url: https://www.tradingview.com/script/BijGRmNw-Pair-Trade-L-S/
- type: strategy
- pine_id: PUB;yz78MylTj0Fupznkj6ECnh3PiICqcqn2
- version: 1.0

## Description

Pair Trading Spread

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © femisapien

//@version=4
strategy("Pair Trade L/S", overlay=true)

source = close
smalength = input(title = "SMA Length", defval = 20, minval=1)
entryzscore = input(title = "Entry ZScore", defval = 2.0, minval=0, maxval = 50)
startYear = input(title="Backtest Start Year", type=input.integer, defval=2016, minval=1980, maxval=2100)

ma = sma(source, smalength)
dev = entryzscore * stdev(source, smalength)

upper = ma + dev
lower = ma - dev

longEntrySignal = cross(source, lower)
shortEntrySignal = cross(source, upper)
exitSignal = cross(source, ma)

afterStartDate = (time >= timestamp(syminfo.timezone, startYear,1,1, 0, 0))

if (longEntrySignal and afterStartDate)
    strategy.entry("le", strategy.long, comment = "Enter Long")

if (shortEntrySignal and afterStartDate)
    strategy.entry("se", strategy.short, comment="Enter Short")

if (exitSignal and afterStartDate)
    strategy.close_all(true)
````
