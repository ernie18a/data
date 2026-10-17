# NDOG / NWOG Levels (NMN_trades)

- url: https://www.tradingview.com/script/mdwCy4TD-NDOG-NWOG-Levels-NMN-trades/
- type: indicator
- pine_id: PUB;ced80fe249604ebe9e784e8acef7060c
- version: 1.0

## Description

Best NDOG/NWOG indicator you will find out there...

## Source Code

````pine
//@version=6
indicator("NDOG / NWOG Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS ───
show_ndog      = input.bool(true,        "Show NDOG",         group = "NDOG")
max_ndog       = input.int(50,           "Max NDOGs",         minval = 1, maxval = 100, group = "NDOG")
ndog_col_high  = input.color(color.black,"NDOG High/Low",     group = "NDOG")
ndog_col_mid   = input.color(color.red,  "NDOG 0.5 Mid",      group = "NDOG")
ndog_col_q     = input.color(color.aqua, "NDOG 0.25/0.75",    group = "NDOG")

show_nwog      = input.bool(true,         "Show NWOG",        group = "NWOG")
max_nwog       = input.int(50,            "Max NWOGs",        minval = 1, maxval = 100, group = "NWOG")
nwog_col_high  = input.color(color.black, "NWOG High/Low",    group = "NWOG")
nwog_col_mid   = input.color(color.orange,"NWOG 0.5 Mid",     group = "NWOG")
nwog_col_q     = input.color(color.yellow,"NWOG 0.25/0.75",   group = "NWOG")

lw_hl  = input.int(2, "High/Low Width", minval = 1, maxval = 4, group = "Style")
lw_mid = input.int(2, "Mid Width",      minval = 1, maxval = 4, group = "Style")
lw_q   = input.int(1, "Quarter Width",  minval = 1, maxval = 4, group = "Style")

TZ = "America/New_York"

// ─── HELPERS ───
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

// ─── GAP STORAGE ───
var float[] ndog_hi = array.new<float>(0)
var float[] ndog_lo = array.new<float>(0)
var int[]   ndog_ts = array.new<int>(0)
var int[]   ndog_bi = array.new<int>(0)

var float[] nwog_hi = array.new<float>(0)
var float[] nwog_lo = array.new<float>(0)
var int[]   nwog_ts = array.new<int>(0)
var int[]   nwog_bi = array.new<int>(0)

// ─── DETECT GAPS ───
is_ndog_bar = f_minute_cross(18, 0) and dow() >= 2 and dow() <= 6
if is_ndog_bar and show_ndog
    gap_top = math.max(close[1], open)
    gap_bot = math.min(close[1], open)
    if gap_top != gap_bot
        array.push(ndog_hi, gap_top)
        array.push(ndog_lo, gap_bot)
        array.push(ndog_ts, time)
        array.push(ndog_bi, bar_index)
        if array.size(ndog_hi) > max_ndog
            array.shift(ndog_hi)
            array.shift(ndog_lo)
            array.shift(ndog_ts)
            array.shift(ndog_bi)

is_nwog_bar = f_minute_cross(18, 0) and dow() == 1
if is_nwog_bar and show_nwog
    gap_top = math.max(close[1], open)
    gap_bot = math.min(close[1], open)
    if gap_top != gap_bot
        array.push(nwog_hi, gap_top)
        array.push(nwog_lo, gap_bot)
        array.push(nwog_ts, time)
        array.push(nwog_bi, bar_index)
        if array.size(nwog_hi) > max_nwog
            array.shift(nwog_hi)
            array.shift(nwog_lo)
            array.shift(nwog_ts)
            array.shift(nwog_bi)

// ─── DRAW ───
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
                      xloc   = xloc.bar_time,
                      color  = c,
                      width  = lw,
                      extend = extend.right,
                      style  = line.style_solid)
        array.push(all_lines, ln)

        txt = switch
            lvl == 1.0 => prefix + " High · " + date_str + "  " + p_str
            lvl == 0.0 => prefix + " Low · "  + date_str + "  " + p_str
            =>            lname + "  " + p_str

        lc = lvl == 0.0 or lvl == 1.0 ? c_high : c

        lb = label.new(last_bar_index + 1, price, txt,
                       xloc      = xloc.bar_index,
                       yloc      = yloc.price,
                       color     = color.new(color.white, 100),
                       textcolor = lc,
                       style     = label.style_none,
                       size      = size.small)
        array.push(all_labels, lb)

if barstate.islast
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)

    if show_ndog
        n = array.size(ndog_hi)
        if n > 0
            for i = 0 to n - 1
                f_draw_gap(array.get(ndog_hi, i), array.get(ndog_lo, i),
                           array.get(ndog_ts, i), array.get(ndog_bi, i),
                           "NDOG", ndog_col_high, ndog_col_mid, ndog_col_q)

    if show_nwog
        n = array.size(nwog_hi)
        if n > 0
            for i = 0 to n - 1
                f_draw_gap(array.get(nwog_hi, i), array.get(nwog_lo, i),
                           array.get(nwog_ts, i), array.get(nwog_bi, i),
                           "NWOG", nwog_col_high, nwog_col_mid, nwog_col_q)
````
