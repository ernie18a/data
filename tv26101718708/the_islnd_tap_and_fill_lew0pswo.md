# The Islnd Tap and Fill

- url: https://www.tradingview.com/script/lEW0psWO-The-Islnd-Tap-and-Fill/
- type: indicator
- pine_id: PUB;a375d9486e394a519b1138e7f8ca2c81
- version: 2.0

## Description

The Islnd Tap and Fill indicator automatically identifies and visualizes Bullish and Bearish Gaps using a three‑candle pattern.
It plots colored zones extended to the right, draws an optional midline with price labels, and tracks each gap’s lifecycle.
When price first trades back into a gap, the indicator marks a “Tap”; when price fully closes through the gap, it removes the zone and associated markings and prints an “FVG Filled” label.
This provides a clear, structured view of where price has left and later revisited imbalanced areas, supporting precise entry, management, and exit decisions.

## Source Code

````pine
//@version=6
indicator(
     title           = "The Island Gaps (FVG) + Tap/Fill + Midline Price",
     shorttitle      = "TIG Tap/Fill",
     overlay         = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count= 500
)

//──────────────────────────────────────────────────────────────────────────────
// USER INPUTS
//──────────────────────────────────────────────────────────────────────────────

showBull       = input.bool(true,  "Show Bullish FVGs")
showBear       = input.bool(true,  "Show Bearish FVGs")

bullBgColor    = input.color(color.new(color.yellow, 75), "Bullish FVG Fill Color")
bearBgColor    = input.color(color.new(color.white,  75), "Bearish FVG Fill Color")

bullBorderCol  = input.color(color.yellow, "Bullish Border Color")
bearBorderCol  = input.color(color.white,  "Bearish Border Color")

showMidline    = input.bool(true,  "Show FVG Midline")
showMidPrice   = input.bool(true,  "Show Midline Price Label")
showTapSignal  = input.bool(true,  "Show Tap Signal")
showFillSignal = input.bool(true,  "Show Filled Signal")

//──────────────────────────────────────────────────────────────────────────────
// PERSISTENT ARRAYS — track active FVG zones
//──────────────────────────────────────────────────────────────────────────────

// Bullish FVG tracking
var bull_boxes       = array.new<box>()    // FVG box
var bull_tops        = array.new<float>()  // top price
var bull_bottoms     = array.new<float>()  // bottom price
var bull_mids        = array.new<line>()   // midline
var bull_tapped      = array.new<bool>()   // has been tapped?
var bull_tap_labels  = array.new<label>()  // "Tap" label
var bull_mid_labels  = array.new<label>()  // midline price label

// Bearish FVG tracking
var bear_boxes       = array.new<box>()
var bear_tops        = array.new<float>()
var bear_bottoms     = array.new<float>()
var bear_mids        = array.new<line>()
var bear_tapped      = array.new<bool>()
var bear_tap_labels  = array.new<label>()
var bear_mid_labels  = array.new<label>()

//──────────────────────────────────────────────────────────────────────────────
// FVG DETECTION (classic 3‑bar ICT style)
//──────────────────────────────────────────────────────────────────────────────

isBullFVG = low[1]  > high[2]
isBearFVG = high[1] < low[2]

//──────────────────────────────────────────────────────────────────────────────
// CREATE NEW BULLISH FVG ZONE
//──────────────────────────────────────────────────────────────────────────────

if isBullFVG and showBull
    float gapTop    = low[1]
    float gapBottom = high[2]
    float gapMid    = (gapTop + gapBottom) / 2.0

    // Box, extended right
    newBox = box.new(
         left         = bar_index - 2,
         top          = gapTop,
         right        = bar_index,
         bottom       = gapBottom,
         bgcolor      = bullBgColor,
         border_color = bullBorderCol,
         border_width = 1,
         extend       = extend.right
         )

    // Midline, extended right
    newMid = line.new(
         x1     = bar_index - 2,
         y1     = gapMid,
         x2     = bar_index,
         y2     = gapMid,
         color  = bullBorderCol,
         style  = line.style_dashed,
         width  = 1,
         extend = extend.right
         )

    if not showMidline
        line.delete(newMid)

    // Midline price label (optional)
    newMidLbl = label(na)
    if showMidline and showMidPrice
        newMidLbl := label.new(
             x         = bar_index,
             y         = gapMid,
             text      = str.tostring(gapMid, format.mintick),
             color     = color.new(color.yellow, 20),
             textcolor = color.black,
             style     = label.style_label_left,
             size      = size.small,
             xloc      = xloc.bar_index
             )

    // Push all into arrays
    array.push(bull_boxes,      newBox)
    array.push(bull_tops,       gapTop)
    array.push(bull_bottoms,    gapBottom)
    array.push(bull_mids,       newMid)
    array.push(bull_tapped,     false)
    array.push(bull_tap_labels, label(na))
    array.push(bull_mid_labels, newMidLbl)

//──────────────────────────────────────────────────────────────────────────────
// CREATE NEW BEARISH FVG ZONE
//──────────────────────────────────────────────────────────────────────────────

if isBearFVG and showBear
    float gapTop    = low[2]
    float gapBottom = high[1]
    float gapMid    = (gapTop + gapBottom) / 2.0

    newBox = box.new(
         left         = bar_index - 2,
         top          = gapTop,
         right        = bar_index,
         bottom       = gapBottom,
         bgcolor      = bearBgColor,
         border_color = bearBorderCol,
         border_width = 1,
         extend       = extend.right
         )

    newMid = line.new(
         x1     = bar_index - 2,
         y1     = gapMid,
         x2     = bar_index,
         y2     = gapMid,
         color  = bearBorderCol,
         style  = line.style_dashed,
         width  = 1,
         extend = extend.right
         )

    if not showMidline
        line.delete(newMid)

    newMidLbl = label(na)
    if showMidline and showMidPrice
        newMidLbl := label.new(
             x         = bar_index,
             y         = gapMid,
             text      = str.tostring(gapMid, format.mintick),
             color     = color.new(color.white, 20),
             textcolor = color.black,
             style     = label.style_label_left,
             size      = size.small,
             xloc      = xloc.bar_index
             )

    array.push(bear_boxes,      newBox)
    array.push(bear_tops,       gapTop)
    array.push(bear_bottoms,    gapBottom)
    array.push(bear_mids,       newMid)
    array.push(bear_tapped,     false)
    array.push(bear_tap_labels, label(na))
    array.push(bear_mid_labels, newMidLbl)

//──────────────────────────────────────────────────────────────────────────────
// BULLISH FVG MANAGEMENT — Tap & Filled
//──────────────────────────────────────────────────────────────────────────────

if array.size(bull_boxes) > 0
    int i = array.size(bull_boxes) - 1
    while i >= 0
        float gTop   = array.get(bull_tops,    i)
        float gBot   = array.get(bull_bottoms, i)
        bool  tapped = array.get(bull_tapped,  i)

        // Tap: wick into zone; Filled: close through bottom
        bool priceInZone = low  <= gTop and low  >= gBot
        bool isFilled    = close < gBot

        if isFilled
            // Delete visuals
            box b = array.get(bull_boxes, i)
            if not na(b)
                box.delete(b)

            line m = array.get(bull_mids, i)
            if not na(m)
                line.delete(m)

            label tapLbl = array.get(bull_tap_labels, i)
            if not na(tapLbl)
                label.delete(tapLbl)

            label midLbl = array.get(bull_mid_labels, i)
            if not na(midLbl)
                label.delete(midLbl)

            // Mark fill
            if showFillSignal
                label.new(
                     x         = bar_index,
                     y         = gBot,
                     text      = "FVG Filled",
                     color     = color.new(color.yellow, 20),
                     textcolor = color.black,
                     style     = label.style_label_up,
                     size      = size.small,
                     xloc      = xloc.bar_index
                     )

            // Remove from arrays (keep indices aligned)
            array.remove(bull_boxes,      i)
            array.remove(bull_tops,       i)
            array.remove(bull_bottoms,    i)
            array.remove(bull_mids,       i)
            array.remove(bull_tapped,     i)
            array.remove(bull_tap_labels, i)
            array.remove(bull_mid_labels, i)

        else if priceInZone and not tapped
            // First time price enters the gap → Tap
            array.set(bull_tapped, i, true)

            if showTapSignal
                label newTapLbl = label.new(
                     x         = bar_index,
                     y         = low,
                     text      = "Tap",
                     color     = color.new(color.yellow, 20),
                     textcolor = color.black,
                     style     = label.style_label_up,
                     size      = size.small,
                     xloc      = xloc.bar_index
                     )
                array.set(bull_tap_labels, i, newTapLbl)

        i -= 1

//──────────────────────────────────────────────────────────────────────────────
// BEARISH FVG MANAGEMENT — Tap & Filled
//──────────────────────────────────────────────────────────────────────────────

if array.size(bear_boxes) > 0
    int j = array.size(bear_boxes) - 1
    while j >= 0
        float gTop   = array.get(bear_tops,    j)
        float gBot   = array.get(bear_bottoms, j)
        bool  tapped = array.get(bear_tapped,  j)

        // Tap: wick into zone; Filled: close through top
        bool priceInZone = high >= gBot and high <= gTop
        bool isFilled    = close > gTop

        if isFilled
            box b = array.get(bear_boxes, j)
            if not na(b)
                box.delete(b)

            line m = array.get(bear_mids, j)
            if not na(m)
                line.delete(m)

            label tapLbl = array.get(bear_tap_labels, j)
            if not na(tapLbl)
                label.delete(tapLbl)

            label midLbl = array.get(bear_mid_labels, j)
            if not na(midLbl)
                label.delete(midLbl)

            if showFillSignal
                label.new(
                     x         = bar_index,
                     y         = gTop,
                     text      = "FVG Filled",
                     color     = color.new(color.white, 20),
                     textcolor = color.black,
                     style     = label.style_label_down,
                     size      = size.small,
                     xloc      = xloc.bar_index
                     )

            array.remove(bear_boxes,      j)
            array.remove(bear_tops,       j)
            array.remove(bear_bottoms,    j)
            array.remove(bear_mids,       j)
            array.remove(bear_tapped,     j)
            array.remove(bear_tap_labels, j)
            array.remove(bear_mid_labels, j)

        else if priceInZone and not tapped
            array.set(bear_tapped, j, true)

            if showTapSignal
                label newTapLbl = label.new(
                     x         = bar_index,
                     y         = high,
                     text      = "Tap",
                     color     = color.new(color.white, 20),
                     textcolor = color.black,
                     style     = label.style_label_down,
                     size      = size.small,
                     xloc      = xloc.bar_index
                     )
                array.set(bear_tap_labels, j, newTapLbl)

        j -= 1
````
