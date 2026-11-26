# PilotJD Indicator

- url: https://www.tradingview.com/script/zrX3WWXl-PilotJD-Indicator/
- type: indicator
- pine_id: PUB;052c8c179e6840e89b63c529ac9a4335
- version: 1.0

## Description

9:30-9:45am ORB
Simple key levels
VWAP
5m TF 
[symbol="CME_MINI:MNQ1!"]CME_MINI:MNQ1![/symbol]

## Source Code

````pine
//@version=6
indicator("PilotJD Ind", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
pmh_col  = input.color(color.new(color.red,   60), "PMH Line Color")
pml_col  = input.color(color.new(color.green, 60), "PML Line Color")
orb_col  = input.color(color.new(color.blue,   0), "ORB Box Border Color")
vwap_col = input.color(color.new(color.aqua,   0), "VWAP Color")

// ─── SESSION HELPERS ──────────────────────────────────────────────────────────
is_new_day = ta.change(time("D")) != 0

et_hour   = hour(time,   "America/New_York")
et_minute = minute(time, "America/New_York")

is_premarket  = et_hour < 9 or (et_hour == 9 and et_minute < 30)
is_930        = et_hour == 9 and et_minute == 30
is_945        = et_hour == 9 and et_minute == 45
in_orb_window = not is_premarket and et_hour == 9 and et_minute >= 30 and et_minute < 45

// ─── PRE-MARKET HIGH / LOW ────────────────────────────────────────────────────
var float pmh      = na
var float pml      = na
var line  pmh_line = na
var line  pml_line = na
var label pmh_lbl  = na
var label pml_lbl  = na

if is_new_day
    pmh := na
    pml := na

if is_premarket
    pmh := na(pmh) ? high : math.max(pmh, high)
    pml := na(pml) ? low  : math.min(pml, low)

if is_930
    if not na(pmh_line)
        line.delete(pmh_line)
        line.delete(pml_line)
        label.delete(pmh_lbl)
        label.delete(pml_lbl)

    pmh_line := line.new(bar_index, pmh, bar_index + 1, pmh,
                         color=pmh_col, width=2,
                         extend=extend.right, style=line.style_dashed)
    pml_line := line.new(bar_index, pml, bar_index + 1, pml,
                         color=pml_col, width=2,
                         extend=extend.right, style=line.style_dashed)

    pmh_lbl := label.new(bar_index, pmh, "PMH",
                         color=color.new(color.black, 100),
                         textcolor=pmh_col,
                         style=label.style_label_right,
                         size=size.small)
    pml_lbl := label.new(bar_index, pml, "PML",
                         color=color.new(color.black, 100),
                         textcolor=pml_col,
                         style=label.style_label_right,
                         size=size.small)

// ─── ORB BOX  9:30 – 9:45 ────────────────────────────────────────────────────
var float orb_high  = na
var float orb_low   = na
var int   orb_left  = na
var int   orb_right = na
var box   orb_box   = na

if is_new_day
    orb_high  := na
    orb_low   := na
    orb_left  := na
    orb_right := na
    if not na(orb_box)
        box.delete(orb_box)
        orb_box := na

// Collect ORB range
if in_orb_window
    if na(orb_left)
        orb_left := bar_index
    orb_high := na(orb_high) ? high : math.max(orb_high, high)
    orb_low  := na(orb_low)  ? low  : math.min(orb_low,  low)

// Every bar after ORB window: delete and redraw box with updated right edge
if not na(orb_high) and not is_premarket and not in_orb_window
    if not na(orb_box)
        box.delete(orb_box)
    orb_box := box.new(orb_left, orb_high, bar_index + 4, orb_low,
                       border_color=orb_col,
                       border_width=2,
                       bgcolor=color.new(color.blue, 90))

// ─── VWAP ─────────────────────────────────────────────────────────────────────
[vwap_val, _, _] = ta.vwap(hlc3, is_new_day, 1)
plot(vwap_val, "VWAP", color=vwap_col, linewidth=2)
````
