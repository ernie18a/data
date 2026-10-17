# 5-Bar High/Low Labels

- url: https://www.tradingview.com/script/jybcdfj5-5-Bar-High-Low-Labels/
- type: indicator
- pine_id: PUB;4e14ef48ff244e939247443f664baf78
- version: 1.0

## Description

basic script to show top and bottom labels in the previous 5 bars.

## Source Code

````pine
//@version=6
indicator("5-Bar High/Low Labels", overlay=true)

// Check if current high/low breaks past the previous 5 bars (excluding current bar)
isNewHigh = high > ta.highest(high, 5)[1]
isNewLow  = low < ta.lowest(low, 5)[1]

// Create labels for New Highs
if isNewHigh
    label.new(x=bar_index, y=high, text=str.tostring(high, "#.##"), 
              color=color.green, textcolor=color.white, 
              style=label.style_label_down, yloc=yloc.abovebar, size=size.small)

// Create labels for New Lows
if isNewLow
    label.new(x=bar_index, y=low, text=str.tostring(low, "#.##"), 
              color=color.red, textcolor=color.white, 
              style=label.style_label_up, yloc=yloc.belowbar, size=size.small)
````
