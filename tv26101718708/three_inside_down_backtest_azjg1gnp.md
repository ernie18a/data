# Three Inside Down Backtest

- url: https://www.tradingview.com/script/azjG1gnP-Three-Inside-Down-Backtest/
- type: strategy
- pine_id: PUB;a82JmfOCu6QxtSih3wQ7tt49Iaft27Ag
- version: 1.0

## Description

This is a three candlestick bearish reversal pattern consisting of a bearish 
    harami pattern formed by the first 2 candlesticks then followed by down 
    candlestick with a lower close than the prior candlestick.
 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 06/02/2019
//    This is a three candlestick bearish reversal pattern consisting of a bearish 
//    harami pattern formed by the first 2 candlesticks then followed by down 
//    candlestick with a lower close than the prior candlestick.
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title = "Three Inside Down Backtest", overlay = true)
input_takeprofit = input(40, title="Take Profit pip", step=0.01)
input_stoploss = input(20, title="Stop Loss pip", step=0.01)
barcolor(close[2] > open[2] ? open[1] > close[1] ? open[1] <= close[2] ? open[2] <= close[1] ? open[1] - close[1]< close[2] - open[2] ? close < open ? close < close[1] ? open < open[1] ? close < open[2] ? yellow :na :na : na : na : na:na : na : na : na)
posprice = 0.0
pos = 0.0
barcolor(nz(pos[1], 0) == -1 ? red: nz(pos[1], 0) == 1 ? green : blue ) 
posprice :=  close[2] > open[2] ? open[1] > close[1] ? open[1] <= close[2] ? open[2] <= close[1] ? open[1] - close[1]< close[2] - open[2] ? close < open ? close < close[1] ? open < open[1] ? close < open[2] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) :nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0):nz(posprice[1], 0) 
pos := iff(posprice > 0, 1, 0)
if (pos == 0) 
    strategy.close_all()
if (pos == 1)
    strategy.entry("Long", strategy.long)
posprice := iff(high >= posprice + input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(low <= posprice - input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
````
