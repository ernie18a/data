# Accumulation Boxes Only

- url: https://www.tradingview.com/script/ga7tqar0-Accumulation-Boxes-Only/
- type: indicator
- pine_id: PUB;aeda0ee89797402eae238a6abd429267
- version: 3.0

## Description

It will show you Accumulation Stage and Alert you once it Breaks!

## Source Code

````pine
//@version=6
indicator("THIS SCRIPT HAS DEPRECATED", overlay=true)

// Displays a permanent warning message on the user's chart
var table infoTable = table.new(position.top_right, 1, 1, bgcolor=color.red)
if barstate.islast
    table.cell(infoTable, 0, 0, "This indicator is no longer supported or active.",text_color=color.white, text_size=size.large)
````
