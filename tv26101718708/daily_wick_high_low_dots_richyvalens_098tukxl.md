# Daily Wick High Low Dots Richyvalens

- url: https://www.tradingview.com/script/098TukXL/
- type: indicator
- pine_id: PUB;67e81cab5b464721b6c6f12c57ceb20d
- version: 1.0

## Description

Con el fin de evitar marcar altos y bajos diarios, espero les sirva.

## Source Code

````pine
//@version=5
indicator("Daily Wick High Low Dots", overlay=true)

dayHigh = request.security(syminfo.tickerid, "D", high)
dayLow = request.security(syminfo.tickerid, "D", low)

isHigh = high == dayHigh
isLow = low == dayLow

plotshape(isHigh ? high : na, style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)

plotshape(isLow ? low : na, style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)
````
