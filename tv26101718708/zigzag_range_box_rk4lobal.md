# ZigZag  Range box

- url: https://www.tradingview.com/script/Rk4loBAL-ZigZag-Range-box/
- type: indicator
- pine_id: PUB;2de66d4e5b474a47b644017412fcc231
- version: 1.0

## Description

ZigZag Box Range
This indicator plots ZigZag swings and draws dynamic boxes based on the price range between swing highs and swing lows.
Main Features:

Clear ZigZag lines that highlight major swing points
Automatic range boxes between consecutive swing highs and lows
Visual representation of price structure and range
Helps identify potential support/resistance zones and market structure
Clean and lightweight design for easy chart reading

How to use:

Use the ZigZag lines to understand the current market structure (higher highs / lower lows)
The boxes show the price range of each swing, making it easier to spot consolidation zones and breakout levels
Can be used on any timeframe and any market

Feel free to adjust the ZigZag settings (deviation, depth, etc.) according to your trading style

## Source Code

````pine
//@version=6
indicator('ZigZag Box Range', 'ZZ Box', true, max_lines_count = 500, max_labels_count = 500)

////////
// Inputs
useRange = input.bool(true, 'Limit to Box (Start/End)', group = 'Range')
startTime = input.time(timestamp('2026-10-05 00:00'), 'Start (left edge of box)', confirm = true, group = 'Range')
endTime = input.time(timestamp('2026-10-09 23:00'), 'End (right edge of box)', confirm = true, group = 'Range')
devMode = input.string('ATR (auto by timeframe)', 'Deviation Mode', options = ['ATR (auto by timeframe)', 'Percent'], group = 'ZigZag Config')
atrLen = input.int(14, 'ATR Length', minval = 1, group = 'ZigZag Config')
atrMult = input.float(2.0, 'ATR Multiplier', minval = 0.1, step = 0.1, group = 'ZigZag Config')
devPct = input.float(0.5, 'Percent Deviation %', minval = 0.01, step = 0.05, group = 'ZigZag Config') / 100
minBars = input.int(1, 'Min Bars Between Pivots', minval = 1, group = 'ZigZag Config')
maxLines = input.int(50, 'Lines to Show (50 = all in box)', minval = 1, maxval = 500, group = 'ZigZag Config')
showLabels = input.bool(true, 'Show HH/LH/HL/LL Labels', group = 'Labels')
label_size__0 = input.int(3, 'Label Size', minval = 1, maxval = 5, group = 'Labels')
label_size = switch label_size__0
    1 => size.tiny
    2 => size.small
    3 => size.normal
    4 => size.large
    5 => size.huge
line_thick = input.int(1, 'Line Thickness', minval = 1, maxval = 4, group = 'Lines')
upcolor = input.color(color.lime, 'Bull Color', group = 'Colors')
dncolor = input.color(color.red, 'Bear Color', group = 'Colors')

////////
// State
var int dir = 0
var int startT = na
var float startP = na
var int startBar = na
var int extT = na
var float extP = na
var int extBar = na
var float lastHigh = na
var float lastLow = na
var line liveLine = na
var array<line> lineArr = array.new<line>()
var array<label> labelArr = array.new<label>()

float atrVal = ta.atr(atrLen)
bool inRange = not useRange or time >= startTime and time <= endTime

// Reversal distance in price (scales with timeframe in ATR mode)
float devUp = devMode == 'Percent' ? extP * devPct : nz(atrVal) * atrMult
float devDn = devMode == 'Percent' ? extP * devPct : nz(atrVal) * atrMult

////////
// ZigZag logic
if inRange
    if dir == 0
        dir := 1
        startT := time
        startP := low
        startBar := bar_index
        extT := time
        extP := high
        extBar := bar_index
        liveLine := line.new(startT, startP, extT, extP, xloc = xloc.bar_time, color = upcolor, width = line_thick)
        liveLine
    else if dir == 1
        if high > extP
            extP := high
            extT := time
            extBar := bar_index
            extBar
        else if low <= extP - devUp and extBar - startBar >= minBars
            string tag = na(lastHigh) or extP > lastHigh ? 'HH' : 'LH'
            lastHigh := extP
            if showLabels
                array.push(labelArr, label.new(extT, extP, tag, xloc = xloc.bar_time, yloc = yloc.price, color = dncolor, style = label.style_label_down, textcolor = color.white, size = label_size))
            array.push(lineArr, liveLine)
            startT := extT
            startP := extP
            startBar := extBar
            dir := -1
            extT := time
            extP := low
            extBar := bar_index
            liveLine := line.new(startT, startP, extT, extP, xloc = xloc.bar_time, color = dncolor, width = line_thick)
            liveLine
    else
        if low < extP
            extP := low
            extT := time
            extBar := bar_index
            extBar
        else if high >= extP + devDn and extBar - startBar >= minBars
            string tag = na(lastLow) or extP < lastLow ? 'LL' : 'HL'
            lastLow := extP
            if showLabels
                array.push(labelArr, label.new(extT, extP, tag, xloc = xloc.bar_time, yloc = yloc.price, color = upcolor, style = label.style_label_up, textcolor = color.black, size = label_size))
            array.push(lineArr, liveLine)
            startT := extT
            startP := extP
            startBar := extBar
            dir := 1
            extT := time
            extP := high
            extBar := bar_index
            liveLine := line.new(startT, startP, extT, extP, xloc = xloc.bar_time, color = upcolor, width = line_thick)
            liveLine

    // Update the live (forming) leg
    line.set_xy2(liveLine, extT, extP)
    line.set_color(liveLine, dir > 0 ? upcolor : dncolor)

    // Keep only the newest lines/labels
    while array.size(lineArr) > maxLines - 1
        line.delete(array.shift(lineArr))
    while array.size(labelArr) > maxLines - 1
        label.delete(array.shift(labelArr))
````
