# Volume vs 30D Avg + RVOL

- url: https://www.tradingview.com/script/nNAPavRZ-Volume-vs-30D-Avg-RVOL/
- type: indicator
- pine_id: PUB;af87f7a708aa43e09818be1ca4b3f73f
- version: 1.0

## Description

Compares the current volume with the 30 days average volume and draws on the chart

## Source Code

````pine
//@version=6
indicator("Volume vs 30D Avg + RVOL", shorttitle="Vol vs 30D", format=format.volume)

// Inputs
lookback = input.int(30, "Average Volume Lookback (days)", minval=2)
showLabel = input.bool(true, "Show RVOL label on last bar")

// Core calculations
avgVol  = ta.sma(volume, lookback)
rvol    = volume / avgVol
isUp    = close >= open
isHigh  = rvol >= 1.0

// Bar colors
volColor = isHigh ? (isUp ? color.new(color.green, 20) : color.new(color.red, 20)) : (isUp ? color.new(color.green, 70) : color.new(color.red, 70))

// Plots
plot(volume, title="Volume", style=plot.style_columns, color=volColor)
plot(avgVol, title="Avg Volume", color=color.orange, linewidth=2)

// RVOL label on last bar
var label rvolLabel = na
if barstate.islast and showLabel
    label.delete(rvolLabel)
    txt = "RVOL: " + str.tostring(rvol, "#.##") + "x\n" + "Vol: " + str.tostring(volume, format.volume) + "\n" + "Avg: " + str.tostring(avgVol, format.volume)
    lblColor = isHigh ? color.new(color.green, 20) : color.new(color.gray, 20)
    rvolLabel := label.new(bar_index, volume, txt, style=label.style_label_left, color=lblColor, textcolor=color.white, size=size.normal)

hline(0, "Zero", color=color.new(color.gray, 70))
````
