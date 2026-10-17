# Fair Value Gap - Dice Trades

- url: https://www.tradingview.com/script/UpoNx20w-Fair-Value-Gap-Dice-Trades/
- type: indicator
- pine_id: PUB;8de251ddeee945ad8a20b5f6afe7dc13
- version: 1.0

## Description

A Fair Value Gap is a 3-candle imbalance pattern where price moves so aggressively in one direction that it leaves an unfilled gap on the chart.
How it works:

Bullish FVG — the low of the current candle is higher than the high of the candle 2 bars ago. Price moved up too fast, leaving a gap below that often gets revisited.
Bearish FVG — the high of the current candle is lower than the low of the candle 2 bars ago. Price moved down too fast, leaving a gap above.

These imbalance zones act as magnets — price tends to return and fill them before continuing its move. Traders use FVGs as entry zones, take profit targets, or directional confirmation.
Settings:

Toggle bullish and bearish FVGs independently
Optional mitigation mode — automatically removes a FVG once price returns to its 50% level

Works on any market and any timeframe.

## Source Code

````pine
//@version=6
indicator("Fair Value Gaps", overlay=true, max_boxes_count=500)

// ─── INPUTS ───
fvg_col     = input.color(color.new(#191919, 80), "Couleur FVG")
fvg_border  = input.color(color.new(#191919, 60), "Bordure FVG")
show_bull   = input.bool(true, "Afficher FVG Haussiers")
show_bear   = input.bool(true, "Afficher FVG Baissiers")
mitigate    = input.bool(true, "Supprimer FVG mitiges")

// ─── DETECTION ───
// FVG Haussier : low[0] > high[2]
// FVG Baissier : high[0] < low[2]
bull_fvg = show_bull and low  > high[2]
bear_fvg = show_bear and high < low[2]

var box[] bull_boxes = array.new_box()
var box[] bear_boxes = array.new_box()

if bull_fvg
    b = box.new(bar_index - 2, low, bar_index + 50, high[2],
                border_color=fvg_border, border_width=1, bgcolor=fvg_col)
    array.push(bull_boxes, b)

if bear_fvg
    b = box.new(bar_index - 2, low[2], bar_index + 50, high,
                border_color=fvg_border, border_width=1, bgcolor=fvg_col)
    array.push(bear_boxes, b)

// ─── SUPPRESSION FVG MITIGES ───
if mitigate
    if array.size(bull_boxes) > 0
        for i = array.size(bull_boxes) - 1 to 0
            b   = array.get(bull_boxes, i)
            mid = box.get_bottom(b) + (box.get_top(b) - box.get_bottom(b)) * 0.5
            if low <= mid
                box.delete(b)
                array.remove(bull_boxes, i)

    if array.size(bear_boxes) > 0
        for i = array.size(bear_boxes) - 1 to 0
            b   = array.get(bear_boxes, i)
            mid = box.get_bottom(b) + (box.get_top(b) - box.get_bottom(b)) * 0.5
            if high >= mid
                box.delete(b)
                array.remove(bear_boxes, i)

// ─── ALERTES ───
alertcondition(bull_fvg, "FVG Haussier", "Fair Value Gap haussier detecte")
alertcondition(bear_fvg, "FVG Baissier", "Fair Value Gap baissier detecte")
````
