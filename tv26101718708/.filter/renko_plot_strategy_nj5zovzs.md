# Renko Plot Strategy

- url: https://www.tradingview.com/script/nJ5zOVzs-Renko-Plot-Strategy/
- type: strategy
- pine_id: PUB;YR3XUliXPeUrrZaA7N0hW1remBYmCgPl
- version: 1.0

## Description

This strategy lets you plot Renko open and close values, based on your preferred Renko size brick, on normal candle chart. You can use it on any timeframe, define your preferred brick size and trailing stop.

## Source Code

````pine
//@version=4
strategy("Renko Plot Strat", overlay=true)
size=input(3.2)
trail=input(8)
renko_tickerid = renko(syminfo.tickerid, "Traditional", size)
renko_close = security(renko_tickerid, "1", close)
renko_open = security(renko_tickerid, "1", open)
plot(renko_close, color=color.red)
plot(renko_open, color=color.green)

longCondition = crossover(renko_close, renko_open) and year > 2018 and month > 6
if (longCondition)
    strategy.entry("Renko Cross Long", strategy.long)
    strategy.exit("Exit Long", "Renko Cross Long", trail_points=trail)

shortCondition = crossunder(renko_close, renko_open) and year > 2018 and month > 6
if (shortCondition)
    strategy.entry("Renko Cross Short", strategy.short)
    strategy.exit("Exit Short", "Renko Cross Short", trail_points=trail)
````
