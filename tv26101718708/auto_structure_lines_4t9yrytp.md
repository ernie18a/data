# Auto Structure Lines

- url: https://www.tradingview.com/script/4t9YrYtp-Auto-Structure-Lines/
- type: indicator
- pine_id: PUB;28e35a1df39b4d16b5167f77913297ee
- version: 1.0

## Description

[image]https://www.tradingview.com/x/8mUmkfdd/[/image]Auto Structure Lines

Auto Structure Lines automatically detects recent swing highs and swing lows, then plots clean support and resistance levels on the chart. It is designed to help traders quickly identify nearby structure, breakout areas, rejection zones, and possible pullback levels without manually drawing every line.

The indicator uses confirmed pivot highs and lows to create resistance and support lines. Nearby levels are merged using an ATR-based tolerance so the chart stays cleaner and avoids stacking multiple lines around the same price area.

Key features:

Automatically detects pivot-based support and resistance
Extends structure lines to the right side of the chart
Stores multiple historical levels while showing only the most recent visible levels
ATR-based level merging to reduce clutter
Optional price labels for each visible level
Customizable pivot length, line style, colors, width, and label offset
Separate toggles for support and resistance
This tool is useful for identifying important price areas, planning breakout entries, watching retests, and managing risk around nearby support or resistance.

Auto Structure Lines is a visual decision-support tool. It does not generate buy or sell signals by itself and should be used with price action, volume, trend context, and your own risk management.

## Source Code

````pine
//@version=5
indicator("Auto Structure Lines", shorttitle="Auto S/R", overlay=true, max_lines_count=200)

// Inputs
pivotLen = input.int(5, "Pivot Length", minval=2, maxval=20, group="Pivots")
maxLevels = input.int(6, "Stored Levels Per Side", minval=1, maxval=10, group="Pivots")
visibleLevels = input.int(3, "Visible Levels Per Side", minval=1, maxval=6, group="Pivots")
mergeAtrLen = input.int(14, "ATR Length", minval=1, group="Pivots")
mergeAtrMult = input.float(0.5, "Level Merge ATR", minval=0.05, step=0.05, group="Pivots", tooltip="Nearby pivot levels inside this ATR distance are merged to reduce clutter.")

showSupport = input.bool(true, "Show Support", group="Levels")
showResistance = input.bool(true, "Show Resistance", group="Levels")
supportColor = input.color(color.new(color.green, 35), "Support Color", group="Levels")
resistanceColor = input.color(color.new(color.red, 35), "Resistance Color", group="Levels")
levelWidth = input.int(2, "Level Width", minval=1, maxval=4, group="Levels")
levelStyleInput = input.string("Dashed", "Level Style", options=["Solid", "Dashed", "Dotted"], group="Levels")
showPriceLabels = input.bool(true, "Show Price Labels", group="Levels")
priceLabelTextColor = input.color(color.white, "Price Label Text", group="Levels")
priceLabelOffset = input.int(4, "Price Label Offset Bars", minval=0, maxval=8, group="Levels")

f_line_style(_style) =>
    _style == "Solid" ? line.style_solid : _style == "Dotted" ? line.style_dotted : line.style_dashed

f_find_nearby_index(_levels, _price, _tolerance) =>
    foundIndex = -1
    if array.size(_levels) > 0
        for i = 0 to array.size(_levels) - 1
            if math.abs(array.get(_levels, i) - _price) <= _tolerance
                foundIndex := i
                break
    foundIndex

f_trim_front_line_array(_arr, _maxSize) =>
    if array.size(_arr) > _maxSize
        oldLine = array.shift(_arr)
        if not na(oldLine)
            line.delete(oldLine)

atr = ta.atr(mergeAtrLen)
tolerance = atr * mergeAtrMult
levelStyle = f_line_style(levelStyleInput)

// Confirmed pivots
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
pivotHighBar = bar_index - pivotLen
pivotLowBar = bar_index - pivotLen

// Active level state
var resistancePrices = array.new_float()
var supportPrices = array.new_float()
var resistanceLines = array.new_line()
var supportLines = array.new_line()
var resistanceLabels = array.new_label()
var supportLabels = array.new_label()

f_clear_label_array(_arr) =>
    if array.size(_arr) > 0
        for i = 0 to array.size(_arr) - 1
            oldLabel = array.get(_arr, i)
            if not na(oldLabel)
                label.delete(oldLabel)
    array.clear(_arr)

if not na(pivotLow)
    nearbySupportIndex = f_find_nearby_index(supportPrices, pivotLow, tolerance)
    if nearbySupportIndex == -1
        array.push(supportPrices, pivotLow)
        newSupportLine = line.new(pivotLowBar, pivotLow, bar_index, pivotLow, extend=extend.right, color=supportColor, width=levelWidth, style=levelStyle)
        array.push(supportLines, newSupportLine)
        if array.size(supportPrices) > maxLevels
            array.shift(supportPrices)
        f_trim_front_line_array(supportLines, maxLevels)

if not na(pivotHigh)
    nearbyResistanceIndex = f_find_nearby_index(resistancePrices, pivotHigh, tolerance)
    if nearbyResistanceIndex == -1
        array.push(resistancePrices, pivotHigh)
        newResistanceLine = line.new(pivotHighBar, pivotHigh, bar_index, pivotHigh, extend=extend.right, color=resistanceColor, width=levelWidth, style=levelStyle)
        array.push(resistanceLines, newResistanceLine)
        if array.size(resistancePrices) > maxLevels
            array.shift(resistancePrices)
        f_trim_front_line_array(resistanceLines, maxLevels)

// Show only the newest levels per side.
f_clear_label_array(supportLabels)
f_clear_label_array(resistanceLabels)

if array.size(supportLines) > 0
    for i = 0 to array.size(supportLines) - 1
        isVisible = i >= array.size(supportLines) - visibleLevels
        line.set_color(array.get(supportLines, i), showSupport and isVisible ? supportColor : color.new(supportColor, 100))
        if barstate.islast and showSupport and showPriceLabels and isVisible
            supportPrice = line.get_y1(array.get(supportLines, i))
            supportLabel = label.new(bar_index + priceLabelOffset, supportPrice, str.tostring(supportPrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(supportColor, 10), textcolor=priceLabelTextColor, size=size.small)
            array.push(supportLabels, supportLabel)

if array.size(resistanceLines) > 0
    for i = 0 to array.size(resistanceLines) - 1
        isVisible = i >= array.size(resistanceLines) - visibleLevels
        line.set_color(array.get(resistanceLines, i), showResistance and isVisible ? resistanceColor : color.new(resistanceColor, 100))
        if barstate.islast and showResistance and showPriceLabels and isVisible
            resistancePrice = line.get_y1(array.get(resistanceLines, i))
            resistanceLabel = label.new(bar_index + priceLabelOffset, resistancePrice, str.tostring(resistancePrice, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(resistanceColor, 10), textcolor=priceLabelTextColor, size=size.small)
            array.push(resistanceLabels, resistanceLabel)
````
