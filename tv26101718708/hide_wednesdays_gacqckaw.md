# Hide Wednesdays

- url: https://www.tradingview.com/script/gACqCKaW-Hide-Wednesdays/
- type: indicator
- pine_id: PUB;0163c1f92f4a41d6afd49d8396b76c73
- version: 1.0

## Description

useless day. POS day. HumpDayDumpDay felll off the chart

## Source Code

````pine
//@version=5
indicator("Hide Wednesdays", overlay=true)

// Check if today is Wednesday
isWednesday = dayofweek(time) == dayofweek.wednesday

// If it is Wednesday, make it completely transparent. Otherwise, leave it alone (na).
hideColor = isWednesday ? color.new(color.blue, 100) : na

// Apply the transparent color to the bars
barcolor(hideColor)
````
