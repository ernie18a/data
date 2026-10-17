# SMA Strategy for TVExtBot

- url: https://www.tradingview.com/script/5Jg2qvS6/
- type: strategy
- pine_id: PUB;0wFpCzMEBEEMy4SO5NXyBmk1xsyKiDYD
- version: 1.0

## Description

TVExtBot for Cryptocurrency 戦略サンプル

## Source Code

````pine
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//【説明】TVExtBot for Cryptocurrency 戦略サンプル
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//@version=3
strategy("SMA Strategy for TVExtBot", overlay=true)

FromYear  = input(defval = 2019, title = "From Year", minval = 2010)
FromMonth = input(defval = 1, title = "From Month", minval = 1)
FromDay   = input(defval = 1, title = "From Day", minval = 1)
ToYear    = input(defval = 2019, title = "To Year", minval = 2010)
ToMonth   = input(defval = 12, title = "To Month", minval = 1)
ToDay     = input(defval = 31, title = "To Day", minval = 1)

FromDate = timestamp("GMT+9",FromYear,FromMonth,FromDay, 0, 1)
ToDate = timestamp("GMT+9",ToYear,ToMonth,ToDay, 0, 1)

BGColor =  (time >= FromDate) and (time <= ToDate) ? #FFFF4D : na
bgcolor(BGColor, transp=94)
BackTest() =>
    time >= FromDate and time <= ToDate ? true : false

longCondition = crossover(sma(close, 14), sma(close, 28))
if (BackTest() and longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 14), sma(close, 28))
if (BackTest() and shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
