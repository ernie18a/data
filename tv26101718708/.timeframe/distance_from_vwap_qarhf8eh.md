# Distance from VWAP

- url: https://www.tradingview.com/script/QARhf8Eh-Distance-from-VWAP/
- type: indicator
- pine_id: PUB;6a094c34785f4bc4b53b86cf04ed2e40
- version: 1.0

## Description

//@version=2
study("Traders Mastermind - Distance from VWAP")
plot(close-vwap)

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blakee

//@version=6
indicator("Historical Range ","",true)

var string GP1 = "Display"
string  tableYposInput = input.string("top", "Panel position", inline = "11", options = ["top", "middle", "bottom"], group = GP1)
string  tableXposInput = input.string("right", "", inline = "11", options = ["left", "center", "right"], group = GP1)
color   textColorInput = input.color(color.new(color.black, 30), group = GP1)
string textSize = input.string("small", "Text Size", inline = "11", options = ["tiny", "small", "normal"], group = GP1)

atrCalc = ta.atr(14)
rngSoFar = high[0] - low[0]
yrRange = request.security(syminfo.tickerid, "12M",atrCalc)
yrSoFar = request.security(syminfo.tickerid, "12M", rngSoFar)
dlyRange = request.security(syminfo.tickerid, "1D",atrCalc)
todayRange = request.security(syminfo.tickerid, "1D",rngSoFar)   


var table panel = table.new(tableYposInput + "_" + tableXposInput, columns=4, rows=14)
if barstate.islast
    // Add Blank Row
    table.cell(panel, 0, 0, "", text_color = textColorInput, text_size = textSize, text_halign = text.align_left)
    // Yearly Data
    table.cell(panel, 0, 1, "1Y ATR = " + str.tostring(math.round(yrRange,4)), text_color = textColorInput, text_size = textSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, "Year = " + str.tostring(math.round(yrSoFar,4)) + ",  ", text_color = textColorInput, text_size = textSize, text_halign = text.align_left)
    // Daily Data
    table.cell(panel, 2, 1, "1D ATR = " + str.tostring(math.round(dlyRange,4)), text_color = textColorInput, text_size = textSize, text_halign = text.align_left)  
    table.cell(panel, 3, 1, "Today = " + str.tostring(math.round(todayRange,4)), text_color = textColorInput, text_size = textSize, text_halign = text.align_left)
````
