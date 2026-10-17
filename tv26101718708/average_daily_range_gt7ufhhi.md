# Average Daily Range

- url: https://www.tradingview.com/script/Gt7uFHHI-Average-Daily-Range/
- type: indicator
- pine_id: PUB;578a6453ced04528bf2937dde65a5fdb
- version: 1.0

## Description

What it shows

Average Daily Range — N-day average of daily high-low ranges (default 14 days)
ADR Used — how much of the ADR has been consumed from today's open (optional)
ADR Remaining — how much range can still be expected in the current direction from current price (optional)
ADR Lines — horizontal lines on the chart marking the projected ADR high and low levels for the day (optional)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © YourUsername

//@version=5
indicator("Average Daily Range", shorttitle="Average Daily Range", overlay=true)

// ─── ADR SETTINGS ───────────────────────────────────────────────────────────
adr_length = input.int(14, title="ADR Period (Days)", minval=1, group="ADR Settings")

// ─── LABEL POSITION ─────────────────────────────────────────────────────────
h_pos = input.string("Right", title="Horizontal Position", options=["Left", "Center", "Right"], group="Label Position")
v_pos = input.string("Top",   title="Vertical Position",   options=["Top", "Middle", "Bottom"], group="Label Position")

// ─── ADR LABEL STYLE ────────────────────────────────────────────────────────
bg_color  = input.color(color.new(color.white, 100),  title="Background Color", group="ADR Label Style")
txt_color = input.color(color.rgb(74, 74, 74),        title="Text Color",       group="ADR Label Style")
txt_size  = input.string("Normal", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="ADR Label Style")

// ─── ADR USED ───────────────────────────────────────────────────────────────
show_used      = input.bool(true,                   title="Show ADR Used", group="ADR Used")
used_txt_color = input.color(color.rgb(74, 74, 74), title="Text Color",    group="ADR Used")

// ─── ADR REMAINING ──────────────────────────────────────────────────────────
show_remaining = input.bool(true,                   title="Show ADR Remaining", group="ADR Remaining")
rem_txt_color  = input.color(color.rgb(74, 74, 74), title="Text Color",         group="ADR Remaining")

// ─── ADR LINE ───────────────────────────────────────────────────────────────
show_line      = input.bool(false,                   title="Show ADR Line",   group="ADR Line")
line_color     = input.color(color.rgb(74, 74, 74),  title="Line Color",      group="ADR Line")
line_width     = input.int(1,                        title="Line Width",      minval=1, maxval=4, group="ADR Line")
line_style_inp = input.string("Dotted",              title="Line Style",      options=["Solid", "Dashed", "Dotted"], group="ADR Line")
line_source    = input.string("Both",                title="Show Level",      options=["ADR High", "ADR Low", "Both"], group="ADR Line")
line_end_hour  = input.int(18,                       title="Line End Hour",   minval=0, maxval=23, group="ADR Line")
line_end_min   = input.int(0,                        title="Line End Minute", minval=0, maxval=59, group="ADR Line")

// ─── CALCULATIONS ───────────────────────────────────────────────────────────
f_adr() => ta.sma(high - low, adr_length)
adr        = request.security(syminfo.tickerid, "D", f_adr())
today_open = request.security(syminfo.tickerid, "D", open)
today_high = request.security(syminfo.tickerid, "D", high)
today_low  = request.security(syminfo.tickerid, "D", low)

current_move   = math.abs(close - today_open)
adr_used       = current_move
adr_remaining  = math.max(adr - current_move, 0)
adr_high_level = today_low  + adr
adr_low_level  = today_high - adr

// ─── LINE END TIMESTAMP ─────────────────────────────────────────────────────
day_start_time = timestamp(year, month, dayofmonth, 0, 0, 0)
line_end_time  = day_start_time + line_end_hour * 3600000 + line_end_min * 60000

// ─── DISPLAY MAPPINGS ───────────────────────────────────────────────────────
mapped_size = txt_size == "Tiny" ? size.tiny : txt_size == "Small" ? size.small : txt_size == "Large" ? size.large : txt_size == "Huge" ? size.huge : size.normal
table_pos   = h_pos == "Left" and v_pos == "Top" ? position.top_left : h_pos == "Left" and v_pos == "Middle" ? position.middle_left : h_pos == "Left" and v_pos == "Bottom" ? position.bottom_left : h_pos == "Center" and v_pos == "Top" ? position.top_center : h_pos == "Center" and v_pos == "Middle" ? position.middle_center : h_pos == "Center" and v_pos == "Bottom" ? position.bottom_center : h_pos == "Right" and v_pos == "Top" ? position.top_right : h_pos == "Right" and v_pos == "Middle" ? position.middle_right : position.bottom_right
mapped_line = line_style_inp == "Dashed" ? line.style_dashed : line_style_inp == "Dotted" ? line.style_dotted : line.style_solid

// ─── TABLE ──────────────────────────────────────────────────────────────────
row_count = 1 + (show_used ? 1 : 0) + (show_remaining ? 1 : 0)
var table t = na
t := table.new(table_pos, 1, row_count, bgcolor=bg_color, border_width=0, border_color=bg_color, frame_width=0, frame_color=bg_color)

row = 0
table.cell(t, 0, row, "ADR: " + str.tostring(math.round(adr, 2)), text_color=txt_color, text_size=mapped_size, bgcolor=bg_color)

if show_used
    row := row + 1
    table.cell(t, 0, row, "Used: " + str.tostring(math.round(adr_used, 2)), text_color=used_txt_color, text_size=mapped_size, bgcolor=bg_color)

if show_remaining
    row := row + 1
    table.cell(t, 0, row, "Remaining: " + str.tostring(math.round(adr_remaining, 2)), text_color=rem_txt_color, text_size=mapped_size, bgcolor=bg_color)

// ─── ADR LINES ──────────────────────────────────────────────────────────────
var line adr_high_line = na
var line adr_low_line  = na

if show_line
    line.delete(adr_high_line)
    line.delete(adr_low_line)

    if line_source == "ADR High" or line_source == "Both"
        adr_high_line := line.new(x1=time, y1=adr_high_level, x2=line_end_time, y2=adr_high_level, xloc=xloc.bar_time, extend=extend.none, color=line_color, width=line_width, style=mapped_line)

    if line_source == "ADR Low" or line_source == "Both"
        adr_low_line := line.new(x1=time, y1=adr_low_level, x2=line_end_time, y2=adr_low_level, xloc=xloc.bar_time, extend=extend.none, color=line_color, width=line_width, style=mapped_line)
````
