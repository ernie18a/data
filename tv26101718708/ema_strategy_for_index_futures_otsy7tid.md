# EMA Strategy For Index Futures

- url: https://www.tradingview.com/script/OTsy7tID-EMA-Strategy-For-Index-Futures/
- type: strategy
- pine_id: PUB;2739
- version: -1.0

## Description

This is a simple long-term strategy based on EMA crossover basically designed for Index futures

## Source Code

````pine
// @version=2
// Written By Sandip Chavan
// Use in 1D timeframe for NSE - BankNifty And Nifty
//
strategy("EMA Strategy", overlay=true)

longCondition = crossover(ema(close, 30), ema(close, 35))
if (longCondition)
    strategy.entry("Buy", strategy.long)

shortCondition = crossunder(ema(close, 30), ema(close,35))
if (shortCondition)
    strategy.entry("Sell", strategy.short)
````
