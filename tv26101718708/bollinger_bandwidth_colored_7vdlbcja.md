# Bollinger BandWidth Colored

- url: https://www.tradingview.com/script/7vdLbCJa-Bollinger-BandWidth-Colored/
- type: indicator
- pine_id: PUB;beec9140bff74f04a79c1f1d14e705e0
- version: 1.0

## Description

Behavior:

Green → current candle closed with BBW rising by 2 points or more versus previous candle.
Gray → BBW is flat or rising less than 2 points.
Red → BBW is decreasing.

You can also:

Change the threshold directly in settings.
Customize all colors from the indicator settings panel.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rain_mustfall

//@version=6
indicator(title="Bollinger BandWidth Colored", shorttitle="BBW Colored", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// Inputs
length = input.int(20, "Length", minval = 1)
src    = input(close, "Source")
mult   = input.float(2.0, "StdDev", minval = 0.001, maxval = 50)

expansionLengthInput   = input.int(125, "Highest Expansion Length", minval = 1, display = display.none)
contractionLengthInput = input.int(125, "Lowest Contraction Length", minval = 1, display = display.none)

// Threshold
moveThreshold = input.float(0.02, "Green Threshold", step = 0.01)

// Custom Colors
greenColor = input.color(color.lime, "Strong Up Color")
grayColor  = input.color(color.gray, "Weak Up / Flat Color")
redColor   = input.color(color.red, "Down Color")

// BBW Calculation
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)

upper = basis + dev
lower = basis - dev

bbw = ((upper - lower) / basis) * 100

// Difference from previous closed candle
bbwDiff = bbw - bbw[1]

// Color Logic
bbwColor =
     bbwDiff >= moveThreshold ? greenColor :
     bbwDiff < 0              ? redColor :
                                  grayColor

// Main Plot
plot(bbw, title="BBW", color=bbwColor, linewidth=3)

// Optional Highest / Lowest plots
plot(
    ta.highest(bbw, expansionLengthInput),
    title="Highest Expansion",
    color=color.new(#F23645, 50)
)

plot(
    ta.lowest(bbw, contractionLengthInput),
    title="Lowest Contraction",
    color=color.new(#089981, 50)
)
````
