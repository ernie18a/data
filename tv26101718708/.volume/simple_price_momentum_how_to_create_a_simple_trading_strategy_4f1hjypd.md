# Simple Price Momentum - How To Create A Simple Trading Strategy

- url: https://www.tradingview.com/script/4F1hjypD-Simple-Price-Momentum-How-To-Create-A-Simple-Trading-Strategy/
- type: strategy
- pine_id: PUB;820Et5xn1jj5tJ0nKUieklzbFc3lV3R8
- version: 1.0

## Description

This script was built using a logical approach to trading systems. All the details can be found in a step by step guide below. I hope you enjoy it. I am really glad to be part of this community. Thank you all. I hope you not only succeed on your trading career but also enjoy it.

https://docs.google.com/document/d/1fXxCtPuGgTXb-RuBJNbwlfgkeiLTK5060LfTrzRlr5k/

## Source Code

````pine
//@version=4
strategy(title = "Simple Price Momentum", shorttitle = "SPM", overlay = true, initial_capital = 20000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.025)

// How To Create A Simple Trading Strategy With TradingView
// https://docs.google.com/document/d/1fXxCtPuGgTXb-RuBJNbwlfgkeiLTK5060LfTrzRlr5k/view

swmaClose = swma(close)
vwapClose = vwap(close)

swmaLong = close > swmaClose
vwapLong = close > vwapClose

triggerLong = vwapLong and not vwapLong[1] and not swmaLong and not swmaLong[1]
saveLong = false, saveLong := triggerLong ? true : not vwapLong ? false : saveLong[1]

startLong = saveLong and swmaLong
startLong := input(false, "Consecutive Orders") ? startLong : startLong and not startLong[1]

stopLoss = input(250, "Stop Loss", step = 50)
takeProfit = input(10, "Reward/Risk") * stopLoss

strategy.entry("Open Long", strategy.long, when = startLong)
strategy.exit("Exit Long", "Open Long", profit = stopLoss, loss = takeProfit)

// bgcolor(swmaLong ? color.blue : na)
// bgcolor(vwapLong ? color.orange : na)
// bgcolor(triggerLong ? color.purple : na)
// bgcolor(saveLong ? color.yellow : na)
bgcolor(startLong[1] ? color.green : na)
````
