# 3n Daily Session open Boxes

- url: https://www.tradingview.com/script/kHGl27yX-3n-Daily-Session-open-Boxes/
- type: indicator
- pine_id: PUB;f0b4925e9abc40509f6fb87b889ba130
- version: 1.0

## Description

My descritption is a little tigth so i cam adding more words and letters so i can publish this script. Welcome to earth, it has 8pm to 12 in yellow or orange boxes woohooo

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © custom_levels_script

//@version=6
indicator("NYO Session Boxes (8pm–12am ET)", overlay=true, max_boxes_count=500)

// ─────────────────────────────────────────────
//  SETTINGS
// ─────────────────────────────────────────────
show_boxes    = input.bool(true,  "Show Session Boxes",   inline="b")
col_weekday   = input.color(color.new(#FFD600, 80), "Weekday (yellow)", inline="b")
col_weekend   = input.color(color.new(#FF6D00, 80), "Weekend (orange)", inline="b")

// ─────────────────────────────────────────────
//  TIMEZONE HELPERS
// ─────────────────────────────────────────────
et_hour   = hour(time, "America/New_York")
et_minute = minute(time, "America/New_York")
et_time   = et_hour * 100 + et_minute

et_dow     = dayofweek(time, "America/New_York")
is_weekend = et_dow == dayofweek.saturday or et_dow == dayofweek.sunday

// Session runs 8:00 PM → 11:59 PM ET
// 8pm = 2000, midnight = 0000 (next calendar day)
is_session_start = et_hour == 20 and et_minute == 0
in_session       = et_time >= 2000 and et_time <= 2359

// ─────────────────────────────────────────────
//  BOX TRACKING
// ─────────────────────────────────────────────
var box session_box = na

if is_session_start and show_boxes
    box_color     = is_weekend ? col_weekend : col_weekday
    session_box  := box.new(time, high, time + 1, low,
         xloc         = xloc.bar_time,
         border_color = color.new(box_color, 50),
         bgcolor      = box_color,
         border_width = 1,
         extend       = extend.none)

if in_session and show_boxes and not na(session_box)
    box.set_right(session_box,  time)
    box.set_top(session_box,    math.max(box.get_top(session_box),    high))
    box.set_bottom(session_box, math.min(box.get_bottom(session_box), low))

// Detach at midnight so next session gets a fresh box
if et_hour == 0 and et_minute == 0 and not na(session_box)
    session_box := na
````
