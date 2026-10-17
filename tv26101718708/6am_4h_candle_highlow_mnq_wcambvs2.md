# 6AM 4H Candle High/Low - MNQ

- url: https://www.tradingview.com/script/WcAMbvs2-6AM-4H-Candle-High-Low-MNQ/
- type: indicator
- pine_id: PUB;c5f7b012d6984c8f9e5418d9bea2563d
- version: 1.0

## Description

This indicator automatically marks the high and low of the 6:00 AM (New York time) 4-hour candle on MNQ/NQ futures with horizontal lines, making it easy to identify key levels for your trading session.
Designed specifically for backtesting and intraday analysis, the lines update each day with the most recent 6AM candle and work across all timeframes — whether you're on the 1m, 5m, 15m, 1H, or 4H chart the levels stay locked in place.

## Source Code

````pine
//@version=6
indicator("6AM 4H Candle High/Low - MNQ", overlay=true, max_lines_count=500, max_labels_count=500)

lineColor_high = input.color(color.new(color.green, 0), "High Line Color")
lineColor_low  = input.color(color.new(color.red, 0),   "Low Line Color")
lineWidth      = input.int(2, "Line Width", minval=1, maxval=4)
showLabels     = input.bool(true, "Show Labels")
lineLength     = input.int(200, "Line Length (bars)", minval=10, step=100)

[h4_high, h4_low, h4_hour, h4_time] = request.security(syminfo.tickerid, "240",
     [high, low, hour(time, "America/New_York"), time],
     lookahead=barmerge.lookahead_on)

var float level_high = na
var float level_low  = na
var int   start_time = na

if h4_hour == 6
    level_high := h4_high
    level_low  := h4_low
    start_time := h4_time

var line high_line = na
var line low_line  = na
var label high_lbl = na
var label low_lbl  = na

if not na(level_high) and not na(start_time)
    if not na(high_line)
        line.delete(high_line)
    if not na(low_line)
        line.delete(low_line)
    if not na(high_lbl)
        label.delete(high_lbl)
    if not na(low_lbl)
        label.delete(low_lbl)

    tf_ms    = timeframe.in_seconds() * 1000 * lineLength
    end_time = start_time + tf_ms

    high_line := line.new(x1=start_time, y1=level_high, x2=end_time, y2=level_high, xloc=xloc.bar_time, color=lineColor_high, width=lineWidth, style=line.style_solid)
    low_line  := line.new(x1=start_time, y1=level_low,  x2=end_time, y2=level_low,  xloc=xloc.bar_time, color=lineColor_low,  width=lineWidth, style=line.style_solid)

    if showLabels
        high_lbl := label.new(x=start_time, y=level_high, text="6AM H: " + str.tostring(level_high, format.mintick), xloc=xloc.bar_time, color=lineColor_high, textcolor=color.white, style=label.style_label_right, size=size.small)
        low_lbl  := label.new(x=start_time, y=level_low,  text="6AM L: " + str.tostring(level_low,  format.mintick), xloc=xloc.bar_time, color=lineColor_low,  textcolor=color.white, style=label.style_label_right, size=size.small)
````
