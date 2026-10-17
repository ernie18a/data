# ECB for EURUSD

- url: https://www.tradingview.com/script/TWMRmTRf-ecb-for-eurusd/
- type: indicator
- pine_id: PUB;31cefb5992e747c68d08544564508c04
- version: 1.0

## Description

The indicator shows the ECB exchange rate, which complies with the new Central Bank of the Russian Federation rules for calculating the Euro exchange rate.

## Source Code

````pine
//@version=6
indicator("ECB EURUSD for CBR - one line", overlay=true, precision=5, max_labels_count=10, max_lines_count=10)
fixHour    = input.int(14, "ECB fixing hour, Europe/Berlin", minval=0, maxval=23)
fixMinute  = input.int(10, "ECB fixing minute, Europe/Berlin", minval=0, maxval=59)
roundTo4   = input.bool(true, "Round to 4 decimals")
priceMode  = input.string("Open", "Price on fixing bar", options=["Open", "Close", "HL2", "HLC3", "OHLC4"])
lineColor  = input.color(color.black, "Line color")
lineWidth  = input.int(1, "Line width", minval=1, maxval=4)
showBridge = input.bool(true, "Show bridge to label")
showLabel  = input.bool(true, "Show label")
labelBars  = 0
f_price() =>
    switch priceMode
        "Close" => close
        "HL2" => hl2
        "HLC3" => hlc3
        "OHLC4" => ohlc4
        => open
f_round4(x) =>
    math.round(x * 10000.0) / 10000.0
f_day_key(t) =>
    year(t, "Europe/Berlin") * 10000 + month(t, "Europe/Berlin") * 100 + dayofmonth(t, "Europe/Berlin")
isFixBar = hour(time, "Europe/Berlin") == fixHour and minute(time, "Europe/Berlin") == fixMinute
fixPx = roundTo4 ? f_round4(f_price()) : f_price()
currentDay = f_day_key(time)
var array<float> fixValues = array.new_float()
var array<int> fixDays = array.new_int()
if isFixBar
    fixDay = f_day_key(time)
    alreadyStored = array.size(fixDays) > 0 and array.get(fixDays, 0) == fixDay
    if not alreadyStored
        array.unshift(fixValues, fixPx)
        array.unshift(fixDays, fixDay)
        if array.size(fixValues) > 100
            array.pop(fixValues)
            array.pop(fixDays)
// ECB old: the latest fixing from a date earlier than the current Berlin day.
float ecbOld = na
if array.size(fixValues) > 0
    for i = 0 to array.size(fixValues) - 1
        if na(ecbOld) and array.get(fixDays, i) < currentDay
            ecbOld := array.get(fixValues, i)
latestIsToday = array.size(fixDays) > 0 and array.get(fixDays, 0) == currentDay
ecbNew = latestIsToday ? array.get(fixValues, 0) : na
plot(ecbOld, "ECB old active today", color=lineColor, linewidth=lineWidth, style=plot.style_stepline)
var label infoLabel = na
var line bridgeLine = na
if barstate.islast and showLabel
    label.delete(infoLabel)
    line.delete(bridgeLine)
    y = na(ecbNew) ? ecbOld : ecbNew
    if not na(y)
        labelX = bar_index + labelBars
        newText = na(ecbNew) ? "-" : str.tostring(ecbNew, "#.####")
        txt = "ECB new " + newText
        txt += "\nECB old " + str.tostring(ecbOld, "#.####")
        if showBridge and not na(ecbOld) and not na(ecbNew) and ecbNew != ecbOld
            bridgeLine := line.new(labelX, ecbOld, labelX, ecbNew, xloc=xloc.bar_index, color=lineColor, width=lineWidth, style=line.style_solid)
        infoLabel := label.new(labelX, y, txt, style=label.style_label_left, textcolor=color.white, color=color.new(color.black, 15), textalign=text.align_left)
````
