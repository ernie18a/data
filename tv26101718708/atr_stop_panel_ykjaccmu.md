# ATR Stop Panel

- url: https://www.tradingview.com/script/yKJAcCMU-ATR-Stop-Panel/
- type: indicator
- pine_id: PUB;db3a9b23e43f4c8e9f79547775b23c49
- version: 1.0

## Description

ATR based information of real time price data to calculate the stop loss of the underlying product to the nearest quarter of a point with and 1.5 times multiplier.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © strades55

//@version=5
indicator("ATR Stop Panel", overlay=true)

// Inputs
atrLength = input.int(14, title="ATR Length")
atrMult   = input.float(1.5, title="Stop Multiplier")

// Round to nearest .25
roundToQuarter(x) => math.round(x * 4) / 4

// Calculations
atrValue  = ta.atr(atrLength)
atrStop   = atrValue * atrMult
currPrice = roundToQuarter(close)

stopAbove = roundToQuarter(currPrice + atrStop)
stopBelow = roundToQuarter(currPrice - atrStop)

// Table setup — 2 cols, 5 rows
var table panel = table.new(
     position.top_right, 2, 5,
     bgcolor      = color.new(color.gray, 85),
     border_width = 1,
     border_color = color.new(color.gray, 50),
     frame_width  = 2,
     frame_color  = color.new(color.gray, 40)
     )

// Header row
table.cell(panel, 0, 0, "ATR Stop Panel",
     text_halign = text.align_right,
     text_color  = color.white,
     text_size   = size.normal,
     bgcolor     = color.new(color.navy, 20))

table.cell(panel, 1, 0, "",
     bgcolor = color.new(color.navy, 20))

// Row 1 — Current Price (nearest .25)
table.cell(panel, 0, 1, "Current Price",
     text_color = color.new(color.white, 20),
     text_size  = size.normal,
     bgcolor    = color.new(color.gray, 80))

table.cell(panel, 1, 1, str.tostring(currPrice, "#.00"),
     text_color = color.new(color.white, 10),
     text_size  = size.normal,
     bgcolor    = color.new(color.gray, 80))

// Row 2 — Current ATR (2 decimals)
table.cell(panel, 0, 2, "Current ATR (" + str.tostring(atrLength) + ")",
     text_color = color.new(color.white, 20),
     text_size  = size.normal,
     bgcolor    = color.new(color.gray, 80))

table.cell(panel, 1, 2, str.tostring(atrValue, "#.00"),
     text_color = color.yellow,
     text_size  = size.normal,
     bgcolor    = color.new(color.gray, 80))

// Row 3 — Stop Above (nearest .25)
table.cell(panel, 0, 3, "Stop Above (+" + str.tostring(atrMult) + "x)",
     text_color = color.new(color.white, 20),
     text_size  = size.normal,
     bgcolor    = color.new(color.green, 70))

table.cell(panel, 1, 3, str.tostring(stopAbove, "#.00"),
     text_color = color.new(color.green, 10),
     text_size  = size.normal,
     bgcolor    = color.new(color.green, 70))

// Row 4 — Stop Below (nearest .25)
table.cell(panel, 0, 4, "Stop Below (-" + str.tostring(atrMult) + "x)",
     text_color = color.new(color.white, 20),
     text_size  = size.normal,
     bgcolor    = color.new(color.red, 70))

table.cell(panel, 1, 4, str.tostring(stopBelow, "#.00"),
     text_color = color.new(color.red, 10),
     text_size  = size.normal,
     bgcolor    = color.new(color.red, 70))
````
