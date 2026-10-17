# MA Cross + Strategy by Realmix

- url: https://www.tradingview.com/script/Lnqjg6ns/
- type: strategy
- pine_id: PUB;p3qwAsBnsRAVuaXnLZiuRveF7Dk4TAhX
- version: 1.0

## Description

Two Moving Average with crossmarker and strategy when both indicators are crossing for a possible position

## Source Code

````pine
//@version=4
strategy(title="MA Cross + Strategy by Realmix", overlay=true)

fast = input(20, minval=1, title="Fast")
slow = input(55, minval=1, title="Slow")

fastline = sma(close, fast)
slowline = sma(close, slow)

plot(fastline,  title="Fast", color = color.red, linewidth = 3)
plot(slowline,  title="Slow", color = color.green, linewidth = 3)
plot(cross(slowline, fastline) ? slowline : na, style = plot.style_cross, linewidth = 4)

longposition = crossover(fastline, slowline)
if (longposition)
    strategy.entry("Long", strategy.long)

shortposition = crossunder(fastline, slowline)
if (shortposition)
    strategy.entry("Short", strategy.short)
````
