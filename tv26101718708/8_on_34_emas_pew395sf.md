# 8 On 34 ema's

- url: https://www.tradingview.com/script/PEw395SF-8-On-34-ema-s/
- type: strategy
- pine_id: PUB;HY4HHhWtYyOwspIaMD8h9e5zPAA0d5hy
- version: 1.0

## Description

Hi guy's
this simple dude send nice message
consider short/long when 8Ema Cross 34 Ema - If you learn this sutep and clear the false alarms (thats why it's - "consider") you can ride some waves

Enjoy

## Source Code

````pine
//@version=4
strategy("My Strategy", overlay=true)

longCondition = crossover(ema(close, 8), ema(close, 34))
if (longCondition)
    strategy.entry("Consider Long", strategy.long)

shortCondition = crossunder(ema(close, 8), ema(close, 34))
if (shortCondition)
    strategy.entry("Consider Short", strategy.short)
````
