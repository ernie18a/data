# 150MA Cross BuyAndSell Strategy [d3nv3r]

- url: https://www.tradingview.com/script/Nn2bCfC7-150MA-Cross-BuyAndSell-Strategy-d3nv3r/
- type: strategy
- pine_id: PUB;QKpODdOL0vQ1DeKqDEKIl96ru0J5y27x
- version: 1.0

## Description

This is a Buy And Sell Strategy I haven't seen anywhere so i share mine.

Used on Bitcoin - daily chart - the strategy generate sell and buy indicator on crossover and crossunder the 150 simple moving average.

## Source Code

````pine
//
// @author d3nv3r 
// @inspiration [LazyBear]
// List of all my indicators: nowhere for now
//
//@version=4
strategy(shorttitle = "150MA X B/S", title="150MA Cross BuyAndSell Strategy [d3nv3r]", overlay=true)

longCondition = crossover(close,sma(close, 150))
shortCondition = crossunder(close, sma(close, 150))

if year >= 2012
    if (longCondition)
        strategy.entry("Long", strategy.long)
    if (shortCondition)
        strategy.entry("short", strategy.short)
````
