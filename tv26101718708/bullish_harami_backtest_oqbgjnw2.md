# Bullish Harami Backtest

- url: https://www.tradingview.com/script/OqBGjNw2-Bullish-Harami-Backtest/
- type: strategy
- pine_id: PUB;CWX0wyU22bDbpYWRfbk5HJtq5SPQQkNX
- version: 1.0

## Description

This is a bullish reversal pattern formed by two candlesticks in which a small 
    real body is contained within the prior session's unusually large real body.
    Usually the second real body is the opposite color of the first real body. 
    The Harami pattern is the reverse of the Engulfing pattern. 

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=3
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 18/01/2019
//    This is a bullish reversal pattern formed by two candlesticks in which a small 
//    real body is contained within the prior session's unusually large real body.
//    Usually the second real body is the opposite color of the first real body. 
//    The Harami pattern is the reverse of the Engulfing pattern. 
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
strategy(title = "Bullish Harami Backtest", overlay = true)
input_takeprofit = input(60, title="Take Profit pip")
input_stoploss = input(18, title="Stop Loss pip")
input_minsizebody = input(1, title="Min. Size Body pip", step = 0.01)
barcolor(abs(close - open) >= input_minsizebody ? open[1] > close[1] ? close > open ? close <= open[1] ? close[1] <= open ? close - open < open[1] - close[1] ? yellow :na :na : na : na : na : na)
pos = 0.0
barcolor(nz(pos[1], 0) == -1 ? red: nz(pos[1], 0) == 1 ? green : blue ) 
posprice = 0.0
posprice := abs(close - open) >= input_minsizebody? open[1] > close[1] ? close > open ? close <= open[1] ? close[1] <= open ? close - open < open[1] - close[1] ? close :nz(posprice[1], 0) :nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0) : nz(posprice[1], 0): nz(posprice[1], 0)
pos := iff(posprice > 0, 1, 0)
if (pos == 0) 
    strategy.close_all()
if (pos == 1)
    strategy.entry("Long", strategy.long)
posprice := iff(low <= posprice - input_stoploss and posprice > 0, 0 ,  nz(posprice, 0))
posprice := iff(high >= posprice + input_takeprofit and posprice > 0, 0 ,  nz(posprice, 0))
````
