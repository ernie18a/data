# Simple Institutional VWAP Overlay

- url: https://www.tradingview.com/script/fotl68tB-Simple-Institutional-VWAP-Overlay/
- type: indicator
- pine_id: PUB;f6bd93b83d144b04bf833e064b61074f
- version: 1.0

## Description

+ Just a very simple VWAP configuration to help traders understand volume weighted average profile. 
Sharp increases and decreases mean large changes to the order flow pattern. 

What to look out for
1) Sharp drops.
2) Sharp rises. 

Drops = large selling behavior
Rises= large buying behavior
+

## Source Code

````pine
//@version=6
indicator("Simple Institutional VWAP Overlay", overlay=true)

// ==========================================
// SESSION BOUNDARY AND CORES
// ==========================================
bool newDayReset = not na(ta.change(time("D")))

var float vwapVolumeSum = na
var float trueVolumeSum = na

if newDayReset
    vwapVolumeSum := close * volume
    trueVolumeSum := volume
else
    vwapVolumeSum := vwapVolumeSum + (close * volume)
    trueVolumeSum := trueVolumeSum + volume

// Calculate Native Anchor
float marketVWAP = vwapVolumeSum / trueVolumeSum

// Smooth high-visibility visualization line
plot(marketVWAP, "Daily Anchor VWAP", color=color.teal, linewidth=2, style=plot.style_line)
````
