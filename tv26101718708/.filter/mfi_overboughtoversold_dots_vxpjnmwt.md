# MFI Overbought/Oversold Dots

- url: https://www.tradingview.com/script/VxPjNmWt-MFI-Overbought-Oversold-Dots/
- type: indicator
- pine_id: PUB;98a33a40a5f145a08c21655c59875826
- version: 1.0

## Description

Indicator plots red/green dots above candles when MFI is oversold and overbought

## Source Code

````pine
//@version=5
indicator("MFI Overbought/Oversold Dots", overlay=true)

// Inputs
mfiLength = input.int(14, title="MFI Length")
overbought = input.int(80, title="Overbought Level")
oversold = input.int(20, title="Oversold Level")

// Calculate MFI
mfiValue = ta.mfi(hlc3, mfiLength)

// Conditions
above80 = mfiValue > overbought
below20 = mfiValue < oversold

// Plot dots
plotshape(series=above80, title="MFI Above 80", location=location.abovebar, color=color.red, style=shape.circle, size=size.tiny)

plotshape(series=below20, title="MFI Below 20", location=location.belowbar, color=color.lime, style=shape.circle, size=size.tiny)
````
