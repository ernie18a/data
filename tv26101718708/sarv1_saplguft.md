# SAR_V1

- url: https://www.tradingview.com/script/sAPlGuft-SAR-V1/
- type: strategy
- pine_id: PUB;czV8Jc3AQ64I3CK5Hww1UJLzB8oTfpaC
- version: 1.0

## Description

SAR_V1

## Source Code

````pine
//@version=4
strategy("SAR_V1", overlay=true)


sar = sar(.04,.04,.4)

longCondition = sar[2] < sar[1] and sar[1] < sar and cross(high,sar)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
    strategy.exit("My Long Entry Id", profit=1000,loss=50,trail_points=50)

shortCondition =  sar[2] > sar[1] and sar[1] > sar and cross(low,sar)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    strategy.exit("My Short Entry Id", profit=1000,loss=50,trail_points=50)
````
