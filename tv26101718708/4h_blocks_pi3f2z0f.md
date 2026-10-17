# 4H Blocks

- url: https://www.tradingview.com/script/pi3f2Z0F-4H-Blocks/
- type: indicator
- pine_id: PUB;0b9c6e89cf544bf3af7d060c3a7253a4
- version: 2.0

## Description

A lightweight visualization tool that plots 4-hour trading blocks directly on your chart using New York Time (EST)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=5
indicator("4H Blocks", overlay=true, max_boxes_count=500, max_lines_count=500)

// === GLOBAL SETTINGS ===
globalGroup = "Global Settings"
daysToShow       = input.int(10, "Days to Show", minval=1, maxval=20, group=globalGroup)
showCurrentBlock = input.bool(false, "Show Current 4H Block", group=globalGroup)

// === BORDER SETTINGS ===
borderGroup      = "Border Style (All Blocks)"
borderWidth      = input.int(1, "Border Width", minval=0, maxval=5, group=borderGroup)
borderStyleInput = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=borderGroup)
borderStyle      = borderStyleInput == "Solid" ? line.style_solid : borderStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// === PER-BLOCK SETTINGS ===
b1Group   = "Block 1 · 18:00–22:00 EST"
showB1    = input.bool(true, "", inline="b1", group=b1Group)
b1BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b1", group=b1Group)
b1BdColor = input.color(#0f0f0f, "Border", inline="b1", group=b1Group)

b2Group   = "Block 2 · 22:00–02:00 EST"
showB2    = input.bool(true, "", inline="b2", group=b2Group)
b2BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b2", group=b2Group)
b2BdColor = input.color(#0f0f0f, "Border", inline="b2", group=b2Group)

b3Group   = "Block 3 · 02:00–06:00 EST"
showB3    = input.bool(false, "", inline="b3", group=b3Group)
b3BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b3", group=b3Group)
b3BdColor = input.color(#0f0f0f, "Border", inline="b3", group=b3Group)

b4Group   = "Block 4 · 06:00–10:00 EST"
showB4    = input.bool(true, "", inline="b4", group=b4Group)
b4BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b4", group=b4Group)
b4BdColor = input.color(#0f0f0f, "Border", inline="b4", group=b4Group)

b5Group   = "Block 5 · 10:00–14:00 EST"
showB5    = input.bool(false, "", inline="b5", group=b5Group)
b5BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b5", group=b5Group)
b5BdColor = input.color(#0f0f0f, "Border", inline="b5", group=b5Group)

b6Group   = "Block 6 · 14:00–18:00 EST"
showB6    = input.bool(false, "", inline="b6", group=b6Group)
b6BgColor = input.color(color.new(#3a86ff, 95), "Background", inline="b6", group=b6Group)
b6BdColor = input.color(#0f0f0f, "Border", inline="b6", group=b6Group)

// === SESSION DETECTION ===
TZ = "America/New_York"
inB1 = not na(time(timeframe.period, "1800-2201", TZ))
inB2 = not na(time(timeframe.period, "2201-0201", TZ))
inB3 = not na(time(timeframe.period, "0201-0601", TZ))
inB4 = not na(time(timeframe.period, "0601-1001", TZ))
inB5 = not na(time(timeframe.period, "1001-1401", TZ))
inB6 = not na(time(timeframe.period, "1401-1800", TZ))

blockIndex      = inB1 ? 1 : inB2 ? 2 : inB3 ? 3 : inB4 ? 4 : inB5 ? 5 : inB6 ? 6 : 0
blockStart      = blockIndex != blockIndex[1] and blockIndex != 0

// === STATE ===
var float blkHigh  = na
var float blkLow   = na
var int   blkStart = na
var int   blkIdx   = na
var box   liveBox  = na
var box[] allBoxes = array.new_box()

// === HELPERS ===
blockBgColor(idx) => idx == 1 ? b1BgColor : idx == 2 ? b2BgColor : idx == 3 ? b3BgColor : idx == 4 ? b4BgColor : idx == 5 ? b5BgColor : idx == 6 ? b6BgColor : color.new(color.gray, 80)
blockBdColor(idx) => idx == 1 ? b1BdColor : idx == 2 ? b2BdColor : idx == 3 ? b3BdColor : idx == 4 ? b4BdColor : idx == 5 ? b5BdColor : idx == 6 ? b6BdColor : color.gray
blockEnabled(idx) => idx == 1 ? showB1 : idx == 2 ? showB2 : idx == 3 ? showB3 : idx == 4 ? showB4 : idx == 5 ? showB5 : idx == 6 ? showB6 : false

// === LOGIC ===
if blockStart and not na(blkHigh) and not na(blkStart)
    if blockEnabled(blkIdx)
        array.push(allBoxes, box.new(blkStart, blkHigh, bar_index - 1, blkLow, border_color=blockBdColor(blkIdx), border_width=borderWidth, border_style=borderStyle, bgcolor=blockBgColor(blkIdx)))
    box.delete(liveBox)
    liveBox := na

if blockStart
    blkStart := bar_index
    blkIdx   := blockIndex
    blkHigh  := na
    blkLow   := na

if blockIndex != 0
    blkHigh := na(blkHigh) ? high : math.max(blkHigh, high)
    blkLow  := na(blkLow)  ? low  : math.min(blkLow, low)
    if showCurrentBlock and blockEnabled(blockIndex)
        box.delete(liveBox)
        liveBox := box.new(blkStart, blkHigh, bar_index, blkLow, border_color=blockBdColor(blockIndex), border_width=borderWidth, border_style=borderStyle, bgcolor=blockBgColor(blockIndex))
    else
        box.delete(liveBox)
        liveBox := na

while array.size(allBoxes) > daysToShow * 6
    box.delete(array.shift(allBoxes))
````
