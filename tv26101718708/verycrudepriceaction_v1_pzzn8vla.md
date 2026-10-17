# VeryCrudePriceAction V1

- url: https://www.tradingview.com/script/PzZN8vlA-VeryCrudePriceAction-V1/
- type: strategy
- pine_id: PUB;pY0UweGdHcsIvY0VuJJjrJVmLdguTd3F
- version: 1.0

## Description

VeryCrudePriceAction V1

## Source Code

````pine
//@version=4
strategy("VeryCrudePriceAction V1", overlay=true)

source = highest(close[31],31)
source1 = lowest(close[31],31)

mult = input(4.0, minval=0.001, maxval=50)

basis = sma(source, 1)
dev = mult * stdev(source, 2)

basis1 = sma(source1, 1)
dev1 = mult * stdev(source, 2)

upper = basis + dev
lower = basis1 - dev

plot(upper)
plot(lower)

buyEntry = crossover(close, lower)
sellEntry = crossunder(close, upper)


longCondition = buyEntry 
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id",profit=1000,loss=50,trail_points=80)

shortCondition = sellEntry 
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id",profit=1000,loss=50,trail_points=80)
````
