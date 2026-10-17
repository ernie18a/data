# ATR Multiplier Table - With Label

- url: https://www.tradingview.com/script/twXzXevr-ATR-Multiplier-Table-With-Label/
- type: indicator
- pine_id: PUB;41d8366634ff462798510c33ac4af5dd
- version: 2.0

## Description

Just a simple ATR with multiplier, shown as text on the top right

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Terrinca

//@version=5
indicator("Universal ATR Position Sizer", overlay=true)

// --- Inputs ---
atrLength  = input.int(14, title="ATR Length", minval=1)
multiplier = input.float(1.5, title="ATR Multiplier (Stop Distance)", step=0.1)
riskAmount = input.float(100.0, title="Dollar Amount to Risk ($)", minval=1.0)
textSize   = input.string("Large", title="Text Size", options=["Small", "Normal", "Large", "Huge"])
boxColor   = input.color(color.new(color.black, 20), title="Background Color")
txtColor   = input.color(color.white, title="Text Color")

// --- Auto-Detection Logic ---
// syminfo.pointvalue handles Futures (e.g., $50 for ES, $10 for MES)
// syminfo.mintick handles the smallest price move
pointValue = syminfo.pointvalue

// --- Calculations ---
atrValue = ta.atr(atrLength)
stopDistance = atrValue * multiplier

// Formula: Risk / (Stop Distance * Value of 1 Point)
posSize = riskAmount / (stopDistance * pointValue)

// --- Map Text Size ---
selectedSize = textSize == "Small" ? size.small : 
               textSize == "Normal" ? size.normal : 
               textSize == "Large" ? size.large : size.huge

// --- Table Logic ---
var table atrTable = table.new(position.top_right, 2, 2, border_width = 1, frame_color=color.gray)

if barstate.islast
    // Header Label
    table.cell(atrTable, 0, 0, "ATR (" + str.tostring(multiplier) + "x)", bgcolor=color.gray, text_color=txtColor, text_size=size.small)
    table.cell(atrTable, 1, 0, "SUGGESTED SIZE", bgcolor=color.gray, text_color=txtColor, text_size=size.small)

    // ATR Value
    table.cell(atrTable, 0, 1, 
         text = str.tostring(stopDistance, format.mintick), 
         bgcolor = boxColor, 
         text_color = txtColor, 
         text_size = selectedSize)
    
    // Position Size Value
    table.cell(atrTable, 1, 1, 
         text = str.tostring(posSize, "#.##"), 
         bgcolor = color.new(color.blue, 40), 
         text_color = txtColor, 
         text_size = selectedSize)
````
