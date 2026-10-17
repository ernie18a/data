# Simple ATR figure display

- url: https://www.tradingview.com/script/LfiKAVD3-Simple-ATR-figure-display/
- type: indicator
- pine_id: PUB;2364a56708f54d0a858adc7446c8cc86
- version: 1.0

## Description

A simple ATR figure that can be positioned in different locations.
Saves space on the screen. 
Editable periods, sizes and colors for background and text.  
Note This only shows current ATR, it does not display previous ATR if you click back on your screen.

## Source Code

````pine
//@version=5
indicator("Simple ATR figure display", overlay = true)

//──────────────── ATR CALCULATION ────────────────
lenATR = input.int(14, "ATR Period")
atr = ta.atr(lenATR)

//──────────────── MINI TABLE SETTINGS ────────────────
groupMini = "Mini ATR Box"

miniPos = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"],
     group=groupMini)

miniTextSize = input.string("Large", "Text Size",
     options=["Small","Normal","Large","Huge"],
     group=groupMini)

miniBg1   = input.color(color.new(color.black, 0),  "ATR Row Background", group=groupMini)
miniText1 = input.color(color.white,               "ATR Row Text",        group=groupMini)

miniBg2   = input.color(color.new(color.gray, 85), "Row 2 Background",    group=groupMini)
miniText2 = input.color(color.white,               "Row 2 Text",          group=groupMini)

//──────────────── TEXT SIZE MAPPING (ONE LINE ONLY) ────────────────
miniSize = miniTextSize == "Small" ? size.small : miniTextSize == "Normal" ? size.normal : miniTextSize == "Large" ? size.large : size.huge

//──────────────── POSITION LOGIC (ONE LINE ONLY) ────────────────
miniAnchor = miniPos == "Top Left" ? position.top_left : miniPos == "Bottom Left" ? position.bottom_left : miniPos == "Bottom Right" ? position.bottom_right : position.top_right

//──────────────── CREATE 2‑ROW TABLE ────────────────
var table mini = table.new(miniAnchor, 1, 2)

//──────────────── UPDATE TABLE ────────────────
if barstate.islast
    // Row 1 — ATR
    table.cell(mini, 0, 0, "ATR: " + str.tostring(atr, "#.##"), bgcolor = miniBg1, text_color = miniText1, text_size = miniSize)

    // Row 2 — padding row
    table.cell(mini, 0, 1, " ", bgcolor = miniBg2, text_color = miniText2, text_size = miniSize)
````
