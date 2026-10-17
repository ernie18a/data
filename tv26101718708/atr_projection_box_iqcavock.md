# ATR Projection Box

- url: https://www.tradingview.com/script/iqCavOcK-ATR-Projection-Box/
- type: indicator
- pine_id: PUB;acb76205182c440998348d5e6c667022
- version: 1.0

## Description

[b]THIS IS NOT A BUY/SELL INDICATOR [/b]- Rather it helps you know where the current candle may move up or down based on ATR.

 This helps you visualize the current state of the market moves on the current candle to help you find possible targets for where the candle can move to in each direction before hitting its ATR average past ticks above or below current price. 

The ATR Projection Box is a volatility-based price projection tool designed to show traders the market’s expected movement range on the current candle using the Average True Range (ATR). 

It creates a forward-looking price zone above and below the current price, helping traders visualize likely expansion areas, manage risk, and identify potential targets or exhaustion zones.


[b]What the Indicator Does[/b]

This script calculates the market’s current ATR and projects a dynamic upper and lower range from price based on a customizable ATR multiplier.

The indicator then draws:

A green upper projection line representing the expected upside range
A red lower projection line representing the expected downside range
A shaded projection box extending several candles into the future

This creates a clean visual “expected movement zone” directly on the chart for the current candle.

## Source Code

````pine
//@version=5
indicator("ATR Projection Box", overlay=true)

// Input parameters
atrLength = input.int(14, "ATR Length", minval=1)
atrMultiplier = input.float(1.0, "ATR Multiplier", minval=0.1, step=0.1)
boxWidth = input.int(3, "Box Width (Candles)", minval=1, maxval=20)
useClosedCandle = input.bool(true, "Use Last Closed Candle", tooltip="When enabled, box stays fixed based on last closed candle. When disabled, box updates with current candle.")

// Calculate ATR
atrValue = ta.atr(atrLength)

// Determine which price to use based on setting
var float basePrice = na
var float baseATR = na
var int baseBar = na

if useClosedCandle
    // Use last closed candle's values
    if barstate.isconfirmed
        basePrice := close
        baseATR := atrValue
        baseBar := bar_index
    // Keep previous values during current candle formation
else
    // Update continuously with current candle
    basePrice := close
    baseATR := atrValue
    baseBar := bar_index

// Calculate projected upper and lower bounds
upperBound = basePrice + (baseATR * atrMultiplier)
lowerBound = basePrice - (baseATR * atrMultiplier)

// Create box coordinates
boxLeft = baseBar
boxRight = baseBar + boxWidth

// Delete old box to keep chart clean
var box projectionBox = na
if not na(projectionBox)
    box.delete(projectionBox)

// Create new projection box with no border
if not na(basePrice)
    projectionBox := box.new(
         left=boxLeft,
         top=upperBound,
         right=boxRight,
         bottom=lowerBound,
         border_color=na,
         border_width=0,
         bgcolor=color.new(color.blue, 95)
     )

// Draw the top line (green)
var line topLine = na
if not na(topLine)
    line.delete(topLine)

if not na(basePrice)
    topLine := line.new(
         x1=boxLeft,
         y1=upperBound,
         x2=boxRight,
         y2=upperBound,
         color=color.green,
         width=2
     )

// Draw the bottom line (red)
var line bottomLine = na
if not na(bottomLine)
    line.delete(bottomLine)

if not na(basePrice)
    bottomLine := line.new(
         x1=boxLeft,
         y1=lowerBound,
         x2=boxRight,
         y2=lowerBound,
         color=color.red,
         width=2
     )

// Optional: Plot ATR value in a separate pane (can be removed if not needed)
plot(atrValue, "ATR Value", color=color.blue, display=display.none)

// Display current ATR info
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(infoTable, 0, 0, "Mode", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, useClosedCandle ? "Closed" : "Live", text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 1, "ATR", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(baseATR, format.mintick), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 2, "Upper", text_color=color.green, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(upperBound, format.mintick), text_color=color.green, text_size=size.small)
    table.cell(infoTable, 0, 3, "Lower", text_color=color.red, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(lowerBound, format.mintick), text_color=color.red, text_size=size.small)
````
