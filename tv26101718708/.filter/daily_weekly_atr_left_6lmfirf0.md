# Daily & Weekly ATR Left

- url: https://www.tradingview.com/script/6LMFiRf0-Daily-Weekly-ATR-Left/
- type: indicator
- pine_id: PUB;0d896f9f82b4468ca807114764648a11
- version: 3.0

## Description

This script will display the weekly and daily ATR and how much is left.

## Source Code

````pine

//@version=6
indicator("Daily & Weekly ATR Left", overlay=true)

length = input.int(14, "ATR Length")

// Daily Values
dATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(length)
)

dTR = request.security(
     syminfo.tickerid,
     "D",
     ta.tr(true)
)

dLeft = dATR - dTR

// Weekly Values
wATR = request.security(
     syminfo.tickerid,
     "W",
     ta.atr(length)
)

wTR = request.security(
     syminfo.tickerid,
     "W",
     ta.tr(true)
)

wLeft = wATR - wTR

// Table
var table atrTbl = table.new(
     position.top_right,
     3,
     3,
     border_width = 1
)

if barstate.islast

    // Headers
    table.cell(atrTbl, 0, 0, "")
    table.cell(atrTbl, 1, 0, "Daily",
         bgcolor = color.new(color.blue, 0),
         text_color = color.white)

    table.cell(atrTbl, 2, 0, "Weekly",
         bgcolor = color.new(color.purple, 0),
         text_color = color.white)

    // ATR Row
    table.cell(atrTbl, 0, 1, "ATR",
         bgcolor = color.new(color.gray, 70),
         text_color = color.white)

    table.cell(atrTbl, 1, 1,
         str.tostring(dATR, "#.00"),
         text_color = color.yellow)

    table.cell(atrTbl, 2, 1,
         str.tostring(wATR, "#.00"),
         text_color = color.aqua)

    // Left Row
    table.cell(atrTbl, 0, 2, "Left",
         bgcolor = color.new(color.gray, 70),
         text_color = color.white)

    table.cell(atrTbl, 1, 2,
         str.tostring(dLeft, "#.00"),
         text_color = color.yellow)

    table.cell(atrTbl, 2, 2,
         str.tostring(wLeft, "#.00"),
         text_color = color.aqua)
````
