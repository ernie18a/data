# Internal Bar Strength Indicator | Reversion system

- url: https://www.tradingview.com/script/ZTnKxBPz-Internal-Bar-Strength-Indicator-Reversion-system/
- type: strategy
- pine_id: PUB;2470
- version: -1.0

## Description

This strategy buy at the next [b]open[/b] when [b]close[/b] = [b]low[/b]. Then it closes the position after either a small profits OR a (very) small losses. Works with several TF

## Source Code

````pine
//@version=2
strategy("IBS", initial_capital=10000, overlay=false, pyramiding=5, default_qty_value=100, currency="USD")

//strategy.risk.allow_entry_in(strategy.direction.long)


src = close
ibs = (close - low) / (high - low) * 100

longCondition = ibs <5
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

//shortCondition = close > high[1]
shortCondition = ibs > 99
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)

p = close * 0.01 * 10
strategy.exit("exit", "My Long Entry Id",profit = 10, loss=2)
strategy.exit("exit", "My Short Entry Id",profit = 10, loss=2)
````
