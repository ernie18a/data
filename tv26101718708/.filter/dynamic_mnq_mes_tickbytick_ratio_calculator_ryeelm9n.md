# Dynamic MNQ / MES Tick-by-Tick Ratio Calculator

- url: https://www.tradingview.com/script/ryEELm9n-Dynamic-MNQ-MES-Tick-by-Tick-Ratio-Calculator/
- type: indicator
- pine_id: PUB;b85c1ade640b42d09c21a2be3e7eae0a
- version: 1.0

## Description

MNQ to MES live tick price  equivalent ratio, great for take profit and stop loss targets.

## Source Code

````pine
//@version=6
indicator("Dynamic MNQ / MES Tick-by-Tick Ratio Calculator", overlay=true)

// Group 1: Configuration & Inputs
string calcMode  = input.string("MNQ to MES", "Conversion Mode", options=["MNQ to MES", "MES to MNQ"], group="Calculator Configuration")
float inputPrice = input.float(18000.00, "Enter Manual Price Target", step=0.25, group="Calculator Configuration")

// Fetch live close prices on EVERY TICK using the empty string "" timeframe parameter
float mesTickPrice = request.security("CME_MINI:MES1!", "", close)
float mnqTickPrice = request.security("CME_MINI:MNQ1!", "", close)

// Dynamically compute the fair market ratio from the live tick data stream
float dynamicRatio = mnqTickPrice / mesTickPrice
float convertedPrice = 0.0

if calcMode == "MNQ to MES"
    convertedPrice := inputPrice / dynamicRatio
else
    convertedPrice := inputPrice * dynamicRatio

// Visual Formatting Theme Settings (Twice the size layout)
var color colorDarkBg    = color.new(#131722, 10)
var color colorBorder    = color.new(#2a2e39, 0)
var color textLabelColor = color.new(#d1d4dc, 0)

// Initialize 2-column by 4-row grid dashboard container block on the bottom right corner
var table dataBox = table.new(position = position.bottom_right, columns = 2, rows = 4, bgcolor = colorDarkBg, border_width = 2, border_color = colorBorder)

if barstate.islast
    // Row 0: Dashboard Header Titles
    table.cell(dataBox, 0, 0, "Calculation Metric", text_color=textLabelColor, text_size=size.large, bgcolor=color.new(#1e222d, 0))
    table.cell(dataBox, 1, 0, "Price Value",        text_color=textLabelColor, text_size=size.large, bgcolor=color.new(#1e222d, 0))
    
    // Row 1: The Live Tick Ratio Being Used
    table.cell(dataBox, 0, 1, "Live Tick Ratio (MNQ/MES)", text_color=color.white, text_size=size.large)
    table.cell(dataBox, 1, 1, str.tostring(dynamicRatio, "#.0000"), text_color=color.white, text_size=size.large)
    
    // Row 2: Manual Value Entered Summary Display
    string inputLabel = (calcMode == "MNQ to MES") ? "Manual Input (MNQ)" : "Manual Input (MES)"
    color inputColor  = (calcMode == "MNQ to MES") ? color.new(#00bcd4, 0) : color.new(#ff9800, 0)
    table.cell(dataBox, 0, 2, inputLabel, text_color=inputColor, text_size=size.large)
    table.cell(dataBox, 1, 2, str.tostring(inputPrice, "#.00"), text_color=inputColor, text_size=size.large)
    
    // Row 3: Equivalent Converted Target Output
    string outputLabel = (calcMode == "MNQ to MES") ? "Equivalent (MES)" : "Equivalent (MNQ)"
    color outputColor  = (calcMode == "MNQ to MES") ? color.new(#ff9800, 0) : color.new(#00bcd4, 0)
    table.cell(dataBox, 0, 3, outputLabel, text_color=outputColor, text_size=size.large)
    table.cell(dataBox, 1, 3, str.tostring(convertedPrice, "#.00"), text_color=outputColor, text_size=size.large)
````
