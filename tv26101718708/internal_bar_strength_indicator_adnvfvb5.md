# Internal Bar Strength Indicator

- url: https://www.tradingview.com/script/adnvfvB5-Internal-Bar-Strength-Indicator/
- type: strategy
- pine_id: PUB;2460
- version: -1.0

## Description

The internal bar strength or (IBS) is an oscillating indicator which measures the relative position of the close price with respect to the low to high range for the same period.

## Source Code

````pine
//@version=2
strategy("IBS", initial_capital=10000, overlay=false, pyramiding=5)

strategy.risk.allow_entry_in(strategy.direction.long)


src = close
ibs = (close - low) / (high - low) * 100

longCondition = ibs < 17
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = close > high[1]
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
