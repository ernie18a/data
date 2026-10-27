# 3n levels

- url: https://www.tradingview.com/script/JrVf0xLb-3n-levels/
- type: indicator
- pine_id: PUB;708571fde438443aa78f2865695cb699
- version: 3.0

## Description

Script i want to use in tradesviz
Includes daily open
Ny midnight
Previous day low
Previous day high
NYO highlighter

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © custom_levels_script

//@version=6
indicator("NYC Key Levels", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=500)

// ─────────────────────────────────────────────
//  SETTINGS — Daily Levels
// ─────────────────────────────────────────────
grp_daily = "── Daily Levels ──"
show_prev_day_high = input.bool(true,  "Previous Day High",          group=grp_daily, inline="pdh")
col_prev_day_high  = input.color(color.new(#00E5FF, 0), "",          group=grp_daily, inline="pdh")
show_prev_day_low  = input.bool(true,  "Previous Day Low",           group=grp_daily, inline="pdl")
col_prev_day_low   = input.color(color.new(#FF1744, 0), "",          group=grp_daily, inline="pdl")
show_prev_day_open = input.bool(true,  "Previous Day Open",          group=grp_daily, inline="pdo")
col_prev_day_open  = input.color(color.new(#FFD600, 0), "",          group=grp_daily, inline="pdo")
show_today_open    = input.bool(true,  "Today's Open (8pm ET)",      group=grp_daily, inline="to")
col_today_open     = input.color(color.new(#69FF47, 0), "",          group=grp_daily, inline="to")
show_nyo_midnight  = input.bool(true,  "NY Midnight Open (12am ET)", group=grp_daily, inline="nyo")
col_nyo_midnight   = input.color(color.new(#FF9100, 0), "",          group=grp_daily, inline="nyo")

// ─────────────────────────────────────────────
//  SETTINGS — Weekly Levels
// ─────────────────────────────────────────────
grp_weekly = "── Weekly Levels ──"
show_prev_week_high  = input.bool(true,  "Previous Week High",        group=grp_weekly, inline="pwh")
col_prev_week_high   = input.color(color.new(#E040FB, 0), "",         group=grp_weekly, inline="pwh")
show_prev_week_low   = input.bool(true,  "Previous Week Low",         group=grp_weekly, inline="pwl")
col_prev_week_low    = input.color(color.new(#F48FB1, 0), "",         group=grp_weekly, inline="pwl")
show_prev_week_close = input.bool(true,  "Previous Week Close",       group=grp_weekly, inline="pwc")
col_prev_week_close  = input.color(color.new(#B0BEC5, 0), "",         group=grp_weekly, inline="pwc")
show_prev_week_open  = input.bool(true,  "Previous Week Open",        group=grp_weekly, inline="pwo")
col_prev_week_open   = input.color(color.new(#80CBC4, 0), "",         group=grp_weekly, inline="pwo")
show_curr_week_high  = input.bool(true,  "Current Week High",         group=grp_weekly, inline="cwh")
col_curr_week_high   = input.color(color.new(#CE93D8, 0), "",         group=grp_weekly, inline="cwh")
show_curr_week_low   = input.bool(true,  "Current Week Low",          group=grp_weekly, inline="cwl")
col_curr_week_low    = input.color(color.new(#F8BBD9, 0), "",         group=grp_weekly, inline="cwl")
show_curr_week_open  = input.bool(true,  "Current Week Open",         group=grp_weekly, inline="cwo")
col_curr_week_open   = input.color(color.new(#A5D6A7, 0), "",         group=grp_weekly, inline="cwo")

// ─────────────────────────────────────────────
//  SETTINGS — London Session
// ─────────────────────────────────────────────
grp_london = "── London Session (3am–6:30am ET) ──"
show_london_high = input.bool(true,  "London Session High", group=grp_london, inline="lh")
col_london_high  = input.color(color.new(#FFB300, 0), "",   group=grp_london, inline="lh")
show_london_low  = input.bool(true,  "London Session Low",  group=grp_london, inline="ll")
col_london_low   = input.color(color.new(#FF6F00, 0), "",   group=grp_london, inline="ll")

// ─────────────────────────────────────────────
//  SETTINGS — NY Open Session Box
// ─────────────────────────────────────────────
grp_nybox = "── NY Open Session Box (9:30am–12:00pm ET) ──"
show_ny_box     = input.bool(true,  "Show NY Open Boxes (all history)", group=grp_nybox, inline="nyb")
col_ny_box      = input.color(color.new(#2962FF, 85), "Weekday color",  group=grp_nybox, inline="nyb")
col_ny_box_wknd = input.color(color.new(#7B1FA2, 85), "Weekend color",  group=grp_nybox, inline="nyb")

// ─────────────────────────────────────────────
//  SETTINGS — NY Equities Open Line (9:30am–4pm)
// ─────────────────────────────────────────────
grp_nyline = "── NY Equities Open Line (9:30am–4:00pm ET) ──"
show_ny_open_line = input.bool(true,  "NY Open (9:30am)",  group=grp_nyline, inline="nyl")
col_ny_open_line  = input.color(color.new(#E040FB, 0), "", group=grp_nyline, inline="nyl")

line_width = input.int(1, "Line Width", minval=1, maxval=4, group="── Style ──")

// ─────────────────────────────────────────────
//  TIMEZONE HELPERS
// ─────────────────────────────────────────────
et_hour   = hour(time, "America/New_York")
et_minute = minute(time, "America/New_York")
et_time   = et_hour * 100 + et_minute

et_dow     = dayofweek(time, "America/New_York")
is_weekend = et_dow == dayofweek.saturday or et_dow == dayofweek.sunday

is_nyc_day_open  = et_hour == 20 and et_minute == 0
is_midnight      = et_hour == 0  and et_minute == 0
is_london_start  = et_hour == 3  and et_minute == 0
in_london        = et_time >= 300  and et_time <= 630
is_ny_open_start = et_hour == 9  and et_minute == 30
in_ny_open       = et_time >= 930  and et_time <= 1200   // extended to 12:00pm
is_ny_close      = et_hour == 16 and et_minute == 0

// ─────────────────────────────────────────────
//  DAILY / WEEKLY DATA
// ─────────────────────────────────────────────
[d_open, d_high, d_low, d_close] = request.security(syminfo.tickerid, "D",
     [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
d_open_today = request.security(syminfo.tickerid, "D",
     open, lookahead=barmerge.lookahead_on)

// Previous week OHLC
[w_open, w_high, w_low, w_close] = request.security(syminfo.tickerid, "W",
     [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// Current week running high/low/open
// open on the current weekly bar = this week's open
cw_open  = request.security(syminfo.tickerid, "W", open,  lookahead=barmerge.lookahead_on)
cw_high  = request.security(syminfo.tickerid, "W", high,  lookahead=barmerge.lookahead_on)
cw_low   = request.security(syminfo.tickerid, "W", low,   lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
//  DRAW HELPERS
// ─────────────────────────────────────────────
f_line(line ln, float price, color clr, bool show) =>
    line result = ln
    if show
        if na(result)
            result := line.new(time, price, time + 1, price,
                 xloc=xloc.bar_time, extend=extend.right,
                 color=clr, width=line_width, style=line.style_dashed)
        else
            line.set_y1(result, price)
            line.set_y2(result, price)
            line.set_color(result, clr)
            line.set_width(result, line_width)
    else
        if not na(result)
            line.delete(result)
            result := na
    result

f_label(label lb, float price, color clr, bool show, string txt) =>
    label result = lb
    if show
        if na(result)
            result := label.new(bar_index + 2, price, txt,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 style=label.style_label_left,
                 color=color.new(clr, 90),
                 textcolor=clr, size=size.small)
        else
            label.set_x(result, bar_index + 2)
            label.set_y(result, price)
            label.set_textcolor(result, clr)
            label.set_color(result, color.new(clr, 90))
    else
        if not na(result)
            label.delete(result)
            result := na
    result

// ─────────────────────────────────────────────
//  PERSISTENT STATE — Daily
// ─────────────────────────────────────────────
var line  l_pdh  = na
var label lb_pdh = na
var line  l_pdl  = na
var label lb_pdl = na
var line  l_pdo  = na
var label lb_pdo = na
var line  l_to   = na
var label lb_to  = na
var line  l_nyo         = na
var label lb_nyo        = na
var float midnight_open = na

var line  l_lh        = na
var label lb_lh       = na
var line  l_ll        = na
var label lb_ll       = na
var float london_high = na
var float london_low  = na
var bool  london_done = false

// ─────────────────────────────────────────────
//  PERSISTENT STATE — Weekly
// ─────────────────────────────────────────────
var line  l_pwh  = na
var label lb_pwh = na
var line  l_pwl  = na
var label lb_pwl = na
var line  l_pwc  = na
var label lb_pwc = na
var line  l_pwo  = na
var label lb_pwo = na
var line  l_cwh  = na
var label lb_cwh = na
var line  l_cwl  = na
var label lb_cwl = na
var line  l_cwo  = na
var label lb_cwo = na

// ─────────────────────────────────────────────
//  PERSISTENT STATE — NY session
// ─────────────────────────────────────────────
var line  l_ny_open_line  = na
var label lb_ny_open_line = na
var float ny_open_price   = na
var bool  ny_line_active  = false
var box   ny_box_cur      = na

// ─────────────────────────────────────────────
//  DAILY LEVELS — reset at 8pm ET
// ─────────────────────────────────────────────
if is_nyc_day_open
    if not na(l_pdh)
        line.delete(l_pdh)
    if not na(lb_pdh)
        label.delete(lb_pdh)
    if not na(l_pdl)
        line.delete(l_pdl)
    if not na(lb_pdl)
        label.delete(lb_pdl)
    if not na(l_pdo)
        line.delete(l_pdo)
    if not na(lb_pdo)
        label.delete(lb_pdo)
    if not na(l_to)
        line.delete(l_to)
    if not na(lb_to)
        label.delete(lb_to)
    if not na(l_lh)
        line.delete(l_lh)
    if not na(lb_lh)
        label.delete(lb_lh)
    if not na(l_ll)
        line.delete(l_ll)
    if not na(lb_ll)
        label.delete(lb_ll)
    l_pdh  := na
    lb_pdh := na
    l_pdl  := na
    lb_pdl := na
    l_pdo  := na
    lb_pdo := na
    l_to   := na
    lb_to  := na
    l_lh   := na
    lb_lh  := na
    l_ll   := na
    lb_ll  := na
    london_high := na
    london_low  := na
    london_done := false

l_pdh  := f_line( l_pdh,  d_high,       col_prev_day_high,  show_prev_day_high)
lb_pdh := f_label(lb_pdh, d_high,       col_prev_day_high,  show_prev_day_high,  "PD High")
l_pdl  := f_line( l_pdl,  d_low,        col_prev_day_low,   show_prev_day_low)
lb_pdl := f_label(lb_pdl, d_low,        col_prev_day_low,   show_prev_day_low,   "PD Low")
l_pdo  := f_line( l_pdo,  d_open,       col_prev_day_open,  show_prev_day_open)
lb_pdo := f_label(lb_pdo, d_open,       col_prev_day_open,  show_prev_day_open,  "PD Open")
l_to   := f_line( l_to,   d_open_today, col_today_open,     show_today_open)
lb_to  := f_label(lb_to,  d_open_today, col_today_open,     show_today_open,     "D Open")

// ─────────────────────────────────────────────
//  MIDNIGHT OPEN — 12:00 AM ET
// ─────────────────────────────────────────────
if is_midnight
    midnight_open := open
    if not na(l_nyo)
        line.delete(l_nyo)
    if not na(lb_nyo)
        label.delete(lb_nyo)
    l_nyo  := na
    lb_nyo := na

if not na(midnight_open)
    l_nyo  := f_line( l_nyo,  midnight_open, col_nyo_midnight, show_nyo_midnight)
    lb_nyo := f_label(lb_nyo, midnight_open, col_nyo_midnight, show_nyo_midnight, "NY Midnight")

// ─────────────────────────────────────────────
//  WEEKLY LEVELS — reset at week open
// ─────────────────────────────────────────────
bool is_week_open = ta.change(time("W")) != 0

if is_week_open
    if not na(l_pwh)
        line.delete(l_pwh)
    if not na(lb_pwh)
        label.delete(lb_pwh)
    if not na(l_pwl)
        line.delete(l_pwl)
    if not na(lb_pwl)
        label.delete(lb_pwl)
    if not na(l_pwc)
        line.delete(l_pwc)
    if not na(lb_pwc)
        label.delete(lb_pwc)
    if not na(l_pwo)
        line.delete(l_pwo)
    if not na(lb_pwo)
        label.delete(lb_pwo)
    if not na(l_cwh)
        line.delete(l_cwh)
    if not na(lb_cwh)
        label.delete(lb_cwh)
    if not na(l_cwl)
        line.delete(l_cwl)
    if not na(lb_cwl)
        label.delete(lb_cwl)
    if not na(l_cwo)
        line.delete(l_cwo)
    if not na(lb_cwo)
        label.delete(lb_cwo)
    l_pwh  := na
    lb_pwh := na
    l_pwl  := na
    lb_pwl := na
    l_pwc  := na
    lb_pwc := na
    l_pwo  := na
    lb_pwo := na
    l_cwh  := na
    lb_cwh := na
    l_cwl  := na
    lb_cwl := na
    l_cwo  := na
    lb_cwo := na

// Previous week levels — static once drawn
l_pwh  := f_line( l_pwh,  w_high,  col_prev_week_high,  show_prev_week_high)
lb_pwh := f_label(lb_pwh, w_high,  col_prev_week_high,  show_prev_week_high,  "PW High")
l_pwl  := f_line( l_pwl,  w_low,   col_prev_week_low,   show_prev_week_low)
lb_pwl := f_label(lb_pwl, w_low,   col_prev_week_low,   show_prev_week_low,   "PW Low")
l_pwc  := f_line( l_pwc,  w_close, col_prev_week_close, show_prev_week_close)
lb_pwc := f_label(lb_pwc, w_close, col_prev_week_close, show_prev_week_close, "PW Close")
l_pwo  := f_line( l_pwo,  w_open,  col_prev_week_open,  show_prev_week_open)
lb_pwo := f_label(lb_pwo, w_open,  col_prev_week_open,  show_prev_week_open,  "PW Open")

// Current week levels — update live as the week develops
l_cwh  := f_line( l_cwh,  cw_high, col_curr_week_high,  show_curr_week_high)
lb_cwh := f_label(lb_cwh, cw_high, col_curr_week_high,  show_curr_week_high,  "CW High")
l_cwl  := f_line( l_cwl,  cw_low,  col_curr_week_low,   show_curr_week_low)
lb_cwl := f_label(lb_cwl, cw_low,  col_curr_week_low,   show_curr_week_low,   "CW Low")
l_cwo  := f_line( l_cwo,  cw_open, col_curr_week_open,  show_curr_week_open)
lb_cwo := f_label(lb_cwo, cw_open, col_curr_week_open,  show_curr_week_open,  "CW Open")

// ─────────────────────────────────────────────
//  LONDON SESSION HIGH / LOW
//  3:00 AM → 6:30 AM ET — lines freeze after session
// ─────────────────────────────────────────────
if is_london_start
    london_high := high
    london_low  := low
    london_done := false

if in_london and not london_done
    london_high := math.max(nz(london_high, high), high)
    london_low  := math.min(nz(london_low,  low),  low)

if et_time == 631 and not london_done
    london_done := true

if in_london or london_done
    if show_london_high and not na(london_high)
        if na(l_lh)
            l_lh  := line.new(time, london_high, time + 1, london_high,
                 xloc=xloc.bar_time, extend=extend.right,
                 color=col_london_high, width=line_width, style=line.style_dashed)
            lb_lh := label.new(bar_index + 2, london_high, "Ldn High",
                 xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left,
                 color=color.new(col_london_high, 90), textcolor=col_london_high, size=size.small)
        else
            line.set_y1(l_lh, london_high)
            line.set_y2(l_lh, london_high)
            line.set_color(l_lh, col_london_high)
            label.set_x(lb_lh, bar_index + 2)
            label.set_y(lb_lh, london_high)
            if london_done
                line.set_extend(l_lh, extend.none)

    if show_london_low and not na(london_low)
        if na(l_ll)
            l_ll  := line.new(time, london_low, time + 1, london_low,
                 xloc=xloc.bar_time, extend=extend.right,
                 color=col_london_low, width=line_width, style=line.style_dashed)
            lb_ll := label.new(bar_index + 2, london_low, "Ldn Low",
                 xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left,
                 color=color.new(col_london_low, 90), textcolor=col_london_low, size=size.small)
        else
            line.set_y1(l_ll, london_low)
            line.set_y2(l_ll, london_low)
            line.set_color(l_ll, col_london_low)
            label.set_x(lb_ll, bar_index + 2)
            label.set_y(lb_ll, london_low)
            if london_done
                line.set_extend(l_ll, extend.none)

// ─────────────────────────────────────────────
//  NY EQUITIES OPEN LINE  9:30 AM – 4:00 PM ET
// ─────────────────────────────────────────────
if is_ny_open_start
    if not na(l_ny_open_line)
        line.delete(l_ny_open_line)
    if not na(lb_ny_open_line)
        label.delete(lb_ny_open_line)
    l_ny_open_line  := na
    lb_ny_open_line := na
    ny_open_price   := open
    ny_line_active  := true

if ny_line_active and not na(ny_open_price)
    if show_ny_open_line
        if na(l_ny_open_line)
            l_ny_open_line  := line.new(time, ny_open_price, time + 1, ny_open_price,
                 xloc=xloc.bar_time, extend=extend.right,
                 color=col_ny_open_line, width=line_width, style=line.style_dashed)
            lb_ny_open_line := label.new(bar_index + 2, ny_open_price, "NY Open",
                 xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left,
                 color=color.new(col_ny_open_line, 90), textcolor=col_ny_open_line, size=size.small)
        else
            line.set_y1(l_ny_open_line, ny_open_price)
            line.set_y2(l_ny_open_line, ny_open_price)
            line.set_color(l_ny_open_line, col_ny_open_line)
            label.set_x(lb_ny_open_line, bar_index + 2)
            label.set_y(lb_ny_open_line, ny_open_price)

if is_ny_close and ny_line_active
    if not na(l_ny_open_line)
        line.set_extend(l_ny_open_line, extend.none)
    ny_line_active := false

// ─────────────────────────────────────────────
//  NY OPEN SESSION BOXES  9:30 AM – 12:00 PM ET
//  All historical sessions kept. Weekends = purple.
// ─────────────────────────────────────────────
if is_ny_open_start and show_ny_box
    box_color  = is_weekend ? col_ny_box_wknd : col_ny_box
    ny_box_cur := box.new(time, high, time + 1, low,
         xloc=xloc.bar_time,
         border_color=color.new(box_color, 60),
         bgcolor=box_color,
         border_width=1,
         extend=extend.none)

if in_ny_open and show_ny_box and not na(ny_box_cur)
    box.set_right(ny_box_cur,  time)
    box.set_top(ny_box_cur,    math.max(box.get_top(ny_box_cur),    high))
    box.set_bottom(ny_box_cur, math.min(box.get_bottom(ny_box_cur), low))

// Seal box at 12:00pm (1 bar past noon)
if et_hour == 12 and et_minute == 1 and not na(ny_box_cur)
    ny_box_cur := na
````
