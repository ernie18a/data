# Session Highs and Lows in Real Time - By NickZZ

- url: https://www.tradingview.com/script/UUHvUs4b-Session-Highs-and-Lows-in-Real-Time-By-NickZZ/
- type: indicator
- pine_id: PUB;94af684c3f494fa4b757b366df36fca3
- version: 1.0

## Description

The Most Powerfull indicator that doesnt miss a single session level , it marks them all , saving you time to watch out for other indications for where price wants to go . As known a session's high or low is one of the strongest liquidity level , and we all know that price is always chasing liquidity.

## Source Code

````pine
//@version=5
indicator("Live Session H/L Tracker", overlay=true, max_lines_count=500, max_boxes_count=500)

// --- Inputs ---
asia_sess   = input.session("0000-0900", "Asia Session")
sydney_sess = input.session("2200-0700", "Sydney Session")
london_sess = input.session("0800-1700", "London Session")
ny_sess     = input.session("1300-2200", "NY Session")

color_as  = input.color(color.new(#00bcd4, 90), "Asia")
color_sdn = input.color(color.new(#9c27b0, 90), "Sydney")
color_ldn = input.color(color.new(#f44336, 90), "London")
color_ny  = input.color(color.new(#4caf50, 90), "New York")

// --- Storage for "Persistent" Lines (Post-Session) ---
var line[] h_lines = array.new_line()
var line[] l_lines = array.new_line()
var label[] h_labels = array.new_label()
var label[] l_labels = array.new_label()

// --- Logic Function ---
process_session(sess_spec, sess_color, short_name) =>
    var float hi = na
    var float lo = na
    var box sess_box = na
    var line live_hi_line = na
    var line live_lo_line = na
    var label live_hi_lab = na
    var label live_lo_lab = na
    
    in_sess = not na(time(timeframe.period, sess_spec, "UTC+0"))
    is_new = in_sess and not in_sess[1]
    is_end = not in_sess and in_sess[1]

    if is_new
        hi := high
        lo := low
        sess_box := box.new(bar_index, hi, bar_index, lo, bgcolor=sess_color, border_color=color.new(color.black, 100))
        // Create "Live" lines that show up immediately
        live_hi_line := line.new(bar_index, hi, bar_index + 1, hi, extend=extend.right, color=color.new(sess_color, 0), style=line.style_solid)
        live_lo_line := line.new(bar_index, lo, bar_index + 1, lo, extend=extend.right, color=color.new(sess_color, 0), style=line.style_solid)
        live_hi_lab := label.new(bar_index, hi, text=short_name + " Highs", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_left)
        live_lo_lab := label.new(bar_index, lo, text=short_name + " Lows", color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_left)
    
    if in_sess
        hi := math.max(high, hi)
        lo := math.min(low, lo)
        // Update Box
        box.set_top(sess_box, hi)
        box.set_bottom(sess_box, lo)
        box.set_right(sess_box, bar_index)
        // Update "Live" Lines & Labels
        line.set_y1(live_hi_line, hi)
        line.set_y2(live_hi_line, hi)
        line.set_y1(live_lo_line, lo)
        line.set_y2(live_lo_line, lo)
        label.set_xy(live_hi_lab, bar_index, hi)
        label.set_xy(live_lo_lab, bar_index, lo)

    if is_end
        // When session ends, convert the "Live" lines into the "Persistent" array to be tracked for taps
        line.set_style(live_hi_line, line.style_dashed)
        line.set_style(live_lo_line, line.style_dashed)
        array.push(h_lines, live_hi_line)
        array.push(l_lines, live_lo_line)
        array.push(h_labels, live_hi_lab)
        array.push(l_labels, live_lo_lab)

// Run Sessions
process_session(asia_sess, color_as, "AS")
process_session(sydney_sess, color_sdn, "SDN")
process_session(london_sess, color_ldn, "LDN")
process_session(ny_sess, color_ny, "NY")

// --- Tap Detection & Cleanup ---
if array.size(h_lines) > 0
    for i = array.size(h_lines) - 1 to 0
        l = array.get(h_lines, i)
        lb = array.get(h_labels, i)
        val = line.get_y1(l)
        label.set_x(lb, bar_index) // Keep labels on the right
        if high >= val
            line.delete(l)
            label.delete(lb)
            array.remove(h_lines, i)
            array.remove(h_labels, i)

if array.size(l_lines) > 0
    for i = array.size(l_lines) - 1 to 0
        l = array.get(l_lines, i)
        lb = array.get(l_labels, i)
        val = line.get_y1(l)
        label.set_x(lb, bar_index) // Keep labels on the right
        if low <= val
            line.delete(l)
            label.delete(lb)
            array.remove(l_lines, i)
            array.remove(l_labels, i)
````
