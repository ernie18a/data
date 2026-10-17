# PSAR w/ Extras

- url: https://www.tradingview.com/script/6L628c5A-PSAR-w-Extras/
- type: strategy
- pine_id: PUB;nyrF0UkUC2TKjy1DnS2EgpmILCJqlYcJ
- version: 2.0

## Description

This script uses PSAR with some extra stuff.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © qweporiuqwer

//@version=4
strategy("PSAR w/ Extras", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=100,
     initial_capital=1000,
     commission_type=strategy.commission.percent, commission_value=0.25)
    
psar = sar(0.02, 0.02, 0.2) // these are default values

var startTime = input(title="Start Date", type=input.time, defval=timestamp("01 Jan 2018 00:00"))

psarLong  = crossunder(psar, close)
psarShort = crossover(psar, close)

buyCondition  = psarLong
sellCondition = psarShort

trailingStopArm = 5
trailingStopCatch = 1

if time > startTime
    strategy.entry("Long", true, when=buyCondition)
    strategy.exit("exit", "Long", 
         trail_points = close * (trailingStopArm * 0.01) / syminfo.mintick,
         trail_offset = close * (trailingStopCatch * 0.01) / syminfo.mintick)

plot(psar, style=plot.style_circles, linewidth=2)
plot(ema(close, 50), color = color.red)
````
