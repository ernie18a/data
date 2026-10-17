# Monthly Trinity Box

- url: https://www.tradingview.com/script/Wyr9gQaO-Monthly-Trinity-Box/
- type: indicator
- pine_id: PUB;583d15d1f218455ca76b3c2e499392bc
- version: 1.0

## Description

The DCG Monthly Day Box is a precision timing tool designed to highlight a specific calendar day each month directly on your chart. Built for traders who study recurring institutional behavior, monthly cycle setups, and time-based confluence zones, this indicator draws a dynamic box spanning the full high-to-low range of your chosen target day — complete with a midline and customizable lookback window.

Inspired by the same logic as third-hour and session-based reference boxes, this tool brings that same discipline to the monthly timeframe. Identify whether the 3rd, 5th, or any key calendar day is acting as support, resistance, or a volatility expansion trigger — month after month.

**Features:**
- Toggle any calendar day (1–28) as your monthly target
- Box auto-expands across all intraday bars within that day
- Alternating colors by even/odd month for instant visual separation
- Month label displayed on each box (e.g. JUN 3, JUL 3)
- Configurable lookback in months (1–24)
- Independent color controls for box fill, border, and midline
- Midline auto-calculated from session high/low — solid, dashed, or dotted
- Extend mode to project the box to the right edge of the chart

## Source Code

````pine
//@version=6
indicator("Monthly Day Box", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
//   MASTERMIND | Monthly Day Box v2
//  The Blu' Group LLC
//  Draws a box on the Nth calendar day of each
//  month — alternating colors, labeled, with
//  configurable lookback in months.
// ─────────────────────────────────────────────

// ── INPUTS ──────────────────────────────────
grp_settings  = "Box Settings"
target_day    = input.int(3,   "Target Day of Month",    minval=1, maxval=28,  group=grp_settings, tooltip="Which calendar day to highlight each month (e.g. 3 = 3rd of the month)")
months_back   = input.int(6,   "Months Back to Display", minval=1, maxval=24,  group=grp_settings, tooltip="How many months back to draw boxes")
show_label    = input.bool(true, "Show Month Label",                            group=grp_settings)
box_extend    = input.bool(true, "Extend Box to End of Day",                   group=grp_settings)

grp_colors    = "Color — Even Months (Feb, Apr, Jun...)"
box_color_a   = input.color(color.new(#00E5FF, 80), "Box Fill (Even)",   group=grp_colors)
bord_color_a  = input.color(color.new(#00E5FF, 10), "Box Border (Even)", group=grp_colors)
mid_color_a   = input.color(color.new(#FFD700,  0), "Midline (Even)",    group=grp_colors)

grp_colors2   = "Color — Odd Months (Jan, Mar, May...)"
box_color_b   = input.color(color.new(#FF6B35, 80), "Box Fill (Odd)",    group=grp_colors2)
bord_color_b  = input.color(color.new(#FF6B35, 10), "Box Border (Odd)",  group=grp_colors2)
mid_color_b   = input.color(color.new(#FFFFFF,  0), "Midline (Odd)",     group=grp_colors2)

grp_style     = "Style"
border_width  = input.int(1, "Border Width",  minval=1, maxval=4, group=grp_style)
mid_width     = input.int(1, "Midline Width", minval=1, maxval=4, group=grp_style)
mid_style_in  = input.string("Dashed", "Midline Style", options=["Solid","Dashed","Dotted"], group=grp_style)
label_size_in = input.string("Small",  "Label Size",    options=["Tiny","Small","Normal","Large"], group=grp_style)

// ── STYLE MAPS ───────────────────────────────
mid_line_style = mid_style_in == "Dashed" ? line.style_dashed :
                 mid_style_in == "Dotted" ? line.style_dotted :
                 line.style_solid

label_sz = label_size_in == "Tiny"   ? size.tiny   :
           label_size_in == "Small"  ? size.small  :
           label_size_in == "Large"  ? size.large  :
           size.normal

// ── MONTH NAME HELPER ────────────────────────
month_name(m) =>
    m == 1  ? "JAN" : m == 2  ? "FEB" : m == 3  ? "MAR" : m == 4  ? "APR" : m == 5  ? "MAY" : m == 6  ? "JUN" :m == 7  ? "JUL" : m == 8  ? "AUG" : m == 9  ? "SEP" :m == 10 ? "OCT" : m == 11 ? "NOV" : "DEC"

// ── LOOKBACK CUTOFF ──────────────────────────
// Calculate the timestamp N months back from the most recent bar
cutoff_month = month(timenow) - months_back
cutoff_year  = year(timenow)
adj_month    = cutoff_month <= 0 ? cutoff_month + 12 : cutoff_month
adj_year     = cutoff_month <= 0 ? cutoff_year - 1  : cutoff_year
cutoff_time  = timestamp(adj_year, adj_month, 1, 0, 0)

// ── DAY / MONTH DETECTION ────────────────────
cur_day_of_month  = dayofmonth(time)
cur_month         = month(time)
cur_year          = year(time)
prev_day_of_month = dayofmonth(time[1])

is_target_day        = cur_day_of_month == target_day and time >= cutoff_time
is_first_bar_of_day  = is_target_day and (prev_day_of_month != target_day or bar_index == 0)
is_even_month        = cur_month % 2 == 0

// ── ACTIVE BOX TRACKING ──────────────────────
var box   current_box = na
var line  current_mid = na
var label current_lbl = na
var float day_high    = na
var float day_low     = na

// ── OPEN NEW BOX ─────────────────────────────
if is_first_bar_of_day
    // Finalize previous if no-extend
    if not na(current_box) and not box_extend
        box.set_right(current_box, bar_index - 1)
    if not na(current_mid) and not box_extend
        line.set_x2(current_mid, bar_index - 1)

    day_high := high
    day_low  := low

    // Pick color set by odd/even month
    bc  = is_even_month ? box_color_a  : box_color_b
    bdc = is_even_month ? bord_color_a : bord_color_b
    mc  = is_even_month ? mid_color_a  : mid_color_b

    current_box := box.new(
         left         = bar_index,
         top          = high,
         right        = bar_index + 1,
         bottom       = low,
         bgcolor      = bc,
         border_color = bdc,
         border_width = border_width,
         extend       = box_extend ? extend.right : extend.none
         )

    float mid_price = (high + low) / 2
    current_mid := line.new(
         x1     = bar_index,
         y1     = mid_price,
         x2     = bar_index + 1,
         y2     = mid_price,
         color  = mc,
         width  = mid_width,
         style  = mid_line_style,
         extend = box_extend ? extend.right : extend.none
         )

    // Month label on top of the box
    if show_label
        lbl_text = month_name(cur_month) + " " + str.tostring(target_day)
        current_lbl := label.new(
             x        = bar_index,
             y        = high,
             text     = lbl_text,
             color    = color.new(#000000, 100),
             textcolor = is_even_month ? #00E5FF : #FF6B35,
             style    = label.style_label_down,
             size     = label_sz
             )

// ── EXPAND BOX WITHIN SAME DAY ───────────────
else if is_target_day and not na(current_box)
    day_high := math.max(day_high, high)
    day_low  := math.min(day_low,  low)

    box.set_top(current_box,    day_high)
    box.set_bottom(current_box, day_low)
    box.set_right(current_box,  bar_index + 1)

    float mid_price = (day_high + day_low) / 2
    line.set_y1(current_mid, mid_price)
    line.set_y2(current_mid, mid_price)
    line.set_x2(current_mid, bar_index + 1)

    if show_label and not na(current_lbl)
        label.set_y(current_lbl, day_high)

// ── CLOSE BOX WHEN DAY ENDS (no-extend mode) ─
else if not is_target_day and not na(current_box) and not box_extend
    box.set_right(current_box, bar_index - 1)
    line.set_x2(current_mid,   bar_index - 1)
    current_box := na
    current_mid := na
    current_lbl := na
````
