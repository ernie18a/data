# Day Session Boxes

- url: https://www.tradingview.com/script/FZxyYybl-Day-Session-Boxes/
- type: indicator
- pine_id: PUB;dd474378e8444798ad16d242941843c3
- version: 1.0

## Description

The daily boxes seperate the the days to give you a more clear overview on the highs, the lows and what the markets does during the weeks.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © DaySessionBoxes

//@version=5
indicator("Day Session Boxes", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=100)

// ══════════════════════════════════════════════════════════════════════════════
//  SETTINGS
// ══════════════════════════════════════════════════════════════════════════════

var string G_TIME  = "⏰  Time Settings"
var string G_STYLE = "✏️  Style"
var string G_COLOR = "🎨  Day Colors"
var string G_WEEK  = "📅  Weekly Line"

// ── Time ─────────────────────────────────────────────────────────────────────
utc_offset = input.int(1, "UTC Offset (hours)", minval=-12, maxval=14, group=G_TIME,
     tooltip="Amsterdam (CET, winter) = 1  |  Amsterdam (CEST, summer) = 2\nLondon (GMT) = 0  |  New York (EST) = -5  |  Tokyo (JST) = 9")

// ── Style ────────────────────────────────────────────────────────────────────
days_shown = input.int   (20,         "Days to Show",           minval=1, maxval=100, group=G_STYLE)
fill_t     = input.int   (82,         "Fill Transparency %",    minval=0, maxval=99,  group=G_STYLE)
bord_t     = input.int   (50,         "Border Transparency %",  minval=0, maxval=99,  group=G_STYLE)
bord_w     = input.int   (1,          "Border Width (px)",      minval=1, maxval=5,   group=G_STYLE)
show_lbl   = input.bool  (true,       "Show Day Labels",                              group=G_STYLE)
lbl_sz     = input.string(size.small, "Label Size",
     options=[size.tiny, size.small, size.normal, size.large],                        group=G_STYLE)

// ── Day Colors (Mon–Fri only) ─────────────────────────────────────────────────
mon_col = input.color(#6BA3FF, "Monday",    group=G_COLOR)
tue_col = input.color(#5CC98A, "Tuesday",   group=G_COLOR)
wed_col = input.color(#F5C842, "Wednesday", group=G_COLOR)
thu_col = input.color(#F07B72, "Thursday",  group=G_COLOR)
fri_col = input.color(#9B7EF5, "Friday",    group=G_COLOR)

// ── Weekly Line ───────────────────────────────────────────────────────────────
show_wline  = input.bool (true,    "Show Weekly Line",  group=G_WEEK)
wline_col   = input.color(#0D2E6E, "Line Color",        group=G_WEEK)
wline_width = input.int  (1,       "Line Width",        minval=1, maxval=4, group=G_WEEK)

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════

// Pine Script's built-in `dayofweek` uses the chart's exchange timezone, which
// is NOT the same as our UTC-shifted local time. To get the correct day of week
// we derive it from `day_num` (the integer count of days since the Unix epoch).
//
// Jan 1, 1970 was a Thursday  → Pine dayofweek = 5
// Formula: ((day_num % 7) + 4) % 7 + 1  gives 1=Sun … 7=Sat

f_adj_dow(dn) =>
    math.round((dn % 7 + 4) % 7) + 1

f_col(d) =>
    switch d
        2 => mon_col
        3 => tue_col
        4 => wed_col
        5 => thu_col
        6 => fri_col
        => color.new(color.gray, 100)   // transparent for Sat/Sun (never used)

f_name(d) =>
    switch d
        2 => "Monday"
        3 => "Tuesday"
        4 => "Wednesday"
        5 => "Thursday"
        6 => "Friday"
        => ""

// ══════════════════════════════════════════════════════════════════════════════
//  CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// ── Detect new day using UTC-shifted time ─────────────────────────────────────
t_adj   = time + utc_offset * 3600000
day_num = math.floor(t_adj / 86400000)
new_day = ta.change(day_num) != 0 or barstate.isfirst

// Day of week for the LOCAL (adjusted) timezone — fixes the naming bug
adj_dow = f_adj_dow(day_num)

// Only draw sessions within the lookback window
in_range   = time >= timenow - days_shown * 86400000
is_weekday = adj_dow >= 2 and adj_dow <= 6   // Mon=2 … Fri=6

// Chart-bottom reference — pinned 500-bar lowest low
chart_btm = ta.lowest(low, 500)

// ── State ─────────────────────────────────────────────────────────────────────
var box     cur_box  = na
var float   d_hi     = na
var float   d_lo     = na
var label[] all_lbls = array.new<label>()

// ── New day handler ───────────────────────────────────────────────────────────
if new_day
    // Close the previous day's box
    if not na(cur_box)
        box.set_right(cur_box, bar_index - 1)
        cur_box := na

    // ── Weekly dashed line every Monday ──────────────────────────────────────
    if show_wline and adj_dow == 2 and in_range
        line.new(
             x1    = bar_index,
             y1    = 1e10,
             x2    = bar_index,
             y2    = -1e10,
             style = line.style_dashed,
             color = wline_col,
             width = wline_width)

    // ── Open new day box for weekdays only ────────────────────────────────────
    if in_range and is_weekday
        c    = f_col(adj_dow)
        d_hi := high
        d_lo := low

        cur_box := box.new(
             left         = bar_index,
             top          = d_hi,
             right        = bar_index,
             bottom       = d_lo,
             border_color = color.new(c, bord_t),
             border_width = bord_w,
             bgcolor      = color.new(c, fill_t))

        if show_lbl
            // Center label at local noon of this day
            noon_t = int(math.floor(t_adj / 86400000) * 86400000
                 + 12 * 3600000
                 - utc_offset * 3600000)

            lbl = label.new(
                 x         = noon_t,
                 y         = chart_btm,
                 text      = f_name(adj_dow),
                 xloc      = xloc.bar_time,
                 yloc      = yloc.price,
                 color     = color.new(color.black, 100),
                 textcolor = color.new(c, 0),
                 style     = label.style_label_up,
                 size      = lbl_sz)

            array.push(all_lbls, lbl)
    else
        d_hi := na
        d_lo := na

// ── Every bar: expand active box ─────────────────────────────────────────────
if not na(cur_box)
    d_hi := math.max(d_hi, high)
    d_lo := math.min(d_lo, low)
    box.set_top   (cur_box, d_hi)
    box.set_bottom(cur_box, d_lo)
    box.set_right (cur_box, bar_index)

// ── Every bar: keep labels pinned to chart bottom ─────────────────────────────
if show_lbl
    for lbl in all_lbls
        label.set_y(lbl, chart_btm)
````
