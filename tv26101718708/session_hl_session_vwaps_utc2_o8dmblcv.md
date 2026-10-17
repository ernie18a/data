# Session H/L + Session Vwaps [UTC+2]

- url: https://www.tradingview.com/script/o8dmBLcv/
- type: indicator
- pine_id: PUB;1a54ce5e4aaa43c6a5b96c42f7a0322a
- version: 1.0

## Description

a simple yet Effective Indicator with multiple configurable Vwaps and Session Liquidity Zones

## Source Code

````pine
//@version=6
indicator("All-in-One Futures Scalping v3 [UTC+2]", overlay=true, max_bars_back=1000, max_lines_count=500, max_labels_count=200)

// ============================================================
// ===              EINSTELLUNGEN / INPUTS                  ===
// ============================================================

// --- VWAP ZEITEN (UTC+2) ---
grp_vwap = "3x Anchored VWAP"
show_vwap_asia  = input.bool(true,  "Asien VWAP anzeigen",    group=grp_vwap)
show_vwap_lon   = input.bool(true,  "London VWAP anzeigen",   group=grp_vwap)
show_vwap_ny    = input.bool(true,  "New York VWAP anzeigen", group=grp_vwap)
show_vwap_bands = input.bool(true,  "±1σ / ±2σ Bänder",      group=grp_vwap)

asia_vwap_h  = input.int(0,  "Asien Start Stunde (UTC+2)",    minval=0, maxval=23, group=grp_vwap)
asia_vwap_m  = input.int(0,  "Asien Start Minute",            minval=0, maxval=59, group=grp_vwap)
lon_vwap_h   = input.int(9,  "London Start Stunde (UTC+2)",   minval=0, maxval=23, group=grp_vwap)
lon_vwap_m   = input.int(0,  "London Start Minute",           minval=0, maxval=59, group=grp_vwap)
ny_vwap_h    = input.int(15, "New York Start Stunde (UTC+2)", minval=0, maxval=23, group=grp_vwap)
ny_vwap_m    = input.int(30, "New York Start Minute",         minval=0, maxval=59, group=grp_vwap)

vwap_end_h   = input.int(22, "VWAP Ende Stunde (UTC+2)",      minval=0, maxval=23, group=grp_vwap)
vwap_end_m   = input.int(0,  "VWAP Ende Minute",              minval=0, maxval=59, group=grp_vwap)

col_vwap_asia = input.color(color.new(#FFD700, 0),  "Asien VWAP Farbe",    group=grp_vwap)
col_vwap_lon  = input.color(color.new(#00FF88, 0),  "London VWAP Farbe",   group=grp_vwap)
col_vwap_ny   = input.color(color.new(#FF6B6B, 0),  "NY VWAP Farbe",       group=grp_vwap)

// --- SESSION H/L LINIEN ---
grp_sess = "Session Highs & Lows"
show_hl         = input.bool(true, "Session H/L anzeigen",    group=grp_sess)

asia_hl_h1  = input.int(0,  "Asien Start Stunde (UTC+2)",    minval=0, maxval=23, group=grp_sess)
asia_hl_m1  = input.int(0,  "Asien Start Minute",            minval=0, maxval=59, group=grp_sess)
asia_hl_h2  = input.int(8,  "Asien Ende Stunde (UTC+2)",     minval=0, maxval=23, group=grp_sess)
asia_hl_m2  = input.int(0,  "Asien Ende Minute",             minval=0, maxval=59, group=grp_sess)

lon_hl_h1   = input.int(9,  "London Start Stunde (UTC+2)",   minval=0, maxval=23, group=grp_sess)
lon_hl_m1   = input.int(0,  "London Start Minute",           minval=0, maxval=59, group=grp_sess)
lon_hl_h2   = input.int(15, "London Ende Stunde (UTC+2)",    minval=0, maxval=23, group=grp_sess)
lon_hl_m2   = input.int(30, "London Ende Minute",            minval=0, maxval=59, group=grp_sess)

ny_hl_h1    = input.int(15, "New York Start Stunde (UTC+2)", minval=0, maxval=23, group=grp_sess)
ny_hl_m1    = input.int(30, "New York Start Minute",         minval=0, maxval=59, group=grp_sess)
ny_hl_h2    = input.int(21, "New York Ende Stunde (UTC+2)",  minval=0, maxval=23, group=grp_sess)
ny_hl_m2    = input.int(45, "New York Ende Minute",          minval=0, maxval=59, group=grp_sess)

col_asia_h  = input.color(#FFD700, "Asien High Farbe",   group=grp_sess)
col_asia_l  = input.color(#FFD700, "Asien Low Farbe",    group=grp_sess)
col_lon_h   = input.color(#00FF88, "London High Farbe",  group=grp_sess)
col_lon_l   = input.color(#00FF88, "London Low Farbe",   group=grp_sess)
col_ny_h    = input.color(#FF6B6B, "NY High Farbe",      group=grp_sess)
col_ny_l    = input.color(#FF6B6B, "NY Low Farbe",       group=grp_sess)
hl_width    = input.int(1, "Linienbreite H/L", minval=1, maxval=4, group=grp_sess)

// ============================================================
// ===         HILFSFUNKTIONEN - ZEITKONVERTIERUNG          ===
// ============================================================

utc_offset_ms = 2 * 60 * 60 * 1000
cur_time_utc2 = time + utc_offset_ms
cur_h = hour(cur_time_utc2, "UTC")
cur_m = minute(cur_time_utc2, "UTC")
cur_total_m = cur_h * 60 + cur_m

f_in_range(h1, m1, h2, m2) =>
    start = h1 * 60 + m1
    end_  = h2 * 60 + m2
    cur_total_m >= start and cur_total_m < end_

f_is_exact(h, m) =>
    cur_h == h and cur_m == m

is_new_day = ta.change(time("D", "UTC+2")) != 0

// ============================================================
// ===            3x ANCHORED VWAP BERECHNUNG               ===
// ============================================================

typical = (high + low + close) / 3.0

f_vwap_calc(pv, vol, pv2) =>
    vwap_v = vol > 0 ? pv / vol : typical
    variance = vol > 0 ? math.max(pv2 / vol - vwap_v * vwap_v, 0.0) : 0.0
    sd = math.sqrt(variance)
    [vwap_v, vwap_v + sd, vwap_v - sd, vwap_v + 2 * sd, vwap_v - 2 * sd]

// ---- ASIEN VWAP ----
var float apv  = 0.0
var float avol = 0.0
var float apv2 = 0.0
var bool  a_active = false

asia_start = f_is_exact(asia_vwap_h, asia_vwap_m)
vwap_end   = f_is_exact(vwap_end_h,  vwap_end_m)

if is_new_day or asia_start
    apv  := 0.0
    avol := 0.0
    apv2 := 0.0
    a_active := true

if vwap_end
    a_active := false

if is_new_day and not f_in_range(asia_vwap_h, asia_vwap_m, vwap_end_h, vwap_end_m)
    a_active := false

if a_active
    apv  += typical * volume
    avol += volume
    apv2 += typical * typical * volume

[vwap_a, vwap_a_u1, vwap_a_d1, vwap_a_u2, vwap_a_d2] = f_vwap_calc(apv, avol, apv2)
vwap_a_plot   = (show_vwap_asia and a_active and avol > 0) ? vwap_a   : na
vwap_a_u1_p   = (show_vwap_asia and show_vwap_bands and a_active and avol > 0) ? vwap_a_u1 : na
vwap_a_d1_p   = (show_vwap_asia and show_vwap_bands and a_active and avol > 0) ? vwap_a_d1 : na
vwap_a_u2_p   = (show_vwap_asia and show_vwap_bands and a_active and avol > 0) ? vwap_a_u2 : na
vwap_a_d2_p   = (show_vwap_asia and show_vwap_bands and a_active and avol > 0) ? vwap_a_d2 : na

// ---- LONDON VWAP ----
var float lpv  = 0.0
var float lvol = 0.0
var float lpv2 = 0.0
var bool  l_active = false

lon_start = f_is_exact(lon_vwap_h, lon_vwap_m)

if is_new_day
    lpv  := 0.0
    lvol := 0.0
    lpv2 := 0.0
    l_active := false

if lon_start
    lpv  := 0.0
    lvol := 0.0
    lpv2 := 0.0
    l_active := true

if vwap_end
    l_active := false

if l_active
    lpv  += typical * volume
    lvol += volume
    lpv2 += typical * typical * volume

[vwap_l, vwap_l_u1, vwap_l_d1, vwap_l_u2, vwap_l_d2] = f_vwap_calc(lpv, lvol, lpv2)
vwap_l_plot   = (show_vwap_lon and l_active and lvol > 0) ? vwap_l   : na
vwap_l_u1_p   = (show_vwap_lon and show_vwap_bands and l_active and lvol > 0) ? vwap_l_u1 : na
vwap_l_d1_p   = (show_vwap_lon and show_vwap_bands and l_active and lvol > 0) ? vwap_l_d1 : na
vwap_l_u2_p   = (show_vwap_lon and show_vwap_bands and l_active and lvol > 0) ? vwap_l_u2 : na
vwap_l_d2_p   = (show_vwap_lon and show_vwap_bands and l_active and lvol > 0) ? vwap_l_d2 : na

// ---- NY VWAP ----
var float npv  = 0.0
var float nvol = 0.0
var float npv2 = 0.0
var bool  n_active = false

ny_start = f_is_exact(ny_vwap_h, ny_vwap_m)

if is_new_day
    npv  := 0.0
    nvol := 0.0
    npv2 := 0.0
    n_active := false

if ny_start
    npv  := 0.0
    nvol := 0.0
    npv2 := 0.0
    n_active := true

if vwap_end
    n_active := false

if n_active
    npv  += typical * volume
    nvol += volume
    npv2 += typical * typical * volume

[vwap_n, vwap_n_u1, vwap_n_d1, vwap_n_u2, vwap_n_d2] = f_vwap_calc(npv, nvol, npv2)
vwap_n_plot   = (show_vwap_ny and n_active and nvol > 0) ? vwap_n   : na
vwap_n_u1_p   = (show_vwap_ny and show_vwap_bands and n_active and nvol > 0) ? vwap_n_u1 : na
vwap_n_d1_p   = (show_vwap_ny and show_vwap_bands and n_active and nvol > 0) ? vwap_n_d1 : na
vwap_n_u2_p   = (show_vwap_ny and show_vwap_bands and n_active and nvol > 0) ? vwap_n_u2 : na
vwap_n_d2_p   = (show_vwap_ny and show_vwap_bands and n_active and nvol > 0) ? vwap_n_d2 : na

// ---- VWAP PLOTS ----
pa_v  = plot(vwap_a_plot, "Asia VWAP",    color=col_vwap_asia, linewidth=2)
pa_u1 = plot(vwap_a_u1_p, "Asia +1σ",    color=color.new(col_vwap_asia, 60), linewidth=1)
pa_d1 = plot(vwap_a_d1_p, "Asia -1σ",    color=color.new(col_vwap_asia, 60), linewidth=1)
pa_u2 = plot(vwap_a_u2_p, "Asia +2σ",    color=color.new(col_vwap_asia, 80), linewidth=1)
pa_d2 = plot(vwap_a_d2_p, "Asia -2σ",    color=color.new(col_vwap_asia, 80), linewidth=1)
fill(pa_u1, pa_d1, color=color.new(col_vwap_asia, 90))
fill(pa_u2, pa_u1, color=color.new(col_vwap_asia, 95))
fill(pa_d1, pa_d2, color=color.new(col_vwap_asia, 95))

pl_v  = plot(vwap_l_plot, "London VWAP",  color=col_vwap_lon,  linewidth=2)
pl_u1 = plot(vwap_l_u1_p, "London +1σ",  color=color.new(col_vwap_lon, 60), linewidth=1)
pl_d1 = plot(vwap_l_d1_p, "London -1σ",  color=color.new(col_vwap_lon, 60), linewidth=1)
pl_u2 = plot(vwap_l_u2_p, "London +2σ",  color=color.new(col_vwap_lon, 80), linewidth=1)
pl_d2 = plot(vwap_l_d2_p, "London -2σ",  color=color.new(col_vwap_lon, 80), linewidth=1)
fill(pl_u1, pl_d1, color=color.new(col_vwap_lon, 90))
fill(pl_u2, pl_u1, color=color.new(col_vwap_lon, 95))
fill(pl_d1, pl_d2, color=color.new(col_vwap_lon, 95))

pn_v  = plot(vwap_n_plot, "NY VWAP",      color=col_vwap_ny,   linewidth=2)
pn_u1 = plot(vwap_n_u1_p, "NY +1σ",      color=color.new(col_vwap_ny, 60), linewidth=1)
pn_d1 = plot(vwap_n_d1_p, "NY -1σ",      color=color.new(col_vwap_ny, 60), linewidth=1)
pn_u2 = plot(vwap_n_u2_p, "NY +2σ",      color=color.new(col_vwap_ny, 80), linewidth=1)
pn_d2 = plot(vwap_n_d2_p, "NY -2σ",      color=color.new(col_vwap_ny, 80), linewidth=1)
fill(pn_u1, pn_d1, color=color.new(col_vwap_ny, 90))
fill(pn_u2, pn_u1, color=color.new(col_vwap_ny, 95))
fill(pn_d1, pn_d2, color=color.new(col_vwap_ny, 95))

// ============================================================
// ===  SESSION H/L                                         ===
// ===  - Linie startet am ersten Bar der Session           ===
// ===  - Wird live aktualisiert wenn neues H/L entsteht   ===
// ===  - Kein Label                                        ===
// ===  - Nach Session-Ende: läuft bis zum Durchbruch      ===
// ============================================================

in_asia_sess = f_in_range(asia_hl_h1, asia_hl_m1, asia_hl_h2, asia_hl_m2)
in_lon_sess  = f_in_range(lon_hl_h1,  lon_hl_m1,  lon_hl_h2,  lon_hl_m2)
in_ny_sess   = f_in_range(ny_hl_h1,   ny_hl_m1,   ny_hl_h2,   ny_hl_m2)

// ---- ALLE VAR-DEKLARATIONEN ZUERST ----
var float asia_h        = na
var float asia_l        = na
var int   asia_h_x1     = na
var int   asia_l_x1     = na
var line  asia_h_line   = na
var line  asia_l_line   = na
var bool  asia_h_broken = false
var bool  asia_l_broken = false
var bool  was_in_asia   = false

var float lon_h        = na
var float lon_l        = na
var int   lon_h_x1     = na
var int   lon_l_x1     = na
var line  lon_h_line   = na
var line  lon_l_line   = na
var bool  lon_h_broken = false
var bool  lon_l_broken = false
var bool  was_in_lon   = false

var float ny_h        = na
var float ny_l        = na
var int   ny_h_x1     = na
var int   ny_l_x1     = na
var line  ny_h_line   = na
var line  ny_l_line   = na
var bool  ny_h_broken = false
var bool  ny_l_broken = false
var bool  was_in_ny   = false

// Merker: wurde die Session heute schon gestartet?
var bool asia_sess_started_today = false
var bool lon_sess_started_today  = false
var bool ny_sess_started_today   = false

was_in_asia := in_asia_sess
was_in_lon  := in_lon_sess
was_in_ny   := in_ny_sess

// Tageswechsel → Merker zurücksetzen (bestehende Linien laufen weiter!)
if is_new_day
    asia_sess_started_today := false
    lon_sess_started_today  := false
    ny_sess_started_today   := false

// Erster Bar einer neuen Session → Tracking-Vars und Linie neu starten
if in_asia_sess and not asia_sess_started_today
    asia_sess_started_today := true
    asia_h        := na
    asia_l        := na
    asia_h_x1     := na
    asia_l_x1     := na
    asia_h_broken := false
    asia_l_broken := false
    asia_h_line   := na
    asia_l_line   := na

if in_lon_sess and not lon_sess_started_today
    lon_sess_started_today := true
    lon_h        := na
    lon_l        := na
    lon_h_x1     := na
    lon_l_x1     := na
    lon_h_broken := false
    lon_l_broken := false
    lon_h_line   := na
    lon_l_line   := na

if in_ny_sess and not ny_sess_started_today
    ny_sess_started_today := true
    ny_h        := na
    ny_l        := na
    ny_h_x1     := na
    ny_l_x1     := na
    ny_h_broken := false
    ny_l_broken := false
    ny_h_line   := na
    ny_l_line   := na

// ---- ASIEN H/L LOGIK ----
if show_hl and in_asia_sess
    new_high = na(asia_h) ? high : math.max(asia_h, high)
    new_low  = na(asia_l) ? low  : math.min(asia_l, low)

    if na(asia_h_line)
        asia_h_x1   := bar_index
        asia_h_line := line.new(bar_index, high, bar_index, high, color=col_asia_h, width=hl_width, extend=extend.none)
    if na(asia_l_line)
        asia_l_x1   := bar_index
        asia_l_line := line.new(bar_index, low,  bar_index, low,  color=col_asia_l, width=hl_width, extend=extend.none)

    if new_high > asia_h or na(asia_h)
        asia_h_x1 := bar_index
        line.set_x1(asia_h_line, bar_index)
        line.set_y1(asia_h_line, new_high)
        line.set_y2(asia_h_line, new_high)

    if new_low < asia_l or na(asia_l)
        asia_l_x1 := bar_index
        line.set_x1(asia_l_line, bar_index)
        line.set_y1(asia_l_line, new_low)
        line.set_y2(asia_l_line, new_low)

    line.set_x2(asia_h_line, bar_index)
    line.set_x2(asia_l_line, bar_index)

    asia_h := new_high
    asia_l := new_low

if show_hl and not in_asia_sess and not na(asia_h_line)
    if not asia_h_broken
        if high >= asia_h
            line.set_x2(asia_h_line, bar_index)
            asia_h_broken := true
        else
            line.set_x2(asia_h_line, bar_index)
    if not asia_l_broken
        if low <= asia_l
            line.set_x2(asia_l_line, bar_index)
            asia_l_broken := true
        else
            line.set_x2(asia_l_line, bar_index)

// ---- LONDON H/L LOGIK ----
if show_hl and in_lon_sess
    new_high = na(lon_h) ? high : math.max(lon_h, high)
    new_low  = na(lon_l) ? low  : math.min(lon_l, low)

    if na(lon_h_line)
        lon_h_x1   := bar_index
        lon_h_line := line.new(bar_index, high, bar_index, high, color=col_lon_h, width=hl_width, extend=extend.none)
    if na(lon_l_line)
        lon_l_x1   := bar_index
        lon_l_line := line.new(bar_index, low,  bar_index, low,  color=col_lon_l, width=hl_width, extend=extend.none)

    if new_high > lon_h or na(lon_h)
        lon_h_x1 := bar_index
        line.set_x1(lon_h_line, bar_index)
        line.set_y1(lon_h_line, new_high)
        line.set_y2(lon_h_line, new_high)

    if new_low < lon_l or na(lon_l)
        lon_l_x1 := bar_index
        line.set_x1(lon_l_line, bar_index)
        line.set_y1(lon_l_line, new_low)
        line.set_y2(lon_l_line, new_low)

    line.set_x2(lon_h_line, bar_index)
    line.set_x2(lon_l_line, bar_index)

    lon_h := new_high
    lon_l := new_low

if show_hl and not in_lon_sess and not na(lon_h_line)
    if not lon_h_broken
        if high >= lon_h
            line.set_x2(lon_h_line, bar_index)
            lon_h_broken := true
        else
            line.set_x2(lon_h_line, bar_index)
    if not lon_l_broken
        if low <= lon_l
            line.set_x2(lon_l_line, bar_index)
            lon_l_broken := true
        else
            line.set_x2(lon_l_line, bar_index)

// ---- NEW YORK H/L LOGIK ----
if show_hl and in_ny_sess
    new_high = na(ny_h) ? high : math.max(ny_h, high)
    new_low  = na(ny_l) ? low  : math.min(ny_l, low)

    if na(ny_h_line)
        ny_h_x1   := bar_index
        ny_h_line := line.new(bar_index, high, bar_index, high, color=col_ny_h, width=hl_width, extend=extend.none)
    if na(ny_l_line)
        ny_l_x1   := bar_index
        ny_l_line := line.new(bar_index, low,  bar_index, low,  color=col_ny_l, width=hl_width, extend=extend.none)

    if new_high > ny_h or na(ny_h)
        ny_h_x1 := bar_index
        line.set_x1(ny_h_line, bar_index)
        line.set_y1(ny_h_line, new_high)
        line.set_y2(ny_h_line, new_high)

    if new_low < ny_l or na(ny_l)
        ny_l_x1 := bar_index
        line.set_x1(ny_l_line, bar_index)
        line.set_y1(ny_l_line, new_low)
        line.set_y2(ny_l_line, new_low)

    line.set_x2(ny_h_line, bar_index)
    line.set_x2(ny_l_line, bar_index)

    ny_h := new_high
    ny_l := new_low

if show_hl and not in_ny_sess and not na(ny_h_line)
    if not ny_h_broken
        if high >= ny_h
            line.set_x2(ny_h_line, bar_index)
            ny_h_broken := true
        else
            line.set_x2(ny_h_line, bar_index)
    if not ny_l_broken
        if low <= ny_l
            line.set_x2(ny_l_line, bar_index)
            ny_l_broken := true
        else
            line.set_x2(ny_l_line, bar_index)

// ============================================================
// ===                   INFO TABELLE                       ===
// ============================================================
var table tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(#1a1a2e, 5), border_color=color.new(color.white, 70), border_width=1)

if barstate.islast
    cur_utc2 = str.format("{0,time,HH:mm}", time + utc_offset_ms)
    sess_now = in_ny_sess ? "🗽 New York" : in_lon_sess ? "🇬🇧 London" : in_asia_sess ? "🌏 Asien" : "😴 Pause"

    table.cell(tbl, 0, 0, "⏰ UTC+2",      text_color=#00BFFF, text_size=size.small, bgcolor=color.new(#16213e, 0))
    table.cell(tbl, 1, 0, cur_utc2,         text_color=color.white, text_size=size.small, bgcolor=color.new(#16213e, 0))

    table.cell(tbl, 0, 1, "📍 Session",     text_color=#00FF88, text_size=size.small, bgcolor=color.new(#0f3460, 0))
    table.cell(tbl, 1, 1, sess_now,          text_color=color.white, text_size=size.small, bgcolor=color.new(#0f3460, 0))

    asia_vwap_str = avol > 0 and a_active ? str.tostring(math.round(vwap_a, 2)) : "–"
    lon_vwap_str  = lvol > 0 and l_active ? str.tostring(math.round(vwap_l, 2)) : "–"
    ny_vwap_str   = nvol > 0 and n_active ? str.tostring(math.round(vwap_n, 2)) : "–"

    table.cell(tbl, 0, 2, "🌏 Asia VWAP",  text_color=col_vwap_asia, text_size=size.small, bgcolor=color.new(#16213e, 0))
    table.cell(tbl, 1, 2, asia_vwap_str,    text_color=color.white, text_size=size.small, bgcolor=color.new(#16213e, 0))

    table.cell(tbl, 0, 3, "🇬🇧 Lon VWAP", text_color=col_vwap_lon,  text_size=size.small, bgcolor=color.new(#0f3460, 0))
    table.cell(tbl, 1, 3, lon_vwap_str,     text_color=color.white, text_size=size.small, bgcolor=color.new(#0f3460, 0))

    table.cell(tbl, 0, 4, "🗽 NY VWAP",    text_color=col_vwap_ny,   text_size=size.small, bgcolor=color.new(#16213e, 0))
    table.cell(tbl, 1, 4, ny_vwap_str,      text_color=color.white, text_size=size.small, bgcolor=color.new(#16213e, 0))

    hl_asia_status = asia_h_broken and asia_l_broken ? "✅ beide gebrochen" : asia_h_broken ? "⚡ High gebrochen" : asia_l_broken ? "⚡ Low gebrochen" : not na(asia_h) ? "🔲 aktiv" : "–"
    table.cell(tbl, 0, 5, "📏 AS H/L",     text_color=#A0A0FF, text_size=size.small, bgcolor=color.new(#0f3460, 0))
    table.cell(tbl, 1, 5, hl_asia_status,   text_color=color.white, text_size=size.small, bgcolor=color.new(#0f3460, 0))
````
