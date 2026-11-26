# Midnight Reset VWAP

- url: https://www.tradingview.com/script/q8NdvPz7-Midnight-Reset-VWAP/
- type: indicator
- pine_id: PUB;f92c6f5efd084ab892c44179d5ccc745
- version: 1.0

## Description

kay. resets at midddddnight. good luck, td wants long description so just typing

## Source Code

````pine
//@version=5
indicator("Midnight Reset VWAP", overlay=true)

// Detect new day safely
newDay = ta.change(time("D")) != 0

var float cumulativePV = na
var float cumulativeVolume = na

// Initialize on first bar or reset on new day
if na(cumulativePV) or newDay
    cumulativePV := hlc3 * volume
    cumulativeVolume := volume
else
    cumulativePV += hlc3 * volume
    cumulativeVolume += volume

vwap = cumulativePV / cumulativeVolume

plot(vwap, color=color.orange, linewidth=2, title="VWAP (Midnight Reset)")
````
