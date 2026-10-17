# WMA + MACD strategy with trailing stop

- url: https://www.tradingview.com/script/0sS5Urzv/
- type: strategy
- pine_id: PUB;y8EeVwKUGdGaTyLZ12zsD5IF0oeI2NI4
- version: 1.0

## Description

Hi!

That's my first strategy.  I already learn pine, so i will work on it more. Now i search how to make trailing stop working.

"WMA + MACD strategy with traiing stop" is very simple strategy which is designated for stocks market. It is created only to take long positions.

Buy signal is when WMA(120) is below price and macd(10,20,10) histogram is higher than 0.

Position should be automaticly closed when price hits stoploss level.

One transaction should be max 20% of our capital and stoploss is set 3% lower than last closing price.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © heniu_1

//@version=4
strategy("WMA + MACD strategy", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=20, commission_type=strategy.commission.percent, commission_value=0.39)

[_, _, histogram] = macd(close, 10, 20, 10)

ma = wma(close, 120)

a = close - (close * 0.03)
b = close[1] - (close[1] * 0.03)

sl = iff(a > b, a, b)

plot(sl, color=color.yellow, style=plot.style_stepline)

longCondition = close > ma and histogram > 0
closeCondition = close <= sl

if (longCondition)
    strategy.entry("Kup", strategy.long)

if (closeCondition)
    strategy.exit("Sprzedaj", stop = sl)
````
