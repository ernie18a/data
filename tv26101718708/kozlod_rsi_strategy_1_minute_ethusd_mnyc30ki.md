# Kozlod - RSI Strategy - 1 minute - ETHUSD

- url: https://www.tradingview.com/script/MNyc30Ki-Kozlod-RSI-Strategy-1-minute-ETHUSD/
- type: strategy
- pine_id: PUB;wA4gC6uxfH6zpMj47iaXnebs9ixPgTcb
- version: 2.0

## Description

Trying to find simple strategies with optimal parameters which work well for certain symbols/timeframe. 
Found that basic RSI strategy without any position management works pretty good for 1m chart for BTCUSDT. 
It might not work very good on it's not but can give you a pretty good base for more complicated indicators. 
Also, some position management as simple as static SL and PT can improve performance quite a lot. 

And remember: 
Past performance does not guarantee future results.

## Source Code

````pine
//@version=3
strategy("Kozlod - RSI Strategy - 1 minute", overlay = false, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

// Inputs
length     = input(23)
overSold   = input(54, type = float)
overBought = input(65, type = float)
price      = input(close)

// RSI
vrsi = rsi(price, length)

plot(vrsi)
plot(overSold, color = red)
plot(overBought, color = green)

if (crossover(vrsi, overSold))
    strategy.entry("RsiLE", strategy.long, comment="RsiLE")
if (crossunder(vrsi, overBought))
    strategy.entry("RsiSE", strategy.short, comment="RsiSE")
````
