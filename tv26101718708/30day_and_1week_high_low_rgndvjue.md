# 30-Day and 1-Week High Low

- url: https://www.tradingview.com/script/RGndVJuE-30-Day-and-1-Week-High-Low/
- type: indicator
- pine_id: PUB;b91b143e327c4501951fa987ed11ea13
- version: 1.0

## Description

For day trading, 1-week high/low is more useful. For swing trading, 30-day high/low is more useful.

## Source Code

````pine
//@version=5
indicator("30-Day and 1-Week High Low", overlay=true)

weekLen = input.int(5, "1 Week Length")
monthLen = input.int(30, "30 Day Length")

weekHigh = ta.highest(high, weekLen)
weekLow = ta.lowest(low, weekLen)

monthHigh = ta.highest(high, monthLen)
monthLow = ta.lowest(low, monthLen)

plot(weekHigh, "1 Week High", color=color.green, linewidth=2)
plot(weekLow, "1 Week Low", color=color.red, linewidth=2)

plot(monthHigh, "30 Day High", color=color.blue, linewidth=2)
plot(monthLow, "30 Day Low", color=color.orange, linewidth=2)
````
