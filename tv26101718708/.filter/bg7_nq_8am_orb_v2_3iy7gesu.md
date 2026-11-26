# BG7 NQ 8AM ORB - v2

- url: https://www.tradingview.com/script/3IY7gEsu-BG7-NQ-8AM-ORB-v2/
- type: indicator
- pine_id: PUB;c82bd33b66a742bfb9c61b23e040b0b1
- version: 1.0

## Description

This is based off the 8am opening range. Similar to other ORB strategies this one has a buffer zone for candle closer and direction. The closing of the candle on 5 min time will signal long or short according to which buffer zone it closed in. This is a simple script that just gives a visual signal when everything aligns on the chart for what direction to trade. Its great for a quick 50 to 100 point scalp before the market opens.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bg7crypto

//@version=6
// ============================================================
// NQ 8AM Opening Range Breakout - INDICATOR
// Timeframe: 5-minute chart (NQ Futures)
// Author: Built for Brandon
// ============================================================
// USAGE:
//   - Apply to NQ 5-minute chart
//   - The first 5-min candle at 8:00 AM ET is the "Opening Range"
//   - Upper/Lower 30-tick buffer zones highlight breakout areas
//   - Signal arrows appear when a candle CLOSES in a buffer zone
// ============================================================

// ============================================================
// NQ 8AM ORB - Fixed & Type-Corrected
// ============================================================
//@version=6
indicator(title="Brandons NQ 8AM ORB - Fixed", shorttitle="NQ ORB", overlay=true, max_boxes_count=100)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_orb   = "Opening Range Settings"
orb_time  = input.string("0800-0805", "ORB Time Range (5min)", group=grp_orb)
tz_input  = input.string("America/New_York", "Timezone",        group=grp_orb)
tick_size = input.float(0.25, "Tick Size (NQ = 0.25)",         group=grp_orb)
buf_ticks = input.int(30, "Buffer Zone Ticks",                 group=grp_orb)

grp_col   = "Colors"
col_orb   = input.color(color.new(color.blue,  80), "ORB Zone Color",   group=grp_col)
col_buf   = input.color(color.new(color.orange, 80), "Buffer Color",     group=grp_col)

// ─── LOGIC ────────────────────────────────────────────────────────────────────
buf_pts = buf_ticks * tick_size

// time() returns na if not in session, or an int timestamp. We must convert to bool.
in_orb_window = not na(time(timeframe.period, orb_time, tz_input))
is_new_day    = ta.change(time("D")) != 0

var float orb_h = na
var float orb_l = na
var int orb_start_index = na

// Capture ORB values
// ─── CAPTURE ORB VALUES ──────────────────────────────────────────────────────
if in_orb_window
    // Check if this is the first bar of the window (instead of na(), we check if it WASN'T true on the last bar)
    is_first_bar = in_orb_window and not in_orb_window[1]
    
    if is_first_bar or is_new_day
        orb_h := high
        orb_l := low
        orb_start_index := bar_index
    else
        orb_h := math.max(nz(orb_h, high), high)
        orb_l := math.min(nz(orb_l, low), low)
// ─── BOX DRAWING ──────────────────────────────────────────────────────────────
var box orb_box = na
var box top_buf = na
var box bot_buf = na

// Move ta.change calls outside of the conditional to keep the compiler happy
orb_h_changed = ta.change(orb_h) != 0
orb_l_changed = ta.change(orb_l) != 0

if not na(orb_h) and not is_new_day
    // Check if we need to redraw (during the ORB bar) or just extend (after)
    if orb_h_changed or orb_l_changed or in_orb_window
        box.delete(orb_box)
        box.delete(top_buf)
        box.delete(bot_buf)
        
        // Main ORB Candle Box
        orb_box := box.new(orb_start_index, orb_h, bar_index, orb_l, 
             bgcolor=col_orb, border_color=color.new(color.blue, 50), xloc=xloc.bar_index, border_style=line.style_dashed)
        
        // Top Buffer (30 ticks above High)
        top_buf := box.new(orb_start_index, orb_h + buf_pts, bar_index, orb_h, 
             bgcolor=col_buf, border_color=color.new(color.orange, 100), xloc=xloc.bar_index)
             
        // Bottom Buffer (30 ticks below Low)
        bot_buf := box.new(orb_start_index, orb_l, bar_index, orb_l - buf_pts, 
             bgcolor=col_buf, border_color=color.new(color.orange, 100), xloc=xloc.bar_index)
    else
        // Just extend existing boxes to the right
        box.set_right(orb_box, bar_index)
        box.set_right(top_buf, bar_index)
        box.set_right(bot_buf, bar_index)

// ─── SIGNALS ──────────────────────────────────────────────────────────────────
is_after_orb = not in_orb_window and not na(orb_h)

long_sig  = is_after_orb and close > orb_h and close <= (orb_h + buf_pts)
short_sig = is_after_orb and close < orb_l and close >= (orb_l - buf_pts)

plotshape(long_sig,  "Long",  shape.triangleup,   location.belowbar, color.lime, size=size.small, text="LONG")
plotshape(short_sig, "Short", shape.triangledown, location.abovebar, color.red,  size=size.small, text="SHORT")
````
