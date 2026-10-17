# oussamacrypto

- url: https://www.tradingview.com/script/oqTVKkRm-oussamacrypto/
- type: strategy
- pine_id: PUB;a97392d16cf048adb17bd4cb4c4ecbf7
- version: 1.0

## Description

What Is an Exponential Moving Average (EMA)?
An exponential moving average (EMA) is a type of moving average (MA) that places a greater weight and significance on the most recent data points. The exponential moving average is also referred to as the exponentially weighted moving average. An exponentially weighted moving average reacts more significantly to recent price changes than a simple moving average simple moving average (SMA), which applies an equal weight to all observations in the period.

## Source Code

````pine
//@version=4
strategy("Simple Moving Averge Strategy", overlay=true)

ema50 = ema(close, 50)
ema180 = ema(close,180)

long = ema180> ema50
short = ema180 < ema50

plot(ema50, title="50", color=#00ffaa, linewidth=3)
plot(ema180, title= "180", color=#FFc1cc, linewidth=3)

start = timestamp(2021, 1, 1, 0, 0)
end = timestamp(2021, 8, 1, 0, 0)

strategy.entry("Long", strategy.long, 1000.0, when = long)
strategy.entry("Short", strategy.short, 1000.0, when = short)

strategy.close("Long", when = short)
strategy.close("Short", when = long)
````
