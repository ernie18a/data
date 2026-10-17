# Daily Vertical Lines

- url: https://www.tradingview.com/script/MeJszkO1-Daily-Vertical-Lines/
- type: indicator
- pine_id: PUB;f55dbe0c38d3463f9e562e4f09d73783
- version: 3.0

## Description

Here's a clean, publish-ready description:

Daily Vertical Lines (ET) — Session Time Markers
Mark key intraday times directly on your chart with up to 10 fully configurable vertical lines, all anchored to Eastern Time (America/New_York) with automatic DST handling.
Purpose
Designed for traders who work off fixed intraday time levels — open auctions, macro releases, session midpoints, settlement windows, or any recurring time-based setup. Each line fires once per trading day at its configured ET time and is automatically cleared and redrawn fresh every day at 4:00 AM ET.
Features

10 independent vertical lines, each fully configurable
Per-line controls: enable/disable line, enable/disable label, time (hour + minute in ET), color, label text, line style (Solid / Dashed / Dotted), and line width
Lines and labels are independently toggleable — run clean lines with no text, or labels only, or both
Full-height vertical lines that extend across the entire chart regardless of price scale or zoom level
Automatic daily reset at 4:00 AM ET — previous day's objects are deleted and a fresh set is drawn for the current day
Duplicate prevention — each line can only fire once per day regardless of bar replays or real-time ticks
DST-aware via Pine's native America/New_York timezone — no manual offset adjustments needed

Default Times
9:50 · 10:00 · 10:30 · 11:00 · 12:00 · 12:30 · 1:00 · 1:30 · 2:00 · 3:48
Compatibility
Works on any intraday timeframe. For best results use a resolution fine enough that each configured time has a matching candle (e.g. a 1-minute or 5-minute chart). Not designed for daily or higher timeframes.
Notes

All times are Eastern Time. The script handles EST/EDT transitions automatically.
The 4:00 AM reset means lines from a prior session are always removed before the pre-market open.
Label text is fully editable — rename any line to match your own session labels, news events, or strategy terminology.

## Source Code

````pine
// @version=6
indicator("Daily Vertical Lines", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

// Unix timestamp for an ET wall-clock time on the current bar's calendar date.
et_ts(h, m) =>
    timestamp("America/New_York", year(time, "America/New_York"),
              month(time, "America/New_York"), dayofmonth(time, "America/New_York"), h, m, 0)

to_line_style(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 1  →  9:50 AM
// ─────────────────────────────────────────────────────────────────────────────
var g1 = "── Line 1 ──"
l1_on      = input.bool  (true,      "Enable Line",  group = g1, inline = "1a")
l1_lbl_on  = input.bool  (true,      "Enable Label", group = g1, inline = "1a")
l1_h       = input.int   (9,         "Hour (ET)",    group = g1, inline = "1b", minval = 0, maxval = 23)
l1_m       = input.int   (50,        "Minute",       group = g1, inline = "1b", minval = 0, maxval = 59)
l1_col     = input.color (#5799d6,   "Color",        group = g1, inline = "1c")
l1_txt     = input.string("9:50 AM", "Label Text",   group = g1, inline = "1c")
l1_style   = input.string("Solid",   "Style",        group = g1, inline = "1d", options = ["Solid","Dashed","Dotted"])
l1_width   = input.int   (1,         "Width",        group = g1, inline = "1d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 2  →  10:00 AM
// ─────────────────────────────────────────────────────────────────────────────
var g2 = "── Line 2 ──"
l2_on      = input.bool  (true,       "Enable Line",  group = g2, inline = "2a")
l2_lbl_on  = input.bool  (true,       "Enable Label", group = g2, inline = "2a")
l2_h       = input.int   (10,         "Hour (ET)",    group = g2, inline = "2b", minval = 0, maxval = 23)
l2_m       = input.int   (0,          "Minute",       group = g2, inline = "2b", minval = 0, maxval = 59)
l2_col     = input.color (#5799d6,    "Color",        group = g2, inline = "2c")
l2_txt     = input.string("10:00 AM", "Label Text",   group = g2, inline = "2c")
l2_style   = input.string("Solid",    "Style",        group = g2, inline = "2d", options = ["Solid","Dashed","Dotted"])
l2_width   = input.int   (1,          "Width",        group = g2, inline = "2d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 3  →  10:30 AM
// ─────────────────────────────────────────────────────────────────────────────
var g3 = "── Line 3 ──"
l3_on      = input.bool  (true,       "Enable Line",  group = g3, inline = "3a")
l3_lbl_on  = input.bool  (true,       "Enable Label", group = g3, inline = "3a")
l3_h       = input.int   (10,         "Hour (ET)",    group = g3, inline = "3b", minval = 0, maxval = 23)
l3_m       = input.int   (30,         "Minute",       group = g3, inline = "3b", minval = 0, maxval = 59)
l3_col     = input.color (#5799d6,    "Color",        group = g3, inline = "3c")
l3_txt     = input.string("10:30 AM", "Label Text",   group = g3, inline = "3c")
l3_style   = input.string("Solid",    "Style",        group = g3, inline = "3d", options = ["Solid","Dashed","Dotted"])
l3_width   = input.int   (1,          "Width",        group = g3, inline = "3d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 4  →  11:00 AM
// ─────────────────────────────────────────────────────────────────────────────
var g4 = "── Line 4 ──"
l4_on      = input.bool  (true,       "Enable Line",  group = g4, inline = "4a")
l4_lbl_on  = input.bool  (true,       "Enable Label", group = g4, inline = "4a")
l4_h       = input.int   (11,         "Hour (ET)",    group = g4, inline = "4b", minval = 0, maxval = 23)
l4_m       = input.int   (0,          "Minute",       group = g4, inline = "4b", minval = 0, maxval = 59)
l4_col     = input.color (#5799d6,    "Color",        group = g4, inline = "4c")
l4_txt     = input.string("11:00 AM", "Label Text",   group = g4, inline = "4c")
l4_style   = input.string("Solid",    "Style",        group = g4, inline = "4d", options = ["Solid","Dashed","Dotted"])
l4_width   = input.int   (1,          "Width",        group = g4, inline = "4d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 5  →  12:00 PM
// ─────────────────────────────────────────────────────────────────────────────
var g5 = "── Line 5 ──"
l5_on      = input.bool  (true,       "Enable Line",  group = g5, inline = "5a")
l5_lbl_on  = input.bool  (true,       "Enable Label", group = g5, inline = "5a")
l5_h       = input.int   (12,         "Hour (ET)",    group = g5, inline = "5b", minval = 0, maxval = 23)
l5_m       = input.int   (0,          "Minute",       group = g5, inline = "5b", minval = 0, maxval = 59)
l5_col     = input.color (#5799d6,    "Color",        group = g5, inline = "5c")
l5_txt     = input.string("12:00 PM", "Label Text",   group = g5, inline = "5c")
l5_style   = input.string("Solid",    "Style",        group = g5, inline = "5d", options = ["Solid","Dashed","Dotted"])
l5_width   = input.int   (1,          "Width",        group = g5, inline = "5d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 6  →  12:30 PM
// ─────────────────────────────────────────────────────────────────────────────
var g6 = "── Line 6 ──"
l6_on      = input.bool  (true,       "Enable Line",  group = g6, inline = "6a")
l6_lbl_on  = input.bool  (true,       "Enable Label", group = g6, inline = "6a")
l6_h       = input.int   (12,         "Hour (ET)",    group = g6, inline = "6b", minval = 0, maxval = 23)
l6_m       = input.int   (30,         "Minute",       group = g6, inline = "6b", minval = 0, maxval = 59)
l6_col     = input.color (#5799d6,    "Color",        group = g6, inline = "6c")
l6_txt     = input.string("12:30 PM", "Label Text",   group = g6, inline = "6c")
l6_style   = input.string("Solid",    "Style",        group = g6, inline = "6d", options = ["Solid","Dashed","Dotted"])
l6_width   = input.int   (1,          "Width",        group = g6, inline = "6d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 7  →  1:00 PM
// ─────────────────────────────────────────────────────────────────────────────
var g7 = "── Line 7 ──"
l7_on      = input.bool  (true,      "Enable Line",  group = g7, inline = "7a")
l7_lbl_on  = input.bool  (true,      "Enable Label", group = g7, inline = "7a")
l7_h       = input.int   (13,        "Hour (ET)",    group = g7, inline = "7b", minval = 0, maxval = 23)
l7_m       = input.int   (0,         "Minute",       group = g7, inline = "7b", minval = 0, maxval = 59)
l7_col     = input.color (#5799d6,   "Color",        group = g7, inline = "7c")
l7_txt     = input.string("1:00 PM", "Label Text",   group = g7, inline = "7c")
l7_style   = input.string("Solid",   "Style",        group = g7, inline = "7d", options = ["Solid","Dashed","Dotted"])
l7_width   = input.int   (1,         "Width",        group = g7, inline = "7d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 8  →  1:30 PM
// ─────────────────────────────────────────────────────────────────────────────
var g8 = "── Line 8 ──"
l8_on      = input.bool  (true,      "Enable Line",  group = g8, inline = "8a")
l8_lbl_on  = input.bool  (true,      "Enable Label", group = g8, inline = "8a")
l8_h       = input.int   (13,        "Hour (ET)",    group = g8, inline = "8b", minval = 0, maxval = 23)
l8_m       = input.int   (30,        "Minute",       group = g8, inline = "8b", minval = 0, maxval = 59)
l8_col     = input.color (#5799d6,   "Color",        group = g8, inline = "8c")
l8_txt     = input.string("1:30 PM", "Label Text",   group = g8, inline = "8c")
l8_style   = input.string("Solid",   "Style",        group = g8, inline = "8d", options = ["Solid","Dashed","Dotted"])
l8_width   = input.int   (1,         "Width",        group = g8, inline = "8d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 9  →  2:00 PM
// ─────────────────────────────────────────────────────────────────────────────
var g9 = "── Line 9 ──"
l9_on      = input.bool  (true,      "Enable Line",  group = g9, inline = "9a")
l9_lbl_on  = input.bool  (true,      "Enable Label", group = g9, inline = "9a")
l9_h       = input.int   (14,        "Hour (ET)",    group = g9, inline = "9b", minval = 0, maxval = 23)
l9_m       = input.int   (0,         "Minute",       group = g9, inline = "9b", minval = 0, maxval = 59)
l9_col     = input.color (#5799d6,   "Color",        group = g9, inline = "9c")
l9_txt     = input.string("2:00 PM", "Label Text",   group = g9, inline = "9c")
l9_style   = input.string("Solid",   "Style",        group = g9, inline = "9d", options = ["Solid","Dashed","Dotted"])
l9_width   = input.int   (1,         "Width",        group = g9, inline = "9d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LINE 10  →  3:48 PM
// ─────────────────────────────────────────────────────────────────────────────
var g10 = "── Line 10 ──"
l10_on     = input.bool  (true,      "Enable Line",  group = g10, inline = "10a")
l10_lbl_on = input.bool  (true,      "Enable Label", group = g10, inline = "10a")
l10_h      = input.int   (15,        "Hour (ET)",    group = g10, inline = "10b", minval = 0, maxval = 23)
l10_m      = input.int   (48,        "Minute",       group = g10, inline = "10b", minval = 0, maxval = 59)
l10_col    = input.color (#5799d6,   "Color",        group = g10, inline = "10c")
l10_txt    = input.string("3:48 PM", "Label Text",   group = g10, inline = "10c")
l10_style  = input.string("Solid",   "Style",        group = g10, inline = "10d", options = ["Solid","Dashed","Dotted"])
l10_width  = input.int   (1,         "Width",        group = g10, inline = "10d", minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STATE
// ─────────────────────────────────────────────────────────────────────────────

var line[]  lines_arr       = array.new<line>()
var label[] labels_arr      = array.new<label>()
var string  last_build_date = ""

// ─────────────────────────────────────────────────────────────────────────────
// DRAW HELPER — uses xloc.bar_time so the line is anchored to a Unix timestamp.
// This allows all lines to be drawn at 4 AM even though future candles don't
// exist yet.  The line will appear at the correct time position on the chart.
// ─────────────────────────────────────────────────────────────────────────────

draw_vline_at_time(target_ts, show_label, col, txt, ls, lw) =>
    // x1 == x2 at the target timestamp → true vertical line.
    // extend = extend.both spans the full chart height regardless of y scale.
    ln = line.new(target_ts, high, target_ts, low,
                  xloc   = xloc.bar_time,
                  extend = extend.both,
                  color  = col,
                  style  = ls,
                  width  = lw)
    array.push(lines_arr, ln)

    if show_label
        lb = label.new(target_ts, high,
                       text      = txt,
                       xloc      = xloc.bar_time,
                       yloc      = yloc.abovebar,
                       color     = color.new(col, 75),
                       textcolor = col,
                       style     = label.style_label_down,
                       size      = size.small)
        array.push(labels_arr, lb)

// ─────────────────────────────────────────────────────────────────────────────
// DAILY BUILD — fires once per day on the first bar at or after 4:00 AM ET.
// All 10 lines are created immediately with their future timestamps so they
// appear on the chart right away, before each configured time arrives.
// ─────────────────────────────────────────────────────────────────────────────

et_date    = str.tostring(year (time, "America/New_York")) + "-" +
             str.tostring(month(time, "America/New_York")) + "-" +
             str.tostring(dayofmonth(time, "America/New_York"))

reset_ts   = et_ts(4, 0)
need_build = time >= reset_ts and et_date != last_build_date

if need_build
    // ── Delete previous day's objects ──────────────────────────────────────
    for ln in lines_arr
        line.delete(ln)
    for lb in labels_arr
        label.delete(lb)
    array.clear(lines_arr)
    array.clear(labels_arr)

    // ── Draw all enabled lines for today in one shot ────────────────────────
    // Each line is placed at its pre-computed ET timestamp for today.
    // Lines whose configured time has already passed still draw correctly
    // because xloc.bar_time accepts any valid timestamp on the chart.

    if l1_on
        draw_vline_at_time(et_ts(l1_h, l1_m),   l1_lbl_on,  l1_col,  l1_txt,  to_line_style(l1_style),  l1_width)
    if l2_on
        draw_vline_at_time(et_ts(l2_h, l2_m),   l2_lbl_on,  l2_col,  l2_txt,  to_line_style(l2_style),  l2_width)
    if l3_on
        draw_vline_at_time(et_ts(l3_h, l3_m),   l3_lbl_on,  l3_col,  l3_txt,  to_line_style(l3_style),  l3_width)
    if l4_on
        draw_vline_at_time(et_ts(l4_h, l4_m),   l4_lbl_on,  l4_col,  l4_txt,  to_line_style(l4_style),  l4_width)
    if l5_on
        draw_vline_at_time(et_ts(l5_h, l5_m),   l5_lbl_on,  l5_col,  l5_txt,  to_line_style(l5_style),  l5_width)
    if l6_on
        draw_vline_at_time(et_ts(l6_h, l6_m),   l6_lbl_on,  l6_col,  l6_txt,  to_line_style(l6_style),  l6_width)
    if l7_on
        draw_vline_at_time(et_ts(l7_h, l7_m),   l7_lbl_on,  l7_col,  l7_txt,  to_line_style(l7_style),  l7_width)
    if l8_on
        draw_vline_at_time(et_ts(l8_h, l8_m),   l8_lbl_on,  l8_col,  l8_txt,  to_line_style(l8_style),  l8_width)
    if l9_on
        draw_vline_at_time(et_ts(l9_h, l9_m),   l9_lbl_on,  l9_col,  l9_txt,  to_line_style(l9_style),  l9_width)
    if l10_on
        draw_vline_at_time(et_ts(l10_h, l10_m), l10_lbl_on, l10_col, l10_txt, to_line_style(l10_style), l10_width)

    last_build_date := et_date
````
