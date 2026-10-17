# Moving Average Mean Reversion Strategy

- url: https://www.tradingview.com/script/gPWz2g3u-Moving-Average-Mean-Reversion-Strategy/
- type: strategy
- pine_id: PUB;sZNa5cLanqm6jrQxO3VG9O6bVjrHXlL3
- version: 1.0

## Description

A basic mean-reversion strategy. Shorts when the close is 10% above the MA, and goes long when it's 10% below the MA.

## Source Code

````pine
//@version=3
strategy(title="Moving Average Mean Reversion Strategy", shorttitle="MA-MR", overlay=true)
len = input(20, minval=1, title="Length")
src = input(close, title="Source")
out = sma(src, len)
// plot(out*1.1, color=green, title="MA")
// plot(out*0.9, color=green, title="MA")
// plot(out, color=blue, title="MA")
// plot(close, color=red, title="Close")

upper_bound = out * 1.1
lower_bound = out * 0.9

if crossunder(close, lower_bound)
    strategy.entry("buy", strategy.long, comment="MR-LE")

if crossover(close, upper_bound)
    strategy.entry("sell", strategy.short, comment="MR-SE")
````
