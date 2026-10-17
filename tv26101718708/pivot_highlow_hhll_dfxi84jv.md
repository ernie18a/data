# Pivot High/Low (HH/LL)

- url: https://www.tradingview.com/script/Dfxi84jv-Pivot-High-Low-HH-LL/
- type: indicator
- pine_id: PUB;5cfed6c944ff43d1adb0fd6fe881f094
- version: 1.0

## Description

The Pivot High/Low (HH/LL) Finder is a clean and effective technical analysis tool designed to automatically identify key market structure points. By scanning price action, it pinpoints local swing highs and swing lows, marking them directly on your chart with clear "HH" (Highest High) and "LL" (Lowest Low) labels.

How It Works
The indicator relies on a customizable parameter, N (default set to 5).

HH (Pivot High): A candlestick is marked with a red "HH" label above it if its High is the absolute highest price compared to the N bars to its left and the N bars to its right.
LL (Pivot Low): A candlestick is marked with a green "LL" label below it if its Low is the absolute lowest price compared to the N bars to its left and the N bars to its right.

## Source Code

````pine
//@version=5
indicator("Pivot High/Low (HH/LL)", overlay=true)

// Set the parameter N, default is 5 (5 bars left, 5 bars right)
n = input.int(5, title="Number of Bars (N)", minval=1, tooltip="Number of bars to the left and right to determine the pivot points")

// Find Pivot High and Pivot Low
// ta.pivothigh(high, n, n) checks if the high of the bar 'n' periods ago is higher than the 'n' bars to its left and 'n' bars to its right.
ph = ta.pivothigh(high, n, n)
pl = ta.pivotlow(low, n, n)

// Draw labels on the chart
// Note: Since we need 'N' bars to the right for confirmation, the signal is confirmed on the current bar, 
// but we need to draw the label 'N' bars ago.
// Using offset = -n shifts the label to the left, placing it exactly on the pivot bar.
plotshape(series=not na(ph), title="HH", style=shape.labeldown, location=location.abovebar, color=color.red, text="HH", textcolor=color.white, offset=-n)
plotshape(series=not na(pl), title="LL", style=shape.labelup, location=location.belowbar, color=color.green, text="LL", textcolor=color.white, offset=-n)
````
