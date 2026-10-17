# 15M ORB Automated levels

- url: https://www.tradingview.com/script/Ki2fSWjL-15M-ORB-Automated-levels/
- type: indicator
- pine_id: PUB;2072d7efdf294bf88457c2d3b4b4590d
- version: 1.0

## Description

Marks opening range high's and low's as well as Pre-market highs and low's (PML, and PMH)

## Source Code

````pine
//@version=6
indicator("NY ORB 15m + London Pre-Market Levels", overlay=true, max_lines_count=20, max_labels_count=10)

// =============================================
// INPUTS
// =============================================
grp_ny = "NY Opening Range (9:30-9:45 ET)"
show_ny     = input.bool(true,  "Show NY OR Levels", group=grp_ny)
ny_h_color  = input.color(color.new(#00C853, 0), "NY OR High Color", group=grp_ny)
ny_l_color  = input.color(color.new(#00C853, 0), "NY OR Low Color",  group=grp_ny)

grp_lon = "London Pre-Market Levels (3:00-9:30 ET)"
show_lon    = input.bool(true,  "Show London Levels", group=grp_lon)
lon_h_color = input.color(color.new(#2196F3, 0), "London High Color (PMH)", group=grp_lon)
lon_l_color = input.color(color.new(#2196F3, 0), "London Low Color (PML)",  group=grp_lon)

grp_gen = "General Settings"
line_width  = input.int(2, "Line Width", minval=1, maxval=4, group=grp_gen)
show_labels = input.bool(true, "Show Labels (Current Day Only)", group=grp_gen)
label_size  = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large], group=grp_gen)

// =============================================
// TIME & SESSION LOGIC (America/New_York)
// =============================================
int ny_hr  = hour(time, "America/New_York")
int ny_min = minute(time, "America/New_York")

// NY Opening Range: 9:30–9:45 ET
bool in_ny_or = ny_hr == 9 and ny_min >= 30 and ny_min < 45

// London Pre-Market: 3:00–9:30 ET
bool in_london = (ny_hr >= 3 and ny_hr <= 8) or (ny_hr == 9 and ny_min < 30)

// New trading day detection (NY timezone)
bool is_new_day = ta.change(time("D", "America/New_York")) != 0

// =============================================
// VARIABLES (reset daily)
// =============================================
var float ny_or_h   = na
var float ny_or_l   = na
var bool  ny_or_done = false

var float lon_h     = na
var float lon_l     = na
var bool  lon_done   = false

// =============================================
// DAILY RESET
// =============================================
if is_new_day
    ny_or_h    := na
    ny_or_l    := na
    ny_or_done := false

    lon_h      := na
    lon_l      := na
    lon_done   := false

// =============================================
// UPDATE RANGES
// =============================================
if in_london
    lon_h := math.max(nz(lon_h, high), high)
    lon_l := math.min(nz(lon_l, low),  low)

if in_ny_or
    ny_or_h := math.max(nz(ny_or_h, high), high)
    ny_or_l := math.min(nz(ny_or_l, low),  low)

// =============================================
// LOCK RANGES WHEN THEY CLOSE
// =============================================
if not in_london and not lon_done and not na(lon_h)
    lon_done := true

if not in_ny_or and not ny_or_done and not na(ny_or_h)
    ny_or_done := true

// =============================================
// PLOT VALUES (horizontal lines)
// =============================================
float p_lon_h = lon_done and show_lon ? lon_h : na
float p_lon_l = lon_done and show_lon ? lon_l : na
float p_ny_h  = ny_or_done and show_ny  ? ny_or_h : na
float p_ny_l  = ny_or_done and show_ny  ? ny_or_l : na

plot(p_lon_h, color=lon_h_color, linewidth=line_width, style=plot.style_linebr, title="London PMH")
plot(p_lon_l, color=lon_l_color, linewidth=line_width, style=plot.style_linebr, title="London PML")
plot(p_ny_h,  color=ny_h_color,  linewidth=line_width, style=plot.style_linebr, title="OR High")
plot(p_ny_l,  color=ny_l_color,  linewidth=line_width, style=plot.style_linebr, title="OR Low")

// =============================================
// LABELS (only on the live bar)
// =============================================
if show_labels and barstate.islast
    if lon_done and show_lon
        label.new(bar_index,     lon_h, " PMH", style=label.style_label_left, color=lon_h_color, textcolor=color.white, size=label_size)
        label.new(bar_index + 6, lon_l, " PML", style=label.style_label_left, color=lon_l_color, textcolor=color.white, size=label_size)

    if ny_or_done and show_ny
        label.new(bar_index,     ny_or_h, " OR High", style=label.style_label_left, color=ny_h_color, textcolor=color.white, size=label_size)
        label.new(bar_index + 6, ny_or_l, " OR Low",  style=label.style_label_left, color=ny_l_color, textcolor=color.white, size=label_size)
````
