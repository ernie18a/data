# Permanent Wednesday Red Bars

- url: https://www.tradingview.com/script/A1wYTIRx-Permanent-Wednesday-Red-Bars/
- type: indicator
- pine_id: PUB;8eb7b31c265d475c983b17c3bbbe5370
- version: 1.0

## Description

OHLC bars in red for WEDNESDAYS. thats it. super simple

## Source Code

````pine
//@version=5
indicator("Permanent Wednesday Red Bars", overlay=true)

// Check if today is Wednesday
isWednesday = dayofweek(time) == dayofweek.wednesday

// If it is Wednesday, make it red. If not, make it transparent (na)
barColor = isWednesday ? color.red : na

// Override the bar colors
barcolor(barColor)
````
