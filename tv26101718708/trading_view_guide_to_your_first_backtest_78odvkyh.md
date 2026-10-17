# Trading View Guide to Your First Backtest

- url: https://www.tradingview.com/script/78ODVkyh-Trading-View-Guide-to-Your-First-Backtest/
- type: strategy
- pine_id: PUB;XcGCGoVUeWvwVcgYgPLCBUj9WQ1ZZYce
- version: 1.0

## Description

This is a simple moving average cross over strategy designed to get you familiar with writing strategies in pine script

## Source Code

````pine
strategy("Moving Average Crossover")

ema20 = ema(close, 20)
ema50 = ema(close, 50)

long = ema20 > ema50 
short = ema20 < ema50 

strategy.entry("Long", strategy.long, 10000.0, when=long)
strategy.entry("Short", strategy.short, 10000.0, when=short)

strategy.close("Long", when = short)
strategy.close("Short", when = long)
````
