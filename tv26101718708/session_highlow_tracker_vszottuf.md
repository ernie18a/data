# Session High/Low Tracker

- url: https://www.tradingview.com/script/VsZoTTuf-Session-High-Low-Tracker/
- type: indicator
- pine_id: PUB;69bb5791f577493fbb2528c6b02da359
- version: 1.0

## Description

Sessions are defined using named timezone strings (Asia/Tokyo · Europe/London · America/New_York), so DST transitions in any country are handled automatically. No UTC offsets. No manual adjustments. No broken sessions twice a year.

Features
— Session boxes with configurable colours and transparency
— High (solid) and Low (dashed) lines per session
— Range label on every completed and active session
— Live labels that update in real time
— London / NY overlap displayed simultaneously
— Background tint indicating the active session
— Optional midpoint and extend-right modes
— All elements individually toggleable

Compatible with any instrument that trades across these hours — Forex, Gold, major indices, crypto. Designed for intraday timeframes: 1m through 4H.

Simple, accurate, automatic.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  SESSION HIGH / LOW TRACKER  —  v2.1
//  Pine Script v5  |  overlay=true
//
//  ✔  Asia · London · New York sessions with auto DST (no manual offset)
//  ✔  Boxes, H/L lines and labels for completed AND live sessions
//  ✔  Live objects updated via set_*() every bar → correct on zoom & pan
//  ✔  Table removed per user request
//
//  Best timeframes : 1m  5m  15m  30m  1H  4H
//  ⚠  Daily/weekly charts cannot resolve intraday sessions
// ══════════════════════════════════════════════════════════════════════════════
//@version=5
indicator("Session High/Low Tracker", shorttitle="Session H/L",
          overlay=true, max_lines_count=500, max_labels_count=300, max_boxes_count=300)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
G_ASIA = "🌏  Asia / Tokyo  —  09:00–18:00 JST  (= 00:00–09:00 UTC)"
G_LON  = "🌍  London  —  08:00–16:30 GMT/BST  (auto DST)"
G_NY   = "🗽  New York  —  09:30–16:00 EST/EDT  (auto DST)"
G_DISP = "⚙️  Display"

// Asia
asia_on   = input.bool(true,  "Show",  group=G_ASIA, inline="a")
asia_bg   = input.color(color.new(#F9A825, 90), "Box",   group=G_ASIA, inline="a")
asia_line = input.color(#F9A825,                "Lines", group=G_ASIA, inline="a")

// London
lon_on    = input.bool(true,  "Show",  group=G_LON, inline="l")
lon_bg    = input.color(color.new(#1E88E5, 90), "Box",   group=G_LON, inline="l")
lon_line  = input.color(#1E88E5,                "Lines", group=G_LON, inline="l")

// New York
ny_on     = input.bool(true,  "Show",  group=G_NY, inline="n")
ny_bg     = input.color(color.new(#43A047, 90), "Box",   group=G_NY, inline="n")
ny_line   = input.color(#43A047,                "Lines", group=G_NY, inline="n")

// Display
show_box  = input.bool(true,  "Session Boxes",           group=G_DISP)
show_hl   = input.bool(true,  "High / Low Lines",        group=G_DISP)
show_lbl  = input.bool(true,  "Session Labels",          group=G_DISP)
show_mid  = input.bool(false, "Show Midpoint Line",      group=G_DISP)
lw        = input.int(1,      "Line Width", 1, 3,        group=G_DISP)
ext_right = input.bool(false, "Extend H/L Lines Right",  group=G_DISP)

// ─────────────────────────────────────────────────────────────────────────────
//  SESSION DETECTION  — DST handled automatically via named timezone strings
//
//  Asia/Tokyo has NO DST (always UTC+9), so session is a fixed UTC window:
//    "0900-1800" JST  =  00:00–09:00 UTC  ← correct Tokyo/Asia session
//    "0000-0900" JST  =  15:00–00:00 UTC  ← WRONG (that's NY evening time!)
// ─────────────────────────────────────────────────────────────────────────────
tf = timeframe.period

in_asia = not na(time(tf, "0900-1800:23456", "Asia/Tokyo"))
in_lon  = not na(time(tf, "0800-1630:23456", "Europe/London"))
in_ny   = not na(time(tf, "0930-1600:23456", "America/New_York"))

asia_open  = in_asia and not in_asia[1]
asia_close = not in_asia and in_asia[1]
lon_open   = in_lon  and not in_lon[1]
lon_close  = not in_lon  and in_lon[1]
ny_open    = in_ny   and not in_ny[1]
ny_close   = not in_ny   and in_ny[1]

// ─────────────────────────────────────────────────────────────────────────────
//  HIGH / LOW TRACKING
// ─────────────────────────────────────────────────────────────────────────────
var float ah = na, var float al = na, var int ab = na
var float lh = na, var float ll = na, var int lb = na
var float nh = na, var float nl = na, var int nb = na

if asia_open
    ah := high,  al := low,  ab := bar_index
else if in_asia
    ah := math.max(ah, high), al := math.min(al, low)

if lon_open
    lh := high,  ll := low,  lb := bar_index
else if in_lon
    lh := math.max(lh, high), ll := math.min(ll, low)

if ny_open
    nh := high,  nl := low,  nb := bar_index
else if in_ny
    nh := math.max(nh, high), nl := math.min(nl, low)

// ─────────────────────────────────────────────────────────────────────────────
//  DRAW COMPLETED SESSION  (called once at session close)
// ─────────────────────────────────────────────────────────────────────────────
ext_mode = ext_right ? extend.right : extend.none

f_complete(s_bar, e_bar, s_hi, s_lo, bg, col, name) =>
    if not na(s_bar) and not na(s_hi)
        mid_bar = s_bar + int((e_bar - s_bar) / 2)
        rng     = math.abs(s_hi - s_lo)
        if show_box
            box.new(s_bar, s_hi, e_bar, s_lo, bgcolor=bg, border_color=col, border_width=1)
        if show_hl
            line.new(s_bar, s_hi, e_bar, s_hi,
                     color=col, width=lw, extend=ext_mode)
            line.new(s_bar, s_lo, e_bar, s_lo,
                     color=col, width=lw, style=line.style_dashed, extend=ext_mode)
            if show_mid
                line.new(s_bar, math.avg(s_hi, s_lo), e_bar, math.avg(s_hi, s_lo),
                         color=col, width=1, style=line.style_dotted, extend=ext_mode)
        if show_lbl
            label.new(mid_bar, s_hi,
                      name + "\n▲ " + str.tostring(s_hi, format.mintick) +
                      "  ▼ " + str.tostring(s_lo, format.mintick) +
                      "\nRange " + str.tostring(rng, format.mintick),
                      color=color.new(col, 10), textcolor=color.white,
                      style=label.style_label_down, size=size.small)

if asia_close and asia_on
    f_complete(ab, bar_index - 1, ah, al, asia_bg, asia_line, "Asia")
if lon_close and lon_on
    f_complete(lb, bar_index - 1, lh, ll, lon_bg,  lon_line,  "London")
if ny_close and ny_on
    f_complete(nb, bar_index - 1, nh, nl, ny_bg,   ny_line,   "New York")

// ─────────────────────────────────────────────────────────────────────────────
//  LIVE SESSION OBJECTS
//  Key design: objects are CREATED once on session open, then UPDATED via
//  set_*() on every subsequent bar.  This ensures correct rendering when the
//  user zooms or pans — no delete/recreate flicker, works on historical bars.
// ─────────────────────────────────────────────────────────────────────────────
var box   a_bx = na, var line a_hl = na, var line a_ll = na, var label a_lb = na
var box   l_bx = na, var line l_hl = na, var line l_ll = na, var label l_lb = na
var box   n_bx = na, var line n_hl = na, var line n_ll = na, var label n_lb = na

// ── Helper: build label text
f_live_txt(name, s_hi, s_lo) =>
    name + " ●\n▲ " + str.tostring(s_hi, format.mintick) + "  ▼ " + str.tostring(s_lo, format.mintick)

// ════════  ASIA  ════════
if asia_open and asia_on
    // Destroy any leftover objects from a previous session
    box.delete(a_bx),   line.delete(a_hl),  line.delete(a_ll),  label.delete(a_lb)
    // Create fresh objects anchored to the opening bar
    if show_box
        a_bx := box.new(bar_index, high, bar_index, low, bgcolor=asia_bg, border_color=asia_line, border_width=1)
    if show_hl
        a_hl := line.new(bar_index, high, bar_index, high, color=asia_line, width=lw)
        a_ll := line.new(bar_index, low,  bar_index, low,  color=asia_line, width=lw, style=line.style_dashed)
    if show_lbl
        a_lb := label.new(bar_index, high, f_live_txt("Asia", high, low),
                          color=color.new(asia_line, 8), textcolor=color.white,
                          style=label.style_label_left, size=size.small)

// Update every bar while Asia is open (NOT on the open bar itself)
if in_asia and asia_on and not asia_open
    if show_box and not na(a_bx)
        box.set_right(a_bx,   bar_index)
        box.set_top(a_bx,     ah)
        box.set_bottom(a_bx,  al)
    if show_hl
        if not na(a_hl)
            line.set_x2(a_hl, bar_index)
            line.set_y1(a_hl, ah), line.set_y2(a_hl, ah)
        if not na(a_ll)
            line.set_x2(a_ll, bar_index)
            line.set_y1(a_ll, al), line.set_y2(a_ll, al)
    if show_lbl and not na(a_lb)
        label.set_x(a_lb,    bar_index)
        label.set_y(a_lb,    ah)
        label.set_text(a_lb, f_live_txt("Asia", ah, al))

// ════════  LONDON  ════════
if lon_open and lon_on
    box.delete(l_bx),   line.delete(l_hl),  line.delete(l_ll),  label.delete(l_lb)
    if show_box
        l_bx := box.new(bar_index, high, bar_index, low, bgcolor=lon_bg, border_color=lon_line, border_width=1)
    if show_hl
        l_hl := line.new(bar_index, high, bar_index, high, color=lon_line, width=lw)
        l_ll := line.new(bar_index, low,  bar_index, low,  color=lon_line, width=lw, style=line.style_dashed)
    if show_lbl
        l_lb := label.new(bar_index, high, f_live_txt("London", high, low),
                          color=color.new(lon_line, 8), textcolor=color.white,
                          style=label.style_label_left, size=size.small)

if in_lon and lon_on and not lon_open
    if show_box and not na(l_bx)
        box.set_right(l_bx,   bar_index)
        box.set_top(l_bx,     lh)
        box.set_bottom(l_bx,  ll)
    if show_hl
        if not na(l_hl)
            line.set_x2(l_hl, bar_index)
            line.set_y1(l_hl, lh), line.set_y2(l_hl, lh)
        if not na(l_ll)
            line.set_x2(l_ll, bar_index)
            line.set_y1(l_ll, ll), line.set_y2(l_ll, ll)
    if show_lbl and not na(l_lb)
        label.set_x(l_lb,    bar_index)
        label.set_y(l_lb,    lh)
        label.set_text(l_lb, f_live_txt("London", lh, ll))

// ════════  NEW YORK  ════════
if ny_open and ny_on
    box.delete(n_bx),   line.delete(n_hl),  line.delete(n_ll),  label.delete(n_lb)
    if show_box
        n_bx := box.new(bar_index, high, bar_index, low, bgcolor=ny_bg, border_color=ny_line, border_width=1)
    if show_hl
        n_hl := line.new(bar_index, high, bar_index, high, color=ny_line, width=lw)
        n_ll := line.new(bar_index, low,  bar_index, low,  color=ny_line, width=lw, style=line.style_dashed)
    if show_lbl
        n_lb := label.new(bar_index, high, f_live_txt("New York", high, low),
                          color=color.new(ny_line, 8), textcolor=color.white,
                          style=label.style_label_left, size=size.small)

if in_ny and ny_on and not ny_open
    if show_box and not na(n_bx)
        box.set_right(n_bx,   bar_index)
        box.set_top(n_bx,     nh)
        box.set_bottom(n_bx,  nl)
    if show_hl
        if not na(n_hl)
            line.set_x2(n_hl, bar_index)
            line.set_y1(n_hl, nh), line.set_y2(n_hl, nh)
        if not na(n_ll)
            line.set_x2(n_ll, bar_index)
            line.set_y1(n_ll, nl), line.set_y2(n_ll, nl)
    if show_lbl and not na(n_lb)
        label.set_x(n_lb,    bar_index)
        label.set_y(n_lb,    nh)
        label.set_text(n_lb, f_live_txt("New York", nh, nl))

// ─────────────────────────────────────────────────────────────────────────────
//  SUBTLE BACKGROUND TINT (active session bars)
// ─────────────────────────────────────────────────────────────────────────────
bar_col = in_ny and in_lon ? color.new(color.orange, 95) :
          in_ny            ? color.new(ny_line,   97)    :
          in_lon           ? color.new(lon_line,  97)    :
          in_asia          ? color.new(asia_line, 97)    : na
bgcolor(bar_col, title="Session Background")
````
