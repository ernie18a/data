<!-- tradingview-pine-id: PUB;67a27ad895dc4784b96ea74df9f070ed -->
<!-- tradingviewscripts-format: 1 -->
# P3 Candle Grouping

Source: https://www.tradingview.com/script/9PztXfwY-P3-Candle-Grouping/

## Description

P3 Candle Grouping — draws boxes around candles that trade within a shared range, making consolidation and balance visible at a glance.

A group holds as long as price stays inside the box's high/low. Wicks poking beyond the edge don't break the group — the boundary ratchets out to include them. A group ends only when a candle closes past the boundary by a set tick buffer (default 2 ticks), and that breakout bar seeds the next group. Both the upper and lower boundaries ratchet independently, and the logic runs on confirmed bars only, so boxes don't repaint.

Teal boxes closed bullish, maroon closed bearish, and the yellow box is the current group still forming live.

Settings:

Close must clear boundary by N ticks — how far past the edge a candle must close to end a group. Higher values give fewer, cleaner groups.
Keep last N group boxes — how many completed boxes remain on the chart.

Works on any symbol or timeframe; built with NQ/MNQ in mind. Source is open — feel free to study or build on the grouping logic.

---

## Source Code

````pine
//@version=6
indicator("P3 Candle Grouping", overlay=true, max_boxes_count=500, max_lines_count=500)

//======================================================================
// LAYER 1 — CANDLE GROUPING (foundation for structure)
// Johnnie's rule:
//   * Bars group into one "grouped candle" while price stays within the
//     group's high/low. Wicks beyond the boundary do NOT end the group —
//     they RATCHET the boundary out to the furthest wick.
//   * The group ends only when a bar CLOSES >= N ticks beyond the current
//     (ratcheted) high or low.
//   * On breakout, a NEW group starts from the breakout bar; its initial
//     high/low are that bar's high/low.
// Both boundaries ratchet independently; a close beyond EITHER ends it.
// Acts on CONFIRMED bars (non-repainting).
//======================================================================

grp       = "Candle Grouping"
tickBreak = input.int(2, "Close must clear boundary by N ticks", minval=1, maxval=20, group=grp)
showBoxes = input.bool(true, "Draw grouped-candle boxes", group=grp)
upBox     = input.color(color.new(color.teal, 80), "Bull group (close > open)", group=grp)
dnBox     = input.color(color.new(color.maroon, 80), "Bear group (close < open)", group=grp)
brdCol    = input.color(color.gray, "Border", group=grp)
keepN     = input.int(60, "Keep last N group boxes", minval=1, maxval=400, group=grp)

tick = syminfo.mintick
brk  = tickBreak * tick

// ---- current group state ----
var float gHigh  = na      // ratcheted group high
var float gLow   = na      // ratcheted group low
var int   gStart = na      // group start bar time
var float gOpen  = na      // open of the group (first bar's open)

var box[] gBoxes = array.new_box()

f_commitBox(_t1, _t2, _hi, _lo, _open, _close) =>
    if showBoxes
        col = _close >= _open ? upBox : dnBox
        bx = box.new(_t1, _hi, _t2, _lo, xloc=xloc.bar_time, border_color=brdCol, bgcolor=col, border_width=1)
        array.push(gBoxes, bx)
        while array.size(gBoxes) > keepN
            box.delete(array.shift(gBoxes))

if barstate.isconfirmed
    if na(gHigh)
        // seed first group
        gHigh  := high
        gLow   := low
        gStart := time
        gOpen  := open
    else
        bool closedAbove = close >= gHigh + brk
        bool closedBelow = close <= gLow - brk

        if closedAbove or closedBelow
            // current group ends on the PREVIOUS bar; commit it, then this
            // breakout bar seeds the next group
            f_commitBox(gStart, time[1], gHigh, gLow, gOpen, close[1])
            gHigh  := high
            gLow   := low
            gStart := time
            gOpen  := open
        else
            // still inside the group: ratchet boundaries out to any wicks
            gHigh := math.max(gHigh, high)
            gLow  := math.min(gLow, low)

    // live box for the forming (still-open) group so you can see it build
    var box liveBox = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=color.yellow, bgcolor=color.new(color.yellow, 92), border_width=1)
    if showBoxes and not na(gStart)
        box.set_lefttop(liveBox, gStart, gHigh)
        box.set_rightbottom(liveBox, time, gLow)
    else
        box.set_lefttop(liveBox, na, na)
        box.set_rightbottom(liveBox, na, na)

//======================================================================
// ALERTS
//======================================================================
alertcondition(barstate.isconfirmed and not na(gHigh[1]) and (close >= gHigh[1] + brk or close <= gLow[1] - brk), title="P3 Grouping - New Group", message="P3: new grouped candle on {{ticker}}")
````
