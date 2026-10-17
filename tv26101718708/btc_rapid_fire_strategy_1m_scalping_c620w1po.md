# BTC Rapid fire strategy 1M Scalping

- url: https://www.tradingview.com/script/c620W1po-BTC-Rapid-fire-strategy-1M-Scalping/
- type: strategy
- pine_id: PUB;dBdhJrQ0tWoBOpognfCmitogSnQqCjOc
- version: 1.0

## Description

Rapid Fire strategy is known for scalping strategy for 1 min EURUSD
I change 15 pip stop loss for eurusd and 1.5% for BTC
for Take profit 10 pip foreurusd and 1% for BTC

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © atakhadivi

//@version=4
strategy("rapid fire", overlay=true)

longCondition = open > sar(0.02,0.02,0.2) and open[1] < sar(0.02,0.02,0.2)[1] and open > sma(close,50)
takeprofit = strategy.position_avg_price * (1 + 0.005)
stopLoss = strategy.position_avg_price * (1 - 0.015)
if (longCondition)
    strategy.entry("longEntry", strategy.long, limit = takeprofit, stop = stopLoss)


shortCondition = open < sar(0.02,0.02,0.2) and open[1] > sar(0.02,0.02,0.2)[1] and open < sma(close,50)
take_profit = strategy.position_avg_price * (1 - 0.005)
stop_Loss = strategy.position_avg_price * (1 + 0.015)
if (shortCondition)
    strategy.entry("shortEntry", strategy.short, limit = take_profit, stop = stop_Loss)
````
