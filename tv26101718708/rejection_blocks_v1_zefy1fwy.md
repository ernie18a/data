# Rejection Blocks v1

- url: https://www.tradingview.com/script/zefy1Fwy-Rejection-Blocks-v1/
- type: indicator
- pine_id: PUB;2e03316cccb1492d9f837eb2daf22ad8
- version: 1.0

## Description

shows rejection blocks on any time frame. Helps with bottom and top ticking

## Source Code

````pine
//@version=5
indicator("ICT Rejection Blocks", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────
grp1 = "Rejection Block Settings"
wickMultiplier   = input.float(2.0,  "Wick-to-Body Ratio",      minval=1.0, step=0.1, group=grp1, tooltip="Minimum wick size relative to candle body to qualify as a rejection")
wickPercent      = input.float(60.0, "Min Wick % of Range",     minval=10,  maxval=99, step=1.0, group=grp1, tooltip="Minimum wick as % of total candle range")
mitigateBlocks   = input.bool(true,  "Mitigate Blocks",         group=grp1, tooltip="Remove block when price closes beyond it (block is used)")
extendBars       = input.int(50,     "Extend Boxes (bars)",     minval=1, maxval=500, group=grp1)
showLabels       = input.bool(true,  "Show Labels",             group=grp1)

grp2 = "Bullish Rejection Block (Demand)"
bullColor        = input.color(color.new(#00e5ff, 75), "Fill Color",   group=grp2)
bullBorderColor  = input.color(color.new(#00e5ff, 20), "Border Color", group=grp2)

grp3 = "Bearish Rejection Block (Supply)"
bearColor        = input.color(color.new(#ff1744, 75), "Fill Color",   group=grp3)
bearBorderColor  = input.color(color.new(#ff1744, 20), "Border Color", group=grp3)

grp4 = "Mitigated Blocks"
showMitigated    = input.bool(false, "Show Mitigated Blocks",  group=grp4)
mitColor         = input.color(color.new(#888888, 85), "Mitigated Fill", group=grp4)
mitBorderColor   = input.color(color.new(#888888, 60), "Mitigated Border", group=grp4)

// ─────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────
candleRange  = high - low
bodyTop      = math.max(open, close)
bodyBot      = math.min(open, close)
bodySize     = bodyTop - bodyBot
upperWick    = high - bodyTop
lowerWick    = bodyBot - low

bodySize_  = bodySize == 0 ? 0.0001 : bodySize
range_     = candleRange == 0 ? 0.0001 : candleRange

isBullRej = (lowerWick / bodySize_ >= wickMultiplier) and
             (lowerWick / range_ * 100 >= wickPercent)

isBearRej = (upperWick / bodySize_ >= wickMultiplier) and
             (upperWick / range_ * 100 >= wickPercent)

// ─────────────────────────────────────────────
// BOX ARRAYS
// ─────────────────────────────────────────────
var box[]   bullBoxes = array.new_box()
var box[]   bearBoxes = array.new_box()
var bool[]  bullMit   = array.new_bool()
var bool[]  bearMit   = array.new_bool()

// ─────────────────────────────────────────────
// DRAW REJECTION BLOCKS
// ─────────────────────────────────────────────
if isBullRej
    b = box.new(
         left         = bar_index,
         top          = bodyTop,
         right        = bar_index + extendBars,
         bottom       = bodyBot,
         bgcolor      = bullColor,
         border_color = bullBorderColor,
         border_width = 1)
    array.push(bullBoxes, b)
    array.push(bullMit, false)
    if showLabels
        label.new(bar_index, bodyBot,
             text      = "RB",
             color     = color.new(#00e5ff, 30),
             textcolor = color.white,
             style     = label.style_label_up,
             size      = size.small)

if isBearRej
    b = box.new(
         left         = bar_index,
         top          = bodyTop,
         right        = bar_index + extendBars,
         bottom       = bodyBot,
         bgcolor      = bearColor,
         border_color = bearBorderColor,
         border_width = 1)
    array.push(bearBoxes, b)
    array.push(bearMit, false)
    if showLabels
        label.new(bar_index, bodyTop,
             text      = "RB",
             color     = color.new(#ff1744, 30),
             textcolor = color.white,
             style     = label.style_label_down,
             size      = size.small)

// ─────────────────────────────────────────────
// EXTEND & MITIGATE BOXES EACH BAR
// ─────────────────────────────────────────────
if array.size(bullBoxes) > 0
    for i = 0 to array.size(bullBoxes) - 1
        b   = array.get(bullBoxes, i)
        mit = array.get(bullMit, i)
        if not mit
            box.set_right(b, bar_index + extendBars)
            if mitigateBlocks and close < box.get_bottom(b)
                array.set(bullMit, i, true)
                if showMitigated
                    box.set_bgcolor(b, mitColor)
                    box.set_border_color(b, mitBorderColor)
                else
                    box.delete(b)

if array.size(bearBoxes) > 0
    for i = 0 to array.size(bearBoxes) - 1
        b   = array.get(bearBoxes, i)
        mit = array.get(bearMit, i)
        if not mit
            box.set_right(b, bar_index + extendBars)
            if mitigateBlocks and close > box.get_top(b)
                array.set(bearMit, i, true)
                if showMitigated
                    box.set_bgcolor(b, mitColor)
                    box.set_border_color(b, mitBorderColor)
                else
                    box.delete(b)

// ─────────────────────────────────────────────
// SIGNAL PLOTS
// ─────────────────────────────────────────────
plotshape(isBullRej, title="Bullish Rejection", style=shape.triangleup,
          location=location.belowbar, color=#00e5ff, size=size.tiny)
plotshape(isBearRej, title="Bearish Rejection", style=shape.triangledown,
          location=location.abovebar, color=#ff1744, size=size.tiny)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(isBullRej, title="Bullish Rejection Block Formed",
     message="Bullish Rejection Block detected on {{ticker}} - {{interval}}")
alertcondition(isBearRej, title="Bearish Rejection Block Formed",
     message="Bearish Rejection Block detected on {{ticker}} - {{interval}}")
````
