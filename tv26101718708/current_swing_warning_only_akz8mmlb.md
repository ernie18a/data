# Current Swing Warning Only

- url: https://www.tradingview.com/script/akz8mMlB-Current-Swing-Warning-Only/
- type: indicator
- pine_id: PUB;efa1270a6c904f378132f4fe1d2401c9
- version: 1.0

## Description

This is a Script made I made with chat GBT, which give a visual of potencial swing point forming.

## Source Code

````pine
//@version=6
indicator("Current Swing Warning Only", overlay=true, max_labels_count=10, max_lines_count=10)

//━━━━━━━━━━ INPUTS ━━━━━━━━━━//
showHighs = input.bool(true, "Show Swing High")
showLows  = input.bool(true, "Show Swing Low")

highColor = input.color(color.red, "High Color")
lowColor  = input.color(color.lime, "Low Color")

extendLevels = input.bool(true, "Extend Current Levels")

//━━━━━━━━━━ SWING LOGIC ━━━━━━━━━━//

potentialSwingHigh = (
     high[1] > high[2] and
     high[1] >= high and
     low < open[1]
)

potentialSwingLow = (
     low[1] < low[2] and
     low[1] <= low and
     high > open[1]
)

//━━━━━━━━━━ STORAGE ━━━━━━━━━━//

var label currentHighLabel = na
var label currentLowLabel  = na

var line currentHighLine = na
var line currentLowLine  = na

//━━━━━━━━━━ SWING HIGH ━━━━━━━━━━//

if potentialSwingHigh and showHighs

    // Delete previous objects
    label.delete(currentHighLabel)
    line.delete(currentHighLine)

    // Create label
    currentHighLabel := label.new(
         x=bar_index[1],
         y=high[1],
         text="SH",
         style=label.style_label_down,
         color=highColor,
         textcolor=color.white,
         size=size.small
     )

    // Create level
    if extendLevels
        currentHighLine := line.new(
             x1=bar_index[1],
             y1=high[1],
             x2=bar_index,
             y2=high[1],
             extend=extend.right,
             color=highColor,
             width=1
         )

//━━━━━━━━━━ SWING LOW ━━━━━━━━━━//

if potentialSwingLow and showLows

    // Delete previous objects
    label.delete(currentLowLabel)
    line.delete(currentLowLine)

    // Create label
    currentLowLabel := label.new(
         x=bar_index[1],
         y=low[1],
         text="SL",
         style=label.style_label_up,
         color=lowColor,
         textcolor=color.white,
         size=size.small
     )

    // Create level
    if extendLevels
        currentLowLine := line.new(
             x1=bar_index[1],
             y1=low[1],
             x2=bar_index,
             y2=low[1],
             extend=extend.right,
             color=lowColor,
             width=1
         )

//━━━━━━━━━━ ALERTS ━━━━━━━━━━//

alertcondition(
     potentialSwingHigh,
     title="Potential Swing High",
     message="Potential Swing HIGH detected"
)

alertcondition(
     potentialSwingLow,
     title="Potential Swing Low",
     message="Potential Swing LOW detected"
)
````
