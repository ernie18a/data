# R-GAP  Kill Zones and Overnight Gap Tracker

- url: https://www.tradingview.com/script/YEnxNdkj-R-GAP-Kill-Zones-and-Overnight-Gap-Tracker/
- type: indicator
- pine_id: PUB;37da605738dc4d5cad9d91a4b7cd329c
- version: 2.0

## Description

**R-GAP** is an advanced TradingView indicator designed for traders who focus on market sessions, liquidity behavior, and overnight price inefficiencies.
It combines customizable **Kill Zones**, an automatic **11PM → 3AM overnight GAP detector**, and a dynamic reference line system based on precise 1-minute timing.

### Main Features

* Fully customizable **Kill Zones**

  * Up to 3 independent sessions
  * Adjustable colors, transparency, and timezone
  * Automatic high/low range boxes
  * Intraday-only display option

* Automatic **Overnight GAP Detection**

  * Detects the price gap between the **11PM close** and the **3AM open**
  * Uses anchored H1 data for accuracy
  * Draws a visual GAP box directly on the chart
  * Displays the exact GAP size with labels

* Dynamic **11PM → 3AM Reference Line**

  * Drawn using a dedicated 1-minute internal clock
  * Fully customizable style, width, and color
  * Helps visualize overnight equilibrium and liquidity levels

* Smart historical cleanup system

  * Automatically removes old boxes and lines
  * Optimized for performance on large histories

* Built-in alert system

  * Kill Zone session start alerts
  * GAP start and GAP completion alerts

### Ideal For

This indicator is especially useful for traders using:

* ICT / Smart Money Concepts
* Session-based trading
* Liquidity sweeps
* NY / London session models
* Overnight imbalance analysis
* Futures and index trading

### Designed For Precision

R-GAP was built to provide clean institutional-style session visualization while remaining lightweight and highly configurable for discretionary or systematic traders.

## Source Code

````pine
//@version=6
indicator("R-GAP killzone", overlay=true, max_boxes_count=2000, max_lines_count=500)

// === PARAMÈTRES KILL ZONES ===
group_kz = "Kill Zones"
show_kz = input.bool(true, "Afficher Kill Zones", group=group_kz)
only_intraday = input.bool(true, "Afficher KZ uniquement en intraday", group=group_kz)
timezone_input = input.string("America/New_York", "Fuseau Horaire", group=group_kz)
max_history_days = input.int(365, "Historique max (jours)", minval=1, maxval=600, group=group_kz)

kz1_session = input.session("0200-0500", "KZ1 - Horaires", group=group_kz)
kz1_color   = input.color(color.orange, "KZ1 - Couleur", group=group_kz)
kz1_show    = input.bool(true, "Afficher KZ1", inline="kz1", group=group_kz)
kz1_transp  = input.int(80, "KZ1 - Transparence", 0, 100, group=group_kz, inline="kz1")

kz2_session = input.session("0700-1100", "KZ2 - Horaires", group=group_kz)
kz2_color   = input.color(color.red, "KZ2 - Couleur", group=group_kz)
kz2_show    = input.bool(true, "Afficher KZ2", inline="kz2", group=group_kz)
kz2_transp  = input.int(80, "KZ2 - Transparence", 0, 100, group=group_kz, inline="kz2")

kz3_session = input.session("1400-1700", "KZ3 - Horaires", group=group_kz)
kz3_color   = input.color(color.blue, "KZ3 - Couleur", group=group_kz)
kz3_show    = input.bool(true, "Afficher KZ3", inline="kz3", group=group_kz)
kz3_transp  = input.int(80, "KZ3 - Transparence", 0, 100, group=group_kz, inline="kz3")

// === PARAMÈTRES GAP ===
group_gap = "GAP"
show_gap = input.bool(true, "Afficher GAP", group=group_gap)
gap_color = input.color(color.purple, "Couleur du GAP", group=group_gap)
gap_transp = input.int(80, "GAP - Transparence", 0, 100, group=group_gap)

// === PARAMÈTRES LIGNE 11H → 3H ===
group_line = "Ligne 11h → 3h"
show_11h_line = input.bool(true, "Afficher ligne 11h-3h", group=group_line)
line_color = input.color(color.yellow, "Couleur ligne", group=group_line)
line_style_input = input.string("Solide", "Style", options=["Solide", "Pointillés", "Tirets"], group=group_line)
line_width = input.int(2, "Épaisseur", minval=1, maxval=5, group=group_line)

// === HORLOGE 1 MINUTE (pour la ligne jaune uniquement) ===
var string REF_TF = "1"
ref_time  = request.security(syminfo.tickerid, REF_TF, time,  barmerge.gaps_off, barmerge.lookahead_off)
ref_close = request.security(syminfo.tickerid, REF_TF, close, barmerge.gaps_off, barmerge.lookahead_off)
ref_hour  = hour(ref_time, timezone_input)
ref_min   = minute(ref_time, timezone_input)
ref_day   = dayofmonth(ref_time, timezone_input)

// === ARRAYS ===
var array<box>  kz1_boxes      = array.new<box>()
var array<box>  kz2_boxes      = array.new<box>()
var array<box>  kz3_boxes      = array.new<box>()
var array<box>  gap_boxes      = array.new<box>()
var array<line> line_11h_array = array.new<line>()

// === VARIABLES TEMPORAIRES ===
var float kz1_high = na
var float kz1_low  = na
var int   kz1_start = na
var box   kz1_current_box = na

var float kz2_high = na
var float kz2_low  = na
var int   kz2_start = na
var box   kz2_current_box = na

var float kz3_high = na
var float kz3_low  = na
var int   kz3_start = na
var box   kz3_current_box = na

// === VARIABLES LIGNE JAUNE ===
var int   last_11h_day   = na
var line  current_line   = na
var float line_price     = na
var int   line_start_time = na

// === FONCTIONS UTILITAIRES ===
in_session(sess) =>
    t = time(timeframe.period, sess, timezone_input)
    not na(t)

clean_old_boxes(arr, max_days) =>
    max_time = max_days * 86400000
    arr_size = array.size(arr)
    if arr_size > 0
        for i = arr_size - 1 to 0
            b = array.get(arr, i)
            if not na(b) and (time - box.get_left(b) > max_time)
                box.delete(b)
                array.remove(arr, i)

clean_old_lines(arr, max_days) =>
    max_time = max_days * 86400000
    arr_size = array.size(arr)
    if arr_size > 0
        for i = arr_size - 1 to 0
            l = array.get(arr, i)
            if not na(l) and (time - line.get_x1(l) > max_time)
                line.delete(l)
                array.remove(arr, i)

update_box_colors(arr, col, transp) =>
    arr_size = array.size(arr)
    if arr_size > 0
        for i = 0 to arr_size - 1
            b = array.get(arr, i)
            if not na(b)
                box.set_border_color(b, color.new(col, transp))
                box.set_bgcolor(b, color.new(col, transp))

// === STYLE LIGNE ===
line_style = line_style_input == "Pointillés" ? line.style_dotted : line_style_input == "Tirets" ? line.style_dashed : line.style_solid
_can_draw_kz = show_kz and (not only_intraday or timeframe.isintraday)

// === KILL ZONES ===
if _can_draw_kz and kz1_show
    active  = in_session(kz1_session)
    started = active and not active[1]
    ended   = not active and active[1]
    if started
        kz1_high := high
        kz1_low  := low
        kz1_start := time
    else if active
        if not na(kz1_high)
            kz1_high := math.max(kz1_high, high)
            kz1_low  := math.min(kz1_low, low)
            if not na(kz1_current_box)
                box.delete(kz1_current_box)
            kz1_current_box := box.new(left=kz1_start, top=kz1_high, right=time, bottom=kz1_low, xloc=xloc.bar_time, border_color=color.new(kz1_color, kz1_transp), bgcolor=color.new(kz1_color, kz1_transp))
    else if ended and not na(kz1_current_box)
        array.push(kz1_boxes, kz1_current_box)
        kz1_current_box := na
        kz1_high := na
        kz1_low := na
        kz1_start := na

if _can_draw_kz and kz2_show
    active2  = in_session(kz2_session)
    started2 = active2 and not active2[1]
    ended2   = not active2 and active2[1]
    if started2
        kz2_high := high
        kz2_low  := low
        kz2_start := time
    else if active2
        if not na(kz2_high)
            kz2_high := math.max(kz2_high, high)
            kz2_low  := math.min(kz2_low, low)
            if not na(kz2_current_box)
                box.delete(kz2_current_box)
            kz2_current_box := box.new(left=kz2_start, top=kz2_high, right=time, bottom=kz2_low, xloc=xloc.bar_time, border_color=color.new(kz2_color, kz2_transp), bgcolor=color.new(kz2_color, kz2_transp))
    else if ended2 and not na(kz2_current_box)
        array.push(kz2_boxes, kz2_current_box)
        kz2_current_box := na
        kz2_high := na
        kz2_low := na
        kz2_start := na

if _can_draw_kz and kz3_show
    active3  = in_session(kz3_session)
    started3 = active3 and not active3[1]
    ended3   = not active3 and active3[1]
    if started3
        kz3_high := high
        kz3_low  := low
        kz3_start := time
    else if active3
        if not na(kz3_high)
            kz3_high := math.max(kz3_high, high)
            kz3_low  := math.min(kz3_low, low)
            if not na(kz3_current_box)
                box.delete(kz3_current_box)
            kz3_current_box := box.new(left=kz3_start, top=kz3_high, right=time, bottom=kz3_low, xloc=xloc.bar_time, border_color=color.new(kz3_color, kz3_transp), bgcolor=color.new(kz3_color, kz3_transp))
    else if ended3 and not na(kz3_current_box)
        array.push(kz3_boxes, kz3_current_box)
        kz3_current_box := na
        kz3_high := na
        kz3_low := na
        kz3_start := na

// === GAP ANCRÉ H1 (11h → 3h le lendemain) ===
var string GAP_TF = "60"
h_time  = request.security(syminfo.tickerid, GAP_TF, time,  barmerge.gaps_off, barmerge.lookahead_off)
h_open  = request.security(syminfo.tickerid, GAP_TF, open,  barmerge.gaps_off, barmerge.lookahead_off)
h_close = request.security(syminfo.tickerid, GAP_TF, close, barmerge.gaps_off, barmerge.lookahead_off)
h_hour  = hour(h_time, timezone_input)
h_day   = dayofmonth(h_time, timezone_input)

var float gap_start_price = na
var int   gap_start_time  = na
is_11_bar = h_hour == 11
is_03_bar = h_hour == 3

if show_gap and is_11_bar and not is_11_bar[1]
    gap_start_price := h_close
    gap_start_time := h_time

if show_gap and is_03_bar and not is_03_bar[1] and not na(gap_start_price)
    if h_day != dayofmonth(gap_start_time, timezone_input)
        gap_end_price = h_open
        hi = math.max(gap_start_price, gap_end_price)
        lo = math.min(gap_start_price, gap_end_price)
        b_gap = box.new(left=gap_start_time, top=hi, right=h_time, bottom=lo, xloc=xloc.bar_time, border_color=color.new(gap_color, gap_transp), bgcolor=color.new(gap_color, gap_transp))
        array.push(gap_boxes, b_gap)
        label.new(x=h_time, y=(hi + lo)/2, text="GAP: " + str.tostring(hi - lo, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, textcolor=color.white, size=size.small, color=gap_color)
        gap_start_price := na
        gap_start_time := na

// === LIGNE JAUNE 11H → 3H (horloge 1m) ===
is_11h = ref_hour == 11 and ref_min == 0
is_3h  = ref_hour == 3 and ref_min == 0

if show_11h_line
    if is_11h and (na(last_11h_day) or ref_day != last_11h_day)
        line_price := ref_close
        line_start_time := ref_time
        if not na(current_line)
            line.delete(current_line)
        current_line := line.new(x1=line_start_time, y1=line_price, x2=line_start_time + 1, y2=line_price, xloc=xloc.bar_time, extend=extend.right, color=line_color, style=line_style, width=line_width)
        last_11h_day := ref_day

    if is_3h and not na(current_line) and not na(line_start_time)
        if dayofmonth(ref_time - 86400000, timezone_input) == last_11h_day
            line.set_x2(current_line, ref_time)
            line.set_extend(current_line, extend.none)
            array.push(line_11h_array, current_line)
            current_line := na
            line_start_time := na
            line_price := na

// === NETTOYAGE ===
if barstate.islast
    clean_old_boxes(kz1_boxes, max_history_days)
    clean_old_boxes(kz2_boxes, max_history_days)
    clean_old_boxes(kz3_boxes, max_history_days)
    clean_old_boxes(gap_boxes, max_history_days)
    clean_old_lines(line_11h_array, max_history_days)
    update_box_colors(kz1_boxes, kz1_color, kz1_transp)
    update_box_colors(kz2_boxes, kz2_color, kz2_transp)
    update_box_colors(kz3_boxes, kz3_color, kz3_transp)
    update_box_colors(gap_boxes, gap_color, gap_transp)

// === ALERTES ===
alertcondition(in_session(kz1_session) and not in_session(kz1_session)[1], "Entrée KZ1", "Entrée Kill Zone 1")
alertcondition(in_session(kz2_session) and not in_session(kz2_session)[1], "Entrée KZ2", "Entrée Kill Zone 2")
alertcondition(in_session(kz3_session) and not in_session(kz3_session)[1], "Entrée KZ3", "Entrée Kill Zone 3")
alertcondition(show_gap and is_11_bar and not is_11_bar[1], "Début GAP 11h", "Début GAP H1 11h")
alertcondition(show_gap and is_03_bar and not is_03_bar[1], "Fin GAP 3h", "Fin GAP H1 3h")
````
