# Extra Timeline

- url: https://www.tradingview.com/script/Pe1dHcNd-Extra-Timeline/
- type: indicator
- pine_id: PUB;48e6ffb47d3b4e28a72a8c8ededf33b9
- version: 1.0

## Description

Are you tired of the default time axis getting cluttered, or do you need to keep track of a specific timezone (like your local time or a specific market session) directly on your chart?

Extra Timeline is a minimalist, highly customizable secondary time axis designed to keep your charts clean and readable, no matter how much you zoom in or out. It solves the common issue of overlapping text labels by using a "Smart Hide" feature that prioritizes full hours over minute intervals when space gets tight.

Key Features:

Smart Anti-Overlap System: Automatically hides minute intervals (like 15 or 30) when you zoom out, ensuring that the full hours always remain visible and the timeline never turns into an unreadable mess.

Minimalist & Clean Format: Removes unnecessary clutter. Full hours are displayed as a simple number (e.g., 9 instead of 09:00), and minute intervals show only the minutes (e.g., 30 instead of 09:30).

Visual Hierarchy: Fully customize the size and color of full hours versus minute intervals. Make full hours large and bright to stand out, while keeping minute markers small and subtle.

Custom Timezones: Easily offset the time to match any GMT timezone you need.

Flexible Intervals: Choose exactly where your time anchors are placed (5m, 10m, 15m, 30m, 1H, 2H, or 4H).

Optional Date Display: Toggle the current date on or off alongside the time markers.

How to Use:
Simply apply the indicator to your chart and adjust the Timezone to your preference. If you notice labels starting to overlap when zooming, just increase the "Minimum Space (in bars)" setting in the indicator options to give the labels more room to breathe.

Perfect for day traders and scalpers who need a precise, distraction-free sense of time across different market sessions!

## Source Code

````pine
//@version=6
indicator("Extra Timeline", overlay=false, max_labels_count=500)

// --- SETTINGS ---
grp1 = "Time Settings"
tz = input.string("GMT+0", title="Target Timezone (e.g., GMT+2)", group=grp1)
interval_inp = input.string("30 Minutes", title="Time Interval", options=["5 Minutes", "10 Minutes", "15 Minutes", "30 Minutes", "1 Hour", "2 Hours", "4 Hours"], group=grp1)
show_date = input.bool(false, title="Show Date?", group=grp1)

grp3 = "Prevent Overlapping"
smart_hide = input.bool(true, title="Smart Hide (Prioritize Full Hours)", group=grp3, tooltip="Hides minute labels if there is not enough space between candles to display them cleanly.")
min_space = input.int(12, title="Minimum Space (in bars)", group=grp3, tooltip="Minimum number of candles required between labels. Increase this if labels still overlap.")

grp2 = "Appearance (Hours)"
hour_size_inp = input.string("Normal", title="Hour Size", options=["Tiny", "Small", "Normal", "Large"], group=grp2)
hour_color = input.color(color.white, title="Hour Color", group=grp2)

grp4 = "Appearance (Minutes)"
min_size_inp = input.string("Small", title="Minute Size", options=["Tiny", "Small", "Normal", "Large"], group=grp4)
min_color = input.color(color.gray, title="Minute Color", group=grp4)

// --- FUNCTIONS & CONVERSIONS ---
get_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

var int interval = switch interval_inp
    "5 Minutes"  => 5
    "10 Minutes" => 10
    "15 Minutes" => 15
    "30 Minutes" => 30
    "1 Hour"     => 60
    "2 Hours"    => 120
    "4 Hours"    => 240
    => 30

plot(0, color=color.new(color.black, 100))

// --- CALCULATION ---
h = hour(time, tz)
m = minute(time, tz)
d = dayofmonth(time, tz)

prev_h = bar_index > 0 ? hour(time[1], tz) : h
prev_m = bar_index > 0 ? minute(time[1], tz) : m
prev_d = bar_index > 0 ? dayofmonth(time[1], tz) : d

curr_total_mins = h * 60 + m
prev_total_mins = prev_h * 60 + prev_m

curr_period = math.floor(curr_total_mins / interval)
prev_period = math.floor(prev_total_mins / interval)

is_new_period = (curr_period != prev_period) or (d != prev_d)

// Track the bar index of the last drawn label
var int last_drawn_bar = -9999

// --- DRAWING ---
if is_new_period
    bool is_full_hour = (m == 0)
    bool enough_space = (bar_index - last_drawn_bar) >= min_space
    
    bool should_draw = true
    if smart_hide and not is_full_hour and not enough_space
        should_draw := false
        
    if should_draw
        string time_str = ""
        string final_size = size.small
        color final_color = color.white
        
        if is_full_hour
            time_str := str.tostring(h)
            final_size := get_size(hour_size_inp)
            final_color := hour_color
        else
            time_str := str.tostring(m, "00")
            final_size := get_size(min_size_inp)
            final_color := min_color
        
        if show_date
            mo = month(time, tz)
            time_str := str.tostring(d) + "." + str.tostring(mo) + ".  " + time_str
            
        label.new(
             x=bar_index, 
             y=0, 
             text=time_str, 
             color=color.new(color.black, 100), 
             textcolor=final_color, 
             style=label.style_label_center, 
             size=final_size
             )
        
        last_drawn_bar := bar_index
````
