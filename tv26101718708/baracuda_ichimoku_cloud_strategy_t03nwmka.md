# Baracuda Ichimoku Cloud Strategy

- url: https://www.tradingview.com/script/T03nWMKa-Baracuda-Ichimoku-Cloud-Strategy/
- type: strategy
- pine_id: PUB;F2wBZ0GeJYq3N5xy3Qs9agyDAqq8VkGo
- version: 1.0

## Description

test strategy

## Source Code

````pine
//@version=3
strategy("Baracuda Ichimoku Cloud Strategy", overlay=true)

conversionPeriods = input(9, minval=1, title="Conversion Line Periods"),
basePeriods = input(26, minval=1, title="Base Line Periods")

donchian(len) => avg(lowest(len), highest(len))

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)

long=crossover(conversionLine,baseLine)
short=crossunder(conversionLine,baseLine)

strategy.entry("long", strategy.long, when=long)
strategy.entry("short", strategy.short, when=short)
````
