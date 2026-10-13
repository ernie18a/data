<!-- tradingview-pine-id: PUB;49358742f8a14df69161bee1c9329609 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Hindsight Gap - swing levels

Source: https://www.tradingview.com/script/ohmCeQvb-hindsight-gap-swing-levels/

## Description

A swing high is not a swing high until some bars have closed after it. If a script marks the level on the bar it forms, every rule that references that level has already seen the future.

This draws both versions of every pivot. The dotted segment covers the window where the level exists only in hindsight. The solid segment starts on the bar the swing is confirmed, which is the first bar you could have acted on. The shaded box is that blind window.

The table measures what the gap costs. On BTCUSDT 15m with swing length 5 it counted 2834 swings and an average move of 0.36% between formation and confirmation. In ATR terms that is 1.14, with a worst single gap of 5.5%. Those numbers move with symbol and timeframe, and they are never zero.

Swing length sets both sides of the pivot, so confirmation always lags by that many bars. Nothing repaints: every line and box is created on the confirmation bar and is never moved afterwards.

Use it as a check on your own scripts. If a level shows up in your logic before the solid segment starts, that part of your backtest is reading the future.

---

## Source Code

````pine
//@version=6
// A swing high is not a swing high until some bars have closed after it.
// Scripts that mark the level on the bar it forms are reading the future:
// live, that level does not exist yet. This draws both versions so the gap
// between them is visible, and measures how much of the move is already gone
// by the time the level is confirmed.
indicator("Hindsight Gap - swing levels", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

len       = input.int(5,    "Swing length",              minval = 1)
shadeGap  = input.bool(true,"Shade the blind window")
showStats = input.bool(true,"Show stats table")

ph  = ta.pivothigh(high, len, len)
pl  = ta.pivotlow(low, len, len)
atr = ta.atr(14)

gapHigh = ta.highest(high, len + 1)
gapLow  = ta.lowest(low, len + 1)

var int   swings    = 0
var float travelPc  = 0.0
var float travelAtr = 0.0
var float worstPc   = 0.0

// One confirmed pivot: dotted where a hindsight backtest thinks it knows the
// level, solid from the bar you could actually act on.
drawPivot(float level, bool isHigh, float boxTop, float boxBot) =>
    pivotBar = bar_index - len
    col      = isHigh ? color.red : color.teal
    line.new(pivotBar, level, bar_index, level, color = col,
         style = line.style_dotted, width = 1)
    line.new(bar_index, level, bar_index + len, level, color = col, width = 2)
    if shadeGap
        box.new(pivotBar, boxTop, bar_index, boxBot,
             border_width = 0, bgcolor = color.new(col, 88))

if not na(ph)
    drawPivot(ph, true, math.max(ph, gapHigh), math.min(ph, gapLow))

if not na(pl)
    drawPivot(pl, false, math.max(pl, gapHigh), math.min(pl, gapLow))

// The cost of waiting for confirmation: the distance price covered between the
// bar the swing formed on and the bar it became knowable.
if not na(ph) or not na(pl)
    ref = close[len]
    if ref > 0 and atr > 0
        movePc     = math.abs(close - ref) / ref * 100.0
        swings    += 1
        travelPc  += movePc
        travelAtr += math.abs(close - ref) / atr
        worstPc   := math.max(worstPc, movePc)

var table t = table.new(position.top_right, 2, 5, border_width = 1)

if showStats and barstate.islast
    avgPc  = swings > 0 ? travelPc  / swings : 0.0
    avgAtr = swings > 0 ? travelAtr / swings : 0.0
    table.cell(t, 0, 0, "Hindsight gap",  text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(t, 1, 0, str.tostring(len) + " bars", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(t, 0, 1, "Swings")
    table.cell(t, 1, 1, str.tostring(swings))
    table.cell(t, 0, 2, "Avg move while blind")
    table.cell(t, 1, 2, str.tostring(avgPc, "#.##") + " %")
    table.cell(t, 0, 3, "Same, in ATR")
    table.cell(t, 1, 3, str.tostring(avgAtr, "#.##"))
    table.cell(t, 0, 4, "Worst single gap")
    table.cell(t, 1, 4, str.tostring(worstPc, "#.##") + " %")
````
