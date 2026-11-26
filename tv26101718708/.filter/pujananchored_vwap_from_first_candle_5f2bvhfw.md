# Pujan_Anchored VWAP (From First Candle)

- url: https://www.tradingview.com/script/5f2bvHfw-Pujan-Anchored-VWAP-From-First-Candle/
- type: indicator
- pine_id: PUB;95c26e1871074cac8a0213a179b6be99
- version: 1.0

## Description

If you want VWAP anchored to the very first candle of the chart (no reset at all), then the logic is simple: start accumulating from the first visible bar and keep going.

## Source Code

````pine
//@version=5
indicator("Anchored VWAP (From First Candle)", overlay=true)

// Persistent variables
var float cumulativePV = 0.0
var float cumulativeVolume = 0.0

// Initialize on very first bar
if bar_index == 0
    cumulativePV := close * volume
    cumulativeVolume := volume
else
    cumulativePV += close * volume
    cumulativeVolume += volume

// VWAP calculation
vwap = cumulativePV / cumulativeVolume

plot(vwap, color=color.blue, linewidth=2, title="Anchored VWAP")
````
