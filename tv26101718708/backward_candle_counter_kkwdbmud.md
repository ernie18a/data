#  Backward Candle Counter 

- url: https://www.tradingview.com/script/KKWdbmUD-Backward-Candle-Counter/
- type: indicator
- pine_id: PUB;1a359374fd4d4f19b007ed58d3abdbf2
- version: 1.0

## Description

This indicator counts the latest number of candles from the current candle

## Source Code

````pine
//@version=6
indicator(" Candle Counter Dinks", overlay=true)

// --- User Inputs ---
maxCount = input.int(5, title="Max Count Number", minval=1, maxval=500, tooltip="The number assigned to the latest, actively forming candle.")
txtColor = input.color(color.white, title="Font Color")

// Font size dropdown
sizeOpt = input.string("Small", title="Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// Helper function to convert the text dropdown into Pine Script size constants
get_size(s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     s == "Large" ? size.large :
     size.huge

// Assign the selected size
lblSize = get_size(sizeOpt)

// --- Variables ---
var labels = array.new<label>()

// --- Core Logic ---
if barstate.islast
    // 1. Clean up previously drawn labels
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)
    
    // 2. Loop backward to draw the new labels
    for i = 0 to maxCount - 1
        currentNum = maxCount - i
        
        if bar_index >= i
            lbl = label.new(
                 x = bar_index - i, 
                 y = na, // y is ignored when using yloc
                 yloc = yloc.belowbar, // Automatically places the text below the lowest wick
                 text = str.tostring(currentNum), 
                 color = color.new(color.white, 100), // Makes the label background fully transparent
                 textcolor = txtColor, 
                 style = label.style_none, // Removes the label border and pointer
                 size = lblSize // Applies the user's selected font size
             )
            array.push(labels, lbl)
````
