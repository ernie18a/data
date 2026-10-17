# Prior Day RTH Range

- url: https://www.tradingview.com/script/e4nDnT1e-Prior-Day-RTH-Range/
- type: indicator
- pine_id: PUB;c6474aac3b484525a8ecd9b03a09bf4a
- version: 1.0

## Description

Denotes the prior day high and low and shades in the prior day price range

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mottand

//@version=5
indicator("Prior Day RTH Range", overlay=true)

// === INPUTS ===
extend_bars  = input.int(50,  "Extend Box Bars to Right", minval=1, maxval=500)
box_color    = input.color(color.new(color.white, 80), "Box Fill Color")
border_color = input.color(color.white, "Box Border Color")
border_width = input.int(1, "Border Width", minval=1, maxval=4)

// === RTH SESSION ===
rth_session = "0930-1600"
is_in_rth   = not na(time(timeframe.period, rth_session))
this_day    = dayofmonth(time)

// === TRACK RTH SESSIONS ===
var int   current_day   = na
var float running_high  = na
var float running_low   = na
var int   running_left  = na
var int   running_right = na

var float day1_high  = na
var float day1_low   = na
var int   day1_left  = na
var int   day1_right = na

if is_in_rth
    if na(current_day) or this_day != current_day
        if not na(current_day)
            day1_high  := running_high
            day1_low   := running_low
            day1_left  := running_left
            day1_right := running_right

        current_day   := this_day
        running_high  := high
        running_low   := low
        running_left  := bar_index
        running_right := bar_index
    else
        running_high  := math.max(running_high, high)
        running_low   := math.min(running_low,  low)
        running_right := bar_index

// === DETERMINE ACTIVE LEVELS ===
float active_high = not is_in_rth ? running_high : day1_high
float active_low  = not is_in_rth ? running_low  : day1_low

// === DRAW BOX ===
var box rth_box = na

if barstate.islast or barstate.isrealtime
    box.delete(rth_box)

    if not na(active_high)
        rth_box := box.new(
             left         = not is_in_rth ? running_left  : day1_left,
             top          = active_high,
             right        = (not is_in_rth ? running_right : day1_right) + extend_bars,
             bottom       = active_low,
             border_color = border_color,
             border_width = border_width,
             bgcolor      = box_color,
             extend       = extend.right
         )

// === ALERT CONDITIONS ONLY (no chart labels) ===
crossed_above_high = not na(active_high) and ta.crossover(close,  active_high)
crossed_below_low  = not na(active_low)  and ta.crossunder(close, active_low)

alertcondition(crossed_above_high, "Price Crossed Above Prior Day High",
     "Price crossed ABOVE prior day high: {{ticker}} @ {{close}}")
alertcondition(crossed_below_low,  "Price Crossed Below Prior Day Low",
     "Price crossed BELOW prior day low: {{ticker}} @ {{close}}")
alertcondition(crossed_above_high or crossed_below_low, "Price Crossed Either Prior Day Level",
     "Price crossed a prior day RTH level: {{ticker}} @ {{close}}")
````
