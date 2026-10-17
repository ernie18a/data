# Quarterly Theory Killzones ( nq.adam )

- url: https://www.tradingview.com/script/GEzQNZoZ-Quarterly-Theory-Killzones-nq-adam/
- type: indicator
- pine_id: PUB;a78ea7993d6543b4af0ea508009b28f3
- version: 1.0

## Description

Quarterly Theory – Killzones plots killzone lines and shaded boxes for every cycle tier — Monthly, Weekly, Daily Quarter, 90-Min, and Micro — by marking the previous cycle's high and low and extending them through the current quarter. Fully customizable: control which cycles and timeframes are visible, toggle/recolor boxes, adjust line widths, label text, and colors per cycle — all from the indicator settings.

## Source Code

````pine
//@version=5
indicator("Quarterly Theory – Killzones", overlay=true,
     max_lines_count=500, max_labels_count=300, max_boxes_count=200)

// ═══════════════════════════════════════════════════════════════════
// INPUTS – MASTER CYCLE TOGGLES
// ═══════════════════════════════════════════════════════════════════
grp_vis = "── Cycle Visibility ──"
show_mo  = input.bool(true, "Monthly Cycle",   group=grp_vis)
show_wk  = input.bool(true, "Weekly Cycle",    group=grp_vis)
show_dq  = input.bool(true, "Daily Quarters",  group=grp_vis)
show_m90 = input.bool(true, "90-Min Quarters", group=grp_vis)
show_mc  = input.bool(true, "Micro Cycles",    group=grp_vis)

// ═══════════════════════════════════════════════════════════════════
// TIMEFRAME VISIBILITY PER CYCLE
// ═══════════════════════════════════════════════════════════════════
grp_mo_tf = "── Monthly – Visible On Timeframes ──"
mo_tf_1   = input.bool(false, "1 min",   group=grp_mo_tf)
mo_tf_5   = input.bool(false, "5 min",   group=grp_mo_tf)
mo_tf_15  = input.bool(false, "15 min",  group=grp_mo_tf)
mo_tf_30  = input.bool(true,  "30 min",  group=grp_mo_tf)
mo_tf_60  = input.bool(true,  "1 Hour",  group=grp_mo_tf)
mo_tf_240 = input.bool(true,  "4 Hour",  group=grp_mo_tf)

grp_wk_tf = "── Weekly – Visible On Timeframes ──"
wk_tf_1   = input.bool(true,  "1 min",  group=grp_wk_tf)
wk_tf_5   = input.bool(true,  "5 min",  group=grp_wk_tf)
wk_tf_15  = input.bool(true,  "15 min", group=grp_wk_tf)
wk_tf_30  = input.bool(true,  "30 min", group=grp_wk_tf)
wk_tf_60  = input.bool(false, "1 Hour", group=grp_wk_tf)
wk_tf_240 = input.bool(false, "4 Hour", group=grp_wk_tf)

grp_dq_tf = "── Daily Quarter – Visible On Timeframes ──"
dq_tf_1   = input.bool(true,  "1 min",  group=grp_dq_tf)
dq_tf_5   = input.bool(true,  "5 min",  group=grp_dq_tf)
dq_tf_15  = input.bool(true,  "15 min", group=grp_dq_tf)
dq_tf_30  = input.bool(false, "30 min", group=grp_dq_tf)
dq_tf_60  = input.bool(false, "1 Hour", group=grp_dq_tf)
dq_tf_240 = input.bool(false, "4 Hour", group=grp_dq_tf)

grp_m90_tf = "── 90-Min – Visible On Timeframes ──"
m90_tf_1   = input.bool(true,  "1 min",  group=grp_m90_tf)
m90_tf_5   = input.bool(true,  "5 min",  group=grp_m90_tf)
m90_tf_15  = input.bool(false, "15 min", group=grp_m90_tf)
m90_tf_30  = input.bool(false, "30 min", group=grp_m90_tf)
m90_tf_60  = input.bool(false, "1 Hour", group=grp_m90_tf)
m90_tf_240 = input.bool(false, "4 Hour", group=grp_m90_tf)

grp_mc_tf = "── Micro Cycle – Visible On Timeframes ──"
mc_tf_1   = input.bool(true,  "1 min",  group=grp_mc_tf)
mc_tf_5   = input.bool(false, "5 min",  group=grp_mc_tf)
mc_tf_15  = input.bool(false, "15 min", group=grp_mc_tf)
mc_tf_30  = input.bool(false, "30 min", group=grp_mc_tf)
mc_tf_60  = input.bool(false, "1 Hour", group=grp_mc_tf)
mc_tf_240 = input.bool(false, "4 Hour", group=grp_mc_tf)

// ═══════════════════════════════════════════════════════════════════
// BOX SHADING – SHOW/HIDE TOGGLES & COLORS
// ═══════════════════════════════════════════════════════════════════
grp_col = "── Box Shading ──"
show_mo_box  = input.bool(true, "Show Monthly Boxes",       group=grp_col)
show_wk_box  = input.bool(true, "Show Weekly Boxes",        group=grp_col)
show_dq_box  = input.bool(true, "Show Daily Quarter Boxes", group=grp_col)
show_m90_box = input.bool(true, "Show 90-Min Boxes",        group=grp_col)
show_mc_box  = input.bool(true, "Show Micro Boxes",         group=grp_col)

col_mo  = input.color(#C8A86B, "Monthly Cycle (muted gold)",   group=grp_col)
col_wk  = input.color(#A07CC0, "Weekly Cycle  (muted purple)", group=grp_col)
col_dq  = input.color(#5B8DB8, "Daily Cycle   (muted blue)",   group=grp_col)
col_m90 = input.color(#5C9E6E, "90-Min Cycle  (muted green)",  group=grp_col)
col_mc  = input.color(#C47A8A, "Micro Cycle   (muted pink)",   group=grp_col)

// ═══════════════════════════════════════════════════════════════════
// KILLZONE LINES & LABELS
// ═══════════════════════════════════════════════════════════════════
grp_sty = "── Killzone Lines & Labels ──"

col_kz_mo  = input.color(#707070, "Monthly Line Color",  group=grp_sty)
col_kz_wk  = input.color(#707070, "Weekly Line Color",   group=grp_sty)
col_kz_dq  = input.color(#707070, "DQ Line Color",       group=grp_sty)
col_kz_m90 = input.color(#707070, "90m Line Color",      group=grp_sty)
col_kz_mc  = input.color(#707070, "Micro Line Color",    group=grp_sty)

col_txt_mo  = input.color(#707070, "Monthly Label Text Color",  group=grp_sty)
col_txt_wk  = input.color(#707070, "Weekly Label Text Color",   group=grp_sty)
col_txt_dq  = input.color(#707070, "DQ Label Text Color",       group=grp_sty)
col_txt_m90 = input.color(#707070, "90m Label Text Color",      group=grp_sty)
col_txt_mc  = input.color(#707070, "Micro Label Text Color",    group=grp_sty)

lw_mo   = input.int(2, "Monthly Line Width", minval=1, maxval=4, group=grp_sty)
lw_wk   = input.int(2, "Weekly Line Width",  minval=1, maxval=4, group=grp_sty)
lw_dq   = input.int(2, "DQ Line Width",      minval=1, maxval=4, group=grp_sty)
lw_m90  = input.int(1, "90m Line Width",     minval=1, maxval=4, group=grp_sty)
lw_mc   = input.int(1, "Micro Line Width",   minval=1, maxval=4, group=grp_sty)

mo_high_txt  = input.string("MO High",    "Monthly High Label", group=grp_sty)
mo_low_txt   = input.string("MO Low",     "Monthly Low Label",  group=grp_sty)
wk_high_txt  = input.string("WK High",    "Weekly High Label",  group=grp_sty)
wk_low_txt   = input.string("WK Low",     "Weekly Low Label",   group=grp_sty)
dq_high_txt  = input.string("DQ High",    "DQ High Label",      group=grp_sty)
dq_low_txt   = input.string("DQ Low",     "DQ Low Label",       group=grp_sty)
m90_high_txt = input.string("90m High",   "90m High Label",     group=grp_sty)
m90_low_txt  = input.string("90m Low",    "90m Low Label",      group=grp_sty)
mc_high_txt  = input.string("Micro High", "Micro High Label",   group=grp_sty)
mc_low_txt   = input.string("Micro Low",  "Micro Low Label",    group=grp_sty)

lbl_size_in = input.string(
     "Small", "Label Text Size",
     options=["Tiny","Small","Normal","Large"],
     group=grp_sty)

lbl_size =
     lbl_size_in == "Tiny"   ? size.tiny   :
     lbl_size_in == "Small"  ? size.small  :
     lbl_size_in == "Normal" ? size.normal :
     size.large

// ═══════════════════════════════════════════════════════════════════
// PACIFIC-TIME CALCULATION
// ═══════════════════════════════════════════════════════════════════
pt_min  = hour(time, "America/Los_Angeles") * 60 + minute(time, "America/Los_Angeles")
ses_off = pt_min >= 900 ? pt_min - 900 : pt_min + 540

// Daily Quarter index 0–3
f_dq() =>
    ses_off < 360 ? 0 : ses_off < 720 ? 1 : ses_off < 1080 ? 2 : 3

// 90-min block index
f_m90() =>
    math.floor(ses_off / 90)

// Micro quarter
f_mc() =>
    off_in = ses_off % 90
    mq     = off_in < 23 ? 0 : off_in < 45 ? 1 : off_in < 68 ? 2 : 3
    f_m90() * 4 + mq

cur_dq  = f_dq()
cur_m90 = f_m90()
cur_mc  = f_mc()

// ═══════════════════════════════════════════════════════════════════
// SESSION BOUNDARY DETECTION  (3 PM PT = ses_off wraps back to 0)
// ═══════════════════════════════════════════════════════════════════
// ses_off runs 0 → ~1439 across each trading day; a drop signals 3 PM PT
new_trading_day = not na(ses_off[1]) and ses_off < ses_off[1]

var int trading_day_id  = 0   // increments every 3 PM PT
var int trading_week_id = 0   // increments every Sunday 3 PM PT

if new_trading_day
    trading_day_id += 1
    if dayofweek(time, "America/Los_Angeles") == dayofweek.sunday
        trading_week_id += 1

// ═══════════════════════════════════════════════════════════════════
// TIMEFRAME GATES
// ═══════════════════════════════════════════════════════════════════
on_1   = timeframe.period == "1"
on_5   = timeframe.period == "5"
on_15  = timeframe.period == "15"
on_30  = timeframe.period == "30"
on_60  = timeframe.period == "60"
on_240 = timeframe.period == "240"

mo_visible  = show_mo  and (
     (mo_tf_1   and on_1)   or (mo_tf_5   and on_5)   or
     (mo_tf_15  and on_15)  or (mo_tf_30  and on_30)  or
     (mo_tf_60  and on_60)  or (mo_tf_240 and on_240))

wk_visible  = show_wk  and (
     (wk_tf_1   and on_1)   or (wk_tf_5   and on_5)   or
     (wk_tf_15  and on_15)  or (wk_tf_30  and on_30)  or
     (wk_tf_60  and on_60)  or (wk_tf_240 and on_240))

dq_visible  = show_dq  and (
     (dq_tf_1   and on_1)   or (dq_tf_5   and on_5)   or
     (dq_tf_15  and on_15)  or (dq_tf_30  and on_30)  or
     (dq_tf_60  and on_60)  or (dq_tf_240 and on_240))

m90_visible = show_m90 and (
     (m90_tf_1   and on_1)   or (m90_tf_5   and on_5)   or
     (m90_tf_15  and on_15)  or (m90_tf_30  and on_30)  or
     (m90_tf_60  and on_60)  or (m90_tf_240 and on_240))

mc_visible  = show_mc  and (
     (mc_tf_1   and on_1)   or (mc_tf_5   and on_5)   or
     (mc_tf_15  and on_15)  or (mc_tf_30  and on_30)  or
     (mc_tf_60  and on_60)  or (mc_tf_240 and on_240))

// ═══════════════════════════════════════════════════════════════════
// LABEL STYLE
// ═══════════════════════════════════════════════════════════════════
lbl_bg = color.new(color.white, 100)

// ═══════════════════════════════════════════════════════════════════
// MONTHLY TRACKER  (prev week H/L → killzone for current week)
// ═══════════════════════════════════════════════════════════════════
var int   p_mo_week = -1
var int   mo_s_bar  = na

var float c_mo_h    = na
var int   c_mo_hb   = na
var float c_mo_l    = na
var int   c_mo_lb   = na

var float l_mo_h    = na
var int   l_mo_hb   = na
var float l_mo_l    = na
var int   l_mo_lb   = na
var int   l_mo_sb   = na

var line  mo_hl     = na
var line  mo_ll     = na
var label mo_hl_lb  = na
var label mo_ll_lb  = na
var box   mo_bx     = na

if trading_week_id != p_mo_week
    if p_mo_week >= 0
        l_mo_h  := c_mo_h
        l_mo_hb := c_mo_hb
        l_mo_l  := c_mo_l
        l_mo_lb := c_mo_lb
        l_mo_sb := mo_s_bar

        line.delete(mo_hl)
        line.delete(mo_ll)
        label.delete(mo_hl_lb)
        label.delete(mo_ll_lb)
        box.delete(mo_bx)

        if mo_visible
            if show_mo_box and not na(l_mo_h) and not na(l_mo_l)
                mo_bx := box.new(
                     l_mo_sb, l_mo_h,
                     bar_index, l_mo_l,
                     border_color = color.new(col_mo, 70),
                     bgcolor      = color.new(col_mo, 85),
                     border_width = 1)

            if not na(l_mo_h)
                mo_hl := line.new(
                     l_mo_hb, l_mo_h,
                     bar_index, l_mo_h,
                     color = col_kz_mo,
                     width = lw_mo,
                     style = line.style_solid)
                mo_hl_lb := label.new(
                     bar_index, l_mo_h,
                     mo_high_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_mo,
                     size      = lbl_size)

            if not na(l_mo_l)
                mo_ll := line.new(
                     l_mo_lb, l_mo_l,
                     bar_index, l_mo_l,
                     color = col_kz_mo,
                     width = lw_mo,
                     style = line.style_solid)
                mo_ll_lb := label.new(
                     bar_index, l_mo_l,
                     mo_low_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_mo,
                     size      = lbl_size)

    p_mo_week := trading_week_id
    mo_s_bar  := bar_index
    c_mo_h    := high
    c_mo_hb   := bar_index
    c_mo_l    := low
    c_mo_lb   := bar_index

else
    if high > c_mo_h or na(c_mo_h)
        c_mo_h  := high
        c_mo_hb := bar_index
    if low < c_mo_l or na(c_mo_l)
        c_mo_l  := low
        c_mo_lb := bar_index

if mo_visible
    if not na(mo_hl)
        line.set_x2(mo_hl, bar_index)
        label.set_x(mo_hl_lb, bar_index)
    if not na(mo_ll)
        line.set_x2(mo_ll, bar_index)
        label.set_x(mo_ll_lb, bar_index)

// ═══════════════════════════════════════════════════════════════════
// WEEKLY TRACKER  (prev day H/L → killzone for current day)
// ═══════════════════════════════════════════════════════════════════
var int   p_wk_day = -1
var int   wk_s_bar = na

var float c_wk_h   = na
var int   c_wk_hb  = na
var float c_wk_l   = na
var int   c_wk_lb  = na

var float l_wk_h   = na
var int   l_wk_hb  = na
var float l_wk_l   = na
var int   l_wk_lb  = na
var int   l_wk_sb  = na

var line  wk_hl    = na
var line  wk_ll    = na
var label wk_hl_lb = na
var label wk_ll_lb = na
var box   wk_bx    = na

if trading_day_id != p_wk_day
    if p_wk_day >= 0
        l_wk_h  := c_wk_h
        l_wk_hb := c_wk_hb
        l_wk_l  := c_wk_l
        l_wk_lb := c_wk_lb
        l_wk_sb := wk_s_bar

        line.delete(wk_hl)
        line.delete(wk_ll)
        label.delete(wk_hl_lb)
        label.delete(wk_ll_lb)
        box.delete(wk_bx)

        if wk_visible
            if show_wk_box and not na(l_wk_h) and not na(l_wk_l)
                wk_bx := box.new(
                     l_wk_sb, l_wk_h,
                     bar_index, l_wk_l,
                     border_color = color.new(col_wk, 70),
                     bgcolor      = color.new(col_wk, 85),
                     border_width = 1)

            if not na(l_wk_h)
                wk_hl := line.new(
                     l_wk_hb, l_wk_h,
                     bar_index, l_wk_h,
                     color = col_kz_wk,
                     width = lw_wk,
                     style = line.style_solid)
                wk_hl_lb := label.new(
                     bar_index, l_wk_h,
                     wk_high_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_wk,
                     size      = lbl_size)

            if not na(l_wk_l)
                wk_ll := line.new(
                     l_wk_lb, l_wk_l,
                     bar_index, l_wk_l,
                     color = col_kz_wk,
                     width = lw_wk,
                     style = line.style_solid)
                wk_ll_lb := label.new(
                     bar_index, l_wk_l,
                     wk_low_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_wk,
                     size      = lbl_size)

    p_wk_day := trading_day_id
    wk_s_bar := bar_index
    c_wk_h   := high
    c_wk_hb  := bar_index
    c_wk_l   := low
    c_wk_lb  := bar_index

else
    if high > c_wk_h or na(c_wk_h)
        c_wk_h  := high
        c_wk_hb := bar_index
    if low < c_wk_l or na(c_wk_l)
        c_wk_l  := low
        c_wk_lb := bar_index

if wk_visible
    if not na(wk_hl)
        line.set_x2(wk_hl, bar_index)
        label.set_x(wk_hl_lb, bar_index)
    if not na(wk_ll)
        line.set_x2(wk_ll, bar_index)
        label.set_x(wk_ll_lb, bar_index)

// ═══════════════════════════════════════════════════════════════════
// DAILY QUARTER TRACKER
// ═══════════════════════════════════════════════════════════════════
var int   p_dq     = -1
var int   dq_s_bar = na

var float c_dq_h   = na
var int   c_dq_hb  = na

var float c_dq_l   = na
var int   c_dq_lb  = na

var float l_dq_h   = na
var int   l_dq_hb  = na

var float l_dq_l   = na
var int   l_dq_lb  = na

var int   l_dq_sb  = na
var int   l_dq_id  = -1

var line  dq_hl    = na
var line  dq_ll    = na

var label dq_hl_lb = na
var label dq_ll_lb = na

var box   dq_bx    = na

if cur_dq != p_dq
    if p_dq >= 0
        l_dq_h  := c_dq_h
        l_dq_hb := c_dq_hb

        l_dq_l  := c_dq_l
        l_dq_lb := c_dq_lb

        l_dq_sb := dq_s_bar
        l_dq_id := p_dq

        line.delete(dq_hl)
        line.delete(dq_ll)

        label.delete(dq_hl_lb)
        label.delete(dq_ll_lb)

        box.delete(dq_bx)

        if dq_visible
            if show_dq_box and not na(l_dq_h) and not na(l_dq_l)
                dq_bx := box.new(
                     l_dq_sb, l_dq_h,
                     bar_index, l_dq_l,
                     border_color = color.new(col_dq, 70),
                     bgcolor      = color.new(col_dq, 85),
                     border_width = 1)

            if not na(l_dq_h)
                dq_hl := line.new(
                     l_dq_hb, l_dq_h,
                     bar_index, l_dq_h,
                     color = col_kz_dq,
                     width = lw_dq,
                     style = line.style_solid)

                dq_hl_lb := label.new(
                     bar_index, l_dq_h,
                     dq_high_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_dq,
                     size      = lbl_size)

            if not na(l_dq_l)
                dq_ll := line.new(
                     l_dq_lb, l_dq_l,
                     bar_index, l_dq_l,
                     color = col_kz_dq,
                     width = lw_dq,
                     style = line.style_solid)

                dq_ll_lb := label.new(
                     bar_index, l_dq_l,
                     dq_low_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_dq,
                     size      = lbl_size)

    p_dq     := cur_dq
    dq_s_bar := bar_index

    c_dq_h   := high
    c_dq_hb  := bar_index

    c_dq_l   := low
    c_dq_lb  := bar_index

else
    if high > c_dq_h or na(c_dq_h)
        c_dq_h  := high
        c_dq_hb := bar_index

    if low < c_dq_l or na(c_dq_l)
        c_dq_l  := low
        c_dq_lb := bar_index

if dq_visible
    if not na(dq_hl)
        line.set_x2(dq_hl, bar_index)
        label.set_x(dq_hl_lb, bar_index)

    if not na(dq_ll)
        line.set_x2(dq_ll, bar_index)
        label.set_x(dq_ll_lb, bar_index)

// ═══════════════════════════════════════════════════════════════════
// 90-MIN TRACKER
// ═══════════════════════════════════════════════════════════════════
var int   p_m90     = -1
var int   m90_s_bar = na

var float c_m90_h   = na
var int   c_m90_hb  = na

var float c_m90_l   = na
var int   c_m90_lb  = na

var float l_m90_h   = na
var int   l_m90_hb  = na

var float l_m90_l   = na
var int   l_m90_lb  = na

var int   l_m90_sb  = na
var int   l_m90_id  = -1

var line  m90_hl    = na
var line  m90_ll    = na

var label m90_hl_lb = na
var label m90_ll_lb = na

var box   m90_bx    = na

if cur_m90 != p_m90
    if p_m90 >= 0
        l_m90_h  := c_m90_h
        l_m90_hb := c_m90_hb

        l_m90_l  := c_m90_l
        l_m90_lb := c_m90_lb

        l_m90_sb := m90_s_bar
        l_m90_id := p_m90

        line.delete(m90_hl)
        line.delete(m90_ll)

        label.delete(m90_hl_lb)
        label.delete(m90_ll_lb)

        box.delete(m90_bx)

        if m90_visible
            if show_m90_box and not na(l_m90_h) and not na(l_m90_l)
                m90_bx := box.new(
                     l_m90_sb, l_m90_h,
                     bar_index, l_m90_l,
                     border_color = color.new(col_m90, 70),
                     bgcolor      = color.new(col_m90, 85),
                     border_width = 1)

            if not na(l_m90_h)
                m90_hl := line.new(
                     l_m90_hb, l_m90_h,
                     bar_index, l_m90_h,
                     color = col_kz_m90,
                     width = lw_m90,
                     style = line.style_solid)

                m90_hl_lb := label.new(
                     bar_index, l_m90_h,
                     m90_high_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_m90,
                     size      = lbl_size)

            if not na(l_m90_l)
                m90_ll := line.new(
                     l_m90_lb, l_m90_l,
                     bar_index, l_m90_l,
                     color = col_kz_m90,
                     width = lw_m90,
                     style = line.style_solid)

                m90_ll_lb := label.new(
                     bar_index, l_m90_l,
                     m90_low_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_m90,
                     size      = lbl_size)

    p_m90     := cur_m90
    m90_s_bar := bar_index

    c_m90_h   := high
    c_m90_hb  := bar_index

    c_m90_l   := low
    c_m90_lb  := bar_index

else
    if high > c_m90_h or na(c_m90_h)
        c_m90_h  := high
        c_m90_hb := bar_index

    if low < c_m90_l or na(c_m90_l)
        c_m90_l  := low
        c_m90_lb := bar_index

if m90_visible
    if not na(m90_hl)
        line.set_x2(m90_hl, bar_index)
        label.set_x(m90_hl_lb, bar_index)

    if not na(m90_ll)
        line.set_x2(m90_ll, bar_index)
        label.set_x(m90_ll_lb, bar_index)

// ═══════════════════════════════════════════════════════════════════
// MICRO TRACKER
// ═══════════════════════════════════════════════════════════════════
var int   p_mc     = -1
var int   mc_s_bar = na

var float c_mc_h   = na
var int   c_mc_hb  = na

var float c_mc_l   = na
var int   c_mc_lb  = na

var float l_mc_h   = na
var int   l_mc_hb  = na

var float l_mc_l   = na
var int   l_mc_lb  = na

var int   l_mc_sb  = na
var int   l_mc_id  = -1

var line  mc_hl    = na
var line  mc_ll    = na

var label mc_hl_lb = na
var label mc_ll_lb = na

var box   mc_bx    = na

if cur_mc != p_mc
    if p_mc >= 0
        l_mc_h  := c_mc_h
        l_mc_hb := c_mc_hb

        l_mc_l  := c_mc_l
        l_mc_lb := c_mc_lb

        l_mc_sb := mc_s_bar
        l_mc_id := p_mc

        line.delete(mc_hl)
        line.delete(mc_ll)

        label.delete(mc_hl_lb)
        label.delete(mc_ll_lb)

        box.delete(mc_bx)

        if mc_visible
            if show_mc_box and not na(l_mc_h) and not na(l_mc_l)
                mc_bx := box.new(
                     l_mc_sb, l_mc_h,
                     bar_index, l_mc_l,
                     border_color = color.new(col_mc, 70),
                     bgcolor      = color.new(col_mc, 85),
                     border_width = 1)

            if not na(l_mc_h)
                mc_hl := line.new(
                     l_mc_hb, l_mc_h,
                     bar_index, l_mc_h,
                     color = col_kz_mc,
                     width = lw_mc,
                     style = line.style_solid)

                mc_hl_lb := label.new(
                     bar_index, l_mc_h,
                     mc_high_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_mc,
                     size      = lbl_size)

            if not na(l_mc_l)
                mc_ll := line.new(
                     l_mc_lb, l_mc_l,
                     bar_index, l_mc_l,
                     color = col_kz_mc,
                     width = lw_mc,
                     style = line.style_solid)

                mc_ll_lb := label.new(
                     bar_index, l_mc_l,
                     mc_low_txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = label.style_label_left,
                     color     = lbl_bg,
                     textcolor = col_txt_mc,
                     size      = lbl_size)

    p_mc     := cur_mc
    mc_s_bar := bar_index

    c_mc_h   := high
    c_mc_hb  := bar_index

    c_mc_l   := low
    c_mc_lb  := bar_index

else
    if high > c_mc_h or na(c_mc_h)
        c_mc_h  := high
        c_mc_hb := bar_index

    if low < c_mc_l or na(c_mc_l)
        c_mc_l  := low
        c_mc_lb := bar_index

if mc_visible
    if not na(mc_hl)
        line.set_x2(mc_hl, bar_index)
        label.set_x(mc_hl_lb, bar_index)

    if not na(mc_ll)
        line.set_x2(mc_ll, bar_index)
        label.set_x(mc_ll_lb, bar_index)
````
