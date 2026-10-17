# Baracuda Ichimoku Cloud Strategy

- url: https://www.tradingview.com/script/v6QyUBYi-Baracuda-Ichimoku-Cloud-Strategy/
- type: strategy
- pine_id: PUB;HktYbzNpbHzKm3aSEg7DYqzZ00fI0FyC
- version: 1.0

## Description

Test strategy for Ichimogu indicator

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
