# Initial 1-Hour High/Low Range Box & Breakout Extension v6

- url: https://www.tradingview.com/script/CVIkQynh-Initial-1-Hour-High-Low-Range-Box-Breakout-Extension-v6/
- type: indicator
- pine_id: PUB;e41209e01fcd44a5bb8cef1aefc92529
- version: 4.0

## Description

### Description
This script automatically identifies the high and low range of the **initial 1 hour** of the trading session and plots a dynamic bounding box that extends throughout the rest of the day.

### Key Features
- **Initial 1-Hour Range Box**: Captures the exact highest and lowest price points within the first 60 minutes.
- **Dynamic Mid-lines**: Automatically plots a median/mid-line inside both the initial range and breakout boxes.
- **2nd Floor Breakout Expansion**: If the price breaks above the 1-hour high after the initial hour (based on bar close), it clones a secondary box with the exact same vertical height stacked directly on top of the initial high.
- **Highly Customizable**: Easily adjust colors, borders, line thickness, dashed/dotted styles, and session reset times from the settings panel.

### Notes
Optimized for **Intraday charts (e.g., 5-min, 15-min)**. Default time settings are pre-configured for **UTC-7 (06:30 - 13:00 trading hours)** but can be fully customized for any specific market session or asset class (Stocks, Crypto, and Futures like MNQ/NQ).

## Source Code

````pine
//@version=6
indicator("Initial High/Low Range Box & Breakout Extension v6", overlay=true, max_boxes_count=100, max_lines_count=200)

// ==========================================
// User Inputs
// ==========================================
int reset_hour     = input.int(6, title="Session Start Hour", minval=0, maxval=23)
int reset_minute   = input.int(30, title="Session Start Minute", minval=0, maxval=59)
int end_hour       = input.int(13, title="Session End Hour", minval=0, maxval=23)
int end_minute     = input.int(0, title="Session End Minute", minval=0, maxval=59)

int target_duration = input.int(60, title="Initial Range Minutes", minval=1, maxval=240)
int floor1_left_padding = input.int(2, title="1st Floor Left Padding (bars)", minval=0, maxval=20, tooltip="Moves 1st-floor left edge this many bars BEFORE the first session candle.")
int left_padding    = input.int(2, title="Breakout Floors Left Padding (bars)", minval=0, maxval=20)
int right_padding   = input.int(2, title="Box Right Padding (bars)", minval=0, maxval=20)

// 1st Floor
color color_box    = input.color(color.blue, title="Initial Box Border Color")
color color_bg     = input.color(color.new(color.blue, 96), title="Initial Box Background Color")
color color_mid    = input.color(color.orange, title="Initial Mid-line Color")
int width_mid      = input.int(1, title="Mid-line Width", minval=1, maxval=5)
string style_mid   = input.string("Dotted", title="Mid-line Style", options=["Solid", "Dotted", "Dashed"])

// 2nd Floor
color color_break_box = input.color(color.red, title="2nd Floor Box Border Color")
color color_break_bg  = input.color(color.new(color.red, 96), title="2nd Floor Box Background Color")
color color_break_mid = input.color(color.purple, title="2nd Floor Mid-line Color")

// 3rd Floor
color color_third_box = input.color(color.green, title="3rd Floor Box Border Color")
color color_third_bg  = input.color(color.new(color.green, 96), title="3rd Floor Box Background Color")
color color_third_mid = input.color(color.teal, title="3rd Floor Mid-line Color")

// 4th Floor
color color_fourth_box = input.color(color.fuchsia, title="4th Floor Box Border Color")
color color_fourth_bg  = input.color(color.new(color.fuchsia, 96), title="4th Floor Box Background Color")
color color_fourth_mid = input.color(color.aqua, title="4th Floor Mid-line Color")

// ==========================================
// Variable Declarations
// ==========================================
var int start_time = na
var float high_1h = na
var float low_1h = na
var box high_low_box = na
var line mid_line = na
var int hl_left_time = na

var box break_box = na
var line break_mid_line = na
var int break_left_time = na
var bool is_broken = false
var float box_height = na

var box third_box = na
var line third_mid_line = na
var int third_left_time = na
var bool is_third_broken = false

var box fourth_box = na
var line fourth_mid_line = na
var int fourth_left_time = na
var bool is_fourth_broken = false

string ln_style = style_mid == "Solid" ? line.style_solid : (style_mid == "Dashed" ? line.style_dashed : line.style_dotted)

int bar_ms = timeframe.in_seconds() * 1000
int left_pad_ms = left_padding * bar_ms
int right_pad_ms = right_padding * bar_ms

// 1st floor: use a prior bar's open time so the left vertical is clearly before candle #1
get_floor1_left_time() =>
    floor1_left_padding <= 0 ? time : (na(time[floor1_left_padding]) ? time - floor1_left_padding * bar_ms : time[floor1_left_padding])

// ==========================================
// Time Zone & Session (GMT-7)
// ==========================================
int cur_h = hour(time, "GMT-7")
int cur_m = minute(time, "GMT-7")

int curr_total_mins = cur_h * 60 + cur_m
int start_total_mins = reset_hour * 60 + reset_minute
int end_total_mins = end_hour * 60 + end_minute

bool in_session = curr_total_mins >= start_total_mins and curr_total_mins < end_total_mins
bool is_new_day = ta.change(dayofmonth) != 0
bool is_target_time = (cur_h == reset_hour and cur_m >= reset_minute and (cur_h[1] < reset_hour or (cur_h[1] == reset_hour and cur_m[1] < reset_minute)))

bool trigger_reset = (is_new_day or is_target_time) and timeframe.isintraday

// ==========================================
// Core Rendering Engine
// ==========================================
if trigger_reset
    start_time := time
    high_1h := high
    low_1h := low
    is_broken := false
    is_third_broken := false
    is_fourth_broken := false
    box_height := na

    hl_left_time := get_floor1_left_time()
    int right_t = time + right_pad_ms

    high_low_box := box.new(left=hl_left_time, top=high, right=right_t, bottom=low, border_color=color_box, border_width=2, bgcolor=color_bg, xloc=xloc.bar_time)
    mid_line := line.new(x1=hl_left_time, y1=high, x2=right_t, y2=high, color=color_mid, width=width_mid, style=ln_style, xloc=xloc.bar_time)

    break_box := na
    break_mid_line := na
    break_left_time := na
    third_box := na
    third_mid_line := na
    third_left_time := na
    fourth_box := na
    fourth_mid_line := na
    fourth_left_time := na
else
    if in_session
        int right_t = time + right_pad_ms

        if na(start_time) and timeframe.isintraday
            start_time := time
            high_1h := high
            low_1h := low
            hl_left_time := get_floor1_left_time()
            high_low_box := box.new(left=hl_left_time, top=high, right=right_t, bottom=low, border_color=color_box, border_width=2, bgcolor=color_bg, xloc=xloc.bar_time)
            mid_line := line.new(x1=hl_left_time, y1=high, x2=right_t, y2=high, color=color_mid, width=width_mid, style=ln_style, xloc=xloc.bar_time)

        if not na(start_time)
            int elapsed_minutes = int((time - start_time) / 60000)

            if elapsed_minutes <= target_duration
                high_1h := math.max(high, high_1h)
                low_1h := math.min(low, low_1h)
                box_height := high_1h - low_1h

            float mid_val = (high_1h + low_1h) / 2

            if not na(high_low_box)
                box.set_left(high_low_box, hl_left_time)
                box.set_top(high_low_box, high_1h)
                box.set_bottom(high_low_box, low_1h)
                box.set_right(high_low_box, right_t)

            if not na(mid_line)
                line.set_xy1(mid_line, hl_left_time, mid_val)
                line.set_xy2(mid_line, right_t, mid_val)

            if elapsed_minutes > target_duration
                float floor2_top = high_1h + box_height
                float floor3_top = high_1h + (box_height * 2)
                float floor4_top = high_1h + (box_height * 3)

                // 2nd floor
                if not is_broken and close > high_1h
                    is_broken := true
                    break_left_time := time - left_pad_ms
                    break_box := box.new(left=break_left_time, top=floor2_top, right=right_t, bottom=high_1h, border_color=color_break_box, border_width=2, bgcolor=color_break_bg, xloc=xloc.bar_time)
                    float break_mid_val = high_1h + (box_height / 2)
                    break_mid_line := line.new(x1=break_left_time, y1=break_mid_val, x2=right_t, y2=break_mid_val, color=color_break_mid, width=width_mid, style=ln_style, xloc=xloc.bar_time)

                if is_broken and not na(break_box)
                    box.set_right(break_box, right_t)

                if is_broken and not na(break_mid_line)
                    float break_mid_val = high_1h + (box_height / 2)
                    line.set_xy1(break_mid_line, break_left_time, break_mid_val)
                    line.set_xy2(break_mid_line, right_t, break_mid_val)

                // 3rd floor
                if is_broken and not is_third_broken and close > floor2_top
                    is_third_broken := true
                    third_left_time := time - left_pad_ms
                    third_box := box.new(left=third_left_time, top=floor3_top, right=right_t, bottom=floor2_top, border_color=color_third_box, border_width=2, bgcolor=color_third_bg, xloc=xloc.bar_time)
                    float third_mid_val = floor2_top + (box_height / 2)
                    third_mid_line := line.new(x1=third_left_time, y1=third_mid_val, x2=right_t, y2=third_mid_val, color=color_third_mid, width=width_mid, style=ln_style, xloc=xloc.bar_time)

                if is_third_broken and not na(third_box)
                    box.set_right(third_box, right_t)

                if is_third_broken and not na(third_mid_line)
                    float third_mid_val = floor2_top + (box_height / 2)
                    line.set_xy1(third_mid_line, third_left_time, third_mid_val)
                    line.set_xy2(third_mid_line, right_t, third_mid_val)

                // 4th floor
                if is_third_broken and not is_fourth_broken and close > floor3_top
                    is_fourth_broken := true
                    fourth_left_time := time - left_pad_ms
                    fourth_box := box.new(left=fourth_left_time, top=floor4_top, right=right_t, bottom=floor3_top, border_color=color_fourth_box, border_width=2, bgcolor=color_fourth_bg, xloc=xloc.bar_time)
                    float fourth_mid_val = floor3_top + (box_height / 2)
                    fourth_mid_line := line.new(x1=fourth_left_time, y1=fourth_mid_val, x2=right_t, y2=fourth_mid_val, color=color_fourth_mid, width=width_mid, style=ln_style, xloc=xloc.bar_time)

                if is_fourth_broken and not na(fourth_box)
                    box.set_right(fourth_box, right_t)

                if is_fourth_broken and not na(fourth_mid_line)
                    float fourth_mid_val = floor3_top + (box_height / 2)
                    line.set_xy1(fourth_mid_line, fourth_left_time, fourth_mid_val)
                    line.set_xy2(fourth_mid_line, right_t, fourth_mid_val)
````
