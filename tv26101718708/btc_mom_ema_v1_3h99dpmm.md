# BTC MOM EMA V1

- url: https://www.tradingview.com/script/3H99dPmM-BTC-MOM-EMA-V1/
- type: strategy
- pine_id: PUB;4c9O1j8VGdZ7ySiG4lNfERPNIVnNAu79
- version: 1.0

## Description

BTC MOM EMA V1

## Source Code

````pine
//@version=4
strategy("BTC MOM EMA V1", overlay=true)

longCondition = mom(close,5) > 50 and mom(close[1],5) > 50 and mom(close[2],5) > 50 and close > ema(close,5)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=1000,trail_points=60)

shortCondition = mom(close,5) < 50 and mom(close[1],5) < 50 and mom(close[2],5) < 50 and close < ema(close,5)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=1000,trail_points=60)
````
