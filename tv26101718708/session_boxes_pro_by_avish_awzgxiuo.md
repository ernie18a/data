# Session Boxes Pro By Avish

- url: https://www.tradingview.com/script/AWZGxIuo-Session-Boxes-Pro-By-Avish/
- type: indicator
- pine_id: PUB;cac74f3fd554488e984bed5c0057de14
- version: 2.0

## Description

Session Boxes Pro - Asia / London / NY

A clean, professional session visualization tool that highlights the three major Forex trading sessions directly on your chart - Asia, London, and New York.

Each session is drawn as a dynamic price box that builds in real time, capturing the exact high and low range as the session develops. When the session closes, the box locks in permanently as a reference level for the next session.

What is included:

Session Boxes - Asia (purple), London (red), New York (green). Each box tracks the live high and low range and updates bar by bar.

Session Labels - Asia, London, New York - pinned inside each box at the top corner so you always know which zone you are looking at.

Boundary Lines - dashed vertical lines mark the open and close of every session, giving you clean visual separation between market periods.

Dashboard Table - a live top-right panel showing each session current status (LIVE or Closed), the session range in price units, and a Bull or Bear bias based on where price sits relative to the session midpoint.

200 EMA - fully integrated with toggle, colour picker, width control, and three style options (Solid, Dashed, Dotted) so it fits any chart setup.

Fully customisable - every colour, time window, label size, and toggle is editable from the Settings panel. Works on all assets and timeframes including Forex, Gold, indices, and crypto.

Best used on: 1m, 5m, 15m, 20m, 1H timeframes.

## Source Code

````pine
//@version=6
indicator("Session Boxes Pro – Asia / London / NY", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── ASIA INPUTS ──────────────────────────────────────────────────────────────
asia_show     = input.bool(true,   "Show Asia Session",           group="🟣 Asia Session")
asia_session  = input.session("2300-0800", "Asia Time (UTC)",     group="🟣 Asia Session")
asia_bg       = input.color(color.new(#A855F7, 88), "Box Fill",   group="🟣 Asia Session")
asia_border   = input.color(color.new(#A855F7, 50), "Box Border", group="🟣 Asia Session")
asia_label_c  = input.color(color.new(#A855F7, 20), "Label Color",group="🟣 Asia Session")

// ─── LONDON INPUTS ────────────────────────────────────────────────────────────
lon_show      = input.bool(true,   "Show London Session",         group="🔴 London Session")
lon_session   = input.session("0700-1600", "London Time (UTC)",   group="🔴 London Session")
lon_bg        = input.color(color.new(#EF4444, 88), "Box Fill",   group="🔴 London Session")
lon_border    = input.color(color.new(#EF4444, 50), "Box Border", group="🔴 London Session")
lon_label_c   = input.color(color.new(#EF4444, 20), "Label Color",group="🔴 London Session")

// ─── NEW YORK INPUTS ──────────────────────────────────────────────────────────
ny_show       = input.bool(true,   "Show New York Session",       group="🟢 New York Session")
ny_session    = input.session("1200-2100", "NY Time (UTC)",       group="🟢 New York Session")
ny_bg         = input.color(color.new(#22C55E, 88), "Box Fill",   group="🟢 New York Session")
ny_border     = input.color(color.new(#22C55E, 50), "Box Border", group="🟢 New York Session")
ny_label_c    = input.color(color.new(#22C55E, 20), "Label Color",group="🟢 New York Session")

// ─── LABEL INPUTS ─────────────────────────────────────────────────────────────
lbl_show      = input.bool(true,  "Show Session Labels",          group="🏷️ Labels")
lbl_size_str  = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large"], group="🏷️ Labels")
lbl_size      = lbl_size_str == "Tiny" ? size.tiny : lbl_size_str == "Small" ? size.small : lbl_size_str == "Large" ? size.large : size.normal

// ─── DASHBOARD INPUTS ─────────────────────────────────────────────────────────
dash_show     = input.bool(true,  "Show Dashboard",               group="📋 Dashboard")
dash_tbl_bg   = input.color(color.new(#1E1E2E, 10), "Table Background", group="📋 Dashboard")
dash_txt      = input.color(#FFFFFF, "Text Color",                group="📋 Dashboard")

// ─── 200 EMA INPUTS ───────────────────────────────────────────────────────────
ema_show      = input.bool(true,  "Show 200 EMA",                 group="📈 200 EMA")
ema_source    = input.source(close, "EMA Source",                  group="📈 200 EMA")
ema_color     = input.color(#F59E0B, "EMA Color",                 group="📈 200 EMA")
ema_width     = input.int(2, "EMA Width", minval=1, maxval=5,     group="📈 200 EMA")
ema_style_str = input.string("Solid", "EMA Style", options=["Solid","Dashed","Dotted"], group="📈 200 EMA")

// ─── VERTICAL LINE INPUT ──────────────────────────────────────────────────────
vline_show    = input.bool(true,  "Show Boundary Lines",          group="⚙️ General")

// ─── 200 EMA CALCULATION ──────────────────────────────────────────────────────
ema200 = ta.ema(ema_source, 200)
plot(ema_show and ema_style_str == "Solid"  ? ema200 : na, title="200 EMA (Solid)",  color=ema_color, linewidth=ema_width, style=plot.style_line)
plot(ema_show and ema_style_str == "Dashed" ? ema200 : na, title="200 EMA (Dashed)", color=ema_color, linewidth=ema_width, style=plot.style_linebr)
plot(ema_show and ema_style_str == "Dotted" ? ema200 : na, title="200 EMA (Dotted)", color=ema_color, linewidth=1,         style=plot.style_circles)

// ─── SESSION DETECTION ────────────────────────────────────────────────────────
in_asia   = not na(time(timeframe.period, asia_session, "UTC"))
in_london = not na(time(timeframe.period, lon_session,  "UTC"))
in_ny     = not na(time(timeframe.period, ny_session,   "UTC"))

// ─── STATE VARIABLES ──────────────────────────────────────────────────────────
var box   asia_box = na
var box   lon_box  = na
var box   ny_box   = na
var label asia_lbl = na
var label lon_lbl  = na
var label ny_lbl   = na

var float asia_hi = na
var float asia_lo = na
var float lon_hi  = na
var float lon_lo  = na
var float ny_hi   = na
var float ny_lo   = na

// ─── HELPER: VERTICAL LINE ────────────────────────────────────────────────────
draw_vline(idx, col) =>
    if vline_show
        line.new(idx, high * 1.1, idx, low * 0.9, extend=extend.both, color=col, style=line.style_dashed, width=1)

// ─── HELPER: LABEL ────────────────────────────────────────────────────────────
draw_label(idx, price, txt, txt_col) =>
    label.new(idx, price, txt, style=label.style_label_lower_right, color=color.new(#000000, 100), textcolor=txt_col, size=lbl_size)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
var table dash = na
if dash_show and barstate.islast
    dash := table.new(position.top_right, 4, 4, bgcolor=dash_tbl_bg, border_color=color.new(#FFFFFF, 70), border_width=1, frame_color=color.new(#FFFFFF, 60), frame_width=1)

    table.cell(dash, 0, 0, "SESSION", text_color=color.new(dash_txt, 30), text_size=size.small, bgcolor=color.new(#000000, 60))
    table.cell(dash, 1, 0, "STATUS",  text_color=color.new(dash_txt, 30), text_size=size.small, bgcolor=color.new(#000000, 60))
    table.cell(dash, 2, 0, "RANGE",   text_color=color.new(dash_txt, 30), text_size=size.small, bgcolor=color.new(#000000, 60))
    table.cell(dash, 3, 0, "BIAS",    text_color=color.new(dash_txt, 30), text_size=size.small, bgcolor=color.new(#000000, 60))

    a_rng  = not na(asia_hi) and not na(asia_lo) ? str.tostring(math.round((asia_hi - asia_lo) * 10) / 10) : "—"
    a_mid  = not na(asia_hi) and not na(asia_lo) ? (asia_hi + asia_lo) / 2.0 : na
    a_bias = not na(a_mid) ? (close > a_mid ? "▲ Bull" : "▼ Bear") : "—"
    a_stat = in_asia ? "● LIVE" : "○ Closed"
    a_sc   = in_asia ? #A855F7 : color.new(dash_txt, 50)
    a_bc   = a_bias == "▲ Bull" ? #22C55E : #EF4444
    table.cell(dash, 0, 1, "Asia",  text_color=#A855F7, text_size=size.small)
    table.cell(dash, 1, 1, a_stat,  text_color=a_sc,    text_size=size.small)
    table.cell(dash, 2, 1, a_rng,   text_color=dash_txt,text_size=size.small)
    table.cell(dash, 3, 1, a_bias,  text_color=a_bc,    text_size=size.small)

    l_rng  = not na(lon_hi) and not na(lon_lo) ? str.tostring(math.round((lon_hi - lon_lo) * 10) / 10) : "—"
    l_mid  = not na(lon_hi) and not na(lon_lo) ? (lon_hi + lon_lo) / 2.0 : na
    l_bias = not na(l_mid) ? (close > l_mid ? "▲ Bull" : "▼ Bear") : "—"
    l_stat = in_london ? "● LIVE" : "○ Closed"
    l_sc   = in_london ? #EF4444 : color.new(dash_txt, 50)
    l_bc   = l_bias == "▲ Bull" ? #22C55E : #EF4444
    table.cell(dash, 0, 2, "London",text_color=#EF4444, text_size=size.small)
    table.cell(dash, 1, 2, l_stat,  text_color=l_sc,    text_size=size.small)
    table.cell(dash, 2, 2, l_rng,   text_color=dash_txt,text_size=size.small)
    table.cell(dash, 3, 2, l_bias,  text_color=l_bc,    text_size=size.small)

    n_rng  = not na(ny_hi) and not na(ny_lo) ? str.tostring(math.round((ny_hi - ny_lo) * 10) / 10) : "—"
    n_mid  = not na(ny_hi) and not na(ny_lo) ? (ny_hi + ny_lo) / 2.0 : na
    n_bias = not na(n_mid) ? (close > n_mid ? "▲ Bull" : "▼ Bear") : "—"
    n_stat = in_ny ? "● LIVE" : "○ Closed"
    n_sc   = in_ny ? #22C55E : color.new(dash_txt, 50)
    n_bc   = n_bias == "▲ Bull" ? #22C55E : #EF4444
    table.cell(dash, 0, 3, "New York",text_color=#22C55E,text_size=size.small)
    table.cell(dash, 1, 3, n_stat,    text_color=n_sc,   text_size=size.small)
    table.cell(dash, 2, 3, n_rng,     text_color=dash_txt,text_size=size.small)
    table.cell(dash, 3, 3, n_bias,    text_color=n_bc,   text_size=size.small)

// ─── ASIA BOX ────────────────────────────────────────────────────────────────
if asia_show
    if in_asia and not in_asia[1]
        asia_hi := high
        asia_lo := low
        asia_box := box.new(bar_index, high, bar_index, low, border_color=asia_border, bgcolor=asia_bg, border_width=1, border_style=line.style_solid)
        if lbl_show
            asia_lbl := draw_label(bar_index, high, "Asia", asia_label_c)
        draw_vline(bar_index, asia_border)

    if in_asia and not na(asia_box)
        asia_hi := math.max(asia_hi, high)
        asia_lo := math.min(asia_lo, low)
        box.set_right(asia_box, bar_index)
        box.set_top(asia_box, asia_hi)
        box.set_bottom(asia_box, asia_lo)
        if lbl_show and not na(asia_lbl)
            label.set_x(asia_lbl, bar_index)
            label.set_y(asia_lbl, asia_hi)

    if not in_asia and in_asia[1] and not na(asia_box)
        draw_vline(bar_index, asia_border)
        asia_box := na

// ─── LONDON BOX ──────────────────────────────────────────────────────────────
if lon_show
    if in_london and not in_london[1]
        lon_hi := high
        lon_lo := low
        lon_box := box.new(bar_index, high, bar_index, low, border_color=lon_border, bgcolor=lon_bg, border_width=1, border_style=line.style_solid)
        if lbl_show
            lon_lbl := draw_label(bar_index, high, "London", lon_label_c)
        draw_vline(bar_index, lon_border)

    if in_london and not na(lon_box)
        lon_hi := math.max(lon_hi, high)
        lon_lo := math.min(lon_lo, low)
        box.set_right(lon_box, bar_index)
        box.set_top(lon_box, lon_hi)
        box.set_bottom(lon_box, lon_lo)
        if lbl_show and not na(lon_lbl)
            label.set_x(lon_lbl, bar_index)
            label.set_y(lon_lbl, lon_hi)

    if not in_london and in_london[1] and not na(lon_box)
        draw_vline(bar_index, lon_border)
        lon_box := na

// ─── NEW YORK BOX ────────────────────────────────────────────────────────────
if ny_show
    if in_ny and not in_ny[1]
        ny_hi := high
        ny_lo := low
        ny_box := box.new(bar_index, high, bar_index, low, border_color=ny_border, bgcolor=ny_bg, border_width=1, border_style=line.style_solid)
        if lbl_show
            ny_lbl := draw_label(bar_index, high, "New York", ny_label_c)
        draw_vline(bar_index, ny_border)

    if in_ny and not na(ny_box)
        ny_hi := math.max(ny_hi, high)
        ny_lo := math.min(ny_lo, low)
        box.set_right(ny_box, bar_index)
        box.set_top(ny_box, ny_hi)
        box.set_bottom(ny_box, ny_lo)
        if lbl_show and not na(ny_lbl)
            label.set_x(ny_lbl, bar_index)
            label.set_y(ny_lbl, ny_hi)

    if not in_ny and in_ny[1] and not na(ny_box)
        draw_vline(bar_index, ny_border)
        ny_box := na
````
