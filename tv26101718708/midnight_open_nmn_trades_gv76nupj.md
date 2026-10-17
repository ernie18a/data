# Midnight Open NMN Trades

- url: https://www.tradingview.com/script/gV76nUPj-Midnight-Open-NMN-Trades/
- type: indicator
- pine_id: PUB;d3819387857c48ea9aca41f8d8437eef
- version: 1.0

## Description

The only Midnight open indicator you need for ICT concepts

## Source Code

````pine
//@version=6
indicator("Midnight Open", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ─── INPUTS ───
show_mo  = input.bool(true,         "Show Midnight Open", group = "Midnight Open")
max_mo   = input.int(5,             "Max Lines",          minval = 1, maxval = 20, group = "Midnight Open")
mo_color = input.color(color.white, "Line Color",         group = "Midnight Open")
mo_width = input.int(1,             "Line Width",         minval = 1, maxval = 4,  group = "Midnight Open")
mo_style = input.string("Solid",    "Line Style",         options = ["Solid", "Dashed", "Dotted"], group = "Midnight Open")

TZ = "America/New_York"

f_date(t) =>
    d      = str.tostring(dayofmonth(t, TZ))
    mo_str = str.tostring(month(t, TZ))
    y      = str.tostring(year(t, TZ))
    dd     = str.length(d)      < 2 ? "0" + d      : d
    mm     = str.length(mo_str) < 2 ? "0" + mo_str : mo_str
    dd + "." + mm + "." + y

// ─── STORAGE ───
var float[] mo_price = array.new<float>(0)
var int[]   mo_ts    = array.new<int>(0)

// Detect exact midnight candle: hour == 0 and minute == 0
is_midnight = hour(time, TZ) == 0 and minute(time, TZ) == 0

if is_midnight and show_mo
    array.push(mo_price, open)
    array.push(mo_ts,    time)
    if array.size(mo_price) > max_mo
        array.shift(mo_price)
        array.shift(mo_ts)

// ─── DRAW ───
var line[]  all_lines  = array.new<line>()
var label[] all_labels = array.new<label>()

if barstate.islast
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)

    ls = mo_style == "Dashed" ? line.style_dashed : mo_style == "Dotted" ? line.style_dotted : line.style_solid

    if show_mo
        n = array.size(mo_price)
        if n > 0
            for i = 0 to n - 1
                price    = array.get(mo_price, i)
                ts       = array.get(mo_ts, i)
                date_str = f_date(ts)
                p_str    = str.tostring(price, "#.##")

                ln = line.new(ts, price, time, price,
                              xloc   = xloc.bar_time,
                              color  = mo_color,
                              width  = mo_width,
                              extend = extend.right,
                              style  = ls)
                array.push(all_lines, ln)

                lb = label.new(last_bar_index + 1, price, "MO · " + date_str + "  " + p_str,
                               xloc      = xloc.bar_index,
                               yloc      = yloc.price,
                               color     = color.new(color.white, 100),
                               textcolor = mo_color,
                               style     = label.style_none,
                               size      = size.small)
                array.push(all_labels, lb)
````
