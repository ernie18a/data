# RSI and HMA strategy

- url: https://www.tradingview.com/script/KSwpMMPh-RSI-and-HMA-strategy/
- type: strategy
- pine_id: PUB;ekNw2NjPqOH4VekWn3ELAjh7NM0sByMT
- version: 1.0

## Description

Crossover of RSI and HMA

## Source Code

````pine
//@version=3
strategy("RSI and HMA strategy", overlay=true)

f_hma(_src, _length)=>
    //HMA = WMA(2*WMA(n/2) − WMA(n)),sqrt(n))
    _return = wma((2 * wma(_src, _length / 2)) - wma(_src, _length), round(sqrt(_length)))

longCondition = crossover(rsi(close, 14), f_hma(close, 21))

if (longCondition)
    strategy.entry("Long", strategy.long, floor(round(strategy.initial_capital/close)))
    strategy.exit("exit", "Long", profit=close*15, loss=close*5, comment="Profit/loss condition hit")

shortCondition = crossunder(rsi(close, 14), f_hma(close, 21))

if (shortCondition)
    strategy.entry("Short", strategy.short, floor(round(strategy.initial_capital/close)))
    strategy.exit("exit", "Short", profit=close*15, loss=close*5, comment="Profit/loss condition hit")
````
