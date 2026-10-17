# CISD

- url: https://www.tradingview.com/script/JHKMZ1JJ-CISD/
- type: indicator
- pine_id: PUB;32ca051fd6e34f50bc88a7730c6a91a5
- version: 1.0

## Description

This indicator is a Smart Money Concepts (SMC) tool designed to help traders identify key market structure and high-probability trading zones. It features automatic detection of Break of Structure (BOS) and Change of Character (CHOCH), along with filtered Fair Value Gaps (FVG) and high-probability Order Blocks that are removed once mitigated to keep the chart clean. It also includes a smart CISD system that extends and disappears upon interaction, providing dynamic insight into price behavior. Built for clarity and precision, this tool focuses on institutional concepts to support better decision-making across all timeframes.

## Source Code

````pine
//@version=5
indicator("SMC FINAL PRO (ULTIMATE CLEAN)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// SETTINGS
showBOS = input.bool(true, "Show CHoCH / BOS")
swingLen = input.int(7, "Swing Length")
minGap = input.int(10, "Min Gap Between Signals")

bosColor = input.color(color.teal, "BOS Color")
chochColor = input.color(color.red, "CHoCH Color")

showCISD = input.bool(true, "Show CISD")
showFVG = input.bool(true, "Show FVG")
extendFVG = input.int(20, "Extend FVG")

fvgBullCol = input.color(color.new(color.gray, 90))
fvgBearCol = input.color(color.new(color.gray, 90))

// PREVENT DUPLICATES
var float lastDrawnHigh = na
var float lastDrawnLow  = na

// SWINGS
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow = na
var int lastHighBar = na
var int lastLowBar = na
var int trend = 0
var int lastSigBar = na

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - swingLen

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - swingLen

// BREAKS
bullBreak = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
bearBreak = not na(lastLow) and close < lastLow and close[1] >= lastLow

chochUp = bullBreak and trend == -1
chochDown = bearBreak and trend == 1

canDraw = na(lastSigBar) or (bar_index - lastSigBar > minGap)

// STRUCTURE
if showBOS and bullBreak and canDraw and (lastHigh != lastDrawnHigh or na(lastDrawnHigh))
    startBar = lastHighBar
    endBar   = bar_index
    midBar   = startBar + int((endBar - startBar) / 2)

    line.new(startBar, lastHigh, endBar, lastHigh, color=chochUp ? chochColor : bosColor)
    label.new(midBar, lastHigh, text=chochUp ? "ch" : "bos", style=label.style_none, size=size.small, textcolor=chochUp ? chochColor : bosColor)

    lastDrawnHigh := lastHigh
    trend := 1
    lastSigBar := bar_index

if showBOS and bearBreak and canDraw and (lastLow != lastDrawnLow or na(lastDrawnLow))
    startBar = lastLowBar
    endBar   = bar_index
    midBar   = startBar + int((endBar - startBar) / 2)

    line.new(startBar, lastLow, endBar, lastLow, color=chochDown ? chochColor : bosColor)
    label.new(midBar, lastLow, text=chochDown ? "ch" : "bos", style=label.style_none, size=size.small, textcolor=chochDown ? chochColor : bosColor)

    lastDrawnLow := lastLow
    trend := -1
    lastSigBar := bar_index

// =====================
// SMART CISD
// =====================
bullCISD = close[1] < open[1] and close > open[1]
bearCISD = close[1] > open[1] and close < open[1]

var line[] bullCISDs = array.new_line()
var line[] bearCISDs = array.new_line()

if showCISD and bullCISD
    l = line.new(bar_index - 1, high[1], bar_index + 50, high[1], color=color.yellow)
    array.push(bullCISDs, l)

if showCISD and bearCISD
    l = line.new(bar_index - 1, low[1], bar_index + 50, low[1], color=color.yellow)
    array.push(bearCISDs, l)

if array.size(bullCISDs) > 0
    for i = array.size(bullCISDs) - 1 to 0
        l = array.get(bullCISDs, i)
        if low <= line.get_y1(l)
            line.delete(l)
            array.remove(bullCISDs, i)

if array.size(bearCISDs) > 0
    for i = array.size(bearCISDs) - 1 to 0
        l = array.get(bearCISDs, i)
        if high >= line.get_y1(l)
            line.delete(l)
            array.remove(bearCISDs, i)

// =====================
// FVG
// =====================
bullFVG = low > high[2]
bearFVG = high < low[2]

body = math.abs(close - open)
candleRange = high - low
strongMove = body > (candleRange * 0.5)

var box[] bullFVGs = array.new_box()
var box[] bearFVGs = array.new_box()

if showFVG and bullFVG and strongMove
    b = box.new(bar_index - 2, high[2], bar_index + extendFVG, low, bgcolor=fvgBullCol)
    array.push(bullFVGs, b)

if showFVG and bearFVG and strongMove
    b = box.new(bar_index - 2, high, bar_index + extendFVG, low[2], bgcolor=fvgBearCol)
    array.push(bearFVGs, b)

if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        b = array.get(bullFVGs, i)
        if low <= box.get_top(b)
            box.delete(b)
            array.remove(bullFVGs, i)

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        b = array.get(bearFVGs, i)
        if high >= box.get_bottom(b)
            box.delete(b)
            array.remove(bearFVGs, i)

// =====================
// 🔥 HIGH PROBABILITY ORDER BLOCK (LIGHT)
// =====================
bodyOB = math.abs(close - open)
rangeOB = high - low
strongOB = bodyOB > (rangeOB * 0.6)

bullOBColor = color.new(color.teal, 85)
bearOBColor = color.new(color.red, 85)

var box[] bullOBs = array.new_box()
var box[] bearOBs = array.new_box()

if showBOS and bullBreak and strongOB and close[1] < open[1]
    b = box.new(bar_index[1], high[1], bar_index + 25, low[1], bgcolor=bullOBColor, border_color=color.new(color.teal, 70))
    array.push(bullOBs, b)

if showBOS and bearBreak and strongOB and close[1] > open[1]
    b = box.new(bar_index[1], high[1], bar_index + 25, low[1], bgcolor=bearOBColor, border_color=color.new(color.red, 70))
    array.push(bearOBs, b)

if array.size(bullOBs) > 0
    for i = array.size(bullOBs) - 1 to 0
        ob = array.get(bullOBs, i)
        if low <= box.get_bottom(ob)
            box.delete(ob)
            array.remove(bullOBs, i)

if array.size(bearOBs) > 0
    for i = array.size(bearOBs) - 1 to 0
        ob = array.get(bearOBs, i)
        if high >= box.get_top(ob)
            box.delete(ob)
            array.remove(bearOBs, i)

// REQUIRED
plot(na)
````
