# Unfilled Fair Value Gaps

- url: https://www.tradingview.com/script/VW9VK9xS-Unfilled-Fair-Value-Gaps/
- type: indicator
- pine_id: PUB;47c6f632885d445b96d90bfc06e99f4e
- version: 7.0

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
indicator("Unfilled Fair Value Gaps", overlay=true, max_boxes_count=500, max_lines_count=500)

// === Inputs ===
bullColor         = input.color(color.new(color.green, 85), "Bullish FVG Color")
bearColor         = input.color(color.new(color.red,   85), "Bearish FVG Color")
borderWidth       = input.int(1, "Border Width", minval=1, maxval=4)
showFilled        = input.bool(false, "Show Recently Filled FVGs", group="Filled FVGs")
filledLookback    = input.int(30, "Filled FVG Lookback (bars)", minval=1, maxval=500, group="Filled FVGs")
filledTransp      = input.int(75, "Filled Transparency (0=solid, 95=faint)", minval=0, maxval=95, group="Filled FVGs")
filledBorderColor = input.color(color.gray,                "Filled Border Color", group="Filled FVGs")
filledBorderWidth = input.int(2, "Filled Border Width", minval=1, maxval=4, group="Filled FVGs")
showLabels        = input.bool(true, "Show FVG Labels")
showMidline       = input.bool(true, "Show 50% Midline", group="Midline")

// === Active FVG tracking ===
var box[]   bullBoxes    = array.new<box>()
var float[] bullTop      = array.new<float>()
var float[] bullBot      = array.new<float>()
var line[]  bullMidLines = array.new<line>()

var box[]   bearBoxes    = array.new<box>()
var float[] bearTop      = array.new<float>()
var float[] bearBot      = array.new<float>()
var line[]  bearMidLines = array.new<line>()

// === Filled FVG tracking ===
var box[] filledBullBoxes = array.new<box>()
var int[] filledBullBars  = array.new<int>()

var box[] filledBearBoxes = array.new<box>()
var int[] filledBearBars  = array.new<int>()

// === Sync unfilled box and midline colors/width with current inputs ===
bullMidColor = showMidline ? color.new(color.green, 40) : color(na)
bearMidColor = showMidline ? color.new(color.red,   40) : color(na)

if array.size(bullBoxes) > 0
    for i = 0 to array.size(bullBoxes) - 1
        b = array.get(bullBoxes, i)
        box.set_bgcolor(b, bullColor)
        box.set_border_color(b, color.new(bullColor, 60))
        box.set_border_width(b, borderWidth)
        line.set_color(array.get(bullMidLines, i), bullMidColor)

if array.size(bearBoxes) > 0
    for i = 0 to array.size(bearBoxes) - 1
        b = array.get(bearBoxes, i)
        box.set_bgcolor(b, bearColor)
        box.set_border_color(b, color.new(bearColor, 60))
        box.set_border_width(b, borderWidth)
        line.set_color(array.get(bearMidLines, i), bearMidColor)

// === Sync filled box colors/width with current inputs ===
if showFilled
    if array.size(filledBullBoxes) > 0
        for i = 0 to array.size(filledBullBoxes) - 1
            b = array.get(filledBullBoxes, i)
            box.set_bgcolor(b, color.new(bullColor, filledTransp))
            box.set_border_color(b, filledBorderColor)
            box.set_border_style(b, line.style_dotted)
            box.set_border_width(b, filledBorderWidth)

    if array.size(filledBearBoxes) > 0
        for i = 0 to array.size(filledBearBoxes) - 1
            b = array.get(filledBearBoxes, i)
            box.set_bgcolor(b, color.new(bearColor, filledTransp))
            box.set_border_color(b, filledBorderColor)
            box.set_border_style(b, line.style_dotted)
            box.set_border_width(b, filledBorderWidth)

// === Expire filled FVGs older than filledLookback bars ===
if showFilled
    if array.size(filledBullBoxes) > 0
        for i = array.size(filledBullBoxes) - 1 to 0
            if bar_index - array.get(filledBullBars, i) >= filledLookback
                box.delete(array.get(filledBullBoxes, i))
                array.remove(filledBullBoxes, i)
                array.remove(filledBullBars,  i)

    if array.size(filledBearBoxes) > 0
        for i = array.size(filledBearBoxes) - 1 to 0
            if bar_index - array.get(filledBearBars, i) >= filledLookback
                box.delete(array.get(filledBearBoxes, i))
                array.remove(filledBearBoxes, i)
                array.remove(filledBearBars,  i)

// === Mitigation: remove or restyle FVGs that price has filled ===
if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0
        if low <= array.get(bullBot, i)
            b  = array.get(bullBoxes, i)
            ml = array.get(bullMidLines, i)
            line.delete(ml)
            if showFilled
                box.set_bgcolor(b, color.new(bullColor, filledTransp))
                box.set_border_color(b, filledBorderColor)
                box.set_border_style(b, line.style_dotted)
                box.set_border_width(b, filledBorderWidth)
                array.push(filledBullBoxes, b)
                array.push(filledBullBars,  bar_index)
            else
                box.delete(b)
            array.remove(bullBoxes,    i)
            array.remove(bullTop,      i)
            array.remove(bullBot,      i)
            array.remove(bullMidLines, i)

if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0
        if high >= array.get(bearTop, i)
            b  = array.get(bearBoxes, i)
            ml = array.get(bearMidLines, i)
            line.delete(ml)
            if showFilled
                box.set_bgcolor(b, color.new(bearColor, filledTransp))
                box.set_border_color(b, filledBorderColor)
                box.set_border_style(b, line.style_dotted)
                box.set_border_width(b, filledBorderWidth)
                array.push(filledBearBoxes, b)
                array.push(filledBearBars,  bar_index)
            else
                box.delete(b)
            array.remove(bearBoxes,    i)
            array.remove(bearTop,      i)
            array.remove(bearBot,      i)
            array.remove(bearMidLines, i)

// === Session open detection ===
isSessionOpen = session.isfirstbar_regular or session.isfirstbar_regular[1] or session.isfirstbar_regular[2]

// === Detect and draw Bullish FVG ===
// 3-candle pattern: candle1=bar[2], candle2=bar[1], candle3=bar[0]
// Condition: low of candle3 > high of candle1 — gap zone: bottom=high[2], top=low[0]
if low[0] > high[2] and (not isSessionOpen or (open[1] <= high[2] and open[0] <= high[1]))
    gapTop = low[0]
    gapBot = high[2]
    b  = box.new(bar_index[2], gapTop, bar_index, gapBot,
         border_color=color.new(bullColor, 60), bgcolor=bullColor, border_width=borderWidth,
         text=showLabels ? "FVG+" : "", text_color=color.new(color.green, 20),
         text_size=size.small, text_halign=text.align_right, text_valign=text.align_center)
    mid = (gapTop + gapBot) / 2
    ml = line.new(bar_index[2], mid, bar_index, mid,
         color=bullMidColor, style=line.style_dashed)
    array.push(bullBoxes,    b)
    array.push(bullTop,      gapTop)
    array.push(bullBot,      gapBot)
    array.push(bullMidLines, ml)

// === Detect and draw Bearish FVG ===
// 3-candle pattern: candle1=bar[2], candle2=bar[1], candle3=bar[0]
// Condition: high of candle3 < low of candle1 — gap zone: bottom=high[0], top=low[2]
if high[0] < low[2] and (not isSessionOpen or (open[1] >= low[2] and open[0] >= low[1]))
    gapTop = low[2]
    gapBot = high[0]
    b  = box.new(bar_index[2], gapTop, bar_index, gapBot,
         border_color=color.new(bearColor, 60), bgcolor=bearColor, border_width=borderWidth,
         text=showLabels ? "FVG-" : "", text_color=color.new(color.red, 20),
         text_size=size.small, text_halign=text.align_right, text_valign=text.align_center)
    mid = (gapTop + gapBot) / 2
    ml = line.new(bar_index[2], mid, bar_index, mid,
         color=bearMidColor, style=line.style_dashed)
    array.push(bearBoxes,    b)
    array.push(bearTop,      gapTop)
    array.push(bearBot,      gapBot)
    array.push(bearMidLines, ml)
````
