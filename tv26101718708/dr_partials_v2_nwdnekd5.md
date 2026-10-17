# DR Partials V2

- url: https://www.tradingview.com/script/NwDnEkd5-DR-Partials-V2/
- type: indicator
- pine_id: PUB;af6b9a9479bd400f9aad0e7ffb5dc18c
- version: 1.0

## Description

this is a updated version of the old indicator. it has less noise and is cleaner for better visability.

## Source Code

````pine
//@version=6
indicator("DR Partials V2", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────
//  BOX 1 — 85% Partial  (15:00 – 03:00 NY)
// ─────────────────────────────────────────────
var GRP_A = "📦 Box 1 — 85% Partial"
box1_on        = input.bool(true,  "Enable",       group = GRP_A)
box1_showTag   = input.bool(true,  "Show Labels",  group = GRP_A)
box1_startHour = input.int(15, "Start H", minval = 0, maxval = 23, group = GRP_A, inline = "b1t")
box1_startMin  = input.int(0,  "Start M", minval = 0, maxval = 59, group = GRP_A, inline = "b1t")
box1_endHour   = input.int(3,  "End H",   minval = 0, maxval = 23, group = GRP_A, inline = "b1t")
box1_endMin    = input.int(0,  "End M",   minval = 0, maxval = 59, group = GRP_A, inline = "b1t")
box1_lineCol   = input.color(color.new(#00ffbb, 0),  "Line Color",  group = GRP_A)
box1_lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5, group = GRP_A)
box1_lineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_A)
box1_hiText    = input.string("85% Partial High", "High Label Text", group = GRP_A)
box1_loText    = input.string("85% Partial Low",  "Low Label Text",  group = GRP_A)
box1_labelCol  = input.color(color.black, "Label Text Color", group = GRP_A)
box1_tagBg     = input.color(color.new(#00ffbb, 0), "Label Tag Background", group = GRP_A)

// ─────────────────────────────────────────────
//  BOX 2 — 60% Partial  (18:30 – 02:00 NY)
// ─────────────────────────────────────────────
var GRP_B = "📦 Box 2 — 60% Partial"
box2_on        = input.bool(true,  "Enable",       group = GRP_B)
box2_showTag   = input.bool(true,  "Show Labels",  group = GRP_B)
box2_startHour = input.int(18, "Start H", minval = 0, maxval = 23, group = GRP_B, inline = "b2t")
box2_startMin  = input.int(30, "Start M", minval = 0, maxval = 59, group = GRP_B, inline = "b2t")
box2_endHour   = input.int(2,  "End H",   minval = 0, maxval = 23, group = GRP_B, inline = "b2t")
box2_endMin    = input.int(0,  "End M",   minval = 0, maxval = 59, group = GRP_B, inline = "b2t")
box2_lineCol   = input.color(color.new(#354733, 0),  "Line Color",  group = GRP_B)
box2_lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5, group = GRP_B)
box2_lineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_B)
box2_hiText    = input.string("60% Partial High", "High Label Text", group = GRP_B)
box2_loText    = input.string("60% Partial Low",  "Low Label Text",  group = GRP_B)
box2_labelCol  = input.color(color.white, "Label Text Color", group = GRP_B)
box2_tagBg     = input.color(color.new(#354733, 0), "Label Tag Background", group = GRP_B)

// ─────────────────────────────────────────────
//  BOX 3 — D-Sequencing  (03:00 – 08:30 NY)
// ─────────────────────────────────────────────
var GRP_C = "📦 Box 3 — D-Sequencing"
box3_on        = input.bool(true,  "Enable",       group = GRP_C)
box3_showTag   = input.bool(true,  "Show Labels",  group = GRP_C)
box3_startHour = input.int(3,  "Start H", minval = 0, maxval = 23, group = GRP_C, inline = "b3t")
box3_startMin  = input.int(0,  "Start M", minval = 0, maxval = 59, group = GRP_C, inline = "b3t")
box3_endHour   = input.int(8,  "End H",   minval = 0, maxval = 23, group = GRP_C, inline = "b3t")
box3_endMin    = input.int(30, "End M",   minval = 0, maxval = 59, group = GRP_C, inline = "b3t")
box3_lineCol   = input.color(color.new(#a0522d, 0),  "Line Color",  group = GRP_C)
box3_lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5, group = GRP_C)
box3_lineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_C)
box3_hiText    = input.string("D-Sequencing High", "High Label Text", group = GRP_C)
box3_loText    = input.string("D-Sequencing Low",  "Low Label Text",  group = GRP_C)
box3_labelCol  = input.color(color.white, "Label Text Color", group = GRP_C)
box3_tagBg     = input.color(color.new(#a0522d, 0), "Label Tag Background", group = GRP_C)

// ─────────────────────────────────────────────
//  TIME UTILITY  (NY time, overnight-safe)
// ─────────────────────────────────────────────
tz = "America/New_York"

barM() =>
    hour(time, tz) * 60 + minute(time, tz)

prevBarM() =>
    hour(time[1], tz) * 60 + minute(time[1], tz)

inRange(startM, endM) =>
    bm = barM()
    startM > endM ? (bm >= startM or bm < endM) : (bm >= startM and bm < endM)

isFirst(startM, endM) =>
    inRange(startM, endM) and not (startM > endM
         ? (prevBarM() >= startM or  prevBarM() < endM)
         : (prevBarM() >= startM and prevBarM() < endM))

lineStyleOf(s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

// ─────────────────────────────────────────────
//  PER-BOX STATE
//  hiLine / loLine = the long horizontal high/low lines
//  hiLbl  / loLbl  = flag-style labels at the right end of each line
// ─────────────────────────────────────────────
var line  b1HiLine = na, var line  b1LoLine = na, var float b1Hi = na, var float b1Lo = na
var label b1HiLbl  = na, var label b1LoLbl  = na

var line  b2HiLine = na, var line  b2LoLine = na, var float b2Hi = na, var float b2Lo = na
var label b2HiLbl  = na, var label b2LoLbl  = na

var line  b3HiLine = na, var line  b3LoLine = na, var float b3Hi = na, var float b3Lo = na
var label b3HiLbl  = na, var label b3LoLbl  = na

b1_sM = box1_startHour * 60 + box1_startMin
b1_eM = box1_endHour   * 60 + box1_endMin
b2_sM = box2_startHour * 60 + box2_startMin
b2_eM = box2_endHour   * 60 + box2_endMin
b3_sM = box3_startHour * 60 + box3_startMin
b3_eM = box3_endHour   * 60 + box3_endMin

// ── BOX 1 ─────────────────────────────────────
if box1_on
    if isFirst(b1_sM, b1_eM)
        b1Hi := high
        b1Lo := low
        b1HiLine := line.new(bar_index, b1Hi, bar_index, b1Hi,
                             color = box1_lineCol, width = box1_lineWidth, style = lineStyleOf(box1_lineStyle))
        b1LoLine := line.new(bar_index, b1Lo, bar_index, b1Lo,
                             color = box1_lineCol, width = box1_lineWidth, style = lineStyleOf(box1_lineStyle))
        if box1_showTag
            b1HiLbl := label.new(bar_index, b1Hi, box1_hiText,
                                 style = label.style_label_left, color = box1_tagBg,
                                 textcolor = box1_labelCol, size = size.small, yloc = yloc.price)
            b1LoLbl := label.new(bar_index, b1Lo, box1_loText,
                                 style = label.style_label_left, color = box1_tagBg,
                                 textcolor = box1_labelCol, size = size.small, yloc = yloc.price)

    if inRange(b1_sM, b1_eM)
        b1Hi := math.max(b1Hi, high)
        b1Lo := math.min(b1Lo, low)
        if not na(b1HiLine)
            line.set_xy1(b1HiLine, line.get_x1(b1HiLine), b1Hi)
            line.set_xy2(b1HiLine, bar_index, b1Hi)
            line.set_xy1(b1LoLine, line.get_x1(b1LoLine), b1Lo)
            line.set_xy2(b1LoLine, bar_index, b1Lo)
        if box1_showTag and not na(b1HiLbl)
            label.set_xy(b1HiLbl, bar_index, b1Hi)
            label.set_xy(b1LoLbl, bar_index, b1Lo)

// ── BOX 2 ─────────────────────────────────────
if box2_on
    if isFirst(b2_sM, b2_eM)
        b2Hi := high
        b2Lo := low
        b2HiLine := line.new(bar_index, b2Hi, bar_index, b2Hi,
                             color = box2_lineCol, width = box2_lineWidth, style = lineStyleOf(box2_lineStyle))
        b2LoLine := line.new(bar_index, b2Lo, bar_index, b2Lo,
                             color = box2_lineCol, width = box2_lineWidth, style = lineStyleOf(box2_lineStyle))
        if box2_showTag
            b2HiLbl := label.new(bar_index, b2Hi, box2_hiText,
                                 style = label.style_label_left, color = box2_tagBg,
                                 textcolor = box2_labelCol, size = size.small, yloc = yloc.price)
            b2LoLbl := label.new(bar_index, b2Lo, box2_loText,
                                 style = label.style_label_left, color = box2_tagBg,
                                 textcolor = box2_labelCol, size = size.small, yloc = yloc.price)

    if inRange(b2_sM, b2_eM)
        b2Hi := math.max(b2Hi, high)
        b2Lo := math.min(b2Lo, low)
        if not na(b2HiLine)
            line.set_xy1(b2HiLine, line.get_x1(b2HiLine), b2Hi)
            line.set_xy2(b2HiLine, bar_index, b2Hi)
            line.set_xy1(b2LoLine, line.get_x1(b2LoLine), b2Lo)
            line.set_xy2(b2LoLine, bar_index, b2Lo)
        if box2_showTag and not na(b2HiLbl)
            label.set_xy(b2HiLbl, bar_index, b2Hi)
            label.set_xy(b2LoLbl, bar_index, b2Lo)

// ── BOX 3 ─────────────────────────────────────
if box3_on
    if isFirst(b3_sM, b3_eM)
        b3Hi := high
        b3Lo := low
        b3HiLine := line.new(bar_index, b3Hi, bar_index, b3Hi,
                             color = box3_lineCol, width = box3_lineWidth, style = lineStyleOf(box3_lineStyle))
        b3LoLine := line.new(bar_index, b3Lo, bar_index, b3Lo,
                             color = box3_lineCol, width = box3_lineWidth, style = lineStyleOf(box3_lineStyle))
        if box3_showTag
            b3HiLbl := label.new(bar_index, b3Hi, box3_hiText,
                                 style = label.style_label_left, color = box3_tagBg,
                                 textcolor = box3_labelCol, size = size.small, yloc = yloc.price)
            b3LoLbl := label.new(bar_index, b3Lo, box3_loText,
                                 style = label.style_label_left, color = box3_tagBg,
                                 textcolor = box3_labelCol, size = size.small, yloc = yloc.price)

    if inRange(b3_sM, b3_eM)
        b3Hi := math.max(b3Hi, high)
        b3Lo := math.min(b3Lo, low)
        if not na(b3HiLine)
            line.set_xy1(b3HiLine, line.get_x1(b3HiLine), b3Hi)
            line.set_xy2(b3HiLine, bar_index, b3Hi)
            line.set_xy1(b3LoLine, line.get_x1(b3LoLine), b3Lo)
            line.set_xy2(b3LoLine, bar_index, b3Lo)
        if box3_showTag and not na(b3HiLbl)
            label.set_xy(b3HiLbl, bar_index, b3Hi)
            label.set_xy(b3LoLbl, bar_index, b3Lo)
````
