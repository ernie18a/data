# MBFX Key Levels 

- url: https://www.tradingview.com/script/PDhgobc9-MBFX-Key-Levels/
- type: indicator
- pine_id: PUB;5652031a77ba4ca3b68c8d4d221f18c9
- version: 1.0

## Description

Multi-Timeframe Opens & Previous High/Low Levels

This indicator plots clean multi-timeframe reference levels to help traders track important market structure without clutter.

It displays the current Daily, Weekly, Monthly, and 4H opens, along with the previous Daily, Weekly, and Monthly highs and lows.

The indicator does not plot current highs or lows.
For the active/current period, it only shows the open level.

What This Indicator Displays

Daily Open
Weekly Open
Monthly Open
4H Open

Previous Day High
Previous Day Low

Previous Week High
Previous Week Low

Previous Month High
Previous Month Low

Abbreviation Guide

DO = Daily Open
WO = Weekly Open
MO = Monthly Open
H4O = 4 Hour Open

PDH = Previous Day High
PDL = Previous Day Low

PWH = Previous Week High
PWL = Previous Week Low

PMH = Previous Month High
PML = Previous Month Low

How Traders Can Use It

Identify key liquidity levels
Track previous highs and lows
Build intraday bias from higher-timeframe levels
Watch price reactions around opens
Use previous period levels as support/resistance references

## Source Code

````pine
// ©️ MBFX Key Levels Indicator
//@version=6
indicator("MBFX Key Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════
//  TIMEFRAME DETECTION
// ══════════════════════════════════════════════════════════════════
tf_secs    = timeframe.in_seconds()
is_monthly = tf_secs >= 2592000
is_weekly  = tf_secs >= 604800  and tf_secs < 2592000
is_daily   = tf_secs >= 86400   and tf_secs < 604800
is_4h      = tf_secs >= 14400   and tf_secs < 86400
is_1h_30m  = tf_secs >= 1800    and tf_secs < 14400
is_15m     = tf_secs >= 900     and tf_secs < 1800
is_5m      = tf_secs >= 300     and tf_secs < 900
is_below5  = tf_secs < 300

// ══════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════
f_style(s) =>
    s == 1 ? line.style_dashed : s == 2 ? line.style_dotted : line.style_solid

f_line(x1, price, x2, col, w, s) =>
    line.new(x1, price, x2, price, color=col, width=w, style=f_style(s))

f_label(x, price, txt, tcol) =>
    label.new(x, price, txt,
              color=color.new(color.black, 100),
              textcolor=tcol,
              style=label.style_label_left,
              size=size.small)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — MONTHLY OPEN
// ══════════════════════════════════════════════════════════════════
grp_mo = "Monthly Open (MO)"
show_mo         = input.bool(true, "Show MO",             group=grp_mo)
mo_line_color   = input.color(color.new(color.orange, 0), "Line Color",  group=grp_mo)
mo_text_color   = input.color(color.new(color.orange, 0), "Text Color",  group=grp_mo)
mo_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_mo)
mo_width        = input.int(2, "Width", minval=1, maxval=4, group=grp_mo)
mo_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_mo)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — PREV MONTHLY HIGH / LOW
// ══════════════════════════════════════════════════════════════════
grp_pm = "Prev Monthly High/Low (PMH/PML)"
show_pmh        = input.bool(true, "Show PMH",            group=grp_pm)
show_pml        = input.bool(true, "Show PML",            group=grp_pm)
pm_bars         = input.int(1, "Months Back", minval=1, maxval=3, group=grp_pm)
pmh_line_color  = input.color(color.new(color.lime, 0),   "PMH Line Color", group=grp_pm)
pmh_text_color  = input.color(color.new(color.lime, 0),   "PMH Text Color", group=grp_pm)
pml_line_color  = input.color(color.new(color.maroon, 0), "PML Line Color", group=grp_pm)
pml_text_color  = input.color(color.new(color.maroon, 0), "PML Text Color", group=grp_pm)
pm_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_pm)
pm_width        = input.int(1, "Width", minval=1, maxval=4, group=grp_pm)
pm_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_pm)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — WEEKLY OPEN
// ══════════════════════════════════════════════════════════════════
grp_wo = "Weekly Open (WO)"
show_wo         = input.bool(true, "Show WO",             group=grp_wo)
wo_line_color   = input.color(color.new(color.blue, 0),   "Line Color",  group=grp_wo)
wo_text_color   = input.color(color.new(color.blue, 0),   "Text Color",  group=grp_wo)
wo_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_wo)
wo_width        = input.int(2, "Width", minval=1, maxval=4, group=grp_wo)
wo_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_wo)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — PREV WEEKLY HIGH / LOW
// ══════════════════════════════════════════════════════════════════
grp_pw = "Prev Weekly High/Low (PWH/PWL)"
show_pwh        = input.bool(true, "Show PWH",            group=grp_pw)
show_pwl        = input.bool(true, "Show PWL",            group=grp_pw)
pw_bars         = input.int(1, "Weeks Back", minval=1, maxval=4, group=grp_pw)
pwh_line_color  = input.color(color.new(color.green, 0),  "PWH Line Color", group=grp_pw)
pwh_text_color  = input.color(color.new(color.green, 0),  "PWH Text Color", group=grp_pw)
pwl_line_color  = input.color(color.new(color.red, 0),    "PWL Line Color", group=grp_pw)
pwl_text_color  = input.color(color.new(color.red, 0),    "PWL Text Color", group=grp_pw)
pw_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_pw)
pw_width        = input.int(1, "Width", minval=1, maxval=4, group=grp_pw)
pw_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_pw)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — DAILY OPEN
// ══════════════════════════════════════════════════════════════════
grp_do = "Daily Open (DO)"
show_do         = input.bool(true, "Show DO",             group=grp_do)
do_line_color   = input.color(color.new(color.white, 0),  "Line Color",  group=grp_do)
do_text_color   = input.color(color.new(color.white, 0),  "Text Color",  group=grp_do)
do_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_do)
do_width        = input.int(1, "Width", minval=1, maxval=4, group=grp_do)
do_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_do)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — PREV DAILY HIGH / LOW
// ══════════════════════════════════════════════════════════════════
grp_pd = "Prev Daily High/Low (PDH/PDL)"
show_pdh        = input.bool(true, "Show PDH",             group=grp_pd)
show_pdl        = input.bool(true, "Show PDL",             group=grp_pd)
pd_days         = input.int(1, "Days Back", minval=1, maxval=5, group=grp_pd)
pdh_line_color  = input.color(color.new(color.aqua, 0),    "PDH Line Color", group=grp_pd)
pdh_text_color  = input.color(color.new(color.aqua, 0),    "PDH Text Color", group=grp_pd)
pdl_line_color  = input.color(color.new(color.fuchsia, 0), "PDL Line Color", group=grp_pd)
pdl_text_color  = input.color(color.new(color.fuchsia, 0), "PDL Text Color", group=grp_pd)
pd_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_pd)
pd_width        = input.int(1, "Width", minval=1, maxval=4, group=grp_pd)
pd_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_pd)

// ══════════════════════════════════════════════════════════════════
//  INPUTS — 4H LEVELS
// ══════════════════════════════════════════════════════════════════
grp_4h = "4H Open / High / Low"
show_4h_open    = input.bool(true, "Show 4H Open",          group=grp_4h)
show_4h_high    = input.bool(true, "Show 4H High",          group=grp_4h)
show_4h_low     = input.bool(true, "Show 4H Low",           group=grp_4h)
h4o_line_color  = input.color(color.new(color.yellow, 0),   "Open Line Color", group=grp_4h)
h4o_text_color  = input.color(color.new(color.yellow, 0),   "Open Text Color", group=grp_4h)
h4h_line_color  = input.color(color.new(color.teal, 0),     "High Line Color", group=grp_4h)
h4h_text_color  = input.color(color.new(color.teal, 0),     "High Text Color", group=grp_4h)
h4l_line_color  = input.color(color.new(color.purple, 0),   "Low Line Color",  group=grp_4h)
h4l_text_color  = input.color(color.new(color.purple, 0),   "Low Text Color",  group=grp_4h)
h4_style        = input.int(1, "0=Solid 1=Dashed 2=Dotted", minval=0, maxval=2, group=grp_4h)
h4_width        = input.int(1, "Width", minval=1, maxval=4, group=grp_4h)
h4_extend_right = input.int(5, "Extend Right", minval=0, maxval=300, group=grp_4h)

// ══════════════════════════════════════════════════════════════════
//  ALL PRICES VIA REQUEST.SECURITY — SINGLE SOURCE OF TRUTH
//  This ensures prices are identical on ALL timeframes
// ══════════════════════════════════════════════════════════════════

// Monthly
mo_open  = request.security(syminfo.tickerid, "M", open,    lookahead=barmerge.lookahead_on)
pm1_h_v  = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pm1_l_v  = request.security(syminfo.tickerid, "M", low[1],  lookahead=barmerge.lookahead_on)
pm2_h_v  = request.security(syminfo.tickerid, "M", high[2], lookahead=barmerge.lookahead_on)
pm2_l_v  = request.security(syminfo.tickerid, "M", low[2],  lookahead=barmerge.lookahead_on)
pm3_h_v  = request.security(syminfo.tickerid, "M", high[3], lookahead=barmerge.lookahead_on)
pm3_l_v  = request.security(syminfo.tickerid, "M", low[3],  lookahead=barmerge.lookahead_on)

// Weekly
wo_open  = request.security(syminfo.tickerid, "W", open,    lookahead=barmerge.lookahead_on)
pw1_h_v  = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pw1_l_v  = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)
pw2_h_v  = request.security(syminfo.tickerid, "W", high[2], lookahead=barmerge.lookahead_on)
pw2_l_v  = request.security(syminfo.tickerid, "W", low[2],  lookahead=barmerge.lookahead_on)
pw3_h_v  = request.security(syminfo.tickerid, "W", high[3], lookahead=barmerge.lookahead_on)
pw3_l_v  = request.security(syminfo.tickerid, "W", low[3],  lookahead=barmerge.lookahead_on)
pw4_h_v  = request.security(syminfo.tickerid, "W", high[4], lookahead=barmerge.lookahead_on)
pw4_l_v  = request.security(syminfo.tickerid, "W", low[4],  lookahead=barmerge.lookahead_on)

// Daily
do_open  = request.security(syminfo.tickerid, "D", open,    lookahead=barmerge.lookahead_on)
pd1_h_v  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd1_l_v  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pd2_h_v  = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_on)
pd2_l_v  = request.security(syminfo.tickerid, "D", low[2],  lookahead=barmerge.lookahead_on)
pd3_h_v  = request.security(syminfo.tickerid, "D", high[3], lookahead=barmerge.lookahead_on)
pd3_l_v  = request.security(syminfo.tickerid, "D", low[3],  lookahead=barmerge.lookahead_on)
pd4_h_v  = request.security(syminfo.tickerid, "D", high[4], lookahead=barmerge.lookahead_on)
pd4_l_v  = request.security(syminfo.tickerid, "D", low[4],  lookahead=barmerge.lookahead_on)
pd5_h_v  = request.security(syminfo.tickerid, "D", high[5], lookahead=barmerge.lookahead_on)
pd5_l_v  = request.security(syminfo.tickerid, "D", low[5],  lookahead=barmerge.lookahead_on)

// 4H
h4_open_val = request.security(syminfo.tickerid, "240", open, lookahead=barmerge.lookahead_off)
h4_high_val = request.security(syminfo.tickerid, "240", high, lookahead=barmerge.lookahead_off)
h4_low_val  = request.security(syminfo.tickerid, "240", low,  lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════
//  LINE START BARS — tracked on current chart bar_index
// ══════════════════════════════════════════════════════════════════
is_new_month = ta.change(time("M")) != 0
is_new_week  = ta.change(time("W")) != 0
is_new_day   = ta.change(time("D")) != 0
is_new_4h    = ta.change(time("240")) != 0

var int mo_start_bar = 0
var int wo_start_bar = 0
var int do_start_bar = 0
var int h4_start_bar = 0
var int pm1_start    = 0
var int pm2_start    = 0
var int pm3_start    = 0
var int pw1_start    = 0
var int pw2_start    = 0
var int pw3_start    = 0
var int pw4_start    = 0
var int pd1_start    = 0
var int pd2_start    = 0
var int pd3_start    = 0
var int pd4_start    = 0
var int pd5_start    = 0

if is_new_month or bar_index == 0
    pm3_start    := pm2_start
    pm2_start    := pm1_start
    pm1_start    := mo_start_bar
    mo_start_bar := bar_index

if is_new_week or bar_index == 0
    pw4_start    := pw3_start
    pw3_start    := pw2_start
    pw2_start    := pw1_start
    pw1_start    := wo_start_bar
    wo_start_bar := bar_index

if is_new_day or bar_index == 0
    pd5_start    := pd4_start
    pd4_start    := pd3_start
    pd3_start    := pd2_start
    pd2_start    := pd1_start
    pd1_start    := do_start_bar
    do_start_bar := bar_index

if is_new_4h or bar_index == 0
    h4_start_bar := bar_index

// ══════════════════════════════════════════════════════════════════
//  VISIBILITY RULES
// ══════════════════════════════════════════════════════════════════
can_monthly = is_monthly or is_weekly or is_daily or is_4h or is_1h_30m
can_weekly  = is_weekly  or is_daily  or is_4h    or is_1h_30m
can_daily   = is_daily   or is_4h     or is_1h_30m or is_15m or is_5m
can_4h      = is_4h      or is_1h_30m or is_15m   or is_5m

// ══════════════════════════════════════════════════════════════════
//  DRAW ON LAST BAR
// ══════════════════════════════════════════════════════════════════
if barstate.islast and not is_below5
    int now = bar_index

    // ── MONTHLY OPEN
    if show_mo and can_monthly
        f_line(mo_start_bar, mo_open, now + mo_extend_right, mo_line_color, mo_width, mo_style)
        f_label(now + mo_extend_right, mo_open, "MO", mo_text_color)

    // ── PREV MONTHLY HIGH / LOW
    if can_monthly
        pm_highs  = array.from(pm1_h_v, pm2_h_v, pm3_h_v)
        pm_lows   = array.from(pm1_l_v, pm2_l_v, pm3_l_v)
        pm_starts = array.from(pm1_start, pm2_start, pm3_start)
        for i = 0 to pm_bars - 1
            x1     = array.get(pm_starts, i)
            suffix = i == 0 ? "" : " (" + str.tostring(i + 1) + "M ago)"
            if show_pmh
                f_line(x1, array.get(pm_highs, i), now + pm_extend_right, pmh_line_color, pm_width, pm_style)
                f_label(now + pm_extend_right, array.get(pm_highs, i), "PMH" + suffix, pmh_text_color)
            if show_pml
                f_line(x1, array.get(pm_lows, i), now + pm_extend_right, pml_line_color, pm_width, pm_style)
                f_label(now + pm_extend_right, array.get(pm_lows, i), "PML" + suffix, pml_text_color)

    // ── WEEKLY OPEN
    if show_wo and can_weekly
        f_line(wo_start_bar, wo_open, now + wo_extend_right, wo_line_color, wo_width, wo_style)
        f_label(now + wo_extend_right, wo_open, "WO", wo_text_color)

    // ── PREV WEEKLY HIGH / LOW
    if can_weekly
        pw_highs  = array.from(pw1_h_v, pw2_h_v, pw3_h_v, pw4_h_v)
        pw_lows   = array.from(pw1_l_v, pw2_l_v, pw3_l_v, pw4_l_v)
        pw_starts = array.from(pw1_start, pw2_start, pw3_start, pw4_start)
        for i = 0 to pw_bars - 1
            x1     = array.get(pw_starts, i)
            suffix = i == 0 ? "" : " (" + str.tostring(i + 1) + "W ago)"
            if show_pwh
                f_line(x1, array.get(pw_highs, i), now + pw_extend_right, pwh_line_color, pw_width, pw_style)
                f_label(now + pw_extend_right, array.get(pw_highs, i), "PWH" + suffix, pwh_text_color)
            if show_pwl
                f_line(x1, array.get(pw_lows, i), now + pw_extend_right, pwl_line_color, pw_width, pw_style)
                f_label(now + pw_extend_right, array.get(pw_lows, i), "PWL" + suffix, pwl_text_color)

    // ── DAILY OPEN
    if show_do and can_daily
        f_line(do_start_bar, do_open, now + do_extend_right, do_line_color, do_width, do_style)
        f_label(now + do_extend_right, do_open, "DO", do_text_color)

    // ── PREV DAILY HIGH / LOW
    if can_daily
        pd_highs  = array.from(pd1_h_v, pd2_h_v, pd3_h_v, pd4_h_v, pd5_h_v)
        pd_lows   = array.from(pd1_l_v, pd2_l_v, pd3_l_v, pd4_l_v, pd5_l_v)
        pd_starts = array.from(pd1_start, pd2_start, pd3_start, pd4_start, pd5_start)
        for i = 0 to pd_days - 1
            x1     = array.get(pd_starts, i)
            suffix = i == 0 ? "" : " (" + str.tostring(i + 1) + "D ago)"
            if show_pdh
                f_line(x1, array.get(pd_highs, i), now + pd_extend_right, pdh_line_color, pd_width, pd_style)
                f_label(now + pd_extend_right, array.get(pd_highs, i), "PDH" + suffix, pdh_text_color)
            if show_pdl
                f_line(x1, array.get(pd_lows, i), now + pd_extend_right, pdl_line_color, pd_width, pd_style)
                f_label(now + pd_extend_right, array.get(pd_lows, i), "PDL" + suffix, pdl_text_color)

    // ── 4H OPEN / HIGH / LOW
    if can_4h
        if show_4h_open
            f_line(h4_start_bar, h4_open_val, now + h4_extend_right, h4o_line_color, h4_width, h4_style)
            f_label(now + h4_extend_right, h4_open_val, "4HO", h4o_text_color)
        if show_4h_high
            f_line(h4_start_bar, h4_high_val, now + h4_extend_right, h4h_line_color, h4_width, h4_style)
            f_label(now + h4_extend_right, h4_high_val, "4HH", h4h_text_color)
        if show_4h_low
            f_line(h4_start_bar, h4_low_val, now + h4_extend_right, h4l_line_color, h4_width, h4_style)
            f_label(now + h4_extend_right, h4_low_val, "4HL", h4l_text_color)
````
