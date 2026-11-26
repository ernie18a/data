# HTF Candle Box [rare_gold_steak]

- url: https://www.tradingview.com/script/mTlOHcXn-HTF-Candle-Box-rare-gold-steak/
- type: indicator
- pine_id: PUB;d5fa507cf6df468d9a8f52e5719903e9
- version: 2.0

## Description

See the bigger picture

This indicator will overlay higher timeframe candles directly on your chart, so you can see the structure far more clearly. Whether you're on 1H showing 1D candles, or on 1D showing Weekly candles, it will make price easier to read at a glance

Plots the box as a normal candle would:
[list]
[*] Open — where price started the day
[*] Close — where price ended the day
[*] High — highest point reached
[*] Low — lowest point reached
[/list]

Everything is customizable. Enjoy

## Source Code

````pine
//@version=5
indicator("HTF Candle Box [rare_gold_steak]", overlay=true, max_lines_count=500, max_boxes_count=500)

htf_input = input.timeframe("D", "Box Timeframe", group="General Settings")

max_history = input.int(25, "Max Candles to Keep", minval=1, maxval=500, group="History Settings", tooltip="Number of historical HTF candle boxes to display. Capped by max_boxes_count (500).")

box_border_color = input.color(color.new(color.black, 0), "Border Color", group="Box Appearance")
box_bg_color     = input.color(color.new(#4dd0e1, 30), "Background Color", group="Box Appearance")
box_border_width = input.int(2, "Border Width", minval=1, group="Box Appearance")

// ── Auto Color Settings ────────────────────────────────────────────────────
auto_color_enabled = input.bool(true, "Auto Color (Bullish / Bearish)", group="Auto Color Settings",
     tooltip="When enabled, each HTF candle box is colored by direction instead of the fixed Background Color above.\nBullish (close ≥ open) → Bullish Color. Bearish (close < open) → Bearish Color.")
auto_color_bull    = input.color(color.new(#26a69a, 30), "Bullish Color", group="Auto Color Settings")
auto_color_bear    = input.color(color.new(#ef5350, 30), "Bearish Color", group="Auto Color Settings")
// ──────────────────────────────────────────────────────────────────────────

show_wicks_input  = input.bool(true, "Show Wicks", group="Wick Settings", tooltip="Box becomes the body (open→close); wicks extend to the high and low.")
wick_color        = input.color(color.new(#f72828, 0), "Wick Color", group="Wick Settings")
wick_width        = input.int(4, "Wick Width", minval=1, group="Wick Settings")

show_wick_shadow  = input.bool(true, "Show Wick Shadow", group="Wick Shadow Settings", tooltip="Draws a wider line behind each wick to simulate a shadow/glow.")
wick_shadow_color = input.color(color.new(#000000, 5), "Wick Shadow Color", group="Wick Shadow Settings")
wick_shadow_width = input.int(6, "Wick Shadow Width", minval=1, group="Wick Shadow Settings", tooltip="Should be larger than Wick Width to be visible behind it.")

f_bg_color(is_bull) =>
    auto_color_enabled ? (is_bull ? auto_color_bull : auto_color_bear) : box_bg_color

var box   htf_box    = na
var line  upper_wick = na
var line  lower_wick = na

var line  upper_wick_shadow = na
var line  lower_wick_shadow = na

var box[]  old_boxes              = array.new<box>()
var line[] old_upper_wicks        = array.new<line>()
var line[] old_lower_wicks        = array.new<line>()
var line[] old_upper_wick_shadows = array.new<line>()
var line[] old_lower_wick_shadows = array.new<line>()

[htf_high, htf_low, htf_open, htf_close, htf_time_open, htf_time_close] = request.security(
     syminfo.tickerid, htf_input,
     [high, low, open, close, time, time_close],
     lookahead = barmerge.lookahead_on)

bool is_new_htf_bar = ta.change(htf_time_open)

if is_new_htf_bar
    if not na(htf_box)
        array.push(old_boxes,              htf_box)
        array.push(old_upper_wicks,        upper_wick)
        array.push(old_lower_wicks,        lower_wick)
        array.push(old_upper_wick_shadows, upper_wick_shadow)
        array.push(old_lower_wick_shadows, lower_wick_shadow)

    while array.size(old_boxes) > max_history
        box.delete (array.shift(old_boxes))
        line.delete(array.shift(old_upper_wicks))
        line.delete(array.shift(old_lower_wicks))
        line.delete(array.shift(old_upper_wick_shadows))
        line.delete(array.shift(old_lower_wick_shadows))

    float box_top    = show_wicks_input ? math.max(htf_open, htf_close) : htf_high
    float box_bottom = show_wicks_input ? math.min(htf_open, htf_close) : htf_low
    int   mid_time   = htf_time_open + (htf_time_close - htf_time_open) / 2

    htf_box := box.new(
         left         = htf_time_open,
         top          = box_top,
         right        = htf_time_close,
         bottom       = box_bottom,
         xloc         = xloc.bar_time,
         border_color = box_border_color,
         bgcolor      = f_bg_color(htf_close >= htf_open),
         border_width = box_border_width)

    if show_wicks_input
        upper_wick_shadow := show_wick_shadow ?
             line.new(x1=mid_time, y1=box_top,    x2=mid_time, y2=htf_high,
                  xloc=xloc.bar_time, color=wick_shadow_color, width=wick_shadow_width) : na
        lower_wick_shadow := show_wick_shadow ?
             line.new(x1=mid_time, y1=box_bottom, x2=mid_time, y2=htf_low,
                  xloc=xloc.bar_time, color=wick_shadow_color, width=wick_shadow_width) : na

        upper_wick := line.new(x1=mid_time, y1=box_top,    x2=mid_time, y2=htf_high,
             xloc=xloc.bar_time, color=wick_color, width=wick_width)
        lower_wick := line.new(x1=mid_time, y1=box_bottom, x2=mid_time, y2=htf_low,
             xloc=xloc.bar_time, color=wick_color, width=wick_width)
    else
        upper_wick        := na
        lower_wick        := na
        upper_wick_shadow := na
        lower_wick_shadow := na

if not na(htf_box)
    float body_top    = math.max(htf_open, htf_close)
    float body_bottom = math.min(htf_open, htf_close)
    float box_top     = show_wicks_input ? body_top    : htf_high
    float box_bottom  = show_wicks_input ? body_bottom : htf_low
    int   mid_time    = htf_time_open + (htf_time_close - htf_time_open) / 2

    box.set_top          (htf_box, box_top)
    box.set_bottom       (htf_box, box_bottom)
    box.set_right        (htf_box, htf_time_close)
    box.set_bgcolor      (htf_box, f_bg_color(htf_close >= htf_open))
    box.set_border_color (htf_box, box_border_color)
    box.set_border_width (htf_box, box_border_width)

    if show_wicks_input and not na(upper_wick)
        if show_wick_shadow and not na(upper_wick_shadow)
            line.set_x1   (upper_wick_shadow, mid_time)
            line.set_x2   (upper_wick_shadow, mid_time)
            line.set_y1   (upper_wick_shadow, body_top)
            line.set_y2   (upper_wick_shadow, htf_high)
            line.set_color(upper_wick_shadow, wick_shadow_color)
            line.set_width(upper_wick_shadow, wick_shadow_width)

            line.set_x1   (lower_wick_shadow, mid_time)
            line.set_x2   (lower_wick_shadow, mid_time)
            line.set_y1   (lower_wick_shadow, body_bottom)
            line.set_y2   (lower_wick_shadow, htf_low)
            line.set_color(lower_wick_shadow, wick_shadow_color)
            line.set_width(lower_wick_shadow, wick_shadow_width)

        line.set_x1   (upper_wick, mid_time)
        line.set_x2   (upper_wick, mid_time)
        line.set_y1   (upper_wick, body_top)
        line.set_y2   (upper_wick, htf_high)
        line.set_color(upper_wick, wick_color)
        line.set_width(upper_wick, wick_width)

        line.set_x1   (lower_wick, mid_time)
        line.set_x2   (lower_wick, mid_time)
        line.set_y1   (lower_wick, body_bottom)
        line.set_y2   (lower_wick, htf_low)
        line.set_color(lower_wick, wick_color)
        line.set_width(lower_wick, wick_width)
````
