# Pivot Point Breakout

- url: https://www.tradingview.com/script/PuGrfn7G/
- type: strategy
- pine_id: PUB;e9UvNF4jkJ9SxxiOwCa3zq2AhVOJA8KX
- version: 1.0

## Description

Pivot Point Breakout

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("枢轴点突破策略", overlay=true)
//strategy.risk.allow_entry_in(strategy.direction.long)
// btcusdt 最好参数为4
period = input(3,'观察数')

startday = 2*period + 1
lasthigh = 0.0
lastlow = 0.0

if high[period + 1] >= highest(high,startday)
	lasthigh := high[period+1]
else
	lasthigh := lasthigh[1]

if low[period+1] <= lowest(low,startday)
	lastlow := low[period+1]
else
	lastlow := lastlow[1]

if high > lasthigh
	strategy.entry("Long", strategy.long, when=strategy.position_size <= 0)
else
	if low < lastlow
		strategy.entry("Short", strategy.short, when=strategy.position_size > 0)
````
