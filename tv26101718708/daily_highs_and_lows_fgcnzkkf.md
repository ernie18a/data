# daily highs and lows

- url: https://www.tradingview.com/script/FgcnZkKf-daily-highs-and-lows/
- type: indicator
- pine_id: PUB;17c5d122552043589ddd87c90d1d9db3
- version: 1.0

## Description

Here's a clean, simple description:
Plots the highest high and lowest low over a set number of days directly on your chart. Useful for quickly spotting key support and resistance levels without any clutter.
Settings:
Days — how far back to look
Color — line color
Line Width — thickness of the lines
Show Labels — toggle the H/L labels on or off
Extend Right — extends the lines to the right of the chart
Solid line is the high, dashed line is the low.

## Source Code

````pine
//@version=5
indicator("Period High & Low", overlay=true, max_lines_count=2, max_labels_count=2)

days = input.int(5, "Days")
col = input.color(color.new(#2962FF, 0), "Color")
line_width = input.int(1, "Line Width", minval=1, maxval=4)
show_labels = input.bool(true, "Show Labels")
extend_right = input.bool(true, "Extend Right")

bars = days * math.max(1, math.round(86400 / timeframe.in_seconds()))

ph = ta.highest(high, bars)
pl = ta.lowest(low, bars)

ext = extend_right ? extend.right : extend.none

var line hi_line = na
var line lo_line = na
var label hi_lbl = na
var label lo_lbl = na

if barstate.islast or barstate.isconfirmed
    line.delete(hi_line)
    line.delete(lo_line)
    label.delete(hi_lbl)
    label.delete(lo_lbl)

    hi_line := line.new(bar_index - bars + 1, ph, bar_index, ph, color=col, width=line_width, extend=ext)
    lo_line := line.new(bar_index - bars + 1, pl, bar_index, pl, color=col, width=line_width, extend=ext, style=line.style_dashed)

    if show_labels
        hi_lbl := label.new(bar_index, ph, str.tostring(days) + "D H: " + str.tostring(ph, format.mintick), color=color.new(col, 80), textcolor=col, style=label.style_label_left, size=size.small)
        lo_lbl := label.new(bar_index, pl, str.tostring(days) + "D L: " + str.tostring(pl, format.mintick), color=color.new(col, 80), textcolor=col, style=label.style_label_left, size=size.small)
````
