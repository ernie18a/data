# NY Opening Range 

- url: https://www.tradingview.com/script/cI5aPZ5T-NY-Opening-Range/
- type: indicator
- pine_id: PUB;8443dd05ed804d4585e2123e850c5f5f
- version: 1.0

## Description

welcome to the locker welcome to the locker welcome to the locker welcome to the locker welcome to the locker welcome to the locker welcome to the locker welcome to the locker

## Source Code

````pine
//@version=5
indicator("NY Opening Range (9:30–10:00 EST)", overlay=true, max_lines_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_time    = "Session Settings"
grp_style   = "Line Style"
grp_labels  = "Labels"
grp_ext     = "Extensions"

session_start_hour   = input.int(9,  "Start Hour (EST)",   minval=0, maxval=23, group=grp_time)
session_start_minute = input.int(30, "Start Minute",       minval=0, maxval=59, group=grp_time)
session_end_hour     = input.int(10, "End Hour (EST)",     minval=0, maxval=23, group=grp_time)
session_end_minute   = input.int(0,  "End Minute",         minval=0, maxval=59, group=grp_time)

high_color    = input.color(color.new(#00C853, 0),  "High Line Color",  group=grp_style)
low_color     = input.color(color.new(#FF1744, 0),  "Low Line Color",   group=grp_style)
mid_show      = input.bool(true,                     "Show Midline",     group=grp_style)
mid_color     = input.color(color.new(#FFD600, 60),  "Midline Color",    group=grp_style)
line_width    = input.int(2, "Line Width", minval=1, maxval=4,           group=grp_style)
line_style_choice = input.string("Solid", "Line Style",
     options=["Solid", "Dashed", "Dotted"],                              group=grp_style)
fill_range    = input.bool(true,  "Fill Range Background",               group=grp_style)
fill_color    = input.color(color.new(#2962FF, 90), "Fill Color",       group=grp_style)

extend_right  = input.bool(true,  "Extend Lines Right",                  group=grp_ext)
extend_bars   = input.int(50,     "Extend Bars (if not to right edge)",
     minval=1, maxval=500,                                               group=grp_ext)

show_labels   = input.bool(true,  "Show High/Low Labels",               group=grp_labels)
show_price    = input.bool(true,  "Show Price in Label",                 group=grp_labels)
label_size_choice = input.string("Normal", "Label Size",
     options=["Tiny","Small","Normal","Large"],                           group=grp_labels)

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_line_style(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_label_size(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        =>         size.normal

in_session(h1, m1, h2, m2) =>
    t = hour * 60 + minute
    t >= h1 * 60 + m1 and t < h2 * 60 + m2

is_range_bar  = in_session(session_start_hour, session_start_minute, session_end_hour, session_end_minute)

// ─── STATE ────────────────────────────────────────────────────────────────────
var float  range_high  = na
var float  range_low   = na
var int    range_start = na
var int    range_end   = na

var line   high_line   = na
var line   low_line    = na
var line   mid_line    = na
var linefill lf        = na
var label  high_lbl    = na
var label  low_lbl     = na

is_new_day = ta.change(dayofweek) != 0 or (hour == session_start_hour and minute == session_start_minute and bar_index > 1 and not is_range_bar[1])

if is_new_day
    range_high := na
    range_low  := na

if is_range_bar
    if na(range_high)
        range_high := high
        range_low  := low
        range_start := bar_index
    else
        range_high := math.max(range_high, high)
        range_low  := math.min(range_low,  low)
    range_end := bar_index

range_just_closed = not is_range_bar and not na(range_high) and not na(range_end) and bar_index == range_end + 1

if range_just_closed
    ext  = extend_right ? extend.right : extend.none
    ls   = f_line_style(line_style_choice)
    lsz  = f_label_size(label_size_choice)
    end_bar = bar_index + extend_bars

    line.delete(high_line)
    line.delete(low_line)
    line.delete(mid_line)
    label.delete(high_lbl)
    label.delete(low_lbl)

    high_line := line.new(
         x1=range_start, y1=range_high,
         x2=end_bar,     y2=range_high,
         xloc=xloc.bar_index,
         color=high_color, width=line_width, style=ls, extend=ext)

    low_line := line.new(
         x1=range_start, y1=range_low,
         x2=end_bar,     y2=range_low,
         xloc=xloc.bar_index,
         color=low_color, width=line_width, style=ls, extend=ext)

    mid_val = math.avg(range_high, range_low)
    if mid_show
        mid_line := line.new(
             x1=range_start, y1=mid_val,
             x2=end_bar,     y2=mid_val,
             xloc=xloc.bar_index,
             color=mid_color, width=1, style=line.style_dashed, extend=ext)

    if fill_range
        lf := linefill.new(high_line, low_line, fill_color)

    if show_labels
        high_txt = show_price ? "OR High: " + str.tostring(range_high, format.mintick) : "OR High"
        low_txt  = show_price ? "OR Low: "  + str.tostring(range_low,  format.mintick) : "OR Low"

        high_lbl := label.new(
             x=range_end, y=range_high,
             text=high_txt, xloc=xloc.bar_index,
             style=label.style_label_right,
             color=color.new(high_color, 20),
             textcolor=color.white, size=lsz)

        low_lbl := label.new(
             x=range_end, y=range_low,
             text=low_txt, xloc=xloc.bar_index,
             style=label.style_label_right,
             color=color.new(low_color, 20),
             textcolor=color.white, size=lsz)

bgcolor(is_range_bar ? color.new(#2962FF, 92) : na, title="Opening Range Window")
````
