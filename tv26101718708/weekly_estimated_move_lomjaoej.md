# Weekly Estimated Move

- url: https://www.tradingview.com/script/lOMJAOEJ-Weekly-Estimated-Move/
- type: indicator
- pine_id: PUB;2237552abd424cbda4fbe529d40a3926
- version: 1.0

## Description

Weekly Estimated Move (WEM) plots the projected high and low price range for the current week based on a user-input expected move value. Upper and lower bands are drawn from Monday's open and persist through the week, giving a visual framework for where price is statistically expected to trade. Useful for identifying potential support, resistance, and breakout zones around the weekly range. Includes optional labels and customizable line styling.

## Source Code

````pine
//@version=5
indicator("Weekly Estimated Move", overlay=true, shorttitle="WEM")

// ─── Input ────────────────────────────────────────────────
all_weeks = input.string("", title="Weekly Levels")
line_width = input.int(2, title="Line Width", minval=1, maxval=4)

// ─── Storage ──────────────────────────────────────────────
var float[] t_starts  = array.new_float(0)
var float[] t_ends    = array.new_float(0)
var float[] uppers    = array.new_float(0)
var float[] lowers    = array.new_float(0)
var string  prev_input = ""
var line[]  all_lines  = array.new_line(0)
var label[] all_labels = array.new_label(0)

// ─── Reparse on input change ──────────────────────────────
if all_weeks != prev_input
    prev_input := all_weeks
    for l in all_lines
        line.delete(l)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)
    array.clear(t_starts)
    array.clear(t_ends)
    array.clear(uppers)
    array.clear(lowers)
    if str.length(all_weeks) > 0
        weeks = str.split(all_weeks, ";")
        for i = 0 to array.size(weeks) - 1
            entry = str.trim(array.get(weeks, i))
            if str.length(entry) > 5
                parts = str.split(entry, ",")
                if array.size(parts) == 4
                    sp = str.split(array.get(parts, 0), "/")
                    ep = str.split(array.get(parts, 1), "/")
                    u  = str.tonumber(array.get(parts, 2))
                    l  = str.tonumber(array.get(parts, 3))
                    t1 = timestamp(
                         int(str.tonumber(array.get(sp, 0))),
                         int(str.tonumber(array.get(sp, 1))),
                         int(str.tonumber(array.get(sp, 2))), 0, 0)
                    t2 = timestamp(
                         int(str.tonumber(array.get(ep, 0))),
                         int(str.tonumber(array.get(ep, 1))),
                         int(str.tonumber(array.get(ep, 2))), 23, 59)
                    if not na(u) and not na(l)
                        array.push(t_starts, t1)
                        array.push(t_ends,   t2)
                        array.push(uppers,   u)
                        array.push(lowers,   l)
                        lu = line.new(t1, u, t2, u,
                             xloc=xloc.bar_time,
                             color=color.blue,
                             width=line_width,
                             style=line.style_solid)
                        ll = line.new(t1, l, t2, l,
                             xloc=xloc.bar_time,
                             color=color.blue,
                             width=line_width,
                             style=line.style_solid)
                        lbu = label.new(t2, u,
                             xloc=xloc.bar_time,
                             text=" " + str.tostring(u, "#.00"),
                             style=label.style_label_left,
                             color=color.new(color.blue, 85),
                             textcolor=color.blue, size=size.small)
                        lbl = label.new(t2, l,
                             xloc=xloc.bar_time,
                             text=" " + str.tostring(l, "#.00"),
                             style=label.style_label_left,
                             color=color.new(color.blue, 85),
                             textcolor=color.blue, size=size.small)
                        array.push(all_lines, lu)
                        array.push(all_lines, ll)
                        array.push(all_labels, lbu)
                        array.push(all_labels, lbl)

// ─── Find active week on each bar ─────────────────────────
float upper_val = na
float lower_val = na
n = array.size(uppers)
if n > 0
    for i = 0 to n - 1
        if time >= array.get(t_starts, i) and time <= array.get(t_ends, i)
            upper_val := array.get(uppers, i)
            lower_val := array.get(lowers, i)

// ─── Orange dot — only on actual price cross ──────────────
var float last_close_vs_upper = na
var float last_close_vs_lower = na

bool cross_upper = false
bool cross_lower = false

if not na(upper_val)
    if not na(last_close_vs_upper)
        cross_upper := (close > upper_val and last_close_vs_upper < upper_val) or
                       (close < upper_val and last_close_vs_upper > upper_val)
    last_close_vs_upper := close

if not na(lower_val)
    if not na(last_close_vs_lower)
        cross_lower := (close > lower_val and last_close_vs_lower < lower_val) or
                       (close < lower_val and last_close_vs_lower > lower_val)
    last_close_vs_lower := close

plotshape(cross_upper ? upper_val : na,
          style=shape.circle,
          location=location.absolute,
          color=color.new(color.orange, 0),
          size=size.small,
          title="Cross Upper")

plotshape(cross_lower ? lower_val : na,
          style=shape.circle,
          location=location.absolute,
          color=color.new(color.orange, 0),
          size=size.small,
          title="Cross Lower")
````
