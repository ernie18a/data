# Darvas Box Theory

- url: https://www.tradingview.com/script/W2a3PSO7-Darvas-Box-Theory/
- type: indicator
- pine_id: PUB;1bd9129be1d24e76b44559ce1d51e6c5
- version: 1.0

## Description

[b]How it works:
[/b]
[b]Spot a new high[/b] — price makes a fresh high over your lookback window (e.g., 20 bars).
[b]Wait for confirmation[/b] — if price stays below that high for N consecutive bars (default 3), the high becomes a locked-in box top.
[b]Set the bottom[/b] — the lowest low during that confirmation window becomes the box bottom.
[b]Trade the breakout[/b] — a close above the top = bullish breakout (buy signal), a close below the bottom = breakdown (exit/short signal). Either way, the box closes and the search for the next one begins.

## Source Code

````pine
//@version=6
indicator("Darvas Box Theory", shorttitle="Darvas Box", overlay=true, max_boxes_count=500, max_labels_count=500)

// ============================= Inputs =============================
lookback       = input.int(20, "New High Lookback (bars)", minval=5, tooltip="Bars used to detect a fresh pivot high. Classic Darvas used 52-week highs on daily charts (~252); shorter lookbacks find boxes more often.")
confirmBars    = input.int(3, "Confirmation Bars", minval=1, tooltip="Consecutive bars price must hold below the pivot high before the box top is confirmed.")
extendBoxes    = input.bool(true, "Extend Active Box to Current Bar")
showSignals    = input.bool(true, "Show Breakout / Breakdown Labels")
maxHistoryBoxes = input.int(50, "Max Boxes to Keep on Chart", minval=1, maxval=490, tooltip="Oldest boxes are removed once this limit is reached (TradingView caps total drawings per indicator).")

boxBorderColor = input.color(color.new(#2962FF, 0), "Box Border", group="Style")
boxFillColor   = input.color(color.new(#2962FF, 85), "Box Fill", group="Style")
buyColor       = input.color(color.new(#089981, 0), "Breakout Color", group="Style")
sellColor      = input.color(color.new(#F23645, 0), "Breakdown Color", group="Style")

// ============================= State ===============================
var float pendingHigh    = na
var int   pendingHighBar = na
var int   barsSinceHigh  = 0
var float pendingLow     = na

var float boxTop    = na
var float boxBottom = na
var bool  boxActive = false
var box   activeBox = na
var box[] boxHistory = array.new<box>()

// ===================== Step 1: detect pivot high =====================
isNewHigh = high >= ta.highest(high, lookback)

if isNewHigh
    pendingHigh    := high
    pendingHighBar := bar_index
    barsSinceHigh  := 0
    pendingLow     := low
else if not na(pendingHigh)
    barsSinceHigh += 1
    pendingLow := math.min(pendingLow, low)
    // top violated before confirmation -> discard, wait for the next pivot high
    if high > pendingHigh
        pendingHigh := na

// =================== Step 2: confirm box top/bottom ===================
if not na(pendingHigh) and not boxActive and barsSinceHigh >= confirmBars
    boxTop    := pendingHigh
    boxBottom := pendingLow
    boxActive := true
    // keep the just-finished box in history instead of deleting it
    if not na(activeBox)
        box.set_bgcolor(activeBox, color.new(boxBorderColor, 95)) // dim the box now that it's history
        array.push(boxHistory, activeBox)
        if array.size(boxHistory) > maxHistoryBoxes
            box.delete(array.shift(boxHistory))
    activeBox := box.new(pendingHighBar, boxTop, bar_index, boxBottom,
                 border_color=boxBorderColor, bgcolor=boxFillColor, border_width=1)
    pendingHigh := na

// =============== Step 3: manage active box / breakouts ================
bullishBreakout  = false
bearishBreakdown = false

if boxActive
    if extendBoxes and not na(activeBox)
        box.set_right(activeBox, bar_index)
    if close > boxTop
        bullishBreakout := true
        boxActive := false
    else if close < boxBottom
        bearishBreakdown := true
        boxActive := false

if bullishBreakout and showSignals
    label.new(bar_index, low, "▲", style=label.style_label_up, color=buyColor, textcolor=color.white, size=size.small)
if bearishBreakdown and showSignals
    label.new(bar_index, high, "▼", style=label.style_label_down, color=sellColor, textcolor=color.white, size=size.small)

alertcondition(bullishBreakout, title="Darvas Box Bullish Breakout", message="Price broke above the Darvas Box top")
alertcondition(bearishBreakdown, title="Darvas Box Bearish Breakdown", message="Price broke below the Darvas Box bottom")

plot(boxActive ? boxTop : na, title="Box Top", color=boxBorderColor, style=plot.style_linebr, linewidth=1)
plot(boxActive ? boxBottom : na, title="Box Bottom", color=boxBorderColor, style=plot.style_linebr, linewidth=1)
````
