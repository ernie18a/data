# DR Partials

- url: https://www.tradingview.com/script/bknzMHAW-DR-Partials/
- type: indicator
- pine_id: PUB;77d678c9d2304bfeb258eb10e049c4a0
- version: 1.0

## Description

this is a script for seeing price action for each seasion

## Source Code

````pine
//@version=6
indicator("DR Partials + D Seq", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────
//  HELPER FUNCTION — builds one box per session
// ─────────────────────────────────────────────
// Returns [sessionHigh, sessionLow, activeBox, activeLabel]
// Called once per box group inside the main loop.

// ── BOX 1 : 85% Partial  (15:00 – 03:00 NY) ──────────────────────────────
var GRP_A = "📦 Box 1 — 85% Partial"
box1_on          = input.bool(true,  "Enable",          group = GRP_A, inline = "b1h")
box1_labelPos    = input.string("Above", "Label Position", options = ["Above", "Inside"], group = GRP_A)
box1_startHour   = input.int(15, "Start H", minval = 0, maxval = 23, group = GRP_A, inline = "b1t")
box1_startMin    = input.int(0,  "Start M", minval = 0, maxval = 59, group = GRP_A, inline = "b1t")
box1_endHour     = input.int(3,  "End H",   minval = 0, maxval = 23, group = GRP_A, inline = "b1t")
box1_endMin      = input.int(0,  "End M",   minval = 0, maxval = 59, group = GRP_A, inline = "b1t")
box1_bg          = input.color(color.new(#3a3a8c, 75), "Background", group = GRP_A)
box1_border      = input.color(color.new(#6699ff, 30), "Border",     group = GRP_A)
box1_bwidth      = input.int(1, "Border Width", minval = 1, maxval = 4, group = GRP_A)
box1_label       = input.string("85% Partial", "Label Text", group = GRP_A)
box1_labelCol    = input.color(color.new(#aabbff, 0), "Label Color", group = GRP_A)

// ── BOX 2 : 60% Partial  (18:30 – 02:00 NY) ──────────────────────────────
var GRP_B = "📦 Box 2 — 60% Partial"
box2_on          = input.bool(true,  "Enable",          group = GRP_B, inline = "b2h")
box2_labelPos    = input.string("Above", "Label Position", options = ["Above", "Inside"], group = GRP_B)
box2_startHour   = input.int(18, "Start H", minval = 0, maxval = 23, group = GRP_B, inline = "b2t")
box2_startMin    = input.int(30, "Start M", minval = 0, maxval = 59, group = GRP_B, inline = "b2t")
box2_endHour     = input.int(2,  "End H",   minval = 0, maxval = 23, group = GRP_B, inline = "b2t")
box2_endMin      = input.int(0,  "End M",   minval = 0, maxval = 59, group = GRP_B, inline = "b2t")
box2_bg          = input.color(color.new(#1a3a5c, 75), "Background", group = GRP_B)
box2_border      = input.color(color.new(#44aaff, 30), "Border",     group = GRP_B)
box2_bwidth      = input.int(1, "Border Width", minval = 1, maxval = 4, group = GRP_B)
box2_label       = input.string("60% Partial", "Label Text", group = GRP_B)
box2_labelCol    = input.color(color.new(#88ccff, 0), "Label Color", group = GRP_B)

// ── BOX 3 : D-Sequencing  (03:00 – 08:30 NY) ─────────────────────────────
var GRP_C = "📦 Box 3 — D-Sequencing"
box3_on          = input.bool(true,  "Enable",          group = GRP_C, inline = "b3h")
box3_labelPos    = input.string("Above", "Label Position", options = ["Above", "Inside"], group = GRP_C)
box3_startHour   = input.int(3,  "Start H", minval = 0, maxval = 23, group = GRP_C, inline = "b3t")
box3_startMin    = input.int(0,  "Start M", minval = 0, maxval = 59, group = GRP_C, inline = "b3t")
box3_endHour     = input.int(8,  "End H",   minval = 0, maxval = 23, group = GRP_C, inline = "b3t")
box3_endMin      = input.int(30, "End M",   minval = 0, maxval = 59, group = GRP_C, inline = "b3t")
box3_bg          = input.color(color.new(#4a2800, 75), "Background", group = GRP_C)
box3_border      = input.color(color.new(#cc7722, 30), "Border",     group = GRP_C)
box3_bwidth      = input.int(1, "Border Width", minval = 1, maxval = 4, group = GRP_C)
box3_label       = input.string("D-Sequencing", "Label Text", group = GRP_C)
box3_labelCol    = input.color(color.new(#ffbb55, 0), "Label Color", group = GRP_C)

// ─────────────────────────────────────────────
//  TIME UTILITY
// ─────────────────────────────────────────────
// NY offset from UTC (standard -5, DST -4). TradingView handles this via
// "America/New_York" timezone string.
tz = "America/New_York"

barM() =>
    hour(time, tz) * 60 + minute(time, tz)

prevBarM() =>
    hour(time[1], tz) * 60 + minute(time[1], tz)

// Overnight sessions (e.g. 15:00 → 03:00) need wrap-around logic:
// a bar is "in range" if startM > endM  →  barM >= startM  OR  barM < endM
//                       startM < endM  →  barM >= startM AND  barM < endM
inRange(startM, endM) =>
    bm = barM()
    startM > endM ? (bm >= startM or bm < endM) : (bm >= startM and bm < endM)

isFirst(startM, endM) =>
    inRange(startM, endM) and not (startM > endM
         ? (prevBarM() >= startM or  prevBarM() < endM)
         : (prevBarM() >= startM and prevBarM() < endM))

// ─────────────────────────────────────────────
//  PER-BOX STATE
// ─────────────────────────────────────────────
var box   b1Box  = na,  var float b1Hi = na,  var float b1Lo = na,  var label b1Lbl = na
var box   b2Box  = na,  var float b2Hi = na,  var float b2Lo = na,  var label b2Lbl = na
var box   b3Box  = na,  var float b3Hi = na,  var float b3Lo = na,  var label b3Lbl = na

// ─────────────────────────────────────────────
//  DRAW / UPDATE ROUTINE  (inline per box)
// ─────────────────────────────────────────────

// — precompute time boundaries once per bar —
b1_sM = box1_startHour * 60 + box1_startMin
b1_eM = box1_endHour   * 60 + box1_endMin
b2_sM = box2_startHour * 60 + box2_startMin
b2_eM = box2_endHour   * 60 + box2_endMin
b3_sM = box3_startHour * 60 + box3_startMin
b3_eM = box3_endHour   * 60 + box3_endMin

// ── BOX 1 ─────────────────────────────────────
if box1_on
    if isFirst(b1_sM, b1_eM)
        b1Hi  := high
        b1Lo  := low
        b1Box := box.new(bar_index, high, bar_index, low,
                         bgcolor      = box1_bg,
                         border_color = box1_border,
                         border_width = box1_bwidth,
                         border_style = line.style_dashed,
                         text         = box1_labelPos == "Inside" ? box1_label : "",
                         text_color   = box1_labelCol,
                         text_size    = size.small,
                         text_halign  = text.align_left,
                         text_valign  = text.align_top)
        if box1_labelPos == "Above"
            b1Lbl := label.new(bar_index, high, box1_label,
                               style     = label.style_none,
                               color     = color.new(color.white, 100),
                               textcolor = box1_labelCol,
                               size      = size.small,
                               yloc      = yloc.price)

    if inRange(b1_sM, b1_eM) and not na(b1Box)
        b1Hi := math.max(b1Hi, high)
        b1Lo := math.min(b1Lo, low)
        box.set_top(b1Box,    b1Hi)
        box.set_bottom(b1Box, b1Lo)
        box.set_right(b1Box,  bar_index)
        if box1_labelPos == "Above" and not na(b1Lbl)
            label.set_y(b1Lbl, b1Hi)
            label.set_x(b1Lbl, box.get_left(b1Box))

// ── BOX 2 ─────────────────────────────────────
if box2_on
    if isFirst(b2_sM, b2_eM)
        b2Hi  := high
        b2Lo  := low
        b2Box := box.new(bar_index, high, bar_index, low,
                         bgcolor      = box2_bg,
                         border_color = box2_border,
                         border_width = box2_bwidth,
                         border_style = line.style_dashed,
                         text         = box2_labelPos == "Inside" ? box2_label : "",
                         text_color   = box2_labelCol,
                         text_size    = size.small,
                         text_halign  = text.align_left,
                         text_valign  = text.align_top)
        if box2_labelPos == "Above"
            b2Lbl := label.new(bar_index, high, box2_label,
                               style     = label.style_none,
                               color     = color.new(color.white, 100),
                               textcolor = box2_labelCol,
                               size      = size.small,
                               yloc      = yloc.price)

    if inRange(b2_sM, b2_eM) and not na(b2Box)
        b2Hi := math.max(b2Hi, high)
        b2Lo := math.min(b2Lo, low)
        box.set_top(b2Box,    b2Hi)
        box.set_bottom(b2Box, b2Lo)
        box.set_right(b2Box,  bar_index)
        if box2_labelPos == "Above" and not na(b2Lbl)
            label.set_y(b2Lbl, b2Hi)
            label.set_x(b2Lbl, box.get_left(b2Box))

// ── BOX 3 ─────────────────────────────────────
if box3_on
    if isFirst(b3_sM, b3_eM)
        b3Hi  := high
        b3Lo  := low
        b3Box := box.new(bar_index, high, bar_index, low,
                         bgcolor      = box3_bg,
                         border_color = box3_border,
                         border_width = box3_bwidth,
                         border_style = line.style_dashed,
                         text         = box3_labelPos == "Inside" ? box3_label : "",
                         text_color   = box3_labelCol,
                         text_size    = size.small,
                         text_halign  = text.align_left,
                         text_valign  = text.align_top)
        if box3_labelPos == "Above"
            b3Lbl := label.new(bar_index, high, box3_label,
                               style     = label.style_none,
                               color     = color.new(color.white, 100),
                               textcolor = box3_labelCol,
                               size      = size.small,
                               yloc      = yloc.price)

    if inRange(b3_sM, b3_eM) and not na(b3Box)
        b3Hi := math.max(b3Hi, high)
        b3Lo := math.min(b3Lo, low)
        box.set_top(b3Box,    b3Hi)
        box.set_bottom(b3Box, b3Lo)
        box.set_right(b3Box,  bar_index)
        if box3_labelPos == "Above" and not na(b3Lbl)
            label.set_y(b3Lbl, b3Hi)
            label.set_x(b3Lbl, box.get_left(b3Box))
````
