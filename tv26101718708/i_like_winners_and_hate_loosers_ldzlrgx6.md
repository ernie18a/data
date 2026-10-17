# I Like Winners And Hate Loosers!

- url: https://www.tradingview.com/script/LdZlRGX6-I-Like-Winners-And-Hate-Loosers/
- type: strategy
- pine_id: PUB;GnPiX4TZRteqHNwNV1KrZzFdzjwxxheM
- version: 1.0

## Description

This simple long only strategy aims to be in trending markets, maximizing win/loss ratio and keep drawdown low (at the expense of net profit).

## Source Code

````pine
//@version=4
strategy("I Like Winners And Hate Loosers!", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

highest_length = input(200, type=input.integer, minval=1, title="Highest Length")
highest_average = input(10, type=input.integer, minval=1, title="Highest Average")

atr_length = input(14, type=input.integer, minval=1, title="ATR Length")
atr_multiplier = input(2, type=input.integer, minval=1, title="ATR Multiplier")

a = atr(atr_length) * atr_multiplier
h = sma(highest(high, highest_length), highest_average)
l = h - a

buy_signal = crossover(close, h)
sell_signal = crossunder(close, l)

strategy.entry("Buy", strategy.long, when=buy_signal)
strategy.close("Buy", when=sell_signal)

plot(h, title="H", color=color.green, transp=50, linewidth=2)
plot(l, title="L", color=color.red, transp=50, linewidth=2)
````
