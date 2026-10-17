# FVG Alert Indicator

- url: https://www.tradingview.com/script/xq6iruqb-FVG-Alert-Indicator/
- type: indicator
- pine_id: PUB;50d269b25c75475cae7f28f896521f0c
- version: 1.0

## Description

FVG Alert Indicator – Confirmed Fair Value Gaps with Auto-Fill Cleanup
This indicator detects and marks Fair Value Gaps (FVGs) — the price imbalance left when a sharp move causes a gap between the high of one candle and the low of a candle two bars later (or vice versa for bearish gaps).
Key features:

Confirmed signals only — Unlike many FVG scripts, this indicator waits for the third candle to fully close before marking a gap as "formed." This eliminates false/early alerts that fire mid-bar before the pattern is actually complete.
Clean visual zones — Each FVG is plotted as a borderless, semi-transparent fill box so the zone is easy to read without cluttering your chart with extra outlines.
Auto-fill removal — Once price trades back through a gap and fills it, the zone is automatically deleted from the chart. Only live, unfilled FVGs remain visible, so you're always looking at gaps that are still relevant.
Minimal markers — Small, clean arrow icons mark exactly where each bullish or bearish FVG formed, without the bulkier triangle shapes used by default.
Built-in alerts — Set alerts for bullish or bearish FVG formation and get notified the moment a gap is confirmed — no more, no less.

How it works:

A bullish FVG forms when the low of the current candle is above the high of the candle two bars back, leaving an unfilled gap below price. A bearish FVG is the mirror case. This script tracks every gap individually, extending the zone bar-by-bar until price returns to fill it, at which point the zone is removed.
Best used for:

Identifying imbalance zones that price is statistically likely to revisit, spotting potential support/resistance from gap fills, and combining with your own trend or structure analysis for entries/exits.

## Source Code

````pine
//@version=6
indicator('FVG Alert Indicator', overlay = true, max_boxes_count = 500)

// ---------------- Colors ----------------
bullColor = color.new(color.lime, 0)
bearColor = color.new(color.red, 0)
bullFillColor = color.new(color.green, 80)
bearFillColor = color.new(color.red, 80)

// ---------------- FVG detection (only once the 3rd candle has CLOSED) ----------------
bullFVG = barstate.isconfirmed and low > high[2]
bearFVG = barstate.isconfirmed and high < low[2]

// ---------------- Storage for active (unfilled) FVG zones ----------------
var array<box> bullBoxes = array.new_box()
var array<float> bullFillLevel = array.new_float() // bullish gap is filled once price trades DOWN to this level
var array<box> bearBoxes = array.new_box()
var array<float> bearFillLevel = array.new_float() // bearish gap is filled once price trades UP to this level

// ---------------- Remove FVGs that have been completely filled ----------------
if barstate.isconfirmed
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0 by 1
            if low <= array.get(bullFillLevel, i)
                box.delete(array.get(bullBoxes, i))
                array.remove(bullBoxes, i)
                array.remove(bullFillLevel, i)

    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0 by 1
            if high >= array.get(bearFillLevel, i)
                box.delete(array.get(bearBoxes, i))
                array.remove(bearBoxes, i)
                array.remove(bearFillLevel, i)

// ---------------- Draw new FVG zones: fill only, no border ----------------
if bullFVG
    newBox = box.new(left = bar_index - 2, top = low, right = bar_index, bottom = high[2], border_color = na, bgcolor = bullFillColor)
    array.push(bullBoxes, newBox)
    array.push(bullFillLevel, high[2])

if bearFVG
    newBox = box.new(left = bar_index - 2, top = low[2], right = bar_index, bottom = high, border_color = na, bgcolor = bearFillColor)
    array.push(bearBoxes, newBox)
    array.push(bearFillLevel, low[2])

// ---------------- Stretch unfilled zones forward until they get filled ----------------
if barstate.isconfirmed
    if array.size(bullBoxes) > 0
        for i = 0 to array.size(bullBoxes) - 1 by 1
            box.set_right(array.get(bullBoxes, i), bar_index)
    if array.size(bearBoxes) > 0
        for i = 0 to array.size(bearBoxes) - 1 by 1
            box.set_right(array.get(bearBoxes, i), bar_index)

// ---------------- Clean signal markers: fill only, no outline, smaller ----------------
plotshape(bullFVG, title = 'Bullish FVG', location = location.belowbar, color = bullColor, style = shape.triangleup, size = size.tiny)
plotshape(bearFVG, title = 'Bearish FVG', location = location.abovebar, color = bearColor, style = shape.triangledown, size = size.tiny)

// ---------------- Alerts (only fire after the 3rd candle closes) ----------------
alertcondition(bullFVG, title = 'Bullish FVG Formed', message = 'Bullish FVG formed on {{ticker}} {{interval}}')
alertcondition(bearFVG, title = 'Bearish FVG Formed', message = 'Bearish FVG formed on {{ticker}} {{interval}}')
````
