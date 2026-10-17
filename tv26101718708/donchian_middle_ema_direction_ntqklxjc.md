# Donchian Middle EMA Direction

- url: https://www.tradingview.com/script/nTqkLxjC-Donchian-Middle-EMA-Direction/
- type: indicator
- pine_id: PUB;2b79cfd98fd648f69e51a27c199a26bf
- version: 1.0

## Description

very usefull ema of donchian midline, easy to follow

## Source Code

````pine
//@version=5
indicator("Donchian Middle EMA Direction", overlay=true)

dcLen  = input.int(20, "Donchian Length")
emaLen = input.int(10, "EMA on Donchian Middle")

upper = ta.highest(high, dcLen)
lower = ta.lowest(low, dcLen)
mid   = (upper + lower) / 2

midEma = ta.ema(mid, emaLen)

plot(upper, "Donchian Upper", color=color.gray)
plot(lower, "Donchian Lower", color=color.gray)
plot(mid, "Donchian Middle", color=color.orange)
plot(midEma, "EMA of Donchian Middle", color=midEma > midEma[1] ? color.green : color.red, linewidth=2)

bgcolor(midEma > midEma[1] ? color.new(color.green, 90) : color.new(color.red, 90))
````
