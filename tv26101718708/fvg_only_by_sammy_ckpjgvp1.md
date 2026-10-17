# FVG only by Sammy

- url: https://www.tradingview.com/script/CkpJgVp1-FVG-only-by-Sammy/
- type: indicator
- pine_id: PUB;fd389e3529c4459794b538082d47845e
- version: 5.0

## Description

A clean and simple Fair Value Gap (FVG) indicator designed to identify three-candle price imbalances without unnecessary chart clutter.

Key Features:

[list]
[*]Detects bullish and bearish FVGs using the traditional three-candle gap structure.
[*]
[*]Requires at least 50% of the third candle's body to overlap the second candle's high-to-low range.
[*]
[*]Adjustable body overlap percentage to customise FVG detection.
[*]
[*]Automatically extends FVG zones until price revisits them or the extension limit is reached.
[*]
[*]Preserves historical FVG zones for backtesting and chart analysis.
[*]
[*]Works across all markets and timeframes.
[*]
[*]Note: The 50% body overlap requirement is a custom filter, not a standard FVG rule.
[*]
[*]Designed for traders who prefer clean charts and price action analysis.
[/list]

## Source Code

````pine
//@version=6
indicator("FVG only", overlay=true, max_boxes_count=500)

// ===== SETTINGS =====
maxZones = input.int(450, "Historical FVGs to Keep", minval=10, maxval=500)
minOverlap = input.float(50.0, "Minimum Candle 3 Body Overlap (%)", minval=0, maxval=100, step=5)
gold = input.color(color.rgb(212, 160, 23), "FVG Colour")

// ===== CANDLE 3 BODY =====
bodyTop = math.max(open, close)
bodyBottom = math.min(open, close)
bodySize = bodyTop - bodyBottom

// ===== BODY OVERLAP WITH CANDLE 2 =====
overlapTop = math.min(bodyTop, high[1])
overlapBottom = math.max(bodyBottom, low[1])
overlapSize = math.max(0.0, overlapTop - overlapBottom)

overlapPercent = bodySize > 0 ? (overlapSize / bodySize) * 100.0 : 0.0
validBodyOverlap = overlapPercent >= minOverlap

// ===== THREE-CANDLE FVG DETECTION =====
bullFVG = high[2] < low and validBodyOverlap
bearFVG = low[2] > high and validBodyOverlap

// ===== BOX STORAGE =====
var array<box> zones = array.new<box>()
var array<int> createdBars = array.new<int>()
var array<bool> active = array.new<bool>()

// ===== CREATE FVG BOX =====
f_addFVG(int leftBar, float top, float bottom) =>
    if not na(top) and not na(bottom) and top > bottom
        b = box.new(
             left=leftBar,
             top=top,
             right=bar_index,
             bottom=bottom,
             border_color=color.new(gold, 20),
             bgcolor=color.new(gold, 88))

        array.push(zones, b)
        array.push(createdBars, bar_index)
        array.push(active, true)

        while array.size(zones) > maxZones
            box.delete(array.shift(zones))
            array.shift(createdBars)
            array.shift(active)

// ===== EXTEND UNTIL FIRST WICK TOUCH =====
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        if array.get(active, i)
            b = array.get(zones, i)
            born = array.get(createdBars, i)

            if bar_index > born
                tapped = low <= box.get_top(b) and high >= box.get_bottom(b)

                box.set_right(b, bar_index)

                if tapped
                    array.set(active, i, false)

// ===== DRAW FVGs AFTER CANDLE 3 CLOSES =====
if barstate.isconfirmed
    if bullFVG
        f_addFVG(bar_index - 2, low, high[2])

    if bearFVG
        f_addFVG(bar_index - 2, low[2], high)
````
