# ATR/DTR[jackieee]

- url: https://www.tradingview.com/script/vltVVA20-ATR-DTR-jackieee/
- type: indicator
- pine_id: PUB;0faf4c58f76d4c27bf832350248df9f7
- version: 1.0

## Description

Description

This indicator compares the current range (DTR) with the Average True Range (ATR) of a selected timeframe and displays the result in a compact table on the chart. Its purpose is to show how much of the market’s “normal” move has already been used.

The logic is straightforward: ATR measures the average volatility over time, while DTR measures the actual high-to-low range of the current bar on the chosen timeframe. The script then calculates DTR / ATR × 100, which shows the current range as a percentage of ATR. This makes it easy to judge whether price is moving within a normal range, approaching an average full move, or already extending beyond it.

A custom threshold can also be set so the table changes color once the current range reaches a chosen percentage of ATR. This helps highlight when volatility is becoming unusually large and can be useful for intraday awareness, range expansion analysis, and managing expectations after a strong move.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jackieeeeeeeee


plot(close)


//@version=6
indicator("ATR/DTR[jackieee]", overlay = true)

// Inputs
timeFrameInput = input.timeframe("D", "Timeframe the ATR is Calculated off of")
percolor       = input.int(100, "Percentage the color will change at")
normalcolor    = input.color(color.gray, "Color under percentage")
colorchange    = input.color(color.white, "Color over percentage")
boxPlacement   = input.string(
     position.bottom_right,
     "Box Placement",
     options = [position.bottom_right, position.bottom_left, position.top_right, position.top_center, position.bottom_center]
)

// Table
var table atrdtr = table.new(boxPlacement, 3, 1, bgcolor = normalcolor, border_color = color.rgb(0, 0, 0), border_width = 2)

// Calculations
atr  = request.security(syminfo.tickerid, timeFrameInput, ta.atr(14))
atr2 = math.round(atr, 2)

dtr  = request.security(syminfo.tickerid, timeFrameInput, math.round(high - low, 2))
atrp = math.round(dtr / atr * 100)

// Draw table
if barstate.islast
    table.cell(atrdtr, 0, 0, text = "ATR: " + str.tostring(atr2))
    table.cell(atrdtr, 1, 0, text = "DTR: " + str.tostring(dtr))
    table.cell(atrdtr, 2, 0, text = str.tostring(atrp) + "%")
    table.set_bgcolor(atrdtr, atrp > percolor ? colorchange : normalcolor)

plot(na)
````
