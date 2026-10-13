<!-- tradingview-pine-id: PUB;92bee7b967304ed18d82afafe4d41745 -->
<!-- tradingviewscripts-format: 1 -->
# ATH and Near ATH Marker

Source: https://www.tradingview.com/script/cS6HOwZz-ATH-and-Near-ATH-Marker/

## Description

This light indicator helps you quickly identify historical ATH breakouts and key resistance testing zones.

Features:

Blue X (Above Bar): Signals a new All-Time High print.

Yellow X (Above Bar): Signals price approaching within a customizable threshold (default: 2%) of the previous ATH without breaking it.

Customizable Inputs: Easily adjust the proximity percentage threshold via settings.

---

## Source Code

````pine
//@version=6
indicator("ATH and Near ATH Marker", overlay=true)

// Input Settings
threshold_pct = input.float(2.0, title="Proximity Threshold (%)", minval=0.1, step=0.1)
show_blue_x   = input.bool(true, title="Show Blue X (New ATH)")
show_yellow_x = input.bool(true, title="Show Yellow X (Near ATH)")

// Historical ATH Tracking
var float ath = 0.0

// New ATH Condition
is_new_ath = high > ath and bar_index > 0

// Near ATH Threshold Calculation
near_threshold = ath * (1.0 - (threshold_pct / 100.0))

// Near ATH Condition
is_near_ath = high >= near_threshold and not is_new_ath and ath > 0

// Update ATH
if high > ath
    ath := high

// Plot Blue X for New ATH
plotshape(show_blue_x and is_new_ath, title="New ATH (Blue X)", style=shape.xcross, 
          location=location.abovebar, color=color.blue, size=size.small)

// Plot Yellow X for Near ATH
plotshape(show_yellow_x and is_near_ath, title="Near ATH (Yellow X)", style=shape.xcross, 
          location=location.abovebar, color=color.yellow, size=size.small)
````
