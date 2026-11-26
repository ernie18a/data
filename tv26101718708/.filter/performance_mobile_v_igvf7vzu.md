# Performance Mobile V.

- url: https://www.tradingview.com/script/IgVf7Vzu-Performance-Mobile-V/
- type: indicator
- pine_id: PUB;bcc3f2c55bdd48a9a0136e6c960323af
- version: 6.0

## Description

Mobile version compact performance table. Can be put on either chart side/height. Custom text size. Also usefull for normal screens (additional decimals displays). Add rows/colums as you wish. Enjoy.

And thank Claude for helping me as always. This is AI !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @Martybird, shoutout to © BeeHolder for original code I adapted

//@version=6
indicator("MTF Performance Table", overlay=true, max_bars_back=500)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — TABLE SETTINGS
// ══════════════════════════════════════════════════════════════════════════════
grp_tbl = "Table Settings"
i_pos_v = input.string("Bottom", "Vertical",   group=grp_tbl, options=["Top","Middle","Bottom"])
i_pos_h = input.string("Right",  "Horizontal", group=grp_tbl, options=["Left","Center","Right"])
i_size  = input.string("Small",  "Text Size",  group=grp_tbl, options=["Tiny","Small","Normal","Large"])

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — ROW TOGGLES
// ══════════════════════════════════════════════════════════════════════════════
grp_row = "Rows"
i_pad_top = input.bool(true,  "─── Empty row at top",        group=grp_row)
i_r_1d    = input.bool(true,  "1D  – Today open",             group=grp_row)
i_r_1w    = input.bool(true,  "1W  – Week open",              group=grp_row)
i_r_mtd   = input.bool(true,  "MTD – Month to date",          group=grp_row)
i_r_1m    = input.bool(true,  "1M  – 21 days rolling",        group=grp_row)
i_r_3m    = input.bool(true,  "3M  – 63 days rolling",        group=grp_row)
i_r_3md   = input.bool(true,  "3MD – 3 months to date",       group=grp_row)
i_r_6m    = input.bool(true,  "6M  – 126 days rolling",       group=grp_row)
i_r_6md   = input.bool(true,  "6MD – 6 months to date",       group=grp_row)
i_r_ytd   = input.bool(true,  "YTD – Year to date",           group=grp_row)
i_r_1y    = input.bool(true,  "1Y  – 252 days rolling",       group=grp_row)
i_r_5y    = input.bool(false, "5Y  – 1260 days rolling",      group=grp_row)
i_pad_bot = input.bool(true,  "─── Empty row at bottom",      group=grp_row)

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_size() =>
    switch i_size
        "Tiny"   => size.tiny
        "Large"  => size.large
        "Normal" => size.normal
        =>          size.small

f_pos() =>
    if i_pos_v == "Top"
        if i_pos_h == "Left"
            position.top_left
        else if i_pos_h == "Center"
            position.top_center
        else
            position.top_right
    else if i_pos_v == "Middle"
        if i_pos_h == "Left"
            position.middle_left
        else if i_pos_h == "Center"
            position.middle_center
        else
            position.middle_right
    else
        if i_pos_h == "Left"
            position.bottom_left
        else if i_pos_h == "Center"
            position.bottom_center
        else
            position.bottom_right

f_pct(ref, cur) =>
    not na(ref) and ref != 0.0 ? (cur - ref) / math.abs(ref) * 100.0 : na

f_bg(v) =>
    if na(v)
        color.new(#222428, 0)
    else if v >= 15
        color.new(#1d5c20, 0)
    else if v > 0
        color.new(#143f16, 0)
    else if v <= -15
        color.new(#6b1818, 0)
    else if v < 0
        color.new(#4a1010, 0)
    else
        color.new(#1c1e22, 0)

f_fg(v) =>
    if na(v)
        color.new(#7d7f85, 0)
    else if v > 0
        color.new(#2ad830, 0)
    else if v < 0
        color.new(#fb9595, 0)
    else
        color.rgb(139, 138, 138)

// ══════════════════════════════════════════════════════════════════════════════
//  DATE HELPERS
// ══════════════════════════════════════════════════════════════════════════════
_now_m = month(timenow)
_now_y = year(timenow)

_m3 = _now_m - 3
_y3 = _now_y
if _m3 < 1
    _m3 := _m3 + 12
    _y3 := _y3 - 1

_m6 = _now_m - 6
_y6 = _now_y
if _m6 < 1
    _m6 := _m6 + 12
    _y6 := _y6 - 1

// ══════════════════════════════════════════════════════════════════════════════
//  REFERENCE OPENS
// ══════════════════════════════════════════════════════════════════════════════
cur = close

ref_1d  = request.security(syminfo.tickerid, "D", open)
ref_1w  = request.security(syminfo.tickerid, "W", open)
ref_mtd = request.security(syminfo.tickerid, "M", open)
ref_1m  = request.security(syminfo.tickerid, "D", close[21])
ref_3m  = request.security(syminfo.tickerid, "D", close[63])
ref_6m  = request.security(syminfo.tickerid, "D", close[126])
ref_1y  = request.security(syminfo.tickerid, "D", close[252])
ref_5y  = request.security(syminfo.tickerid, "D", close[1260])

ref_3md = request.security(syminfo.tickerid, "D", ta.valuewhen(month == _m3 and year == _y3 and (month != month[1] or bar_index == 0), open, 0))
ref_6md = request.security(syminfo.tickerid, "D", ta.valuewhen(month == _m6 and year == _y6 and (month != month[1] or bar_index == 0), open, 0))
ref_ytd = request.security(syminfo.tickerid, "D", ta.valuewhen(year == _now_y and (year != year[1] or bar_index == 0), open, 0))

// ══════════════════════════════════════════════════════════════════════════════
//  DYNAMIC ROW COUNT
// ══════════════════════════════════════════════════════════════════════════════
_n = 0
_n := i_pad_top ? _n + 1 : _n
_n := i_r_1d    ? _n + 1 : _n
_n := i_r_1w    ? _n + 1 : _n
_n := i_r_mtd   ? _n + 1 : _n
_n := i_r_1m    ? _n + 1 : _n
_n := i_r_3m    ? _n + 1 : _n
_n := i_r_3md   ? _n + 1 : _n
_n := i_r_6m    ? _n + 1 : _n
_n := i_r_6md   ? _n + 1 : _n
_n := i_r_ytd   ? _n + 1 : _n
_n := i_r_1y    ? _n + 1 : _n
_n := i_r_5y    ? _n + 1 : _n
_n := i_pad_bot ? _n + 1 : _n
NROWS = math.max(_n, 1)

// ══════════════════════════════════════════════════════════════════════════════
//  TABLE
// ══════════════════════════════════════════════════════════════════════════════
C_LBL_BG  = color.new(#0d1117, 0)
C_LBL_TXT = color.new(#8e8d8d, 0)
C_PAD_BG  = color.new(#0a0d10, 0)

var table tbl = table.new(f_pos(), 2, NROWS, border_width=1, border_color=#2a2a2a, frame_width=2, frame_color=#000000)

f_row(lbl, ref, row) =>
    v     = f_pct(ref, cur)
    v_str = na(v) ? "N/A" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"
    table.cell(tbl, 0, row, lbl,   bgcolor=C_LBL_BG, text_color=C_LBL_TXT, text_size=f_size(), text_halign=text.align_center, text_valign=text.align_center)
    table.cell(tbl, 1, row, v_str, bgcolor=f_bg(v),  text_color=f_fg(v),   text_size=f_size(), text_halign=text.align_right,  text_valign=text.align_center)

f_pad(row) =>
    table.cell(tbl, 0, row, "", bgcolor=C_PAD_BG, text_size=size.tiny)
    table.cell(tbl, 1, row, "", bgcolor=C_PAD_BG, text_size=size.tiny)

if barstate.islast
    r = 0
    if i_pad_top
        f_pad(r)
        r := r + 1
    if i_r_1d
        f_row("1D",  ref_1d,  r)
        r := r + 1
    if i_r_1w
        f_row("1W",  ref_1w,  r)
        r := r + 1
    if i_r_mtd
        f_row("MTD", ref_mtd, r)
        r := r + 1
    if i_r_1m
        f_row("1M",  ref_1m,  r)
        r := r + 1
    if i_r_3m
        f_row("3M",  ref_3m,  r)
        r := r + 1
    if i_r_3md
        f_row("3MD", ref_3md, r)
        r := r + 1
    if i_r_6m
        f_row("6M",  ref_6m,  r)
        r := r + 1
    if i_r_6md
        f_row("6MD", ref_6md, r)
        r := r + 1
    if i_r_ytd
        f_row("YTD", ref_ytd, r)
        r := r + 1
    if i_r_1y
        f_row("1Y",  ref_1y,  r)
        r := r + 1
    if i_r_5y
        f_row("5Y",  ref_5y,  r)
        r := r + 1
    if i_pad_bot
        f_pad(r)
````
