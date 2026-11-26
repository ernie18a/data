# Session Open Range [PRO]

- url: https://www.tradingview.com/script/rWCfdoDd-Session-Open-Range-PRO/
- type: indicator
- pine_id: PUB;fda73129337249f784bdfa73276d94cd
- version: 2.0

## Description

Session Open Range [PRO] is a customizable TradingView indicator designed to mark key market sessions and their opening ranges directly on the chart.

The indicator highlights the Asia, London, New York, and custom trading sessions with adjustable session times, opening range duration, labels, boxes, borders, and open lines. It helps traders quickly identify session highs/lows, opening range levels, and important intraday price zones.

Features:
• Asia, London, New York, and Custom session support
• Adjustable session times
• Custom opening range duration
• Session open line
• Opening range box
• Session box and border styling
• Custom colors for each session
• Optional labels and visual controls
• Useful for intraday, scalping, and session-based trading strategies

This tool is useful for traders who track session opens, opening range breakouts, liquidity sweeps, and market behavior around major trading sessions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Session Open Range Pro

//@version=6
indicator(title="Session Open Range [PRO]", shorttitle="SOR Pro", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=300)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  UTILITY FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_line_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_lbl_size(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Large" => size.large
        "Huge"  => size.huge
        => size.small

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TOOLTIPS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string TT_S  = "Session window in the selected timezone.  Format: HHMM-HHMM  e.g. 0200-0500"
var string TT_RM = "Opening Range length in minutes from session open.\nThe OR box spans only this period; the Session box covers the full session open→close."
var string TT_TZ = "Timezone all four session times are interpreted in.\n\"Exchange\" = chart symbol's own exchange clock.\nForex/Crypto on UTC → select UTC.  If your broker shows UTC+3 → select UTC+3."

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — ASIA SESSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GA = "Asia Session"
bool   a_on  = input.bool   (true,              "Enable",              group=GA, inline="h")
string a_nm  = input.string ("Asia",             "  Name",              group=GA, inline="h")
string a_ss  = input.session("0500-1200",        "Session Time",        group=GA, tooltip=TT_S)
string a_rms = input.string("5", "Opening Range (min)", group=GA, options=["1","3","5","10","15","20","30","45","60","90","120","180","240"], tooltip=TT_RM)
int    a_rm  = int(str.tonumber(a_rms))
color  a_fc  = input.color  (color.new(#00BCD4, 88), "OR Fill",         group=GA, inline="c1")
color  a_bc  = input.color  (color.new(#00BCD4,  0), "OR Border",       group=GA, inline="c1")
color  a_mc  = input.color  (color.new(#00BCD4, 20), "Open Line",       group=GA, inline="c1")
color  a_sfc = input.color  (color.new(#00BCD4, 94), "Sess Fill",       group=GA, inline="c2")
color  a_sbc = input.color  (color.new(#00BCD4, 55), "Sess Border",     group=GA, inline="c2")
bool   a_shm = input.bool   (true,  "Open Line",   group=GA, inline="v")
bool   a_shl = input.bool   (true,  "Label",       group=GA, inline="v")
bool   a_ssb = input.bool   (true,  "Session Box", group=GA, inline="v")
bool   a_brk = input.bool   (false, "Brk Tint",    group=GA, inline="v")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — LONDON SESSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GL = "London Session"
bool   l_on  = input.bool   (true,              "Enable",              group=GL, inline="h")
string l_nm  = input.string ("London",           "  Name",              group=GL, inline="h")
string l_ss  = input.session("1200-1830",        "Session Time",        group=GL, tooltip=TT_S)
string l_rms = input.string("5", "Opening Range (min)", group=GL, options=["1","3","5","10","15","20","30","45","60","90","120","180","240"], tooltip=TT_RM)
int    l_rm  = int(str.tonumber(l_rms))
color  l_fc  = input.color  (color.new(#FF9800, 88), "OR Fill",         group=GL, inline="c1")
color  l_bc  = input.color  (color.new(#FF9800,  0), "OR Border",       group=GL, inline="c1")
color  l_mc  = input.color  (color.new(#FF9800, 20), "Open Line",       group=GL, inline="c1")
color  l_sfc = input.color  (color.new(#FF9800, 94), "Sess Fill",       group=GL, inline="c2")
color  l_sbc = input.color  (color.new(#FF9800, 55), "Sess Border",     group=GL, inline="c2")
bool   l_shm = input.bool   (true,  "Open Line",   group=GL, inline="v")
bool   l_shl = input.bool   (true,  "Label",       group=GL, inline="v")
bool   l_ssb = input.bool   (true,  "Session Box", group=GL, inline="v")
bool   l_brk = input.bool   (false, "Brk Tint",    group=GL, inline="v")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — NEW YORK SESSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GN = "New York Session"
bool   n_on  = input.bool   (true,              "Enable",              group=GN, inline="h")
string n_nm  = input.string ("New York",         "  Name",              group=GN, inline="h")
string n_ss  = input.session("1830-0100",        "Session Time",        group=GN, tooltip=TT_S)
string n_rms = input.string("5", "Opening Range (min)", group=GN, options=["1","3","5","10","15","20","30","45","60","90","120","180","240"], tooltip=TT_RM)
int    n_rm  = int(str.tonumber(n_rms))
color  n_fc  = input.color  (color.new(#E91E63, 88), "OR Fill",         group=GN, inline="c1")
color  n_bc  = input.color  (color.new(#E91E63,  0), "OR Border",       group=GN, inline="c1")
color  n_mc  = input.color  (color.new(#E91E63, 20), "Open Line",       group=GN, inline="c1")
color  n_sfc = input.color  (color.new(#E91E63, 94), "Sess Fill",       group=GN, inline="c2")
color  n_sbc = input.color  (color.new(#E91E63, 55), "Sess Border",     group=GN, inline="c2")
bool   n_shm = input.bool   (true,  "Open Line",   group=GN, inline="v")
bool   n_shl = input.bool   (true,  "Label",       group=GN, inline="v")
bool   n_ssb = input.bool   (true,  "Session Box", group=GN, inline="v")
bool   n_brk = input.bool   (false, "Brk Tint",    group=GN, inline="v")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — CUSTOM SESSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GC = "Custom Session"
bool   c_on  = input.bool   (false,             "Enable",              group=GC, inline="h")
string c_nm  = input.string ("Custom",           "  Name",              group=GC, inline="h")
string c_ss  = input.session("0000-0400",        "Session Time",        group=GC, tooltip=TT_S)
string c_rms = input.string("5", "Opening Range (min)", group=GC, options=["1","3","5","10","15","20","30","45","60","90","120","180","240"], tooltip=TT_RM)
int    c_rm  = int(str.tonumber(c_rms))
color  c_fc  = input.color  (color.new(#9C27B0, 88), "OR Fill",         group=GC, inline="c1")
color  c_bc  = input.color  (color.new(#9C27B0,  0), "OR Border",       group=GC, inline="c1")
color  c_mc  = input.color  (color.new(#9C27B0, 20), "Open Line",       group=GC, inline="c1")
color  c_sfc = input.color  (color.new(#9C27B0, 94), "Sess Fill",       group=GC, inline="c2")
color  c_sbc = input.color  (color.new(#9C27B0, 55), "Sess Border",     group=GC, inline="c2")
bool   c_shm = input.bool   (true,  "Open Line",   group=GC, inline="v")
bool   c_shl = input.bool   (true,  "Label",       group=GC, inline="v")
bool   c_ssb = input.bool   (true,  "Session Box", group=GC, inline="v")
bool   c_brk = input.bool   (false, "Brk Tint",    group=GC, inline="v")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — BREAKOUT COLORS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GBK = "Breakout Colors  (applies when Brk Tint is enabled per session)"
color bk_up = input.color(color.new(#26A69A, 72), "Broke Above OR", group=GBK, inline="bk")
color bk_dn = input.color(color.new(#EF5350, 72), "Broke Below OR", group=GBK, inline="bk")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — TIMEZONE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GTZ = "Timezone  (all session times are interpreted in this timezone)"
var string TT_TZ2 = "Chart Time = use the chart symbol's exchange timezone (default — your session times match the times shown on the chart's time axis).\nOr pick a specific UTC offset if you want session times in a different timezone.\n\nNOTE: switching timezones reinterprets the session times you entered.  E.g. 05:00-12:00 with UTC+5 = UTC+5 5AM-noon.  Switching to UTC means UTC 5AM-noon."
string v_tz = input.string("UTC+5", "Session Timezone", group=GTZ, tooltip=TT_TZ2,
     options=["Chart Time",
              "UTC-12","UTC-11","UTC-10","UTC-9:30","UTC-9","UTC-8","UTC-7","UTC-6",
              "UTC-5","UTC-4","UTC-3","UTC-2","UTC-1","UTC",
              "UTC+1","UTC+2","UTC+3","UTC+3:30","UTC+4","UTC+4:30",
              "UTC+5","UTC+5:30","UTC+5:45",
              "UTC+6","UTC+6:30","UTC+7","UTC+8","UTC+8:45",
              "UTC+9","UTC+9:30","UTC+10","UTC+10:30","UTC+11",
              "UTC+12","UTC+12:45","UTC+13","UTC+14"])

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS — VISUAL SETTINGS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GV = "Visual Settings"
int    v_bw = input.int   (1,        "Border Width",    group=GV, minval=1, maxval=5)
string v_bs = input.string("Solid",  "Border Style",    group=GV, options=["Solid","Dashed","Dotted"])
string v_ls = input.string("Small",  "Label Size",      group=GV, options=["Tiny","Small","Normal","Large","Huge"])
string v_lp = input.string("Top",    "Label Position",  group=GV, options=["Top","Bottom"])

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  COMPUTED STYLE VALUES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_bs      = f_line_style(v_bs)
_ls      = f_lbl_size(v_ls)
_lby_top = v_lp == "Top"
_lbst    = _lby_top ? label.style_label_lower_left : label.style_label_upper_left

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SESSION DETECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_tz  = v_tz == "Chart Time" ? syminfo.timezone : v_tz

a_in = not na(time(timeframe.period, a_ss, _tz))
l_in = not na(time(timeframe.period, l_ss, _tz))
n_in = not na(time(timeframe.period, n_ss, _tz))
c_in = not na(time(timeframe.period, c_ss, _tz))

a_new = a_on and a_in and not a_in[1]
l_new = l_on and l_in and not l_in[1]
n_new = n_on and n_in and not n_in[1]
c_new = c_on and c_in and not c_in[1]

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ASIA — OPENING RANGE BOX  +  SESSION BOX
//
//  Opening Range (OR) box  → spans the first a_rm minutes of the session,
//                             its right edge extends to the session close.
//  Session box             → tracks the full session H/L, also closes with
//                             the session.  Drawn first so it sits behind the OR box.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box   a_sbx  = na      // Session box  (behind)
var float a_shi  = na      // Session high
var float a_slo  = na      // Session low
var box   a_bx   = na      // Opening range box  (in front)
var line  a_ml   = na      // OR midline
var label a_lb   = na      // Label
var float a_rh   = na      // OR high
var float a_rl   = na      // OR low
var int   a_oms  = na      // Session open timestamp (ms) — used for minutes-based OR

if a_new
    a_oms := time
    a_rh  := high
    a_rl  := low
    a_shi := high
    a_slo := low
    // Session box created FIRST so it renders behind the OR box
    a_sbx := a_ssb ? box.new(bar_index, a_shi, bar_index, a_slo, border_color=a_sbc, bgcolor=a_sfc, border_width=1, border_style=_bs) : na
    // Opening range box on top
    a_bx  := box.new(bar_index, a_rh, bar_index, a_rl, border_color=a_bc, bgcolor=a_fc, border_width=v_bw, border_style=_bs)
    a_ml  := a_shm ? line.new(bar_index, open, bar_index, open, color=a_mc, style=line.style_dotted, width=2) : na
    a_lb  := a_shl ? label.new(bar_index, _lby_top ? a_rh : a_rl, a_nm, color=color.new(a_bc, 70), textcolor=a_bc, size=_ls, style=_lbst) : na

if a_on and not na(a_bx) and not a_new
    // Expand the OR while within the opening range window
    _or = a_in and (time - a_oms) < a_rm * 60000
    if _or
        a_rh  := math.max(a_rh, high)
        a_rl  := math.min(a_rl, low)
        box.set_top(a_bx, a_rh)
        box.set_bottom(a_bx, a_rl)
        if not na(a_lb)
            label.set_y(a_lb, _lby_top ? a_rh : a_rl)
    // Extend OR box right edge through the session (stops automatically when session ends)
    if a_in
        box.set_right(a_bx, bar_index)
        if not na(a_ml)
            line.set_x2(a_ml, bar_index)
    // Update and extend session box
    if not na(a_sbx) and a_in
        a_shi := math.max(a_shi, high)
        a_slo := math.min(a_slo, low)
        box.set_top(a_sbx, a_shi)
        box.set_bottom(a_sbx, a_slo)
        box.set_right(a_sbx, bar_index)
    // Breakout tint on OR box
    if a_brk and a_in
        _t = box.get_top(a_bx)
        _b = box.get_bottom(a_bx)
        box.set_bgcolor(a_bx, close > _t ? bk_up : close < _b ? bk_dn : a_fc)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LONDON — OPENING RANGE BOX  +  SESSION BOX
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box   l_sbx  = na
var float l_shi  = na
var float l_slo  = na
var box   l_bx   = na
var line  l_ml   = na
var label l_lb   = na
var float l_rh   = na
var float l_rl   = na
var int   l_oms  = na

if l_new
    l_oms := time
    l_rh  := high
    l_rl  := low
    l_shi := high
    l_slo := low
    l_sbx := l_ssb ? box.new(bar_index, l_shi, bar_index, l_slo, border_color=l_sbc, bgcolor=l_sfc, border_width=1, border_style=_bs) : na
    l_bx  := box.new(bar_index, l_rh, bar_index, l_rl, border_color=l_bc, bgcolor=l_fc, border_width=v_bw, border_style=_bs)
    l_ml  := l_shm ? line.new(bar_index, open, bar_index, open, color=l_mc, style=line.style_dotted, width=2) : na
    l_lb  := l_shl ? label.new(bar_index, _lby_top ? l_rh : l_rl, l_nm, color=color.new(l_bc, 70), textcolor=l_bc, size=_ls, style=_lbst) : na

if l_on and not na(l_bx) and not l_new
    _or = l_in and (time - l_oms) < l_rm * 60000
    if _or
        l_rh  := math.max(l_rh, high)
        l_rl  := math.min(l_rl, low)
        box.set_top(l_bx, l_rh)
        box.set_bottom(l_bx, l_rl)
        if not na(l_lb)
            label.set_y(l_lb, _lby_top ? l_rh : l_rl)
    if l_in
        box.set_right(l_bx, bar_index)
        if not na(l_ml)
            line.set_x2(l_ml, bar_index)
    if not na(l_sbx) and l_in
        l_shi := math.max(l_shi, high)
        l_slo := math.min(l_slo, low)
        box.set_top(l_sbx, l_shi)
        box.set_bottom(l_sbx, l_slo)
        box.set_right(l_sbx, bar_index)
    if l_brk and l_in
        _t = box.get_top(l_bx)
        _b = box.get_bottom(l_bx)
        box.set_bgcolor(l_bx, close > _t ? bk_up : close < _b ? bk_dn : l_fc)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NEW YORK — OPENING RANGE BOX  +  SESSION BOX
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box   n_sbx  = na
var float n_shi  = na
var float n_slo  = na
var box   n_bx   = na
var line  n_ml   = na
var label n_lb   = na
var float n_rh   = na
var float n_rl   = na
var int   n_oms  = na

if n_new
    n_oms := time
    n_rh  := high
    n_rl  := low
    n_shi := high
    n_slo := low
    n_sbx := n_ssb ? box.new(bar_index, n_shi, bar_index, n_slo, border_color=n_sbc, bgcolor=n_sfc, border_width=1, border_style=_bs) : na
    n_bx  := box.new(bar_index, n_rh, bar_index, n_rl, border_color=n_bc, bgcolor=n_fc, border_width=v_bw, border_style=_bs)
    n_ml  := n_shm ? line.new(bar_index, open, bar_index, open, color=n_mc, style=line.style_dotted, width=2) : na
    n_lb  := n_shl ? label.new(bar_index, _lby_top ? n_rh : n_rl, n_nm, color=color.new(n_bc, 70), textcolor=n_bc, size=_ls, style=_lbst) : na

if n_on and not na(n_bx) and not n_new
    _or = n_in and (time - n_oms) < n_rm * 60000
    if _or
        n_rh  := math.max(n_rh, high)
        n_rl  := math.min(n_rl, low)
        box.set_top(n_bx, n_rh)
        box.set_bottom(n_bx, n_rl)
        if not na(n_lb)
            label.set_y(n_lb, _lby_top ? n_rh : n_rl)
    if n_in
        box.set_right(n_bx, bar_index)
        if not na(n_ml)
            line.set_x2(n_ml, bar_index)
    if not na(n_sbx) and n_in
        n_shi := math.max(n_shi, high)
        n_slo := math.min(n_slo, low)
        box.set_top(n_sbx, n_shi)
        box.set_bottom(n_sbx, n_slo)
        box.set_right(n_sbx, bar_index)
    if n_brk and n_in
        _t = box.get_top(n_bx)
        _b = box.get_bottom(n_bx)
        box.set_bgcolor(n_bx, close > _t ? bk_up : close < _b ? bk_dn : n_fc)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CUSTOM — OPENING RANGE BOX  +  SESSION BOX
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box   c_sbx  = na
var float c_shi  = na
var float c_slo  = na
var box   c_bx   = na
var line  c_ml   = na
var label c_lb   = na
var float c_rh   = na
var float c_rl   = na
var int   c_oms  = na

if c_new
    c_oms := time
    c_rh  := high
    c_rl  := low
    c_shi := high
    c_slo := low
    c_sbx := c_ssb ? box.new(bar_index, c_shi, bar_index, c_slo, border_color=c_sbc, bgcolor=c_sfc, border_width=1, border_style=_bs) : na
    c_bx  := box.new(bar_index, c_rh, bar_index, c_rl, border_color=c_bc, bgcolor=c_fc, border_width=v_bw, border_style=_bs)
    c_ml  := c_shm ? line.new(bar_index, open, bar_index, open, color=c_mc, style=line.style_solid, width=1) : na
    c_lb  := c_shl ? label.new(bar_index, _lby_top ? c_rh : c_rl, c_nm, color=color.new(c_bc, 70), textcolor=c_bc, size=_ls, style=_lbst) : na

if c_on and not na(c_bx) and not c_new
    _or = c_in and (time - c_oms) < c_rm * 60000
    if _or
        c_rh  := math.max(c_rh, high)
        c_rl  := math.min(c_rl, low)
        box.set_top(c_bx, c_rh)
        box.set_bottom(c_bx, c_rl)
        if not na(c_lb)
            label.set_y(c_lb, _lby_top ? c_rh : c_rl)
    if c_in
        box.set_right(c_bx, bar_index)
        if not na(c_ml)
            line.set_x2(c_ml, bar_index)
    if not na(c_sbx) and c_in
        c_shi := math.max(c_shi, high)
        c_slo := math.min(c_slo, low)
        box.set_top(c_sbx, c_shi)
        box.set_bottom(c_sbx, c_slo)
        box.set_right(c_sbx, bar_index)
    if c_brk and c_in
        _t = box.get_top(c_bx)
        _b = box.get_bottom(c_bx)
        box.set_bgcolor(c_bx, close > _t ? bk_up : close < _b ? bk_dn : c_fc)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PREVIOUS DAY HIGH / LOW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var string GPD   = "Previous Day High / Low"
bool   pd_on     = input.bool  (true,                    "Show PD High / PD Low",  group=GPD)
color  pd_hc     = input.color (color.new(#FFD600,  0),  "PD High Color",          group=GPD, inline="pdc")
color  pd_lc     = input.color (color.new(#FFD600,  0),  "PD Low Color",           group=GPD, inline="pdc")
int    pd_lw     = input.int   (1,                       "Line Width",             group=GPD, minval=1, maxval=4)
string pd_ls     = input.string("Dashed",                "Line Style",             group=GPD, options=["Solid","Dashed","Dotted"])
string pd_extend = input.string("Current Day Only",      "Line Extent",            group=GPD, options=["Current Day Only","Entire Chart"], tooltip="Current Day Only = lines redrawn each day (clean, professional).\nEntire Chart = lines plotted across the whole chart (busy).")
bool   pd_shl    = input.bool  (true,                    "Show Labels",            group=GPD)
string pd_lsize  = input.string("Small",                 "Label Size",             group=GPD, options=["Tiny","Small","Normal","Large","Huge"])

_pd_ls  = f_line_style(pd_ls)
_pd_lsz = f_lbl_size(pd_lsize)

// Fetch previous completed day's high and low via the exchange's daily candle
pd_hi = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_lo = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// ── Render mode 1: Current Day Only — one pair of lines per day ──
//   Cleaner appearance, doesn't bleed across the whole chart.
//   New lines are created on each day boundary and extended through the day.
var line _pd_hiLn = na
var line _pd_loLn = na
_pd_newDay = ta.change(time("D")) != 0

if pd_on and pd_extend == "Current Day Only"
    if _pd_newDay and not na(pd_hi)
        // Start new lines for today
        _pd_hiLn := line.new(bar_index, pd_hi, bar_index, pd_hi, color=pd_hc, style=_pd_ls, width=pd_lw)
        _pd_loLn := line.new(bar_index, pd_lo, bar_index, pd_lo, color=pd_lc, style=_pd_ls, width=pd_lw)
    if not na(_pd_hiLn)
        line.set_x2(_pd_hiLn, bar_index)
        line.set_y1(_pd_hiLn, pd_hi)
        line.set_y2(_pd_hiLn, pd_hi)
    if not na(_pd_loLn)
        line.set_x2(_pd_loLn, bar_index)
        line.set_y1(_pd_loLn, pd_lo)
        line.set_y2(_pd_loLn, pd_lo)

// ── Render mode 2: Entire Chart — plots that span the full chart ──
plot(pd_on and pd_extend == "Entire Chart" ? pd_hi : na, "PD High", color=pd_hc, linewidth=pd_lw, style=plot.style_line)
plot(pd_on and pd_extend == "Entire Chart" ? pd_lo : na, "PD Low",  color=pd_lc, linewidth=pd_lw, style=plot.style_line)

// Right-edge labels recreated on every realtime bar to track the chart edge
var label pd_hib = na
var label pd_lob = na

if pd_on and pd_shl and barstate.islast and not na(pd_hi)
    label.delete(pd_hib)
    label.delete(pd_lob)
    pd_hib := label.new(bar_index + 1, pd_hi, "PDH  " + str.tostring(pd_hi, format.mintick), color=color.new(pd_hc, 80), textcolor=pd_hc, size=_pd_lsz, style=label.style_label_left)
    pd_lob := label.new(bar_index + 1, pd_lo, "PDL  " + str.tostring(pd_lo, format.mintick), color=color.new(pd_lc, 80), textcolor=pd_lc, size=_pd_lsz, style=label.style_label_left)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ALERT CONDITIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(a_new, "Asia Open",           "Asia session opened — OR being built")
alertcondition(l_new, "London Open",         "London session opened — OR being built")
alertcondition(n_new, "New York Open",       "New York session opened — OR being built")
alertcondition(c_new, "Custom Session Open", "Custom session opened — OR being built")
alertcondition(a_on and not na(a_bx) and a_brk and close > box.get_top(a_bx),    "Asia OR Broke Up",     "Close broke above Asia opening range")
alertcondition(a_on and not na(a_bx) and a_brk and close < box.get_bottom(a_bx), "Asia OR Broke Down",   "Close broke below Asia opening range")
alertcondition(l_on and not na(l_bx) and l_brk and close > box.get_top(l_bx),    "London OR Broke Up",   "Close broke above London opening range")
alertcondition(l_on and not na(l_bx) and l_brk and close < box.get_bottom(l_bx), "London OR Broke Down", "Close broke below London opening range")
alertcondition(n_on and not na(n_bx) and n_brk and close > box.get_top(n_bx),    "NY OR Broke Up",       "Close broke above NY opening range")
alertcondition(n_on and not na(n_bx) and n_brk and close < box.get_bottom(n_bx), "NY OR Broke Down",     "Close broke below NY opening range")
alertcondition(pd_on and not na(pd_hi) and close > pd_hi, "Price Crossed PD High", "Close crossed above Previous Day High")
alertcondition(pd_on and not na(pd_lo) and close < pd_lo, "Price Crossed PD Low",  "Close crossed below Previous Day Low")
````
