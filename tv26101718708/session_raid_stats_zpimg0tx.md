# Session Raid Stats

- url: https://www.tradingview.com/script/ZPImG0tx-Session-Raid-Stats/
- type: indicator
- pine_id: PUB;8914e13de88c4b968fb4b37e02228a64
- version: 1.0

## Description

This indicator combines two ideas into one tool: it plots fixed-point projection levels above and below up to three configurable session ranges, and it tracks a **raid statistics table** that measures how often price breaks beyond each of those levels and closes back inside the range — a confirmed "raid" — across hundreds of historical sessions.

The result is a probability-based view of where price tends to reach and reverse after a session closes, expressed as a percentage drawn from real historical data on your current chart and timeframe.

---

**What is a Raid?**

A raid occurs when price breaks beyond a session's high or low by at least a user-defined minimum amount, then closes back inside the range. This is distinct from a simple breakout — a raid requires the close to return, confirming the move was a liquidity sweep rather than a sustained break.

The indicator tracks raids separately for the high side (upward sweeps above the range high) and the low side (downward sweeps below the range low).

---

**Features**

- Up to **3 independent session ranges**, each with configurable time windows (in NY timezone)
- **Range boxes** drawn during the session using wick high/low
- **Projection lines** drawn at fixed-point intervals beyond the range high and low when the session closes — all three ranges share the same level configuration so the lines are directly comparable
- **Raid detection** begins the moment each session range closes and runs for a user-configurable cutoff window
- **Raid statistics table** showing cumulative confirmed raid counts and probabilities at each level, for both the high and low side, for all three ranges
- **Cutoff line** drawn on the chart when each range's detection window expires, with configurable colour, style and label size
- Title row of each table panel is colour-matched to that range's box colour for instant visual identification

---

**How the Levels Work**

All projection lines and statistics table rows are driven by a single pair of inputs: **Level Start** and **Level Step**. If you set Level Start to 20pts and Level Step to 10pts, the six levels will be placed at 20, 30, 40, 50, 60 and 70 points beyond the range high and low. The same thresholds define the bucket boundaries in the statistics table — so the "≥ 20 pts" row in the table directly corresponds to the "+20pts" line on the chart.

This means the table is answering a precise question: *"Of all historical sessions on this chart, what percentage had a confirmed high-side raid that reached at least the +20pts line?"*

---

**Statistics Table — How to Read It**

The table shows one panel per range (or just the active range if "Show All 3 Panels" is turned off). Each panel contains:

| Column | Meaning |
|---|---|
| **Level** | The point threshold beyond the range high/low |
| **^ Cnt** | Number of historical sessions with a confirmed high-side raid reaching at least this level |
| **^ Prob** | That count as a percentage of total sessions tracked |
| **v Cnt** | Same for low-side raids |
| **v Prob** | Low-side probability |

The probabilities are **cumulative** — the "≥ 20pts" row counts all sessions where the confirmed raid reached *at least* 20pts beyond the range, including any that went further. This means probabilities always decrease as you move down the table to higher levels.

A **→** arrow next to a level indicates the current session's confirmed raid has been sized into that bucket.

The **STATUS** row at the bottom shows the live state of the current session:
- **WATCHING** — range has closed, cutoff window is open, no raid confirmed yet
- **CONFIRMED** — a raid has been confirmed this session, with the extension in points shown
- **WINDOW CLOSED** — the cutoff window has expired without a confirmation

The title row of each panel shows the session time string and total number of historical sessions used for the statistics.

---

**Raid Detection Logic**

Detection begins on the first bar after the session range closes and continues until the cutoff window expires:

1. A **touch** is registered when price wicks beyond the range high or low by more than the minimum raid size (configurable per range)
2. A **confirmation** is registered when, after a touch, price closes back inside the range
3. At the moment the cutoff window expires, the session is recorded — confirmed raids are bucketed by their extension size, sessions without a confirmation are recorded as no-raid and counted toward the denominator

Raids that touch outside the range but never close back inside are not recorded as confirmed raids, but they do count toward the session total used to calculate probabilities.

---

**Settings**

**Range Extension / Raid Levels** *(shared across all ranges)*
- **Level Start (pts)** — distance in points of the first level beyond the range high/low. This becomes the first line on the chart and the first row in the table.
- **Level Step (pts)** — distance between each subsequent level. With Start=20 and Step=10, levels are at 20, 30, 40, 50, 60, 70pts.
- **Level 1–6** — enable/disable individual levels. Disabling a level removes both the chart line and the corresponding table row.

**Range 1 / 2 / 3 Settings** *(per range)*
- **Session** — the time window in NY timezone (e.g. `0200-0215` for 2:00–2:15am ET). The range high and low are built from the wicks during this window.
- **Show Range Extension Lines** — toggle the projection lines on/off for this range
- **Show Range Box** — toggle the session range box on/off
- **Box colour** — colour of the range box (also tints the table title row for this range)
- **Line colour / Line style** — appearance of the projection lines

**Range 1 / 2 / 3 — Raid Detection** *(per range)*
- **Min Raid Size (pts)** — minimum distance price must wick beyond the range before a touch is registered. Filters out minor noise near the range boundary. Set this to match a reasonable minimum for the volatility of the session you are analysing.
- **Cutoff (mins after range close)** — how many minutes after the session closes the indicator will continue watching for raids. Set to 0 to watch indefinitely until the next session start. A cutoff line is drawn on the chart when this window expires.

**Raid Statistics — Table**
- **Position** — where the table appears on the chart
- **Text Size** — size of table text
- **Show All 3 Panels** — when on, all three range panels are shown side by side. When off, only the most recently active range is shown.
- **Max Historical Sessions** — caps the number of sessions used to build the statistics. Higher values give more statistically robust numbers; lower values weight recent history more heavily.

**Cutoff Line Display**
- **Cutoff Label Size / Colour** — appearance of the "R1 cutoff" label drawn on the chart
- **Cutoff Line Colour / Style** — appearance of the vertical dashed line drawn when the cutoff window expires

---

**Usage Notes**

- The indicator works on any **intraday timeframe**. The statistics accumulate over the chart history loaded by TradingView — longer histories and lower timeframes generally produce more sessions and more reliable probabilities. For sessions shorter than 30 minutes, a 1–5 minute chart is recommended.
- The session times are evaluated in the **America/New_York timezone** regardless of your chart's timezone setting.
- Statistics reset if you change the session times or the level configuration, as the historical data will no longer match the current settings.
- For futures markets with overnight sessions (e.g. NQ, ES), set the session window to match the specific range period you want to analyse — for example the London open range, the Asia session high/low, or the NY open range.
- The **minimum raid size** should be calibrated to the instrument's typical noise level near range boundaries. Too low a value will register false touches on every minor wick; too high will miss genuine raids. A starting point is roughly half the average range size.

---

**Disclaimer**

This indicator is a statistical tool based on historical price data. Past probabilities do not guarantee future outcomes. It is intended as a research aid and does not constitute financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © notprofessorgreen

//@version=6
indicator("Session Raid Stats", shorttitle = "SRS", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// -------------------------------------------------- Inputs --------------------------------------------------
var g_GLOBAL = "Global Settings"
label_size_input   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_GLOBAL)
label_text_color   = input.color(color.black, "Label Text Color", group = g_GLOBAL)

// Raid bucket inputs — these drive BOTH the RE lines on the chart AND the stat table buckets
var g_BUCKETS = "Range Extension / Raid Levels"
i_bucket_start = input.float(20.0, "Level Start (pts)", minval = 0.25, step = 0.25, group = g_BUCKETS,
     tooltip = "The first level in points beyond the range high/low. Used for both chart lines and raid stat buckets.")
i_bucket_step  = input.float(10.0, "Level Step (pts)",  minval = 0.25, step = 0.25, group = g_BUCKETS,
     tooltip = "Distance between each subsequent level.")
use_level_1    = input.bool(true, "Level 1", inline = "L1", group = g_BUCKETS)
use_level_2    = input.bool(true, "Level 2", inline = "L2", group = g_BUCKETS)
use_level_3    = input.bool(true, "Level 3", inline = "L3", group = g_BUCKETS)
use_level_4    = input.bool(true, "Level 4", inline = "L4", group = g_BUCKETS)
use_level_5    = input.bool(true, "Level 5", inline = "L5", group = g_BUCKETS)
use_level_6    = input.bool(true, "Level 6", inline = "L6", group = g_BUCKETS)

// Range 1 Settings
var g_RANGE_1 = "Range 1 Settings"
session        = input.session("0200-0215", "Session 1", group = g_RANGE_1)
horiz_lines    = input.bool(true, "Show Range Extension Lines", group = g_RANGE_1)
show_box_1     = input.bool(true, "Show Range Box", group = g_RANGE_1)
range_box_color_1 = input.color(color.new(color.yellow, 70), "Box colour", group = g_RANGE_1)
line_color_1      = input.color(color.black, "Line colour", group = g_RANGE_1)
line_style_1      = input.string("Dotted", "Line style", options = ["Solid", "Dotted", "Dashed"], group = g_RANGE_1)

// Range 1 Raid Settings
var g_RAID_1 = "Range 1 — Raid Detection"
i_min_raid_1   = input.float(5.0, "Min Raid Size (pts)", minval = 0.1, step = 0.25, group = g_RAID_1)
i_cut_1        = input.int(120, "Cutoff (mins after range close)", minval = 0, group = g_RAID_1, tooltip = "0 = no cutoff")

// Range 2 Settings
var g_RANGE_2 = "Range 2 Settings"
session_2      = input.session("0900-0915", "Session 2", group = g_RANGE_2)
horiz_lines_2  = input.bool(true, "Show Range Extension Lines", group = g_RANGE_2)
show_box_2     = input.bool(true, "Show Range Box", group = g_RANGE_2)
range_box_color_2 = input.color(color.new(color.fuchsia, 70), "Box colour", group = g_RANGE_2)
line_color_2      = input.color(color.black, "Line colour", group = g_RANGE_2)
line_style_2      = input.string("Dotted", "Line style", options = ["Solid", "Dotted", "Dashed"], group = g_RANGE_2)

var g_RAID_2 = "Range 2 — Raid Detection"
i_min_raid_2   = input.float(5.0, "Min Raid Size (pts)", minval = 0.1, step = 0.25, group = g_RAID_2)
i_cut_2        = input.int(120, "Cutoff (mins after range close)", minval = 0, group = g_RAID_2)

// Range 3 Settings
var g_RANGE_3 = "Range 3 Settings"
session_3      = input.session("1300-1315", "Session 3", group = g_RANGE_3)
horiz_lines_3  = input.bool(true, "Show Range Extension Lines", group = g_RANGE_3)
show_box_3     = input.bool(true, "Show Range Box", group = g_RANGE_3)
range_box_color_3 = input.color(color.new(color.teal, 70), "Box colour", group = g_RANGE_3)
line_color_3      = input.color(color.black, "Line colour", group = g_RANGE_3)
line_style_3      = input.string("Dotted", "Line style", options = ["Solid", "Dotted", "Dashed"], group = g_RANGE_3)

var g_RAID_3 = "Range 3 — Raid Detection"
i_min_raid_3   = input.float(5.0, "Min Raid Size (pts)", minval = 0.1, step = 0.25, group = g_RAID_3)
i_cut_3        = input.int(120, "Cutoff (mins after range close)", minval = 0, group = g_RAID_3)

// Raid table display
var g_RTABLE = "Raid Statistics — Table"
i_table_pos    = input.string("Top right", "Position", options = ["Top right", "Top left", "Top center", "Bottom right", "Bottom left"], group = g_RTABLE)
i_text_size    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_RTABLE)
i_show_all     = input.bool(true, "Show All 3 Panels", group = g_RTABLE)
i_max_days     = input.int(500, "Max Historical Sessions", minval = 10, group = g_RTABLE)

// Cutoff line display
var g_CUTOFF = "Cutoff Line Display"
i_cutoff_label_size  = input.string("Tiny", "Cutoff Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_CUTOFF)
i_cutoff_label_color = input.color(color.new(#aaaaaa, 0), "Cutoff Label Colour", group = g_CUTOFF)
i_cutoff_line_color  = input.color(color.new(#aaaaaa, 30), "Cutoff Line Colour", group = g_CUTOFF)
i_cutoff_line_style  = input.string("Dashed", "Cutoff Line Style", options = ["Solid", "Dotted", "Dashed"], group = g_CUTOFF)

// -------------------------------------------------- Functions --------------------------------------------------
get_line_style(i) =>
    switch i
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

get_label_size(i) =>
    switch i
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large

f_tablePos(string s) =>
    switch s
        "Top right"    => position.top_right
        "Top left"     => position.top_left
        "Top center"   => position.top_center
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        => position.top_right

f_textSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

line_style_1 := get_line_style(line_style_1)
line_style_2 := get_line_style(line_style_2)
line_style_3 := get_line_style(line_style_3)

// -------------------------------------------------- Constants & Variables --------------------------------------------------
t  = not na(time("", session,   "America/New_York"))
t2 = not na(time("", session_2, "America/New_York"))
t3 = not na(time("", session_3, "America/New_York"))
label_size = get_label_size(label_size_input)

MAX_BUCKETS = 6   // matches 6 configurable levels
MS_PER_MIN  = 60000

// Level offsets in points — shared across all ranges and the stat table
// level_pts(n) = i_bucket_start + (n-1) * i_bucket_step  for n = 1..6
level_pts_1 = i_bucket_start
level_pts_2 = i_bucket_start + i_bucket_step
level_pts_3 = i_bucket_start + i_bucket_step * 2
level_pts_4 = i_bucket_start + i_bucket_step * 3
level_pts_5 = i_bucket_start + i_bucket_step * 4
level_pts_6 = i_bucket_start + i_bucket_step * 5

// Raid bucket helpers — buckets are exactly the 6 levels above
// bucket i (0-based) covers [level_pts_i, level_pts_(i+1))
// overflow bucket 6 covers anything beyond level_pts_6
int BC = MAX_BUCKETS + 1  // 7 buckets: levels 1-6 plus overflow

f_bucketIndex(float value) =>
    int idx = MAX_BUCKETS  // overflow
    if value < level_pts_2
        idx := 0
    else if value < level_pts_3
        idx := 1
    else if value < level_pts_4
        idx := 2
    else if value < level_pts_5
        idx := 3
    else if value < level_pts_6
        idx := 4
    else if value < level_pts_6 + i_bucket_step
        idx := 5
    idx

f_cumulative(int[] counts) =>
    int[] cum = array.new_int(array.size(counts), 0)
    int running = 0
    for i = array.size(counts) - 1 to 0
        running += array.get(counts, i)
        array.set(cum, i, running)
    cum

f_withinCutoff(int range_end_ms, int cutoff_mins) =>
    if cutoff_mins == 0
        true
    else
        (time - range_end_ms) <= cutoff_mins * MS_PER_MIN

f_updateProbCache(int[] hi_counts, int[] lo_counts, int day_count, float[] cache_hi, float[] cache_lo) =>
    if day_count > 0
        int[] cum_h = f_cumulative(hi_counts)
        int[] cum_l = f_cumulative(lo_counts)
        for i = 0 to array.size(cache_hi) - 1
            array.set(cache_hi, i, array.get(cum_h, i) / float(day_count) * 100)
            array.set(cache_lo, i, array.get(cum_l, i) / float(day_count) * 100)

f_drawCutoff(int bi, string lbl) =>
    line.new(bi, low - 999999, bi, high + 999999,
         xloc = xloc.bar_index,
         color = i_cutoff_line_color,
         style = get_line_style(i_cutoff_line_style),
         width = 1,
         extend = extend.both)
    label.new(bi, high + (high - low) * 2, lbl + "\ncutoff",
         style = label.style_none,
         textcolor = i_cutoff_label_color,
         size = get_label_size(i_cutoff_label_size),
         text_font_family = font.family_monospace)

// Range 1 box/line variables
var box   range_box    = na
var box   body_box     = na
var int   start        = 0
var int   end_bar      = 0
var float session_open = na
var line line_p1 = na
var line line_p2 = na
var line line_p3 = na
var line line_p4 = na
var line line_p5 = na
var line line_p6 = na
var line line_m1 = na
var line line_m2 = na
var line line_m3 = na
var line line_m4 = na
var line line_m5 = na
var line line_m6 = na

// Range 2 box/line variables
var box   range_box_2    = na
var box   body_box_2     = na
var int   start_2        = 0
var int   end_bar_2      = 0
var float session_open_2 = na
var line line_p1_2 = na
var line line_p2_2 = na
var line line_p3_2 = na
var line line_p4_2 = na
var line line_p5_2 = na
var line line_p6_2 = na
var line line_m1_2 = na
var line line_m2_2 = na
var line line_m3_2 = na
var line line_m4_2 = na
var line line_m5_2 = na
var line line_m6_2 = na

// Range 3 box/line variables
var box   range_box_3    = na
var box   body_box_3     = na
var int   start_3        = 0
var int   end_bar_3      = 0
var float session_open_3 = na
var line line_p1_3 = na
var line line_p2_3 = na
var line line_p3_3 = na
var line line_p4_3 = na
var line line_p5_3 = na
var line line_p6_3 = na
var line line_m1_3 = na
var line line_m2_3 = na
var line line_m3_3 = na
var line line_m4_3 = na
var line line_m5_3 = na
var line line_m6_3 = na

// Raid state — Range 1
var float r1_hi        = na
var float r1_lo        = na
var int   r1_end_ms    = na
var bool  r1_active    = false
var float r1_hi_max    = na
var bool  r1_hi_touch  = false
var bool  r1_hi_conf   = false
var float r1_hi_pts    = na
var float r1_lo_min    = na
var bool  r1_lo_touch  = false
var bool  r1_lo_conf   = false
var float r1_lo_pts    = na
var bool  r1_cut_exp   = false
var bool  r1_cut_drawn = false
var int   cnt_r1       = 0
var int[] h_r1_hi      = array.new_int(BC, 0)
var int[] h_r1_lo      = array.new_int(BC, 0)
var float[] prob_r1_hi = array.new_float(BC, 0.0)
var float[] prob_r1_lo = array.new_float(BC, 0.0)

// Raid state — Range 2
var float r2_hi        = na
var float r2_lo        = na
var int   r2_end_ms    = na
var bool  r2_active    = false
var float r2_hi_max    = na
var bool  r2_hi_touch  = false
var bool  r2_hi_conf   = false
var float r2_hi_pts    = na
var float r2_lo_min    = na
var bool  r2_lo_touch  = false
var bool  r2_lo_conf   = false
var float r2_lo_pts    = na
var bool  r2_cut_exp   = false
var bool  r2_cut_drawn = false
var int   cnt_r2       = 0
var int[] h_r2_hi      = array.new_int(BC, 0)
var int[] h_r2_lo      = array.new_int(BC, 0)
var float[] prob_r2_hi = array.new_float(BC, 0.0)
var float[] prob_r2_lo = array.new_float(BC, 0.0)

// Raid state — Range 3
var float r3_hi        = na
var float r3_lo        = na
var int   r3_end_ms    = na
var bool  r3_active    = false
var float r3_hi_max    = na
var bool  r3_hi_touch  = false
var bool  r3_hi_conf   = false
var float r3_hi_pts    = na
var float r3_lo_min    = na
var bool  r3_lo_touch  = false
var bool  r3_lo_conf   = false
var float r3_lo_pts    = na
var bool  r3_cut_exp   = false
var bool  r3_cut_drawn = false
var int   cnt_r3       = 0
var int[] h_r3_hi      = array.new_int(BC, 0)
var int[] h_r3_lo      = array.new_int(BC, 0)
var float[] prob_r3_hi = array.new_float(BC, 0.0)
var float[] prob_r3_lo = array.new_float(BC, 0.0)

// -------------------------------------------------- Core Logic — Range 1 --------------------------------------------------
if t and not t[1]
    if show_box_1
        range_box := box.new(bar_index, high, bar_index, low, border_color = range_box_color_1, bgcolor = range_box_color_1)
    start        := bar_index
    session_open := open
    r1_hi        := na
    r1_lo        := na
    r1_end_ms    := na
    r1_active    := false
    r1_hi_max    := na
    r1_hi_touch  := false
    r1_hi_conf   := false
    r1_hi_pts    := na
    r1_lo_min    := na
    r1_lo_touch  := false
    r1_lo_conf   := false
    r1_lo_pts    := na
    r1_cut_exp   := false
    r1_cut_drawn := false
else if t
    if show_box_1
        range_box.set_right(bar_index)
        if high > range_box.get_top()
            range_box.set_top(high)
        if low < range_box.get_bottom()
            range_box.set_bottom(low)
else if not t and t[1]
    top     = range_box.get_top()
    bot     = range_box.get_bottom()
    end_bar := bar_index
    if show_box_1
        range_box := na
    line_p1 := na
    if horiz_lines
        if use_level_1
            line_p1 := line.new(start, top + level_pts_1, end_bar, top + level_pts_1, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_1, "+" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m1 := line.new(start, bot - level_pts_1, end_bar, bot - level_pts_1, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_1, "-" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_2
            line_p2 := line.new(start, top + level_pts_2, end_bar, top + level_pts_2, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_2, "+" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m2 := line.new(start, bot - level_pts_2, end_bar, bot - level_pts_2, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_2, "-" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_3
            line_p3 := line.new(start, top + level_pts_3, end_bar, top + level_pts_3, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_3, "+" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m3 := line.new(start, bot - level_pts_3, end_bar, bot - level_pts_3, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_3, "-" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_4
            line_p4 := line.new(start, top + level_pts_4, end_bar, top + level_pts_4, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_4, "+" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m4 := line.new(start, bot - level_pts_4, end_bar, bot - level_pts_4, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_4, "-" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_5
            line_p5 := line.new(start, top + level_pts_5, end_bar, top + level_pts_5, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_5, "+" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m5 := line.new(start, bot - level_pts_5, end_bar, bot - level_pts_5, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_5, "-" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_6
            line_p6 := line.new(start, top + level_pts_6, end_bar, top + level_pts_6, color = line_color_1, style = line_style_1)
            label.new(start - 1, top + level_pts_6, "+" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m6 := line.new(start, bot - level_pts_6, end_bar, bot - level_pts_6, color = line_color_1, style = line_style_1)
            label.new(start - 1, bot - level_pts_6, "-" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_1, style = label.style_none, textcolor = label_text_color, size = label_size)
    r1_hi     := top
    r1_lo     := bot
    r1_end_ms := time
    r1_active := true

if r1_active and not na(r1_end_ms)
    bool r1_within = f_withinCutoff(r1_end_ms, i_cut_1)
    if not r1_within and not r1_cut_exp
        r1_cut_exp := true
        if cnt_r1 < i_max_days
            if r1_hi_conf and not na(r1_hi_pts)
                int bidx = f_bucketIndex(r1_hi_pts)
                array.set(h_r1_hi, bidx, array.get(h_r1_hi, bidx) + 1)
            if r1_lo_conf and not na(r1_lo_pts)
                int bidx = f_bucketIndex(r1_lo_pts)
                array.set(h_r1_lo, bidx, array.get(h_r1_lo, bidx) + 1)
            cnt_r1 += 1
            f_updateProbCache(h_r1_hi, h_r1_lo, cnt_r1, prob_r1_hi, prob_r1_lo)
        r1_active := false
        if i_cut_1 > 0 and not r1_cut_drawn
            f_drawCutoff(bar_index, "R1")
            r1_cut_drawn := true
    if r1_within and high > r1_hi + i_min_raid_1
        r1_hi_touch := true
        r1_hi_max   := na(r1_hi_max) ? high : math.max(r1_hi_max, high)
    if r1_hi_touch and not r1_hi_conf and close <= r1_hi
        r1_hi_conf := true
        r1_hi_pts  := r1_hi_max - r1_hi
    if r1_within and low < r1_lo - i_min_raid_1
        r1_lo_touch := true
        r1_lo_min   := na(r1_lo_min) ? low : math.min(r1_lo_min, low)
    if r1_lo_touch and not r1_lo_conf and close >= r1_lo
        r1_lo_conf := true
        r1_lo_pts  := r1_lo - r1_lo_min

// -------------------------------------------------- Core Logic — Range 2 --------------------------------------------------
if t2 and not t2[1]
    if show_box_2
        range_box_2 := box.new(bar_index, high, bar_index, low, border_color = range_box_color_2, bgcolor = range_box_color_2)
    start_2        := bar_index
    session_open_2 := open
    r2_hi        := na
    r2_lo        := na
    r2_end_ms    := na
    r2_active    := false
    r2_hi_max    := na
    r2_hi_touch  := false
    r2_hi_conf   := false
    r2_hi_pts    := na
    r2_lo_min    := na
    r2_lo_touch  := false
    r2_lo_conf   := false
    r2_lo_pts    := na
    r2_cut_exp   := false
    r2_cut_drawn := false
else if t2
    if show_box_2
        range_box_2.set_right(bar_index)
        if high > range_box_2.get_top()
            range_box_2.set_top(high)
        if low < range_box_2.get_bottom()
            range_box_2.set_bottom(low)
else if not t2 and t2[1]
    top_2      = range_box_2.get_top()
    bot_2      = range_box_2.get_bottom()
    end_bar_2 := bar_index
    if show_box_2
        range_box_2 := na
    line_p1_2 := na
    if horiz_lines_2
        if use_level_1
            line_p1_2 := line.new(start_2, top_2 + level_pts_1, end_bar_2, top_2 + level_pts_1, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_1, "+" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m1_2 := line.new(start_2, bot_2 - level_pts_1, end_bar_2, bot_2 - level_pts_1, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_1, "-" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_2
            line_p2_2 := line.new(start_2, top_2 + level_pts_2, end_bar_2, top_2 + level_pts_2, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_2, "+" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m2_2 := line.new(start_2, bot_2 - level_pts_2, end_bar_2, bot_2 - level_pts_2, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_2, "-" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_3
            line_p3_2 := line.new(start_2, top_2 + level_pts_3, end_bar_2, top_2 + level_pts_3, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_3, "+" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m3_2 := line.new(start_2, bot_2 - level_pts_3, end_bar_2, bot_2 - level_pts_3, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_3, "-" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_4
            line_p4_2 := line.new(start_2, top_2 + level_pts_4, end_bar_2, top_2 + level_pts_4, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_4, "+" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m4_2 := line.new(start_2, bot_2 - level_pts_4, end_bar_2, bot_2 - level_pts_4, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_4, "-" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_5
            line_p5_2 := line.new(start_2, top_2 + level_pts_5, end_bar_2, top_2 + level_pts_5, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_5, "+" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m5_2 := line.new(start_2, bot_2 - level_pts_5, end_bar_2, bot_2 - level_pts_5, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_5, "-" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_6
            line_p6_2 := line.new(start_2, top_2 + level_pts_6, end_bar_2, top_2 + level_pts_6, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, top_2 + level_pts_6, "+" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m6_2 := line.new(start_2, bot_2 - level_pts_6, end_bar_2, bot_2 - level_pts_6, color = line_color_2, style = line_style_2)
            label.new(start_2 - 1, bot_2 - level_pts_6, "-" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_2, style = label.style_none, textcolor = label_text_color, size = label_size)
    r2_hi     := top_2
    r2_lo     := bot_2
    r2_end_ms := time
    r2_active := true

if r2_active and not na(r2_end_ms)
    bool r2_within = f_withinCutoff(r2_end_ms, i_cut_2)
    if not r2_within and not r2_cut_exp
        r2_cut_exp := true
        if cnt_r2 < i_max_days
            if r2_hi_conf and not na(r2_hi_pts)
                int bidx = f_bucketIndex(r2_hi_pts)
                array.set(h_r2_hi, bidx, array.get(h_r2_hi, bidx) + 1)
            if r2_lo_conf and not na(r2_lo_pts)
                int bidx = f_bucketIndex(r2_lo_pts)
                array.set(h_r2_lo, bidx, array.get(h_r2_lo, bidx) + 1)
            cnt_r2 += 1
            f_updateProbCache(h_r2_hi, h_r2_lo, cnt_r2, prob_r2_hi, prob_r2_lo)
        r2_active := false
        if i_cut_2 > 0 and not r2_cut_drawn
            f_drawCutoff(bar_index, "R2")
            r2_cut_drawn := true
    if r2_within and high > r2_hi + i_min_raid_2
        r2_hi_touch := true
        r2_hi_max   := na(r2_hi_max) ? high : math.max(r2_hi_max, high)
    if r2_hi_touch and not r2_hi_conf and close <= r2_hi
        r2_hi_conf := true
        r2_hi_pts  := r2_hi_max - r2_hi
    if r2_within and low < r2_lo - i_min_raid_2
        r2_lo_touch := true
        r2_lo_min   := na(r2_lo_min) ? low : math.min(r2_lo_min, low)
    if r2_lo_touch and not r2_lo_conf and close >= r2_lo
        r2_lo_conf := true
        r2_lo_pts  := r2_lo - r2_lo_min

// -------------------------------------------------- Core Logic — Range 3 --------------------------------------------------
if t3 and not t3[1]
    if show_box_3
        range_box_3 := box.new(bar_index, high, bar_index, low, border_color = range_box_color_3, bgcolor = range_box_color_3)
    start_3        := bar_index
    session_open_3 := open
    r3_hi        := na
    r3_lo        := na
    r3_end_ms    := na
    r3_active    := false
    r3_hi_max    := na
    r3_hi_touch  := false
    r3_hi_conf   := false
    r3_hi_pts    := na
    r3_lo_min    := na
    r3_lo_touch  := false
    r3_lo_conf   := false
    r3_lo_pts    := na
    r3_cut_exp   := false
    r3_cut_drawn := false
else if t3
    if show_box_3
        range_box_3.set_right(bar_index)
        if high > range_box_3.get_top()
            range_box_3.set_top(high)
        if low < range_box_3.get_bottom()
            range_box_3.set_bottom(low)
else if not t3 and t3[1]
    top_3      = range_box_3.get_top()
    bot_3      = range_box_3.get_bottom()
    end_bar_3 := bar_index
    if show_box_3
        range_box_3 := na
    line_p1_3 := na
    if horiz_lines_3
        if use_level_1
            line_p1_3 := line.new(start_3, top_3 + level_pts_1, end_bar_3, top_3 + level_pts_1, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_1, "+" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m1_3 := line.new(start_3, bot_3 - level_pts_1, end_bar_3, bot_3 - level_pts_1, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_1, "-" + str.tostring(level_pts_1, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_2
            line_p2_3 := line.new(start_3, top_3 + level_pts_2, end_bar_3, top_3 + level_pts_2, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_2, "+" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m2_3 := line.new(start_3, bot_3 - level_pts_2, end_bar_3, bot_3 - level_pts_2, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_2, "-" + str.tostring(level_pts_2, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_3
            line_p3_3 := line.new(start_3, top_3 + level_pts_3, end_bar_3, top_3 + level_pts_3, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_3, "+" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m3_3 := line.new(start_3, bot_3 - level_pts_3, end_bar_3, bot_3 - level_pts_3, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_3, "-" + str.tostring(level_pts_3, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_4
            line_p4_3 := line.new(start_3, top_3 + level_pts_4, end_bar_3, top_3 + level_pts_4, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_4, "+" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m4_3 := line.new(start_3, bot_3 - level_pts_4, end_bar_3, bot_3 - level_pts_4, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_4, "-" + str.tostring(level_pts_4, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_5
            line_p5_3 := line.new(start_3, top_3 + level_pts_5, end_bar_3, top_3 + level_pts_5, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_5, "+" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m5_3 := line.new(start_3, bot_3 - level_pts_5, end_bar_3, bot_3 - level_pts_5, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_5, "-" + str.tostring(level_pts_5, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
        if use_level_6
            line_p6_3 := line.new(start_3, top_3 + level_pts_6, end_bar_3, top_3 + level_pts_6, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, top_3 + level_pts_6, "+" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
            line_m6_3 := line.new(start_3, bot_3 - level_pts_6, end_bar_3, bot_3 - level_pts_6, color = line_color_3, style = line_style_3)
            label.new(start_3 - 1, bot_3 - level_pts_6, "-" + str.tostring(level_pts_6, "#.#") + "pts", color = line_color_3, style = label.style_none, textcolor = label_text_color, size = label_size)
    r3_hi     := top_3
    r3_lo     := bot_3
    r3_end_ms := time
    r3_active := true

if r3_active and not na(r3_end_ms)
    bool r3_within = f_withinCutoff(r3_end_ms, i_cut_3)
    if not r3_within and not r3_cut_exp
        r3_cut_exp := true
        if cnt_r3 < i_max_days
            if r3_hi_conf and not na(r3_hi_pts)
                int bidx = f_bucketIndex(r3_hi_pts)
                array.set(h_r3_hi, bidx, array.get(h_r3_hi, bidx) + 1)
            if r3_lo_conf and not na(r3_lo_pts)
                int bidx = f_bucketIndex(r3_lo_pts)
                array.set(h_r3_lo, bidx, array.get(h_r3_lo, bidx) + 1)
            cnt_r3 += 1
            f_updateProbCache(h_r3_hi, h_r3_lo, cnt_r3, prob_r3_hi, prob_r3_lo)
        r3_active := false
        if i_cut_3 > 0 and not r3_cut_drawn
            f_drawCutoff(bar_index, "R3")
            r3_cut_drawn := true
    if r3_within and high > r3_hi + i_min_raid_3
        r3_hi_touch := true
        r3_hi_max   := na(r3_hi_max) ? high : math.max(r3_hi_max, high)
    if r3_hi_touch and not r3_hi_conf and close <= r3_hi
        r3_hi_conf := true
        r3_hi_pts  := r3_hi_max - r3_hi
    if r3_within and low < r3_lo - i_min_raid_3
        r3_lo_touch := true
        r3_lo_min   := na(r3_lo_min) ? low : math.min(r3_lo_min, low)
    if r3_lo_touch and not r3_lo_conf and close >= r3_lo
        r3_lo_conf := true
        r3_lo_pts  := r3_lo - r3_lo_min

// -------------------------------------------------- Raid Dashboard --------------------------------------------------
f_drawPanel(table tbl, int col, string title, string sess_time, color box_col, int day_count, int[] hi_counts, int[] lo_counts,
     bool hi_conf, float hi_pts, bool lo_conf, float lo_pts, bool cut_exp, float min_pts, int cut_mins) =>
    int[] cum_h    = f_cumulative(hi_counts)
    int[] cum_l    = f_cumulative(lo_counts)
    color C_TITLE  = color.new(box_col, 20)
    color C_HEADER = color.new(#024040, 30)
    color C_EVEN   = color.new(color.black, 93)
    color C_ODD    = color.new(color.black, 87)
    color C_FOOT   = color.new(#024040, 55)
    color C_SUB    = color.new(#024040, 20)
    string SZ      = f_textSize(i_text_size)
    string MONO    = font.family_monospace
    // Row 0: title
    table.cell(tbl, col, 0, title + "  " + sess_time + "  |  " + str.tostring(day_count) + " sessions", bgcolor = C_TITLE, text_color = color.white, text_size = SZ, text_font_family = MONO, text_halign = text.align_center)
    table.merge_cells(tbl, col, 0, col + 4, 0)
    // Row 1: subtitle
    string cut_str = cut_mins > 0 ? " | cutoff " + str.tostring(cut_mins) + "m" : " | no cutoff"
    table.cell(tbl, col, 1, "min " + str.tostring(min_pts, "#.#") + " pts" + cut_str, bgcolor = C_SUB, text_color = color.white, text_size = SZ, text_font_family = MONO, text_halign = text.align_center)
    table.merge_cells(tbl, col, 1, col + 4, 1)
    // Row 2: headers
    table.cell(tbl, col,     2, "Level",  bgcolor = C_HEADER, text_color = color.white,           text_size = SZ, text_font_family = MONO, text_halign = text.align_left)
    table.cell(tbl, col + 1, 2, "^ Cnt",  bgcolor = C_HEADER, text_color = color.new(#b9d989, 0), text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
    table.cell(tbl, col + 2, 2, "^ Prob", bgcolor = C_HEADER, text_color = color.new(#b9d989, 0), text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
    table.cell(tbl, col + 3, 2, "v Cnt",  bgcolor = C_HEADER, text_color = color.new(#66ccbb, 0), text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
    table.cell(tbl, col + 4, 2, "v Prob", bgcolor = C_HEADER, text_color = color.new(#66ccbb, 0), text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
    // Live bucket arrow
    int live_h = (hi_conf and not na(hi_pts)) ? f_bucketIndex(hi_pts) : -1
    int live_l = (lo_conf and not na(lo_pts))  ? f_bucketIndex(lo_pts) : -1
    // Data rows — one per level plus overflow
    float[] lvl_pts = array.new_float(7, 0.0)
    array.set(lvl_pts, 0, level_pts_1)
    array.set(lvl_pts, 1, level_pts_2)
    array.set(lvl_pts, 2, level_pts_3)
    array.set(lvl_pts, 3, level_pts_4)
    array.set(lvl_pts, 4, level_pts_5)
    array.set(lvl_pts, 5, level_pts_6)
    array.set(lvl_pts, 6, level_pts_6 + i_bucket_step)
    bool[] lvl_enabled = array.new_bool(7, true)
    array.set(lvl_enabled, 0, use_level_1)
    array.set(lvl_enabled, 1, use_level_2)
    array.set(lvl_enabled, 2, use_level_3)
    array.set(lvl_enabled, 3, use_level_4)
    array.set(lvl_enabled, 4, use_level_5)
    array.set(lvl_enabled, 5, use_level_6)
    array.set(lvl_enabled, 6, true)  // overflow always shown
    int row = 3
    for i = 0 to BC - 1
        color row_bg  = row % 2 == 0 ? C_EVEN : C_ODD
        float lv      = array.get(lvl_pts, i)
        string lbl    = i < MAX_BUCKETS ? ">= " + str.tostring(lv, "#.#") + " pts" : "> " + str.tostring(array.get(lvl_pts, MAX_BUCKETS - 1), "#.#") + " pts"
        int h_cnt     = day_count > 0 ? array.get(cum_h, i) : 0
        int l_cnt     = day_count > 0 ? array.get(cum_l, i) : 0
        float h_pct   = day_count > 0 ? h_cnt / float(day_count) * 100 : 0.0
        float l_pct   = day_count > 0 ? l_cnt / float(day_count) * 100 : 0.0
        string row_lbl = (i == live_h or i == live_l) ? "-> " + lbl : "   " + lbl
        table.cell(tbl, col,     row, row_lbl,                          bgcolor = row_bg, text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_left)
        table.cell(tbl, col + 1, row, str.tostring(h_cnt),              bgcolor = row_bg, text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
        table.cell(tbl, col + 2, row, str.tostring(h_pct, "#.#") + "%", bgcolor = row_bg, text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
        table.cell(tbl, col + 3, row, str.tostring(l_cnt),              bgcolor = row_bg, text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
        table.cell(tbl, col + 4, row, str.tostring(l_pct, "#.#") + "%", bgcolor = row_bg, text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_right)
        row += 1
    // Footer status
    string h_stat    = hi_conf ? "CONFIRMED" : (cut_exp ? "WINDOW CLOSED" : "WATCHING")
    string l_stat    = lo_conf ? "CONFIRMED" : (cut_exp ? "WINDOW CLOSED" : "WATCHING")
    color h_col      = hi_conf ? color.new(#b9d989, 40) : (cut_exp ? color.new(#666666, 60) : color.new(#024040, 70))
    color l_col      = lo_conf ? color.new(#b9d989, 40) : (cut_exp ? color.new(#666666, 60) : color.new(#024040, 70))
    string h_pts_str = hi_conf and not na(hi_pts) ? "  " + str.tostring(hi_pts, "#.#") + " pts" : ""
    string l_pts_str = lo_conf and not na(lo_pts) ? "  " + str.tostring(lo_pts, "#.#") + " pts" : ""
    table.cell(tbl, col,     row, "STATUS",            bgcolor = C_FOOT, text_color = color.white, text_size = SZ, text_font_family = MONO, text_halign = text.align_center)
    table.cell(tbl, col + 1, row, h_stat + h_pts_str,  bgcolor = h_col,  text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_center)
    table.merge_cells(tbl, col + 1, row, col + 2, row)
    table.cell(tbl, col + 3, row, l_stat + l_pts_str,  bgcolor = l_col,  text_color = color.black, text_size = SZ, text_font_family = MONO, text_halign = text.align_center)
    table.merge_cells(tbl, col + 3, row, col + 4, row)

var table raid_table = na

if barstate.islast
    if not na(raid_table)
        table.delete(raid_table)
    int n_rows     = BC + 4  // subtitle + headers + BC data rows + footer
    int n_panels   = i_show_all ? 3 : 1
    raid_table := table.new(f_tablePos(i_table_pos), n_panels * 5, n_rows, border_width = 1, border_color = color.new(#024040, 50), frame_width = 2, frame_color = color.new(#024040, 10))
    if i_show_all
        f_drawPanel(raid_table, 0,  "RANGE 1", session,   range_box_color_1, cnt_r1, h_r1_hi, h_r1_lo, r1_hi_conf, r1_hi_pts, r1_lo_conf, r1_lo_pts, r1_cut_exp, i_min_raid_1, i_cut_1)
        f_drawPanel(raid_table, 5,  "RANGE 2", session_2, range_box_color_2, cnt_r2, h_r2_hi, h_r2_lo, r2_hi_conf, r2_hi_pts, r2_lo_conf, r2_lo_pts, r2_cut_exp, i_min_raid_2, i_cut_2)
        f_drawPanel(raid_table, 10, "RANGE 3", session_3, range_box_color_3, cnt_r3, h_r3_hi, h_r3_lo, r3_hi_conf, r3_hi_pts, r3_lo_conf, r3_lo_pts, r3_cut_exp, i_min_raid_3, i_cut_3)
    else
        if r1_active or r1_cut_exp
            f_drawPanel(raid_table, 0, "RANGE 1", session,   range_box_color_1, cnt_r1, h_r1_hi, h_r1_lo, r1_hi_conf, r1_hi_pts, r1_lo_conf, r1_lo_pts, r1_cut_exp, i_min_raid_1, i_cut_1)
        else if r2_active or r2_cut_exp
            f_drawPanel(raid_table, 0, "RANGE 2", session_2, range_box_color_2, cnt_r2, h_r2_hi, h_r2_lo, r2_hi_conf, r2_hi_pts, r2_lo_conf, r2_lo_pts, r2_cut_exp, i_min_raid_2, i_cut_2)
        else
            f_drawPanel(raid_table, 0, "RANGE 3", session_3, range_box_color_3, cnt_r3, h_r3_hi, h_r3_lo, r3_hi_conf, r3_hi_pts, r3_lo_conf, r3_lo_pts, r3_cut_exp, i_min_raid_3, i_cut_3)
````
