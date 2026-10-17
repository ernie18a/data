# Hikks Session Highs & Lows - ASIA NY LONDON

- url: https://www.tradingview.com/script/iJsw8aFt-Hikks-Session-Highs-Lows-ASIA-NY-LONDON/
- type: indicator
- pine_id: PUB;7451ce9996ad43cfb13a94fa22023c09
- version: 2.0

## Description

Hikks Session Highs & Lows - ASIA NY LONDON -  WAFFLING TO HOT WORD LIMIT

## Source Code

````pine
//@version=6
indicator("Hikks Session Highs & Lows", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── Asia Inputs ───────────────────────────────────────────────────────────
show_asia   = input.bool(true,         title="Show Asia",        group="Asia Session")
asia_start  = input.int(18,            title="Start Hour (EST)", group="Asia Session", minval=0, maxval=23)
asia_end    = input.int(3,             title="End Hour (EST)",   group="Asia Session", minval=0, maxval=23)
asia_col_hi = input.color(color.yellow, title="High Color",      group="Asia Session")
asia_col_lo = input.color(color.yellow, title="Low Color",       group="Asia Session")
asia_hi_txt = input.string("Asia High", title="High Label",      group="Asia Session")
asia_lo_txt = input.string("Asia Low",  title="Low Label",       group="Asia Session")

// ─── London Inputs ─────────────────────────────────────────────────────────
show_lon   = input.bool(true,         title="Show London",       group="London Session")
lon_start  = input.int(3,             title="Start Hour (EST)",  group="London Session", minval=0, maxval=23)
lon_end_h  = input.int(8,             title="End Hour (EST)",    group="London Session", minval=0, maxval=23)
lon_end_m  = input.int(55,            title="End Minute (EST)",  group="London Session", minval=0, maxval=59)
lon_col_hi = input.color(color.blue,  title="High Color",        group="London Session")
lon_col_lo = input.color(color.blue,  title="Low Color",         group="London Session")
lon_hi_txt = input.string("London High", title="High Label",     group="London Session")
lon_lo_txt = input.string("London Low",  title="Low Label",      group="London Session")

// ─── New York Inputs ───────────────────────────────────────────────────────
show_ny   = input.bool(true,           title="Show New York",    group="New York Session")
ny_start  = input.int(9,               title="Start Hour (EST)", group="New York Session", minval=0, maxval=23)
ny_start_m = input.int(30,             title="Start Min (EST)",  group="New York Session", minval=0, maxval=59)
ny_end    = input.int(18,              title="End Hour (EST)",   group="New York Session", minval=0, maxval=23)
ny_col_hi = input.color(color.orange,  title="High Color",       group="New York Session")
ny_col_lo = input.color(color.orange,  title="Low Color",        group="New York Session")
ny_hi_txt = input.string("New York High", title="High Label",    group="New York Session")
ny_lo_txt = input.string("New York Low",  title="Low Label",     group="New York Session")

// ─── General ───────────────────────────────────────────────────────────────
ray_len = input.int(300, title="Ray Length (bars)", minval=5, maxval=1000, group="General")

// ─── Session Detection ─────────────────────────────────────────────────────
bar_hour = hour(time, "America/New_York")
bar_min  = minute(time, "America/New_York")
bar_mins = bar_hour * 60 + bar_min

asia_start_mins = asia_start * 60
asia_end_mins   = asia_end   * 60
lon_start_mins  = lon_start  * 60
lon_end_mins    = lon_end_h  * 60 + lon_end_m
ny_start_mins   = ny_start   * 60 + ny_start_m
ny_end_mins     = ny_end     * 60

in_asia   = asia_start_mins > asia_end_mins ? (bar_mins >= asia_start_mins or bar_mins < asia_end_mins) : (bar_mins >= asia_start_mins and bar_mins < asia_end_mins)
in_london = bar_mins >= lon_start_mins and bar_mins < lon_end_mins
in_ny     = bar_mins >= ny_start_mins  and bar_mins < ny_end_mins

// ─── Asia ─────────────────────────────────────────────────────────────────
var float asia_high      = na
var float asia_low       = na
var int   asia_hi_bar    = na
var int   asia_lo_bar    = na
var line  asia_hi_ray    = na
var line  asia_lo_ray    = na
var label asia_hi_lbl    = na
var label asia_lo_lbl    = na
var bool  asia_prev      = false
var float asia_hi_frozen = na
var float asia_lo_frozen = na
var int   asia_hi_frozen_bar = na
var int   asia_lo_frozen_bar = na

if in_asia
    if na(asia_high) or high > asia_high
        asia_high   := high
        asia_hi_bar := bar_index
    if na(asia_low) or low < asia_low
        asia_low    := low
        asia_lo_bar := bar_index

// Session just ended — freeze the values
if not in_asia and asia_prev
    asia_hi_frozen      := asia_high
    asia_lo_frozen      := asia_low
    asia_hi_frozen_bar  := asia_hi_bar
    asia_lo_frozen_bar  := asia_lo_bar
    asia_high           := na
    asia_low            := na

// Draw/extend every bar after session ends while frozen values exist
if not in_asia and not na(asia_hi_frozen) and show_asia
    line.delete(asia_hi_ray)
    line.delete(asia_lo_ray)
    label.delete(asia_hi_lbl)
    label.delete(asia_lo_lbl)
    asia_hi_ray := line.new(x1=asia_hi_frozen_bar, y1=asia_hi_frozen, x2=asia_hi_frozen_bar + ray_len, y2=asia_hi_frozen, color=asia_col_hi, width=2)
    asia_lo_ray := line.new(x1=asia_lo_frozen_bar, y1=asia_lo_frozen, x2=asia_lo_frozen_bar + ray_len, y2=asia_lo_frozen, color=asia_col_lo, width=2)
    asia_hi_lbl := label.new(x=asia_hi_frozen_bar + ray_len, y=asia_hi_frozen, text=asia_hi_txt, color=color.new(color.black, 100), textcolor=asia_col_hi, style=label.style_label_right, size=size.small)
    asia_lo_lbl := label.new(x=asia_lo_frozen_bar + ray_len, y=asia_lo_frozen, text=asia_lo_txt, color=color.new(color.black, 100), textcolor=asia_col_lo, style=label.style_label_right, size=size.small)

// New session starting — wipe frozen values so old lines stop extending
if in_asia and not asia_prev
    asia_hi_frozen := na
    asia_lo_frozen := na

asia_prev := in_asia

// ─── London ───────────────────────────────────────────────────────────────
var float lon_high      = na
var float lon_low       = na
var int   lon_hi_bar    = na
var int   lon_lo_bar    = na
var line  lon_hi_ray    = na
var line  lon_lo_ray    = na
var label lon_hi_lbl    = na
var label lon_lo_lbl    = na
var bool  lon_prev      = false
var float lon_hi_frozen = na
var float lon_lo_frozen = na
var int   lon_hi_frozen_bar = na
var int   lon_lo_frozen_bar = na

if in_london
    if na(lon_high) or high > lon_high
        lon_high   := high
        lon_hi_bar := bar_index
    if na(lon_low) or low < lon_low
        lon_low    := low
        lon_lo_bar := bar_index

if not in_london and lon_prev
    lon_hi_frozen      := lon_high
    lon_lo_frozen      := lon_low
    lon_hi_frozen_bar  := lon_hi_bar
    lon_lo_frozen_bar  := lon_lo_bar
    lon_high           := na
    lon_low            := na

if not in_london and not na(lon_hi_frozen) and show_lon
    line.delete(lon_hi_ray)
    line.delete(lon_lo_ray)
    label.delete(lon_hi_lbl)
    label.delete(lon_lo_lbl)
    lon_hi_ray := line.new(x1=lon_hi_frozen_bar, y1=lon_hi_frozen, x2=lon_hi_frozen_bar + ray_len, y2=lon_hi_frozen, color=lon_col_hi, width=2)
    lon_lo_ray := line.new(x1=lon_lo_frozen_bar, y1=lon_lo_frozen, x2=lon_lo_frozen_bar + ray_len, y2=lon_lo_frozen, color=lon_col_lo, width=2)
    lon_hi_lbl := label.new(x=lon_hi_frozen_bar + ray_len, y=lon_hi_frozen, text=lon_hi_txt, color=color.new(color.black, 100), textcolor=lon_col_hi, style=label.style_label_right, size=size.small)
    lon_lo_lbl := label.new(x=lon_lo_frozen_bar + ray_len, y=lon_lo_frozen, text=lon_lo_txt, color=color.new(color.black, 100), textcolor=lon_col_lo, style=label.style_label_right, size=size.small)

if in_london and not lon_prev
    lon_hi_frozen := na
    lon_lo_frozen := na

lon_prev := in_london

// ─── New York ─────────────────────────────────────────────────────────────
var float ny_high      = na
var float ny_low       = na
var int   ny_hi_bar    = na
var int   ny_lo_bar    = na
var line  ny_hi_ray    = na
var line  ny_lo_ray    = na
var label ny_hi_lbl    = na
var label ny_lo_lbl    = na
var bool  ny_prev      = false
var float ny_hi_frozen = na
var float ny_lo_frozen = na
var int   ny_hi_frozen_bar = na
var int   ny_lo_frozen_bar = na

if in_ny
    if na(ny_high) or high > ny_high
        ny_high   := high
        ny_hi_bar := bar_index
    if na(ny_low) or low < ny_low
        ny_low    := low
        ny_lo_bar := bar_index

if not in_ny and ny_prev
    ny_hi_frozen      := ny_high
    ny_lo_frozen      := ny_low
    ny_hi_frozen_bar  := ny_hi_bar
    ny_lo_frozen_bar  := ny_lo_bar
    ny_high           := na
    ny_low            := na

if not in_ny and not na(ny_hi_frozen) and show_ny
    line.delete(ny_hi_ray)
    line.delete(ny_lo_ray)
    label.delete(ny_hi_lbl)
    label.delete(ny_lo_lbl)
    ny_hi_ray := line.new(x1=ny_hi_frozen_bar, y1=ny_hi_frozen, x2=ny_hi_frozen_bar + ray_len, y2=ny_hi_frozen, color=ny_col_hi, width=2)
    ny_lo_ray := line.new(x1=ny_lo_frozen_bar, y1=ny_lo_frozen, x2=ny_lo_frozen_bar + ray_len, y2=ny_lo_frozen, color=ny_col_lo, width=2)
    ny_hi_lbl := label.new(x=ny_hi_frozen_bar + ray_len, y=ny_hi_frozen, text=ny_hi_txt, color=color.new(color.black, 100), textcolor=ny_col_hi, style=label.style_label_right, size=size.small)
    ny_lo_lbl := label.new(x=ny_lo_frozen_bar + ray_len, y=ny_lo_frozen, text=ny_lo_txt, color=color.new(color.black, 100), textcolor=ny_col_lo, style=label.style_label_right, size=size.small)

if in_ny and not ny_prev
    ny_hi_frozen := na
    ny_lo_frozen := na

ny_prev := in_ny
````
