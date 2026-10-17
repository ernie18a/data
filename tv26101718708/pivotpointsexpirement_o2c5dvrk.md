# Pivot_Points_Expirement

- url: https://www.tradingview.com/script/o2c5dvrK-Pivot-Points-Expirement/
- type: strategy
- pine_id: PUB;qpWaW2JhTkByAHHPD4SanjfDGIEbJKQ5
- version: 1.0

## Description

Pivot_Points_Expirement

## Source Code

````pine
//@version=4
strategy("Pivot_Points_Expirement", overlay=true)


plot(pivothigh(open[1],20, 20))
plot(pivotlow(open[1],20, 20))

longCondition = cross(open,pivotlow(open[1],20, 20))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=5000,trail_points=100)

shortCondition = cross(open,pivothigh(open[1],20, 20))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=5000,trail_points=100)
````
