# Eaglizer Pivot Boxes

- url: https://www.tradingview.com/script/ZlTbKCr4-Eaglizer-Pivot-Boxes/
- type: indicator
- pine_id: PUB;049e226e83244e49b29632eebf134ffc
- version: 1.0

## Description

Most range tools make you drag boxes by hand and then argue with yourself about where the range really starts. This draws the box for you from the market's own swing highs and swing lows, and tells you the moment price closes out of it.

WHAT IT DOES

It confirms swing highs and swing lows using a pivot length you choose. The most recent confirmed swing high becomes the top of the box and the most recent confirmed swing low becomes the bottom. The box then extends to the right while price stays inside it.

When a bar closes above the top, the box turns green and a triangle prints under the bar. When a bar closes below the bottom, the box turns red and a triangle prints above the bar. Every time a new swing is confirmed while price is still inside, a fresh box starts.

WHY BOXES

A range is a decision the market has not made yet. Price is balancing between buyers and sellers. The close that leaves the box is the first honest sign of which side won. I would rather wait for that close than guess early.

HOW I USE IT

I use the box as a map, not a trigger. A breakout close is a reason to look at the chart, check volume, and check the trend on a higher timeframe. A breakout into a wall of resistance is a different trade from a breakout into open space.

I look at the daily and the 4 hour. On very low timeframes the swings are noise and the boxes churn.

SETTINGS

Pivot length, default 5. Higher numbers give fewer, wider boxes. Lower numbers give more, tighter ones. Boxes that ended in a breakout always stay on the chart so you can see how past ranges resolved. You can also choose to keep superseded ranges. All three colors are editable.

ALERTS

Two alert conditions are included, one for a close above the range and one for a close below. Both carry the ticker and the close price.

WHAT THIS IS NOT

This is not a complete trading system. It has no stop, no target, and no position size. It shows you the range and when it broke. Everything after that is on you.

The full system I trade adds an EMA 89, a higher timeframe EMA 34, dual RSI moving averages, a volume filter, and defined stop and target rules. If you want it, the link is on my profile.

DISCLAIMER

This is not financial advice. This indicator is a charting tool for educational purposes only. Trading involves substantial risk of loss and past behavior of any indicator does not guarantee future results. You are responsible for your own decisions.

## Source Code

````pine
//@version=6
indicator("Eaglizer Pivot Boxes", shorttitle="PivotBoxes", overlay=true, max_boxes_count=100, max_labels_count=100)

// INPUTS

grpPivot = "Pivots"
grpViz   = "Display"

pivLen  = input.int(5, "Pivot Length", minval=2, group=grpPivot, tooltip="Bars on each side needed to confirm a swing high or swing low. Default 5.")
keepOld = input.bool(false, "Keep superseded ranges", group=grpViz, tooltip="When a new swing is confirmed, the old range is replaced by a new one. Turn this on to leave the old ranges on the chart. Boxes that ended in a breakout always stay.")

colRange = input.color(color.new(color.gray, 85),  "Active range",   group=grpViz)
colUp    = input.color(color.new(color.green, 75), "Breakout up",    group=grpViz)
colDown  = input.color(color.new(color.red, 75),   "Breakout down",  group=grpViz)

// STATE

var float topP   = na
var float botP   = na
var int   topBar = na
var int   botBar = na
var box   bx     = na
var bool  active = false

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

if not na(ph)
    topP   := ph
    topBar := bar_index - pivLen
if not na(pl)
    botP   := pl
    botBar := bar_index - pivLen

newPivot = not na(ph) or not na(pl)
haveBoth = not na(topP) and not na(botP) and topP > botP
inside   = close <= topP and close >= botP

// A new box starts when a fresh pivot is confirmed and price is still inside the range.
if newPivot and haveBoth and inside
    if active
        box.set_right(bx, bar_index)
        if not keepOld
            box.delete(bx)
    bx := box.new(math.min(topBar, botBar), topP, bar_index, botP, border_color=color.new(color.gray, 40), bgcolor=colRange)
    active := true

breakUp   = false
breakDown = false

if active
    box.set_right(bx, bar_index)
    if close > topP
        box.set_bgcolor(bx, colUp)
        box.set_border_color(bx, color.green)
        active  := false
        breakUp := true
    else if close < botP
        box.set_bgcolor(bx, colDown)
        box.set_border_color(bx, color.red)
        active    := false
        breakDown := true

// PLOTS

plotshape(breakUp,   title="Breakout up",   location=location.belowbar, color=color.green, style=shape.triangleup,   size=size.small)
plotshape(breakDown, title="Breakout down", location=location.abovebar, color=color.red,   style=shape.triangledown, size=size.small)

// ALERTS

alertcondition(breakUp,   title="Range breakout up",   message="Eaglizer Pivot Boxes: closed above the range on {{ticker}} at {{close}}")
alertcondition(breakDown, title="Range breakout down", message="Eaglizer Pivot Boxes: closed below the range on {{ticker}} at {{close}}")
````
