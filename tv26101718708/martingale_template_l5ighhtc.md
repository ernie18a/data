# Martingale Template

- url: https://www.tradingview.com/script/l5ighhTc-Martingale-Template/
- type: indicator
- pine_id: PUB;65qtbWfzacU03wc6rM3vCLoTZz67oDUJ
- version: 1.0

## Description

A template example on how to apply the famous Martingale gambling strategy. When your strategy gets an exit signal for your long position that leaves you without profit, you re-enter on the next entry long condition with double the capital of the previous amount entered with. You keep doubling the amount of capital entered with until you finally exit with a profit. If the strategy isn't sound enough then it could take several attempts and it can take only as much as a dozen tries to eat away at all your capital as the capital required to double on the next entry increases greatly over time by consecutive products of 2.

The strategy used is just a simple moving average crossover, above the moving average is going long, below the moving average is going short. It can be replaced with whatever strategy that you want. The colored vertical bars show long and short positions and exits. The default option on the tick box under the settings show the number of attempts at entering before finally exiting with a profit, the other option shows the amount of capital it took starting from 1.

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// Martingale Template
// by SparkyFlary

study(title="Martingale Template", overlay=false)

length = input(20)
showCapitalEnteredWith = input(false)

//example strategy using a simple moving average
sma = sma(close, length)
//strategy conditions go here
buy = close[1]<sma[1] and close>sma
sell = close[1]>sma[1] and close<sma
short = close[1]>sma[1] and close<sma
cover = close[1]<sma[1] and close>sma


entryBuyPrice = 0.0
exitBuyPrice = 0.0
entryBuyPrice := buy ? close : entryBuyPrice[1]
exitBuyPrice := sell ? close : exitBuyPrice[1]
netBuy = sell ? exitBuyPrice - entryBuyPrice : na

entryShortPrice = 0.0
exitShortPrice = 0.0
entryShortPrice := short ? close : entryShortPrice[1]
exitShortPrice := cover ? close : exitShortPrice[1]
netShort = cover ? entryShortPrice - exitShortPrice : na


buyCapitalAmount = 0
shortCapitalAmount = 0
buyCapitalAmount := buy ? (buyCapitalAmount[1]==0?1:buyCapitalAmount[1]*2) : buyCapitalAmount[1]
shortCapitalAmount := short ? (shortCapitalAmount[1]==0?1:shortCapitalAmount[1]*2) : shortCapitalAmount[1]

if sell and netBuy>0
    buyCapitalAmount := 0
if cover and netShort>0
    shortCapitalAmount := 0

numBuyAttempts = (log(buyCapitalAmount)/log(2)) + 1
numShortAttempts = (log(shortCapitalAmount)/log(2)) + 1

//plots show by default number of attempts on entries before finally exiting with profit
//if showCapitalEnteredWith option is ticked, then it'll show the amount of capital it took to finally exit with profit, starting from 1
plot(showCapitalEnteredWith?buyCapitalAmount:numBuyAttempts, color=color.green)
plot(showCapitalEnteredWith?shortCapitalAmount:numShortAttempts, color=color.red)
//colored bars show entries for long and short positions
bgcolor(color=buy?color.green:short?color.red:na)
````
