# TrumpShipper_Long_Short V26

- url: https://www.tradingview.com/script/0Fclf4ol/
- type: strategy
- pine_id: PUB;rmTT2igZhVeqM1MWH6PjSGtYm0Tysj5Q
- version: 2.0

## Description

Signal Long Short with BB, exactly to 80%

## Source Code

````pine
//@version=2
//Design by MrPhu in August,10,2018
strategy("TrumpShipper_Long_Short V26", overlay=true)
filterFractals = input(true, title=" Follow Code #Trump On/Off")
dt = 0.0001
confidence=(security(tickerid, 'D', close)-security(tickerid, 'D', close[1]))/security(tickerid, 'D', close[1])
prediction = confidence > dt ? true : confidence < -dt ? false : prediction[1]

if (prediction)
    strategy.exit("Close", "Short ")
    strategy.entry("Long ", strategy.long, qty=10000*confidence)

if (not prediction)
    strategy.exit("Close", "Long ")
    strategy.entry("Short ", strategy.short, qty=-10000*confidence)
````
