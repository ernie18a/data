# Last 30 Candles Highlight

- url: https://www.tradingview.com/script/Br2qNknq-Last-30-Candles-Highlight/
- type: indicator
- pine_id: PUB;b534aa886adb4df78fcf791f72a47b61
- version: 1.0

## Description

Last 30 min candle highlight on any timeframe

You can change color and mark candle

## Source Code

````pine
//@version=6
indicator("Last 30 Candles Highlight", overlay=true, max_boxes_count=10, max_labels_count=10)

// ============================================================
// Highlights the most recent 30 bars on ANY timeframe.
// ============================================================

// --- User Inputs ---
boxOpacity     = input.int(15, "Box Background Opacity (%)", minval=0, maxval=100)
boxBorderColor = input.color(color.new(color.blue, 40), "Box Border Color")
labelEnabled   = input.bool(true, "Show Label at Start of Zone")

// --- Capture the last bar index ---
var int lastBarIdx = na
if barstate.islast
    lastBarIdx := bar_index

// --- Determine if current bar is one of the last 30 ---
isLast30 = not na(lastBarIdx) ? (bar_index > lastBarIdx - 30) : false

// --- (1) Background Box covering the last 30 bars ---
var box highlightBox = na
if barstate.islast
    box.delete(highlightBox)
    topY = ta.highest(high, 30)
    botY = ta.lowest(low, 30)
    highlightBox := box.new(
         bar_index - 30, topY * 1.15,
         bar_index,      botY * 0.85,
         bgcolor      = color.new(color.blue, 100 - boxOpacity),
         border_color = boxBorderColor,
         border_style = line.style_dashed,
         xloc         = xloc.bar_index
    )

// --- (2) Blue candle coloring (semi-transparent overlay on the candle bodies) ---
barcolor(isLast30 ? color.new(color.blue, 60) : na)

// --- (3) Optional label at the start of the zone ---
if barstate.islast and labelEnabled
    label.new(
         x         = bar_index - 30,
         y         = ta.highest(high, 50) * 1.03,
         text      = "← Last 30 bars",
         style     = label.style_label_down,
         color     = color.new(color.blue, 80),
         textcolor = color.white,
         size      = size.normal
    )

// --- (4) Legend entry ---
plot(na, title="Last 30 bars highlighted", display=display.none)
````
