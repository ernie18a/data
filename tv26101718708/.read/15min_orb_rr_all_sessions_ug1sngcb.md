# 15min ORB + R:R  |  All Sessions

- url: https://www.tradingview.com/script/ug1sNgCB-15min-ORB-R-R-All-Sessions/
- type: indicator
- pine_id: PUB;e2afc8d1b7bc40e98443e7a386860582
- version: 1.0

## Description

ORB BABY!!!

this indicator shows the 15 minute orb high and low. tp long and tp short with midway lines.

## Source Code

````pine
//@version=5
indicator("15min ORB + R:R  |  All Sessions", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────
rrRatio    = input.float(2.0, "Risk : Reward", minval=0.1, step=0.5)
showRR     = input.bool(true, "Show R:R Targets")
showMid    = input.bool(true, "Show ORB Midline")
showHalf   = input.bool(true, "Show Halfway Dotted Lines")

colHigh    = input.color(#2196F3, "ORB High",         group="Colors")
colLow     = input.color(#F44336, "ORB Low",          group="Colors")
colMid     = input.color(#9E9E9E, "ORB Midline",      group="Colors")
colLongTP  = input.color(#00C853, "Long Target",      group="Colors")
colShortTP = input.color(#FF6D00, "Short Target",     group="Colors")
colHalf    = input.color(#B0BEC5, "Halfway Lines",    group="Colors")

// ─── SESSION TIMES (ET) ────────────────────────────────────────────────────
t_orbOpen  = timestamp("America/New_York", year, month, dayofmonth,  9, 30, 0)
t_orbClose = timestamp("America/New_York", year, month, dayofmonth,  9, 45, 0)
t_nyClose  = timestamp("America/New_York", year, month, dayofmonth, 16,  0, 0)

inORB     = time >= t_orbOpen  and time < t_orbClose
inSession = time >= t_orbOpen  and time < t_nyClose
newDay    = ta.change(time("D"))

// ─── PER-DAY STATE ─────────────────────────────────────────────────────────
var float dayH  = na
var float dayL  = na
var int   dayT1 = na   // first ORB bar
var int   dayT2 = na   // tracks session end bar
var bool  drawn = false

// Live session lines (delete+redraw each bar until 4pm)
var line  ln_h   = na, var line  ln_l   = na, var line  ln_m   = na
var line  ln_tL  = na, var line  ln_tS  = na
var line  ln_hfL = na, var line  ln_hfS = na
var label lb_h   = na, var label lb_l   = na, var label lb_m   = na
var label lb_tL  = na, var label lb_tS  = na

if newDay
    dayH  := na
    dayL  := na
    dayT1 := na
    dayT2 := na
    drawn := false

if inORB
    dayH  := na(dayH) ? high : math.max(dayH, high)
    dayL  := na(dayL) ? low  : math.min(dayL, low)
    dayT1 := na(dayT1) ? bar_index : dayT1

// Track session end bar continuously (stops updating after 4pm)
if inSession and not na(dayH)
    dayT2 := bar_index

// ─── DRAW COMPLETED SESSIONS ONCE (on first bar after 4pm ET) ──────────────
sessionJustClosed = not inSession and inSession[1] and not na(dayH) and not drawn

if sessionJustClosed
    h    = dayH
    l    = dayL
    t1   = dayT1
    t2   = dayT2
    mid  = math.avg(h, l)
    rng  = h - l
    tgtL = h + rng * rrRatio
    tgtS = l - rng * rrRatio
    hfL  = math.avg(h, tgtL)   // halfway between ORB high and long TP
    hfS  = math.avg(l, tgtS)   // halfway between ORB low and short TP

    line.new(t1, h, t2, h, color=colHigh, width=2)
    line.new(t1, l, t2, l, color=colLow,  width=2)

    if showMid
        line.new(t1, mid, t2, mid,
                 color=color.new(colMid, 50), width=1, style=line.style_dashed)
    if showRR
        line.new(t1, tgtL, t2, tgtL, color=colLongTP,  width=1, style=line.style_dashed)
        line.new(t1, tgtS, t2, tgtS, color=colShortTP, width=1, style=line.style_dashed)
    if showHalf and showRR
        line.new(t1, hfL, t2, hfL, color=color.new(colHalf, 40), width=1, style=line.style_dotted)
        line.new(t1, hfS, t2, hfS, color=color.new(colHalf, 40), width=1, style=line.style_dotted)

    drawn := true

// ─── LIVE SESSION: extend lines from ORB close bar to current bar ──────────
// Triggers as soon as inORB ends and runs until 4pm
orbJustClosed = not inORB and inSession and not na(dayH) and not drawn

if orbJustClosed or (inSession and not inORB and not na(dayH) and not drawn)
    h    = dayH
    l    = dayL
    t1   = dayT1
    t2   = bar_index
    mid  = math.avg(h, l)
    rng  = h - l
    tgtL = h + rng * rrRatio
    tgtS = l - rng * rrRatio
    hfL  = math.avg(h, tgtL)
    hfS  = math.avg(l, tgtS)
    rrs  = str.tostring(rrRatio, "#.#") + "R"

    // Delete previous live lines
    line.delete(ln_h),   line.delete(ln_l),   line.delete(ln_m)
    line.delete(ln_tL),  line.delete(ln_tS)
    line.delete(ln_hfL), line.delete(ln_hfS)
    label.delete(lb_h),  label.delete(lb_l),  label.delete(lb_m)
    label.delete(lb_tL), label.delete(lb_tS)

    ln_h := line.new(t1, h, t2, h, color=colHigh, width=2)
    lb_h := label.new(t2, h, "ORB High  " + str.tostring(h, format.mintick),
             color=color.new(color.white,100), textcolor=colHigh,
             style=label.style_label_left, size=size.small)

    ln_l := line.new(t1, l, t2, l, color=colLow, width=2)
    lb_l := label.new(t2, l, "ORB Low  " + str.tostring(l, format.mintick),
             color=color.new(color.white,100), textcolor=colLow,
             style=label.style_label_left, size=size.small)

    if showMid
        ln_m := line.new(t1, mid, t2, mid,
                 color=color.new(colMid,50), width=1, style=line.style_dashed)
        lb_m := label.new(t2, mid, "Mid  " + str.tostring(mid, format.mintick),
                 color=color.new(color.white,100), textcolor=color.new(colMid,20),
                 style=label.style_label_left, size=size.tiny)

    if showRR
        ln_tL := line.new(t1, tgtL, t2, tgtL, color=colLongTP,  width=1, style=line.style_dashed)
        lb_tL := label.new(t2, tgtL, "Long TP  " + rrs + "  " + str.tostring(tgtL, format.mintick),
                  color=color.new(color.white,100), textcolor=colLongTP,
                  style=label.style_label_left, size=size.small)

        ln_tS := line.new(t1, tgtS, t2, tgtS, color=colShortTP, width=1, style=line.style_dashed)
        lb_tS := label.new(t2, tgtS, "Short TP  " + rrs + "  " + str.tostring(tgtS, format.mintick),
                  color=color.new(color.white,100), textcolor=colShortTP,
                  style=label.style_label_left, size=size.small)

    if showHalf and showRR
        ln_hfL := line.new(t1, hfL, t2, hfL,
                   color=color.new(colHalf, 40), width=1, style=line.style_dotted)
        ln_hfS := line.new(t1, hfS, t2, hfS,
                   color=color.new(colHalf, 40), width=1, style=line.style_dotted)

// ─── INFO TABLE ────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8,
     bgcolor=color.new(color.black, 80),
     border_color=color.new(color.gray, 60), border_width=1,
     frame_color=color.new(color.gray, 60),  frame_width=1)

if not na(dayH) and barstate.islast
    h    = dayH
    l    = dayL
    rng  = h - l
    tgtL = h + rng * rrRatio
    tgtS = l - rng * rrRatio

    table.cell(tbl, 0, 0, "15min ORB", text_color=color.gray,    text_size=size.small, bgcolor=color.new(color.black,70))
    table.cell(tbl, 1, 0, "",          text_color=color.gray,    text_size=size.small, bgcolor=color.new(color.black,70))
    table.cell(tbl, 0, 1, "High",      text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(h,    format.mintick),    text_color=colHigh,   text_size=size.small)
    table.cell(tbl, 0, 2, "Low",       text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(l,    format.mintick),    text_color=colLow,    text_size=size.small)
    table.cell(tbl, 0, 3, "Range",     text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(rng,  format.mintick),    text_color=color.white,text_size=size.small)
    table.cell(tbl, 0, 4, "R:R",       text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 4, "1 : " + str.tostring(rrRatio,"#.#"), text_color=color.white,text_size=size.small)
    table.cell(tbl, 0, 5, "Long TP",   text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(tgtL, format.mintick),    text_color=colLongTP, text_size=size.small)
    table.cell(tbl, 0, 6, "Short TP",  text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(tgtS, format.mintick),    text_color=colShortTP,text_size=size.small)
    table.cell(tbl, 0, 7, "½ Long",    text_color=color.gray,    text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(math.avg(h, tgtL), format.mintick), text_color=colHalf, text_size=size.small)
````
