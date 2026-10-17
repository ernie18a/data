# Triple EMA Cross JS

- url: https://www.tradingview.com/script/Oi4q9CfP-Triple-EMA-Cross-JS/
- type: strategy
- pine_id: PUB;dld8Kmn26J3UrQJCBalcBCyzz7YoX49y
- version: 1.0

## Description

Strategy that indicates potential buy and sell signals.

## Source Code

````pine
//@version=2
strategy("Triple EMA Cross", overlay = true)

a = ema(close, 8)
b = ema(close, 20)
c = ema(close, 50)

plot(a, "ema8", color = yellow, linewidth = 2)
plot(b, "ema20", color = blue, linewidth = 2)
plot(c, "ema50", color = red, linewidth = 2)

long = a > c and a > b and b > c
short = a < c and a < b and b < c

start = timestamp(2019, 1, 1, 0, 0)

if time >= start and time
    strategy.entry("long", strategy.long, 50000.0, when = long)
    strategy.entry("short", strategy.short, 50000.0, when = short)

strategy.close("long", when = a < b)
strategy.close("short", when = a > b)
````
