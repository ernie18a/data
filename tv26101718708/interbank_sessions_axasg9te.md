# Interbank Sessions

- url: https://www.tradingview.com/script/aXAsG9TE-Interbank-Sessions/
- type: indicator
- pine_id: PUB;5954e950cf4e4d50bd113d702dcd6187
- version: 1.0

## Description

Interbank Sessions is a precision‑engineered timing tool designed for traders who rely on clean, repeatable intraday structure.
The indicator plots three vertical timelines representing the core global trading sessions:

Asia Session

London Session

New York Session

Built for Forex and cryptocurrencies, Interbank Sessions provides a clear visual framework for understanding liquidity cycles, volatility rotations, and session‑to‑session transitions.

Traders in cash indices and equities can also use it to mark the cash opens of Asia, Europe, and the United States — giving you a unified, global market timing map on any chart.

Every element is fully customizable:

Adjustable session times for any timezone

Custom colors, line styles, and label visibility

Minimalist, non‑intrusive vertical markers

Works on all timeframes and all assets

Interbank Sessions delivers a clean, institutional‑grade view of the market’s temporal rhythm — without clutter, noise, or unnecessary features.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © VH_Traders
//@version=6
//@author=VH_Traders
indicator('Interbank Sessions', shorttitle = 'Interbank Sessions', overlay = true, scale = scale.none, max_lines_count=100, max_labels_count=100)

// -------------------------
// Inputs
// -------------------------
offset = input.string('America/New_York', 'Timezone Offset', 
     options=['America/New_York', 'UTC-12', 'UTC-11', 'UTC-10', 'UTC-9', 'UTC-8', 'UTC-7', 'UTC-6', 'UTC-5', 'UTC-4', 'UTC-3', 'UTC-2', 'UTC-1', 'UTC', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6', 'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12', 'UTC+13', 'UTC+14'], 
     tooltip='Select Timezone for lines')
max_lines = input.int(20, "Show Labels (Backward)", minval=1, maxval=100, tooltip = 'Restricts the number of visible labels on the \nchart history. Plotted lines are not affected, \nas Pine does not allow limiting plot history.')

// Label settings - inline grouped
show_labels  = input.bool(true, "Show Labels 🏷️", inline="labels")
label_size = input.string("small", "| Size", options=["tiny", "small", "normal", "large", "huge"], inline="labels")

// Label colors - inline grouped  
label_bg_color = input.color(color.new(color.gray, 20), "Label Background 🎨", inline="colors")
label_text_color = input.color(color.white, "Text 🎨", inline="colors")

// Time + Color + On/Off inline
sess1_time  = input.string("00:00", "Line 1 Time ⌛", inline="s1")
sess1_color = input.color(color.blue, "", inline="s1")
sess1_on    = input.bool(true, "On", inline="s1")

sess2_time  = input.string("07:00", "Line 2 Time ⌛", inline="s2")
sess2_color = input.color(color.red, "", inline="s2")
sess2_on    = input.bool(false, "On", inline="s2")

sess3_time  = input.string("08:30", "Line 3 Time ⌛", inline="s3")
sess3_color = input.color(color.green, "", inline="s3")
sess3_on    = input.bool(true, "On", inline="s3")
// -------------------------
// Helper functions
// -------------------------
parse_time(t_str) =>
    parts = str.split(t_str, ":")
    h_str = array.size(parts) > 0 ? array.get(parts, 0) : "0"
    m_str = array.size(parts) > 1 ? array.get(parts, 1) : "0"
    [str.tonumber(h_str), str.tonumber(m_str)]

isTime(t_str) =>
    [h, m] = parse_time(t_str)
    t_hour = hour(time, offset)
    t_hour := t_hour % 24
    if t_hour < 0
        t_hour := t_hour + 24
    t_minute = minute(time, offset)
    hour_match = t_hour == h
    minute_match = t_minute == m
    hour_match and minute_match

// -------------------------
// Series builder with customizable label colors and size
// -------------------------
var label[] tl_labels = array.new_label()

plot_line(show, t_str, line_color) =>
    cond = show and isTime(t_str)
    // Add small time label below the line (with custom colors and size)
    if cond and show_labels
        if array.size(tl_labels) >= max_lines
            oldLbl = array.shift(tl_labels)
            label.delete(oldLbl)
        // Convert string to size value
        text_size = label_size == "tiny" ? size.tiny : 
                   label_size == "small" ? size.small :
                   label_size == "normal" ? size.normal :
                   label_size == "large" ? size.large :
                   label_size == "huge" ? size.huge : size.small
        
        lbl = label.new(bar_index, low - (high-low)*0.02, t_str, 
                  style=label.style_label_up, 
                  color=label_bg_color, 
                  textcolor=label_text_color, 
                  size=text_size)

        array.push(tl_labels, lbl)

    cond ? 10e20 : na

// -------------------------
// Plots with labels
// -------------------------
plot(plot_line(sess1_on, sess1_time, sess1_color), style=plot.style_histogram, color=color.new(sess1_color, 60))
plot(plot_line(sess2_on, sess2_time, sess2_color), style=plot.style_histogram, color=color.new(sess2_color, 60))
plot(plot_line(sess3_on, sess3_time, sess3_color), style=plot.style_histogram, color=color.new(sess3_color, 60))
````
