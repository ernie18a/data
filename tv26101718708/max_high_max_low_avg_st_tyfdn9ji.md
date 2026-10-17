# Max High Max Low AVG ST

- url: https://www.tradingview.com/script/tYFdN9ji-Max-High-Max-Low-AVG-ST/
- type: strategy
- pine_id: PUB;AvKKDRaG1QDMh6cRV8Qn05DcBl8bMf30
- version: 1.0

## Description

Max High Max Low AVG ST

## Source Code

````pine
//@version=4
strategy("My Strategy", overlay=true)

FM = input(defval=8,minval=1)
SM = input(defval=20,minval=1)

diff = max(high,sma(high,100)) - max(close,sma(close,50))
avg = avg(max(high,sma(high,100)),max(close,sma(close,50)))
div = diff/avg
mult = div*100

longCondition = crossover(sma(mult,FM), sma(mult,SM))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id",profit=200,loss=30,trail_points=20)

shortCondition = crossunder(sma(mult,FM), sma(mult,SM))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id",profit=200,loss=30,trail_points=20)
````
