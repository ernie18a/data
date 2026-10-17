# Swing Indicator

- url: https://www.tradingview.com/script/GLtUHR1l-Swing-Indicator/
- type: indicator
- pine_id: PUB;34b21e2242794e809e3969d8bb35c024
- version: 1.0

## Description

Plots a clean zigzag line connecting significant swing highs and lows, with each segment drawn as price confirms a pivot reversal. Pivot points are detected using configurable left/right bar lookback periods — a swing high requires a peak with the specified number of lower bars on each side, and vice versa for swing lows. Consecutive pivots in the same direction are merged, keeping only the more extreme point, so the line always reflects the cleanest swing structure.
Layered on top is a Gann Three Day Rule signal system. After each confirmed swing high, the indicator tracks the running high and counts consecutive lower closes — three in a row prints a 3↓ sell signal. After each confirmed swing low, it tracks the running low and counts consecutive higher closes — three in a row prints a 3↑ buy signal. New all-time highs and lows are also treated as significant pivots, resetting the signal tracker accordingly.

## Source Code

````pine
//@version=6
indicator("Swing Indicator", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
leftBars      = input.int(5,   "Left Bars",  minval=1, maxval=50, group="Detection")
rightBars     = input.int(5,   "Right Bars", minval=1, maxval=50, group="Detection")
upColor       = input.color(color.new(color.orange, 0), "Up Color",   group="Style")
downColor     = input.color(color.new(color.orange, 0), "Down Color", group="Style")
lineWidth     = input.int(2,   "Line Width", minval=1, maxval=4,  group="Style")

// ── Three Day Rule inputs ─────────────────────────────────────────────────────
showThreeDay  = input.bool(true, "Show Three Day Rule", group="Three Day Rule")
buySignalCol  = input.color(color.new(color.lime,   0), "Buy Signal Color",  group="Three Day Rule")
sellSignalCol = input.color(color.new(color.orange, 0), "Sell Signal Color", group="Three Day Rule")

// ── Pivot detection ───────────────────────────────────────────────────────────
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low,  leftBars, rightBars)

// ── State ─────────────────────────────────────────────────────────────────────
var float curPrice = na
var int   curBar   = na
var int   curDir   = 0
var line  curLine  = na

// Gann 3-Day Rule state
var int   gMode      = 0
var float gHigh      = na
var int   gHighBar   = na
var int   gDownCnt   = 0
var bool  gSellFired = false

var float gLow       = na
var int   gLowBar    = na
var int   gUpCnt     = 0
var bool  gBuyFired  = false

// All-time extremes
var float athHigh = na
var float atlLow  = na

// v6: explicit != na checks instead of relying on implicit bool casting
isNewATH = not na(athHigh) and high > athHigh
isNewATL = not na(atlLow)  and low  < atlLow

if na(athHigh) or high > athHigh
    athHigh := high
if na(atlLow) or low < atlLow
    atlLow := low

pivotBar = bar_index - rightBars

// ── High pivot ────────────────────────────────────────────────────────────────
if not na(ph)
    if curDir == 1
        if ph > curPrice
            if not na(curLine)
                line.set_x2(curLine, pivotBar)
                line.set_y2(curLine, ph)
            curPrice := ph
            curBar   := pivotBar
    else
        if not na(curPrice)
            curLine := line.new(curBar, curPrice, pivotBar, ph, color=upColor, width=lineWidth)
        curDir    := 1
        curPrice  := ph
        curBar    := pivotBar
        gMode     := 1
        gLow      := na
        gLowBar   := na
        gUpCnt    := 0
        gBuyFired := false

// ── Low pivot ─────────────────────────────────────────────────────────────────
if not na(pl)
    if curDir == -1
        if pl < curPrice
            if not na(curLine)
                line.set_x2(curLine, pivotBar)
                line.set_y2(curLine, pl)
            curPrice := pl
            curBar   := pivotBar
    else
        if not na(curPrice)
            curLine := line.new(curBar, curPrice, pivotBar, pl, color=downColor, width=lineWidth)
        curDir     := -1
        curPrice   := pl
        curBar     := pivotBar
        gMode      := -1
        gHigh      := na
        gHighBar   := na
        gDownCnt   := 0
        gSellFired := false

// ── Gann 3-Day Rule ───────────────────────────────────────────────────────────
if showThreeDay
    if isNewATH
        gMode      := -1
        gHigh      := high
        gHighBar   := bar_index
        gDownCnt   := 0
        gSellFired := false
    if isNewATL
        gMode     := 1
        gLow      := low
        gLowBar   := bar_index
        gUpCnt    := 0
        gBuyFired := false

    if gMode == -1
        if na(gHigh) or high > gHigh
            gHigh      := high
            gHighBar   := bar_index
            gDownCnt   := 0
            gSellFired := false
        else
            // v6: explicit bool expression instead of implicit int-to-bool
            gDownCnt := close < close[1] ? gDownCnt + 1 : 0
            if gDownCnt >= 3 and not gSellFired
                label.new(bar_index, high, "3↓", style=label.style_label_down, color=sellSignalCol, textcolor=color.white, size=size.normal)
                gSellFired := true
    else if gMode == 1
        if na(gLow) or low < gLow
            gLow      := low
            gLowBar   := bar_index
            gUpCnt    := 0
            gBuyFired := false
        else
            // v6: explicit bool expression instead of implicit int-to-bool
            gUpCnt := close > close[1] ? gUpCnt + 1 : 0
            if gUpCnt >= 3 and not gBuyFired
                label.new(bar_index, low, "3↑", style=label.style_label_up, color=buySignalCol, textcolor=color.white, size=size.normal)
                gBuyFired := true
````
