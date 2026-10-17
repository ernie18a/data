# AsiaSesion RO

- url: https://www.tradingview.com/script/SNn9J9Ox-AsiaSesion-RO/
- type: indicator
- pine_id: PUB;495b4d24e2d645dd90dcfc55e6e7b0c3
- version: 1.0

## Description

TThe indicator is based on the breakout of the 6pm box, the first candle that closes within the 0-50 pointrange above or below the box is the trade entry signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nicubuhai2002

//@version=6
indicator("6PM UTC-4 Range Box", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

keepHistory = input.bool(false, "Keep History")
offsetPoints = input.float(50.0, "Offset Points")
historyLimit = input.int(20, "History Days Limit", minval=1, maxval=50)

boxFillColor = input.color(color.new(color.blue, 80), "Box Fill")
boxBorderColor = input.color(color.blue, "Box Border")
upperLineColor = input.color(color.green, "Upper Line")
lowerLineColor = input.color(color.red, "Lower Line")
signalColor = input.color(color.yellow, "Signal Box")

tz = "GMT-4"

var float refHigh = na
var float refLow = na
var bool firstSignalDone = false

var box rangeBox = na
var line upperLine = na
var line lowerLine = na
var box signalBox = na
var box[] boxes = array.new_box()
var line[] lines = array.new_line()

barHour = hour(time, tz)
barMinute = minute(time, tz)

isReferenceCandle = timeframe.isintraday and timeframe.multiplier == 60 and barHour == 18 and barMinute == 0

if isReferenceCandle and barstate.isconfirmed
    if not keepHistory
        box.delete(rangeBox)
        line.delete(upperLine)
        line.delete(lowerLine)
        box.delete(signalBox)

        refHigh := high
        refLow := low
        firstSignalDone := false

        rangeBox := box.new(bar_index, refHigh, bar_index + 22, refLow, bgcolor=boxFillColor, border_color=boxBorderColor)

        upperLine := line.new(bar_index, refHigh + offsetPoints, bar_index + 22, refHigh + offsetPoints, color=upperLineColor, width=2)

        lowerLine := line.new(bar_index, refLow - offsetPoints, bar_index + 22, refLow - offsetPoints, color=lowerLineColor, width=2)
    if keepHistory
        array.push(boxes, rangeBox)
        array.push(lines, upperLine)
        array.push(lines, lowerLine)

    if array.size(boxes) > historyLimit
        box.delete(array.shift(boxes))

    if array.size(lines) > historyLimit * 2
        line.delete(array.shift(lines))
bullishCandle = close > open
bearishCandle = close < open

upperZone = not na(refHigh) and bullishCandle and close > refHigh and close <= refHigh + offsetPoints

lowerZone = not na(refLow) and bearishCandle and close < refLow and close >= refLow - offsetPoints

validSignal = (upperZone or lowerZone) and not firstSignalDone and not isReferenceCandle

if validSignal and barstate.isconfirmed
    firstSignalDone := true
    signalBox := box.new(bar_index - 1 , high, bar_index + 1, low, bgcolor=color.new(signalColor, 70), border_color=signalColor, border_width=2)
if keepHistory
    array.push(boxes, signalBox)

if array.size(boxes) > historyLimit * 2
    box.delete(array.shift(boxes))
buySignal = upperZone and not firstSignalDone and not isReferenceCandle
sellSignal = lowerZone and not firstSignalDone and not isReferenceCandle
alertcondition(buySignal, title="BUY Signal", message="BUY signal above the 6PM box")
alertcondition(sellSignal, title="SELL Signal", message="SELL signal below the 6PM box")
````
