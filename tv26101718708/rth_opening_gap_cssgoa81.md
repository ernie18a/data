# RTH Opening Gap

- url: https://www.tradingview.com/script/CSsgOa81-RTH-Opening-Gap/
- type: indicator
- pine_id: PUB;f9b78b96009b4ce499192e2001110ea9
- version: 1.0

## Description

The Only RTH Gap indicator you need for ICT concepts!!!

## Source Code

````pine
//@version=6
indicator("RTH Opening Gap", overlay = true, max_lines_count = 500, max_labels_count = 500)

show_rth     = input.bool(true,          "Show RTH Gap",  group = "RTH")
max_rth      = input.int(5,              "Max RTH Gaps",  minval = 1, maxval = 20, group = "RTH")
rth_col_high = input.color(color.white,  "RTH High/Low",  group = "RTH")
rth_col_mid  = input.color(color.yellow, "RTH 0.5 Mid",   group = "RTH")
rth_col_q    = input.color(color.orange, "RTH 0.25/0.75", group = "RTH")
lw_hl  = input.int(2, "High/Low Width", minval = 1, maxval = 4, group = "Style")
lw_mid = input.int(2, "Mid Width",      minval = 1, maxval = 4, group = "Style")
lw_q   = input.int(1, "Quarter Width",  minval = 1, maxval = 4, group = "Style")

TZ = "America/New_York"

f_minute_cross(h, m) =>
    t      = hour(time, TZ) * 60 + minute(time, TZ)
    t_prev = hour(time[1], TZ) * 60 + minute(time[1], TZ)
    t >= h * 60 + m and t_prev < h * 60 + m

dow() => dayofweek(time, TZ)

f_date(t) =>
    d  = str.tostring(dayofmonth(t, TZ))
    mo = str.tostring(month(t, TZ))
    y  = str.tostring(year(t, TZ))
    dd = str.length(d)  < 2 ? "0" + d  : d
    mm = str.length(mo) < 2 ? "0" + mo : mo
    dd + "." + mm + "." + y

var float[] rth_hi = array.new<float>(0)
var float[] rth_lo = array.new<float>(0)
var int[]   rth_ts = array.new<int>(0)
var int[]   rth_bi = array.new<int>(0)
var float rth_prev_close = na

// 16:14 NY → letzter RTH Close Bar
is_rth_close = f_minute_cross(16, 15) and dow() >= 2 and dow() <= 6
if is_rth_close
    rth_prev_close := close[1]

// 09:30 NY → RTH Open
is_rth_open = f_minute_cross(9, 30) and dow() >= 2 and dow() <= 6
if is_rth_open and show_rth and not na(rth_prev_close)
    gap_top = math.max(rth_prev_close, open)
    gap_bot = math.min(rth_prev_close, open)
    if gap_top != gap_bot
        array.push(rth_hi, gap_top)
        array.push(rth_lo, gap_bot)
        array.push(rth_ts, time)
        array.push(rth_bi, bar_index)
        if array.size(rth_hi) > max_rth
            array.shift(rth_hi)
            array.shift(rth_lo)
            array.shift(rth_ts)
            array.shift(rth_bi)

var line[]  all_lines  = array.new<line>()
var label[] all_labels = array.new<label>()

f_draw_gap(hi, lo, ts, bi, prefix, c_high, c_mid, c_q) =>
    rng      = hi - lo
    date_str = f_date(ts)
    levels      = array.from(0.0, 0.25, 0.5, 0.75, 1.0)
    level_names = array.from("0", "0.25", "0.5", "0.75", "1")
    for i = 0 to 4
        lvl   = array.get(levels, i)
        price = lo + lvl * rng
        lname = array.get(level_names, i)
        p_str = str.tostring(price, "#.##")
        c  = lvl == 0.5 ? c_mid : lvl == 0.0 or lvl == 1.0 ? c_high : c_q
        lw = lvl == 0.5 ? lw_mid : lvl == 0.0 or lvl == 1.0 ? lw_hl : lw_q
        ln = line.new(ts, price, time, price,
                      xloc = xloc.bar_time, color = c, width = lw,
                      extend = extend.right, style = line.style_solid)
        array.push(all_lines, ln)
        txt = switch
            lvl == 1.0 => prefix + " High · " + date_str + "  " + p_str
            lvl == 0.0 => prefix + " Low · "  + date_str + "  " + p_str
            =>            lname + "  " + p_str
        lc = lvl == 0.0 or lvl == 1.0 ? c_high : c
        lb = label.new(last_bar_index + 1, price, txt,
                       xloc = xloc.bar_index, yloc = yloc.price,
                       color = color.new(color.white, 100), textcolor = lc,
                       style = label.style_none, size = size.small)
        array.push(all_labels, lb)

if barstate.islast
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)
    if show_rth
        n = array.size(rth_hi)
        if n > 0
            for i = 0 to n - 1
                f_draw_gap(array.get(rth_hi, i), array.get(rth_lo, i),
                           array.get(rth_ts, i), array.get(rth_bi, i),
                           "RTH", rth_col_high, rth_col_mid, rth_col_q)
````
