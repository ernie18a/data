# Impulse Box System

- url: https://www.tradingview.com/script/kHwXxnJ6-Impulse-Box-System/
- type: indicator
- pine_id: PUB;68873f37110244fdb63451346189cd48
- version: 1.0

## Description

Description:
A Pine Script v6 Smart Money Concepts engine that plots swing structure, BOS/CHoCH, order blocks, fair value gaps, pivot supply/demand zones, equal highs/lows, premium/discount zones, institutional filters, and wick‑based Fibonacci rejection levels. Built for confluence stacking and clean visual execution.

How to Use:
Add the indicator, enable the features you want, and watch for structure breaks, OB/FVG touches, zone reactions, and wick‑fib confluence to guide entries and bias.

## Source Code

````pine
//@version=6
indicator("Impulse Box System — Test 10", overlay = true, max_boxes_count = 500)

//──────────────────────────────────────────────
// 1. Candle State Detection
//──────────────────────────────────────────────
isBull = close > open
isBear = close < open
bearishClose = isBear and barstate.isconfirmed

//──────────────────────────────────────────────
// 2. Track the bullish candle that made the high
//──────────────────────────────────────────────
var float lastBullWickHigh = na
var float lastBullBodyTop  = na

if isBull
    lastBullWickHigh := high
    lastBullBodyTop  := close > open ? close : open

//──────────────────────────────────────────────
// 3. ULTIMATE + PENULTIMATE BOX LOGIC
//──────────────────────────────────────────────
var box ultimate = na
var box penultimate = na

//──────────────────────────────────────────────
// 4. DOMINANT IMPULSE SOURCE CANDLE STORAGE
// This stores the bullish candle AFTER the bearish candle
// that created the ultimate.
//──────────────────────────────────────────────
var float domBodyBottom = na
var float domWickBottom = na

// Track the previous candle type
var bool prevWasBear = false

if bearishClose
    prevWasBear := true
else
    prevWasBear := false

// If previous candle was bearish and THIS candle is bullish,
// THIS is the dominant impulse source candle.
if prevWasBear and isBull
    domBodyBottom := math.min(open, close)
    domWickBottom := low

//──────────────────────────────────────────────
// 5. DOMINANT IMPULSE BOX
//──────────────────────────────────────────────
var box impulseBox = na

//──────────────────────────────────────────────
// 6. ON BEARISH CLOSE → SHIFT + CREATE BOXES
//──────────────────────────────────────────────
if bearishClose and not na(lastBullWickHigh)

    // SHIFT ultimate → penultimate
    newPenultimate = false
    if not na(ultimate)

        if not na(penultimate)
            box.delete(penultimate)

        penultimate := ultimate
        newPenultimate := true

    // CREATE NEW ULTIMATE
    ultimate := box.new(
        bar_index - 1, lastBullWickHigh,
        bar_index,     lastBullBodyTop,
        bgcolor = color.new(color.green, 80),
        border_color = color.green
    )

    //──────────────────────────────────────────
    // 7. CREATE DOMINANT IMPULSE BOX
    // Using ONLY the bullish candle AFTER the bearish candle
    // that created the ultimate.
    //──────────────────────────────────────────
    if newPenultimate and not na(domBodyBottom) and not na(domWickBottom)

        if not na(impulseBox)
            box.delete(impulseBox)

        impulseBox := box.new(
            bar_index - 1, domWickBottom,   // bottom wick
            bar_index - 1, domBodyBottom,   // bottom body
            bgcolor = color.new(color.green, 80),
            border_color = color.green
        )

//──────────────────────────────────────────────
// 8. Extend boxes to the right edge
//──────────────────────────────────────────────
if not na(ultimate)
    box.set_right(ultimate, bar_index)

if not na(penultimate)
    box.set_right(penultimate, bar_index)

if not na(impulseBox)
    box.set_right(impulseBox, bar_index)
````
