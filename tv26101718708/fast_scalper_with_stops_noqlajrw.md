# Fast Scalper with Stops

- url: https://www.tradingview.com/script/nOqlAJrw-Fast-Scalper-with-Stops/
- type: strategy
- pine_id: PUB;9bb68cb23f4a4c57b6b21590aedf8a58
- version: 1.0

## Description

fast scalping strategy using EMA and MACD with stops.

## Source Code

````pine
//@version=5
strategy("Fast Scalper with Stops", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

fast = ta.ema(close, 5)
slow = ta.ema(close, 13)

plot(fast, color=color.blue)
plot(slow, color=color.red)

longCondition = ta.crossover(fast, slow)
shortCondition = ta.crossunder(fast, slow)

if longCondition
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit Long", "Long", stop=close * 0.99, trail_points=close * 0.02 / syminfo.mintick)
    alert("long", alert.freq_once_per_bar_close)

if shortCondition
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit Short", "Short", stop=close * 1.01, trail_points=close * 0.02 / syminfo.mintick)
    alert("short", alert.freq_once_per_bar_close)
````
