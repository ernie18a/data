# Anchored VWAP_Pujan

- url: https://www.tradingview.com/script/VrdZaRNo-Anchored-VWAP-Pujan/
- type: indicator
- pine_id: PUB;e2e0f22184284259a433afeae0dfaaca
- version: 2.0

## Description

If you want VWAP anchored to the very first candle of the chart (no reset at all), then the logic is simple: start accumulating from the first visible bar and keep going.

## Source Code

````pine
//@version=5
indicator("Anchored_VWAP_Pujan", overlay=true)

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
