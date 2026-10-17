# Strategy for The Bitcoin Buy/Sell Indicator

- url: https://www.tradingview.com/script/oiVFpfAo-Strategy-for-The-Bitcoin-Buy-Sell-Indicator/
- type: strategy
- pine_id: PUB;kk4MxLQ42FeXMPNNVxMWqmHMdMVKPhqi
- version: 2.0

## Description

This is the strategy for https://www.tradingview.com/script/Q5nQJQNc-The-Bitcoin-Buy-Sell-Signal-using-multiple-combined-indicators/

Starting with a capital of [b]$3,000 XBT[/b], one might have [b]$15,975 dollar worth of XBT[/b] plus whatever the bitcoin has appreciated over the years.
The Sharpe Ratio: 0.586, Net Profit is 532%,  57 closed trades from 2017 till today, Profit factor of 3.745 (aka for every dollar loss, there is 3.745 dollar profit) with [b]14% drawdown[/b].

Let that sink in.

## Source Code

````pine
//@version=4
strategy("SMA Crossover Strategy", overlay=true)

shortSma = sma(close, 20)
longSma = sma(close, 100)

if crossover(shortSma, longSma)
    strategy.entry("Buy", strategy.long)

if crossunder(shortSma, longSma)
    strategy.entry("Sell", strategy.short)

plot(shortSma, color=color.red)
plot(longSma, color=color.blue)
````
