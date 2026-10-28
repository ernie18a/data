# 246 LEVELS 

- url: https://www.tradingview.com/script/HEPPNzuL-246-LEVELS/
- type: indicator
- pine_id: PUB;8ef73acf886e4bd398492999837733c2
- version: 1.0

## Description

THESE ARE THE 246 LEVEL BASED ON LIQ LEVELS FOR IPDA
This indicator is designed to provide high-probability trading zones based on time, price action, and market structure. It automatically plots key levels and highlights reaction zones where price is likely to reverse or continue.

Built for precision traders, it integrates:

Dynamic range detection
Institutional liquidity zones
Smart candle coloring based on interaction with levels

Ideal for intraday traders using ICT concepts, killzones, and liquidity-based entries.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ankitaghorui10229

//@version=6
indicator("Session-Based Time Levels", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// --- Inputs ---
gmt_offset   = input.int(0, "GMT Offset (Hours)", minval=-12, maxval=14)
text_size    = input.string("Small", "Text Size", options=["Small", "Normal", "Large"])
history_days = input.string("Last 2 Days", "Historical Sessions", options=["Current Day Only", "Last 2 Days", "Last 3 Days", "Last 5 Days", "Last 10 Days"])

// Colors
color_2am = input.color(color.new(color.blue, 85), "2 AM Box Color")
color_4am = input.color(color.new(color.red, 85), "4 AM Box Color")
color_6am = input.color(color.new(color.green, 85), "6 AM Box Color")
color_2pm = input.color(color.new(color.orange, 85), "2 PM Box Color")
color_4pm = input.color(color.new(color.purple, 85), "4 PM Box Color")
color_6pm = input.color(color.new(color.teal, 85), "6 PM Box Color")

// --- Constants ---
var int MS_PER_DAY = 86400000
var int OFFSET_MS = gmt_offset * 3600000

// Dynamic bars per hour calculation
bars_per_hour = math.round(60 / timeframe.multiplier)

// Map text size
get_size(s) =>
    s == "Small" ? size.small : s == "Large" ? size.large : size.normal

// Map history days
int days_to_show = switch history_days
    "Current Day Only" => 0
    "Last 2 Days"      => 1
    "Last 3 Days"      => 2
    "Last 5 Days"      => 4
    "Last 10 Days"     => 9
    => 1

// --- Helper Function to Draw Session Levels ---
draw_session(session_name, hour_start, col) =>
    // Check if current bar is within the lookback period
    is_in_history = (time >= (timenow - (days_to_show + 1) * MS_PER_DAY))
    
    // Detect start of the specific hour
    is_new_hour = hour(time + OFFSET_MS) == hour_start and minute(time + OFFSET_MS) == 0 and is_in_history
    
    // Use request.security to get the actual 1H High/Low to ensure accuracy on lower TFs
    [h1, l1] = request.security(syminfo.tickerid, "60", [high, low], lookahead=barmerge.lookahead_on)
    
    if is_new_hour
        int end_bar = bar_index + bars_per_hour - 1
        // Draw High and Low lines for the full hour period
        line.new(bar_index, h1, end_bar, h1, color=color.new(col, 0), width=1)
        line.new(bar_index, l1, end_bar, l1, color=color.new(col, 0), width=1)
        
        // Draw labels at the right edge with Time + High/Low + Price
        label.new(end_bar, h1, session_name + " High: " + str.tostring(h1, format.mintick), color=color.new(col, 100), textcolor=color.new(col, 0), style=label.style_label_left, size=get_size(text_size))
        label.new(end_bar, l1, session_name + " Low: " + str.tostring(l1, format.mintick), color=color.new(col, 100), textcolor=color.new(col, 0), style=label.style_label_left, size=get_size(text_size))

// --- Execution ---
// Since this is a 1H chart, we look for exact hour starts
draw_session("2AM", 2, color_2am)
draw_session("4AM", 4, color_4am)
draw_session("6AM", 6, color_6am)
draw_session("2PM", 14, color_2pm)
draw_session("4PM", 16, color_4pm)
draw_session("6PM", 18, color_6pm)
````
