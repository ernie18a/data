# Market Gap

- url: https://www.tradingview.com/script/vJH8JGQe-Market-Gap/
- type: indicator
- pine_id: PUB;da7ce95d34cd45a3b9cfe9137cd6f807
- version: 1.0

## Description

Simple Script for Gap up and and Gap down. This script detects gap up and gap down.
it is not screener

## Source Code

````pine
//@version=6
indicator("Market Gap", overlay=true)

// ── Inputs ────────────────────────────────────────────────────────────────────
gap_up_color   = input.color(color.new(color.green, 80), "Gap Up Color")
gap_down_color = input.color(color.new(color.red,   80), "Gap Down Color")

// ── Sessions ──────────────────────────────────────────────────────────────────
is_rth       = not na(time("1", "0930-1600", "America/New_York"))
is_premarket = not na(time("1", "0400-0930", "America/New_York"))

rth_open  = is_rth and not is_rth[1]
rth_close = not is_rth and is_rth[1]

// ── Tracking ──────────────────────────────────────────────────────────────────
var float prev_close   = na
var int   prev_close_t = na
var float gap_open     = na

if rth_close
    prev_close   := close[1]
    prev_close_t := time[1]

if rth_open
    gap_open := open

// ── Draw ──────────────────────────────────────────────────────────────────────
var box gap_box = na

if barstate.islast
    box.delete(gap_box)

    if not na(prev_close) and not na(prev_close_t)
        ref_price = is_premarket ? close : gap_open
        if not na(ref_price) and ref_price != prev_close
            col     = ref_price > prev_close ? gap_up_color : gap_down_color
            top     = math.max(prev_close, ref_price)
            bot     = math.min(prev_close, ref_price)
            gap_box := box.new(prev_close_t, top, time, bot, xloc=xloc.bar_time, bgcolor=col, border_color=col)
````
