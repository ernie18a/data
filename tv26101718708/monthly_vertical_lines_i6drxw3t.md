# Monthly Vertical Lines

- url: https://www.tradingview.com/script/I6dRXW3t-Monthly-Vertical-Lines/
- type: indicator
- pine_id: PUB;6f6d24ef7fe540d682e6a4865b5ae0c6
- version: 1.0

## Description

you can insert monthly Vertical lines easily, it can help to track the past performance in specific months.

## Source Code

````pine
//@version=5
indicator("Monthly Vertical Lines", overlay=true)

// --- Inputs ---
// Allows you to choose the month (1 = Jan, 12 = Dec)
targetMonth = input.int(1, "Select Month", minval=1, maxval=12, tooltip="The month you want to highlight every year.")
lineColor   = input.color(color.new(color.blue, 50), "Line Color")
lineStyle   = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])

// --- Logic ---
// Check if the current bar's month matches the input
isTargetMonth = month(time) == targetMonth and (month(time) != month(time[1]) or barstate.isfirst)

// Map style selection to Pine Script constants
styleInput = lineStyle == "Solid" ? line.style_solid : 
             lineStyle == "Dashed" ? line.style_dashed : 
             line.style_dotted

// --- Drawing ---
if isTargetMonth
    line.new(x1=bar_index, y1=0, x2=bar_index, y2=1, 
             xloc=xloc.bar_index, 
             extend=extend.both, 
             color=lineColor, 
             style=styleInput, 
             width=1)
````
