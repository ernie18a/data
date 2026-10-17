# Modified 3MA cross : Modified 3 moving average crossover

- url: https://www.tradingview.com/script/FgksfsTm/
- type: strategy
- pine_id: PUB;ZCX9Brem9lH1xOd4WGM0D21z7wrRAHGO
- version: 1.0

## Description

Modified 3MA cross : Modified 3 moving average crossover

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("三重交叉修正模式系统", overlay=true)
//strategy.risk.allow_entry_in(strategy.direction.long)
length1 = input(18,'长线')
length2 = input(9,'中线')
length3 = input(4,'短线')

ma1 =0.0
ma2 = 0.0
ma3 = 0.0

ma1 := sma(close,length1)
ma2 := sma(close,length2)
ma3 := sma(close,length3)

plot(ma1)
plot(ma2)
plot(ma3)

if ma2 > ma1 and ma3 > ma3[1]
	strategy.entry("Long", strategy.long, when=strategy.position_size <= 0)

if ma2 < ma1 and ma3 < ma3[1]
	strategy.entry("Short", strategy.short, when=strategy.position_size > 0)
````
