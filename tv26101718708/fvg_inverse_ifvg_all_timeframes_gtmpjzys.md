# FVG Inverse (IFVG) All Timeframes

- url: https://www.tradingview.com/script/GTmpjzYs-FVG-Inverse-IFVG-All-Timeframes/
- type: indicator
- pine_id: PUB;2090fbfff1da443aa3d5a61791ac1771
- version: 1.0

## Description

Tracks standard Fair Value Gaps (FVGs) and Inverse Fair Value Gaps (IFVGs) automatically on any chart timeframe.

The indicator detects bullish and bearish FVGs based on classic 3-candle imbalance structure, draws the zone with its Consequent Encroachment (CE) as a dotted midpoint line, and labels each setup clearly as BULL FVG or BEAR FVG.

When price fully closes through an opposing FVG, the zone automatically converts into an IFVG and is relabeled accordingly, helping traders quickly identify potential shifts in market structure and support/resistance flips.

Designed as a clean, strategy-neutral tool for all markets and timeframes, with customizable colors, opacity, and a simplified visual layout that keeps only the most recent zones on screen for clarity.

## Source Code

````pine
//@version=6
indicator("FVG/IFVG All Timeframes", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//====================================================
// Inputs
//====================================================
forwardBars       = input.int(7, "Show each zone forward bars from middle candle", minval=1, maxval=100)
maxVisibleFvgs    = input.int(5, "How many most recent zones to keep", minval=1, maxval=50)

// Visual customization
bullFvgColor      = input.color(color.gray, "Bullish FVG Color")
bullFvgOpacity    = input.int(75, "Bullish FVG Opacity", minval=0, maxval=100)

bearFvgColor      = input.color(color.gray, "Bearish FVG Color")
bearFvgOpacity    = input.int(75, "Bearish FVG Opacity", minval=0, maxval=100)

ifvgColorInput    = input.color(color.teal, "IFVG Color")
ifvgOpacity       = input.int(75, "IFVG Opacity", minval=0, maxval=100)

ceLineColor       = input.color(color.black, "CE Line Color")
boxBorderColor    = input.color(color.black, "Box Border Color")

tagBgColor        = input.color(color.black, "Tag Background Color")
tagTextColor      = input.color(color.white, "Tag Text Color")
tagOffsetTicks    = input.int(4, "Tag Offset (ticks)", minval=1, maxval=100)

//====================================================
// Visuals
//====================================================
bullFill    = color.new(bullFvgColor, bullFvgOpacity)
bearFill    = color.new(bearFvgColor, bearFvgOpacity)
ifvgFill    = color.new(ifvgColorInput, ifvgOpacity)
boxBorder   = color.new(boxBorderColor, 0)
tagBg       = color.new(tagBgColor, 0)
tagOffset   = syminfo.mintick * tagOffsetTicks

//====================================================
// Arrays
//====================================================
var fvgDir      = array.new_int()
var fvgLow      = array.new_float()
var fvgHigh     = array.new_float()
var fvgCe       = array.new_float()
var fvgStartBar = array.new_int()
var fvgEndBar   = array.new_int()
var fvgBox      = array.new_box()
var fvgLine     = array.new_line()
var fvgLabel    = array.new_label()

//====================================================
// FVG Detection
//====================================================
newBullFvg = barstate.isconfirmed and bar_index >= 2 and low > high[2]
newBearFvg = barstate.isconfirmed and bar_index >= 2 and high < low[2]

//====================================================
// Add Bullish FVG
//====================================================
if newBullFvg
    zoneLow   = high[2]
    zoneHigh  = low
    zoneCe    = (zoneLow + zoneHigh) / 2.0
    startBar  = bar_index - 1
    endBar    = startBar + forwardBars
    tagY      = zoneCe + tagOffset

    newBox   = box.new(startBar, zoneHigh, endBar, zoneLow, xloc=xloc.bar_index, border_color=boxBorder, bgcolor=bullFill)
    newLine  = line.new(startBar, zoneCe, endBar, zoneCe, xloc=xloc.bar_index, color=ceLineColor, style=line.style_dotted, width=2)
    newLabel = label.new(endBar, tagY, "BULL FVG", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=tagTextColor, color=tagBg, size=size.tiny)

    array.push(fvgDir, 1)
    array.push(fvgLow, zoneLow)
    array.push(fvgHigh, zoneHigh)
    array.push(fvgCe, zoneCe)
    array.push(fvgStartBar, startBar)
    array.push(fvgEndBar, endBar)
    array.push(fvgBox, newBox)
    array.push(fvgLine, newLine)
    array.push(fvgLabel, newLabel)

//====================================================
// Add Bearish FVG
//====================================================
if newBearFvg
    zoneLow   = high
    zoneHigh  = low[2]
    zoneCe    = (zoneLow + zoneHigh) / 2.0
    startBar  = bar_index - 1
    endBar    = startBar + forwardBars
    tagY      = zoneCe - tagOffset

    newBox   = box.new(startBar, zoneHigh, endBar, zoneLow, xloc=xloc.bar_index, border_color=boxBorder, bgcolor=bearFill)
    newLine  = line.new(startBar, zoneCe, endBar, zoneCe, xloc=xloc.bar_index, color=ceLineColor, style=line.style_dotted, width=2)
    newLabel = label.new(endBar, tagY, "BEAR FVG", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=tagTextColor, color=tagBg, size=size.tiny)

    array.push(fvgDir, -1)
    array.push(fvgLow, zoneLow)
    array.push(fvgHigh, zoneHigh)
    array.push(fvgCe, zoneCe)
    array.push(fvgStartBar, startBar)
    array.push(fvgEndBar, endBar)
    array.push(fvgBox, newBox)
    array.push(fvgLine, newLine)
    array.push(fvgLabel, newLabel)

//====================================================
// IFVG Conversion
//====================================================
fvgCount = array.size(fvgDir)
if fvgCount > 0
    for idx = 0 to fvgCount - 1
        dir_i   = array.get(fvgDir, idx)
        low_i   = array.get(fvgLow, idx)
        high_i  = array.get(fvgHigh, idx)
        ce_i    = array.get(fvgCe, idx)
        end_i   = array.get(fvgEndBar, idx)
        box_i   = array.get(fvgBox, idx)
        label_i = array.get(fvgLabel, idx)

        bullIfvg = dir_i == -1 and close > high_i
        bearIfvg = dir_i == 1 and close < low_i

        if bullIfvg
            array.set(fvgDir, idx, 2)
            box.set_bgcolor(box_i, ifvgFill)
            label.set_text(label_i, "IFVG")
            label.set_x(label_i, end_i)
            label.set_y(label_i, ce_i + tagOffset)
            label.set_style(label_i, label.style_label_down)

        if bearIfvg
            array.set(fvgDir, idx, -2)
            box.set_bgcolor(box_i, ifvgFill)
            label.set_text(label_i, "IFVG")
            label.set_x(label_i, end_i)
            label.set_y(label_i, ce_i - tagOffset)
            label.set_style(label_i, label.style_label_up)

//====================================================
// Keep only latest N
//====================================================
while array.size(fvgDir) > maxVisibleFvgs
    oldBox   = array.shift(fvgBox)
    oldLine  = array.shift(fvgLine)
    oldLabel = array.shift(fvgLabel)

    if not na(oldBox)
        box.delete(oldBox)
    if not na(oldLine)
        line.delete(oldLine)
    if not na(oldLabel)
        label.delete(oldLabel)

    array.shift(fvgDir)
    array.shift(fvgLow)
    array.shift(fvgHigh)
    array.shift(fvgCe)
    array.shift(fvgStartBar)
    array.shift(fvgEndBar)
````
