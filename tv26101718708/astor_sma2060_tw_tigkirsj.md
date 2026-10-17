# Astor SMA20/60 TW

- url: https://www.tradingview.com/script/TiGkIrSj/
- type: strategy
- pine_id: PUB;3f5f5b3f859d4b55b6cdb3843d5d16b6
- version: 1.0

## Description

這是給台股用的
跟前一篇一樣
只是修改了每次購買的數量大小

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astorhsu

//@version=5
strategy("Astor SMA20/60 TW", overlay=true, margin_long=100, margin_short=100)
backtest_year = input(2018, title='backtest_year') //回測開始年分
backtest_month = input.int(01, title='backtest_month', minval=1, maxval=12) //回測開始月份
backtest_day = input.int(01, title='backtest_day', minval=1, maxval=31)  //回測開始日期
start_time = timestamp(backtest_year, backtest_month, backtest_day, 00, 00)  //回測開始的時間函數

//Indicators
sma20 = ta.sma(close,20)
sma60 = ta.sma(close,60)
plot(sma20, color=color.green, title="sma(20)")
plot(sma60, color=color.red, title="sma(60)")

//進場條件
longCondition = ta.crossover(close, ta.sma(close, 20))
if (longCondition) and time >= start_time
    strategy.entry("open long20", strategy.long, qty=1, comment="站上m20做多")


shortCondition = ta.crossunder(close, ta.sma(close, 20))
if (shortCondition) and time >= start_time
    strategy.close("open long20",comment="跌破m20平倉", qty=1)     
    
longCondition1 = ta.crossover(close, ta.sma(close, 60))
if (longCondition1) and time >= start_time
    strategy.entry("open long60", strategy.long, qty=1, comment="站上m60做多")


shortCondition1 = ta.crossunder(close, ta.sma(close, 60))
if (shortCondition1) and time >= start_time
    strategy.close("open long60",comment="跌破m60平倉", qty=1)
````
