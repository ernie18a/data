# Buy_Only

- url: https://www.tradingview.com/script/px1cnHpr-Buy-Only/
- type: strategy
- pine_id: PUB;CoXES0ttdCEKp7kFYjnSEItSqITOEYBE
- version: 1.0

## Description

Buy_Only

## Source Code

````pine
//@version=4
strategy("Buy_Only", overlay=false)

H = highest(open,31)
L = lowest(open,31)

HM = mom(high,10)
HL = mom(low,20)


longCondition = crossover(HL, HM) and low < H
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=1000,loss=500,trail_points=50)
````
