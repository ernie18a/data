# EMA 5/13 Strategy

- url: https://www.tradingview.com/script/N18VdyZl-EMA-5-13-Strategy/
- type: strategy
- pine_id: PUB;bcc46701c6784854b4389bda337a018b
- version: 1.0

## Description

Buy when EMA5 crosses up EMA13
Sell when EMA5 crosses down EMA13

## Source Code

````pine
//@version=5
strategy("EMA 5/13 Crossover (Long & Short, No Plots)", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// Inputs
fastLength = input.int(5, title="Fast EMA Length")
slowLength = input.int(13, title="Slow EMA Length")

// EMA Calculations (hidden)
emaFast = ta.ema(close, fastLength)
emaSlow = ta.ema(close, slowLength)

// Conditions
longCondition = ta.crossover(emaFast, emaSlow)
shortCondition = ta.crossunder(emaFast, emaSlow)

// Execute Trades
if (longCondition)
    strategy.close("Short")
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.close("Long")
    strategy.entry("Short", strategy.short)
````
