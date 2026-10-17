# Momentum Price Projector 

- url: https://www.tradingview.com/script/cw2gvPZa-Momentum-Price-Projector/
- type: indicator
- pine_id: PUB;6cf601649b034ed29faf8624fe0514ce
- version: 1.0

## Description

This is a simple indicator designed to bridge the gap between momentum oscillator levels and real asset prices by reversing the standard momentum formula.


What it does:

• Project Future Price Targets: Input or visually line up the orange target line with any major momentum peak or trendline, and the script instantly calculates the exact price needed to reach that level.

Predict Breakouts: Includes a built-in electric blue zero line that tracks the precise price required to flip market momentum from bearish to bullish (can toggle the zero-price label on/off in settings).

## Source Code

````pine
//@version=6
indicator("Momentum Price Projector [v6]", overlay=false, precision=2)

// --- Inputs ---
int momLength       = input.int(20, title="Momentum Length", minval=1)
int futureShift     = input.int(1, title="Bars In Future for Prediction", minval=1)
float src           = input.source(close, title="Source Price")
float targetMom     = input.float(0.0, title="Target Momentum Level", tooltip="Manually enter your target momentum level.")
bool showZeroLabel  = input.bool(false, title="Show Zero Line Price Tag", tooltip="Toggle to show or hide the price tag on the zero line.")

// --- Calculations ---
// Standard Momentum: Current Price minus Price 'X' bars ago
float momValue = src - src[momLength]

// Reverse Math for your target line projection using the pure manual target input
float historicalRefPrice = src[momLength - futureShift]
float projectedPrice     = targetMom + historicalRefPrice

// Reverse Math for the Zero Line breakout price (Target Momentum = 0)
float zeroLineBreakPrice = 0.0 + src[momLength - 1]

// --- Plotting ---
// Plot the True Electric Blue Built-in Zero Line
hline(0, "Zero Line", color=color.rgb(0, 0, 255), linestyle=hline.style_solid, linewidth=2)

// Plot the actual Momentum line (Updated to the custom mint green color)
plot(momValue, title="Momentum", color=color.rgb(180, 240, 215), linewidth=2)

// Plot your Target Line (Pure manual input tracking)
plot(targetMom, title="Target Momentum Line", color=color.orange, linewidth=1, style=plot.style_stepline)

// --- Visual Label Display ---
var label priceLabel = na
var label zeroLabel = na

if barstate.islast
    // Clear old labels
    label.delete(priceLabel)
    label.delete(zeroLabel)
    
    // Label 1: Manual Target Line Projected Price
    string labelText = "Target Mom: " + str.tostring(targetMom, "#.##") + "\nProjected Price: " + str.tostring(projectedPrice, "#.##")
    priceLabel := label.new(
         x=bar_index, 
         y=targetMom, 
         text=labelText, 
         color=color.orange, 
         textcolor=color.white, 
         style=label.style_label_left,
         yloc=yloc.price,
         size=size.small
         )
         
    // Label 2: Zero Line Price Only
    if showZeroLabel
        string zeroLabelText = str.tostring(zeroLineBreakPrice, "#.##")
        zeroLabel := label.new(
             x=bar_index, 
             y=0.0, 
             text=zeroLabelText, 
             color=color.rgb(0, 0, 255), 
             textcolor=color.white, 
             style=label.style_label_left,
             yloc=yloc.price,
             size=size.small
             )
````
