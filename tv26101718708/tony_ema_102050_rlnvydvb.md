# Tony EMA 10-20-50

- url: https://www.tradingview.com/script/RLNvydvB-Tony-EMA-10-20-50/
- type: indicator
- pine_id: PUB;ceaa9f95a14c4d188873b6a21ddd3f01
- version: 1.0

## Description

Exponential moving averages using the 10 20  and 50 day.

## Source Code

````pine
//@version=6
indicator("Tony EMA", overlay=true)

ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

plot(ema10, "EMA 10", color=color.green, linewidth=2)
plot(ema20, "EMA 20", color=color.blue,  linewidth=2)
plot(ema50, "EMA 50", color=color.red,   linewidth=2)
````
