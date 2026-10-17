# Inside Bar Failure

- url: https://www.tradingview.com/script/tyffFjO0-Inside-Bar-Failure/
- type: strategy
- pine_id: PUB;9jmDV9lMORwwaHaXJd5Zj6tPCiYb3H40
- version: 1.0

## Description

You can check edge profitability by adjusting the forward looking input, eg. how profitable is this signal after X bars.

## Source Code

````pine
//@version=3
strategy("Inside Bar Failure", overlay=true)

forward = input(defval=3, title="Look Forward")

longCondition = if (high[2] > high[1] and low[2] < low[1] and low < low[1] and high < high[1] and close > low[1])
    x = true
if (longCondition)
    strategy.entry("Long", strategy.long)

shortCondition = if (high[2] > high[1] and low[2] < low[1] and high > high[1] and low > low[1] and close < high[1])
    y = true
if (shortCondition)
    strategy.entry("Short", strategy.short)
    
if (longCondition[forward])
    strategy.close("Long")
if (shortCondition[forward])
    strategy.close("Short")
````
