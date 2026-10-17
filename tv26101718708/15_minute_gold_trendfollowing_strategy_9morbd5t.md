# 15 Minute Gold Trend-Following Strategy

- url: https://www.tradingview.com/script/9morbD5t-15-Minute-Gold-Trend-Following-Strategy/
- type: strategy
- pine_id: PUB;v0d1rwLHjXobyApD15BLp3iWRG8DxwkJ
- version: 1.0

## Description

This is the main strategy that I will be forward testing on demo for a month or two, then making it an EA in MetaTrader4 

You can see the code for yourself this time, all the strategy is, is a crossover of various moving averages.

Commission included, $10,000 account.

Results over the past 3 months, beginning in January 2017.

## Source Code

````pine
//@version=3
strategy("MAster Gold Strategy", overlay = true, currency = currency.USD, commission_value = 0.02, initial_capital = 10000, pyramiding = 1)

strategy.entry("Buy", strategy.long, 1, when = close > ema(close, 182) and crossover(close, sma(close, 60)))
strategy.entry("Short", strategy.short, 1, when = low < sma(close, 182) and crossunder(close, ema(close, 60)))

c = crossover(sma(close, 60), close)
alertcondition(c, title = 'Gold Alert', message = 'Gold Alert')
````
