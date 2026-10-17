# Unfilled Fair Value Gaps - Jestin V James

- url: https://www.tradingview.com/script/WhsXdymA-Unfilled-Fair-Value-Gaps-Jestin-V-James/
- type: indicator
- pine_id: PUB;ceef6083b41645388175aeae99d6a600
- version: 2.0

## Description

[b]Unfilled Fair Value Gaps[/b]

Detects and displays Fair Value Gaps (FVG) based on ICT (Inner Circle Trader) methodology. A Fair Value Gap is a 3-candle price imbalance where the market moved so aggressively that certain price levels were never traded — creating an inefficiency that price tends to revisit.

[i]Bullish FVG (green rectangle)[/i]
Formed when the low of the 3rd candle is higher than the high of the 1st candle, indicating an aggressive upward move. The gap sits below current price and acts as a potential support zone.

[i]Bearish FVG (red rectangle)[/i]
Formed when the high of the 3rd candle is lower than the low of the 1st candle, indicating an aggressive downward move. The gap sits above current price and acts as a potential resistance zone.

Only unfilled gaps are shown. A gap is considered fully filled when price completely trades through it — bullish gaps are removed when price breaks below the gap's bottom, bearish gaps are removed when price breaks above the gap's top. Partial fills keep the rectangle visible.

[b]Settings:[/b]

Bullish FVG color (default: light green)
Bearish FVG color (default: light red)

## Source Code

````pine
//@version=6
indicator("Unfilled Fair Value Gaps", overlay=true, max_boxes_count=500)

// === Inputs ===
bullColor = input.color(color.new(color.green, 85), "Bullish FVG Color")
bearColor = input.color(color.new(color.red,   85), "Bearish FVG Color")

// === Active FVG tracking ===
var box[]   bullBoxes = array.new<box>()
var float[] bullTop   = array.new<float>()
var float[] bullBot   = array.new<float>()

var box[]   bearBoxes = array.new<box>()
var float[] bearTop   = array.new<float>()
var float[] bearBot   = array.new<float>()

// === Mitigation: remove FVGs that price has entered ===
// Check BEFORE creating new ones so newly formed gaps are not immediately deleted.

if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        // Bullish gap fully filled when price closes through the bottom of the gap
        if low <= array.get(bullBot, i)
            box.delete(array.get(bullBoxes, i))
            array.remove(bullBoxes, i)
            array.remove(bullTop,   i)
            array.remove(bullBot,   i)

if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        // Bearish gap fully filled when price closes through the top of the gap
        if high >= array.get(bearTop, i)
            box.delete(array.get(bearBoxes, i))
            array.remove(bearBoxes, i)
            array.remove(bearTop,   i)
            array.remove(bearBot,   i)

// === Detect and draw Bullish FVG ===
// 3-candle pattern: candle1=bar[2], candle2=bar[1], candle3=bar[0]
// Condition: low of candle3 > high of candle1
// Gap zone: bottom = high[2], top = low[0]
if low[0] > high[2]
    gapTop = low[0]
    gapBot = high[2]
    b = box.new(bar_index[2], gapTop, bar_index, gapBot,
         border_color=color.new(color.green, 60), bgcolor=bullColor)
    array.push(bullBoxes, b)
    array.push(bullTop, gapTop)
    array.push(bullBot, gapBot)

// === Detect and draw Bearish FVG ===
// 3-candle pattern: candle1=bar[2], candle2=bar[1], candle3=bar[0]
// Condition: high of candle3 < low of candle1
// Gap zone: bottom = high[0], top = low[2]
if high[0] < low[2]
    gapTop = low[2]
    gapBot = high[0]
    b = box.new(bar_index[2], gapTop, bar_index, gapBot,
         border_color=color.new(color.red, 60), bgcolor=bearColor)
    array.push(bearBoxes, b)
    array.push(bearTop, gapTop)
    array.push(bearBot, gapBot)
````
