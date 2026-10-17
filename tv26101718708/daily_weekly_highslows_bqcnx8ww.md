# Daily & Weekly Highs/Lows

- url: https://www.tradingview.com/script/BQcnx8ww/
- type: indicator
- pine_id: PUB;71aa57eb35ca4da1ba13867c1bc40057
- version: 1.0

## Description

**Daily & Weekly Highs/Lows — Liquidity Levels**

This indicator automatically displays the highs and lows of Daily and Weekly candles as horizontal dotted lines directly on your chart.

**Key features:**

- Plots liquidity levels (highs/lows) of the last N Daily and Weekly candles, configurable in the settings
- Levels **automatically disappear** once swept by price — only intact levels remain visible
- **Green** for highs, **red** for lows, consistent across Daily and Weekly for a clean chart
- When a Daily and Weekly level coincide, the label displays **"W  D"** to highlight the confluence — a stronger liquidity signal

**Settings:**
- Number of Daily levels to display (1 to 10)
- Number of Weekly levels to display (1 to 8)
- High and low colors
- Line width for Daily and Weekly
- Label text color (black or white depending on your theme)
- Proximity tolerance for D/W confluence detection

**Recommended use:**
Perfect for traders using an SMC/ICT approach or simply looking to track key liquidity levels on higher timeframes. Works on all instruments and all chart timeframes.

---

## Source Code

````pine
//@version=6
indicator("Daily & Weekly Highs/Lows", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show_daily   = input.bool(true, "Afficher Daily",  group="Daily")
show_weekly  = input.bool(true, "Afficher Weekly", group="Weekly")
high_color   = input.color(color.new(#4CAF50, 0), "Couleur High (D & W)")
low_color    = input.color(color.new(#F44336, 0), "Couleur Low  (D & W)")
d_line_width = input.int(1, "Épaisseur Daily",  minval=1, maxval=4, group="Daily")
w_line_width = input.int(2, "Épaisseur Weekly", minval=1, maxval=4, group="Weekly")
d_count      = input.int(5, "Nombre de jours",    minval=1, maxval=10, group="Daily")
w_count      = input.int(4, "Nombre de semaines", minval=1, maxval=8,  group="Weekly")
label_color  = input.color(color.black, "Couleur texte étiquettes")
prox_pct     = input.float(0.05, "Tolérance proximité D/W (%)", minval=0.01, maxval=1.0, step=0.01)

// ─── RÉCUPÉRATION ─────────────────────────────────────────────────────────────
d_high_src = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_on)
d_low_src  = request.security(syminfo.tickerid, "D", low,  lookahead=barmerge.lookahead_on)
d_time_src = request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_on)

w_high_src = request.security(syminfo.tickerid, "W", high, lookahead=barmerge.lookahead_on)
w_low_src  = request.security(syminfo.tickerid, "W", low,  lookahead=barmerge.lookahead_on)
w_time_src = request.security(syminfo.tickerid, "W", time, lookahead=barmerge.lookahead_on)

// ─── TABLEAUX ─────────────────────────────────────────────────────────────────
var float[] dh = array.new_float(10, na)
var float[] dl = array.new_float(10, na)
var int[]   dt = array.new_int(10, na)

var float[] wh = array.new_float(8, na)
var float[] wl = array.new_float(8, na)
var int[]   wt = array.new_int(8, na)

var bool[] dh_swept = array.new_bool(10, false)
var bool[] dl_swept = array.new_bool(10, false)
var bool[] wh_swept = array.new_bool(8, false)
var bool[] wl_swept = array.new_bool(8, false)

is_new_day = ta.change(d_time_src) != 0
if is_new_day or barstate.isfirst
    array.set(dh, 9, array.get(dh, 8))
    array.set(dh, 8, array.get(dh, 7))
    array.set(dh, 7, array.get(dh, 6))
    array.set(dh, 6, array.get(dh, 5))
    array.set(dh, 5, array.get(dh, 4))
    array.set(dh, 4, array.get(dh, 3))
    array.set(dh, 3, array.get(dh, 2))
    array.set(dh, 2, array.get(dh, 1))
    array.set(dh, 1, array.get(dh, 0))
    array.set(dl, 9, array.get(dl, 8))
    array.set(dl, 8, array.get(dl, 7))
    array.set(dl, 7, array.get(dl, 6))
    array.set(dl, 6, array.get(dl, 5))
    array.set(dl, 5, array.get(dl, 4))
    array.set(dl, 4, array.get(dl, 3))
    array.set(dl, 3, array.get(dl, 2))
    array.set(dl, 2, array.get(dl, 1))
    array.set(dl, 1, array.get(dl, 0))
    array.set(dt, 9, array.get(dt, 8))
    array.set(dt, 8, array.get(dt, 7))
    array.set(dt, 7, array.get(dt, 6))
    array.set(dt, 6, array.get(dt, 5))
    array.set(dt, 5, array.get(dt, 4))
    array.set(dt, 4, array.get(dt, 3))
    array.set(dt, 3, array.get(dt, 2))
    array.set(dt, 2, array.get(dt, 1))
    array.set(dt, 1, array.get(dt, 0))
    array.set(dh_swept, 9, array.get(dh_swept, 8))
    array.set(dh_swept, 8, array.get(dh_swept, 7))
    array.set(dh_swept, 7, array.get(dh_swept, 6))
    array.set(dh_swept, 6, array.get(dh_swept, 5))
    array.set(dh_swept, 5, array.get(dh_swept, 4))
    array.set(dh_swept, 4, array.get(dh_swept, 3))
    array.set(dh_swept, 3, array.get(dh_swept, 2))
    array.set(dh_swept, 2, array.get(dh_swept, 1))
    array.set(dh_swept, 1, array.get(dh_swept, 0))
    array.set(dl_swept, 9, array.get(dl_swept, 8))
    array.set(dl_swept, 8, array.get(dl_swept, 7))
    array.set(dl_swept, 7, array.get(dl_swept, 6))
    array.set(dl_swept, 6, array.get(dl_swept, 5))
    array.set(dl_swept, 5, array.get(dl_swept, 4))
    array.set(dl_swept, 4, array.get(dl_swept, 3))
    array.set(dl_swept, 3, array.get(dl_swept, 2))
    array.set(dl_swept, 2, array.get(dl_swept, 1))
    array.set(dl_swept, 1, array.get(dl_swept, 0))
    array.set(dh_swept, 0, false)
    array.set(dl_swept, 0, false)

array.set(dh, 0, d_high_src)
array.set(dl, 0, d_low_src)
array.set(dt, 0, d_time_src)

is_new_week = ta.change(w_time_src) != 0
if is_new_week or barstate.isfirst
    array.set(wh, 7, array.get(wh, 6))
    array.set(wh, 6, array.get(wh, 5))
    array.set(wh, 5, array.get(wh, 4))
    array.set(wh, 4, array.get(wh, 3))
    array.set(wh, 3, array.get(wh, 2))
    array.set(wh, 2, array.get(wh, 1))
    array.set(wh, 1, array.get(wh, 0))
    array.set(wl, 7, array.get(wl, 6))
    array.set(wl, 6, array.get(wl, 5))
    array.set(wl, 5, array.get(wl, 4))
    array.set(wl, 4, array.get(wl, 3))
    array.set(wl, 3, array.get(wl, 2))
    array.set(wl, 2, array.get(wl, 1))
    array.set(wl, 1, array.get(wl, 0))
    array.set(wt, 7, array.get(wt, 6))
    array.set(wt, 6, array.get(wt, 5))
    array.set(wt, 5, array.get(wt, 4))
    array.set(wt, 4, array.get(wt, 3))
    array.set(wt, 3, array.get(wt, 2))
    array.set(wt, 2, array.get(wt, 1))
    array.set(wt, 1, array.get(wt, 0))
    array.set(wh_swept, 7, array.get(wh_swept, 6))
    array.set(wh_swept, 6, array.get(wh_swept, 5))
    array.set(wh_swept, 5, array.get(wh_swept, 4))
    array.set(wh_swept, 4, array.get(wh_swept, 3))
    array.set(wh_swept, 3, array.get(wh_swept, 2))
    array.set(wh_swept, 2, array.get(wh_swept, 1))
    array.set(wh_swept, 1, array.get(wh_swept, 0))
    array.set(wl_swept, 7, array.get(wl_swept, 6))
    array.set(wl_swept, 6, array.get(wl_swept, 5))
    array.set(wl_swept, 5, array.get(wl_swept, 4))
    array.set(wl_swept, 4, array.get(wl_swept, 3))
    array.set(wl_swept, 3, array.get(wl_swept, 2))
    array.set(wl_swept, 2, array.get(wl_swept, 1))
    array.set(wl_swept, 1, array.get(wl_swept, 0))
    array.set(wh_swept, 0, false)
    array.set(wl_swept, 0, false)

array.set(wh, 0, w_high_src)
array.set(wl, 0, w_low_src)
array.set(wt, 0, w_time_src)

// ─── DÉTECTION SWEEP ─────────────────────────────────────────────────────────
for i = 1 to 9
    h = array.get(dh, i)
    l = array.get(dl, i)
    if not na(h) and high >= h
        array.set(dh_swept, i, true)
    if not na(l) and low <= l
        array.set(dl_swept, i, true)

for i = 1 to 7
    h = array.get(wh, i)
    l = array.get(wl, i)
    if not na(h) and high >= h
        array.set(wh_swept, i, true)
    if not na(l) and low <= l
        array.set(wl_swept, i, true)

// ─── FONCTION PROXIMITÉ ───────────────────────────────────────────────────────
f_close(a, b) =>
    not na(a) and not na(b) and math.abs(a - b) / b * 100 <= prox_pct

// ─── TRACÉ ────────────────────────────────────────────────────────────────────
if bar_index == last_bar_index

    if show_daily
        visible_d = 0
        i = 0
        while visible_d < d_count and i < 10
            t = array.get(dt, i)
            h = array.get(dh, i)
            l = array.get(dl, i)
            if not na(t) and not na(h) and not na(l)
                h_swept = array.get(dh_swept, i)
                l_swept = array.get(dl_swept, i)
                if not h_swept or not l_swept
                    visible_d := visible_d + 1
                if not h_swept
                    w_near_h = false
                    for j = 0 to w_count - 1
                        if f_close(h, array.get(wh, j)) and not array.get(wh_swept, j)
                            w_near_h := true
                    line.new(x1=t, y1=h, x2=time, y2=h,
                         color=high_color, style=line.style_dotted,
                         width=d_line_width, xloc=xloc.bar_time)
                    label.new(x=bar_index, y=h, text=w_near_h ? "W  D" : "D",
                         color=color.new(color.black, 100), textcolor=label_color,
                         style=label.style_none, size=size.tiny)
                if not l_swept
                    w_near_l = false
                    for j = 0 to w_count - 1
                        if f_close(l, array.get(wl, j)) and not array.get(wl_swept, j)
                            w_near_l := true
                    line.new(x1=t, y1=l, x2=time, y2=l,
                         color=low_color, style=line.style_dotted,
                         width=d_line_width, xloc=xloc.bar_time)
                    label.new(x=bar_index, y=l, text=w_near_l ? "W  D" : "D",
                         color=color.new(color.black, 100), textcolor=label_color,
                         style=label.style_none, size=size.tiny)
            i := i + 1

    if show_weekly
        visible_w = 0
        i = 0
        while visible_w < w_count and i < 8
            t = array.get(wt, i)
            h = array.get(wh, i)
            l = array.get(wl, i)
            if not na(t) and not na(h) and not na(l)
                h_swept = array.get(wh_swept, i)
                l_swept = array.get(wl_swept, i)
                if not h_swept or not l_swept
                    visible_w := visible_w + 1
                if not h_swept
                    d_near_h = false
                    for j = 0 to d_count - 1
                        if f_close(h, array.get(dh, j)) and not array.get(dh_swept, j)
                            d_near_h := true
                    line.new(x1=t, y1=h, x2=time, y2=h,
                         color=high_color, style=line.style_dotted,
                         width=w_line_width, xloc=xloc.bar_time)
                    label.new(x=bar_index, y=h, text=d_near_h ? "W  D" : "W",
                         color=color.new(color.black, 100), textcolor=label_color,
                         style=label.style_none, size=size.tiny)
                if not l_swept
                    d_near_l = false
                    for j = 0 to d_count - 1
                        if f_close(l, array.get(dl, j)) and not array.get(dl_swept, j)
                            d_near_l := true
                    line.new(x1=t, y1=l, x2=time, y2=l,
                         color=low_color, style=line.style_dotted,
                         width=w_line_width, xloc=xloc.bar_time)
                    label.new(x=bar_index, y=l, text=d_near_l ? "W  D" : "W",
                         color=color.new(color.black, 100), textcolor=label_color,
                         style=label.style_none, size=size.tiny)
            i := i + 1
````
