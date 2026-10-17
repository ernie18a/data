# Kozlod - RSI Strategy - 1 minute

- url: https://www.tradingview.com/script/H3dWnaou-Kozlod-RSI-Strategy-1-minute/
- type: strategy
- pine_id: PUB;SuujF4KYQFZmtySKiR9y7JHB8GA0OoXH
- version: 2.0

## Description

Started to play with very simple strategies. Trying to find ones with optimal parameters which work well for certain symbols/timeframe. 
Found that basic RSI strategy without any position management with high RSI length (65 in this script) works pretty good for 1m chart for few stocks. 
It's also not bad for [symbol="NASDAQ:AAPL"]AAPL[/symbol], [symbol="AMEX:SPY"]SPY[/symbol]. 
It might not work very good on it's not but can give you a pretty good base for more complicated indicators. 

And remember: 
[b]Past performance does not guarantee future results.[/b]

## Source Code

````pine
//@version=3
strategy("Kozlod - RSI Strategy - 1 minute", overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

// Inputs
length     = input(65)
overSold   = input(40)
overBought = input(60)
price      = input(close)

// RSI
vrsi = rsi(price, length)

if (crossover(vrsi, overSold))
    strategy.entry("RsiLE", strategy.long, comment="RsiLE")
if (crossunder(vrsi, overBought))
    strategy.entry("RsiSE", strategy.short, comment="RsiSE")
````
