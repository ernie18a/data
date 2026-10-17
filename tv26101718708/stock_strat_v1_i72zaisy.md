# Stock Strat v1

- url: https://www.tradingview.com/script/i72ZAisy-Stock-Strat-v1/
- type: strategy
- pine_id: PUB;mAdJrVhI0sl1dGBWH9eCwq91mQcroiNy
- version: 1.0

## Description

Stock Strat v1 


Buy: mom > mom1 and mom1 > mom2 and rsi > 80 

Sell: mom < mom1 and mom1 < mom2 and rsi < 80

## Source Code

````pine
//@version=4
strategy("Stock Strat v1", overlay=true)

longCondition = mom(close[2],10) < mom(close[1],10) and mom(close[1],10) < mom(close[0],10) and rsi(close,14) < 31
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=500,trail_points=50)

shortCondition = mom(close[2],10) > mom(close[1],10) and mom(close[1],10) > mom(close[0],10) and rsi(close,14) < 80
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=500,trail_points=50)
````
