# T3 crossover strategy

- url: https://www.tradingview.com/script/0DeI9Z4m-T3-crossover-strategy/
- type: strategy
- pine_id: PUB;VpzZZKBqWjmXvVUooy3FHFfW36m4IGKh
- version: 1.0

## Description

Hi everybody,

Hereby a simple strategy based on T3 moving average crossover. If people are interested we can also add some alerts in people are interested.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DynamicSignalLab

//@version=4
strategy(title="T3 crossover strategy", shorttitle="T3 strategy", overlay=true)

length = input(title="Length", type=input.integer, defval=5)
factor = input(title="Factor", type=input.float, minval=0, maxval=1, defval=0.7)
highlightMovements = input(title="Highlight Movements ?", type=input.bool, defval=true)
src = input(title="Source", type=input.source, defval=close)

gd(src, length) =>
    ema(src, length) * (1 + factor) - ema(ema(src, length), length) * factor

t3 = gd(gd(gd(src, length), length), length)

t3Color = highlightMovements ? (t3 > t3[1] ? color.green : color.red) : #6d1e7f
plot(t3, title="T3", linewidth=2, color=t3Color, transp=0)

longCondition = crossover(t3, t3[2])
if (longCondition)
    strategy.entry("long", strategy.long)

shortCondition = crossunder(t3, t3[2])
if (shortCondition)
    strategy.entry("short", strategy.short)
````
