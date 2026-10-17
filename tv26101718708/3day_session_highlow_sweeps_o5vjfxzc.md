# 3-Day Session High/Low Sweeps

- url: https://www.tradingview.com/script/o5VJFxZC-3-Day-Session-High-Low-Sweeps/
- type: indicator
- pine_id: PUB;d6db5bbbc5294f7d9796e0fb6396b9a0
- version: 1.0

## Description

NY, LON, & ASIA high/low for three most recent sessions. It will remove each level when swept and keep those that aren't swept.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jakelester17

//@version=6
indicator("3-Day Session High/Low Sweeps", overlay = true, max_lines_count = 500, max_labels_count = 500)

//==============================
// Inputs
//==============================
showAsia   = input.bool(true, "Show Asia")
showLondon = input.bool(true, "Show London")
showNY     = input.bool(true, "Show New York")

asiaSession   = input.session("1700-0000", "Asia Session")
londonSession = input.session("0100-0400", "London Session")
nySession     = input.session("0830-1100", "New York Session")

lineWidth       = input.int(1, "Line Width", minval = 1, maxval = 3)
labelOffsetBars = input.int(3, "Label Offset Bars", minval = 1, maxval = 50)
daysToKeep      = input.int(3, "Completed Session Days To Keep", minval = 1, maxval = 10)

//==============================
// Colors
//==============================
asiaColor   = color.red
londonColor = color.orange
nyColor     = color.blue

//==============================
// Session Detection
//==============================
inAsia   = not na(time(timeframe.period, asiaSession))
inLondon = not na(time(timeframe.period, londonSession))
inNY     = not na(time(timeframe.period, nySession))

asiaStart   = inAsia and not inAsia[1]
asiaEnd     = not inAsia and inAsia[1]

londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

nyStart     = inNY and not inNY[1]
nyEnd       = not inNY and inNY[1]

//==============================
// Current session tracking
//==============================
var float asiaHigh = na
var float asiaLow  = na

var float londonHigh = na
var float londonLow  = na

var float nyHigh = na
var float nyLow  = na

if asiaStart
    asiaHigh := high
    asiaLow  := low
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

if londonStart
    londonHigh := high
    londonLow  := low
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

if nyStart
    nyHigh := high
    nyLow  := low
else if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

//==============================
// Storage arrays
//==============================
var line[]  asiaHighLines   = array.new_line()
var line[]  asiaLowLines    = array.new_line()
var label[] asiaHighLabels  = array.new_label()
var label[] asiaLowLabels   = array.new_label()

var line[]  londonHighLines  = array.new_line()
var line[]  londonLowLines   = array.new_line()
var label[] londonHighLabels = array.new_label()
var label[] londonLowLabels  = array.new_label()

var line[]  nyHighLines   = array.new_line()
var line[]  nyLowLines    = array.new_line()
var label[] nyHighLabels  = array.new_label()
var label[] nyLowLabels   = array.new_label()

//==============================
// Helpers
//==============================
f_trim_oldest(_lines, _labels, _keepCount) =>
    while array.size(_lines) > _keepCount
        oldLine = array.shift(_lines)
        oldLabel = array.shift(_labels)
        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

f_add_level(_lines, _labels, _price, _text, _color) =>
    newLine = line.new(
         bar_index, _price,
         bar_index + 1, _price,
         extend = extend.right,
         color = _color,
         style = line.style_dashed,
         width = lineWidth)
    newLabel = label.new(
         bar_index + labelOffsetBars, _price,
         _text,
         style = label.style_label_left,
         textcolor = color.white,
         color = _color,
         size = size.tiny)
    array.push(_lines, newLine)
    array.push(_labels, newLabel)

f_update_labels(_labels) =>
    labelCount = array.size(_labels)
    if labelCount > 0
        for i = 0 to labelCount - 1
            lbl = array.get(_labels, i)
            if not na(lbl)
                label.set_x(lbl, bar_index + labelOffsetBars)

f_remove_swept_highs(_lines, _labels) =>
    lineCount = array.size(_lines)
    if lineCount > 0
        for i = lineCount - 1 to 0
            ln = array.get(_lines, i)
            lb = array.get(_labels, i)
            if not na(ln) and high > line.get_y1(ln)
                line.delete(ln)
                if not na(lb)
                    label.delete(lb)
                array.remove(_lines, i)
                array.remove(_labels, i)

f_remove_swept_lows(_lines, _labels) =>
    lineCount = array.size(_lines)
    if lineCount > 0
        for i = lineCount - 1 to 0
            ln = array.get(_lines, i)
            lb = array.get(_labels, i)
            if not na(ln) and low < line.get_y1(ln)
                line.delete(ln)
                if not na(lb)
                    label.delete(lb)
                array.remove(_lines, i)
                array.remove(_labels, i)

//==============================
// Create new completed session levels
//==============================
if asiaEnd and showAsia and not na(asiaHigh) and not na(asiaLow)
    f_add_level(asiaHighLines, asiaHighLabels, asiaHigh, "Asia High", asiaColor)
    f_add_level(asiaLowLines, asiaLowLabels, asiaLow, "Asia Low", asiaColor)
    f_trim_oldest(asiaHighLines, asiaHighLabels, daysToKeep)
    f_trim_oldest(asiaLowLines, asiaLowLabels, daysToKeep)

if londonEnd and showLondon and not na(londonHigh) and not na(londonLow)
    f_add_level(londonHighLines, londonHighLabels, londonHigh, "London High", londonColor)
    f_add_level(londonLowLines, londonLowLabels, londonLow, "London Low", londonColor)
    f_trim_oldest(londonHighLines, londonHighLabels, daysToKeep)
    f_trim_oldest(londonLowLines, londonLowLabels, daysToKeep)

if nyEnd and showNY and not na(nyHigh) and not na(nyLow)
    f_add_level(nyHighLines, nyHighLabels, nyHigh, "NY High", nyColor)
    f_add_level(nyLowLines, nyLowLabels, nyLow, "NY Low", nyColor)
    f_trim_oldest(nyHighLines, nyHighLabels, daysToKeep)
    f_trim_oldest(nyLowLines, nyLowLabels, daysToKeep)

//==============================
// Keep labels moving right
//==============================
f_update_labels(asiaHighLabels)
f_update_labels(asiaLowLabels)

f_update_labels(londonHighLabels)
f_update_labels(londonLowLabels)

f_update_labels(nyHighLabels)
f_update_labels(nyLowLabels)

//==============================
// Remove only the exact swept side
//==============================
f_remove_swept_highs(asiaHighLines, asiaHighLabels)
f_remove_swept_lows(asiaLowLines, asiaLowLabels)

f_remove_swept_highs(londonHighLines, londonHighLabels)
f_remove_swept_lows(londonLowLines, londonLowLabels)

f_remove_swept_highs(nyHighLines, nyHighLabels)
f_remove_swept_lows(nyLowLines, nyLowLabels)
````
