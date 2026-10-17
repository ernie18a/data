# Session High & Low - Dice Trades

- url: https://www.tradingview.com/script/oOYbdnEv-Session-High-Low-Dice-Trades/
- type: indicator
- pine_id: PUB;2c86112f2e5f4d78aef64f1afa7c5eb6
- version: 1.0

## Description

Voilà la description prête à coller :

Session High & Low Indicator
This indicator automatically plots the High and Low of each major trading session directly on your chart, giving you a clear view of where liquidity is resting at all times.
Sessions included:

Asia — 20:00 to 00:00 UTC
London — 02:00 to 08:00 UTC
New York — 08:30 to 17:00 UTC
NY AM — 09:30 to 12:00 UTC (optional)

Key features:

Each session high and low is drawn automatically at the start of the session and updates in real time as price makes new extremes
Once a level is taken out (price trades through it), the line disappears automatically — keeping your chart clean and only showing untested levels
Each session can be toggled on or off independently
Fully customizable colors, line style (Solid, Dashed, Dotted) and line width
Labels display the session name next to each level
Built-in alerts for every session sweep

How to use it:
Session highs and lows are key liquidity zones. Smart money tends to sweep these levels before reversing. Use them as targets, entry triggers, or confirmation that a sweep has occurred.
Works on any market and any timeframe. Session times are in UTC — adjust them in the settings to match your broker's timezone if needed.

## Source Code

````pine
//@version=6
indicator("Session High & Low", overlay=true, max_lines_count=500, max_labels_count=200)

// ─────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────
asia_show  = input.bool(true,    "Show Asia Session",           group="Asia Session")
asia_col   = input.color(#f0c040,"Asia Color",                  group="Asia Session")
asia_start = input.session("2000-0000", "Asia Time",            group="Asia Session")

lon_show   = input.bool(true,    "Show London Session",         group="London Session")
lon_col    = input.color(#00b4d8,"London Color",                group="London Session")
lon_start  = input.session("0200-0800", "London Time",          group="London Session")

ny_show    = input.bool(true,    "Show New York Session",       group="New York Session")
ny_col     = input.color(#00c897,"New York Color",              group="New York Session")
ny_start   = input.session("0830-1700", "New York Time",        group="New York Session")

nyam_show  = input.bool(false,   "Show NY AM Session",          group="NY AM Session")
nyam_col   = input.color(#a78bfa,"NY AM Color",                 group="NY AM Session")
nyam_start = input.session("0930-1200", "NY AM Time",           group="NY AM Session")

extend_right  = input.bool(true, "Extend lines to the right")
show_labels   = input.bool(true, "Show Labels")
line_width    = input.int(1,     "Line Width", 1, 3)
line_style_in = input.string("Dashed", "Line Style",
                options=["Solid","Dashed","Dotted"])

// ─────────────────────────────────────────
//  UTILITAIRES
// ─────────────────────────────────────────
f_style(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

ls  = f_style(line_style_in)
ext = extend_right ? extend.right : extend.none

f_del_line(ln) =>
    if not na(ln)
        line.delete(ln)

f_del_label(lb) =>
    if not na(lb)
        label.delete(lb)

f_session_start(sess) =>
    in_sess     = not na(time(timeframe.period, sess))
    was_in_sess = not na(time(timeframe.period, sess)[1])
    in_sess and not was_in_sess

// ─────────────────────────────────────────
//  ASIA
// ─────────────────────────────────────────
in_asia  = not na(time(timeframe.period, asia_start))
asia_new = f_session_start(asia_start)

var float asia_hi      = na
var float asia_lo      = na
var int   asia_bar     = na
var line  asia_h_line  = na
var line  asia_l_line  = na
var label asia_h_lbl   = na
var label asia_l_lbl   = na
var bool  asia_h_taken = false
var bool  asia_l_taken = false

if asia_new
    asia_hi      := high
    asia_lo      := low
    asia_bar     := bar_index
    asia_h_taken := false
    asia_l_taken := false
    if asia_show
        f_del_line(asia_h_line)
        f_del_line(asia_l_line)
        f_del_label(asia_h_lbl)
        f_del_label(asia_l_lbl)

if in_asia
    asia_hi := math.max(nz(asia_hi, high), high)
    asia_lo := math.min(nz(asia_lo, low),  low)

// Détecter si le high/low est pris (prix clôture au-delà)
if not in_asia and not na(asia_hi)
    if high >= asia_hi and not asia_h_taken
        asia_h_taken := true
        f_del_line(asia_h_line)
        f_del_label(asia_h_lbl)
        asia_h_line := na
        asia_h_lbl  := na
    if low <= asia_lo and not asia_l_taken
        asia_l_taken := true
        f_del_line(asia_l_line)
        f_del_label(asia_l_lbl)
        asia_l_line := na
        asia_l_lbl  := na

if in_asia and asia_show and not na(asia_bar)
    f_del_line(asia_h_line)
    f_del_line(asia_l_line)
    f_del_label(asia_h_lbl)
    f_del_label(asia_l_lbl)
    asia_h_line := line.new(asia_bar, asia_hi, bar_index, asia_hi,
                             color=asia_col, width=line_width, style=ls, extend=ext)
    asia_l_line := line.new(asia_bar, asia_lo, bar_index, asia_lo,
                             color=asia_col, width=line_width, style=ls, extend=ext)
    if show_labels
        asia_h_lbl := label.new(asia_bar, asia_hi, "Asia H",
                                 color=color.new(asia_col, 20), textcolor=color.black,
                                 style=label.style_label_right, size=size.tiny)
        asia_l_lbl := label.new(asia_bar, asia_lo, "Asia L",
                                 color=color.new(asia_col, 20), textcolor=color.black,
                                 style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────
//  LONDON
// ─────────────────────────────────────────
in_lon  = not na(time(timeframe.period, lon_start))
lon_new = f_session_start(lon_start)

var float lon_hi      = na
var float lon_lo      = na
var int   lon_bar     = na
var line  lon_h_line  = na
var line  lon_l_line  = na
var label lon_h_lbl   = na
var label lon_l_lbl   = na
var bool  lon_h_taken = false
var bool  lon_l_taken = false

if lon_new
    lon_hi      := high
    lon_lo      := low
    lon_bar     := bar_index
    lon_h_taken := false
    lon_l_taken := false
    if lon_show
        f_del_line(lon_h_line)
        f_del_line(lon_l_line)
        f_del_label(lon_h_lbl)
        f_del_label(lon_l_lbl)

if in_lon
    lon_hi := math.max(nz(lon_hi, high), high)
    lon_lo := math.min(nz(lon_lo, low),  low)

if not in_lon and not na(lon_hi)
    if high >= lon_hi and not lon_h_taken
        lon_h_taken := true
        f_del_line(lon_h_line)
        f_del_label(lon_h_lbl)
        lon_h_line := na
        lon_h_lbl  := na
    if low <= lon_lo and not lon_l_taken
        lon_l_taken := true
        f_del_line(lon_l_line)
        f_del_label(lon_l_lbl)
        lon_l_line := na
        lon_l_lbl  := na

if in_lon and lon_show and not na(lon_bar)
    f_del_line(lon_h_line)
    f_del_line(lon_l_line)
    f_del_label(lon_h_lbl)
    f_del_label(lon_l_lbl)
    lon_h_line := line.new(lon_bar, lon_hi, bar_index, lon_hi,
                            color=lon_col, width=line_width, style=ls, extend=ext)
    lon_l_line := line.new(lon_bar, lon_lo, bar_index, lon_lo,
                            color=lon_col, width=line_width, style=ls, extend=ext)
    if show_labels
        lon_h_lbl := label.new(lon_bar, lon_hi, "London H",
                                color=color.new(lon_col, 20), textcolor=color.black,
                                style=label.style_label_right, size=size.tiny)
        lon_l_lbl := label.new(lon_bar, lon_lo, "London L",
                                color=color.new(lon_col, 20), textcolor=color.black,
                                style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────
//  NEW YORK
// ─────────────────────────────────────────
in_ny  = not na(time(timeframe.period, ny_start))
ny_new = f_session_start(ny_start)

var float ny_hi      = na
var float ny_lo      = na
var int   ny_bar     = na
var line  ny_h_line  = na
var line  ny_l_line  = na
var label ny_h_lbl   = na
var label ny_l_lbl   = na
var bool  ny_h_taken = false
var bool  ny_l_taken = false

if ny_new
    ny_hi      := high
    ny_lo      := low
    ny_bar     := bar_index
    ny_h_taken := false
    ny_l_taken := false
    if ny_show
        f_del_line(ny_h_line)
        f_del_line(ny_l_line)
        f_del_label(ny_h_lbl)
        f_del_label(ny_l_lbl)

if in_ny
    ny_hi := math.max(nz(ny_hi, high), high)
    ny_lo := math.min(nz(ny_lo, low),  low)

if not in_ny and not na(ny_hi)
    if high >= ny_hi and not ny_h_taken
        ny_h_taken := true
        f_del_line(ny_h_line)
        f_del_label(ny_h_lbl)
        ny_h_line := na
        ny_h_lbl  := na
    if low <= ny_lo and not ny_l_taken
        ny_l_taken := true
        f_del_line(ny_l_line)
        f_del_label(ny_l_lbl)
        ny_l_line := na
        ny_l_lbl  := na

if in_ny and ny_show and not na(ny_bar)
    f_del_line(ny_h_line)
    f_del_line(ny_l_line)
    f_del_label(ny_h_lbl)
    f_del_label(ny_l_lbl)
    ny_h_line := line.new(ny_bar, ny_hi, bar_index, ny_hi,
                           color=ny_col, width=line_width, style=ls, extend=ext)
    ny_l_line := line.new(ny_bar, ny_lo, bar_index, ny_lo,
                           color=ny_col, width=line_width, style=ls, extend=ext)
    if show_labels
        ny_h_lbl := label.new(ny_bar, ny_hi, "NY H",
                               color=color.new(ny_col, 20), textcolor=color.black,
                               style=label.style_label_right, size=size.tiny)
        ny_l_lbl := label.new(ny_bar, ny_lo, "NY L",
                               color=color.new(ny_col, 20), textcolor=color.black,
                               style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────
//  NY AM
// ─────────────────────────────────────────
in_nyam  = not na(time(timeframe.period, nyam_start))
nyam_new = f_session_start(nyam_start)

var float nyam_hi      = na
var float nyam_lo      = na
var int   nyam_bar     = na
var line  nyam_h_line  = na
var line  nyam_l_line  = na
var label nyam_h_lbl   = na
var label nyam_l_lbl   = na
var bool  nyam_h_taken = false
var bool  nyam_l_taken = false

if nyam_new
    nyam_hi      := high
    nyam_lo      := low
    nyam_bar     := bar_index
    nyam_h_taken := false
    nyam_l_taken := false
    if nyam_show
        f_del_line(nyam_h_line)
        f_del_line(nyam_l_line)
        f_del_label(nyam_h_lbl)
        f_del_label(nyam_l_lbl)

if in_nyam
    nyam_hi := math.max(nz(nyam_hi, high), high)
    nyam_lo := math.min(nz(nyam_lo, low),  low)

if not in_nyam and not na(nyam_hi)
    if high >= nyam_hi and not nyam_h_taken
        nyam_h_taken := true
        f_del_line(nyam_h_line)
        f_del_label(nyam_h_lbl)
        nyam_h_line := na
        nyam_h_lbl  := na
    if low <= nyam_lo and not nyam_l_taken
        nyam_l_taken := true
        f_del_line(nyam_l_line)
        f_del_label(nyam_l_lbl)
        nyam_l_line := na
        nyam_l_lbl  := na

if in_nyam and nyam_show and not na(nyam_bar)
    f_del_line(nyam_h_line)
    f_del_line(nyam_l_line)
    f_del_label(nyam_h_lbl)
    f_del_label(nyam_l_lbl)
    nyam_h_line := line.new(nyam_bar, nyam_hi, bar_index, nyam_hi,
                             color=nyam_col, width=line_width, style=ls, extend=ext)
    nyam_l_line := line.new(nyam_bar, nyam_lo, bar_index, nyam_lo,
                             color=nyam_col, width=line_width, style=ls, extend=ext)
    if show_labels
        nyam_h_lbl := label.new(nyam_bar, nyam_hi, "NY AM H",
                                 color=color.new(nyam_col, 20), textcolor=color.black,
                                 style=label.style_label_right, size=size.tiny)
        nyam_l_lbl := label.new(nyam_bar, nyam_lo, "NY AM L",
                                 color=color.new(nyam_col, 20), textcolor=color.black,
                                 style=label.style_label_right, size=size.tiny)

// ─────────────────────────────────────────
//  ALERTES
// ─────────────────────────────────────────
alertcondition(high >= asia_hi[1] and not in_asia, "Sweep Asia High",   "Price swept Asia Session High!")
alertcondition(low  <= asia_lo[1] and not in_asia, "Sweep Asia Low",    "Price swept Asia Session Low!")
alertcondition(high >= lon_hi[1]  and not in_lon,  "Sweep London High", "Price swept London Session High!")
alertcondition(low  <= lon_lo[1]  and not in_lon,  "Sweep London Low",  "Price swept London Session Low!")
alertcondition(high >= ny_hi[1]   and not in_ny,   "Sweep NY High",     "Price swept New York Session High!")
alertcondition(low  <= ny_lo[1]   and not in_ny,   "Sweep NY Low",      "Price swept New York Session Low!")
````
