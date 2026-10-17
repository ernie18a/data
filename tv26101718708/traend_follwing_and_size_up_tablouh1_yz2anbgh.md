# TRAEND FOLLWING AND SIZE UP (TABLOUH1)

- url: https://www.tradingview.com/script/YZ2AnbGh-TRAEND-FOLLWING-AND-SIZE-UP-TABLOUH1/
- type: indicator
- pine_id: PUB;b6e8d6948ea24a23813b13ed75586e31
- version: 1.0

## Description

How to use this for sizing up:
Intraday: Use the current 4H box high/low as support and resistance.

Sizing Up: 
If the previous 4H box was a "bullish" close and the current price is holding above that box's midpoint or high, that’s your green light to size up.

Swing/Overnight: 
If the daily price closes outside the 4H box in your direction, the trend is confirmed for an overnight hold.

## Source Code

````pine
//@version=5
indicator("Specific Session Box", overlay=true)

// --- Inputs ---
session_input = input.session("0900-1200", "Session Time (HHMM-HHMM)", tooltip="Enter the time range you want to box. Format: 0900-1200")
box_color     = input.color(color.new(color.orange, 85), "Box Color")
border_color  = input.color(color.orange, "Border Color")

// --- Logic ---
// Check if the current bar is within the user-defined session
is_in_session = not na(time(timeframe.period, session_input))

// Use variables to track session High and Low
var float session_high = na
var float session_low  = na
var int   session_start_time = na
var box   session_box = na

// Reset values when a new session starts
if is_in_session and not is_in_session[1]
    session_high := high
    session_low  := low
    session_start_time := time
    session_box := box.new(left=session_start_time, top=session_high, right=time, bottom=session_low, 
                           xloc=xloc.bar_time, border_color=border_color, bgcolor=box_color)
else if is_in_session
    // Update existing session box with new high/low and current time
    session_high := math.max(high, session_high)
    session_low  := math.min(low, session_low)
    box.set_top(session_box, session_high)
    box.set_bottom(session_box, session_low)
    box.set_right(session_box, time_close)
````
