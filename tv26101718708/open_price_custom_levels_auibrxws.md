# Open Price Custom % Levels

- url: https://www.tradingview.com/script/AuIbRxWs-Open-Price-Custom-Levels/
- type: indicator
- pine_id: PUB;e7eed9a5e7ac4cfc96e99e0340c23fb1
- version: 1.0

## Description

**Open Price % Levels With Session Gap**

This indicator plots the session opening price and automatically calculates percentage-based levels above and below it.

### Features

* Session Opening Price Line
* +0.5%, +1%, +2%, +2.5%, +3% Levels
* -0.5%, -1%, -2%, -2.5%, -3% Levels
* Customizable line colors and thickness
* Session-based plotting with automatic daily reset
* No line connection between trading sessions (clean session gaps)
* Works on all markets and timeframes

Useful for identifying key percentage expansion and retracement zones relative to the session open, helping traders track intraday price movement and potential reaction levels.

**Best suited for:** Index, Forex, Gold, Crypto, and Intraday Trading.

## Source Code

````pine
//@version=6
indicator("Open Price Custom % Levels", overlay=true, max_lines_count=500)

//======================
// OPEN LINE
//======================
openColor = input.color(color.black, "Open Line Color")
openWidth = input.int(2, "Open Line Width", minval=1)

//======================
// UPPER LEVEL INPUTS
//======================
upPct1 = input.float(0.5, "Upper Level 1 (%)", step=0.1)
upPct2 = input.float(1.0, "Upper Level 2 (%)", step=0.1)
upPct3 = input.float(2.0, "Upper Level 3 (%)", step=0.1)
upPct4 = input.float(2.5, "Upper Level 4 (%)", step=0.1)
upPct5 = input.float(3.0, "Upper Level 5 (%)", step=0.1)

upColor1 = input.color(color.green, "Upper Level 1 Color")
upColor2 = input.color(color.lime, "Upper Level 2 Color")
upColor3 = input.color(color.teal, "Upper Level 3 Color")
upColor4 = input.color(color.aqua, "Upper Level 4 Color")
upColor5 = input.color(color.blue, "Upper Level 5 Color")

upWidth1 = input.int(1, "Upper Level 1 Width", minval=1)
upWidth2 = input.int(1, "Upper Level 2 Width", minval=1)
upWidth3 = input.int(1, "Upper Level 3 Width", minval=1)
upWidth4 = input.int(1, "Upper Level 4 Width", minval=1)
upWidth5 = input.int(1, "Upper Level 5 Width", minval=1)

//======================
// LOWER LEVEL INPUTS
//======================
dnPct1 = input.float(0.5, "Lower Level 1 (%)", step=0.1)
dnPct2 = input.float(1.0, "Lower Level 2 (%)", step=0.1)
dnPct3 = input.float(2.0, "Lower Level 3 (%)", step=0.1)
dnPct4 = input.float(2.5, "Lower Level 4 (%)", step=0.1)
dnPct5 = input.float(3.0, "Lower Level 5 (%)", step=0.1)

dnColor1 = input.color(color.red, "Lower Level 1 Color")
dnColor2 = input.color(color.maroon, "Lower Level 2 Color")
dnColor3 = input.color(color.orange, "Lower Level 3 Color")
dnColor4 = input.color(color.fuchsia, "Lower Level 4 Color")
dnColor5 = input.color(color.purple, "Lower Level 5 Color")

dnWidth1 = input.int(1, "Lower Level 1 Width", minval=1)
dnWidth2 = input.int(1, "Lower Level 2 Width", minval=1)
dnWidth3 = input.int(1, "Lower Level 3 Width", minval=1)
dnWidth4 = input.int(1, "Lower Level 4 Width", minval=1)
dnWidth5 = input.int(1, "Lower Level 5 Width", minval=1)

//======================
// SESSION OPEN
//======================
newDay = ta.change(time("D")) != 0

var float sessionOpen = na

if newDay or barstate.isfirst
    sessionOpen := open

//======================
// CALCULATE LEVELS
//======================
up1 = sessionOpen * (1 + upPct1 / 100)
up2 = sessionOpen * (1 + upPct2 / 100)
up3 = sessionOpen * (1 + upPct3 / 100)
up4 = sessionOpen * (1 + upPct4 / 100)
up5 = sessionOpen * (1 + upPct5 / 100)

dn1 = sessionOpen * (1 - dnPct1 / 100)
dn2 = sessionOpen * (1 - dnPct2 / 100)
dn3 = sessionOpen * (1 - dnPct3 / 100)
dn4 = sessionOpen * (1 - dnPct4 / 100)
dn5 = sessionOpen * (1 - dnPct5 / 100)

//======================
// LINE VARIABLES
//======================
var line openLine = na

var line upLine1 = na
var line upLine2 = na
var line upLine3 = na
var line upLine4 = na
var line upLine5 = na

var line dnLine1 = na
var line dnLine2 = na
var line dnLine3 = na
var line dnLine4 = na
var line dnLine5 = na

//======================
// CREATE NEW SESSION LINES
//======================
if newDay or barstate.isfirst

    openLine := line.new(bar_index, sessionOpen, bar_index, sessionOpen, color=openColor, width=openWidth)

    upLine1 := line.new(bar_index, up1, bar_index, up1, color=upColor1, width=upWidth1)
    upLine2 := line.new(bar_index, up2, bar_index, up2, color=upColor2, width=upWidth2)
    upLine3 := line.new(bar_index, up3, bar_index, up3, color=upColor3, width=upWidth3)
    upLine4 := line.new(bar_index, up4, bar_index, up4, color=upColor4, width=upWidth4)
    upLine5 := line.new(bar_index, up5, bar_index, up5, color=upColor5, width=upWidth5)

    dnLine1 := line.new(bar_index, dn1, bar_index, dn1, color=dnColor1, width=dnWidth1)
    dnLine2 := line.new(bar_index, dn2, bar_index, dn2, color=dnColor2, width=dnWidth2)
    dnLine3 := line.new(bar_index, dn3, bar_index, dn3, color=dnColor3, width=dnWidth3)
    dnLine4 := line.new(bar_index, dn4, bar_index, dn4, color=dnColor4, width=dnWidth4)
    dnLine5 := line.new(bar_index, dn5, bar_index, dn5, color=dnColor5, width=dnWidth5)

//======================
// EXTEND CURRENT SESSION LINES
//======================
if not na(openLine)
    line.set_x2(openLine, bar_index)

if not na(upLine1)
    line.set_x2(upLine1, bar_index)
if not na(upLine2)
    line.set_x2(upLine2, bar_index)
if not na(upLine3)
    line.set_x2(upLine3, bar_index)
if not na(upLine4)
    line.set_x2(upLine4, bar_index)
if not na(upLine5)
    line.set_x2(upLine5, bar_index)

if not na(dnLine1)
    line.set_x2(dnLine1, bar_index)
if not na(dnLine2)
    line.set_x2(dnLine2, bar_index)
if not na(dnLine3)
    line.set_x2(dnLine3, bar_index)
if not na(dnLine4)
    line.set_x2(dnLine4, bar_index)
if not na(dnLine5)
    line.set_x2(dnLine5, bar_index)
````
