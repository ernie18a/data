# Session Range Boxes

- url: https://www.tradingview.com/script/5jMfC5MJ-Session-Range-Boxes/
- type: indicator
- pine_id: PUB;ca9bee920ac84ae1a0414e5f6f4b8021
- version: 1.0

## Description

This script automatically draws rectangular boxes on your chart to visualize specific time-based trading sessions. It calculates periods based on a configurable start time (in UTC) and a fixed duration (defaulting to 3-hour intervals). For each session, it tracks the High, Low, Open, and Close prices:

Historical Boxes: Once a session ends, it locks the High/Low range into a static box. It keeps a limited history (default 50 boxes) to prevent clutter.

Live Box: It draws a dynamic, updating box for the current active session that expands as the price moves. This can be toggled on/off instantly.

OHLC Lines: It optionally plots lines for the session's opening and closing prices within the live box.

Primary Use Cases
Session Analysis: Traders use this to visually isolate price action during specific market hours (e.g., London Open, New York Open, or custom Asian sessions) to identify volatility ranges and support/resistance levels formed during those times.

Range Boundaries: The boxes clearly define the high and low of a specific time window, helping traders spot breakouts or rejections at session extremes.

Custom Timeframes: Since it allows custom start times and durations (in seconds), it works for non-standard sessions (e.g., a specific 4-hour block or a custom "pre-market" window) that standard indicators might miss.

Visual Clarity: By separating sessions into distinct colored blocks, it helps remove noise from overlapping timeframes and focuses attention on the current session's behavior.

## Source Code

````pine
//@version=6
indicator("Session Range Boxes", overlay=true, max_boxes_count=500)

// ── 1. INPUTS ─────────────────────────────────────
start_hour     = input.int(8,   "Start Hour (UTC)", 0, 23)
start_min      = input.int(30,  "Start Minute (UTC)", 0, 59)

interval_sec   = input.int(10800, "New box starts every (seconds)", minval=60)
duration_sec   = input.int(10300, "Each box lasts exactly (seconds)", minval=60)

max_boxes      = input.int(50, "Maximum Historical Boxes", minval=1, maxval=500)

showCurrent    = input.bool(true,  "Show Current/Live Box", 
     tooltip="When OFF: completely removes the live box (no shading, no border). Historical boxes remain visible.")

boxColor       = input.color(color.new(color.blue, 90), "Box Fill Color")
borderColor    = input.color(color.blue, "Border Color")

showOHLC       = input.bool(true, "Show OHLC Lines")
lineColor      = input.color(color.white, "OHLC Line Color")

// ── 2. CALCULATIONS ───────────────────────────────
interval_ms = interval_sec * 1000
duration_ms = duration_sec * 1000
offset_ms   = (start_hour * 3600 + start_min * 60) * 1000

period_start = math.floor((time - offset_ms) / interval_ms) * interval_ms + offset_ms

// ── 3. NEW PERIOD DETECTION ───────────────────────
var int last_period_start = na
bool new_period = na(last_period_start) or (last_period_start != period_start)

// ── 4. BOX LOGIC ──────────────────────────────────
var box   live_box      = na
var float sess_high     = na
var float sess_low      = na
var float sess_open     = na
var float sess_close    = na

var box[] hist_boxes    = array.new_box()

if new_period
    // Finalize the just-ended period as a permanent historical box
    if not na(last_period_start) and not na(sess_high)
        hist_box = box.new(
             left         = last_period_start,
             right        = last_period_start + duration_ms,
             top          = sess_high,
             bottom       = sess_low,
             border_color = borderColor,
             bgcolor      = boxColor,
             border_width = 1,
             xloc         = xloc.bar_time
             )
        array.push(hist_boxes, hist_box)
        
        // Limit number of historical boxes
        if array.size(hist_boxes) > max_boxes
            box.delete(array.shift(hist_boxes))
    
    // Start new session
    sess_high  := high
    sess_low   := low
    sess_open  := open
    sess_close := close

    last_period_start := period_start

    // Create live box only if enabled
    live_box := showCurrent ?
         box.new(
             left   = period_start,
             right  = period_start + duration_ms,
             top    = sess_high,
             bottom = sess_low,
             border_color = borderColor,
             bgcolor = boxColor,
             border_width = 1,
             xloc = xloc.bar_time
         ) : na

else
    // Update current live session
    sess_high  := math.max(sess_high, high)
    sess_low   := math.min(sess_low, low)
    sess_close := close

    if showCurrent and not na(live_box)
        box.set_top(live_box, sess_high)
        box.set_bottom(live_box, sess_low)
        box.set_right(live_box, period_start + duration_ms)

// ── 5. KILL LIVE BOX INSTANTLY WHEN TURNED OFF ─────
if not showCurrent and not na(live_box)
    box.delete(live_box)
    live_box := na

// ── 6. OHLC LINES ─────────────────────────────────
in_session = (time >= period_start) and (time < period_start + duration_ms)

plot(showOHLC and showCurrent and in_session ? sess_open  : na, 
     color=lineColor, style=plot.style_linebr, linewidth=1, title="Open")

plot(showOHLC and showCurrent and in_session ? sess_close : na, 
     color=lineColor, style=plot.style_linebr, linewidth=1, title="Close")
````
