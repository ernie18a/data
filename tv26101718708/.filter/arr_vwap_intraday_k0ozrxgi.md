# ARR VWAP Intraday

- url: https://www.tradingview.com/script/K0ozrxGi-ARR-VWAP-Intraday/
- type: strategy
- pine_id: PUB;Yta07K53AA9hHfA5Aog9KG1Xizt7vlyL
- version: 1.0

## Description

Intra day VWAP Strategy 
Strategy is
Buy when vwap goes up and RSI above 50 (Can be modified) . 
Sell wehn vwap goes  down and rsi bellow 50  (Can be modified) 

Exit all at market close hour specified

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ALLURI_RAJU

//@version=4
strategy("ARR VWAP Intraday", overlay=true)
starHrs = input(11, title="Trade start Hours", type=input.integer)
endHrs = input(15, title="Close all trade @ Hours", type=input.integer)
rsiPreiod = input(14, title="RSI Period", type=input.integer)
rsiBuy = input(50, title="Buy when RSI above", type=input.integer)
rsiSell = input(50, title="Sell when RSI Bellow", type=input.integer)
isReversal = input(true, title="Exit on Wap Reversal", type=input.bool)

plot(vwap,color=color.black)

o=(open[1]+close[1])/2
h=max(high,close,o) 
l=min(low,close,o)
c=(open+high+low+close)/4

longCondition = vwap > vwap[1]  and rsi(close,rsiPreiod)>rsiBuy     and hour>starHrs and hour<endHrs
if (longCondition)
    strategy.entry("Buy", strategy.long)

shortCondition =  vwap < vwap[1] and rsi(close,rsiPreiod)<rsiSell  and hour>starHrs and hour<endHrs
if (shortCondition)
    strategy.entry("Sell", strategy.short)
if(isReversal)
    strategy.close("Buy", when = vwap < vwap[1] ,comment = "ExitBuy")
    strategy.close("Sell", when =vwap > vwap[1], comment = "ExitSell")

strategy.close_all(when =   hour == endHrs  , comment = "Exit All")
````
