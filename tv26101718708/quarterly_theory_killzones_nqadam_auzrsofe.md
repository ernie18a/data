# Quarterly Theory - Killzones (NQ.ADAM)

- url: https://www.tradingview.com/script/AuZrsOFE-Quarterly-Theory-Killzones-NQ-ADAM/
- type: indicator
- pine_id: PUB;96b035cd9bc74903bb08791d6bf8aa38
- version: 1.0

## Description

Currently working on Weekly and Monthly Cycles they are buggin

Daily, 90m, and Micro should work.

## Source Code

````pine
//@version=5
indicator("Quarterly Theory - Killzones", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

grp_vis = "Visibility"
show_monthly = input.bool(true, "Monthly Cycle", group=grp_vis)
show_weekly  = input.bool(true, "Weekly Cycle", group=grp_vis)
show_dq      = input.bool(true, "Daily Quarters", group=grp_vis)
show_m90     = input.bool(true, "90-Min Quarters", group=grp_vis)
show_mc      = input.bool(true, "Micro Cycles", group=grp_vis)

grp_tf_1 = "Timeframe Visibility - 1m"
monthly_tf_1 = input.bool(true, "Monthly", group=grp_tf_1)
weekly_tf_1  = input.bool(true, "Weekly", group=grp_tf_1)
dq_tf_1      = input.bool(true, "Daily", group=grp_tf_1)
m90_tf_1     = input.bool(true, "90m", group=grp_tf_1)
mc_tf_1      = input.bool(true, "Micro", group=grp_tf_1)

grp_tf_3 = "Timeframe Visibility - 3m"
monthly_tf_3 = input.bool(true, "Monthly", group=grp_tf_3)
weekly_tf_3  = input.bool(true, "Weekly", group=grp_tf_3)
dq_tf_3      = input.bool(false, "Daily", group=grp_tf_3)
m90_tf_3     = input.bool(false, "90m", group=grp_tf_3)
mc_tf_3      = input.bool(false, "Micro", group=grp_tf_3)

grp_tf_5 = "Timeframe Visibility - 5m"
monthly_tf_5 = input.bool(true, "Monthly", group=grp_tf_5)
weekly_tf_5  = input.bool(true, "Weekly", group=grp_tf_5)
dq_tf_5      = input.bool(true, "Daily", group=grp_tf_5)
m90_tf_5     = input.bool(true, "90m", group=grp_tf_5)
mc_tf_5      = input.bool(false, "Micro", group=grp_tf_5)

grp_tf_15 = "Timeframe Visibility - 15m"
monthly_tf_15 = input.bool(true, "Monthly", group=grp_tf_15)
weekly_tf_15  = input.bool(true, "Weekly", group=grp_tf_15)
dq_tf_15      = input.bool(true, "Daily", group=grp_tf_15)
m90_tf_15     = input.bool(false, "90m", group=grp_tf_15)
mc_tf_15      = input.bool(false, "Micro", group=grp_tf_15)

grp_tf_30 = "Timeframe Visibility - 30m"
monthly_tf_30 = input.bool(false, "Monthly", group=grp_tf_30)
weekly_tf_30  = input.bool(false, "Weekly", group=grp_tf_30)
dq_tf_30      = input.bool(false, "Daily", group=grp_tf_30)
m90_tf_30     = input.bool(false, "90m", group=grp_tf_30)
mc_tf_30      = input.bool(false, "Micro", group=grp_tf_30)

grp_tf_60 = "Timeframe Visibility - 1h"
monthly_tf_60 = input.bool(false, "Monthly", group=grp_tf_60)
weekly_tf_60  = input.bool(false, "Weekly", group=grp_tf_60)
dq_tf_60      = input.bool(false, "Daily", group=grp_tf_60)
m90_tf_60     = input.bool(false, "90m", group=grp_tf_60)
mc_tf_60      = input.bool(false, "Micro", group=grp_tf_60)

grp_col = "Box Shading Colors"
col_monthly = input.color(#8A7CC2, "Monthly Cycle", group=grp_col)
col_weekly  = input.color(#B89B5B, "Weekly Cycle", group=grp_col)
col_dq      = input.color(#5B8DB8, "Daily Cycle", group=grp_col)
col_m90     = input.color(#5C9E6E, "90-Min Cycle", group=grp_col)
col_mc      = input.color(#C47A8A, "Micro Cycle", group=grp_col)

grp_sty = "Killzone Lines & Labels"
col_kz_monthly = input.color(#707070, "Monthly Killzone Line Color", group=grp_sty)
col_kz_weekly  = input.color(#707070, "Weekly Killzone Line Color", group=grp_sty)
col_kz_dq      = input.color(#707070, "DQ Killzone Line Color", group=grp_sty)
col_kz_m90     = input.color(#707070, "90m Killzone Line Color", group=grp_sty)
col_kz_mc      = input.color(#707070, "Micro Killzone Line Color", group=grp_sty)

lw_monthly = input.int(2, "Monthly Line Width", minval=1, maxval=4, group=grp_sty)
lw_weekly  = input.int(2, "Weekly Line Width", minval=1, maxval=4, group=grp_sty)
lw_dq      = input.int(2, "DQ Line Width", minval=1, maxval=4, group=grp_sty)
lw_m90     = input.int(1, "90m Line Width", minval=1, maxval=4, group=grp_sty)
lw_mc      = input.int(1, "Micro Line Width", minval=1, maxval=4, group=grp_sty)

monthly_high_txt = input.string("Monthly High", "Monthly High Label", group=grp_sty)
monthly_low_txt  = input.string("Monthly Low", "Monthly Low Label", group=grp_sty)
weekly_high_txt  = input.string("Weekly High", "Weekly High Label", group=grp_sty)
weekly_low_txt   = input.string("Weekly Low", "Weekly Low Label", group=grp_sty)
dq_high_txt      = input.string("DQ High", "DQ High Label", group=grp_sty)
dq_low_txt       = input.string("DQ Low", "DQ Low Label", group=grp_sty)
m90_high_txt     = input.string("90m High", "90m High Label", group=grp_sty)
m90_low_txt      = input.string("90m Low", "90m Low Label", group=grp_sty)
mc_high_txt      = input.string("Micro High", "Micro High Label", group=grp_sty)
mc_low_txt       = input.string("Micro Low", "Micro Low Label", group=grp_sty)

lbl_size_in = input.string("Small", "Label Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_sty)
lbl_size = lbl_size_in == "Tiny" ? size.tiny : lbl_size_in == "Small" ? size.small : lbl_size_in == "Normal" ? size.normal : size.large
lbl_bg = color.new(color.white, 100)

on_1 = timeframe.period == "1"
on_3 = timeframe.period == "3"
on_5 = timeframe.period == "5"
on_15 = timeframe.period == "15"
on_30 = timeframe.period == "30"
on_60 = timeframe.period == "60"

monthly_visible = show_monthly and ((monthly_tf_1 and on_1) or (monthly_tf_3 and on_3) or (monthly_tf_5 and on_5) or (monthly_tf_15 and on_15) or (monthly_tf_30 and on_30) or (monthly_tf_60 and on_60))
weekly_visible  = show_weekly and ((weekly_tf_1 and on_1) or (weekly_tf_3 and on_3) or (weekly_tf_5 and on_5) or (weekly_tf_15 and on_15) or (weekly_tf_30 and on_30) or (weekly_tf_60 and on_60))
dq_visible      = show_dq and ((dq_tf_1 and on_1) or (dq_tf_3 and on_3) or (dq_tf_5 and on_5) or (dq_tf_15 and on_15) or (dq_tf_30 and on_30) or (dq_tf_60 and on_60))
m90_visible     = show_m90 and ((m90_tf_1 and on_1) or (m90_tf_3 and on_3) or (m90_tf_5 and on_5) or (m90_tf_15 and on_15) or (m90_tf_30 and on_30) or (m90_tf_60 and on_60))
mc_visible      = show_mc and ((mc_tf_1 and on_1) or (mc_tf_3 and on_3) or (mc_tf_5 and on_5) or (mc_tf_15 and on_15) or (mc_tf_30 and on_30) or (mc_tf_60 and on_60))

MIN_MS = 60 * 1000
DAY_MS = 24 * 60 * 60 * 1000
WEEK_MS = 7 * DAY_MS
DAY_SESSION_MS = (23 * 60 - 1) * MIN_MS

pt_min = hour(time, "America/Los_Angeles") * 60 + minute(time, "America/Los_Angeles")
ses_off = pt_min >= 900 ? pt_min - 900 : pt_min + 540
in_trading_day = ses_off <= 1379

pt_y = year(time, "America/Los_Angeles")
pt_m = month(time, "America/Los_Angeles")
pt_dom = dayofmonth(time, "America/Los_Angeles")
pt_dow = dayofweek(time, "America/Los_Angeles")

pt_midnight = timestamp("America/Los_Angeles", pt_y, pt_m, pt_dom, 0, 0)
pt_day_3pm = timestamp("America/Los_Angeles", pt_y, pt_m, pt_dom, 15, 0)

cur_weekly_start = time >= pt_day_3pm ? pt_day_3pm : pt_day_3pm - DAY_MS
cur_weekly_end = cur_weekly_start + DAY_SESSION_MS

cur_month_start = timestamp("America/Los_Angeles", pt_y, pt_m, 1, 0, 0)
next_month_start = pt_m == 12 ? timestamp("America/Los_Angeles", pt_y + 1, 1, 1, 0, 0) : timestamp("America/Los_Angeles", pt_y, pt_m + 1, 1, 0, 0)
cur_month_end = next_month_start - MIN_MS

f_dq() =>
    ses_off < 360 ? 0 : ses_off < 720 ? 1 : ses_off < 1080 ? 2 : 3

f_m90() =>
    math.floor(ses_off / 90)

f_mc() =>
    off_in = ses_off % 90
    mq = off_in < 23 ? 0 : off_in < 45 ? 1 : off_in < 68 ? 2 : 3
    f_m90() * 4 + mq

cur_dq = f_dq()
cur_m90 = f_m90()
cur_mc = f_mc()

var int p_monthly = na
var int monthly_s_time = na
var int monthly_e_time = na
var float c_monthly_h = na
var int c_monthly_ht = na
var float c_monthly_l = na
var int c_monthly_lt = na
var int l_monthly_st = na
var int l_monthly_et = na
var float l_monthly_h = na
var int l_monthly_ht = na
var float l_monthly_l = na
var int l_monthly_lt = na
var line monthly_hl = na
var line monthly_ll = na
var label monthly_hl_lb = na
var label monthly_ll_lb = na
var box monthly_bx = na

if cur_month_start != p_monthly
    if not na(p_monthly)
        l_monthly_st := monthly_s_time
        l_monthly_et := cur_month_start - MIN_MS
        l_monthly_h := c_monthly_h
        l_monthly_ht := c_monthly_ht
        l_monthly_l := c_monthly_l
        l_monthly_lt := c_monthly_lt
    p_monthly := cur_month_start
    monthly_s_time := cur_month_start
    monthly_e_time := cur_month_end
    c_monthly_h := high
    c_monthly_ht := time
    c_monthly_l := low
    c_monthly_lt := time
else
    monthly_e_time := cur_month_end
    if high > c_monthly_h or na(c_monthly_h)
        c_monthly_h := high
        c_monthly_ht := time
    if low < c_monthly_l or na(c_monthly_l)
        c_monthly_l := low
        c_monthly_lt := time

var int p_weekly = na
var int weekly_s_time = na
var int weekly_e_time = na
var float c_weekly_h = na
var int c_weekly_ht = na
var float c_weekly_l = na
var int c_weekly_lt = na
var int l_weekly_st = na
var int l_weekly_et = na
var float l_weekly_h = na
var int l_weekly_ht = na
var float l_weekly_l = na
var int l_weekly_lt = na
var line weekly_hl = na
var line weekly_ll = na
var label weekly_hl_lb = na
var label weekly_ll_lb = na
var box weekly_bx = na

if in_trading_day
    if cur_weekly_start != p_weekly
        if not na(p_weekly)
            l_weekly_st := weekly_s_time
            l_weekly_et := weekly_e_time
            l_weekly_h := c_weekly_h
            l_weekly_ht := c_weekly_ht
            l_weekly_l := c_weekly_l
            l_weekly_lt := c_weekly_lt
        p_weekly := cur_weekly_start
        weekly_s_time := cur_weekly_start
        weekly_e_time := cur_weekly_end
        c_weekly_h := high
        c_weekly_ht := time
        c_weekly_l := low
        c_weekly_lt := time
    else
        weekly_e_time := cur_weekly_end
        if high > c_weekly_h or na(c_weekly_h)
            c_weekly_h := high
            c_weekly_ht := time
        if low < c_weekly_l or na(c_weekly_l)
            c_weekly_l := low
            c_weekly_lt := time

var int p_dq = -1
var int dq_s_bar = na
var int dq_e_bar = na
var float c_dq_h = na
var int c_dq_hb = na
var float c_dq_l = na
var int c_dq_lb = na
var int l_dq_sb = na
var int l_dq_eb = na
var float l_dq_h = na
var int l_dq_hb = na
var float l_dq_l = na
var int l_dq_lb = na
var line dq_hl = na
var line dq_ll = na
var label dq_hl_lb = na
var label dq_ll_lb = na
var box dq_bx = na

if cur_dq != p_dq
    if p_dq >= 0
        l_dq_sb := dq_s_bar
        l_dq_eb := dq_e_bar
        l_dq_h := c_dq_h
        l_dq_hb := c_dq_hb
        l_dq_l := c_dq_l
        l_dq_lb := c_dq_lb
    p_dq := cur_dq
    dq_s_bar := bar_index
    dq_e_bar := bar_index
    c_dq_h := high
    c_dq_hb := bar_index
    c_dq_l := low
    c_dq_lb := bar_index
else
    dq_e_bar := bar_index
    if high > c_dq_h or na(c_dq_h)
        c_dq_h := high
        c_dq_hb := bar_index
    if low < c_dq_l or na(c_dq_l)
        c_dq_l := low
        c_dq_lb := bar_index

var int p_m90 = -1
var int m90_s_bar = na
var int m90_e_bar = na
var float c_m90_h = na
var int c_m90_hb = na
var float c_m90_l = na
var int c_m90_lb = na
var int l_m90_sb = na
var int l_m90_eb = na
var float l_m90_h = na
var int l_m90_hb = na
var float l_m90_l = na
var int l_m90_lb = na
var line m90_hl = na
var line m90_ll = na
var label m90_hl_lb = na
var label m90_ll_lb = na
var box m90_bx = na

if cur_m90 != p_m90
    if p_m90 >= 0
        l_m90_sb := m90_s_bar
        l_m90_eb := m90_e_bar
        l_m90_h := c_m90_h
        l_m90_hb := c_m90_hb
        l_m90_l := c_m90_l
        l_m90_lb := c_m90_lb
    p_m90 := cur_m90
    m90_s_bar := bar_index
    m90_e_bar := bar_index
    c_m90_h := high
    c_m90_hb := bar_index
    c_m90_l := low
    c_m90_lb := bar_index
else
    m90_e_bar := bar_index
    if high > c_m90_h or na(c_m90_h)
        c_m90_h := high
        c_m90_hb := bar_index
    if low < c_m90_l or na(c_m90_l)
        c_m90_l := low
        c_m90_lb := bar_index

var int p_mc = -1
var int mc_s_bar = na
var int mc_e_bar = na
var float c_mc_h = na
var int c_mc_hb = na
var float c_mc_l = na
var int c_mc_lb = na
var int l_mc_sb = na
var int l_mc_eb = na
var float l_mc_h = na
var int l_mc_hb = na
var float l_mc_l = na
var int l_mc_lb = na
var line mc_hl = na
var line mc_ll = na
var label mc_hl_lb = na
var label mc_ll_lb = na
var box mc_bx = na

if cur_mc != p_mc
    if p_mc >= 0
        l_mc_sb := mc_s_bar
        l_mc_eb := mc_e_bar
        l_mc_h := c_mc_h
        l_mc_hb := c_mc_hb
        l_mc_l := c_mc_l
        l_mc_lb := c_mc_lb
    p_mc := cur_mc
    mc_s_bar := bar_index
    mc_e_bar := bar_index
    c_mc_h := high
    c_mc_hb := bar_index
    c_mc_l := low
    c_mc_lb := bar_index
else
    mc_e_bar := bar_index
    if high > c_mc_h or na(c_mc_h)
        c_mc_h := high
        c_mc_hb := bar_index
    if low < c_mc_l or na(c_mc_l)
        c_mc_l := low
        c_mc_lb := bar_index

if barstate.islast
    line.delete(monthly_hl)
    line.delete(monthly_ll)
    label.delete(monthly_hl_lb)
    label.delete(monthly_ll_lb)
    box.delete(monthly_bx)

    line.delete(weekly_hl)
    line.delete(weekly_ll)
    label.delete(weekly_hl_lb)
    label.delete(weekly_ll_lb)
    box.delete(weekly_bx)

    line.delete(dq_hl)
    line.delete(dq_ll)
    label.delete(dq_hl_lb)
    label.delete(dq_ll_lb)
    box.delete(dq_bx)

    line.delete(m90_hl)
    line.delete(m90_ll)
    label.delete(m90_hl_lb)
    label.delete(m90_ll_lb)
    box.delete(m90_bx)

    line.delete(mc_hl)
    line.delete(mc_ll)
    label.delete(mc_hl_lb)
    label.delete(mc_ll_lb)
    box.delete(mc_bx)

    if monthly_visible and not na(l_monthly_h) and not na(l_monthly_l)
        monthly_bx := box.new(l_monthly_st, l_monthly_h, l_monthly_et, l_monthly_l, xloc=xloc.bar_time, border_color=color.new(col_monthly, 70), bgcolor=color.new(col_monthly, 85), border_width=1)
        monthly_hl := line.new(l_monthly_ht, l_monthly_h, cur_month_end, l_monthly_h, xloc=xloc.bar_time, color=col_kz_monthly, width=lw_monthly)
        monthly_ll := line.new(l_monthly_lt, l_monthly_l, cur_month_end, l_monthly_l, xloc=xloc.bar_time, color=col_kz_monthly, width=lw_monthly)
        monthly_hl_lb := label.new(time, l_monthly_h, monthly_high_txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_monthly, size=lbl_size)
        monthly_ll_lb := label.new(time, l_monthly_l, monthly_low_txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_monthly, size=lbl_size)

    if weekly_visible and not na(l_weekly_h) and not na(l_weekly_l)
        weekly_bx := box.new(l_weekly_st, l_weekly_h, l_weekly_et, l_weekly_l, xloc=xloc.bar_time, border_color=color.new(col_weekly, 70), bgcolor=color.new(col_weekly, 85), border_width=1)
        weekly_hl := line.new(l_weekly_ht, l_weekly_h, cur_weekly_end, l_weekly_h, xloc=xloc.bar_time, color=col_kz_weekly, width=lw_weekly)
        weekly_ll := line.new(l_weekly_lt, l_weekly_l, cur_weekly_end, l_weekly_l, xloc=xloc.bar_time, color=col_kz_weekly, width=lw_weekly)
        weekly_hl_lb := label.new(time, l_weekly_h, weekly_high_txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_weekly, size=lbl_size)
        weekly_ll_lb := label.new(time, l_weekly_l, weekly_low_txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_weekly, size=lbl_size)

    if dq_visible and not na(l_dq_h) and not na(l_dq_l)
        dq_bx := box.new(l_dq_sb, l_dq_h, l_dq_eb, l_dq_l, border_color=color.new(col_dq, 70), bgcolor=color.new(col_dq, 85), border_width=1)
        dq_hl := line.new(l_dq_hb, l_dq_h, bar_index, l_dq_h, color=col_kz_dq, width=lw_dq)
        dq_ll := line.new(l_dq_lb, l_dq_l, bar_index, l_dq_l, color=col_kz_dq, width=lw_dq)
        dq_hl_lb := label.new(bar_index, l_dq_h, dq_high_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_dq, size=lbl_size)
        dq_ll_lb := label.new(bar_index, l_dq_l, dq_low_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_dq, size=lbl_size)

    if m90_visible and not na(l_m90_h) and not na(l_m90_l)
        m90_bx := box.new(l_m90_sb, l_m90_h, l_m90_eb, l_m90_l, border_color=color.new(col_m90, 70), bgcolor=color.new(col_m90, 85), border_width=1)
        m90_hl := line.new(l_m90_hb, l_m90_h, bar_index, l_m90_h, color=col_kz_m90, width=lw_m90)
        m90_ll := line.new(l_m90_lb, l_m90_l, bar_index, l_m90_l, color=col_kz_m90, width=lw_m90)
        m90_hl_lb := label.new(bar_index, l_m90_h, m90_high_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_m90, size=lbl_size)
        m90_ll_lb := label.new(bar_index, l_m90_l, m90_low_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_m90, size=lbl_size)

    if mc_visible and not na(l_mc_h) and not na(l_mc_l)
        mc_bx := box.new(l_mc_sb, l_mc_h, l_mc_eb, l_mc_l, border_color=color.new(col_mc, 70), bgcolor=color.new(col_mc, 85), border_width=1)
        mc_hl := line.new(l_mc_hb, l_mc_h, bar_index, l_mc_h, color=col_kz_mc, width=lw_mc)
        mc_ll := line.new(l_mc_lb, l_mc_l, bar_index, l_mc_l, color=col_kz_mc, width=lw_mc)
        mc_hl_lb := label.new(bar_index, l_mc_h, mc_high_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_mc, size=lbl_size)
        mc_ll_lb := label.new(bar_index, l_mc_l, mc_low_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=col_kz_mc, size=lbl_size)
````
